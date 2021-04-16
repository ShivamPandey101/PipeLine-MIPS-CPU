# PipeLine-MIPS-CPU
Pipeline MIPS CPU Using Verilog

#  Pipeline CPU

Pipelining is an implementation technique whereby multiple instructions are overlapped in execution; it takes an advantage of parallelism that exists among the actions needed to execute an instruction. Nowadays all processors incorporate pipelining as it is fast. MIPS is a five-stage pipeline structure, each stage is responsible to complete a part of each instruction. All these five stages are connected through a pipelining register. All the stages are connected, all of them should be ready to perform at the same time. The time required to move an instruction one step down to another stage among five stages sequentially is known as the ‘processor cycle’. The slowest pipeline stage decides the length of the processor cycle.

## Different Stages in Pipeline CPU

In all RISC architecture processor, the instruction is implemented by following 5 clocks/ stages:

1. Instruction Fetch (IF): 

• Here in this section, the PC is sent to memory and the current instruction is fetched and
the PC is also incremented by PC+4.
2. Instruction decode (ID):

• In the ID stage, the instruction is decoded using the opcode of the instruction. Reading the registers as specified in the register file.

• If the branch instruction is detected, then the equality test on the register is done when it is read. The possible branch target address.

• If immediate, load, or store instruction is detected, then the sign is extended to 32 bit.

3. Execute (EX):

• Here the main part of the instruction is done which is mainly ALU-based.

• The ALU adds the base address and effective address to acquire an effective address in
LOAD/STORE instruction.

• For RR ALU type instruction the ALU – opcode performs addition, subtraction as it is
needed.

4. Memory access (MEM):

• This particular stage is used by LOAD/STORE instruction only.

• RM ALU or RR ALU type instruction bypasses this stage.

• If the instruction is of LOAD type then it reads the effective address from the memory, and if the instruction is STORE then it writes the information into the memory.

5. Write Back (WB):

• This is the final stage of the pipeline. This block provides the write-back datapath to the register bank and writes the answer in the destination register. One can design pipeline processor (MIPS here) by initializing new instruction at on every clk cycles. Here each clock cycle represents one of the stage of pipeline. Following figure represents the typical pipeline structure, even though an instruction takes five clocks to complete the execution, hardware will start a new instruction and will execute a part of the instruction at each stage.
