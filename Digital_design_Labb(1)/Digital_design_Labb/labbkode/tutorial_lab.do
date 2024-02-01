restart -f -nowave
add wave clk resetn a b c d sel output


force clk 0 0, 1 50ns -repeat 100ns
force resetn 0 0, 1 120ns
force a 3'b000
force b 3'b001
force c 3'b111
force d 3'b101
force sel 2'b11 
run 300ns
force sel 2'b10
run 100ns
force sel 2'b00
run 100ns
force sel 2'b01
run 200ns
