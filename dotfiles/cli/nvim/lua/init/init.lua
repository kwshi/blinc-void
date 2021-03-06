local on_attach = function(opts)
  return function(client, buf)
    local set_key = function(k, v) 
      vim.api.nvim_buf_set_keymap(buf, 'n', k, v, {
        noremap = true,
        silent = true,
      })
    end
    set_key('K', '<Cmd>lua vim.lsp.buf.hover()<CR>') 
    if opts.fmt == nil or opts.fmt then
      vim.api.nvim_exec('au BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)', false)
    end
  end
end

require 'lspconfig'.tsserver.setup {
  on_attach = on_attach {fmt=false}
}

require 'lspconfig'.svelte.setup {
  on_attach = on_attach {}
}


