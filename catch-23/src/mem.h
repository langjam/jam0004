#include <stdint.h>

// NOTE: uses malloc
typedef struct DestroyListS *DestroyList;

DestroyList destroy_list_create();
void *destroy_list_alloc(DestroyList l, size_t bytes);
void destroy_list_destroy(DestroyList l);

