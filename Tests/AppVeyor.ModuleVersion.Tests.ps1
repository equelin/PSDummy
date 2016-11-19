If ($env:BHPSModulePath -and $env:BHBuildSystem -eq 'AppVeyor') {
    Describe -Name "Testing module published versions (PSGallery and GitHub latest release)" -Fixture {
        It -Name "The module version is greater than the latest GitHub release" {
            $env:BHModuleVersion | Should BeGreaterThan $env:BHGitHubLatestReleaseVersion
        }

        It -Name "The module version is greater than the latest PSGallery version" {
            $env:BHModuleVersion | Should BeGreaterThan $env:BHPSGalleryLatestModuleVersion
        }
    }
}
