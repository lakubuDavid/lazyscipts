# lazyscripts

A collection of standalone Lua utility scripts — single-file tools meant to be
kept executable in your `$PATH`. Some are fully self-sufficient, others plug
into existing tools like `just`, `fzf`, or `zellij`.

**Requires:** `lua` (5.1+ / LuaJIT)

## Scripts

### `todo` — Markdown-backed todo CLI

A tiny task tracker that stores each task as a markdown file with YAML
frontmatter and keeps an auto-generated `todos/index.lua` index. Designed to be
hackable and LLM-friendly.

```
todo add "Ship feature" "Description of the task" "Extra details"
todo list [--done|--pending]
todo status 001
todo update 001 done
```

| Command | Description |
|---------|-------------|
| `todo add TITLE "DESC" ["DETAILS"]` | Create a new pending task |
| `todo list [--done\|--pending]` | List tasks, optionally filtered |
| `todo status TASK_ID` | Show full task markdown |
| `todo update TASK_ID pending\|done` | Change task status |

Storage lives in a `./todos/` directory relative to where you run the command.

---

### `jp` — Just recipe picker

Fuzzy-pick a recipe from `just --list` using `fzf`, then run it. Optionally
spawns the command in a floating Zellij pane.

```
jp              # pick recipe, run in current terminal
jp -f           # pick recipe, run in floating Zellij pane
jp -f -q        # same, but close pane immediately when done
```

| Option | Description |
|--------|-------------|
| `-f`, `--floating` | Run the picked recipe in a floating Zellij pane |
| `-q`, `--quick` | Close the floating pane immediately (no "press any key" prompt) |

**Depends on:** `just`, `fzf`, optionally `zellij` (for `-f`).

---

### `zf` — Zellij floating pane runner

Run any command in a floating Zellij pane. Shows output and waits for a keypress
before closing (unless `-q` is used).

```
zf -- ls -la
zf -q -- curl https://api.example.com/health
zf -- bat README.md
```

| Option | Description |
|--------|-------------|
| `-q`, `--quick` | Close pane immediately after command exits |

**Depends on:** `zellij`.

---

## Installation

Symlink or copy any script into a directory on your `$PATH`:

```sh
# Example: symlink all three into ~/.local/bin
ln -sf ~/Code/Lua/lazyscripts/todo ~/.local/bin/todo
ln -sf ~/Code/Lua/lazyscripts/jp   ~/.local/bin/jp
ln -sf ~/Code/Lua/lazyscripts/zf   ~/.local/bin/zf
```

Or add the whole directory to your `PATH`:

```sh
export PATH="$HOME/Code/Lua/lazyscripts:$PATH"
```
