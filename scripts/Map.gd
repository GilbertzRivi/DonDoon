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
var collider_atlas = 1
var collider_cell = Vector2i(1, 1)
var wall_cells = {"r": Vector2i(12, 9), "l": Vector2i(13, 9)}
var floor_cells = [Vector2i(18, 4), Vector2i(18, 5), Vector2i(19, 6), Vector2i(20, 7)]

var loot_table = { 
#	"stick": {
#		"chance": 25,
#		"name": "stick",
#		"damage": 10,
#		"damage_range": 15,
#		"crit_chance": 2.5,
#		"crit_multiplier": 1.5,
#		"attack_speed": 1,
#		"range": 1.5,
#		"attack_angle": 90,
#		"armour_penetration": 0,
#		"src": ""
#		},
	"sword": {
		"chance": 10,
		"src": "res://scenes/loot/sword.tscn"
		},
	"coins": {
		"max_amount": 50,
		"min_amount": 5,
		"chance": 25,
		"src": "res://scenes/loot/coin.tscn"
	}
}

var rarity_mod = {
	"common": {
		"damage": 0,
		"crit_chance": 0,
		"crit_multiplier": 0,
		"armour_penetration": 0,
	},
	"better": {
		"damage": 5,
		"crit_chance": 2.5,
		"crit_multiplier": 0.25,
		"armour_penetration": 5,
	},
	"rare": {
		"damage": 10,
		"crit_chance": 5,
		"crit_multiplier": 0.5,
		"armour_penetration": 5,
	},
	"magic": {
		"damage": 10,
		"crit_chance": 5,
		"crit_multiplier": 1,
		"armour_penetration": 7.5,
	},
	"epic": {
		"damage": 15,
		"crit_chance": 10,
		"crit_multiplier": 1,
		"armour_penetration": 15,
	},
	"best": {
		"damage": 25,
		"crit_chance": 15,
		"crit_multiplier": 2,
		"armour_penetration": 25,
	},
}

func _ready():
	generate_new_row()
	generate_new_row()
	generate_new_row()
	position = Vector2i(0, 0)
	$"../Player".position = Vector2i(int(width/2)*tile_size, 2*tile_size)
	randomize()

func generate_new_row():
	last_gen_y += 1
	for y in range(5):
		for x in range(width+2):
			x -= 1
			set_cell(1, Vector2(x, last_gen_y+y), floor_atlas, random_choice(floor_cells))
			if x == -1:
				set_cell(2, Vector2(x, last_gen_y+y), wall_atlas, wall_cells["l"])
				set_cell(0, Vector2(x, last_gen_y+y), collider_atlas, collider_cell)
				set_cell(2, Vector2(x-1, last_gen_y+y), wall_atlas, wall_cells["r"])
			elif x == width:
				set_cell(2, Vector2(x, last_gen_y+y), wall_atlas, wall_cells["r"])
				set_cell(0, Vector2(x, last_gen_y+y), collider_atlas, collider_cell)
				set_cell(2, Vector2(x+1, last_gen_y+y), wall_atlas, wall_cells["l"])
	#if randi()%2:
	if true:
		var structure = random_choice(structures)
		structure = load(structure).instantiate()
		while offset == 0:
			offset = int(randf_range(0, width-structure.get_used_rect().end.x))	
		structure.position = Vector2i(offset*tile_size, last_gen_y*tile_size)
		structure.name = "Structure"
		structure.add_to_group("last_gen_structures")
		$"../Structures".add_child(structure)

	if randi()%5:
		var enemy = preload("res://scenes/enemy.tscn").instantiate()
		var generated_position
		$"../Enemies".add_child(enemy)
		generated_position = Vector2i(randi()%(width-2)+1, last_gen_y)
		enemy.position = map_to_local(generated_position)
		enemy.set_hp(15)
		enemy.attack_range = 1.5
		enemy.damage = 5
		enemy.speed = 1
		enemy.dropped_xp = 10
		enemy.armour = 0
		enemy.add_to_group("enemies")
		var intersecting = true
		while intersecting:
			intersecting = false
			for structure in get_tree().get_nodes_in_group("last_gen_structures"):
				for tile in structure.get_used_cells(0):
					if Vector2(tile.x*tile_size+tile_size/2, tile.y*tile_size+tile_size/2) + structure.position == enemy.position:
						intersecting = true
						generated_position = Vector2i(randi()%(width-2)+1, last_gen_y)
						enemy.position = map_to_local(generated_position)
		for structure in get_tree().get_nodes_in_group("last_gen_structures"):
			structure.remove_from_group('last_gen_structures')

	offset = 0
	last_gen_y += 4

func update_enemies():
	var player = $"../Player"
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.action(player)
	player.can_move = true

func mtw_cords(pos: Vector2i) -> Vector2i:
	return Vector2i(pos.x * tile_size + tile_size/2, pos.y * tile_size + tile_size/2)
	
func distance(pos1: Vector2i, pos2: Vector2i) -> float:
	return sqrt(pow(pos1.x - pos2.x, 2) + pow(pos1.y - pos2.y, 2))
	
func random_choice(array: Array):
	return array[randi() % array.size()]

	
	
	
	
