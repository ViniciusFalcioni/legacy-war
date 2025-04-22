extends CharacterBody2D

class_name StickFigure

const GRAVITY = 100

@export var animation_player : AnimationPlayer
@export var audio_player : AudioStreamPlayer
@export var blood_particles : CPUParticles2D
@export var raycast : RayCast2D
@export var life_bar : ProgressBar
@export var polygons : Node2D 
@export var skeleton : Skeleton2D
@export var hurt_sound : AudioStreamPlayer

@export_enum("Left", "Right") var team : String = "Right"
@export var speed : int = 100
@export var hp : int = 250
@export var damage : int = 25

const PRICE : int = 200

const CRITICAL_MULT : float = 2
const CRITICAL_RATE : float = .1

var is_dead : bool = false

func _ready():
	reset()
	set_team()

func reset():
	life_bar.max_value = hp
	life_bar.value = hp
	blood_particles.emitting = false
	is_dead = false

func set_team():
	raycast.target_position = -raycast.target_position if team == "Right" else raycast.target_position
	polygons.scale.x = 1 if team == "Right" else -1
	skeleton.scale.x = -1 if team == "Right" else 1
	blood_particles.scale.x = -1 if team == "Right" else 1

func apply_gravity(delta : float):
	velocity.y += GRAVITY * delta

func apply_movement():
	move_and_slide()

func walk():
	velocity.x = -speed if team == "Right" else speed

func is_raycast_colliding():
	return raycast.is_colliding() if !(raycast.get_collider() is Cave) else raycast.is_colliding() and raycast.get_collider().team != self.team

func is_enemy_detected():
	if (raycast.is_colliding() and raycast.get_collider().team != self.team):
		return true
	return false

func _on_hurt_box_area_entered(area: Area2D):
	var enemy = area.get_owner()
	if (enemy.team != self.team):
		hurt_sound.play()
		blood_particles.emitting = true
		var critical_chance = randf() < CRITICAL_RATE
		life_bar.value -= enemy.damage if !critical_chance else enemy.damage * CRITICAL_MULT
