extends Node2D

class_name Cave

signal cave_destroyed

var stick_person_preload := preload("res://Scenes/stick_person.tscn")
var super_stick_person_preload := preload("res://Scenes/super_stick_person.tscn")

var stick_person : StickFigure
var super_stick_person : SuperStickFigure

@export var life_bar : ProgressBar
@export var spawn_timer : Timer
@export var spawn_point : Marker2D
@export var collision : CollisionShape2D
@export var hurtbox : Area2D
@export var visuals : Sprite2D
@export var ui : GameUI

@export var destroy_sound : AudioStreamPlayer
@export var hit_sound : AudioStreamPlayer

@export_enum("Left", "Right") var team : String = "Right"

const CRITICAL_MULT : float = 2
const CRITICAL_RATE : float = .1

const MIN_SPAWN_TIME : float = 5
const MAX_SPAWN_TIME : float = 8

@export var hp : int = 1000

func _ready():
	stick_person = stick_person_preload.instantiate()
	super_stick_person = super_stick_person_preload.instantiate()
	life_bar.max_value = hp
	life_bar.value = hp
	if (team == "Left"):
		collision.position.x *= -1
		hurtbox.position.x *= -1
		spawn_point.position.x *= -1
		life_bar.position.x *= -1
		visuals.scale.x = -1
	else:
		recalculate_spawn_timer()
		spawn_timer.start()

func recalculate_spawn_timer():
	spawn_timer.wait_time = randf_range(MIN_SPAWN_TIME, MAX_SPAWN_TIME)

func instantiate_stick_person(type : String):
	var stick_person = stick_person_preload.instantiate() if type == "Basic" else super_stick_person_preload.instantiate()
	stick_person.team = self.team
	spawn_point.get_node(type).add_child(stick_person)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	hit_sound.play()
	var enemy = area.get_owner()
	if (enemy.team != self.team):
		var critical_chance = randf() < CRITICAL_RATE
		life_bar.value -= enemy.damage if !critical_chance else enemy.damage * CRITICAL_MULT
	if (life_bar.value <= 0):
		destroy_sound.play()
		emit_signal("cave_destroyed", team)

func on_spawn_demand(type : String):
	var stick = stick_person if type == "Basic" else super_stick_person
	var money : int = int(ui.money_label.text)
	var found_dead : bool = false
	
	for stick_person in spawn_point.get_node(type).get_children():
		if (stick_person.is_dead and money >= stick.PRICE):
			ui.subtract_money(stick.PRICE)
			stick_person.position = Vector2.ZERO
			stick_person.reset()
			found_dead = true
			break;
	
	if (!found_dead and money >= stick.PRICE):
		ui.subtract_money(stick.PRICE)
		instantiate_stick_person(type)

func _on_spawn_timer_timeout() -> void:
	spawn_timer.paused = true
	recalculate_spawn_timer()
	var found_dead : bool = false
	
	for stick_person in spawn_point.get_node("Basic").get_children():
		if (stick_person.is_dead):
			stick_person.position = Vector2.ZERO
			stick_person.reset()
			found_dead = true
			break;
	
	if (!found_dead):
		instantiate_stick_person("Basic")
	spawn_timer.paused = false
