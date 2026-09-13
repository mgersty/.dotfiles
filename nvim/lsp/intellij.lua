-- IntelliJ Language Server (JetBrains, product code ILS).
--
-- Two things are mandatory or the server is useless:
--   * eulaHash      -- initialize is rejected outright without it.
--   * buildTools    -- without it the project is never imported, so you get
--                      hover and completion but *zero* diagnostics.
-- buildTools is keyed by project URI, which isn't known until root_dir is
-- resolved, so it's filled in from before_init rather than init_options.
--
-- The hash is the digest of ~/.local/share/intellij-server/EULA.txt and pins a
-- specific build; after upgrading the server the rejection message reports the
-- new expected value.

local install = vim.fn.expand('$HOME/.local/share/intellij-server')

-- Code actions from this server aren't WorkspaceEdits. Every one of them is the
-- single command `applyModCommand`, carrying IntelliJ's own ModCommand payload
-- as its argument. Running it server-side is a no-op that returns `true`: the
-- server never sends workspace/applyEdit and never touches the file, because it
-- expects the client to apply the payload. Without the handler below every code
-- action silently does nothing.
--
-- `kind` is the JVM class name; the variant is the part after the last dot.
local function apply_mod_command(data, offset_encoding)
    local kind = tostring(data.kind or ''):match('([^.]+)$')

    if kind == 'Composite' then
        for _, sub in ipairs(data.commands or {}) do
            apply_mod_command(sub, offset_encoding)
        end
    elseif kind == 'UpdateFileText' then
        -- Whole-file replacement. Routed through apply_text_edits rather than
        -- nvim_buf_set_lines so cursor position and marks survive.
        local bufnr = vim.uri_to_bufnr(data.fileUrl)
        vim.fn.bufload(bufnr)
        vim.lsp.util.apply_text_edits({
            {
                range = {
                    start = { line = 0, character = 0 },
                    ['end'] = { line = vim.api.nvim_buf_line_count(bufnr), character = 0 },
                },
                newText = data.newText,
            },
        }, bufnr, offset_encoding)
    elseif kind == 'CreateFile' then
        local path = vim.uri_to_fname(data.fileUrl)
        local content = data.content or {}
        if tostring(content.kind or ''):match('([^.]+)$') == 'Directory' then
            vim.fn.mkdir(path, 'p')
        else
            vim.fn.mkdir(vim.fs.dirname(path), 'p')
            local bufnr = vim.uri_to_bufnr(data.fileUrl)
            vim.fn.bufload(bufnr)
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false,
                vim.split(content.text or '', '\n', { plain = true }))
            vim.api.nvim_buf_call(bufnr, function() vim.cmd.write({ mods = { silent = true } }) end)
        end
    elseif kind == 'DeleteFile' then
        local path = vim.uri_to_fname(data.fileUrl)
        local bufnr = vim.fn.bufnr(path)
        if bufnr ~= -1 then
            vim.api.nvim_buf_delete(bufnr, { force = true })
        end
        vim.fn.delete(path, 'rf')
    elseif kind == 'MoveFile' then
        vim.lsp.util.rename(vim.uri_to_fname(data.fileUrl), vim.uri_to_fname(data.targetUrl))
    elseif kind == 'Navigate' then
        local bufnr = vim.uri_to_bufnr(data.fileUrl)
        vim.fn.bufload(bufnr)
        vim.api.nvim_win_set_buf(0, bufnr)
        if data.caret then
            -- ModCommand carries a flat character offset into the file, not a
            -- line/character pair, so convert it through the byte index.
            local line = vim.fn.byte2line(data.caret + 1)
            if line > 0 then
                local col = data.caret + 1 - vim.fn.line2byte(line)
                vim.api.nvim_win_set_cursor(0, { line, math.max(0, col) })
            end
        end
    elseif kind == 'DisplayMessage' then
        vim.notify(data.message or '', data.messageKind == 'ERROR'
            and vim.log.levels.ERROR or vim.log.levels.INFO)
    elseif kind == 'Nothing' then
        -- nothing to do
    else
        -- Snippet/SnippetVar are template-driven refactorings; they need a
        -- snippet engine to be meaningful, so surface rather than silently drop.
        vim.notify('intellij: unhandled ModCommand ' .. tostring(data.kind), vim.log.levels.WARN)
    end
end

return {
    cmd = {
        install .. '/bin/intellij-server',
        '--stdio',
        -- Without this the JVM picks a fresh /tmp/idea-system<random> each run
        -- and re-indexes the JDK from scratch on every launch.
        '--system-path', vim.fn.stdpath('cache') .. '/intellij-server',
        '--log-level', 'WARNING',
    },
    cmd_env = {
        -- Bundled default is -Xmx2048m, which is tight for a real project.
        IJ_JAVA_OPTIONS = '-Xmx4g',
    },
    filetypes = { 'java', 'kotlin' },
    root_markers = {
        'workspace.json',       -- exported model, for unsupported build systems
        'MODULE.bazel',
        'WORKSPACE.bazel',
        'WORKSPACE',
        'settings.gradle',      -- Gradle multi-project: outermost dir wins
        'settings.gradle.kts',
        'pom.xml',
        'build.gradle',
        'build.gradle.kts',
        '.git',
    },
    init_options = {
        eulaHash = '34d850193ee04897',
    },
    commands = {
        applyModCommand = function(command, ctx)
            local client = vim.lsp.get_client_by_id(ctx.client_id)
            for _, arg in ipairs(command.arguments or {}) do
                apply_mod_command(arg, client and client.offset_encoding or 'utf-16')
            end
        end,
    },
    handlers = {
        -- Buffers are opened long before the build import and indexing finish,
        -- so the server's one-and-only push of diagnostics is computed against
        -- an empty project model and comes back empty. It never re-publishes,
        -- and it doesn't send workspace/diagnostic/refresh either -- the only
        -- "I'm ready" signal is this notification. Re-pull on it, or Java
        -- buffers stay silently diagnostic-free for the whole session.
        ['intellij/ready-for-test'] = function(_, _, ctx)
            vim.lsp.diagnostic.on_refresh(nil, nil, ctx)
        end,
    },
    before_init = function(params, config)
        local root = config.root_dir
        if not root then
            return
        end
        params.initializationOptions = params.initializationOptions or {}
        -- '*' = try every importer; 'maven'/'gradle' pin one, '' skips import.
        params.initializationOptions.buildTools = { [vim.uri_from_fname(root)] = '*' }
        -- Keep the index next to the caches instead of the default temp dir.
        params.initializationOptions.indexDir =
            vim.fn.stdpath('cache') .. '/intellij-server/index/' .. vim.fn.sha256(root)
    end,
}
