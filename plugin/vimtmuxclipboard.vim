
function! s:InTmuxSession()
	return $TMUX != ''
endfunction

function! s:TmuxBufferName()
	let l:list = systemlist('tmux list-buffers -F"#{buffer_name}"')
	if len(l:list)==0
		return ""
	else
		return l:list[0]
	endif
endfunction

function! s:TmuxBuffer()
	return system('tmux show-buffer')
endfunction

function! s:Enable()

	if s:InTmuxSession()==0
		return
	endif

	let g:vimtmuxclipboard_LastBufferName=""

	" @"
	augroup vimtmuxclipboard
		autocmd!
		autocmd FocusGained * let g:vimtmuxclipboard_LastBufferName = s:TmuxBufferName()
		autocmd	FocusLost   * if g:vimtmuxclipboard_LastBufferName!=s:TmuxBufferName() | let @" = s:TmuxBuffer() | endif
		autocmd TextYankPost * call s:YankPost()
	augroup END

endfunction

function! s:YankPost()
	let l:s=join(v:event["regcontents"],"\n") 
	if len(l:s)<4096
		silent! call system('tmux set-buffer ' . shellescape(l:s))
	endif
endfunction

call s:Enable()