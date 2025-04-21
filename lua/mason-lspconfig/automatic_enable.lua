local _ = require "mason-core.functional"
local mappings = require "mason-lspconfig.mappings"
local registry = require "mason-registry"
local settings = require "mason-lspconfig.settings"

---@param mason_pkg string
local function setup_server(mason_pkg)
    local lspconfig_name = mappings.get_mason_map().package_to_lspconfig[mason_pkg]
    if not lspconfig_name then
        return
    end

    -- We don't provide LSP configurations in the lsp/ directory because it risks overriding configurations in a way the
    -- user doesn't want. Instead we only override LSP configurations for servers that are installed via Mason.
    local ok, config = pcall(require, ("mason-lspconfig.lsp.%s"):format(lspconfig_name))
    if ok then
        vim.lsp.config(lspconfig_name, config)
    end

    if settings.current.automatic_enable then
        vim.lsp.enable(lspconfig_name)
    end
end

_.each(setup_server, registry.get_installed_package_names())

registry:on(
    "package:install:success",
    vim.schedule_wrap(function(pkg)
        setup_server(pkg.name)
    end)
)
