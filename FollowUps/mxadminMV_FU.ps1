<#
#Copy the needed folders for other MXAdmin versions
#>

$src = "https://file.ac/YzdYUQfTRc8/"
$arrFolders = @("MXAdmin16.04",
"MXAdmin17.10",
"MXAdminShortcuts")

foreach ($folder in $arrFolders) {
    $dl = $src + $folder
    curl.exe $dl -o "C:\Program Files (x86)\Zultys\$($folder)\"
}