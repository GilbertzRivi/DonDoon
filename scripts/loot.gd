extends Node2D
class_name Loot

var amount: int
var script_name

func _ready():
	$AnimatedSprite2D.play("default")
