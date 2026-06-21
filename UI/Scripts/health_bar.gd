class_name HealthBar extends Control

@onready var texture_progress_bar: TextureProgressBar = $NinePatchRect/TextureProgressBar
@onready var health_text: Label = $NinePatchRect/TextureProgressBar/HealthText
@onready var shield_text: Label = $NinePatchRect/Shield/ShieldText
@onready var shield: TextureRect = $NinePatchRect/Shield
@onready var damage_indicator_spawn: Marker2D = $DamageIndicatorSpawn
@onready var status_ailments: HFlowContainer = $StatusAilments
@onready var yip_stats: HFlowContainer = $YipStats
@onready var cooldown_bar: TextureProgressBar = $NinePatchRect/CDBar/TextureProgressBar

const DAMAGE_TOOLYIP = preload("uid://cxcii53yccour")
const DAMAGE_INDICATOR = preload("uid://b1wbuxori6udj")



@export var max_health : int

var HP_graphic_size : int = 52
var HP_graphic_step_size : float
var current_health : int
var current_shield : int = 0

var current_ailments = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health
	
	#in ready youd instantiate all the yips stats on the YipStats flowbox

func update_cooldown(current):
	var converted = int(current * 34)
	cooldown_bar.value = converted

func health_change(change : int, type : String):
	var amount_of_change = current_health - change
	if amount_of_change == 0:
		return
	if amount_of_change < 0:
		amount_of_change *= -1
		spawn_damage_indicator(change, type)
		current_health += amount_of_change
		return
	spawn_damage_indicator(change, type)
	#print("YOOOOOOOO  ", amount_of_change)
	current_health -= change
	
	HP_graphic_step_size = float(HP_graphic_size) / float(max_health)
	texture_progress_bar.value = current_health * HP_graphic_step_size
	damage_indicator_spawn.position.x = current_health * HP_graphic_step_size
	health_text.text = str(current_health, "/", max_health)
	if current_shield <= 0:
		shield.hide()
	else:
		shield.show()
	shield_text.text = str(current_shield)

func update_UI():
	HP_graphic_step_size = float(HP_graphic_size) / float(max_health)
	texture_progress_bar.value = current_health * HP_graphic_step_size
	damage_indicator_spawn.position.x = current_health * HP_graphic_step_size
	health_text.text = str(current_health, "/", max_health)
	if current_shield <= 0:
		shield.hide()
	else:
		shield.show()
	shield_text.text = str(current_shield)

func spawn_damage_indicator(value, type):
	var dmg_indicator = DAMAGE_INDICATOR.instantiate()
	get_tree().get_root().add_child(dmg_indicator)
	dmg_indicator.global_position = damage_indicator_spawn.global_position
	dmg_indicator.popup(value, type)

func populate_yip_stats(data: YipeeData) -> void:
	var pips := {}
	var attack_total := roundi(data.get_attack())
	if attack_total > 0:
		pips["PHYSICAL"] = attack_total
	for strand in data.helix.strands:
		if strand == null:
			continue
		for allele in [strand.left, strand.right]:
			if allele == null:
				continue
			var contribution: Dictionary = allele.get_damage_pips()
			for type in contribution:
				pips[type] = pips.get(type, 0) + contribution[type]
	for child in yip_stats.get_children():
		child.queue_free()
	for type in pips:
		if pips[type] <= 0:
			continue
		var pip = DAMAGE_TOOLYIP.instantiate()
		yip_stats.add_child(pip)
		pip.ailment_name = type
		pip.value = pips[type]

func update_ailments(status_name: String, ailment_value: int):
	for i in current_ailments.size():
		var ailment = current_ailments[i]
		if ailment["status_name"] == status_name:
			if ailment_value <= 0:
				ailment["node"].queue_free()
				current_ailments.remove_at(i)
			else:
				ailment["value"] = ailment_value
				ailment["node"].value = ailment_value
			return
	# not currently shown:
	if ailment_value <= 0:
		return
	var dmg_note = DAMAGE_TOOLYIP.instantiate()
	status_ailments.add_child(dmg_note)
	dmg_note.ailment_name = status_name
	dmg_note.value = ailment_value
	current_ailments.append({
		"status_name": status_name,
		"value": ailment_value,
		"node": dmg_note
	})
