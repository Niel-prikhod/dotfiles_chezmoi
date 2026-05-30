-- MicroPython / Raspberry Pi Pico helper for Neovim
-- Put this whole block into your init.lua.
-- Edit mpremote_path to the full path of your project's venv mpremote binary.

local M = {}

-- === CONFIG (edit this) ===
local mpremote_path = "/mnt/wd_blue/code/rt_ot/micro/bin/mpremote"
local preferred_ports = { "/dev/ttyACM0", "/dev/ttyACM1", "/dev/ttyUSB0", "/dev/ttyUSB1" }
-- local default_timeout_ms = 2000
-- ==========================

local fn = vim.fn
local api = vim.api

local function file_exists(path)
	return fn.filereadable(path) == 1 or fn.isdirectory(path) == 1
end

local function is_executable(path)
	-- if it's on PATH, executable() is fine; for full path, fallback to file_exists
	if fn.executable(path) == 1 then return true end
	return file_exists(path)
end

local function find_port()
	-- prefer explicit list first
	for _, p in ipairs(preferred_ports) do
		if fn.filereadable(p) == 0 and fn.isdirectory(p) == 0 then
			-- filereadable returns 0 for device nodes; check using glob instead
		end
		if fn.glob(p) ~= "" then
			return p
		end
	end
	-- fallback: glob common patterns and return first match
	local acm = fn.glob("/dev/ttyACM*")
	if acm ~= "" then
		return fn.split(acm, "\n")[1]
	end
	local usb = fn.glob("/dev/ttyUSB*")
	if usb ~= "" then
		return fn.split(usb, "\n")[1]
	end
	return nil
end

local function ensure_saved()
	-- Save buffer if modified so we run the latest file
	if vim.bo.modified then
		vim.cmd("write")
	end
end

-- Run the current buffer on the Pico (in RAM). Opens a terminal split showing output.
local api = vim.api
local fn = vim.fn

function M.run_current_file(opts)
	opts = opts or {}
	if not is_executable(mpremote_path) then
		api.nvim_notify("mpremote not found at: " .. mpremote_path, vim.log.levels.ERROR, {})
		return
	end

	local file = fn.expand("%:p")
	if file == "" then
		api.nvim_notify("No file in current buffer to run", vim.log.levels.ERROR, {})
		return
	end

	ensure_saved()

	local port = opts.port or find_port()
	if not port then
		api.nvim_notify("No serial port found (/dev/ttyACM* or /dev/ttyUSB*)", vim.log.levels.ERROR, {})
		return
	end

	local cmd = {
		mpremote_path,
		"connect",
		port,
		"run",
		file,
	}

	-- save current window and buffer
	local cur_win = api.nvim_get_current_win()
	local cur_buf = api.nvim_get_current_buf()

	-- compute split height
	local cur_height = api.nvim_win_get_height(cur_win)
	local term_height = math.max(6, math.floor(cur_height / 2))

	-- open bottom split for terminal
	api.nvim_command("botright split")
	api.nvim_command("resize " .. term_height)
	local term_buf = api.nvim_get_current_buf()

	-- start terminal process
	local term_chan = api.nvim_open_term(term_buf, {})

	-- feed the command to the terminal
	api.nvim_chan_send(term_chan, table.concat(cmd, " ") .. "\n")

	-- name the terminal buffer
	pcall(api.nvim_buf_set_name, term_buf, "MicroRun: " .. fn.fnamemodify(file, ":t"))
	pcall(api.nvim_buf_set_option, term_buf, "bufhidden", "wipe")

	-- restore focus to original window
	if api.nvim_win_is_valid(cur_win) then
		api.nvim_set_current_win(cur_win)
	end

	-- autocmd to restore buffer on terminal close
	api.nvim_create_autocmd("TermClose", {
		buffer = term_buf,
		once = true,
		callback = function()
			if api.nvim_win_is_valid(cur_win) then
				api.nvim_set_current_win(cur_win)
				if api.nvim_buf_is_loaded(cur_buf) and api.nvim_buf_is_valid(cur_buf) then
					pcall(api.nvim_win_set_buf, cur_win, cur_buf)
				else
					api.nvim_command("edit " .. fn.fnameescape(file))
				end
			else
				api.nvim_command("edit " .. fn.fnameescape(file))
			end
		end,
	})
end

-- Upload (fs put) current file to the Pico filesystem, then soft-reset the board.
-- This persists the file on the device.
function M.put_current_file_and_reset(opts)
	opts = opts or {}
	if not is_executable(mpremote_path) then
		api.nvim_err_writeln("mpremote not found at: " .. mpremote_path)
		return
	end

	local file = fn.expand("%:p")
	if file == "" or file == nil then
		api.nvim_err_writeln("No file in current buffer to upload")
		return
	end

	ensure_saved()

	local port = opts.port or find_port()
	if not port then
		api.nvim_err_writeln("No serial port found (/dev/ttyACM* or /dev/ttyUSB*).")
		return
	end

	-- Two-step: fs put <file> then reset
	local put_cmd = table.concat({
		fn.shellescape(mpremote_path),
		"connect",
		fn.shellescape(port),
		"fs",
		"put",
		fn.shellescape(file)
	}, " ")

	local reset_cmd = table.concat({
		fn.shellescape(mpremote_path),
		"connect",
		fn.shellescape(port),
		"reset"
	}, " ")

	vim.cmd("botright split")
	vim.cmd("resize 12")
	local full_cmd = put_cmd .. " && " .. reset_cmd
	vim.fn.termopen(full_cmd, { detach = 0 })
	vim.cmd("startinsert")
end

-- Create user commands and keymaps
api.nvim_create_user_command("MicroRun", function(opts)
	M.run_current_file()
end, { desc = "Run current file on Pico using mpremote (executes in RAM)" })

api.nvim_create_user_command("MicroPut", function(opts)
	M.put_current_file_and_reset()
end, { desc = "Upload current file to Pico filesystem and reset (persists file)" })

-- Keymaps: <leader>mr -> run, <leader>mu -> upload+reset
-- Adjust the lhs if you prefer different keys.
vim.keymap.set("n", "<leader>mr", "<cmd>MicroRun<CR>", { silent = true, noremap = true })
vim.keymap.set("n", "<leader>mu", "<cmd>MicroPut<CR>", { silent = true, noremap = true })

-- Expose module for further customization if you `require` this file.
return M
