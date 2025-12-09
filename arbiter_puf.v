module tb_arbiter_puf;
    reg in_X, in_Y;
    reg [31:0] Chal;
    wire out_Q;
    arbiter_puf #(.le(32), .SPARSITY_PERCENT(50), .NUM_PUFS(3)) dut (.in_X(in_X), .in_Y(in_Y), .Chal(Chal), .out_Q(out_Q));
    initial begin
        in_X = 1; in_Y = 1; Chal = 32'hAAAAAAAA;
        #10 Chal = 32'h55555555;
        #10 $finish;
    end
endmodule

module arbiter_puf #(
    parameter le = 32,          // Number of stages (challenge bits)
    parameter SPARSITY_PERCENT = 50,  // Percentage of bits to zero
    parameter NUM_PUFS = 3      // Number of PUF instances for XOR chaining
) (
    input in_X,                // Start signal for top path
    input in_Y,                // Start signal for bottom path (tie to in_X)
    input [le-1:0] Chal,       // 32-bit challenge input
    output out_Q               // Chained response output
);
    wire [NUM_PUFS-1:0] out_Qs;  // Responses from individual PUFs
    wire [le-1:0] sparse_Chal;   // Sparsified challenge

    // Generate sparse challenge
    genvar i;
    generate
        for (i = 0; i < le; i = i + 1) begin : sparse_gen
            assign sparse_Chal[i] = (i % (100 / SPARSITY_PERCENT) == 0) ? Chal[i] : 0;
        end
    endgenerate

    // Instantiate multiple PUF instances with slight delay variations
    generate
        for (i = 0; i < NUM_PUFS; i = i + 1) begin : puf_instances
            arbiter_puf_stage #(.le(le), .delay_offset(i)) u_puf (
                .in_X(in_X),
                .in_Y(in_Y),
                .Chal(sparse_Chal),
                .out_Q(out_Qs[i])
            );
        end
    endgenerate

    // XOR chain the responses
    assign out_Q = ^out_Qs;  // Reduction XOR of all PUF outputs
endmodule

// Internal stage module (to handle delay offset)
module arbiter_puf_stage #(
    parameter le = 32,
    parameter delay_offset = 0
) (
    input in_X,
    input in_Y,
    input [le-1:0] Chal,
    output out_Q
);
    wire [le-1:0] A, B;
    mux4x2 #(.delay_offset(delay_offset)) loop0 (.A(in_X), .B(in_Y), .c(Chal[0]), .X(A[0]), .Y(B[0]));
    genvar j;
    generate
        for (j = 1; j < le; j = j + 1) begin : loop
            mux4x2 #(.delay_offset(delay_offset)) inst (.A(A[j-1]), .B(B[j-1]), .c(Chal[j]), .X(A[j]), .Y(B[j]));
        end
    endgenerate
    flipflop FF (.Df(A[le-1]), .Cf(B[le-1]), .Qf(out_Q));
endmodule

module mux4x2 #(
    parameter delay_offset = 0
) (
    input A,
    input B,
    input c,
    output X,
    output Y
);
    wire xg, yg /* synthesis keep = "TRUE" */;
    buf #(5 + delay_offset) buf_A (xg, A);  // Delay with offset
    buf #(10 + delay_offset) buf_B (yg, B); // Delay with offset
    mux2x1 M1 (.j(xg), .k(yg), .s(c), .m(X));
    mux2x1 M2 (.j(yg), .k(xg), .s(c), .m(Y));
endmodule

module mux2x1 (
    input j,
    input k,
    input s,
    output m
);
    wire sg, jg, kg;
    not (sg, s);
    and (jg, j, sg);
    and (kg, k, s);
    or (m, jg, kg);
endmodule

(* DONT_TOUCH = "true" *)
module flipflop (
    input Df,
    input Cf,
    output Qf
);
    wire Qm;
    (* ALLOW_COMBINATORIAL_LOOPS = "true" *)
    d_latch master (.D(Df), .C(~Cf), .Q(Qm));
    (* ALLOW_COMBINATORIAL_LOOPS = "true" *)
    d_latch slave (.D(Qm), .C(Cf), .Q(Qf));
endmodule

(* DONT_TOUCH = "true" *) (* ALLOW_COMBINATORIAL_LOOPS = "true" *)
module d_latch (
    input D,
    input C,
    output Q
);
    wire R, S, Qn;
    wire R_g, S_g /* synthesis keep = "TRUE" */;
    assign S = D;
    assign R = ~D;
    and (R_g, R, C);
    and (S_g, S, C);
    nor (Q, R_g, Qn);
    nor (Qn, S_g, Q);
endmodule
