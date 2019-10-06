#include <stdio.h>
#include <stdlib.h>

#include "s7.h"
#include "repl-s7.h"

int main(int argc, char **argv) {
    int ret_value = SUCCESS;
    s7_scheme *sc;
    sc = s7_init();

    if (argc > 1) {
        for (int i=1; i<argc && ret_value==SUCCESS; i++) {
            fprintf(stderr, "load %s\n", argv[i]);
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
