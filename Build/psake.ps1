# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Find the build folder based on build system
        $ProjectRoot = $ENV:BHProjectPath
        if(-not $ProjectRoot)
        {
            $ProjectRoot = $PSScriptRoot
        }

    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $BaseFileName = "TestResults_PS$PSVersion`_$TimeStamp"
    $lines = '----------------------------------------------------------------------'

    $Verbose = @{}
    if($ENV:BHCommitMessage -match "!verbose")
    {
        $Verbose = @{Verbose = $True}
    }

    . $ENV:BHProjectPath\Build\Functions\New-GitHubRelease.ps1
}

Task Default -Depends Deploy

Task Init {
    $lines
    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH*
    "`n"
}

Task Test -Depends Init  {
    $lines
    "`n`tSTATUS: Testing with PowerShell $PSVersion"

    # Gather test results. Store them in a variable and file
    $TestResults = Invoke-Pester -Path $ProjectRoot\Tests -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\Build\$TestFile" | Format-Pester -Path . -Format

    # Document the pester results
    $FormatPesterResult = $TestResults | Format-Pester -Path . -Format 'Text' -BaseFileName $BaseFileName 

    # In Appveyor?  Upload our tests and documentation! #Abstract this into a function?
    If($ENV:BHBuildSystem -eq 'AppVeyor')
    {
        #Upload NUnitXml tests results
        (New-Object 'System.Net.WebClient').UploadFile(
            "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
            "$ProjectRoot\Build\$TestFile" )
        #Upload documented tests results in .txt format 
        (New-Object 'System.Net.WebClient').UploadFile(
            "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
            "$FormatPesterResult" )
    }

    Remove-Item "$ProjectRoot\Build\$TestFile" -Force -ErrorAction SilentlyContinue

    Remove-Item "$FormatPesterResult" -Force -ErrorAction SilentlyContinue

    # Failed tests?
    # Need to tell psake or it will proceed to the deployment. Danger!
    if($TestResults.FailedCount -gt 0)
    {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }
    "`n"
}

Task Build -Depends Test {
    $lines
    
    # Load the module, read the exported functions, update the psd1 FunctionsToExport
    Set-ModuleFunctions
}

Task Deploy -Depends Build {
    $lines

    # Publish to PSGallery and create a GitHub release if all conditions are met
    if(
    $env:BHPSModulePath -and
    $env:BHBuildSystem -ne 'Unknown' -and
    $env:BHBranchName -eq "master" -and
    $env:BHModuleVersion -gt $env:BHGitHubLatestReleaseVersion -and
    $env:BHModuleVersion -gt $env:BHPSGalleryLatestModuleVersion
    )
    {
        $Params = @{
            Path = "$ProjectRoot\Build\PSGalleryModule.PSDeploy.ps1"
            Force = $true
            Recurse = $false # We keep psdeploy artifacts, avoid deploying those : )
        }
    
        Invoke-PSDeploy @Verbose @Params

        # Create a new GitHub draft release
        New-GitHubRelease -username 'equelin' -repository $ENV:BHProjectName -token $ENV:GHToken -tag_name $env:BHModuleVersion -name $env:BHModuleVersion -draft $False
    }
    else
    {
        "Skipping deployment: To deploy, ensure that...`n" +
        "`t* You are in a known build system (Current: $ENV:BHBuildSystem)`n" +
        "`t* You are committing to the master branch (Current: $ENV:BHBranchName) `n" +
        "`t* The module version is greater than the latest GitHub release (Current: $ENV:BHModuleVersion GitHub:$env:BHGitHubLatestReleaseVersion) `n" +
        "`t* The module version is greater than the latest PSGallery version (Current: $ENV:BHModuleVersion GitHub:$env:BHPSGalleryLatestModuleVersion) `n" |
            Write-Host
    }

    # Publish to AppVeyor if we're in AppVeyor
    if(
        $env:BHPSModulePath -and
        $env:BHBuildSystem -eq 'AppVeyor'
    )
    {
        $Params = @{
            Path = "$ProjectRoot\Build\AppVeyorModule.PSDeploy.ps1"
            Force = $true
            Recurse = $false # We keep psdeploy artifacts, avoid deploying those : )
        }
    
        Invoke-PSDeploy @Verbose @Params
    }
}