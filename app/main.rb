module Main
  def boot args
    args.state = {}
  end

  def tick args
    args.state.current_scene ||= :menu_scene

    current_scene = args.state.current_scene

    case current_scene
    when :menu_scene
      tick_menu_scene args
    when :game_scene
      tick_game_scene args
    when :game_over_scene
      tick_game_over_scene args
    when :pause_scene
      tick_pause_scene args
    end

    if args.state.current_scene != current_scene
      raise "Scene was changed incorrectly. Set args.state.next_scene to change scenes."
    end

    if args.state.next_scene
      args.state.current_scene = args.state.next_scene
      args.state.next_scene = nil
    end
  end

  def tick_menu_scene args
    args.outputs.background_color = [0, 117, 10]
    args.outputs.sprites << {x: 350, y: 400, w: 600, h: 320, path: 'sprites/title.png'}
    args.outputs.labels << [x: 530, y: 400, text: "How to play:", size_enum: 10, a: 255, r: 0, g: 0, b: 0]
    args.outputs.labels << [x: 50, y: 350, text: "Pick two dominoes that add up to double the target domino in rank, So for example:", size_enum: 5, a: 255, r: 0, g: 0, b: 0]

    args.outputs.sprites << {x: 200, y: 140, w: 96, h: 160, path: 'sprites/target-box.png'}
    args.outputs.labels << [x: 320, y: 280, text: "=", size_enum: 50, a: 255, r: 0, g: 0, b: 0]
    args.outputs.labels << [x: 390, y: 280, text: "6", size_enum: 50, a: 255, r: 0, g: 0, b: 0]
    args.outputs.sprites << {x: 605, y: 140, w: 96, h: 160, path: 'sprites/selection-box.png'}
    args.outputs.labels << [x: 725, y: 280, text: "+", size_enum: 50, a: 255, r: 0, g: 0, b: 0]
    args.outputs.sprites << {x: 805, y: 140, w: 96, h: 160, path: 'sprites/selection-box.png'}
    args.outputs.labels << [x: 930, y: 280, text: "=", size_enum: 50, a: 255, r: 0, g: 0, b: 0]
    args.outputs.labels << [x: 1000, y: 280, text: "12", size_enum: 50, a: 255, r: 0, g: 0, b: 0]
    args.outputs.sprites << {x: 215, y: 155, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 0, tile_y: 396, tile_w: 32, tile_h: 64, rank: 12, id: 100}
    args.outputs.sprites << {x: 820, y: 155, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 0, tile_y: 132, tile_w: 32, tile_h: 64, rank: 12, id: 100}
    args.outputs.sprites << {x: 620, y: 155, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 136, tile_y: 396, tile_w: 32, tile_h: 64, rank: 12, id: 100}

    if DR.platform? :touch
      args.outputs.labels << [x: 430, y: 100, text: "Then tap the \"Double!\" button.", size_enum: 5, a: 255, r: 0, g: 0, b: 0]
      args.outputs.labels << [x: 500, y: 50, text: "Ready? Tap to start.", size_enum: 5, a: 255, r: 0, g: 0, b: 0]

      if !args.inputs.finger_one.nil?
        args.state.next_scene = :game_scene
      end
    else
      args.outputs.labels << [x: 400, y: 100, text: "Then click the \"Double!\" button.", size_enum: 5, a: 255, r: 0, g: 0, b: 0]
      if args.inputs.controller_one.connected
        args.outputs.labels << [x: 450, y: 50, text: "Ready? Hit the A button to start.", size_enum: 5, a: 255, r: 0, g: 0, b: 0]
      else
        args.outputs.labels << [x: 450, y: 50, text: "Ready? Hit enter to start.", size_enum: 5, a: 255, r: 0, g: 0, b: 0]
      end

      if args.inputs.keyboard.enter or args.inputs.controller_one.key_down.a
        args.state.next_scene = :game_scene
      end
    end
  end

  def tick_game_scene args
    args.state.domino_hand ||=[]
    args.state.target_domino ||= {x: 115, y: 465, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 0, tile_y: 0, tile_w: 32, tile_h: 64, rank: 0, id: 0}
    args.state.target_domino_id ||= 0
    args.state.new_target_domino ||= false
    args.state.domino_picked_one ||= {x: 515, y: 465, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 34, tile_y: 0, tile_w: 32, tile_h: 64, rank: 0, id: 100}
    args.state.domino_picked_one_old ||= {x: 0, y: 0}
    args.state.domino_picked_two ||= {x: 675, y: 465, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 34, tile_y: 0, tile_w: 32, tile_h: 64, rank: 0, id: 100}
    args.state.domino_picked_two_old ||= {x: 0, y: 0, tile_x: 0, tile_y: 0, rank: 0, id: 0}
    args.state.domino_picked_total ||= 0
    args.state.selection_box_one ||= {x: 500, y: 450, w: 96, h: 160, path: 'sprites/selection-box.png'}
    args.state.selection_box_two ||= {x: 660, y: 450, w: 96, h: 160, path: 'sprites/selection-box.png'}
    args.state.target_box ||= {x: 100, y: 450, w: 96, h: 160, path: 'sprites/target-box.png'}
    args.state.double_button ||= {x: 1000, y: 500, w: 128, h: 64, path: 'sprites/double-button-grey.png'}
    args.state.touch_collision ||= {x: 0, y: 0, w: 1, h: 1}
    args.state.cursor ||= {x: 600, y: 350, w: 32, h: 32, path: 'sprites/cursor.png'}
    args.state.cursor_collision ||= {x: 600, y: 350, w: 1, h: 1}
    args.state.score ||= 0
    args.state.time_seconds ||= 20
    args.state.time_frame ||= 0
    args.state.debug_enabled ||= false

    if args.state.time_seconds > 0
      args.state.time_frame += 1
    end

    if args.state.time_seconds == 0
      args.state.next_scene = :game_over_scene
    end

    if args.state.time_frame >= 59
      args.state.time_frame = 0
      args.state.time_seconds -= 1
    end

    if args.state.domino_hand.empty?
      args.state.domino_hand += fill_domino_hand
    end

    if args.state.target_domino_id == 0
      args.state.new_target_domino = true
    end

    if args.state.new_target_domino == true
      args.state.target_domino_id = Numeric.rand(1..26)
      args.state.domino_hand = args.state.domino_hand.reject do |domino|
        if domino[:id] == args.state.target_domino_id
          args.state.target_domino[:tile_x] = domino[:tile_x]
          args.state.target_domino[:tile_y] = domino[:tile_y]
          args.state.target_domino[:rank] = domino[:rank]
          args.state.target_domino[:id] = domino[:id]
          true
        end
      end
      args.state.new_target_domino = false
    end

    # Beginning of input code

    if args.inputs.keyboard.key_down.o and args.state.debug_enabled == false
      args.state.debug_enabled = true
    elsif args.inputs.keyboard.key_down.o and args.state.debug_enabled == true
      args.state.debug_enabled = false
    end

    if args.inputs.keyboard.key_down.p or args.inputs.controller_one.key_down.start
      args.state.next_scene = :pause_scene
    end

    if args.state.debug_enabled
      debug args
    end

    if args.inputs.controller_one.connected
      if args.inputs.controller_one.left
        args.state.cursor[:x] -= 8
        args.state.cursor_collision[:x] -= 8
      elsif args.inputs.controller_one.right
        args.state.cursor[:x] += 8
        args.state.cursor_collision[:x] += 8
      end
      if args.inputs.controller_one.up
        args.state.cursor[:y] += 8
        args.state.cursor_collision[:y] += 8
      elsif args.inputs.controller_one.down
        args.state.cursor[:y] -= 8
        args.state.cursor_collision[:y] -= 8
      end
    end

    if !args.inputs.touch
      args.state.touch_collision[:x] = args.inputs.finger_one.x
      args.state.touch_collision[:y] = args.inputs.finger_one.y
    end

    args.state.domino_hand = args.state.domino_hand.reject do |domino|
      if args.inputs.mouse.inside_rect? domino or args.state.cursor_collision.intersect_rect? domino
        if args.inputs.mouse.key_down.left or args.inputs.controller_one.key_down.a
          args.outputs.sounds << { path: "sounds/domino-select-edited-87997.wav", gain: 0.5 }
          if args.state.domino_picked_one[:id] == 100
            args.state.domino_picked_one[:tile_x] = domino[:tile_x]
            args.state.domino_picked_one[:tile_y] = domino[:tile_y]
            args.state.domino_picked_one[:rank] = domino[:rank]
            args.state.domino_picked_one[:id] = domino[:id]
            args.state.domino_picked_one_old[:x] = domino[:x]
            args.state.domino_picked_one_old[:y] = domino[:y]
            args.state.domino_picked_one_old[:tile_x] = domino[:tile_x]
            args.state.domino_picked_one_old[:tile_y] = domino[:tile_y]
            args.state.domino_picked_one_old[:rank] = domino[:rank]
            args.state.domino_picked_one_old[:id] = domino[:id]
            true
          elsif args.state.domino_picked_two[:id] == 100
            args.state.domino_picked_two[:tile_x] = domino[:tile_x]
            args.state.domino_picked_two[:tile_y] = domino[:tile_y]
            args.state.domino_picked_two[:rank] = domino[:rank]
            args.state.domino_picked_two[:id] = domino[:id]
            args.state.domino_picked_two_old[:x] = domino[:x]
            args.state.domino_picked_two_old[:y] = domino[:y]
            args.state.domino_picked_two_old[:tile_x] = domino[:tile_x]
            args.state.domino_picked_two_old[:tile_y] = domino[:tile_y]
            args.state.domino_picked_two_old[:rank] = domino[:rank]
            args.state.domino_picked_two_old[:id] = domino [:id]
            true
          end
        end
      end
    end

    args.state.domino_hand = args.state.domino_hand.reject do |domino|
      if domino.intersect_rect? args.state.touch_collision
        args.outputs.sounds << { path: "sounds/domino-select-edited-87997.wav", gain: 0.5 }
        if args.state.domino_picked_one[:id] == 100
          args.state.domino_picked_one[:tile_x] = domino[:tile_x]
          args.state.domino_picked_one[:tile_y] = domino[:tile_y]
          args.state.domino_picked_one[:rank] = domino[:rank]
          args.state.domino_picked_one[:id] = domino[:id]
          args.state.domino_picked_one_old[:x] = domino[:x]
          args.state.domino_picked_one_old[:y] = domino[:y]
          args.state.domino_picked_one_old[:tile_x] = domino[:tile_x]
          args.state.domino_picked_one_old[:tile_y] = domino[:tile_y]
          args.state.domino_picked_one_old[:rank] = domino[:rank]
          args.state.domino_picked_one_old[:id] = domino[:id]
          true
        elsif args.state.domino_picked_two[:id] == 100
          args.state.domino_picked_two[:tile_x] = domino[:tile_x]
          args.state.domino_picked_two[:tile_y] = domino[:tile_y]
          args.state.domino_picked_two[:rank] = domino[:rank]
          args.state.domino_picked_two[:id] = domino[:id]
          args.state.domino_picked_two_old[:x] = domino[:x]
          args.state.domino_picked_two_old[:y] = domino[:y]
          args.state.domino_picked_two_old[:tile_x] = domino[:tile_x]
          args.state.domino_picked_two_old[:tile_y] = domino[:tile_y]
          args.state.domino_picked_two_old[:rank] = domino[:rank]
          args.state.domino_picked_two_old[:id] = domino [:id]
          true
        end
      end
    end

    if args.inputs.mouse.inside_rect? args.state.domino_picked_one or args.state.cursor_collision.intersect_rect? args.state.domino_picked_one
      if args.inputs.mouse.key_down.left or args.inputs.controller_one.key_down.a
        args.outputs.sounds << { path: "sounds/domino-select-edited-87997.wav", gain: 0.5 }
        if args.state.domino_picked_one[:id] < 30
          args.state.domino_picked_one[:tile_x] = 34
          args.state.domino_picked_one[:tile_y] = 0
          args.state.domino_picked_one[:rank] = 0
          args.state.domino_picked_one[:id] = 100
          args.state.domino_hand += 1.times.map { |n| {
            x: args.state.domino_picked_one_old[:x],
            y: args.state.domino_picked_one_old[:y],
            w: 64,
            h: 128,
            path: 'sprites/domino-set.png',
            tile_x: args.state.domino_picked_one_old[:tile_x],
            tile_y: args.state.domino_picked_one_old[:tile_y],
            tile_w: 32,
            tile_h: 64,
            rank: args.state.domino_picked_one_old[:rank],
            id: args.state.domino_picked_one_old[:id]
          }}
          args.state.domino_picked_one_old[:x] = 0
          args.state.domino_picked_one_old[:y] = 0
        end
      end
    end

    if !args.inputs.touch
      if args.inputs.domino_picked_one.intersect_rect? args.state.touch_collision
        args.outputs.sounds << { path: "sounds/domino-select-edited-87997.wav", gain: 0.5 }
        if args.state.domino_picked_one[:id] < 30
          args.state.domino_picked_one[:tile_x] = 34
          args.state.domino_picked_one[:tile_y] = 0
          args.state.domino_picked_one[:rank] = 0
          args.state.domino_picked_one[:id] = 100
          args.state.domino_hand += 1.times.map { |n| {
            x: args.state.domino_picked_one_old[:x],
            y: args.state.domino_picked_one_old[:y],
            w: 64,
            h: 128,
            path: 'sprites/domino-set.png',
            tile_x: args.state.domino_picked_one_old[:tile_x],
            tile_y: args.state.domino_picked_one_old[:tile_y],
            tile_w: 32,
            tile_h: 64,
            rank: args.state.domino_picked_one_old[:rank],
            id: args.state.domino_picked_one_old[:id]
          }}
          args.state.domino_picked_one_old[:x] = 0
          args.state.domino_picked_one_old[:y] = 0
        end
      end
    end

    if args.inputs.mouse.inside_rect? args.state.domino_picked_two or args.state.cursor_collision.intersect_rect? args.state.domino_picked_two
      if args.inputs.mouse.key_down.left or args.inputs.controller_one.key_down.a
        args.outputs.sounds << { path: "sounds/domino-select-edited-87997.wav", gain: 0.5 }
        if args.state.domino_picked_two[:id] < 30
          args.state.domino_picked_two[:tile_x] = 34
          args.state.domino_picked_two[:tile_y] = 0
          args.state.domino_picked_two[:rank] = 0
          args.state.domino_picked_two[:id] = 100
          args.state.domino_hand += 1.times.map { |n| {
            x: args.state.domino_picked_two_old[:x],
            y: args.state.domino_picked_two_old[:y],
            w: 64,
            h: 128,
            path: 'sprites/domino-set.png',
            tile_x: args.state.domino_picked_two_old[:tile_x],
            tile_y: args.state.domino_picked_two_old[:tile_y],
            tile_w: 32,
            tile_h: 64,
            rank: args.state.domino_picked_two_old[:rank],
            id: args.state.domino_picked_two_old[:id]
          }}
          args.state.domino_picked_two_old[:x] = 0
          args.state.domino_picked_two_old[:y] = 0
        end
      end
    end

    if !args.inputs.touch
      if args.inputs.domino_picked_two.intersect_rect? args.state.touch_collision
        args.outputs.sounds << { path: "sounds/domino-select-edited-87997.wav", gain: 0.5 }
        if args.state.domino_picked_two[:id] < 30
          args.state.domino_picked_two[:tile_x] = 34
          args.state.domino_picked_two[:tile_y] = 0
          args.state.domino_picked_two[:rank] = 0
          args.state.domino_picked_two[:id] = 100
          args.state.domino_hand += 1.times.map { |n| {
            x: args.state.domino_picked_two_old[:x],
            y: args.state.domino_picked_two_old[:y],
            w: 64,
            h: 128,
            path: 'sprites/domino-set.png',
            tile_x: args.state.domino_picked_two_old[:tile_x],
            tile_y: args.state.domino_picked_two_old[:tile_y],
            tile_w: 32,
            tile_h: 64,
            rank: args.state.domino_picked_two_old[:rank],
            id: args.state.domino_picked_two_old[:id]
          }}
          args.state.domino_picked_two_old[:x] = 0
          args.state.domino_picked_two_old[:y] = 0
        end
      end
    end

    if args.inputs.mouse.inside_rect? args.state.double_button or args.state.cursor_collision.intersect_rect? args.state.double_button
      if args.inputs.mouse.key_down.left or args.inputs.controller_one.key_down.a
        args.outputs.sounds << { path: "sounds/zapsplat_multimedia_game_sound_menu_click_005_76691.mp3", gain: 0.5 }
        # increase score and reset dominoes.
        if args.state.target_domino[:rank] * 2 == args.state.domino_picked_total
          args.state.score += 1
          args.state.double_button[:path] = 'sprites/double-button-grey.png'
          args.state.domino_picked_one[:tile_x] = 34
          args.state.domino_picked_one[:tile_y] = 0
          args.state.domino_picked_one[:rank] = 0
          args.state.domino_picked_one[:id] = 100
          args.state.domino_picked_two[:tile_x] = 34
          args.state.domino_picked_two[:tile_y] = 0
          args.state.domino_picked_two[:rank] = 0
          args.state.domino_picked_two[:id] = 100
          args.state.new_target_domino = true
        end
      end
    end

    if !args.inputs.touch
      if args.inputs.double_button.intersect_rect? args.state.touch_collision
        args.outputs.sounds << { path: "sounds/zapsplat_multimedia_game_sound_menu_click_005_76691.mp3", gain: 0.5 }
        # increase score and reset dominoes.
        if args.state.target_domino[:rank] * 2 == args.state.domino_picked_total
          args.state.score += 1
          args.state.double_button[:path] = 'sprites/double-button-grey.png'
          args.state.domino_picked_one[:tile_x] = 34
          args.state.domino_picked_one[:tile_y] = 0
          args.state.domino_picked_one[:rank] = 0
          args.state.domino_picked_one[:id] = 100
          args.state.domino_picked_two[:tile_x] = 34
          args.state.domino_picked_two[:tile_y] = 0
          args.state.domino_picked_two[:rank] = 0
          args.state.domino_picked_two[:id] = 100
          args.state.new_target_domino = true
        end
      end
    end

     if args.inputs.touch
      args.state.touch_collision[:x] = 0
      args.state.touch_collision[:y] = 0
    end

    # End of input code

    if args.state.domino_picked_one[:id] < 100 and args.state.domino_picked_two[:id] < 100
      args.state.domino_picked_total = args.state.domino_picked_one[:rank] + args.state.domino_picked_two[:rank]
      args.outputs.labels << [x: 800, y: 550, text: "#{(args.state.domino_picked_total)}", size_enum: 20, a: 255, r: 0, g: 0, b: 0]
      args.state.double_button[:path] = 'sprites/double-button.png'
    end

    if args.state.domino_picked_one[:id] == 100 or args.state.domino_picked_two[:id] == 100
      args.state.double_button[:path] = 'sprites/double-button-grey.png'
    end

    args.outputs.background_color = [0, 117, 10]
    args.outputs.sprites << args.state.domino_hand
    args.outputs.sprites << args.state.target_domino
    args.outputs.sprites << args.state.domino_picked_one
    args.outputs.sprites << args.state.domino_picked_two
    args.outputs.sprites << args.state.target_box
    args.outputs.sprites << args.state.selection_box_one
    args.outputs.sprites << args.state.selection_box_two
    args.outputs.sprites << args.state.double_button
    args.outputs.labels << {x: 550, y: 700, text: "Time: #{(args.state.time_seconds)}", size_enum: 10, a: 255, r: 0, g: 0, b: 0}
    args.outputs.labels << {x: 900, y: 700, text: "Score: #{(args.state.score)}", size_enum: 10, a: 255, r: 0, g: 0, b: 0}

    if args.inputs.controller_one.connected == true
      args.outputs.sprites << args.state.cursor
    end
  end

  def tick_game_over_scene args
    args.outputs.background_color = [0, 117, 10]
    args.outputs.labels << [x: 550, y: 500, text: "Times up!", size_enum: 10, a: 255, r: 0, g: 0, b: 0]
    args.outputs.labels << [x: 470, y: 400, text: "Dominoes doubled: #{(args.state.score)}", size_enum: 10, a: 255, r: 0, g: 0, b: 0]
    if DR.platform? :touch
      args.outputs.labels << [x: 430, y: 300, text: "Tap to try again.", size_enum: 10, a: 255, r: 0, g: 0, b: 0]

      if !args.inputs.finger_one.nil?
        args.state.next_scene = :game_scene
        args.state.domino_hand.clear
        args.state.target_domino[:tile_x] = 0
        args.state.target_domino[:tile_y] = 0
        args.state.target_domino[:rank] = 0
        args.state.target_domino[:id] = 0
        args.state.target_domino_id = 0
        args.state.new_target_domino = false
        args.state.domino_picked_one[:tile_x] = 34
        args.state.domino_picked_one[:tile_y] = 0
        args.state.domino_picked_one[:rank] = 0
        args.state.domino_picked_one[:id] = 100
        args.state.domino_picked_two[:tile_x] = 34
        args.state.domino_picked_two[:tile_y] = 0
        args.state.domino_picked_two[:rank] = 0
        args.state.domino_picked_two[:id] = 100
        args.state.domino_picked_total = 0
        args.state.double_button[:path] = 'sprites/double-button-grey.png'
        args.state.score = 0
        args.state.time_seconds = 20
        args.state.time_frame = 0
      end
    else
      if args.inputs.controller_one.connected
        args.outputs.labels << [x: 430, y: 300, text: "Press the A button to try again.", size_enum: 10, a: 255, r: 0, g: 0, b: 0]
      else
        args.outputs.labels << [x: 430, y: 300, text: "Press enter to try again.", size_enum: 10, a: 255, r: 0, g: 0, b: 0]
      end

      if args.inputs.keyboard.enter or args.inputs.controller_one.key_down.a
        args.state.next_scene = :game_scene
        args.state.domino_hand.clear
        args.state.target_domino[:tile_x] = 0
        args.state.target_domino[:tile_y] = 0
        args.state.target_domino[:rank] = 0
        args.state.target_domino[:id] = 0
        args.state.target_domino_id = 0
        args.state.new_target_domino = false
        args.state.domino_picked_one[:tile_x] = 34
        args.state.domino_picked_one[:tile_y] = 0
        args.state.domino_picked_one[:rank] = 0
        args.state.domino_picked_one[:id] = 100
        args.state.domino_picked_two[:tile_x] = 34
        args.state.domino_picked_two[:tile_y] = 0
        args.state.domino_picked_two[:rank] = 0
        args.state.domino_picked_two[:id] = 100
        args.state.domino_picked_total = 0
        args.state.double_button[:path] = 'sprites/double-button-grey.png'
        args.state.cursor[:x] = 600
        args.state.cursor[:y] = 350
        args.state.cursor_collision[:x] = 600
        args.state.cursor_collision[:y] = 350
        args.state.score = 0
        args.state.time_seconds = 20
        args.state.time_frame = 0
      end
    end
  end

  def tick_pause_scene args
    args.outputs.background_color = [0, 117, 10]

    args.outputs.sprites << args.state.domino_hand
    args.outputs.sprites << args.state.target_domino
    args.outputs.sprites << args.state.domino_picked_one
    args.outputs.sprites << args.state.domino_picked_two
    args.outputs.sprites << args.state.target_box
    args.outputs.sprites << args.state.selection_box_one
    args.outputs.sprites << args.state.selection_box_two
    args.outputs.sprites << args.state.double_button

    args.outputs.labels << [x: 580, y: 460, text: "Paused.", size_enum: 10, a: 255, r: 255, g: 255, b: 255]

    if args.inputs.keyboard.key_down.p or args.inputs.controller_one.key_down.start
      args.state.next_scene = :game_scene
    end
  end

  def fill_domino_hand
    domino_hand = []
    domino_hand += 1.times.map { |n| {x: 32, y: 32, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 0, tile_y: 0, tile_w: 32, tile_h: 64, rank: 0, id: 0} }
    domino_hand += 1.times.map { |n| {x: 100, y: 32, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 0, tile_y: 66, tile_w: 32, tile_h: 64, rank: 1, id: 1} }
    domino_hand += 1.times.map { |n| {x: 168, y: 32, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 34, tile_y: 66, tile_w: 32, tile_h: 64, rank: 2, id: 2} }
    domino_hand += 1.times.map { |n| {x: 238, y: 32, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 0, tile_y: 132, tile_w: 32, tile_h: 64, rank: 2, id: 3} }
    domino_hand += 1.times.map { |n| {x: 306, y: 32, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 34, tile_y: 132, tile_w: 32, tile_h: 64, rank: 3, id: 4} }
    domino_hand += 1.times.map { |n| {x: 374, y: 32, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 68, tile_y: 132, tile_w: 32, tile_h: 64, rank: 4, id: 5} }
    domino_hand += 1.times.map { |n| {x: 442, y: 32, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 0, tile_y: 198, tile_w: 32, tile_h: 64, rank: 3, id: 6} }
    domino_hand += 1.times.map { |n| {x: 510, y: 32, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 34, tile_y: 198, tile_w: 32, tile_h: 64, rank: 4, id: 7} }
    domino_hand += 1.times.map { |n| {x: 578, y: 32, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 68, tile_y: 198, tile_w: 32, tile_h: 64, rank: 5, id: 8} }
    domino_hand += 1.times.map { |n| {x: 646, y: 32, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 102, tile_y: 198, tile_w: 32, tile_h: 64, rank: 6, id: 9} }
    domino_hand += 1.times.map { |n| {x: 714, y: 32, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 0, tile_y: 264, tile_w: 32, tile_h: 64, rank: 4, id: 10} }
    domino_hand += 1.times.map { |n| {x: 782, y: 32, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 34, tile_y: 264, tile_w: 32, tile_h: 64, rank: 5, id: 11} }
    domino_hand += 1.times.map { |n| {x: 850, y: 32, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 68, tile_y: 264, tile_w: 32, tile_h: 64, rank: 6, id: 12} }
    domino_hand += 1.times.map { |n| {x: 918, y: 32, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 102, tile_y: 264, tile_w: 32, tile_h: 64, rank: 7, id: 13} }
    domino_hand += 1.times.map { |n| {x: 986, y: 32, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 136, tile_y: 264, tile_w: 32, tile_h: 64, rank: 8, id: 14} }
    domino_hand += 1.times.map { |n| {x: 1054, y: 32, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 0, tile_y: 330, tile_w: 32, tile_h: 64, rank: 5, id: 15} }
    domino_hand += 1.times.map { |n| {x: 1122, y: 32, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 34, tile_y: 330, tile_w: 32, tile_h: 64, rank: 6, id: 16} }
    domino_hand += 1.times.map { |n| {x: 32, y: 164, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 68, tile_y: 330, tile_w: 32, tile_h: 64, rank: 7, id: 17} }
    domino_hand += 1.times.map { |n| {x: 100, y: 164, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 102, tile_y: 330, tile_w: 32, tile_h: 64, rank: 8, id: 18} }
    domino_hand += 1.times.map { |n| {x: 168, y: 164, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 136, tile_y: 330, tile_w: 32, tile_h: 64, rank: 9, id: 19} }
    domino_hand += 1.times.map { |n| {x: 238, y: 164, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 170, tile_y: 330, tile_w: 32, tile_h: 64, rank: 10, id: 20} }
    domino_hand += 1.times.map { |n| {x: 306, y: 164, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 0, tile_y: 396, tile_w: 32, tile_h: 64, rank: 6, id: 21} }
    domino_hand += 1.times.map { |n| {x: 374, y: 164, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 34, tile_y: 396, tile_w: 32, tile_h: 64, rank: 7, id: 22} }
    domino_hand += 1.times.map { |n| {x: 442, y: 164, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 68, tile_y: 396, tile_w: 32, tile_h: 64, rank: 8, id: 23} }
    domino_hand += 1.times.map { |n| {x: 510, y: 164, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 102, tile_y: 396, tile_w: 32, tile_h: 64, rank: 9, id: 24} }
    domino_hand += 1.times.map { |n| {x: 578, y: 164, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 136, tile_y: 396, tile_w: 32, tile_h: 64, rank: 10, id: 25} }
    domino_hand += 1.times.map { |n| {x: 646, y: 164, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 170, tile_y: 396, tile_w: 32, tile_h: 64, rank: 11, id: 26} }
    domino_hand += 1.times.map { |n| {x: 714, y: 164, w: 64, h: 128, path: 'sprites/domino-set.png', tile_x: 204, tile_y: 396, tile_w: 32, tile_h: 64, rank: 12, id: 27} }
    domino_hand
  end

  def debug args
    args.outputs.debug << args.gtk.framerate_diagnostics_primitives
    args.outputs.labels << [x: 10, y: 30, text: "new target domino: #{(args.state.new_target_domino)}", size_enum: 1, a: 255, r: 0, g: 0, b: 0]
    args.outputs.labels << [x: 10, y: 60, text: "target domino id: #{(args.state.target_domino_id)}", size_enum: 1, a: 255, r: 0, g: 0, b: 0]
    args.outputs.labels << [x: 10, y: 90, text: "target domino x/y: #{(args.state.target_domino[:x])}/#{(args.state.target_domino[:y])}", size_enum: 1, a: 255, r: 0, g: 0, b: 0]
    args.outputs.labels << [x: 10, y: 120, text: "domino picked total: #{(args.state.domino_picked_total)}", size_enum: 1, a: 255, r: 0, g: 0, b: 0]
  end
end
