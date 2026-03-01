extends Node

var audio_players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer

func _ready() -> void:
	add_to_group("sound_manager")

	# Create pool of audio players for sound effects
	for i in range(8):
		var player = AudioStreamPlayer.new()
		player.volume_db = -5
		add_child(player)
		audio_players.append(player)

	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -8
	add_child(music_player)

	# Start background music
	call_deferred("start_music")

func start_music() -> void:
	# Try to load the OGG music file
	if ResourceLoader.exists("res://background_music.ogg"):
		var music_stream = load("res://background_music.ogg")
		if music_stream:
			music_player.stream = music_stream
			music_player.play()
			return

	# Fallback to simple procedural music if file not found
	var fallback = generate_simple_music()
	if fallback:
		music_player.stream = fallback
		music_player.play()

func get_available_player() -> AudioStreamPlayer:
	for player in audio_players:
		if not player.playing:
			return player
	return audio_players[0]

func play_sound(sound_name: String) -> void:
	var player = get_available_player()
	var stream = generate_sound(sound_name)
	if stream:
		player.stream = stream
		player.play()

func generate_sound(sound_name: String) -> AudioStreamWAV:
	var sample_hz: float = 22050.0
	var samples: PackedByteArray = PackedByteArray()

	match sound_name:
		"shoot":
			samples = make_noise(0.06, sample_hz, 0.5)
		"jump":
			samples = make_beep(300, 500, 0.08, sample_hz, 0.4)
		"hurt":
			samples = make_beep(400, 150, 0.12, sample_hz, 0.5)
		"die":
			samples = make_beep(500, 80, 0.3, sample_hz, 0.5)
		"pickup":
			samples = make_beep(500, 900, 0.08, sample_hz, 0.3)
		"key":
			samples = make_beep(600, 900, 0.12, sample_hz, 0.35)
		"locker":
			samples = make_beep(200, 250, 0.1, sample_hz, 0.3)
		"enemy_shoot":
			samples = make_noise(0.05, sample_hz, 0.35)
		_:
			return null

	if samples.size() == 0:
		return null

	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = int(sample_hz)
	stream.stereo = false
	stream.data = samples

	return stream

func make_beep(start_freq: float, end_freq: float, duration: float, sample_hz: float, volume: float) -> PackedByteArray:
	var samples = PackedByteArray()
	var num_samples = int(sample_hz * duration)
	var phase: float = 0.0

	for i in range(num_samples):
		var t = float(i) / float(num_samples)
		var freq = start_freq + (end_freq - start_freq) * t
		var envelope = (1.0 - t) * (1.0 - t)

		phase += freq / sample_hz
		var value = sin(phase * TAU) * volume * envelope
		var byte_val = int(clamp((value + 1.0) * 127.5, 0, 255))
		samples.append(byte_val)

	return samples

func make_noise(duration: float, sample_hz: float, volume: float) -> PackedByteArray:
	var samples = PackedByteArray()
	var num_samples = int(sample_hz * duration)

	for i in range(num_samples):
		var t = float(i) / float(num_samples)
		var envelope = (1.0 - t) * (1.0 - t)
		var value = (randf() * 2.0 - 1.0) * volume * envelope
		var byte_val = int(clamp((value + 1.0) * 127.5, 0, 255))
		samples.append(byte_val)

	return samples

func generate_simple_music() -> AudioStreamWAV:
	# Simple fallback loop
	var sample_hz: float = 22050.0
	var duration: float = 4.0
	var num_samples: int = int(sample_hz * duration)
	var samples = PackedByteArray()

	for i in range(num_samples):
		var t = float(i) / sample_hz
		var value: float = 0.0

		# Simple bass drone
		value += sin(t * 55.0 * TAU) * 0.15
		value += sin(t * 110.0 * TAU) * 0.08

		var byte_val = int(clamp((value + 1.0) * 127.5, 0, 255))
		samples.append(byte_val)

	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = int(sample_hz)
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = num_samples
	stream.data = samples

	return stream
