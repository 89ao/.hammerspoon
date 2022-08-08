hs.hotkey.alertDuration = 0
hs.hints.showTitleThresh = 0
hs.window.animationDuration = 0
hs.application.enableSpotlightForNameSearches(true)


local alert = require "hs.alert"
alert.defaultStyle.strokeColor = {white = 1, alpha = 0}
alert.defaultStyle.fillColor = {white = 0.05, alpha = 0.75}
alert.defaultStyle.radius = 5
alert.defaultStyle.fadeOutDuration = 0.5
--alert.defaultStyle.textFont = "Fira Mono"
alert.defaultStyle.textSize = 18
--alert.defaultStyle.atScreenEdge = 1

-- Use the standardized config location, if present
custom_config = hs.fs.pathToAbsolute(os.getenv("HOME") .. '/.config/hammerspoon/private/config.lua')
if custom_config then
    print("Loading custom config")
    dofile( os.getenv("HOME") .. "/.config/hammerspoon/private/config.lua")
    privatepath = hs.fs.pathToAbsolute(hs.configdir .. '/private/config.lua')
    if privatepath then
        hs.alert("You have config in both .config/hammerspoon and .hammerspoon/private.\nThe .config/hammerspoon one will be used.")
    end
else
    -- otherwise fallback to 'classic' location.
    if not privatepath then
        privatepath = hs.fs.pathToAbsolute(hs.configdir .. '/private')
        -- Create `~/.hammerspoon/private` directory if not exists.
        hs.fs.mkdir(hs.configdir .. '/private')
    end
    privateconf = hs.fs.pathToAbsolute(hs.configdir .. '/private/config.lua')
    if privateconf then
        -- Load awesomeconfig file if exists
        require('private/config')
    end
end

hsreload_keys = hsreload_keys or {{"cmd", "shift", "ctrl"}, "R"}
if string.len(hsreload_keys[2]) > 0 then
    hs.hotkey.bind(hsreload_keys[1], hsreload_keys[2], "Reload Configuration", function() hs.reload() end)
end

-- ModalMgr Spoon must be loaded explicitly, because this repository heavily relies upon it.
hs.loadSpoon("ModalMgr")

-- Define default Spoons which will be loaded later
if not hspoon_list then
    hspoon_list = {
        "AClock",
--        "BingDaily",
        "CircleClock",
--        "ClipShow",
        "CountDown",
        "HCalendar",
--        "Calendar",
--        "HSaria2",
        "HSearch",
--        "SpeedMenu",
        "WinWin",
--        "FnMate",
    }
end

-- Load those Spoons
for _, v in pairs(hspoon_list) do
    hs.loadSpoon(v)
end

----------------------------------------------------------------------------------------------------
-- Then we create/register all kinds of modal keybindings environments.
----------------------------------------------------------------------------------------------------
-- Register windowHints (Register a keybinding which is NOT modal environment with modal supervisor)
hswhints_keys = hswhints_keys or {"alt", "tab"}
if string.len(hswhints_keys[2]) > 0 then
    spoon.ModalMgr.supervisor:bind(hswhints_keys[1], hswhints_keys[2], 'Show Window Hints', function()
        spoon.ModalMgr:deactivateAll()
        hs.hints.windowHints()
    end)
end

----------------------------------------------------------------------------------------------------
-- appM modal environment
spoon.ModalMgr:new("appM")
local cmodal = spoon.ModalMgr.modal_list["appM"]
cmodal:bind('', 'escape', 'Deactivate appM', function() spoon.ModalMgr:deactivate({"appM"}) end)
cmodal:bind('', 'Q', 'Deactivate appM', function() spoon.ModalMgr:deactivate({"appM"}) end)
cmodal:bind('', 'tab', 'Toggle Cheatsheet', function() spoon.ModalMgr:toggleCheatsheet() end)
if not hsapp_list then
    hsapp_list = {
        {key = 'f', name = 'Finder'},
        {key = 's', name = 'Safari'},
        {key = 't', name = 'WeTERM'},
        {key = 'v', id = 'com.apple.ActivityMonitor'},
        {key = 'y', id = 'com.apple.systempreferences'},
	{key = 'c', id = 'com.google.Chrome'},
	{key = 'l', name = 'Sublime Text'},
	{key = 'w', name = 'Mweb Pro'},
    }
end
for _, v in ipairs(hsapp_list) do
    if v.id then
        local located_name = hs.application.nameForBundleID(v.id)
        if located_name then
            cmodal:bind('', v.key, located_name, function()
                hs.application.launchOrFocusByBundleID(v.id)
                spoon.ModalMgr:deactivate({"appM"})
            end)
        end
    elseif v.name then
        cmodal:bind('', v.key, v.name, function()
            hs.application.launchOrFocus(v.name)
            spoon.ModalMgr:deactivate({"appM"})
        end)
    end
end

-- Then we register some keybindings with modal supervisor
hsappM_keys = hsappM_keys or {"alt", "A"}
if string.len(hsappM_keys[2]) > 0 then
    spoon.ModalMgr.supervisor:bind(hsappM_keys[1], hsappM_keys[2], "Enter AppM Environment", function()
        spoon.ModalMgr:deactivateAll()
        -- Show the keybindings cheatsheet once appM is activated
        spoon.ModalMgr:activate({"appM"}, "#FFBD2E", true)
    end)
end

----------------------------------------------------------------------------------------------------
-- clipshowM modal environment
if spoon.ClipShow then
    spoon.ModalMgr:new("clipshowM")
    local cmodal = spoon.ModalMgr.modal_list["clipshowM"]
    cmodal:bind('', 'escape', 'Deactivate clipshowM', function()
        spoon.ClipShow:toggleShow()
        spoon.ModalMgr:deactivate({"clipshowM"})
    end)
    cmodal:bind('', 'Q', 'Deactivate clipshowM', function()
        spoon.ClipShow:toggleShow()
        spoon.ModalMgr:deactivate({"clipshowM"})
    end)
    cmodal:bind('', 'N', 'Save this Session', function()
        spoon.ClipShow:saveToSession()
    end)
    cmodal:bind('', 'R', 'Restore last Session', function()
        spoon.ClipShow:restoreLastSession()
    end)
    cmodal:bind('', 'B', 'Open in Browser', function()
        spoon.ClipShow:openInBrowserWithRef()
        spoon.ClipShow:toggleShow()
        spoon.ModalMgr:deactivate({"clipshowM"})
    end)
    cmodal:bind('', 'S', 'Search with Bing', function()
        spoon.ClipShow:openInBrowserWithRef("https://www.bing.com/search?q=")
        spoon.ClipShow:toggleShow()
        spoon.ModalMgr:deactivate({"clipshowM"})
    end)
    cmodal:bind('', 'M', 'Open in MacVim', function()
        spoon.ClipShow:openWithCommand("/usr/local/bin/mvim")
        spoon.ClipShow:toggleShow()
        spoon.ModalMgr:deactivate({"clipshowM"})
    end)
    cmodal:bind('', 'F', 'Save to Desktop', function()
        spoon.ClipShow:saveToFile()
        spoon.ClipShow:toggleShow()
        spoon.ModalMgr:deactivate({"clipshowM"})
    end)
    cmodal:bind('', 'H', 'Search in Github', function()
        spoon.ClipShow:openInBrowserWithRef("https://github.com/search?q=")
        spoon.ClipShow:toggleShow()
        spoon.ModalMgr:deactivate({"clipshowM"})
    end)
    cmodal:bind('', 'G', 'Search with Google', function()
        spoon.ClipShow:openInBrowserWithRef("https://www.google.com/search?q=")
        spoon.ClipShow:toggleShow()
        spoon.ModalMgr:deactivate({"clipshowM"})
    end)
    cmodal:bind('', 'L', 'Open in Sublime Text', function()
        spoon.ClipShow:openWithCommand("/usr/local/bin/subl")
        spoon.ClipShow:toggleShow()
        spoon.ModalMgr:deactivate({"clipshowM"})
    end)

    -- Register clipshowM with modal supervisor
    hsclipsM_keys = hsclipsM_keys or {"alt", "C"}
    if string.len(hsclipsM_keys[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(hsclipsM_keys[1], hsclipsM_keys[2], "Enter clipshowM Environment", function()
            -- We need to take action upon hsclipsM_keys is pressed, since pressing another key to showing ClipShow panel is redundant.
            spoon.ClipShow:toggleShow()
            -- Need a little trick here. Since the content type of system clipboard may be "URL", in which case we don't need to activate clipshowM.
            if spoon.ClipShow.canvas:isShowing() then
                spoon.ModalMgr:deactivateAll()
                spoon.ModalMgr:activate({"clipshowM"})
            end
        end)
    end
end

----------------------------------------------------------------------------------------------------
-- Register HSaria2
-- if spoon.HSaria2 then
--     -- First we need to connect to aria2 rpc host
--     hsaria2_host = hsaria2_host or "http://localhost:6800/jsonrpc"
--     hsaria2_secret = hsaria2_secret or "token"
--     spoon.HSaria2:connectToHost(hsaria2_host, hsaria2_secret)
-- 
--     hsaria2_keys = hsaria2_keys or {"alt", "D"}
--     if string.len(hsaria2_keys[2]) > 0 then
--         spoon.ModalMgr.supervisor:bind(hsaria2_keys[1], hsaria2_keys[2], 'Toggle aria2 Panel', function() spoon.HSaria2:togglePanel() end)
--     end
-- end

----------------------------------------------------------------------------------------------------
-- Register Hammerspoon Search
if spoon.HSearch then
    hsearch_keys = hsearch_keys or {"alt", "G"}
    if string.len(hsearch_keys[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(hsearch_keys[1], hsearch_keys[2], 'Launch Hammerspoon Search', function() spoon.HSearch:toggleShow() end)
    end
end

----------------------------------------------------------------------------------------------------
-- Register Hammerspoon API manual: Open Hammerspoon manual in default browser
hsman_keys = hsman_keys or {"alt", "H"}
if string.len(hsman_keys[2]) > 0 then
    spoon.ModalMgr.supervisor:bind(hsman_keys[1], hsman_keys[2], "Read Hammerspoon Manual", function()
        hs.doc.hsdocs.forceExternalBrowser(true)
        hs.doc.hsdocs.moduleEntitiesInSidebar(true)
        hs.doc.hsdocs.help()
    end)
end

----------------------------------------------------------------------------------------------------
-- countdownM modal environment
if spoon.CountDown then
    spoon.ModalMgr:new("countdownM")
    local cmodal = spoon.ModalMgr.modal_list["countdownM"]
    cmodal:bind('', 'escape', 'Deactivate countdownM', function() spoon.ModalMgr:deactivate({"countdownM"}) end)
    cmodal:bind('', 'Q', 'Deactivate countdownM', function() spoon.ModalMgr:deactivate({"countdownM"}) end)
    cmodal:bind('', 'tab', 'Toggle Cheatsheet', function() spoon.ModalMgr:toggleCheatsheet() end)
    cmodal:bind('', '0', '5 Minutes Countdown', function()
        spoon.CountDown:startFor(5)
        spoon.ModalMgr:deactivate({"countdownM"})
    end)
    for i = 1, 9 do
        cmodal:bind('', tostring(i), string.format("%s Minutes Countdown", 10 * i), function()
            spoon.CountDown:startFor(10 * i)
            spoon.ModalMgr:deactivate({"countdownM"})
        end)
    end
    cmodal:bind('', 'return', '25 Minutes Countdown', function()
        spoon.CountDown:startFor(25)
        spoon.ModalMgr:deactivate({"countdownM"})
    end)
    cmodal:bind('', 'space', 'Pause/Resume CountDown', function()
        spoon.CountDown:pauseOrResume()
        spoon.ModalMgr:deactivate({"countdownM"})
    end)

    -- Register countdownM with modal supervisor
    hscountdM_keys = hscountdM_keys or {"alt", "I"}
    if string.len(hscountdM_keys[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(hscountdM_keys[1], hscountdM_keys[2], "Enter countdownM Environment", function()
            spoon.ModalMgr:deactivateAll()
            -- Show the keybindings cheatsheet once countdownM is activated
            spoon.ModalMgr:activate({"countdownM"}, "#FF6347", true)
        end)
    end
end

----------------------------------------------------------------------------------------------------
-- Register lock screen
hslock_keys = hslock_keys or {"alt", "L"}
if string.len(hslock_keys[2]) > 0 then
    spoon.ModalMgr.supervisor:bind(hslock_keys[1], hslock_keys[2], "Lock Screen", function()
        hs.caffeinate.lockScreen()
    end)
end

----------------------------------------------------------------------------------------------------
-- resizeM modal environment
if spoon.WinWin then
    spoon.ModalMgr:new("resizeM")
    local cmodal = spoon.ModalMgr.modal_list["resizeM"]
    cmodal:bind('', 'escape', 'Deactivate resizeM', function() spoon.ModalMgr:deactivate({"resizeM"}) end)
    cmodal:bind('', 'Q', 'Deactivate resizeM', function() spoon.ModalMgr:deactivate({"resizeM"}) end)
    cmodal:bind('', 'tab', 'Toggle Cheatsheet', function() spoon.ModalMgr:toggleCheatsheet() end)
    cmodal:bind('', 'A', 'Move Leftward', function() spoon.WinWin:stepMove("left") end, nil, function() spoon.WinWin:stepMove("left") end)
    cmodal:bind('', 'D', 'Move Rightward', function() spoon.WinWin:stepMove("right") end, nil, function() spoon.WinWin:stepMove("right") end)
    cmodal:bind('', 'W', 'Move Upward', function() spoon.WinWin:stepMove("up") end, nil, function() spoon.WinWin:stepMove("up") end)
    cmodal:bind('', 'S', 'Move Downward', function() spoon.WinWin:stepMove("down") end, nil, function() spoon.WinWin:stepMove("down") end)
    cmodal:bind('', 'H', 'Lefthalf of Screen', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("halfleft") end)
    cmodal:bind('', 'L', 'Righthalf of Screen', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("halfright") end)
    cmodal:bind('', 'K', 'Uphalf of Screen', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("halfup") end)
    cmodal:bind('', 'J', 'Downhalf of Screen', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("halfdown") end)
    cmodal:bind('', 'Y', 'NorthWest Corner', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("cornerNW") end)
    cmodal:bind('', 'O', 'NorthEast Corner', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("cornerNE") end)
    cmodal:bind('', 'U', 'SouthWest Corner', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("cornerSW") end)
    cmodal:bind('', 'I', 'SouthEast Corner', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("cornerSE") end)
    cmodal:bind('', 'F', 'Fullscreen', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("fullscreen") end)
    cmodal:bind('', 'C', 'Center Window', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("center") end)
    cmodal:bind('', '=', 'Stretch Outward', function() spoon.WinWin:moveAndResize("expand") end, nil, function() spoon.WinWin:moveAndResize("expand") end)
    cmodal:bind('', '-', 'Shrink Inward', function() spoon.WinWin:moveAndResize("shrink") end, nil, function() spoon.WinWin:moveAndResize("shrink") end)
    cmodal:bind('shift', 'H', 'Move Leftward', function() spoon.WinWin:stepResize("left") end, nil, function() spoon.WinWin:stepResize("left") end)
    cmodal:bind('shift', 'L', 'Move Rightward', function() spoon.WinWin:stepResize("right") end, nil, function() spoon.WinWin:stepResize("right") end)
    cmodal:bind('shift', 'K', 'Move Upward', function() spoon.WinWin:stepResize("up") end, nil, function() spoon.WinWin:stepResize("up") end)
    cmodal:bind('shift', 'J', 'Move Downward', function() spoon.WinWin:stepResize("down") end, nil, function() spoon.WinWin:stepResize("down") end)
    cmodal:bind('', 'left', 'Move to Left Monitor', function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("left") end)
    cmodal:bind('', 'right', 'Move to Right Monitor', function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("right") end)
    cmodal:bind('', 'up', 'Move to Above Monitor', function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("up") end)
    cmodal:bind('', 'down', 'Move to Below Monitor', function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("down") end)
    cmodal:bind('', 'space', 'Move to Next Monitor', function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("next") end)
    cmodal:bind('', '[', 'Undo Window Manipulation', function() spoon.WinWin:undo() end)
    cmodal:bind('', ']', 'Redo Window Manipulation', function() spoon.WinWin:redo() end)
    cmodal:bind('', '`', 'Center Cursor', function() spoon.WinWin:centerCursor() end)

    -- Register resizeM with modal supervisor
    hsresizeM_keys = hsresizeM_keys or {"alt", "R"}
    if string.len(hsresizeM_keys[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(hsresizeM_keys[1], hsresizeM_keys[2], "Enter resizeM Environment", function()
            -- Deactivate some modal environments or not before activating a new one
            spoon.ModalMgr:deactivateAll()
            -- Show an status indicator so we know we're in some modal environment now
            spoon.ModalMgr:activate({"resizeM"}, "#B22222")
        end)
    end
end

----------------------------------------------------------------------------------------------------
-- cheatsheetM modal environment (Because KSheet Spoon is NOT loaded, cheatsheetM will NOT be activated)
if spoon.KSheet then
    spoon.ModalMgr:new("cheatsheetM")
    local cmodal = spoon.ModalMgr.modal_list["cheatsheetM"]
    cmodal:bind('', 'escape', 'Deactivate cheatsheetM', function()
        spoon.KSheet:hide()
        spoon.ModalMgr:deactivate({"cheatsheetM"})
    end)
    cmodal:bind('', 'Q', 'Deactivate cheatsheetM', function()
        spoon.KSheet:hide()
        spoon.ModalMgr:deactivate({"cheatsheetM"})
    end)

    -- Register cheatsheetM with modal supervisor
    hscheats_keys = hscheats_keys or {"alt", "S"}
    if string.len(hscheats_keys[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(hscheats_keys[1], hscheats_keys[2], "Enter cheatsheetM Environment", function()
            spoon.KSheet:show()
            spoon.ModalMgr:deactivateAll()
            spoon.ModalMgr:activate({"cheatsheetM"})
        end)
    end
end

----------------------------------------------------------------------------------------------------
-- Register AClock
if spoon.AClock then
    hsaclock_keys = hsaclock_keys or {"alt", "T"}
    if string.len(hsaclock_keys[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(hsaclock_keys[1], hsaclock_keys[2], "Toggle Floating Clock", function() spoon.AClock:toggleShow() end)
    end
end

----------------------------------------------------------------------------------------------------
-- Register browser tab typist: Type URL of current tab of running browser in markdown format. i.e. [title](link)
--hstype_keys = hstype_keys or {"alt", "V"}
--if string.len(hstype_keys[2]) > 0 then
--    spoon.ModalMgr.supervisor:bind(hstype_keys[1], hstype_keys[2], "Type Browser Link", function()
--        local safari_running = hs.application.applicationsForBundleID("com.apple.Safari")
--        local chrome_running = hs.application.applicationsForBundleID("com.google.Chrome")
--        if #safari_running > 0 then
--            local stat, data = hs.applescript('tell application "Safari" to get {URL, name} of current tab of window 1')
--            if stat then hs.eventtap.keyStrokes("[" .. data[2] .. "](" .. data[1] .. ")") end
--        elseif #chrome_running > 0 then
--            local stat, data = hs.applescript('tell application "Google Chrome" to get {URL, title} of active tab of window 1')
--            if stat then hs.eventtap.keyStrokes("[" .. data[2] .. "](" .. data[1] .. ")") end
--        end
--    end)
--end
--
----------------------------------------------------------------------------------------------------
-- Register Hammerspoon console
--hsconsole_keys = hsconsole_keys or {"alt", "Z"}
--if string.len(hsconsole_keys[2]) > 0 then
--    spoon.ModalMgr.supervisor:bind(hsconsole_keys[1], hsconsole_keys[2], "Toggle Hammerspoon Console", function() hs.toggleConsole() end)
--end

----------------------------------------------------------------------------------------------------
-- Finally we initialize ModalMgr supervisor
spoon.ModalMgr.supervisor:enter()

local function Chinese()
    hs.keycodes.currentSourceID("com.apple.keylayout.ABC")
--    hs.keycodes.currentSourceID("com.baidu.inputmethod.BaiduIM.pinyin")
    hs.keycodes.currentSourceID("com.sogou.inputmethod.sogou.pinyin")
    hs.alert.closeAll(0)
    hs.alert.show("中文拼音", 1)
end

local function English()
    hs.keycodes.currentSourceID("com.apple.keylayout.ABC")
--    hs.keycodes.currentSourceID("com.baidu.inputmethod.BaiduIM")
    hs.alert.closeAll(0)
    hs.alert.show(" ABC", 1)
end

-- 备选输入法
-- com.baidu.inputmethod.BaiduIM (Baidu输入法)
-- com.sogou.inputmethod.sogou (搜狗拼音)
-- com.baidu.inputmethod.BaiduIM.pinyin (百度拼音)
-- com.baidu.inputmethod.BaiduIM.wubi (百度五笔)
-- com.sogou.inputmethod.sogou.pinyin (搜狗拼音)

-- app to expected ime config
local app2Ime = {
    {'/Applications/iTerm.app', 'English'},
    {'/Applications/WeTERM.app', 'English'},
    {'/Applications/MacVim.app', 'English'},
    {'/Applications/PyCharm.app', 'English'},
    {'/Applications/Xcode.app', 'English'},
    {'/Applications/Google Chrome.app', 'Chinese'},
    {'/Applications/Safari.app', 'Chinese'},
    {'/System/Library/CoreServices/Finder.app', 'English'},
    {'/Applications/DingTalk.app', 'Chinese'},
    {'/Applications/NeteaseMusic.app', 'Chinese'},
    {'/Applications/企业微信.app', 'Chinese'},
    {'/Applications/WeChat.app', 'Chinese'},
    {'/Applications/System Preferences.app', 'English'},
    {'/Applications/Dash.app', 'English'},
    {'/Applications/XMind.app', 'Chinese'},
    {'/Applications/Preview.app', 'Chinese'},
    {'/Applications/wechatwebdevtools.app', 'English'},
    {'/Applications/Sketch.app', 'English'},
    {'/Applications/AppCleaner.app', 'English'},
    {'/Applications/Bitwarden.app', 'English'},
    {'/Applications/MWeb Pro.app', 'Chinese'},
    {'/Applications/Microsoft Word.app', 'Chinese'},
    {'/Applications/Microsoft Excel.app', 'Chinese'},
    {'/Applications/Microsoft PowerPoint.app', 'Chinese'},
}

function updateFocusAppInputMethod()
    local focusAppPath = hs.window.frontmostWindow():application():path()
    for index, app in pairs(app2Ime) do
        local appPath = app[1]
        local expectedIme = app[2]

        if focusAppPath == appPath then
            if expectedIme == 'English' then
                English()
            else
                Chinese()
            end
            break
        end
    end
end

-- helper hotkey to figure out the app path and name of current focused window
hs.hotkey.bind({'ctrl', 'cmd'}, ".", function()
    hs.alert.show("App path:        "
    ..hs.window.focusedWindow():application():path()
    .."\n"
    .."App name:      "
    ..hs.window.focusedWindow():application():name()
    .."\n"
    .."IM source id:  "
    ..hs.keycodes.currentSourceID())
end)

-- Handle cursor focus and application's screen manage.
function applicationWatcher(appName, eventType, appObject)
    if (eventType == hs.application.watcher.activated) then
        updateFocusAppInputMethod()
    end
end

appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

------------------------------------------
local KEY_APP_PAIRS = {
--    A = "IntelliJ IDEA CE.app",
--    C = "Google Chrome.app",
--    D = "Dash.app",
--    E = "Visual Studio Code.app",
    Q = "企业微信.app",
    S = "Safari.app",
    W = "WeChat.app",
    E = "WeTERM.app",
    P = "/System/Applications/Preview.app",
    C = "Google Chrome.app",
    M = "/System/Applications/Mail.app",
    [1] = "MWeb Pro.app",
    [2] = "Sublime Text.app",
    [3] = "TextMate.app",
    D = "iTerm.app",
    V = "MacVim.app",
    J = "AppCleaner.app",
    P = "PyCharm.app"
}

-- 显示 Finder: Alt + f
hs.hotkey.bind({"alt"}, "f", function()
    hs.application.open("/System/Library/CoreServices/Finder.app")
    hs.application.get("com.apple.finder"):setFrontmost(true)
end)

--------------------------------------------------------------------------------------
-- 按下 "Alt+键" 会打开或激活对应的应用，如果应用不是绝对路径，则指的是 /Applications 中的应用 --
--------------------------------------------------------------------------------------
function bindAppWithHotkey(keyAppPairs)
    for key, app in pairs(keyAppPairs) do
        -- local app = entry[2]
        -- local key = entry[1]

        -- 路径不以 / 开头，则指的是 /Applications 中的应用，把路径补充完整
        if string.sub(app, 0, 1) ~= "/" then
            app = "/Applications/" .. app
        end

        -- hs.alert.show(app)

        hs.hotkey.bind({"alt"}, key .. "", function()
            hs.application.open(app)
        end)
    end
end

bindAppWithHotkey(KEY_APP_PAIRS)

-- 窗口最大化
hs.hotkey.bind({"alt", "ctrl"}, "Return", function()
    sizeFocusedWindow("Max")
end)

-- 窗口左半屏
hs.hotkey.bind({"alt", "ctrl"}, "Left", function()
    sizeFocusedWindow("Half Left")
end)

-- 窗口右半屏
hs.hotkey.bind({"alt", "ctrl"}, "Right", function()
    sizeFocusedWindow("Half Right")
end)

-- 窗口靠左
hs.hotkey.bind({"alt", "ctrl", "cmd"}, "Left", function()
    moveFocusedWindow("Edge Left")
end)

-- 窗口靠右
hs.hotkey.bind({"alt", "ctrl", "cmd"}, "Right", function()
    moveFocusedWindow("Edge Right")
end)

-- 窗口居中
hs.hotkey.bind({"alt", "ctrl"}, "C", function()
    moveFocusedWindow("Center")
end)


-- 设置当前窗口的大小
function sizeFocusedWindow(mode)
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    f.x = max.x
    f.y = max.y
    f.w = max.w
    f.h = max.h

    if mode == "Max" then

    end
    if mode == "Half Left" then
        f.w = max.w / 2
    end
    if mode == "Half Right" then
        f.x = max.x + max.w / 2
        f.w = max.w / 2
    end

    win:setFrame(f, 0.2) -- 0 取消动画
end

-- 移动当前窗口
function moveFocusedWindow(mode)
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    if mode == "Edge Left" then
        f.x = max.x
        f.y = 0
    end
    if mode == "Edge Right" then
        f.x = max.x + (max.w - f.w)
        f.y = 0
    end
    if mode == "Center" then
        f.x = max.x + (max.w - f.w) / 2
        f.y = max.y + (max.h - f.h) / 3
        f.x = f.x > 0 and f.x or 0
        f.y = f.y > 0 and f.y or 0
    end

    win:setFrame(f, 0.3) -- 0 取消动画
end
----------------------
-- pomo
--- Pomodoro module

--------------------------------------------------------------------------------
-- Configuration variables
--------------------------------------------------------------------------------
local pom={}
pom.bar = {
  indicator_height = 0.1, -- ratio from the height of the menubar (0..1)
  indicator_alpha  = 0.3,
  indicator_in_all_spaces = true,
  color_time_remaining = hs.drawing.color.green,
  color_time_used      = hs.drawing.color.red,

  c_left = hs.drawing.rectangle(hs.geometry.rect(0,0,0,0)),
  c_used = hs.drawing.rectangle(hs.geometry.rect(0,0,0,0))
}

pom.config = {
  enable_color_bar = true,
  work_period_sec  = 25 * 60,
  rest_period_sec  = 5 * 60,

}

pom.var = {
  is_active        = false,
  disable_count    = 0,
  work_count       = 0,
  curr_active_type = "🍄", -- {"work", "rest"}
  time_left        = pom.config.work_period_sec,
  max_time_sec     = pom.config.work_period_sec
}

--------------------------------------------------------------------------------
-- Color bar for pomodoor
--------------------------------------------------------------------------------

function pom_del_indicators()
  pom.bar.c_left:delete()
  pom.bar.c_used:delete()
end

function pom_draw_on_menu(target_draw, screen, offset, width, fill_color)
  local screeng                  = screen:fullFrame()
  local screen_frame_height      = screen:frame().y
  local screen_full_frame_height = screeng.y
  local height_delta             = screen_frame_height - screen_full_frame_height
  local height                   = pom.bar.indicator_height * (height_delta)

  target_draw:setSize(hs.geometry.rect(screeng.x + offset, screen_full_frame_height, width, height))
  target_draw:setTopLeft(hs.geometry.point(screeng.x + offset, screen_full_frame_height))
  target_draw:setFillColor(fill_color)
  target_draw:setFill(true)
  target_draw:setAlpha(pom.bar.indicator_alpha)
  target_draw:setLevel(hs.drawing.windowLevels.overlay)
  target_draw:setStroke(false)
  if pom.bar.indicator_in_all_spaces then
    target_draw:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
  end
  target_draw:show()
end

function pom_draw_indicator(time_left, max_time)
  local main_screen = hs.screen.mainScreen()
  local screeng     = main_screen:fullFrame()
  local time_ratio  = time_left / max_time
  local width       = math.ceil(screeng.w * time_ratio)
  local left_width  = screeng.w - width

  pom_draw_on_menu(pom.bar.c_left, main_screen, left_width, width,      pom.bar.color_time_remaining)
  pom_draw_on_menu(pom.bar.c_used, main_screen, 0,          left_width, pom.bar.color_time_used)

end
--------------------------------------------------------------------------------

-- update display
local function pom_update_display()
  local time_min = math.floor( (pom.var.time_left / 60))
  local time_sec = pom.var.time_left - (time_min * 60)
  local str = string.format ("[ %s | %02d:%02d | #%02d ]", pom.var.curr_active_type, time_min, time_sec, pom.var.work_count)
  pom_menu:setTitle(str)
end

-- stop the clock
-- Stateful:
-- * Disabling once will pause the countdown
-- * Disabling twice will reset the countdown
-- * Disabling trice will shut down and hide the pomodoro timer
function pom_disable()

  local pom_was_active = pom.var.is_active
  pom.var.is_active = false

  if (pom.var.disable_count == 0) then
     if (pom_was_active) then
      pom_timer:stop()
    end
  elseif (pom.var.disable_count == 1) then
    pom.var.time_left         = pom.config.work_period_sec
    pom.var.curr_active_type  = "🍄"
    pom_update_display()
  elseif (pom.var.disable_count >= 2) then
    if pom_menu == nil then
      pom.var.disable_count = 2
      return
    end

    pom_menu:delete()
    pom_menu = nil
    pom_timer:stop()
    pom_timer = nil
    pom_del_indicators()
  end

  pom.var.disable_count = pom.var.disable_count + 1

end

-- update pomodoro timer
local function pom_update_time()
  if pom.var.is_active == false then
    return
  else
    pom.var.time_left = pom.var.time_left - 1

    if (pom.var.time_left <= 0 ) then
      pom_disable()
      if pom.var.curr_active_type == "🍄" then
        hs.alert.show("番茄时间完成！", 3)
        pom.var.work_count        =  pom.var.work_count + 1
        pom.var.curr_active_type  = "☕️"
        pom.var.time_left         = pom.config.rest_period_sec
        pom.var.max_time_sec      = pom.config.rest_period_sec
      else
          hs.alert.show("休息时间结束.", 3)
          pom.var.curr_active_type  = "🍄"
          pom.var.time_left         = pom.config.work_period_sec
          pom.var.max_time_sec      = pom.config.work_period_sec
      end
    end

    -- draw color bar indicator, if enabled.
    if (pom.config.enable_color_bar == true) then
      pom_draw_indicator(pom.var.time_left, pom.var.max_time_sec)
    end

  end
end

-- update menu display
local function pom_update_menu()
  pom_update_time()
  pom_update_display()
end

local function pom_create_menu(pom_origin)
  if pom_menu == nil then
    pom_menu = hs.menubar.new()
    pom.bar.c_left = hs.drawing.rectangle(hs.geometry.rect(0,0,0,0))
    pom.bar.c_used = hs.drawing.rectangle(hs.geometry.rect(0,0,0,0))
  end
end

-- start the pomodoro timer
function pom_enable()
  pom.var.disable_count = 0;
  if (pom.var.is_active) then
    return
  end

  pom_create_menu()
  pom_timer = hs.timer.new(1, pom_update_menu)

  pom.var.is_active = true
  pom_timer:start()
end

-- reset work count
-- TODO - reset automatically every day
function pom_reset_work()
  pom.var.work_count = 0;
end
-- Use examples:

-- init pomodoro -- show menu immediately
-- pom_create_menu()
-- pom_update_menu()

-- show menu only on first pom_enable
-- hs.hotkey.bind(hyper, '9', function() pom_enable() end)
-- hs.hotkey.bind(hyper, '0', function() pom_disable() end)

local application = require "hs.application"
local window = require "hs.window"
local hotkey = require "hs.hotkey"
local alert = require "hs.alert"
local grid = require "hs.grid"
local hints = require "hs.hints"
local applescript = require "hs.applescript"

-- hyper
local hyper = {"ctrl", "alt"}

require "slowq"

hs.hotkey.bind(hyper, '9', '🤓 > POMO ON', function() pom_enable() end)
hs.hotkey.bind(hyper, '0', '😌 > POMO OFF', function() pom_disable() end)


