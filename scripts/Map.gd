extends TileMap

var width: int = 16
var start_height: int = 6
var wall_cell = 0
var floor_cell = 1
var last_gen_y = 0
var offset = 0

var structures = [
	[[1, 0, 0, 0],
	 [1, 0, 1, 1],
	 [0, 0, 0, 1]],
	[[1, 0, 1, 1, 1],
	 [1, 0, 0, 0, 1],
	 [1, 1, 0, 1, 1]]
]

func _ready():
	generate_start()
	
func generate_start():
	for y in range(start_height):
		last_gen_y = y
		for x in range(width):
			if y == 0:
				set_cell(x, y, wall_cell)
			elif x == 0 or x == width-1:
				set_cell(x, y, wall_cell)
			else:
				set_cell(x, y, floor_cell)

func generate_new_row():
	last_gen_y += 1
	for y in range(3):
		for x in range(width):
			if x == 0 or x == width-1:
				set_cell(x, last_gen_y+y, wall_cell)
			else:
				set_cell(x, last_gen_y+y, floor_cell)
	if randi()%2:
		var choice = structures[randi() % structures.size()]
		for y in range(3):
			while offset == 0:
				offset = int(rand_range(0, width-len(choice[0])))
			print(offset)
			for x in len(choice[y]):
				set_cell(offset+x, last_gen_y+y, choice[y][x])
	offset = 0
	last_gen_y += 2
	
