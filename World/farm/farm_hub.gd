extends Node2D

var all_yips:  Array[Yipee] = []


#func _spawn(data: YipeeData, pos: Vector2) -> Yipee:
	#var yip := preload("res://World/yipee/yipee.tscn").instantiate() as Yipee
	#yip.data = data
	#yip.position = pos
	#
	#add_child(yip)
	#yip.health_UI.visible = true
	#yip.health_UI.current_health = yip.health.current_health
	#yip.health_UI.max_health = yip.health.max_health
	#yip.health_UI.update_UI()
	#return yip

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for yip in SignalBus.yip_inventory:
		print(yip)
		#var new_yip = spawn_yip()
		#wire_yip(new_yip)
		#all_yips.append(new_yip)
		pass

func spawn_yip(data: YipeeData, pos: Vector2) -> Yipee:
	var yip := preload("res://World/yipee/yipee.tscn").instantiate() as Yipee
	yip.data = data
	yip.position = pos
	
	add_child(yip)
	yip.health_UI.visible = false
	yip.health_UI.current_health = yip.health.current_health
	yip.health_UI.max_health = yip.health.max_health
	yip.health_UI.update_UI()
	return yip

func wire_yip(yip: Yipee) -> void:
	#yip.yip_hovered.connect(_on_yip_hovered)
	#yip.yip_unhovered.connect(_on_yip_unhovered)
	print('wire yip', yip)



func _on_texture_button_mouse_entered() -> void:
	$LabDoor2.play("DoorOpen")
func _on_texture_button_mouse_exited() -> void:
	$LabDoor2.play("DoorClose")

func _on_field_button_pressed():
	SignalBus.go_to.emit(SignalBus.Locations.FIELD)
	pass # Replace with function body.
