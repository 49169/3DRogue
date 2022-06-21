extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var dir = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#translation = look_at()
	translation += dir*50*delta
	look_at(translation + dir, Vector3.UP)
	pass



func _on_PiercingBullet_body_entered(body):
	if body.is_in_group("enemy"):
		body.hit(1)
	pass # Replace with function body.
