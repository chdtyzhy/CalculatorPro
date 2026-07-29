import SwiftUI

struct CalculationHistoryEntry: Codable, Identifiable, Equatable {
    static let presetCategories = ["房租", "餐饮", "购物", "交通", "水电", "工资"]

    let id: UUID
    let expression: String
    let result: String
    let createdAt: Date
    var category: String?

    init(
        id: UUID,
        expression: String,
        result: String,
        createdAt: Date,
        category: String? = nil
    ) {
        self.id = id
        self.expression = expression
        self.result = result
        self.createdAt = createdAt
        self.category = category
    }

    var copyText: String {
        let calculation = "\(expression) = \(result)"
        guard let category, !category.isEmpty else { return calculation }
        return "[\(category)] \(calculation)"
    }
}

// 计算器主视图模型
// 使用状态机和处理器模式重构，逻辑更清晰
class MainViewModel: ObservableObject {
    @Published var result: String = "0"
    @Published var previousResult: String = ""
    @Published var currentExpression: String = ""
    @Published var resultReady: Bool = false
    @Published private(set) var history: [CalculationHistoryEntry] = []

    var primaryDisplayText: String {
        let text = currentExpression.isEmpty ? result : currentExpression
        return formatForDisplay(text.isEmpty ? "0" : text)
    }

    var secondaryDisplayText: String {
        guard currentExpression.isEmpty else { return "" }
        return formatForDisplay(previousResult)
    }

    // 内部状态管理
    private var state = CalculatorState()
    private let userDefaults: UserDefaults
    private let historyKey: String
    private let maximumHistoryCount = 100

    init(
        userDefaults: UserDefaults = .standard,
        historyKey: String = "calculationHistory"
    ) {
        self.userDefaults = userDefaults
        self.historyKey = historyKey
        loadHistory()
    }

    // MARK: - 公共接口

    func performAction(for pad: DialPad) {
        let handler = createHandler(for: pad)
        let update = handler?.handle(state: &state)

        // 同步到 Published 属性
        syncToPublished(update: update)

        if (pad == .equal || pad == .percentage),
           let expression = update?.previousResult,
           !expression.isEmpty,
           let display = update?.display,
           !display.isEmpty {
            addHistory(expression: expression, result: display)
        }
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

    func reuse(_ entry: CalculationHistoryEntry) {
        state.prepareForNewCalculation()
        state.display = entry.result
        state.accumulator = Decimal(string: entry.result) ?? 0
        state.isReadyForInput = true
        result = entry.result
        previousResult = entry.expression
        currentExpression = ""
        resultReady = true
    }

    func deleteHistory(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        saveHistory()
    }

    func clearHistory() {
        history.removeAll()
        saveHistory()
    }

    func updateCategory(for entryID: UUID, category: String) {
        guard let index = history.firstIndex(where: { $0.id == entryID }) else { return }

        let trimmed = category.trimmingCharacters(in: .whitespacesAndNewlines)
        history[index].category = trimmed.isEmpty ? nil : String(trimmed.prefix(20))
        saveHistory()
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

    private func formatForDisplay(_ text: String) -> String {
        text
            .replacingOccurrences(of: "/", with: "÷")
            .replacingOccurrences(of: "*", with: "×")
            .replacingOccurrences(of: "-", with: "−")
    }

    private func addHistory(expression: String, result: String) {
        let entry = CalculationHistoryEntry(
            id: UUID(),
            expression: formatForDisplay(expression),
            result: formatForDisplay(result),
            createdAt: Date()
        )
        history.insert(entry, at: 0)
        if history.count > maximumHistoryCount {
            history.removeLast(history.count - maximumHistoryCount)
        }
        saveHistory()
    }

    private func loadHistory() {
        guard let data = userDefaults.data(forKey: historyKey),
              let entries = try? JSONDecoder().decode([CalculationHistoryEntry].self, from: data) else {
            return
        }
        history = entries
    }

    private func saveHistory() {
        if history.isEmpty {
            userDefaults.removeObject(forKey: historyKey)
        } else if let data = try? JSONEncoder().encode(history) {
            userDefaults.set(data, forKey: historyKey)
        }
    }
}
