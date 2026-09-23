--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

What is Kickstart?

  Kickstart.nvim is *not* a distribution.

  Kickstart.nvim is a starting point for your own configuration.
    The goal is that you can read every line of code, top-to-bottom, understand
    what your configuration is doing, and modify it to suit your needs.

    Once you've done that, you can start exploring, configuring and tinkering to
    make Neovim your own! That might mean leaving kickstart just the way it is for a while
    or immediately breaking it into modular pieces. It's up to you!

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:

  TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

    If you don't know what this means, type the following:
      - <escape key>
      - :
      - Tutor
      - <enter key>

    (If you already know how the Neovim basics, you can skip this step)

  Once you've completed that, you can continue working through **AND READING** the rest
  of the kickstart init.lua

  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    This should be the first place you go to look when you're stuck or confused
    with something. It's one of my favorite neovim features.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not sure exactly what you're looking for.

  I have left several `:help X` comments throughout the init.lua
    These are hints about where to find more information about the relevant settings,
    plugins or neovim features used in kickstart.

   NOTE: Look for lines like this

    Throughout the file. These are for you, the reader, to help understand what is happening.
    Feel free to delete them once you know what you're doing, but they should serve as a guide
    for when you are first encountering a few different constructs in your nvim config.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now! :)
--]]

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true
vim.opt.breakindent = true
vim.opt.fillchars:append { diff = '╱' }
vim.opt.foldlevel = 99
vim.opt.inccommand = 'split'
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.mouse = 'a'
vim.opt.number = true
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.scrolloff = 1
vim.opt.sidescroll = 1
vim.opt.sidescrolloff = 2
vim.opt.signcolumn = 'yes'
vim.opt.swapfile = false

vim.api.nvim_create_autocmd('TermResponse', {
  group = vim.api.nvim_create_augroup('detect-osc52', { clear = true }),
  callback = function(ev)
    local resp = ev.data.sequence

    -- Match Primary Device Attributes (DA1) response: \027[?<params>c
    local params = resp:match '^\027%[%?([%d;]+)c$'
    if params then
      for code in params:gmatch '%d+' do
        if code == '52' then
          local function paste()
            return {
              vim.fn.split(vim.fn.getreg '', '\n'),
              vim.fn.getregtype '',
            }
          end
          vim.g.clipboard = {
            name = 'OSC 52',
            copy = {
              ['+'] = require('vim.ui.clipboard.osc52').copy '+',
              ['*'] = require('vim.ui.clipboard.osc52').copy '*',
            },
            -- Some terminals don't support pasting via OSC 52,
            -- so we use the default clipboard provider for pasting.
            paste = {
              ['+'] = paste,
              ['*'] = paste,
            },
          }
          vim.opt.clipboard = 'unnamedplus'
          return true -- Deletes this autocmd
        end
      end
    end
  end,
})

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Search ignoring case explicitly
vim.keymap.set('n', '/', '/\\c', { silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set(
  'n',
  '<leader>e',
  vim.diagnostic.open_float,
  { desc = 'Show diagnostic [E]rror messages' }
)
vim.keymap.set(
  'n',
  '<leader>q',
  vim.diagnostic.setloclist,
  { desc = 'Open diagnostic [Q]uickfix list' }
)

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

--- Better soft wraps for text files
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'text', 'org' },
  callback = function()
    vim.opt_local.breakindent = true
    vim.opt_local.linebreak = true
    vim.opt_local.briopt:append 'list:-1'
  end,
})

-- Set filetype for `.bb` files to `clojure`
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { '*.bb' },
  callback = function()
    vim.opt_local.filetype = 'clojure'
  end,
})

local codecompanion_chat_system_prompt = [[Chat client: Neovim (%s) on %s OS. CWD: `%s`. Date: %s.
Style
- Follow user requirements carefully and to the letter.
- Short answers. Markdown only; no H1/H2 headers; no full-response triple-backtick wrapping.
- All non-code text in %s. Use OS-specific commands where applicable.

Behavior
- Contradictions: Flag when your response differs from earlier decisions, recommendations, or assumptions made in this session.
- Consistency: Be consistent in your word choices and style.
- Uncertainty: Admit uncertainty rather than hallucinate when information is missing or unverified.

**Code blocks** — 4 backticks, language ID, `{file/path}`:
````lang {path/to/file}
// ...existing code...
// changed code
// ...existing code...
````
Use appropriate comment syntax for `...existing code...`. No diff formatting or line numbers unless asked.

Tasks
1. Think step-by-step; describe the plan first for complex/architectural changes.
2. Include only relevant code — omit unchanged sections.
3. End with a short suggestion for the next user turn.
]]

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  { -- Browse diffs in a tab
    'dlyongemallo/diffview-plus.nvim',
    version = '*',
    opts = {
      auto_close_on_empty = true,
      clean_up_buffers = true,
      diffopt = { algorithm = 'histogram' },
      enhanced_diff_hl = true,
      file_panel = {
        win_config = {
          win_opts = {
            linebreak = true,
            wrap = true,
          },
        },
      },
      view = {
        default = { layout = 'diff1_inline' },
        cycle_layouts = {
          default = { 'diff1_inline', 'diff2_horizontal' },
        },
      },
    },
    config = function(_, opts)
      require('diffview').setup(opts)
      vim.keymap.set(
        'n',
        '<leader>dO',
        ':DiffviewOpen --imply-local ',
        { desc = '[D]iffview [O]open (with args)' }
      )
    end,
  },
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  { -- Colorscheme
    'EdenEast/nightfox.nvim',
    lazy = false, -- Don't lazy load
    priority = 1000, -- Load first
    config = function()
      require('nightfox').setup {
        groups = {
          all = {
            DiffChange = { bg = '#002249' },
            DiffDelete = { bg = '#69002e' },
            DiffAdd = { bg = '#004c2b' },
            DiffText = { bg = '#005582' },
          },
        },
      }
      vim.cmd.colorscheme 'nightfox'
    end,
  },
  'famiu/bufdelete.nvim', -- Delete buffers while keeping layout
  { -- Set `commentstring` based on the treesitter
    'JoosepAlviste/nvim-ts-context-commentstring',
    dependencies = {
      'tpope/vim-commentary',
    },
  },
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  { -- Highlight todo, notes, etc in comments
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default whick-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      -- Document existing key chains
      spec = {
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },
  {
    'github/copilot.vim',
    event = 'VeryLazy',
    init = function()
      -- Disable copilot in every buffer by default but enable Copilot if file
      -- is trackable by git. We assume that if a file can be commited to a
      -- repository, it should not contain secrets to be leaked to Copilot API.
      vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
        group = vim.api.nvim_create_augroup('copilot-disable', { clear = true }),
        pattern = '*',
        callback = function(args)
          vim.b.copilot_enabled = false
          local path = vim.fn.expand(args.file)
          if path == '' or vim.fn.filereadable(path) == 0 then
            vim.b.copilot_enabled = true
            return -- Use default settings for unsaved or non-existent files
          end
          if vim.fn.executable 'git' == 1 then
            local dir = vim.fn.fnamemodify(path, ':h')
            vim.fn.jobstart({ 'git', '-C', dir, 'rev-parse', '--show-toplevel' }, {
              on_exit = function(_, non_git_repo)
                if non_git_repo ~= 0 then
                  -- Not in a git repo, do not enable Copilot
                  return
                end
                vim.fn.jobstart({ 'git', 'check-ignore', '--quiet', '--', path }, {
                  on_exit = function(_, is_ignored)
                    if is_ignored ~= 0 then
                      -- Enable Copilot in main thread
                      vim.schedule(function()
                        vim.b[args.buf].copilot_enabled = true
                      end)
                    end
                  end,
                })
              end,
            })
          end
        end,
      })

      if vim.env.COPILOT_PROXY then
        vim.g.copilot_proxy = vim.env.COPILOT_PROXY
      end
      if vim.env.COPILOT_STRICT_SSL then
        vim.g.copilot_proxy_strict_ssl = vim.env.COPILOT_PROXY_STRICT_SSL ~= '0'
      end
      if vim.env.COPILOT_ENTERPRISE_URI then
        vim.g.copilot_enterprise_uri = vim.env.COPILOT_ENTERPRISE_URI
      end
    end,
  },
  { -- Useful status updates for LSP.
    'j-hui/fidget.nvim',
    opts = {},
  },
  { -- Jujutsu (jj) support
    'jceb/jiejie.nvim',
    cond = function()
      return vim.fn.executable 'jj' == 1
    end,
    -- Custom configuration settings
    opts = {
      -- Excluded revset expression, see https://docs.jj-vcs.dev/latest/revsets/ for the full language
      excluded_revset = 'bookmarks(glob:"renovate/*") | tracked_remote_bookmarks(glob:"renovate/*") | untracked_remote_bookmarks(glob:"renovate/*")',
      default_view = 1,
      dynamic_views = {
        -- Dynamic view that dispalys all merges, see https://docs.jj-vcs.dev/latest/revsets/ for the full language
        { revset = 'merges()' },
      },
      log_revisions = 10,
    },
    config = function(_, opts)
      require('jiejie').setup(opts)
      -- Override :J and :JJ to behave like :G in fugitive (open in current buffer)
      vim.api.nvim_create_user_command('J', function(args)
        local context = require 'jiejie.context'
        local parsers = require 'jiejie.parsers'
        local api = require 'jiejie.api'
        local buffer = require 'jiejie.buffer'
        -- The repo belongs to the buffer, not the cwd. Walk up from the
        -- buffer's file to the nearest .jj directory, so nested jj
        -- repositories resolve exactly like jj itself would.
        -- The walk is reimplemented here because jiejie exposes no API for
        -- it: context.get_context(root) only treats its argument as a
        -- trusted root ("root or jujutsu.get_root()"), and the latter
        -- shells out to `jj workspace root` and silently degrades to the
        -- cwd when the buffer isn't a real file — the exact wrong-repo
        -- hazard nested repositories expose. Don't simplify this away.
        local jj_root = function()
          -- jiejie caches the root in its own buffers (fugitive's
          -- b:git_dir). Not just a fast path: :J from inside a
          -- log/oplog/evolog buffer must resolve to that buffer's repo,
          -- and their synthetic jj:// names are un-walkable anyway.
          if vim.b.jiejie_root then
            return vim.b.jiejie_root
          end
          -- Unnamed buffers (scratch, terminals) expand to the cwd's
          -- directory, so resolution quietly becomes cwd-based — old
          -- behavior, kept on purpose rather than as an oversight.
          local dir = vim.fn.expand '%:p:h'
          while dir ~= '' and dir ~= '/' do
            local stat = vim.uv.fs_stat(vim.fs.joinpath(dir, '.jj'))
            if stat and stat.type == 'directory' then
              return dir
            end
            local parent = vim.fn.fnamemodify(dir, ':h')
            if parent == dir then
              break
            end
            dir = parent
          end
          -- No .jj on the way up: last resort, wherever the cwd lives
          return require('jiejie.jujutsu').get_root()
        end
        -- One resolution, up front, from the buffer's file — not the cwd.
        local ctx = context.get_context(jj_root())
        if not ctx then
          local where = vim.fn.expand '%:p' ~= '' and vim.fn.expand '%' or vim.fn.getcwd()
          vim.notify('Not in a Jujutsu repository: ' .. where, vim.log.levels.ERROR)
          return
        end
        local cmd = #args.fargs > 0 and args.fargs[1] or 'log'
        -- Commands that need interactive TTY (like :G rebase -i)
        local interactive_cmds = {
          ['commit'] = { '--interactive', '-i' },
          ['rebase'] = { '--interactive', '-i' },
          ['edit'] = { '--interactive', '-i' },
          ['squash'] = { '--interactive', '-i' },
        }
        local is_interactive = false
        if interactive_cmds[cmd] then
          for _, flag in ipairs(interactive_cmds[cmd]) do
            if vim.tbl_contains(args.fargs, flag) then
              is_interactive = true
              break
            end
          end
        end
        if cmd == 'log' then
          -- Open log respecting :tab, :vertical, etc. (like :G)
          -- Build the log buffer filename (same as buffer.focus does internally)
          local filename = parsers.join_url {
            root = ctx.root,
            is_log = true,
            is_oplog = false,
            is_evolog = false,
            revision = nil,
            workspace = 'default',
          }
          -- Handle :tab J (open in new tab, full tab)
          if args.smods.tab and args.smods.tab > 0 then
            vim.cmd.tabedit(filename)
            return
          end
          -- Use the buffer.focus function which respects smods.vertical
          buffer.focus(ctx, {
            vertical = args.smods.vertical,
            buffer_type = buffer.BUFFER_TYPE.LOG,
          })
        elseif is_interactive then
          -- Run interactive commands in a terminal (like :G rebase -i).
          -- Pin the repo with -R (like fugitive's --git-dir), so the
          -- terminal's cwd — which is Neovim's cwd — never gets a say.
          local full_cmd = ('jj -R %s %s'):format(
            vim.fn.shellescape(ctx.root),
            table.concat(args.fargs, ' ')
          )
          -- Handle :tab J commit --interactive (open in new tab)
          if args.smods.tab and args.smods.tab > 0 then
            vim.cmd.tabnew()
          elseif args.smods.vertical then
            vim.cmd.vsplit()
          elseif args.smods.horizontal then
            vim.cmd.split()
          end
          vim.cmd('terminal ' .. full_cmd)
          vim.cmd 'startinsert'
          -- Close window/tab when terminal exits
          local term_buf = vim.api.nvim_get_current_buf()
          vim.api.nvim_create_autocmd('TermClose', {
            buffer = term_buf,
            once = true,
            callback = function()
              if args.smods.tab and args.smods.tab > 0 then
                vim.cmd.tabclose()
              else
                vim.cmd.close()
              end
            end,
          })
        else
          -- For other jj commands, use the original behavior.
          -- api.cli already runs with cwd = ctx.root, so this is
          -- repo-relative once ctx is resolved from the buffer's file.
          local command = cmd
          api.cli(ctx, command, { args = vim.list_slice(args.fargs, 2) })
        end
      end, { desc = 'Jujutsu command wrapper (like :G)', nargs = '*', complete = 'file' })
      -- Also override :JJ and :Jj (preserve :tab, :vertical modifiers)
      vim.api.nvim_create_user_command('JJ', function(args)
        local cmd = 'J ' .. table.concat(args.fargs, ' ')
        if args.smods.tab and args.smods.tab > 0 then
          cmd = 'tab ' .. cmd
        end
        if args.smods.vertical then
          cmd = 'vertical ' .. cmd
        end
        vim.cmd(cmd)
      end, { desc = 'Jujutsu command wrapper (like :G)', nargs = '*', complete = 'file' })
      vim.api.nvim_create_user_command('Jj', function(args)
        local cmd = 'J ' .. table.concat(args.fargs, ' ')
        if args.smods.tab and args.smods.tab > 0 then
          cmd = 'tab ' .. cmd
        end
        if args.smods.vertical then
          cmd = 'vertical ' .. cmd
        end
        vim.cmd(cmd)
      end, { desc = 'Jujutsu command wrapper (like :G)', nargs = '*', complete = 'file' })
    end,
  },
  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    opts = {},
  },
  { -- Replace netrw with nnn for file explorer
    'luukvbaal/nnn.nvim',
    cond = function()
      return vim.fn.executable 'nnn' == 1
    end,
    config = function()
      require('nnn').setup {
        explorer = {
          cmd = 'nnn -H',
        },
        picker = {
          cmd = 'nnn -H',
        },
        replace_netrw = 'picker',
      }
      vim.keymap.set('n', '-', '<cmd>NnnPicker %<CR>', { silent = true })
    end,
  },
  { -- Set escape keys with minimal delay
    'max397574/better-escape.nvim',
    config = function()
      require('better_escape').setup {
        timeout = vim.o.timeoutlen,
        default_mappings = false,
        mappings = {
          i = {
            j = {
              k = '<Esc>',
            },
          },
          c = {
            j = {
              k = '<Esc>',
            },
          },
          s = {
            j = {
              k = '<Esc>',
            },
          },
        },
      }
    end,
  },
  'mfussenegger/nvim-ansible', -- Configure behavior for Ansible files
  { -- Mappings for editing markdown
    'SidOfc/mkdx',
    init = function()
      vim.g['mkdx#settings'] = {
        checkbox = { toggles = { ' ', 'x' } },
        map = { enable = 0 },
      }
    end,
    config = function()
      vim.keymap.set(
        'n',
        '<leader>tx',
        '<Plug>(mkdx-checkbox-prev-n)',
        { noremap = true, silent = true }
      )
      vim.keymap.set(
        'v',
        '<leader>tx',
        '<Plug>(mkdx-checkbox-prev-n)',
        { noremap = true, silent = true }
      )
      vim.keymap.set(
        'n',
        '<leader>t[',
        '<Plug>(mkdx-toggle-checkbox-n)',
        { noremap = true, silent = true }
      )
      vim.keymap.set(
        'v',
        '<leader>t[',
        '<Plug>(mkdx-toggle-checkbox-n)',
        { noremap = true, silent = true }
      )
      vim.keymap.set(
        'n',
        '<leader>t-',
        '<Plug>(mkdx-toggle-list-n)',
        { noremap = true, silent = true }
      )
      vim.keymap.set(
        'v',
        '<leader>t-',
        '<Plug>(mkdx-toggle-list-n)',
        { noremap = true, silent = true }
      )
    end,
  },
  { -- A collection of common utilities and functions
    'nvim-lua/plenary.nvim',
    version = false,
    lazy = true,
  },
  {
    'olimorris/codecompanion.nvim',
    version = '^19.0.0',
    -- This will provide type hinting with LuaLS
    ---@module "codecompanion"
    ---@type CodeCompanion.AdapterArgs
    opts = {
      interactions = {
        chat = {
          adapter = (vim.env.ANTHROPIC_API_KEY or vim.env.ANTHROPIC_API_KEY_CMD) and 'anthropic'
            or 'copilot',
          opts = {
            ---@param ctx CodeCompanion.SystemPrompt.Context
            ---@return string
            system_prompt = function(ctx)
              return string.format(
                codecompanion_chat_system_prompt,
                ctx.nvim_version,
                ctx.os,
                ctx.cwd,
                ctx.date,
                ctx.language
              )
            end,
          },
        },
        opts = {
          date_format = '%a %Y-%m-%d',
        },
      },
      adapters = {
        http = {
          anthropic = function()
            return require('codecompanion.adapters').extend('anthropic', {
              env = {
                api_key = vim.env.ANTHROPIC_API_KEY or vim.env.ANTHROPIC_API_KEY_CMD or nil,
              },
              schema = {
                model = {
                  default = 'claude-sonnet-4-6',
                },
              },
            })
          end,
          copilot = function()
            local copilot = require 'codecompanion.adapters.http.copilot'
            return require('codecompanion.adapters').extend('copilot', {
              schema = {
                temperature = {
                  enabled = function(self)
                    local default_enabled = copilot.schema.temperature.enabled(self)
                    if not default_enabled then
                      return default_enabled
                    end
                    local model = self.schema.model.default
                    if type(model) == 'function' then
                      model = model()
                    end
                    return not vim.startswith(model, 'oswe')
                  end,
                },
              },
            })
          end,
          opts = {
            allow_insecure = vim.env.COPILOT_PROXY_STRICT_SSL == '0',
            proxy = vim.env.COPILOT_PROXY or nil,
            show_model_choices = true,
          },
        },
      },
      display = {
        chat = {
          show_tools_processing = true,
        },
      },
      extensions = {
        history = {
          enabled = true,
          opts = {
            -- Keymap to open history from chat buffer (default: gh)
            keymap = 'gh',
            -- Keymap to save the current chat manually (when auto_save is disabled)
            save_chat_keymap = 'sc',
            -- Save all chats by default (disable to save only manually using 'sc')
            auto_save = true,
            -- Number of days after which chats are automatically deleted (0 to disable)
            expiration_days = 0,
            -- Picker interface (auto resolved to a valid picker)
            picker = 'telescope', --- ("telescope", "snacks", "fzf-lua", or "default")
            ---Optional filter function to control which chats are shown when browsing
            chat_filter = nil, -- function(chat_data) return boolean end
            -- Customize picker keymaps (optional)
            picker_keymaps = {
              rename = { n = 'r', i = '<M-r>' },
              delete = { n = 'd', i = '<M-d>' },
              duplicate = { n = '<C-y>', i = '<C-y>' },
            },
            ---Automatically generate titles for new chats
            auto_generate_title = true,
            title_generation_opts = {
              ---Adapter for generating titles (defaults to current chat adapter)
              adapter = 'copilot', -- "copilot"
              ---Model for generating titles (defaults to current chat model)
              model = 'gpt-4o', -- "gpt-4o"
              ---Number of user prompts after which to refresh the title (0 to disable)
              refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
              ---Maximum number of times to refresh the title (default: 3)
              max_refreshes = 3,
              format_title = function(original_title)
                -- this can be a custom function that applies some custom
                -- formatting to the title.
                return original_title
              end,
            },
            ---On exiting and entering neovim, loads the last chat on opening chat
            continue_last_chat = false,
            ---When chat is cleared with `gx` delete the chat from history
            delete_on_clearing_chat = false,
            ---Directory path to save the chats
            dir_to_save = vim.fn.stdpath 'data' .. '/codecompanion-history',
            ---Enable detailed logging for history extension
            enable_logging = false,

            -- Summary system
            summary = {
              -- Keymap to generate summary for current chat (default: "gcs")
              create_summary_keymap = 'gcs',
              -- Keymap to browse summaries (default: "gbs")
              browse_summaries_keymap = 'gbs',

              generation_opts = {
                adapter = nil, -- defaults to current chat adapter
                model = nil, -- defaults to current chat model
                context_size = 90000, -- max tokens that the model supports
                include_references = true, -- include slash command content
                include_tool_outputs = true, -- include tool execution results
                system_prompt = nil, -- custom system prompt (string or function)
                format_summary = nil, -- custom function to format generated summary e.g to remove <think/> tags from summary
              },
            },

            -- Memory system (requires VectorCode CLI)
            memory = {
              -- Automatically index summaries when they are generated
              auto_create_memories_on_summary_generation = true,
              -- Path to the VectorCode executable
              vectorcode_exe = 'vectorcode',
              -- Tool configuration
              tool_opts = {
                -- Default number of memories to retrieve
                default_num = 10,
              },
              -- Enable notifications for indexing progress
              notify = true,
              -- Index all existing memories on startup
              -- (requires VectorCode 0.6.12+ for efficient incremental indexing)
              index_on_startup = false,
            },
          },
        },
        spinner = {
          opts = {
            style = 'fidget',
          },
        },
      },
    },
    dependencies = {
      'j-hui/fidget.nvim', -- For lalitmee/codecompanion-spinners.nvim
      'lalitmee/codecompanion-spinners.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'ravitemer/codecompanion-history.nvim',
    },
  },
  { -- Highlight the exact diff, based on characters and words
    'rickhowe/diffchar.vim',
    version = '*',
  },
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        -- Customize or remove this keymap to your liking
        '<leader>f',
        function()
          require('conform').format({ async = true }, function(err)
            if not err then
              local mode = vim.api.nvim_get_mode().mode
              if vim.startswith(string.lower(mode), 'v') then
                vim.api.nvim_feedkeys(
                  vim.api.nvim_replace_termcodes('<Esc>', true, false, true),
                  'n',
                  true
                )
              end
            end
          end)
        end,
        mode = '',
        desc = 'Format buffer',
      },
    },
    -- This will provide type hinting with LuaLS
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
      formatters_by_ft = {
        javascript = { 'eslint_d', 'prettierd', 'prettier', stop_after_first = true },
        lua = { 'stylua' },
        markdown = { 'markdownlint-cli2' },
        nix = { 'nixfmt' },
        python = function(bufnr)
          local conform = require 'conform'
          if conform.get_formatter_info('ruff_format', bufnr).available then
            return { 'ruff_format' }
          end
          return { 'isort', 'black' }
        end,
        typescript = { 'eslint_d', 'prettierd', 'prettier', stop_after_first = true },
      },
      default_format_opts = {
        lsp_format = 'fallback',
      },
      formatters = {},
    },
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = '*',
        callback = function()
          local exclude_ft = { markdown = true }
          if not exclude_ft[vim.bo.filetype] then
            vim.opt_local.formatexpr = "v:lua.require'conform'.formatexpr()"
          end
        end,
      })
    end,
  },
  {
    'toppair/peek.nvim',
    event = { 'VeryLazy' },
    build = 'deno task --quiet build:fast',
    cond = function()
      return vim.fn.executable 'deno' == 1
    end,
    config = function()
      require('peek').setup()
      vim.api.nvim_create_user_command('PeekOpen', require('peek').open, {})
      vim.api.nvim_create_user_command('PeekClose', require('peek').close, {})
    end,
  },
  { -- Bindings for (un)commenting
    'tpope/vim-commentary',
    version = false,
  },
  { -- Vim sugar for the UNIX shell commands that need it the most.
    'tpope/vim-eunuch',
    version = false,
  },
  { -- Criminal git integration
    'tpope/vim-fugitive',
    version = false,
  },
  { -- Vim sessions
    'tpope/vim-obsession',
    version = false,
  },
  { -- Linewise mappings, toggling options, encoding/decoding, jumping
    'tpope/vim-unimpaired',
    version = false,
  },
  { -- Repeat surround and unimpaired mappings
    'tpope/vim-repeat',
    version = false,
  },
  { -- Readline key bindings in vim
    'tpope/vim-rsi',
    version = false,
  },
  { -- Detect tabstop and shiftwidth automatically
    'tpope/vim-sleuth',
    version = false,
  },
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for install instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      'nvim-telescope/telescope-ui-select.nvim',
      { -- Useful for getting pretty icons, but requires a Nerd Font.
        'nvim-tree/nvim-web-devicons',
        version = false,
        enabled = vim.g.have_nerd_font,
      },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of help_tags options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        defaults = {
          preview = {
            -- For compatibility with treesitter main branch as of 2026-06-16
            treesitter = false,
          },
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--column',
            '--hidden',
            '--line-number',
            '--no-heading',
            '--smart-case',
            '--with-filename',
            -- Enable this if you want to search multiline strings
            -- '--multiline',
          },
        },
        -- pickers = {}
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable telescope extensions, if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- User command for find_files with overridable options.
      -- Defaulting hidden=true to allow finding dotfiles. Side-effect of this
      -- is finding .git which can be fixed by adding .git to .rgignore and
      -- ~/.config/fd/ignore
      -- Like :J, the search belongs to the buffer, not the cwd: it anchors at
      -- the buffer's project root. jiejie's b:jiejie_root cache (fugitive's
      -- b:git_dir) goes first: it is the only anchor jiejie's synthetic
      -- jiejie:// log/oplog buffers have — those names don't begin with /, so
      -- vim.fs.root treats them as cwd-relative and quietly resolves the
      -- cwd's repo instead of nil (on real files the cache merely restates
      -- what the walk below computes: jiejie stamps it on first write via
      -- its BufWritePost). Otherwise the nearest .git/.jj ancestor of the
      -- buffer's file wins — marker files count, so git worktrees (where
      -- .git is a file) resolve, and colocated or native jj repos both
      -- carry .jj. Out-of-repo files yield no root: pass no cwd and
      -- Telescope falls back to vim's cwd. Unnamed buffers seed from the
      -- cwd, the same degrade :J documents as kept on purpose.
      -- :FindFiles cwd=... opts back out to explicit anchoring.
      -- Delegates to telescope.command.load_command — the same entry point
      -- :Telescope itself uses — so converting hidden=/no_ignore= into the
      -- typed opts find_files expects stays Telescope's job. Unlike the old
      -- `:Telescope find_files ...` string round-trip, values with spaces
      -- survive (Telescope documents the string API as breaking on e.g.
      -- cwd=/foo bar). Later args overwrite earlier ones in its opts map,
      -- so :FindFiles hidden=false still wins over the default.
      vim.api.nvim_create_user_command('FindFiles', function(opts)
        local root_override = false
        for _, arg in ipairs(opts.fargs) do
          if arg:find '^cwd=' then
            root_override = true
            break
          end
        end
        local args = { 'hidden=true' }
        vim.list_extend(args, opts.fargs)
        if not root_override then
          local root = vim.b.jiejie_root or vim.fs.root(0, { '.git', '.jj' })
          if root then
            table.insert(args, 'cwd=' .. root)
          end
        end
        require('telescope.command').load_command('find_files', unpack(args))
      end, {
        nargs = '*',
        complete = function(arg_lead)
          -- Complete option names (hidden=, no_ignore=, etc.)
          local opts_list = { 'hidden=', 'no_ignore=', 'no_ignore_parent=', 'follow=', 'cwd=' }
          -- If arg_lead contains '=', complete the value (true/false)
          if arg_lead:find('=', 1, true) then
            local prefix = arg_lead:match '^(.+=)'
            if prefix then
              return vim.tbl_filter(function(v)
                return v:find(arg_lead:sub(#prefix + 1), 1, true) == 1
              end, { 'true', 'false' })
            end
          end
          return vim.tbl_filter(function(opt)
            return opt:find(arg_lead, 1, true) == 1
          end, opts_list)
        end,
        desc = 'Find files at the project root of the current buffer (default: hidden=true). Override: :FindFiles cwd=... hidden=false',
      })

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set(
        { 'n', 'v' },
        '<leader>sw',
        builtin.grep_string,
        { desc = '[S]earch current [W]ord' }
      )
      vim.keymap.set(
        'n',
        '<leader><leader>',
        builtin.buffers,
        { desc = '[ ] Find existing buffers' }
      )
      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })
      vim.keymap.set(
        'n',
        '<leader>s.',
        builtin.oldfiles,
        { desc = '[S]earch Recent Files ("." for repeat)' }
      )
      -- Also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sf', '<cmd>FindFiles<CR>', { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sF', ':FindFiles ', { desc = '[S]earch [F]iles (with args)' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      -- Shortcut for searching your neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })

      -- Add Telescope-based LSP pickers when an LSP attaches to a buffer.
      -- If you later switch picker plugins, this is where to update these mappings.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
        callback = function(event)
          local buf = event.buf
          -- Find references for the word under your cursor.
          vim.keymap.set(
            'n',
            'grr',
            builtin.lsp_references,
            { buffer = buf, desc = '[G]oto [R]eferences' }
          )

          -- Jump to the implementation of the word under your cursor.
          -- Useful when your language has ways of declaring types without an actual implementation.
          vim.keymap.set(
            'n',
            'gri',
            builtin.lsp_implementations,
            { buffer = buf, desc = '[G]oto [I]mplementation' }
          )

          -- Jump to the definition of the word under your cursor.
          -- This is where a variable was first declared, or where a function is defined, etc.
          -- To jump back, press <C-t>.
          vim.keymap.set(
            'n',
            'grd',
            builtin.lsp_definitions,
            { buffer = buf, desc = '[G]oto [D]efinition' }
          )

          -- Fuzzy find all the symbols in your current document.
          -- Symbols are things like variables, functions, types, etc.
          vim.keymap.set(
            'n',
            'gO',
            builtin.lsp_document_symbols,
            { buffer = buf, desc = 'Open Document Symbols' }
          )

          -- Fuzzy find all the symbols in your current workspace.
          -- Similar to document symbols, except searches over your entire project.
          vim.keymap.set(
            'n',
            'gW',
            builtin.lsp_dynamic_workspace_symbols,
            { buffer = buf, desc = 'Open Workspace Symbols' }
          )

          -- Jump to the type of the word under your cursor.
          -- Useful when you're not sure what type a variable is and you want to see
          -- the definition of its *type*, not where it was *defined*.
          vim.keymap.set(
            'n',
            'grt',
            builtin.lsp_type_definitions,
            { buffer = buf, desc = '[G]oto [T]ype Definition' }
          )
        end,
      })
    end,
  },
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      'j-hui/fidget.nvim',
      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method('textDocument/documentHighlight', event.buf) then
            local highlight_augroup =
              vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end
          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client:supports_method('textDocument/inlayHint', event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })
      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --  See `:help lsp-config` for information about keys and how to configure
      local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        --
        vtsls = {
          settings = {
            vtsls = {
              autoUseWorkspaceTsdk = true,
              enableMoveToFileCodeAction = true,
            },
            typescript = {
              implementationsCodeLens = { enabled = false },
              referencesCodeLens = { enabled = false },
              updateImportsOnFileMove = { enabled = 'always' },
            },
            javascript = {
              referencesCodeLens = { enabled = false },
              updateImportsOnFileMove = { enabled = 'always' },
            },
          },
        },
        ansiblels = {},
        jsonls = {
          -- jsonc permits trailing commas; drop jsonls code 519 'Trailing comma'
          -- warnings without hiding other diagnostics. Neovim uses pull
          -- diagnostics (textDocument/diagnostic) when the server declares a
          -- diagnosticProvider, so filter both pull and publish paths.
          handlers = {
            ['textDocument/diagnostic'] = function(err, result, ctx, config)
              if result and result.items then
                local kept = {}
                for _, d in ipairs(result.items) do
                  if tonumber(d.code) ~= 519 then
                    kept[#kept + 1] = d
                  end
                end
                result.items = kept
              end
              return vim.lsp.diagnostic.on_diagnostic(err, result, ctx, config)
            end,
            ['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
              if result and result.diagnostics then
                local kept = {}
                for _, d in ipairs(result.diagnostics) do
                  if tonumber(d.code) ~= 519 then
                    kept[#kept + 1] = d
                  end
                end
                result.diagnostics = kept
              end
              return vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
            end,
          },
        },
        lua_ls = {
          -- cmd = {...},
          -- filetypes { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              runtime = { version = 'LuaJIT' },
              workspace = {
                checkThirdParty = false,
                -- Tells lua_ls where to find all the Lua files that you have loaded
                -- for your neovim configuration.
                library = {
                  '${3rd}/luv/library',
                  unpack(vim.api.nvim_get_runtime_file('', true)),
                },
                -- If lua_ls is really slow on your computer, you can try this instead:
                -- library = { vim.env.VIMRUNTIME },
              },
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
        marksman = {},
        nixd = {},
        pylsp = {},
        terraformls = {},
        yamlls = {},
      }
      for name, server in pairs(servers) do
        server.capabilities =
          vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end
      -- Special Lua Config, as recommended by neovim help docs
      vim.lsp.config('lua_ls', {
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
              path ~= vim.fn.stdpath 'config'
              and (
                vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')
              )
            then
              return
            end
          end

          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
              version = 'LuaJIT',
              path = { 'lua/?.lua', 'lua/?/init.lua' },
            },
            workspace = {
              checkThirdParty = false,
              -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
              --  See https://github.com/neovim/nvim-lspconfig/issues/3189
              library = vim.api.nvim_get_runtime_file('', true),
            },
          })
        end,
        settings = {
          Lua = {},
        },
      })
      vim.lsp.enable 'lua_ls'
    end,
  },
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    version = false,
    build = ':TSUpdate',
    config = function()
      local parsers = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'nix',
        'query',
        'vim',
        'vimdoc',
        'yaml',
      }
      require('nvim-treesitter').install(parsers)
      local function treesitter_try_attach(buf, language)
        -- Check if a parser exists and load it
        if not vim.treesitter.language.add(language) then
          return
        end
        -- Enable syntax highlighting and other treesitter features
        vim.treesitter.start(buf, language)

        -- Enable treesitter based folds
        -- For more info on folds see `:help folds`
        -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        -- vim.wo.foldmethod = 'expr'

        -- Check if treesitter indentation is available for this language, and if so enable it
        -- in case there is no indent query, the indentexpr will fallback to the vim's built in one
        local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil

        -- Enable treesitter based indentation
        if has_indent_query then
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end
      local available_parsers = require('nvim-treesitter').get_available()
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local buf, filetype = args.buf, args.match

          local language = vim.treesitter.language.get_lang(filetype)
          if not language then
            return
          end

          local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

          if vim.tbl_contains(installed_parsers, language) then
            -- Enable the parser if it is already installed
            treesitter_try_attach(buf, language)
          elseif vim.tbl_contains(available_parsers, language) then
            -- If a parser is available in `nvim-treesitter`, auto-install it and enable it after the installation is done
            require('nvim-treesitter').install(language):await(function()
              treesitter_try_attach(buf, language)
            end)
          else
            -- Try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
            treesitter_try_attach(buf, language)
          end
        end,
      })
    end,
  },
  { -- Syntax aware text-objects, select, move, swap, and peek support.
    'nvim-treesitter/nvim-treesitter-textobjects',
    version = false,
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
  },
  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      -- Snippet Engine
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
        opts = {},
      },
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        -- 'default' (recommended) for mappings similar to built-in completions
        --   <c-y> to accept ([y]es) the completion.
        --    This will auto-import if your LSP supports it.
        --    This will expand snippets if the LSP sent a snippet.
        -- 'super-tab' for tab to accept
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- For an understanding of why the 'default' preset is recommended,
        -- you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        --
        -- All presets have the following mappings:
        -- <tab>/<s-tab>: move to right/left of your snippet expansion
        -- <c-space>: Open menu or open docs if already open
        -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
        -- <c-e>: Hide menu
        -- <c-k>: Toggle signature help
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        preset = 'default',

        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      completion = {
        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },

      snippets = { preset = 'luasnip' },

      -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
      -- which automatically downloads a prebuilt binary when enabled.
      --
      -- By default, we use the Lua implementation instead, but you may enable
      -- the rust implementation via `'prefer_rust_with_warning'`
      --
      -- See :h blink-cmp-config-fuzzy for more information
      fuzzy = { implementation = 'lua' },

      -- Shows a signature help window while you type arguments for a function
      signature = { enabled = true },
    },
  },
  -- The following two comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- put them in the right spots if you want.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for kickstart
  --
  --  Here are some example plugins that I've included in the kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
  -- { import = 'custom.plugins' },
}, {
  defaults = {
    version = '*',
  },
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
-- vim: ts=2 sts=2 sw=2 et
