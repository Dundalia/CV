#!/bin/bash

#-------------------------------------------------------------------------------
# Build script for LaTeX CV (XeLaTeX + Biber)
# Usage: ./build.sh [clean|distclean]
#-------------------------------------------------------------------------------

set -e  # Exit on error

MAIN_FILE="resume"
CV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$CV_DIR"

#-------------------------------------------------------------------------------
# Helper functions
#-------------------------------------------------------------------------------

build_cv() {
    echo "========================================"
    echo "Building CV: ${MAIN_FILE}.tex"
    echo "========================================"
    
    # First pass: Generate auxiliary files
    echo "[1/5] Running XeLaTeX (first pass)..."
    xelatex -interaction=nonstopmode -halt-on-error "${MAIN_FILE}.tex"
    
    # Process bibliography
    echo "[2/5] Running Biber..."
    biber "${MAIN_FILE}"
    
    # Second pass: Resolve references
    echo "[3/5] Running XeLaTeX (second pass)..."
    xelatex -interaction=nonstopmode -halt-on-error "${MAIN_FILE}.tex"
    
    # Third pass: Final polish
    echo "[4/5] Running XeLaTeX (third pass)..."
    xelatex -interaction=nonstopmode -halt-on-error "${MAIN_FILE}.tex"
    
    echo ""
    echo "✓ PDF complete! Output: ${MAIN_FILE}.pdf"
    
    # Generate Markdown version
    echo "[5/5] Generating Markdown version..."
    python3 generate_md.py
    
    # Copy to Obsidian vault
    OBSIDIAN_PATH="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault/Career/Profile"
    if [ -d "$OBSIDIAN_PATH" ]; then
        cp "${MAIN_FILE}.md" "$OBSIDIAN_PATH/${MAIN_FILE}.md"
        echo "✓ Copied to Obsidian vault"
    else
        echo "⚠ Obsidian vault path not found, skipping copy"
    fi
    
    echo "========================================"
}

clean_aux() {
    echo "Cleaning auxiliary files..."
    rm -f *.aux *.bbl *.bcf *.blg *.log *.out *.run.xml *.fdb_latexmk *.fls
    rm -f *.synctex.gz *.toc *.lof *.lot *.nav *.snm *.vrb
    rm -f *.bcf-SAVE-ERROR
    echo "✓ Auxiliary files removed"
}

clean_all() {
    clean_aux
    echo "Removing PDF and Markdown outputs..."
    rm -f "${MAIN_FILE}.pdf"
    rm -f "${MAIN_FILE}.md"
    echo "✓ All generated files removed"
}

#-------------------------------------------------------------------------------
# Main script
#-------------------------------------------------------------------------------

case "${1:-build}" in
    clean)
        clean_aux
        ;;
    distclean)
        clean_all
        ;;
    build|"")
        build_cv
        ;;
    *)
        echo "Usage: $0 [build|clean|distclean]"
        echo "  build (default) - Compile the CV"
        echo "  clean           - Remove auxiliary files"
        echo "  distclean       - Remove all generated files including PDF"
        exit 1
        ;;
esac

