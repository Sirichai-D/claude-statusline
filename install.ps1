# Claude Code StatusLine Installer
# Usage (one-liner from GitHub):
#   irm https://raw.githubusercontent.com/<YOUR_USERNAME>/claude-statusline/main/install.ps1 | iex

$claudeDir  = "$env:USERPROFILE\.claude"
$psFile     = "$claudeDir\statusline-command.ps1"
$settingsFile = "$claudeDir\settings.json"

if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Force $claudeDir | Out-Null
}

Set-Content -LiteralPath $psFile -Encoding UTF8 -Value @'
$d = [Console]::In.ReadToEnd()
if (-not $d.Trim()) { exit 0 }
try { $j = $d | ConvertFrom-Json } catch { exit 0 }

function Find-Property {
    param($obj, $name)
    if ($null -eq $obj) { return $null }
    $val = $obj.PSObject.Properties[$name]
    if ($val) { return $val.Value }
    foreach ($prop in $obj.PSObject.Properties) {
        $v = $prop.Value
        if ($null -ne $v -and $v.GetType().FullName -eq 'System.Management.Automation.PSCustomObject') {
            $found = Find-Property $v $name
            if ($null -ne $found) { return $found }
        }
    }
    return $null
}

function Get-Bar {
    param([double]$pct)
    $filled = [int][Math]::Round($pct / 10)
    if ($filled -lt 0) { $filled = 0 }
    if ($filled -gt 10) { $filled = 10 }
    return '[' + ('#' * $filled) + ('-' * (10 - $filled)) + ']'
}

$parts = @()

$model = $j.model.display_name
if ($model) { $parts += $model }

$used = $j.context_window.used_percentage
if ($null -ne $used) { $parts += "ctx:$([int]$used)%" }

function Format-ResetTime {
    param([long]$unix)
    $t = [DateTimeOffset]::FromUnixTimeSeconds($unix).LocalDateTime
    $diff = $t - [DateTime]::Now
    if ($diff.TotalMinutes -lt 60) { return "RST $([int]$diff.TotalMinutes)m" }
    return "RST $([int]$diff.TotalHours)h$($t.ToString('mm'))m"
}

$fiveHour = Find-Property $j 'five_hour'
if ($null -ne $fiveHour) {
    $pct = $fiveHour.used_percentage
    if ($null -ne $pct) {
        $str = "5h:$(Get-Bar $pct)$([int][Math]::Round($pct))%"
        if ($fiveHour.resets_at) { $str += "($(Format-ResetTime $fiveHour.resets_at))" }
        $parts += $str
    }
}

$sevenDay = Find-Property $j 'seven_day'
if ($null -ne $sevenDay) {
    $pct = $sevenDay.used_percentage
    if ($null -ne $pct) {
        $str = "7d:$(Get-Bar $pct)$([int][Math]::Round($pct))%"
        if ($sevenDay.resets_at) { $str += "($(Format-ResetTime $sevenDay.resets_at))" }
        $parts += $str
    }
}

$cwd = $j.workspace.current_dir
if ($cwd) { $parts += $cwd }

if ($parts) { Write-Host ($parts -join ' | ') -NoNewline }
'@

$psPathForward = ($psFile -replace '\\', '/')
$statusLineValue = [ordered]@{
    type    = "command"
    command = "powershell.exe -NoProfile -File $psPathForward"
}

if (Test-Path $settingsFile) {
    $settings = Get-Content $settingsFile -Raw | ConvertFrom-Json
} else {
    $settings = [PSCustomObject]@{}
}

$settings | Add-Member -MemberType NoteProperty -Name statusLine -Value $statusLineValue -Force
$settings | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $settingsFile -Encoding UTF8

Write-Host "Claude Code statusline installed successfully."
Write-Host "Restart Claude Code to activate."
Write-Host ""
Write-Host "Status line will show:"
Write-Host "  <Model> | ctx:NN% | 5h:[...]NN%(RSTXh) | 7d:[...]NN%(RSTXd) | <current dir>"
