extends CharacterBody2D

var tile_size = 32
var inputs = {"right": Vector2.RIGHT,
			"left": Vector2.LEFT,
			"up": Vector2.UP,
			"down": Vector2.DOWN}

@onready var ray = $RayCast2D
@onready var _animated_sprite = $AnimatedSprite2D

var max_hp: int = 100
var hp: int = max_hp
var max_mana: int = 100
var mana: int = max_mana
var can_move: bool = true
var game_over: bool = false
var xp: int = 0
var level: int = 1
var level_treshold: int = level * 125
var skill_points: int = 0
var move_speed: int = 1
var moved_tiles: int = 0
var attacked_times: int = 0
var actions_done: int = 0
var armour: int = 0
var looking_dir = "down"
var coins: int = 0
var fists = {
	"name": "fists",
	"damage": 50,
	"damage_range": 15,
	"crit_chance": 5,
	"crit_multiplier": 1.5,
	"attack_speed": 2,
	"range": 1,
	"attack_angle": 180,
	"armour_penetration": 0,
}
var eq = {}


func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	$"../UI".set_hp_bar(max_hp, hp)
	$"../UI".set_mana_bar(max_mana, mana)
	$"../UI".set_xp_bar(level_treshold, xp)
	_animated_sprite.play("idle")

func _unhandled_input(event):
	var Map = get_tree().current_scene.get_node("Map")
	if can_move and !game_over:
		if event.is_action_pressed("inventory"):
			inventory()
		if actions_done == 0:
			if (event.is_action_pressed("down") or event.is_action_pressed("up") or 
				event.is_action_pressed("left") or event.is_action_pressed("right")): 
				for dir in inputs.keys():
					if event.is_action_pressed(dir):
						move(dir)
				moved_tiles += 1
				if moved_tiles >= move_speed:
					actions_done += 1
					moved_tiles = 0
		else:
			can_move = false
			Map.update_enemies()
			actions_done = 0

func move(dir):
	var Map = get_tree().current_scene.get_node("Map")
	ray.target_position = inputs[dir] * tile_size
	ray.force_raycast_update()
	looking_dir = dir
	_animated_sprite.play(dir)
	if !ray.is_colliding():
		position += inputs[dir] * tile_size
		collect_loot()
		if dir == "down" and int(position.y/tile_size) % 5 == 0:
			Map.generate_new_row()
			
func attack(enemy):
	var Map = get_tree().current_scene.get_node("Map")
	if can_move and not game_over and not actions_done:
		var calculated_damage
		var weapon = fists
		if eq.has('weapon'):
			weapon = eq['weapon']
		calculated_damage = calculate_damage(weapon)
		var distance = sqrt(pow(enemy.position.x - self.position.x, 2) + pow(enemy.position.y - self.position.y, 2))
		if distance <= tile_size * weapon["range"]:
			enemy.hit(self, calculated_damage, weapon["armour_penetration"])
		attacked_times += 1
		if attacked_times >= weapon["attack_speed"]:
			actions_done += 1
	if actions_done:
		can_move = false
		Map.update_enemies()
		actions_done = 0
		

func hit(given_damage):
	hp -= given_damage
	if hp <= 0:
		game_over = true
		var game_over_screen = load("res://scenes/game_over.tscn").instantiate()
		$"../UI".add_child(game_over_screen)
	$"../UI".set_hp_bar(max_hp, hp)

func calculate_damage(weapon) -> int:
	var calculated_damage = 1
	var d_range: float = round(weapon['damage']*weapon['damage_range']/100)+1
	calculated_damage = weapon["damage"] + (d_range - (randi()%int(d_range*2)+1))
	if randi()%100+1 < weapon["crit_chance"]:
		calculated_damage *= weapon["crit_multiplier"]
	return calculated_damage

func add_xp(xp_amount):
	xp += xp_amount
	if xp >= level_treshold:
		level += 1
		skill_points += 1
		level_treshold = level * 125
		xp = xp % level_treshold
	$"../UI".set_xp_bar(level_treshold, xp)

func inventory():
	pass

func collect_loot():
	for loot in get_tree().get_nodes_in_group("loot"):
		var distance = sqrt(pow(loot.position.x - self.position.x, 2) + pow(loot.position.y - self.position.y, 2))
		if distance < 10:
			add_to_eq(loot)
			loot.queue_free()

func add_to_eq(loot):
	if loot.script_name == "coins":
		self.coins += loot.amount
