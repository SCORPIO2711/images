# force_reupload_assets.ps1
# Upload complet de toutes les images dans assets/
# + suppression des images a la racine du repo

$SOURCE = "D:\BlackNova\ImagesGuardianAuth\ImagesGuardianAuth"
$ASSETS = "assets"

Write-Host "FORCE REUPLOAD -> assets/ (avec creation automatique)" -ForegroundColor Cyan

# ============================
# VERIFICATIONS
# ============================

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Host "ERREUR: Git n'est pas installe ou pas dans le PATH." -ForegroundColor Red
  Pause
  exit 1
}

if (!(Test-Path ".git")) {
  Write-Host "ERREUR: Lance ce script DANS le dossier du repo clone (il manque .git)." -ForegroundColor Red
  Pause
  exit 1
}

if (!(Test-Path $SOURCE)) {
  Write-Host "ERREUR: Le dossier SOURCE n'existe pas: $SOURCE" -ForegroundColor Red
  Pause
  exit 1
}

# ============================
# PULL
# ============================

Write-Host "-> Mise a jour du repo (git pull)" -ForegroundColor DarkCyan
git pull

# Extensions images
$exts = @("*.png","*.jpg","*.jpeg","*.gif","*.webp","*.bmp")

# ============================
# SUPPRESSION RACINE
# ============================

Write-Host "-> Suppression des images a la racine du repo..." -ForegroundColor Yellow

foreach ($ext in $exts) {
  Get-ChildItem -Path . -File -Filter $ext -ErrorAction SilentlyContinue |
    Remove-Item -Force -ErrorAction SilentlyContinue
}

# ============================
# CREATION / RESET ASSETS
# ============================

Write-Host "-> Reset complet du dossier assets/..." -ForegroundColor Yellow

# Supprime assets/ si deja present
if (Test-Path $ASSETS) {
  Remove-Item -Recurse -Force $ASSETS
}

# Cree assets/ automatiquement
New-Item -ItemType Directory -Path $ASSETS | Out-Null
Write-Host "Dossier assets/ cree !" -ForegroundColor Green

# ============================
# COPIE COMPLETE
# ============================

Write-Host "-> Copie COMPLETE depuis $SOURCE vers assets/ ..." -ForegroundColor DarkCyan

$srcRoot = (Resolve-Path $SOURCE).Path
$destRoot = (Resolve-Path $ASSETS).Path

$files = foreach ($ext in $exts) {
  Get-ChildItem -Path $srcRoot -Recurse -File -Filter $ext
}

$total = $files.Count
$copied = 0

foreach ($f in $files) {

  # Chemin relatif
  $rel = $f.FullName.Substring($srcRoot.Length).TrimStart("\")

  # Destination finale
  $destPath = Join-Path $destRoot $rel
  $destDir = Split-Path $destPath -Parent

  # Cree les sous-dossiers si besoin
  if (!(Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
  }

  # Copie en ecrasant
  Copy-Item -LiteralPath $f.FullName -Destination $destPath -Force

  $copied++
  if (($copied % 500) -eq 0) {
    Write-Host ("  Copie: {0}/{1}" -f $copied, $total)
  }
}

Write-Host ("Copie terminee: {0} images ajoutees dans assets/" -f $copied) -ForegroundColor Green

# ============================
# COMMIT + PUSH
# ============================

Write-Host "-> Git add" -ForegroundColor DarkCyan
git add -A

$changes = git status --porcelain
if ([string]::IsNullOrWhiteSpace($changes)) {
  Write-Host "Aucun changement detecte." -ForegroundColor Yellow
  Pause
  exit 0
}

$dt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "-> Commit" -ForegroundColor DarkCyan
git commit -m "Force reupload assets $dt"

Write-Host "-> Push GitHub" -ForegroundColor DarkCyan
git push

Write-Host "OK: Upload complet termine !" -ForegroundColor Green
Pause
