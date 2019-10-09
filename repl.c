#include <stdio.h>
#include <stdlib.h>


#include "s7.h"
#include "repl-s7.h"

static char *progname = NULL;
static const char *version = "v0.0.1";
static char *base_scm_lib[] = {
    "cload.scm",
    "more-tests/path-to-list.scm",
    NULL
};

// fopen does not like ~/filename !!!
// we must find a way to expand this
#define S7_USER_CONFIG ".shs7.scm"
char s7_user_conf_name[512] = "";
static char *ui_scm_lib[] = {
    S7_USER_CONFIG,
    "repl.scm",
    NULL
};
static bool is_quiet = false;
static bool is_batch = false;

static void dohelp(const int exit_code) {
    fprintf(stdout, "%s [-h|-v|-qb]\n", progname);
    fprintf(stdout, "  -h: show this text and exits\n");
    fprintf(stdout, "  -v: show version and exits\n");
    fprintf(stdout, "  -q: quiet, suppress some messages\n");
    fprintf(stdout, "  -b: batch, executes files and quit, implies -q\n");
    exit (exit_code);
}

static void show_version(void) {
    fprintf(stdout, "%s version %s (%s - %s)\n",
            progname, version, __DATE__, __TIME__);
}
static void doversion(const int exit_code) {
    show_version();
    exit (exit_code);
}

static int load_scm(s7_scheme *sc, const char *file_name) {
    int ret_value = SUCCESS;

    if (!is_quiet) {
        fprintf(stdout, "loading %s...\n", file_name);
    }
    if (!s7_load(sc, file_name)) {
        fprintf(stderr, "Cannot load %s\n", file_name);
        ret_value = FAILURE;
    }
    return ret_value;
}

static int load_scm_files(s7_scheme *sc, char *scm_files[]) {
    int ret_value = SUCCESS;

    for (int k=0; ret_value == SUCCESS && scm_files[k] != NULL; k++) {
        ret_value = load_scm(sc, scm_files[k]);
    }
    return ret_value;
}
static int load_base_lib(s7_scheme *sc) {
    return load_scm_files(sc, base_scm_lib);
}

static int load_ui_lib(s7_scheme *sc) {
    return load_scm_files(sc, ui_scm_lib);
}

static void ensure_user_conf_exists(void) {
    sprintf(s7_user_conf_name, "%s/%s", getenv("HOME"), S7_USER_CONFIG);
    // bad hack !!!!
    ui_scm_lib[0] = s7_user_conf_name;
    FILE *s7_config_file = fopen(s7_user_conf_name, "r");
    if (s7_config_file == NULL) {
        s7_config_file = fopen(s7_user_conf_name, "w");
        if (s7_config_file != NULL) {
            fprintf(s7_config_file, ";; %s - created on %s - %s\n\n",
                    s7_user_conf_name, __DATE__, __TIME__);
            fprintf(s7_config_file, "(format #t \"%s loaded !!!~\% \")",
                    S7_USER_CONFIG);
        }
    }
    if (s7_config_file != NULL) {
        fclose(s7_config_file);
    }
}

int main(int argc, char **argv) {
    int ret_value = SUCCESS;
    int i;
    s7_scheme *sc;
    sc = s7_init();

    progname = argv[0];
    for (i=1; i<argc && *(argv[i]) == '-' && ret_value==SUCCESS; i++) {
        char *current_arg = argv[i] + 1;
        while (*current_arg != 0) {
            switch (*current_arg) {
                case 'h':
                    dohelp(SUCCESS);
                    break;
                case 'v':
                    doversion(SUCCESS);
                    break;
                case 'b':
                    is_batch = true;
                    is_quiet = true;
                    break;
                case 'q':
                    is_quiet = true;
                    break;
                default:
                    fprintf(stderr, "unknown flag (-%c)\n", *current_arg);
                    dohelp(FAILURE);
                    break;
            }
            current_arg++;
        }
    }
    if (!is_batch) {
        ensure_user_conf_exists();
        ret_value = load_ui_lib(sc);
    }
    if (ret_value == SUCCESS) {
        ret_value = load_base_lib(sc);
        for (; i<argc && ret_value==SUCCESS; i++) {
            ret_value = load_scm(sc, argv[i]);
        }
        if (ret_value == SUCCESS && !is_batch) {
            if (!is_quiet) {
                show_version();
            }
            s7_eval_c_string(sc, "((*repl* 'run))");
        }
    }
    return ret_value;
}

/* gcc -o repl repl.c s7.o -Wl,-export-dynamic -lm -I. -ldl
*/
