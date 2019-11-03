/*
 * repl.c
 * REPL for a shell in s7 Scheme
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <libgen.h>
#include <string.h>


#include "s7.h"
#include "repl-s7.h"

static char *progname = NULL;
static char *s7_home = NULL;
static char *s7_libs = NULL;

static char *base_scm_lib[] = {
    "cload.scm",
    "libc.scm",
    "libdl.scm",
    "basic-lib.scm",
    "path-to-list.scm",
    NULL
};

char s7_user_conf_name[512] = "";
static char *ui_scm_lib[] = {
    S7_USER_CONFIG,
    "repl.scm",
    NULL
};
static bool is_quiet = false;
static bool is_batch = false;
// 4096, $PATH can be very long...
static char scm_code_buffer[SCM_CODE_BUFFER_LEN];

static void dohelp(const int exit_code) {
    fprintf(stdout, "%s [-h|-v|-qb] [-L dir-lib]\n", progname);
    fprintf(stdout, "  -h: show this text and exits\n");
    fprintf(stdout, "  -v: show VERSION and exits\n");
    fprintf(stdout, "  -q: quiet, suppress some messages\n");
    fprintf(stdout, "  -b: batch, executes files and quit, implies -q\n");
    fprintf(stdout, "  -L dir-lib: add dir-lib to *load-path*\n");
    exit (exit_code);
}

static void show_VERSION(void) {
    fprintf(stdout, "%s VERSION %s (%s - %s)\n",
            progname, VERSION, __DATE__, __TIME__);
}
static void do_VERSION(const int exit_code) {
    show_VERSION();
    exit (exit_code);
}

static int autoload_scm(s7_scheme *sc, char *file_name) {
    // TODO: verify memory leaks
    // function basename is not clear
    char *file_name_2 = strdup(file_name);
    char *symbol = basename(file_name_2);
    int ret_value = SUCCESS;

    if (!is_quiet) {
        fprintf(stdout, "autoloading %s...\n", file_name);
    }
    sprintf(scm_code_buffer, "(autoload '%s \"%s\")", symbol, file_name);
    s7_eval_c_string(sc, scm_code_buffer);
    free(file_name_2);
    return ret_value;
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

static int autoload_scm_files(s7_scheme *sc, char *scm_files[]) {
    int ret_value = SUCCESS;

    for (int k=0; ret_value == SUCCESS && scm_files[k] != NULL; k++) {
        ret_value = autoload_scm(sc, scm_files[k]);
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
    return autoload_scm_files(sc, base_scm_lib);
}

static int load_ui_lib(s7_scheme *sc) {
    return load_scm_files(sc, ui_scm_lib);
}

static int ensure_user_conf_exists(void) {
    int ret_value = SUCCESS;

    sprintf(s7_user_conf_name, "%s/%s", getenv("HOME"), S7_USER_CONFIG);
    // TODO: remove this bad hack !!!!
    ui_scm_lib[0] = s7_user_conf_name;
    FILE *s7_config_file = fopen(s7_user_conf_name, "r");
    if (s7_config_file == NULL) {
        s7_config_file = fopen(s7_user_conf_name, "w");
        if (s7_config_file != NULL) {
            fprintf(s7_config_file, ";; %s - created on %s - %s\n\n",
                    s7_user_conf_name, __DATE__, __TIME__);
            fprintf(s7_config_file, "(format #t \"%s loaded !!!~%% \")",
                    S7_USER_CONFIG);
        } else {
            ret_value = FAILURE;
        }
    }
    if (s7_config_file != NULL) {
        fclose(s7_config_file);
    }
    return ret_value;
}

static char *strue = "#t";
static char *sfalse = "#f";
static inline char *Cbool_to_Sbool(const bool b) {
    if (b) {
        return strue;
    } else {
        return sfalse;
    }
}

static bool is_read_dir(char *dir_name) {
    struct stat statbuf;
    if (stat(dir_name, &statbuf) != 0) {
        return false;
    } else if ((statbuf.st_mode & S_IFMT) != S_IFDIR) {
        return false;
    } else {
        return true;
    }
}

static void add_lib_dir(s7_scheme *sc, const char *lib_dir) {
    sprintf(scm_code_buffer,
            "(set! *load-path* (cons \"%s\" *load-path*))",
            lib_dir);
    s7_eval_c_string(sc, scm_code_buffer);
}
static void set_scm_conf_bool(s7_scheme *sc, const char *bname, const bool bvalue) {
    sprintf(scm_code_buffer, "(define-constant %s %s)",
            bname, Cbool_to_Sbool(bvalue));
    s7_eval_c_string(sc, scm_code_buffer);
}
static void set_scm_configuration(s7_scheme *sc) {
    set_scm_conf_bool(sc, "*quiet*", is_quiet);
    set_scm_conf_bool(sc, "*batch*", is_batch);
}

static void set_scm_env_var(s7_scheme *sc, char *scm_varname, char *sh_varname) {
    sprintf(scm_code_buffer, "(define-constant %s \"%s\")",
            scm_varname, getenv(sh_varname));
    s7_eval_c_string(sc, scm_code_buffer);
}
static void set_scm_environment(s7_scheme *sc) {
    set_scm_env_var(sc, "*home*", "HOME");
    set_scm_env_var(sc, "*base-path*", "PATH");
    set_scm_env_var(sc, "*editor*", "EDITOR");
    set_scm_env_var(sc, "*user*", "USER");
}

static char *concat(char *s1, char *s2) {
    int len1 = strlen(s1);
    int len2 = strlen(s2);
    char *ret_str = (char *)calloc(len1 + len2 + 2, 1);
    char *ptr = ret_str;

    strcpy(ptr, s1);
    ptr += len1;
    *(ptr++) = '/';
    strcpy(ptr, s2);
    return ret_str;
}

static void clean_on_exit(void ) {
    if (s7_libs != NULL) {
        free(s7_libs);
        s7_libs = NULL;
    }
    if (s7_home != NULL) {
        free(s7_home);
        s7_home = NULL;
    }
}
static void manage_directories(s7_scheme *sc, char *argv0) {
    progname = basename(argv0);
    s7_home = dirname(argv0);
    char *start_dir = NULL;
    // fprintf(stdout, "s7_home  : <%s> (DEBUG)\n", s7_home);
    switch (*s7_home) {
        case '.':
            // current dir or upper (..)
            if (*(s7_home + 1) == '.') {
                start_dir = concat(strdup(dirname(getcwd(NULL, 0))), s7_home + 2);
            } else {
                start_dir = concat(strdup(getcwd(NULL, 0)), s7_home + 1);
            }
            break;
        case '/':
            // absolute dir, nothing to do
            start_dir = strdup(s7_home);
            break;
        default:
            // relative dir
            start_dir = concat(getcwd(NULL, 0), s7_home);
            break;
    }
    s7_home = start_dir;
    s7_libs = concat(s7_home, "libs");
    atexit(clean_on_exit);
    /*
    fprintf(stdout, "progname : <%s>\n", progname);
    fprintf(stdout, "s7_home  : <%s>\n", s7_home);
    fprintf(stdout, "s7_libs  : <%s>\n", s7_libs);
    fprintf(stdout, "start_dir: <%s>\n", start_dir);
    */
}

int main(int argc, char **argv) {
    int ret_value = SUCCESS;
    int i;
    s7_scheme *sc;
    sc = s7_init();

    manage_directories(sc, argv[0]);
    // fprintf(stderr, "s7_home: <%s>\n", s7_home);
    for (i=1; i<argc && *(argv[i]) == '-' && ret_value==SUCCESS; i++) {
        char *current_arg = argv[i] + 1;
        while (*current_arg != 0) {
            switch (*current_arg) {
                case 'h':
                    dohelp(SUCCESS);
                    break;
                case 'v':
                    do_VERSION(SUCCESS);
                    break;
                case 'b':
                    is_batch = true;
                    is_quiet = true;
                    break;
                case 'q':
                    is_quiet = true;
                    break;
                case 'L':
                    i++;
                    if (i >= argc) {
                        fprintf(stderr, "-L flag needs a directory name\n");
                        dohelp(FAILURE);
                    } else if (!is_read_dir(argv[i])) {
                        fprintf(stderr,
                                "%s is not a directory or you don't have read access\n",
                                argv[i]);
                        dohelp(FAILURE);
                    } else {
                        add_lib_dir(sc, argv[i]);
                    }
                    break;
                default:
                    fprintf(stderr, "unknown flag (-%c)\n", *current_arg);
                    dohelp(FAILURE);
                    break;
            }
            current_arg++;
        }
    }
    add_lib_dir(sc, s7_home);
    add_lib_dir(sc, s7_libs);
    set_scm_configuration(sc);
    set_scm_environment(sc);
    load_scm(sc, concat(s7_libs, "basic-lib.scm"));
    if (ret_value == SUCCESS) {
        ret_value = load_base_lib(sc);
        if (ret_value == SUCCESS && !is_batch) {
            if ((ret_value = ensure_user_conf_exists()) == SUCCESS) {
                ret_value = load_ui_lib(sc);
            }
        }
        for (; i<argc && ret_value==SUCCESS; i++) {
            ret_value = load_scm(sc, argv[i]);
        }
        if (ret_value == SUCCESS && !is_batch) {
            if (!is_quiet) {
                show_VERSION();
            }
            s7_eval_c_string(sc, "((*repl* 'run))");
        }
    }
    return ret_value;
}

/* gcc -o repl repl.c s7.o -Wl,-export-dynamic -lm -I. -ldl
*/
