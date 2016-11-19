Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - TEST" -ForegroundColor Yellow

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
Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - Run pester tests" -ForegroundColor Blue
$TestResults = Invoke-Pester -Path $ProjectRoot\Tests -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\AppVeyor\$TestFile"

Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - Documenting the pester's results with Format-Pester" -ForegroundColor Blue
# Document the pester results
$FormatPesterResult = $TestResults | Format-Pester -Format 'Text' -BaseFileName $BaseFileName

# In Appveyor?  Upload our tests and documentation! 
If($ENV:BHBuildSystem -eq 'AppVeyor')
{
    Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - Uploading tests and documentation on Appveyor" -ForegroundColor Blue
    Push-AppveyorArtifact $ProjectRoot\Appveyor\$TestFile
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
    Throw "[$env:BHBuildSystem]-[$env:BHProjectName]-Failed '$($TestResults.FailedCount)' tests, build failed"
}