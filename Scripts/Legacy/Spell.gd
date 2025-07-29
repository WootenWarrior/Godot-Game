extends AnimatedSprite2D

class_name Spell

@export var SpellConfig: SpellConfig

var sprite: AnimatedSprite2D
var collider = null
var area = null
var player = null
var type = null

signal idle
signal fire
signal despawn

func _ready() -> void:
	player = WorldManager.player
	connect("tree_exited",Callable(self, "_on_tree_exited"))
	connect("despawn", Callable(self, "_on_despawn"))

func set_collider(_collider) -> void:
	collider = _collider

func set_area(_area) -> void:
	area = _area

func set_animated_sprite(animated_sprite):
	sprite = animated_sprite

func knockback(body, direction) -> void:
	var knockback_strength = spell_config.knockback_strength
	if body.name == "Player":
		body.apply_force(direction,knockback_strength)

func connect_to_area_signal() -> void:
	area.connect("body_entered", Callable(self, "_on_area_2d_body_entered"))

func connect_to_animation_signal() -> void:
	spell_config.sprite.connect("on_animation_finished", Callable(self, "_on_animation_finished"))

func _on_tree_exited() -> void:
	player.weapon.equipped_spell = null

func _on_despawn():
	queue_free()
