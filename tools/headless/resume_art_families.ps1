# Resume the art-family design sessions after the usage limit resets (set up 2026-11-11 ~17:00).
# Waits until $StartAt, then runs the four job files in parallel (run_jobs.py skips families already done and pauses
# 15 min on a usage-limit message), then lints every family file. Log: design/arts/_logs/resume.log
param([string]$StartAt = "18:10")
$repo = "C:\Users\xphuo\IdeaProjects\my-game"
Set-Location $repo
$log = Join-Path $repo "design\arts\_logs\resume.log"
"[$(Get-Date -Format s)] waiting until $StartAt" | Out-File -FilePath $log -Append -Encoding utf8
$target = [datetime]::ParseExact($StartAt, "HH:mm", $null)
if ($target -lt (Get-Date)) { $target = $target.AddDays(1) }
while ((Get-Date) -lt $target) { Start-Sleep -Seconds 60 }
"[$(Get-Date -Format s)] starting runners" | Out-File -FilePath $log -Append -Encoding utf8
$procs = @()
foreach ($k in 0..3) {
    $procs += Start-Process -FilePath python -PassThru -WindowStyle Hidden -WorkingDirectory $repo -ArgumentList @(
        "-I", "tools/headless/run_jobs.py", "design/arts/_logs/family2-jobs-$k.json",
        "design/arts/_logs/family2-run-$k", "--model", "sonnet")
}
$procs | Wait-Process
"[$(Get-Date -Format s)] runners done" | Out-File -FilePath $log -Append -Encoding utf8
$files = Get-ChildItem (Join-Path $repo "design\arts") -Filter "family-*.json" | ForEach-Object { $_.FullName }
& python -I tools/design/arts/lint_arts.py @files 2>&1 | Out-File -FilePath $log -Append -Encoding utf8
"[$(Get-Date -Format s)] finished" | Out-File -FilePath $log -Append -Encoding utf8
