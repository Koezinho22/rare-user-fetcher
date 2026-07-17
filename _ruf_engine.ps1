param(
    [string]$Mode,
    [int]$Len = 4,
    [int]$Count = 25,
    [string]$CharsetPick = "1",
    [string]$Platform = "3",
    [int]$DelayMs = 1000,
    [string]$ResultsFile = "",
    [string]$SingleName = "",
    [string]$ListFile = ""
)

$charsets = @{
    "1" = "abcdefghijklmnopqrstuvwxyz"
    "2" = "0123456789"
    "3" = "abcdefghijklmnopqrstuvwxyz0123456789"
    "4" = "abcdefghijklmnopqrstuvwxyz_"
    "5" = "abcdefghijklmnopqrstuvwxyz0123456789_"
}
$chars = $charsets[$CharsetPick]
if (-not $chars) { $chars = "abcdefghijklmnopqrstuvwxyz" }
$alpha = "abcdefghijklmnopqrstuvwxyz"
$rng = New-Object System.Random

function GenName {
    $n = [string]$alpha[$rng.Next(26)]
    for ($x = 1; $x -lt $Len; $x++) {
        $n += $chars[$rng.Next($chars.Length)]
    }
    return $n
}

function Check-Roblox($name) {
    try {
        $url = "https://auth.roblox.com/v1/usernames/validate?request.username=$name&request.birthday=2000-01-01&request.context=Signup"
        $r = Invoke-RestMethod -Uri $url -Method GET -UseBasicParsing -ErrorAction Stop
        if ($r.code -eq 0) {
            Write-Host "    [ROBLOX]  *** AVAILABLE ***" -ForegroundColor Green
            if ($ResultsFile) { Add-Content -Path $ResultsFile -Value "ROBLOX|$name|AVAILABLE" }
            return 1
        } elseif ($r.code -eq 1) {
            Write-Host "    [ROBLOX]  Taken" -ForegroundColor DarkGray
        } else {
            Write-Host "    [ROBLOX]  Invalid" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "    [ROBLOX]  API error" -ForegroundColor Red
    }
    return 0
}

function Check-Discord($name) {
    try {
        $url = "https://api.lixqa.de/v3/discord/pomelo/$name"
        $r = Invoke-RestMethod -Uri $url -Method GET -UseBasicParsing -ErrorAction Stop
        $s = $r.status
        if ($s -eq 2) {
            Write-Host "    [DISCORD] *** AVAILABLE ***" -ForegroundColor Green
            if ($ResultsFile) { Add-Content -Path $ResultsFile -Value "DISCORD|$name|AVAILABLE" }
            return 1
        } elseif ($s -eq 3) {
            Write-Host "    [DISCORD] Taken" -ForegroundColor DarkGray
        } elseif ($s -eq 5 -or $s -eq 4) {
            Write-Host "    [DISCORD] Restricted (5+ letters only)" -ForegroundColor Yellow
        } else {
            Write-Host "    [DISCORD] Invalid" -ForegroundColor Yellow
        }
    } catch {
        $code = 0
        try { $code = $_.Exception.Response.StatusCode.value__ } catch {}
        if ($code -eq 429) {
            Write-Host "    [DISCORD] Rate limited - waiting 10s..." -ForegroundColor Yellow
            Start-Sleep 10
        } elseif ($code -eq 403) {
            Write-Host "    [DISCORD] Restricted" -ForegroundColor Yellow
        } else {
            Write-Host "    [DISCORD] API error" -ForegroundColor Red
        }
    }
    return 0
}

function Run-Checks($name, [ref]$fR, [ref]$fD) {
    if ($Platform -eq "1" -or $Platform -eq "3") {
        $fR.Value += Check-Roblox $name
    }
    if ($Platform -eq "2" -or $Platform -eq "3") {
        $fD.Value += Check-Discord $name
    }
}

# ── HUNT MODE ──
if ($Mode -eq "hunt") {
    $foundR = 0
    $foundD = 0
    for ($i = 1; $i -le $Count; $i++) {
        $name = GenName
        Write-Host ""
        Write-Host "  [$i/$Count]  $name" -ForegroundColor Cyan
        Run-Checks $name ([ref]$foundR) ([ref]$foundD)
        Write-Host "    Score: Roblox=$foundR  Discord=$foundD" -ForegroundColor White
        if ($DelayMs -gt 0) { Start-Sleep -Milliseconds $DelayMs }
    }
    Write-Host ""
    Write-Host "  ========================================" -ForegroundColor Green
    Write-Host "  DONE  Checked: $Count" -ForegroundColor Green
    Write-Host "  Roblox available:  $foundR" -ForegroundColor Green
    Write-Host "  Discord available: $foundD" -ForegroundColor Green
    Write-Host "  Saved to: rare_available.txt" -ForegroundColor Green
    Write-Host "  ========================================" -ForegroundColor Green
}

# ── SINGLE MODE ──
if ($Mode -eq "single") {
    $foundR = 0
    $foundD = 0
    Write-Host "  Testing: $SingleName" -ForegroundColor Cyan
    Write-Host ""
    $Platform = "3"
    Run-Checks $SingleName ([ref]$foundR) ([ref]$foundD)
}

# ── FILE MODE ──
if ($Mode -eq "file") {
    $lines = Get-Content $ListFile | Where-Object { $_.Trim() -ne "" }
    $total = $lines.Count
    $foundR = 0
    $foundD = 0
    $i = 0
    foreach ($name in $lines) {
        $i++
        $name = $name.Trim()
        Write-Host ""
        Write-Host "  [$i/$total]  $name" -ForegroundColor Cyan
        $Platform = "3"
        Run-Checks $name ([ref]$foundR) ([ref]$foundD)
        Write-Host "    Score: Roblox=$foundR  Discord=$foundD" -ForegroundColor White
        Start-Sleep -Milliseconds 500
    }
    Write-Host ""
    Write-Host "  DONE  Roblox: $foundR  Discord: $foundD" -ForegroundColor Green
}

# ── VIEW MODE ──
if ($Mode -eq "view") {
    if (-not (Test-Path $ResultsFile)) {
        Write-Host "  No results yet. Run a check first." -ForegroundColor Yellow
        exit
    }
    $lines = Get-Content $ResultsFile | Where-Object { $_ -match '^\w+\|' }
    if ($lines.Count -eq 0) {
        Write-Host "  No names found yet." -ForegroundColor Yellow
        exit
    }
    $roblox = $lines | Where-Object { $_ -match '^ROBLOX' }
    $discord = $lines | Where-Object { $_ -match '^DISCORD' }

    Write-Host "  --- ROBLOX ---" -ForegroundColor Cyan
    if (-not $roblox -or $roblox.Count -eq 0) {
        Write-Host "    (none yet)" -ForegroundColor DarkGray
    } else {
        foreach ($l in $roblox) {
            $n = ($l -split '\|')[1]
            $nlen = $n.Length
            $tag = switch ($nlen) {
                3 { "*** [3-letter OG]" }
                4 { "**  [4-letter very rare]" }
                5 { "*   [5-letter rare]" }
                default { "    [$nlen-letter]" }
            }
            Write-Host "    $n  $tag" -ForegroundColor Green
        }
    }
    Write-Host ""
    Write-Host "  --- DISCORD ---" -ForegroundColor Cyan
    if (-not $discord -or $discord.Count -eq 0) {
        Write-Host "    (none yet)" -ForegroundColor DarkGray
    } else {
        foreach ($l in $discord) {
            $n = ($l -split '\|')[1]
            $nlen = $n.Length
            $tag = switch ($nlen) {
                3 { "*** [3-letter OG]" }
                4 { "**  [4-letter very rare]" }
                5 { "*   [5-letter rare]" }
                default { "    [$nlen-letter]" }
            }
            Write-Host "    $n  $tag" -ForegroundColor Green
        }
    }
}
