########################################
###Info###
#Function: Default install script for Telecom Apps.
#Author: Brian Zerphey
########################################
param (
    [Parameter(Position=0,mandatory=$true)]
    $file, #installer
    [Parameter(Position=1,mandatory=$true)]
    $name, #software name as it would appear in automate
    [Parameter(Position=2,mandatory=$true)]
    $version, #software version installing
    [Parameter(Position=3,mandatory=$true)]
    $fileDL, #download link for installer
    [Parameter(Mandatory=$false)]
    [string[]]$switch, #switch array
    [Parameter(Mandatory=$false)]
    [bool]$log = $false #Logging 
)

###
#Functions
###
$LogFile = "C:\TBSI_Repo\Install_$($name).log"

function Logger {
    param(
        [Parameter(Mandatory = $true)][string] $message,
        [Parameter(Mandatory = $false)] [ValidateSet("INFO","WARNING","ERROR")] [string] $level = "INFO",
        [Parameter(Mandatory = $true)][bool] $log
    )

    If ($log -eq $true){
        $Timestamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
        Add-Content -Path $LogFile -Value "$timestamp [$level] - $message"
    }
}

###
#Real Work
###

Logger -level INFO -message "Starting script..." -log $log

Logger -level INFO -message "Setting directory location..." -log $log
#Directory check/creation
Set-Location -Path "C:\TBSI_Repo"

#Download files
Logger -level INFO -message "Downloading install files..." -log $log

try {
    curl.exe $fileDL -o ".\$($file)"
}
catch {
    Logger -level ERROR -message "An error occured in curl request: $_" -log $log
    Exit
} 

#File Check
$installer = ".\" + $file

Logger -level INFO -message "Checking for install file..." -log $log

If (!(Test-Path -Path $installer)){
    Logger -level ERROR -message "Install file not found." -log $log
    Exit
}

Logger -level INFO -message "File found..." -log $log

Logger -level INFO -message "Checking for previous installations..." -log $log
#Installed Check
try {
    $arrProgram = Get-WmiObject -Class Win32_Product | where name -eq $name 

    If ($arrProgram -ne $null){
            Logger -level ERROR -message "A version of $($name) is already installed. Please remove and run again." -log $log
            exit
    }
}
catch {
    Logger -level ERROR -message "An error occured at prerun: $_" -log $log
}

Logger -level INFO -message "No installations found. Starting install..." -log $log
#Run
if (([System.IO.Path]::GetExtension($file) -eq ".exe") -or ([System.IO.Path]::GetExtension($file) -eq ".EXE")) {
    Logger -level INFO -message "Install file is an EXE. Starting EXE logic..." -log $log
    if ($switch -ne $null){
        $executeargs = $switch
    }Else{
        $executeargs = @(
            "/S" 
            "/v/qn"
        )
    }
    try {
        Start-Process $installer -Wait -ArgumentList $executeargs
    }
    catch {
        Logger -level ERROR -message "An error occured in run for exe: $_" -log $log
        Exit
    }
    
}else{#if (([System.IO.Path]::GetExtension($installfile) -eq ".msi") -or ([System.IO.Path]::GetExtension($installfile) -eq ".MSI")) {
    Logger -level INFO -message "Install file is an MSI. Starting MSI logic..." -log $log
    if ($switch -ne $null){
        $executeargs = @(
        "/i"
        "$($file)"
        "$($switch)"
        )
    }Else{$executeargs = @(
        "/i"
        "$($file)"
        "/qb"
        "/norestart"
        )
    }
    try {
        Start-Process "msiexec.exe" -Wait -ArgumentList $executeargs
    }
    catch {
        Logger -level ERROR -message "An error occured in run for msi: $_" -log $log
        Exit
    }
}

#Confirm Installtion
Logger -level INFO -message "Install complete. Performing followup..." -log $log
$i += 1
try {
    $arrProgram = Get-WmiObject -Class Win32_Product | where name -eq $name 

    If (($arrProgram -ne $null) -and ($arrProgram.version = $version)){
        Logger -level INFO -message "Program installed successfully." -log $log
    }else{
        Logger -level ERROR -message "Program did not install correctly." -log $log
    }
}
catch {
    Logger -level ERROR -message "An error occured at post install check: $_" -log $log
}

#The End