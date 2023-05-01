#include "helloworld.h"

#include <stdint.h>
#include <stdio.h>

void hw_hello_world()
{
    printf("Hello world from C!\n");
}

void hw_print_string(const char* s)
{
    printf("%s\n", s);
}