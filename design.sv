module sync_fifo (
    input  logic       clk,
    input  logic       rst,
    input  logic       wr_en,
    input  logic       rd_en,
    input  logic [7:0] wr_data,
    output logic [7:0] rd_data,
    output logic       full,
    output logic       empty
);

    // FIFO storage: 4 entries, 8 bits per entry
    logic [7:0] mem [0:3];

    // Pointers and occupancy counter
    logic [1:0] wr_ptr;
    logic [1:0] rd_ptr;
    logic [2:0] count;

    // Accepted operations
    logic write_accept;
    logic read_accept;

    // Status flags
    assign empty = (count == 0);
    assign full  = (count == 4);

    assign write_accept = wr_en && !full;
    assign read_accept  = rd_en && !empty;

    always_ff @(posedge clk) begin
        if (rst) begin
            wr_ptr  <= 0;
            rd_ptr  <= 0;
            count   <= 0;
            rd_data <= 0;
        end
        else begin

            // Write operation
            if (write_accept) begin
                mem[wr_ptr] <= wr_data;

                if (wr_ptr == 3)
                    wr_ptr <= 0;
                else
                    wr_ptr <= wr_ptr + 1;
            end

            // Read operation
            if (read_accept) begin
                rd_data <= mem[rd_ptr];

                if (rd_ptr == 3)
                    rd_ptr <= 0;
                else
                    rd_ptr <= rd_ptr + 1;
            end

            // Occupancy counter
            if (write_accept && !read_accept)
                count <= count + 1;
            else if (!write_accept && read_accept)
                count <= count - 1;

        end
    end

endmodule
