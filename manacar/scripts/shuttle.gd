extends Node2D

# VehicleManager.gd
@onready var controlpanel = $Vehicle/InteriorAnchor/Controlpanel
@onready var body  = $Vehicle/case/RigidBody2D

func _ready():
	# Panel-Signal abonnieren und an Body weiterleiten
	controlpanel.button_state_changed.connect(_on_panel_changed)

func _on_panel_changed(btn_name: String, state: int) -> void:
	match btn_name:
		"Engine1":
			body.engine_active = (state == controlpanel.ButtonState.GREEN)
		"button_brake":
			body.brake_force = 800.0 if state != controlpanel.ButtonState.OFF else 0.0
