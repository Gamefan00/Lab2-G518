restart -f -nowave
add wave clk resetn loadEnable dataIn dataOut

force clk 0 0, 1 50ns -repeat 100ns
force resetn 0 0, 1 100ns
force loadEnable 1'b1
force dataIn 8'b00110001
run 200ns
force resetn 0 0
force loadEnable 1'b1
force dataIn 8'b00110001
run 200ns
force resetn 1 1
force loadEnable 0 0, 1 100ns
force dataIn 8'b00110001
run 200ns
