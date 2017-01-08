-- Standard awesome library
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvtc -e tmux"
editor = "vi"

-- Default modkey.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
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
	awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = { }
for s = 1, screen.count() do
	-- Each screen has its own tag table.
	tags[s] = awful.tag({ 1, 2, 3, 4, 5 }, s, layouts[1])
end
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
				{ "mute/unmute", function() awful.util.spawn("pactl set-sink-mute 0 toggle") end },
				{ "volume 10%", function() awful.util.spawn("pactl set-sink-volume 0 10%") end },
				{ "volume 20%", function() awful.util.spawn("pactl set-sink-volume 0 20%") end },
				{ "volume 30%", function() awful.util.spawn("pactl set-sink-volume 0 30%") end },
				{ "volume 40%", function() awful.util.spawn("pactl set-sink-volume 0 40%") end },
				{ "volume 50%", function() awful.util.spawn("pactl set-sink-volume 0 50%") end }
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

-- {{{ Wibox (top)
-- Create a wibox for each screen and add it
mytitlewibox = { }

mymainlauncher = awful.widget.launcher({
	image = awesome.load_image(awful.util.getdir("config") .. "/images/menu"),
	menu = globalmenu
})

mypromptbox = { }

mytasklist = { }
mytasklist.buttons = awful.util.table.join(
	awful.button({ }, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			-- Without this, the following
			-- :isvisible() makes no sense
			c.minimized = false
			if not c:isvisible() then
				awful.tag.viewonly(c:tags()[1])
			end
			-- This will also un-minimize
			-- the client, if needed
			client.focus = c
			c:raise()
		end
	end),
	awful.button({ }, 3, function()
		if instance then
			instance:hide()
			instance = nil
		else
			instance = awful.menu.clients({ width = 250 })
		end
	end),
	awful.button({ }, 4, function()
		awful.client.focus.byidx(1)
		if client.focus then client.focus:raise() end
	end),
	awful.button({ }, 5, function()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	end)
)

mywindowlauncher = awful.widget.launcher({
	image = awesome.load_image(awful.util.getdir("config") .. "/images/close"),
	menu = clientmenu
})

for s = 1, screen.count() do
	-- Create a promptbox for each screen
	mypromptbox[s] = awful.widget.prompt()

	-- Create a tasklist widget
	mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

	-- Create the wibox
	mytitlewibox[s] = awful.wibox({ position = "top", screen = s })

	-- Widgets that are aligned to the left
	local top_left_layout = wibox.layout.fixed.horizontal()
	top_left_layout:add(mymainlauncher)
	top_left_layout:add(mypromptbox[s])

	-- Widgets that are aligned to the right
	local top_right_layout = wibox.layout.fixed.horizontal()
	top_right_layout:add(mywindowlauncher)

	-- Now bring it all together (with the tasklist in the middle)
	local top_layout = wibox.layout.align.horizontal()
	top_layout:set_left(top_left_layout)
	top_layout:set_middle(mytasklist[s])
	top_layout:set_right(top_right_layout)

	mytitlewibox[s]:set_widget(top_layout)
end
-- }}}

-- {{{ Wibox (bottom)
-- Create a wibox for each screen and add it
mystatuswibox = { }

mytaglist = { }
mytaglist.buttons = awful.util.table.join(
	awful.button({ }, 1, awful.tag.viewonly),
	awful.button({ modkey }, 1, awful.client.movetotag),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, awful.client.toggletag),
	awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
	awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)

mylayoutbox = { }

-- Create a statustext widget
mystatustext = wibox.widget.textbox()
local mytimer = timer({ timeout = 1 })
mytimer:connect_signal("timeout", function()
	local file = io.open("/tmp/conkytext.tmp")
	mystatustext:set_markup(file:read("*all"))
	file:close()
end)
mytimer:start()
mytimer:emit_signal("timeout")

-- Create a textclock widget
mytextclock = awful.widget.textclock(" %Y-%m-%d %a %H:%M:%S ", 1)

for s = 1, screen.count() do
	-- Create a taglist widget
	mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	mylayoutbox[s] = awful.widget.layoutbox(s)
	mylayoutbox[s]:buttons(awful.util.table.join(
		awful.button({ }, 1, function() awful.layout.inc(layouts, 1) end),
		awful.button({ }, 3, function() awful.layout.inc(layouts, -1) end),
		awful.button({ }, 4, function() awful.layout.inc(layouts, 1) end),
		awful.button({ }, 5, function() awful.layout.inc(layouts, -1) end)
	))

	-- Create the wibox
	mystatuswibox[s] = awful.wibox({ position = "bottom", screen = s })

	-- Widgets that are aligned to the left
	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(mytaglist[s])
	left_layout:add(mylayoutbox[s])

	-- Widgets that are aligned to the right
	local right_layout = wibox.layout.fixed.horizontal()
	if s == 1 then right_layout:add(wibox.widget.systray()) end
	right_layout:add(mytextclock)

	-- Now bring it all together (with the tasklist in the middle)
	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(mystatustext)
	layout:set_right(right_layout)

	mystatuswibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
	awful.button({ }, 3, function() globalmenu:toggle() end),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
))

clientbuttons = awful.util.table.join(
	awful.button({ modkey }, 1, function(c) c:lower() end),
	awful.button({ modkey, "Shift" }, 1, awful.mouse.client.move),
	awful.button({ modkey }, 3, function(c) c:raise() end),
	awful.button({ modkey, "Shift" }, 3, awful.mouse.client.resize)
)
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
	-- awful.key({ modkey }, "Left", awful.tag.viewprev),
	-- awful.key({ modkey }, "Right", awful.tag.viewnext),
	-- awful.key({ modkey }, "Escape", awful.tag.history.restore),

	awful.key({ modkey }, "j", function()
		awful.client.focus.byidx(1)
		if client.focus then client.focus:raise() end
	end),
	awful.key({ modkey }, "k", function()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	end),
	awful.key({ modkey }, "w", function()
		globalmenu:show({ keygrabber = true, coords = { x = 0, y = 0 } })
	end),
	awful.key({ modkey, "Shift" }, "w", function()
		clientmenu:show({ keygrabber = true, coords = { x = 0, y = 0 } })
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
	awful.key({ modkey }, "Return", function() awful.util.spawn(terminal) end),
	awful.key({ modkey, "Control" }, "r", awesome.restart),
	awful.key({ modkey, "Shift" }, "q", awesome.quit),

	awful.key({ modkey }, "l", function() awful.tag.incmwfact(0.05) end),
	awful.key({ modkey }, "h", function() awful.tag.incmwfact(-0.05) end),
	awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1) end),
	awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1) end),
	awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1) end),
	awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1) end),
	awful.key({ modkey }, "space", function() awful.layout.inc(layouts, 1) end),
	awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(layouts, -1) end),

	awful.key({ modkey, "Control" }, "n", awful.client.restore),

	-- Prompt
	awful.key({ modkey }, "r", function() mypromptbox[mouse.screen]:run() end),

	awful.key({ modkey }, "x", function()
		awful.prompt.run({ prompt = "Run Lua code: " },
		mypromptbox[mouse.screen].widget,
		awful.util.eval, nil,
		awful.util.getdir("cache") .. "/history_eval")
	end),

	-- Move mouse cursor
	awful.key({ modkey }, "Left", function() mouse.coords({ x = mouse.coords().x - 50, y = mouse.coords().y }) end),
	awful.key({ modkey }, "Down", function() mouse.coords({ x = mouse.coords().x, y = mouse.coords().y + 50 }) end),
	awful.key({ modkey }, "Up", function() mouse.coords({ x = mouse.coords().x, y = mouse.coords().y - 50 }) end),
	awful.key({ modkey }, "Right", function() mouse.coords({ x = mouse.coords().x + 50, y = mouse.coords().y }) end),

	awful.key({ modkey, "Control" }, "Left", function() mouse.coords({ x = mouse.coords().x - 10, y = mouse.coords().y }) end),
	awful.key({ modkey, "Control" }, "Down", function() mouse.coords({ x = mouse.coords().x, y = mouse.coords().y + 10 }) end),
	awful.key({ modkey, "Control" }, "Up", function() mouse.coords({ x = mouse.coords().x, y = mouse.coords().y - 10 }) end),
	awful.key({ modkey, "Control" }, "Right", function() mouse.coords({ x = mouse.coords().x + 10, y = mouse.coords().y }) end),

	awful.key({ modkey, "Shift" }, "Left", function() mouse.coords({ x = mouse.coords().x - 300, y = mouse.coords().y }) end),
	awful.key({ modkey, "Shift" }, "Down", function() mouse.coords({ x = mouse.coords().x, y = mouse.coords().y + 300 }) end),
	awful.key({ modkey, "Shift" }, "Up", function() mouse.coords({ x = mouse.coords().x, y = mouse.coords().y - 300 }) end),
	awful.key({ modkey, "Shift" }, "Right", function() mouse.coords({ x = mouse.coords().x + 300, y = mouse.coords().y }) end),

	awful.key({ modkey }, "Escape", function()
		if mouse.coords().x == 0 and mouse.coords().y == 0 then
			mouse.coords({
				x = screen[mouse.screen].geometry.width / 2,
				y = screen[mouse.screen].geometry.height / 2
			})
		else
			mouse.coords({ x = 0, y = 0 })
		end
	end),

	awful.key({ modkey, "Mod1" }, "Left", function() awful.util.spawn("xdotool click 1") end),
	awful.key({ modkey, "Mod1" }, "Down", function() awful.util.spawn("xdotool click 2") end),
	awful.key({ modkey, "Mod1" }, "Right", function() awful.util.spawn("xdotool click 3") end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 5 do
	globalkeys = awful.util.table.join(
		globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = mouse.screen
			local tag = awful.tag.gettags(screen)[i]
			if tag then
				awful.tag.viewonly(tag)
			end
		end),
		-- Toggle tag.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			local screen = mouse.screen
			local tag = awful.tag.gettags(screen)[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = awful.tag.gettags(client.focus.screen)[i]
				if tag then
					awful.client.movetotag(tag)
				end
			end
		end),
		-- Toggle tag.
		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			if client.focus then
				local tag = awful.tag.gettags(client.focus.screen)[i]
				if tag then
					awful.client.toggletag(tag)
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

-- Set keys
root.keys(globalkeys)
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
		c.maximized_horizontal = not c.maximized_horizontal
		c.maximized_vertical = not c.maximized_vertical
	end)
)
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
			focus = true,
			keys = clientkeys,
			buttons = clientbuttons,
			size_hints_honor = false
		}
	},
	-- Set Firefox to always map on tags number 2 of screen 1.
	-- { rule = { class = "Firefox" },
	--   properties = { tag = tags[1][2] } },
	{
		rule = { class = "URxvt" },
		properties = { icon = awesome.load_image(awful.util.getdir("config") .. "/images/terminal") }
	}
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c, startup)
	-- Enable sloppy focus
	c:connect_signal("mouse::enter", function(c)
		if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
			client.focus = c
		end
	end)

	if not startup then
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		-- awful.client.setslave(c)

		-- Put windows in a smart way, only if they does not set an initial position.
		if not c.size_hints.user_position and not c.size_hints.program_position then
			awful.placement.no_overlap(c)
			awful.placement.no_offscreen(c)
		end
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
