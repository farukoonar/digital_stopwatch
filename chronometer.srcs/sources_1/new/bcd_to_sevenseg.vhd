--------------------------------------------------------------------------------
-- LIBRARY and PACKAGE DECLARATIONS
--------------------------------------------------------------------------------
-- standard package
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity bcd_to_sevenseg is
port(
bcd_i : in std_logic_vector (3 downto 0);
sevenseg_o : out std_logic_vector (6 downto 0)
);
end bcd_to_sevenseg;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture Behavioral of bcd_to_sevenseg is

--------------------------------------------------------------------------------
-- BEGIN
--------------------------------------------------------------------------------	
begin

--------------------------------------------------------------------------------
-- PROCESS STATEMENTS 
-- NOTE: Process blocks work concurrently with each other
--------------------------------------------------------------------------------
-- COMBINATIONAL PROCESS
process(bcd_i) begin

    case bcd_i is
    
        when "0000" =>  -- 0
            sevenseg_o <= "1000000";  -- ABCDEF on, G off
            
        when "0001" =>  -- 1
            sevenseg_o <= "1111001";  -- BC on
            
        when "0010" =>  -- 2
            sevenseg_o <= "0100100";  -- ABDEG on, CF off
            
        when "0011" =>  -- 3
            sevenseg_o <= "0110000";  -- ABCDG on, EF off
            
        when "0100" =>  -- 4
            sevenseg_o <= "0011001";  -- BCFG on, ADE off
            
        when "0101" =>  -- 5
            sevenseg_o <= "0010010";  -- ACDFG on, BE off
            
        when "0110" =>  -- 6
            sevenseg_o <= "0000010";  -- ACDEFG on, B off
            
        when "0111" =>  -- 7
            sevenseg_o <= "1111000";  -- ABC on
            
        when "1000" =>  -- 8
            sevenseg_o <= "0000000";  -- ABCDEFG on
            
        when "1001" =>  -- 9
            sevenseg_o <= "0010000";  -- ABCDFG on, E off
            
        when others => -- others
            sevenseg_o <= "1111111";  -- All off
   
    end case;
                                       
end process;
end Behavioral;
