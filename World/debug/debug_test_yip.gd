extends Node


func _ready() -> void:
	# --- Sample 1: BODY part, red dye ---
	var body_allele := RightAllele.new()
	body_allele.slot = Helix.Slot.HEALTH        # any slot; body_target drives the look
	body_allele.body_target = BodyMap.Part.BODY
	body_allele.body_part = preload("res://Assets/yipee/BodyPartsEdited/CoveredBody.png")
	body_allele.yip_color = Color(1, 0, 0)      # red dye
	body_allele.allele_name = "Test Body (red)"

	# --- Sample 2: HEAD part, blue dye ---
	var head_allele := RightAllele.new()
	head_allele.slot = Helix.Slot.ATTACK
	head_allele.body_target = BodyMap.Part.EYES
	head_allele.body_part = preload("res://Assets/yipee/BodyPartsEdited/WinkEyes.png")
	head_allele.yip_color = Color(0, 0, 1)      # blue dye
	head_allele.allele_name = "Test Head (blue)"

	# --- wire both into a helix ---
	var helix := Helix.new()
	var s1 := Strand.new()
	s1.slot = Helix.Slot.HEALTH
	s1.right = body_allele
	helix.strands[Helix.Slot.HEALTH] = s1

	var s2 := Strand.new()
	s2.slot = Helix.Slot.ATTACK
	s2.right = head_allele
	helix.strands[Helix.Slot.ATTACK] = s2

	# --- build data + spawn ---
	var data := YipeeData.new()
	data.helix = helix

	var yip: Yipee = preload("res://World/yipee/yipee.tscn").instantiate()
	yip.data = data                # MUST be set before add_child — _ready reads it
	yip.position = Vector2(960, 540)
	add_child(yip)
	#print()
