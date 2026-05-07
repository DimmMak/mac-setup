-- ~/.hammerspoon/init.lua
-- Voice dictation trigger layer.
-- Karabiner remaps Mouse5 → F19. Hammerspoon catches F19 → runs dictate.sh.
--
-- Why this split: Karabiner's shell_command runs through a daemon that lacks
-- macOS mic-TCC entitlement (silent denial). Hammerspoon is a GUI app with
-- proper TCC scope, so sox can capture mic when launched via hs.task.

local PID_FILE = "/tmp/voice-dictate.pid"
local DICTATE = "/Users/danny/voice/scripts/dictate.sh"

-- Helper: check if recording is active by looking at lockfile
local function isRecording()
    local f = io.open(PID_FILE, "r")
    if f then f:close(); return true end
    return false
end

-- F19 → toggle dictation. ALWAYS show a visible alert.
hs.hotkey.bind({}, "F19", function()
    -- Capture state BEFORE running script (script will toggle it)
    local wasRecording = isRecording()

    if wasRecording then
        hs.alert.show("⏹  Transcribing...", 1.5)
    else
        hs.alert.show("🎤 Recording... press Mouse5 to stop", 1.5)
    end

    -- Run the script. Callback fires when sox kill + whisper run completes.
    local task = hs.task.new(DICTATE, function(exitCode, stdOut, stdErr)
        if exitCode ~= 0 then
            hs.alert.show("❌ dictate.sh failed", 3)
            return
        end

        -- If we WERE recording (i.e., this run was a stop+transcribe),
        -- auto-paste the result at the current cursor.
        if wasRecording then
            -- Tiny delay to ensure pbcopy fully flushed before we paste
            hs.timer.doAfter(0.1, function()
                hs.alert.show("✅ Pasted", 1)
                hs.eventtap.keyStroke({"cmd"}, "v")
            end)
        end
    end)
    task:start()
end)

-- ====== STREAMING HOTKEYS (added 2026-04-25, fixed 2026-04-25) ======
-- Karabiner Caps emits ⌃⇧⌘ (left_control + left_shift + right_command).
-- So bind to {"cmd", "ctrl", "shift"} — that's THREE mods matching Caps.
-- Caps+S is taken (Page Down in your gauntlet); Caps+B = Broadcast (stream-safe).

-- Caps + B → Broadcast: stream-safe mode (run pre-stream sanitization)
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "B", function()
    hs.alert.show("🔴 Activating stream-safe mode...", 2)
    hs.task.new("/Users/danny/stream/scripts/pre-stream.sh", function(exitCode, stdOut, stdErr)
        if exitCode == 0 then
            hs.alert.show("🔴 STREAM-SAFE MODE ACTIVE", 2)
        else
            hs.alert.show("❌ pre-stream.sh failed", 3)
        end
    end):start()
end)

-- Caps + N → Normal mode (revert pre-stream sanitization)
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "N", function()
    hs.alert.show("🟢 Reverting to normal mode...", 2)
    hs.task.new("/Users/danny/stream/scripts/post-stream.sh", function(exitCode, stdOut, stdErr)
        if exitCode == 0 then
            hs.alert.show("🟢 NORMAL MODE", 2)
        else
            hs.alert.show("❌ post-stream.sh failed", 3)
        end
    end):start()
end)

-- Caps + M → Mark moment (clip target during stream)
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "M", function()
    hs.task.new("/Users/danny/stream/scripts/mark-moment.sh", function(exitCode, stdOut, stdErr)
        if exitCode == 0 then
            hs.alert.show("📌 Moment marked", 1)
        end
    end):start()
end)

-- Caps + R → Swap to "Reaction Cam" scene in OBS
-- 2026-04-26: GUI hotkey binding failed (OBS field captures only modifier prefix
-- ⌃⇧⌘ when R is pressed via Karabiner remap, missing the R). Worked around by
-- writing F13 binding directly into OBS scene JSON
-- (~/Library/Application Support/obs-studio/basic/scenes/Untitled.json).
-- Hammerspoon emits F13 via eventtap → OBS matches its registered hotkey.
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "R", function()
    hs.alert.show("🎥 Toggling Reaction Cam...", 1)
    hs.eventtap.keyStroke({}, "F13")  -- OBS listens for F13 globally
end)

-- Caps + L → Toggle live captions (always-on whisper-stream)
-- See ~/voice-stream/ (homebrew-live-captions project)
local LIVE_PID_FILE = "/tmp/voice-stream.pid"
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "L", function()
    local f = io.open(LIVE_PID_FILE, "r")
    if f then
        local pid = f:read("*a"):gsub("%s+", "")
        f:close()
        -- Check if process alive
        local alive = os.execute("kill -0 " .. pid .. " 2>/dev/null")
        if alive then
            hs.alert.show("🟠 Stopping live captions...", 1.5)
            hs.task.new("/Users/danny/voice-stream/scripts/stop-stream.sh", function(exitCode)
                if exitCode == 0 then
                    hs.alert.show("⚪ Live Captions OFF", 2)
                else
                    hs.alert.show("❌ stop failed", 2)
                end
            end):start()
            return
        end
    end
    -- Not running → start
    hs.alert.show("🟢 Starting live captions...", 1.5)
    hs.task.new("/Users/danny/voice-stream/scripts/start-stream.sh", function(exitCode, stdOut, stdErr)
        -- start-stream.sh blocks (waits on whisper-stream); we don't expect this callback unless it crashed
        if exitCode ~= 0 then
            hs.alert.show("❌ start failed (exit " .. tostring(exitCode) .. ")", 3)
        end
    end):start()
    -- Show "ON" alert immediately; the task callback only fires on crash
    hs.timer.doAfter(1.5, function()
        local pf = io.open(LIVE_PID_FILE, "r")
        if pf then
            pf:close()
            hs.alert.show("🔴 Live Captions ON", 2)
        end
    end)
end)

-- ========== MECH COCKPIT (v0.4) — screen-share size + monitor mode ==========
-- Caps+J/K/L/; cycle screen-share size in the cockpit overlay.
-- Caps+D/V toggle monitor between decorative (fake tactical display) and live
-- (transparent — OBS Window Capture shows through).
-- Writes to ~/stream/data/cockpit-state.json; HTML overlay polls every 1 sec.
local COCKPIT_STATE = os.getenv("HOME") .. "/stream/data/cockpit-state.json"

local function readCockpitState()
    local f = io.open(COCKPIT_STATE, "r")
    if not f then return { size = "small", mode = "decorative", view = "close" } end
    local content = f:read("*a"); f:close()
    local size = content:match('"size"%s*:%s*"([^"]+)"') or "small"
    local mode = content:match('"mode"%s*:%s*"([^"]+)"') or "decorative"
    local view = content:match('"view"%s*:%s*"([^"]+)"') or "close"
    return { size = size, mode = mode, view = view }
end

local function writeCockpitState(state)
    local f = io.open(COCKPIT_STATE, "w")
    if not f then
        hs.alert.show("❌ cockpit-state.json write failed", 2); return
    end
    f:write(string.format(
        '{\n  "_comment": "Hammerspoon-managed. Caps+J/K/L/; size, Caps+D/V mode, Caps+1/2 view.",\n  "size": "%s",\n  "mode": "%s",\n  "view": "%s"\n}\n',
        state.size, state.mode, state.view
    ))
    f:close()
end

local function setSize(s, label)
    local st = readCockpitState(); st.size = s; writeCockpitState(st)
    hs.alert.show("📺 Screen size → " .. label, 1)
end

hs.hotkey.bind({"cmd", "ctrl", "shift"}, "J", function() setSize("small",      "S")          end)
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "K", function() setSize("medium",     "M")          end)
hs.hotkey.bind({"cmd", "ctrl", "shift"}, ";", function() setSize("large",      "L (immersion break)") end)
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "'", function() setSize("fullscreen", "FULL — mech hidden") end)

hs.hotkey.bind({"cmd", "ctrl", "shift"}, "D", function()
    local st = readCockpitState(); st.mode = "decorative"; writeCockpitState(st)
    hs.alert.show("🎯 Monitor → DECORATIVE (radar + ticker)", 1)
end)
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "V", function()
    local st = readCockpitState(); st.mode = "live"; writeCockpitState(st)
    hs.alert.show("📡 Monitor → LIVE (Chrome window-capture)", 1)
end)

-- Caps+= / Caps+- = OBS scene swap between Mech Cockpit (close) and Mech Cockpit (Wide)
-- Hammerspoon emits Cmd+Ctrl+Alt+1 / Cmd+Ctrl+Alt+2 which OBS catches as scene-switch hotkeys.
-- (State file no longer used — OBS scenes are the source of truth for view.)
local function viewClose()
    local st = readCockpitState(); st.view = "close"; writeCockpitState(st)
    hs.eventtap.keyStroke({"cmd", "ctrl", "alt"}, "1")
    hs.alert.show("🔍 View → CLOSE (zoom in)", 1)
end
local function viewWide()
    local st = readCockpitState(); st.view = "wide"; writeCockpitState(st)
    hs.eventtap.keyStroke({"cmd", "ctrl", "alt"}, "2")
    hs.alert.show("🔭 View → WIDE (zoom out)", 1)
end
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "=", viewClose)
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "-", viewWide)

-- Caps+0 = OBS scene swap to DJ Booth (portrait, 1080x1920 collection)
local function viewDjBooth()
    hs.eventtap.keyStroke({"cmd", "ctrl", "alt"}, "3")
    hs.alert.show("🎧 Scene → DJ BOOTH", 1)
end
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "0", viewDjBooth)

-- Quick reload for editing this config
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
    hs.reload()
end)

-- Auto-run kickdisplay on screen wake (added 2026-05-07)
-- Recovers stuck external display handshake when displays wake from sleep.
-- May or may not be the actual trigger for the HDMI-not-detected bug — additive guard.
local displayWakeWatcher = hs.caffeinate.watcher.new(function(event)
    if event == hs.caffeinate.watcher.screensDidWake then
        hs.execute("system_profiler SPDisplaysDataType > /dev/null", true)
    end
end)
displayWakeWatcher:start()

hs.alert.show("🎤 Voice + 🔴 Stream + 🤖 Mech + 📺 Display-kick hotkeys loaded", 2)
