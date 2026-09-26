library IEEE;
use ieee.std_logic_1164.all;
use work.Ascon_pkg.all;

entity DiffusionLayer is
    Port ( dIN : in w320;
           dOUT : out w320);
end DiffusionLayer;

architecture Diffusion of DiffusionLayer is
begin
    dOut(63 downto 0) <= 
        dIN(63 downto 0) xor rotr(dIN(63 downto 0), 19) xor rotr(dIN(63 downto 0), 28);
        
    dOut(127 downto 64) <= 
        dIN(127 downto 64) xor rotr(dIN(127 downto 64), 61) xor rotr(dIN(127 downto 64), 39);
        
    dOut(191 downto 128) <= 
        dIN(191 downto 128) xor rotr(dIN(191 downto 128), 1) xor rotr(dIN(191 downto 128), 6);
        
    dOut(255 downto 192) <= 
        dIN(255 downto 192) xor rotr(dIN(255 downto 192), 10) xor rotr(dIN(255 downto 192), 17);
        
    dOut(319 downto 256) <= 
        dIN(319 downto 256) xor rotr(dIN(319 downto 256), 7) xor rotr(dIN(319 downto 256), 41);

end Diffusion;