extends Node

signal register(requester, event, timeData)
signal unregister(requester, event)
signal register_continous(requester, event, timeData)
signal unregister_continous(requester, event)

var runTick: bool = false
var runContinous: bool = false
var collection: Dictionary = {}
var continousCollection: Dictionary = {}
var collectionKeys: Array = []
var continousCollectionKeys: Array = []

func _ready():
	register.connect(handle_register)
	unregister.connect(handle_unregister)
	register_continous.connect(handle_register_continous)
	unregister_continous.connect(handle_unregister_continous)

func handle_register(requester, event: StringName, timeData: Array):
	if collection.has(requester):
		if collection[requester].has(event):
			print("duplicate")
		else:
			collection[requester][event] = timeData
	else:
		collection[requester] = {event: timeData}
	__update_collection_keys()

func handle_unregister(requester, event):
	if collection.has(requester):
		if collection[requester].has(event):
			collection[requester].erase(event)

	if collection[requester].is_empty():
		collection.erase(requester)
	__update_collection_keys()

func __update_collection_keys():
	collectionKeys = collection.keys()
	if collection.is_empty():
		runTick = false
	else:
		runTick = true

func handle_register_continous(requester, event: StringName, timeData: Array):
	if continousCollection.has(requester):
		if continousCollection[requester].has(event):
			print("duplicate continous TickEvent")
		else:
			continousCollection[requester][event] = timeData
	else:
		continousCollection[requester] = {event: timeData}
	__update_continous_collection_keys()

func handle_unregister_continous(requester, event: StringName):
	if continousCollection.has(requester):
		if continousCollection[requester].has(event):
			continousCollection[requester].erase(event)
		if collection[requester].is_empty():
			collection.erase(requester)
	__update_continous_collection_keys()


func __update_continous_collection_keys():
	continousCollectionKeys = continousCollection.keys()
	if continousCollection.is_empty():
		runContinous = false
	else:
		runContinous = true

func _physics_process(delta: float):
	if runTick:
		check_collection(delta)
	if runContinous:
		check_continous(delta)

func check_collection(delta: float):
	for requester in collectionKeys:
		var requesterData = collection[requester]
		var eventKeys = requesterData.keys()
		for event in eventKeys:
			var timeData = requesterData[event]
			timeData[0] += delta
			if timeData[0] >= timeData[1]:
				if is_instance_valid(requester):
					requester.tick_over(event)
					requesterData.erase(event)
					if requesterData.is_empty():
						collection.erase(requester)
						__update_collection_keys()

func check_continous(delta: float):
	for requester in continousCollectionKeys:
		var requesterData = continousCollection[requester]
		var eventKeys = requesterData.keys()
		for event in eventKeys:
			var timeData = requesterData[event]
			timeData[0] += delta
			if timeData[0] >= timeData[1]:
				timeData[0] = 0
				if is_instance_valid(requester):
					requester.tick_over(event)
