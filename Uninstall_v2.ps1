########################################
###Info###
#Function: Default install script for Telecom MSP/Managed Apps.
#Author: Brian Zerphey
########################################
param (
    [Parameter(Position=0,mandatory=$true)]
    $id, #json id
    [Parameter(Mandatory=$false)]
    [bool]$log = $True #Logging 
)

###
#Global Variables
###
$root = "https://raw.githubusercontent.com/bzerphey/AppScripts/main/"

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
    
    $url = $root + "software.json"

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

$LogFile = "C:\TBSI_Repo\Install_$(Get-Date -Format o | foreach {$_ -replace ":", "."}).log"

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

Logger -level INFO -message "Starting checks for $($name)" -log $log

Logger -level INFO -message "Checking for installations..." -log $log

#Installed Check
try {
    $arrProgram = Get-WmiObject -Class Win32_Product | where name -eq $name 

    If ($arrProgram -ne $null){
        if ($arrProgram.version -lt $version){
            Logger -level ERROR -message "An older version of $($name) has been found. Please run the appropriate script." -log $log
            exit
        }elseif ($arrProgram.version -gt $version){
            Logger -level ERROR -message "A newer version of $($name) has been found. Please run the appropriate script." -log $log
            exit
        }else {
            Logger -level INFO -message "$($name) has been found. Running uninstall." -log $log
        }

    }
}
catch {
    Logger -level ERROR -message "Program not found." -log $log
    Logger -level ERROR -message "An error occured at prerun: $_" -log $log
}