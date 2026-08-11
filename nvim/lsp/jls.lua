return {
    cmd = { 'jls' },
    cmd_env = { JLS_LOG = 'debug' },
    filetypes = { 'java' },
    root_markers = {
        'pom.xml',
        '.git'
    },
    settings = {
        jls = {
            diagnostics = {
                unused = true,
                unresolvedTypes = false,
            },
        },
    },
}
