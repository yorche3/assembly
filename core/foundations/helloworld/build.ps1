# build.ps1 — Compila y ejecuta hello_world.asm en Windows
# Uso:
#   .\build.ps1          -> compila
#   .\build.ps1 -Run     -> compila y ejecuta
#   .\build.ps1 -Clean   -> limpia archivos generados

param(
    [switch]$Run,
    [switch]$Clean
)

$TARGET = "hello_world.exe"
$SRC    = "hello_world.asm"
$OBJ    = "hello_world.obj"

# Requisito: NASM instalado y en PATH
$NASM = Get-Command nasm -ErrorAction SilentlyContinue
if (-not $NASM) {
    Write-Host "[ERROR] NASM no encontrado. Instálalo desde https://www.nasm.us/" -ForegroundColor Red
    exit 1
}

# Requisito: GoLink, MSVC link.exe o类似 (para linkear .obj → .exe)
$LINK = "golink"   # GoLink (golink /console hello_world.obj)
# Alternativas:
#   - MSVC:   link /subsystem:console hello_world.obj
#   - Alink:  alink -oPE hello_world.obj

function Build {
    Write-Host "[NASM] $SRC → $OBJ"
    & nasm -f win64 $SRC -o $OBJ
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host "[LINK] $OBJ → $TARGET"
    if ($LINK -eq "golink") {
        & golink /console $OBJ /entry _start
    } else {
        & link /subsystem:console $OBJ /out:$TARGET
    }
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host "[OK]   $TARGET listo" -ForegroundColor Green
}

function RunBuild {
    Build
    Write-Host "[RUN]  Ejecutando $TARGET`n" -ForegroundColor Cyan
    & ".\$TARGET"
}

function CleanBuild {
    Write-Host "[CLEAN] Eliminando archivos generados..."
    if (Test-Path $OBJ)  { Remove-Item $OBJ;  Write-Host "  → $OBJ eliminado" }
    if (Test-Path $TARGET) { Remove-Item $TARGET; Write-Host "  → $TARGET eliminado" }
    Write-Host "[OK]" -ForegroundColor Green
}

# --- Main ---
if ($Clean) {
    CleanBuild
} elseif ($Run) {
    RunBuild
} else {
    Build
}
