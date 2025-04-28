return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'jay-babu/mason-nvim-dap.nvim',
      'williamboman/mason.nvim',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = '', linehl = '', numhl = '' })
      vim.fn.sign_define('DapStopped', { text = '➡️', texthl = '', linehl = '', numhl = '' })
      vim.fn.sign_define('DapBreakpointRejected', { text = '⚠️', texthl = '', linehl = '', numhl = '' })

      -- 🛠 Setup DAP UI
      dapui.setup()

      -- 🔌 Setup Virtual Text
      require('nvim-dap-virtual-text').setup()

      -- 🔧 Setup Mason + Mason DAP
      require('mason').setup()
      require('mason-nvim-dap').setup {
        ensure_installed = { 'node2', 'chrome' },
        automatic_installation = true,
        handlers = {}, -- Default
      }

      -- 🎯 Auto open/close DAP UI
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      -- 🔥 DAP Adapters y Configuraciones personalizadas para Node.js
      dap.adapters.node2 = {
        type = 'executable',
        command = 'node',
        args = { os.getenv 'HOME' .. '/.local/share/nvim/mason/packages/node-debug2-adapter/out/src/nodeDebug.js' },
      }

      dap.configurations.javascript = {
        {
          name = 'Launch NPM Script',
          type = 'node2',
          request = 'launch',
          program = vim.fn.expand '${workspaceFolder}/node_modules/.bin/npm',
          args = function()
            local input = vim.fn.input('Script to run (dev/test/start): ', 'dev')
            return { 'run', input }
          end,
          cwd = '${workspaceFolder}',
          console = 'integratedTerminal',
          sourceMaps = true,
          protocol = 'inspector',
        },
        {
          name = 'Debug Jest Current Test',
          type = 'node2',
          request = 'launch',
          program = vim.fn.expand '${workspaceFolder}/node_modules/.bin/jest',
          args = function()
            local file = vim.fn.expand '%'
            local line = vim.fn.line '.'
            return { file, '--testNamePattern', vim.fn.input 'Test name: ' }
          end,
          cwd = '${workspaceFolder}',
          console = 'integratedTerminal',
          sourceMaps = true,
          protocol = 'inspector',
          runtimeExecutable = 'node',
        },
      }

      -- 🎯 Keymaps
      local map = vim.keymap.set
      map('n', '<F5>', function()
        dap.continue()
      end, { desc = 'DAP continue' })
      map('n', '<F10>', function()
        dap.step_over()
      end, { desc = 'DAP step over' })
      map('n', '<F11>', function()
        dap.step_into()
      end, { desc = 'DAP step into' })
      map('n', '<F12>', function()
        dap.step_out()
      end, { desc = 'DAP step out' })
      map('n', '<leader>b', function()
        dap.toggle_breakpoint()
      end, { desc = 'DAP toggle breakpoint' })
      map('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'DAP conditional breakpoint' })
      map('n', '<leader>dr', function()
        dap.repl.toggle()
      end, { desc = 'DAP toggle REPL' })
      map('n', '<leader>dl', function()
        dap.run_last()
      end, { desc = 'DAP run last' })
      map('n', '<leader>du', function()
        dapui.toggle()
      end, { desc = 'DAP UI toggle' })

      -- ✨ Extra: correr una configuración específica con prompt
      map('n', '<leader>dc', function()
        local configurations = dap.configurations.javascript
        local options = {}
        for i, conf in ipairs(configurations) do
          table.insert(options, i .. '. ' .. conf.name)
        end
        vim.ui.select(options, { prompt = 'Select debug configuration:' }, function(choice)
          if not choice then
            return
          end
          local idx = tonumber(choice:match '^(%d+)')
          dap.run(configurations[idx])
        end)
      end, { desc = 'DAP choose config' })
    end,
  },
}
