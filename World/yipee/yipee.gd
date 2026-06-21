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
@onready var farmslot: Area2D = $FarmSlot
@onready var animation_player : AnimationPlayer = $ActionsAnim

@onready var cost_of_yip: Sprite2D = $CostOfYip
@onready var cost: Label = $CostOfYip/Cost

var dead = false

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

\
func in_battle_dance():
	$ActionsAnim.play("IdleBattle")

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


func _on_throw_punch_anim_animation_finished(anim_name: StringName) -> void:
	if !dead:
		$ActionsAnim.play("IdleBattle")


func _on_hit_anim_animation_finished(anim_name: StringName) -> void:
	if !dead:
		$ActionsAnim.play("IdleBattle")

func _on_actions_anim_animation_finished(anim_name: StringName) -> void:
	pass
	#$ActionsAnim.play("IdleBattle")
