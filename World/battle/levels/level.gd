class_name Level
extends Resource
@export var level_name: String = ""

@export_group("Team Data")
@export var enemy_team: Array[YipeeData]

@export_group("Intro")
@export var intro_animation: PackedScene
@export var intro_timeline: DialogicTimeline
@export var enemy_portait: Texture2D
@export var enemy_color: Color
