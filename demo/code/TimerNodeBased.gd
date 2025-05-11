extends Node2D

@export var tickMinTime: float = 0.1
@export var tickMaxTime: float = 5.0

var rng = RandomNumberGenerator.new()
var timer: Timer

func init(_seed: int):
	rng.seed = _seed
	timer = Timer.new()
	add_child(timer)
	run_timer()

func run_timer():
	timer.start(rng.randf_range(tickMinTime, tickMaxTime))
	await timer.timeout
	run_timer()