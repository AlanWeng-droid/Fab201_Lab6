library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
  port (
    clk_i     : in  std_logic;                       -- Clock 50MHz (Chân T9)
    btn_i     : in  std_logic_vector(2 downto 0);    -- 3 nút nhấn (KEY0, KEY1, KEY2)
    leds_o    : out std_logic_vector(3 downto 0);    -- Đèn LED hiển thị
    seg7_dio  : out std_logic;                       -- 7-segment SPI data
    seg7_rclk : out std_logic;                       -- 7-segment RCLK
    seg7_sclk : out std_logic                        -- 7-segment SCLK
  );
end entity;

architecture rtl of top is

  -- 1. Khai báo đầy đủ các tín hiệu nội bộ
  signal press_pulse : std_logic_vector(2 downto 0);     
  signal game_leds   : std_logic_vector(2 downto 0);     
  signal game_status : std_logic_vector(1 downto 0);     
  signal game_score  : std_logic_vector(3 downto 0);     

  -- 2. Khai báo Component bộ lọc phím
  component key_conditioner is
    port (
      clk_i   : in  std_logic;
      rst_i   : in  std_logic;
      key_i   : in  std_logic_vector(2 downto 0);
      event_o : out std_logic_vector(2 downto 0)
    );
  end component;

  -- 3. Khai báo Component Game Core chuẩn
  component lab06_game is
    generic (
      G_OFF_TICKS  : positive := 15000000;
      G_SHOW_TICKS : positive := 20000000
    );
    port (
      clk_i        : in  std_logic;
      rst_i        : in  std_logic;
      start_i      : in  std_logic;
      press_i      : in  std_logic_vector(2 downto 0);
      leds_o       : out std_logic_vector(2 downto 0);
      score_o      : out std_logic_vector(3 downto 0);
      status_o     : out std_logic_vector(1 downto 0);
      state_o      : out std_logic_vector(2 downto 0);
      show_idx_o   : out std_logic_vector(2 downto 0);
      input_idx_o  : out std_logic_vector(2 downto 0)
    );
  end component;

begin

  -- Kết nối bộ lọc phím
  u_conditioner : key_conditioner
    port map (
      clk_i   => clk_i,
      rst_i   => '0',
      key_i   => btn_i,
      event_o => press_pulse
    );

  -- Kết nối Game Core chính
  u_game_core : lab06_game
    port map (
      clk_i       => clk_i,
      rst_i       => '0',
      start_i     => '1',
      press_i     => press_pulse,
      leds_o      => game_leds,
      score_o     => game_score,
      status_o    => game_status,
      state_o     => open,
      show_idx_o  => open,
      input_idx_o => open
    );

  -- Gán tín hiệu ngõ ra LED
  leds_o(2 downto 0) <= game_leds;
  leds_o(3)          <= '1' when game_status = "10" else '0';

  -- Gán cứng chân màn hình 7 đoạn để tránh lỗi tổng hợp
  seg7_dio  <= '0';
  seg7_rclk <= '0';
  seg7_sclk <= '0';

end architecture;