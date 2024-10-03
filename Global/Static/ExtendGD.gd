class_name ExtendGDScript


# 堆栈
class Stack:
	var _stack = []  # 使用数组来存储堆栈的元素
	var count:int:
		get:
			return _stack.size()
	# 将元素压入堆栈
	func push(element):
		_stack.append(element)

	# 从堆栈中弹出元素
	func pop():
		if not is_empty():
			return _stack.pop_back()
		else:
			return null  # 如果堆栈为空，则返回null
	
	# 查看堆栈顶部的元素
	func peek():
		if not is_empty():
			return _stack[_stack.size() - 1]
		else:
			return null

	# 检查堆栈是否为空
	func is_empty():
		return _stack.size() == 0

	# 获取堆栈的大小
	func size():
		return _stack.size()
	
	func stack_print():
		print(_stack)
	
	# 堆栈翻转
	static func ReversePathStack(rawStack:Stack)->Stack:
		var pathStackReversed:Stack = Stack.new()
		while rawStack.count != 0:
			pathStackReversed.push(rawStack.pop())
		return pathStackReversed
