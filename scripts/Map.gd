extends TileMap

var width: int = 16
var start_height: int = 12
var wall_cells = [7]
var floor_cells = [2, 3, 4, 5]
var last_gen_y = 0
var offset = 0
var tile_size = 32
var enemies = []
var directions = {"right": Vector2.RIGHT,
			"left": Vector2.LEFT,
			"up": Vector2.UP,
			"down": Vector2.DOWN}
var structures = [
	"res://scenes/structures/str1.tscn",
	"res://scenes/structures/str2.tscn",
	"res://scenes/structures/str3.tscn",
	"res://scenes/structures/str4.tscn",
]

func _ready():
	generate_start()
	randomize()
	
func generate_start():
	for y in range(start_height):
		last_gen_y = y
		for x in range(width):
			if y == 0:
				set_block(Vector2(x, y), wall_cells, true)
			elif x == 0 or x == width-1:
				set_block(Vector2(x, y), wall_cells, true)
			else:
				set_block(Vector2(x, y), floor_cells, false)

func generate_new_row():
	last_gen_y += 1
	for y in range(4):
		for x in range(width):
			if x == 0 or x == width-1:
				set_block(Vector2(x, last_gen_y+y), wall_cells, true)
			else:
				set_block(Vector2(x, last_gen_y+y), floor_cells, false)
	#if randi()%2:
	if true:
		var structure = random_choice(structures)
		structure = load(structure).instantiate()
		while offset == 0:
			offset = int(randf_range(0, width-structure.get_used_rect().end.x))	
		structure.position = Vector2(offset*tile_size, last_gen_y*tile_size)
		add_child(structure)
		structure.add_to_group("currently_generated_structures")
			
				
	if randi()%5:
		var enemy = preload("res://scenes/enemy.tscn").instantiate()
		var position
		var enemy_pos
		var intersecting = true
		while intersecting:
			position = mtw_cords(Vector2(randi()%(width-2)+1, last_gen_y))
			intersecting = false
			for structure in get_tree().get_nodes_in_group("currently_generated_structures"):
				for cell in structure.get_used_cells():
					var block_pos = structure.map_to_local(cell) + structure.position + Vector2(tile_size/2, tile_size/2)
					if block_pos == position:
						intersecting = true
		for structure in get_tree().get_nodes_in_group("currently_generated_structures"):
			structure.remove_from_group("currently_generated_structures")
		$"..".add_child(enemy)
		enemy.position = position
		enemy.set_hp(15)
		enemy.set_range(1.5)
		enemy.set_damage(5)
		enemy.add_to_group("enemies")

	offset = 0
	last_gen_y += 3

func update_enemies():
	var player = $"../Player"
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if distance(enemy.position, player.position)/32 <= 20:
			var attacked = enemy.attack(player)
			var moved = false
			if not attacked:
				moved = enemy.move_to_player(player)
			if moved or attacked:
				await get_tree().create_timer(1/60).timeout
	player.can_move()

func set_block(pos: Vector2, type: Array, collision: bool) -> void:	
	set_cell(pos.x, pos.y, random_choice(type))
	if collision: 
		var collider = preload("res://scenes/collider.tscn").instantiate()
		collider.position = mtw_cords(pos)
		add_child(collider)
	
func mtw_cords(pos: Vector2) -> Vector2:
	return Vector2(pos.x * tile_size + tile_size/2, pos.y * tile_size + tile_size/2)
	
func distance(pos1: Vector2, pos2: Vector2) -> float:
	return sqrt(pow(pos1.x - pos2.x, 2) + pow(pos1.y - pos2.y, 2))
	
func random_choice(array: Array):
	return array[randi() % array.size()]

	
	
	
	
