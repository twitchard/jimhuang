"                                  NeoVim
"
"  Dependencies
"    ctags	github.com/universal-ctags/ctags
"    gtags      github.com/jstemmer/gotags
"    cscope     apt-git install cscope "vim plugin not installed by vundle, refer tutorial
"    editorconfig-core-c  github.com/editorconfig/editorconfig-core-c
"
"  Good References
"    1) Vim/Cscope tutorial  http://cscope.sourceforge.net/cscope_vim_tutorial.html
"    2) Effortless Ctags with Git	https://tbaggery.com/2011/08/08/effortless-ctags-with-git.html
"    3) https://www.embeddedarm.com/blog/tag-jumping-in-a-codebase-using-ctags-and-cscope-in-vim/
"    " After read above two links, you can do cscope-with-git
"    4) Vim and ctas  https://andrew.stwrt.ca/posts/vim-ctags/
"    5) vim-go tutorial  https://github.com/fatih/vim-go-tutorial#go-to-definition
"    6) Using Vim as c/c++ IDE  http://www.alexeyshmalko.com/2014/using-vim-as-c-cpp-ide/
"    7) some mapping refs  https://github.com/amix/vimrc#normal-mode-mappings
"    8) EditorConfig  https://editorconfig.org/
"
"  Issues which are fixed
"    vim-go quickfx windwo opening beneth TagBar  https://github.com/fatih/vim-go/issues/108
"    Let path default value search downward CWD   https://github.com/neovim/neovim/issues/3209
"
"
"  <Shift+K>: put cusor on a symbol, jump to the symbol defs in vim doc
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
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
Plugin 'VundleVim/Vundle.vim' " let Vundle manage Vundle, required
Plugin 'vimwiki/vimwiki'
Plugin 'fatih/molokai'         " color schema
Plugin 'fatih/vim-go'
Plugin 'jodosha/vim-godebug'
Plugin 'AndrewRadev/splitjoin.vim'
Plugin 'SirVer/ultisnips'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'majutsushi/tagbar'
Plugin 'tpope/vim-git'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-rhubarb.git' " enable Gbrowse, fugitive addin
Plugin 'tpope/vim-capslock'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-unimpaired'  "mappings for commonly used ex commands
Plugin 'tpope/vim-dadbod'      " interact with database
Plugin 'tpope/vim-eunuch'      " vim sugar for unix shell command
Plugin 'tpope/vim-dispatch'    " Asynchronous build and test dispatcher
Plugin 'airblade/vim-gitgutter'
Plugin 'zivyangll/git-blame.vim'
Plugin 'editorconfig/editorconfig-vim'  " have dependency, see github page
Plugin '907th/vim-auto-save'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'scrooloose/nerdtree'
Bundle 'jistr/vim-nerdtree-tabs'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'vim-scripts/a.vim'              " uAlternate Files quickly (.c --> .h)
Plugin 'vim-scripts/Conque-GDB'         " GDB command line interface
Plugin 'vim-scripts/grep.vim'           " Search tools(grep, egrep, fgrep, agrep)
Plugin 'w0rp/ale'                       " Asynchronouse linting/fixing
Plugin 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plugin 'Shougo/deoplete-clangx'         " c/c++ completion using clang for deoplete
Plugin 'Shougo/neoinclude.vim'
Plugin 'Shougo/context_filetype.vim'
Plugin 'Shougo/neco-syntax'             " use the syntax file as a completion source 
Plugin 'Shougo/echodoc.vim'             " look selected func' args in deoplete
call vundle#end()            " required
" Put your non-Plugin stuff after this line


""""""""""""""""""""""
"      Settings      "
""""""""""""""""""""""
set shell=bash
set shellpipe=>                 " prevent output being copied to stdout
set ttyfast                     " Indicate fast terminal conn for faster redraw
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
"set timeoutlen=500              " set timoutlen for mappling delay in millseconds (default 1000)
set updatetime=100               " in milliseconds (default 4000)
set clipboard+=unnamedplus      " Alwyas use clipboard for ALL operations
" This enables us to undo files even if you exit Vim.
if has('persistent_undo')
  set undofile
  set undodir=~/.config/vim/tmp/undo//
endif

"""""""""""""""""""""""
" Setting path variable
"""""""""""""""""""""""
" Vim has gf commnd which open file whose name is under or after cusor.
" By default Vim searches file in working directory. However, most projects
" However, most projects have sepearted directory for include files.
let &path.="src/include,/usr/include/AL,"
" search downward (relative to present working directory) for the file you are
" looking for
set path+=**


""""""""""""""""""""""
" Visualization 
""""""""""""""""""""""
" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,space:·
"Invisible character colors
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59
" color column
highlight ColorColumn ctermbg=darkgray
" Colorscheme
syntax enable
:set t_Co=256
let g:rehash256 = 1
colorscheme molokai


""""""""""""""""""""""""
" Mapping
""""""""""""""""""""""""
" Set leader shortcut to a comma ','. By default it's the backslash
let mapleader = ","

" paste from system clipboard 
nnoremap p "+p

"-- Move to window
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

"-- Go to definition using g
" gd      local def
" dD      global def
" g*      search for word under cursor
" g#      same as g* in backward
" gg      goto first line in buffer
" G
" gf      goto file
" g]      jump to a tag def

"-- Go to tab
" gt      go to next tab
" gT      go to previous tab
 
"-- Control tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
" Opens a new tab with the current buffer's path
" Useful when editing files in the same directory
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

"-- Misc
" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>
" Fast saving
nmap <leader>w :w!<cr>
" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
nnoremap n nzzzv
nnoremap N Nzzzv
" Turn off the highlights until you next search
nnoremap <leader><Enter> :noh<CR>   
" Shortcut to rapidly toggle `set list`, will show invisible
nmap <leader>l :set list!<CR>
" Close quickfix window
nnoremap <leader>a :cclose<CR>

""""""""""""""""""""""""""""""
" Commands
"""""""""""""""""""""""""""""
"visually select the code the type :SuperRetab 4
:command! -nargs=1 -range SuperRetab <line1>,<line2>s/\v%(^ *)@<= {<args>}/\t/g

" Convert all leading spaces to tabs (default range is whole file):
" These commands use the current 'tabstop' (abbreviated as 'ts') option.
" :Space2Tab
" Convert lines 11 to 15 only (inclusive):
" :11,15Space2Tab
" Convert last visually-selected lines:
" :'<,'>Space2Tab
" Same, converting leading tabs to spaces:
" :'<,'>Tab2Space
:command! -range=% -nargs=0 Tab2Space execute '<line1>,<line2>s#^\t\+#\=repeat(" ", len(submatch(0))*' . &ts . ')'
:command! -range=% -nargs=0 Space2Tab execute '<line1>,<line2>s#^\( \{'.&ts.'\}\)\+#\=repeat("\t", len(submatch(0))/' . &ts . ')'

" strip trailing space
function! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfunction
command! TrimWhitespace call TrimWhitespace()


""""""""""""""""""""""""""""""
" Autocmd
"""""""""""""""""""""""""""""
" Enter automatically into the files directory
"autocmd BufEnter * silent! lcd %:p:h

" Disable automatic comment insertion for c, cpp, go
" http://vim.wikia.com/wiki/Disable_automatic_comment_insertion
au FileType c,cpp,go setlocal comments-=:// comments+=f://

" vim-go using :botright cwindow instead of plain :cwindow, when with TagBag
" opeing, this will put quick window (invoked by many vim-go command) beneath TagBar.
"
" This trigger takes advantage of the fact that the quickfix window can be
" easily distinguished by its file-type, qf. The wincmd J command is
" equivalent to the Ctrl+W, Shift+J shortcut telling Vim to move a window to
" the very bottom (see :help :wincmd and :help ^WJ).
autocmd FileType qf wincmd J


""""""""""""""""""""""""""""""
" Plugins
"""""""""""""""""""""""""""""
"
" vim-fugitive
"
" https://github.com/tpope/vim-fugitive#faq
" patch that automatically opens the quickfix window after :Ggrep
autocmd QuickFixCmdPost *grep* cwindow
" Prevent Glog output to ternimal instead of quickfix window
" https://github.com/tpope/vim-fugitive/issues/677
nnoremap <leader>gl :silent! Glog<CR> :redraw!<CR>

" vim-gitgutter
"
let g:gitgutter_diff_args = '-w'      "ignore whitespace
"
" Turn off realtime update
" Add this to your vim configuration (in an /after/plugin directory):
" .vim/after/plugin/gitgutter.vim
" autocmd! gitgutter CursorHold,CursorHoldI
"
" Update signs when some events happen
autocmd BufWritePost,WinEnter * GitGutter

"
" editorconfig-vim
"
let g:EditorConfig_exec_path = '/usr/bin/editorconfig'
" Ensure to works well with fugitive
let g:EditorConfig_exclude_patterns = ['fugitive://.*'] 
" Avoid loading EditorConfig for any remote files over ssh
let g:EditorConfig_exclude_patterns = ['scp://.*']      

"
" airline
"
"let g:airline_solarized_bg='dark'
" enable smart tabline, use :bp, :bn
let g:airline#extensions#tabline#enabled = 1  
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#show_tab_nr = 1
" configure filename match rules to exclude
let g:airline#extensions#tabline#excludes = ['tree*', 'fugitive:*']  
let g:airline#extensions#tabline#buffers_label = 'b'
let g:airline#extensions#tabline#tabs_label = 't'
let g:airline#extensions#tabline#buffer_idx_mode = 1
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9
nmap <leader>- <Plug>AirlineSelectPrevTab
nmap <leader>= <Plug>AirlineSelectNextTab
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_sep = ''
let g:airline#extensions#tabline#right_alt_sep = ''
let g:airline#extensions#tabline#show_close_button = 1 
let g:airline#extensions#tabline#close_symbol = 'X'
let g:airline#extensions#capslock#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#branch#sha1_len = 10
let g:airline#extensions#ctrlp#show_adjacent_modes = 1
let g:airline#extensions#fugitiveline#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline#extensions#tagbar#flags = 'f'
let g:airline#extensions#ale#enabled = 1

"
" vim-auto-save
"
let g:auto_save = 1
let g:auto_save_events = ["FocusLost","WinLeave","TabLeave","BufWritePost","BufLeave","DirChanged","TabClosed"]

"
" git-blame.vim
"
nnoremap <silent> <leader>s :<C-u>call gitblame#echo()<CR>

"
" vim-capslock
"
" Capslock and escape has been swapped
" http://vim.wikia.com/wiki/Map_caps_lock_to_escape_in_XWindows
imap <leader>c <Plug>CapsLockToggle
nmap <leader>C <Plug>CapsLockToggle

"
" vim-commentary
"
" https://github.com/tpope/vim-commentary#faq
autocmd FileType apache setlocal commentstring=#\ %s
" To have // by default for c and cpp
" setlocal commentstring=//\ %s in after/ftplugin/c.vim
" setlocal commentstring=//\ %s in after/ftplugin/cpp.vim

"
" NERD tree
"
map <leader>nn <plug>NERDTreeTabsToggle<CR>
" NerdTreeStatusline

" 
" nerdtree-git-plugin symbols
"
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
" vim-nerdtree-tab
"
let g:nerdtree_tabs_open_on_console_startup=1
" Do not turn this off, which could cause fugitive work unormal. 
" Automatically find and select currently opened file in NERDTree
"let g:nerdtree_tabs_autofind=1
" When switching into a tab, make sure that focus is on the file window
let g:nerdtree_tabs_focus_on_files=1
" Open NERDTree only if directory was given
let g:nerdtree_tabs_open_on_console_startup=2

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
let g:go_metalinter_enabled= ['vet', 'golint', 'errcheck']
let g:go_metalinter_autosave = 0
let g:go_metalinter_autosave_enabled = ['vet', 'golint']
let g:go_metalinter_deadline = "5s"
let g:go_version_warning = 0
" Open :GoDeclsDir with ctrl-g
nmap <C-g> :GoDeclsDir<cr>
imap <C-g> <esc>:<C-u>GoDeclsDir<cr>
augroup go
  autocmd!
  " Show by default 4 spaces for a tab
  autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4
  " :GoBuild and :GoTestCompile
  autocmd FileType go nmap <leader>bb :<C-u>call <SID>build_go_files()<CR>
  " :GoTest
  autocmd FileType go nmap <leader>tt  <Plug>(go-test)
  " :GoRun
  autocmd FileType go nmap <leader>rr  <Plug>(go-run)
  " :GoDoc
  autocmd FileType go nmap <leader>dd <Plug>(go-doc)
  " :GoCoverageToggle
  autocmd FileType go nmap <leader>cc <Plug>(go-coverage-toggle)
  " :GoInfo
  autocmd FileType go nmap <leader>ii <Plug>(go-info)
  " :GoMetaLinter
  autocmd FileType go nmap <leader>ll <Plug>(go-metalinter)
  " :GoDef but opens in a vertical split
  autocmd FileType go nmap <leader>vv <Plug>(go-def-vertical)
  " :GoDef but opens in a horizontal split
  autocmd FileType go nmap <leader>ss <Plug>(go-def-split)
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
" tagbar
"
nnoremap <silent> <leader>b :TagbarToggle<CR>
let g:tagbar_autofocus = 1
let g:tagbar_width = 33   " default 40
let g:tagbar_compact = 1
let g:tagbar_indent = 1

"auto FileType * nested :call tagbar#autoopen(0)
"auto BufEnter * nested :call tagbar#autoopen(0)
"autocmd Filetype c,cpp,go,py nested :TagbarOpen
"
" gotags need to be installed: go get -u github.com/jstemmer/gotags
"
let g:tagbar_type_go = {
        \ 'ctagstype' : 'go',
        \ 'kinds'     : [
                \ 'p:package',
                \ 'i:imports:1',
                \ 'c:constants',
                \ 'v:variables',
                \ 't:types',
                \ 'n:interfaces',
                \ 'w:fields',
                \ 'e:embedded',
                \ 'm:methods',
                \ 'r:constructor',
                \ 'f:functions'
        \ ],
        \ 'sro' : '.',
        \ 'kind2scope' : {
                \ 't' : 'ctype',
                \ 'n' : 'ntype'
        \ },
        \ 'scope2kind' : {
                \ 'ctype' : 't',
                \ 'ntype' : 'n'
        \ },
        \ 'ctagsbin'  : 'gotags',
        \ 'ctagsargs' : '-sort -silent'
\ }

"
" cscope
"
if has("cscope")
    """"""""""""" Standard cscope/vim boilerplate
    "
    " NOTE invoke /usr/local/bin/gentags at beginning
    "
    "set csprg=/usr/bin/cscope

    " use both cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
    set cscopetag

    " set cscoperrelative
    "set csre

    " check cscope for definition of a symbol before checking ctags: set to 1
    " if you want the reverse search order.
    set csto=0

    set nocsverb
    " add any cscope database in current directory
    if filereadable("cscope.out")
        cs add $PWD/cscope.out $PWD
    " else add the database pointed to by environment variable
    elseif $CSCOPE_DB != ""
        cs add $CSCOPE_DB
    endif

    " show msg when any other cscope db added
    set csverb

    """"""""""""" My cscope/vim key mappings
    "
    " The following maps all invoke one of the following cscope search types:
    "
    "   's'   symbol: find all references to the token under cursor
    "   'g'   global: find global definition(s) of the token under cursor
    "   'c'   calls:  find all calls to the function name under cursor
    "   't'   text:   find all instances of the text under cursor
    "   'e'   egrep:  egrep search for the word under cursor
    "   'f'   file:   open the filename under cursor
    "   'i'   includes: find files that include the filename under cursor
    "   'd'   called: find functions that function under cursor calls
    "
    " Below are three sets of the maps: one set that just jumps to your
    " search result
    "
    " All of the maps involving the <cfile> macro use '^<cfile>$': this is so
    " that searches over '#include <time.h>" return only references to
    " 'time.h', and not 'sys/time.h', etc. (by default cscope will return all
    " files that contain 'time.h' as part of their name).

    " To do the first type of search, hit '<leader>c', followed by one of the
    " cscope search types above (s,g,c,t,e,f,i,d).  The result of your cscope
    " search will be displayed in the current window.  You can use CTRL-T to
    " go back to where you were before the search.
    "
    nmap <leader>ss :cs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <leader>sg :cs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <leader>sc :cs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <leader>st :cs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <leader>se :cs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <leader>sf :cs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <leader>si :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <leader>sd :cs find d <C-R>=expand("<cword>")<CR><CR>

    """"""""""""" key map timeouts
    "
    " By default Vim will only wait 1 second for each keystroke in a mapping.
    " You may find that too short with the above typemaps.  If so, you should
    " either turn off mapping timeouts via 'notimeout'.
    "
    "set notimeout
    "
    " Or, you can keep timeouts, by uncommenting the timeoutlen line below,
    " with your own personal favorite value (in milliseconds):
    "
    "set timeoutlen=4000
    "
    " Either way, since mapping timeout settings by default also set the
    " timeouts for multicharacter 'keys codes' (like <F1>), you should also
    " set ttimeout and ttimeoutlen: otherwise, you will experience strange
    " delays as vim waits for a keystroke after you hit ESC (it will be
    " waiting to see if the ESC is actually part of a key code like <F1>).
    "
    "set ttimeout
    "
    " personally, I find a tenth of a second to work well for key code
    " timeouts. If you experience problems and have a slow terminal or network
    " connection, set it higher.  If you don't set ttimeoutlen, the value for
    " timeoutlent (default: 1000 = 1 second, which is sluggish) is used.
    "
    "set ttimeoutlen=100
endif

"
" a.vim
"
" quick commands to switch between source files and headers quickly
" :A switches to the header file corresponding to the current file being edited (or vise versa)
" :AS splits and switches
" :AV vertical splits and switches
" :AT new tab and switches
" :AN cycles through matches
" :IH switches to file under cursor
" :IHS splits and switches
" :IHV vertical splits and switches
" :IHT new tab and switches
" :IHN cycles through matches
" <leader>ih switches to file under cursor
" <leader>is switches to the alternate file of file under cursor (e.g. on  <foo.h> switches to foo.cpp)
" <leader>ihn cycles through matches

"
" grep.vim
"
nnoremap <silent> <F3> :Grep<cr>

"
" Conque-GDB
"
let g:ConqueGdb_Leader = '\'
let g:ConqueGdb_SaveHistory = 1
nnoremap <silent> <C-\>Y :ConqueGdbCommand y<cr>
nnoremap <silent> <C-\>N :ConqueGdbCommand n<cr>
"
" ConqueTerm
"
nnoremap <C-\>b     :ConqueTermSplit bash<cr>
nnoremap <C-\>vb    :ConqueTermVSplit bash<cr>
"
"https://michaelthessel.com/go-vim-debugging-with-gdb/
let g:ConqueTerm_Color = 2
let g:ConqueTerm_CloseOnEnd = 1
let g:ConqueTerm_StartMessages = 0

"
" ale
"
map <leader>al :ALEToggle<cr>
nmap <silent> <leader>p <Plug>(ale_previous_wrap)
nmap <silent> <leader>n <Plug>(ale_next_wrap)
let g:ale_enabled = 0
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_enter = 0
let g:ale_lint_on_filetype_changed = 0
let g:ale_lint_on_save = 0
let g:ale_set_highlights = 0
let g:ale_completion_enabled = 1
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1
let g:ale_list_window_size = 8

"
" deoplete
"
" press <C-y> on the candidate to select response
let g:python3_host_prog = '/usr/bin/python3'
" Enable deoplete when InsertEnter.
let g:deoplete#enable_at_startup = 0
autocmd InsertEnter * call deoplete#enable()
" Enable smart case
call deoplete#custom#option('smart_case', v:true)
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function() abort
  return deoplete#close_popup() . "\<CR>"
endfunction
" Complete filename after "="
set isfname-==
" Enable auto select feature
" set completeopt+=noinsert
" Close preview window after completion done
autocmd CompleteDone * silent! pclose!
" Disable auto completion for tex file
autocmd FileType tex
\ call deoplete#custom#buffer_option('auto_complete', v:false)
"call deoplete#custom#option('sources', {
"\ '_': ['buffer'],
"\ 'cpp': ['buffer', 'tag'],
"\})
" Change clang binary path
call deoplete#custom#var('clangx', 'clang_binary', '/usr/local/bin/clang')
let g:clang_library_path='/usr/local/lib/libclang.so.7'
let g:clang_snippets = 1
let g:clang_snippets_engine = 'ultisnips'

"
" vimwiki/vimwiki
"
filetype plugin on
syntax on

