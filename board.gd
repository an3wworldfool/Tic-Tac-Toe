extends Node2D

@export var pieceX_scene: PackedScene
@export var pieceO_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# if clicked on the board somewhere, figure out which one of the 9 spaces
	# and render the "X" piece at that space
	
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
	
	if Input.is_action_just_pressed("mark_spot"):
		print("marked")
	
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
			
		var piece = pieceX_scene.instantiate()
		piece.position = spots[y_pos][x_pos] + Vector2(40,15)
		
		#for i in spots:
		#	var piece2 = pieceO_scene.instantiate()
		#	piece2.position = spots[i] + Vector2(40,15)
		#	add_child(piece2)	

		
		add_child(piece)
