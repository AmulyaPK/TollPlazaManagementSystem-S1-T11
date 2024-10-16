// Design of Digital Systems - Mini Project 2024-25
// S1-T11: Toll Plaza Management System
// Team members:
// 1. Amulya Paathipati Kolar 231CS111
// 2. Preeti Mondal 231CS144
// 3. Vanshika Mittal 231CS163

// Toll Plaza Management System Main-Code

module toll_traffic_management(clk, reset, enable, lane1, lane2, lane3, lane4, lane5, lane6, a, b, c, d, priority, common, cash, vhType, selectedLane, flane1, flane2, flane3, flane4, flane5, flane6, truck1_bal, truck2_bal, car1_bal, car2_bal, bike1_bal, bike2_bal);
    input clk, reset, enable;
    input [2:0] lane1, lane2, lane3, lane4, lane5, lane6;
    input [3:0] a, b, c, d;
    input priority, common;
    input [1:0] vhType;
    output reg cash;
    output [2:0] selectedLane;
    output [2:0] flane1, flane2, flane3, flane4, flane5, flane6;
    output [3:0] truck1_bal, truck2_bal, car1_bal, car2_bal, bike1_bal, bike2_bal;

    wire cashW;
    wire [2:0] l21, l22, l23, l24, l25, l26, chosenLane;
    wire [3:0] truck_bal1, truck_bal2, car_bal1, car_bal2, bike_bal1, bike_bal2;
    
    luhn_gate LG (.a(a), .b(b), .c(c), .d(d), .enable(enable), .valid(cashW)); // check if the vehicle has a valid fastag ID
    lane_separation LS ( // direct the vehicle to the appropriate lane
        .lane1(lane1),
        .lane2(lane2),
        .lane3(lane3),
        .lane4(lane4),
        .lane5(lane5),
        .lane6(lane6),
        .vhType(vhType),
        .en(enable),
        .clk(clk),
        .selectedLane(chosenLane),
        .flane1(flane1),
        .flane2(flane2),
        .flane3(flane3),
        .flane4(flane4),
        .flane5(flane5),
        .flane6(flane6)
    );

    payment_processor PP ( // checks the balances of vehicles at the gates and validates payments
        .selectedLane(chosenLane),
        .lane1(lane1), 
        .lane2(lane2), 
        .lane3(lane3), 
        .lane4(lane4), 
        .lane5(lane5), 
        .lane6(lane6),
        .vhType(vhType),
        .clk(~clk), 
        .reset(reset), 
        .Lane1(l21), 
        .Lane2(l22), 
        .Lane3(l23), 
        .Lane4(l24), 
        .Lane5(l25), 
        .Lane6(l26),
        .truck_bal1(truck_bal1), 
        .truck_bal2(truck_bal1), 
        .car_bal1(car_bal1), 
        .car_bal2(car_bal2), 
        .bike_bal1(bike_bal1), 
        .bike_bal2(bike_bal2)
    );

    assign selectedLane = chosenLane;
    assign truck1_bal = truck_bal1;
    assign truck2_bal = truck_bal2;
    assign car1_bal = car_bal1;
    assign car2_bal = car_bal2;
    assign bike1_bal = bike_bal1;
    assign bike2_bal = bike_bal2;
endmodule

// determines if a vehicle is a priority vehicle or not
module vehicle_priority (clk, reset, priority_vehicle, common_vehicle);
    input clk, reset;
    output priority_vehicle, common_vehicle;

    reg q1, q0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            q1 <= 0;
            q0 <= 0;
        end else begin
            if (q0 == 1) begin
                q0 <= 0;
                q1 <= ~q1;
            end else begin
                q0 <= q0 + 1;
            end
        end
    end

    assign priority_vehicle = (~q1) & q0;
    assign common_vehicle = ~priority_vehicle;
endmodule

// validating fastag IDs
module luhn_gate (a, b, c, d, enable, valid);
    input [3:0] a, b, c, d;
    input enable; 
    output valid;

    wire [3:0] b2, d2, sum1, sum2, sum3, sum4, sum5, sum6;
    wire [3:0] y1;
    wire y2;

    // doubling the even indexed digits
    double_bcd double1(b, b2);
    double_bcd double2(d, d2);

    buf(y1[0], 0);
    buf(y1[1], 0);
    buf(y1[2], 0);
    buf(y1[3], 0);

    // adding all the digits
    eight_bit_adder adder1(y1, a, b2, sum1, sum2);
    eight_bit_adder adder2(sum1, sum2, c, sum3, sum4);
    eight_bit_adder adder3(sum3, sum4, d, sum5, sum6);

    // checking if the sum % 10 == 0
    nor(y2, sum6[3], sum6[2], sum6[1], sum6[0]);
    and(valid, y2, enable);
endmodule

// segregates vehicles into their types (trucks, cars, bikes)
module vehicle_type_segregation (clk, reset, type);
    input clk, reset;
    output [1:0] type;

    wire q1, q0;
    two_bit_counter CTB (.clk(clk), .reset(reset), .count(type));
endmodule

// directs the vehicle to the most appropriate lane
module lane_separation (lane1, lane2, lane3, lane4, lane5, lane6, vhType, en, clk, selectedLane, flane1, flane2, flane3, flane4, flane5, flane6);
    input wire [2:0] lane1, lane2, lane3, lane4, lane5, lane6;
    input [1:0] vhType;
    input en, clk;
    output [2:0] selectedLane;
    output [2:0] flane1, flane2, flane3, flane4, flane5, flane6;
    
    wire [2:0] finalLane;
    wire [7:0] out;
    wire [2:0] y1, l1, l2, l3, y2;
    buf(y1[0], 0);
    buf(y1[1], 0);
    buf(y1[2], 0);
    mux4to1 mux1(lane1, lane3, lane5, y1, vhType, l1);
    mux4to1 mux2(lane2, lane4, lane6, y1, vhType, l2);
    comparator_3_bit comp1(l1, l2, l3);
    buf (y2[2], vhType[1]);
    buf (y2[1], vhType[0]);
    buf (y2[0], 0);
    three_bit_adder adder1(l3, y2, selectedLane);
    decoder3_to_8 decoder1(selectedLane, out, en);

    wire up, ctrl1, ctrl2, ctrl3, ctrl4, ctrl5, ctrl6;
    buf(up, 1);
    and(ctrl1, clk, out[1]);
    and(ctrl2, clk, out[2]);
    and(ctrl3, clk, out[3]);
    and(ctrl4, clk, out[4]);
    and(ctrl5, clk, out[5]);
    and(ctrl6, clk, out[6]);

    up_down_counter UDC1 (.clk(ctrl1), .reset(reset), .up_down(up), .curr(lane1), .count(flane1));
    up_down_counter UDC2 (.clk(ctrl2), .reset(reset), .up_down(up), .curr(lane2), .count(flane2));
    up_down_counter UDC3 (.clk(ctrl3), .reset(reset), .up_down(up), .curr(lane3), .count(flane3));
    up_down_counter UDC4 (.clk(ctrl4), .reset(reset), .up_down(up), .curr(lane4), .count(flane4));
    up_down_counter UDC5 (.clk(ctrl5), .reset(reset), .up_down(up), .curr(lane5), .count(flane5));
    up_down_counter UDC6 (.clk(ctrl6), .reset(reset), .up_down(up), .curr(lane6), .count(flane6));
endmodule

// generates random balances for vehicles at every lane and checks if the vehicle has enough balance to pay the toll ticket
module payment_processor (selectedLane, lane1, lane2, lane3, lane4, lane5, lane6, vhType, clk, reset, Lane1, Lane2, Lane3, Lane4, Lane5, Lane6, truck_bal1, truck_bal2, car_bal1, car_bal2, bike_bal1, bike_bal2);
    input [2:0] selectedLane, lane1, lane2, lane3, lane4, lane5, lane6;
    input [1:0] vhType;
    input clk, reset;
    output wire [2:0] Lane1, Lane2, Lane3, Lane4, Lane5, Lane6;
    output [3:0] truck_bal1, truck_bal2, car_bal1, car_bal2, bike_bal1, bike_bal2;

    wire [3:0] truck1_bal, truck2_bal, car1_bal, car2_bal, bike1_bal, bike2_bal;
    wire [3:0] truckT, carT, bikeT;
    assign truckT = 4'b0101;
    assign carT = 4'b0100;
    assign bikeT = 4'b0010;

    random_4bit_truck1 RBT1 (.clk(~clk), .reset(reset), .random_number(truck1_bal));
    random_4bit_truck2 RBT2 (.clk(~clk), .reset(reset), .random_number(truck2_bal));
    random_4bit_car1 RBC1 (.clk(~clk), .reset(reset), .random_number(car1_bal));
    random_4bit_car2 RBC2 (.clk(~clk), .reset(reset), .random_number(car2_bal));
    random_4bit_bike1 RBB1 (.clk(~clk), .reset(reset), .random_number(bike1_bal));
    random_4bit_bike2 RBB2 (.clk(~clk), .reset(reset), .random_number(bike2_bal));

    wire tb1_gt, tb1_lt, tb1_et;
    wire tb2_gt, tb2_lt, tb2_et;
    wire cb1_gt, cb1_lt, cb1_et;
    wire cb2_gt, cb2_lt, cb2_et;
    wire bb1_gt, bb1_lt, bb1_et;
    wire bb2_gt, bb2_lt, bb2_et;

    comparator_4_bit CFB1 (.A(truck1_bal), .B(truckT), .A_gt_B(tb1_gt), .A_lt_B(tb1_lt), .A_eq_B(tb1_et));
    comparator_4_bit CFB2 (.A(truck2_bal), .B(truckT), .A_gt_B(tb2_gt), .A_lt_B(tb2_lt), .A_eq_B(tb2_et));
    comparator_4_bit CFB3 (.A(car1_bal), .B(carT), .A_gt_B(cb1_gt), .A_lt_B(cb1_lt), .A_eq_B(cb1_et));
    comparator_4_bit CFB4 (.A(car2_bal), .B(carT), .A_gt_B(cb2_gt), .A_lt_B(cb2_lt), .A_eq_B(cb2_et));
    comparator_4_bit CFB5 (.A(bike1_bal), .B(bikeT), .A_gt_B(bb1_gt), .A_lt_B(bb1_lt), .A_eq_B(bb1_et));
    comparator_4_bit CFB6 (.A(bike2_bal), .B(bikeT), .A_gt_B(bb2_gt), .A_lt_B(bb2_lt), .A_eq_B(bb2_et));

    wire t1_res, t2_res, c1_res, c2_res, b1_res, b2_res;
    or(t1_res, tb1_gt, tb1_et);
    or(t2_res, tb2_gt, tb2_et);
    or(c1_res, cb1_gt, cb1_et);
    or(c2_res, cb2_gt, cb2_et);
    or(b1_res, bb1_gt, bb1_et);
    or(b2_res, bb2_gt, bb2_et);

    wire t1_ud, t2_ud, c1_ud, c2_ud, b1_ud, b2_ud; 
    not(t1_ud, t1_res);
    not(t2_ud, t2_res);
    not(c1_ud, c1_res);
    not(c2_ud, c2_res);
    not(b1_ud, b1_res);
    not(b2_ud, b2_res);

    up_down_counter UDC1 (.clk(clk), .reset(reset), .up_down(t1_ud), .curr(lane1), .count(Lane1));
    up_down_counter UDC2 (.clk(clk), .reset(reset), .up_down(t2_ud), .curr(lane2), .count(Lane2));
    up_down_counter UDC3 (.clk(clk), .reset(reset), .up_down(c1_ud), .curr(lane3), .count(Lane3));
    up_down_counter UDC4 (.clk(clk), .reset(reset), .up_down(c2_ud), .curr(lane4), .count(Lane4));
    up_down_counter UDC5 (.clk(clk), .reset(reset), .up_down(b1_ud), .curr(lane5), .count(Lane5));
    up_down_counter UDC6 (.clk(clk), .reset(reset), .up_down(b2_ud), .curr(lane6), .count(Lane6));
endmodule

// generates a random 4-bit binary number for the balance
module random_4bit_truck1 (
    input wire clk,
    input wire reset,
    output wire [3:0] random_number
);

    wire [3:0] lfsr;
    wire feedback;
    wire d0, d1, d2, d3;

    xor(feedback, lfsr[3], lfsr[2]);

    d_flip_flop ff23 (.clk(clk), .d(d0), .reset(reset), .q(lfsr[0]));
    d_flip_flop ff24 (.clk(clk), .d(d1), .reset(reset), .q(lfsr[1]));
    d_flip_flop ff25 (.clk(clk), .d(d2), .reset(reset), .q(lfsr[2]));
    d_flip_flop ff26 (.clk(clk), .d(d3), .reset(reset), .q(lfsr[3]));

    not (d0, reset);
    and (d1, lfsr[0], reset);
    and (d2, lfsr[1], reset);
    and (d3, feedback, reset);

    assign random_number = lfsr;
endmodule

module random_4bit_truck2 (
    input wire clk,
    input wire reset,
    output wire [3:0] random_number
);

    wire [3:0] lfsr;
    wire feedback;
    wire d0, d1, d2, d3;

    xor(feedback, lfsr[3], lfsr[2]);

    d_flip_flop ff19 (.clk(clk), .d(d0), .reset(reset), .q(lfsr[0]));
    d_flip_flop ff20 (.clk(clk), .d(d1), .reset(reset), .q(lfsr[1]));
    d_flip_flop ff21 (.clk(clk), .d(d2), .reset(reset), .q(lfsr[2]));
    d_flip_flop ff22 (.clk(clk), .d(d3), .reset(reset), .q(lfsr[3]));

    not (d0, reset);
    and (d1, lfsr[0], reset);
    and (d2, lfsr[1], reset);
    and (d3, feedback, reset);

    assign random_number = lfsr;
endmodule

module random_4bit_car1 (
    input wire clk,
    input wire reset,
    output wire [3:0] random_number
);

    wire [3:0] lfsr;
    wire feedback;
    wire d0, d1, d2, d3;

    xor(feedback, lfsr[3], lfsr[2]);

    d_flip_flop ff15 (.clk(clk), .d(d0), .reset(reset), .q(lfsr[0]));
    d_flip_flop ff16 (.clk(clk), .d(d1), .reset(reset), .q(lfsr[1]));
    d_flip_flop ff17 (.clk(clk), .d(d2), .reset(reset), .q(lfsr[2]));
    d_flip_flop ff18 (.clk(clk), .d(d3), .reset(reset), .q(lfsr[3]));

    not (d0, reset);
    and (d1, lfsr[0], reset);
    and (d2, lfsr[1], reset);
    and (d3, feedback, reset);

    assign random_number = lfsr;
endmodule

module random_4bit_car2 (
    input wire clk,
    input wire reset,
    output wire [3:0] random_number
);

    wire [3:0] lfsr;
    wire feedback;
    wire d0, d1, d2, d3;

    xor(feedback, lfsr[3], lfsr[2]);

    d_flip_flop ff11 (.clk(clk), .d(d0), .reset(reset), .q(lfsr[0]));
    d_flip_flop ff12 (.clk(clk), .d(d1), .reset(reset), .q(lfsr[1]));
    d_flip_flop ff13 (.clk(clk), .d(d2), .reset(reset), .q(lfsr[2]));
    d_flip_flop ff14 (.clk(clk), .d(d3), .reset(reset), .q(lfsr[3]));

    not (d0, reset);
    and (d1, lfsr[0], reset);
    and (d2, lfsr[1], reset);
    and (d3, feedback, reset);

    assign random_number = lfsr;
endmodule

module random_4bit_bike1 (
    input wire clk,
    input wire reset,
    output wire [3:0] random_number
);

    wire [3:0] lfsr;
    wire feedback;
    wire d0, d1, d2, d3;

    xor(feedback, lfsr[3], lfsr[2]);

    d_flip_flop ff7 (.clk(clk), .d(d0), .reset(reset), .q(lfsr[0]));
    d_flip_flop ff8 (.clk(clk), .d(d1), .reset(reset), .q(lfsr[1]));
    d_flip_flop ff9 (.clk(clk), .d(d2), .reset(reset), .q(lfsr[2]));
    d_flip_flop ff10 (.clk(clk), .d(d3), .reset(reset), .q(lfsr[3]));

    not (d0, reset);
    and (d1, lfsr[0], reset);
    and (d2, lfsr[1], reset);
    and (d3, feedback, reset);

    assign random_number = lfsr;
endmodule

module random_4bit_bike2 (
    input wire clk,
    input wire reset,
    output wire [3:0] random_number
);

    wire [3:0] lfsr;
    wire feedback;
    wire d0, d1, d2, d3;

    xor(feedback, lfsr[3], lfsr[2]);

    d_flip_flop ff3 (.clk(clk), .d(d0), .reset(reset), .q(lfsr[0]));
    d_flip_flop ff4 (.clk(clk), .d(d1), .reset(reset), .q(lfsr[1]));
    d_flip_flop ff5 (.clk(clk), .d(d2), .reset(reset), .q(lfsr[2]));
    d_flip_flop ff6 (.clk(clk), .d(d3), .reset(reset), .q(lfsr[3]));

    not (d0, reset);
    and (d1, lfsr[0], reset);
    and (d2, lfsr[1], reset);
    and (d3, feedback, reset);

    assign random_number = lfsr;
endmodule


// compares two 4-bit binary numbers
module comparator_4_bit (
    input wire [3:0] A,
    input wire [3:0] B,
    output wire A_gt_B,
    output wire A_lt_B,
    output wire A_eq_B
);

    wire [3:0] a_not, b_not;
    wire [3:0] a_and_b;
    wire [3:0] a_and_b_not;
    wire [3:0] a_not_and_b;
    wire [3:0] a_gt_b_intermediate, a_lt_b_intermediate;

    not (a_not[0], A[0]);
    not (a_not[1], A[1]);
    not (a_not[2], A[2]);
    not (a_not[3], A[3]);
    
    not (b_not[0], B[0]);
    not (b_not[1], B[1]);
    not (b_not[2], B[2]);
    not (b_not[3], B[3]);

    wire w1, w2, w3, w4, w11, w12, w21, w22, w31, w32, w41, w42;

    and(A_eq_B, w1, w2, w3, w4);
    and(w11, A[0], b_not[0]);
    and(w12, a_not[0], B[0]);
    or(w1, w11, w12);
    and(w21, A[1], b_not[1]);
    and(w22, a_not[1], B[1]);
    or(w2, w21, w22);
    and(w31, A[2], b_not[2]);
    and(w32, a_not[2], B[2]);
    or(w3, w31, w32);
    and(w41, A[3], b_not[3]);
    and(w42, a_not[3], B[3]);
    or(w4, w41, w42);

    wire a_gt_b_0, a_gt_b_1, a_gt_b_2, a_gt_b_3;
    wire w5, w6, w7, w8, w9, w10, w13, w14;

    and (a_gt_b_0, A[3], b_not[3]);
    and(w5, A[3], B[3]);
    and (a_gt_b_1, A[2], b_not[2], w5);
    and(w6, A[2], B[2]);
    and(w7, A[3], B[3]);
    or(w8, w6, w7);
    and (a_gt_b_2, A[1], b_not[1], w8);
    and(w9, A[1], B[1]);
    and(w10, A[2], B[2]);
    and(w13, A[3], B[3]);
    or(w14, w9, w10, w13);
    and (a_gt_b_3, A[0], b_not[0], w14);

    or (A_gt_B, a_gt_b_0, a_gt_b_1, a_gt_b_2, a_gt_b_3);

    wire a_lt_b_0, a_lt_b_1, a_lt_b_2, a_lt_b_3;

    and (a_lt_b_0, B[3], a_not[3]);
    and (a_lt_b_1, B[2], a_not[2], w5);
    and (a_lt_b_2, B[1], a_not[1], w8);
    and (a_lt_b_3, B[0], a_not[0], w14);

    or (A_lt_B, a_lt_b_0, a_lt_b_1, a_lt_b_2, a_lt_b_3);
endmodule

// 3-bit up-down counter used to increment and decrement the count of vehicles at every lane
module up_down_counter (
    input wire clk,
    input wire reset,
    input wire up_down,
    input wire [2:0] curr, 
    output reg [2:0] count
);

    wire n1, n2, n3, n4, n5, n6;
    wire [2:0] temp;

    d_flip_flop ff0 (.clk(clk), .d(curr[0]), .reset(reset), .q(temp[0]));
    d_flip_flop ff1 (.clk(clk), .d(curr[1]), .reset(reset), .q(temp[1]));
    d_flip_flop ff2 (.clk(clk), .d(curr[2]), .reset(reset), .q(temp[2]));

    not(n1, count[0]);
    not(n2, count[1]);
    not(n3, count[2]);

    and(and1, up_down, n1);
    and(and2, count[0], up_down);
    and(and3, count[1], count[0]);

    and(and4, n1, n2);
    and(and5, count[1], n1);
    and(and6, n2, n3);

    or(d0, and1, count[0]);
    or(d1, and2, and4);
    or(d2, and3, and6);

endmodule

module two_bit_counter (
    input wire clk,
    input wire reset,
    output wire [1:0] count
);
    wire nclk;
    wire d0, d1;
    wire q0, q1;

    not(nclk, clk);
    d_flip_flop ff0 (.clk(clk), .d(d0), .reset(reset), .q(q0));
    d_flip_flop ff1 (.clk(clk), .d(d1), .reset(reset), .q(q1));
    xor(d0, q0, 1'b1);
    and(d1, q0, nclk);
    assign count = {q1, q0};
endmodule

module d_flip_flop (
    input wire clk,
    input wire d,
    input wire reset,
    output wire q
);

    wire nclk;
    wire nand1_out, nand2_out;

    not(nclk, clk);

    nand(nand1_out, d, nclk);
    nand(nand2_out, nand1_out, clk);

    wire reset_n;
    not(reset_n, reset);
    nand(q, nand2_out, reset_n);

endmodule

module decoder3_to_8 (in, out, en);
    input [2:0] in;
    input en;
    output [7:0] out;

    wire [2:0] not_in;

    // NOT gates for input
    not (not_in[0], in[0]);
    not (not_in[1], in[1]);
    not (not_in[2], in[2]);

    // AND gates to generate outputs
    and (out[0], not_in[2], not_in[1], not_in[0], en);
    and (out[1], not_in[2], not_in[1], in[0], en);
    and (out[2], not_in[2], in[1], not_in[0], en);
    and (out[3], not_in[2], in[1], in[0], en);
    and (out[4], in[2], not_in[1], not_in[0], en);
    and (out[5], in[2], not_in[1], in[0], en);
    and (out[6], in[2], in[1], not_in[0], en);
    and (out[7], in[2], in[1], in[0], en);

endmodule

module comparator_3_bit (A, B, Cout);
    input [2:0] A, B;
    output [2:0] Cout;

    wire a2_not, b2_not; 
    wire a1_not, b1_not;
    wire a0_not, b0_not; 

    // Invert the inputs
    not (a2_not, A[2]);
    not (b2_not, B[2]);
    not (a1_not, A[1]);
    not (b1_not, B[1]);
    not (a0_not, A[0]);
    not (b0_not, B[0]);

    // Equal condition: A == B
    wire eq0, eq1, eq2, eq;
    xnor (eq1, A[0], B[0]);
    xnor (eq2, A[1], B[1]);
    xnor (eq3, A[2], B[2]);

    or (eq, eq0, eq1);  
    or (eq, eq2, eq);  
    or (eq, eq3, eq); 

    // Less than condition: A < B
    wire lt1, lt2, lt3, lt;
    and (lt1, a2_not, B[2]); 
    and (lt2, A[2], b2_not); 
    and (lt3, eq3, eq2, A[1], b1_not); 
    
    or (lt, lt1, lt2, lt3);

    // Greater than condition: A > B
    wire gt1, gt2, gt3, gt;
    and (gt1, A[2], b2_not); 
    and (gt2, a2_not, B[2]); 
    and (gt3, eq3, eq2, a1_not, B[1]); 

    or (gt, gt1, gt2, gt3);

    // Combining conditions
    wire eg;
    or(eg, gt, eq);
    buf(Cout[2], 0);
    buf(Cout[1], eg);
    buf(Cout[0], lt);
endmodule

module mux2to1 (in0, in1, control, out);
    input in0, in1, control;
    output out;

    wire n_ctrl;

    not(n_ctrl, control);
    and(a, n_ctrl, in0);
    and(b, control, in1);
    or(out, a, b);
endmodule

module mux4to1 (
    input wire [2:0] in0, 
    input wire [2:0] in1, 
    input wire [2:0] in2, 
    input wire [2:0] in3, 
    input wire [1:0] control, 
    output [2:0] out
);
    wire not_control0, not_control1;
    wire [2:0] and0, and1, and2, and3;
    
    not (not_control0, control[0]);
    not (not_control1, control[1]);

    and (and0[0], in0[0], not_control1, not_control0); // Select in0
    and (and0[1], in0[1], not_control1, not_control0);
    and (and0[2], in0[2], not_control1, not_control0);

    and (and1[0], in1[0], not_control1, control[0]); // Select in1
    and (and1[1], in1[1], not_control1, control[0]);
    and (and1[2], in1[2], not_control1, control[0]);

    and (and2[0], in2[0], control[1], not_control0); // Select in2
    and (and2[1], in2[1], control[1], not_control0);
    and (and2[2], in2[2], control[1], not_control0);

    and (and3[0], in3[0], control[1], control[0]); // Select in3
    and (and3[1], in3[1], control[1], control[0]);
    and (and3[2], in3[2], control[1], control[0]);

    or (out[0], and0[0], and1[0], and2[0], and3[0]);
    or (out[1], and0[1], and1[1], and2[1], and3[1]);
    or (out[2], and0[2], and1[2], and2[2], and3[2]);
    
endmodule

// to double a bcd digit
module double_bcd (a, b);
    input [3:0] a;
    output [3:0] b;

    wire n_a0, n_a1, n_a2, n_a3;
    wire w1, w2, w3, w4, w5, w6, w7, w8, w9, w10;

    // NOT gates for a
    not (n_a0, a[0]);
    not (n_a1, a[1]);
    not (n_a2, a[2]);
    not (n_a3, a[3]);

    or(w1, a[1], a[0]);
    and(w2, w1, a[2]);
    or(b[0], w2, a[3]);

    and(w3, n_a3, n_a2, a[0]);
    and(w4, a[2], a[1], n_a0);
    and(w5, a[3], n_a0);
    or(b[1], w3, w4, w5);

    and(w6, n_a0, a[3]);
    or(w7, n_a2, a[0]);
    and(w8, w7, a[1]);
    or(b[2], w6, w8);

    and(w9, a[3], a[0]);
    and(w10, a[2], n_a1, n_a0);
    or(b[3], w9, w10);

endmodule

module eight_bit_adder (a1, a2, b, sum1, sum2);
    input [3:0] a1, a2, b;
    output [3:0] sum1, sum2;

    wire y1, y2, cin;
    wire [3:0] b2;
    buf (cin, 0);
    bcd_adder adder1(a2, b, cin, sum2, y1);
    buf(b2[3], 0);
    buf(b2[2], 0);
    buf(b2[1], 0);
    buf(b2[0], y1);
    bcd_adder adder2(a1, b2, cin, sum1, y2);
endmodule

module bcd_adder (a, b, cin, sum, cout);
    input [3:0] a;
    input [3:0] b;
    input wire cin;
    output [3:0] sum;
    output wire cout;

    wire [3:0] s1;
    wire [3:0] b2;
    wire c1, y1, y2, y3, c2;
    four_bit_adder adder1(a, b, cin, s1, c1);
    and(y1, s1[3], s1[2]);
    and(y2, s1[3], s1[1]);
    or(y3, y1, y2, c1);
    buf(b2[3], 0);
    buf(b2[2], y3);
    buf(b2[1], y3);
    buf(b2[0], 0);
    four_bit_adder adder2(s1, b2, cin, sum, c2);
    buf(cout, y3);
endmodule

module four_bit_adder (a, b, cin, sum, cout);
    input [3:0] a;
    input [3:0] b;
    input wire cin;
    output [3:0] sum;
    output cout;

    wire [2:0] s;
    full_adder fa1 (a[0], b[0], cin, sum[0], s[0]);
    full_adder fa2 (a[1], b[1], s[0], sum[1], s[1]);
    full_adder fa3 (a[2], b[2], s[1], sum[2], s[2]);
    full_adder fa4 (a[3], b[3], s[2], sum[3], cout);
endmodule

module three_bit_adder (a, b, sum);
    input [2:0] a;
    input [2:0] b;
    output [2:0] sum;

    wire cin;
    wire [2:0] s;
    buf(cin, 0);
    full_adder fa4 (a[0], b[0], cin, sum[0], s[0]);
    full_adder fa5 (a[1], b[1], s[0], sum[1], s[1]);
    full_adder fa6 (a[2], b[2], s[1], sum[2], s[2]);
endmodule

module full_adder (a, b, c, sum, carry);
    input a, b, c;
    output sum, carry;

    wire y1, y2, y3, y4;

    xor(y1, a, b);
    xor(sum, y1, c);
    and(y3, a, b);
    and(y4, y1, c);
    or(carry, y3, y4);
endmodule
