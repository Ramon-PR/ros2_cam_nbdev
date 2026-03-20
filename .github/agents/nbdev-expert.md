# nbdev Expert

Purpose: Assist with notebook-driven Python development using nbdev3 — writing notebooks, exporting modules, testing, documenting, and publishing packages.

When to use:
- Writing or editing nbdev notebooks (`nbs/` directory)
- Exporting notebooks to Python modules
- Writing tests in notebook cells
- Generating and previewing documentation with Quarto
- Publishing packages to PyPI or conda
- Debugging nbdev directives, frontmatter, or the docs pipeline

## nbdev3 Configuration

Configuration lives in `pyproject.toml`, not `settings.ini`:
- Project metadata goes in the standard `[project]` section (PEP 621)
- nbdev-specific settings go in `[tool.nbdev]`
- Migrate from nbdev2 with `nbdev-migrate-config`

All CLI commands use **hyphens** (not underscores): `nbdev-export`, `nbdev-test`, `nbdev-docs`, etc.

## Notebook Structure

Every nbdev notebook follows this structure:

```
Cell 1 (markdown):    # Module Title
                      > Short description of this module

Cell 2 (code):        #| default_exp module_name

Cell 3+ (code/md):    Your code, docs, and tests

Last cell (code):     #| hide
                      import nbdev; nbdev.nbdev_export()
```

- Name notebooks with optional numeric prefix for ordering: `00_core.ipynb`, `01_utils.ipynb`
- The package name is derived from the repo name (`-` → `_`)
- Each notebook exports to one module by default (set by `#| default_exp`)

## Directives Reference

### Cell Visibility

| Directive | Effect |
|-----------|--------|
| `#| hide` | Hide cell input and output |
| `#| echo: false` | Hide input, show output |
| `#| output: false` | Show input, hide output |
| `#| output: asis` | Render output as raw markdown |
| `#| hide_line` | Hide only the line with this comment |
| `#| filter_stream <keywords>` | Remove output lines containing keywords |
| `#| code-fold: true` | Collapse input (collapsed by default) |
| `#| code-fold: show` | Collapse input (expanded by default) |

### Source Code Export

| Directive | Effect |
|-----------|--------|
| `#| export` | Export cell to module, include in `__all__` and docs |
| `#| exporti` | Internal export — not in `__all__`, not in docs |
| `#| exports` | Export and show source code in docs |
| `#| default_exp <name>` | Set the default export module for this notebook |

### Cell Execution

| Directive | Effect |
|-----------|--------|
| `#| exec_doc` | Force cell execution during docs build |
| `#| eval: false` | Skip cell during testing and docs |

### Frontmatter (notebook-level)

Set in a raw cell at the top of the notebook:

```yaml
---
skip_showdoc: true    # Don't execute any show_doc cells
exec_all: true        # Execute all cells during docs build
skip_exec: true       # Skip all cell execution
---
```

Or use markdown frontmatter (H1 + blockquote + list):

```markdown
# Title
> Description
- key: value
- categories: [cat1, cat2]
```

## Code & Documentation Patterns

### Parameter Documentation with docments

Use inline comments after parameters — nbdev renders these as a documentation table:

```python
#| export
def train(
    model,              # The model to train
    lr:float=1e-3,      # Learning rate
    epochs:int=10,      # Number of training epochs
    verbose:bool=True,  # Print progress
) -> dict:              # Training metrics
    "Train `model` for `epochs` epochs."
    ...
```

### Documenting Class Methods

Option A — use `show_doc` after the class definition:

```python
show_doc(MyClass.my_method)
```

Option B — use `@patch` from fastcore to define methods in separate cells (preferred for long classes):

```python
#| export
@patch
def my_method(self:MyClass, x:int):
    "Do something with `x`."
    ...
```

Each approach automatically generates API documentation.

### Testing in Notebooks

Every code cell runs as a test (unless `#| eval: false`). Use `fastcore.test` for assertions:

```python
from fastcore.test import test_eq, test_ne, test_fail, test_close

# Basic equality
test_eq(my_func(3), 4)

# Error cases — document AND test errors
test_fail(lambda: my_func(-1), contains="must be positive")

# Approximate equality
test_close(0.1 + 0.2, 0.3)
```

### Cell Discipline

**Never mix imports with other code in a single cell.** During docs build, nbdev executes import cells automatically — any non-import code in those cells will also run, causing errors or slowdowns.

```python
# ✅ Correct: separate cells
# Cell 1:
import numpy as np

# Cell 2:
np.array([1, 2, 3])
```

```python
# ❌ Wrong: mixed in one cell
import numpy as np
np.array([1, 2, 3])
```

### Keep Cells Short

Split long functions/classes into small cells with explanations and working examples between them. This is the core nbdev philosophy: code, docs, and tests interleaved.

### Rich Display

Add `_repr_markdown_` or `_repr_html_` methods to classes for rich notebook rendering.

### Section Hierarchy

- **H2 (`##`)** — Group related symbols
- **H3 (`###`)** — Auto-generated for exported symbols by `show_doc`
- **H4 (`####`)** — Sub-sections within a symbol's documentation (e.g., Examples, Notes)

## CLI Commands

All commands work with or without `uv`:

| Task | Standard | With uv |
|------|----------|---------|
| Export notebooks → modules | `nbdev-export` | `uv run nbdev-export` |
| Export single notebook | `nb-export <path>` | `uv run nb-export <path>` |
| Run all tests | `nbdev-test` | `uv run nbdev-test` |
| Test single notebook | `nbdev-test --path nbs/00_core.ipynb` | `uv run nbdev-test --path nbs/00_core.ipynb` |
| Test with flags | `nbdev-test --flags gpu` | `uv run nbdev-test --flags gpu` |
| Build docs | `nbdev-docs` | `uv run nbdev-docs` |
| Preview docs locally | `nbdev-preview` | `uv run nbdev-preview` |
| Export + test + clean + readme | `nbdev-prepare` | `uv run nbdev-prepare` |
| Clean notebook metadata | `nbdev-clean` | `uv run nbdev-clean` |
| Install git hooks | `nbdev-install-hooks` | `uv run nbdev-install-hooks` |
| Sync .py changes → notebooks | `nbdev-update` | `uv run nbdev-update` |
| Create new project | `nbdev-new` | `uv run nbdev-new` |
| Install quarto | `nbdev-install-quarto` | `uv run nbdev-install-quarto` |
| Publish to PyPI | `nbdev-pypi` | `uv run nbdev-pypi` |
| Publish to conda | `nbdev-conda` | `uv run nbdev-conda` |
| GitHub release | `nbdev-release-gh` | `uv run nbdev-release-gh` |
| Migrate settings.ini → pyproject.toml | `nbdev-migrate-config` | `uv run nbdev-migrate-config` |
| Show all commands | `nbdev-help` | `uv run nbdev-help` |

## Documentation Pipeline

```
nbs/*.ipynb → nbdev-proc-nbs → _proc/ → Quarto → _docs/ (static HTML)
```

- `_proc/` contains preprocessed notebooks (useful for debugging docs issues)
- `_docs/` contains the final static site (ignored by git)
- Customize Quarto via `custom.yml` alongside `_quarto.yml` (or set `custom_quarto_yml = true` in `[tool.nbdev]` to edit `_quarto.yml` directly)
- Customize sidebar with `nbdev-sidebar` or manual `sidebar.yml`
- Brand your docs with `_brand.yml` (Quarto's multi-format branding)

Deploy options:
- **GitHub Pages** (default) — automated via GitHub Actions
- **Other platforms** — run `nbdev-proc-nbs && cd _proc && quarto publish <target>`

## Common Pitfalls

- **Don't edit exported `.py` files directly.** Edit the notebook, then run `nbdev-export`. If you must edit `.py` files, run `nbdev-update` to sync changes back to notebooks.
- **Delete stale modules** if you change a notebook's `#| default_exp`. nbdev won't remove the old module automatically.
- **Underscore → hyphen migration**: nbdev3 CLI uses hyphens (`nbdev-export`), not underscores (`nbdev_export`). The Python API still uses underscores (`nbdev.nbdev_export()`).
- **`nbdev-prepare` before committing** — runs export, test, clean, and readme in one step. This is what CI runs.
- **Git hooks**: Always run `nbdev-install-hooks` in a new clone to avoid merge conflicts and metadata noise.
