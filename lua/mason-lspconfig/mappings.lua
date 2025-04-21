local _ = require "mason-core.functional"
local registry = require "mason-registry"

local M = {}

---Returns a map of language (lowercased) to one or more corresponding Mason package names.
---@return table<string, string[]>
function M.get_language_map()
    if not registry.get_all_package_specs then
        return {}
    end
    ---@type table<string, string[]>
    local languages = {}
    for _, pkg_spec in ipairs(registry.get_all_package_specs()) do
        for _, language in ipairs(pkg_spec.languages) do
            language = language:lower()
            if not languages[language] then
                languages[language] = {}
            end
            table.insert(languages[language], pkg_spec.name)
        end
    end
    return languages
end

function M.get_mason_map()
    if not registry.get_all_package_specs then
        return {
            lspconfig_to_package = {},
            package_to_lspconfig = {},
        }
    end

    ---@type table<string, string>
    local package_to_lspconfig = {}
    for _, pkg_spec in ipairs(registry.get_all_package_specs()) do
        local lspconfig = vim.tbl_get(pkg_spec, "neovim", "lspconfig")
        if lspconfig then
            package_to_lspconfig[pkg_spec.name] = lspconfig
        end
    end

    return {
        package_to_lspconfig = package_to_lspconfig,
        lspconfig_to_package = _.invert(package_to_lspconfig),
    }
end

function M.get_filetype_map()
    local server_names = vim.tbl_keys(M.get_mason_map().lspconfig_to_package)

    ---@type table<string, string[]>
    local filetype_map = {}
    for _, server_name in ipairs(server_names) do
        local filetypes = vim.tbl_get(vim.lsp.config, server_name, "filetypes")
        if filetypes then
            for _, filetype in ipairs(filetypes) do
                if not filetype_map[filetype] then
                    filetype_map[filetype] = {}
                end
                table.insert(filetype_map[filetype], server_name)
            end
        end
    end
    return filetype_map
end

function M.get_all()
    local mason_map = M.get_mason_map()
    return {
        filetypes = M.get_filetype_map(),
        languages = M.get_language_map(),
        lspconfig_to_package = mason_map.lspconfig_to_package,
        package_to_lspconfig = mason_map.package_to_lspconfig,
    }
end

return M
