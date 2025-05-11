# TickEvents-Godot4
Data Oriented system to delay code execution in GDscript

# Motivation
Often when developing any interactive software there is a need to delay code by an arbitrary amount of time. 

Godot offers a specialized Timer node for this function. There is also the "Accumulator" pattern, which is available to any program/language with a loop. These are the two alternative strategies I tested against.

I created this (naive/proof-of-concept) alternative solution to fit my development preferences and to perform better than the built-in solution.

NOTE: Unity ex-pats have created multiple Coroutine addons for C#. As this is a GD-Script solution, I didn't benchmark against any of the Coroutine addons. Additionally a C# implementation of TickEvents would likely be 
more performant than this GD-Script implementation. 

# Highlevel Overview
Tick Events is a data-oriented Accumulator. 

It uses a Singleton as to be available to any object, which I'll refer to as a "Requester". The events emitted pass an `Object` reference, a `StringName`, and a bespoke `Array[float]` where index 0 is the accumlator and index 1 is the timeout. The `Object` reference is often `self`, but it can be anything which implements a `tick_over(key: StringName)` function.

The Singleton stores all Tick Events in a `Dictionary{Object}`, with the Object being the Requester of a Tick Event that was passed as a reference. When a new Tick Event is registered the Singleton checks if it is a duplicate event. Requesters can have as many Tick Event requests as they need, but only 1 per `StringName`.

Every loop the Singleton iterates Tick Events and adds delta to each accumulator. When a Tick Event's accumulator is greater than or equal to the timeout, the Singleton checks if the Requester still exists. If it does it invokes `tick_over(key: StringName)` on the Requester and removes the Tick Event associated with the `key: StringName` from the Requester's data structure. If the Requester has no Tick Events, then it is removed from the `Dictionary{Object}`. If the `Dictionary{Object}` has no Requesters then it will not attempt to iterate on future loops until it does have Objects with Tick Events.

The implementation of `tick_over(key: StringName)` is up to you, but I basically always use a `match` statement. If a Requester only has 1 type of Tick Event, you can forgo the `match` statement. 


# Recommended Usecase
While the tests/benchmarks used a large amount of nodes/timeouts/requesters, there are definitely solutions which will be a "better fit" given X workload and Y target hardware.

For most small-to-medium size games which are not rts/sim games, Tick Events is going to perform as well or better than Timers and per-script Accumulators. If you have (potentially) 100-10,000 timers/accumulators running in your game, Tick Events could benefit your projects performance.

For very very small games which have less than 50 Timers/Accumulators... Tick Events is unlikely to provide any notable performance benefit. If you prefer code to nodes, you may perfer using Tick Events over Timers.


# Test Environment
For comparing I used my relatively low power laptop, a Huawei Matebook MACH-WX M14 with these specs:

- Intel® Core™ i7-8550U 8th Gen Quad-core Processor 8M Cache, up to 4.00 GHz
- SATA SSD
- 16GB DD4

I used a lower-power device so performance could be affected with less total nodes.

I included one 10 second video of each solution with 16,000 nodes making "end-to-end" delayed code requests of a random length. Each node had it's own rng and seed, with a minimum delay of 0.1 seconds and a maximum delay of 5 seconds.

Before recording each video I let the solution run for 20-30 seconds.

To make the test "hostile" against Tick Events I made these choices:

- Accumulator is run in the process loop. This makes Accumulator look competitive. When Accumulator is run on physics the FPS drops to low single digits.
- The minimum delay and maximum delay are set at 0.1 and 5.0 seconds to make Timers look competitive. Timers struggle when many timeouts finish simultaneously e.g. when the minimum and maximum delays are close they perform poorly.
- Tick Event is run in the physics loop. This is because:
 		
 	1. This shows the limits of Tick Events with less nodes.
 	2. The physics loop is "tighter", so if you want your delayed code to resolve "better" with physics, its probably best to run it there.


# Benchmark Results
Raw data table:

| Metric | Accumulator  | Timer Node | Tick Event |
| ------------- | ------------- | ------------- | ------------- |
| FPS Avg | 18.5 | 37.5 | 56.9 |
| FPS Delta | 3 | 14 | 6 |
| Process Avg  | 75.9269 | 129.5431 | 25.2383 |
| Process Delta | 22.991 | 188.306 | 4.975 |
| Physics Avg  | 124.3 |  146.1 | 202.5 |
| Physics Delta | 108 | 104 | 218 |
| FPS Min | 17 | 31 | 54 |
| FPS Max | 20 | 45 | 60 |
| Process Min  | 65.962 | 28.439 | 22.693 |
| Process Max  | 88.953 | 216.745 | 27.668 |
| Physics Min  | 96 | 112 | 141 |
| Physics Max  | 204 | 216 | 359 |

Observations:
- Accumulation has very low FPS, but reasonable deltas. (expected, as it's constantly working across all nodes loops)
- Timer Node has decent FPS, but more extreme deltas. (i have no idea how the Timer Node works in C++ land)
- Tick Event has high FPS, but an extreme physics delta. (expected, as Tick Events was run in the physics loop)
