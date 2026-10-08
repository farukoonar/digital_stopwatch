--------------------------------------------------------------------------------
-- LIBRARY and PACKAGE DECLARATIONS
--------------------------------------------------------------------------------
-- standard package
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity debounce is
generic(
c_clkfreq 		: integer 	:= 100_000_000;
c_debtime_ms	: integer 	:= 10;
c_initval 		: std_logic := '0'
);
port(
CLK 		: in std_logic;
signal_i 	: in std_logic;
signal_o 	: out std_logic
);
end debounce;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture Behavioral of debounce is

--------------------------------------------------------------------------------
-- CONSTANTS
--------------------------------------------------------------------------------
constant c_timerlim : integer := (c_clkfreq/1_000)*c_debtime_ms;

--------------------------------------------------------------------------------
-- COMPONENT DECLARATIONS
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- TYPES
--------------------------------------------------------------------------------
type t_state is (S_INITIAL, S_ZERO, S_ZEROTOONE, S_ONE, S_ONETOZERO);
signal state : t_state := S_INITIAL;

--------------------------------------------------------------------------------
-- SIGNALS
--------------------------------------------------------------------------------
signal timer 			: integer range 0 to c_timerlim := 0;
signal timer_en 		: std_logic 					:= '0';
signal timer_tick 		: std_logic 					:= '0';
signal sync_reg     	: std_logic_vector(1 downto 0)	:= (others => c_initval);
signal signal_i_sync	: std_logic 					:= c_initval;

--------------------------------------------------------------------------------
-- BEGIN
--------------------------------------------------------------------------------	
begin

--------------------------------------------------------------------------------
-- COMPONENT INSTANTIATIONS
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- CONCURRENT STATEMENTS
--------------------------------------------------------------------------------
signal_i_sync <= sync_reg(1);

--------------------------------------------------------------------------------
-- PROCESS STATEMENTS 
-- NOTE: Process blocks work concurrently with each other
--------------------------------------------------------------------------------
-- COMBINATIONAL PROCESS


-- SEQUENTIAL PROCESS
-- synchronizer
P_SYNC : process(clk) begin
if rising_edge(clk) then
	sync_reg(1) 	<= sync_reg(0);
	sync_reg(0)     <= signal_i;
end if;
end process;

-- state machine
P_STATE : process(clk) begin
if(rising_edge(CLK)) then
    case state is
        when S_INITIAL =>
			signal_o <= c_initval;
			
            if(c_initval ='0' ) then
                state <= S_ZERO;
            else
                state <= S_ONE;
            end if;
            
        when S_ZERO =>
            signal_o <= '0';
            
            if (signal_i_sync = '1') then
                state <= S_ZEROTOONE;  
            end if;
                
        when S_ZEROTOONE =>
            signal_o <= '0';
            timer_en <= '1';
            
            if(timer_tick = '1') then
                state <= S_ONE;
                timer_en <= '0';
            end if;
            
            if(signal_i_sync = '0') then
                state <= S_ZERO;
                timer_en <= '0';
            end if;
        when S_ONE =>
            signal_o <= '1';
            
            if (signal_i_sync = '0') then
                state <= S_ONETOZERO;  
            end if;
            
        when S_ONETOZERO =>
            signal_o <= '1';
            timer_en <= '1';
            
            if(timer_tick = '1') then
                state <= S_ZERO;
                timer_en <= '0';
            end if;
            
            if(signal_i_sync = '1') then
                state <= S_ONE;
                timer_en <= '0';
            end if;
    
    end case;
end if;
end process;

-- timer
P_TIMER: process(clk) begin
if(rising_edge(clk)) then
    if (timer_en = '1') then
        if(timer >= c_timerlim-1) then
            timer_tick <= '1';
            timer <= 0;
        else
            timer_tick <= '0';
            timer <= timer + 1;
        end if;
    else   
        timer_tick <= '0';
        timer <= 0;
    end if;
end if;
end process;
end Behavioral;
