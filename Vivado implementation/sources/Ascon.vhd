library IEEE;
use ieee.std_logic_1164.all;
use work.Ascon_pkg.all;
use ieee.std_logic_textio.all;
entity ASCON is
    Port (  clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            start : in STD_LOGIC;
           
            busIN : in w128;
            busType : in busTypes;
            busNext : out STD_LOGIC;
           
            busOUT : out w128;
            busOutEnable : out STD_LOGIC;
            FSMState: out AsconStates; 
            FSMCommand : out commandType

            -- check_state : out w320 := (others => '0') -- και το only for testing στην process
           );
end ASCON;

architecture AsconArch of ASCON is

signal round : integer range 0 to 12;
signal keyR : w128;
signal Msg : w128;
signal state : w320;  
signal nextState : w320;
signal addRC : w320;
signal SBoxState : w320;
signal perEND : w320;
signal hashR : w256;

begin

with FSMCommand select
   nextState <= (busIN & keyR & IV) when Init,
        ((state(319 downto 192) xor keyR) & state(191 downto 0)) when applyKeyI,
        perEND when applyRound,
        (state(319 downto 128) & (state(127 downto 0) xor busIN)) when applyAD, 
        (state(319 downto 128) & (state(127 downto 0) xor busIN)) when applyEnc, 
        ((state(319) xor '1') & state(318 downto 0)) when applyOne,
        (state(319 downto 1) & (state(0) xor '1')) when applyOneAt0,
        (state(319 downto 256) & (state(255 downto 128) xor keyR) & state(127 downto 0)) when applyKeyTag,
        ((state(319 downto 192) xor keyR) & state(191 downto 0)) when applyKeyTagFin,
        ((319 downto 64 => '0') & hashIV) when applyHashInit,
        (state(319 downto 64) & (Msg(63 downto 0) xor state(63 downto 0))) when applyHashMsg_1,
        (state(319 downto 64) & (Msg(127 downto 64) xor state(63 downto 0))) when applyHashMsg_2,
   state when others;

with FSMCommand select 
   busOUT <= 
        swap_endian(state(127 downto 0) xor busIN) when applyEnc,
        swap_endian(state(319 downto 192)) when applyTag,
        hashR(255 downto 128) when getHash1,
        hashR(127 downto 0) when printLast,
   (others => 'Z') when others;
       
          
process(all)
begin
if rising_edge(clk) then
    if busType = Key then
        keyR <= busIN;
    else
        state <= nextState;
        -- check_state <= nextState; --only for testing 
    end if; 
        
    if FSMCommand = applyEnc then
        msg <= busIN;
    end if;   
    
    if FSMCommand = getHash3 then
        hashR <= swap_endian_64b(state(63 downto 0)) & hashR(191 downto 0);
    elsif FSMCommand = getHash2 then
        hashR <= hashR(255 downto 192) & swap_endian_64b(state(63 downto 0)) & hashR(127 downto 0);
    elsif FSMCommand = getHash1 then
        hashR <= hashR(255 downto 128) & swap_endian_64b(state(63 downto 0)) & hashR(63 downto 0);
    elsif FSMCommand = getHash0 then
        hashR <= hashR(255 downto 64) & swap_endian_64b(state(63 downto 0));
    end if; 
    
    if FSMCommand = printLast then
        report "Hash 256  = " & to_hstring(hashR);
    end if;
--    report "State  = " & to_hstring(state) & "-" & to_hstring(swap_endian(state(127 downto 0)));
--    report "State  = " & to_hstring(state(319 downto 256)) & "-" 
--                       & to_hstring(state(255 downto 192)) & "-"
--                       & to_hstring(state(191 downto 128)) & "-"
--                       & to_hstring(state(127 downto 64)) & "-"
--                       & to_hstring(state(63 downto 0));
end if;
end process;

addRC <= state(319 downto 136) & (state(135 downto 128) xor RC(4 + round)) & state(127 downto 0);

SBoxAscon : entity work.SBox320b
    port map(sbIN_320b => addRC, sbOUT_320b => SBoxState);

DiffusionAscon : entity work.DiffusionLayer
    port map(dIN => SBoxState, dOUT => perEND);

FSMAscon : entity work.FSM
    port map(clk => clk, 
        reset => reset,
        start => start,
        busNext => busNext,
        busType => busType,
        busOutEnable => busOutEnable,
        FSMState => FSMState, --test
        FSMCommand => FSMCommand,
        round => round);
           
end AsconArch;
