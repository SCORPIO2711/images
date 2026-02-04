# push_all.ps1
# Upload tout le contenu du dossier courant vers GitHub

Write-Host "Upload de toutes les images..." -ForegroundColor Cyan

# Verif git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Host "ERREUR: Git n'est pas installe ou pas dans le PATH." -ForegroundColor Red
  Write-Host "Installe Git: https://git-scm.com/download/win"
  Pause
  exit 1
}

# Ajouter tout
git add -A

# Verifier s'il y a des changements
$changes = git status --porcelain
if ([string]::IsNullOrWhiteSpace($changes)) {
  Write-Host "Aucun changement a envoyer (rien a commit)." -ForegroundColor Yellow
  Pause
  exit 0
}

# Commit + push
$dt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git commit -m "Upload images $dt"
git push

Write-Host "OK: Push termine." -ForegroundColor Green
Pause
