local rg = { "rg", "--vimgrep", "--smart-case", "--hidden" }

-- Keep :grep working by hand; the mapping below deliberately bypasses it.
vim.opt.grepprg = table.concat(rg, " ")
vim.opt.grepformat = "%f:%l:%c:%m"

vim.keymap.set("n", "<leader>fg", function()
    vim.ui.input({ prompt = "Grep: " }, function(pattern)
        if not pattern or pattern == "" then
            return
        end

        -- Run rg directly rather than through ":grep <pattern>". Building that
        -- string means the pattern is parsed twice -- once by Vim's command
        -- line, then by the shell -- and no escaping survives both: "|" ends
        -- the :grep command whatever it's quoted with, and "%" expands to the
        -- current file. Passing argv avoids both parsers entirely. "-e" keeps
        -- a pattern starting with "-" from being read as a flag.
        local cmd = vim.list_extend(vim.list_slice(rg, 1, #rg), { "-e", pattern })

        vim.system(cmd, { text = true }, function(res)
            local lines = vim.split(res.stdout or "", "\n", { trimempty = true })
            vim.schedule(function()
                if res.code > 1 then -- 1 just means no matches
                    vim.notify(vim.trim(res.stderr or "rg failed"), vim.log.levels.ERROR)
                    return
                end
                if #lines == 0 then
                    vim.notify("No match: " .. pattern, vim.log.levels.WARN)
                    return
                end
                local items = vim.fn.getqflist({ lines = lines, efm = vim.o.grepformat }).items
                vim.fn.setqflist({}, " ", { title = "rg " .. pattern, items = items })
                vim.cmd("copen")
            end)
        end)
    end)
end, { silent = true, noremap = true })

-- Close the quickfix list once a result is selected
vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function(args)
        vim.keymap.set("n", "<CR>", "<CR><cmd>cclose<CR>",
            { buffer = args.buf, silent = true, noremap = true })
    end,
})


local ignore_dirs = { ".git", "node_modules", ".cache", "dist", "build", "target" }

-- 'findfunc' is called synchronously on every completion request, so walking the
-- tree per keystroke is not affordable. Listing is delegated to rg (which also
-- honours .gitignore) and memoised per cwd; the fuzzy match runs on the cache.
local file_cache = { cwd = nil, files = nil }

local function list_files()
    local cmd = { "rg", "--files", "--hidden" }
    for _, dir in ipairs(ignore_dirs) do
        -- Anchored to whole path segments, so a directory named "build" is
        -- skipped but a file named "rebuild.lua" is not.
        table.insert(cmd, "--glob=!**/" .. dir .. "/**")
    end

    local res = vim.system(cmd, { text = true }):wait()
    if res.code > 1 then
        -- rg missing or erroring: fall back to a plain walk rather than
        -- leaving :find with nothing to complete.
        return vim.fn.getcompletion("**/*", "file", true)
    end
    return vim.split(res.stdout or "", "\n", { trimempty = true })
end

local function project_files()
    local cwd = vim.uv.cwd()
    if file_cache.cwd ~= cwd or not file_cache.files then
        file_cache = { cwd = cwd, files = list_files() }
    end
    return file_cache.files
end

local function invalidate()
    file_cache = { cwd = nil, files = nil }
end

-- The listing goes stale when files appear from outside this Neovim.
vim.api.nvim_create_autocmd({ "DirChanged", "FocusGained" }, {
    group = vim.api.nvim_create_augroup("FindCache", { clear = true }),
    callback = invalidate,
})
vim.api.nvim_create_user_command("FindRefresh", invalidate, { desc = "Drop the :find file cache" })

function _G.native_find(text, _)
    local files = project_files()
    if text == "" then
        return files
    end
    return vim.fn.matchfuzzy(files, text)
end

vim.opt.findfunc = "v:lua.native_find"
vim.keymap.set("n", "<leader>ff", ":find ", {silent = false, noremap = true })




