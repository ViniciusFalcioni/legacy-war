extends Control

class_name GameUI

var stick_person_preload := preload("res://Scenes/stick_person.tscn")
var super_stick_person_preload := preload("res://Scenes/super_stick_person.tscn")

var basic_stick : StickFigure
var super_stick : SuperStickFigure

@export var left_cave : Cave

@export var basic_button : TextureButton
@export var basic_button_texture : TextureProgressBar
@export var super_button : TextureButton
@export var super_button_texture : TextureProgressBar
@export var button_sound : AudioStreamPlayer

@export var money_label : RichTextLabel
@export var level_label : RichTextLabel

var money : int = 400
var XP : int = 0

@export var basic_cooldown : float = 2
@export var super_cooldown : float = 4

var basic_is_on_cooldown : bool = false
var super_is_on_cooldown : bool = false

var level : int = 1
var level_gap : int = 2000


func _ready() -> void:
	basic_stick = stick_person_preload.instantiate()
	super_stick = super_stick_person_preload.instantiate()
	update_money_label(money)
	block_based_on_money()

func update_money_label(value : int):
	money_label.text = "
[color=gold]" + str(value) + "[/color]"

func subtract_money(amount : int):
	money -= amount
	block_based_on_money()
	update_money_label(money)

func add_money(amount : int):
	money += amount
	unblock_based_on_money()
	update_money_label(money)

func update_level_label(value : int):
	level_label.text = "
[color=red]" + str(value) + "[/color]"

func add_xp(amount : int):
	if (level < 2):
		XP += amount
		if (XP > level_gap):
			level += 1
			update_level_label(level)
			unblock_based_on_money()

func block_based_on_money():
	if (money < basic_stick.PRICE):
		basic_button.disabled = true
		basic_button_texture.value = basic_button_texture.max_value
	if (money < super_stick.PRICE or level < 2):
		super_button.disabled = true
		super_button_texture.value = super_button_texture.max_value

func unblock_based_on_money():
	if (money >= basic_stick.PRICE and !basic_is_on_cooldown):
		basic_button.disabled = false
		basic_button_texture.value = basic_button_texture.min_value
	if (money >= super_stick.PRICE and !super_is_on_cooldown and level >= 2):
		super_button.disabled = false
		super_button_texture.value = super_button_texture.min_value

func _on_basic_button_pressed() -> void:
	button_sound.play()
	basic_button.disabled = true
	basic_is_on_cooldown = true
	left_cave.on_spawn_demand("Basic")
	var tween_cooldown = create_tween()
	basic_button_texture.value = basic_button_texture.max_value
	tween_cooldown.tween_property(basic_button_texture, "value", basic_button_texture.min_value, basic_cooldown)
	await tween_cooldown.finished
	basic_tween_finished()
	

func basic_tween_finished():
	basic_button.disabled = false
	basic_is_on_cooldown = false
	block_based_on_money()

func _on_super_button_pressed() -> void:
	button_sound.play()
	super_button.disabled = true
	super_is_on_cooldown = true
	left_cave.on_spawn_demand("Super")
	var tween_cooldown = create_tween()
	super_button_texture.value = super_button_texture.max_value
	tween_cooldown.tween_property(super_button_texture, "value", super_button_texture.min_value, super_cooldown)
	await tween_cooldown.finished
	super_tween_finished()

func super_tween_finished():
	super_button.disabled = false
	super_is_on_cooldown = false
	block_based_on_money()
