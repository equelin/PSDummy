Write-Host "***** START BUILD *****" -ForegroundColor Yellow

Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - Show build helper variables" -ForegroundColor Blue
Get-Item ENV:BH*

Write-Host "[$env:BHBuildSystem]-[$env:BHProjectName] - Nothing to build..." -ForegroundColor Blue

Write-Host "***** END BUILD *****" -ForegroundColor Yellow