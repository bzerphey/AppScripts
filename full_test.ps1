########################################
###Info###
#Function: Script to test all JSON published apps.
#Author: Brian Zerphey
########################################

#Pull Json count
$url = "https://raw.githubusercontent.com/bzerphey/AppScripts/main/software.json"

$jsons = Invoke-RestMethod -Uri $url -UseBasicParsing -ContentType "application/json"

$jsons | ForEach-Object {
    $script = ".\Install_v2.ps1 -Id " + $_.ID
    & $script
}
