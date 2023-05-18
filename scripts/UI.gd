extends Control


func _ready():
	pass
	
func set_hp_bar(max_hp, current_hp):
	var hp_bar = $CanvasLayer/HP_bar
	var hp_val = $CanvasLayer/HP_val
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	hp_val.text = str(current_hp) + '/' + str(max_hp)
	
func set_mana_bar(max_mana, current_mana):
	var mana_bar = $CanvasLayer/mana_bar
	var mana_val = $CanvasLayer/mana_val
	mana_bar.max_value = max_mana
	mana_bar.value = current_mana
	mana_val.text = str(current_mana) + '/' + str(max_mana)
	
func set_xp_bar(max_xp, current_xp):
	var xp_bar = $CanvasLayer/xp_bar
	xp_bar.max_value = max_xp
	xp_bar.value = current_xp
