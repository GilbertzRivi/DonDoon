extends Control

func _ready():
	pass
	
func set_hp_bar(max_hp, current_hp):
	var hp_bar = $CanvasLayer/HP_bar
	var hp_val = $CanvasLayer/HP_val
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	hp_val.text = str(current_hp) + '/' + str(max_hp)
