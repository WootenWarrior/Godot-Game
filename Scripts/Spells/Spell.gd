extends AnimatedSprite2D

class_name Spell

enum types {AREA,PROJECTILE}

var damage = 1
var charge_time = 1
var collider = null
var area = null
var knockback_strength = 0
var player = null
var type = null
var max_reach = 0
var sprite = null
@export var hotbar_image:AtlasTexture = null

signal idle
signal fire
signal despawn

func _ready() -> void:
	player = WorldManager.get_player()
	connect("tree_exited",Callable(self, "_on_tree_exited"))

func set_collider(_collider) -> void:
	collider = _collider

func set_area(_area) -> void:
	area = _area

func set_animated_sprite(animated_sprite):
	sprite = animated_sprite

func knockback(body, direction) -> void:
	body.apply_force(direction,knockback_strength)

func connect_to_area_signal() -> void:
	area.connect("body_entered", Callable(self, "_on_area_2d_body_entered"))

func connect_to_animation_signal() -> void:
	sprite.connect("on_animation_finished", Callable(self, "_on_animation_finished"))

func _on_tree_exited() -> void:
	player.weapon.equipped_spell = null
