-- init.lua
vim.opt.rtp:prepend("~/.config/nvim/lazy")

vim.opt.number = true                -- show line numbers
vim.opt.relativenumber = false       -- no relative numbers to keep it simple
vim.opt.expandtab = true             -- use spaces, not tabs
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 5
vim.opt.isfname:append("@-@")        -- allow @ in file names

-- Keep mappings empty: do not add leader or convenience keybindings
-- The only mapping added is to let ":" in Insert mode open the command-line.
-- This preserves the "press : to run commands" workflow while keeping you
-- in editing mode by default.
vim.keymap.set('i', ':', '<C-o>:', { noremap = true, silent = true })

-- Basic options (keep your other options if present)
vim.opt.number = true
vim.opt.termguicolors = true

-- Start insert for regular files when a buffer is ready
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype
    -- skip special filetypes; extend this list if needed
    local skip = { "oil", "nerdtree", "help", "alpha", "dashboard" }
    for _, s in ipairs(skip) do
      if ft == s then return end
    end
    -- only startinsert for real file buffers (not prompts, terminals, etc.)
    if vim.bo[ev.buf].buftype == "" then
      pcall(vim.cmd, "startinsert")
    end
  end,
})

-- Ensure Oil buffers are in Normal mode when opened
vim.api.nvim_create_autocmd("FileType", {
  pattern = "oil",
  callback = function()
    -- stopinsert is safe even if not inserted
    pcall(vim.cmd, "stopinsert")
  end,
})

-- Insert-mode ':' mapping:
-- - If in an Oil buffer (or excluded types) just insert a literal ':'.
-- - Otherwise open command-line like <C-o>: without inserting an extra colon.
vim.keymap.set("i", ":", function()
  local ft = vim.bo.filetype
  local exclude = { "oil", "terminal", "prompt", "TelescopePrompt" }
  for _, s in ipairs(exclude) do
    if ft == s then
      return ":"  -- behave like normal insert for these buffers
    end
  end
  -- Feed <C-o>: into the input stream and return empty so no extra ":" is inserted
  local keys = vim.api.nvim_replace_termcodes("<C-o>:", true, false, true)
  vim.api.nvim_feedkeys(keys, "n", true)
  return ""
end, { expr = true, noremap = true, silent = true })

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map('i', '<C-.>', '<C-V>:', opts)
-- Insert mode: use <C-o> to run a single normal command then return to insert
map('i', '<C-z>', '<C-o>u', opts)
map('i', '<C-S-z>', '<C-o><C-r>', opts)
-- Insert mode: temporarily drop to Normal to start/extend visual selection
map('i', '<S-Right>', '<C-o>v l', opts)
map('i', '<S-Left>',  '<C-o>v h', opts)
map('i', '<S-Down>',  '<C-o>v j', opts)
map('i', '<S-Up>',    '<C-o>v k', opts)

require("lazy").setup({
  { "stevearc/oil.nvim",
  opts = {
      view_options = {
        show_hidden = false,
      },
    },
  },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
})
