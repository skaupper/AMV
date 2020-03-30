`ifndef PROL16_MODEL
`define PROL16_MODEL


`include "Prol16Opcode.sv"


class Prol16State;
    data_v regs[gRegs];
    bit zero;
    bit carry;
    int pc;
endclass


class Prol16Model;
    local Prol16State state;

    local function __reset;
        state.regs = '{gRegs{'0}};
        state.zero = 0;
        state.carry = 0;
        state.pc = 0;
        return 0;
    endfunction

    function new;
        state = new;
        void'(__reset);
    endfunction

    task reset;
        void'(__reset);
    endtask

    function execute (Prol16Opcode opc);
        int ra = state.regs[opc.ra];
        int rb = state.regs[opc.rb];

        bit setZero = 1;
        // If Ra or Carry should not be updated, neither change the values of res nor carry.
        int res = ra;
        int carry = state.carry;


        // Calculate operation result
        case (opc.cmd)
            LOADI:  begin
                setZero = 0;
                res = opc.data;
            end
            JUMP:   begin
                setZero = 0;
                state.pc = ra;
            end
            JUMPC:  begin
                setZero = 0;
                if (state.carry) begin
                    state.pc = ra;
                end
            end

            JUMPZ:  begin
                setZero = 0;
                if (state.zero) begin
                    state.pc = ra;
                end
            end

            MOVE:   begin res = rb;                         end
            AND:    begin res = ra & rb;                    end
            OR:     begin res = ra | rb;                    end
            XOR:    begin res = ra ^ rb;                    end
            NOT:    begin res = !ra;                        end
            ADD:    begin res = ra + rb;                    end
            ADDC:   begin res = ra + rb + state.carry;      end
            SUB:    begin res = ra - rb;                    end
            SUBC:   begin res = ra - rb - state.carry;      end
            COMP:   begin res = ra - rb;                    end
            INC:    begin res = ra + 1;                     end
            DEC:    begin res = ra - 1;                     end
            SHL:    begin res = ra << 1;                    end
            SHR:    begin res = ra >> 1;                    end
            SHLC:   begin res = (ra << 1) | state.carry;    end
            SHRC:   begin res = (ra >> 1) | (state.carry << (gDataWidth-1)); end


            NOP: begin end
            LOAD, STORE, SLEEP: begin
                $display("Unsupported opcode");
            end

            default: begin
                $display("Unknown opcode");
            end
        endcase


        // Calculate carry out
        case (opc.cmd)
            ADD:    begin carry = (res > (1 << gDataWidth)); end
            ADDC:   begin carry = (res > (1 << gDataWidth)); end
            SUB:    begin carry = (res < 0); end
            SUBC:   begin carry = (res < 0); end
            COMP:   begin carry = (res < 0); end
            INC:    begin carry = (res > (1 << gDataWidth)); end
            DEC:    begin carry = (res < 0); end
            SHL:    begin carry = (ra & (1 << (gDataWidth-1)) != 0); end
            SHR:    begin carry = ra & 1; end
            SHLC:   begin carry = (ra & (1 << (gDataWidth-1)) != 0); end
            SHRC:   begin carry = ra & 1; end

            default: begin end
        endcase


        // update flags
        if (setZero == 0) begin
            state.zero = (res == 0);
        end
        state.carry = carry;

        // Update register Ra
        state.regs[opc.ra] = res;
    endfunction

endclass


`endif
