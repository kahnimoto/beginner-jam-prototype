extends Pickups


func _ready() -> void:
	$GPUParticles2D.show()


## Defines what happens when this specific type of Pickups is picked up
func pick_up() -> void:
	if GameManager.pickup_bridge():
		queue_free()
