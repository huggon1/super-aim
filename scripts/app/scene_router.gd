class_name SceneRouter
extends RefCounted


static func replace_child(parent: Node, current_child: Node, next_child: Node) -> Node:
	if current_child != null and is_instance_valid(current_child):
		parent.remove_child(current_child)
		current_child.queue_free()

	parent.add_child(next_child)
	return next_child
