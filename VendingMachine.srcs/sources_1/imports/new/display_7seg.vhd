library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;


entity display_7seg is
    Port ( n : in STD_LOGIC_VECTOR (9 downto 0);   -- the 10-bit number to display
           state : in STD_LOGIC_VECTOR (0 to 3);   -- state code
           clock, reset : in STD_LOGIC;
           AN : out STD_LOGIC_VECTOR (7 downto 0); -- anodes
           seg : out STD_LOGIC_VECTOR (0 to 6));   -- cathodes
end display_7seg;

architecture Behavioral of display_7seg is
    component bin_to_bcd_10 is -- convert number from binary to BCD
    Port ( b : in STD_LOGIC_VECTOR (9 downto 0);
           nr : out STD_LOGIC_VECTOR (15 downto 0));
    end component;
    
    component bcd_to_cathodes is -- print to display an alphanumeric character
        Port ( x : in STD_LOGIC_VECTOR (4 downto 0); -- identifier for alphanumeric character
               seg : out STD_LOGIC_VECTOR (0 to 6)); -- cathodes for 7-segment display
    end component;
    
    signal groups : STD_LOGIC_VECTOR (15 downto 0); -- 4 groups corresponding to 4 BCDs
    signal bcd : STD_LOGIC_VECTOR (4 downto 0);     -- current digit

    signal LED_activating_counter : std_logic_vector(2 downto 0);
    -- 3 bits for selecting one of the 8 LEDs
    -- count         0   ->  1  ->  2  ->  3  ->  4  ->  5  ->  6  ->  7
    -- activates    LED7    LED6   LED5   LED4   LED3   LED2   LED1   LED0
    
begin
    convert_int_to_bcd: bin_to_bcd_10 PORT MAP (b => n, nr => groups);
    display: bcd_to_cathodes PORT MAP (x => bcd, seg => seg);
    
    process (clock, reset)
    begin 
        if (reset = '0') then
            LED_activating_counter <= (others => '0');
        elsif (rising_edge(clock)) then
            LED_activating_counter <= LED_activating_counter + 1;
        end if;
    end process;
    
    -- 8-to-1 MUX to generate anode activating signals for 8 LEDs 
    process (LED_activating_counter, groups, state)
    begin
        case LED_activating_counter is
        ---------------------------------------- print number => bcd(4) <= '0'
        when "100" =>
            -- activate LED3 and deactivate others
            AN <= "11110111"; 
            bcd(3 downto 0) <= groups(15 downto 12); -- the first digit of the number
            bcd(4) <= '0';
            
        when "101" =>
            -- activate LED2 and deactivate others
            AN <= "11111011"; 
            bcd(3 downto 0) <= groups(11 downto 8); -- the second digit of the number
            bcd(4) <= '0';
            
        when "110" =>
            -- activate LED1 and deactivate others
            AN <= "11111101"; 
            bcd(3 downto 0) <= groups(7 downto 4);  -- the third digit of the number
            bcd(4) <= '0';
           
        when "111" =>
            -- activate LED0 and deactivate others
            AN <= "11111110"; 
            bcd(3 downto 0) <= groups(3 downto 0); -- the fourth digit of the number 
            bcd(4) <= '0';
        
        ---------------------------------------- print state => bcd(4) <= '1'
        when "000" =>
            -- activate LED7
            AN <= "01111111"; 
            case state is
                when others => bcd(3 downto 0) <= "1111"; -- display nothing
            end case;
            bcd(4) <= '1';
            
        when "001" =>
            -- activate LED6
            AN <= "10111111"; 
            case state is
                when "0000" => bcd(3 downto 0) <= "0000"; -- INIT | InI
                when "0011" => bcd(3 downto 0) <= "0010"; -- sCARD | SCd
                when "0100" => bcd(3 downto 0) <= "0010"; -- sCASH | SCH
                when "0101" => bcd(3 downto 0) <= "0001"; -- bCARD | bCd
                when "0110" => bcd(3 downto 0) <= "0001"; -- bCASH | bCH
                when "0111" => bcd(3 downto 0) <= "0010"; -- sREADY | SrE
                when "1000" => bcd(3 downto 0) <= "0001"; -- bREADY | brE
                when "1001" => bcd(3 downto 0) <= "0101"; -- DONE | dnE
                when others => bcd(3 downto 0) <= "1111";
            end case;
            bcd(4) <= '1';
            
        when "010" =>
            -- activate LED5
            AN <= "11011111"; 
            case state is
                when "0000" => bcd(3 downto 0) <= "1000"; -- INIT | InI
                when "0011" => bcd(3 downto 0) <= "0011"; -- sCARD | SCd
                when "0100" => bcd(3 downto 0) <= "0011"; -- sCASH | SCH
                when "0101" => bcd(3 downto 0) <= "0011"; -- bCARD | bCd
                when "0110" => bcd(3 downto 0) <= "0011"; -- bCASH | bCH
                when "0111" => bcd(3 downto 0) <= "0100"; -- sREADY | SrE
                when "1000" => bcd(3 downto 0) <= "0100"; -- bREADY | brE
                when "1001" => bcd(3 downto 0) <= "1000"; -- DONE | dnE
                when others => bcd(3 downto 0) <= "1111";
            end case;
            bcd(4) <= '1';
           
        when "011" =>
            -- activate LED4
            AN <= "11101111"; 
            case state is
                when "0000" => bcd(3 downto 0) <= "0000"; -- INIT | InI
                when "0001" => bcd(3 downto 0) <= "0010"; -- SMALL | S
                when "0010" => bcd(3 downto 0) <= "0001"; -- BIG | b
                when "0011" => bcd(3 downto 0) <= "0101"; -- sCARD | SCd
                when "0100" => bcd(3 downto 0) <= "0110"; -- sCASH | SCH
                when "0101" => bcd(3 downto 0) <= "0101"; -- bCARD | bCd
                when "0110" => bcd(3 downto 0) <= "0110"; -- bCASH | bCH
                when "0111" => bcd(3 downto 0) <= "0111"; -- sREADY | SrE
                when "1000" => bcd(3 downto 0) <= "0111"; -- bREADY | brE  
                when "1001" => bcd(3 downto 0) <= "0111"; -- DONE | dnE                              
                when others => bcd(3 downto 0) <= "0000";
            end case;
            bcd(4) <= '1';
            
        when others =>
            AN <= "11111111";
            bcd <= "0000"; 
        end case;
    end process;

end Behavioral;
