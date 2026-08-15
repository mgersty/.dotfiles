-- Readable LSP logs.
--
-- The stock formatter writes one `vim.inspect` blob per entry with newlines
-- squashed out, so a single `initialize` can be a 30KB line, `tail` shows you
-- one useless record, and the Lua table syntax doesn't match the JSON you see
-- in the LSP spec. This rewrites entries as:
--
--   14:22:07.431 DEBUG [intellij] --> req  #12 textDocument/hover {"position":...}
--   14:22:07.462 DEBUG [intellij] <-- resp #12 {"contents":...}
--   14:22:09.118 ERROR [jls]      stderr  INFO jls ready
--
-- One line per entry, so the log stays greppable. Payloads are JSON, and the
-- two known monsters (the client capabilities we send on initialize, and the
-- whole-client dump on exit) are elided rather than truncated blindly, so what
-- survives is the part worth reading.

local log = vim.lsp.log

-- Longest a single rendered argument may get before it's cut. Backstop only:
-- the payloads that actually blow up the log are elided by name below.
local MAX_ARG = 700

local function truncate(s)
    if #s <= MAX_ARG then
        return s
    end
    return s:sub(1, MAX_ARG) .. ('…[+%d chars]'):format(#s - MAX_ARG)
end

local function render(v)
    if type(v) == 'string' then
        -- Embedded newlines would break one-entry-per-line; servers put whole
        -- stack traces in window/logMessage.
        return (v:gsub('%s+$', ''):gsub('\n', '\\n'))
    end
    if type(v) ~= 'table' then
        return tostring(v)
    end
    -- Fails on functions and cycles, which is exactly what the client-object
    -- dumps are made of; fall back to a shallow inspect for those.
    local ok, json = pcall(vim.json.encode, v)
    if ok then
        return json
    end
    return vim.inspect(v, { newline = ' ', indent = '', depth = 2 })
end

--- Strip the parts of an RPC payload that are enormous and never interesting.
local function elide(payload)
    local params = payload.params
    if payload.method == 'initialize' and type(params) == 'table' and params.capabilities then
        payload = vim.tbl_extend('force', {}, payload)
        payload.params = vim.tbl_extend('force', {}, params)
        payload.params.capabilities = '<elided>'
    end
    return payload
end

--- Turn an RPC payload into "kind #id method" plus the interesting half.
---@return string? tag, any body
local function rpc(payload)
    if type(payload) ~= 'table' then
        return nil
    end
    local id = payload.id and ('#' .. tostring(payload.id)) or ''
    if payload.method and payload.id then
        return ('req  %s %s'):format(id, payload.method), elide(payload).params
    elseif payload.method then
        return ('notif   %s'):format(payload.method), payload.params
    elseif payload.error then
        return ('err  %s'):format(id), payload.error
    else
        return ('resp %s'):format(id), payload.result
    end
end

log.set_format_func(function(level, ...)
    -- The default formatter does its own level check, so a replacement has to
    -- as well or set_level() silently stops filtering anything.
    if log.levels[level] < log.get_level() then
        return nil
    end

    local sec, usec = vim.uv.gettimeofday()
    local parts = {
        ('%s.%03d %-5s'):format(os.date('%H:%M:%S', sec), math.floor(usec / 1000), level),
    }

    local args = { n = select('#', ...), ... }
    local i = 1

    -- Client-scoped entries lead with "LSP[name]"; lift it into a column.
    local first = args[1]
    local client = type(first) == 'string' and first:match('^LSP%[(.+)%]$')
    if client then
        i = 2
    end

    local tag = args[i]
    if (tag == 'rpc.send' or tag == 'rpc.receive') and args.n >= i + 1 then
        local arrow = tag == 'rpc.send' and '-->' or '<--'
        local kind, body = rpc(args[i + 1])
        if kind then
            -- rpc.lua logs the raw payload with no client identity attached, so
            -- there is nothing to put in the client column here.
            if client then
                table.insert(parts, ('[%s]'):format(client))
            end
            table.insert(parts, ('%s %s'):format(arrow, kind))
            if body ~= nil then
                table.insert(parts, truncate(render(body)))
            end
            return table.concat(parts, ' ') .. '\n'
        end
    elseif tag == 'rpc' and args[i + 2] == 'stderr' then
        -- _transport.lua logs every server stderr chunk at ERROR; these are
        -- usually just the server's own INFO logging, so flatten them.
        -- The name here is cmd[1], often an absolute path.
        table.insert(parts, ('[%s]'):format(vim.fs.basename(tostring(args[i + 1]))))
        table.insert(parts, 'stderr')
        table.insert(parts, render(args[i + 3]))
        return table.concat(parts, ' ') .. '\n'
    end

    if client then
        table.insert(parts, ('[%s]'):format(client))
    end
    for j = i, args.n do
        table.insert(parts, truncate(render(args[j])))
    end
    return table.concat(parts, ' ') .. '\n'
end)
