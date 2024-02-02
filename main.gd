extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_board_player_moved():
	
	if($Board.winner != ""):
		$MessageLabel.text = "Player "+$Board.winner+" WINS!!!"
		
	else:
		$MessageLabel.text = "MOVEEE!!! Player "+$Board.curr_player
