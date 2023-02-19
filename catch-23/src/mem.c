#include <stdlib.h>
#include "mem.h"

struct DestroyListS {
    void **pointers;
    size_t pointers_len;
};

DestroyList destroy_list_create()
{
    DestroyList l = malloc(sizeof(struct DestroyListS));
    *l = (struct DestroyListS){0};
    return l;
}

static void pointer_append(DestroyList l, void *pointer)
{
    l->pointers = (void**)realloc(l->pointers, (l->pointers_len+1)*(sizeof *l->pointers));
    l->pointers[l->pointers_len++] = pointer;
}

void *destroy_list_alloc(DestroyList l, size_t bytes)
{
    void *ptr = malloc(bytes);
    if (ptr == NULL) {
        return NULL;
    }

    pointer_append(l, ptr);
    return ptr;
}

void destroy_list_destroy(DestroyList l)
{
    for (int i = 0; i < l->pointers_len; i++) {
        free(l->pointers[i]);
    }
    free(l->pointers);
}