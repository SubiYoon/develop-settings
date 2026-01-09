return {
  -- INFO: 차후 PR컨펌되면 수정
  "SubiYoon/uv.nvim",
  branch = "feature/multiple-venv-patterns",

  -- "benomahony/uv.nvim",
  -- Optional filetype to lazy load when you open a python file
  -- ft = { python }
  -- Optional dependency, but recommended:
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "neovim/nvim-lspconfig",
    {
      "linux-cultist/venv-selector.nvim",
      ft = "python",
      opts = {},
    },
  },
  opts = {
    execution = {
      hide_result_buffer = true,
      reuse_result_split_buffer = true,
    },
    picker_integration = true,
    notify_activate_venv = true,
    keymaps = {
      prefix = "<leader>U",
      commands = false,
    },
  },
}
