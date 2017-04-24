
" The "Vim Hanami" plugin for Hanami framework support.
"
" Author:    Oleg 'Sovetnik' Siniuk
" URL:       https://github.com/sovetnik/vim-hanami
" Version:   0.1.2
" Copyright: Copyright (c) 2017 Oleg Siniuk
" License:   MIT
" -----------------------------------------------------

set swb=useopen

if !exists('g:hanami_open_strategy')
  let g:hanami_open_strategy = 'split'
endif

" Path patterns
let s:pattern_entity =  'lib/.*/entities/.*\.rb'
let s:pattern_repo = 'lib/.*/repositories/.*_repository.rb'
let s:pattern_entity_spec = 'spec/.*/entities/.*_spec.rb'
let s:pattern_repo_spec = 'spec/.*/repositories/.*_repository_spec.rb'

nmap <Leader>x :HanamiRepoToggle<CR>
nmap <Leader>s :HanamiSpecToggle<CR>

command! HanamiRepoToggle :call <SID>SplitToggle('repo')
command! HanamiSpecToggle :call <SID>SplitToggle('spec')
command! HanamiProject :call <SID>HanamiGetProjectName()

" opens a new window or warns that no hanami file
fu! s:SplitToggle(way)
  let path = expand('%:p')
  if s:HanamiEnsure(path) =~ 0
    echom 'There is not a Hanami file'
  else
    if a:way =~ 'repo'
      if filereadable(s:HanamiEntityRepoToggle(path))
        return s:SmartOpen(s:HanamiEntityRepoToggle(path))
      else
        echom 'No file for Repo toggle'
      endif
    elseif a:way =~ 'spec'
      if filereadable(s:HanamiLibSpecToggle(path))
        return s:SmartOpen( s:HanamiLibSpecToggle(path))
      else
        echom 'No file for Spec toggle'
      endif
    endif
  endif
endfunction

fu! s:SmartOpen(target_path)
  let bufnr = bufnr(a:target_path)
  if bufnr == -1
    exec g:hanami_open_strategy . a:target_path
  else
    exec 'sbuffer' . bufnr
  endif
endfu

" ensures if file in hanami lib or spec folder
" and try read .hanamirc in project root
" returnes 1 or 0
fu! s:HanamiEnsure(path)
  if match(a:path, '/lib/') > -1
    return filereadable(substitute(a:path, 'lib/.*', '.hanamirc', 'g'))
  elseif match(a:path, '/spec/') > -1
    return filereadable(substitute(a:path, 'spec/.*', '.hanamirc', 'g'))
  endif
endfunction

" Togglers
fu! s:HanamiEntityRepoToggle(path)
 if a:path =~ s:pattern_repo_spec
    return s:PathSpecRepoToEntity(a:path)
  elseif a:path =~ s:pattern_entity_spec
    return s:PathSpecEntityToRepo(a:path)
  elseif a:path =~ s:pattern_repo
    return s:PathLibRepoToEntity(a:path)
  elseif a:path =~ s:pattern_entity
    return s:PathLibEntityToRepo(a:path)
  endif
endfunction

fu! s:HanamiLibSpecToggle(path)
 if a:path =~ s:pattern_repo_spec
    return s:PathSpecToLib(a:path)
  elseif a:path =~ s:pattern_entity_spec
    return s:PathSpecToLib(a:path)
  elseif a:path =~ s:pattern_repo
    return s:PathLibToSpec(a:path)
  elseif a:path =~ s:pattern_entity
    return s:PathLibToSpec(a:path)
  endif
endfunction

" Path transformation methods
" accepts path, return path
fu! s:PathLibEntityToRepo(path)
  let path = substitute(a:path , '/entities/', '/repositories/', 'g')
  let path = substitute(path , '.rb', '_repository.rb', 'g')
  return path
endfunction

fu! s:PathLibRepoToEntity(path)
  let path = substitute(a:path, '/repositories/', '/entities/', 'g')
  let path = substitute(path, '_repository.rb', '.rb', 'g') 
  return path
endfunction

fu! s:PathSpecEntityToRepo(path)
  let path = substitute(a:path , '/entities/', '/repositories/', 'g')
  let path = substitute(path , '_spec.rb', '_repository_spec.rb', 'g')
  return path
endfunction

fu! s:PathSpecRepoToEntity(path)
  let path = substitute(a:path, '/repositories/', '/entities/', 'g')
  let path = substitute(path, '_repository_spec.rb', '_spec.rb', 'g') 
  return path
endfunction

fu! s:PathLibToSpec(path)
  let path = substitute(a:path, '/lib/', '/spec/', 'g')
  let path = substitute(path, '.rb', '_spec.rb', 'g')
  return path
endfunction

fu! s:PathSpecToLib(path)
  let path = substitute(a:path, '/spec/', '/lib/', 'g')
  let path = substitute(path, '_spec.rb', '.rb', 'g')
  return path
endfunction

fu! s:HanamiGetProjectName()
  echom s:HanamiGetProject(s:HanamiRcPath(expand('%:p')))
endfunction

" read project name from .hanamirc
fu! s:HanamiGetProject(path_to_rc)
  return a:path_to_rc =~ 0 ? 0 : substitute(matchstr(readfile(a:path_to_rc), 'project='), 'project=', '', 'g')
endfunction

" check if file in hanami lib or spec folder
" and try read .hanamirc in project root
" returnes path_to_rc 0
fu! s:HanamiRcPath(path)
  if match(a:path, '/lib/') > -1
    if filereadable(substitute(a:path, 'lib/.*', '.hanamirc', 'g'))
      return substitute(a:path, 'lib/.*', '.hanamirc', 'g')
    endif
  elseif match(a:path, '/spec/') > -1
    if filereadable(substitute(a:path, 'spec/.*', '.hanamirc', 'g'))
      return substitute(a:path, 'spec/.*', '.hanamirc', 'g')
    endif
  endif
endfunction

