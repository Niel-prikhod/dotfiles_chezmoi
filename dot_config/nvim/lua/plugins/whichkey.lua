return {
	{
		"folke/which-key.nvim",
		tag = "v3.17.0",
		event = "VeryLazy",
		config = function()
			require("which-key").setup({
				delay = 0,
			})
		end,
	},
}
