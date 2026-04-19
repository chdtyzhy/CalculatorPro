#!/usr/bin/swift

import Foundation

// 模拟修复后的计算器核心计算逻辑

extension Double {
    func clean(places: Int) -> String {
        if self.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", self)
        }
        let format = "%." + String(places) + "f"
        var formatted = String(format: format, self)
        while formatted.hasSuffix("0") {
            formatted.removeLast()
        }
        if formatted.hasSuffix(".") {
            formatted.removeLast()
        }
        return formatted
    }
}

// 顺序计算模式（与系统计算器一致）
class Calculator {
    var result = ""
    var previousValue: Double = 0
    var pendingOperation: String = ""
    var resultReady = false
    
    func tap(_ key: String) {
        switch key {
        case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".":
            if resultReady && pendingOperation.isEmpty {
                result = ""
                previousValue = 0
                resultReady = false
            } else if resultReady {
                result = ""
                resultReady = false
            }
            
            if result == "0" && key != "." && key != "0" {
                result = key
            } else if result == "0" && key == "0" {
                return
            } else {
                result += key
            }
            
        case "+", "-", "*", "/":
            guard !result.isEmpty else { return }
            let currentValue = Double(result) ?? 0
            
            if !pendingOperation.isEmpty {
                calculate()
                previousValue = Double(result) ?? 0
            } else {
                previousValue = currentValue
            }
            
            pendingOperation = key
            resultReady = true
            
        case "%":
            guard !result.isEmpty else { return }
            let currentValue = Double(result) ?? 0
            var computedValue: Double = 0
            
            switch pendingOperation {
            case "+":
                computedValue = previousValue + (previousValue * currentValue / 100)
            case "-":
                computedValue = previousValue - (previousValue * currentValue / 100)
            case "*":
                computedValue = previousValue * (currentValue / 100)
            case "/":
                computedValue = previousValue / (currentValue / 100)
            default:
                computedValue = currentValue / 100
            }
            
            result = computedValue.clean(places: 6)
            previousValue = computedValue
            pendingOperation = ""
            resultReady = true
            
        case "=":
            calculate()
            
        case "AC":
            result = ""
            previousValue = 0
            pendingOperation = ""
            resultReady = false
            
        default:
            break
        }
    }
    
    func calculate() {
        guard !result.isEmpty && !pendingOperation.isEmpty else { return }
        
        let currentValue = Double(result) ?? 0
        var computedValue: Double = 0
        
        switch pendingOperation {
        case "+":
            computedValue = previousValue + currentValue
        case "-":
            computedValue = previousValue - currentValue
        case "*":
            computedValue = previousValue * currentValue
        case "/":
            computedValue = previousValue / currentValue
        default:
            computedValue = currentValue
        }
        
        result = computedValue.clean(places: 6)
        previousValue = computedValue
        pendingOperation = ""
        resultReady = true
    }
}

// 测试用例
print("========== 修复后计算器功能测试 ==========\n")

// 顺序输入模拟
func runTest(_ sequence: [String], expected: String, desc: String) -> String {
    let calc = Calculator()
    for key in sequence {
        calc.tap(key)
    }
    let result = calc.result
    let match = result == expected ? "✓" : "✗"
    print("\(desc)")
    print("  输入: \(sequence.joined())")
    print("  预期: \(expected), 实际: \(result) \(match)")
    return result
}

print("【基础运算测试】\n")
runTest(["9", "/", "8", "="], expected: "1.125", desc: "9 ÷ 8")
runTest(["7", "*", "8", "="], expected: "56", desc: "7 × 8")
runTest(["15", "-", "7", "="], expected: "8", desc: "15 − 7")
runTest(["23", "+", "45", "="], expected: "68", desc: "23 + 45")

print("\n【浮点数运算测试】\n")
runTest(["1", "/", "3", "="], expected: "0.333333", desc: "1 ÷ 3")
runTest(["0", ".", "1", "+", "0", ".", "2", "="], expected: "0.3", desc: "0.1 + 0.2")
runTest(["2", ".", "5", "*", "4", "="], expected: "10", desc: "2.5 × 4")

print("\n【连续运算测试 - 顺序计算】\n")
runTest(["5", "+", "3", "*", "2", "="], expected: "16", desc: "5 + 3 × 2 (顺序: (5+3)×2=16)")
runTest(["100", "/", "10", "/", "2", "="], expected: "5", desc: "100 ÷ 10 ÷ 2")
runTest(["10", "-", "5", "+", "3", "="], expected: "8", desc: "10 − 5 + 3")

print("\n【百分比测试 - 修复后】\n")
runTest(["50", "%"], expected: "0.5", desc: "50% (直接除以100)")
runTest(["100", "+", "10", "%"], expected: "110", desc: "100 + 10% = 100 + 10 = 110")
runTest(["100", "-", "10", "%"], expected: "90", desc: "100 − 10% = 100 − 10 = 90")
runTest(["100", "*", "10", "%"], expected: "10", desc: "100 × 10% = 100 × 0.1 = 10")
runTest(["100", "/", "10", "%"], expected: "1000", desc: "100 ÷ 10% = 100 ÷ 0.1 = 1000")

print("\n【边界条件测试】\n")
runTest(["0", "/", "5", "="], expected: "0", desc: "0 ÷ 5")
runTest(["9", "9", "9", "9", "9", "9", "+", "1", "="], expected: "1000000", desc: "999999 + 1")

print("\n========== 测试完成 ==========")
print("\n【修复内容】")
print("1. 改为顺序计算模式（与系统计算器一致）")
print("2. 百分比功能实现系统计算器逻辑")
