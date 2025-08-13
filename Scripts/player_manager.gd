extends Node2D

var player_resource = preload("res://Scenes/player.tscn")
var players = []

func add_player():
	if player_resource:
		var player_instance = player_resource.instance()
		self.add_child(player_instance)
		players.append(player_resource)
	pass

func update_player(player: Player):
	pass
