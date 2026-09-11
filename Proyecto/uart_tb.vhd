--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:43:43 05/27/2025
-- Design Name:   
-- Module Name:   C:/Users/ATC/Desktop/Trabajo2/trabajo2/uart_tb.vhd
-- Project Name:  trabajo2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: uart
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
USE ieee.numeric_std.ALL;
 
ENTITY uart_tb IS
END uart_tb;
 
ARCHITECTURE behavior OF uart_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT uart
    PORT(
         clk : IN  std_logic;
         reset_n : IN  std_logic;
         tx_ena : IN  std_logic;
         tx_data : IN  std_logic_vector(7 downto 0);
         rx : IN  std_logic;
         rx_busy : OUT  std_logic;
         rx_error : OUT  std_logic;
         rx_data : OUT  std_logic_vector(7 downto 0);
         tx_busy : OUT  std_logic;
         tx : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset_n : std_logic := '0';
   signal tx_ena : std_logic := '0';
   signal tx_data : std_logic_vector(7 downto 0) := (others => '0');
   signal rx : std_logic := '0';

 	--Outputs
   signal rx_busy : std_logic;
   signal rx_error : std_logic;
   signal rx_data : std_logic_vector(7 downto 0);
   signal tx_busy : std_logic;
   signal tx : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: uart PORT MAP (
          clk => clk,
          reset_n => reset_n,
          tx_ena => tx_ena,
          tx_data => tx_data,
          rx => rx,
          rx_busy => rx_busy,
          rx_error => rx_error,
          rx_data => rx_data,
          tx_busy => tx_busy,
          tx => tx
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin	
      --tx <= '1';
      reset_n <= '0';

      
      -- hold reset state for 100 ns.
      wait for 77 ns;	
      reset_n <= '1';
      tx_data <= "01101000";
      tx_ena <= '1';
      wait for clk_period*10;
      tx_ena <= '0';
      loop
      wait for 1 us;
      rx <= tx;
      end loop;

      -- insert stimulus here 

      wait;
   end process;

END;
