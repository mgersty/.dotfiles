" When using vimdiff or diff mode
highlight DiffAdd    term=bold         ctermbg=darkgreen ctermfg=white    cterm=bold guibg=DarkGreen  guifg=White    gui=bold
highlight DiffText   term=reverse,bold ctermbg=red       ctermfg=yellow   cterm=bold guibg=DarkRed    guifg=yellow   gui=bold
highlight DiffChange term=bold         ctermbg=black     ctermfg=white    cterm=bold guibg=Black      guifg=White    gui=bold
highlight DiffDelete term=none         ctermbg=darkblue  ctermfg=darkblue cterm=none guibg=DarkBlue   guifg=DarkBlue gui=none
if &background == "light"
	" Changes when bg=white fg=black
	highlight DiffAdd                   ctermfg=black cterm=bold guibg=green      guifg=black
	highlight DiffText   ctermbg=yellow ctermfg=red   cterm=bold guibg=yellow     guifg=red
	highlight DiffChange ctermbg=none   ctermfg=none  cterm=bold guibg=white      guifg=black
	highlight DiffDelete                                         guibg=lightblue  guifg=lightblue
endif
