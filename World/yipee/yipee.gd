class_name Yipee 
extends Node2D

##Base Yipee class.

@export var data: YipeeData

@onready var health: Health = $Health
@onready var attack: Attack = $Attack

func _ready() -> void:
	health.setup(data.get_health())
	attack.setup(data.get_cooldown(), data.get_attack())
