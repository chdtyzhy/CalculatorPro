//
//  CalculatorView.swift
//  计算器主界面
//

import SwiftUI

struct CalculatorView: View {
    @StateObject private var calculator = Calculator()
    @State private var showingHistory = false
    
    // 按钮布局
    let buttons: [[CalculatorButton]] = [
        [.clear, .toggleSign, .percent, .divide],
        [.digit("7"), .digit("8"), .digit("9"), .multiply],
        [.digit("4"), .digit("5"), .digit("6"), .subtract],
        [.digit("1"), .digit("2"), .digit("3"), .add],
        [.digit("0"), .decimal, .equals]
    ]
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部显示区域
                displaySection
                
                // 历史记录按钮
                historyButtonSection
                
                // 按钮网格
                buttonsGrid
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView(calculator: calculator)
        }
    }
    
    // MARK: - 显示区域
    private var displaySection: some View {
        VStack(alignment: .trailing, spacing: 8) {
            // 历史表达式
            if !calculator.previousInput.isEmpty, let operation = calculator.operation {
                Text("\(calculator.previousInput) \(operation.displaySymbol)")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
            
            // 当前输入
            Text(calculator.currentInput)
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.top, 40)
        .background(Color(.secondarySystemBackground))
    }
    
    // MARK: - 历史记录按钮
    private var historyButtonSection: some View {
        HStack {
            Button(action: {
                showingHistory = true
            }) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("历史记录")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(20)
            }
            .padding(.leading)
            
            Spacer()
            
            if calculator.history.count > 0 {
                Button("清空历史") {
                    calculator.clearHistory()
                }
                .font(.system(size: 14))
                .foregroundColor(.red)
                .padding(.trailing)
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    // MARK: - 按钮网格
    private var buttonsGrid: some View {
        VStack(spacing: 12) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { button in
                        CalculatorButtonView(
                            button: button,
                            action: { handleButtonTap(button) }
                        )
                    }
                }
            }
        }
        .padding(12)
    }
    
    // MARK: - 按钮点击处理
    private func handleButtonTap(_ button: CalculatorButton) {
        switch button {
        case .digit(let digit):
            calculator.inputDigit(digit)
            
        case .decimal:
            calculator.inputDecimal()
            
        case .clear:
            calculator.clear()
            
        case .clearEntry:
            calculator.clearEntry()
            
        case .toggleSign:
            calculator.toggleSign()
            
        case .percent:
            calculator.inputPercent()
            
        case .add:
            calculator.setOperation(.add)
            
        case .subtract:
            calculator.setOperation(.subtract)
            
        case .multiply:
            calculator.setOperation(.multiply)
            
        case .divide:
            calculator.setOperation(.divide)
            
        case .equals:
            calculator.performCalculation()
            
        case .delete:
            calculator.deleteLast()
        }
    }
}

// MARK: - 计算器按钮类型
enum CalculatorButton: Hashable {
    case digit(String)
    case decimal
    case clear
    case clearEntry
    case toggleSign
    case percent
    case add
    case subtract
    case multiply
    case divide
    case equals
    case delete
    
    var title: String {
        switch self {
        case .digit(let digit): return digit
        case .decimal: return "."
        case .clear: return "C"
        case .clearEntry: return "CE"
        case .toggleSign: return "±"
        case .percent: return "%"
        case .add: return "+"
        case .subtract: return "−"
        case .multiply: return "×"
        case .divide: return "÷"
        case .equals: return "="
        case .delete: return "⌫"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .clear, .clearEntry, .toggleSign, .percent:
            return Color(.tertiarySystemFill)
        case .add, .subtract, .multiply, .divide, .equals:
            return .orange
        case .digit, .decimal:
            return Color(.secondarySystemFill)
        case .delete:
            return Color(.tertiarySystemFill)
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .add, .subtract, .multiply, .divide, .equals:
            return .white
        default:
            return .primary
        }
    }
    
    var isWide: Bool {
        if case .digit("0") = self {
            return true
        }
        return false
    }
}

// MARK: - 计算器按钮视图
struct CalculatorButtonView: View {
    let button: CalculatorButton
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(button.title)
                .font(.system(size: 32, weight: .medium))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(button.backgroundColor)
                .foregroundColor(button.foregroundColor)
                .cornerRadius(40)
        }
        .buttonStyle(CalculatorButtonStyle())
        .frame(maxWidth: button.isWide ? .infinity : nil)
        .aspectRatio(button.isWide ? 2.2 : 1, contentMode: .fit)
    }
}

// MARK: - 按钮样式
struct CalculatorButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - 预览
struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView()
            .preferredColorScheme(.dark)
    }
}