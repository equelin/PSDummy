$here = Split-Path -Parent $MyInvocation.MyCommand.Path

#Get information from the module manifest
$manifestPath = "$here\..\PSDummy\PSDummy.psd1"
$manifest = Test-ModuleManifest -Path $manifestPath

#Test if a PSDummy module is already loaded
$Module = Get-Module -Name 'PSDummy' -ErrorAction SilentlyContinue

#Load the module if needed
If ($module) {
    If ($Module.Version -ne $manifest.version) {
        Remove-Module $Module
        Import-Module "$here\..\..\PSDummy" -Version $manifest.version -force
    }
} else {
    Import-Module "$here\..\..\PSDummy" -Version $manifest.version -force
}

Describe -Tags 'VersionChecks' "PSDummy manifest" {
    $script:manifest = $null
    It "has a valid manifest" {
        {
            $script:manifest = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop -WarningAction SilentlyContinue
        } | Should Not Throw
    }

    It "has a valid name in the manifest" {
        $script:manifest.Name | Should Be 'PSDummy'
    }

    It "has a valid guid in the manifest" {
        $script:manifest.Guid | Should Be '0e1a8b0d-d0d7-4369-b4e5-435273c6cced'
    }

    It "has a valid version in the manifest" {
        $script:manifest.Version -as [Version] | Should Not BeNullOrEmpty
    }
}