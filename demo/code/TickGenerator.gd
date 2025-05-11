extends Node2D

@export var tickMinTime: float = 0.1
@export var tickMaxTime: float = 5.0

var rng = RandomNumberGenerator.new()

func init(_seed: int):
	rng.seed = _seed

func reregister():
	TickEvents.register.emit(self, &"reregister", [0, rng.randf_range(tickMinTime, tickMaxTime)])

func tick_over(key: StringName):
	match key:
		&"reregister":
			reregister()