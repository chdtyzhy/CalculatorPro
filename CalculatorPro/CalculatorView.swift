//
//  CalculatorView.swift
//  计算器主视图 - 参考 Calculator with History App 风格
//

import SwiftUI

/// 系统计算器布局：键盘按宽度铺满，显示区占剩余高度，底部适配安全区。
private enum CalculatorPadMetrics {
    static func compute(contentHeight: CGFloat, screenWidth: CGFloat) -> (display: CGFloat, button: CGFloat, rowSpacing: CGFloat, bottomPad: CGFloat) {
        let hPad: CGFloat = 16
        // 底部留白：适配 home indicator 区域（约 34pt）+ 额外间距
        let bottomPad: CGFloat = 20
        
        let innerW = max(0, screenWidth - 2 * hPad)
        
        // 按键边长：优先按宽度四列等分
        let spacing: CGFloat = 12
        let buttonSize = max(1, floor((innerW - 3 * spacing) / 4))
        
        // 键盘总高 = 5行按键 + 4行间距
        let kbdH = 5 * buttonSize + 4 * spacing
        
        // 显示区 = 剩余高度（不少于 80，不超过 120）
        let displayH = min(120, max(80, contentHeight - bottomPad - kbdH))
        
        return (displayH, buttonSize, spacing, bottomPad)
    }
}

struct CalculatorView: View {
    @StateObject private var calculator = CalculatorModel()
    
    var body: some View {
        GeometryReader { geometry in
            let safeTop = geometry.safeAreaInsets.top
            let safeBottom = geometry.safeAreaInsets.bottom
            /// 使用 GeometryReader 的全高，内容通过 ignoresSafeArea + 手动 padding 控制
            let hPad: CGFloat = 16
            
            let layout = CalculatorPadMetrics.compute(
                contentHeight: geometry.size.height - safeTop - safeBottom,
                screenWidth: geometry.size.width
            )
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 显示区：占剩余空间，数字贴底
                    DisplayView(calculator: calculator, layoutHeight: layout.display)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, hPad)
                    
                    // 键盘区：明确高度避免裁切，贴底
                    ButtonPadView(calculator: calculator, buttonSize: layout.button, rowSpacing: layout.rowSpacing)
                        .frame(height: 5 * layout.button + 4 * layout.rowSpacing)
                        .padding(.horizontal, hPad)
                        .padding(.bottom, max(safeBottom, 20))
                }
                .padding(.top, safeTop)
            }
        }
        .sheet(isPresented: $calculator.showHistory) {
            HistoryView(calculator: calculator)
        }
    }
}

private enum CalcColors {
    /// 顶栏与首行功能键：浅灰
    static let lightGrayFill = Color(white: 0.52)
    /// 数字区：深灰
    static let darkNumericFill = Color(white: 0.22)
    /// 系统计算器风格橙
    static let operatorOrange = Color(red: 1, green: 0.58, blue: 0.12)
}

// MARK: - 显示区域
struct DisplayView: View {
    @ObservedObject var calculator: CalculatorModel
    /// 分配到的显示区高度，用于主数字字号与竖直留白
    var layoutHeight: CGFloat = 100
    
    /// 根据显示内容长度动态调整字号：长数字用小字号
    private var mainDigitSize: CGFloat {
        let baseSize = min(70, max(44, layoutHeight * 0.45))
        let count = calculator.display.count
        if count > 12 {
            return baseSize * 0.72
        } else if count > 9 {
            return baseSize * 0.82
        }
        return baseSize
    }
    
    var body: some View {
        Group {
            if calculator.previousDisplay.isEmpty {
                Text(calculator.display)
                    .font(.system(size: mainDigitSize, weight: .light))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            } else {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(calculator.previousDisplay)
                        .font(.system(size: min(20, layoutHeight * 0.22)))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Spacer(minLength: 0)
                    Text(calculator.display)
                        .font(.system(size: mainDigitSize, weight: .light))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(.vertical, 8)
        .contextMenu {
            Button("历史记录") { calculator.showHistory = true }
        }
    }
}

// MARK: - 按钮区域
struct ButtonPadView: View {
    @ObservedObject var calculator: CalculatorModel
    /// 优先按屏幕宽度铺满四列；与 `rowSpacing` 一起由外层算出
    let buttonSize: CGFloat
    var rowSpacing: CGFloat = 10
    
    var body: some View {
        let gap = rowSpacing
        VStack(spacing: gap) {
            // 第1行: C / +/- / % / ÷（与系统计算器一致）
            HStack(spacing: gap) {
                LightGrayTextButton("C", buttonSize) { calculator.clear() }
                LightGrayTextButton("+/-", buttonSize) { calculator.toggleSign() }
                LightGrayTextButton("%", buttonSize) { calculator.percentage() }
                OperatorButton("÷", buttonSize) { calculator.setOperation(.divide) }
            }
            
            HStack(spacing: gap) {
                NumericButton("7", buttonSize) { calculator.inputDigit("7") }
                NumericButton("8", buttonSize) { calculator.inputDigit("8") }
                NumericButton("9", buttonSize) { calculator.inputDigit("9") }
                OperatorButton("×", buttonSize) { calculator.setOperation(.multiply) }
            }
            
            HStack(spacing: gap) {
                NumericButton("4", buttonSize) { calculator.inputDigit("4") }
                NumericButton("5", buttonSize) { calculator.inputDigit("5") }
                NumericButton("6", buttonSize) { calculator.inputDigit("6") }
                OperatorButton("−", buttonSize) { calculator.setOperation(.subtract) }
            }
            
            HStack(spacing: gap) {
                NumericButton("1", buttonSize) { calculator.inputDigit("1") }
                NumericButton("2", buttonSize) { calculator.inputDigit("2") }
                NumericButton("3", buttonSize) { calculator.inputDigit("3") }
                OperatorButton("+", buttonSize) { calculator.setOperation(.add) }
            }
            
            // 第5行: 0 占两格（胶囊）/ . / =（与系统计算器一致）
            HStack(spacing: gap) {
                WideZeroButton(width: buttonSize * 2 + gap, height: buttonSize) { calculator.inputDigit("0") }
                NumericButton(".", buttonSize) { calculator.inputDecimal() }
                OperatorButton("=", buttonSize) { calculator.calculate() }
            }
        }
    }
}

// MARK: - 宽「0」键（占两列，胶囊形）
private struct WideZeroButton: View {
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("0")
                .font(.system(size: height * 0.42, weight: .medium))
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .background(CalcColors.darkNumericFill)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 浅灰文字键（C、+/-、%）
private struct LightGrayTextButton: View {
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
                .font(.system(size: size * (title.count >= 2 ? 0.3 : 0.36), weight: .semibold))
                .foregroundColor(Color(white: 0.06))
                .frame(width: size, height: size)
                .background(CalcColors.lightGrayFill)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 深灰数字键（含 +/-、0、小数点）
private struct NumericButton: View {
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
                .font(.system(size: title == "+/-" ? size * 0.28 : size * 0.4, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(width: size, height: size)
                .background(CalcColors.darkNumericFill)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 运算符按钮（橙）
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
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(CalcColors.operatorOrange)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
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
