extends Camera2D

@export var scroll_area_size: int = 150
@export var max_scroll_speed: float = 500.0
@export var dead_zone_width: int = 100

func _physics_process(delta: float):
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_width = get_viewport().get_visible_rect().size.x
	var half_dead_zone = dead_zone_width * 0.5

	var move_dir := 0.0
	var speed_factor := 0.0

	if mouse_pos.x < scroll_area_size:
		move_dir = -1.0
		speed_factor = (scroll_area_size - mouse_pos.x) / scroll_area_size

	elif mouse_pos.x > screen_width - scroll_area_size:
		move_dir = 1.0
		speed_factor = (mouse_pos.x - (screen_width - scroll_area_size)) / scroll_area_size

	elif abs(mouse_pos.x - screen_width * 0.5) < half_dead_zone:
		move_dir = 0.0
		speed_factor = 0.0

	if move_dir != 0:
		global_position.x += move_dir * speed_factor * max_scroll_speed * delta
