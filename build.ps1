[Cmdletbinding()]
param()

#Get function definition files
$Functions  = @( Get-ChildItem -Path $PSScriptRoot\Build\Functions\*.ps1 -ErrorAction SilentlyContinue )

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

Resolve-Module Psake, PSDeploy, Pester, BuildHelpers

Set-BuildEnvironment

#Get module version
$ENV:BHModuleVersion = (Test-ModuleManifest -Path $ENV:BHPSModuleManifest).version

#Get PSGallery latest module version
$ENV:BHPSGalleryLatestModuleVersion = (Find-Module -Name $ENV:BHProjectName).version

#Get GitHub latest release
$Releases = Get-GitHubRelease -username 'equelin' -repository $ENV:BHProjectName

If ($Releases) {
    $ENV:BHGitHubLatestReleaseVersion = [version]($releases.name | Select-Object -First 1).Substring(1)
} else {
    $ENV:BHGitHubLatestReleaseVersion = '0.0.0'
}

#Invoke PSake
Invoke-psake $PSScriptRoot\Build\psake.ps1
exit ( [int]( -not $psake.build_success ) )