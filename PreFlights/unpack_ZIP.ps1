<#
#UnZip file
#>

#Directory check/creation
Set-Location -Path "C:\TBSI_Repo"

#Gather zip files
$targets = Get-ChildItem -Filter *.zip

foreach ($target in $targets)
{
    $target.toSting()
    $folderName = $target.trim("C:\TBSI_Repo\", ".zip")
    write-host $folderName

}