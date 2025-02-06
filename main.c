#include <stdio.h>
#include <string.h>
#include "libstr.h"

int main(void) {
    char str1[MAX_STR] = {0}, str2[MAX_STR] = {0};
    char continueChoice;

    while (1) {
        puts("Enter two strings to compute the Hamming distance:");
        memset(str1, 0, MAX_STR);
        memset(str2, 0, MAX_STR);
        scanf("%s %s", str1, str2);
        int result = hamming_dist(str1, str2);
        printf("Hamming distance: %d\n", result);
        printf("Do you want to compute another Hamming distance? (y/n): ");
        getchar(); 
        scanf("%c", &continueChoice);

        if (continueChoice == 'n' || continueChoice == 'N') {
            puts("Exiting program. Goodbye!");
            break;
        }
    }

    return 0;
}
