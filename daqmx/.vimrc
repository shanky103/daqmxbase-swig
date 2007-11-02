set path+=/Applications/National\\\ Instruments/NI-DAQmx\\\ Base/includes,/usr/lib/ruby/1.8/universal-darwin8.0
set path+=/opt/local/share/swig/1.3.31/ruby,/opt/local/share/swig/1.3.31/
set makeprg=make\ -f\ Makefile.swig
set isfname+=\ 
set errorformat^=%f:%l:\ %m
au BufNewFile,BufRead Makefile* setf make
au BufNewFile,BufRead *.i setf swig
