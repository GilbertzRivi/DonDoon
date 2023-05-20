extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
var tile_size = 32
var directions = {"right": Vector2.RIGHT,
			"left": Vector2.LEFT,
			"up": Vector2.UP,
			"down": Vector2.DOWN}
var hp: int
var damage: int
var attack_range: float
var ray_move: RayCast2D
var last_seen_player: Vector2 = Vector2(0, 0)
var speed: int
var dropped_xp: int
var armour: int

func _ready():
	_animated_sprite.play("idle")
	$Button.pressed.connect(self.being_attacked)
	
func distance(pos1: Vector2i, pos2: Vector2i) -> float:
	return sqrt(pow(pos1.x - pos2.x, 2) + pow(pos1.y - pos2.y, 2))
	
func action(player):
	if distance(self.global_position, player.position)/32 <= 20:
		for i in range(speed):
			var attacked = self.attack(player)
			var moved = false
			if not attacked:
				moved = self.move_to_player(player)
			if moved or attacked:
				await get_tree().create_timer(speed/60).timeout
	
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
	
func hit(player, given_damage, armour_penetration):
	hp -= given_damage - given_damage * (armour - armour_penetration)
	last_seen_player = player.position
	if hp <= 0:
		player.add_xp(dropped_xp)
		remove_from_group("enemies")
		drop_loot()
		queue_free()
	$HP_bar.value = hp
	
func attack(player) -> bool:
	var attacked = false
	var my_distance = sqrt(pow(position.x - player.position.x,2) + pow(position.y - player.position.y,2))
	if my_distance <= attack_range * tile_size:
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

func being_attacked():
	$"../../Player".attack(self)

func drop_loot():
	var loot = get_tree().current_scene.get_node("Map").loot_table
	var choosen_loot = loot.keys()[randi() % loot.keys().size()]
	if randi()%100 <= 35:
		var coin = load(loot['coins']['src']).instantiate()
		coin.amount = randi_range(loot['coins']['min_amount'], loot['coins']['max_amount'])
		coin.script_name = "coins"
		coin.position = self.position
		coin.add_to_group("loot")
		get_parent().add_child(coin)
	else:
		loot = loot[choosen_loot]
		#if randi()%100+1 <= loot['chance']:
		if true:
			var rarity = choose_rarity()
			loot = load(loot['src']).instantiate()
			loot.script_name = choosen_loot
			loot.position = self.position
			loot.rarity = rarity
			loot.add_to_group("loot")
			get_parent().add_child(loot)

func choose_rarity():
	var r = randi()%100
	if r <= 50:
		return "common"
	elif r <= 70:
		return "better"
	elif r <= 85:
		return "rare"
	elif r <= 95:
		return "magic"
	elif r <= 99:
		return "epic"
	else:
		return "best"
