extends Node

# --- Referenzen auf die Player ---
@onready var player_ui      = $PlayerUI
@onready var player_ambient = $PlayerAmbient
@onready var player_alert   = $PlayerAlert
@onready var player_voice   = $PlayerVoice

# --- Alle Sounds zentral registriert ---
const SOUNDS = {
	# UI-Klicks
	"engine_start":        { "file": "res://sounds/engine_start.mp3",        "player": "ui"      },
	"engine_loop":       { "file": "res://sounds/engine_loop.mp3",       "player": "ui"      },

}

# --- Gecachte Streams ---
var _cache: Dictionary = {}

func _ready() -> void:
	_preload_all()

func _preload_all() -> void:
	for key in SOUNDS:
		_cache[key] = load(SOUNDS[key]["file"])

# --- Öffentliche API ---

func play(sound_key: String) -> void:
	var cfg = SOUNDS.get(sound_key)
	if not cfg:
		push_warning("AudioManager: unbekannter Sound '%s'" % sound_key)
		return

	var p = _get_player(cfg["player"])
	p.stream = _cache[sound_key]
	p.play()

func stop(sound_key: String) -> void:
	var cfg = SOUNDS.get(sound_key)
	if cfg:
		_get_player(cfg["player"]).stop()

func stop_all() -> void:
	for p in [$PlayerUI, $PlayerAmbient, $PlayerAlert, $PlayerVoice]:
		p.stop()

func _get_player(name: String) -> AudioStreamPlayer2D:
	match name:
		"ui":      return player_ui
		"ambient": return player_ambient
		"alert":   return player_alert
		"voice":   return player_voice
	push_error("AudioManager: unbekannter Player '%s'" % name)
	return player_ui
