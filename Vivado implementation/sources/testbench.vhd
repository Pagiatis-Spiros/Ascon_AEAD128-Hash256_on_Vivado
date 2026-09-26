library IEEE;
use ieee.std_logic_1164.all;
use work.Ascon_pkg.all;
use ieee.numeric_std.all;

entity testbench is
end testbench;

architecture testbenchArch of testbench is

signal clk : STD_LOGIC := '1';
signal reset : STD_LOGIC := '1';
signal start : STD_LOGIC := '0';          
                  
signal busIN : STD_LOGIC_VECTOR (0 to 127);
signal busType : busTypes;
signal busNext :  STD_LOGIC;
           
signal busOUT : STD_LOGIC_VECTOR (0 to 127);
signal busOutEnable :  STD_LOGIC;
signal FSMState :  AsconStates; 
signal FSMCommand : commandType; 

signal check_state : w320;
       
begin

ASCONTestBench : entity work.ASCON
    port map ( clk => clk, 
        reset => reset, 
        start => start,
        busIN => busIN,
        busType => busType,
        busNext => busNext,
        busOUT => busOUT,
        busOutEnable => busOutEnable,
        FSMState => FSMState,
        FSMCommand => FSMCommand,
        check_state => check_state
     );

  Clk <= not Clk after 2.5ns; -- clock frequency = 1/(5*10^(-9)) => 200Mhz
  
    process

    begin
        -- test 1
        busIN <= swap_endian(x"2e45359eff1340ab04b32a1d09bd7f3b"); --testA        
        busType <= Key;   
        wait until (rising_edge(Clk)); -- and (busNext = '1'));
        busIN <= swap_endian(x"ea9432a05bf1e53c853086621be55680"); --testA
        busType <= Nonce;       
        wait until (rising_edge(Clk) and (busNext = '1'));
        busIN <= swap_endian(x"54686973207465787420697320617373"); --testA
        busType <= AData;       
        wait until (rising_edge(Clk) and (busNext = '1'));
        busIN <= (127=>'1', others=>'0'); 
        busType <= AData;       
        wait until (rising_edge(Clk) and (busNext = '1'));
        busIN <= swap_endian(x"05319cf7ffec692672cf2722d8df7f27"); --testA
        busType <= Message; 
        
        -- test 2
--        busIN <= swap_endian(x"ab4013ff9e35452e3b7fbd091d2ab304");
--        busType <= Key;   
--        wait until (rising_edge(Clk)); -- and (busNext = '1'));
--        busIN <= swap_endian(x"3ce5f15ba03294ea8056e51b62863085");
--        busType <= Nonce;       
--        wait until (rising_edge(Clk) and (busNext = '1'));
--        busIN <= swap_endian(x"54686973207465787420697320617373");
--        busType <= AData;        
--        wait until (rising_edge(Clk) and (busNext = '1'));
--        busIN <= (127=>'1', others=>'0'); 
--        busType <= AData;
--        wait until (rising_edge(Clk) and (busNext = '1'));
--        busIN <= swap_endian(x"78657420736968547373612073692074");
--        busType <= Message;     
        
        
       
        wait until (rising_edge(Clk) and (busNext = '1'));
        busIN <= (others => 'Z');
        busType <= Tag;
        wait until (rising_edge(Clk) and (busNext = '1'));
        busType <= Hash256;

        wait;
    end process;
    
    process(clk) 
    begin
        if rising_edge(clk) then
            if busOUTEnable = '1' and busType = Message then
                report "Ciphertext  = " & to_hstring(busOUT);
            elsif busOUTEnable = '1' and busType = Tag then
                report "Tag  = " & to_hstring(busOUT);
            end if;
        end if;
    end process;
    
    process 
    begin  
        wait until rising_edge(Clk);    
        reset <= '1';
        wait until rising_edge(Clk);
        reset <= '0';
        wait for 20ns;
        start <= '1';
        wait until rising_edge(Clk);
        start <= '0';
             
        wait;
    end process;
    
end testbenchArch;
