//
//  HistoryView.swift
//  历史记录视图
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var calculator: Calculator
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if calculator.history.isEmpty {
                    emptyStateView
                } else {
                    historyListView
                }
            }
            .navigationTitle("计算历史")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
                
                if !calculator.history.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("清空") {
                            calculator.clearHistory()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    // MARK: - 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("暂无历史记录")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("开始计算后，你的计算历史会显示在这里")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - 历史记录列表
    private var historyListView: some View {
        List {
            ForEach(calculator.history) { item in
                HistoryRow(item: item)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // 点击历史记录可以快速使用
                        useHistoryItem(item)
                    }
            }
            .onDelete { indexSet in
                deleteHistoryItems(at: indexSet)
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - 历史记录行
    private struct HistoryRow: View {
        let item: HistoryItem
        
        private var formattedTime: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: item.timestamp)
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                // 表达式
                Text(item.expression)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.primary)
                
                HStack {
                    // 结果
                    Text(item.result)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    // 时间
                    Text(formattedTime)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - 操作方法
    private func useHistoryItem(_ item: HistoryItem) {
        // 这里可以添加逻辑，将历史记录的结果应用到当前计算
        // 例如：calculator.currentInput = item.result
        dismiss()
    }
    
    private func deleteHistoryItems(at offsets: IndexSet) {
        calculator.history.remove(atOffsets: offsets)
        calculator.saveHistory()
    }
}

// MARK: - 预览
struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let calculator = Calculator()
        
        // 添加一些测试数据
        calculator.history = [
            HistoryItem(expression: "123 + 456", result: "579"),
            HistoryItem(expression: "789 × 2", result: "1,578"),
            HistoryItem(expression: "100 ÷ 4", result: "25"),
            HistoryItem(expression: "50 - 25", result: "25"),
            HistoryItem(expression: "15 %", result: "0.15")
        ]
        
        return HistoryView(calculator: calculator)
    }
}