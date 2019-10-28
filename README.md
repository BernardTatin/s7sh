# A shell from s7 Scheme? A shell from s7 Scheme!

I took the _[s7](https://ccrma.stanford.edu/software/snd/snd/s7.html)_ code because I love the presentation page (light style, good content) and the binding of C language. It is in the hope to write my shell (as _bash_, _zsh_, ...) with the _[Scheme](https://schemers.org/)_ language. It is an early version *which can break the original code*.

## compatibility

| OS       	 	| gcc  | clang   | Sun cc  |
| :------------- 	| ---: | ------: | ------: |
|  **Linux**	 	| OK   | OK      | Todo	   |
|  **Solaris 11.4**  	| OK   | OK      | OK	   |
|  **NetBSD 8**		| NO   | OK      | N/A     |

## first steps: `REPL`

The big work is a `REPL` version with a full configuration thanks to files or command line options. Because I am not _Windows friendly_, all the work is done on _Linux_ and (later) _BSD_ systems. Here is what is working.

### compilation

There is a `Makefile` for the _GNU_ version of  `make` (`gmake` on _BSD_ systems).  The targets are the following:

- `all`: compile `repl-s7`,
- `clean`: delete all the compilation products,
- `install`: install all that stuff in `/usr/local` (or elsewhere after editing the `PREFIX` variable), not implemented today,
- `full-clean`: call the `clean` target and remove all object files and dynamic libraries created by running `repl-s7`,
- `test` and `test-load` are deprecated tests.

### configuration file(s)

**mid October 2019** : There is only one configuration file, `~/.shs7.scm`, which must be filled by the user.  It is loaded only in interactive mode (see _modes_ below).  There is one sample in the `s7` directory. 

### command line arguments

#### help and version

The first flag to know is `-h` which show this help and exits:

```
repl-s7 [-h|-v|-qb] [-L dir-lib] [files ...]
  -h: show this text and exits
  -v: show VERSION and exits
  -q: quiet, suppress some messages
  -b: batch, executes files and quit, implies -q
  -L dir-lib: add dir-lib to *load-path*

```

The second one is `-v` which shows the version:

```
repl-s7 VERSION v0.0.2 (Oct 15 2019 - 16:09:08)
```

#### modes

`repl-s7` runs in two modes:

- **interactive**, where you can enter _Scheme_ code at the prompt,
- **batch**, in which the files of the command line are executed and the interpreter quits at the end of the execution of all files.

#### interactive mode

Without arguments, `repl-s7` loads some libraries, the configuration file(s)and start in interactive mode:

```
$ ./repl-s7
repl-s7 VERSION v0.0.2 (Oct 15 2019 - 16:09:08)
<1>
```

You can add some files:

```
$  ./repl-s7 more-tests/fact.scm
loading more-tests/fact.scm...
repl-s7 VERSION v0.0.2 (Oct 15 2019 - 16:09:08)
<1> (load "more-tests/show-facts.scm")
error: require: no autoload info for fact.scm
<2> (autoload 'fact.scm "fact.scm")
"fact.scm"
<3> (load "more-tests/show-facts.scm")
15! = 1307674368000
14! = 87178291200
13! = 6227020800
...
 2! = 2
 1! = 1
#<unspecified>
<4> 
```

You can add some library path with one or more `-L dirname` options.
