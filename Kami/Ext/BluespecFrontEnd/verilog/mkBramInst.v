//
// Generated by Bluespec Compiler, version 2014.07.A (build 34078, 2014-07-30)
//
// On Tue Jun 25 17:37:50 EDT 2019
//
//
// Ports:
// Name                         I/O  size props
// RDY_readRq                     O     1 const
// readRs                         O    32 reg
// RDY_readRs                     O     1 const
// RDY_write                      O     1 const
// CLK                            I     1 clock
// RST_N                          I     1 unused
// readRq_idx                     I    10
// write_idx                      I    10
// write_d                        I    32 reg
// EN_readRq                      I     1
// EN_write                       I     1
//
// No combinational paths from inputs to outputs
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkBramInst(CLK,
		  RST_N,

		  readRq_idx,
		  EN_readRq,
		  RDY_readRq,

		  readRs,
		  RDY_readRs,

		  write_idx,
		  write_d,
		  EN_write,
		  RDY_write);
  input  CLK;
  input  RST_N;

  // action method readRq
  input  [9 : 0] readRq_idx;
  input  EN_readRq;
  output RDY_readRq;

  // value method readRs
  output [31 : 0] readRs;
  output RDY_readRs;

  // action method write
  input  [9 : 0] write_idx;
  input  [31 : 0] write_d;
  input  EN_write;
  output RDY_write;

  // signals for module outputs
  wire [31 : 0] readRs;
  wire RDY_readRq, RDY_readRs, RDY_write;

  // register bram_data
  reg [31 : 0] bram_data;
  wire [31 : 0] bram_data$D_IN;
  wire bram_data$EN;

  // ports of submodule bram_rf
  wire [31 : 0] bram_rf$D_IN, bram_rf$D_OUT_1;
  wire [9 : 0] bram_rf$ADDR_1,
	       bram_rf$ADDR_2,
	       bram_rf$ADDR_3,
	       bram_rf$ADDR_4,
	       bram_rf$ADDR_5,
	       bram_rf$ADDR_IN;
  wire bram_rf$WE;

  // action method readRq
  assign RDY_readRq = 1'd1 ;

  // value method readRs
  assign readRs = bram_data ;
  assign RDY_readRs = 1'd1 ;

  // action method write
  assign RDY_write = 1'd1 ;

  // submodule bram_rf
  RegFileLoad #(.file("file.hex"),
		.addr_width(32'd10),
		.data_width(32'd32),
		.lo(10'h0),
		.hi(10'd1023),
		.binary(1'd0)) bram_rf(.CLK(CLK),
				       .ADDR_1(bram_rf$ADDR_1),
				       .ADDR_2(bram_rf$ADDR_2),
				       .ADDR_3(bram_rf$ADDR_3),
				       .ADDR_4(bram_rf$ADDR_4),
				       .ADDR_5(bram_rf$ADDR_5),
				       .ADDR_IN(bram_rf$ADDR_IN),
				       .D_IN(bram_rf$D_IN),
				       .WE(bram_rf$WE),
				       .D_OUT_1(bram_rf$D_OUT_1),
				       .D_OUT_2(),
				       .D_OUT_3(),
				       .D_OUT_4(),
				       .D_OUT_5());

  // register bram_data
  assign bram_data$D_IN = bram_rf$D_OUT_1 ;
  assign bram_data$EN = EN_readRq ;

  // submodule bram_rf
  assign bram_rf$ADDR_1 = readRq_idx ;
  assign bram_rf$ADDR_2 = 10'h0 ;
  assign bram_rf$ADDR_3 = 10'h0 ;
  assign bram_rf$ADDR_4 = 10'h0 ;
  assign bram_rf$ADDR_5 = 10'h0 ;
  assign bram_rf$ADDR_IN = write_idx ;
  assign bram_rf$D_IN = write_d ;
  assign bram_rf$WE = EN_write ;

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (bram_data$EN) bram_data <= `BSV_ASSIGNMENT_DELAY bram_data$D_IN;
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    bram_data = 32'hAAAAAAAA;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on
endmodule  // mkBramInst

