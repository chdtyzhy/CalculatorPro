import SwiftUI

struct FinancialPlanningView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.calculatorTheme) private var theme
    @StateObject private var viewModel = FinancialPlanningViewModel()
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Picker("测算模式", selection: $viewModel.mode) {
                        ForEach(FinancialPlanningViewModel.Mode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("financial-mode-picker")

                    if viewModel.mode == .fire {
                        fireContent
                            .accessibilityIdentifier("fire-planning-content")
                    } else {
                        runwayContent
                            .accessibilityIdentifier("runway-planning-content")
                    }

                    Text("仅供规划参考，不构成投资建议")
                        .font(.footnote)
                        .foregroundColor(theme.secondaryInk)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .frame(maxWidth: 560)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("财务测算")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成") { dismiss() }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("收起键盘") { isInputFocused = false }
                }
            }
        }
    }

    private var fireContent: some View {
        VStack(spacing: 16) {
            planningSection("基础情况") {
                amountField("税后年收入", text: $viewModel.annualIncome)
                amountField("当前月支出", text: $viewModel.currentMonthlyExpense)
                amountField("可投资资产", text: $viewModel.fireAssets)
                amountField("退休后月支出", text: $viewModel.retirementMonthlyExpense)
            }

            planningSection("时间与假设") {
                numberField("当前年龄", suffix: "岁", text: $viewModel.currentAge)
                numberField("预期寿命", suffix: "岁", text: $viewModel.lifeExpectancy)
                percentField("年化收益率", text: $viewModel.fireAnnualReturn)
                percentField("通胀率", text: $viewModel.fireInflation)
                percentField("工资增长率", text: $viewModel.salaryGrowth)
                percentField("安全提取率", text: $viewModel.safeWithdrawalRate)
            }

            resultSection(title: "FIRE 结果", status: viewModel.fireStatusText) {
                resultRow("目标资产", value: FinancialPlanningViewModel.currency(viewModel.fireResult.targetAssets))
                resultRow("6 个月应急基金", value: FinancialPlanningViewModel.currency(viewModel.fireResult.emergencyFund))
                resultRow("当前每月结余", value: FinancialPlanningViewModel.currency(viewModel.fireResult.monthlySurplus))
                resultRow("预计达成年数", value: reachYearsText)
                resultRow("预计退休年龄", value: retirementAgeText)
                resultRow("预计退休资产", value: FinancialPlanningViewModel.currency(viewModel.fireResult.projectedRetirementAssets))
                resultRow("每月安全提取额", value: FinancialPlanningViewModel.currency(viewModel.fireResult.monthlySafeWithdrawal))
            }
        }
    }

    private var runwayContent: some View {
        VStack(spacing: 16) {
            planningSection("资产续航输入") {
                amountField("可投资资产", text: $viewModel.runwayAssets)
                amountField("月支出", text: $viewModel.runwayMonthlyExpense)
                amountField("月被动收入", text: $viewModel.passiveMonthlyIncome)
                percentField("年化收益率", text: $viewModel.runwayAnnualReturn)
                percentField("通胀率", text: $viewModel.runwayInflation)
            }

            resultSection(title: "续航结果", status: viewModel.runwayStatusText) {
                if case .depleted(let months) = viewModel.runwayResult {
                    resultRow("可续航月数", value: "\(months) 个月")
                    resultRow("可续航年数", value: "\(FinancialPlanningViewModel.yearsString(months)) 年")
                } else {
                    resultRow("资产状态", value: viewModel.runwayStatusText)
                }
            }
        }
    }

    private var reachYearsText: String {
        guard let months = viewModel.fireResult.monthsToReach else { return "—" }
        return "\(FinancialPlanningViewModel.yearsString(months)) 年"
    }

    private var retirementAgeText: String {
        guard let age = viewModel.fireResult.retirementAge else { return "—" }
        let value = NSDecimalNumber(decimal: age).doubleValue
        return String(format: "%.1f 岁", value)
    }

    private func amountField(_ title: String, text: Binding<String>) -> some View {
        inputField(title, prefix: "¥", suffix: nil, text: text, keyboard: .decimalPad)
    }

    private func percentField(_ title: String, text: Binding<String>) -> some View {
        inputField(title, prefix: nil, suffix: "%", text: text, keyboard: .numbersAndPunctuation)
    }

    private func numberField(_ title: String, suffix: String, text: Binding<String>) -> some View {
        inputField(title, prefix: nil, suffix: suffix, text: text, keyboard: .numberPad)
    }

    private func inputField(
        _ title: String,
        prefix: String?,
        suffix: String?,
        text: Binding<String>,
        keyboard: UIKeyboardType
    ) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .foregroundColor(theme.primaryInk)
            Spacer(minLength: 12)
            if let prefix {
                Text(prefix).foregroundColor(theme.secondaryInk)
            }
            TextField(title, text: text)
                .keyboardType(keyboard)
                .multilineTextAlignment(.trailing)
                .focused($isInputFocused)
                .frame(minWidth: 86, maxWidth: 150)
                .accessibilityLabel(title)
            if let suffix {
                Text(suffix).foregroundColor(theme.secondaryInk)
            }
        }
        .font(.system(size: 16, design: .rounded))
        .frame(minHeight: 44)
    }

    private func planningSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.headline)
                .foregroundColor(theme.primaryInk)
                .padding(.bottom, 4)
            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(theme.numberKey)
        )
    }

    private func resultSection<Content: View>(
        title: String,
        status: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(theme.primaryInk)
            Text(status)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(theme.equalKey)
                .accessibilityIdentifier("financial-result-status")
            Divider()
            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(theme.numberKey)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(theme.equalKey.opacity(0.25), lineWidth: 1)
                )
        )
    }

    private func resultRow(_ title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .foregroundColor(theme.secondaryInk)
            Spacer(minLength: 12)
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(theme.primaryInk)
                .multilineTextAlignment(.trailing)
        }
        .font(.system(size: 15, design: .rounded))
    }
}
