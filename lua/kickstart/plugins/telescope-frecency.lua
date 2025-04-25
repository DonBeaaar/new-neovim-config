return {
  'nvim-telescope/telescope-frecency.nvim',
  version = '*',
  config = function()
    require('telescope').setup {
      extensions = {
        frecency = {
          show_scores = false,
          show_filter_column = false,
        },
      },
    }
    require('telescope').load_extension 'frecency'
  end,
}
