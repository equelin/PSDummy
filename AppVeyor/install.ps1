Write-Host "***** INSTALL / INIT *****" -ForegroundColor Yellow

# Grab nuget bits, install modules, set build variables, start build.
Write-Host "Get NuGEt package provider" -ForegroundColor Blue
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

Write-Host "Import local module AppVeyor-Util" -ForegroundColor Blue
Import-Module -Name .\Functions\AppVeyorUtil.psm1 -ErrorAction Stop | Out-Null

Write-Host "Import modules from PSGallery" -ForegroundColor Blue
Resolve-Module PSDeploy, Pester, BuildHelpers, Format-Pester

Write-Host "Set build environment variables" -ForegroundColor Blue
Set-BuildEnvironment

#Get module version
Write-Host "Get module version" -ForegroundColor Blue
$ENV:BHModuleVersion = (Test-ModuleManifest -Path $ENV:BHPSModuleManifest).version

#Get PSGallery latest module version
Write-Host "Get PSGallery latest module version" -ForegroundColor Blue
$ENV:BHPSGalleryLatestModuleVersion = (Find-Module -Name $ENV:BHProjectName).version

#Get GitHub latest release
Write-Host "Get GitHub latest release" -ForegroundColor Blue
$Releases = Get-GitHubRelease -username 'equelin' -repository $ENV:BHProjectName 

If ($Releases) {
    $ENV:BHGitHubLatestReleaseVersion = [version]($releases.tag_name | Select-Object -First 1)
} else {
    $ENV:BHGitHubLatestReleaseVersion = '0.0.0'
}

Write-Host "***** END INSTALL / INIT *****" -ForegroundColor Yellow