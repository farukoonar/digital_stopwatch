--------------------------------------------------------------------------------
-- LIBRARY and PACKAGE DECLARATIONS
--------------------------------------------------------------------------------
-- standard package
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity bcd_incrementor is
generic(
c_oneslim 	: integer := 9;
c_tenslim 	: integer := 5
);
port(
CLK 		: in std_logic ;
increment_i : in std_logic ;
rst_i 		: in std_logic ;
ones_o 		: out std_logic_vector (3 downto 0);
tens_o 		: out std_logic_vector (3 downto 0);
carry_o		: out std_logic
);
end bcd_incrementor;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture Behavioral of bcd_incrementor is

--------------------------------------------------------------------------------
-- SIGNALS
--------------------------------------------------------------------------------
signal ones : std_logic_vector (3 downto 0) := (others => '0');
signal tens : std_logic_vector (3 downto 0) := (others => '0');

--------------------------------------------------------------------------------
-- BEGIN
--------------------------------------------------------------------------------
begin

--------------------------------------------------------------------------------
-- CONCURRENT STATEMENTS
--------------------------------------------------------------------------------
ones_o 	<= ones;
tens_o 	<= tens;

--------------------------------------------------------------------------------
-- PROCESS STATEMENTS 
-- NOTE: Process blocks work concurrently with each other
--------------------------------------------------------------------------------
-- SEQUENTIAL PROCESS
process(clk) begin
if(rising_edge(clk)) then
	carry_o <= '0';
    if(increment_i = '1') then
        if(ones = c_oneslim) then
            if(tens = c_tenslim) then
                tens 	<= (others => '0');
                ones 	<= (others => '0');
				carry_o <= '1';
            else
                ones <= (others => '0');
                tens <= tens + 1 ;
            end if;
        else
            ones <= ones + 1;
        end if;
    end if;
    
    if(rst_i = '1') then
        tens 	<= (others => '0');
        ones 	<= (others => '0');
		carry_o <= '0';
    end if;

end if;
end process;

end Behavioral;
