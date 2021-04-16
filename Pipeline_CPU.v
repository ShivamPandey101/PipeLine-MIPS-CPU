module project_6 (clk1,clk2);

input clk1,clk2;					// Two phase clock

reg [31:0] PC, IF_ID_IR, IF_ID_NPC;
reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
reg [2:0]  ID_EX_type, EX_MEM_type, MEM_WB_type;
reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B;
reg        EX_MEM_Cond;
reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD;

reg [31:0] Reg [0:31];			// Register bank (32x32)
reg [31:0] Mem [0:1023];		// 1024x32 Memory

parameter ADD=6'b000000,		// Assigning opcodes
			 SUB=6'b000001,
			 AND=6'b000010,
			 OR=6'b000011,
			 SLT=6'b000100,
			 MUL=6'b000101,
			 HLT=6'b111111,
			 LW=6'b001000,
			 SW=6'b001001,
			 ADDI=6'b001010,
			 SUBI=6'b001011,
			 SLTI=6'b001100,
			 BENQZ=6'b001101,
			 BEQZ=6'b001110;

parameter RR_ALU=3'b000,			// For instruction types
			 RM_ALU=3'b001,
			 LOAD=3'b010,
			 STORE=3'b011,
			 BRANCH=3'b100,
			 HALT=3'b101;
			 
reg HALTED;			// Set after HLT instruction is completed (in WB stage)
reg TAKEN_BRANCH = 1'b0;	// Required to disable instructions after branch
integer k;

initial							// Example-1
		begin
			for (k=0; k<31; k=k+1)
			
				Reg[k] = k;
				
				Mem[0] = 32'h2801000a;			// ADDI   R1,R0,10
				Mem[1] = 32'h28020014;			// ADDI   R2,R0,20
				Mem[2] = 32'h28030019;			// ADDI   R3,R0,25
				Mem[3] = 32'h0ce77800;			// OR     R7,R7,R7  (dummy instruction)
				Mem[4] = 32'h0ce77800;			// OR     R7,R7,R7
				Mem[5] = 32'h00222000;			// ADD    R4,R1,R2
				Mem[6] = 32'h0ce77800;			// OR     R7,R7,R7
				Mem[7] = 32'h00832800;			// ADD    R5,R4,R3
				Mem[8] = 32'hfc000000;			// HLT
			
				
			HALTED = 0;
			PC = 0;
			TAKEN_BRANCH = 0;
			
		end
	

always @(posedge clk1)				// IF Stage
	if (HALTED == 0)
	begin
		if (((EX_MEM_IR[31:26] == BEQZ) && (EX_MEM_Cond == 1)) ||
		    ((EX_MEM_IR[31:26] == BENQZ) && (EX_MEM_Cond == 0)))		// Checking for branch instructions
			 begin
				IF_ID_IR <= #2 Mem[EX_MEM_ALUOut];
				TAKEN_BRANCH = #2 ~TAKEN_BRANCH;
				IF_ID_NPC <= #2 EX_MEM_ALUOut + 1;
				PC <= #2 EX_MEM_ALUOut + 1;
			 end
		 else
			  begin
				IF_ID_IR <= #2 Mem[PC];
				IF_ID_NPC <= #2 PC + 1;
				PC <= #2 PC+1;
			  end
	end
	
always @(posedge clk2)				// ID Stage
if (HALTED == 0)
	begin
		if (IF_ID_IR[25:21] == 5'b00000) ID_EX_A <= 0;
		else ID_EX_A <= #2 Reg[IF_ID_IR[25:21]];						// rs
		
		if (IF_ID_IR[20:16] == 5'b00000) ID_EX_B <= 0;
		else ID_EX_B <= #2 Reg[IF_ID_IR[20:16]];						// rt
		
		ID_EX_NPC <= #2 IF_ID_NPC;
		ID_EX_IR <= #2 IF_ID_IR;
		ID_EX_Imm <= #2 {{16{IF_ID_IR[15]}}, {IF_ID_IR[15:0]}};	// Signed extention
		
		case (IF_ID_IR[31:26])
			ADD,SUB,AND,OR,SLT,MUL : ID_EX_type <= #2 RR_ALU;
			ADDI,SUBI,SLTI :         ID_EX_type <= #2 RM_ALU;
			LW :                     ID_EX_type <= #2 LOAD;
			SW :                     ID_EX_type <= #2 STORE;
			BENQZ,BEQZ :             ID_EX_type <= #2 BRANCH;
			HLT :                    ID_EX_type <= #2 HALT;
			default :                ID_EX_type <= #2 HALT;			// For invalid opcode
			
		endcase
	end

always @(posedge clk1)										// EX Stage
	if (HALTED == 0)
	begin
		EX_MEM_type <= #2 ID_EX_type;
		EX_MEM_IR   <= #2 ID_EX_IR;
		
		case (ID_EX_type)
			RR_ALU : begin
							case (ID_EX_IR[31:26])			// opcode
								ADD :       EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_B;
								SUB :       EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_B;
								AND :       EX_MEM_ALUOut <= #2 ID_EX_A & ID_EX_B;
								OR  :       EX_MEM_ALUOut <= #2 ID_EX_A | ID_EX_B;
								SLT :       EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_B;
								MUL :       EX_MEM_ALUOut <= #2 ID_EX_A * ID_EX_B;
								default :   EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
							endcase
						end
			 RM_ALU : begin
							case (ID_EX_IR[31:26])			// opcode
								ADDI :      EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
								SUBI :      EX_MEM_ALUOut <= #2 ID_EX_A - ID_EX_Imm;
								SLTI :      EX_MEM_ALUOut <= #2 ID_EX_A < ID_EX_Imm;
								default :   EX_MEM_ALUOut <= #2 32'hxxxxxxxx;
							endcase
						end
						
			 LOAD, STORE :
							begin
								EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_Imm;
								EX_MEM_B      <= #2 ID_EX_B;
							end
							
			 BRANCH :	begin
								EX_MEM_ALUOut <= #2 ID_EX_NPC + ID_EX_Imm;
								EX_MEM_Cond   <= #2 (ID_EX_A == 0);
							end
			endcase
		end
			 
always @(posedge clk2)							// MEM Stage
		if (HALTED == 0)
		begin
			MEM_WB_type <= #2 EX_MEM_type;
			MEM_WB_IR   <= #2 EX_MEM_IR;
			
			case (EX_MEM_type)
				RR_ALU, RM_ALU :
							MEM_WB_ALUOut <= #2 EX_MEM_ALUOut;
							
				LOAD :   MEM_WB_LMD    <= #2 Mem[EX_MEM_ALUOut];
				
				STORE:   if (TAKEN_BRANCH == 0) 	// Disable write
									Mem[EX_MEM_ALUOut] <= #2 EX_MEM_B;
			endcase
		end
		
always @(posedge clk1)							// WB Stage
		begin
			if (TAKEN_BRANCH == 0)				// Disable write if branch taken
			
			case (MEM_WB_type)
				RR_ALU :   Reg[MEM_WB_IR[15:11]]  <=  #2 MEM_WB_ALUOut;		// rd
				
				RM_ALU :   Reg[MEM_WB_IR[20:16]]  <=  #2 MEM_WB_ALUOut;		// rt
				
				LOAD :   Reg[MEM_WB_IR[20:16]]  <=  #2 MEM_WB_LMD;				// rt
				
				HALT :   HALTED <= #2 1'b1;
			endcase
		end
endmodule
			