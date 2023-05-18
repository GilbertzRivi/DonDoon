extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
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
var move_speed = 0
var attack_speed = 0
var dropped_xp = 0

func _ready():
	_animated_sprite.play("idle")

func move_to_player(player):
	var Map = get_tree().current_scene.get_node("Map")
	var space_state = get_world_2d().direct_space_state
	var ray_parameters = PhysicsRayQueryParameters2D.create(position, player.position, 2, [self])
	var result = space_state.intersect_ray(ray_parameters)
	
	if len(result) == 0:
		last_seen_player = player.position
	if last_seen_player == Vector2(0,0):
		return false
	var enemy_pos = Map.local_to_map(position)
	var player_pos = Map.local_to_map(last_seen_player)
	var direction_to_player = Vector2(player_pos.x - enemy_pos.x, player_pos.y - enemy_pos.y)
	var moved = false
	for i in range(move_speed):
		var dir = choose_direction(direction_to_player)
		ray_parameters = PhysicsRayQueryParameters2D.create(position, position + (directions[dir] * tile_size), 2, [self])
		result = space_state.intersect_ray(ray_parameters)
		if len(result) == 0:
			position += directions[dir] * tile_size
			moved = true
	return moved

func set_hp(setted_hp):
	hp = setted_hp
	$HP_bar.max_value = hp
	$HP_bar.value = hp
	
func hit(player, setted_damage):
	hp -= setted_damage
	if hp <= 0:
		player.add_xp(dropped_xp)
		remove_from_group("enemies")
		queue_free()
	$HP_bar.value = hp
	
func attack(player) -> bool:
	var attacked = false
	for i in range(attack_speed):
		var distance = sqrt(pow(position.x - player.position.x,2) + pow(position.y - player.position.y,2))
		if distance <= attack_range * tile_size:
			player.hit(damage)
			attacked = true
	return attacked

func choose_direction(direction_to_player: Vector2):
	var dir = null
	var result
	var space_state = get_world_2d().direct_space_state
	if abs(direction_to_player.x) > abs(direction_to_player.y):
		if direction_to_player.x > 0:
			dir = "right"
			result = space_state.intersect_ray(
				PhysicsRayQueryParameters2D.create(position, position + (directions[dir] * tile_size), 2, [self])
			)
			if len(result) != 0:
				if direction_to_player.y > 0: dir = "down"
				else: dir = "up"
		else: 
			dir = "left"
			result = space_state.intersect_ray(
				PhysicsRayQueryParameters2D.create(position, position + (directions[dir] * tile_size), 2, [self])
			)
			if len(result) != 0:
				if direction_to_player.y > 0: dir = "down"
				else: dir = "up"
	else:
		if direction_to_player.y > 0: 
			dir = "down"
			result = space_state.intersect_ray(
				PhysicsRayQueryParameters2D.create(position, position + (directions[dir] * tile_size), 2, [self])
			)
			if len(result) != 0:
				if direction_to_player.x > 0: dir = "right"
				else: dir = "left"
		else:
			dir = "up"
			result = space_state.intersect_ray(
				PhysicsRayQueryParameters2D.create(position, position + (directions[dir] * tile_size), 2, [self])
			)
			if len(result) != 0:
				if direction_to_player.x > 0: dir = "right"
				else: dir = "left"
	
	return dir
