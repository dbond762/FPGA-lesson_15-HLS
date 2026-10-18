#include <climits>
#include "moving_max.h"

/* Ковзний максимум: out_data[n] = найбільше з останніх WINDOW відліків,
   разом із поточним відліком n.
   Допишіть місця, позначені TODO. */
void moving_max(int in_data[N_SAMPLES], int out_data[N_SAMPLES]) {
    int window[WINDOW];      /* тут зберігаються останні WINDOW відліків */
    int window_max = INT_MIN;

INIT_LOOP:
    for (int k = 0; k < WINDOW; k++) {
        window[k] = INT_MIN;
    }

MAIN_LOOP:
    for (int n = 0; n < N_SAMPLES; n++) {
#pragma HLS PIPELINE II=1
        for (int k = WINDOW - 1; k >= 1; k--) {
            window[k] = window[k - 1];
        }

        window[0] = in_data[n];

        for (int k = 0; k < WINDOW; k++) {
            if (window[k] > window_max) {
                window_max = window[k];
            }
        }
        
        out_data[n] = window_max;
        window_max = INT_MIN;
    }
}