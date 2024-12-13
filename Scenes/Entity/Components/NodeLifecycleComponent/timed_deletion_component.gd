extends Timer


@export var target_node:Node
@export var time:float = 10.0

enum WorkMode {AUTO,HAND}
@export var work_mode:WorkMode


func _ready() -> void:
	self.start(time)
	match work_mode:
		WorkMode.AUTO:
			assert(target_node,"target_node 不能为空")
			timeout.connect(
				func():
					target_node.call_deferred("queue_free")
			)
		WorkMode.HAND:
			pass
