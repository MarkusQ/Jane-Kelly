#include <stdio.h>
#include <stdlib.h>
#define program int
#define Example(a,b) main()
#define begin {
#define writeln(s) printf(dequote(#s)); printf("\n");
#define end }

char* dequote(char* str) {
    char *result;
    int pass,r,w;
    for (pass=1;pass <= 2;pass++) {
        for(r=0,w=0;str[r] != '\0';r++) {
            if (pass==2) result[w] = str[r];
            if ((str[r+1] == '\'') || (str[r] != '\'')) w++;
            };
        if (pass==1) result=malloc(sizeof(char)*(w+1));
        }
    result[w]='\0';
    return result;
    }

program Example(Input,Output)
    begin
    writeln('What''s it Wirth to you?')
    end

