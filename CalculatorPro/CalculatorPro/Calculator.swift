//
//  Calculator Models
//  计算器数据模型
//

import Foundation

// MARK: - 计算操作枚举
enum CalculatorOperation: String, CaseIterable {
    case add = "+"
    case subtract = "−"
    case multiply = "×"
    case divide = "÷"
    case percent = "%"
    case equals = "="
    
    var displaySymbol: String {
        return self.rawValue
    }
}

// MARK: - 历史记录项
struct HistoryItem: Identifiable, Codable {
    let id: UUID
    let expression: String
    let result: String
    let timestamp: Date
    
    init(expression: String, result: String) {
        self.id = UUID()
        self.expression = expression
        self.result = result
        self.timestamp = Date()
    }
    
    var displayText: String {
        return "\(expression) = \(result)"
    }
}

// MARK: - 计算器状态
class Calculator: ObservableObject {
    @Published var currentInput: String = "0"
    @Published var previousInput: String = ""
    @Published var operation: CalculatorOperation?
    @Published var history: [HistoryItem] = []
    @Published var shouldResetInput: Bool = false
    
    private var storedValue: Double = 0
    
    // 初始化
    init() {
        loadHistory()
    }
    
    // MARK: - 输入处理
    func inputDigit(_ digit: String) {
        if currentInput == "0" || shouldResetInput {
            currentInput = digit
            shouldResetInput = false
        } else {
            currentInput += digit
        }
    }
    
    func inputDecimal() {
        if !currentInput.contains(".") {
            currentInput += "."
        }
    }
    
    func toggleSign() {
        if let value = Double(currentInput) {
            currentInput = String(value * -1)
        }
    }
    
    func inputPercent() {
        if let value = Double(currentInput) {
            currentInput = String(value / 100)
        }
    }
    
    // MARK: - 操作处理
    func setOperation(_ newOperation: CalculatorOperation) {
        if let currentValue = Double(currentInput) {
            if operation == nil {
                storedValue = currentValue
            } else {
                performCalculation()
            }
            
            previousInput = currentInput
            operation = newOperation
            shouldResetInput = true
        }
    }
    
    func performCalculation() {
        guard let operation = operation,
              let currentValue = Double(currentInput),
              let previousValue = Double(previousInput) else {
            return
        }
        
        var result: Double = 0
        
        switch operation {
        case .add:
            result = storedValue + currentValue
        case .subtract:
            result = storedValue - currentValue
        case .multiply:
            result = storedValue * currentValue
        case .divide:
            result = currentValue != 0 ? storedValue / currentValue : 0
        case .percent:
            result = storedValue * (currentValue / 100)
        case .equals:
            // 等号操作已经在其他逻辑中处理
            return
        }
        
        // 创建历史记录
        let expression = "\(formatNumber(storedValue)) \(operation.displaySymbol) \(formatNumber(currentValue))"
        let resultString = formatNumber(result)
        
        let historyItem = HistoryItem(expression: expression, result: resultString)
        history.insert(historyItem, at: 0)
        saveHistory()
        
        // 更新显示
        currentInput = resultString
        storedValue = result
        self.operation = nil
        shouldResetInput = true
    }
    
    func clear() {
        currentInput = "0"
        previousInput = ""
        operation = nil
        storedValue = 0
        shouldResetInput = false
    }
    
    func clearEntry() {
        currentInput = "0"
    }
    
    func deleteLast() {
        if currentInput.count > 1 {
            currentInput = String(currentInput.dropLast())
        } else {
            currentInput = "0"
        }
    }
    
    // MARK: - 历史记录管理
    private func saveHistory() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(history)
            UserDefaults.standard.set(data, forKey: "calculatorHistory")
        } catch {
            print("保存历史记录失败: \(error)")
        }
    }
    
    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: "calculatorHistory") else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            history = try decoder.decode([HistoryItem].self, from: data)
        } catch {
            print("加载历史记录失败: \(error)")
        }
    }
    
    func clearHistory() {
        history.removeAll()
        UserDefaults.standard.removeObject(forKey: "calculatorHistory")
    }
    
    // MARK: - 工具函数
    private func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 10
        formatter.minimumFractionDigits = 0
        formatter.groupingSeparator = ""
        
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}