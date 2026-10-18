#include <climits>
#include <stdio.h>
#include "moving_max.h"

static void reference(const int x[N_SAMPLES], int y[N_SAMPLES]) {
    int window[WINDOW];
    for (int k = 0; k < WINDOW; k++) {
        window[k] = INT_MIN;
    }

    int window_max    = INT_MIN;
    int window_header = 0;
    int window_last   = INT_MIN;
    
    for (int i = 0; i < N_SAMPLES; i++) {
        window_last = window[window_header];
        
        window[window_header] = x[i];
        
        window_header++;
        if (window_header == WINDOW) {
            window_header = 0;
        }
        
        if (window_max == window_last) {
            window_max = INT_MIN;
            for (int k = 0; k < WINDOW; k++) {
                if (window_max < window[k]) {
                    window_max = window[k];
                }
            }
        } else {
            if (x[i] > window_max) {
                window_max = x[i];
            }
        }

        y[i] = window_max;
    }
}

int main() {
    int errors = 0;
    unsigned seed = 12345;

    /* Три виклики поспіль -- щоб co-simulation могла виміряти II між транзакціями */
    for (int t = 0; t < 5; t++) {
        int in_data[N_SAMPLES], out_data[N_SAMPLES], golden[N_SAMPLES];

        for (int n = 0; n < N_SAMPLES; n++) {
            seed = seed * 1103515245u + 12345u;   /* простий повторюваний генератор */
            in_data[n] = (int)((seed >> 16) % 1000);
        }

        reference(in_data, golden);
        moving_max(in_data, out_data);

        for (int n = 0; n < N_SAMPLES; n++) {
            if (out_data[n] != golden[n]) {
                printf("MISMATCH: виклик %d, відлік %d: DUT=%d, еталон=%d\n",
                       t, n, out_data[n], golden[n]);
                errors++;
            }
        }
    }

    if (errors == 0) {
        printf("Test passed !\n");
        return 0;
    }
    printf("Test FAILED: %d помилок\n", errors);
    return 1;
}