library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- convert number from binary to BCD
entity bin_to_bcd_10 is
    Port ( b : in STD_LOGIC_VECTOR (9 downto 0);     -- 10-bit integer
           nr : out STD_LOGIC_VECTOR (15 downto 0)); -- binary-coded decimal (BCD)
end bin_to_bcd_10;

architecture Behavioral of bin_to_bcd_10 is
    function correct(signal b : std_logic_vector (3 downto 0)) return std_logic_vector is
    begin
        if (b(3) or (b(2) and (b(1) or b(0)))) = '1' then  -- if b >= 5
            return std_logic_vector(unsigned(b) + "0011"); -- add 3 to b
        else
            return b;
        end if;
    end function;
    
    signal X0, X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11 : std_logic_vector (3 downto 0) := "1111";
    signal Y0, Y1, Y2, Y3, Y4, Y5, Y6, Y7, Y8, Y9, Y10, Y11 : std_logic_vector (3 downto 0) := "1111";
    
begin
    -- async parallel BINARY - parallel BCD conversion
    -- convert the 10-bit number using 12 elementary conversion cells
    X0 <= '0' & b(9 downto 7);
    X1 <= Y0(2 downto 0) & b(6);
    X2 <= Y1(2 downto 0) & b(5);
    X3 <= '0' & Y0(3) & Y1(3) & Y2(3);
    X4 <= Y2(2 downto 0) & b(4);
    X5 <= Y3(2 downto 0) & Y4(3);
    X6 <= Y4(2 downto 0) & b(3);
    X7 <= Y5(2 downto 0) & Y6(3);
    X8 <= Y6(2 downto 0) & b(2);
    X9 <= '0' & Y3(3) & Y5(3) & Y7(3);
    X10 <= Y7(2 downto 0) & Y8(3);
    X11 <= Y8(2 downto 0) & b(1);
    
    -- correct the values greater than 4 (so that left-shifting to be done correctly)
    Y0 <= correct(X0);
    Y1 <= correct(X1);
    Y2 <= correct(X2);
    Y3 <= correct(X3);
    Y4 <= correct(X4);
    Y5 <= correct(X5);
    Y6 <= correct(X6);
    Y7 <= correct(X7);
    Y8 <= correct(X8);
    Y9 <= correct(X9);
    Y10 <= correct(X10);
    Y11 <= correct(X11);
    
    nr <= "000" & Y9 & Y10 & Y11 & b(0);
end Behavioral;
