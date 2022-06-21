extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var dir = Vector3.ZERO
var destination = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translation += delta*500*dir
	if destination != null:
		if translation>destination:
			queue_free()
	else:
		if translation.length() > 9999:
			queue_free()
	pass
