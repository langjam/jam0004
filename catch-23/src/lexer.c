#include "tokens.h"
#include "stdio.h"
#include "stdlib.h"

char* scan(const char* source_code) {
    
    FILE* file = fopen(source_code, "r");
    char* result;
    
    if (file == NULL) *result = -1;
    
    else {
        
        fseek(file, 0, SEEK_END);
        
        long size = ftell(file) + 1;
        char* result = malloc(size);
        
        fseek(file, 0, SEEK_SET);
        
        if (result) {
            
            fread(result, 1, size, file);
            result[size - 1] = '\0'; 
        }
    }
    
    fclose(file);
    
    return result;
}

/*
static token* resize_token_array(token* arr) {
    
}
*/

token* tokenize(const char* source_code) {
    
    token* result;
}
