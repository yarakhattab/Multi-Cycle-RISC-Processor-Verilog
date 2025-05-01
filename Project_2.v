/////

//     Students:
//     Masa Jalamneh - 1212145
//     Saja Asfour   - 1210737
//     Yara khattab  - 1210520

//     Section: 1

/////
///////////--------------------------------------------------------------------////////////
///////////--------------------Design Code (Data Path)-------------------------////////////
///////////--------------------------------------------------------------------////////////
reg [2:0] stage;  // instruction cycle

module datapath ( 
	input clk,
  	
  	input [15:0] PC,
  	
  	output reg [15:0] next_PC,

	output reg RB_sel,Din, RegWr, ALU_src, ExtOp, ExtOp2, Ads_s, MemWr, MemRd, LExt, Imm_s,
		  
  	output reg [15:0] Data_out,
					  
    output reg [1:0] PC_Src, WBdata, Src_s, RegDst,
	
  	output reg [3:0] opcode, 
  
	output reg mode,
  
  	input [15:0] Address_1, Address_2,
  
  	output reg [15:0] address_1, address_2,
  	
  	output reg [7:0] Data_in1, Data_in2,
  
	output reg Z, N, V,
  
  	output reg signed [15:0] ALU_result
);

    reg [2:0] Rd, Rs, Rs1, Rs2, Rt, RW;
    reg [1:0] ALUop;
  	assign R0 = 3'b000;
 	//wire [15:0] PC;
  	reg [15:0]IR;

	
	//assign pc_temp = Address_1;
	
  	reg [15:0] BusA, BusB, BusW, extended_immediate, First_Operand, Seconed_Operand, jumpTargetAddress, branchTargetAddress, ALU_result_buffer;
	
  	reg [15:0] Register_result;
  	reg [4:0] immediate;
  	reg [7:0] imm;
  	reg [15:0] data;
  	reg [7:0] data_out1, data_out2;
	
  	reg [2:0] RA_regfile, RW_regfile;
  	reg [2:0] RA, RB;
  	reg [15:0] regData [0:7]; // for data stored in reg_file
  		initial begin
          regData[0] = 16'h0000;
          regData[1] = 16'h0001;  // 0001
          regData[2] = 16'h000F;  // 1111
          regData[3] = 16'h0004;
          regData[4] = 16'h0000;
          regData[5] = 16'h0110;
          regData[6] = 16'h0000;
          regData[7] = 16'h0007;
          regData[8] = 16'h0110;
         
        end
									

  	reg [11:0] jump_offset;

  	reg [2:0] next_state;
  	reg [15:0] buffer_stage0_stage1 ; 
  	reg [15:0] buffer_stage1_stage2 [0:1] ; 
  	reg [15:0] buffer_stage2_stage3 [0:1] ; 
  	reg [15:0] buffer_stage3_stage4 ;
  
  	  reg [7:0] mem [0: 32];// for data stored in data memory

  		initial begin 
           mem[2] = 11;
   		   mem[3] = 42;
           mem[4] = 176;
 		   mem[5] = -72;
   		   mem[6] = -60;
   		   mem[7] = 35;
           mem[8] = 05;
          
    
		end
  
  reg [7:0] Instruction_1, Instruction_2;
  reg [15:0] Instruction;
  
  reg [15:0] PC_2;
  
  initial begin
  PC_2= PC + 16'h0001;
    $display("\n PC : %b \n", PC);
    $display("\n PC_2 : %b \n", PC_2);
  end
  
  	instruction_memory instruction(
      .clk(clk),
      .Address_1(PC),
      .Address_2(PC_2), 
      .Instruction_1(Instruction_1), 
      .Instruction_2(Instruction_2)
    );
  
  	always @* begin
    // Concatenate instructions on clock edge
      Instruction = {Instruction_2,Instruction_1};

    // Extract opcode
    opcode = Instruction[15:12];
      
      $display("\n opcode : %b \n", opcode);

  	end
  
  
  
  always @(posedge clk) begin 
      
    if (opcode == 4'b0010 || opcode == 4'b0001 || opcode == 4'b0000) begin // R_Type
           Rd = Instruction[11:9];
           Rs1 = Instruction[8:6];
           Rs2 = Instruction[5:3];
          
          case (stage) 	
								0: 		 //fetch
									next_state = 1;
								1:       //dacode
									next_state = 2;
								2: 		// execute
									next_state = 4;
								4: 		// write back
									next_state = 0;
		  endcase
        end
        
    else if(opcode == 4'b1100 || opcode == 4'b1101 || opcode == 4'b1110) begin // J_Type
           jump_offset = Instruction[11:0];
           jumpTargetAddress={PC[15:13], (jump_offset << 1)};
      if (opcode == 4'b1100 || opcode == 4'b1110)
             case (stage) 	
								0: 		 //fetch
									next_state = 1;
								1:       //dacode
									next_state = 0;
             endcase
          else 
             case (stage) 	
								0: 		 //fetch
									next_state = 1;
								1:       //dacode
									next_state = 4;
								4: 		// write back
									next_state = 0;
		  endcase
								
          
        end
        
    else if (opcode == 4'b1111) begin // S_Type
           Rs1 = Instruction[11:9];
           imm = Instruction[8:1];
           case (stage) 	
								0: 		 //fetch
									next_state = 1;
								1:       //dacode
									next_state = 3;
								3: 		// memory
									next_state = 0;
		  endcase
        end   

    else if(opcode == 4'b0011 || opcode == 4'b0100 || opcode == 4'b0101 || opcode == 4'b0110 || opcode == 4'b0111 || opcode == 4'b1000 || opcode == 4'b1001 || opcode == 4'b1010 || opcode == 4'b1011) begin // I_Type
           mode = Instruction[11];
           Rd = Instruction[10:8];
           Rs1 = Instruction[7:5];	
           immediate = Instruction[4:0];
      if(opcode == 4'b0011|| opcode == 4'b0100) // ADDI, ANDI
             case (stage) 	
								0: 		 //fetch
									next_state = 1;
								1:       //dacode
									next_state = 2;
								2: 		// execute
									next_state = 4;
								4: 		// write back
									next_state = 0;
		  endcase
      else if (opcode == 4'b0101|| opcode == 4'b0110)// LW, LB
             case (stage) 	
								0: 		 //fetch
									next_state = 1;
								1:       //dacode
									next_state = 2;
								2: 		// execute
									next_state = 3;
               					3: 		// memory
									next_state = 4;
								4: 		// write back
									next_state = 0;
		  endcase
      else if(opcode == 4'b0111)// SW
            case (stage) 	
								0: 		 //fetch
									next_state = 1;
								1:       //dacode
									next_state = 2;
								2: 		// execute
									next_state = 3;
               					3: 		// memory
									next_state = 0;
		  endcase
          else // Branch
            case (stage) 	
								0: 		 //fetch
									next_state = 1;
								1:       //dacode
									next_state = 2;
								2: 		// execute
									next_state = 0; 	
		  endcase
        end
      stage =  next_state ;
    end   
     
    
    
    always @(posedge clk) begin
			
      if (stage == 0) begin
					IR = Instruction;
					
					next_PC = PC + 16'h0002;
					
         
					$display("Time= %0t,in stage: %0d, PC = %0d", $time, stage,PC);
        		
					buffer_stage0_stage1 = IR;	
              stage =  1 ;

				end	 
      
      ///////////////////////////
      ///////////////////////////
      			else if (stage == 1) begin	
                  	//opcode = buffer_stage0_stage1[15:12];
					
				
                  $display("Time= %0t,in stage: %d, opcode = %b", $time, stage,opcode);
              	
                 
					// ********** R TYPE  *****************
                  if((opcode == 4'b0000) || (opcode == 4'b0001) || (opcode == 4'b0010)) begin //ADD || AND || SUB
							
							PC_Src = 2'b00;
							Src_s = 2'b00;
							RegWr = 1'b1;
                    		RegDst= 2'b01;
							ALU_src = 1'b1;
							MemRd= 	1'b0;
							MemWr=	1'b0;
							WBdata= 2'b11;
							RB_sel = 1'b1;
							case (opcode) //determine the operation based on the opcode 
								4'b0001 : ALUop =  2'b10; //opcode = ADD R-TYPE
								4'b0010 : ALUop = 2'b11; //opcode = SUB R-TYPE
								4'b0000 : ALUop = 2'b01; //opcode = AND R-TYPE
							endcase
							
						end	 
					
					
					// ********** I TYPE  *****************		
                  else if (opcode == 4'b0100  )begin	  //ANDI 
							
							PC_Src = 2'b00;
							Src_s = 2'b00;
							RegWr = 1'b1;
                    		RegDst= 2'b00;
							ALU_src = 1'b0;
							MemRd= 	1'b0;
							MemWr=	1'b0;
							WBdata= 2'b11;
                    		ExtOp = 1'b0;
                    		Imm_s = 1'b1;
                    
                  			ALUop = 2'b01; // AND I-TYPE
							
						end	  

                  else if ( opcode == 4'b0011 )begin	  // ADDI
							
							PC_Src = 2'b00;
							Src_s = 2'b00;
							RegWr = 1'b1;
                    		RegDst= 2'b00;
							ALU_src = 1'b0;
							MemRd= 	1'b0;
							MemWr=	1'b0;
							WBdata= 2'b11;
                            ExtOp = 1'b1;
		           			Imm_s = 1'b1;
                    		ALUop = 2'b10; // AND I-TYPE


						end	  
					
                  else if (opcode == 4'b0101)begin      //LW 
    							
							PC_Src = 2'b00;
							Src_s = 2'b00;
							RegWr = 1'b1;
                    		RegDst= 2'b00;
							ALU_src = 1'b0;
                   			Ads_s = 1'b1;
							MemRd= 	1'b1;
							MemWr=	1'b0;
							WBdata= 2'b01;
                            ExtOp = 1'b1;
        					Imm_s = 1'b1;
                    		ALUop =  2'b10; // ADD

						end
                  
                  else if (opcode == 4'b0110 && mode == 0)begin      //LBu
    							
							PC_Src = 2'b00;
							Src_s = 2'b00;
							RegWr = 1'b1;
                    		RegDst= 2'b00;
							ALU_src = 1'b0;
                   			Ads_s = 1'b1;
							MemRd= 	1'b1;
							MemWr=	1'b0;
							WBdata= 2'b00;
                            ExtOp = 1'b1;
                       		Imm_s = 1'b1;
                    		LExt = 1'b0;
                    		
                    		ALUop =  2'b10; //ADD

						end
                  
                  else if (opcode == 4'b0110 && mode == 1)begin      //LBs
    							
							PC_Src = 2'b00;
							Src_s = 2'b00;
							RegWr = 1'b1;
                    		RegDst= 2'b00;
							ALU_src = 1'b0;
                   			Ads_s = 1'b1;
							MemRd= 	1'b1;
							MemWr=	1'b0;
							WBdata= 2'b00;
                            ExtOp = 1'b1;
                       		Imm_s = 1'b1;
                    		LExt = 1'b1;
                    		ALUop =  2'b10;  //ADD

						end            
					
                  else if (opcode == 4'b0111)begin   //SW 	  
							
							PC_Src = 2'b00;
							Src_s = 2'b00;
							RegWr = 1'b0;
							ALU_src = 1'b0;
                   			Ads_s = 1'b1;
							MemRd= 	1'b0;
							MemWr=	1'b1;
                            ExtOp = 1'b1;
                       		Imm_s = 1'b1;
                    		Din= 1'b1;
                    		ALUop =  2'b10; //ADD
                    		RB_sel = 1'b0;
							
						end
					
                  else if ((opcode == 4'b1000 && mode == 0)|| (opcode == 4'b1001 && mode == 0)|| (opcode == 4'b1010 && mode == 0)|| (opcode == 4'b1011 && mode == 0))begin   //BGT, BLT, BEQ, BNE 
							
							PC_Src = 2'b00;
							Src_s = 2'b00;
							RegWr = 1'b0;
							ALU_src = 1'b1;
							MemRd= 	1'b0;
							MemWr=	1'b0;
                            ExtOp = 1'b1;
                       		Imm_s = 1'b1;	
                    		ALUop =  2'b11; //SUB
                    		RB_sel = 1'b0;
								
						end	
                  
                  else if ((opcode == 4'b1000 && mode == 1) || (opcode == 4'b1001 && mode == 1) || (opcode == 4'b1010 && mode == 1) || (opcode == 4'b1011 && mode == 1))begin   //BGTZ, BLTZ, BEQZ, BNEZ 
							
							PC_Src = 2'b00;
							Src_s = 2'b01;
							RegWr = 1'b0;
							ALU_src = 1'b1;
							MemRd= 	1'b0;
							MemWr=	1'b0;
                            ExtOp = 1'b1;
                       		Imm_s = 1'b1;
                    		ALUop =  2'b11; //SUB
	              			RB_sel = 1'b0;
				
						end	 
		
					
					//********************** J TYPE ****************
					
                  if (opcode == 4'b1100)begin   //JMP 	
							$display("jump decode");
							PC_Src=	2'b10;
							RegWr = 1'b0;
							MemRd= 	1'b0;
							MemWr=	1'b0;
                       		Imm_s = 1'b1;		
                    
		          	 jump_offset = Instruction[11:0];
                     jumpTargetAddress={PC[15:13], (jump_offset << 1)};
                    
                    if (PC_Src == 2'b10)begin
                        next_PC = jumpTargetAddress; 
                    end
							
							$display("jump decode");
							
						end
					
                  if (opcode == 4'b1101)begin   //CALL 
							$display("Call inst reached");
								
							PC_Src = 2'b10;
							RegWr = 1'b1;
                    		RegDst =2'b10;
							MemRd= 	1'b0;
							MemWr=	1'b0;
                    		WBdata= 2'b10;
                       		Imm_s = 1'b1;		
                    
		          	 jump_offset = Instruction[11:0];
                     jumpTargetAddress={PC[15:13], (jump_offset << 1)};
						
                 
                    
                    if (PC_Src == 2'b10)begin
                        next_PC = jumpTargetAddress; 
                    end
                    
							
						end
					
                  else if (opcode == 4'b1110)begin   //RET  
							PC_Src = 2'b11;
                    		Src_s = 2'b10;
							RegWr = 1'b0;
							MemRd= 	1'b0;
							MemWr=	1'b0;
                       		Imm_s = 1'b1;	
                    
                    if (PC_Src == 2'b11)begin
                        next_PC = regData[7]; 
                    end
                    
						end							   
					
					
					
					//********************** S TYPE **************** 
					
					
                  else if (opcode == 4'b1111)begin   //Sv
							
							PC_Src = 2'b00;
							Src_s = 2'b00;
							RegWr = 1'b0;
                   			Ads_s = 1'b0;
							MemRd= 	1'b0;
							MemWr=	1'b1;
                            ExtOp2 = 1'b1;
                       		Imm_s = 1'b0;
                    		Din= 1'b0;
							
							
						end

				
			
      //////////////////////////////////////////////////
      case (Src_s) 
			2'b00 : RA = Rs1;
			2'b01 : RA = 3'b000;
			2'b10 : RA = 3'b111;
			2'b11 : RA = 3'b000;
		endcase
      
                  RB = (RB_sel) ? Rs2 : Rd;
      
       BusA = regData[RA];
       BusB = regData[RB];
       buffer_stage1_stage2[0] = BusA;
       buffer_stage1_stage2[1] = BusB;
                  
                  
      end
      
      //////////////////////////////
      //////////////////////////////
			//Execution in ALU	
			else if (stage == 2) begin
              $display("Time= %0t,in stage: %0d, opcode = %0h", $time, stage,opcode);
					
              First_Operand = buffer_stage1_stage2[0];    
              Seconed_Operand =(ALU_src)?  buffer_stage1_stage2[1] : imm_extend_1(immediate, ExtOp);
					
					
					case(ALUop)
						
						2'b10: begin 
                          ALU_result = First_Operand + Seconed_Operand;
                           Z= (ALU_result == 0);
  						   N = ALU_result[15];
                           V = (First_Operand[15] & Seconed_Operand[15] & ~ALU_result[15]) |(~First_Operand[15] & ~Seconed_Operand[15] & ALU_result[15]);
                        end
                          
						2'b11: begin
                          ALU_result = First_Operand - Seconed_Operand;
                           Z= (ALU_result == 0);
  						   N = ALU_result[15];
                           V = (First_Operand[15] & ~Seconed_Operand[15] & ~ALU_result[15]) |(~First_Operand[15] & Seconed_Operand[15] & ALU_result[15]);
                        end
                          
                        2'b01: begin
                          ALU_result = First_Operand & Seconed_Operand;
                           Z= (ALU_result == 0);
  						   N = ALU_result[15];
                           V = 0;
                        end
                      
						default: ALU_result = 32'b0;
					endcase
              
					$display("first input = %0d, second input = %0d",First_Operand,Seconed_Operand);
              		$display("opcode = %b, aluOut = %0d",opcode,ALU_result); 
					
					// Branch
              if((opcode == 4'b1000 && Z == 0 && N != V) || (opcode == 4'b1001 && Z==0 && N == V) || (opcode == 4'b1010 && Z==1) || (opcode == 4'b1011 && Z==0) ) begin //BGT, BLT, BEQ, BNE
							
							PC_Src= 2'b01;
								end
					
              		if(PC_Src == 2'b01) begin  // if branch is taken , PC= branch target address	
							$display("branch1: PC= %0d",PC);
							$display("immediate16:%0d",immediate);	
							next_PC= PC + imm_extend_1(immediate, ExtOp) ;
							
							$display("branch2: PC= %0d",PC);
						end 
					 
              
              buffer_stage2_stage3[0] =  (Ads_s) ? ALU_result : buffer_stage1_stage2[0];
              buffer_stage2_stage3[1] =  buffer_stage2_stage3[0] + 1;

					
				end	//end stage		
      	///////
      
      
      	// Memory access stage
			else if(stage == 3) begin
              
              buffer_stage2_stage3[0] =  (Ads_s) ? ALU_result : buffer_stage1_stage2[0];
              buffer_stage2_stage3[1] =  buffer_stage2_stage3[0] + 1;
          
              $display("Time= %0t,in stage: %0d, opcode = %0h", $time, stage,opcode);
					
              if(opcode == 4'b0101 || opcode == 4'b0110 || opcode == 4'b0111 || opcode == 4'b1111) begin // 
                
                address_1 = buffer_stage2_stage3[0];
                address_2 = buffer_stage2_stage3[1];
                
                if(MemRd == 1'b1) begin 		//Memory read (load)
                  
                  			
				  data_out1 = mem[address_1];
        		  data_out2 = mem[address_2];
                  
                  if(opcode == 4'b0101) // LW
                    Data_out = {data_out2, data_out1};
                  else if (opcode == 4'b0110 && mode == 0) // LBu
                    Data_out = imm_extend_2(data_out1, LExt) ;
                  else if (opcode == 4'b0110 && mode == 1) // LBs
                    Data_out = imm_extend_2(data_out1, LExt) ;

					 buffer_stage3_stage4 = Data_out;				
                  
                  $display("dataOut = %0d", Data_out);
				
                 end
					
                 
                else if(MemWr == 1'b1) begin 	// STORE SW & Sv
                     	data = (Din) ? BusB: imm_extend_2(imm, ExtOp2);
                  		Data_in1 = data[7:0] ;
                     	Data_in2 = data[15:8] ;
                           
                     	mem[address_1] = Data_in1;
        			 	mem[address_2] = Data_in2;		
                   
                  $display("STORE inst: data_memory[%0d] = %0d",address_1,data );
				 	end
					
				end
            end
			
			// write back
			else if(stage == 4 ) begin 
              $display("Time= %0t,in stage: %0d, opcode = %0h", $time, stage,opcode);
              		if (RegWr) begin //LW and LW.POI
                           case(RegDst)
                                2'b00: RW = Rs;
                                2'b01: RW = Rd;
                                2'b10: RW = 3'b111;
                                2'b11: RW = 3'b000;
                              endcase 
                             
                      if(WBdata == 2'b00 || WBdata == 2'b01) begin
                         
                        	BusW = buffer_stage3_stage4;

                        	regData[RW] = BusW;
                       
                            end
                      
                      else if (WBdata == 2'b10) begin 
                          	 
                        	BusW = PC + 2;
                      		regData[RW] = BusW;
                      end		
                      else begin
                        	BusW = ALU_result;
                      		regData[RW] = BusW;
				   end
					
				end
			
            end
			
		end	// end always
       
  
  initial begin 
    $display("\n ALU_result : %b \n", ALU_result);
  end  
      
      /////////////////////////////
      ////////////////////Functions
      
      	// Function to extend a 5-bit immediate to 16 bits
      function [16:0] imm_extend_1;
        input [4:0] imm;
		input ExtOp;
		
        if (ExtOp && imm[4])
          imm_extend_1 = {11'b11111111111, imm};
		else 
			imm_extend_1 = imm;
	  
      endfunction
      
         // Function to extend a 8-bit immediate to 16 bits
      function [16:0] imm_extend_2;
        input [7:0] imm;
		input ExtOp;
		
        if (ExtOp && imm[7])
          imm_extend_2 = {8'hFF, imm};
		else 
			imm_extend_2 = imm;
	  
      endfunction
  
  
  
endmodule


//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
    
module instruction_memory(
  	  input clk,
      input [15:0] Address_1, Address_2, 
      output reg [7:0] Instruction_1, Instruction_2
    );
  
  reg [7:0] mem [0:15]; // for instructions stored in instruction memory
  initial begin
    
    
    mem[16'h0000] = 8'b01100011; 
    mem[16'h0001] = 8'b00110101;
    mem[16'h0002] = 8'b01010000;
    mem[16'h0003] = 8'b00001010;

  end
  
  
   assign Instruction_1 = mem[Address_1];
   assign Instruction_2 = mem[Address_2];
 
  initial begin 
    $display("\n Address_1 : %b \n", Address_1);
    $display("\n Address_2 : %b \n", Address_2);
    $display("\n Instruction_1 : %b \n", Instruction_1);
    $display("\n Instruction_2 : %b \n", Instruction_2);
  end 
  endmodule


////////-----------------------------------------------------------/////////
////////-----------------------Test Bench----------------------------/////////
////////-----------------------------------------------------------///////// 

  
module All_Sys_TestBench;
	
	
	reg clk;
  reg [15:0] PC;
  
  wire [15:0] next_PC;
	//Control Siganls
    wire [1:0] PC_Src;	
  	wire RB_sel;
	wire Din;
  	wire RegWr;
  	wire ALU_src;
	wire ExtOp;
	wire ExtOp2;
    wire [1:0] Src_s;
  	wire Ads_s;
  	wire MemRd;
  	wire MemWr;
  	wire LExt;
  	wire Imm_s;
    wire [1:0] RegDst;
  	wire [15:0] Data_out;
	wire Ext_Op;
  	wire [1:0] WBdata;
	wire mode;
  	wire [3:0] opcode;
  	
  wire [15:0] address_1;
  wire [15:0] address_2;
  reg [15:0] Address_1;
  reg [15:0] Address_2;
  wire [7:0] Data_in1;
  wire [7:0] Data_in2;
  
  wire Z;
  wire N;
  wire V;
  
  wire [15:0] ALU_result;

  
	
	
  datapath M (.clk(clk),
              .PC(PC),
              .next_PC(next_PC), 
              .RB_sel(RB_sel),
              .Din(Din),
              .RegWr(RegWr),
              .ALU_src(ALU_src),
              .ExtOp(ExtOp),
              .ExtOp2(ExtOp2),
              .Ads_s(Ads_s),
              .MemWr(MemWr),
              .MemRd(MemRd),
              .LExt(LExt),
              .Imm_s(Imm_s),
              .Data_out(Data_out),
              .PC_Src(PC_Src),
              .WBdata(WBdata),
              .Src_s(Src_s),
              .RegDst(RegDst),
              .opcode(opcode),
              .mode(mode),
              .address_1(address_1),
              .address_2(address_2),
              .Address_1(Address_1),
              .Address_2(Address_2),
              .Data_in1(Data_in1),
              .Data_in2(Data_in2),
              .Z(Z),
              .N(N),
              .V(V),
              .ALU_result(ALU_result)
             );
	
	initial begin
			clk = 0;
			stage = 0;
      		PC = 16'h0000;
		end	
	
	//clock generation
	always #100ns clk = ~clk;
  
    always begin 
      $display("\n Address_1 : %b \n", Address_1);
      $display("\n next_PC : %b \n", next_PC);
      $display("\n opcode : %b \n", opcode);
      $display("\n ALU_result : %b \n", ALU_result);
    #800ns $finish;
  
    end 
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;
    end 
  
endmodule