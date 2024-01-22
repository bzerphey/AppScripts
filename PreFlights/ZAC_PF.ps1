<#
#Run TaskKill on the following:
#ZAC
#OutlookSync
#ZAC Crash Handler
#>

$procArr = Get-Process

foreach ($proc in $procArr) {
    if (($proc.ProcessName -eq "zac") -or ($proc.ProcessName -eq "ZultysCrashHandler") -or ($proc.ProcessName -eq "OutlookSync")) {
        Stop-Process -Id $proc.ID -PassThru
    }else{
        Write-Host "No process found."
    }
}