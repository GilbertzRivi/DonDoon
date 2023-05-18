extends TileMap

var width: int = 17
var start_height: int = 12
var last_gen_y = 4
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
var floor_atlas = 0
var wall_atlas = 0
var wall_cells = {"r": Vector2i(12, 9), "l": Vector2i(13, 9)}
var floor_cells = [Vector2i(18, 4), Vector2i(18, 5), Vector2i(19, 6), Vector2i(20, 7)]

func _ready():
	generate_new_row()
	generate_new_row()
	generate_new_row()
	position = Vector2i(0, 0)
	$"../Player".position = Vector2i(int(width/2)*tile_size, 2*tile_size)
	randomize()

func generate_new_row():
	last_gen_y += 1
	for y in range(4):
		for x in range(width+2):
			x -= 1
			set_cell(0, Vector2(x, last_gen_y+y), floor_atlas, random_choice(floor_cells))
			if x == -1:
				set_cell(1, Vector2(x, last_gen_y+y), wall_atlas, wall_cells["l"])
				set_cell(1, Vector2(x-1, last_gen_y+y), wall_atlas, wall_cells["r"])
			elif x == width:
				set_cell(1, Vector2(x, last_gen_y+y), wall_atlas, wall_cells["r"])
				set_cell(1, Vector2(x+1, last_gen_y+y), wall_atlas, wall_cells["l"])
	if randi()%2:
		var structure = random_choice(structures)
		structure = load(structure).instantiate()
		while offset == 0:
			offset = int(randf_range(0, width-structure.get_used_rect().end.x))	
		structure.position = Vector2i(offset*tile_size, last_gen_y*tile_size)
		structure.name = "Structure"
		structure.add_to_group("last_gen_structures")
		$"..".add_child(structure)

	if randi()%5:
		var enemy = preload("res://scenes/enemy.tscn").instantiate()
		var generated_position
		var enemy_pos
		var tile_pos
		var intersecting = true
		while intersecting:
			generated_position = Vector2i(randi()%(width-2)+1, last_gen_y)
			intersecting = false
			for structure in get_tree().get_nodes_in_group("last_gen_structures"):
				for tile in structure.get_used_cells(0):
					tile_pos = structure.position / tile_size + Vector2(tile.x, tile.y)
					if generated_position == Vector2i(tile_pos.x, tile_pos.y):
						intersecting = true
		for structure in get_tree().get_nodes_in_group("last_gen_structures"):
			structure.remove_from_group('last_gen_structures')
		add_child(enemy)
		enemy.position = map_to_local(generated_position)
		enemy.set_hp(15)
		enemy.attack_range = 1.5
		enemy.damage = 5
		enemy.attack_speed = 1
		enemy.move_speed = 1
		enemy.dropped_xp = 10
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
	player.can_move = true

func mtw_cords(pos: Vector2i) -> Vector2i:
	return Vector2i(pos.x * tile_size + tile_size/2, pos.y * tile_size + tile_size/2)
	
func distance(pos1: Vector2i, pos2: Vector2i) -> float:
	return sqrt(pow(pos1.x - pos2.x, 2) + pow(pos1.y - pos2.y, 2))
	
func random_choice(array: Array):
	return array[randi() % array.size()]

	
	
	
	
