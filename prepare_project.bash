#! /bin/bash

# Remove the template README.md file, since we will create our own.
rm README.md

# Start a uv project where I can easily install dependencies. It creates a pyproject.toml file
uv init

# Add a local nbdev to the project.
uv add nbdev

# Remove uv pyproject.toml, since we will use the one from nbdev, 
# which is more complete and has the right dependencies.
rm pyproject.toml

# Create the nbdev project (Adds its own pyproject.toml which can be updated easily with uv add)
# uv run nbdev-new to use the nbdev locally installed by uv in .venv
uv run nbdev-new

