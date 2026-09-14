let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
doautoall SessionLoadPre
silent only
silent tabonly
cd ~/develop/gistol_dashboard
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
set shortmess+=aoO
badd +41 lib/features/groups/view/widgets/group_list.dart
badd +12 term://~/develop/gistol_dashboard//2553:/usr/bin/fish
argglobal
%argdel
$argadd .
edit lib/features/groups/view/widgets/group_list.dart
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
wincmd _ | wincmd |
split
1wincmd k
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 35 + 104) / 208)
exe '2resize ' . ((&lines * 30 + 25) / 50)
exe 'vert 2resize ' . ((&columns * 172 + 104) / 208)
exe '3resize ' . ((&lines * 16 + 25) / 50)
exe 'vert 3resize ' . ((&columns * 172 + 104) / 208)
argglobal
enew
file NvimTree_1
balt lib/features/groups/view/widgets/group_list.dart
setlocal foldmethod=manual
setlocal foldexpr=0
setlocal foldmarker={{{,}}}
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal nofoldenable
lcd ~/develop/gistol_dashboard
wincmd w
argglobal
setlocal foldmethod=manual
setlocal foldexpr=0
setlocal foldmarker={{{,}}}
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldenable
silent! normal! zE
let &fdl = &fdl
let s:l = 41 - ((2 * winheight(0) + 15) / 30)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 41
normal! 052|
lcd ~/develop/gistol_dashboard
wincmd w
argglobal
if bufexists(fnamemodify("term://~/develop/gistol_dashboard//2553:/usr/bin/fish", ":p")) | buffer term://~/develop/gistol_dashboard//2553:/usr/bin/fish | else | edit term://~/develop/gistol_dashboard//2553:/usr/bin/fish | endif
if &buftype ==# 'terminal'
  silent file term://~/develop/gistol_dashboard//2553:/usr/bin/fish
endif
balt ~/develop/gistol_dashboard/lib/features/groups/view/widgets/group_list.dart
setlocal foldmethod=manual
setlocal foldexpr=0
setlocal foldmarker={{{,}}}
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldenable
let s:l = 12 - ((7 * winheight(0) + 8) / 16)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 12
normal! 0
lcd ~/develop/gistol_dashboard
wincmd w
3wincmd w
exe 'vert 1resize ' . ((&columns * 35 + 104) / 208)
exe '2resize ' . ((&lines * 30 + 25) / 50)
exe 'vert 2resize ' . ((&columns * 172 + 104) / 208)
exe '3resize ' . ((&lines * 16 + 25) / 50)
exe 'vert 3resize ' . ((&columns * 172 + 104) / 208)
tabnext 1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let &winminheight = s:save_winminheight
let &winminwidth = s:save_winminwidth
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
set hlsearch
nohlsearch
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
