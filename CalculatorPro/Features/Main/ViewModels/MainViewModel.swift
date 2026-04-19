import SwiftUI

// 计算器主视图模型
class MainViewModel: ObservableObject {
    @Published var result = ""           // 显示结果
    @Published var resultReady = false   // 是否已完成计算
    @Published var previousValue: Double = 0  // 上一个操作数
    @Published var pendingOperation: Operation = .unknown  // 待执行的运算符

    let maxCalculatorLimit = 10

    // 执行计算（顺序计算模式，与系统计算器一致）
    func calculate() {
        guard !result.isEmpty else { return }
        
        let currentValue = Double(result) ?? 0
        var computedValue: Double = 0
        
        switch pendingOperation {
        case .plus:
            computedValue = previousValue + currentValue
        case .minus:
            computedValue = previousValue - currentValue
        case .multiply:
            computedValue = previousValue * currentValue
        case .divide:
            computedValue = previousValue / currentValue
        case .modulo:
            computedValue = previousValue.truncatingRemainder(dividingBy: currentValue)
        default:
            computedValue = currentValue
        }
        
        self.result = computedValue.clean(places: 6)
        self.previousValue = computedValue
        self.pendingOperation = .unknown
        self.resultReady = true
    }

    // 设置特殊操作（如正负切换）
    func set(operation: Operation) {
        switch operation {
        case .plusMinus:
            guard let input = Double(result) else { return }
            self.result = (-input).clean(places: 6)
            self.resultReady = true
        default:
            break
        }
    }

    // 添加运算符（顺序计算模式）
    func addOperation(operation: Operation) {
        guard !result.isEmpty else { return }
        
        let currentValue = Double(result) ?? 0
        
        // 如果有待执行的运算，先计算
        if pendingOperation != .unknown {
            calculate()
            previousValue = Double(result) ?? 0
        } else {
            previousValue = currentValue
        }
        
        pendingOperation = operation
        resultReady = true  // 标记等待下一个数字输入
    }

    // 执行百分比运算（系统计算器逻辑）
    func calculatePercentage() {
        guard !result.isEmpty else { return }
        
        let currentValue = Double(result) ?? 0
        var computedValue: Double = 0
        
        // 根据待执行的运算符，计算相对百分比
        switch pendingOperation {
        case .plus:
            // 100 + 10% = 100 + (100 × 0.1) = 110
            computedValue = previousValue + (previousValue * currentValue / 100)
        case .minus:
            // 100 - 10% = 100 - (100 × 0.1) = 90
            computedValue = previousValue - (previousValue * currentValue / 100)
        case .multiply:
            // 100 × 10% = 100 × 0.1 = 10
            computedValue = previousValue * (currentValue / 100)
        case .divide:
            // 100 ÷ 10% = 100 ÷ 0.1 = 1000
            computedValue = previousValue / (currentValue / 100)
        default:
            // 没有待执行运算，直接除以100
            computedValue = currentValue / 100
        }
        
        self.result = computedValue.clean(places: 6)
        self.previousValue = computedValue
        self.pendingOperation = .unknown
        self.resultReady = true
    }

    // 处理按钮点击
    func performAction(for pad: DialPad) {
        switch pad {
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            // 数字输入
            if resultReady && pendingOperation == .unknown {
                // 开始新计算
                self.result = ""
                self.previousValue = 0
                self.resultReady = false
            } else if resultReady {
                // 输入运算符后的新数字
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

        case .clear:
            reset()

        case .plusMinus:
            self.set(operation: .plusMinus)

        case .percentage:
            calculatePercentage()

        case .divide:
            self.addOperation(operation: .divide)

        case .multiply:
            self.addOperation(operation: .multiply)

        case .substract:
            self.addOperation(operation: .minus)

        case .plus:
            self.addOperation(operation: .plus)

        case .decimal:
            if resultReady && pendingOperation == .unknown {
                // 开始新计算
                self.result = "0"
                self.previousValue = 0
                self.resultReady = false
            } else if resultReady {
                // 运算符后的小数
                self.result = "0"
                self.resultReady = false
            }

            guard !result.contains(".") else { return }
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
        self.previousValue = 0
        self.pendingOperation = .unknown
        self.resultReady = false
    }
}
