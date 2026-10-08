--------------------------------------------------------------------------------
-- LIBRARY and PACKAGE DECLARATIONS
--------------------------------------------------------------------------------
-- standard package
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--------------------------------------------------------------------------------
-- TESTBENCH ENTITY
--------------------------------------------------------------------------------
entity tb_bcd_incrementor is
generic(
c_oneslim 	: integer := 9;
c_tenslim 	: integer := 5
);
end tb_bcd_incrementor;

--------------------------------------------------------------------------------
-- TESTBENCH ARCHITECTURE
--------------------------------------------------------------------------------
architecture Behavioral of tb_bcd_incrementor is

----------------------------------------------------------------------------
--  COMPONENT INSTANTIATION
----------------------------------------------------------------------------
component bcd_incrementor is
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
end component;

----------------------------------------------------------------------------
-- CONSTANTS
----------------------------------------------------------------------------
constant c_clkperiod : time := 10 ns;

----------------------------------------------------------------------------
-- SIGNALS
----------------------------------------------------------------------------
signal CLK 			: std_logic ;
signal increment_i 	: std_logic ;
signal rst_i 		: std_logic ;
signal ones_o 		: std_logic_vector (3 downto 0);
signal tens_o 		: std_logic_vector (3 downto 0);
signal carry_o		: std_logic;

----------------------------------------------------------------------------
-- BEGIN
----------------------------------------------------------------------------
begin

----------------------------------------------------------------------------
-- UUT (Unit Under Test) 
----------------------------------------------------------------------------
UUT: bcd_incrementor 
generic map(
c_oneslim 	=>c_oneslim,
c_tenslim 	=>c_tenslim
)
port map( 
CLK 		   => CLK ,
increment_i    => increment_i ,
rst_i 		   => rst_i 	,
ones_o 		   => ones_o 	,
tens_o 		   => tens_o	,
carry_o		   => carry_o		
);

----------------------------------------------------------------------------
-- CLOCK GENERATOR PROCESS
----------------------------------------------------------------------------
P_CLKGEN : process begin
CLK <= '0';
wait for c_clkperiod/2;
CLK <= '1';
wait for c_clkperiod/2;
end process;

----------------------------------------------------------------------------
-- STIMULUS PROCESS
----------------------------------------------------------------------------
P_STIMULI: process begin
increment_i <= '0';
rst_i 		<= '0';
wait for 20 ns;

increment_i <= '1';
wait for 400 ns;
increment_i <= '0';
wait for 400 ns;
rst_i 		<= '1';
wait for 20 ns;
increment_i <= '1';
wait for 200 ns;
rst_i 		<= '0';
wait for 650 ns;

assert false
report "SIM DONE"
severity failure;

end process;

end Behavioral;
