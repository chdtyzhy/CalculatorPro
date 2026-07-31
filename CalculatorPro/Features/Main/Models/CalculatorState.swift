import Foundation

// 计算器状态管理结构体
// 集中管理所有计算状态，减少分散判断
struct CalculatorState {
    var display: String = "0"           // 当前显示值
    var expression: String = ""         // 表达式显示
    var accumulator: Decimal = 0        // 累加器（上一个操作数）
    var pendingOp: Operation = .unknown // 待执行的运算符
    var isReadyForInput: Bool = false   // 是否等待新输入（刚输入运算符）
    var previousResult: String = ""     // 上一次结果（顶部显示）
    var repeatedOp: Operation = .unknown
    var repeatedOperand: Decimal?

    let maxDigits = 10

    // MARK: - 状态查询

    var isUndefined: Bool {
        display == "未定义"
    }

    var isEmptyOrZero: Bool {
        display == "0" || display.isEmpty || display == "-0"
    }

    var isNegative: Bool {
        display.hasPrefix("-")
    }

    var numericValue: Decimal {
        Decimal(string: display) ?? 0
    }

    func expressionOperand(for value: String) -> String {
        guard value.hasPrefix("-") else { return value }
        return value == "-0" ? "(-" : "(\(value))"
    }

    @discardableResult
    mutating func replaceTrailingExpressionOperand(
        from oldValue: String,
        with newValue: String?
    ) -> Bool {
        let oldOperand = expressionOperand(for: oldValue)
        guard !oldOperand.isEmpty, expression.hasSuffix(oldOperand) else {
            return false
        }

        expression.removeLast(oldOperand.count)
        if let newValue {
            expression += expressionOperand(for: newValue)
        }
        return true
    }

    // MARK: - 状态操作

    mutating func setUndefined() {
        display = "未定义"
        expression = ""
        pendingOp = .unknown
        accumulator = 0
        isReadyForInput = true
        clearRepeatedOperation()
    }

    mutating func reset() {
        display = ""
        expression = ""
        previousResult = ""
        accumulator = 0
        pendingOp = .unknown
        isReadyForInput = false
        clearRepeatedOperation()
    }

    mutating func prepareForNewCalculation() {
        display = ""
        expression = ""
        previousResult = ""
        accumulator = 0
        pendingOp = .unknown
        isReadyForInput = false
        clearRepeatedOperation()
    }

    mutating func prepareForOperandInput() {
        isReadyForInput = true
    }

    mutating func clearRepeatedOperation() {
        repeatedOp = .unknown
        repeatedOperand = nil
    }
}
