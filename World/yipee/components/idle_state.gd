class_name IdleState extends Node

@onready var timer: Timer = $IdleTimer
var yip_animation_player: AnimationPlayer

enum Mood { IDLE, WANDER, SLEEP }

const MOODS := {
	Mood.IDLE: {
		"animation_name": "IdleNormal",
		"duration": 20,
	},
	Mood.WANDER: {
		"animation_name": "Wander",
		"duration": 12,
	},
	Mood.SLEEP: {
		"animation_name": "Sleep",
		"duration": 30,
	},
}

var variance: float = 10.0

func setup(anim_player: AnimationPlayer):
	yip_animation_player = anim_player

func start():
	enter_random()

func stop():
	timer.stop()

func enter_random():
	enter_mood(MOODS.keys().pick_random())

func enter_mood(mood: Mood, duration: float = -1.0):
	var anim_duration = duration
	
	if anim_duration < 0:
		var add_to = randf_range(0, variance)
		anim_duration = MOODS[mood]["duration"] + add_to
	
	yip_animation_player.play("RESET")
	yip_animation_player.advance(0)
	yip_animation_player.play(MOODS[mood]["animation_name"])
	timer.start(anim_duration)

func _on_idle_timer_timeout():
	start()
