function jsonRead {
    param (
        [Parameter(Position=0,mandatory=$true)]
        $name, #software name as it would appear in automate
        [Parameter(Position=1,mandatory=$true)]
        $version #software version installing
    )
    
    $url = "https://raw.githubusercontent.com/bzerphey/AppScripts/main/test.json"

    $jsons = Invoke-RestMethod -Uri $url -UseBasicParsing -ContentType "application/json" | ConvertTo-Json

    $jsons | ConvertFrom-Json | Get-Member -MemberType NoteProperty | ForEach-Object { 
        Write-Host $_
        if ($_.swname -eq $name) {
            if ($_.version -eq $version) {
                return $json
            }
        }
    }
}

$jsonID = jsonRead -name "Test1" -version "1.1.1"
Write-Host $jsonID.id