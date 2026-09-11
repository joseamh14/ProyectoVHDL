----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:14:07 05/27/2025 
-- Design Name: 
-- Module Name:    reception_uart_bt - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reception_uart_bt_lcd is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           rx : in  STD_LOGIC;
           e : out  STD_LOGIC; --Habilitacion lectura/escritura
           rs : out  STD_LOGIC; --Seleccion de registro
           rw : out  STD_LOGIC; --Señal de lectura escritura
           db : out  STD_LOGIC_VECTOR (7 downto 0);
           tx : out  STD_LOGIC;
           Send_ok : out  STD_LOGIC;
           Send_error : out  STD_LOGIC);
end reception_uart_bt_lcd;

architecture Behavioral of reception_uart_bt_lcd is

component write_lcd is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC; --Asincrono activo en alta
           init : in  STD_LOGIC; --Señal de inicio de escritura
           e : out  STD_LOGIC; --Habilitacion lectura/escritura
           rs : out  STD_LOGIC; --Seleccion de registro
           rw : out  STD_LOGIC; --Señal de lectura escritura
           db : out  STD_LOGIC_VECTOR (7 downto 0);
           addrb : out  STD_LOGIC_vector (4 downto 0);
           dob : in  STD_LOGIC_vector (7 downto 0);  -- Puerto de salida de 8 bits
           enb : out  STD_LOGIC);  -- Señal de habilitación del puerto B --Bus de datos
end component;

component ram32x8_dualp is
      port(
          
           addra : in  STD_LOGIC_vector (4 downto 0);  -- Como hay 32 direcciones, con 5 bits tenemos suficente ( 2^5 = 32 )
           dia : in  STD_LOGIC_vector (7 downto 0);  -- Puerto de entrada de 8 bits
           ena : in  STD_LOGIC;  -- Señal de habilitación del puerto A
           wea : in  STD_LOGIC;  -- Señal de escritura del puerto A                     
           addrb : in  STD_LOGIC_vector (4 downto 0);
           dob : out  STD_LOGIC_vector (7 downto 0);  -- Puerto de salida de 8 bits
           enb : in  STD_LOGIC;  -- Señal de habilitación del puerto B             
           clk : in  STD_LOGIC); 
end component;

component uart is
      port(
            clk      :  IN   STD_LOGIC;                             --system clock
            reset_n  :  IN   STD_LOGIC;                             --ascynchronous reset
            tx_ena   :  IN   STD_LOGIC;                             --initiate transmission
            tx_data  :  IN   STD_LOGIC_VECTOR(7 DOWNTO 0);  --data to transmit
            rx       :  IN   STD_LOGIC;                             --receive pin
            rx_busy  :  OUT  STD_LOGIC;                             --data reception in progress
            rx_error :  OUT  STD_LOGIC;                             --start, parity, or stop bit error detected
            rx_data  :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);  --data received
            tx_busy  :  OUT  STD_LOGIC;                             --transmission in progress
            tx       :  OUT  STD_LOGIC);                            --transmit pin
end component;


type tipo_estado is (espera,final_de_linea,recibiendo, rellenando_espacios, envio_respuesta);
signal estado: tipo_estado;
signal espaciando : STD_LOGIC;
signal Send_ok_interna : STD_LOGIC;
signal Send_error_interna : STD_LOGIC;
signal reset_n : STD_LOGIC;
signal addra : STD_LOGIC_vector (4 downto 0);
signal dia : STD_LOGIC_vector (7 downto 0);
signal ena : STD_LOGIC; 
signal wea : STD_LOGIC;
signal tx_ena : STD_LOGIC;
signal rx_ena : STD_LOGIC;
signal tx_busy : STD_LOGIC;
signal rx_busy : STD_LOGIC;
signal rx_busy_previo : STD_LOGIC;
signal rx_error : STD_LOGIC;
signal done : STD_LOGIC;
signal tx_busy_previo : std_logic;
signal tx_done : std_logic;
signal tx_data : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal rx_data : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal cont : unsigned (5 downto 0); -- Señal que cuenta el numero de caracteres para saber si el mensaje es mayor que 32
constant CR : STD_LOGIC_VECTOR(7 downto 0) := x"0D";
constant LF : STD_LOGIC_VECTOR(7 downto 0) := x"0A";
constant espacio : STD_LOGIC_VECTOR(7 downto 0) := x"20";
signal caracter_actual : unsigned(2 downto 0) := (others => '0'); -- Señal para saber el caracter que toca enviar de los mensajes de ok y error
signal addrb : STD_LOGIC_vector (4 downto 0);
signal dob : STD_LOGIC_vector (7 downto 0);  -- Puerto de salida de 8 bits
signal enb : STD_LOGIC;
signal init : std_logic;

begin

reset_n <= not reset;

inst1 : ram32x8_dualp PORT MAP
(
           addra => addra,
           dia => dia,
           ena => ena,
           wea => wea,                   
           addrb => addrb,
           dob => dob,
           enb => enb,           
           clk => clk

);

inst2 : uart PORT MAP
(
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

inst3 : write_lcd PORT MAP
(
           clk => clk,
           reset => reset,
           init => init,
           e => e,
           rs => rs,
           rw => rw,
           db => db,
           addrb => addrb,
           enb => enb,
           dob => dob
);



--Proceso para detectar el fin de recepcion y el fin de transmision

P1 : process(clk)
    begin
        if rising_edge(clk) then
            rx_busy_previo <= rx_busy;
            tx_busy_previo <= tx_busy;
        end if;
    end process;
    
    done <= '1' when (rx_busy_previo = '1' and rx_busy = '0') else '0';
    tx_done <= '1' when (tx_busy_previo = '1' and tx_busy = '0') else '0';




P2 : process (clk, reset)
     begin
     if reset = '1' then
        estado <= espera;
        Send_ok_interna <= '0';
        Send_error_interna <= '0';
        espaciando <= '0';
        cont <= (others => '0');
        addra <= (others => '0');
        ena <= '0';
        wea <= '0';
        dia <= (others => '0');
        tx_ena <= '0';
        tx_data <= (others => '0');
        init <= '0';
       
     elsif rising_edge(clk) then
         case estado is
              
              when espera => -- Estado a la espera constante de una recepcion
                     
                     init <= '0';
                     wea <= '0';
                     if done = '1' then 
                        if rx_data = CR or rx_data = LF then
                            estado <= final_de_linea;
                        else
                            ena <= '1';
                            wea <= '1';
                            addra <= std_logic_vector(cont(4 downto 0));
                            dia <= rx_data;
                            cont <= cont + 1;
                            estado <= recibiendo; 
                            
                        end if;
                     end if;
                     
              when recibiendo => -- Estado en el que se almacena el mensaje recibido hasta el fin de linea
                        
                     if done = '1' then 
                        if rx_data = CR or rx_data = LF then
                            estado <= final_de_linea;
                        elsif cont < 32 then
                              
                            ena <= '1';
                            wea <= '1';
                            addra <= std_logic_vector(cont(4 downto 0));
                            dia <= rx_data;
                            cont <= cont + 1;
                            --estado <= recibiendo;   
                        end if;
                     end if;
                     
              when final_de_linea => -- Estado donde se comprueba la validez del mensaje

                     if cont <32 then
                        Send_ok_interna <= '1';
                        estado <= rellenando_espacios;
                        espaciando <= '1';
                     else
                        Send_error_interna <= '1';
                        estado <= envio_respuesta;
                        init <= '1'; 
                     end if;
                     
              when rellenando_espacios => -- Estado donde se rellenan de espacios los huecos de un mensaje valido menor que 32 caracteres

                     if cont < 32 then
                        ena <= '1';
                        wea <= '1';
                        addra <= std_logic_vector(cont(4 downto 0));
                        dia <= espacio;
                        cont <= cont + 1;
                    else
                        espaciando <= '0';
                        estado <= envio_respuesta;
                        init <= '1'; 
                    end if;
                     
 

      when envio_respuesta => -- Estado que envia al movil la señal de ok o de error
        
        tx_ena <= '0'; -- Asegurar que tx_ena está inactivo
        
        if Send_ok_interna = '1' then
            case to_integer(caracter_actual) is
                when 0 => -- Primer carácter 'o'
                    tx_data <= x"6F";
                    tx_ena <= '1';
                    caracter_actual <= caracter_actual + 1;
                    
                when 1 => -- Segundo carácter 'k'
                    if tx_done = '1' then
                    
                    tx_data <= x"6B";
                    tx_ena <= '1';
                    caracter_actual <= caracter_actual + 1;
                    end if;
                when 2 => -- Tercer carácter CR
                    if tx_done = '1' then
                    tx_data <= CR;
                    tx_ena <= '1';
                    caracter_actual <= caracter_actual + 1;
                    end if;
                when 3 => -- Finalización
                    estado <= espera;
                    cont <= (others => '0');
                    caracter_actual <= (others => '0');
                   
                    
                when others =>
                    caracter_actual <= (others => '0');
            end case;
        elsif Send_error_interna = '1' then
        
            case to_integer(caracter_actual) is
                when 0 => -- Primer carácter 'E'
                    tx_data <= x"45";
                    tx_ena <= '1';
                    caracter_actual <= caracter_actual + 1;
                    
                when 1 => -- Segundo carácter 'r'
                    if tx_done = '1' then
                    tx_data <= x"72";
                    tx_ena <= '1';
                    caracter_actual <= caracter_actual + 1;
                    end if;
                when 2 => -- Tercer carácter 'r'
                    if tx_done = '1' then
                    tx_data <= x"72";
                    tx_ena <= '1';
                    caracter_actual <= caracter_actual + 1;
                    end if;
                when 3 => -- Cuarto carácter 'o'
                    if tx_done = '1' then
                    tx_data <= x"6F";
                    tx_ena <= '1';
                    caracter_actual <= caracter_actual + 1;
                    end if;
                when 4 => -- Quinto carácter 'r' 
                    if tx_done = '1' then
                    tx_data <= x"72";
                    tx_ena <= '1';
                    caracter_actual <= caracter_actual + 1;
                    end if;
                when 5 => -- Sexto carácter CR
                    if tx_done = '1' then
                    tx_data <= CR;
                    tx_ena <= '1';
                    caracter_actual <= caracter_actual + 1;
                    end if;
                when 6 => -- Finalización
                    estado <= espera;
                    cont <= (others => '0');
                    caracter_actual <= (others => '0');
                when others =>
                    caracter_actual <= (others => '0');
            end case;
     
                    end if;                                  
         end case;          
     end if;
     end process;

Send_ok <= Send_ok_interna;
Send_error <= Send_error_interna;

end Behavioral;

