// Design of Digital Systems - Mini Project 2024-25
// S1-T11: Toll Plaza Management System
// Team members:
// 1. Amulya Paathipati Kolar 231CS111
// 2. Preeti Mondal 231CS144
// 3. Vanshika Mittal 231CS163

// Toll Plaza Managemnet System Main-Code

module toll_traffic_management (clk, reset, enable, lane1, lane2, lane3, lane4, lane5, lane6, a, b, c, d, priority, common, cash, vhType, selectedLane, flane1, flane2, flane3, flane4, flane5, flane6, truck1_bal, truck2_bal, car1_bal, car2_bal, bike1_bal, bike2_bal);
    input clk, reset, enable;
    input [2:0] lane1, lane2, lane3, lane4, lane5, lane6;
    input [3:0] a, b, c, d;
    output priority, common; 
    output reg cash;
    output [1:0] vhType;
    output [2:0] selectedLane;
    output reg [2:0] flane1, flane2, flane3, flane4, flane5, flane6;
    output [3:0] truck1_bal, truck2_bal, car1_bal, car2_bal, bike1_bal, bike2_bal;

    wire cashW;
    wire [2:0] l21, l22, l23, l24, l25, l26, chosenLane;
    wire [3:0] truck_bal1, truck_bal2, car_bal1, car_bal2, bike_bal1, bike_bal2;
    vehicle_priority VP (.clk(clk), .reset(reset), .priority_vehicle(priority), .common_vehicle(common)); // check if a vehicle if a priority vehicle or not
    luhn_gate LG (.a(a), .b(b), .c(c), .d(d), .enable(enable), .valid(cashW)); // check if the vehicle has a valid fastag ID
    vehicle_type_segregation VTS (.clk(~clk), .reset(reset), .type(vhType)); // check if the vehicle if a truck, car or bike
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
        .finalLane(chosenLane)
    );
    payment_processor PP ( // checks the balances of vehicles at the gates and validates payments
        .selectedLane(chosenLane),
        .lane1(lane1), .lane2(lane2), .lane3(lane3), .lane4(lane4), .lane5(lane5), .lane6(lane6),
        .vhType(vhType),
        .clk(~clk), .reset(reset),
        .Lane1(l21), .Lane2(l22), .Lane3(l23), .Lane4(l24), .Lane5(l25), .Lane6(l26),
        .truck_bal1(truck_bal1), .truck_bal2(truck_bal1), .car_bal1(car_bal1), .car_bal2(car_bal2), .bike_bal1(bike_bal1), .bike_bal2(bike_bal2)
    );

    always @ (posedge clk) begin
        case (chosenLane) // increments the counter at each lane when a vehicle is added
            3'b001: begin
                flane1 <= lane1 + 3'b001;
                flane2 <= lane2;
                flane3 <= lane3;
                flane4 <= lane4;
                flane5 <= lane5;
                flane6 <= lane6;
            end
            3'b010: begin
                flane1 <= lane1;
                flane2 <= lane2 + 3'b001;
                flane3 <= lane3;
                flane4 <= lane4;
                flane5 <= lane5;
                flane6 <= lane6;
            end
            3'b011: begin
                flane1 <= lane1;
                flane2 <= lane2;
                flane3 <= lane3 + 3'b001;
                flane4 <= lane4;
                flane5 <= lane5;
                flane6 <= lane6;
            end
            3'b100: begin
                flane1 <= lane1;
                flane2 <= lane2;
                flane3 <= lane3;
                flane4 <= lane4 + 3'b001;
                flane5 <= lane5;
                flane6 <= lane6;
            end
            3'b101: begin
                flane1 <= lane1;
                flane2 <= lane2;
                flane3 <= lane3;
                flane4 <= lane4;
                flane5 <= lane5 + 3'b001;
                flane6 <= lane6;
            end
            3'b110: begin
                flane1 <= lane1;
                flane2 <= lane2;
                flane3 <= lane3;
                flane4 <= lane4;
                flane5 <= lane5;
                flane6 <= lane6 + 3'b001;
            end
        endcase
    end

    always @ (negedge clk) begin
        flane1 <= l21;
        flane2 <= l22;
        flane3 <= l23;
        flane4 <= l24;
        flane5 <= l25;
        flane6 <= l26;
    end
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
    assign y1 = 0;

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
    counter_2bit CTB (.clk(clk), .reset(reset), .Q1(q1), .Q0(q0));
    assign type = {q1, q0};
endmodule

// directs the vehicle to the most appropriate lane
module lane_separation (lane1, lane2, lane3, lane4, lane5, lane6, vhType, en, clk, finalLane);
    input [2:0] lane1, lane2, lane3, lane4, lane5, lane6;
    input [1:0] vhType;
    input en, clk;
    output [2:0] finalLane;
    
    wire [7:0] out;
    wire [2:0] y1, l1, l2, l3, y2;
    assign y1 = 3'b000;
    mux4to1 mux1(lane1, lane3, lane5, y1, vhType, l1);
    mux4to1 mux2(lane2, lane4, lane6, y1, vhType, l2);
    comparator_3_bit comp1(l1, l2, l3);
    assign y2[2] = vhType[1];
    assign y2[1] = vhType[0];
    assign y2[0] = 0;
    three_bit_adder adder1(l3, y2, finalLane);
    decoder3_to_8 decoder1(finalLane, out, en);
endmodule

// generates random balances for vehicles at every lane and checks if the vehicle has enough balance to pay the toll ticket
module payment_processor (selectedLane, lane1, lane2, lane3, lane4, lane5, lane6, vhType, clk, reset, Lane1, Lane2, Lane3, Lane4, Lane5, Lane6, truck_bal1, truck_bal2, car_bal1, car_bal2, bike_bal1, bike_bal2);
    input [2:0] selectedLane, lane1, lane2, lane3, lane4, lane5, lane6;
    input [1:0] vhType;
    input clk, reset;
    output reg [2:0] Lane1, Lane2, Lane3, Lane4, Lane5, Lane6;
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

    always @ (posedge clk or posedge reset) begin
        if (truck1_bal >= truckT)
            Lane1 <= lane1 - 3'b001;
        else 
            Lane1 <= lane1;
        if (truck2_bal >= truckT)
            Lane2 <= lane2 - 3'b001;
        else 
            Lane2 <= lane2;
        if (car1_bal >= carT)
            Lane3 <= lane3 - 3'b001;
        else 
            Lane3 <= lane3;
        if (car2_bal >= carT)
            Lane4 <= lane4 - 3'b001;
        else 
            Lane4 <= lane4;
        if (bike1_bal >= bikeT)
            Lane5 <= lane5 - 3'b001;
        else 
            Lane5 <= lane5;
        if (bike2_bal >= bikeT)
            Lane6 <= lane6 - 3'b001;
        else 
            Lane6 <= lane6;
    end
    assign truck_bal1 = truck1_bal;
    assign truck_bal2 = truck2_bal;
    assign car_bal1 = car1_bal;
    assign car_bal2 = car2_bal;
    assign bike_bal1 = bike1_bal;
    assign bike_bal2 = bike2_bal;
endmodule

// generates a random 4-bit binary number for the balance
module random_4bit_truck1 (clk, reset, random_number);
    input clk, reset;
    output reg [3:0] random_number;

    reg [3:0] lfsr = 4'b0001;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr <= 4'b0001;
        end
        else begin
            lfsr[3:1] <= lfsr[2:0];
            lfsr[0] <= lfsr[3] ^ lfsr[2];
        end
    end
    
    always @(*) begin
        random_number = lfsr;
    end
endmodule

module random_4bit_truck2 (clk, reset, random_number);
    input clk, reset;
    output reg [3:0] random_number;

    reg [3:0] lfsr = 4'b1111;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr <= 4'b1111;
        end
        else begin
            lfsr[3:1] <= lfsr[2:0];
            lfsr[0] <= lfsr[3] ^ lfsr[2];
        end
    end
    
    always @(*) begin
        random_number = lfsr;
    end
endmodule

module random_4bit_car1 (clk, reset, random_number);
    input clk, reset;
    output reg [3:0] random_number;

    reg [3:0] lfsr = 4'b0011;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr <= 4'b0011;
        end
        else begin
            lfsr[3:1] <= lfsr[2:0];
            lfsr[0] <= lfsr[3] ^ lfsr[2];
        end
    end
    
    always @(*) begin
        random_number = lfsr;
    end
endmodule

module random_4bit_car2 (clk, reset, random_number);
    input clk, reset;
    output reg [3:0] random_number;

    reg [3:0] lfsr = 4'b1010;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr <= 4'b1010;
        end
        else begin
            lfsr[3:1] <= lfsr[2:0];
            lfsr[0] <= lfsr[3] ^ lfsr[2];
        end
    end
    
    always @(*) begin
        random_number = lfsr;
    end
endmodule

module random_4bit_bike1 (clk, reset, random_number);
    input clk, reset;
    output reg [3:0] random_number;

    reg [3:0] lfsr = 4'b0101;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr <= 4'b0101;
        end
        else begin
            lfsr[3:1] <= lfsr[2:0];
            lfsr[0] <= lfsr[3] ^ lfsr[2];
        end
    end
    
    always @(*) begin
        random_number = lfsr;
    end
endmodule

module random_4bit_bike2 (clk, reset, random_number);
    input clk, reset;
    output reg [3:0] random_number;

    reg [3:0] lfsr = 4'b1001;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr <= 4'b1001;
        end
        else begin
            lfsr[3:1] <= lfsr[2:0];
            lfsr[0] <= lfsr[3] ^ lfsr[2];
        end
    end
    
    always @(*) begin
        random_number = lfsr;
    end
endmodule


// compares two 4-bit binary numbers
module comparator_4_bit (A, B, AGEB, ALB);
    input [3:0] A, B;
    output reg AGEB, ALB; // AGEB ~ A >= B and ALB ~ A < B

    always @ (*) begin
        if (A < B) begin
            AGEB = 0;
            ALB = 1;
        end
        else begin
            AGEB = 1;
            ALB = 0;
        end
    end
endmodule

// 3-bit up-down counter used to increment and decrement the count of vehicles at every lane
module ctr_3bit_updown (clk, reset, up_down, count);
    input clk, reset, up_down;
    output reg [2:0] count;

    always @ (posedge clk or posedge reset) begin
        if (reset) 
            count <= 3'b000;
        else if (up_down == 0)
            count <= count + 1;
        else
            count <= count - 1;
    end
endmodule

module decoder3_to_8 (in, out, en);
    input [2:0] in;
    input en;
    output reg [7:0] out;

    always @(in or en)
    begin
        if (en) 
        begin
            case (in)
                3'b000: out = 8'b10000000;
                3'b001: out = 8'b01000000;
                3'b010: out = 8'b00100000;
                3'b011: out = 8'b00010000;
                3'b100: out = 8'b00001000;
                3'b101: out = 8'b00000100;
                3'b110: out = 8'b00000010;
                3'b111: out = 8'b00000001;
            endcase
        end
    end
endmodule

module comparator_3_bit (A, B, Cout);
    input [2:0] A, B;
    output reg [2:0] Cout;

    always @ (*) begin
        if (A < B) begin
            Cout[2] = 0;
            Cout[1] = 0;
            Cout[0] = 1;
        end
        else begin
            Cout[2] = 0;
            Cout[1] = 1;
            Cout[0] = 0;
        end
    end
endmodule

module mux2to1 (in0, in1, control, out);
    input in0, in1, control;
    output reg out;

    always @ (*) begin
        case (control)
            1'b0: out = in0;
            1'b1: out = in1;
        endcase
    end
endmodule

module mux4to1 (in0, in1, in2, in3, control, out);
    input [2:0] in0, in1, in2, in3;
    input [1:0] control;
    output reg [2:0] out;

    always @ (*) begin
        case (control)
            2'b00: out = in0;
            2'b01: out = in1;
            2'b10: out = in2;
            2'b11: out = in3;
            default: out = 3'b000;
        endcase
    end
endmodule

// to double a bcd digit
module double_bcd (a, b);
    input [3:0] a;
    output [3:0] b;

    assign b[0] = (((a[1] | a[0]) & (a[2])) | a[3]);
    assign b[1] = ((~a[3]) & (~a[2]) & a[0]) | (a[2] & a[1] & (~a[0])) | (a[3] & (~a[0]));
    assign b[2] = ((~a[0]) & a[3]) | (((~a[2]) | a[0]) & (a[1]));
    assign b[3] = (a[3] & a[0]) | (a[2] & (~a[1]) & (~a[0]));

endmodule

module counter_2bit (clk, reset, Q1, Q0);
    input clk, reset;
    output reg Q1, Q0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Q1 <= 0;
            Q0 <= 0;
        end
        else begin
            if (Q0 == 1) begin
                Q0 <= 0;
                Q1 <= ~Q1;
            end else begin
                Q0 <= Q0 + 1;
            end
        end
    end
endmodule

module eight_bit_adder (a1, a2, b, sum1, sum2);
    input [3:0] a1, a2, b;
    output [3:0] sum1, sum2;

    wire y1, y2, cin;
    wire [3:0] b2;
    assign cin = 0;
    bcd_adder adder1(a2, b, cin, sum2, y1);
    assign b2[3] = 0;
    assign b2[2] = 0;
    assign b2[1] = 0;
    assign b2[0] = y1;
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
    assign cin = 0;
    full_adder fa4 (a[0], b[0], cin, sum[0], s[0]);
    full_adder fa5 (a[1], b[1], s[0], sum[1], s[1]);
    full_adder fa6 (a[2], b[2], s[1], sum[2], s[2]);
endmodule

module full_adder (a, b, c, sum, carry);
    input a, b, c;
    output sum, carry;

    assign sum = a ^ b ^ c;
    assign carry = (a & b) | ((a ^ b) & c);
endmodule