extends Node

# Manages all animations in the game using Godot's AnimationTree system

# Preload required classes
const Character = preload("res://scripts/character.gd")

@onready var animation_tree: AnimationTree
@onready var animation_player: AnimationPlayer

# Animation states
enum AnimationState {
	IDLE,
	WORKING,
	LEVEL_UP,
	ACHIEVEMENT,
	ERROR,
	SUCCESS
}

var current_state: AnimationState = AnimationState.IDLE
var animation_queue: Array[AnimationState] = []

# UI Animation properties
var ui_animations: Dictionary = {}
var character_animations: Dictionary = {}

func _ready():
	# Initialize animation tree if it exists
	if has_node("AnimationTree"):
		animation_tree = get_node("AnimationTree")
		animation_tree.active = true

	if has_node("AnimationPlayer"):
		animation_player = get_node("AnimationPlayer")

	# Connect to game events
	GameEvents.activity_started.connect(_on_activity_started)
	GameEvents.activity_completed.connect(_on_activity_completed)
	GameEvents.character_leveled_up.connect(_on_character_leveled_up)
	GameEvents.achievement_unlocked.connect(_on_achievement_unlocked)

func _process(delta):
	process_animation_queue()

func play_animation(animation_name: String, custom_speed: float = 1.0) -> void:
	if animation_player and animation_player.has_animation(animation_name):
		animation_player.play(animation_name)
		animation_player.speed_scale = custom_speed

func play_ui_animation(ui_element: Control, animation_type: String) -> void:
	match animation_type:
		"fade_in":
			animate_fade_in(ui_element)
		"fade_out":
			animate_fade_out(ui_element)
		"slide_in":
			animate_slide_in(ui_element)
		"slide_out":
			animate_slide_out(ui_element)
		"bounce":
			animate_bounce(ui_element)
		"shake":
			animate_shake(ui_element)

func animate_fade_in(ui_element: Control) -> void:
	ui_element.modulate.a = 0.0
	var tween = create_tween()
	var element_ref = weakref(ui_element)
	tween.tween_property(ui_element, "modulate:a", 1.0, 0.3)
	tween.tween_callback(func(): _set_modulate_alpha(element_ref, 1.0))

func animate_fade_out(ui_element: Control) -> void:
	var tween = create_tween()
	var element_ref = weakref(ui_element)
	tween.tween_property(ui_element, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): _set_modulate_alpha(element_ref, 1.0))

func animate_slide_in(ui_element: Control) -> void:
	var original_position = ui_element.position
	ui_element.position.x -= 100
	var tween = create_tween()
	var element_ref = weakref(ui_element)
	tween.tween_property(ui_element, "position:x", original_position.x, 0.3)
	tween.tween_callback(func(): _set_position(element_ref, original_position))

func animate_slide_out(ui_element: Control) -> void:
	var original_position = ui_element.position
	var tween = create_tween()
	var element_ref = weakref(ui_element)
	tween.tween_property(ui_element, "position:x", original_position.x - 100, 0.3)
	tween.tween_callback(func(): _set_position(element_ref, original_position))

func animate_bounce(ui_element: Control) -> void:
	var original_scale = ui_element.scale
	var tween = create_tween()
	var element_ref = weakref(ui_element)
	tween.tween_property(ui_element, "scale", original_scale * 1.2, 0.1)
	tween.tween_property(ui_element, "scale", original_scale, 0.1)
	tween.tween_callback(func(): _set_scale(element_ref, original_scale))

func animate_shake(ui_element: Control) -> void:
	var original_position = ui_element.position
	var tween = create_tween()
	var element_ref = weakref(ui_element)

	for i in range(5):
		var offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		tween.tween_property(ui_element, "position", original_position + offset, 0.05)

	tween.tween_property(ui_element, "position", original_position, 0.05)
	tween.tween_callback(func(): _set_position(element_ref, original_position))

func animate_progress_bar(progress_bar: ProgressBar, target_value: float, duration: float = 1.0) -> void:
	var tween = create_tween()
	var bar_ref = weakref(progress_bar)
	tween.tween_property(progress_bar, "value", target_value, duration)
	tween.tween_callback(func(): _set_progress_value(bar_ref, target_value))

func animate_number_counter(label: Label, start_value: int, end_value: int, duration: float = 1.0) -> void:
	var tween = create_tween()
	var label_ref = weakref(label)
	tween.tween_method(
		func(value: float): _set_label_text(label_ref, str(int(value))),
		start_value,
		end_value,
		duration
	)
	tween.tween_callback(func(): _set_label_text(label_ref, str(end_value)))

func queue_animation(state: AnimationState) -> void:
	animation_queue.append(state)

func process_animation_queue() -> void:
	if animation_queue.is_empty():
		return

	var next_animation = animation_queue.pop_front()
	play_state_animation(next_animation)

func play_state_animation(state: AnimationState) -> void:
	current_state = state

	match state:
		AnimationState.IDLE:
			play_animation("idle")
		AnimationState.WORKING:
			play_animation("working", 0.8)
		AnimationState.LEVEL_UP:
			play_animation("level_up")
			play_sound_effect("level_up")
		AnimationState.ACHIEVEMENT:
			play_animation("achievement")
			play_sound_effect("achievement")
		AnimationState.ERROR:
			play_animation("error")
			play_sound_effect("error")
		AnimationState.SUCCESS:
			play_animation("success")
			play_sound_effect("success")

func play_sound_effect(effect_name: String) -> void:
	# This would connect to the audio system
	# For now, just emit a signal
	GameEvents.debug_message.emit("Playing sound effect: " + effect_name, "info")

# Event handlers
func _on_activity_started(character: Character, activity: String) -> void:
	queue_animation(AnimationState.WORKING)

func _on_activity_completed(character: Character, activity: String, rewards: Dictionary) -> void:
	queue_animation(AnimationState.SUCCESS)

func _on_character_leveled_up(character: Character, new_level: int) -> void:
	queue_animation(AnimationState.LEVEL_UP)

func _on_achievement_unlocked(achievement: String) -> void:
	queue_animation(AnimationState.ACHIEVEMENT)

# Animation presets for common UI elements
func create_progress_animation(progress_bar: ProgressBar) -> void:
	# Smooth progress bar animation
	animate_progress_bar(progress_bar, progress_bar.value, 0.5)

func create_countup_animation(label: Label, target_value: int) -> void:
	# Animated number counting
	animate_number_counter(label, 0, target_value, 1.0)

func create_pulse_animation(ui_element: Control) -> void:
	# Pulsing effect for important elements
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(ui_element, "modulate:a", 0.5, 0.5)
	tween.tween_property(ui_element, "modulate:a", 1.0, 0.5)

func stop_pulse_animation(ui_element: Control) -> void:
	# Stop any pulsing animations
	var tween = create_tween()
	tween.kill()
	ui_element.modulate.a = 1.0

# Helper functions to safely set properties using weak references
func _set_modulate_alpha(element_ref: WeakRef, alpha: float) -> void:
	var element = element_ref.get_ref()
	if element and is_instance_valid(element):
		element.modulate.a = alpha

func _set_position(element_ref: WeakRef, position: Vector2) -> void:
	var element = element_ref.get_ref()
	if element and is_instance_valid(element):
		element.position = position

func _set_scale(element_ref: WeakRef, scale: Vector2) -> void:
	var element = element_ref.get_ref()
	if element and is_instance_valid(element):
		element.scale = scale

func _set_progress_value(bar_ref: WeakRef, value: float) -> void:
	var bar = bar_ref.get_ref()
	if bar and is_instance_valid(bar):
		bar.value = value

func _set_label_text(label_ref: WeakRef, text: String) -> void:
	var label = label_ref.get_ref()
	if label and is_instance_valid(label):
		label.text = text
