<#
    .SYNOPSIS
        Retrieve GitHub release.

    .DESCRIPTION
        Retrieve GitHub release.

#>

Function Get-GitHubCommit {
    [cmdletbinding()]
    param(
        #GitHub user name.
        [Parameter(Mandatory=$true)]
        [string]$username,

        #GitHub repository name.
        [Parameter(Mandatory=$true)]
        [string]$repository,

        #SHA or branch to start listing commits from. Default: the repository’s default branch (usually master).
        [Parameter(Mandatory=$false)]
        [string]$sha = 'master',
        
        #Only commits containing this file path will be returned.
        [Parameter(Mandatory=$false)]
        [string]$path,
        
        #GitHub login or email address by which to filter by commit author.
        [Parameter(Mandatory=$false)]
        [string]$author,
        
        #Only commits after this date will be returned. This is a timestamp in ISO 8601 format: YYYY-MM-DDTHH:MM:SSZ.
        [Parameter(Mandatory=$false)]
        [string]$since,
        
        #Only commits before this date will be returned. This is a timestamp in ISO 8601 format: YYYY-MM-DDTHH:MM:SSZ.
        [Parameter(Mandatory=$false)]
        [string]$until
    )

    Process {

        #Building URI
        $URI = 'https://api.github.com/repos/'+$username+'/'+$repository+'/commits?sha='+$sha

        If ($path) {
            $query = $query+'&path='+$path
        }

        If ($author) {
            $query = $query+'&author='+$author
        }

        If ($since) {
            $query = $query+'&since='+$since
        }

        If ($until) {
            $query = $query+'&until='+$until
        }

        If ($query) {
            $URI = $URI+$query
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


