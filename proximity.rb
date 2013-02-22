require './proximity/game'
require './proximity/player'

Shoes.app :title => 'Proximity' do
  $app_background = seashell
  $radius = 30
  $width = $radius * Math.sqrt(3) / 2
  $board_padding_x = 10
  $board_padding_y = 10
  $margin = 1
  $fill_color = rgb(0, 0.6, 0.9, 0.1)
  $fill_color_over = rgb(0, 0, 0, 0.2)
  $border_color = rgb(0, 0.6, 0.9)
  $random_colors = [green, red, blue, purple, brown, orange, tan, chartreuse, navy]

  @columns = 10
  @rows = 10
  @temporary_users = []
  @users_count = 2

  #Screens management begin
  def reset
    clear
    background $app_background
  end

  def show_home_screen
    reset
    title 'Proximity', :size => 20, :weight => 'bold', :align => 'center', :margin => 150
    draw_hexagon(280, 190, $fill_color, $border_color, 20)
    button 'Нова игра', :left => 225, :top => 270 do
      show_game_create_screen
    end
    button 'Правила', :left => 235, :top => 300 do
      show_rules_screen
    end
  end

  def show_rules_screen
    reset
    title 'Правила', :size => 20, :weight => 'bold', :align => 'center', :margin => 50
    flow do
      style(:margin_left => '10%', :left => '-5%', :top => 80)
      para "1. Дъската се състои от MxN на брой шестоъгълника.\n"
      para "2. Играчите се редуват, като на всеки ход се пада число между 2 и 20 (включително).\n"
      para "3. Играчът на ход избира \"свободен\" шестоъгълник, на който да постави падналото му се число. Ако в съседство с него има противникови шестоъгълници - всеки от тях, в които числото е по-малко от новопоставеното - се завзема от играча на ход. А ако в съседство с избраното поле има полета, собственост на същия играч - стойността им се увеличава с 1 (като максималната стойност отново е 20).\n"
      para "4. Играта приключва, когато всички полета се попълнят, като победител е играчът с най-много събрани точки (сумата от всички негови шестоъгълници).\n"
    end
    flow do
      button 'Начало', :left => 235 do
        show_home_screen
      end
    end
  end

  def show_game_create_screen
    reset
    stack :width => '100%' do
      title 'Нова игра', :size => 20, :weight => 'bold', :align => 'center'
    end
    stack :width => '100%' do
      flow :width => '100%', :margin_left => '40%' do
        para 'Колони: ', :margin => 10
        list_box :items => (5..20).to_a, :width => 60, :margin => 10, :choose => @columns do |list|
          @columns = list.text.to_i
        end
      end
    end
    stack :width => '100%' do
      flow :width => '100%', :margin_left => '40%' do
        para 'Редове: ', :margin => 10
        list_box :items => (5..20).to_a, :width => 60, :margin => 10, :choose => @rows do |list|
          @rows = list.text.to_i
        end
      end
    end
    stack :width => '40%' do
      flow :width => '100%' do
        para 'Брой играчи: ', :margin => 10
        list_box :items => ('2'..'4').to_a, :width => 50, :margin => 10, :choose => @users_count.to_s do |list|
          manage_players_inputs list.text.to_i
        end
      end
    end
    @users_panel = stack :width => '60%', :margin => 10
    stack :width => '100%' do
      button 'Старт', :left => 235, :top => 50 do
        initialize_game
      end
      button 'Отказ', :left => 235, :top => 90 do
        show_home_screen
      end
    end
    manage_players_inputs @users_count
  end

  def manage_players_inputs(count)
    @users_count = count
    shuffled_colors = $random_colors.shuffle
    @users_panel.clear
    count.times do |idx|
      if @temporary_users[idx] == nil
        @temporary_users[idx] = { name: '', color: shuffled_colors.pop }
      else
        color = @temporary_users[idx].fetch(:color)
        shuffled_colors.delete_if {|element| element == color }
      end
      @users_panel.append do
        flow do
          style(:margin => 5)
          text_field = edit_line :width => 200, :text => @temporary_users[idx].fetch(:name) do
            @temporary_users[idx][:name] = text_field.text
          end
          stroke black
          fill @temporary_users[idx].fetch(:color)
          color_picker = rect(
            :left => 210,
            :width => 21
          )
          color_picker.click do
            color = ask_color('Избери си цвят:')
            color_picker.style(:fill => color)
            @temporary_users[idx][:color] = color
          end
        end
      end
    end
  end
  #Screens management end

  def draw_hexagon(x, y, color, border_color, points)
    fill color
    stroke border_color
    hexagon = shape(x, y) do
      move_to $width, 0
      line_to 2 * $width, $radius * 0.5
      line_to 2 * $width, $radius * 1.5
      line_to $width, $radius * 2
      line_to 0, $radius * 1.5
      line_to 0, $radius * 0.5
      line_to $width, 0
    end
    caption points, :left => x, :top => y + $radius / 2, :width => 2 * $width, :height => 2 * $radius, :align => 'center'
    return hexagon
  end

  def initialize_game
    selected_users = @temporary_users[0, @users_count]
    unless selected_users.all? {|user| user.fetch(:name) != ''}
      alert 'Не се допуска играч без име!'
      return
    end
    @game = Game.new(@rows, @columns, selected_users.collect {|user| Player.new(user.fetch(:name), user.fetch(:color))})
    draw_board
  end

  def calc_x(row, col)
    $board_padding_x + col * (2 * $width + $margin) + (row % 2 == 0 ? 0 : $width + $margin / 2)
  end

  def calc_y(row)
    $board_padding_y + row * 1.5 * $radius + $margin * 2
  end

  def draw_board
    reset
    $board_padding_y = 110 + @game.players.length * 30

    @hexagons = Array.new(@game.rows){ Array.new(@game.columns) }
    @game.rows.times do |row|
      @game.columns.times do |col|
        x = calc_x(row, col)
        y = calc_y(row)

        hexagon = draw_hexagon x, y, $fill_color, $border_color, ''
        hexagon.click do
          changed = @game.claim_hexagon(row, col)
          #alert changed
          changed.each {|hex| recreate_at(hex.fetch(:row), hex.fetch(:col)) }
          @game.next_move
          refresh_info
        end
        hexagon.hover do
          hexagon.fill = $fill_color_over
        end
        hexagon.leave do
          hexagon.fill = $fill_color
        end

        @hexagons[row][col] = hexagon
      end
    end
    refresh_info
  end

  def refresh_info
    if @info != nil then @info.clear end
    x = calc_x(-2, 1)
    y = calc_y(-2)
    @info = stack do
      @game.players.each do |player|
        title "#{player.name} - #{player.points} т.", :size => 12, :margin_left => 60, :stroke => player.color
      end
      if @game.game_over?
        title "Победител: #{@game.get_winner.name}", :size => 20, :margin_left => 150, :stroke => @game.get_winner.color, :weight => 'bold'
        button 'Нова игра', :margin_left => 150 do
          initialize_game
        end
      end
    end

    unless @game.game_over?
      if @info_next != nil then @info_next.remove end
      @info_next = draw_hexagon(x, y, @game.next_player.color, $border_color, @game.next_num)
    end
  end

  def recreate_at(row, col)
    @hexagons[row][col].remove
    x = calc_x(row, col)
    y = calc_y(row)
    hex = @game.get_at(row, col)
    @hexagons[row][col] = draw_hexagon(x, y, @game.players[hex.owner_id].color, $border_color, hex.points)
  end

  show_home_screen
end