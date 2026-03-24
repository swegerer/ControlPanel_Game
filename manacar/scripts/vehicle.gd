extends Node2D

# VehicleBody.gd
var engine_active: bool = false
var brake_force: float = 0.0

func _physics_process(delta):
	if engine_active:
		#apply_central_force(Vector2(thrust, 0))
		return
