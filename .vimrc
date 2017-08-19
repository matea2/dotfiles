colorscheme delek
syntax on

set number
set nowrap
set hidden
set showcmd
set nrformats=hex
set ambiwidth=double
set formatoptions+=mM
"set viminfo=

" 文字コード
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,euc-jp,cp932,iso-2022-jp

" 改行コード
set fileformat=unix
set fileformats=unix,dos,mac

" タブ、インデント
set tabstop=4
set shiftwidth=4
set smartindent

" 検索
set hlsearch
set noincsearch
set smartcase
set wrapscan

" ステータスライン
set laststatus=2
set statusline=%n:\ %<%f\ %m%r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%4vC,\ %l/%LL\ \-\-%P\-\-

" ハイライト
highlight ZenkakuSpace ctermbg=lightgrey
match ZenkakuSpace /　/
