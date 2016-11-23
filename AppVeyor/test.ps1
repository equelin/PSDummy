Write-Host "***** TEST *****" -ForegroundColor Yellow

# Find the build folder based on build system
$ProjectRoot = $ENV:BHProjectPath

if(-not $ProjectRoot) {
    $ProjectRoot = $PSScriptRoot
}

$Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
$PSVersion = $PSVersionTable.PSVersion.Major
$TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
$BaseFileName = "TestResults_PS$PSVersion`_$TimeStamp"

# Gather test results. Store them in a variable and file
Add-AppVeyorLog -Message 'Run pester tests' -Category 'Information'
$TestResults = Invoke-Pester -Path $ProjectRoot\Tests -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\AppVeyor\$TestFile"

# Document the pester results
Add-AppVeyorLog -Message "Documenting the pester's results with Format-Pester" -Category 'Information'
$FormatPesterResult = $TestResults | Format-Pester -Format 'Text' -BaseFileName $BaseFileName

# In Appveyor?  Upload our tests and documentation! 
If($ENV:BHBuildSystem -eq 'AppVeyor')
{
    Add-AppVeyorLog -Message 'Uploading tests and documentation on Appveyor' -Category 'Information'
    
    #Upload NUnitXml tests results
    (New-Object 'System.Net.WebClient').UploadFile(
        "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
        "$ProjectRoot\AppVeyor\$TestFile")

    #Upload Format-Pester tests results   
    Push-AppveyorArtifact $FormatPesterResult
}

# Stop the build if a pester test fails 
If ($TestResults.FailedCount -gt 0) {
    Add-AppVeyorLog -Message "Tests failed, stop the build" -Category 'Error' -Details "Number of tests failed: $($TestResults.FailedCount)"
    Throw
}