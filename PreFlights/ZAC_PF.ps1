<#
#Run TaskKill on the following:
#ZAC
#OutlookSync
#ZAC Crash Handler
#>

$procArr = @("zac",
"ZultysCrashHandler",
"OutlookSync") 

foreach ($process in $procArr){
        Stop-Process -Name $process -PassThru
}