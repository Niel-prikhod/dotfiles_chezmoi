return {
	{
		"ray-x/lsp_signature.nvim",
		tag = "v0.3.1",
		event = "VeryLazy",
		config = function()
			require("lsp_signature").setup({
				bind = true,
				handler_opts = { border = "single" },
			})
		end,
	},
}
