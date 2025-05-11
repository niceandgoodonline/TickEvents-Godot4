extends Node

@export_group("Tick")
@export var tickScene: PackedScene
@export var tickSceneInstances: int = 2000

@export_group("Timer")
@export var testTimer: bool = false
@export var timerScene: PackedScene
@export var timerSceneInstances: int = 2000

@export_group("Process")
@export var testProcess: bool = false
@export var processScene: PackedScene
@export var processSceneInstances: int = 2000

var rng = RandomNumberGenerator.new()
var max_int = 9223372036854775807

func _ready():
	rng.seed = ResourceUID.create_id()
	var packedScene = tickScene
	var instanceCount = tickSceneInstances

	if testTimer:
		packedScene = timerScene
		instanceCount = timerSceneInstances

	if testProcess:
		packedScene = processScene
		instanceCount =	processSceneInstances

	for n in range(instanceCount):
		var instance = packedScene.instantiate()
		add_child(instance)
		instance.init(rng.randi_range(0, max_int))