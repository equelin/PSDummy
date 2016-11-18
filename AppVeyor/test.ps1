# Find the build folder based on build system
$ProjectRoot = $ENV:BHProjectPath
if(-not $ProjectRoot) {
    $ProjectRoot = $PSScriptRoot
}

$Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
$PSVersion = $PSVersionTable.PSVersion.Major
$TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
$BaseFileName = "TestResults_PS$PSVersion`_$TimeStamp"
$lines = '----------------------------------------------------------------------'

# Gather test results. Store them in a variable and file
$TestResults = Invoke-Pester -Path $ProjectRoot\Tests -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\AppVeyor\$TestFile"

"`n`tSTATUS: Documenting the Pester results"
# Document the pester results
$FormatPesterResult = $TestResults | Format-Pester -Format 'Text' -BaseFileName $BaseFileName

# In Appveyor?  Upload our tests and documentation! #Abstract this into a function?
If($ENV:BHBuildSystem -eq 'AppVeyor')
{
    "`n`tSTATUS: Uploading tests and documentation on Appveyor"
    Push-AppveyorArtifact $ProjectRoot\Build\$TestFile
    Push-AppveyorArtifact $FormatPesterResult
}

"`n`tSTATUS: Delete files"
# Delete files
If (Get-Item -Path "$ProjectRoot\AppVeyor\$TestFile") {
    Remove-Item "$ProjectRoot\AppVeyor\$TestFile" -Force -ErrorAction SilentlyContinue
}

If (Get-Item -Path $FormatPesterResult) {
    Remove-Item "$FormatPesterResult" -Force -ErrorAction SilentlyContinue
}