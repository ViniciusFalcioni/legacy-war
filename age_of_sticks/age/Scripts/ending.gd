extends Control

@export var ending_label : RichTextLabel
@export var click_sound : AudioStreamPlayer
@export var win_sound : AudioStreamPlayer
@export var lose_sound : AudioStreamPlayer

var color_win : Color = Color("#00ff6b")
var color_lose : Color = Color("#ff0017")

func _ready():
	self.visible = false
	muzzle_music(false)
	

func muzzle_music(toggle : bool):
	var bus_idx = AudioServer.get_bus_index("Music")
	var effect = AudioServer.get_bus_effect(bus_idx, 0)
	if (!toggle):
		effect.cutoff_hz = 20000
	else:
		effect.cutoff_hz = 800

func _on_cave_destroyed(team : String):
	get_tree().paused = true
	self.visible = true
	muzzle_music(true)
	if (team == "Left"):
		lose_sound.play()
		ending_label.modulate = color_lose
		ending_label.text = "[center]" + "PERDEU!" + "[/center]"
	else:
		win_sound.play()
		ending_label.modulate = color_win
		ending_label.text = "[center]" + "VENCEU!" + "[/center]"

func _on_retry_pressed():
	click_sound.play()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed():
	click_sound.play()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
