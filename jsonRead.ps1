function jsonRead {
    param (
        [Parameter(Position=0,mandatory=$true)]
        $swname, #software name as it would appear in automate
        [Parameter(Position=1,mandatory=$true)]
        $version #software version installing
    )
    
    $url = "https://raw.githubusercontent.com/bzerphey/AppScripts/main/test.json"

    $jsons = Invoke-RestMethod -Uri $url -UseBasicParsing -ContentType "application/json" | ConvertTo-Json

    $obj = $jsons | ConvertFrom-Json

    foreach ($sw in $obj){
        if ($sw.swname -eq $name) {
            if ($sw.version -eq $version) {
                return $json
            }
        }
    }
}

$jsonID = jsonRead -swname "Test1" -version "1.1.1"
Write-Host $jsonID.id