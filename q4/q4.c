#include <stdio.h>
#include <dlfcn.h>
typedef int (*fptr)(int,int);
int main() {
    char op[7];
    int n1,n2;
    while(scanf("%s %d %d", op,&n1,&n2)!=EOF){
        char library_name[20];
        sprintf(library_name, "./lib%s.so", op);
        void *library=dlopen(library_name,RTLD_LAZY);
        fptr func=dlsym(library, op);  
        int ans=func(n1,n2);
        printf("%d\n",ans);
        dlclose(library); //clear memory
    }
    return 0;
}