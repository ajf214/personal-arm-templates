<#PSScriptInfo

.VERSION 2.0

.GUID 0fc48522-2362-4cc0-b46d-e1d88d87b4e2

.AUTHOR jbritt@microsoft.com

.COMPANYNAME Microsoft

.COPYRIGHT Microsoft

.TAGS 

.LICENSEURI 

.PROJECTURI 
   https://aka.ms/ManageARMBlueprints/Video

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
   November 13, 2018
   * Added try/catch logic on json conversion to catch improper json files
   * Fixed an example in my get-help output
   * Thank you Jorge Cotillo (MSFT) AzureCAT for your inputs on improved logic for json validation!    
#>


<#  
.SYNOPSIS  
  Import, Export, or Report for an Azure Blueprint and related artifacts into or out of an Azure AD Management Group.
  
.DESCRIPTION  
  To learn how to use this script, please watch this video: https://aka.ms/ManageARMBlueprints/Video 

  This script takes a SubscriptionID, ManagementGroupID, BlueprintName, Mode switch, and an optional 
  NewBluePrintName as a parameter.  This script is meant to provide the ability to export an Azure
  ARM Blueprint for backup or import into an other Management Group.  You can also report on what artifacts are configured
  for a specific blueprint using the report mode.

  Use of "-Force" provides the ability to launch this script without prompting, if all required parameters are provided.

  NOTE: This version currently only supports exporting a latest full published version or current draft of a blueprint and
  related artifacts.

.PARAMETER SubscriptionId
    The subscriptionID of the Azure Subscription that is within the Azure AD tenant with your Blueprint or where
    you will be targeting for import of your Blueprint

.PARAMETER ManagementGroupID
    Use this to reference a Management Group to export a named Blueprint and artifacts

.PARAMETER NewBluePrintName
    Use this to update the Blueprint name on a selected Blueprint to a new name on import / export.

.PARAMETER BlueprintName
    Use this to bypass searching for a Blueprint during the script on export

.PARAMETER Mode
    Indicates mode of operation (Import/Export/Report) for a Blueprint

.PARAMETER ExportDir
    This is the base folder for exporting the Azure Blueprint data.  Example "Exports" or .\Exports or "c:\exports"

.PARAMETER ImportDir
    This is the base folder for importing a Blueprint and artifacts into an Azure AD Management Group. The folder would
    look something like ".\Exports\MG-Root\MyBlueprint" or "c:\exports\MG-Root\MyBlueprint"
 
 .PARAMETER Force
    Use Force to run silently [providing all parameters needed for silent mode]
    see get-help <scriptfile> -examples

 .PARAMETER ReportDir
    Use ReportDir in conjunction with report to export report results to a report directory

 .EXAMPLE
  .\Manage-AzureRMBlueprint.ps1 -Mode import -ImportDir .\BPExports\MG-root\MyBlueprint 
  Imports a blueprint from the relative path.  Will prompt for Azure Subscription to set context on AD Tenant

.EXAMPLE
  .\Manage-AzureRMBlueprint.ps1 -mode export -ManagementGroupID "<ManagementGroup where Blueprint is located>" -BlueprintName "<MyBlueprint>" -ExportDir "<Target Folder Name>"
  Take in parameters and exports a named blueprint and related artifacts to a sub directory named after the MG

.EXAMPLE
  .\Manage-AzureRMBlueprint.ps1 -mode export -ManagementGroupID "<ManagementGroup where Blueprint is located>" -BlueprintName "<MyBlueprint>" -ExportDir "Blueprints"
  Take in parameters and exports a named blueprint and related artifacts to a sub directory named after the new MG name
  This example allows you to export the named Managment Group in the blueprint and artifacts to a new one allowing you
  to import into another Azure AD tenant with a different naming / management group structure.

.EXAMPLE
  .\Manage-AzureRMBlueprint.ps1 -mode import -ImportDir ".\exports\MG-Root\MyBlueprint" -ManagementGroupID "<Target ManagementGroup for Blueprint>" -NewBlueprintName "<New Blueprint Name>"
  This will import a blueprint and artifacts from a source directory and targets a management group and new blueprint name on import

.EXAMPLE
  .\Manage-AzureRMBlueprint.ps1 -Mode Import -ImportDir ".\exports\MG-Root\MyBlueprint" -SubscriptionId "e69041bc-8e27-4272-9089-60ac8f508937" -force
  This will import a blueprint and artifacts from a source directory without prompting.

.EXAMPLE
  .\Manage-AzureRMBlueprint.ps1 -mode report -ManagementGroupID "<ManagementGroup where Blueprint is located>" -BlueprintName "<MyBlueprint>" -ReportDir "<Target Folder Name>" -SubscriptionID "<a SubscriptionID within the tenant you want to report from>"
  Take in parameters and exports a named blueprint and related artifacts to a sub directory named after the MG


.NOTES
   AUTHOR: Jim Britt Senior Program Manager - Azure CAT 
   LAST EDIT: November 13, 2018 ver 1.42
   * Added try/catch logic on json conversion to catch improper json files
   * Fixed an example in my get-help output
   * Thank you Jorge Cotillo (MSFT) AzureCAT for your inputs on improved logic for json validation!
   
   
   October 31, 2018 ver 1.41
   * Added more debug information to help in troubleshooting issues
   * Removed NewManagementGroupID and required ManagementGroupID as a parameter for import/report/export
   * Thank you Javier Soriano (MSFT) for the feedback and recommendations for a cleaner import experience!
   * Thank you Tao Yang (MVP) for your input around additional debug options
   * And special thanks to Aleksandar Nikolic (MVP) for your initial review and great feedback!

   October 24, 2018
   * Renamed ManagementGroup parameter to ManagementGroupID to make it clearer
   * Added ReportDir parameter to target a report directory
   * No longer navigating to script directory during execution
   * Updated Parameters / Sets in general - clean up


.LINK
    This script posted to and discussed at the following locations:
    https://aka.ms/ManageARMBlueprints/
    https://aka.ms/ManageARMBlueprints/Video
#>

<# 
REST API Documentation here: https://docs.microsoft.com/en-us/azure/governance/blueprints/create-blueprint-rest-api

Blueprints are available via the following rest endpoint within your Azure AD tenant.
https://management.azure.com/providers/Microsoft.Management/managementGroups/<MG-NAME>/providers/Microsoft.Blueprint/blueprints/<BLUEPRINT-NAME>?api-version=2017-11-11-preview

And to get the artifacts the following REST API endpoint is available:
https://management.azure.com/providers/Microsoft.Management/managementGroups/<MG-NAME>/providers/Microsoft.Blueprint/blueprints/<BLUEPRINT-NAME>/artifacts?api-version=2017-11-11-preview
#>
[cmdletbinding(
        DefaultParameterSetName='Default'
    )]

param
(
    # Mode (Export/Import/Report)
    [Parameter(ParameterSetName='Default',Mandatory = $True)]
    [Parameter(ParameterSetName='Import')]
    [Parameter(ParameterSetName='Export')]
    [Parameter(ParameterSetName='Report')]
    [ValidateSet("Export","Import","Report")]
    [String]$Mode,

    # The Management Group ID (***not the friendly name***)
    [Parameter(ParameterSetName='Import')]
    [Parameter(ParameterSetName='Export')]
    [Parameter(ParameterSetName='Report')]
    [string]$ManagementGroupID,

    # Use ReportDir to export a report of the selected Blueprint and related artifacts
    # Used with the report mode
    [Parameter(ParameterSetName='Report')]
    [string]$ReportDir,

    # The Blueprint Name
    [Parameter(ParameterSetName='Export')]
    [Parameter(ParameterSetName='Report')]
    [string]$BlueprintName,

    # Provide SubscriptionID to bypass subscription listing
    [Parameter(ParameterSetName='force')]
    [Parameter(ParameterSetName='Export')]
    [Parameter(ParameterSetName='Import')]
    [Parameter(ParameterSetName='Report')]
    [guid]$SubscriptionId,

    # New Blueprint Name
    [Parameter(ParameterSetName='Export')]
    [Parameter(ParameterSetName='Import')]
    [string]$NewBluePrintName,        

    <#
    # Draft or Published **** future use ****
    [Parameter(Mandatory=$False,ParameterSetName='Export')]
    [ValidateSet("Draft","Published")] 
    [string]$State,        

    # Published Blueprint Version **** future use ****
    [Parameter(Mandatory=$False,ParameterSetName='Export')]
    [string]$Version,        
    #>

    # Base folder for export
    [Parameter(Mandatory=$False,ParameterSetName='Export')]
    [string]$ExportDir,

    # Base folder for import
    [Parameter(ParameterSetName='Import')]
    [Parameter(ParameterSetName='force')]
    [string]$ImportDir,

    # Use Force to run in silent mode (requires certain parameters to be provided)
    [Parameter(ParameterSetName='Import')]
    [Parameter(ParameterSetName='force')]
    [switch]$Force

)

# Function used to build numbers in selection tables for menus
function Add-IndexNumberToArray (
    [Parameter(Mandatory=$True)]
    [array]$array
    )
{
    for($i=0; $i -lt $array.Count; $i++) 
    { 
        Add-Member -InputObject $array[$i] -Name "#" -Value ($i+1) -MemberType NoteProperty 
    }
    $array
}

# MAIN SCRIPT
# Determine where the script is running - build export dir
write-host "Please note this script is using a preview API for Azure Blueprint and is subject to change." -ForegroundColor Green
write-host "This script currently only supports Draft Blueprints or most recently published and related artifacts." -ForegroundColor DarkYellow
if ($MyInvocation.MyCommand.Path -ne $null)
{
    $CurrentDir = Split-Path $MyInvocation.MyCommand.Path
}
else
{
    # Sometimes $myinvocation is null, it depends on the PS console host
    $CurrentDir = "."
}
$APIVersion = "?api-version=2017-11-11-preview"
#cd $CurrentDir

# Determine what we are doing - export/import/report
if($Mode -eq "Export" -and !$ExportDir)
{
    Write-Host "Please " -NoNewline
    write-host "provide a directory " -NoNewline -ForegroundColor Yellow
    Write-Host "to EXPORT using the `$ExportDir parameter for your blueprint and artifacts"
    exit
}

if($Mode -eq "Import" -AND !$ImportDir)
{
    Write-Host "Please " -NoNewline
    write-host "provide a directory " -NoNewline -ForegroundColor Yellow
    write-host "to IMPORT using the `$ImportDir parameter for your blueprint and artifacts" 
    exit
}
If($Mode -eq "Report" -AND $ReportDir)
{
    IF(!$(Test-Path -Path "$ReportDir"))
    {
        write-host "Directory " -NoNewline
        Write-Host "$ReportDir " -ForegroundColor Yellow -NoNewline
        Write-Host "does not exist - please create and retry the operation"
        exit        
    }
}

# Login to Azure - if already logged in, use existing credentials.
Write-Host "Authenticating to Azure..." -ForegroundColor Cyan
try
{
    $AzureLogin = Get-AzureRmSubscription
}
catch
{
    $null = Login-AzureRmAccount
    $AzureLogin = Get-AzureRmSubscription
}

# Authenticate to Azure if not already authenticated 
# Ensure this is the subscription where your Management Groups are that house Blueprints for import/export operations
If($AzureLogin -and !($SubscriptionID))
{
    [array]$SubscriptionArray = Add-IndexNumberToArray (Get-AzureRmSubscription) 
    [int]$SelectedSub = 0

    # use the current subscription if there is only one subscription available
    if ($SubscriptionArray.Count -eq 1) 
    {
        $SelectedSub = 1
    }
    # Get SubscriptionID if one isn't provided
    while($SelectedSub -gt $SubscriptionArray.Count -or $SelectedSub -lt 1)
    {
        Write-host "Please select a subscription from the list below for the " -NoNewline
        write-host $Mode -ForegroundColor Yellow -NoNewline
        write-host " Operation"
        $SubscriptionArray | select "#", Name, ID | ft
        try
        {
            $SelectedSub = Read-Host "Please enter a selection from 1 to $($SubscriptionArray.count) for the $Mode Operation"
        }
        catch
        {
            Write-Warning -Message 'Invalid option, please try again.'
        }
    }
    if($($SubscriptionArray[$SelectedSub - 1].Name))
    {
        $SubscriptionName = $($SubscriptionArray[$SelectedSub - 1].Name)
    }
    elseif($($SubscriptionArray[$SelectedSub - 1].SubscriptionName))
    {
        $SubscriptionName = $($SubscriptionArray[$SelectedSub - 1].SubscriptionName)
    }
    write-verbose "You Selected Azure Subscription: $SubscriptionName"
    
    if($($SubscriptionArray[$SelectedSub - 1].SubscriptionID))
    {
        [guid]$SubscriptionID = $($SubscriptionArray[$SelectedSub - 1].SubscriptionID)
    }
    if($($SubscriptionArray[$SelectedSub - 1].ID))
    {
        [guid]$SubscriptionID = $($SubscriptionArray[$SelectedSub - 1].ID)
    }
}
Write-Host "Selecting Azure Subscription: $($SubscriptionID.Guid) ..." -ForegroundColor Cyan
$Null = Select-AzureRmSubscription -SubscriptionId $SubscriptionID.Guid

If(!($ManagementGroupID))
{
    [array]$MgtGroupArray = Add-IndexNumberToArray (Get-AzureRmManagementGroup) 
    if(!$MgtGroupArray)
    {
        Write-host "Please make sure you have Management Groups that are accessible"
        exit
    }
    [int]$SelectedMG = 0

    # use the current Managment Group if there is only one MG available
    if ($MgtGroupArray.Count -eq 1) 
    {
        $SelectedMG = 1
    }
    # Get Management Group if one isn't provided
    while($SelectedMG -gt $MgtGroupArray.Count -or $SelectedMG -lt 1)
    {
        Write-host "Please select a Management Group from the list below"
        $MgtGroupArray | select "#", Name, DisplayName, Id | ft
        try
        {
            write-host "If you don't see your ManagementGroupID try using the parameter -ManagementGroupID" -ForegroundColor Cyan
            $SelectedMG = Read-Host "Please enter a selection from 1 to $($MgtGroupArray.count)"
        }
        catch
        {
            Write-Warning -Message 'Invalid option, please try again.'
        }
    }
    if($($MgtGroupArray[$SelectedMG - 1].Name))
    {
        $ManagementGroupID = $($MgtGroupArray[$SelectedMG - 1].Name)
    }
    
    write-verbose "You Selected Management Group: $ManagementGroupID"
    Write-Host "Selecting Management Group: $ManagementGroupID ..." -ForegroundColor Cyan
}

# Set context for REST Auth Token
$currentContext = Get-AzureRmContext

# Get token from current context to auth
$token = $currentContext.TokenCache.ReadItems() | ? {$_.tenantid -eq $currentContext.Tenant.Id}    

# If export or report mode is used 
If($Mode -eq "Export" -or $Mode -eq "Report")
{
    # REST Header for REST call to get Blueprints and Artifacts
    $GetBlueprint = @{
        Headers = @{
            Authorization = "Bearer $($token.AccessToken)"
            'Content-Type' = 'application/json'
        }
        Method = 'Get'
        UseBasicParsing = $true
    }
    # Let's go get all blueprints available within a selected management group
    If(!$BlueprintName)
    {
        # Get all Blueprints
        $BlueprintsURI = "https://management.azure.com/providers/Microsoft.Management/managementGroups/$ManagementGroupID/providers/Microsoft.Blueprint/blueprints$APIVersion"
        Try
        {
            $BPs = Invoke-WebRequest -uri $BlueprintsURI @GetBlueprint
        }
        catch
        {
            write-host "An error occurred - please check rights or parameters for proper configuration and try again"
            write-host "If you received " -NoNewline 
            write-host "The access token is invalid " -NoNewline -ForegroundColor Red
            write-host "or an error " -NoNewline
            write-host "(401)" -NoNewline -ForegroundColor Red 
            write-host ", then please type"
            write-host "logout-AzureRMAccount " -ForegroundColor Yellow
            write-host "from within your PowerShell prompt and try running the script again"
            write-host "Error 401 could indicate cached authentication tokens have expired"
            write-host "Error 403 could indicate target Management Group does not exist"
            write-host "Error 404 could indicate source blueprint not found"
            write-host "======================================================================="
            write-host "Specific Error is: " -NoNewline
            write-host "$($_.Exception.Message)" -ForegroundColor Yellow
            exit
        }
        $BPValues = $($BPs|convertfrom-json).value
        if(!$BPValues)
        {
            write-host "No Blueprints found in $ManagementGroupID"
            exit
        }
        [array]$BPsArray = Add-IndexNumberToArray $BPValues
        [int]$SelectedBP = 0

        # use the only BP if there is only one BP available
        if ($BPsArray.Count -eq 1) 
        {
            $SelectedBP = 1
        }
        # Get Blueprint if one isn't provided
        while($SelectedBP -gt $BPsArray.Count -or $SelectedBP -lt 1)
        {
            Write-host "Please select a Blueprint from the list below to export"
            $BPsArray | select "#", @{Label = "Blueprint Name";Expression={$_.name}}, @{Label = "ManagementGroup"; Expression = {$($BPsArray.ID).split("/")[4]}}, @{Label = "Blueprint Description";Expression={$_.properties.description}} | ft
            try
            {
                $SelectedBP = Read-Host "Please enter a selection from 1 to $($BPsArray.count)"
            }
            catch
            {
                Write-Warning -Message 'Invalid option, please try again.'
            }
        }
        if($($BPsArray[$SelectedBP - 1].Name))
        {
            $BlueprintName = $($BPsArray[$SelectedBP - 1].Name)
        }
        write-verbose "You Selected Blueprint: $BlueprintName"
    }
    Write-Host "Selecting Blueprint: $BlueprintName ..." -ForegroundColor Cyan

    <#
    # FUTURE USE
    # Get all possible published versions of a selected Blueprint (if they exist) to choose from
    $BluePrintVersionsURI = "https://management.azure.com/providers/Microsoft.Management/managementGroups/$ManagementGroup/providers/Microsoft.Blueprint/blueprints/$BluePrintName/versions" + "?api-version=2017-11-11-preview"
    $BPVersions = Invoke-WebRequest -uri $BluePrintVersionsURI @GetBlueprint
    $BPVersions = $($BPVersions|convertfrom-json).value
    if($BPVersions)
    {
        [array]$BPVersionArray = Add-IndexNumberToArray ($BPVersions) 
        [int]$SelectedBPVer = 0

        # If there is only one Blueprint version available - select it
        if ($BPVersionArray.Count -eq 1) 
        {
            $SelectedBPVer = 1
        }
        # Get all blueprint versions
        while($SelectedBPVer -gt $BPVersionArray.Count -or $SelectedBPVer -lt 1)
        {
            Write-host "Please select a Blueprint Version from the list below to export"
            $BPVersionArray|select "#", @{Label = "Version";Expression={$_.name}}, @{Label = "Blueprint Name";Expression={$BlueprintName}}|ft
                
            try
            {
                $SelectedBPVer = Read-Host "Please enter a selection from 1 to $($BPVersionArray.count)"
            }
            catch
            {
                Write-Warning -Message 'Invalid option, please try again.'
            }
        }
        if($($BPVersionArray[$SelectedBPVer - 1].Name))
        {
            $Version = $($BPVersionArray[$SelectedBPVer - 1].Name)
        }
    
        write-verbose "You Selected Blueprint Version: $Version"
        Write-Host "Selecting Blueprint: $Version for Blueprint $BlueprintName..." -ForegroundColor Cyan
        $BluePrintURI = "https://management.azure.com/providers/Microsoft.Management/managementGroups/$ManagementGroupID/providers/Microsoft.Blueprint/blueprints/$BlueprintName/versions/$Version" + "?api-version=2017-11-11-preview"
        $ArtifactsURI = "https://management.azure.com/providers/Microsoft.Management/managementGroups/$ManagementGroupID/providers/Microsoft.Blueprint/blueprints/$BlueprintName/versions/$Version/artifacts" + "?api-version=2017-11-11-preview"
    }
    Else
    {
        Write-host "No published versions present to export - defaulting to draft"#>
        $BluePrintURI = "https://management.azure.com/providers/Microsoft.Management/managementGroups/$ManagementGroupID/providers/Microsoft.Blueprint/blueprints/$BluePrintName$APIVersion"
        $ArtifactsURI = "https://management.azure.com/providers/Microsoft.Management/managementGroups/$ManagementGroupID/providers/Microsoft.Blueprint/blueprints/$BluePrintName/artifacts$APIVersion"
    #}
    try
    {
        $BP = Invoke-WebRequest -uri $BluePrintURI @GetBlueprint
    }
    catch
    {
        write-host "An error occurred - please check rights or parameters for proper configuration and try again"
        write-host "If you received " -NoNewline 
        write-host "The access token is invalid " -NoNewline -ForegroundColor Red
        write-host "or an error " -NoNewline
        write-host "(401)" -NoNewline -ForegroundColor Red 
        write-host ", then please type"
        write-host "logout-AzureRMAccount " -ForegroundColor Yellow
        write-host "from within your PowerShell prompt and try running the script again"
        write-host "Error 401 could indicate cached authentication tokens have expired"
        write-host "Error 403 could indicate target Management Group does not exist"
        write-host "Error 404 could indicate source blueprint not found"
        write-host "======================================================================="
        write-host "Specific Error is: " -NoNewline
        write-host "$($_.Exception.Message)" -ForegroundColor Yellow
        exit
    }
    $BlueprintContent = $BP.content | ConvertFrom-Json
    # Remove ID to generalize JSON
    $BlueprintContent = $BlueprintContent | Select-Object -Property * -ExcludeProperty id

    If($NewBluePrintName)
    {
        $TargetBPName = $NewBluePrintName
        # Only works for Draft currently
        $BlueprintContent.Name = $NewBluePrintName
        
        # Update Blueprint ID for new Blueprint name
        #$BlueprintContent.ID = $BlueprintContent.ID -replace "/providers/Microsoft.Blueprint/blueprints/.*", "/providers/Microsoft.Blueprint/blueprints/$NewBluePrintName"
    }
    Else
    {
        $TargetBPName = $BlueprintName
    }
    if($Mode -eq "Export")
    {
        # Create export directory if one doesn't exist
        IF(!$(Test-Path -Path "$ExportDir\$TargetBPName"))
        {
            $NewFolder = New-Item -Type Directory "$ExportDir\$TargetBPName"
        }
        # Exporting main Blueprint
        write-host "Export Folder for export: $ExportDir\$TargetBPName" 
        Write-Host "Exporting Blueprint: " -ForegroundColor Cyan -NoNewline
        write-host "$BlueprintName " -ForegroundColor Yellow -NoNewline
        write-host "to target Blueprint Name $TargetBPName" -ForegroundColor White
    
        $BlueprintContent|ConvertTo-Json -Depth 50|Out-File "$ExportDir\$TargetBPName\Blueprint-$TargetBPName.json"
    }
    # Build details for Blueprint basic report
    if($Mode -eq "Report")
    {
        $Report =@()
        $MyObj = New-Object System.Object
        Add-Member -InputObject $MyObj -Name "Type" -Value ("AzureBlueprint") -MemberType NoteProperty 
        Add-Member -InputObject $MyObj -Name "Display Name" -Value ($BlueprintName) -MemberType NoteProperty
        Add-Member -InputObject $MyObj -Name "ID" -value ($BlueprintContent.name)-MemberType NoteProperty
        $Report = $Report + $Myobj
    }
    # Get All Artifacts
    try
    {
        try
        {
            $BPArtifacts = Invoke-WebRequest -Uri $ArtifactsURI @GetBlueprint
        }
        catch
        {
            write-host "An error occurred - please check rights or parameters for proper configuration and try again"
            write-host "If you received " -NoNewline 
            write-host "The access token is invalid " -NoNewline -ForegroundColor Red
            write-host "or an error " -NoNewline
            write-host "(401)" -NoNewline -ForegroundColor Red 
            write-host ", then please type"
            write-host "logout-AzureRMAccount " -ForegroundColor Yellow
            write-host "from within your PowerShell prompt and try running the script again"
            write-host "Error 401 could indicate cached authentication tokens have expired"
            write-host "Error 403 could indicate target Management Group does not exist"
            write-host "Error 404 could indicate source blueprint not found"
            write-host "======================================================================="
            write-host "Specific Error is: " -NoNewline
            write-host "$($_.Exception.Message)" -ForegroundColor Yellow
            exit
        }
        $Artifacts = $BPArtifacts.Content | ConvertFrom-Json
        
        # Logic for exporting artifacts from a selected Blueprint        
        if($Mode -eq "Export")
        {
            Write-Host "Starting the export of Blueprint Artifacts" -ForegroundColor Cyan
            foreach($Artifact in $Artifacts.value)
            {
                # Remove ID to generalize json
                $Artifact = $Artifact | Select-Object -Property * -ExcludeProperty id

                # Exporting all artifacts by kind and name
                $Kind = $Artifact.kind
                $Name = $Artifact.Name
                
                Write-Host "Exporting Artifact: " -NoNewline -ForegroundColor Cyan
                write-host "$Kind-$Name.json" -ForegroundColor Yellow
                $Artifact|ConvertTo-Json -Depth 50|Out-File "$ExportDir\$TargetBPName\$Kind-$Name.json"
            }
        }
        # Report logic for exporting a basic report of a Blueprint and Artifacts        
        if($Mode -eq "Report")
        {
            
            foreach($Artifact in $Artifacts.value)
            {
                # Display Details
                $MyObj = New-Object System.Object
                Add-Member -InputObject $MyObj -Name "Type" -Value ($Artifact.kind) -MemberType NoteProperty 
                Add-Member -InputObject $MyObj -Name "Display Name" -Value ($Artifact.Properties.DisplayName) -MemberType NoteProperty 
                Add-Member -InputObject $MyObj -Name "ID" -Value ($Artifact.Name) -MemberType NoteProperty 
                $Report = $Report + $Myobj
            }
            IF(!$ReportDir)
            {
                Write-Host "No Report Directory parameter " -NoNewline
                write-host "(`$ReportDir) " -NoNewline -ForegroundColor Yellow
                write-host " provided.  Writing to console!"
                $Report|ft
            }
            If($ReportDir)
            {
                $Time = $(Get-Date).ToString("yyyyMMddhhmm")
                Write-host "Writing Report to " -NoNewline
                write-host "$ReportDir\Report-$BlueprintName-$Time.csv"  -ForegroundColor Yellow
                $Report | Export-Csv "$ReportDir\Report-$BlueprintName-$Time.csv" -NoTypeInformation
            }
        } 
    }
    catch
    {}
    Write-host "Complete"
}
# Import logic for Azure Blueprints
If($Mode -eq "Import")
{
    # Validate customer wants to continue to import Blueprint and artifacts
    # If Force used, will update without prompting
    if ($Force -OR $PSCmdlet.ShouldContinue("This operation will attempt to import the Blueprint from $ImportDir into your $ManagementGroupID Management Group. Continue?",$ImportDir) )
    {
        $filesToImport = Get-ChildItem $ImportDir\*.json -rec
        Write-Host "Starting the import of a Blueprint and Artifacts" -ForegroundColor Cyan
        Write-Host "Importing Blueprint from: " -ForegroundColor Cyan -NoNewline
        write-host "$ImportDir" -ForegroundColor Yellow 
        
        # Getting BlueprintName from base folder
        $BlueprintName = $filesToImport[0].directory.Name

        # Get each file
        foreach ($file in $filesToImport)
        {
            try
            {
                $FileContent = Get-Content -Path $File.pspath|ConvertFrom-Json -ErrorAction stop
            }
            catch
            {
                # Throw an error to screen and exit script on invalid json
                write-host "ERROR: " -NoNewline -ForegroundColor Red
                Write-Host "Check to ensure " -NoNewline
                write-host "$($File.Name) " -ForegroundColor Yellow -NoNewline
                write-host "is a valid JSON"
                exit
            }
            # Add ID to the PSObject to allow for importing to proper path
            If($FileContent.ID)
            {
                $FileContent.ID = $null
            }
            else
            {
                $FileContent | Add-Member -Name 'id' -Type NoteProperty -Value $Null
            }
            if($FileContent.type -eq "Microsoft.Blueprint/blueprints")
            {
                if($NewBluePrintName)
                {
                    # Only supported on draft (non versioned blueprint exports)
                    $FileContent.Name = $NewBluePrintName
                    $BlueprintName = $NewBluePrintName
                }
                #Ensure we update the Management Group and BlueprintName for the target ID
                $FileContent.ID = "/providers/Microsoft.Management/managementGroups/$($ManagementGroupID)/providers/Microsoft.Blueprint/blueprints/$($BluePrintName)"
            }
            if($FileContent.type -eq "Microsoft.Blueprint/blueprints/artifacts") 
            {
                if($NewBluePrintName)
                {
                    $BlueprintName = $NewBluePrintName
                }
                #Ensure we update the Management Group and BlueprintName for the target ID
                $FileContent.ID = "/providers/Microsoft.Management/managementGroups/$($ManagementGroupID)/providers/Microsoft.Blueprint/blueprints/$($BluePrintName)/artifacts/$($FileContent.Name)"
            }
            $ImportURI = "https://management.azure.com$($FileContent.ID)$APIVersion"
            $Body = $FileContent|ConvertTo-Json -depth 50 -Compress -ErrorAction Stop

            # Put call 
            $Putconfig = @{
                URI = $ImportURI
                Headers = @{
                    Authorization = "Bearer $($token.AccessToken)"
                    'Content-Type' = 'application/json'
                }
                Method = 'Put'
                UseBasicParsing = $true
                Body = $body
            }
            Write-Host "Importing " -ForegroundColor White -NoNewline
            write-host "$($file.Name)" -ForegroundColor Yellow
            try
            {
                $PutEvent = Invoke-WebRequest @Putconfig
            }
            catch
            {
                write-host "An error occurred - please check rights or parameters for proper configuration and try again"
                write-host "If you received " -NoNewline 
                write-host "The access token is invalid " -NoNewline -ForegroundColor Red
                write-host "or an error " -NoNewline
                write-host "(401)" -NoNewline -ForegroundColor Red 
                write-host ", then please type"
                write-host "logout-AzureRMAccount " -ForegroundColor Yellow
                write-host "from within your PowerShell prompt and try running the script again"
                write-host "Error 401 could indicate cached authentication tokens have expired"
                write-host "Error 403 could indicate target Management Group does not exist"
                write-host "Error 404 could indicate source blueprint not found"
                write-host "======================================================================="
                write-host "Specific Error is: " -NoNewline
                write-host "$($_.Exception.Message)" -ForegroundColor Yellow
                exit
            }
        }
        write-host "Complete!"
    }
    else
    {
            Write-Host "You selected No - exiting"
            Write-Host "Complete" -ForegroundColor Cyan
            exit
    }
    
}
