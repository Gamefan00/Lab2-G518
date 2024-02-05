restart -f -nowave
add wave  a b cin cout s

force cin 1'b1
force a 8'b00000001
force b 8'b00000001
run 300ns
force a 8'b00000001
force b 8'b11111110
run 200ns
