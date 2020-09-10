extends Node

var custom_data = {
	missiles_unlocked = false,
	boss_defeated = false
}

var is_loading = false

func save_game():
	var save_game = File.new()
	save_game.open("user://save_game.save", File.WRITE)
	save_game.store_line(to_json(custom_data))
	var persisting_nodes = get_tree().get_nodes_in_group("Persists")
	for node in persisting_nodes:
		var node_data = node.save()
		save_game.store_line(to_json(node_data))
	save_game.close()

func reset_custom_data():
	self.custom_data = {
		missiles_unlocked = false,
		boss_defeated = false
	}

func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://save_game.save"):
		return
	
	var persisting_nodes = get_tree().get_nodes_in_group("Persists")
	for node in persisting_nodes:
		node.queue_free()
	
	save_game.open("user://save_game.save", File.READ)
	if not save_game.eof_reached():
		var custom_data_line = save_game.get_line()
		if custom_data_line != "":
			custom_data = parse_json(custom_data_line)

	while not save_game.eof_reached():
		var line_string = save_game.get_line()
		if line_string == "":
			continue
		var current_line = parse_json(line_string)
		if current_line != null:
			var new_node = load(current_line["filename"]).instance()
			get_node(current_line["parent"]).add_child(new_node, true)
			new_node.position = Vector2(current_line["position_x"], current_line["position_y"])
			for property in current_line.keys():
				if (property == "filename"
					or property == "parent"
					or property == "position_x"
					or property == "position_y"):
						continue
				new_node.set_property(current_line[property])
	save_game.close()
