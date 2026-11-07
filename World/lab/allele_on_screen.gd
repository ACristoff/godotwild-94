extends MarginContainer

const LEVEL_UP_DELAY := 0.5

@export var name_label : Label
@export var level_label : Label
@export var type_texture : TextureRect
@export var BG_color_rect : ColorRect
@export var tick_rect : HBoxContainer

@onready var add_goop_button : Button = $AlleleBG/NameBox/MarginContainer4/Box/MarginContainer3/Tick8/AddGoop

var type
var leveling_up : bool = false
var current_allele: Allele = null

func _ready() -> void:
	clear()

func setup(allele: Allele, slot) -> void:
	current_allele = allele
	type = slot
	leveling_up = false
	refresh()

func clear() -> void:
	setup(null, null)

func refresh() -> void:
	if current_allele == null:
		level_label.text = "Lvl 0"
		show_ticks(Allele.GOOP_PER_TIER, 0)
		add_goop_button.disabled = true
		return
	var cost := current_allele.goop_to_next_tier()
	if current_allele.is_max_tier():
		level_label.text = "MAX"
		show_ticks(cost, cost)
		add_goop_button.disabled = true
		return
	level_label.text = "Lvl %d" % current_allele.tier
	show_ticks(cost, current_allele.goop_progress)
	add_goop_button.disabled = false

func show_ticks(total: int, filled: int) -> void:
	var index := 0
	for tick in tick_rect.get_children():
		tick.visible = index < total
		tick.draw_center = index < filled
		index += 1

func _on_add_goop_pressed() -> void:
	if leveling_up or current_allele == null or current_allele.is_max_tier():
		return
	var goop_key: String = BodyMap.Slot.keys()[type]
	if SignalBus.goop_inventory.get(goop_key, 0) <= 0:
		return
	var allele := current_allele
	SignalBus.spent_goop.emit(type)
	allele.goop_progress += 1
	var cost := allele.goop_to_next_tier()
	if allele.goop_progress >= cost:
		allele.level_up()
		SignalBus.gene_levelled_up.emit(allele)
		leveling_up = true
		show_ticks(cost, cost)
		await get_tree().create_timer(LEVEL_UP_DELAY).timeout
		leveling_up = false
	refresh()
