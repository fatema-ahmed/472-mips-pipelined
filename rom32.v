//-----------------------------------------------------------------------------
// Title         : Read-Only Memory (Instruction ROM)
// Project       : ECE 313 - Computer Organization
//-----------------------------------------------------------------------------
// File          : rom32.v
// Author        : John Nestor  <nestorj@lafayette.edu>
// Organization  : Lafayette College
// 
// Created       : October 2002
// Last modified : 7 January 2005
//-----------------------------------------------------------------------------
// Description :
//   Behavioral model of a read-only memory used in the implementations of the MIPS
//   processor subset described in Ch. 5-6 of "Computer Organization and Design, 3rd ed."
//   by David Patterson & John Hennessey, Morgan Kaufmann, 2004 (COD3e).  
//
//   Note the use of the Verilog concatenation operator to specify different
//   instruction fields in each memory element.
//
//-----------------------------------------------------------------------------

module rom32(address, data_out);
  input  [31:0] address;
  output [31:0] data_out;
  reg    [31:0] data_out;

  parameter BASE_ADDRESS = 25'd0; // address that applies to this memory

  wire [4:0] mem_offset;
  wire address_select;

  assign mem_offset = address[6:2];  // drop 2 LSBs to get word offset

  assign address_select = (address[31:7] == BASE_ADDRESS);  // address decoding

  always @(address_select or mem_offset)
  begin
    if ((address % 4) != 0) $display($time, " rom32 error: unaligned address %d", address);
    if (address_select == 1)
    begin
      case (mem_offset) 
        // This program should initialize $t1 to 0 then loop, adding 5 to $t1
        // until it is equal to 25. At this point it should jump to the end,
        // skipping the addition of -17 into $t1
        5'd0 : data_out = 32'h20090000;   // addi $t1, $zero, 0
        // LOOP:
        5'd1 : data_out = 32'h21290005;   // addi $t1, $t1, 5
        5'd2 : data_out = 32'h20010019;   // addi $1, $0, 0x0019 (inserted by assembler)
        5'd3 : data_out = 32'h1429fffd;   // bne  $t1, 25, LOOP
        5'd4 : data_out = 32'h08100006;   // j    END
        5'd5 : data_out = 32'h2129ffef;   // addi $t1, $t1, -17
        // END:

        default data_out = 32'hxxxx;
      endcase
      $display($time, " reading data: rom32[%h] => %h", address, data_out);
    end
  end 
endmodule

