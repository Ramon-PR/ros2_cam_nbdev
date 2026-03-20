# 🚀 template_uv_nbdev

**Get from zero to a fully structured Python project in one command.**

This template combines [uv](https://docs.astral.sh/uv/) (blazing-fast package manager) with [nbdev](https://nbdev.fast.ai/) (notebook-driven development) so you can focus on writing code, not configuring tools.

---

## ⚡ 30-second setup

```sh
# 1. Click "Use this template" on GitHub, then clone your new repo
git clone https://github.com/<you>/<your-project>.git && cd <your-project>

# 2. Set git identity (required by nbdev)
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

# 3. Install everything and scaffold the project
bash scripts/basic_install.sh && bash scripts/prepare_project.bash
```

Done. Start writing notebooks in `nbs/`.

---

## 🤔 Why uv + nbdev?

### uv — The fast lane for Python packaging
- ⚡ **10–100× faster** than pip (written in Rust)
- 🔧 **Replaces** pip + pyenv + virtualenv + pipx
- 🔒 **Reproducible** via `uv.lock`
- 🐍 **Manages Python versions** — `uv python install 3.12`

### nbdev — Write once, get everything
- 📓 Code, tests, and docs live together in **Jupyter notebooks**
- 📦 **Auto-exports** notebooks into a clean Python package
- 📖 **Auto-generates** documentation with Quarto
- ✅ **Auto-extracts** tests from notebook cells

---

## 📁 What you get after setup

```
your-project/
├── nbs/              # Notebooks (your source of truth)
│   └── 00_core.ipynb
├── your_project/     # Auto-generated Python package
├── pyproject.toml    # Metadata (add deps with `uv add`)
├── uv.lock           # Locked dependencies
├── .venv/            # Virtual environment
└── scripts/
    ├── basic_install.sh       # System + uv + python3 installer
    └── prepare_project.bash   # uv + nbdev project scaffolding
```

---

## 🛠️ Daily workflow

| Task | Command |
|------|---------|
| Add a package | `uv add <package>` |
| Run a script | `uv run <script.py>` |
| Export notebooks → modules | `uv run nbdev-export` |
| Run notebook tests | `uv run nbdev-test` |
| Build documentation | `uv run nbdev-docs` |
| Preview docs locally | `uv run nbdev-preview` |

---

## 📋 What `basic_install.sh` does

Detects your OS and package manager (apt/dnf/yum/pacman/zypper/apk/brew), then installs:

| Dependency | Method |
|---|---|
| curl, git, sudo | System package manager |
| uv | [Official Astral installer](https://astral.sh/uv) |
| python3 | System package manager |

Tested on a clean Ubuntu container.
