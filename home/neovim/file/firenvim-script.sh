#!/bin/sh

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"

run_dir="$XDG_RUNTIME_DIR/firenvim"
mkdir -p "$run_dir"
chmod 700 "$run_dir"
cd "$run_dir" || exit

unset NVIM_LISTEN_ADDRESS

exec nvim --headless \
  --cmd 'let g:started_by_firenvim = v:true' \
  -c 'call firenvim#run()'

  #--cmd "let g:firenvim_i=[]|let g:firenvim_o=[]|let g:Firenvim_oi={i,d,e->add(g:firenvim_i,d)}|let g:Firenvim_oo={t->add(g:firenvim_o,t)}|let g:firenvim_c=stdioopen({'on_stdin':{i,d,e->g:Firenvim_oi(i,d,e)},'on_print':{t->g:Firenvim_oo(t)}})" \
