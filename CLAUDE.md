# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose
This repository contains a collection of useful one-liner commands and scripts in different programming languages (Bash, Python, etc.) for various tasks like endian conversion, recursive cleanup, and branch management.

## Build/Run Commands
- Shell scripts: Run with `bash scriptname.sh` 
- Shell scripts with parameters: Use environment variables (e.g., `DRY_RUN=0 bash delete-old-branches.sh`)

## Code Style Guidelines
- **Shell Scripts**:
  - Use `/usr/bin/env bash` shebang
  - Include helpful comments explaining purpose and usage
  - Use proper error handling and exit codes
  - Make scripts configurable with environment variables
  - Include dry-run mode for destructive operations
  
- **Documentation**:
  - Document one-liners in README.md with clear examples
  - Include brief explanation of what the command/script does
  - For complex scripts, explain parameters and configuration options

- **Naming Conventions**:
  - Use descriptive filenames with hyphens (e.g., `delete-old-branches.sh`)
  - Use meaningful variable names in uppercase for environment variables