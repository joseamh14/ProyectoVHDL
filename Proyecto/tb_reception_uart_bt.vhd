--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:38:31 05/28/2025
-- Design Name:   
-- Module Name:   C:/Users/ATC/Desktop/Trabajo2/trabajo2/tb_reception_uart_bt.vhd
-- Project Name:  trabajo2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: reception_uart_bt
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_reception_uart_bt is
end tb_reception_uart_bt;

architecture Behavioral of tb_reception_uart_bt is
    -- Constantes
    constant CLK_PERIOD : time := 10 ns;  -- 100 MHz
    constant BIT_PERIOD : time := 104.16 us; -- 9600 baudios
    
    -- Componente a testear
    component reception_uart_bt
        Port (
            clk        : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            rx         : in  STD_LOGIC;
            enb        : in  STD_LOGIC;
            addrb      : in  STD_LOGIC_VECTOR(4 downto 0);
            dob        : out STD_LOGIC_VECTOR(7 downto 0);
            tx         : out STD_LOGIC;
            send_ok    : out STD_LOGIC;
            send_error : out STD_LOGIC
        );
    end component;
    
    -- Componente UART para generar estímulos
    component uart
        Generic (
            clk_freq   : integer := 100000000;
            baud_rate  : integer := 9600;
            os_rate    : integer := 16;
            d_width    : integer := 8;
            parity     : integer := 0;
            parity_eo  : std_logic := '0'
        );
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
    
    -- Señales
    signal clk        : STD_LOGIC := '0';
    signal reset      : STD_LOGIC := '1';
    signal rx_to_dut  : STD_LOGIC := '1';
    signal tx_from_dut: STD_LOGIC;
    signal enb        : STD_LOGIC := '0';
    signal addrb      : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal dob        : STD_LOGIC_VECTOR(7 downto 0);
    signal send_ok    : STD_LOGIC;
    signal send_error : STD_LOGIC;
    
    -- Señales para la UART del testbench
    signal tb_tx_ena  : STD_LOGIC := '0';
    signal tb_tx_data : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal tb_tx_busy : STD_LOGIC;
    signal tb_rx_data : STD_LOGIC_VECTOR(7 downto 0);
    
    -- Procedimiento para enviar un carácter por UART
    procedure UART_WRITE_BYTE (
        data_in       : in  std_logic_vector(7 downto 0);
        signal tx_ena : out std_logic;
        signal tx_data: out std_logic_vector(7 downto 0);
        signal tx_busy: in  std_logic
    ) is
    begin
        wait until rising_edge(clk);
        tx_data <= data_in;
        tx_ena  <= '1';
        wait until rising_edge(clk);
        tx_ena  <= '0';
        wait until tx_busy = '0';
        wait for BIT_PERIOD;
    end procedure;
    
begin
    -- Generación de reloj
    clk <= not clk after CLK_PERIOD/2;
    
    -- Instancia del diseño bajo prueba
    DUT: reception_uart_bt
    port map (
        clk        => clk,
        reset      => reset,
        rx         => rx_to_dut,
        enb        => enb,
        addrb      => addrb,
        dob        => dob,
        tx         => tx_from_dut,
        send_ok    => send_ok,
        send_error => send_error
    );
    
    -- Instancia de la UART para generar estímulos
    TB_UART: uart
    generic map (
        clk_freq  => 100000000,
        baud_rate => 9600,
        os_rate   => 16,
        d_width   => 8,
        parity    => 0,
        parity_eo => '0'
    )
    port map (
        clk      => clk,
        reset_n  => not reset,
        tx_ena   => tb_tx_ena,
        tx_data  => tb_tx_data,
        rx       => tx_from_dut,  -- Conectado a la salida del DUT
        rx_busy  => open,
        rx_error => open,
        tx_busy  => tb_tx_busy,
        tx       => rx_to_dut,    -- Conectado a la entrada del DUT
        rx_data  => tb_rx_data
    );
    
    -- Proceso de estimulación
    stimulus: process
    begin
        -- Inicialización
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;
        
        -- Caso 1: Mensaje corto (menos de 32 caracteres)
        report "Enviando mensaje corto 'Hola'";
        UART_WRITE_BYTE(x"48", tb_tx_ena, tb_tx_data, tb_tx_busy); -- 'H'
        UART_WRITE_BYTE(x"6F", tb_tx_ena, tb_tx_data, tb_tx_busy); -- 'o'
        UART_WRITE_BYTE(x"6C", tb_tx_ena, tb_tx_data, tb_tx_busy); -- 'l'
        UART_WRITE_BYTE(x"61", tb_tx_ena, tb_tx_data, tb_tx_busy); -- 'a'
        UART_WRITE_BYTE(x"0D", tb_tx_ena, tb_tx_data, tb_tx_busy); -- CR
        
        -- Esperar respuesta "ok"
        wait until send_ok = '1';
        report "Mensaje corto recibido correctamente";
        wait for 1 ms;
        
        -- Caso 2: Mensaje largo (más de 32 caracteres)
        report "Enviando mensaje largo (33 caracteres)";
        for i in 0 to 32 loop
            UART_WRITE_BYTE(x"41", tb_tx_ena, tb_tx_data, tb_tx_busy); -- 'A'
        end loop;
        UART_WRITE_BYTE(x"0A", tb_tx_ena, tb_tx_data, tb_tx_busy); -- LF
        
        -- Esperar respuesta "error"
        wait until send_error = '1';
        report "Mensaje largo detectado correctamente";
        wait for 1 ms;
        
        -- Caso 3: Verificar contenido de la RAM
        report "Verificando contenido de la RAM para mensaje corto";
        enb <= '1';
        for i in 0 to 3 loop
            addrb <= std_logic_vector(to_unsigned(i, 5));
            wait for 100 ns;
            report "Dirección " & integer'image(i) & ": " & to_hstring(dob);
        end loop;
        enb <= '0';
        
        report "Test completado";
        wait;
    end process;
    
END;