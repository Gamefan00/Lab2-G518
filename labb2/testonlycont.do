restart -f -nowave
add wave clk resetn master_load_enable opcode e_flag z_flag decoEnable decoSel pcSel pcLd imRead dmRead dmWrite aluOp flagLd accSel accLd dsLd OPout

force clk 0 0, 1 50ns -repeat 100ns

force resetn 1 1
force master_load_enable 1 1
force opcode 4'b0000
run 100ns

force resetn 1 1
force master_load_enable 1 1
force opcode 4'b1110
run 400ns

force resetn 1 1
force master_load_enable 0 0
force opcode 4'b1010
run 300ns

force resetn 1 1
force master_load_enable 1 1
force dataIn 4'b1101
run 200ns

force master_load_enable 1 1
force opcode 4'b1011
run 300ns

force master_load_enable 1 1
force opcode 4'b1101
run 200ns

force master_load_enable 1 1
force opcode 4'b0111
run 300ns

force resetn 1 1
force e_flag 1 1
force master_load_enable 1 1
force opcode 4'b0101
run 200ns

force resetn 1 1
force e_flag 0 0
force master_load_enable 1 1
force opcode 4'b0101
run 200ns

force resetn 1 1
force master_load_enable 1 1
force opcode 4'b0000
run 100ns
force resetn 1 1
force master_load_enable 1 1
force opcode 4'b0100
run 100ns
force resetn 1 1
force master_load_enable 1 1
force opcode 4'b0100
run 100ns

run 1000ns   ;# Extend the simulation time limit to 1000ns or any desired duration