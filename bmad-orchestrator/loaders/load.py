#!/usr/bin/env python3
"""
load.py — One-click multi-IDE loader for the BMAD-Orchestrated Custom AI Stack.

Reads AGENTS.md (source of truth) + agents/ + skills/ + hooks/ from
this package, and generates the IDE-specific rule files for the IDE you choose.

Usage:
  python load.py                     # interactive picker
  python load.py --ide cursor        # direct
  python load.py --auto              # auto-detect from project files
  python load.py --list              # list known IDEs
  python load.py --add-ide <name>    # scaffold a new IDE template
  python load.py --target <dir>      # write into <dir> (default: cwd)
"""
from __future__ import annotations

import argparse
import glob
import json
import os
import shutil
import sys
from pathlib import Path
from typing import Any

# Force UTF-8 on Windows consoles (CP1252 chokes on emoji)
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except (AttributeError, OSError):
        pass

PKG_DIR = Path(__file__).resolve().parent.parent
REGISTRY_PATH = PKG_DIR / "loaders" / "ide-registry.json"
AGENTS_MD = PKG_DIR / "AGENTS.md"


def load_registry() -> dict[str, Any]:
    return json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))


def list_ides() -> None:
    reg = load_registry()
    print("\nKnown IDEs:")
    for key, ide in reg["ides"].items():
        print(f"  {key:<14}  {ide['label']}")
    print(f"\nUnlisted IDE? Run:  python load.py --add-ide <name>\n")


def detect_ide(target: Path) -> str | None:
    reg = load_registry()
    for key, ide in reg["ides"].items():
        for marker in ide.get("detect", []):
            if (target / marker).exists():
                return key
    return None


def pick_ide_interactive() -> str:
    reg = load_registry()
    keys = list(reg["ides"].keys())
    print("\n=================================================")
    print("  BMAD Orchestrator — Multi-IDE Loader")
    print("=================================================\n")
    for i, key in enumerate(keys, 1):
        ide = reg["ides"][key]
        print(f"  [{i:>2}] {key:<14}  {ide['label']}")
    print(f"  [ 0]  Other (not listed) — scaffold a new IDE template")
    print()
    while True:
        choice = input("Pick a number (or type a name): ").strip()
        if choice == "0" or choice.lower() == "other":
            name = input("New IDE name (kebab-case): ").strip().lower()
            if name:
                add_new_ide(name)
                print(f"\n✅ Template created: bmad-orchestrator/loaders/ide-templates/{name}.md")
                print("   Fill in the output mappings, then re-run with: --ide", name)
            sys.exit(0)
        if choice.isdigit():
            idx = int(choice) - 1
            if 0 <= idx < len(keys):
                return keys[idx]
        if choice in keys:
            return choice
        print("Invalid choice. Try again.")


def add_new_ide(name: str) -> None:
    tmpl_dir = PKG_DIR / "loaders" / "ide-templates"
    tmpl_dir.mkdir(parents=True, exist_ok=True)
    tmpl = tmpl_dir / f"{name}.md"
    tmpl.write_text(f"""# IDE Template: {name}

> Fill in the registry entry below, then add it to `loaders/ide-registry.json` under `ides.{name}`.

```json
{{
  "label": "<Display Name>",
  "detect": ["<filename or dir that signals this IDE is present>"],
  "outputs": [
    {{"from": "AGENTS.md", "to": "<target file>", "format": "passthrough"}},
    {{"from": "agents/*.md", "to": "<dir>/{{name}}.md", "format": "passthrough"}},
    {{"from": "skills/*/SKILL.md", "to": "<dir>/{{name}}/SKILL.md", "format": "passthrough"}}
  ]
}}
```

## Format options

- `passthrough` — copy file verbatim
- `cursor_mdc` — wrap with Cursor MDC frontmatter (description + globs)
- `kiro_skill` — keep YAML frontmatter; ensure name + description fields
- `kiro_agent_json` — convert agent .md frontmatter to Kiro JSON config
- `merge_hooks_json` — merge hooks into existing settings.local.json

## After filling in

1. Add the IDE block to `loaders/ide-registry.json` under `ides.{name}`
2. Run: `python loaders/load.py --ide {name}`
3. Verify the generated files in your project
""", encoding="utf-8")


def render_passthrough(src: Path, header_note: bool | str = False) -> str:
    body = src.read_text(encoding="utf-8")
    if header_note:
        note = header_note if isinstance(header_note, str) else f"Generated from {src.name} — do not edit by hand."
        body = f"<!-- {note} -->\n\n{body}"
    return body


def render_cursor_mdc(src: Path) -> str:
    """Wrap a markdown file as a Cursor .mdc rule."""
    body = src.read_text(encoding="utf-8")
    name = src.stem
    fm = (
        f"---\n"
        f"description: {name} — auto-loaded from AGENTS.md / bmad-orchestrator\n"
        f"globs: ['**/*']\n"
        f"alwaysApply: true\n"
        f"---\n\n"
    )
    return fm + body


def render_kiro_skill(src: Path) -> str:
    """Kiro skills require YAML frontmatter with name + description. Pass through if already present."""
    body = src.read_text(encoding="utf-8")
    if body.startswith("---"):
        return body
    name = src.parent.name
    fm = (
        f"---\n"
        f"name: {name}\n"
        f"description: {name} skill — generated from bmad-orchestrator\n"
        f"---\n\n"
    )
    return fm + body


def render_kiro_agent_json(src: Path) -> str:
    """Convert agent .md frontmatter to Kiro JSON agent config."""
    body = src.read_text(encoding="utf-8")
    fm: dict[str, Any] = {}
    md_body = body
    if body.startswith("---"):
        try:
            _, fm_text, md_body = body.split("---", 2)
            for line in fm_text.strip().splitlines():
                if ":" in line:
                    k, v = line.split(":", 1)
                    fm[k.strip()] = v.strip().strip('"').strip("'")
        except ValueError:
            pass
    name = fm.get("name", src.stem)
    desc = fm.get("description", f"{name} agent")
    model = fm.get("model", "sonnet")
    cfg = {
        "name": name,
        "description": desc,
        "model": model,
        "tools": ["*"],
        "allowedTools": ["*"],
        "resources": [
            f"skill://~/.kiro/skills/*"
        ],
        "prompt": md_body.strip(),
    }
    return json.dumps(cfg, indent=2)


def merge_hooks_json(src: Path, dst: Path) -> str:
    """Deep-merge our hooks block into an existing settings.local.json (or create new)."""
    new = json.loads(src.read_text(encoding="utf-8"))
    new_hooks = new.get("hooks", {})
    if dst.exists():
        try:
            existing = json.loads(dst.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            existing = {}
    else:
        existing = {}
    existing_hooks = existing.get("hooks", {})
    # Merge per-event lists, dedupe by command string
    for event, blocks in new_hooks.items():
        existing_blocks = existing_hooks.get(event, [])
        existing_cmds = set()
        for b in existing_blocks:
            for h in b.get("hooks", []):
                if h.get("type") == "command":
                    existing_cmds.add(h.get("command"))
        for b in blocks:
            cmds_in_block = [h.get("command") for h in b.get("hooks", []) if h.get("type") == "command"]
            if any(c in existing_cmds for c in cmds_in_block):
                continue
            existing_blocks.append(b)
        existing_hooks[event] = existing_blocks
    existing["hooks"] = existing_hooks
    return json.dumps(existing, indent=2)


def write_with_format(src: Path, dst: Path, fmt: str, header_note: bool | str = False) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    if fmt == "passthrough":
        dst.write_text(render_passthrough(src, header_note=header_note), encoding="utf-8")
    elif fmt == "cursor_mdc":
        dst.write_text(render_cursor_mdc(src), encoding="utf-8")
    elif fmt == "kiro_skill":
        dst.write_text(render_kiro_skill(src), encoding="utf-8")
    elif fmt == "kiro_agent_json":
        dst.write_text(render_kiro_agent_json(src), encoding="utf-8")
    elif fmt == "merge_hooks_json":
        dst.write_text(merge_hooks_json(src, dst), encoding="utf-8")
    else:
        raise ValueError(f"Unknown format: {fmt}")


def expand_glob(pattern: str, base: Path) -> list[Path]:
    if "*" not in pattern:
        return [base / pattern]
    return [Path(p) for p in glob.glob(str(base / pattern))]


def resolve_dst(template: str, src: Path) -> str:
    """Replace {name} placeholder OR append source name if template ends with /."""
    # Trailing-slash directory target → append source filename
    if template.endswith("/") or template.endswith("\\"):
        return template + src.name
    if "{name}" not in template:
        return template
    if src.name == "SKILL.md":
        name = src.parent.name
    else:
        name = src.stem
    return template.replace("{name}", name)


def _warn_hooks_on_windows(ide: dict[str, Any]) -> None:
    """Warn Windows users when the IDE uses .sh hooks that require bash."""
    if sys.platform == "win32":
        has_sh_hooks = any(
            str(o.get("from", "")).endswith(".sh") or str(o.get("to", "")).endswith(".sh")
            for o in ide.get("outputs", [])
        )
        has_merge_hooks = any(
            o.get("format") == "merge_hooks_json" for o in ide.get("outputs", [])
        )
        if has_sh_hooks or has_merge_hooks:
            print(
                "\n⚠️  Windows hook notice:\n"
                "   The installed hooks include .sh scripts that require bash.\n"
                "   On Windows, hooks will only fire if Git Bash or WSL is available\n"
                "   and your IDE is configured to use it as the shell.\n"
                "   Without bash, session-boot / smart-formatting / code-quality hooks\n"
                "   will silently do nothing.\n"
                "   → Git Bash: https://git-scm.com/download/win\n"
            )


def install(ide_key: str, target: Path) -> None:
    reg = load_registry()
    if ide_key not in reg["ides"]:
        print(f"❌ IDE '{ide_key}' not in registry. Available:", ", ".join(reg["ides"].keys()))
        sys.exit(2)
    ide = reg["ides"][ide_key]
    print(f"\n📦 Installing for: {ide['label']}")
    print(f"   Source: {PKG_DIR}")
    print(f"   Target: {target}\n")

    written: list[str] = []
    for output in ide["outputs"]:
        from_pat = output["from"]
        to_pat = output["to"]
        fmt = output.get("format", "passthrough")
        header_note = output.get("header_note", False)
        for src in expand_glob(from_pat, PKG_DIR):
            if not src.exists():
                continue
            dst = target / resolve_dst(to_pat, src)
            try:
                write_with_format(src, dst, fmt, header_note=header_note)
                written.append(str(dst.relative_to(target)))
            except Exception as e:
                print(f"  ⚠️  Failed: {src} → {dst}: {e}")

    print(f"✅ Wrote {len(written)} file(s):")
    for f in written:
        print(f"   • {f}")

    _warn_hooks_on_windows(ide)

    print(f"\n🎉 Done. Restart {ide['label']} to pick up the changes.\n")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--ide", help="IDE key (e.g. cursor, claude-code, kiro)")
    ap.add_argument("--auto", action="store_true", help="Auto-detect IDE from target dir")
    ap.add_argument("--list", action="store_true", help="List known IDEs")
    ap.add_argument("--add-ide", metavar="NAME", help="Scaffold a new IDE template")
    ap.add_argument("--target", default=".", help="Target project dir (default: cwd)")
    args = ap.parse_args()

    target = Path(args.target).resolve()

    if args.list:
        list_ides()
        return
    if args.add_ide:
        add_new_ide(args.add_ide)
        print(f"✅ Template created: bmad-orchestrator/loaders/ide-templates/{args.add_ide}.md")
        print("   Fill in the output mappings, then add to ide-registry.json")
        return

    ide_key = args.ide
    if args.auto and not ide_key:
        ide_key = detect_ide(target)
        if not ide_key:
            print("⚠️  Could not auto-detect IDE; falling back to interactive picker.")
    if not ide_key:
        ide_key = pick_ide_interactive()

    install(ide_key, target)


if __name__ == "__main__":
    main()
