extends StateMachine

func _ready():
	add_state("IDLE")
	add_state("WALK")
	add_state("ATTACK")
	add_state("DIE")
	
	call_deferred("set_state", states.IDLE)

func _state_logic(delta):
	
	if (state != states.DIE):
		parent.apply_gravity(delta)
		parent.apply_movement()
	
	if (state == states.WALK):
		parent.walk()

func _get_transition(delta):
	match (state):
		states.IDLE:
			if (!parent.is_raycast_colliding()):
				return states.WALK
		states.WALK:
			if (parent.life_bar.value <= 0):
				return states.DIE
			elif (parent.is_enemy_detected()):
				return states.ATTACK
			elif (parent.is_raycast_colliding()):
				return states.IDLE
		states.ATTACK:
			if (parent.life_bar.value <= 0):
				return states.DIE
			elif (parent.is_raycast_colliding() and !parent.is_enemy_detected()):
				return states.IDLE
			elif (!parent.is_raycast_colliding()):
				return states.WALK
		states.DIE:
			if (!parent.is_dead):
				return states.IDLE

func _enter_state(new_state, old_state):
	match (new_state):
		states.IDLE:
			parent.animation_player.play("idle")
		states.WALK:
			parent.animation_player.play("walk")
		states.ATTACK:
			parent.animation_player.play("attack")
		states.DIE:
			parent.is_dead = true
			if (parent.team == "Right"):
				parent.get_node("../../..").ui.add_money(parent.PRICE*1.5)
				parent.get_node("../../..").ui.add_xp(400)
			parent.animation_player.play("die")

func _exit_state(old_state, new_state):
	if (old_state == states.WALK):
		parent.velocity.x = 0
