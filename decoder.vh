
    `ifndef DECODER_HEADER
    `define DECODER_HEADER

    `define I_IM(X, S) {{21{X[31-S]}}, X[30-S:20-S]}
    `define S_IM(X, S) {{21{X[31-S]}}, X[30-S:25-S], X[11-S:7-S]};
    `define B_IM(X, S) {{20{X[31-S]}}, X[7-S], X[30-S:25-S], X[11-S:8-S], 1'b0}
    `define U_IM(X, S) {X[31-S:12-S], {12{1'b0}}}
    `define J_IM(X, S) {{12{X[31-S]}}, X[19-S:12-S], X[20-S], X[30-S:21-S], 1'b0}

    `define RD(X, S) X[11-S:7-S]
    `define RS1(X, S) X[19-S:15-S]
    `define RS2(X, S) X[24-S:20-S]

    `define FUNCT3(X, S) X[14-S:12-S]
    `define FUNCT7_5(X, S) X[30-S]

    `endif