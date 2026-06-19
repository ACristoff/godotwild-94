class_name Level
extends Resource
@export var level_name: String = ""

@export_group("Enemy Team")
@export var enemy_team: Array[YipeeData]

@export_group("Intro")
@export var intro_animation: PackedScene
@export var intro_timeline: DialogicTimeline
