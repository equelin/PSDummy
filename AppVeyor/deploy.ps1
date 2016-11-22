Write-Host "***** DEPLOY *****" -ForegroundColor Yellow

# Publish to PSGallery and create a GitHub release if all conditions are met
If (
$env:BHPSModulePath -and
$env:BHBuildSystem -ne 'Unknown' -and
$env:BHBranchName -eq "master" -and
$env:BHModuleVersion -gt $env:BHGitHubLatestReleaseVersion -and
$env:BHModuleVersion -gt $env:BHPSGalleryLatestModuleVersion
)
{
    $Params = @{
        Path = "$ProjectRoot\AppVeyor\PSDeploy\PSGalleryModule.PSDeploy.ps1"
        Force = $true
        Recurse = $false # We keep psdeploy artifacts, avoid deploying those : )
    }

    Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - Publish module on PSGallery" -ForegroundColor Blue
    Invoke-PSDeploy @Verbose @Params

    # Publish to AppVeyor if we're in AppVeyor
    If (
        $env:BHPSModulePath -and
        $env:BHBuildSystem -eq 'AppVeyor'
    )
    {
        $Params = @{
            Path = "$ProjectRoot\AppVeyor\PSDeploy\AppVeyorModule.PSDeploy.ps1"
            Force = $true
            Recurse = $false # We keep psdeploy artifacts, avoid deploying those : )
        }

        Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - Publish module as an AppVeyor artifact" -ForegroundColor Blue
        Invoke-PSDeploy @Verbose @Params
    }      

    # Create a new GitHub release
    Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - Create a new GitHub release" -ForegroundColor Blue
    $Release = New-GitHubRelease -username 'equelin' -repository $ENV:BHProjectName -token $ENV:GHToken -tag_name $env:BHModuleVersion -name $env:BHModuleVersion -draft $False

    # Show informations about the created release
    $Release | Format-Table id, tag_name, name, target_commitish -Autosize
}
Else
{
    Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - Skipping deployment: To deploy, ensure that..." -ForegroundColor Magenta
    Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - You are in a known build system (Current: $ENV:BHBuildSystem)" -ForegroundColor Magenta
    Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - You are committing to the master branch (Current: $ENV:BHBranchName)" -ForegroundColor Magenta
    Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - The module version is greater than the latest GitHub release (Current: $ENV:BHModuleVersion GitHub:$env:BHGitHubLatestReleaseVersion)" -ForegroundColor Magenta
    Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - The module version is greater than the latest PSGallery version (Current: $ENV:BHModuleVersion GitHub:$env:BHPSGalleryLatestModuleVersion)" -ForegroundColor Magenta
}

Write-Host "***** END DEPLOY *****" -ForegroundColor Yellow