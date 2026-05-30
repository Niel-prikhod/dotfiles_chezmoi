return {
	"nvimdev/lspsaga.nvim",
	config = function()
		require("lspsaga").setup({
			lightbulb = {
				enable = true,
				enable_in_insert = true,
				sign = false,
				sign_priority = 40,
				virtual_text = true,
			},
			ui = {
				border = "single",
			},
		})
	end,
}
