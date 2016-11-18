<#
    .SYNOPSIS
        Retrieve GitHub release.

    .DESCRIPTION
        Retrieve GitHub release.

#>

Function Get-GitHubRelease {
    [cmdletbinding()]
    param(
        #GitHub user name.
        [Parameter(Mandatory=$true)]
        [string]$username,

        #GitHub repository name.
        [Parameter(Mandatory=$true)]
        [string]$repository,

        #The name of the tag.
        [Parameter(Mandatory=$false)]
        [switch]$latest
    )

    Process {

        #Building URI
        $URI = 'https://api.github.com/repos/'+$username+'/'+$repository+'/releases'

        If ($latest) {
            $URI = $URI+'/latest'
        }

        Write-Verbose $URI

        Try {
            Invoke-RestMethod -Uri $URI -Method 'Get'
        }
        Catch {
            Throw "Error... $_"
        }
    }
}


