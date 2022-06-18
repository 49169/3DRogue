extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var npc = preload("res://NPC.tscn")

var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if$Timer.time_left <= 0:
		var newNPC = npc.instance()
		add_child(newNPC)
		var dir = Vector3(rng.randf_range(-1,1),0,rng.randf_range(-1,1))
		newNPC.translation = Global.playerPos + dir*rand_range(20,30)
		$Timer.start(3)
	pass
