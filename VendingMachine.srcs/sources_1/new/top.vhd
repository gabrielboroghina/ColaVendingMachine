----------------------------------------------------------------------------------
-- Group: 323CB 
-- Students: Gabriel Boroghina & Mihaela Catrina
-- 
-- Create Date: 04/12/2018 03:00:28 PM
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: Vending Machine
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_bit.ALL;

entity top is
    Port ( clk100MHz : in BIT;                     -- high frequency clock
           reset : in STD_LOGIC;
           CAT : out STD_LOGIC_VECTOR (0 to 6);    -- cathodes
           AN : out STD_LOGIC_VECTOR (7 downto 0); -- anodes
           clk_led : out BIT;                      -- output led for clock
           size_small,size_big : in STD_LOGIC;     -- size selectors
           card : in STD_LOGIC;                    -- card/cash selector
           led_small,led_big : out STD_LOGIC;      -- LEDs for delivered product
           sum : in STD_LOGIC_VECTOR (0 to 2)      -- inputs for different money sums
          );
end top;

architecture Behavioral of top is
    component clk_divider is -- clock frequency divider
        Port ( clk100MHz : in BIT;
               clk : out BIT);
    end component;
    
    component vending_machine is -- finite state machine
        Port ( clk : in BIT;
               reset : in STD_LOGIC;
               size_small,size_big : in STD_LOGIC;
               card : in STD_LOGIC;
               led_small,led_big : out STD_LOGIC;
               cat : out STD_LOGIC_VECTOR (0 to 6);
               sum : in STD_LOGIC_VECTOR (0 to 2);
               AN : out STD_LOGIC_VECTOR (7 downto 0)
             );
    end component;
    
    signal clk : BIT;
begin
    clk_led <= clk; -- display clk on a led
    
    clock_div: clk_divider PORT MAP (clk100MHz => clk100MHz, clk => clk);
    FSM: vending_machine PORT MAP (clk => clk, reset => reset, size_small => size_small, size_big => size_big, card => card, led_small => led_small, led_big => led_big, cat => CAT, sum => sum, AN => AN);
end Behavioral;
