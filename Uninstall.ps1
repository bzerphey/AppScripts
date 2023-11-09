########################################
###Info###
#Function: Default uninistall script for Telecom Apps.
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
    [string[]]$switch, #full uninstall string
    [Parameter(Mandatory=$false)]
    [bool]$log = $false  #Logging 
)

###
#Functions
###
$LogFile = "C:\TBSI_Repo\Uninstall_$($name).log"

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

function RegSearch {
    param (
        [Parameter(Position=0,mandatory=$true)]
        $name, #software name as it would appear in automate
        [Parameter(Position=1,mandatory=$true)]
        $version, #software version installing
        [Parameter(Position=2,mandatory=$false)]
        $switch #software version installing
    )    

    $x86 = (Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | Where-Object DisplayName -like "*$($name)*").UninstallString
    $x64 = (Get-ItemProperty "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | Where-Object DisplayName -like "*$($name)*").UninstallString
    
    Logger -level INFO -message "Checking x86 installs..." -log $log

    if ($switch -ne $null){
        Logger -level INFO -message "Manual uninstall string supplied. Returning string." -log $log
        Return $string
    }elseif($x86 -ne $null) {
        Logger -level INFO -message "x86 string found. Returning string." -log $log
        Return $x86
    }elseif ($x64 -ne $null) {
        Logger -level INFO -message "x64 string found. Returning string." -log $log
        Return $x64
    } else {
        Logger -level ERROR -message "No uninstall string found. Please see your administrator" -log $log
    }
}

###
#Real Work
###

If(!(Test-Path -Path "C:\TBSI_Repo")){
    New-Item -ItemType Directory -Force -Path "C:\TBSI_Repo"
}

Logger -level INFO -message "Starting script..." -log $log

Logger -level INFO -message "Setting directory location..." -log $log

#Directory check/creation
Set-Location -Path "C:\TBSI_Repo"

#Installed Check
try {
    $arrProgram = Get-WmiObject -Class Win32_Product | where name -eq $name 

    If ($arrProgram -eq $null){
            Logger -level ERROR -message "$($name) is not found install on the system. Please see administrator." -log $log
            exit
    }
}
catch {
    Logger -level ERROR -message "An error occured at installed check: $_" -log $log
}

#Get uninstall string
Logger -level INFO -message "Getting uninstall string..." -log $log

$uString = RegSearch -name $name -version $version -switch $switch

#Uninstall
if ($uString -contains "MsiExec.exe /I"){
    $uString = $uString.replace('MsiExec.exe /I','')
    
    Logger -level INFO -message "Running uninstall..." -log $log

    Start-Process "MsiExec.exe /X$($switch) /qn" -Wait
}else {
    Logger -level INFO -message "Running uninstall..." -log $log

    Start-Process $switch -Wait
}

#Installed Check
try {
    $arrProgram = Get-WmiObject -Class Win32_Product | where name -eq $name 

    If ($arrProgram -ne $null){
            Logger -level ERROR -message "The uninstall did not complete. Program still shows installed." -log $log
            exit
    }
}
catch {
    Logger -level ERROR -message "An error occured at post check: $_" -log $log
}
