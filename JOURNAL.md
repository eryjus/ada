Century Ada Compiler
---

As with all projects, I will keep a journal of my progress on this projects -- not as much as for how to do things, but more for how not to do things.  As with all projects, I expect I will make some really stupid mistakes.

I have been wanting my own compiler for some time -- not just a watered down toy from a class, but something that I can really make ues of.  I recently discovered how flexible LLVM really is and that I should be able to output LLVM code and end up with an executable relatively quickly.

I have always liked Ada because of the threaded features that are already built into the language primitives and the strong static type checking.

---

### 2019-May-17

Well, I have a kernel project going on at the same time.  But I need a small distraction.  So, I figure I will start this for a few days and see if I can get myself back into the kernel.  Like all my projects, I have had several false starts with a compiler, including Ada compilers.  I have have one on [github.com](https://github.com/eryjus/small-ada).  I will be borrowing from that iteration to help speed things along here.

One thing will be about the AST -- will I use a custom-built AST with this project, or will I continue to leverate [ast-cc](https://github.com/eryjus/ast-cc)?  I do not yet have a reference implementation for `ast-cc` and it would be very nice to have one.

Another thing is I think I will use `clang` as my C compiler for this version.  I do prefer `tup` and will continue to use that.  It is also a project to learn some new tools.

Finally, C or C++?  Well, if I am going to use `ast-cc` then it will be C++ for sure.  If I make my own AST, C++ would be better for overloading and inheritence.  So, C++ it is.

---

I have the basic tokens identified for the parser.  Now, the next step is to make sure flex can properly identify the proper UTF-8 characters for in flex -- such as making sure inetifiers do not have illegal code points.

---

### 2019-May-18

Today I downloaded the `icu4c` library from IBM and I am compiling that.  I will use this library to handle the Unicode work.

---

### 2019-May-19

I have gotten the parser to generate and the scanner to generate code as well.  The code is not yet being compiled.

I think the next thing to look at is going to be the string tables -- numbers, identifiers, and strings.

---

I think I have a reasonable scanner.  The last thing to do is to write the function to canonicalize a number.

---

### 2019-May-20

Today I managed to get a dedicated scanner written -- which dumps the values returned by `yylex()`.  Well, the token IDs anyway.  There is some cleanup with the scanner to complete and there is some definite cleanup with the scanner itself.  Several things to mention with this fist execution.
* Comments are not terminating at the end of the line
* Spaces are being recognized as part of an identifier
* Digits are being recognized individually in some cases
* Among others...

So, I am going to start with comments and whitespace.

Whitespace is being consumed by the identifier as part of the `{UANYN}` pattern.  I think I am going to have to make a state for recognizing identifiers, and probably set that in the final rule.

---

### 2019-May-21

Mode debugging.

---

### 2019-May-22

I think I have this all worked out.  Strings are working; identifiers are working; comments are working; numbers are working.  At least as far as recognition.  I have not yet been able to validate that all the different components are interpreted properly.

So, the next step is going to be to complete the scanner and output the tokens formally in a manner that gives concrete data for later troubleshooting.

---

I did find a bug canonicalizing numbers.  This is next to take care of.

---

### 2019-May-24

I think I have the debugging complete.  All the errors are resolved and all the tokens and values are coming back correct.  After cleaning this up and setting some debugging macros, I am ready for a commit.  But I need to create the public repo as well.

