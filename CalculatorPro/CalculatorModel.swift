//
//  CalculatorModel.swift
//  计算器模型
//

import Foundation
import Combine

enum CalculatorOperation: String {
    case add = "+"
    case subtract = "−"
    case multiply = "×"
    case divide = "÷"
    case percent = "%"
}

struct CalculationHistory: Identifiable {
    let id = UUID()
    let expression: String
    let result: String
    let timestamp: Date
}

class CalculatorModel: ObservableObject {
    @Published var display: String = "0"
    @Published var previousDisplay: String = ""
    @Published var operation: CalculatorOperation?
    @Published var history: [CalculationHistory] = []
    @Published var showHistory: Bool = false
    
    private var firstNumber: Double = 0
    private var isTypingNumber = false
    private var shouldClearDisplay = false
    
    // MARK: - 数字输入
    func inputDigit(_ digit: String) {
        if shouldClearDisplay || display == "0" {
            display = digit
            shouldClearDisplay = false
            isTypingNumber = true
        } else {
            display += digit
            isTypingNumber = true
        }
    }
    
    // MARK: - 小数点
    func inputDecimal() {
        if shouldClearDisplay {
            display = "0."
            shouldClearDisplay = false
        } else if !display.contains(".") {
            display += "."
        }
    }
    
    // MARK: - 清除
    func clear() {
        display = "0"
        previousDisplay = ""
        operation = nil
        firstNumber = 0
        isTypingNumber = false
        shouldClearDisplay = false
    }
    
    // MARK: - 退格
    func backspace() {
        if display.count > 1 {
            display.removeLast()
        } else {
            display = "0"
        }
    }
    
    // MARK: - 正负切换
    func toggleSign() {
        if let value = Double(display) {
            let newValue = -value
            display = formatNumber(newValue)
        }
    }
    
    // MARK: - 百分比
    func percentage() {
        if let value = Double(display) {
            let result = value / 100
            display = formatNumber(result)
        }
    }
    
    // MARK: - 设置操作
    func setOperation(_ op: CalculatorOperation) {
        if Double(display) != nil {
            if operation != nil && isTypingNumber {
                calculate()
            }
            firstNumber = Double(display) ?? 0
            operation = op
            previousDisplay = display + " " + op.rawValue
            shouldClearDisplay = true
            isTypingNumber = false
        }
    }
    
    // MARK: - 计算
    func calculate() {
        guard let op = operation,
              let secondNumber = Double(display) else {
            return
        }
        
        let expression = "\(formatNumber(firstNumber)) \(op.rawValue) \(formatNumber(secondNumber))"
        var result: Double = 0
        
        switch op {
        case .add:
            result = firstNumber + secondNumber
        case .subtract:
            result = firstNumber - secondNumber
        case .multiply:
            result = firstNumber * secondNumber
        case .divide:
            result = secondNumber != 0 ? firstNumber / secondNumber : .nan
        case .percent:
            result = firstNumber * secondNumber / 100
        }
        
        if result.isNaN || result.isInfinite {
            display = "错误"
        } else {
            display = formatNumber(result)
            let historyItem = CalculationHistory(
                expression: expression,
                result: display,
                timestamp: Date()
            )
            history.insert(historyItem, at: 0)
        }
        
        firstNumber = result
        operation = nil
        previousDisplay = ""
        shouldClearDisplay = true
        isTypingNumber = false
    }
    
    // MARK: - 格式化数字
    private func formatNumber(_ number: Double) -> String {
        if number == floor(number) && abs(number) < 1e15 {
            return String(format: "%.0f", number)
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 10
            formatter.minimumFractionDigits = 0
            formatter.groupingSeparator = ","
            return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
        }
    }
    
    // MARK: - 删除历史记录
    func clearHistory() {
        history.removeAll()
    }
    
    func deleteHistoryItem(at indexSet: IndexSet) {
        history.remove(atOffsets: indexSet)
    }
}
