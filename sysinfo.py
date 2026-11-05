"""Local hardware info (GPU/CPU/RAM/disk) - safe, read-only."""

import subprocess


def _run(cmd: list[str]) -> str:
    try:
        return subprocess.run(cmd, capture_output=True, text=True, timeout=10).stdout.strip()
    except Exception as e:
        return f"(unavailable: {e})"


def get_system_specs() -> str:
    gpu = _run([
        "nvidia-smi",
        "--query-gpu=name,driver_version,memory.total,memory.used,utilization.gpu,temperature.gpu",
        "--format=csv,noheader",
    ])
    cpu = _run(["bash", "-c", "lscpu | grep -E 'Model name|^CPU\\(s\\)|MHz'"])
    mem = _run(["free", "-h"])
    disk = _run(["df", "-h", "/"])
    return (
        f"GPU: {gpu or '(not available)'}\n\n"
        f"CPU:\n{cpu}\n\n"
        f"Memory:\n{mem}\n\n"
        f"Disk (/):\n{disk}"
    )
