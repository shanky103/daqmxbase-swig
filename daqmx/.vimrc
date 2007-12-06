set path+=C:/Program\\\ Files/National\\\ Instruments/NI-DAQmx\\\ Base/Include
set path+=c:/cygwin/lib/ruby/site_ruby/1.8,c:/cygwin/lib/ruby/site_ruby/1.8/i386-cygwin,c:/cygwin/lib/ruby/site_ruby,c:/cygwin/lib/ruby/1.8,c:/cygwin/lib/ruby/1.8/i386-cygwin,.,
set path+=c:/cygwin/usr/local/share/swig/1.3.31/ruby,c:/cygwin/usr/local/share/swig/1.3.31,
set makeprg=make\ -f\ Makefile.swig
set isfname+=\ 
set errorformat^=%f:%l:\ %m
au BufNewFile,BufRead Makefile* setf make
au BufNewFile,BufRead *.i setf swig
