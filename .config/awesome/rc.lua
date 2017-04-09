-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.get_configuration_dir() .. "theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvtc -e tmux"
editor = "vi"

-- Default modkey.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts =
{
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top,
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
	awful.layout.suit.spiral,
	awful.layout.suit.spiral.dwindle,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,
	awful.layout.suit.magnifier,
	awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
globalmenu = awful.menu({
	items = {
		{
			"awesome",
			{
				{ "restart", awesome.restart },
				{ "quit", awesome.quit }
			},
			beautiful.awesome_icon
		},
		{
			"applications",
			{
				{ "open terminal", terminal }
			}
		},
		{
			"volume",
			{
				{ "mute/unmute", function() awful.spawn("pactl set-sink-mute 0 toggle") end },
				{ "volume 10%", function() awful.spawn("pactl set-sink-volume 0 10%") end },
				{ "volume 20%", function() awful.spawn("pactl set-sink-volume 0 20%") end },
				{ "volume 30%", function() awful.spawn("pactl set-sink-volume 0 30%") end },
				{ "volume 40%", function() awful.spawn("pactl set-sink-volume 0 40%") end },
				{ "volume 50%", function() awful.spawn("pactl set-sink-volume 0 50%") end }
			},
		},
		{
			"brightness",
			{
				{ "brightness 10%", function() awful.spawn("xbacklight -set 10") end },
				{ "brightness 20%", function() awful.spawn("xbacklight -set 20") end },
				{ "brightness 30%", function() awful.spawn("xbacklight -set 30") end },
				{ "brightness 40%", function() awful.spawn("xbacklight -set 40") end },
				{ "brightness 50%", function() awful.spawn("xbacklight -set 50") end }
			},
		}
	}
})

-- Create a laucher widget and a window menu
clientmenu = awful.menu({
	items = {
		{ "close", function() client.focus:kill() end },
		{ "lower", function() client.focus:lower() end },
		{ "raise", function() client.focus:raise() end },
		{ "redraw", function() client.focus:redraw() end },
		{ "floating", function() awful.client.floating.toggle(client.focus) end }
	}
})
-- }}}

-- {{{ Widgets
globalmenu_launcher = awful.widget.launcher({
	image = awesome.load_image(awful.util.get_configuration_dir() .. "images/menu"),
	menu = globalmenu
})

clientmenu_launcher = awful.widget.launcher({
	image = awesome.load_image(awful.util.get_configuration_dir() .. "images/close"),
	menu = clientmenu
})

-- Create a textclock widget
mytextclock = wibox.widget.textclock(" %Y-%m-%d %a %H:%M:%S ", 1)

-- Create a statustext widget
mystatustext = wibox.widget.textbox()
mystatustext.align = "center"
mystatustext.valign = "center"
local mytimer = gears.timer({ timeout = 1 })
mytimer:connect_signal("timeout", function()
	local file = io.open("/tmp/conkytext.tmp")
	mystatustext:set_markup(file:read("*all"))
	file:close()
end)
mytimer:start()
mytimer:emit_signal("timeout")
-- }}}

-- {{{ Screen
awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	--set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])

	-- Create widgets for each screen
	s.mypromptbox = awful.widget.prompt()
	s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)
	s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)
	s.mylayoutbox = awful.widget.layoutbox(s)

	-- Create the wibox (top)
	s.mytitlewibox = awful.wibar({ position = "top", screen = s })

	s.mytitlewibox:setup {
		layout = wibox.layout.align.horizontal,
		{
			layout = wibox.layout.fixed.horizontal,
			globalmenu_launcher,
			s.mypromptbox,
		},
		s.mytasklist,
		{
			layout = wibox.layout.fixed.horizontal,
			clientmenu_launcher,
		},
	}

	-- Create the wibox (bottom)
	s.mystatuswibox = awful.wibar({ position = "bottom", screen = s })

	s.mystatuswibox:setup {
		layout = wibox.layout.align.horizontal,
		{
			layout = wibox.layout.fixed.horizontal,
			s.mytaglist,
			s.mylayoutbox,
		},
		mystatustext,
		{
			layout = wibox.layout.fixed.horizontal,
			wibox.widget.systray(),
			mytextclock,
		},
	}
end)
-- }}}

-- {{{ Mouse bindings
rootbuttons = awful.util.table.join(
	awful.button({ }, 3, function() globalmenu:toggle() end),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
)

clientbuttons = awful.util.table.join(
	awful.button({ modkey }, 1, function(c) c:lower() end),
	awful.button({ modkey, "Shift" }, 1, awful.mouse.client.move),
	awful.button({ modkey }, 3, function(c) c:raise() end),
	awful.button({ modkey, "Shift" }, 3, awful.mouse.client.resize)
)

local tasklist_buttons = awful.util.table.join(
	awful.button({ }, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			-- Without this, the following
			-- :isvisible() makes no sense
			c.minimized = false
			if not c:isvisible() and c.first_tag then
				c.first_tag:view_only()
			end
			-- This will also un-minimize
			-- the client, if needed
			client.focus = c
			c:raise()
		end
	end),
	-- awful.button({ }, 3, client_menu_toggle_fn()),
	awful.button({ }, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({ }, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

local taglist_buttons = awful.util.table.join(
	awful.button({ }, 1, function(t) t:view_only() end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
	-- awful.key({ modkey }, "Left", awful.tag.viewprev),
	-- awful.key({ modkey }, "Right", awful.tag.viewnext),
	awful.key({ modkey }, "Escape", awful.tag.history.restore),

	awful.key({ modkey }, "j", function() awful.client.focus.byidx(1) end),
	awful.key({ modkey }, "k", function() awful.client.focus.byidx(-1) end),

	awful.key({ modkey }, "w", function()
		globalmenu:show({
			keygrabber = true,
			coords = { x = 0, y = 0 }
		})
	end),
	awful.key({ modkey, "Shift" }, "w", function()
		-- clientmenu:show({ keygrabber = true, coords = { x = 0, y = 0 } })
		clientmenu:show({
			keygrabber = true,
			coords = { x = awful.screen.focused().geometry.width, y = 0 }
		})
	end),

	-- Layout manipulation
	awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end),
	awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end),
	awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end),
	awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end),
	awful.key({ modkey }, "u", awful.client.urgent.jumpto),
	awful.key({ modkey }, "Tab", function()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end),

	-- Standard program
	awful.key({ modkey }, "Return", function() awful.spawn(terminal) end),
	awful.key({ modkey, "Control" }, "r", awesome.restart),
	awful.key({ modkey, "Shift" }, "q", awesome.quit),

	awful.key({ modkey }, "l", function() awful.tag.incmwfact(0.05) end),
	awful.key({ modkey }, "h", function() awful.tag.incmwfact(-0.05) end),
	awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1) end),
	awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1) end),
	awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1) end),
	awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1) end),
	awful.key({ modkey }, "space", function() awful.layout.inc(1) end),
	awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end),

	awful.key({ modkey, "Control" }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			client.focus = c
			c:raise()
		end
	end),

	-- Prompt
	awful.key({ modkey }, "r", function() awful.screen.focused().mypromptbox:run() end),

	awful.key({ modkey }, "x", function()
		awful.prompt.run {
			prompt = "Run Lua code: ",
			textbox = awful.screen.focused().mypromptbox.widget,
			exe_callback = awful.util.eval,
			history_path = awful.util.get_cache_dir() .. "/history_eval"
		}
	end),

	-- Move mouse cursor
	awful.key({ "Mod5" }, "h", function() mouse.coords({ x = mouse.coords().x - 50, y = mouse.coords().y }) end),
	awful.key({ "Mod5" }, "j", function() mouse.coords({ x = mouse.coords().x, y = mouse.coords().y + 50 }) end),
	awful.key({ "Mod5" }, "k", function() mouse.coords({ x = mouse.coords().x, y = mouse.coords().y - 50 }) end),
	awful.key({ "Mod5" }, "l", function() mouse.coords({ x = mouse.coords().x + 50, y = mouse.coords().y }) end),

	awful.key({ "Mod5", "Control" }, "h", function() mouse.coords({ x = mouse.coords().x - 10, y = mouse.coords().y }) end),
	awful.key({ "Mod5", "Control" }, "j", function() mouse.coords({ x = mouse.coords().x, y = mouse.coords().y + 10 }) end),
	awful.key({ "Mod5", "Control" }, "k", function() mouse.coords({ x = mouse.coords().x, y = mouse.coords().y - 10 }) end),
	awful.key({ "Mod5", "Control" }, "l", function() mouse.coords({ x = mouse.coords().x + 10, y = mouse.coords().y }) end),

	awful.key({ "Mod5", "Shift" }, "h", function() mouse.coords({ x = mouse.coords().x - 300, y = mouse.coords().y }) end),
	awful.key({ "Mod5", "Shift" }, "j", function() mouse.coords({ x = mouse.coords().x, y = mouse.coords().y + 300 }) end),
	awful.key({ "Mod5", "Shift" }, "k", function() mouse.coords({ x = mouse.coords().x, y = mouse.coords().y - 300 }) end),
	awful.key({ "Mod5", "Shift" }, "l", function() mouse.coords({ x = mouse.coords().x + 300, y = mouse.coords().y }) end),

	awful.key({ "Mod5" }, "i", function() awful.spawn("xdotool click 1") end),
	awful.key({ "Mod5" }, "u", function() awful.spawn("xdotool click 2") end),
	awful.key({ "Mod5" }, "o", function() awful.spawn("xdotool click 3") end),
	awful.key({ "Mod5" }, "p", function() awful.spawn("xdotool click 4") end),
	awful.key({ "Mod5" }, "n", function() awful.spawn("xdotool click 5") end),

	awful.key({ "Mod5" }, "m", function()
		if mouse.coords().x == 0 and mouse.coords().y == 0 then
			mouse.coords({
				x = awful.screen.focused().geometry.width / 2,
				y = awful.screen.focused().geometry.height / 2
			})
		else
			mouse.coords({ x = 0, y = 0 })
		end
	end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 5 do
	globalkeys = awful.util.table.join(
		globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end),
		-- Toggle tag.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end),
		-- My Key bindings
		awful.key({ modkey }, "6", function() awful.layout.set(awful.layout.suit.floating, t) end),
		awful.key({ modkey }, "7", function()
			if awful.layout.get() == awful.layout.suit.tile.left then
				awful.layout.set(awful.layout.suit.tile.right, t)
			else
				awful.layout.set(awful.layout.suit.tile.left, t)
			end
		end),
		awful.key({ modkey }, "8", function()
			if awful.layout.get() == awful.layout.suit.tile.top then
				awful.layout.set(awful.layout.suit.tile.bottom, t)
			else
				awful.layout.set(awful.layout.suit.tile.top, t)
			end
		end),
		awful.key({ modkey }, "9", function()
			if awful.layout.get() == awful.layout.suit.max then
				awful.layout.set(awful.layout.suit.max.fullscreen, t)
			else
				awful.layout.set(awful.layout.suit.max, t)
			end
		end)
	)
end
-- }}}

-- {{{ Client Key bindings
clientkeys = awful.util.table.join(
	awful.key({ modkey }, "f", function(c) c.fullscreen = not c.fullscreen end),
	awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end),
	awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle),
	awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end),
	awful.key({ modkey }, "o", awful.client.movetoscreen),
	awful.key({ modkey, "Shift" }, "r", function(c) c:redraw() end),
	awful.key({ modkey }, "t", function(c) c.ontop = not c.ontop end),
	awful.key({ modkey }, "n", function(c)
		-- The client currently has the input focus, so it cannot be
		-- minimized, since minimized clients can't have the focus.
		c.minimized = true
	end),
	awful.key({ modkey }, "m", function(c)
		c.maximized = not c.maximized
		c:raise()
	end)
)
-- }}}

-- {{{ Set keys and buttons
root.buttons(rootbuttons)
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = { },
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap+awful.placement.no_offscreen,
			size_hints_honor = false
		}
	},
	-- Set Firefox to always map on tags number 2 of screen 1.
	-- { rule = { class = "Firefox" },
	--   properties = { tag = tags[1][2] } },
	{
		rule = { class = "URxvt" },
		properties = { icon = awesome.load_image(awful.util.get_configuration_dir() .. "images/terminal") }
	}
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
		client.focus = c
	end
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
	c.opacity = 1
end)

client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
	c.opacity = 0.6
end)
-- }}}

-- {{{ Naughty
for key, value in pairs({ naughty.config.presets.low, naughty.config.presets.normal, naughty.config.presets.critical }) do
	value.width = 400
	value.border_width = 2
	value.icon_size = 48
	value.position = "bottom_right"
end
-- }}}
