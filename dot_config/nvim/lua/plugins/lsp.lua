return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"folke/lazydev.nvim",
				ft = "lua", -- Only load on Lua files
				opts = {
					library = {
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					},
				},
			},
			{ "williamboman/mason.nvim",          config = true },
			{ "williamboman/mason-lspconfig.nvim" },
			{ "hrsh7th/nvim-cmp" },
			{ "hrsh7th/cmp-nvim-lsp" },
		},
		config = function()
			require("mason").setup()

			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "clangd", "bashls", "pylsp" },
				handlers = {
					function(server_name)
						require("lspconfig")[server_name].setup({
							capabilities = require('cmp_nvim_lsp').default_capabilities(),
						})
					end,

					["clangd"] = function() end,
				}
			})

			local function force_diagnostics(bufnr)
				bufnr = bufnr or vim.api.nvim_get_current_buf()
				local clients = vim.lsp.get_clients({ bufnr = bufnr })
				for _, client in ipairs(clients) do
					client.notify("textDocument/didSave", { textDocument = { uri = vim.uri_from_bufnr(bufnr) } })
					if client.supports_method("workspace/diagnostic/refresh") then
						client.request("workspace/diagnostic/refresh", {}, function() end, bufnr)
					end
				end
			end

			local on_attach = function(client, bufnr)
				if client.supports_method("textDocument/formatting") then
					vim.keymap.set("n", "<leader>f", function()
							vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 2000 })
						end,
						{ buffer = bufnr, desc = "LSP: Format buffer" })
				end
				vim.api.nvim_create_autocmd("BufWritePost", {
					buffer = bufnr,
					callback = function()
						force_diagnostics(bufnr)
					end,
				})
			end

			vim.lsp.config("lua_ls", {
				filetypes = { 'lua' },
				on_attach = on_attach,
				settings = {
					Lua = {
						runtime = { version = 'LuaJIT' },
						diagnostics = { globals = { 'vim' } },
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						telemetry = { enable = false },
					},
				}
			})

			vim.lsp.config("pylsp", {
				filetypes = { "python" },
				on_attach = on_attach,
				settings = { pylsp = { plugins = { pyflakes = { enabled = true } } } },
			})

			vim.lsp.config("clangd", {
				cmd = {
					"clangd",
					"--background-index",
					"--query-driver=/usr/bin/arm-none-eabi-gcc",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--compile-commands-dir=build/Debug",
				},
				on_attach = on_attach,
				root_markers = { "compile_commands.json", "build/Debug/compile_commands.json", ".git" },
				capabilities = require('cmp_nvim_lsp').default_capabilities(),
			})

			vim.lsp.enable("clangd")
			vim.lsp.enable("lua_ls")

			vim.api.nvim_create_autocmd('LspAttach', {
				group = vim.api.nvim_create_augroup('my.lsp', {}),
				callback = function(args)
					local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
					if not client then return end
					local ft = vim.bo[args.buf].filetype
					if ft == "c" or ft == "cpp" then return end
					if client.supports_method('textDocument/formatting') then
						vim.api.nvim_create_autocmd('BufWritePre', {
							buffer = args.buf,
							callback = function()
								vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
							end,
						})
					end
				end,
			})

			-- Global LSP keybindings
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local bufnr = args.buf
					vim.keymap.set("n", "gd", function()
						vim.lsp.buf.definition()
						vim.cmd("normal! zz") -- Center after jumping
					end, { buffer = bufnr, desc = "Go to definition" })
					-- vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Show hover info" })
					vim.keymap.set("n", "gf", vim.lsp.buf.declaration, { buffer = bufnr, desc = "Go to declaration" })
					vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", { buffer = bufnr, desc = "Show hover info" })
					vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code action" })
					vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename symbol" })
					vim.keymap.set("n", "<Leader>f", function()
						vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 2000 })
						vim.cmd("write")
					end, { buffer = bufnr, desc = "LSP: Format and save" })
					vim.api.nvim_set_keymap('n', '<leader>do', '<cmd>lua vim.diagnostic.open_float()<CR>',
						{ noremap = true, silent = true })
					vim.api.nvim_set_keymap('n', '<leader>d[', '<cmd>lua vim.diagnostic.goto_prev()<CR>',
						{ noremap = true, silent = true })
					vim.api.nvim_set_keymap('n', '<leader>d]', '<cmd>lua vim.diagnostic.goto_next()<CR>',
						{ noremap = true, silent = true })
				end,
			})

			-- nvim-cmp setup
			local cmp = require("cmp")
			cmp.setup({
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "buffer" },
					{ name = "path" },
				},
			})
		end,
	},
}
