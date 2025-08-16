extends Node2D

@onready var particles = $CPUParticles2D

func _ready() -> void:
	particles.emitting = true

func _on_cpu_particles_2d_finished() -> void:
	queue_free()
