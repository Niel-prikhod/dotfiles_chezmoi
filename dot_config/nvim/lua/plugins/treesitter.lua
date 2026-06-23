return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local parsers = {
				"vimdoc",
				"c",
				"cpp",
				"rust",
				"zig",
				"python",
				"bash",
				"lua",
				"json",
				"toml",
				"yaml",
				"asm",
				"nasm",
				"make",
				"cmake",
			}
			require("nvim-treesitter").setup()
			require("nvim-treesitter").install(parsers)
			vim.api.nvim_create_autocmd("FileType", {
				pattern = parsers,
				callback = function(args)
					local max_filesize = 100 * 1024 -- 100 KB
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))
					if ok and stats and stats.size > max_filesize then
						return
					end
					pcall(vim.treesitter.start)
				end,
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-context",
		tag = "v1.0.0",
		after = "nvim-treesitter",
		config = function()
			require 'treesitter-context'.setup {
				enable = true,
				multiwindow = false,
				max_lines = 0,
				min_window_height = 0,
				line_numbers = true,
				multiline_threshold = 20,
				trim_scope = 'outer',
				mode = 'cursor',
				separator = nil,
				zindex = 20,
				on_attach = nil,
			}
		end
	}
}
