extends Node

func get_files_in_directory(path : String, extension : String, function : FuncRef):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(extension):
				function.call_func(path.plus_file(file_name))
			file_name = dir.get_next()

func filename_from_date():
	var datetime_dictionary = OS.get_datetime()
	datetime_dictionary.erase("dst")
	for key in datetime_dictionary:
		datetime_dictionary[key] = "%02d" % datetime_dictionary[key]
	return "{day}-{month}-{year}_{hour}-{minute}-{second}".format(datetime_dictionary)
