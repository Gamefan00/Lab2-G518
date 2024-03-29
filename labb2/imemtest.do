restart -f -nowave
add wave clk readEn writeEn address dataIn dataOut

force clk 0 0, 1 50ns -repeat 100ns
force dataIn 8'b00000000
force writeEn 0 0

force readEn 1 1
force address 8'b00000000
run 200ns

force dataIn 8'b00000000
force writeEn 0 0

force readEn 1 1
force address 8'b00000001
run 200ns

force dataIn 8'b00000000
force writeEn 0 0

force readEn 1 1
force address 8'b00000010
run 200ns

force dataIn 8'b00000000
force writeEn 0 0

force readEn 0 0
force address 8'b01000000
run 200ns

force dataIn 8'b00000000
force writeEn 0 0

force readEn 1 1
force address 8'b00000001
run 200ns