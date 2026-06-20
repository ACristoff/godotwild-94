class_name Yipee 
extends Node2D

const MAIN_CHARACTER_FOOTSTEP_GRASS_STEP_3 = preload("uid://bkwvuoumm61h3")
const YIP_BUFF = preload("uid://nkypm8ojycqe")


##Base Yipee class.
@onready var cd_bar: Control = $HealthBar/NinePatchRect/CDBar
@onready var punch_handle: Node2D = $PunchHandle


@export var data: YipeeData

@onready var health: Health = $Health
@onready var attack: Attack = $Attack
@onready var ability: AbilityRunner = $AbilityRunner
@onready var status: StatusEffects = $StatusEffects
@onready var body: YipBody = $AnimScaleHandle/BodyParts

@onready var health_UI: HealthBar = $HealthBar
@onready var hover_area: Area2D = $HoverArea

#region Farm Hub stuff
# Yip can only be picked up in the Farm Hub.
# This will also let us know when they are in the farm hub
var can_be_grabbed : bool = false

# If the yip gets dragged off screen, we snap it back to its last known location
# I want them to run back to the old position if possible with a cute animation. We can slide them for now
# When the yip is spawned in the farm hub, set this variable, we will be spawning the yip in the safe areas.
var farm_last_known_position : Vector2 = Vector2.ZERO

#endregion

signal yip_hovered(yip_data: Yipee)
signal yip_unhovered

func _ready() -> void:
	health.setup(data.get_health())
	attack.setup(data.get_cooldown(), data.get_attack())
	ability.setup(data.helix)
	body.apply_helix(data.helix)
	status.setup(health)
	status.effects_changed.connect(health_UI.update_ailments)
	attack.progress_changed.connect(_on_cooldown_changed)

func enemy_flip():
	cd_bar.scale.x *= -1
	punch_handle.scale.x *= -1

## Lets check to see if we are in the farm scene here.
func _on_hover_area_mouse_entered():
	yip_hovered.emit(self)

func _on_hover_area_mouse_exited():
	yip_unhovered.emit()

func _on_cooldown_changed(fraction):
	health_UI.update_cooldown(fraction)


"""
Note:
Yips
Pick up and Move Yips 
Boolean - To flag yips as being able to be picked up and moved. Done
Function - To drag and drop yips, drop them at the last known location if off screen - Do this after we spawn in the yips into the farm hub scene
Variable - To keep track of position (last placed position, only in farm hub) - Done
Yips don't roam.
"""
