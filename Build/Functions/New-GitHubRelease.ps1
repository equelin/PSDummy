<#
    .SYNOPSIS
        Creates a GitHub release.

    .DESCRIPTION
        Creates a GitHub release.
        Users with push access to the repository can create a release.

#>
Function New-GitHubRelease {

    [cmdletbinding()]
    param(
        #GitHub user name.
        [Parameter(Mandatory=$true)]
        [string]$username,

        #GitHub repository name.
        [Parameter(Mandatory=$true)]
        [string]$repository,

        #GitHub authentication token
        [Parameter(Mandatory=$true)]
        [string]$token,

        #The name of the tag.
        [Parameter(Mandatory=$true)]
        [string]$tag_name,

        #The name of the release.
        [Parameter(Mandatory=$false)]
        [string]$Name, 

        #Specifies the commitish value that determines where the Git tag is created from.
        [Parameter(Mandatory=$false)]
        [string]$target_commitish, 

        #Text describing the contents of the tag.
        [Parameter(Mandatory=$false)]
        [string]$body,

        #true to create a draft (unpublished) release, false to create a published one. Default: false
        [Parameter(Mandatory=$false)]
        [bool]$draft = $false,

        #true to identify the release as a prerelease. false to identify the release as a full release. Default: false
        [Parameter(Mandatory=$false)]
        [bool]$prerelease = $false
    )

    Process {

        #GitHub authentication
        $BasicToken = $username+':'+$token
        $Base64BasicToken = [System.Convert]::ToBase64String([char[]]$BasicToken)

        #Building URI
        $URI = 'https://api.github.com/repos/'+$username+'/'+$repository+'/releases'

        #Building header
        $Headers = @{
            Authorization = 'Basic {0}' -f $Base64BasicToken
        }

        #Building body
        $RequestBody = @{}

        $RequestBody["tag_name"] = $tag_name

        If ($PSBoundParameters.ContainsKey('name')) {
            $Requestbody["name"] = "$name"
        }

        If ($PSBoundParameters.ContainsKey('target_commitish')) {
            $Requestbody["target_commitish"] = "$target_commitish"
        }

        If ($PSBoundParameters.ContainsKey('body')) {
            $Requestbody["body"] = "$body"
        }

        If ($PSBoundParameters.ContainsKey('draft')) {
            $Requestbody["draft"] = $draft
        }

        If ($PSBoundParameters.ContainsKey('prerelease')) {
            $Requestbody["prerelease"] = $prerelease
        }

        $RequestBody = $RequestBody | ConvertTo-JSON

        Write-Verbose $RequestBody

        Invoke-RestMethod -Headers $Headers -Uri $URI -Body $RequestBody -Method 'Post'

    }
}

