local waywall = require("waywall")
local helpers = require("waywall.helpers")
local Scene = require("waywork.scene")
local Modes = require("waywork.modes")
local Processes = require("waywork.processes")

local scene = Scene.SceneManager.new(waywall)
local mode_manager = Modes.ModeManager.new(waywall)

-- config

local config = {
  theme = {
    background = "#303030ff",
  },

  input = {
    sensitivity = 4.168456796691616,
  },
}

-- scenes

scene:register("e_counter", {
	kind = "mirror",
	options = { src = { x = 1, y = 37, w = 49, h = 9 }, dst = { x = 1150, y = 300, w = 196, h = 36 } },
	groups = { "thin" },
})

scene:register("tall_e_counter", {
	kind = "mirror",
	options = { src = { x = 1, y = 37, w = 49, h = 9 }, dst = { x = 1170, y = 300, w = 196, h = 36 } },
	groups = { "tall" },
})

scene:register("eye_measure", {
	kind = "mirror",
	options = { src = { x = 162, y = 7902, w = 60, h = 580 }, dst = { x = 30, y = 340, w = 700, h = 400 } },
	groups = { "tall" },
})

scene:register("eye_overlay", {
	kind = "image",
	path = files.overlay,
	options = { dst = { x = 30, y = 340, w = 700, h = 400 }, depth = 999 },
	groups = { "tall" },
})

scene:register("eye_crosshair", {
  kind = "image",
  path = files.crosshair,
  options = { dst = { x = 1266, y = 706, w = 28, h = 28}, depth = 999 },
  groups = { "tall" },
})

-- modes

mode_manager:define("tall", {
	width = 384,
	height = 16384,
	on_enter = function()
		scene:enable_group("tall", true)
		waywall.set_sensitivity(0.3749051567834777)
	end,
	on_exit = function()
		scene:enable_group("tall", false)
		waywall.set_sensitivity(0)
	end,
})

mode_manager:define("thin", {
	width = 384,
	height = 1440,
	on_enter = function()
		scene:enable_group("thin", true)
	end,
	on_exit = function()
		scene:enable_group("thin", false)
	end,
})

mode_manager:define("wide", {
	width = 2560,
	height = 384,
})

-- keybinds

config.actions = {
  ["Ctrl-Shift-N"] = function()
    waywall.exec(programs.ninjabrain_bot)
  end,
  ["Ctrl-Shift-Z"] = function()
    helpers.toggle_floating()
  end,
  ["Ctrl-B"] = function()
    return mode_manager:toggle("tall")
  end,
  ["Ctrl-Shift-MB4"] = function()
		return mode_manager:toggle("thin")
  end,
  ["Ctrl-Shift-MB5"] = function()
    return mode_manager:toggle("wide")
  end,
}

return config
