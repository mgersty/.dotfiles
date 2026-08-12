--- HELPFUL FUNCTIONS ---
local augroup = vim.api.nvim_create_augroup("UserConfig", {})

-- Per-filetype indent width. Anything not listed keeps the global width set in
-- config.lua.
local indent_width = {}
for width, filetypes in pairs({
    [4] = { "lua", "python", "java" },
    [2] = { "javascript", "typescript", "json", "xml", "html", "css" },
}) do
    for _, ft in ipairs(filetypes) do
        indent_width[ft] = width
    end
end

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = vim.tbl_keys(indent_width),
    callback = function(args)
        local width = indent_width[args.match]
        vim.opt_local.tabstop = width
        vim.opt_local.shiftwidth = width
        -- Also softtabstop, or <BS> keeps stepping by the global width and
        -- disagrees with the indent size in every buffer listed above.
        vim.opt_local.softtabstop = width
    end,
})

local skip_cursor_restore = {
	gitcommit = true,
}

vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	callback = function(args)
		-- Git reuses one COMMIT_EDITMSG per repo, so the stored mark points at
		-- wherever the last message ended -- always start these at the top.
		if skip_cursor_restore[vim.bo[args.buf].filetype] then
			return
		end

		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(args.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			vim.api.nvim_win_set_cursor(0, mark)
			-- defer centering slightly so it's applied after render
			vim.schedule(function()
				vim.cmd("normal! zz")
			end)
		end
	end,
})
