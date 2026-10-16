module tb_sync_fifo;

    logic clk = 0;
    logic rst = 0;
    logic wr_en = 0;
    logic rd_en = 0;
    logic [7:0] wr_data = 0;

    logic [7:0] rd_data;
    logic full, empty;

    sync_fifo dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .wr_data(wr_data),
        .rd_data(rd_data),
        .full(full),
        .empty(empty)
    );

    always #5 clk = ~clk;

    task automatic write_item(input logic [7:0] data);
        @(negedge clk);
        wr_en = 1;
        wr_data = data;
        rd_en = 0;

        @(posedge clk);
        #1;
        @(negedge clk);
        wr_en = 0;
    endtask

    task automatic read_item(input logic [7:0] expected);
        @(negedge clk);
        rd_en = 1;
        wr_en = 0;

        @(posedge clk);
        #1;
        if (rd_data !== expected)
            $fatal(1, "READ ERROR: expected %0d, got %0d",
                   expected, rd_data);
        else
            $display("READ PASS: data = %0d", rd_data);

        @(negedge clk);
        rd_en = 0;
    endtask

    initial begin
        // Reset
        rst = 1;
        repeat (2) @(negedge clk);
        rst = 0;
        @(negedge clk);

        if (empty !== 1 || full !== 0)
            $fatal(1, "Reset/initial flags incorrect");

        // FIFO ordering
        write_item(8'd25);
        write_item(8'd50);

        if (empty !== 0 || full !== 0)
            $fatal(1, "Flags incorrect after writes");

        read_item(8'd25);
        read_item(8'd50);

        if (empty !== 1)
            $fatal(1, "FIFO should be empty");

        // Fill all four entries
        write_item(8'd10);
        write_item(8'd20);
        write_item(8'd30);
        write_item(8'd40);

        if (full !== 1)
            $fatal(1, "FIFO should be full");

        // Attempt a write while full
        write_item(8'd99);

        if (full !== 1)
            $fatal(1, "Full flag changed incorrectly");

        // Confirm order and that rejected write did not corrupt data
        read_item(8'd10);
        read_item(8'd20);
        read_item(8'd30);
        read_item(8'd40);

        if (empty !== 1)
            $fatal(1, "FIFO should be empty after draining");

        // Simultaneous accepted read and write
        write_item(8'd55);

        @(negedge clk);
        wr_en = 1;
        rd_en = 1;
        wr_data = 8'd66;

        @(posedge clk);
        #1;
        if (rd_data !== 8'd55)
            $fatal(1, "Simultaneous read returned wrong data");

        @(negedge clk);
        wr_en = 0;
        rd_en = 0;

        read_item(8'd66);

        if (empty !== 1)
            $fatal(1, "FIFO should be empty at end");

        $display("ALL FIFO TESTS PASSED");
        $finish;
    end

endmodule
