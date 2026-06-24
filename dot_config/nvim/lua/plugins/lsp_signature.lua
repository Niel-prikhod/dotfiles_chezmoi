return {
	{
		"ray-x/lsp_signature.nvim",
		-- TODO: revert to a release tag once one ships past v0.3.1; pinned to a
		-- master commit because the vim.tbl_flatten deprecation fix is unreleased.
		commit = "b7ace9ddb1640ce266012a45a672dfdaedfa5ec6",
		event = "VeryLazy",
		config = function()
			require("lsp_signature").setup({
				bind = true,
				handler_opts = { border = "single" },
			})
		end,
	},
}
