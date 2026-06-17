class_name Yipee 
extends Node2D

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

func _ready() -> void:
	health.setup(data.get_health())
	attack.setup(data.get_cooldown(), data.get_attack())
	ability.setup(data.helix)
	body.apply_helix(data.helix)
	status.effects_changed.connect(health_UI.update_ailments)

func enemy_flip():
	cd_bar.scale.x *= -1
	punch_handle.scale.x *= -1
