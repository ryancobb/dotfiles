return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  cmd = { "ObsidianToday" },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "<leader>oo", "<cmd>ObsidianToday<cr>", desc = "Open today" },
    { "<leader>oy", "<cmd>ObsidianYesterday<cr>", desc = "Open yesterday" },
    { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "Create new note" },
    { "<leader>od", "<cmd>ObsidianDailies<cr>", desc = "Open dailies" },
  },
  opts = {
    ui = { enable = false },
    workspaces = {
      {
        name = "work",
        path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work",
      },
    },
    daily_notes = {
      folder = "notes/dailies",
      template = "nvim-daily.md",
    },
    templates = {
      folder = "templates",
    },
    notes_subdir = "inbox",
    note_id_func = function(title)
      -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
      -- In this case a note with the title 'My new note' will be given an ID that looks
      -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
      local suffix = ""
      if title ~= nil then
        -- If title is given, transform it into valid file name.
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        -- If title is nil, just add 4 random uppercase letters to the suffix.
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return tostring(os.time()) .. "-" .. suffix
    end,
    follow_url_func = function(url)
      vim.fn.jobstart({ "open", url })
    end,
  },
}
