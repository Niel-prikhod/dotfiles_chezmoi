local M = {}

local function run(cmd, opts)
	opts = opts or {}
	local result = vim.fn.system(cmd)
	local ok = vim.v.shell_error == 0
	if not ok then
		vim.notify("compiledb: " .. (opts.error_msg or "command failed"), vim.log.levels.ERROR)
	end
	return ok, result
end

function M.generate()
	local root = vim.fn.getcwd()

	if vim.fn.filereadable(root .. "/CMakeLists.txt") == 1 then
		local build_dirs = { "build", "build/Debug", "build/Release" }
		for _, dir in ipairs(build_dirs) do
			local src = root .. "/" .. dir .. "/compile_commands.json"
			if vim.fn.filereadable(src) == 1 then
				vim.fn.system({ "ln", "-sf", src, root .. "/compile_commands.json" })
				vim.notify("compiledb: Linked " .. dir .. "/compile_commands.json", vim.log.levels.INFO)
				return
			end
		end

		vim.notify("compiledb: Configuring CMake...", vim.log.levels.INFO)
		if run({ "cmake", "-B", "build", "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" }, { error_msg = "CMake failed" }) then
			vim.fn.system({ "ln", "-sf", root .. "/build/compile_commands.json", root .. "/compile_commands.json" })
			vim.notify("compiledb: Generated compile_commands.json via CMake", vim.log.levels.INFO)
		end
		return
	end

	if vim.fn.filereadable(root .. "/Makefile") == 1 or vim.fn.filereadable(root .. "/makefile") == 1 then
		local ok, _ = run({ "compiledb", "-n", "make" }, { error_msg = "compiledb not found or failed" })
		if not ok then
			ok, _ = run({ "bear", "--", "make", "-n" }, { error_msg = "bear also failed" })
		end
		if ok then
			vim.notify("compiledb: Generated compile_commands.json", vim.log.levels.INFO)
		end
		return
	end

	vim.notify("compiledb: No Makefile or CMakeLists.txt found", vim.log.levels.WARN)
end

function M.setup()
	vim.api.nvim_create_user_command("Compiledb", M.generate, {})
	vim.keymap.set("n", "<leader>cb", M.generate, { desc = "compiledb: Generate compile_commands.json" })
end

return M
