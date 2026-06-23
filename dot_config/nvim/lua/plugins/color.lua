-- lua/plugins/rose-pine.lua
return {
	"rose-pine/neovim",
	name = "rose-pine",
	tag = "v3.0.2",
	config = function()
		require("rose-pine").setup({
			styles = {
				bold = true,
				italic = true,
				transparency = true,
			},
		})
		vim.cmd("colorscheme rose-pine-moon")
	end
}

