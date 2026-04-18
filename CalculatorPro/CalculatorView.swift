//
//  CalculatorView.swift
//  计算器主视图 - 参考 Calculator with History App 风格
//

import SwiftUI

struct CalculatorView: View {
    @StateObject private var calculator = CalculatorModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 显示区域
                    DisplayView(calculator: calculator)
                        .frame(height: geometry.size.height * 0.28)
                        .padding(.horizontal, 20)
                    
                    // 按钮区域
                    ButtonPadView(calculator: calculator, size: geometry.size)
                        .padding(.horizontal, 16)
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 10)
                }
            }
        }
        .sheet(isPresented: $calculator.showHistory) {
            HistoryView(calculator: calculator)
        }
    }
}

// MARK: - 显示区域
struct DisplayView: View {
    @ObservedObject var calculator: CalculatorModel
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            // 历史记录预览（可选）
            if !calculator.previousDisplay.isEmpty {
                Text(calculator.previousDisplay)
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            
            Spacer()
            
            // 主显示
            Text(calculator.display)
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.2)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.vertical, 20)
    }
}

// MARK: - 按钮区域
struct ButtonPadView: View {
    @ObservedObject var calculator: CalculatorModel
    let size: CGSize
    
    var body: some View {
        let spacing: CGFloat = 12
        let columns: CGFloat = 4
        let padding: CGFloat = 16
        let availableWidth = size.width - padding * 2 - spacing * (columns - 1)
        let buttonSize = floor(availableWidth / columns)
        
        VStack(spacing: spacing) {
            // 第1行: C +/- % ÷
            HStack(spacing: spacing) {
                DarkFuncButton("C", buttonSize) { calculator.clear() }
                DarkFuncButton("+/-", buttonSize) { calculator.toggleSign() }
                DarkFuncButton("%", buttonSize) { calculator.percentage() }
                OperatorButton("÷", buttonSize) { calculator.setOperation(.divide) }
            }
            
            // 第2行: 7 8 9 ×
            HStack(spacing: spacing) {
                NumberButton("7", buttonSize) { calculator.inputDigit("7") }
                NumberButton("8", buttonSize) { calculator.inputDigit("8") }
                NumberButton("9", buttonSize) { calculator.inputDigit("9") }
                OperatorButton("×", buttonSize) { calculator.setOperation(.multiply) }
            }
            
            // 第3行: 4 5 6 −
            HStack(spacing: spacing) {
                NumberButton("4", buttonSize) { calculator.inputDigit("4") }
                NumberButton("5", buttonSize) { calculator.inputDigit("5") }
                NumberButton("6", buttonSize) { calculator.inputDigit("6") }
                OperatorButton("−", buttonSize) { calculator.setOperation(.subtract) }
            }
            
            // 第4行: 1 2 3 +
            HStack(spacing: spacing) {
                NumberButton("1", buttonSize) { calculator.inputDigit("1") }
                NumberButton("2", buttonSize) { calculator.inputDigit("2") }
                NumberButton("3", buttonSize) { calculator.inputDigit("3") }
                OperatorButton("+", buttonSize) { calculator.setOperation(.add) }
            }
            
            // 第5行: 0 . = (等号双倍高度)
            HStack(spacing: spacing) {
                NumberButton("0", buttonSize * 2 + spacing, buttonSize) { calculator.inputDigit("0") }
                NumberButton(".", buttonSize) { calculator.inputDecimal() }
                EqualsButton(buttonSize, buttonSize * 2 + spacing) { calculator.calculate() }
            }
        }
    }
}

// MARK: - 数字按钮 (白色背景)
struct NumberButton: View {
    let title: String
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void
    
    init(_ title: String, _ size: CGFloat, _ action: @escaping () -> Void) {
        self.title = title
        self.width = size
        self.height = size
        self.action = action
    }
    
    init(_ title: String, _ width: CGFloat, _ height: CGFloat, _ action: @escaping () -> Void) {
        self.title = title
        self.width = width
        self.height = height
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: min(width, height) * 0.4, weight: .medium))
                .frame(width: width, height: height)
                .background(Color.white)
                .foregroundColor(.black)
                .clipShape(Capsule())
        }
    }
}

// MARK: - 深色功能按钮 (C, +/-, %)
struct DarkFuncButton: View {
    let title: String
    let size: CGFloat
    let action: () -> Void
    
    init(_ title: String, _ size: CGFloat, _ action: @escaping () -> Void) {
        self.title = title
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: size * 0.35, weight: .medium))
                .frame(width: size, height: size)
                .background(Color(white: 0.25))
                .foregroundColor(.white)
                .clipShape(Circle())
        }
    }
}

// MARK: - 运算符按钮
struct OperatorButton: View {
    let title: String
    let size: CGFloat
    let action: () -> Void
    
    init(_ title: String, _ size: CGFloat, _ action: @escaping () -> Void) {
        self.title = title
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: size * 0.45, weight: .medium))
                .frame(width: size, height: size)
                .background(Color.orange)
                .foregroundColor(.white)
                .clipShape(Circle())
        }
    }
}

// MARK: - 等号按钮 (双倍高度)
struct EqualsButton: View {
    let height: CGFloat
    let action: () -> Void
    let width: CGFloat
    
    init(_ height: CGFloat, _ action: @escaping () -> Void) {
        self.height = height
        self.width = height
        self.action = action
    }
    
    init(_ width: CGFloat, _ height: CGFloat, _ action: @escaping () -> Void) {
        self.width = width
        self.height = height
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text("=")
                .font(.system(size: height * 0.4, weight: .medium))
                .frame(width: width, height: height)
                .background(Color.orange)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
}

// MARK: - 历史记录视图
struct HistoryView: View {
    @ObservedObject var calculator: CalculatorModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(calculator.history) { item in
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(item.expression)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        Text("= " + item.result)
                            .font(.system(size: 24, weight: .medium))
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.vertical, 4)
                }
                .onDelete(perform: calculator.deleteHistoryItem)
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("完成") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("清除") { calculator.clearHistory() }
                        .disabled(calculator.history.isEmpty)
                }
            }
        }
    }
}

#Preview {
    CalculatorView()
}
