restart -f -nowave
add wave  a b e

force a 8'b00000001
force b 8'b00000001
run 200ns
force a 8'b00000001
force b 8'b00000000
run 200ns
force a 8'b00000001
force b 8'b00100010
run 200ns
force a 8'b00100010
force b 8'b00100010
run 200ns