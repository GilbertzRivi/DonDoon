extends KinematicBody2D

var tile_size = 32
var directions = {"right": Vector2.RIGHT,
			"left": Vector2.LEFT,
			"up": Vector2.UP,
			"down": Vector2.DOWN}
var hp: int = 0
var damage: int = 0
var attack_range: float = 0
var ray_move: RayCast2D
var last_seen_player: Vector2 = Vector2(0, 0)

func move_to_player(player):
	var Map = get_tree().current_scene.get_node("Map")
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, player.position, [self], 2)
	if !result:
		last_seen_player = player.position
	if last_seen_player == Vector2(0,0):
		return false
	var enemy_pos = Map.world_to_map(position)
	var player_pos = Map.world_to_map(last_seen_player)
	var direction_to_player = Vector2(player_pos.x - enemy_pos.x, player_pos.y - enemy_pos.y)
	var dir = choose_direction(direction_to_player)
	result = space_state.intersect_ray(position, position + (directions[dir] * tile_size), [self], 2)
	if !result:
		position += directions[dir] * tile_size
		return true
	return false

func set_hp(set_hp):
	hp = set_hp
	$HP_bar.max_value = hp
	$HP_bar.value = hp
	
func set_damage(set_damage):
	damage = set_damage
	
func set_range(set_range):
	attack_range = set_range
	
func hit(set_damage):
	hp -= set_damage
	if hp <= 0:
		remove_from_group("enemies")
		queue_free()
	$HP_bar.value = hp
	
func attack(player) -> bool:
	var distance = sqrt(pow(position.x - player.position.x,2) + pow(position.y - player.position.y,2))
	if distance <= attack_range * tile_size:
		player.hit(damage)
		return true
	else:
		return false

func choose_direction(direction_to_player: Vector2):
	var dir = null
	var result
	var space_state = get_world_2d().direct_space_state
	if abs(direction_to_player.x) > abs(direction_to_player.y):
		if direction_to_player.x > 0:
			dir = "right"
			result = space_state.intersect_ray(position, position + (directions[dir] * tile_size), [self], 2)
			if result:
				if direction_to_player.y > 0: dir = "down"
				else: dir = "up"
		else: 
			dir = "left"
			result = space_state.intersect_ray(position, position + (directions[dir] * tile_size), [self], 2)
			if result:
				if direction_to_player.y > 0: dir = "down"
				else: dir = "up"
	else:
		if direction_to_player.y > 0: 
			dir = "down"
			result = space_state.intersect_ray(position, position + (directions[dir] * tile_size), [self], 2)
			if result:
				if direction_to_player.x > 0: dir = "right"
				else: dir = "left"
		else:
			dir = "up"
			result = space_state.intersect_ray(position, position + (directions[dir] * tile_size), [self], 2)
			if result:
				if direction_to_player.x > 0: dir = "right"
				else: dir = "left"
	
	return dir
