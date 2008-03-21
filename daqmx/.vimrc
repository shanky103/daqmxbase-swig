set path+=/Applications/National\\\ Instruments/NI-DAQmx\\\ Base/includes
set path+=/opt/local/lib/ruby/site_ruby/1.8,/opt/local/lib/ruby/site_ruby/1.8/i686-darwin9.2.0,/opt/local/lib/ruby/site_ruby,/opt/local/lib/ruby/vendor_ruby/1.8,/opt/local/lib/ruby/vendor_ruby/1.8/i686-darwin9.2.0,/opt/local/lib/ruby/vendor_ruby,/opt/local/lib/ruby/1.8,/opt/local/lib/ruby/1.8/i686-darwin9.2.0,.
set path+=/opt/local/share/swig/1.3.33/ruby,/opt/local/share/swig/1.3.33
set makeprg=make\ -f\ Makefile.swig
set isfname+=\ 
set errorformat^=%f:%l:\ %m
au BufNewFile,BufRead Makefile* setf make
au BufNewFile,BufRead *.i setf swig
