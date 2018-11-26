""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"  <Shift+K>: put cusor on a symbol, jump to the symbol defs in vim doc
"
"
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Should be put at beginnig
set nocompatible                " Enables us Vim specific features
filetype off                    " Reset filetype detection first ...
filetype plugin indent on       " ... and enable filetype detection


""""""""""""""""""
" Vundle         "
"""""""""""""""""" 
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Keep Plugin commands between vundle#begin/end.

Plugin 'flazz/vim-colorschemes'         " could use fatih/moloki

Plugin 'scrooloose/nerdtree'
Bundle 'jistr/vim-nerdtree-tabs'
Plugin 'Xuyuanp/nerdtree-git-plugin' 

Plugin 'fatih/vim-go'
Plugin 'AndrewRadev/splitjoin.vim'
Plugin 'SirVer/ultisnips'
Plugin 'ctrlpvim/ctrlp.vim'

Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-git'

Plugin 'editorconfig/editorconfig-vim'  " have dependency, see github page

Plugin 'Valloric/YouCompleteMe'         " see https://github.com/Valloric/YouCompleteMe
Plugin 'Rip-Rip/clang_complete'

Plugin 'majutsushi/tagbar'

call vundle#end()            " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line


""""""""""""""""""""""
"      Settings      "
""""""""""""""""""""""
set shell=/bin/bash
set ttyfast                     " Indicate fast terminal conn for faster redraw
set ttymouse=xterm2             " Indicate terminal type for mouse codes
set ttyscroll=3                 " Speedup scrolling
set laststatus=2                " Show status line always
set encoding=utf-8              " Set default encoding to UTF-8
set autoread                    " Automatically read changed files
set autoindent                  " Enabile Autoindent
set backspace=indent,eol,start  " Makes backspace key more powerful.
set incsearch                   " Shows the match while typing
set hlsearch                    " Highlight found searches
set noerrorbells                " No beeps
set number                      " Show line numbers
set showcmd                     " Show me what I'm typing
set noswapfile                  " Don't use swapfile
set nobackup                    " Don't create annoying backup files
set splitright                  " Vertical windows should be split to right
set splitbelow                  " Horizontal windows should split to bottom
set autowrite                   " Automatically save before :next, :make etc.
set hidden                      " Buffer should still exist if window is closed
set fileformats=unix,dos,mac    " Prefer Unix over Windows over OS 9 formats
set noshowmatch                 " Do not show matching brackets by flickering
set noshowmode                  " We show the mode with airline or lightline
set ignorecase                  " Search case insensitive...
set smartcase                   " ... but not it begins with upper case
set completeopt=menu,menuone    " Show popup menu, even if there is one entry
set pumheight=10                " Completion window max size
set nocursorcolumn              " Do not highlight column (speeds up highlighting)
set nocursorline                " Do not highlight cursor (speeds up highlighting)
set lazyredraw                  " Wait to redraw

set exrc                        " Forces vim to source .vimrc if it present in working directory
set secure                      " Restrict usage of some commands in non-default .vimrc files

set colorcolumn=100             " highlight column number 100 with color
highlight ColorColumn ctermbg=darkgray

"set tags=./.tags;,.tags


" Enable to copy to clipboard for operations like yank, delete, change and put
" http://stackoverflow.com/questions/20186975/vim-mac-how-to-copy-to-clipboard-without-pbcopy
if has('unnamedplus')
  set clipboard^=unnamed
  set clipboard^=unnamedplus
endif

" This enables us to undo files even if you exit Vim.
if has('persistent_undo')
  set undofile
  set undodir=~/.config/vim/tmp/undo//
endif


" Colorscheme
syntax enable
:set t_Co=256
let g:rehash256 = 1
colorscheme molokai

" Setting path variable
" Vim has gf commnd which open file whose name is under or after cusor.
" By default Vim searches file in working directory. However, most projects
" However, most projects have sepearted directory for include files.
let &path.="src/include,/usr/include/AL,"

""""""""""""""""""""""
"      Mappings      "
""""""""""""""""""""""

" Set leader shortcut to a comma ','. By default it's the backslash
let mapleader = ","

" Jump to next error with Ctrl-n and previous error with Ctrl-m. Close the
" quickfix window with <leader>a
map <C-n> :cnext<CR>
map <C-m> :cprevious<CR>
nnoremap <leader>a :cclose<CR>

" Visual linewise up and down by default (and use gj gk to go quicker)
noremap <Up> gk
noremap <Down> gj
noremap j gj
noremap k gk

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap <leader><Enter> :noh<CR>   " Turn off the highlights until you next search

" Act like D and C
nnoremap Y y$

" Enter automatically into the files directory
autocmd BufEnter * silent! lcd %:p:h

" Fast saving
nmap <leader>w :w!<cr>

" Move between window
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l


""""""""""""""""""""""""""""""
"        Plugin              "
""""""""""""""""""""""""""""""
"
" NERD tree
"
map <leader>nn :NERDTreeToggle<cr>
map <leader>n <plug>NERDTreeTabsToggle<CR>
" run NERDTreeTabs on console vim startup
"let g:nerdtree_tabs_open_on_console_startup=1
" nerdtree-git-plugin symbols
let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
    \ }

"
" vim-go
"
let g:go_fmt_command = "goimports"
let g:go_autodetect_gopath = 1
let g:go_auto_type_info = 1
let g:go_auto_sameids = 1
" use only quickfix for all lists
let g:go_list_type = "quickfix"

let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_build_constraints=1

"
let g:go_metalinter_enabled= ['vet', 'golint', 'errcheck']
let g:go_metalinter_autosave = 1
let g:go_metalinter_autosave_enabled = ['vet', 'golint']
let g:go_metalinter_deadline = "5s"
"
let g:go_version_warning = 0

" Open :GoDeclsDir with ctrl-g
nmap <C-g> :GoDeclsDir<cr>
imap <C-g> <esc>:<C-u>GoDeclsDir<cr>

augroup go
  autocmd!

  " Show by default 4 spaces for a tab
  autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4

  " :GoBuild and :GoTestCompile
  autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>

  " :GoTest
  autocmd FileType go nmap <leader>t  <Plug>(go-test)

  " :GoRun
  autocmd FileType go nmap <leader>r  <Plug>(go-run)

  " :GoDoc
  autocmd FileType go nmap <leader>d <Plug>(go-doc)

  " :GoCoverageToggle
  autocmd FileType go nmap <leader>c <Plug>(go-coverage-toggle)

  " :GoInfo
  autocmd FileType go nmap <leader>i <Plug>(go-info)

  " :GoMetaLinter
  autocmd FileType go nmap <leader>l <Plug>(go-metalinter)

  " :GoDef but opens in a vertical split
  autocmd FileType go nmap <leader>v <Plug>(go-def-vertical)
  " :GoDef but opens in a horizontal split
  autocmd FileType go nmap <leader>s <Plug>(go-def-split)

  " :GoAlternate  commands :A, :AV, :AS and :AT
  autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
  autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
  autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
  autocmd Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')
augroup END

" build_go_files is a custom function that builds or compiles the test file.
" It calls :GoBuild if its a Go file, or :GoTestCompile if it's a test file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction


"
" airline
"
"let g:airline_section_b = '%{strftime("%c")}'
"let g:airline_section_y = 'BN: %{bufnr("%")}'
let g:airline_solarized_bg='dark'


"
" c
"
augroup c
	autocmd!
	autocmd BufRead,BufNewFile *.h,*.c set filetype=c.doxygen
augroup END


"
" editorconfig-vim
"
let g:EditorConfig_exec_path = '/usr/bin/editorconfig'
let g:EditorConfig_exclude_patterns = ['fugitive://.*'] " Ensure to works well with fugitive
let g:EditorConfig_exclude_patterns = ['scp://.*']      " Avoid loading EditorConfig for any remote files over ssh


"
" Tab confilit YCM & ultisnips
"
" 
""Option1: Change ultisnips expand trigger to <c-j>
"let g:UltiSnipsExpandTrigger="<c-j>"    
"let g:UltiSnipsJumpForwardTrigger="<c-j>"
"let g:UltiSnipsJumpBackwardTrigger="<c-k>"
""Option2: Make YCM not use Tab key, YCM will cycle through completion with <C-N> and <C-P>
let g:ycm_key_list_select_completion=[]
let g:ycm_key_list_previous_completion=[]


"
" clang_complete
"
let g:clang_library_path='/usr/local/lib/libclang.so.7'


"
" tagbar
"
nnoremap <silent> <leader>b :TagbarToggle<CR>
let g:tagbar_autofocus = 1
