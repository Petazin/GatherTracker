$version = "v2.8.0"
$git_path = "C:\Program Files\Git\bin\git.exe"

# 1. Add all changes
Write-Host "Adding changes..."
& $git_path add .

# 2. Commit
Write-Host "Commiting changes..."
$commit_msg = "v2.8.0: Static TBC Database, Instant Parsing & SV Cleanup"
& $git_path commit -m "$commit_msg"

# 3. Tag
Write-Host "Tagging version $version ..."
& $git_path tag -a "$version" -m "Release ${version}: Full AtlasLoot TBC integration (7600+ recipes), removal of legacy Tooltip Scanning, and auto-cleanup of saved variables."

# 4. Push Main
Write-Host "Pushing to main..."
& $git_path push origin main

# 5. Push Tags
Write-Host "Pushing tags..."
& $git_path push origin "$version"

Write-Host "Release $version completed successfully!" -ForegroundColor Green
