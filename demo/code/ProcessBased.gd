extends Node2D

@export var tickMinTime: float = 0.1
@export var tickMaxTime: float = 5.0

var rng = RandomNumberGenerator.new()
var accumulator: float = 0.0
var sentinel: float = tickMaxTime

func init(_seed: int):
	rng.seed = _seed
	sentinel = rng.randf_range(tickMinTime, tickMaxTime)

func _process(delta: float) -> void:
	accumulator += delta
	if accumulator >= sentinel:
		accumulator = 0
		sentinel = rng.randf_range(tickMinTime, tickMaxTime)
