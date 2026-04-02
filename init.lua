
-- Copyright (C) 2026 Riccce-4s
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License.
-- [[ ========================================================================== ]]
-- [[  REDVIM V7 first beta                                                      ]]
-- [[                                                                            ]]
-- [[ ========================================================================== ]]

-- [ 1. BASIC OPTIONS & GLOBAL VARIABLES ]
-- =============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

opt.number = true
opt.relativenumber = false
opt.termguicolors = true
opt.cursorline = true
opt.laststatus = 3
opt.showmode = false
opt.clipboard = "unnamedplus"
opt.mouse = ""
opt.title = true
opt.titlestring = "REDVIM - %t"

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
opt.breakindent = true
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false

opt.ignorecase = true
opt.smartcase = true
opt.splitright = true
opt.splitbelow = true
opt.inccommand = "split"
opt.updatetime = 100
opt.scrolloff = 10
opt.sidescrolloff = 8

-- Декорации
opt.fillchars = { eob = " ", fold = " ", foldopen = "", foldsep = " ", foldclose = "" }
opt.signcolumn = "yes"

-- [ 2. BOOTSTRAP PLUGINS MANAGER ]
-- =============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- [ 3. BIG PLUGINS BLOCK ]
-- =============================================================================
require("lazy").setup({
    { "EdenEast/nightfox.nvim", config = function()
        require('nightfox').setup({
            options = {
                style = "carbonfox",
                transparent = true,
                terminal_colors = true,
                styles = { comments = "italic", keywords = "bold" }
            }
        })
        vim.cmd("colorscheme carbonfox")
    end },

    { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },

    -- DASHBOARD
    { 'goolord/alpha-nvim', config = function ()
        local dash = require('alpha.themes.dashboard')
        dash.section.header.val = {
            [[                                                             ]],
            [[        ██████╗ ███████╗██████╗ ██╗   ██╗██╗███╗   ███╗      ]],
            [[        ██╔══██╗██╔════╝██╔══██╗██║   ██║██║████╗ ████║      ]],
            [[        ██████╔╝█████╗  ██║  ██║██║   ██║██║██╔████╔██║      ]],
            [[        ██╔══██╗██╔════╝██║  ██║╚██╗ ██╔╝██║██║╚██╔╝██║      ]],
            [[        ██║  ██║███████╗██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║      ]],
            [[        ╚═╝  ╚═╝╚══════╝╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝      ]],
            [[                                                             ]],
            [[                                                             ]],
            [[                                                             ]],
        }
        dash.section.buttons.val = {
	    dash.button("n", "  NEW FILE", ":ene | startinsert<CR>"),
            dash.button("f", "󰈞  FIND FILES", ":Telescope find_files<CR>"),
            dash.button("g", "󰱼  LIVE GREP", ":Telescope live_grep<CR>"),
            dash.button("p", "󰄉  RECENT PROJECTS", ":Telescope oldfiles<CR>"),
            dash.button("s", "󰒲  LAZY SYSTEM", ":Lazy sync<CR>"),
            dash.button("c", "󰒓  CONFIG EDIT", ":e $MYVIMRC<CR>"),
            dash.button("q", "󰅚  TERMINATE", ":qa<CR>"),
        }
        vim.api.nvim_set_hl(0, "AlphaRed", { fg = "#FF0000", bold = true })
        dash.opts.opts.hl = "AlphaRed"
	dash.section.header.opts.hl = "AlphaRed"
	dash.section.buttons.opts.hl = "AlphaRed"
        require('alpha').setup(dash.opts)
    end },

    -- Treesitter
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", config = function()
        require('nvim-treesitter').setup({
            ensure_installed = { "lua", "python", "cpp", "c", "bash", "vim", "markdown", "json", "rust", "yaml", "toml" },
            highlight = { enable = true, additional_vim_regex_highlighting = false },
            indent = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<c-space>",
                    node_incremental = "<c-space>",
                    scope_incremental = "<c-s>",
                    node_decremental = "<M-space>",
                },
            },
        })
    end },

    -- LSP: Mason & Configs
    {
"neovim/nvim-lspconfig",
dependencies = {
"williamboman/mason.nvim",
"williamboman/mason-lspconfig.nvim",
"j-hui/fidget.nvim",
},
config = function()
require('mason').setup({
ui = { border = "rounded" },
})

require('mason-lspconfig').setup({
ensure_installed = { "lua_ls", "pyright", "clangd", "bashls" },
})


local capabilities = require('cmp_nvim_lsp').default_capabilities()


vim.lsp.config('lua_ls', {
capabilities = capabilities,
settings = {
Lua = {
diagnostics = { globals = { 'vim' } },
workspace = { checkThirdParty = false },
}
}
})
vim.lsp.enable('lua_ls')
end
},

    -- COMPLETION: nvim-cmp
     { "hrsh7th/nvim-cmp", dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets"
    }},

    -- TOOLS
    { "nvim-tree/nvim-tree.lua", opts = {
        view = { side = "left", width = 35 },
        renderer = { highlight_opened_files = "all", indent_markers = { enable = true } }
    }},

    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" }, config = function()
        local telescope = require('telescope')
        telescope.setup({
            defaults = {
                prompt_prefix = " RED > ",
                selection_caret = " 󰁔 ",
                path_display = { "smart" },
                mappings = { i = { ["<C-u>"] = false, ["<C-d>"] = false } }
            }
        })
    end },

    { "akinsho/toggleterm.nvim", version = "*", opts = {
        direction = "float",
        open_mapping = [[<C-\>]],
        shading_factor = 2,
        float_opts = { border = "curved", winblend = 0 }
    }},

    { "smoka7/hop.nvim", opts = { keys = 'etovxqpdygfblzhckisuran' } },
    { "lewis6991/gitsigns.nvim", opts = {
        current_line_blame = true,
        signs = {
            add = { text = '+' }, change = { text = '~' }, delete = { text = '_' },
        }
    }},
    { "windwp/nvim-autopairs", config = true },
    { "numToStr/Comment.nvim", config = true },
    { "folke/todo-comments.nvim", opts = { colors = { error = { "#FF0000" } } } },
    { "RRethy/vim-illuminate", config = function()
        require('illuminate').configure({ providers = { 'lsp', 'treesitter' } })
    end },
})

-- [ 4. ADVANCED LSP CONFIGURATION (0.11 NATIVE) ]
-- =============================================================================
require('fidget').setup({})
require('mason').setup({ ui = { border = "rounded", icons = { package_installed = "󰄬", package_pending = "󰄽", package_uninstalled = "󰅖" } } })
require('mason-lspconfig').setup({ ensure_installed = { "lua_ls", "pyright", "clangd", "bashls" } })

local capabilities = require('cmp_nvim_lsp').default_capabilities()
local on_attach = function(client, bufnr)
    local nmap = function(keys, func, desc)
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
    end
    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
end

-- 1. LUA_LS
vim.lsp.config('lua_ls', {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = { Lua = { diagnostics = { globals = { 'vim' } }, workspace = { checkThirdParty = false } } }
})
vim.lsp.enable('lua_ls')

-- 2. PYRIGHT (PYTHON)
vim.lsp.config('pyright', {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = { python = { analysis = { typeCheckingMode = "basic", autoSearchPaths = true, useLibraryCodeForTypes = true } } }
})
vim.lsp.enable('pyright')

-- 3. CLANGD (C++)
vim.lsp.config('clangd', {
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" }
})
vim.lsp.enable('clangd')

-- 4. BASHLS
vim.lsp.config('bashls', { on_attach = on_attach, capabilities = capabilities })
vim.lsp.enable('bashls')

-- [ 5. COMPLETION & SNIPPETS ENGINE ]
-- =============================================================================
local cmp = require('cmp')
local luasnip = require('luasnip')
require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
    snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
    window = {
        completion = cmp.config.window.bordered({ border = "single", winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None" }),
        documentation = cmp.config.window.bordered({ border = "single" }),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
        end, { 'i', 's' } ),
    }),
    sources = { { name = 'nvim_lsp' }, { name = 'luasnip' }, { name = 'buffer' }, { name = 'path' } }
})

-- [ 6. HOTKEYS SYSTEM (EXTENDED) ]
-- =============================================================================
local key = vim.keymap.set

key('n', '<C-h>', '<C-w>h')
key('n', '<C-j>', '<C-w>j')
key('n', '<C-k>', '<C-w>k')
key('n', '<C-l>', '<C-w>l')
key('n', '<leader>n', ':ene | startinsert<CR>', { desc = "New File" })

key('n', '<leader>w', ':w<CR>', { desc = "Save File" })
key('n', '<leader>q', ':q<CR>', { desc = "Quit" })
key('n', '<Tab>', ':bn<CR>', { desc = "Next Buffer" })
key('n', '<S-Tab>', ':bp<CR>', { desc = "Prev Buffer" })
key('n', '<leader>x', ':bd<CR>', { desc = "Close Buffer" })


key('n', '<leader>e', ':NvimTreeToggle<CR>')
key('n', '<leader>ff', ':Telescope find_files<CR>')
key('n', '<leader>fg', ':Telescope live_grep<CR>')
key('n', '<leader>fb', ':Telescope buffers<CR>')
key('n', 'f', ':HopWord<CR>')

-- [ 7. REDVIM DESIGN SYSTEM (BLOOD & CARBON) ]
-- =============================================================================
local function set_hl(group, opts) vim.api.nvim_set_hl(0, group, opts) end


set_hl("Normal", { bg = "NONE" })
set_hl("LineNr", { fg = "#440000" })
set_hl("CursorLineNr", { fg = "#FF0000", bold = true })
set_hl("Visual", { bg = "#660000" })
set_hl("Search", { fg = "#000000", bg = "#FF0000" })
set_hl("FloatBorder", { fg = "#FF0000" })
set_hl("WinSeparator", { fg = "#FF0000" })
set_hl("Pmenu", { bg = "#0d0d0d", fg = "#FF0000" })
set_hl("PmenuSel", { bg = "#FF0000", fg = "#000000" })

-- Lualine
require('lualine').setup({
    options = {
        theme = 'carbonfox',
        globalstatus = true,
        component_separators = '|',
        section_separators = '',
    },
    sections = {
        lualine_a = {{'mode', color = {bg = '#FF0000', fg = '#000000', gui = 'bold'}}},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {{'filename', path = 1, color = {fg = '#FF0000', gui = 'bold'}}},
        lualine_x = {'encoding', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
    }
})

-- Custom fuctions and commands
-- =============================================================================
local red_group = vim.api.nvim_create_augroup("RedVimAuto", { clear = true })


vim.api.nvim_create_autocmd("TextYankPost", {
    group = red_group,
    callback = function() vim.highlight.on_yank({ higroup = "Visual", timeout = 150 }) end,
})


vim.api.nvim_create_autocmd("TermClose", {
    group = red_group,
    callback = function() vim.cmd("bdelete!") end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = red_group,
    pattern = { "help", "alpha", "dashboard", "nvimtree", "toggleterm" },
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.cursorline = false
    end,
})
-- ==========================================================================
--  help
-- ==========================================================================

_G.RunCode = function()
    vim.cmd("silent! write")
    local file_extension = vim.fn.expand("%:e")
    if file_extension == "py" then vim.cmd("TermExec cmd='python3 %'")
    elseif file_extension == "cpp" then vim.cmd("TermExec cmd='g++ % -o %:r && ./%:r'")
    elseif file_extension == "c" then vim.cmd("TermExec cmd='gcc % -o %:r && ./%:r'")
    elseif file_extension == "lua" then vim.cmd("source %")
    elseif file_extension == "sh" then vim.cmd("TermExec cmd='bash %'")
    else print(">> REDVIM: Filetype not supported for auto-run") end
end
key('n', '<F5>', '<cmd>lua RunCode()<CR>', { desc = "Run Current File" })

_G.ToggleMouse = function()
    if vim.inspect(vim.opt.mouse:get()):find("a") then
        vim.opt.mouse = ""
        print(">> REDVIM: MOUSE DISABLED (KEYBOARD ONLY)")
    else
        vim.opt.mouse = "a"
        print(">> REDVIM: MOUSE ENABLED")
    end
end


key('n', '1', '<cmd>lua ToggleMouse()<CR>', { desc = "Toggle Mouse" })

vim.api.nvim_create_autocmd("BufWritePre", {
    group = red_group,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})


luasnip.add_snippets("cpp", {
    luasnip.snippet("redmain", {
        luasnip.text_node({ "#include <iostream>", "", "int main() {", "    std::cout << \"REDVIM ACTIVATED\" << std::endl;", "    " }),
        luasnip.insert_node(1, "// code"),
        luasnip.text_node({ "", "    return 0;", "}" })
    })
})

-- [ final
-- =============================================================================
print(">> REDVIM load")
print(">> ALL loading done!")

