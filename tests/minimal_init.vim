" Avoid neovim/neovim#11362
set display=lastline
set directory=""
set noswapfile

let $mason = getcwd()
let $test_helpers = getcwd() .. "/tests/helpers"
let $dependencies = getcwd() .. "/dependencies"

set rtp^=$mason,$test_helpers
set packpath=$dependencies

packloadall

lua require("luassertx")
lua require("test_helpers")

lua <<EOF
vim.lsp.config("dummylsp", {
    cmd = { "dummylsp" },
    filetypes = { "dummylang" }
})
vim.lsp.config("dummy2lsp", {
    cmd = { "dummy2lsp" },
})
vim.lsp.config("fail_dummylsp", {
    cmd = { "fail_dummylsp" }
})

require("mason").setup {
    install_root_dir = vim.env.INSTALL_ROOT_DIR,
    registries = {
        "lua:dummy-registry.index"
    }
}

require("mason-registry").refresh()
EOF

function! RunTests() abort
    lua <<EOF
    require("plenary.test_harness").test_directory(os.getenv("FILE") or "./tests", {
        minimal_init = vim.fn.getcwd() .. "/tests/minimal_init.vim",
        sequential = true,
    })
EOF
endfunction
