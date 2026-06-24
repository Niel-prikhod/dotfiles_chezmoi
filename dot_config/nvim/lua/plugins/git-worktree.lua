return {
	"polarmutex/git-worktree.nvim",

	tag = "2.1.0",

	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},

	config = function()
		local hooks = require("git-worktree.hooks")

		-- Update open buffers to the new worktree path after switching.
		hooks.register(hooks.type.SWITCH, hooks.builtins.update_current_buffer_on_switch)

		require("telescope").load_extension("git_worktree")

		local worktree = require("telescope").extensions.git_worktree
		-- List worktrees: <CR> switch, <M-d> delete, <M-c> create, <C-f> toggle force delete.
		vim.keymap.set("n", "<leader>gw", worktree.git_worktree, { desc = "Git worktrees" })
		-- Create a new worktree (prompts for branch/path/upstream).
		vim.keymap.set("n", "<leader>gW", worktree.create_git_worktree, { desc = "Create git worktree" })
	end,
}
