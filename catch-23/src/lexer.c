#include "tokens.h"
#include "stdio.h"
#include "stdlib.h"

char* scan(const char* source_code) {
    
    FILE* file = fopen(source_code, "r");
    char* result;
    
    if (file == NULL) *result = -1;
    
    else {
        
        fseek(file, 0, SEEK_END);
        
        long size = ftell(file);
        char* result = malloc(size);
        
        fseek(file, 0, SEEK_SET);
        
        if (result) 
            fread(result, 1, size, file);
    }
    
    fclose(file);
    
    return result;
}
//token* tokenize(const char* source_code);
