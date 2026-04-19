import SwiftUI

// 计算器主视图模型
class MainViewModel: ObservableObject {
    @Published var result = ""           // 显示结果
    @Published var resultReady = false   // 是否已完成计算

    let mathOperations = "+-*/%"
    var currentOperation: Operation = .unknown
    let maxCalculatorLimit = 10

    // 执行计算
    func calculate() {
        guard !result.isEmpty else { return }
        guard (!mathOperations.contains(result.suffix(1))) else { return }

        // 将表达式转换为浮点数运算格式
        var expression = result
            .replacingOccurrences(of: "/", with: "*1.0/")
        
        let exp: NSExpression = NSExpression(format: expression)
        guard let computedValue: Double = exp.expressionValue(with:nil, context: nil) as? Double else { return }

        self.result = computedValue.clean(places: 6)
        self.currentOperation = .unknown
        self.resultReady = true
    }

    // 设置特殊操作（如正负切换）
    func set(operation: Operation) {
        switch operation {
        case .plusMinus:
            guard let input = Double(result) else { return }
            self.result = (-input).clean(places: 6)
            self.currentOperation = .unknown
        default:
            break
        }
    }

    // 添加运算符
    func addOperation(operation: Operation) {
        guard !result.isEmpty || operation == .minus else { return }

        if (currentOperation != .unknown) {
            if mathOperations.contains(result.suffix(1)) {
                self.result.removeLast()
                result += operation.rawValue
                self.currentOperation = operation
                return
            }
            calculate()
        }

        result += operation.rawValue
        self.currentOperation = operation
    }

    // 处理按钮点击
    func performAction(for pad: DialPad) {
        switch pad {
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            // 数字输入
            if resultReady && currentOperation == .unknown {
                self.result = ""
                self.resultReady = false
            }

            guard result.count <= maxCalculatorLimit else { return }

            let digit = pad.rawValue
            if result == "0" && digit != "0" {
                self.result = digit
            } else if result == "0" && digit == "0" {
                return
            } else {
                self.result += digit
            }
            self.resultReady = false

        case .clear:
            reset()

        case .plusMinus:
            self.set(operation: .plusMinus)

        case .percentage:
            if let value = Double(result) {
                self.result = (value / 100).clean(places: 6)
                self.resultReady = true
            }

        case .divide:
            self.addOperation(operation: .divide)

        case .multiply:
            self.addOperation(operation: .multiply)

        case .substract:
            self.addOperation(operation: .minus)

        case .plus:
            self.addOperation(operation: .plus)

        case .decimal:
            if resultReady && currentOperation == .unknown {
                self.result = "0"
                self.resultReady = false
            }

            let currentNumber = result.split(whereSeparator: { "+-*/%".contains($0) }).last.map(String.init) ?? result
            guard !currentNumber.contains(".") else { return }
            self.result += pad.rawValue

        case .revert:
            if !result.isEmpty {
                result.removeLast()
                if result.isEmpty {
                    result = "0"
                }
            }

        case .equal:
            self.calculate()
        }
    }

    // 重置计算器
    func reset() {
        self.result = ""
        self.currentOperation = .unknown
        self.resultReady = false
    }
}
