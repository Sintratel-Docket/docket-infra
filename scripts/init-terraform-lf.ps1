# Run from the Terraform root. Preserve Git module bytes (including heredocs)
# even when Windows has core.autocrlf=true. Existing module caches are not rewritten.
# From environments/dev: & ../../scripts/init-terraform-lf.ps1
[CmdletBinding()]
param(
    [string[]]$InitArguments = @('-backend=false', '-lockfile=readonly')
)

$ErrorActionPreference = 'Stop'
$previousCount = [Environment]::GetEnvironmentVariable('GIT_CONFIG_COUNT', 'Process')
$configCount = if ([string]::IsNullOrEmpty($previousCount)) { 0 } else { [int]$previousCount }
$overrides = @(
    @{ Key = 'core.autocrlf'; Value = 'false' },
    @{ Key = 'core.eol'; Value = 'lf' }
)
$savedVariables = @{}

try {
    for ($i = 0; $i -lt $overrides.Count; $i++) {
        $index = $configCount + $i
        foreach ($entry in @{
            "GIT_CONFIG_KEY_$index" = $overrides[$i].Key
            "GIT_CONFIG_VALUE_$index" = $overrides[$i].Value
        }.GetEnumerator()) {
            $savedVariables[$entry.Key] = [Environment]::GetEnvironmentVariable($entry.Key, 'Process')
            [Environment]::SetEnvironmentVariable($entry.Key, $entry.Value, 'Process')
        }
    }
    $env:GIT_CONFIG_COUNT = [string]($configCount + $overrides.Count)
    terraform init @InitArguments
    if ($LASTEXITCODE -ne 0) {
        throw "terraform init failed with exit code $LASTEXITCODE"
    }
}
finally {
    foreach ($entry in $savedVariables.GetEnumerator()) {
        [Environment]::SetEnvironmentVariable($entry.Key, $entry.Value, 'Process')
    }
    [Environment]::SetEnvironmentVariable('GIT_CONFIG_COUNT', $previousCount, 'Process')
}
