########################################
###Info###
#Function: Default install script for Telecom Apps.
#Version: 1.0
#Author: Brian Zerphey
####TODO###
#1. Fix if logic for MSI
#2. Make prerun and check a function.
#3. Create Log file.
#4. C:\TBSI_Repo folder check logic.
########################################
param (
    [Parameter(Position=0,mandatory=$true)]
    $file, #installer
    [Parameter(Position=1,mandatory=$true)]
    $name, #software name as it would appear in automate
    [Parameter(Position=2,mandatory=$true)]
    $version, #software version installing
    [Parameter(Mandatory=$false)]
    [string[]]$switch, #switch array
    [Parameter(Mandatory=$false)]
    $log #Logging 0/null for no logging, 1 for basic logging, 2 for verbose
)

###
#Real Work
###

Set-Location -Path "C:\TBSI_Repo"

#File Check
$installer = ".\" + $file

try {
    Test-Path $installer
}
catch {
    Write-Error "Install file not found."
}

#Installed Check
try {
    $arrProgram = Get-WmiObject -Class Win32_Product | where name -eq $name 

    If ($arrProgram -ne $null){
            Write-Error "A version of $($name) is already installed. Please remove and run again."
            exit
    }
}
catch {
    Write-Error "An error occured at prerun: $_"
}

#Run
if (([System.IO.Path]::GetExtension($file) -eq ".exe") -or ([System.IO.Path]::GetExtension($file) -eq ".EXE")) {
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
        Write-Error "An error occured in run for exe: $_"
    }
    
}else{#if (([System.IO.Path]::GetExtension($installfile) -eq ".msi") -or ([System.IO.Path]::GetExtension($installfile) -eq ".MSI")) {
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
        Write-Error "An error occured in run for msi: $_"
    }
}

#Confirm Installtion
$i += 1
try {
    $arrProgram = Get-WmiObject -Class Win32_Product | where name -eq $name 

    If (($arrProgram -ne $null) -and ($arrProgram.version = $version)){
            Write-Host "Program installed successfully."
    }else{
        Write-Error "Program did not install correctly."
    }
}
catch {
    Write-Error "An error occured at post install check: $_"
}
#The End