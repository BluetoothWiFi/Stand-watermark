--[[
**  github.com/BluetoothWiFi            **
**  Version: 1.1.1		**
**  Script repo - https://github.com/BluetoothWiFi/Stand-watermark		**
**  original script repo - github.com/IMXNOOBX/ScriptKid  **
]]

util.require_natives(1651208000)

-- Local Functions

-- Local Vars
local x, y = 0.992, 0.008
local icon
local editions = {
    'Free',
    'Basic',
    'Regular',
    'Ultimate'
}

-- Settings
local Settings <const> = {}
Settings.show_icon = true
Settings.show_name = true
Settings.show_time = true
Settings.show_players = true
Settings.show_tps = true
Settings.show_firstl = 2
Settings.add_x = 0.0055
Settings.add_y = 0.0
Settings.bg_color = {r = 0.8, g = 0.35, b = 0.8, a = 0.8}
Settings.tx_color = {r = 1.0, g = 1.0, b = 1.0, a = 1.0}
Settings.tps = 0
Settings.time_format = 2

--tps counter (very dodgy but works lol)
local tps = 0
util.create_tick_handler(function()
    tps = tps + 1
end)
util.create_tick_handler(function()
    util.yield(1000)
    Settings.tps = tps
    tps = 0
end)

-- Download Icon
if not filesystem.exists(filesystem.scripts_dir() .. "/watermark/icon.png") then
    util.toast("[FS|WaterMark] Watermark icon not found, downloading...")
    local path_root = filesystem.scripts_dir() .."watermark/"
    async_http.init("raw.githubusercontent.com", "/BluetoothWiFi/Stand-watermark/main/icon/stand_icon.png", function(req)
		if not req then
			util.toast("Failed to download watermak/stand_icon.png, please download it manually.\nThe link is copied in your clipboard.")
            util.copy_to_clipboard("https://github.com/BluetoothWiFi/Stand-watermark/blob/main/icon/stand_icon.png", true)
            return 
        end

        filesystem.mkdir(path_root)
		local f = io.open(path_root.."icon.png", "wb")
		f:write(req)
		f:close()
		util.toast("Successfully downloaded icon.png from the repository.")
        icon = directx.create_texture(filesystem.scripts_dir() .. "/watermark/icon.png")
	end)
	async_http.dispatch()
else
    icon = directx.create_texture(filesystem.scripts_dir() .. "/watermark/icon.png")
end

-- Settings
menu.divider(menu.my_root(), "Settings")
local pos_settings = menu.list(menu.my_root(), "Position", {}, "", function() end)
menu.slider(pos_settings, "X position", {"watermark-x"}, "Move the watermark in the x position", -100000, 100000, x * 10000, 1, function(xvar1)
    x = xvar1 / 10000
end)
menu.slider(pos_settings, "Y position", {"watermark-y"}, "Move the watermark in the y position", -100000, 100000, y * 10000, 1, function(yvar1)
    y = yvar1 / 10000
end)
menu.slider(pos_settings, "Background Size X", {"watermark-addx"}, "Add x ammount to the background", -100000, 100000, Settings.add_x * 10000, 1, function(xvar2)
    Settings.add_x = xvar2 / 10000
end)
menu.slider(pos_settings, "Background Size Y", {"watermark-addy"}, "Add y ammount to the background", -100000, 100000, Settings.add_y * 10000, 1, function(yvar2)
    Settings.add_y = yvar2 / 10000
end)

-- Colour
local color_settings = menu.list(menu.my_root(), "Colors", {}, "", function() end)
local rgb_background = menu.colour(color_settings, "Background Color", {"watermark-bg_color"}, "Select background color", Settings.bg_color, true, function(col)
    Settings.bg_color = col
end)
menu.rainbow(rgb_background)
local rgb_text = menu.colour(color_settings, "Text Color", {"watermark-tx_color"}, "Select text color", Settings.tx_color, true, function(col)
    Settings.tx_color = col
end)
menu.rainbow(rgb_text)

-- Misc Options
menu.divider(menu.my_root(), "Additional")
menu.toggle(menu.my_root(), "Icon", {}, "Shows stand logo in the watermark", function(val)
	Settings.show_icon = val
end, Settings.show_icon)
menu.list_select(menu.my_root(), "Label", {}, "Change the first label in the watermak", {"Disable", "Stand", "Version", "Root Name", "FemboyEdition", "^_-", "OwO"}, Settings.show_firstl, function (val)
    Settings.show_firstl = val
end)
menu.toggle(menu.my_root(), "Name", {}, "Shows ur nickname in the watermark", function(val)
	Settings.show_name = val
end, Settings.show_name)
menu.toggle(menu.my_root(), "Player Count", {}, "Shows Player Count in the watermark", function(val)
	Settings.show_players = val
end, Settings.show_players)
menu.toggle(menu.my_root(), "TPS", {}, "Shows ticks per second in the watermark\nNOTE: TPS is similar to FPS, but they are not", function(val)
	Settings.show_tps = val
end, Settings.show_tps)
menu.toggle(menu.my_root(), "Time", {}, "Shows OS time in the watermark", function(val)
	Settings.show_time = val
end, Settings.show_time)
menu.list_select(menu.my_root(), "Time Format", {}, "Change the time format in the watermak", {"12HR", "24HR"}, Settings.time_format, function (val)
    Settings.time_format = val
end)

-- Main Toggle
menu.divider(menu.my_root(), "")
menu.toggle_loop(menu.my_root(), "Enable Watermark", {"watermark"}, "Enable/Disable Watermark \n\n It is very temperamental with the 100 emoji showing", function()
    if menu.is_in_screenshot_mode() then return end

    local function get_root_name()
        local root_name = menu.get_state(menu.ref_by_path("Stand>Settings>Appearance>Address Bar>Root Name"))
        root_name = root_name:gsub("{}", "")
        root_name = root_name:gsub("Hidden", "")
        return root_name
    end
    local label_table = {
        "",                               --1
        "Stand",                          --2
        editions[menu.get_edition() + 1], --3
        get_root_name(),                  --4
        "FemboyEdition",                  --5
        "^_-",                            --6
        "OwO",                            --7
    }

    local wm_text = label_table[Settings.show_firstl]
    if Settings.show_name then
        if Settings.show_firstl == 1 then 
            wm_text = wm_text..players.get_name(players.user())
        else
            wm_text = wm_text.." | "..players.get_name(players.user())
        end
    end
    if Settings.show_players and NETWORK.NETWORK_IS_SESSION_STARTED() then
        wm_text = wm_text.." | ".."Players: "..#players.list()
    end
    if Settings.show_tps then
        wm_text = wm_text.." | ".."TPS: "..Settings.tps
    end
    if Settings.show_time and Settings.time_format == 1 then
        wm_text = wm_text..os.date(" | %I"):gsub("0", "")..os.date(":%M:%S")
    elseif Settings.show_time and Settings.time_format == 2 then
        wm_text = wm_text..os.date(" | %H"):gsub("0", "")..os.date(":%M:%S")
    end
    local tx_size = directx.get_text_size(wm_text, 0.5)

    if Settings.show_icon then
        directx.draw_rect(
            x + Settings.add_x * 0.5,
            y,
            -(tx_size + 0.0105 + Settings.add_x),  -- add watermark size
            0.025 + Settings.add_y,
            Settings.bg_color
        )
    else
        directx.draw_rect(
            x + Settings.add_x * 0.5,
            y,
            -(tx_size + 0.005),  -- add watermark size
            0.025 + Settings.add_y,
            Settings.bg_color
        )
    end

    if Settings.show_icon then
        directx.draw_texture(icon, 
            0.0055,
            0.0055,
            0.5,
            0.5,
            x - tx_size - 0.0055,
            y + 0.013,
            0,
            {r = 1.0, g = 1.0, b = 1.0, a = 1.0}
        )
    end 
    directx.draw_text(
        x,
        y + 0.004,
        wm_text,
        ALIGN_TOP_RIGHT,
        0.5,
        Settings.tx_color,
        false
    )
end)

util.keep_running()
