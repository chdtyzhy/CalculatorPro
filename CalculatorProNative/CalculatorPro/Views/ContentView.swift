//
//  ContentView.swift
//  CalculatorPro
//
//  Created by Your Name on 2026/03/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var calculatorManager: CalculatorManager
    
    @State private var selectedTab = 0
    @State private var displayValue = "0"
    @State private var previousValue: String? = nil
    @State private var currentOperator: String? = nil
    @State private var isShowingSettings = false
    
    // 屏幕适配器
    private let screenAdapter = ScreenAdapter.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 计算器标签
            CalculatorView(
                displayValue: $displayValue,
                previousValue: $previousValue,
                currentOperator: $currentOperator
            )
            .tabItem {
                Label("计算器", systemImage: "function")
            }
            .tag(0)
            
            // 历史记录标签
            HistoryView()
                .tabItem {
                    Label("历史", systemImage: "clock.arrow.circlepath")
                }
                .tag(1)
            
            // 设置标签
            SettingsView(isShowingSettings: $isShowingSettings)
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
                .tag(2)
        }
        .accentColor(.blue)
        .adaptiveFont(size: 16)  // 自适应字体
        .onChange(of: selectedTab) { oldValue, newValue in
            // 标签切换时的处理
            handleTabChange(from: oldValue, to: newValue)
        }
    }
    
    private func handleTabChange(from oldTab: Int, to newTab: Int) {
        // 可以在这里添加标签切换的逻辑
        // 例如：保存当前状态、更新UI等
    }
}

// MARK: - 计算器视图
struct CalculatorView: View {
    @EnvironmentObject private var calculatorManager: CalculatorManager
    @EnvironmentObject private var themeManager: ThemeManager
    
    @Binding var displayValue: String
    @Binding var previousValue: String?
    @Binding var currentOperator: String?
    
    @State private var isScientificPanelExpanded = false
    @State private var isShowingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 显示区域
                    DisplayView(
                        value: displayValue,
                        previousValue: previousValue,
                        currentOperator: currentOperator
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // 模式指示器
                    ModeIndicatorView()
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    
                    // 科学计算面板 (如果启用)
                    if calculatorManager.currentMode == .scientific && isScientificPanelExpanded {
                        ScientificPanelView(
                            onFunctionSelected: handleScientificFunction
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // 按钮网格
                    CalculatorButtonsView(
                        onNumberPressed: handleNumberPress,
                        onOperatorPressed: handleOperatorPress,
                        onFunctionPressed: handleFunctionPress,
                        onEqualsPressed: handleEqualsPress,
                        onClearPressed: handleClearPress
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Calculator Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: toggleScientificPanel) {
                        Image(systemName: isScientificPanelExpanded ? "chevron.up" : "function")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .disabled(calculatorManager.currentMode != .scientific)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(CalculatorManager.CalculatorMode.allCases, id: \.self) { mode in
                            Button(action: { calculatorManager.currentMode = mode }) {
                                Label(mode.rawValue, systemImage: mode == calculatorManager.currentMode ? "checkmark" : "")
                            }
                        }
                    } label: {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 18, weight: .medium))
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .alert("计算错误", isPresented: $isShowingError) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - 按钮处理函数
    
    private func handleNumberPress(_ number: String) {
        if displayValue == "0" || displayValue == "错误" {
            displayValue = number
        } else {
            displayValue += number
        }
    }
    
    private func handleOperatorPress(_ operatorSymbol: String) {
        previousValue = displayValue
        currentOperator = operatorSymbol
        displayValue = "0"
    }
    
    private func handleFunctionPress(_ function: String) {
        switch function {
        case "C":
            handleClearPress()
        case "+/-":
            if let value = Double(displayValue) {
                displayValue = String(-value)
            }
        case "%":
            if let value = Double(displayValue) {
                displayValue = String(value / 100)
            }
        default:
            break
        }
    }
    
    private func handleScientificFunction(_ function: String) {
        guard let value = Double(displayValue) else {
            showError("无效的输入值")
            return
        }
        
        do {
            let result: Double
            
            switch function {
            case "sin":
                result = calculatorManager.scientificEngine.sin(value, angleMode: calculatorManager.angleMode)
            case "cos":
                result = calculatorManager.scientificEngine.cos(value, angleMode: calculatorManager.angleMode)
            case "tan":
                result = calculatorManager.scientificEngine.tan(value, angleMode: calculatorManager.angleMode)
            case "log":
                result = calculatorManager.scientificEngine.log10(value)
            case "ln":
                result = calculatorManager.scientificEngine.ln(value)
            case "√":
                result = calculatorManager.scientificEngine.sqrt(value)
            case "x²":
                result = calculatorManager.scientificEngine.power(value, exponent: 2)
            case "π":
                result = .pi
                displayValue = String(result)
                return
            case "e":
                result = .e
                displayValue = String(result)
                return
            default:
                showError("未实现的函数: \(function)")
                return
            }
            
            displayValue = formatResult(result)
            
        } catch {
            showError(error.localizedDescription)
        }
    }
    
    private func handleEqualsPress() {
        guard let prevValue = previousValue,
              let prevDouble = Double(prevValue),
              let currentDouble = Double(displayValue),
              let operatorSymbol = currentOperator else {
            return
        }
        
        do {
            let result: Double
            
            switch operatorSymbol {
            case "+":
                result = calculatorManager.calculatorCore.add(prevDouble, currentDouble)
            case "-":
                result = calculatorManager.calculatorCore.subtract(prevDouble, currentDouble)
            case "×":
                result = calculatorManager.calculatorCore.multiply(prevDouble, currentDouble)
            case "÷":
                result = try calculatorManager.calculatorCore.divide(prevDouble, currentDouble)
            default:
                showError("未知的操作符")
                return
            }
            
            displayValue = formatResult(result)
            previousValue = nil
            currentOperator = nil
            
        } catch {
            showError(error.localizedDescription)
        }
    }
    
    private func handleClearPress() {
        displayValue = "0"
        previousValue = nil
        currentOperator = nil
    }
    
    private func toggleScientificPanel() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isScientificPanelExpanded.toggle()
        }
    }
    
    private func formatResult(_ value: Double) -> String {
        if value.isNaN || value.isInfinite {
            return "错误"
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = calculatorManager.decimalPlaces
        formatter.minimumFractionDigits = 0
        formatter.groupingSeparator = ""
        
        if let formatted = formatter.string(from: NSNumber(value: value)) {
            return formatted
        }
        
        // 如果格式化失败，使用科学计数法
        return String(format: "%.\(min(calculatorManager.decimalPlaces, 10))e", value)
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        isShowingError = true
        displayValue = "错误"
    }
}

// MARK: - 显示视图
struct DisplayView: View {
    let value: String
    let previousValue: String?
    let currentOperator: String?
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            if let previous = previousValue, let op = currentOperator {
                Text("\(previous) \(op)")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            
            Text(value)
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
                .padding(.vertical, 4)
        }
    }
}

// MARK: - 模式指示器
struct ModeIndicatorView: View {
    @EnvironmentObject private var calculatorManager: CalculatorManager
    
    var body: some View {
        HStack {
            Text(calculatorManager.currentMode.rawValue)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            if calculatorManager.currentMode == .scientific {
                Text("•")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(calculatorManager.angleMode.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(ThemeManager())
        .environmentObject(CalculatorManager())
}