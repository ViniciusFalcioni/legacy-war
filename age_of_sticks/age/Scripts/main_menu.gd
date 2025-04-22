extends Control

@export var button_sound : AudioStreamPlayer

func _on_button_pressed():
	button_sound.play()
	await button_sound.finished
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
