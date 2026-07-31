#!/usr/bin/env lua
--- install.lua - symlink lazyscripts (todo, jp, zf, fancynames) into ~/.local/bin
-- Usage:
--   ./install.lua                 # link into ~/.local/bin (default)
--   ./install.lua ~/bin           # link into another directory
--   DEST=~/bin ./install.lua      # same, via env var
--
-- Uses sudo only if the destination isn't writable (e.g. /usr/local/bin on
-- root-owned systems); user dirs like ~/.local/bin need no sudo.

-- Directory containing this script (the repo root), resolved to an absolute
-- path so the symlinks stay valid regardless of the cwd at runtime.
-- Note: unlike the shell version, this does not follow a symlinked
-- install.lua; run it from the repo.
local thisScript = arg[0] or "install.lua"
local scriptDir  = thisScript:match("^(.*)[/\\]") or "."
local cwd        = io.popen("pwd 2>/dev/null"):read("*l") or os.getenv("PWD") or "."
if scriptDir:sub(1, 1) ~= "/" then
    scriptDir = cwd .. "/" .. scriptDir
end
scriptDir = scriptDir:gsub("/+$", ""):gsub("/%.$", "")
if scriptDir == "" or scriptDir == "." then scriptDir = cwd end

local home = os.getenv("HOME")
local dest = arg[1] or os.getenv("DEST") or (home and home .. "/.local/bin") or "/usr/local/bin"
local scripts = { "todo", "jp", "zf", "fancynames" }

-- Run a command and return true on success (works across Lua 5.1 - 5.4).
local function run(cmd)
    local ok, how, code = os.execute(cmd)
    if how == "exit" then return code == 0 end
    if how == "signal" then return false end
    return ok == true or ok == 0
end

-- Create the destination as the current user when possible; escalate to sudo
-- only if it's missing and can't be created, or exists but isn't writable.
run('mkdir -p "' .. dest .. '"')

local sudo = ""
if not run('test -w "' .. dest .. '"') then
    if run("command -v sudo >/dev/null 2>&1") then
        sudo = "sudo "
    end
end

-- Make sure the destination is usable.
if not run(sudo .. 'mkdir -p "' .. dest .. '"') then
    io.stderr:write("error: cannot create/write " .. dest .. "\n")
    os.exit(1)
end

local installed = 0
for _, s in ipairs(scripts) do
    local src = scriptDir .. "/" .. s
    local f, err = io.open(src)
    if not f then
        io.stderr:write("skip: " .. s .. " (not found in " .. scriptDir .. ")\n")
    else
        f:close()
        local cmd = string.format('ln -sfn "%s" "%s/%s"', src, dest, s)
        if run(sudo .. cmd) then
            print("linked: " .. dest .. "/" .. s .. " -> " .. src)
            installed = installed + 1
        else
            io.stderr:write("error: failed to link " .. s .. "\n")
        end
    end
end

print("done: " .. installed .. " script(s) linked into " .. dest)
