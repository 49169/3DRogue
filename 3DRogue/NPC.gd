extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var health = 10
onready var redMat = preload("res://RedMat.tres")
onready var defaultMat = preload("res://DefaultMat.tres")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if $Timer.time_left >0:
		$MeshInstance.set_material_override(redMat)
	else:
		$MeshInstance.set_material_override(defaultMat)
		
	var dir = (Global.playerPos - translation).normalized()
	move_and_slide(dir*2)
	
	pass

func hit(amt):
	health -= amt
	$Timer.start(0.1)
	if health <= 0:
		queue_free()


	
