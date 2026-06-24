vim.filetype.add({
	pattern = {
		[".*%.tmpl"] = function(path)
			local stripped = path:gsub("%.tmpl$", "")
			local ft = vim.filetype.match({ filename = stripped })
			if not ft then
				local dir = vim.fn.fnamemodify(stripped, ":h")
				local base = vim.fn.fnamemodify(stripped, ":t"):gsub("^dot_", ".")
				ft = vim.filetype.match({ filename = dir .. "/" .. base })
			end
			return ft
		end,
	},
})
