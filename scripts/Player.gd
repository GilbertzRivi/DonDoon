extends CharacterBody2D

var tile_size = 32
var inputs = {"right": Vector2.RIGHT,
			"left": Vector2.LEFT,
			"up": Vector2.UP,
			"down": Vector2.DOWN}

@onready var ray = $RayCast2D
@onready var _animated_sprite = $AnimatedSprite2D

var max_hp: int = 1000
var hp: int = max_hp
var max_mana: int = 1000
var mana: int = max_mana
var can_move: bool = true
var attack_range: float = 1.5
var damage: int = 10
var game_over: bool = false
var crit_chance: int = 5 # %
var crit_multiplier: float = 1.5
var damage_range: int = 15 # +- damage given in %
var xp: int = 0
var level: int = 1
var level_treshold: int = level * 125
var skill_points: int = 0

func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	$"../UI".set_hp_bar(max_hp, hp)
	$"../UI".set_mana_bar(max_mana, mana)
	$"../UI".set_xp_bar(level_treshold, xp)
	_animated_sprite.play("idle")

func _unhandled_input(event):
	if can_move and !game_over:
		if event.is_action_pressed("inventory"):
			inventory()
		for dir in inputs.keys():
			if event.is_action_pressed(dir):
				move(dir)
	else:
		return

func move(dir):
	var Map = get_tree().current_scene.get_node("Map")
	ray.target_position = inputs[dir] * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		position += inputs[dir] * tile_size
		can_move = false
		if dir == "down" and int(position.y/tile_size) % 4 == 0:
			Map.generate_new_row()
		Map.update_enemies()
			
func attack(enemy):
	var Map = get_tree().current_scene.get_node("Map")
	var calculated_damage = calculate_damage(damage)
	if (abs(enemy.global_position.x - self.position.x) < tile_size * attack_range and 
		abs(enemy.global_position.y - self.position.y) < tile_size * attack_range):
		enemy.hit(self, damage)
		can_move = false
		Map.update_enemies()

func hit(given_damage):
	hp -= given_damage
	if hp <= 0:
		game_over = true
		var game_over_screen = load("res://scenes/game_over.tscn").instantiate()
		$"../UI".add_child(game_over_screen)
	$"../UI".set_hp_bar(max_hp, hp)

func calculate_damage(given_damage) -> int:
	var calculated_damage = 1
	var d_range: float = given_damage*damage_range/100
	calculated_damage = damage + (d_range - (randi()%int(d_range*2)+1))
	if randi()%100+1 < crit_chance:
		calculated_damage *= crit_multiplier
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
