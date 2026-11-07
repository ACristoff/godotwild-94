class_name SnapshotStore

const FOLDER_NAME := "snapshots"
const FORMAT_VERSION := 1


static func get_root_folder() -> String:
	if OS.has_feature("web"):
		return ""
	var user_folder := ProjectSettings.globalize_path("user://").path_join(FOLDER_NAME)
	if OS.has_feature("editor"):
		return user_folder
	var exe_folder := OS.get_executable_path().get_base_dir().path_join(FOLDER_NAME)
	if _can_write(exe_folder):
		return exe_folder
	return user_folder

static func get_day_folder(day: int) -> String:
	var root_folder := get_root_folder()
	if root_folder.is_empty():
		return ""
	return root_folder.path_join("day_%d" % day)

static func _can_write(folder: String) -> bool:
	if DirAccess.make_dir_recursive_absolute(folder) != OK:
		return false
	var probe_path := folder.path_join(".write_test")
	var probe_file := FileAccess.open(probe_path, FileAccess.WRITE)
	if probe_file == null:
		return false
	probe_file.close()
	DirAccess.remove_absolute(probe_path)
	return true

static func save_party(party: Array, won: bool, day: int) -> void:
	var day_folder := get_day_folder(day)
	if day_folder.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(day_folder)
	var safe_name := SignalBus.player_name.strip_edges().validate_filename()
	if safe_name.is_empty():
		safe_name = "anon"
	var file_name := "%d_%s.json" % [int(Time.get_unix_time_from_system()), safe_name]
	var file_path := day_folder.path_join(file_name)
	var snapshot_file := FileAccess.open(file_path, FileAccess.WRITE)
	if snapshot_file == null:
		push_error("SnapshotStore: cannot write %s (error %d)" % [file_path, FileAccess.get_open_error()])
		return
	snapshot_file.store_string(JSON.stringify(PartySnapshot.party_to_dict(party, won, day), "\t"))
	snapshot_file.close()

static func load_random_opponent(day: int) -> Level:
	var day_folder := get_day_folder(day)
	if day_folder.is_empty():
		return null
	var folder_access := DirAccess.open(day_folder)
	if folder_access == null:
		return null
	var file_names := Array(folder_access.get_files())
	file_names.shuffle()
	for file_name: String in file_names:
		if not file_name.ends_with(".json"):
			continue
		var snapshot = JSON.parse_string(FileAccess.get_file_as_string(day_folder.path_join(file_name)))
		if typeof(snapshot) != TYPE_DICTIONARY:
			continue
		if int(snapshot.get("format", 0)) != FORMAT_VERSION:
			continue
		if str(snapshot.get("run_id", "")) == SignalBus.run_id:
			continue
		var opponent_level := PartySnapshot.dict_to_level(snapshot)
		if opponent_level != null:
			return opponent_level
	return null
