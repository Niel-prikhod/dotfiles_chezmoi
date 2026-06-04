return {
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				format_on_save = function(bufnr)
					local filetype = vim.bo[bufnr].filetype
					if filetype ~= "c" and filetype ~= "cpp" then
						return { timeout_ms = 500, lsp_format = "fallback" }
					end
				end,
				formatters_by_ft = {},
			})
		end,
	},
}
