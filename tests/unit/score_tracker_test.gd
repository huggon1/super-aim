extends RefCounted


static func run() -> void:
	_test_zero_shots_accuracy()
	_test_hit_tracking()


static func _test_zero_shots_accuracy() -> void:
	var tracker := ScoreTracker.new()
	assert(tracker.get_accuracy_percent() == 0.0)
	assert(tracker.get_score() == 0)


static func _test_hit_tracking() -> void:
	var tracker := ScoreTracker.new()
	tracker.record_shot(true)
	tracker.record_shot(false)
	tracker.record_shot(true)

	assert(tracker.hits == 2)
	assert(tracker.shots == 3)
	assert(is_equal_approx(tracker.get_accuracy_percent(), 66.666667))
	assert(tracker.get_score() == 200)
