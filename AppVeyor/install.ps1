Write-Host "***** INSTALL / INIT *****" -ForegroundColor Yellow

#Get function definition files
$Functions  = @( Get-ChildItem -Path $PSScriptRoot\ Functions\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($import in $Functions)
{
    Try
    {
        Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - Import function: $($import.fullname)" -ForegroundColor Blue
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import file $($import.fullname): $_"
    }
}

# Grab nuget bits, install modules, set build variables, start build.
Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - Get NuGEt package provider" -ForegroundColor Blue
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - Import modules" -ForegroundColor Blue
Resolve-Module PSDeploy, Pester, BuildHelpers, Format-Pester

Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - Set build environment variables" -ForegroundColor Blue
Set-BuildEnvironment

#Get module version
Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - Get module version" -ForegroundColor Blue
$ENV:BHModuleVersion = (Test-ModuleManifest -Path $ENV:BHPSModuleManifest).version

#Get PSGallery latest module version
Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - Get PSGallery latest module version" -ForegroundColor Blue
$ENV:BHPSGalleryLatestModuleVersion = (Find-Module -Name $ENV:BHProjectName).version

#Get GitHub latest release
Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - Get GitHub latest release" -ForegroundColor Blue
$Releases = Get-GitHubRelease -username 'equelin' -repository $ENV:BHProjectName 

If ($Releases) {
    $ENV:BHGitHubLatestReleaseVersion = [version]($releases.tag_name | Select-Object -First 1)
} else {
    $ENV:BHGitHubLatestReleaseVersion = '0.0.0'
}

Write-Host "***** END INSTALL / INIT *****" -ForegroundColor Yellow