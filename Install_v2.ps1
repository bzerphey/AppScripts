########################################
###Info###
#Function: Default install script for Telecom MSP/Managed Apps.
#Author: Brian Zerphey
########################################
param (
    [Parameter(Position=0,mandatory=$true)]
    $id, #json id
    [Parameter(Mandatory=$false)]
    [bool]$log = $false #Logging 
)

###
#Functions
###
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

function jsonRead {
    param (
        [Parameter(Position=0,mandatory=$true)]
        $id
    )
    
    $url = "https://raw.githubusercontent.com/bzerphey/AppScripts/main/software.json"

    $jsons = Invoke-RestMethod -Uri $url -UseBasicParsing -ContentType "application/json"

    $jsons | ForEach-Object {
        if ($_.id -eq $id) {
            return $_
        }
    }
}

###
#Real Work
###

If(!(Test-Path -Path "C:\TBSI_Repo")){
    New-Item -ItemType Directory -Force -Path "C:\TBSI_Repo"
}

#Logger -level INFO -message "Starting script..." -log $log

#Logger -level INFO -message "Setting directory location..." -log $log

#Directory check/creation
Set-Location -Path "C:\TBSI_Repo"

#Pull variables from json
#Logger -level INFO -message "Gathering variables..." -log $log
$var = jsonRead -id $id

if ($var -ne $null){
    $file = $var.file #installer
    $name = $var.name #software name as it would appear in automate
    $version = $var.version #software version installing
    $fileDL = $var.installLink #download link for installer
    $switch = $var.switches #switch array
    $PreFlight = $var.preflight #PreInstall tasks script
    $fuTask = $var.fuscript #Follow-up task script
}else{
    Logger -level ERROR -message "The variable request returned no data. Please check the ID and try again. If you continue to recieve this error, see your System Administrator.: $_" -log $log
    Exit
}

$LogFile = "C:\TBSI_Repo\Install_$(Get-Date -Format o | foreach {$_ -replace ":", "."}).log"

# Preflight tasks
Logger -level INFO -message "Checking for preflight tasks..." -log $log

if ($PreFlight -ne ""){
    Logger -level INFO -message "Preflight file found. Running task..." -log $log
    $pfDL = "https://raw.githubusercontent.com/bzerphey/AppScripts/main/" + $PreFlight
    curl.exe $pfDL -o ".\PF.ps1"
    Start-Process ".\PF.ps1 -name $($name) -log $log" -Wait
}else{
    Logger -level INFO -message "Preflight not found. Continuing script..." -log $log
}

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
        if (arrProgram.version -lt $version){
            Logger -level ERROR -message "A previous version of $($name) is already installed. Attempting install overtop." -log $log
        }elseif (arrProgram.version -gt $version){
            Logger -level ERROR -message "A newer version of $($name) is already installed. Please check installation." -log $log
            exit
        }else {
            Logger -level ERROR -message "$($name) is already installed." -log $log
            exit
        }

    }
}
catch {
    Logger -level ERROR -message "An error occured at prerun: $_" -log $log
}

Logger -level INFO -message "No installations found. Starting install..." -log $log

#Run
if (([System.IO.Path]::GetExtension($file) -eq ".exe") -or ([System.IO.Path]::GetExtension($file) -eq ".EXE")) {
    Logger -level INFO -message "Install file is an EXE. Starting EXE logic..." -log $log
    if ($switch -ne ""){
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

    if ($switch -ne ""){
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

#Follow-up task
Logger -level INFO -message "Checking for follow-up task..." -log $log

if($fuTask -ne ""){
    Logger -level INFO -message "Follow-up task found. Running script..." -log $log
    Start-Process ".\$($fuTask) -log $log" -Wait
}else{
    Logger -level INFO -message "No follow-up task found" -log $log
}

#Cleanup
Logger -level INFO -message "Starting Cleanup..." -log $log

Logger -level INFO -message "Removing install script..." -log $log
if (Test-Path -Path "C:\Windows\LTSvc\packages\Install.ps1"){
    try {
        Remove-Item -Path 'C:\Windows\LTSvc\packages\Install.ps1' -Force        
    }
    catch {
        Logger -level ERROR -message "Could not remove install.ps1. Please remove manually." -log $log
    }
}

Logger -level INFO -message "Removing install file..." -log $log
try {
    $inFileP = "C:\TBSI_Repo\" + $file
    Remove-Item -Path $inFileP -Force        
}
catch {
    Logger -level ERROR -message "Could not remove install file." -log $log
}

#The End#>