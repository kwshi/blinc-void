local default = function(val, def)
  if val == nil then return def
  else return val
  end
end

local on_attach = function(opts)
  opts.fmt = default(opts.fmt, true)
  opts.incr = default(opts.incr, false)

  return function(client, buf)
    local set_key = function(k, v) 
      vim.api.nvim_buf_set_keymap(buf, 'n', k, v, {
        noremap = true,
        silent = true,
      })
    end
    set_key('K', '<Cmd>lua vim.lsp.buf.hover()<CR>') 
    if opts.fmt then
      vim.api.nvim_exec('au BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)', false)
    end

    if client.config.flags then
      if opts.incr then
        client.config.flags.allow_incremental_sync = true
      end
    end

  end
end

require 'lspconfig'.tsserver.setup {
  on_attach = on_attach { fmt = false }
}

require 'lspconfig'.ocamllsp.setup {
  on_attach = on_attach {}
}

require 'lspconfig'.svelte.setup {
  on_attach = on_attach {}
}

require 'lspconfig'.elmls.setup {
  on_attach = on_attach { incr = true }
}

require 'lspconfig'.pyls.setup {
 on_attach = on_attach {}
}
