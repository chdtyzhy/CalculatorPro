import SwiftUI

enum Tool: String, Identifiable, CaseIterable {
    case financialPlanning

    var id: String { rawValue }

    var title: String {
        switch self {
        case .financialPlanning: return "财务自由计算器"
        }
    }

    var subtitle: String {
        switch self {
        case .financialPlanning: return "FIRE 与资产续航测算"
        }
    }

    var icon: String {
        switch self {
        case .financialPlanning: return "chart.line.uptrend.xyaxis"
        }
    }
}

struct ToolsMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.calculatorTheme) private var theme
    @State private var selectedTool: Tool?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Tool.allCases) { tool in
                        Button {
                            selectedTool = tool
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: tool.icon)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(theme.equalKey)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(theme.numberKey)
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(tool.title)
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(theme.primaryInk)

                                    Text(tool.subtitle)
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(theme.secondaryInk)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(theme.secondaryInk)
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 64)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                        .adaptiveGlassSurface(tint: theme.numberKey)
                        .accessibilityLabel(tool.title)
                        .accessibilityIdentifier("tool-row-\(tool.rawValue)")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("工具")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成") { dismiss() }
                }
            }
            .sheet(item: $selectedTool) { tool in
                switch tool {
                case .financialPlanning:
                    FinancialPlanningView()
                }
            }
        }
    }
}
