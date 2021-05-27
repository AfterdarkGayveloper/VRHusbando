tool
extends EditorScript

func _run():
	var path = "res://mesh/shoto_todoroki/"
	get_files_in_directory(path, ".material", funcref(self, "_process_material"))

func _process_material(path : String):
	var material : SpatialMaterial = load(path).duplicate()
	material.params_diffuse_mode = SpatialMaterial.DIFFUSE_TOON
	material.params_specular_mode = SpatialMaterial.SPECULAR_TOON
	material.roughness = 1.0
	material.next_pass = load("res://misc_materials/OutlineShader.tres")
	var err = ResourceSaver.save(path, material)
	if not err == OK:
		printerr("_process_material err", err)

func get_files_in_directory(path : String, extension : String, function : FuncRef):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(extension):
				function.call_func(path.plus_file(file_name))
			file_name = dir.get_next()
