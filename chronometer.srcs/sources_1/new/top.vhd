--------------------------------------------------------------------------------
-- LIBRARY and PACKAGE DECLARATIONS
--------------------------------------------------------------------------------
-- standard package
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity top is
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
end top;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture Behavioral of top is

--------------------------------------------------------------------------------
-- CONSTANTS
--------------------------------------------------------------------------------
constant c_debtime_ms	 	: integer 	:= 10;
constant c_initval 			: std_logic := '0';
constant c_seconds_oneslim 	: integer 	:= 9;
constant c_seconds_tenslim 	: integer 	:= 5;
constant c_minutes_oneslim 	: integer 	:= 9;
constant c_minutes_tenslim 	: integer 	:= 5;
constant c_timer1mslim  	: integer 	:= c_clkfreq/1_000;
constant c_timer1slim  		: integer 	:= c_clkfreq/1;

--------------------------------------------------------------------------------
-- COMPONENT DECLARATIONS
--------------------------------------------------------------------------------

-- debounce declaration
component debounce is
generic(
c_clkfreq 		: integer := 100_000_000;
c_debtime_ms : integer := 10;
c_initval 		: std_logic := '0'
);
port(
CLK 		: in std_logic;
signal_i 	: in std_logic;
signal_o 	: out std_logic
);
end component debounce;

-- bcd_to_sevenseg declaration
component bcd_to_sevenseg is
port(
bcd_i 		: in std_logic_vector (3 downto 0);
sevenseg_o 	: out std_logic_vector (6 downto 0)
);
end component bcd_to_sevenseg;

-- bcd_incrementor declaration
component bcd_incrementor is
generic(
c_oneslim 	: integer 	:= 9;
c_tenslim 	: integer 	:= 5
);
port(
CLK 		: in std_logic ;
increment_i : in std_logic ;
rst_i 		: in std_logic ;
ones_o 		: out std_logic_vector (3 downto 0);
tens_o 		: out std_logic_vector (3 downto 0);
carry_o 	: out std_logic
);
end component bcd_incrementor;

--------------------------------------------------------------------------------
-- TYPES
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- SIGNALS
--------------------------------------------------------------------------------
signal c_second_counterlim           : integer := c_clkfreq;

signal start_deb: std_logic     := '0';
signal reset_deb: std_logic     := '0';
signal second_incr         		: std_logic         := '0';
signal minute_incr         		: std_logic         := '0';

signal second_ones            	: std_logic_vector(3 downto 0) := (others => '0');
signal minute_ones            	: std_logic_vector(3 downto 0) := (others => '0');
signal second_tens             	: std_logic_vector(3 downto 0) := (others => '0');
signal minute_tens             	: std_logic_vector(3 downto 0) := (others => '0');

signal second_ones_seg        	: std_logic_vector(6 downto 0) := (others => '1');   
signal second_tens_seg         	: std_logic_vector(6 downto 0) := (others => '1');  
signal minute_ones_seg        	: std_logic_vector(6 downto 0) := (others => '1');  
signal minute_tens_seg         	: std_logic_vector(6 downto 0) := (others => '1');  

signal anodes                   : std_logic_vector(3 downto 0) := "1110";

signal timer1ms                 : integer range 0 to c_timer1mslim := 0;
signal timer1s                 	: integer range 0 to c_timer1slim := 0;


signal start_deb_prev           : std_logic := '0';
signal continue                 : std_logic := '0';
signal second_counter           : integer := 0;

signal dp_temp                  : std_logic := '0';

--------------------------------------------------------------------------------
-- BEGIN
--------------------------------------------------------------------------------	
begin

--------------------------------------------------------------------------------
-- COMPONENT INSTANTIATIONS
--------------------------------------------------------------------------------

-- Debounce instantiation 
i_debounce_start : debounce
generic map(
c_clkfreq 		=> c_clkfreq,
c_debtime_ms 	=> c_debtime_ms,
c_initval 		=> c_initval
)
port map(
CLK       => CLK,
signal_i  => START,
signal_o  => start_deb
);

i_debounce_reset : debounce
generic map(
c_clkfreq 		=> c_clkfreq,
c_debtime_ms 	=> c_debtime_ms,
c_initval	 	=> c_initval
)
port map(
CLK       => CLK,
signal_i  => RST,
signal_o  => reset_deb
);

-- bcd_incrementor instantiation
i_saniye_bcd_incrementor: bcd_incrementor
generic map(
c_oneslim 	=> c_seconds_oneslim,
c_tenslim  	=> c_seconds_tenslim
)
port map(
CLK         => CLK,
increment_i => second_incr,
rst_i       => reset_deb,
ones_o    	=> second_ones,
tens_o     	=> second_tens,
carry_o		=> minute_incr
);

i_dakika_bcd_incrementor: bcd_incrementor
generic map(
c_oneslim => c_minutes_oneslim,
c_tenslim  => c_minutes_tenslim
)
port map(
CLK         => CLK,
increment_i => minute_incr,
rst_i       => reset_deb,
ones_o    	=> minute_ones,
tens_o     	=> minute_tens,
carry_o		=> open
);

-- bcd_to_sevenseg instantiation 
i_second_ones : bcd_to_sevenseg 
port map(
bcd_i      => second_ones,
sevenseg_o => second_ones_seg
);

i_second_tens : bcd_to_sevenseg 
port map(
bcd_i      => second_tens,
sevenseg_o => second_tens_seg
);

i_minute_ones : bcd_to_sevenseg 
port map(
bcd_i      => minute_ones,
sevenseg_o => minute_ones_seg
);

i_minute_tens : bcd_to_sevenseg 
port map(
bcd_i      => minute_tens,
sevenseg_o => minute_tens_seg
);

--------------------------------------------------------------------------------
-- CONCURRENT STATEMENTS
--------------------------------------------------------------------------------
an <= anodes;

--------------------------------------------------------------------------------
-- PROCESS STATEMENTS 
-- NOTE: Process blocks work concurrently with each other
--------------------------------------------------------------------------------
-- COMBINATIONAL PROCESS


-- SEQUENTIAL PROCESS
-- main process
P_MAIN : process(clk) begin
if(rising_edge(clk)) then
    start_deb_prev <= start_deb;
    if(start_deb = '1' and start_deb_prev = '0') then
        continue <= not continue;
    end if;
    
    second_incr <= '0';
    
    if(continue = '1') then
        if(second_counter = c_second_counterlim) then
            second_counter <= 0;
            second_incr <= '1';
        else
            second_counter <= second_counter + 1;
        end if;
            
    end if;
    
    if(reset_deb = '1') then
        second_counter <= 0;
		continue <= '0';
    end if;

end if;
end process;    

-- anodes process
P_ANODES : process(clk) begin
if(rising_edge(clk)) then
    if (timer1ms = c_timer1mslim-1) then
        timer1ms <= 0;
        anodes(3 downto 1) <= anodes(2 downto 0);
        anodes(0) <= anodes(3);
    else
        timer1ms <= timer1ms + 1;
    end if;
end if;
end process;


-- dp process
P_DP : process(clk) begin
if(rising_edge(clk)) then
    if (timer1s = c_timer1slim-1) then
        timer1s <= 0;
        dp_temp <= not dp_temp;
    else
        timer1s <= timer1s + 1;
    end if;
end if;
end process;

-- cathodes process
P_CATHODES : process(clk) begin
if(rising_edge(clk)) then
    if(anodes(0) = '0') then
        seg <= second_ones_seg;
        dp <= '1';
    elsif(anodes(1) = '0') then
        seg <= second_tens_seg;
        dp <= '1';
        
    elsif(anodes(2) = '0') then
        seg <= minute_ones_seg;
        dp <= dp_temp;
   
    elsif(anodes(3) = '0') then
        seg <= minute_tens_seg;
        dp <= '1';
    else
        seg <= (others => '1');
        dp <= '1';
    end if;
end if;
end process;

end Behavioral;
