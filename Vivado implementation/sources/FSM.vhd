library IEEE;
use ieee.std_logic_1164.all;
use work.Ascon_pkg.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;


entity FSM is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC; -- active high
           start: in STD_LOGIC;  -- active high
           
           busNext : out STD_LOGIC := '0';
           busType : in busTypes;
           busOutEnable : out STD_LOGIC := '0';
           
           FSMState: out AsconStates; 
           
           FSMCommand : out commandType;
           round : out integer range 0 to 12 
           );
end FSM;

architecture Behavioral of FSM is
signal flag : STD_LOGIC := '0';
signal check : HashChecking;
begin

    process(all)
    begin
        if rising_edge(clk) then
            case FSMState is
            when Idle => 
                FSMCommand <= Init;
                busOutEnable <= '0';
                busNext <= '0';
                round <= 0;
                if start = '1' then
                    FSMState <= InitRound;
                end if;
            
            when InitRound =>
--                report "First round  = " & integer'image(round);
                if round = 12 then
                    FSMState <= InitOver;
                    busNext <= '1';
                    FSMCommand <= applyKeyI;
                else
                    FSMState <= InitRound;
                    round <= round + 1;
                    FSMCommand <= applyRound;
--                    report "round  = " & to_hstring(round) & " - round_counter1  = " & integer'image(round_counter1);
--                    report "round  = " & integer'image(round) & " - round_counter1  = " & integer'image(round_counter1);                
                end if;
            
            when InitOver =>
                FSMState <= InitFinalStage;
                busNext <= '0';
                FSMCommand <= NOP;
            
            when InitFinalStage =>
                busNext <= '0';
                if busType = AData then
                    FSMState <= PerRound; 
                    FSMCommand <= applyAD;
                    round <= 4;
                elsif busType = Message then
                    FSMState <= AbsorbFinalCheck;
                    FSMCommand <= NOP;
                    round <= 0;
                end if;

            when PerRound =>
                if round = 12 then
                    FSMState <= AbsorbOver;
                    busNext <= '1';
                    FSMCommand <= NOP;               
                    round <= 0;
                else 
                    FSMState <= PerRound;
                    FSMCommand <= applyRound;
                    round <= round + 1;
                end if;
            
            when AbsorbOver =>
                FSMState <= AbsorbFinalCheck;
                busNext <= '0';
                round <= 0;
            
            when AbsorbFinalCheck =>
                if busType = AData then
                    FSMState <= PerRound; 
                    FSMCommand <= applyAD;
                    round <= 4;
                elsif busType = Message then
                    FSMCommand <= applyOne; --xor me '1' sto telos ton AD
                    FSMState <= AbsorbEnd; 
                end if;
                
            when AbsorbEnd =>
                FSMState <= PerRound2; 
                FSMCommand <= applyEnc;
                busOutEnable <= '1'; 
                round <= 4;
                flag <= '0';                               
                
            when PerRound2 =>
                if round = 12 then
                    FSMState <= EncodeOver;
                    FSMCommand <= applyOneAt0;               
                    round <= 0;
                    if flag = '1' then
                        FSMState <= TagFin;
                        FSMCommand <= applyKeyTagFin;
                    end if;
                else 
                    FSMState <= PerRound2;
                    FSMCommand <= applyRound;
                    busOutEnable <= '0';
                    round <= round + 1;
                end if;
                
            when EncodeOver =>
                FSMState <= EncodeOverFinal;
                FSMCommand <= applyKeyTag; 
                
            when EncodeOverFinal =>
                FSMState <= Tag;
                FSMCommand <= NOP;
                busNext <= '1';               
               
            when Tag =>
                FSMState <= PerRound2;
                flag <= '1';
                busNext <= '0'; 
            
            when TagFin =>
                FSMState <= HashInit;
                FSMCommand <= applyTag;
                busOutEnable <= '1';
                busNext <= '1';               
                
            -- Hash 256  
            when HashInit =>
                FSMState <= HashRound; 
                FSMCommand <= applyHashInit;
                busOutEnable <= '0';
                busNext <= '0'; 
                check <= h0;
                round <= 0;                             
                
            when HashRound =>
                if round = 12 then
                    FSMState <= HashMsg;
                    FSMCommand <= NOP;               
                    round <= 0;
                else 
                    FSMState <= HashRound;
                    FSMCommand <= applyRound;
                    round <= round + 1;
                end if;
                busOutEnable <= '0';
                
            when HashMsg =>
                if check = h1 then
                    FSMCommand <= applyHashMsg_2;
                    FSMState <= HashRound;
                    check <= h2;
                elsif check = h2 then
                    FSMCommand <= applyOneAt0;
                    FSMState <= HashMsgFin;
                elsif check = sH0 then
                    FSMState <= HashSH1;
                elsif check = sH1 then
                    FSMState <= HashSH2;
                elsif check = sH2 then
                    FSMState <= HashSH3;
                elsif check = sH3 then
                    FSMState <= HashSH4;
                else
                    FSMCommand <= applyHashMsg_1;
                    FSMState <= hashRoundFin;
                end if;                
                
            when hashRoundFin =>
                FSMState <= HashRound;
                check <= h1;
                FSMCommand <= NOP;           
               
            when HashMsgFin =>
                FSMState <= HashRound;
                FSMCommand <= NOP;
                check <= sH0;
            
            when HashSH1 =>
                --pernoyme to lsb ton 64b apo to H0 kai to kanoyme swapEndian kai metafora os msb 
                FSMCommand <= getHash3; 
                FSMState <= HashRound;
                check <= sH1;
            
            when HashSH2 => 
                FSMCommand <= getHash2; 
                FSMState <= HashRound;
                check <= sH2;

            when HashSH3 =>
                FSMCommand <= getHash1; 
                FSMState <= HashRound;
                check <= sH3;
                busOutEnable <= '1';   
                
            when HashSH4 =>
                FSMCommand <= getHash0; 
                FSMState <= FinAll;   

            when FinAll =>
                FSMCommand <= printLast;
                FSMState <= last; 
                busOutEnable <= '1';   
                
             when last =>
                FSMCommand <= NOP;
                busOutEnable <= '0';    
            
            when others =>
                FSMCommand <= NOP;
                
                
            end case;  
            
            if reset = '1' then
                FSMState <= Idle;
                busNext <= '0';
                busOutEnable <= '0';
                FSMCommand <= Init;
                round <= 0;
            end if;
        end if;
    end process;

end Behavioral;