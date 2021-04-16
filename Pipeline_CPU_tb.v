module project_6_tb;

	reg clk1,clk2;
	
	project_6 project_6 (clk1, clk2);
	
	initial
		begin
			clk1 = 0;
			clk2 = 0;
			repeat (20)
			begin
				#5 clk1 = 1;   #5 clk1 = 0;
				#5 clk2 = 1;   #5 clk2 = 0;
			end
		end
endmodule
				