return {
	{
		"nvim-mini/mini.nvim",
		tag = "v0.18.0",
		config = function()
			require("mini.ai").setup({
				n_lines = 500,
			})
			require("mini.surround").setup()
		end,
	},
}
