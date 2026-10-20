
$ErrorActionPreference = "Continue"

while ($true) {
    Start-Sleep -Seconds 5

    # Stage tracked changes and new Python/Jupyter files
    git add -u -- '*.py' '*.ipynb' 2>$null

    Get-ChildItem -Path . -Recurse -File |
        Where-Object {
            $_.Extension -in '.py', '.ipynb' -and
            $_.FullName -notmatch '[\\/](\.git|\.venv|venv|__pycache__)[\\/]'
        } |
        ForEach-Object {
            git add -- "$($_.FullName.Substring((Get-Location).Path.Length + 1))"
        }

    git diff --cached --quiet
    if ($LASTEXITCODE -eq 1) {
        git commit -m "Auto-sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

        if ($LASTEXITCODE -eq 0) {
            git push origin main
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Push failed; check connection and retry."
            } else {
                Write-Host "GitHub sync successful."
            }
        }
    }
}
