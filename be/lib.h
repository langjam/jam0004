#include <string.h>
#include <stdlib.h>
#include <stdio.h>

struct arg
{
    int type; // 1: s->t, 2: "constant", 3: ?, 4: ...
    char *value;
    char *param;
};

struct step
{
    int type; // 1: print, 2: function
    unsigned char fu;
    struct arg *args;
    int args_len;
    unsigned char param_table[255];
};

struct function_decl
{
    char *name;
    char **param_names;
    struct step *steps;
    unsigned char index_param_names;
    unsigned char index_steps;
    unsigned char done;
};

unsigned char hash(unsigned char *str)
{
    unsigned char hash = 0;
    for (int i = 0; i < 30 && str[i] != '\0'; ++i)
        hash += str[i];
    return hash % 255;
}

struct function_decl unsafe_fn_table[256];
struct function_decl *current_function;

struct step main_steps[10];
char main_steps_len = 0;

struct step *current_step = NULL;

void push_function(const char *_name)
{
    int len = strlen(_name) - 1;
    char *name = (char *)malloc(sizeof(char) * len);
    memcpy(name, _name, sizeof(char) * len);
    name[len - 1] = '\0';
    unsigned char index = hash((unsigned char *)name);
    unsafe_fn_table[index].name = name;
    unsafe_fn_table[index].param_names = (char **)malloc(sizeof(char *) * 5);
    unsafe_fn_table[index].steps = (struct step *)calloc(sizeof(struct step) * 5, 0);
    unsafe_fn_table[index].index_param_names = 0;
    unsafe_fn_table[index].index_steps = 0;
    unsafe_fn_table[index].done = 0;
    current_function = &unsafe_fn_table[index];
}

struct code
{
    char *content;
    int capa;
};

void concat(struct code *code, char *c)
{
    if (code->capa == 0)
    {
        code->content = (char *)malloc(sizeof(char) * 1024);
        code->capa = 1024;
        strcpy(code->content, c);
        return;
    }
    if (strlen(c) + strlen(code->content) >= code->capa)
    {
        code->capa *= 2;
        code->content = (char *)realloc(code->content, sizeof(char) * code->capa);
    }
    code->content = strcat(code->content, c);
}

const char *n[10] = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10"};

void dump_step(struct code *code, struct step *step, int index)
{
    concat(code, "\nvoid step_");
    concat(code, (char *)n[index]);
    concat(code, "_");
    concat(code, current_function->name);
    concat(code, "(struct s_");
    concat(code, current_function->name);
    concat(code, " *s) {\n");
    if (step->type == 1) // print
    {
        concat(code, "\tprintf(\"");
        for (int i = 0; i < step->args_len; ++i)
            concat(code, "\%s ");
        concat(code, "\\n\"");
        for (int i = 0; i < step->args_len; ++i)
        {
            concat(code, ", ");
            if (step->args[i].type == 2)
            {
                concat(code, "\"");
                concat(code, step->args[i].value);
                concat(code, "\"");
            }
            else
            {
                concat(code, "s->");
                concat(code, step->args[i].value);
            }
        }
        concat(code, ");\n");
    }
    else if (step->type == 3) // user defined function call
    {
        concat(code, "\tstruct s_");
        concat(code, unsafe_fn_table[step->fu].name);
        concat(code, " ");
        concat(code, unsafe_fn_table[step->fu].name);
        concat(code, ";\n\t");

        for (int i = 0; i < step->args_len; ++i)
        {
            concat(code, unsafe_fn_table[step->fu].name);
            concat(code, ".");
            concat(code, step->args[i].param);
            concat(code, " = ");
            if (step->args[i].type == 1)
                concat(code, "s->");
            concat(code, step->args[i].value);
            concat(code, ";\n\t");
        }

        concat(code, "f_");
        concat(code, unsafe_fn_table[step->fu].name);
        concat(code, "(&");
        concat(code, unsafe_fn_table[step->fu].name);
        concat(code, ");\n\t");
    }
    concat(code, "}\n");
}

int steps_param_dependencies(struct step *step, struct arg *deps[10])
{
    int ret = 0;
    for (int i = 0; i < step->args_len; ++i)
    {
        if (step->args[i].type == 1)
        {
            deps[ret] = &step->args[i];
            ++ret;
        }
    }
    return ret;
}

void dump_function()
{
    struct code code = {NULL, 0};
    concat(&code, "\nstruct s_");

    concat(&code, current_function->name);
    concat(&code, "\n{\n");

    for (int i = 0; i < current_function->index_param_names; ++i)
    {
        concat(&code, "\tchar *");
        concat(&code, current_function->param_names[i]);
        concat(&code, ";\n");
        concat(&code, "\tchar state_");
        concat(&code, current_function->param_names[i]);
        concat(&code, ";\n");
    }

    concat(&code, "\tint step;\n");
    concat(&code, "};\n");

    for (int i = 0; i < current_function->index_steps; ++i)
        dump_step(&code, &current_function->steps[i], i);

    concat(&code, "\nvoid f_");
    concat(&code, current_function->name);
    concat(&code, "(struct s_");
    concat(&code, current_function->name);
    concat(&code, " *s) {\n");

    struct arg *deps[10];

    for (int i = 0; i < current_function->index_steps; ++i)
    {
        concat(&code, "\tif (s->step < ");
        concat(&code, (char *)n[i]);
        concat(&code, ") return;\n");

        concat(&code, "\tif (s->step == ");
        concat(&code, (char *)n[i]);

        int deps_len = steps_param_dependencies(&current_function->steps[i], deps);
        for (int j = 0; j < deps_len; ++j)
        {
            concat(&code, " && s->state_");
            concat(&code, deps[j]->value);
            concat(&code, " == 0");
        }

        concat(&code, ")\n\t{\n\t");
        concat(&code, "\tstep_");
        concat(&code, (char *)n[i]);
        concat(&code, "_");
        concat(&code, current_function->name);
        concat(&code, "(s);\n");
        concat(&code, "\t\ts->step++;\n");
        concat(&code, "\t}\n");
        for (int j = 0; j < deps_len; ++j)
        {
            concat(&code, "\telse if (s->state_");
            concat(&code, deps[j]->value);
            concat(&code, " == 2)\n\t{\n");
            concat(&code, "\t\tchar *buffer = malloc(sizeof(char) * 30);\n");
            concat(&code, "\t\tprintf(\"Please enter a value for the parameter \\\"\%s\\\"\\n\", \"");
            concat(&code, deps[j]->value);
            concat(&code, "\");\n");
            concat(&code, "\t\tint _ = scanf(\"\%29s\", &buffer[0]);\n");
            concat(&code, "\t\ts->");
            concat(&code, deps[j]->value);
            concat(&code, " = buffer;\n");
            concat(&code, "\t\ts->state_");
            concat(&code, deps[j]->value);
            concat(&code, " = 0;\n");
            concat(&code, "\t\tf_");
            concat(&code, current_function->name);
            concat(&code, "(s);\n");
            concat(&code, "\t}\n");
        }
    }
    concat(&code, "}\n");

    current_function = NULL;
    current_step = NULL;
    FILE *f = fopen("clap.c", "a");
    fprintf(f, "%s", code.content);
    fclose(f);
}

void free_current_function()
{
    // todo
}

void push_parameter(const char *name)
{
    int len = strlen((char *)name) - 2;
    char *param = (char *)malloc(sizeof(char) * len);
    strcpy(param, &name[1]);
    current_function->param_names[current_function->index_param_names++] = param;
}

void push_step(char type)
{
    struct arg *args = (struct arg *)malloc(sizeof(struct arg) * 5);

    if (current_function)
    {
        current_function->steps[current_function->index_steps].type = type;
        current_function->steps[current_function->index_steps].args = args;
        current_function->steps[current_function->index_steps].args_len = 0;
        current_step = &current_function->steps[current_function->index_steps];
        current_function->index_steps++;
    }
    else
    {
        main_steps[main_steps_len].type = type;
        main_steps[main_steps_len].args = args;
        main_steps[main_steps_len].args_len = 0;
        current_step = &main_steps[main_steps_len];
        main_steps_len++;
    }
}

void push_print()
{
    push_step(1);
}

void push_function_call(const char *_name)
{
    char *name = (char *)malloc(sizeof(char) * (strlen(_name) - 1));
    strcpy(name, _name);
    // On peut déjà trouver ici si la fonction à ou non été déclarée.
    unsigned char fu = hash((unsigned char *)name);
    if (strcmp(unsafe_fn_table[fu].name, name) != 0)
        exit(13);

    push_step(3);
    current_step->fu = fu;
}

void push_arg_name(const char *word, const char *name)
{
    // test current step, args et s'il n'existe.

    int len = strlen(name) - 1;
    current_step->args[current_step->args_len].value =
        (char *)malloc(sizeof(char) * len);
    current_step->args[current_step->args_len].param =
        (char *)malloc(sizeof(char) * strlen(word));
    strcpy(current_step->args[current_step->args_len].param, word);
    strcpy(current_step->args[current_step->args_len].value, &name[1]);
    current_step->args[current_step->args_len].type = 1;
    current_step->param_table[hash((unsigned char *)name)] = 1;
    current_step->args_len++;
}

void push_arg_const(const char *word, const char *value)
{
    // test current step, args et s'il n'existe.
    current_step->args[current_step->args_len].value =
        (char *)malloc(sizeof(char) * strlen(value));
    current_step->args[current_step->args_len].param =
        (char *)malloc(sizeof(char) * strlen(word));
    strcpy(current_step->args[current_step->args_len].param, word);
    strcpy(current_step->args[current_step->args_len].value, value);
    current_step->args[current_step->args_len].type = 2;
    current_step->param_table[hash((unsigned char *)word)] = 1;
    current_step->args_len++;
}

// Print sugar X to s=X
void push_arg_print(const char *name)
{
    if (current_step->type != 1)
        exit(12);

    int len = strlen(name) - 1;
    current_step->args[current_step->args_len].value =
        (char *)malloc(sizeof(char) * len);
    current_step->args[current_step->args_len].param = "s";
    strcpy(current_step->args[current_step->args_len].value, &name[1]);
    current_step->args[current_step->args_len].type = 1;
    current_step->args_len++;
}

// Print sugar X to s=X
void push_arg_print_const(const char *name)
{
    if (current_step->type != 1)
        exit(12);

    int len = strlen(name) - 1;
    current_step->args[current_step->args_len].value =
        (char *)malloc(sizeof(char) * len);
    current_step->args[current_step->args_len].param = "s";
    strcpy(current_step->args[current_step->args_len].value, name);
    current_step->args[current_step->args_len].type = (char)2;
    current_step->args_len++;
}

void push_arg_curry(const char *word)
{
    current_step->args[current_step->args_len].param =
        (char *)malloc(sizeof(char) * strlen(word));
    strcpy(current_step->args[current_step->args_len].param, word);
    current_step->args[current_step->args_len].type = 4;
    current_step->args[current_step->args_len].value = NULL;
    current_step->param_table[hash((unsigned char *)word)] = 1;
    current_step->args_len++;
}

void push_arg_alge(const char *word)
{
    current_step->args[current_step->args_len].param =
        (char *)malloc(sizeof(char) * strlen(word));
    strcpy(current_step->args[current_step->args_len].param, word);
    current_step->args[current_step->args_len].type = 3;
    current_step->args[current_step->args_len].value = NULL;
    current_step->param_table[hash((unsigned char *)word)] = 1;
    current_step->args_len++;
}

void fill_curryfication()
{
    // const CHAR const const const CHAR const const...
    const char const *const *args = (const char const *const *)
                                        unsafe_fn_table[current_step->fu]
                                            .param_names;

    for (int i = 0; i < unsafe_fn_table[current_step->fu].index_param_names; ++i)
        if (current_step->param_table[hash((unsigned char *)args[i])] == 0)
            push_arg_curry(args[i]);
}

void fill_algebraic()
{
    // const CHAR const const const CHAR const const...
    const char const *const *args = (const char const *const *)
                                        unsafe_fn_table[current_step->fu]
                                            .param_names;

    for (int i = 0; i < unsafe_fn_table[current_step->fu].index_param_names; ++i)
        if (current_step->param_table[hash((unsigned char *)args[i])] == 0)
            push_arg_alge(args[i]);
}

void dump_main()
{
    struct code code = {NULL, 0};
    concat(&code, "\nint main(void)\n");
    concat(&code, "{\n");

    for (int i = 0; i < main_steps_len; ++i)
    {
        if (main_steps[i].type == 3) // user defined function call
        {
            if (unsafe_fn_table[main_steps[i].fu].done == 0)
            {
                concat(&code, "\tstruct s_");
                concat(&code, unsafe_fn_table[main_steps[i].fu].name);
                concat(&code, " ");
                concat(&code, unsafe_fn_table[main_steps[i].fu].name);
                concat(&code, " = {.step = 1};\n");
                unsafe_fn_table[main_steps[i].fu].done = 1;
            }
            for (int d = 0; d < main_steps[i].args_len; ++d)
            {
                concat(&code, "\t");
                if (main_steps[i].args[d].type == 3)
                {
                    concat(&code, unsafe_fn_table[main_steps[i].fu].name);
                    concat(&code, ".state_");
                    concat(&code, main_steps[i].args[d].param);
                    concat(&code, " = 2;\n");
                    continue;
                }
                if (main_steps[i].args[d].type == 4)
                {
                    concat(&code, unsafe_fn_table[main_steps[i].fu].name);
                    concat(&code, ".state_");
                    concat(&code, main_steps[i].args[d].param);
                    concat(&code, " = 1;\n");
                    continue;
                }
                concat(&code, unsafe_fn_table[main_steps[i].fu].name);
                concat(&code, ".");
                concat(&code, main_steps[i].args[d].param);
                concat(&code, " = ");
                if (main_steps[i].args[d].type == 1)
                {
                    concat(&code, "s->");
                    concat(&code, main_steps[i].args[d].value);
                }
                else if (main_steps[i].args[d].type == 2)
                {
                    concat(&code, "\"");
                    concat(&code, main_steps[i].args[d].value);
                    concat(&code, "\"");
                }
                concat(&code, ";\n\t");
                concat(&code, unsafe_fn_table[main_steps[i].fu].name);
                concat(&code, ".state_");
                concat(&code, main_steps[i].args[d].param);
                concat(&code, " = 0;\n\t");
            }

            concat(&code, "\tf_");
            concat(&code, unsafe_fn_table[main_steps[i].fu].name);
            concat(&code, "(&");
            concat(&code, unsafe_fn_table[main_steps[i].fu].name);
            concat(&code, ");\n\t");
        }
        else if (main_steps[i].type == 1) // user defined function call
        {
            if (main_steps[i].type == 1) // print
            {
                concat(&code, "printf(\"");
                for (int d = 0; d < main_steps[i].args_len; ++d)
                    concat(&code, "\%s ");
                concat(&code, "\\n\"");
                for (int d = 0; d < main_steps[i].args_len; ++d)
                {
                    concat(&code, ", ");
                    if (main_steps[i].args[d].type == 2)
                    {
                        concat(&code, "\"");
                        concat(&code, main_steps[i].args[d].value);
                        concat(&code, "\"");
                    }
                    else
                    {
                        exit(15);
                    }
                }
                concat(&code, ");\n");
            }
        }
    }
    concat(&code, "\r}\n");
    FILE *f = fopen("clap.c", "a");
    fprintf(f, "%s", code.content);
    fclose(f);
}