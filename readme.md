This repo is for collecting a variety of Blueprints and ARM templates that are used for implementing Blueprints-as-Code.


# Getting started
Helpful resources for getting started with managing Blueprints as code:

* [Manage-AzureRmBlueprint Powershell script for importing/exporting Blueprint files](https://www.powershellgallery.com/packages/Manage-AzureRMBlueprint)
* [Video walking through usage of the above script](https://www.youtube.com/watch?v=SMORUIPhKd8)
* [Blueprint documentation](https://aka.ms/whatareblueprints)
* [Boilerplate for blueprint and each artifact type](https://github.com/ajf214/personal-arm-templates/tree/master/Boilerplate)
* [AxAzureBlueprint Powershell Module](https://www.powershellgallery.com/packages/AxAzureBlueprint/)
* [Walkthrough of AxAzureBlueprint usage](https://agazoth.github.io/blogpost/2018/11/11/Azure-Blueprint.html)

# Import these Blueprints with Powershell

With [Manage-AzureRmBlueprint script](https://www.powershellgallery.com/packages/Manage-AzureRMBlueprint)
```
Install-Script -Name Manage-AzureRMBlueprint
".\Manage-AzureRmBlueprint" -mode Import -ImportDir ".\Example Blueprints\PortalBlueprints\networking" -ManagementGroupId "ManagementGroupId"
```

With [AxAzureBlueprint module](https://www.powershellgallery.com/packages/AxAzureBlueprint/)
```
Install-Module -Name AxAzureBlueprint
Connect-AzureBlueprint -ManagementGroupName "ManagementGroupId"
Set-AzureBlueprint -BlueprintFolder ".\Example Blueprints\PortalBlueprints\networking"
```

# Troubleshooting
There is no official support for this repo, but if you have problems, please open an issue or reach out to me at [alfran@microsoft.com](mailto:alfran@microsoft.com?subject=Blueprint%20GitHub%20Troubleshooting)
