extends Node

var player_node: Node = null
var spell_inventory = []
signal spell_inventory_updated

func _ready():
	spell_inventory.resize(2)

func add_spell():
	spell_inventory_updated.emit()

func remove_item():
	spell_inventory_updated.emit()

func increase_inventory_size():
	spell_inventory_updated.emit()

func set_player_reference(player):
	player_node = player
