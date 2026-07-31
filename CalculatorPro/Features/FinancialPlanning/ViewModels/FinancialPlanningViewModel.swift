import Combine
import Foundation

final class FinancialPlanningViewModel: ObservableObject {
    enum Mode: String, CaseIterable {
        case fire = "FIRE"
        case runway = "资产续航"
    }

    @Published var mode: Mode = .fire

    @Published var annualIncome: String { didSet { recalculateFIRE() } }
    @Published var currentMonthlyExpense: String { didSet { recalculateFIRE() } }
    @Published var fireAssets: String { didSet { recalculateFIRE() } }
    @Published var retirementMonthlyExpense: String { didSet { recalculateFIRE() } }
    @Published var currentAge: String { didSet { recalculateFIRE() } }
    @Published var lifeExpectancy: String { didSet { recalculateFIRE() } }
    @Published var fireAnnualReturn: String { didSet { recalculateFIRE() } }
    @Published var fireInflation: String { didSet { recalculateFIRE() } }
    @Published var salaryGrowth: String { didSet { recalculateFIRE() } }
    @Published var safeWithdrawalRate: String { didSet { recalculateFIRE() } }

    @Published var runwayAssets: String { didSet { recalculateRunway() } }
    @Published var runwayMonthlyExpense: String { didSet { recalculateRunway() } }
    @Published var passiveMonthlyIncome: String { didSet { recalculateRunway() } }
    @Published var runwayAnnualReturn: String { didSet { recalculateRunway() } }
    @Published var runwayInflation: String { didSet { recalculateRunway() } }

    @Published private(set) var fireResult: FIREResult
    @Published private(set) var runwayResult: RunwayResult

    let assumptionsVersion: String

    init(provider: FinancialAssumptionsProvider = BundledFinancialAssumptionsProvider()) {
        let defaults = provider.snapshot
        assumptionsVersion = defaults.version
        annualIncome = Self.inputString(defaults.annualAfterTaxIncome)
        currentMonthlyExpense = Self.inputString(defaults.currentMonthlyExpense)
        fireAssets = Self.inputString(defaults.investableAssets)
        retirementMonthlyExpense = Self.inputString(defaults.retirementMonthlyExpense)
        currentAge = String(defaults.currentAge)
        lifeExpectancy = String(defaults.lifeExpectancy)
        fireAnnualReturn = Self.percentInputString(defaults.annualReturnRate)
        fireInflation = Self.percentInputString(defaults.inflationRate)
        salaryGrowth = Self.percentInputString(defaults.salaryGrowthRate)
        safeWithdrawalRate = Self.percentInputString(defaults.safeWithdrawalRate)

        runwayAssets = Self.inputString(defaults.investableAssets)
        runwayMonthlyExpense = Self.inputString(defaults.currentMonthlyExpense)
        passiveMonthlyIncome = Self.inputString(defaults.passiveMonthlyIncome)
        runwayAnnualReturn = Self.percentInputString(defaults.annualReturnRate)
        runwayInflation = Self.percentInputString(defaults.inflationRate)

        fireResult = FinancialPlanningEngine.calculateFIRE(
            FIREInput(
                annualAfterTaxIncome: defaults.annualAfterTaxIncome,
                currentMonthlyExpense: defaults.currentMonthlyExpense,
                investableAssets: defaults.investableAssets,
                retirementMonthlyExpense: defaults.retirementMonthlyExpense,
                currentAge: defaults.currentAge,
                lifeExpectancy: defaults.lifeExpectancy,
                annualReturnRate: defaults.annualReturnRate,
                inflationRate: defaults.inflationRate,
                salaryGrowthRate: defaults.salaryGrowthRate,
                safeWithdrawalRate: defaults.safeWithdrawalRate
            )
        )
        runwayResult = FinancialPlanningEngine.calculateRunway(
            RunwayInput(
                investableAssets: defaults.investableAssets,
                monthlyExpense: defaults.currentMonthlyExpense,
                passiveMonthlyIncome: defaults.passiveMonthlyIncome,
                annualReturnRate: defaults.annualReturnRate,
                inflationRate: defaults.inflationRate
            )
        )
    }

    var fireStatusText: String {
        switch fireResult.status {
        case .achieved:
            return "当前资产已达到 FIRE 目标"
        case .reachable:
            return "按当前参数预计可以达成"
        case .unreachable:
            return "在预期寿命或 60 年模拟范围内无法达成"
        case .invalid(let message):
            return message
        }
    }

    var runwayStatusText: String {
        switch runwayResult {
        case .sustainable:
            return "可持续"
        case .depleted(let months):
            return months == 0 ? "资产已耗尽" : "预计可续航 \(months) 个月（\(Self.yearsString(months)) 年）"
        case .invalid(let message):
            return message
        }
    }

    private func recalculateFIRE() {
        guard let annualIncome = Self.decimal(annualIncome),
              let currentMonthlyExpense = Self.decimal(currentMonthlyExpense),
              let assets = Self.decimal(fireAssets),
              let retirementExpense = Self.decimal(retirementMonthlyExpense),
              let age = Int(currentAge),
              let life = Int(lifeExpectancy),
              let annualReturn = Self.percent(fireAnnualReturn),
              let inflation = Self.percent(fireInflation),
              let growth = Self.percent(salaryGrowth),
              let withdrawal = Self.percent(safeWithdrawalRate) else {
            fireResult = Self.invalidFIRE("请填写有效的数字")
            return
        }

        fireResult = FinancialPlanningEngine.calculateFIRE(
            FIREInput(
                annualAfterTaxIncome: annualIncome,
                currentMonthlyExpense: currentMonthlyExpense,
                investableAssets: assets,
                retirementMonthlyExpense: retirementExpense,
                currentAge: age,
                lifeExpectancy: life,
                annualReturnRate: annualReturn,
                inflationRate: inflation,
                salaryGrowthRate: growth,
                safeWithdrawalRate: withdrawal
            )
        )
    }

    private func recalculateRunway() {
        guard let assets = Self.decimal(runwayAssets),
              let expense = Self.decimal(runwayMonthlyExpense),
              let passive = Self.decimal(passiveMonthlyIncome),
              let annualReturn = Self.percent(runwayAnnualReturn),
              let inflation = Self.percent(runwayInflation) else {
            runwayResult = .invalid("请填写有效的数字")
            return
        }

        runwayResult = FinancialPlanningEngine.calculateRunway(
            RunwayInput(
                investableAssets: assets,
                monthlyExpense: expense,
                passiveMonthlyIncome: passive,
                annualReturnRate: annualReturn,
                inflationRate: inflation
            )
        )
    }

    static func currency(_ value: Decimal?) -> String {
        guard let value else { return "—" }
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.numberStyle = .currency
        formatter.currencySymbol = "¥"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "—"
    }

    static func yearsString(_ months: Int) -> String {
        String(format: "%.1f", Double(months) / 12)
    }

    private static func decimal(_ text: String) -> Decimal? {
        let normalized = text
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "，", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return nil }
        return Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX"))
    }

    private static func percent(_ text: String) -> Decimal? {
        decimal(text).map { $0 / 100 }
    }

    private static func inputString(_ value: Decimal) -> String {
        NSDecimalNumber(decimal: value).stringValue
    }

    private static func percentInputString(_ value: Decimal) -> String {
        inputString(value * 100)
    }

    private static func invalidFIRE(_ message: String) -> FIREResult {
        FIREResult(
            status: .invalid(message),
            targetAssets: nil,
            emergencyFund: nil,
            monthlySurplus: nil,
            monthsToReach: nil,
            retirementAge: nil,
            projectedRetirementAssets: nil,
            monthlySafeWithdrawal: nil
        )
    }
}
