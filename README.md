# Ada Compiler


This project is part of the Century Project -- an OS and tool set that are expected to take more than a century to complete.

## Build System

I use `tup` as my build system.  `tup` will need to be installed on your system and located somewhere in your path.  See http://gittup.org/tup/ for more information.  A `Makefile` is provided for convenience, which simply executes `tup`.

## Unicode Support

The Ada compiler supports Unicode Code Points.  For this support, I use `icu4c`.  This will need to be installed on your system.  See http://site.icu-project.org/ for more infomration.  This was built with the ICU 64.2 version, but the latest should work as well.  Additionally, you should be able to update this libaray to get the latest Unicode standard support without having to rebuild the Ada compiler.

