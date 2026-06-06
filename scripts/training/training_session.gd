class_name TrainingSession
extends RefCounted

signal finished

enum State {
	READY,
	RUNNING,
	FINISHED,
}

var duration_seconds := 60.0
var elapsed_seconds := 0.0
var state := State.READY


func _init(session_duration_seconds: float = 60.0) -> void:
	duration_seconds = session_duration_seconds


func start() -> void:
	elapsed_seconds = 0.0
	state = State.RUNNING


func tick(delta: float) -> void:
	if state != State.RUNNING:
		return

	elapsed_seconds = minf(duration_seconds, elapsed_seconds + delta)
	if elapsed_seconds >= duration_seconds:
		finish()


func finish() -> void:
	if state == State.FINISHED:
		return

	state = State.FINISHED
	finished.emit()


func is_running() -> bool:
	return state == State.RUNNING


func get_remaining_seconds() -> float:
	return maxf(0.0, duration_seconds - elapsed_seconds)
