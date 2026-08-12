-- FILE HANDLING SETTINGS -
vim.g.netrw_liststyle = 3
vim.g.netrw_bufsettings = 'noma nomod rnu nobl nowrap ro'
vim.g.netrw_winsize = 25     -- sidebar takes 25% of the width
vim.g.netrw_browse_split = 4 -- <CR> opens the file back in the previous window
vim.g.netrw_banner = 0

-- Is the Lexplore sidebar currently up? netrw tracks it per-tab, so use its own
-- bookkeeping rather than scanning windows -- that keeps :Lexplore's internal
-- toggle state and ours from drifting apart.
local function lex_win()
  local bufnr = vim.t.netrw_lexbufnr
  if not bufnr or vim.fn.bufexists(bufnr) == 0 then
    return nil
  end
  local win = vim.fn.bufwinid(bufnr)
  return win ~= -1 and win or nil
end

-- Park the cursor on `name` inside the netrw listing. Tree view (liststyle 3)
-- indents entries with "| ", and netrw suffixes them with */@/ for
-- executables, symlinks and directories, so match on the trailing segment
-- instead of the whole line.
local function focus_entry(name)
  if name == '' then
    return
  end
  for i, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    local entry = line:gsub('[*@/]$', '')
    if entry:sub(-#name) == name then
      local prev = entry:sub(-#name - 1, -#name - 1)
      -- Guard against "init.lua" landing on "min-init.lua".
      if prev == '' or prev == ' ' or prev == '|' or prev == '/' then
        pcall(vim.api.nvim_win_set_cursor, 0, { i, 0 })
        return
      end
    end
  end
end

-- Open netrw on the left, rooted at the current file's directory and with the
-- cursor already on that file. Closing goes through :Lexplore so netrw gets to
-- restore the window layout it saved on open.
local function toggle()
  if lex_win() then
    vim.cmd('Lexplore')
    return
  end

  local path = vim.api.nvim_buf_get_name(0)
  local dir = path ~= '' and vim.fn.fnamemodify(path, ':p:h') or vim.uv.cwd()
  local name = vim.fn.fnamemodify(path, ':t')

  vim.cmd('Lexplore ' .. vim.fn.fnameescape(dir))
  focus_entry(name)
end

-- netrw keeps the sidebar open after <CR> by design, so wrap its own mapping:
-- run the normal browse, then dismiss the sidebar if we landed on a file.
-- Directories leave us in a netrw buffer, so the sidebar stays put for those.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('NetrwSidebar', { clear = true }),
  pattern = 'netrw',
  callback = function(args)
    vim.keymap.set('n', '<CR>', function()
      -- 'x' drains the typeahead before returning, so netrw has finished
      -- opening the file by the time we check what buffer we're in.
      vim.api.nvim_feedkeys(vim.keycode('<Plug>NetrwLocalBrowseCheck'), 'mx', false)
      if vim.bo.filetype ~= 'netrw' and lex_win() then
        vim.cmd('Lexplore')
      end
    end, { buffer = args.buf, silent = true, desc = 'Open entry, closing the sidebar for files' })
  end,
})

vim.keymap.set('n', '<leader>fe', toggle, { desc = 'Toggle netrw sidebar at current file' })
vim.api.nvim_create_user_command('Sidebar', toggle, { desc = 'Toggle netrw sidebar at current file' })
