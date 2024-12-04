return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    dependencies = {
      "echasnovski/mini.icons",
    },
    opts = function(_, opts)
      local actions = require("fzf-lua.actions")

      opts.grep = {
        rg_glob = true,
        fzf_opts = {
          -- ctrl+n ctrl+p to cycle history
          ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-grep-history",
        },
        actions = {
          ["ctrl-i"] = { actions.toggle_ignore },
          ["ctrl-h"] = { actions.toggle_hidden },
        },
      }
      opts.files = {
        fzf_opts = {
          -- ctrl+n ctrl+p to cycle history
          ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-files-history",
        },
        actions = {
          ["ctrl-i"] = { actions.toggle_ignore },
          ["ctrl-h"] = { actions.toggle_hidden },
          ["enter"] = function(selected, opts)
            local fallback = vim.api.nvim_get_current_win()
            local window_id = require("window-picker").pick_window() or fallback
            vim.api.nvim_set_current_win(window_id)
            require("fzf-lua.actions").file_edit(selected, opts)
          end,
        },
      }
      opts.winopts = {
        preview = {
          layout = "flex",
          flip_columns = 200,
        },
      }
      opts.previewers = {
        git_diff = {
          cmd_deleted = "DFT_WIDTH=$FZF_PREVIEW_COLUMNS git diff HEAD --",
          cmd_modified = "DFT_WIDTH=$FZF_PREVIEW_COLUMNS git diff HEAD",
          cmd_untracked = "DFT_WIDTH=$FZF_PREVIEW_COLUMNS git diff --no-index /dev/null",
        },
        render_markdown = { enable = true, filetypes = { ["markdown"] = true } },
      }

      return opts
    end,
    keys = {
      { "<leader><space>", "<cmd>FzfLua files<cr>", desc = "files" },
      { "<leader>st", "<cmd>FzfLua live_grep<cr>", desc = "text" },
      { "<leader>fr", LazyVim.pick("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },
      { "<leader>fR", "<cmd>FzfLua oldfiles<cr>", desc = "Recent" },
      {
        "<leader>fa",
        function()
          require("fzf-lua").files({
            fzf_opts = {
              ["--query"] = vim.fn
                .expand("%:~:.:r")
                :gsub("_spec", "")
                :gsub("^app/", "")
                :gsub("^spec/", "")
                :gsub("^ee/app/", "") .. " !" .. vim.fn.expand("%:t"),
            },
          })
        end,
        desc = "alternate",
      },
    },
  },
}
