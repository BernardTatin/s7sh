# A shell from s7 Scheme? A shell from s7 Scheme!

I took the _[s7](https://ccrma.stanford.edu/software/snd/snd/s7.html)_ code because I love the presentation page (light style, good content) and the binding of C language. It is in the hope to write my shell (as _bash_, _zsh_, ...) with the _[Scheme](https://schemers.org/)_ language. It is an early version *which can break the original code*.

## first steps: `REPL`

The big work is a `REPL` version with a full configuration thanks to files or command line options. Because I am not _Windows friendly_, all the work is done on _Linux_ and (later) _BSD_ systems. Here is what is working.

### compilation

There is a `Makefile` for the _GNU_ version of  `make` (`gmake` on _BSD_ systems).  The target are the following:

- `all`: compile `repl-s7`,
- `clean`: delete all the compilation products,
- `install`: install all that stuff in `/usr/local` (or elsewhere after editing the `PREFIX` variable), not implemented today,
- `full-clean`: call the `clean` target and remove all object files and dynamic libraries created by running `repl-s7`,
- `test` and `test-load` are deprecated tests.

### configuration file(s)

**mid October 2019** : There is only one configuration file, `~/.shs7.scm`, which must be filled by the user.  It is loaded only in interactive mode (see _modes_ below).  There is one sample in the `s7` directory. 