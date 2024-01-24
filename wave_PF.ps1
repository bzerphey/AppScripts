<#
#Run TaskKill on the following:
#OneDrive#>

$procArr = @("OneDrive") 

foreach ($process in $procArr){
        Stop-Process -Name $process -PassThru
}