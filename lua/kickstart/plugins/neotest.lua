return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'antoinemadec/FixCursorHold.nvim',
      'haydenmeade/neotest-jest',
    },
    config = function()
      local neotest = require 'neotest'

      neotest.setup {
        adapters = {
          require 'neotest-jest' {
            jestCommand = 'npm test --',
            jestConfigFile = function()
              local configs = {
                'jest.config.ts',
                'jest.config.js',
                'jest.config.json',
              }
              for _, config in ipairs(configs) do
                if vim.fn.filereadable(config) == 1 then
                  return config
                end
              end
              return nil
            end,
            env = { CI = true },
            cwd = function()
              return vim.fn.getcwd()
            end,
          },
        },
      }

      local map = vim.keymap.set
      map('n', '<leader>tn', function()
        neotest.run.run()
      end, { desc = 'Run nearest test' })

      map('n', '<leader>tf', function()
        neotest.run.run(vim.fn.expand '%')
      end, { desc = 'Run file tests' })

      map('n', '<leader>ts', function()
        neotest.summary.toggle()
      end, { desc = 'Toggle test summary' })

      map('n', '<leader>to', function()
        neotest.output.open { enter = true, auto_close = true }
      end, { desc = 'Open test output' })
    end,
  },
}
