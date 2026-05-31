<#
.SYNOPSIS
    Build and run Calculator Unit Tests on Windows (PowerShell)

.DESCRIPTION
    Assembles the calculator.asm source, the test suite, and the entry point
    using NASM, links them with LD, and runs the resulting binary.

    Requirements:
        - NASM (Netwide Assembler) in PATH
        - A linker that supports ELF64 (e.g. mingw64 or WSL ld)

    On native Windows without WSL, consider using a cross-linker or
    running inside WSL. Alternatively, for a pure Windows build,
    use goLink (golink) or MS LINK with COFF format.

    This script assumes a WSL/Linux environment or a Unix-like shell
    (MSYS2, Cygwin) where nasm and ld are available.

.EXAMPLE
    .\run_tests.ps1          # Build and run
    .\run_tests.ps1 -Build   # Only build
    .\run_tests.ps1 -Run     # Only run (if already built)
    .\run_tests.ps1 -Clean   # Clean build artifacts
#>

param(
    [switch]$Build,
    [switch]$Run,
    [switch]$Clean,
    [switch]$Help
)

# --- Configuration -------------------------------------------
$SrcDir     = "src"
$TestDir    = "test"
$ObjDir     = "obj"

$CalculatorSrc  = Join-Path $SrcDir "calculator.asm"
$TestSrc        = Join-Path $TestDir "calculator_test.asm"
$RunSrc         = Join-Path $TestDir "run_tests.asm"
$PrintSrc       = Join-Path $TestDir "print_utils.asm"

$CalculatorObj  = Join-Path $ObjDir "calculator.o"
$TestObj        = Join-Path $ObjDir "calculator_test.o"
$RunObj         = Join-Path $ObjDir "run_tests.o"
$PrintObj       = Join-Path $ObjDir "print_utils.o"
$Target         = Join-Path $TestDir "run_tests"

$Asm     = "nasm"
$AsmOpts = @("-f", "elf64", "-g", "-F", "dwarf")
$Linker  = "ld"
$LinkOpts = @("-m", "elf_x86_64")

# --- Helper Functions ----------------------------------------
function Show-Help {
    Write-Host @"
Usage: .\run_tests.ps1 [[-Build] | [-Run] | [-Clean] | [-Help]]

Switches (mutually exclusive, default is Build+Run):
    -Build    Only assemble and link.
    -Run      Only execute the tests (assumes already built).
    -Clean    Remove all build artifacts.
    -Help     Show this help message.

Examples:
    .\run_tests.ps1          # Build and run
    .\run_tests.ps1 -Build   # Build only
    .\run_tests.ps1 -Run     # Run only
    .\run_tests.ps1 -Clean   # Clean
"@
}

function Invoke-Assemble {
    param([string]$Source, [string]$Output)

    $srcRel = (Resolve-Path $Source -Relative)
    Write-Host "  ASM  $srcRel"

    $args = @($AsmOpts, $Source, "-o", $Output)
    & $Asm @args 2>&1 | ForEach-Object { Write-Host "    $_" }
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Assembly failed for $Source" -ForegroundColor Red
        exit 1
    }
}

function Invoke-Build {
    Write-Host "=== Building Calculator Unit Tests ===" -ForegroundColor Cyan

    # Create obj directory
    if (-not (Test-Path $ObjDir)) {
        New-Item -ItemType Directory -Path $ObjDir -Force | Out-Null
    }

    # Assemble source files
    Invoke-Assemble -Source $CalculatorSrc -Output $CalculatorObj
    Invoke-Assemble -Source $TestSrc       -Output $TestObj
    Invoke-Assemble -Source $RunSrc        -Output $RunObj
    Invoke-Assemble -Source $PrintSrc      -Output $PrintObj

    # Link
    Write-Host "  LINK $Target"
    $linkArgs = @($LinkOpts, $CalculatorObj, $TestObj, $RunObj, $PrintObj, "-o", $Target)
    & $Linker @linkArgs 2>&1 | ForEach-Object { Write-Host "    $_" }
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Linking failed" -ForegroundColor Red
        exit 1
    }

    Write-Host "Build complete: $Target" -ForegroundColor Green
}

function Invoke-Run {
    if (-not (Test-Path $Target)) {
        Write-Host "ERROR: Binary not found. Run with -Build first." -ForegroundColor Red
        exit 1
    }

    Write-Host "=== Running Calculator Unit Tests ===" -ForegroundColor Cyan
    Write-Host ""

    # Use WSL if available on Windows for running ELF binaries
    $isWSL = (Get-Command "wsl.exe" -ErrorAction SilentlyContinue) -ne $null

    if ($isWSL) {
        $fullPath = Resolve-Path $Target
        $wslPath = $fullPath.Path -replace '^([A-Za-z]):\\', '/mnt/$1/'
        $wslPath = $wslPath -replace '\\', '/'
        & wsl.exe ./$wslPath 2>&1 | ForEach-Object { Write-Host $_ }
    }
    else {
        # Direct execution (Linux / MSYS2 / Cygwin)
        & ./$Target 2>&1 | ForEach-Object { Write-Host $_ }
    }

    Write-Host ""
    Write-Host "Exit code: $LASTEXITCODE" -ForegroundColor $(
        if ($LASTEXITCODE -eq 0) { "Green" } else { "Red" }
    )
}

function Invoke-Clean {
    Write-Host "=== Cleaning ===" -ForegroundColor Yellow

    if (Test-Path $ObjDir) {
        Remove-Item -Recurse -Force $ObjDir
        Write-Host "  Removed $ObjDir"
    }
    if (Test-Path $Target) {
        Remove-Item -Force $Target
        Write-Host "  Removed $Target"
    }

    # Also remove old object files from src/ and test/ if any
    Get-ChildItem -Path $SrcDir  -Filter "*.o" -ErrorAction SilentlyContinue | Remove-Item -Force
    Get-ChildItem -Path $TestDir -Filter "*.o" -ErrorAction SilentlyContinue | Remove-Item -Force

    Write-Host "Clean complete." -ForegroundColor Green
}

# --- Main ----------------------------------------------------
if ($Help) {
    Show-Help
    exit 0
}

# Determine mode
if ($Build -and -not $Run) {
    Invoke-Build
}
elseif ($Run -and -not $Build) {
    Invoke-Run
}
elseif ($Clean) {
    Invoke-Clean
}
else {
    # Default: build and run
    Invoke-Build
    Invoke-Run
}
