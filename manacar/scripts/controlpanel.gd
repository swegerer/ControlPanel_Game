extends Node2D

@onready var audio = $Node2D/AudioManager

# Wird nur emitted wenn die Anzeige angepasst wird. 
signal button_state_changed()


# --- Enum für alle möglichen Zustände ---
enum ButtonState { OFF, GREEN, RED }

# --- Konfiguration aller Buttons ---
# "name": { overlays pro State, Area2D-Node-Name }
const BUTTON_CONFIG = {
	"Start": {
		ButtonState.OFF:   [],                          # kein Overlay sichtbar
		ButtonState.GREEN: ["Start_green"],
		ButtonState.RED:   ["Start_red"],
		"area": "Start"
	},
	"Auto": {
		ButtonState.OFF:   [],                          # kein Overlay sichtbar
		ButtonState.GREEN: ["Auto_green"],
		ButtonState.RED:   ["Auto_red"],
		"area": "Auto"
	},
	"Engine1": {
		ButtonState.OFF:   [],                          # kein Overlay sichtbar
		ButtonState.GREEN: ["Engine1_green"],
		ButtonState.RED:   ["Engine1_red"],
		"area": "Engine1"
	},
	"Engine2": {
		ButtonState.OFF:   [],                          # kein Overlay sichtbar
		ButtonState.GREEN: ["Engine2_green"],
		ButtonState.RED:   ["Engine2_red"],
		"area": "Engine2"
	},
	"Forward": {
		ButtonState.OFF:   [],                          # kein Overlay sichtbar
		ButtonState.GREEN: ["Forward_green"],
		ButtonState.RED:   ["Forward_red"],
		"area": "Forward"
	},
	"High": {
		ButtonState.OFF:   [],                          # kein Overlay sichtbar
		ButtonState.GREEN: ["High_green"],
		ButtonState.RED:   ["High_red"],
		"area": "High"
	},
	"Jog": {
		ButtonState.OFF:   [],                          # kein Overlay sichtbar
		ButtonState.GREEN: ["Jog_green"],
		ButtonState.RED:   ["Jog_red"],
		"area": "Jog"
	},
	"Low": {
		ButtonState.OFF:   [],                          # kein Overlay sichtbar
		ButtonState.GREEN: ["Low_green"],
		ButtonState.RED:   ["Low_red"],
		"area": "Low"
	},
	"Lower": {
		ButtonState.OFF:   [],                          # kein Overlay sichtbar
		ButtonState.GREEN: ["Lower_green"],
		ButtonState.RED:   ["Lower_red"],
		"area": "Lower"
	},
	"Man": {
		ButtonState.OFF:   [],                          # kein Overlay sichtbar
		ButtonState.GREEN: ["Man_green"],
		ButtonState.RED:   ["Man_red"],
		"area": "Man"
	},
	"Off": {
		ButtonState.OFF:   [],                          # kein Overlay sichtbar
		ButtonState.GREEN: ["Off_green"],
		ButtonState.RED:   ["Off_red"],
		"area": "Off"
	},
	"Open2": {
		ButtonState.OFF:   [],                          # kein Overlay sichtbar
		ButtonState.GREEN: ["Open2_green"],
		ButtonState.RED:   ["Open2_red"],
		"area": "Open2"
	},
	"Open": {
		ButtonState.OFF:   [],                          # kein Overlay sichtbar
		ButtonState.GREEN: ["Open_green"],
		ButtonState.RED:   ["Open_red"],
		"area": "Open"
	},
	"Raise": {
		ButtonState.OFF:   [],                          # kein Overlay sichtbar
		ButtonState.GREEN: ["Raise_green"],
		ButtonState.RED:   ["Raise_red"],
		"area": "Raise"
	},
	"Reset": {
		ButtonState.OFF:   [],                          # kein Overlay sichtbar
		ButtonState.GREEN: ["Reset_green"],
		ButtonState.RED:   ["Reset_red"],
		"area": "Reset"
	},
	"Run": {
		ButtonState.OFF:   [],                          # kein Overlay sichtbar
		ButtonState.GREEN: ["Run_green"],
		ButtonState.RED:   ["Run_red"],
		"area": "Run"
	},
	"Stop": {
		ButtonState.OFF:   [],   
		ButtonState.GREEN: ["Stop_green"],              # kein Overlay sichtbar
		ButtonState.RED:   ["Stop_red"],
		"area": "Stop"
	},
	
	
	# --- Einfach weitere Buttons hier anhängen ---
}

# --- Laufzeit-Zustand ---
var button_states: Dictionary = {}

func _ready() -> void:
	# Alle Buttons auf OFF initialisieren
	for btn_name in BUTTON_CONFIG:
		button_states[btn_name] = ButtonState.OFF
		_apply_state(btn_name)

		# Input-Signal vom Area2D verbinden
		var area_name = BUTTON_CONFIG[btn_name]["area"]
		var area = $ButtonsArea.get_node(area_name)
		if area:
			area.input_event.connect(_on_area_input.bind(btn_name))

func _on_area_input(_viewport, event: InputEvent, _shape_idx, btn_name: String) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		if _can_activate(btn_name):       # ← Logik-Gate
			_cycle_state(btn_name)

# Hier sitzt deine gesamte Spiellogik
func _can_activate(btn_name: String) -> bool:
	# Beispiel: button_03 nur aktivierbar wenn button_01 grün ist
	if btn_name == "Start":
		return button_states["Start"] == ButtonState.OFF

	if btn_name == "Engine1":
		return button_states["Start"] == ButtonState.GREEN
	return true

func _cycle_state(btn_name: String) -> void:
	var current = button_states[btn_name]
	# Zyklus: OFF → GREEN → RED → OFF
	var next = (current + 1) % ButtonState.size()
	
	button_states[btn_name] = next
		
	audio.play("engine_start")
	_apply_state(btn_name)
	print("Button '%s' → %s" % [btn_name, ButtonState.keys()[next]])

func set_button(btn_name: String, state: ButtonState) -> void:
	button_states[btn_name] = state
	_apply_state(btn_name)
	#_play_sound_for_state(btn_name, state)

func _apply_state(btn_name: String) -> void:
	
	var config = BUTTON_CONFIG[btn_name]
	var active_overlays: Array = config.get(button_states[btn_name], [])

	# Alle Overlays dieses Buttons erst ausblenden
	for state in ButtonState.values():
		for overlay_name in config.get(state, []):
			var node = $OverlayContainer.get_node_or_null(overlay_name)
			if node:
				node.visible = false

	# Dann nur die aktiven einblenden
	for overlay_name in active_overlays:
		var node = $OverlayContainer.get_node_or_null(overlay_name)
		if node:
			node.visible = true
			
	button_state_changed.emit(btn_name, button_states[btn_name])
