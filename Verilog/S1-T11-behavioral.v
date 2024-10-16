module toll_traffic_management (clk, reset, enable, lane1, lane2, lane3, lane4, lane5, lane6, a, b, c, d, priority, common, cash, vhType, selectedLane, flane1, flane2, flane3, flane4, flane5, flane6, truck1_bal, truck2_bal, car1_bal, car2_bal, bike1_bal, bike2_bal);
    input clk, reset, enable;
    input [2:0] lane1, lane2, lane3, lane4, lane5, lane6;
    input [3:0] a, b, c, d;
    input priority, common;
    input [1:0] vhType;

    output cash;
    output reg [2:0] selectedLane, flane1, flane2, flane3, flane4, flane5, flane6;
    output [3:0] truck1_bal, truck2_bal, car1_bal, car2_bal, bike1_bal, bike2_bal;

    always @ (posedge clk or negedge clk) begin
        case (vhType)
            2'b00: begin
                if (lane1 > lane2) begin
                    selectedLane <= 3'b010;
                end
                else begin
                    selectedLane <= 3'b001;
                end
            end
            2'b01: begin
                if (lane3 > lane4) begin
                    selectedLane <= 3'b100;
                end
                else begin
                    selectedLane <= 3'b011;
                end
            end
            2'b10: begin
                if (lane5 > lane6) begin
                    selectedLane <= 3'b110;
                end
                else begin
                    selectedLane <= 3'b101;
                end
            end
        endcase
    end

    always @ (negedge clk) begin
        case(selectedLane)
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

    reg feedback;
    wire [3:0] truckT, carT, bikeT;
    assign truckT = 4'b0101;
    assign carT = 4'b0100;
    assign bikeT = 4'b0010;
    reg [3:0] num;
    reg [3:0] lfsr;

    always @ (posedge clk) begin
        if (lane1 > 3'b000) begin
            assign feedback = lfsr[3] ^ lfsr[2];
            if (reset) begin
                lfsr <= 4'b0001;
            end else begin
                lfsr <= {lfsr[2:0], feedback};
            end
            num <= lfsr;
            if (num >= truckT)
                flane1 <= lane1 - 3'b001;
            else
                flane1 <= lane1;
        end
        else
            flane1 <= lane1;

        if (lane2 > 3'b000) begin
            assign feedback = lfsr[3] ^ lfsr[2];
            if (reset) begin
                lfsr <= 4'b0010;
            end else begin
                lfsr <= {lfsr[2:0], feedback};
            end
            num <= lfsr;
            if (num >= truckT)
                flane2 <= lane2 - 3'b001;
            else
                flane2 <= lane2;
        end
        else
            flane2 <= lane2;

        if (lane3 > 3'b000) begin
            assign feedback = lfsr[3] ^ lfsr[2];
            if (reset) begin
                lfsr <= 4'b0011;
            end else begin
                lfsr <= {lfsr[2:0], feedback};
            end
            num <= lfsr;
            if (num >= carT)
                flane3 <= lane3 - 3'b001;
            else
                flane3 <= lane3;
        end
        else
            flane3 <= lane3;

        if (lane4 > 3'b000) begin
            assign feedback = lfsr[3] ^ lfsr[2];
            if (reset) begin
                lfsr <= 4'b0100;
            end else begin
                lfsr <= {lfsr[2:0], feedback};
            end
            num <= lfsr;
            if (num >= carT)
                flane4 <= lane4 - 3'b001;
            else
                flane4 <= lane4;
            end
        else
            flane4 <= lane4;

        if (lane5 > 3'b000) begin
            assign feedback = lfsr[3] ^ lfsr[2];
            if (reset) begin
                lfsr <= 4'b0101;
            end else begin
                lfsr <= {lfsr[2:0], feedback};
            end
            num <= lfsr;
            if (num >= bikeT)
                flane5 <= lane5 - 3'b001;
            else
                flane5 <= lane5;
        end
        else
            flane5 <= lane5;

        if (lane6 > 3'b000) begin
            assign feedback = lfsr[3] ^ lfsr[2];
            if (reset) begin
                lfsr <= 4'b0110;
            end else begin
                lfsr <= {lfsr[2:0], feedback};
            end
            num <= lfsr;
            if (num >= bikeT)
                flane6 <= lane6 - 3'b001;
            else
                flane6 <= lane6;
        end
        else
            flane6 <= lane6;
    end

endmodule