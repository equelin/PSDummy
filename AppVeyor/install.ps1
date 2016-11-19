Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - INSTALL / INIT" -ForegroundColor Yellow

#Get function definition files
$Functions  = @( Get-ChildItem -Path $PSScriptRoot\ Functions\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($import in $Functions)
{
    Try
    {
        Write-Verbose "Import file: $($import.fullname)"
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import file $($import.fullname): $_"
    }
}

# Grab nuget bits, install modules, set build variables, start build.
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

Resolve-Module PSDeploy, Pester, BuildHelpers, Format-Pester

Set-BuildEnvironment

#Get module version
$ENV:BHModuleVersion = (Test-ModuleManifest -Path $ENV:BHPSModuleManifest).version

#Get PSGallery latest module version
$ENV:BHPSGalleryLatestModuleVersion = (Find-Module -Name $ENV:BHProjectName).version

#Get GitHub latest release
$Releases = Get-GitHubRelease -username 'equelin' -repository $ENV:BHProjectName 

If ($Releases) {
    $ENV:BHGitHubLatestReleaseVersion = [version]($releases.tag_name | Select-Object -First 1)
} else {
    $ENV:BHGitHubLatestReleaseVersion = '0.0.0'
}