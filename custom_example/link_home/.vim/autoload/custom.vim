" autoload/*.vim only load when you call *:a_function

if exists('g:loaded_custom')
  finish
endif
let g:loaded_custom = 1

function! custom#begin()
  let g:custom_ai_plugin = 'codeium' " codeium | copilot | openai
endfunction
