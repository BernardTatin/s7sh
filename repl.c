#include <stdio.h>
#include <stdlib.h>


#include "s7.h"
#include "repl-s7.h"

static char *progname = NULL;
static const char *version = "v0.0.1";

static void dohelp(const int exit_code) {
    fprintf(stdout, "%s [-h|-v|-q]\n", progname);
    fprintf(stdout, "  -h: show this text and exits\n");
    fprintf(stdout, "  -v: show version and exits\n");
    fprintf(stdout, "  -q: quiet, suppress some messages\n");
    exit (exit_code);
}

static void doversion(const int exit_code) {
    fprintf(stdout, "%s version %s (%s)\n", progname, version, __DATE__);
    exit (exit_code);
}

int main(int argc, char **argv) {
    int ret_value = SUCCESS;
    s7_scheme *sc;
    sc = s7_init();
    bool is_quiet = false;

    progname = argv[0];
    if (argc > 1) {
        int i;
        for (i=1; i<argc && *(argv[i]) == '-' && ret_value==SUCCESS; i++) {
            char *current_arg = argv[i] + 1;
            if (*(current_arg+1) == 0) {
                switch (*current_arg) {
                    case 'h':
                        dohelp(SUCCESS);
                        break;
                    case 'v':
                        doversion(SUCCESS);
                        break;
                    case 'q':
                        is_quiet = true;
                        break;
                    default:
                        fprintf(stderr, "unknown flag (%c)\n", *current_arg);
                        dohelp(FAILURE);
                        break;
                }
            }
        }
        for (; i<argc && ret_value==SUCCESS; i++) {
            if (!is_quiet) {
                fprintf(stderr, "load %s\n", argv[i]);
            }
            if (!s7_load(sc, argv[i])) {
                fprintf(stderr, "can't load %s\n", argv[i]);  /* it could also be a directory */
                ret_value = FAILURE;
            }
        }
    } else {
        s7_load(sc, "repl.scm");
        s7_eval_c_string(sc, "((*repl* 'run))");
    }
    return ret_value;
}

/* gcc -o repl repl.c s7.o -Wl,-export-dynamic -lm -I. -ldl
*/
