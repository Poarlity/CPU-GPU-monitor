#!/usr/bin/env bash
# ============================================================
# UMonitor — Launch Script for Ubuntu
# ============================================================
# Usage:
#   ./umonitor.sh              # launch with settings from umonitor.conf
#   ./umonitor.sh myenv        # override conda env name
#   ./umonitor.sh -h           # show help
#
# Make executable:  chmod +x umonitor.sh
# Desktop shortcut: copy to ~/.local/share/applications/ or
#                    create a .desktop file pointing here.
# ============================================================

set -euo pipefail

# Resolve the directory this script lives in (handles symlinks).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ------------------------------------------------------------------
# 1.  Load config file
# ------------------------------------------------------------------
CONF_FILE="${SCRIPT_DIR}/umonitor.conf"
if [[ -f "${CONF_FILE}" ]]; then
    # shellcheck source=/dev/null
    source "${CONF_FILE}"
else
    echo "[umonitor] Config file not found at ${CONF_FILE}, using defaults."
    CONDA_ENV="base"
    CONDA_PATH=""
    UMONITOR_DIR=""
    REFRESH_INTERVAL="1.0"
fi

# CLI override for conda env name
if [[ ${#} -gt 0 && "${1}" != "-h" && "${1}" != "--help" ]]; then
    CONDA_ENV="${1}"
fi

# Quick help
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "UMonitor — Real-time CPU & GPU Monitor"
    echo ""
    echo "Usage:  ./umonitor.sh [conda_env_name]"
    echo ""
    echo "Config: edit umonitor.conf to set defaults."
    exit 0
fi

# ------------------------------------------------------------------
# 2.  Find conda installation
# ------------------------------------------------------------------
_find_conda() {
    # Priority: explicit config → auto-detect common paths → PATH fallback
    if [[ -n "${CONDA_PATH:-}" && -f "${CONDA_PATH}/etc/profile.d/conda.sh" ]]; then
        echo "${CONDA_PATH}"
        return
    fi

    local search=(
        "${HOME}/anaconda3"
        "${HOME}/miniconda3"
        "${HOME}/miniforge3"
        "${HOME}/mambaforge"
        "/opt/conda"
        "/opt/anaconda3"
        "/opt/miniconda3"
    )

    for dir in "${search[@]}"; do
        if [[ -f "${dir}/etc/profile.d/conda.sh" ]]; then
            echo "${dir}"
            return
        fi
    done

    # Last resort: try the conda on PATH
    if command -v conda &>/dev/null; then
        echo ""
        return
    fi

    echo ""
}

CONDA_DIR="$(_find_conda)"

if [[ -z "${CONDA_DIR}" ]]; then
    # conda not found as a directory — try sourcing via PATH conda
    if command -v conda &>/dev/null; then
        CONDA_DIR="$(dirname "$(dirname "$(command -v conda)")")"
    fi
fi

# ------------------------------------------------------------------
# 3.  Activate conda environment
# ------------------------------------------------------------------
_activate_conda() {
    if [[ -n "${CONDA_DIR}" && -f "${CONDA_DIR}/etc/profile.d/conda.sh" ]]; then
        # shellcheck source=/dev/null
        source "${CONDA_DIR}/etc/profile.d/conda.sh"
        conda activate "${CONDA_ENV}" 2>/dev/null || {
            echo "[umonitor] ERROR: conda environment '${CONDA_ENV}' not found."
            echo "[umonitor] Available environments:"
            conda env list 2>/dev/null || true
            exit 1
        }
    elif command -v conda &>/dev/null; then
        # conda is on PATH but we don't have conda.sh — try conda run
        # This path also works for conda installations without conda.sh
        CONDA_DIR="$(dirname "$(dirname "$(command -v conda)")")"
        if [[ -f "${CONDA_DIR}/etc/profile.d/conda.sh" ]]; then
            source "${CONDA_DIR}/etc/profile.d/conda.sh"
            conda activate "${CONDA_ENV}"
        fi
    else
        echo "[umonitor] WARNING: conda not found. Running with system Python."
        echo "[umonitor] Install conda or set CONDA_PATH in umonitor.conf."
        return 1
    fi
    return 0
}

echo "[umonitor] Conda dir  : ${CONDA_DIR:-auto-detect}"
echo "[umonitor] Environment: ${CONDA_ENV}"

if _activate_conda; then
    echo "[umonitor] Python     : $(which python)"
else
    echo "[umonitor] Falling back to system Python: $(which python 2>/dev/null || echo 'not found')"
fi

# ------------------------------------------------------------------
# 4.  Resolve project directory & install umonitor package
# ------------------------------------------------------------------
PROJECT_DIR="${UMONITOR_DIR:-${SCRIPT_DIR}}"
cd "${PROJECT_DIR}"

# Install umonitor (editable mode) + all dependencies if not already installed.
# pip install -e . is idempotent — fast no-op on subsequent runs.
if ! python -c "import umonitor" &>/dev/null; then
    echo "[umonitor] Installing umonitor + dependencies (first run)..."
    pip install -e . --quiet
    echo "[umonitor] Install complete."
fi

echo "[umonitor] Launching UMonitor..."
echo ""

# Run with optional refresh interval from config
export UMONITOR_REFRESH="${REFRESH_INTERVAL:-1.0}"
python -m umonitor

echo ""
echo "[umonitor] Done."
