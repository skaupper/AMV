`ifndef PROL16_MODEL
`define PROL16_MODEL


`include "Prol16Opcode.sv"



class Prol16Model;
    Prol16State state;
    Prol16Opcode nextOpc;
    Prol16Opcode lastOpc;

    function new;
        state = new;
        lastOpc = new;
        reset;
    endfunction

    function void reset;
        state.regs = '{gRegs{'0}};
        state.zero = 0;
        state.carry = 0;
        state.pc = 0;
    endfunction

    function void setOpcode(Prol16Opcode opc);
        nextOpc = opc;
    endfunction

    function void executeNext();
        nextOpc.print();
        execute(nextOpc);
        lastOpc = nextOpc;
    endfunction

    function void execute (Prol16Opcode opc);
        int ra = state.regs[opc.ra];
        int rb = state.regs[opc.rb];

        bit setZero = 1;
        bit setResult = 1;
        int res = ra;
        int carry = state.carry;
        int newPc = state.pc + 1;


        // Calculate operation result
        case (opc.cmd)
            LOADI:  begin
                newPc = state.pc + 2;
                setZero = 0;
                res = opc.data;
            end
            JUMP:   begin
                setZero = 0;
                newPc = ra;
            end
            JUMPC:  begin
                setZero = 0;
                if (state.carry) begin
                    newPc = ra;
                end
            end

            JUMPZ:  begin
                setZero = 0;
                if (state.zero) begin
                    newPc = ra;
                end
            end

            MOVE:   begin res = rb;                             setZero = 0; end
            AND:    begin res = ra & rb;                    end
            OR:     begin res = ra | rb;                    end
            XOR:    begin res = ra ^ rb;                    end
            NOT:    begin res = ~ra;                        end
            ADD:    begin res = ra + rb;                    end
            ADDC:   begin res = ra + rb + state.carry;      end
            SUB:    begin res = ra - rb;                    end
            SUBC:   begin res = ra - rb - state.carry;      end
            COMP:   begin res = ra - rb;                        setResult = 0;  end
            INC:    begin res = ra + 1;                     end
            DEC:    begin res = ra - 1;                     end
            SHL:    begin res = ra << 1;                    end
            SHR:    begin res = ra >> 1;                    end
            SHLC:   begin res = (ra << 1) | state.carry;    end
            SHRC:   begin res = (ra >> 1) | (state.carry << (gDataWidth-1)); end


            NOP: begin
                setZero = 0;
            end
            LOAD, STORE, SLEEP: begin
                setZero = 0;
                $display("Unsupported opcode");
            end

            default: begin
                $display("Unknown opcode");
            end
        endcase


        // Calculate carry out
        case (opc.cmd)
            AND:    begin carry = 0; end
            OR:     begin carry = 0; end
            XOR:    begin carry = 0; end
            NOT:    begin carry = 0; end
            ADD:    begin carry = (res >= (1 << gDataWidth)); end
            ADDC:   begin carry = (res >= (1 << gDataWidth)); end
            SUB:    begin carry = (res < 0); end
            SUBC:   begin carry = (res < 0); end
            COMP:   begin carry = (res < 0); end
            INC:    begin carry = (res >= (1 << gDataWidth)); end
            DEC:    begin carry = (res < 0); end
            SHL:    begin carry = (ra & (1 << (gDataWidth-1))) != 0; end
            SHR:    begin carry = ra & 1; end
            SHLC:   begin carry = (ra & (1 << (gDataWidth-1))) != 0; end
            SHRC:   begin carry = ra & 1; end

            default: begin end
        endcase

        // Cap the result to gDataWidth bits
        res %= (1 << gDataWidth);

        // Update flags, registers and program counter
        if (setZero) begin
            state.zero = (res == 0);
        end
        state.carry = carry;

        if (setResult) begin
            state.regs[opc.ra] = res;
        end
        state.pc = newPc;
    endfunction


    function void print;
        state.print();
    endfunction

endclass


`endif
