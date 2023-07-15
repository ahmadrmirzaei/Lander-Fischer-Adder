`timescale 1ns / 1ps
module half_cell (
    input gr,
    input gl, al,
    output g
);

    assign g = gl | (al & gr);
    
endmodule

module full_cell (
    input gr, ar,
    input gl, al,
    output g, a
);

    half_cell hc (gr, gl, al, g);
    assign a = al & ar;
    
endmodule

module ladner_fischer_adder (
    input [16:1] a,
    input [16:1] b,
    input cin,
    output [16:1] sum,
    output carryout
);
    wire [16:0] g, p, g1, p1, g2, p2, g3, p3, g4, p4, g5, p5; 
    assign g[0] = cin;
    assign p[0] = cin;
    
    assign g[16:1] = a & b;
    assign p[16:1] = a ^ b;
    
    genvar i;
    
    generate
        for (i=0; i<16; i=i+1) begin
            if (i%2==0) begin
                assign g1[i] = g[i];
                assign p1[i] = p[i];
            end
            else if (i==1) begin
                half_cell hc1 (g[i-1], g[i], p[i], g1[i]);
            end
            else begin
                full_cell fc1 (g[i-1], p[i-1], g[i], p[i], g1[i], p1[i]);
            end
        end
    endgenerate
    
    generate
        for (i=0; i<16; i=i+1) begin
            if (i%4==0 || i%4==1 || i%4==2) begin
                assign g2[i] = g1[i];
                assign p2[i] = p1[i];
            end
            else if (i==3) begin
                half_cell hc2 (g1[i-2], g1[i], p1[i], g2[i]);
            end
            else begin
                full_cell fc2 (g1[i-2], p1[i-2], g1[i], p1[i], g2[i], p2[i]);
            end
        end
    endgenerate
    
    generate
        for (i=0; i<16; i=i+1) begin
            if (i%8==0 || i%8==1 || i%8==2 || i%8==3 || i%8==4 || i%8==6) begin
                assign g3[i] = g2[i];
                assign p3[i] = p2[i];
            end
            else if (i==5 || i==7) begin
                half_cell hc3 (g2[3], g2[i], p2[i], g3[i]);
            end
            else begin
                full_cell fc3 (g2[11], p2[11], g2[i], p2[i], g3[i], p3[i]);
            end
        end
    endgenerate
    
    generate
        for (i=0; i<16; i=i+1) begin
            if (i==9 || i==11 || i==13 || i==15) begin
                half_cell hc4 (g3[7], g3[i], p3[i], g4[i]);
            end
            else begin
                assign g4[i] = g3[i];
                assign p4[i] = p3[i];
            end
        end
    endgenerate
    
    generate
        for (i=0; i<16; i=i+1) begin
            if (i==2 || i==4 || i==6 || i==8 || i==10 || i==12 || i==14) begin
                half_cell hc5 (g4[i-1], g4[i], p4[i], g5[i]);
            end
            else begin
                assign g5[i] = g4[i];
                assign p5[i] = p4[i];
            end
        end
    endgenerate
    
    generate
        for (i=0; i<16; i=i+1) begin
            assign sum[i+1] = p[i+1] ^ g5[i];
        end
    endgenerate
    
    half_cell hc6 (g5[15], g[16], p[16], carryout);
endmodule
