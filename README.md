# Ковзний максимум (Vitis HLS → Vivado)

Блок `moving_max`: для кожного з `N_SAMPLES = 64` вхідних відліків видає максимум
серед останніх `WINDOW = 8` відліків (включно з поточним). На початку масиву,
поки вікно ще не заповнене, порожні комірки дорівнюють `INT_MIN`.

```
out_data[n] = max(in_data[n-7] … in_data[n])
```

## Структура

```
HW_15/
├── hls_component/            # компонент Vitis HLS
│   ├── moving_max.cpp        # DUT (зсувний регістр + пошук максимуму, MAIN_LOOP з PIPELINE II=1)
│   ├── moving_max.h          # N_SAMPLES, WINDOW, прототип
│   ├── tb_moving_max.cpp     # C-тестбенч: еталон на кільцевому буфері, 5 викликів
│   ├── hls_config.cfg        # part, clock, top, файли
│   └── vitis-comp.json
└── Vivado/                   # проєкт Vivado з IP moving_max_0
    ├── Vivado.xpr
    └── Vivado.srcs/
        ├── sources_1/ip/moving_max_0/moving_max_0.xci
        └── sim_1/new/tb_moving_max.v   # Verilog-тестбенч для IP (ap_ctrl_hs + модель ap_memory RAM)
```

## Результати

![Ресурси без #pragma HLS PIPELINE II=1](https://github.com/user-attachments/assets/7f9721f8-fccb-423e-aa71-ac0a2485114d)
> **Рис. 1** *Ресурси і швидкодія без #pragma HLS PIPELINE II=1*

![Ресурси з #pragma HLS PIPELINE II=1](https://github.com/user-attachments/assets/dfc1769d-415e-4ec4-aff4-0db583f15220)
> **Рис. 2** *Ресурси і швидкодія з #pragma HLS PIPELINE II=1*

![Симуляція в Vivado](https://github.com/user-attachments/assets/aa5b9d74-0f18-47ce-8056-648e77921c3c)
> **Рис. 3** *Симуляція в Vivado*
