$version = "v2.4.1"
$git_path = "C:\Program Files\Git\bin\git.exe"

# 1. Add all changes
Write-Host "Adding changes..."
& $git_path add .

# 2. Commit
Write-Host "Commiting changes..."
$commit_msg = "v2.4.1: Smart Alerts, Achievement Fix & Logic Validation"
& $git_path commit -m "$commit_msg"

# 3. Tag
Write-Host "Tagging version $version ..."
& $git_path tag -a "$version" -m "Release ${version}: Completion alerts for Shopping List and strict filtering for achievements (looting only)."

# 4. Push Main
Write-Host "Pushing to main..."
& $git_path push origin main

# 5. Push Tags
Write-Host "Pushing tags..."
& $git_path push origin "$version"

Write-Host "Release $version completed successfully!" -ForegroundColor Green
