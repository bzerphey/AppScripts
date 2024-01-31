<#
#Copy the needed folders for other MXAdmin versions
#>

$src = "https://file.ac/YzdYUQfTRc8/MXAdmin.zip"
$dst = "C:\TBSI_Repo\MXAdmin.zip"
$pfDST = "C:\Program Files (x86)\Zultys"

curl.exe $src -o $dst

Expand-Archive -LiteralPath $dst -DestinationPath $pfDST -Force

Move-Item -Path "$($pfDST)\MXAdminShortcuts" -Destination "C:\Users\Public\Desktop"