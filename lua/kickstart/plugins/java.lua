local jdtls = require 'jdtls'
local home = os.getenv 'HOME'
local workspace_path = home .. '/.local/share/nvim/jdtls-workspace/'
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = workspace_path .. project_name

-- 确保目录存在
os.execute('mkdir -p ' .. workspace_dir)

local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens',
    'java.base/java.util=ALL-UNNAMED',
    '--add-opens',
    'java.base/java.lang=ALL-UNNAMED',
    '-jar',
    vim.fn.glob(home .. '/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
    '-configuration',
    home .. '/.local/share/nvim/mason/packages/jdtls/config_linux', -- 或 config_mac / config_win
    '-data',
    workspace_dir,
  },

  root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' },

  settings = {
    java = {
      configuration = {
        runtimes = {
          {
            name = 'JavaSE-8',
            path = '/Users/yitiansong/Library/Java/JavaVirtualMachines/corretto-1.8.0_432/Contents/Home', -- 替换为你的 Java 路径
          },
        },
      },
    },
    -- 启用 Lombok 支持
    completion = {
      favoriteStaticMembers = {
        'org.junit.Assert.*',
        'org.junit.Assume.*',
        'org.junit.jupiter.api.Assertions.*',
        'org.junit.jupiter.api.Assumptions.*',
        'org.junit.jupiter.api.DynamicContainer.*',
        'org.junit.jupiter.api.DynamicTest.*',
        'org.mockito.Mockito.*',
        'org.mockito.ArgumentMatchers.*',
        'org.mockito.Answers.*',
      },
      importOrder = {
        'java',
        'javax',
        'com',
        'org',
      },
    },
    maven = {
      downloadSources = true,
    },
    implementationsCodeLens = {
      enabled = true,
    },
    referencesCodeLens = {
      enabled = true,
    },
    references = {
      includeDecompiledSources = true,
    },
  },

  init_options = {
    bundles = {},
  },
}

-- 添加调试支持
local bundles = {
  vim.fn.glob(home .. '/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', 1),
}

config.init_options.bundles = bundles

-- 启动 jdtls
jdtls.start_or_attach(config)

-- 添加键位映射
local bufnr = vim.api.nvim_get_current_buf()
local opts = { silent = true, buffer = bufnr }
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
vim.keymap.set('n', '<leader>wl', function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, opts)
vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
vim.keymap.set('n', '<leader>jc', jdtls.generate_constructor, opts)
vim.keymap.set('n', '<leader>jg', jdtls.generate_getters_and_setters, opts)
vim.keymap.set('n', '<leader>ji', jdtls.implement_methods, opts)
vim.keymap.set('n', '<leader>jt', jdtls.generate_to_string, opts)
