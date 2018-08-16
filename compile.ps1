# execute three commands
# armclient login
# ./compile.ps1 -Directory ./TestBlueprintScript > puts.ps1
# ./puts.ps1

param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Directory
)

$ErrorActionPreference = 'Stop';
function GenerateArmClientCommand([string] $fileName)
{
    $json = Get-Content -Path $fileName | ConvertFrom-Json;
    $resourceId = $json.id;

    # first param is the URL for the PUT, second param is the body of the request, contained in the file
    # there's some weird loop-ish type stuff going on - don't know how to describe it...
    return "armclient PUT $($resourceId)?api-version=2017-11-11-preview @$fileName";
}

# gets all the files in the given directory that end in .json
$files = Get-ChildItem -Path $Directory -Filter *.json;

foreach($file in $files)
{
    Write-Output (GenerateArmClientCommand -fileName $file.FullName);
}