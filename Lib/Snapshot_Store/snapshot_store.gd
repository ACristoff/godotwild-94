class_name SnapshotStore

const FOLDER_NAME := "snapshots"



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
