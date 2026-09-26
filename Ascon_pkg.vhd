library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Ascon_pkg is   

  type busTypes is (Key, Nonce, AData, Message, Tag, Hash256);
  type commandType is (Init, applyRound, applyAD, applyEnc, applyKeyI, applyKeyF, applyOne, 
                       applyOneAt0, applyKeyTag, applyKeyTagFin, applyTag, applyHashInit, applyHashMsg_1,
                       applyHashMsg_2, getHash0, getHash1, getHash2, getHash3, printLast, NOP); 
  type AsconStates is (Idle, InitRound, InitOver, InitFinalStage,PerRound, AbsorbOver, 
                       AbsorbFinalCheck, AbsorbEnd, Tag, EncodeOver, PerRound2, EncodeOverFinal, 
                       TagFin, HashInit, HashRound, HashMsg, hashRoundFin, HashMsgFin, HashSH1,HashSH2,
                       HashSH3, HashSH4, FinAll, last); 
  type HashChecking is (h0, h1, h2, sH0, sH1, sH2, sH3, sH4);
  type rc_array is array (0 to 16) of std_logic_vector(7 downto 0);
  
  subtype w5 is STD_LOGIC_VECTOR (4 downto 0);
  subtype w64  is std_logic_vector(63 downto 0);
  subtype w128 is std_logic_vector(127 downto 0);
  subtype w256 is std_logic_vector(255 downto 0);
  subtype w320 is std_logic_vector(319 downto 0);
  
  constant IV : w64 := x"00001000808c0001";
  constant hashIV : w64 := x"0000080100cc0002";
  constant RC : rc_array := (
    x"00", x"3C", x"2D", x"1E", x"0F", x"F0", x"E1", x"D2", x"C3", 
    x"B4", x"A5", x"96", x"87", x"78", x"69", x"5A", x"4B");
   
  function swap_endian_64b(x : w64) return w64;
  function swap_endian(x : w128) return w128;
  function swap_endian_320b(x : w320) return w320;
  function rotr(x : w64; n : integer) return w64;

end Ascon_pkg;

package body Ascon_pkg is

  function swap_endian_64b(x : w64)
    return w64 is
    variable r : w64;
  begin
    for i in 0 to 7 loop
      r((i*8)+7 downto i*8) := x((7-i)*8+7 downto (7-i)*8);
    end loop;
    return r;
  end function;

  function swap_endian(x : w128)
    return w128 is
    variable r : w128;
  begin
    for i in 0 to 15 loop
      r((i*8)+7 downto i*8) := x((15-i)*8+7 downto (15-i)*8);
    end loop;
    return r;
  end function;  
  
  function swap_endian_320b(x : w320)
    return w320 is
    variable r : w320;
  begin
    for i in 0 to 39 loop
      r((i*8)+7 downto i*8) := x((39-i)*8+7 downto (39-i)*8);
    end loop;
    return r;
  end function; 
  
  function rotr(x : w64; n : integer) return w64 is
  begin
    return std_logic_vector(rotate_right(unsigned(x), n));
  end function;
   
end Ascon_pkg;