local M = {}

---@class MasonLspconfigSettings
local DEFAULT_SETTINGS = {
    -- A list of servers to automatically install if they're not already installed. Example: { "rust_analyzer@nightly", "lua_ls" }
    ---@type string[]
    ensure_installed = {},

    -- See `:h mason-lspconfig.setup_handlers()`
    ---@type table<string, fun(server_name: string)>?
    handlers = nil,
}

M._DEFAULT_SETTINGS = DEFAULT_SETTINGS
M.current = M._DEFAULT_SETTINGS

---@param opts MasonLspconfigSettings
function M.set(opts)
    M.current = vim.tbl_deep_extend("force", M.current, opts)
end

return M
