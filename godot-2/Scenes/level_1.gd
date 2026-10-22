extends Node2D

@export var spawnPoint : Vector2 = Vector2(42,67)
@onready var player : CharacterBody2D = $CharacterBody2D

@onready var timer_label: Label=$UI/TimerLabel
@onready var resultLabel: Label=$UI/PanelContainer/Results
@onready var resultContainer: PanelContainer=$UI/PanelContainer

@export var levelNumber: int = 1
var elapsed_time: float = 0.0
var timer_running: bool = false
var levelFinished: bool = true



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for spike in $Spikes.get_children():
		if spike is Area2D:
			spike.body_entered.connect(_on_spike_body_entered)
	resultContainer.visible=false
	_start_timer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer_running:
		elapsed_time+=delta
		_update_timer_label()

func _update_timer_label():
	timer_label.text="%.2f Sec" % elapsed_time

func _start_timer() ->void:
	elapsed_time=0.0
	timer_running = true
	levelFinished=false
	_update_timer_label()

func _on_spike_body_entered(body:Node2D)->void:
	if body==player:
		player.global_position = spawnPoint
		player.velocity = Vector2.ZERO

func _on_next_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_2.tscn")


func _on_finish_body_entered(body: Node2D) -> void:
	if body != player or levelFinished:
		return
	
	levelFinished=true
	timer_running=false
	
	resultLabel.text="Level %d Finished! \n Süre %.2f sn" % [levelNumber,elapsed_time]
	resultContainer.visible = true
