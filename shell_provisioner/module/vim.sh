#!/bin/bash

# Vim

apt-get install -y vim

cat << EOF >/etc/vim/vimrc.local
syntax on
colors elflord
"set softtabstop=4
set expandtab
set tabstop=4
set number
"set showcmd
"set cursorline
"set cursorcolumn
highlight CursorLine ctermbg=lightgray
"set wildmenu
"set lazyredraw
set showmatch
set incsearch
set hlsearch " nohl to undo
set nofoldenable " disable folding
EOF

update-alternatives --set editor /usr/bin/vim.basic

