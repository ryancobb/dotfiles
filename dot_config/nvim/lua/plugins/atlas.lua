-- GitLab MRs and issues inside Neovim. GitLab only; auth is a PAT with
-- `api` scope stored in the macOS Keychain (service "atlas-nvim-gitlab").
-- glab's token cannot be reused: it is OAuth2, and atlas sends it as a
-- PRIVATE-TOKEN header, which GitLab only accepts for PATs.
local function gitlab_token()
  local out = vim.fn.system({ "security", "find-generic-password", "-s", "atlas-nvim-gitlab", "-w" })
  if vim.v.shell_error ~= 0 then
    vim.notify(
      "atlas.nvim: no GitLab token in Keychain. Add one with:\n"
        .. 'security add-generic-password -s atlas-nvim-gitlab -a "$USER" -w <PAT>',
      vim.log.levels.WARN
    )
    return ""
  end
  return vim.trim(out)
end

return {
  "emrearmagan/atlas.nvim",
  cmd = { "AtlasPulls", "AtlasIssues", "AtlasCreatePR", "AtlasCreateIssue", "AtlasDiff" },
  keys = {
    { "<leader>gm", "<cmd>AtlasPulls gitlab<cr>", desc = "Merge requests (Atlas)" },
    { "<leader>gi", "<cmd>AtlasIssues gitlab<cr>", desc = "Issues (Atlas)" },
  },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "esmuellert/codediff.nvim",
  },
  opts = function()
    local token = gitlab_token()
    return {
      pulls = {
        -- codediff renders atlas comment/task overlays; the default AtlasDiff
        -- viewer would duplicate what codediff already does in this config.
        diff = { open_cmd = "CodeDiff" },
        providers = {
          gitlab = {
            base_url = "https://gitlab.com",
            token = token,
            views = {
              { name = "Assigned", key = "1", scope = "assigned_to_me", state = "opened" },
              {
                name = "Review requests",
                key = "2",
                scope = "all",
                state = "opened",
                -- The README suggests reviewer_id = "Me", but atlas passes
                -- extra_params verbatim and GitLab's API only takes an
                -- integer/None/Any there; reviewer_username works as a string.
                extra_params = { reviewer_username = "rcobb" },
              },
              { name = "Created", key = "3", scope = "created_by_me", state = "opened" },
            },
          },
        },
      },
      issues = {
        providers = {
          gitlab = {
            base_url = "https://gitlab.com",
            token = token,
            views = {
              { name = "Assigned", key = "1", scope = "assigned_to_me", state = "opened" },
              { name = "Created", key = "2", scope = "created_by_me", state = "opened" },
            },
          },
        },
      },
    }
  end,
}
