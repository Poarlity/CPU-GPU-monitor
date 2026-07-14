# UMonitor

**Real-time CPU & GPU resource monitor for Ubuntu — lightweight terminal TUI.**

Monitor CPU usage, memory, NVIDIA GPU utilization, VRAM, temperature, and power — all in a **compact 13-line dashboard** that fits any terminal window.

```
┌─  UMonitor — CPU / GPU Monitor  ──────────────────────────┐
│                                                            │
│  CPU  ██████████░░░░░░  28.3%  2400 MHz  20 cores         │
│  GPU  ░░░░░░░░░░░░░░░░   0.0%  RTX 4060 Laptop GPU       │
│  RAM  ████████████████  55.5%  8.8 GB / 15.8 GB          │
│  Swap ░░░░░░░░░░░░░░░░   0.6%  0.1 GB / 9.5 GB           │
│  VRAM ███████░░░░░░░░░  19.9%  1.6 GB / 8.0 GB           │
│       Temp 49°C  Power 12W                                │
│                                                            │
│   Refresh: 1.0s  │  Quit  Pause  Refresh  D Show details  │
└────────────────────────────────────────────────────────────┘
```

## Features

- **CPU** — total usage %, frequency, core count; per-core breakdown on demand
- **Memory** — RAM and swap bars with human-readable GB values
- **GPU (NVIDIA)** — core usage %, VRAM, temperature, power draw
- **Graceful degradation** — runs normally even without an NVIDIA GPU
- **Compact by default** — 13 lines, no need to stretch the terminal
- **Keyboard controls** — `Q` quit, `P` pause, `R` refresh rate, `D` toggle per-core details, `↑↓` scroll

## Requirements

- Python 3.8+
- Ubuntu (or any Linux); also works on Windows/macOS for CPU/memory
- NVIDIA driver + NVML library (optional — GPU section shows "not available" if missing)

## Quick Start

### Option 1: Launch script (recommended for Ubuntu)

```bash
# 1. Edit umonitor.conf to set your conda environment
vim umonitor.conf
#    Set CONDA_ENV="your_env_name"

# 2. Make executable and run
chmod +x umonitor.sh
./umonitor.sh
```

The launch script automatically:
- Detects your conda installation
- Activates the specified environment
- Installs umonitor + dependencies on first run
- Launches the monitor

You can also override the conda environment on the command line:

```bash
./umonitor.sh my_other_env
```

### Option 2: Manual pip install

```bash
cd umonitor
pip install -e .
umonitor
```

Or without installing:

```bash
cd umonitor
pip install -r requirements.txt
python -m umonitor
```

### Desktop shortcut (Ubuntu)

```bash
cp umonitor.desktop ~/.local/share/applications/
# Now search "UMonitor" in your app launcher
```

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `Q` | Quit |
| `P` | Pause / Resume auto-refresh |
| `R` | Cycle refresh interval (0.5s → 1s → 2s → 5s) |
| `D` | Toggle per-core CPU details |
| `↑` / `↓` | Scroll in detail mode |
| `Ctrl+C` | Quit |

## Configuration

### umonitor.conf

```ini
CONDA_ENV="base"          # Conda environment name
CONDA_PATH=""             # Conda install path (auto-detect if empty)
UMONITOR_DIR=""           # Project directory (default: script location)
REFRESH_INTERVAL="1.0"    # Refresh interval in seconds
```

### src/umonitor/config.py

Python-level defaults for the TUI itself:

```python
REFRESH_INTERVAL = 1.0       # default refresh rate
HISTORY_LENGTH = 60          # CPU history samples retained
REFRESH_OPTIONS = [0.5, 1.0, 2.0, 5.0]  # cycled with R key
CORE_BAR_WIDTH = 20          # bar width in characters
CORE_GRID_COLS = 2           # per-core grid columns
```

## Project Structure

```
umonitor/
├── umonitor.sh              # Launch script (conda auto-detect + activate)
├── umonitor.conf            # User config (conda env, refresh rate)
├── umonitor.desktop         # Ubuntu desktop launcher
├── pyproject.toml           # Package metadata & dependencies
├── requirements.txt         # Pip dependencies
├── README.md
└── src/umonitor/
    ├── __init__.py
    ├── __main__.py          # Entry point (python -m umonitor)
    ├── config.py            # TUI configuration constants
    ├── dashboard.py         # Rich TUI rendering & keyboard loop
    └── monitors/
        ├── cpu.py           # CPU collector (psutil)
        ├── memory.py        # Memory / Swap collector (psutil)
        └── gpu.py           # NVIDIA GPU collector (pynvml)
```

## How It Works

| Library | Role |
|---------|------|
| [`psutil`](https://github.com/giampaolo/psutil) | CPU %, per-core %, memory, swap |
| [`nvidia-ml-py`](https://pypi.org/project/nvidia-ml-py/) | NVIDIA GPU utilisation, VRAM, temperature, power |
| [`rich`](https://github.com/Textualize/rich) | Terminal UI — live refresh, panels, bars, colours |

## License

MIT

---

*Built with [VSCode](https://code.visualstudio.com/) · [CCSwitch](https://marketplace.visualstudio.com/items?itemName=ccswitch.ccswitch) · [DeepSeek V4 Flash](https://deepseek.com)*
