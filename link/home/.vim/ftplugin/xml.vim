" https://vim.fandom.com/wiki/Pretty-formatting_XML
" nnoremap :FormatXML :%!python3 -c "import xml.dom.minidom, sys; print(xml.dom.minidom.parse(sys.stdin).toprettyxml())"
com! FormatXML :%!python3 -c "import xml.dom.minidom, sys; print(xml.dom.minidom.parse(sys.stdin).toprettyxml())"
" This delays FZF (,f)
" nmap <Leader>fmt :FormatXML<CR>
