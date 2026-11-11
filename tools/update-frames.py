#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Regenerate frames/ from the fish in hugomd/ascii-live (GPL-3.0).

Downloads frames/fish.go, replaces the dotted background with spaces, drops
the stray marker in the last column of the first row and trims the empty
border shared by all frames.
"""
import ast
import re
import urllib.request
from pathlib import Path

SOURCE = "https://raw.githubusercontent.com/hugomd/ascii-live/master/frames/fish.go"
OUT = Path(__file__).resolve().parent.parent / "frames"


def main() -> None:
    go = urllib.request.urlopen(SOURCE, timeout=30).read().decode()
    body = go[go.index("fishFrames = []string{"):]
    raw = [ast.literal_eval(s) for s in re.findall(r'"(?:[^"\\]|\\.)*"', body)]

    frames = []
    for frame in raw:
        lines = frame.split("\n")
        lines = [lines[0][:79]] + [l[4:] if l.startswith("    ") else l for l in lines[1:]]
        frames.append([l.replace(".", " ").rstrip() for l in lines])

    height = max(map(len, frames))
    frames = [f + [""] * (height - len(f)) for f in frames]
    used = [i for i in range(height) if any(f[i].strip() for f in frames)]
    top, bottom = used[0], used[-1]
    left = min(len(l) - len(l.lstrip()) for f in frames for l in f[top:bottom + 1] if l.strip())
    right = max(len(l) for f in frames for l in f[top:bottom + 1])

    OUT.mkdir(exist_ok=True)
    for old in OUT.glob("frame-*.txt"):
        old.unlink()
    for i, f in enumerate(frames):
        (OUT / f"frame-{i}.txt").write_text(
            "\n".join(l[left:right].ljust(right - left) for l in f[top:bottom + 1]) + "\n")
    print(f"wrote {len(frames)} frames, {right - left}x{bottom - top + 1}, to {OUT}")


if __name__ == "__main__":
    main()
