[1mdiff --git a/install.ps1 b/install.ps1[m
[1mindex 35c92bc..08bba41 100644[m
[1m--- a/install.ps1[m
[1m+++ b/install.ps1[m
[36m@@ -1,4 +1,4 @@[m
[31m-# Armando (The Gardener) - Windows PowerShell Installer[m
[32m+[m[32m# Armando - Windows PowerShell Installer[m
 # Symlinks agents and commands into Claude Code global directories[m
 # and adds the armando command to your PowerShell profile.[m
 #[m
[36m@@ -67,7 +67,7 @@[m [mif ($profileContent -match "function armando") {[m
 } else {[m
     $funcText = @"[m
 [m
[31m-# Armando (The Gardener) - AI development team[m
[32m+[m[32m# Armando - AI development team[m
 function armando {[m
     # Pull latest agent defs and handoffs before starting[m
     `$armandoRepo = Join-Path `$HOME "armando"[m
[36m@@ -85,7 +85,7 @@[m [mfunction armando {[m
         `$version = "dev"[m
     }[m
     Write-Host ""[m
[31m-    Write-Host "  🌿 Armando v`$version - The Gardener" -ForegroundColor Green[m
[32m+[m[32m    Write-Host "  🌿 Armando v`$version" -ForegroundColor Green[m
     Write-Host "  Let's go do it, dude." -ForegroundColor DarkGray[m
     Write-Host ""[m
 [m
[1mdiff --git a/install.sh b/install.sh[m
[1mindex 6e38633..a2e380a 100755[m
[1m--- a/install.sh[m
[1m+++ b/install.sh[m
[36m@@ -1,5 +1,5 @@[m
 #!/bin/bash[m
[31m-# Armando (The Gardener): Linux/Mac Installer[m
[32m+[m[32m# Armando: Linux/Mac Installer[m
 # Symlinks agents and commands into Claude Code's global directories[m
 # and adds the 'armando' command to your shell profile.[m
 [m
[36m@@ -65,7 +65,7 @@[m [melse[m
     echo "" >> "$PROFILE"[m
     cat >> "$PROFILE" << 'ARMANDO_FUNC'[m
 [m
[31m-# Armando (The Gardener): AI development team[m
[32m+[m[32m# Armando: AI development team[m
 armando() {[m
     # Pull latest agent defs and handoffs before starting[m
     if [ -d "$HOME/armando/.git" ]; then[m
