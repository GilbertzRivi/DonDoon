extends Control

func _ready():
	var exit = $"CanvasLayer/exit"
	exit.pressed.connect(close)
	exit.text = "exit"
	var coins = $"CanvasLayer/coins"
	coins.text = str($"../Player".coins) + " coins"
	var level = $"CanvasLayer/level"
	level.text = str($"../Player".level) + " levels"

func close():
	$"../Player".can_move = true
	queue_free()
