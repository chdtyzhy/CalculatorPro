import Foundation

// MARK: - 按钮处理器协议

protocol ButtonHandler {
    func handle(state: inout CalculatorState) -> CalculatorUpdate?
}

// 更新类型：用于通知视图需要更新的字段
struct CalculatorUpdate: Equatable {
    var display: String?
    var expression: String?
    var previousResult: String?
    var isReadyForInput: Bool?

    static let none = CalculatorUpdate()
}

// MARK: - 数字处理器

struct DigitHandler: ButtonHandler {
    let digit: String

    func handle(state: inout CalculatorState) -> CalculatorUpdate? {
        // 如果显示未定义，重新开始
        if state.isUndefined {
            state.prepareForNewCalculation()
        }

        // 如果已完成计算且没有待执行运算，重新开始
        if state.isReadyForInput && state.pendingOp == .unknown {
            state.prepareForNewCalculation()
        } else if state.isReadyForInput {
            // 刚输入运算符，清空当前显示
            state.display = ""
            state.isReadyForInput = false
        }

        let digitCount = state.display.filter(\.isNumber).count
        guard digitCount < state.maxDigits else { return nil }

        let wasEmpty = state.display.isEmpty

        // 处理各种输入情况
        if state.display == "0" && digit != "0" {
            state.display = digit
        } else if state.display == "0" && digit == "0" {
            return nil // 忽略重复的0
        } else if state.display == "-0" && digit != "0" {
            state.display = "-" + digit
        } else if state.display == "-0" && digit == "0" {
            return nil // 忽略重复的-0
        } else {
            state.display += digit
        }

        // 更新表达式
        if !state.expression.isEmpty {
            if wasEmpty || state.display == digit {
                // 新操作数的第一个数字，追加完整显示值
                state.expression += state.display
            } else if state.display.hasPrefix("-") {
                // 负数情况（从 -0 变成 -数字），替换表达式中的 -0
                if state.expression.hasSuffix("-0") {
                    state.expression.removeLast(2)
                    state.expression += state.display
                } else {
                    state.expression += digit
                }
            } else {
                // 继续输入，只追加数字
                state.expression += digit
            }
        }

        return CalculatorUpdate(
            display: state.display,
            expression: state.expression,
            isReadyForInput: state.isReadyForInput
        )
    }
}

// MARK: - 小数点处理器

struct DecimalHandler: ButtonHandler {
    func handle(state: inout CalculatorState) -> CalculatorUpdate? {
        // 如果显示未定义，重新开始
        if state.isUndefined {
            state.prepareForNewCalculation()
        }

        let wasReady = state.isReadyForInput

        if state.isReadyForInput && state.pendingOp == .unknown {
            // 开始新计算
            state.prepareForNewCalculation()
            state.display = "0"
            state.isReadyForInput = false
        } else if state.isReadyForInput {
            // 运算符后的小数
            state.display = "0"
            state.isReadyForInput = false
        }

        // 如果已经有小数点，忽略
        guard !state.display.contains(".") else { return nil }

        state.display += "."

        // 更新表达式
        if !state.expression.isEmpty {
            if wasReady {
                // 新操作数的第一个小数点，追加完整值
                state.expression += state.display
            } else {
                // 继续输入，只追加小数点
                state.expression += "."
            }
        }

        return CalculatorUpdate(display: state.display, expression: state.expression)
    }
}

// MARK: - 正负号处理器

struct PlusMinusHandler: ButtonHandler {
    func handle(state: inout CalculatorState) -> CalculatorUpdate? {
        guard !state.isUndefined else { return nil }

        let oldDisplay = state.display
        let wasReady = state.isReadyForInput

        if wasReady && state.pendingOp == .unknown {
            state.clearRepeatedOperation()
        }

        // 切换正负号
        if wasReady && state.pendingOp != .unknown {
            state.display = "-0"
        } else if state.display == "0" || state.display.isEmpty {
            state.display = "-0"
        } else if state.display == "-0" {
            state.display = "0"
        } else if state.isNegative {
            state.display.removeFirst()
        } else {
            state.display = "-" + state.display
        }

        // 更新表达式
        if !state.expression.isEmpty {
            if wasReady {
                // 刚输入运算符后的第一个 +/-，追加完整值
                state.expression += state.display
            } else if !oldDisplay.isEmpty && state.expression.hasSuffix(oldDisplay) {
                // 替换表达式末尾的旧值
                state.expression.removeLast(oldDisplay.count)
                state.expression += state.display
            }
        }

        state.isReadyForInput = false

        return CalculatorUpdate(
            display: state.display,
            expression: state.expression,
            isReadyForInput: state.isReadyForInput
        )
    }
}

// MARK: - 运算符处理器

struct OperatorHandler: ButtonHandler {
    let operation: Operation

    func handle(state: inout CalculatorState) -> CalculatorUpdate? {
        guard !state.display.isEmpty else { return nil }
        guard !state.isUndefined else { return nil }

        let opSymbol = symbol(for: operation)

        // 连续点击运算符时只替换待执行运算，不使用占位显示值 0 参与计算。
        if state.isReadyForInput && state.pendingOp != .unknown {
            state.pendingOp = operation
            if !state.expression.isEmpty {
                state.expression.removeLast()
                state.expression += opSymbol
            } else {
                state.expression = state.accumulator.clean(places: 6) + opSymbol
            }
            return CalculatorUpdate(expression: state.expression)
        }

        // 计算结果虽然只显示 6 位小数，但继续运算时应保留内部精度。
        let currentValue = state.isReadyForInput ? state.accumulator : state.numericValue

        // 如果有待执行的运算，先计算
        if state.pendingOp != .unknown {
            guard let result = calculate(state: &state) else {
                return nil // 除以零等情况
            }
            state.accumulator = result
        } else {
            state.accumulator = currentValue
        }

        // 保留用户输入的完整算式；内部仍按从左到右的顺序计算。
        if state.expression.isEmpty {
            state.expression = state.display + opSymbol
        } else {
            state.expression += opSymbol
        }

        state.pendingOp = operation
        state.prepareForOperandInput()

        return CalculatorUpdate(
            display: state.display,
            expression: state.expression,
            isReadyForInput: state.isReadyForInput
        )
    }

    private func symbol(for op: Operation) -> String {
        switch op {
        case .plus: return "+"
        case .minus: return "−"
        case .multiply: return "×"
        case .divide: return "÷"
        case .modulo: return "%"
        default: return ""
        }
    }

    private func calculate(state: inout CalculatorState) -> Decimal? {
        let currentValue = state.numericValue
        var result: Decimal = 0

        switch state.pendingOp {
        case .plus:
            result = state.accumulator + currentValue
        case .minus:
            result = state.accumulator - currentValue
        case .multiply:
            result = state.accumulator * currentValue
        case .divide:
            if currentValue == 0 {
                state.setUndefined()
                return nil
            }
            result = state.accumulator / currentValue
        case .modulo:
            if currentValue == 0 {
                state.setUndefined()
                return nil
            }
            let remainder = NSDecimalNumber(decimal: state.accumulator).doubleValue
                .truncatingRemainder(
                    dividingBy: NSDecimalNumber(decimal: currentValue).doubleValue
                )
            result = Decimal(remainder)
        default:
            result = currentValue
        }

        if result.isNaN {
            state.setUndefined()
            return nil
        }

        state.display = result.clean(places: 6)
        return result
    }
}

// MARK: - 减号处理器（区分负号和减运算符）

struct SubtractHandler: ButtonHandler {
    func handle(state: inout CalculatorState) -> CalculatorUpdate? {
        // 判断是作为负号还是减运算符
        let canBeNegativeSign =
            (state.pendingOp == .unknown && state.isEmptyOrZero) ||
            (state.pendingOp != .unknown && state.isReadyForInput)

        if canBeNegativeSign {
            // 作为负号处理
            let wasReady = state.isReadyForInput
            state.display = "-0"
            state.isReadyForInput = false

            // 更新表达式（如果是刚输入运算符后的负号）
            if wasReady && !state.expression.isEmpty {
                state.expression += state.display
            }

            return CalculatorUpdate(
                display: state.display,
                expression: state.expression,
                isReadyForInput: state.isReadyForInput
            )
        } else {
            // 作为减运算符处理
            return OperatorHandler(operation: .minus).handle(state: &state)
        }
    }
}

// MARK: - 等号处理器

struct EqualHandler: ButtonHandler {
    func handle(state: inout CalculatorState) -> CalculatorUpdate? {
        guard !state.display.isEmpty else { return nil }

        let isRepeatedEqual = state.pendingOp == .unknown &&
            state.isReadyForInput &&
            state.repeatedOp != .unknown &&
            state.repeatedOperand != nil
        let operation = isRepeatedEqual ? state.repeatedOp : state.pendingOp
        let usesAccumulatorAsOperand = state.isReadyForInput && state.pendingOp != .unknown
        let currentValue: Decimal

        if isRepeatedEqual {
            currentValue = state.repeatedOperand!
        } else if usesAccumulatorAsOperand {
            currentValue = state.accumulator
        } else {
            currentValue = state.numericValue
        }

        var result: Decimal = 0

        switch operation {
        case .plus:
            result = state.accumulator + currentValue
        case .minus:
            result = state.accumulator - currentValue
        case .multiply:
            result = state.accumulator * currentValue
        case .divide:
            if currentValue == 0 {
                state.setUndefined()
                return CalculatorUpdate(display: state.display, expression: state.expression)
            }
            result = state.accumulator / currentValue
        case .modulo:
            if currentValue == 0 {
                state.setUndefined()
                return CalculatorUpdate(display: state.display, expression: state.expression)
            }
            let remainder = NSDecimalNumber(decimal: state.accumulator).doubleValue
                .truncatingRemainder(
                    dividingBy: NSDecimalNumber(decimal: currentValue).doubleValue
                )
            result = Decimal(remainder)
        default:
            result = currentValue
        }

        if result.isNaN {
            state.setUndefined()
            return CalculatorUpdate(display: state.display, expression: state.expression)
        }

        let operandDisplay = usesAccumulatorAsOperand
            ? currentValue.clean(places: 6)
            : state.display
        if isRepeatedEqual {
            state.previousResult = state.display + symbol(for: operation) + currentValue.clean(places: 6)
        } else {
            state.previousResult = state.expression.hasSuffix(operandDisplay)
                ? state.expression
                : state.expression + operandDisplay
        }

        if operation != .unknown {
            state.repeatedOp = operation
            state.repeatedOperand = currentValue
        }

        state.display = result.clean(places: 6)
        state.expression = ""
        state.accumulator = result
        state.pendingOp = .unknown
        state.isReadyForInput = true

        return CalculatorUpdate(
            display: state.display,
            expression: state.expression,
            previousResult: state.previousResult,
            isReadyForInput: state.isReadyForInput
        )
    }

    private func symbol(for operation: Operation) -> String {
        switch operation {
        case .plus: return "+"
        case .minus: return "−"
        case .multiply: return "×"
        case .divide: return "÷"
        case .modulo: return "%"
        default: return ""
        }
    }
}

// MARK: - 百分比处理器

struct PercentageHandler: ButtonHandler {
    func handle(state: inout CalculatorState) -> CalculatorUpdate? {
        guard !state.display.isEmpty else { return nil }
        guard !state.isUndefined else { return nil }

        // 仅运算符后的等待态缺少右操作数；已完成计算时应继续使用当前结果。
        let isWaitingForOperand = state.isReadyForInput && state.pendingOp != .unknown
        let currentValue: Decimal = isWaitingForOperand ? 0 : state.numericValue
        var result: Decimal = 0

        switch state.pendingOp {
        case .plus:
            result = state.accumulator + (state.accumulator * currentValue / 100)
        case .minus:
            result = state.accumulator - (state.accumulator * currentValue / 100)
        case .multiply:
            result = state.accumulator * (currentValue / 100)
        case .divide:
            if currentValue == 0 {
                state.setUndefined()
                return CalculatorUpdate(display: state.display, expression: state.expression)
            }
            result = state.accumulator / (currentValue / 100)
        default:
            result = currentValue / 100
        }

        if result.isNaN {
            state.setUndefined()
            return CalculatorUpdate(display: state.display, expression: state.expression)
        }

        let operandDisplay = state.isReadyForInput
            ? currentValue.clean(places: 6)
            : state.display
        state.previousResult = state.expression.hasSuffix(operandDisplay)
            ? state.expression + "%"
            : state.expression + operandDisplay + "%"
        state.display = result.clean(places: 6)
        state.expression = ""
        state.accumulator = result
        state.pendingOp = .unknown
        state.isReadyForInput = true
        state.clearRepeatedOperation()

        return CalculatorUpdate(
            display: state.display,
            expression: state.expression,
            previousResult: state.previousResult,
            isReadyForInput: state.isReadyForInput
        )
    }
}

// MARK: - 清除处理器

struct ClearHandler: ButtonHandler {
    func handle(state: inout CalculatorState) -> CalculatorUpdate? {
        state.reset()
        return CalculatorUpdate(
            display: state.display,
            expression: state.expression,
            previousResult: state.previousResult,
            isReadyForInput: state.isReadyForInput
        )
    }
}

// MARK: - 退格处理器

struct RevertHandler: ButtonHandler {
    func handle(state: inout CalculatorState) -> CalculatorUpdate? {
        if state.isUndefined {
            state.display = "0"
            return CalculatorUpdate(display: state.display)
        }

        // 等待新操作数时退格不应删除保留的左操作数或表达式中的运算符。
        guard !state.isReadyForInput else { return nil }
        guard !state.display.isEmpty else { return nil }

        let oldDisplay = state.display
        state.display.removeLast()

        // 如果只剩负号或为空，重置为0
        if state.display == "-" || state.display.isEmpty {
            state.display = "0"
        }

        // 用完整操作数替换表达式尾部，避免负号与显示值失去同步。
        if !state.expression.isEmpty && state.expression.hasSuffix(oldDisplay) {
            state.expression.removeLast(oldDisplay.count)
            if state.display != "0" {
                state.expression += state.display
            }
        }

        return CalculatorUpdate(display: state.display, expression: state.expression)
    }
}
