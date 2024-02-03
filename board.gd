extends Node2D

@export var pieceX_scene: PackedScene
@export var pieceO_scene: PackedScene
@export var curr_player = "X"
@export var winner = ""
signal player_moved

var spots = {
	0: {
		0: Vector2(250,100),
		1: Vector2(450,100),
		2: Vector2(650,100)
	},
	1: {
		0: Vector2(250,250),
		1: Vector2(450,250),
		2: Vector2(650,250)
	},
	2: {
		0: Vector2(250,400),
		1: Vector2(450,400),
		2: Vector2(650,400)
	}
}

var board_array = [
	[null,null,null], # first row
	[null,null,null], #second row
	[null,null,null], # 3rd row
]


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	if Input.is_action_just_pressed("mark_spot"):
		if(winner):
			return
		if curr_player != "X":
			return
		print("marked")
		
		$PlacementSound.play()
	
		# Set the piece's position to where you clicked
		#piece.position = get_viewport().get_mouse_position()
		
		var click_position = get_viewport().get_mouse_position()
		var x_pos = null
		var y_pos = null
		
		if (click_position.x >= 650):
			x_pos = 2
		elif click_position.x >= 450:
			x_pos = 1
		else:
			x_pos = 0
			
		if (click_position.y >= 400):
			y_pos = 2
		elif click_position.y >= 250:
			y_pos = 1
		else:
			y_pos = 0
			
		var piece = null
		if(board_array[y_pos][x_pos] != null):
			return
			
		# Assign the move to the position on the board	
		board_array[y_pos][x_pos] = curr_player
		
		if curr_player == "X":
			piece = pieceX_scene.instantiate()
			curr_player = "O"	
		else:
			piece = pieceO_scene.instantiate()
			curr_player = "X"	
		piece.position = spots[y_pos][x_pos] + Vector2(40,15)
		
		print(board_array)
		verify_win_cond()
		player_moved.emit()
		add_child(piece)
		
		if (winner == ""):
			computer_move()
		
	

func verify_win_cond():
	
	for num in 3:
		if(board_array[num][0] == board_array[num][1] && board_array[num][1] == board_array[num][2] && board_array[num][2] != null):
			winner=board_array[num][0] 
		elif(board_array[0][num] == board_array[1][num] && board_array[1][num] == board_array[2][num] && board_array[2][num] != null):
			winner=board_array[0][num]
			
	if(board_array[0][0] == board_array[1][1] && board_array[1][1] == board_array[2][2] && board_array[2][2] != null):
		winner=board_array[0][0]
	elif(board_array[0][2] == board_array[1][1] && board_array[1][1] == board_array[2][0] && board_array[2][0] != null):
		winner=board_array[0][2]
		
	# if there is a winner, even if no space available, don't do the tie check
	if winner == "X":
		$BattleMusic.stop()
		$WinSound.play()
		return
	if winner == "O":
		$BattleMusic.stop()
		$LoseSound.play()
		return
	
	var space_available = false
	for x in 3:
		for y in 3:
			if (board_array[y][x] == null):
				space_available = true
	
	if space_available == false:
		$BattleMusic.stop()
		$LoseSound.play()
		winner="tie"
	
func computer_move():
	# make a random move on one of the available spaces
	await get_tree().create_timer(0.5).timeout
	
	var open_spots = []
	
	for x in 3:
		for y in 3:
			if (board_array[y][x] == null):
				open_spots.append({"x":x,"y":y})
				
	
	var rand_spot = open_spots[randi_range(0, open_spots.size()-1)]
	
	print(open_spots)
	print(rand_spot)
	
	
	# Assign the move to the position on the board	
	board_array[rand_spot.y][rand_spot.x] = curr_player
	
	var piece = null
	
	if curr_player == "X":
		piece = pieceX_scene.instantiate()
		curr_player = "O"	
	else:
		piece = pieceO_scene.instantiate()
		curr_player = "X"	
		
	piece.position = spots[rand_spot.y][rand_spot.x] + Vector2(40,15)
	add_child(piece)
	print(board_array)
	verify_win_cond()
	player_moved.emit()
	
	$PlacementSound.play()
	
	
