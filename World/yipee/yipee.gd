class_name Yipee 
extends Node2D

##Base Yipee class.

@export var data: YipeeData

@onready var health: Health = $Health
@onready var attack: Attack = $Attack
@onready var ability: AbilityRunner = $AbilityRunner
@onready var status: StatusEffects = $StatusEffects
@onready var body: YipBody = $BodyParts

@onready var health_UI: HealthBar = $HealthBar
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	health.setup(data.get_health())
	attack.setup(data.get_cooldown(), data.get_attack())
	ability.setup(data.helix)
	body.apply_helix(data.helix)
	status.effects_changed.connect(health_UI.update_ailments)
