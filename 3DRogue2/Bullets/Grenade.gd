extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var destination = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if destination != null:
		translation = translation.move_toward(destination, 40*delta)
		if (translation - destination).length() <= 1:
			$Area.visible = true
			for child in $Area.get_overlapping_bodies():
				if child.is_in_group("enemy"):
					child.hit(10, "default")
			queue_free()
	pass
