--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:12:13 06/03/2025
-- Design Name:   
-- Module Name:   C:/Users/Alumnos/Desktop/trabajo 2 post prueba fallida/prueba 1 trabajo 2 dda/Trabajo2/trabajo2/reception_uart_bt_lcd_tb.vhd
-- Project Name:  trabajo2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: reception_uart_bt_lcd
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY reception_uart_bt_lcd_tb IS
END reception_uart_bt_lcd_tb;
 
ARCHITECTURE behavior OF reception_uart_bt_lcd_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT reception_uart_bt_lcd
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         rx : IN  std_logic;
         e : OUT  std_logic;
         rs : OUT  std_logic;
         rw : OUT  std_logic;
         db : OUT  std_logic_vector(7 downto 0);
         tx : OUT  std_logic;
         Send_ok : OUT  std_logic;
         Send_error : OUT  std_logic
        );
    END COMPONENT;
    
   component uart
        
        Port (
            clk       : in  std_logic;
            reset_n   : in  std_logic;
            tx_ena    : in  std_logic;
            tx_data   : in  std_logic_vector(7 downto 0);
            rx        : in  std_logic;
            rx_busy   : out std_logic;
            rx_error  : out std_logic;
            tx_busy   : out std_logic;
            tx        : out std_logic;
            rx_data   : out std_logic_vector(7 downto 0)
        );
    end component;
   
   
   
   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
	signal reset_n : std_logic;
   signal rx0 : std_logic := '0';
	signal rx1: std_logic := '0';
   signal enb : std_logic := '0';
   signal addrb : std_logic_vector(4 downto 0) := (others => '0');
	signal tx_data: std_logic_vector(7 downto 0);
	signal tx_ena: std_logic;

 	--Outputs
   signal dob : std_logic_vector(7 downto 0);
   signal tx0 : std_logic;
	signal tx1 : std_logic;
   signal send_ok : std_logic;
   signal send_error : std_logic;
	signal rx_busy: std_logic;
	signal tx_busy: std_logic;
	signal rx_data: std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	uut1: uart PORT MAP (
          clk => clk,
          reset_n => reset_n,
          tx_ena => tx_ena,
          tx_data => tx_data,
          rx => rx0,
          rx_busy => rx_busy,
          rx_error => open,
          rx_data => rx_data,
          tx_busy => tx_busy,
          tx => tx0
        );
   
   
   -- Instantiate the Unit Under Test (UUT)
   uut: reception_uart_bt_lcd PORT MAP (
          clk => clk,
          reset => reset,
          rx => rx,
          e => e,
          rs => rs,
          rw => rw,
          db => db,
          tx => tx,
          Send_ok => Send_ok,
          Send_error => Send_error
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
 in_out: process
 begin
		rx0 <= tx1;
		rx1 <= tx0;
		wait for clk_period;
 end process;
 
   -- Stimulus process

      -- insert stimulus here 
stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		reset <= '1';
		reset_n <= '0';
      wait for clk_period*10;
		reset <= '0';
		reset_n <= '1';
      -- insert stimulus here 
		tx_ena <= '1';
		tx_data <= x"41"; --A
		wait for 10 ns;
		tx_ena <= '0';
		wait for 1.5 ms;
		tx_data <= x"42"; --B
		tx_ena <= '1';
		wait for 10 ns;
		tx_ena <= '0';
		wait for 1.5 ms;
		tx_data <= x"0A"; --CR
		tx_ena <= '1';
		wait for 10 ns;
		tx_ena <= '0';
		
		wait for 2 ms;
		enb <= '1';
		addrb <= "00000";
		wait for 1 us;
		addrb <= "00001";
		wait for 1 us;
		addrb <= "00010";
		wait for 1 us;
		addrb <= "00011";
		wait for 1 us;
		addrb <= "00100";
		wait for 1 us;
		addrb <= "00101";
		wait for 1 us;
		addrb <= "00110";
		wait for 1 us;
		
     
      wait;
   end process;

END;
