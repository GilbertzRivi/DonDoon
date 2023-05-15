extends KinematicBody2D

var tile_size = 32
var inputs = {"right": Vector2.RIGHT,
			"left": Vector2.LEFT,
			"up": Vector2.UP,
			"down": Vector2.DOWN}

onready var ray = $RayCast2D

var max_hp: int = 1000
var hp: int = max_hp
var can_move: bool = true
var attack_range: float = 1.5
var damage: int = 10
var game_over: bool = false
var crit_chance: int = 5 # %
var crit_multiplier: float = 1.5
var damage_range: int = 15 # +- damage given in %

func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	get_tree().current_scene.get_node("UI")
	$"../UI".set_hp_bar(max_hp, hp)

func _unhandled_input(event):
	if can_move and !game_over:
		if event.is_action_pressed("action"):
			attack()
		for dir in inputs.keys():
			if event.is_action_pressed(dir):
				move(dir)
	else:
		return

func move(dir):
	var Map = get_tree().current_scene.get_node("Map")
	ray.cast_to = inputs[dir] * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		position += inputs[dir] * tile_size
		can_move = false
		if dir == "down" and int(position.y/tile_size) % 4 == 0:
			Map.generate_new_row()
		Map.update_enemies()
		
func can_move():
	can_move = true
	
func attack():
	var Map = get_tree().current_scene.get_node("Map")
	var mouse_pos = get_global_mouse_position()
	var square = {
		"x1": global_position.x + (attack_range * tile_size) - 2,
		"x2": global_position.x - (attack_range * tile_size) + 2,
		"y1": global_position.y + (attack_range * tile_size) - 2,
		"y2": global_position.y - (attack_range * tile_size) + 2,
		}
	var calculated_damage = calculate_damage(damage)
	if mouse_pos.x < square.x1 and mouse_pos.x > square.x2 and mouse_pos.y < square.y1 and mouse_pos.y > square.y2:
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if abs(enemy.position.x - mouse_pos.x) <= 16 and abs(enemy.position.y - mouse_pos.y) <= 16:
				enemy.hit(calculated_damage)
				break
	can_move = false
	Map.update_enemies()

func hit(damage):
	hp -= damage
	if hp <= 0:
		game_over = true
		var game_over = load("res://scenes/game_over.tscn").instance()
		$"../UI".add_child(game_over)
	$"../UI".set_hp_bar(max_hp, hp)

func calculate_damage(given_damage) -> int:
	var calculated_damage = 1
	var d_range: float = given_damage*damage_range/100
	calculated_damage = damage + (d_range - (randi()%int(d_range*2)+1))
	if randi()%100+1 < crit_chance:
		calculated_damage *= crit_multiplier
	return calculated_damage
