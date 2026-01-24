$ErrorActionPreference = "Stop"

Write-Host "Iniciando Release v1.8.0..." -ForegroundColor Cyan

# 1. Stage changes
Write-Host "1. Staging files..."
git add .

# 2. Commit
Write-Host "2. Committing..."
git commit -m "Release v1.8.0 - Global Localization"

# 3. Tag
Write-Host "3. Tagging v1.8.0..."
git tag -a v1.8.0 -m "Localization Update: Added full English (enUS) and Spanish (esES) support. Auto-detection of client language. Global string refactor."

# 4. Push
Write-Host "4. Pushing to GitHub (Main + Tags)..."
git push origin main
git push origin v1.8.0

Write-Host "¡Release v1.8.0 completado con éxito!" -ForegroundColor Green
