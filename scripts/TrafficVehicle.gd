extends Node3D
class_name TrafficVehicle

@export var travel_speed := 6.0
@export var lane_direction := 1.0
@export var reset_z := -85.0
@export var end_z := 85.0

func _process(delta: float) -> void:
    position.z += travel_speed * lane_direction * delta
    if lane_direction > 0.0 and position.z > end_z:
        position.z = reset_z
    elif lane_direction < 0.0 and position.z < reset_z:
        position.z = end_z
