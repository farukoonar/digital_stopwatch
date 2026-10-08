--------------------------------------------------------------------------------
-- LIBRARY and PACKAGE DECLARATIONS
--------------------------------------------------------------------------------
-- standard package
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--------------------------------------------------------------------------------
-- TESTBENCH ENTITY
--------------------------------------------------------------------------------
entity tb_top is
generic(
c_clkfreq 	: integer := 1
);
end tb_top;

--------------------------------------------------------------------------------
-- TESTBENCH ARCHITECTURE
--------------------------------------------------------------------------------
architecture Behavioral of tb_top is

----------------------------------------------------------------------------
--  COMPONENT INSTANTIATION
----------------------------------------------------------------------------
component top is
generic(
c_clkfreq 	: integer := 100_000_000
);
port(
CLK 		: in std_logic;
RST 		: in std_logic;
START 		: in std_logic;
seg 		: out std_logic_vector( 6 downto 0);
dp 			: out std_logic;
an 			: out std_logic_vector (3 downto 0)
);
end component;


----------------------------------------------------------------------------
-- CONSTANTS
----------------------------------------------------------------------------
constant c_clkperiod : time := 10 ns;

----------------------------------------------------------------------------
-- SIGNALS
----------------------------------------------------------------------------
signal CLK 		: std_logic := '0';
signal RST 		: std_logic;
signal START 	: std_logic;
signal seg 		: std_logic_vector( 6 downto 0);
signal dp 		: std_logic;
signal an 		: std_logic_vector (3 downto 0);

----------------------------------------------------------------------------
-- BEGIN
----------------------------------------------------------------------------
begin

----------------------------------------------------------------------------
-- UUT (Unit Under Test) 
----------------------------------------------------------------------------
UUT : top
generic map(
c_clkfreq 	=> c_clkfreq
)
port map(
CLK 	=> CLK 		 ,
RST 	=> RST 	     ,
START 	=> START 	 ,
seg 	=> seg 	     ,
dp 		=> dp 		 ,
an 		=> an 		
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
RST <= '1';
wait for 20 ns;

RST 	<= '0';
START 	<= '1';
wait for 75 us;

assert false
report "SIM DONE"
severity failure;

end process;

end Behavioral;
