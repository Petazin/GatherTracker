$version = "v1.9.0"
$git_path = "C:\Program Files\Git\bin\git.exe"

# 1. Add all changes
& $git_path add .

# 2. Commit
$commit_msg = "feat(release): ${version} - Smart Utility Mode"
& $git_path commit -m "$commit_msg"

# 3. Tag
& $git_path tag -a "$version" -m "Release ${version}: Utility Mode (Repair/Bags), HUD Stats, Priority Alerts"

# 4. Push Main
& $git_path push origin main

# 5. Push Tags
& $git_path push origin "$version"

Write-Host "Release ${version} completed successfully!" -ForegroundColor Green
