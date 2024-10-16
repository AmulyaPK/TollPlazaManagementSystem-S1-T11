// Design of Digital Systems - Mini Project 2024-25
// S1-T11: Toll Plaza Management System
// Team members:
// 1. Amulya Paathipati Kolar 231CS111
// 2. Preeti Mondal 231CS144
// 3. Vanshika Mittal 231CS163

// Toll Plaza Managemnet System Test-Bench

module toll_traffic_management_tb;
    reg clk, reset, enable;
    reg [2:0] lane1, lane2, lane3, lane4, lane5, lane6;
    reg [3:0] a, b, c, d;
    reg priority, common;
    reg [1:0] vhType;

    wire cash;
    wire [2:0] selectedLane, flane1, flane2, flane3, flane4, flane5, flane6;
    wire [3:0] truck1_bal, truck2_bal, car1_bal, car2_bal, bike1_bal, bike2_bal;

    // Instantiate the traffic management module
    toll_traffic_management TTF(
        .clk(clk), 
        .reset(reset), 
        .enable(enable), 
        .lane1(lane1), 
        .lane2(lane2), 
        .lane3(lane3), 
        .lane4(lane4), 
        .lane5(lane5), 
        .lane6(lane6), 
        .a(a), 
        .b(b), 
        .c(c), 
        .d(d), 
        .priority(priority), 
        .common(common), 
        .vhType(vhType),
        .cash(cash),  
        .selectedLane(selectedLane), 
        .flane1(flane1), 
        .flane2(flane2), 
        .flane3(flane3), 
        .flane4(flane4), 
        .flane5(flane5), 
        .flane6(flane6), 
        .truck1_bal(truck1_bal), .truck2_bal(truck2_bal), .car1_bal(car1_bal), .car2_bal(car2_bal), .bike1_bal(bike1_bal), .bike2_bal(bike2_bal)
    );

    // Clock generation
    always #5 clk = ~clk; // Toggle clock every 5 time units

    initial begin
        // Initialize inputs
        $display("Initializing system...");
        $display("Key:");
        $display("P: priority vehicle || C: common vehicle || ilx: initial count at lane x || flx: final count at lane x ||");
        $display("-------------------------------------------------------- Truth Table ---------------------------------------------------------");
        $display("Time | Clk | res | en | P | C | vhType | il1 | il2 | il3 | il4 | il5 | il6 | Lane | fl1 | fl2 | fl3 | fl4 | fl5 | fl6 |");
        $monitor("%4d | %3d | %3d | %2d | %1d | %1d | %6b | %3b | %3b | %3b | %3b | %3b | %3b | %4b | %3b | %3b | %3b | %3b | %3b | %3b |",
            $time, clk, reset, enable, priority, common, vhType, lane1, lane2, lane3, lane4, lane5, lane6, selectedLane, flane1, flane2, flane3, flane4, flane5, flane6);
        clk = 0;
        reset = 1;
        enable = 0;
        lane1 = 3'b010; lane2 = 3'b011; lane3 = 3'b001;
        lane4 = 3'b101; lane5 = 3'b110; lane6 = 3'b001;
        a = 4'b1001; b = 4'b0001; c = 4'b0101; d = 4'b1001;
        priority = 0; common = 1;
        vhType = 2'b00;
        // Release reset and enable the system
        #5;
        reset = 0;
        enable = 1;

        // Clock cycle 1
        #5;
        // Clock cycle 2: feed output from previous call into inputs
        lane1 = flane1; lane2 = flane2; lane3 = flane3;
        lane4 = flane4; lane5 = flane5; lane6 = flane6;
        priority = 0; common = 1;
        vhType = 2'b10;
        #5;
        // Clock cycle 3: feed output from previous call into inputs
        lane1 = flane1; lane2 = flane2; lane3 = flane3;
        lane4 = flane4; lane5 = flane5; lane6 = flane6;
        priority = 0; common = 1;
        vhType = 2'b01;
        #5;
        // Clock cycle 4: feed output from previous call into inputs
        lane1 = flane1; lane2 = flane2; lane3 = flane3;
        lane4 = flane4; lane5 = flane5; lane6 = flane6;
        priority = 0; common = 1;
        vhType = 2'b01;
        #5;
        // Clock cycle 5: feed output from previous call into inputs
        lane1 = flane1; lane2 = flane2; lane3 = flane3;
        lane4 = flane4; lane5 = flane5; lane6 = flane6;
        priority = 1; common = 0;
        vhType = 2'b10;
        #5;
        // Clock cycle 6: feed output from previous call into inputs
        lane1 = flane1; lane2 = flane2; lane3 = flane3;
        lane4 = flane4; lane5 = flane5; lane6 = flane6;
        priority = 0; common = 1;
        vhType = 2'b01;
        #5;
        // Clock cycle 7: feed output from previous call into inputs
        lane1 = flane1; lane2 = flane2; lane3 = flane3;
        lane4 = flane4; lane5 = flane5; lane6 = flane6;
        priority = 0; common = 1;
        vhType = 2'b01;
        #5;
        // Finish the simulation
        $finish;
    end

endmodule
