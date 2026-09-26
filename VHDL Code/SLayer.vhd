library IEEE;
use ieee.std_logic_1164.all;
use work.Ascon_pkg.all;
entity SBox5b is
    Port ( sbIN_5b : in w5;
           sbOUT_5b : out w5);
end SBox5b;
architecture SboxArch of SBox5b is
begin
    sbOUT_5b(0) <= 
        (sbIN_5b(4) and sbIN_5b(1)) xor sbIN_5b(3) xor (sbIN_5b(2) and sbIN_5b(1)) xor 
        sbIN_5b(2) xor (sbIN_5b(1) and sbIN_5b(0)) xor sbIN_5b(1) xor sbIN_5b(0);
        
    sbOUT_5b(1) <= 
        sbIN_5b(4) xor (sbIN_5b(3) and sbIN_5b(2)) xor (sbIN_5b(3) and sbIN_5b(1)) xor 
        sbIN_5b(3) xor (sbIN_5b(2) and sbIN_5b(1)) xor sbIN_5b(2) xor sbIN_5b(1) xor sbIN_5b(0);
        
    sbOUT_5b(2) <= 
        (sbIN_5b(4) and sbIN_5b(3)) xor sbIN_5b(4) xor sbIN_5b(2) xor sbIN_5b(1) xor '1';
        
    sbOUT_5b(3) <= 
        (sbIN_5b(4) and sbIN_5b(0)) xor sbIN_5b(4) xor (sbIN_5b(3) and sbIN_5b(0)) xor 
        sbIN_5b(3) xor sbIN_5b(2) xor sbIN_5b(1) xor sbIN_5b(0);
        
    sbOUT_5b(4) <= 
        (sbIN_5b(4) and sbIN_5b(1)) xor sbIN_5b(4) xor sbIN_5b(3) xor (sbIN_5b(1) and 
        sbIN_5b(0)) xor sbIN_5b(1);
end SboxArch;

library IEEE;
use ieee.std_logic_1164.all;
use work.Ascon_pkg.all;
entity SBox320b is
    Port ( sbIN_320b : in w320;
           sbOUT_320b : out w320);
end SBox320b;
architecture SBoxArch of SBox320b is
begin
SBoxGenerate : for J in 0 to 63 generate
    SBoxEntity : entity work.SBox5b
    port map(sbIN_5b(0) => sbIN_320b(J), sbIN_5b(1) => sbIN_320b(J+64), sbIN_5b(2) => sbIN_320b(J+128), 
                    sbIN_5b(3) => sbIN_320b(J+192), sbIN_5b(4) => sbIN_320b(J+256),
             sbOUT_5b(0) => sbOUT_320b(J), sbOUT_5b(1) => sbOUT_320b(J+64), sbOUT_5b(2) => sbOUT_320b(J+128), 
                    sbOUT_5b(3) => sbOUT_320b(J+192), sbOUT_5b(4) => sbOUT_320b(J+256));
end generate;
end SBoxArch;
