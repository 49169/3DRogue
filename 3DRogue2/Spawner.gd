extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var npc = preload("res://EnemyAsset/NPC.tscn")
onready var exploNPC = preload("res://EnemyAsset/ExploNPC.tscn")

onready var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if$Timer.time_left <= 0:
		
		for i in 5:
			var dir = Vector3(rng.randf_range(-1,1),0,rng.randf_range(-1,1))
			var dir2 = Vector3(rng.randf_range(-0.5,0.5),0,rng.randf_range(-0.5,0.5))
			var newNPC
			if rand_range(0,1) > 0.5:
				newNPC = npc.instance()
			else:
				newNPC = exploNPC.instance()
			add_child(newNPC)
			
			newNPC.translation = Global.playerPos + (dir+dir2) *rand_range(40,45)
			
		$Timer.start(8)
	pass
