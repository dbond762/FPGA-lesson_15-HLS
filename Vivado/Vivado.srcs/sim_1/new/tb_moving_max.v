`timescale 1ns / 1ps

module tb_moving_max();

    localparam N_SAMPLES = 64;
    localparam WINDOW    = 8;
    // Затримка читання RAM: 1 такт (звичайна для ap_memory). Якщо тест дає
    // помилки в КОЖНОМУ відліку, спробуйте 2.
    localparam RD_LAT    = 1;

    reg clk = 1'b0;
    reg rst = 1'b1;          // ap_rst активний ВИСОКИМ рівнем
    reg ap_start = 1'b0;
    wire ap_done, ap_idle, ap_ready;

    wire [5:0]  in_data_address0;
    wire        in_data_ce0;
    wire [31:0] in_data_q0;
    wire [5:0]  out_data_address0;
    wire        out_data_ce0;
    wire        out_data_we0;
    wire [31:0] out_data_d0;

    always #5 clk = ~clk;    // 100 МГц

    // ---------- DUT ----------
    moving_max_0 dut (
        .ap_clk            (clk),
        .ap_rst            (rst),
        .ap_start          (ap_start),
        .ap_done           (ap_done),
        .ap_idle           (ap_idle),
        .ap_ready          (ap_ready),
        .in_data_address0  (in_data_address0),
        .in_data_ce0       (in_data_ce0),
        .in_data_q0        (in_data_q0),
        .out_data_address0 (out_data_address0),
        .out_data_ce0      (out_data_ce0),
        .out_data_we0      (out_data_we0),
        .out_data_d0       (out_data_d0)
    );

    // ---------- Моделі зовнішніх RAM ----------
    reg [31:0] mem_in  [0:N_SAMPLES-1];
    reg [31:0] mem_out [0:N_SAMPLES-1];
    reg [31:0] q_a, q_b;

    always @(posedge clk) begin
        if (in_data_ce0) q_a <= mem_in[in_data_address0];
        q_b <= q_a;
        if (out_data_ce0 && out_data_we0) mem_out[out_data_address0] <= out_data_d0;
    end
    assign in_data_q0 = (RD_LAT == 1) ? q_a : q_b;

    // ---------- Еталон ----------
    reg [31:0] golden [0:N_SAMPLES-1];

    task make_golden;
        integer n, k, max;
        begin
            for (n = 0; n < N_SAMPLES; n = n + 1) begin
                for (k = 0; k < WINDOW; k = k + 1) begin
                    if (k == 0) begin
                        max = mem_in[n];
                    end
                    
                    if (n - k >= 0 && mem_in[n-k] > max) begin
                        max = mem_in[n-k];
                    end
                end
                golden[n] = max;
            end
        end
    endtask

    // ---------- Один виклик блока за протоколом ap_ctrl_hs ----------
    integer errors;

    task run_once;
        integer cnt;
        begin
            @(negedge clk);
            ap_start = 1'b1;
            @(negedge clk);
            cnt = 0;
            while (!ap_ready && cnt < 2000) begin
                @(negedge clk);
                cnt = cnt + 1;
            end
            if (!ap_ready) begin
                $display("TIMEOUT: ap_ready never came");
                errors = errors + 1;
            end
            ap_start = 1'b0;     // ap_ready побачено: знімаємо ap_start, щоб блок не стартував знову
            cnt = 0;
            while (!ap_idle && cnt < 100) begin
                @(negedge clk);
                cnt = cnt + 1;
            end
        end
    endtask

    // ---------- Основний сценарій ----------
    integer t, n, k;
    reg [31:0] seed;

    initial begin
        errors = 0;
        seed   = 32'd12345;

        repeat (5) @(negedge clk);
        rst = 1'b0;
        repeat (2) @(negedge clk);

        for (t = 0; t < 5; t = t + 1) begin
            for (n = 0; n < N_SAMPLES; n = n + 1) begin
                seed = seed * 32'd1103515245 + 32'd12345;
                mem_in[n]  = (seed >> 16) % 1000;
                mem_out[n] = 32'hDEADBEEF;      // маркер: якщо блок не запише, побачимо
            end
            make_golden;
            run_once;
            repeat (3) @(negedge clk);
            for (n = 0; n < N_SAMPLES; n = n + 1) begin
                if (mem_out[n] !== golden[n]) begin
                    errors = errors + 1;
                    if (errors <= 10)
                        $display("MISMATCH: call %0d, sample %0d: DUT=%0d, ref=%0d",
                                 t, n, mem_out[n], golden[n]);
                end
            end
        end

        if (errors == 0) $display("Test passed !");
        else             $display("Test FAILED: %0d errors", errors);
        $finish;
    end

    // Захист від зависання
    initial begin
        #200000;
        $display("TIMEOUT: simulation too long");
        $finish;
    end

endmodule
