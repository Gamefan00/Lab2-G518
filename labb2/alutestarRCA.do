restart -f -nowave
add wave  alu_inA alu_inB alu_op alu_out C E Z

force alu_inA 8'b00000001
force alu_inB 8'b00000001
force alu_op 2'b11
run 200ns
force alu_inA 8'b10000001
force alu_inB 8'b10000001
force alu_op 2'b10
run 200ns
force alu_inA 8'b00000001
force alu_inB 8'b10000001
force alu_op 2'b01
run 200ns
force alu_inA 8'b00000001
force alu_inB 8'b00000000
force alu_op 2'b01
run 200ns
force alu_inA 8'b00000001
force alu_inB 8'b00000000
force alu_op 2'b00
run 200ns
force alu_inA 8'b11111110
force alu_inB 8'b00001110
force alu_op 2'b00
run 200ns