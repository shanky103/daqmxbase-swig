set path+=C:/Program\\\ Files/National\\\ Instruments/NI-DAQmx\\\ Base/Include
set path+=C:/cygwin/usr/local/lib/ruby/site_ruby/1.8,C:/cygwin/usr/local/lib/ruby/site_ruby/1.8/i386-cygwin,C:/cygwin/usr/local/lib/ruby/site_ruby,C:/cygwin/usr/local/lib/ruby/1.8,C:/cygwin/usr/local/lib/ruby/1.8/i386-cygwin,.,
set path+=C:/cygwin/usr/share/swig/1.3.29/ruby,C:/cygwin/usr/share/swig/1.3.29,
set makeprg=make\ -f\ Makefile.swig
set isfname+=\ 
set errorformat^=%f:%l:\ %m
au BufNewFile,BufRead Makefile* setf make
au BufNewFile,BufRead *.i setf swig
