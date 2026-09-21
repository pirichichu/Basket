# Repository Guidelines

## Project Structure & Module Organization

This is a Godot 4.7 project using the GL Compatibility renderer and Jolt for 3D physics. `project.godot` is the authoritative project configuration; edit it through the Godot editor when practical. `icon.svg` is the application icon. Godot-generated editor and import data belongs in `.godot/` and is ignored by Git.

As gameplay is added, keep resources organized by feature: place scenes in `scenes/`, scripts in `scripts/`, reusable assets in `assets/`, and tests in `tests/`. For example, pair `scenes/player/player.tscn` with `scripts/player/player.gd` rather than collecting unrelated files in a single directory.

## Build, Test, and Development Commands

- `godot --editor --path .` opens this repository in the Godot editor.
- `godot --path . --editor` is equivalent when invoking Godot from a terminal.
- Use the editor's **Run Project** command (F6/F5 as appropriate) to test a configured scene or project. There is currently no main scene, so configure one before using project run.

There is no build script or automated test suite yet. When export presets are introduced, document their target-specific export command here.

## Coding Style & Naming Conventions

Use UTF-8 text and LF line endings, as required by `.editorconfig` and `.gitattributes`. Write GDScript with tabs for indentation, `snake_case` for files, variables, functions, and nodes where Godot conventions allow, and `PascalCase` for `class_name` declarations. Name scenes after their primary responsibility, e.g. `basketball_court.tscn`. Prefer small, focused scripts and typed GDScript for public values and function boundaries.

Format GDScript using Godot's built-in formatter before committing. Avoid manually editing generated `.godot/` files.

## Testing Guidelines

Add tests alongside new gameplay behavior under `tests/`, mirroring the feature path, such as `tests/player/test_player_movement.gd`. Use a Godot-compatible test framework selected by the project (for example, GUT) and name tests for observable behavior. Run relevant tests before opening a pull request; until a framework is added, manually exercise affected scenes in the editor.

## Commit & Pull Request Guidelines

The history currently contains only an initial-project commit, so no established commit convention exists. Use concise imperative subjects, such as `Add player jump controller`; keep each commit focused. Pull requests should explain the gameplay or configuration change, link related issues when available, list validation performed, and include screenshots or short video for visible scene/UI changes. Do not commit `.godot/` cache output or local export artifacts.
