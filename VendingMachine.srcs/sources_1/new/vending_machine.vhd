library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;


entity vending_machine is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           size_small,size_big : in STD_LOGIC;    -- size selectors
           card : in STD_LOGIC;                   -- card/cash selector
           led_small,led_big : out STD_LOGIC;     -- LEDs for delivered product
           cat : out STD_LOGIC_VECTOR (0 to 6);   -- cathodes
           sum : in STD_LOGIC_VECTOR (0 to 2);    -- inputs for different money sums
           AN : out STD_LOGIC_VECTOR (7 downto 0) -- anodes
          );
end vending_machine;

architecture Behavioral of vending_machine is
    component display_7seg is -- display 10-bit number (money sum) and state on the 7-seg display
       Port ( n : in STD_LOGIC_VECTOR (9 downto 0);  -- the number to display
              clock, reset : in STD_LOGIC;
              AN : out STD_LOGIC_VECTOR (7 downto 0);
              seg : out STD_LOGIC_VECTOR (0 to 6);
              state : in STD_LOGIC_VECTOR (0 to 3)); -- the state code
    end component;
    
    procedure update_counter(sum, sum_old: in std_logic_vector (0 to 2);
                             signal counter : inout unsigned(9 downto 0) ) is
        -- update counter only on the 'button pressed' events
        begin
             if (sum_old (0) = '0' and sum(0) = '1') then    -- sum(0) button pressed
                counter <= counter + 1;
             elsif (sum_old (1) = '0' and sum(1) = '1') then -- sum(1) button pressed
                counter <= counter + 5;
             elsif (sum_old (2) = '0' and sum(2) = '1') then -- sum(2) button pressed
                counter <= counter + 10;
             end if;
    end update_counter;

    type state_type is (INIT, sCASH, sCARD, bCARD, bCASH, SMALL, BIG, sREADY, bREADY, DONE); -- states of the FSM
    signal state : state_type := INIT;                             -- current state
    signal counter : unsigned(9 downto 0) := (others => '0');      -- counter for the inserted money sum
    signal cnt : std_logic_vector(9 downto 0);                     -- logic_vector version of the counter
    signal sum_old : std_logic_vector(0 to 2) := "000";            -- old states of the sum inputs (buttons)
    signal state_index : std_logic_vector(0 to 3) := "0000";       -- state codes
    signal wait_counter : unsigned(8 downto 0) := (others => '0'); -- counter for state transition delays

begin
    cnt <= std_logic_vector(counter);
    disp: display_7seg PORT MAP (n => cnt, clock => clk, reset => reset, AN => AN, seg => cat, state => state_index);
    
    process(clk, reset)
    begin
        if (reset = '0') then
            state <= INIT; -- reset state
            state_index <= "0000";
            counter <= (others => '0');
        elsif (rising_edge(clk)) then
            case state is
                when INIT =>
                    if(size_small = '1') then   -- small size selected
                        state <= SMALL;
                        state_index <= "0001";
                        wait_counter <= (others => '0');
                    elsif (size_big = '1') then -- big size selected
                        state <= BIG;
                        state_index <= "0010";
                        wait_counter <= (others => '0');
                    end if;
                    led_small <= '0';
                    led_big <= '0';

                when SMALL =>
                    if (wait_counter = "111111111") then -- the waiting (transition) time is over
                        counter <= (others => '0');
                        if(card = '1') then -- card payment selected
                            state <= sCARD;
                            wait_counter <= (others => '0');
                            state_index <= "0011";
                        else                -- cash payment selected
                            state <= sCASH;
                            state_index <= "0100";
                        end if;
                    else
                        wait_counter <= wait_counter + 1;
                    end if;

                when BIG =>
                   if (wait_counter = "111111111") then -- the waiting (transition) time is over
                         if(card = '1') then -- card payment selected
                             state <= bCARD;
                             wait_counter <= (others => '0');
                             state_index <= "0101";
                         else                -- cash payment selected
                             state <= bCASH;
                             state_index <= "0110";
                         end if;
                    else
                        wait_counter <= wait_counter + 1;
                    end if;
 
                when sCARD =>
                    if (wait_counter = "111111111") then -- the waiting (transition) time is over
                         led_small <= '1'; -- deliver small soda
                         state <= DONE;
                         state_index <= "1001";
                     else
                         wait_counter <= wait_counter + 1;
                     end if;
 
                 when bCARD =>
                     if (wait_counter = "111111111") then -- the waiting (transition) time is over
                         led_big <= '1'; -- deliver big soda
                         state <= DONE;
                         state_index <= "1001";
                     else
                         wait_counter <= wait_counter + 1;
                     end if;
                      
                when sCASH =>
                     -- check the total introduced sum
                     if (counter >= 7) then -- enough money
                         state <= sREADY;
                         state_index <= "0111";
                     else -- continue to take money
                         update_counter(sum, sum_old, counter);
                     end if;

                when bCASH =>
                     -- check the total introduced sum
                     if (counter >= 20) then -- enough money
                         state <= bREADY;
                         state_index <= "1000";
                     else -- continue to take money
                         update_counter(sum, sum_old, counter);
                     end if;

                when sREADY =>
                     led_small <= '1'; -- deliver small soda
                     -- print the extra-money to display
                     counter <= counter + "1111111001"; -- substract 7(price for small soda) from counter
                     state <= DONE;
                     state_index <= "1001";

                when bREADY =>
                     led_big <= '1'; -- deliver big soda
                     -- print the extra-money to display
                     counter <= counter + "1111101100"; -- substract 20(price for small soda) from counter
                     state <= DONE;
                     state_index <= "1001";

                when others => NULL;
            end case;
            -- update sum_old (push buttons' states)
            sum_old <= sum;
        end if;
    end process;
end Behavioral;
