extends Control

var amnt_of_stats : int

@onready var stats_flow_container: FlowContainer = $StatsFlowContainer
@onready var stats_container: NinePatchRect = $StatsContainer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	amnt_of_stats = stats_flow_container.get_child_count()
	match amnt_of_stats:
		1:
			stats_flow_container.size = Vector2(22, 13)
		2:
			stats_flow_container.size = Vector2(42, 13)
		3:
			stats_flow_container.size = Vector2(42, 25)
		4:
			stats_flow_container.size = Vector2(42, 25)
		5:
			stats_flow_container.size = Vector2(42, 37)
		6:
			stats_flow_container.size = Vector2(42, 37)
		7:
			stats_flow_container.size = Vector2(42, 49)
		8:
			stats_flow_container.size = Vector2(42, 49)
		9:
			stats_flow_container.size = Vector2(42, 61)
		10:
			stats_flow_container.size = Vector2(42, 61)
	stats_container.size = stats_flow_container.size
	stats_container.size.y = stats_container.size.y + 2
	stats_container.size.x = stats_container.size.x + 1
			
