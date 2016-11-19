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
Add-AppveyorTest -Name "Pester" -Outcome Running

Add-AppveyorMessage -Message "Run pester tests" -Category Information
$TestResults = Invoke-Pester -Path $ProjectRoot\Tests -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\AppVeyor\$TestFile"

Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - Documenting the pester's results with Format-Pester" -ForegroundColor Blue
# Document the pester results
$FormatPesterResult = $TestResults | Format-Pester -Format 'Text' -BaseFileName $BaseFileName

# In Appveyor?  Upload our tests and documentation! 
If($ENV:BHBuildSystem -eq 'AppVeyor')
{
    Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - Uploading tests and documentation on Appveyor" -ForegroundColor Blue
    #Upload NUnitXml tests results
    (New-Object 'System.Net.WebClient').UploadFile(
        "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
        "$ProjectRoot\AppVeyor\$TestFile")

    #Upload Format-Pester tests results   
    Push-AppveyorArtifact $FormatPesterResult
}

# Delete files
Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - Delete tests files" -ForegroundColor Blue
If (Get-Item -Path "$ProjectRoot\AppVeyor\$TestFile") {
    Remove-Item "$ProjectRoot\AppVeyor\$TestFile" -Force -ErrorAction SilentlyContinue
}

If (Get-Item -Path $FormatPesterResult) {
    Remove-Item "$FormatPesterResult" -Force -ErrorAction SilentlyContinue
}

# Stop the build if a pester test fails 
If ($TestResults.FailedCount -gt 0) {
    Add-AppveyorMessage -Message "Pester: $($TestResults.FailedCount) tests failed." -Category Error
    Update-AppveyorTest -Name 'Pester' -Outcome Failed -ErrorMessage "$($TestResults.FailedCount) tests failed."
    Throw "Pester: $($TestResults.FailedCount) tests failed."
} else {
    Update-AppveyorTest -Name 'Pester' -Outcome Passed
}

Write-Host "***** END TEST *****" -ForegroundColor Yellow