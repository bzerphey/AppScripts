<#
#Start the following:
#OneDrive
#>

$procArr = @("C:\Program Files\Microsoft OneDrive\OneDrive.exe") 

foreach ($process in $procArr){
        Start-Process $process -PassThru
}