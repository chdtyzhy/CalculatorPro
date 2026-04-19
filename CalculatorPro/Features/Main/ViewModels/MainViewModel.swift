import SwiftUI

// 计算器主视图模型
// 使用状态机和处理器模式重构，逻辑更清晰
class MainViewModel: ObservableObject {
    @Published var result: String = "0"
    @Published var previousResult: String = ""
    @Published var currentExpression: String = ""
    @Published var resultReady: Bool = false

    // 内部状态管理
    private var state = CalculatorState()

    // MARK: - 公共接口

    func performAction(for pad: DialPad) {
        let handler = createHandler(for: pad)
        let update = handler?.handle(state: &state)

        // 同步到 Published 属性
        syncToPublished(update: update)
    }

    func set(operation: Operation) {
        guard operation == .plusMinus else { return }

        let handler = PlusMinusHandler()
        let update = handler.handle(state: &state)
        syncToPublished(update: update)
    }

    func calculate() {
        let handler = EqualHandler()
        let update = handler.handle(state: &state)
        syncToPublished(update: update)
    }

    func reset() {
        let handler = ClearHandler()
        let update = handler.handle(state: &state)
        syncToPublished(update: update)
    }

    // MARK: - 私有方法

    private func createHandler(for pad: DialPad) -> ButtonHandler? {
        switch pad {
        case .zero: return DigitHandler(digit: "0")
        case .one: return DigitHandler(digit: "1")
        case .two: return DigitHandler(digit: "2")
        case .three: return DigitHandler(digit: "3")
        case .four: return DigitHandler(digit: "4")
        case .five: return DigitHandler(digit: "5")
        case .six: return DigitHandler(digit: "6")
        case .seven: return DigitHandler(digit: "7")
        case .eight: return DigitHandler(digit: "8")
        case .nine: return DigitHandler(digit: "9")
        case .decimal: return DecimalHandler()
        case .clear: return ClearHandler()
        case .plusMinus: return PlusMinusHandler()
        case .percentage: return PercentageHandler()
        case .divide: return OperatorHandler(operation: .divide)
        case .multiply: return OperatorHandler(operation: .multiply)
        case .substract: return SubtractHandler()
        case .plus: return OperatorHandler(operation: .plus)
        case .revert: return RevertHandler()
        case .equal: return EqualHandler()
        }
    }

    private func syncToPublished(update: CalculatorUpdate?) {
        guard let update = update else { return }

        if let display = update.display {
            self.result = display
            self.state.display = display
        }
        if let expression = update.expression {
            self.currentExpression = expression
            self.state.expression = expression
        }
        if let prevResult = update.previousResult {
            self.previousResult = prevResult
            self.state.previousResult = prevResult
        }
        if let ready = update.isReadyForInput {
            self.resultReady = ready
            self.state.isReadyForInput = ready
        }
    }
}
