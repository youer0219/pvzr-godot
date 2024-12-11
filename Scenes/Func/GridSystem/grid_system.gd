extends Node2D


## 作用：显示/不显示 不同形态的 网格

## 与建造系统：
## 为建造系统提供植物的鼠标落点
## 建造系统为其提供形态参考
var cell_size = Vector2i(16,16)
@onready var base_grid: BaseGrid = $BaseGrid

func _ready() -> void:
	#base_grid.color_type = BaseGrid.ColorType.BLACK
	pass

func _process(delta: float) -> void:
	base_grid.position = get_mouse_cell_center()

# 获取鼠标位置。得到鼠标对应cell的中心位置。
func get_mouse_cell_center():
	var mouse_pos = get_global_mouse_position()
	var mouse_cell = floor(mouse_pos / Vector2(cell_size))
	return get_cell_rect(mouse_cell).get_center()

# 返回对应单元格的矩形
func get_cell_rect(cell_pos:Vector2i) -> Rect2:
	return Rect2(cell_pos * cell_size,cell_size)
