Add-AppVeyorLog -Message 'START INSTALL / INIT' -Category 'Information'

# Grab nuget bits, install modules, set build variables, start build.
Add-AppVeyorLog -Message 'Get NuGEt package provider' -Category 'Information'
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

Add-AppVeyorLog -Message 'Import local module AppVeyor-Util' -Category 'Information' -Details "Source: $PSScriptRoot\Functions\AppVeyor-Util.psm1"
Import-Module -Name $PSScriptRoot\Functions\AppVeyor-Util.psm1 -ErrorAction Stop | Out-Null

Add-AppVeyorLog -Message 'Import modules from PSGallery' -Category 'Information' -Details 'Module list: PSDeploy, Pester, BuildHelpers, Format-Pester'
Resolve-Module PSDeploy, Pester, BuildHelpers, Format-Pester

Add-AppVeyorLog -Message 'Set build environment variables' -Category 'Information'
Set-BuildEnvironment

#Get module version
Add-AppVeyorLog -Message 'Get module version' -Category 'Information'
$ENV:BHModuleVersion = (Test-ModuleManifest -Path $ENV:BHPSModuleManifest).version

#Get PSGallery latest module version
Add-AppVeyorLog -Message 'Get PSGallery latest module version' -Category 'Information'
$ENV:BHPSGalleryLatestModuleVersion = (Find-Module -Name $ENV:BHProjectName).version

#Get GitHub latest release
Add-AppVeyorLog -Message 'Get GitHub latest release' -Category 'Information'
$Releases = Get-GitHubRelease -username 'equelin' -repository $ENV:BHProjectName 

If ($Releases) {
    $ENV:BHGitHubLatestReleaseVersion = [version]($releases.tag_name | Select-Object -First 1)
} else {
    $ENV:BHGitHubLatestReleaseVersion = '0.0.0'
}

Add-AppVeyorLog -Message 'END INSTALL / INIT' -Category 'Information'