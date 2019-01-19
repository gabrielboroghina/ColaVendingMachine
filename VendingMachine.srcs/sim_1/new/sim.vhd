library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sim is
--  Port ( );
end sim;

architecture Behavioral of sim is
component vending_machine is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           size_small,size_big: in STD_LOGIC;
           card : in STD_LOGIC;
           led_small,led_big : out STD_LOGIC;
           cat : out STD_LOGIC_VECTOR (0 to 6);
           sum : in STD_LOGIC_VECTOR (0 to 2);
           AN : out STD_LOGIC_VECTOR (7 downto 0)
         );
end component;

    signal crd, ss, sb, ls, lb : std_logic := '0';
    signal cat0 : STD_LOGIC_VECTOR (0 to 6) := (others => '1');
    signal sum0 : STD_LOGIC_VECTOR (0 to 2) := "000";
    signal AN0 : STD_LOGIC_VECTOR (7 downto 0) := (others => '1');
    signal clk0 : std_logic := '0';
    signal cnt : std_logic_vector(9 downto 0);
begin
    clk0 <= not clk0 after 2ns;
    det : vending_machine PORT MAP (clk => clk0, reset => '1', size_small => ss,
         size_big => sb, card => '0', led_small => ls, led_big => lb,cat => cat0, sum => sum0, AN => AN0);
process
begin
      wait for 5ns;
      sb <= '1';
      wait for 50ns;
      sum0 <= "001";
      wait for 10ns;
      sum0 <= "010";
      wait for 10ns;
      sum0 <= "001";
      wait for 10ns;
end process;
end Behavioral;
