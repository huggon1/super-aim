extends RefCounted


static func run() -> void:
	_test_session_finishes_after_duration()


static func _test_session_finishes_after_duration() -> void:
	var session := TrainingSession.new(1.0)
	session.start()
	session.tick(0.5)
	assert(session.is_running())

	session.tick(0.5)
	assert(session.state == TrainingSession.State.FINISHED)
	assert(session.get_remaining_seconds() == 0.0)
