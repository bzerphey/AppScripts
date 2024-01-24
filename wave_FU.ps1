<#
#Start the following:
#OneDrive
#>

$procArr = @("OneDrive") 

foreach ($process in $procArr){
        Start-Process -Name $process -PassThru
}