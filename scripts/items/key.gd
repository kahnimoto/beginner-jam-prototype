extends Pickups


func _ready() -> void:
	$GPUParticles2D.show()


## Defines what happens when this specific type of Pickups is picked up
func pick_up() -> void:
	Events.key_picked_up.emit()
	queue_free()
