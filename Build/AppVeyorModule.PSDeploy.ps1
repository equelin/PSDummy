Deploy DeveloperBuild {
    By AppVeyorModule {
        FromSource $ENV:BHPSModulePath
        To AppVeyor
        WithOptions @{
            Version = $env:APPVEYOR_BUILD_VERSION
        }
    }
}
