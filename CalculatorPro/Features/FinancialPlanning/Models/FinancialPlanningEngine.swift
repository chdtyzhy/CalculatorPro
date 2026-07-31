import Foundation

struct FIREInput: Equatable {
    var annualAfterTaxIncome: Decimal
    var currentMonthlyExpense: Decimal
    var investableAssets: Decimal
    var retirementMonthlyExpense: Decimal
    var currentAge: Int
    var lifeExpectancy: Int
    var annualReturnRate: Decimal
    var inflationRate: Decimal
    var salaryGrowthRate: Decimal
    var safeWithdrawalRate: Decimal
}

enum FIREStatus: Equatable {
    case achieved
    case reachable
    case unreachable
    case invalid(String)
}

struct FIREResult: Equatable {
    let status: FIREStatus
    let targetAssets: Decimal?
    let emergencyFund: Decimal?
    let monthlySurplus: Decimal?
    let monthsToReach: Int?
    let retirementAge: Decimal?
    let projectedRetirementAssets: Decimal?
    let monthlySafeWithdrawal: Decimal?
}

struct RunwayInput: Equatable {
    var investableAssets: Decimal
    var monthlyExpense: Decimal
    var passiveMonthlyIncome: Decimal
    var annualReturnRate: Decimal
    var inflationRate: Decimal
}

enum RunwayResult: Equatable {
    case depleted(months: Int)
    case sustainable
    case invalid(String)
}

enum FinancialPlanningEngine {
    static let maximumFIREMonths = 720

    static func calculateFIRE(_ input: FIREInput) -> FIREResult {
        let amounts = [
            input.annualAfterTaxIncome,
            input.currentMonthlyExpense,
            input.investableAssets,
            input.retirementMonthlyExpense
        ]
        guard amounts.allSatisfy({ $0 >= 0 }) else {
            return invalidFIRE("金额不能为负数")
        }
        guard input.currentAge >= 0,
              input.currentAge < input.lifeExpectancy,
              input.lifeExpectancy <= 130 else {
            return invalidFIRE("年龄应有效，且预期寿命必须大于当前年龄")
        }
        guard input.safeWithdrawalRate > 0, input.safeWithdrawalRate <= 1 else {
            return invalidFIRE("安全提取率应大于 0% 且不超过 100%")
        }

        guard let annualReturn = finiteDouble(input.annualReturnRate),
              let inflation = finiteDouble(input.inflationRate),
              let salaryGrowth = finiteDouble(input.salaryGrowthRate),
              annualReturn > -1,
              inflation > -1,
              salaryGrowth > -1 else {
            return invalidFIRE("收益率、通胀率和工资增长率必须大于 -100%")
        }

        let realAnnualReturn = (1 + annualReturn) / (1 + inflation) - 1
        let realAnnualSalaryGrowth = (1 + salaryGrowth) / (1 + inflation) - 1
        guard realAnnualReturn.isFinite,
              realAnnualReturn > -1,
              realAnnualSalaryGrowth.isFinite,
              realAnnualSalaryGrowth > -1 else {
            return invalidFIRE("实际收益率必须大于 -100%")
        }

        let target = input.retirementMonthlyExpense * 12 / input.safeWithdrawalRate
        let emergencyFund = input.currentMonthlyExpense * 6
        let initialMonthlySurplus = input.annualAfterTaxIncome / 12 - input.currentMonthlyExpense

        if input.investableAssets >= target {
            return FIREResult(
                status: .achieved,
                targetAssets: target,
                emergencyFund: emergencyFund,
                monthlySurplus: initialMonthlySurplus,
                monthsToReach: 0,
                retirementAge: Decimal(input.currentAge),
                projectedRetirementAssets: input.investableAssets,
                monthlySafeWithdrawal: input.investableAssets * input.safeWithdrawalRate / 12
            )
        }

        guard let monthlyReturn = monthlyRate(fromAnnual: realAnnualReturn),
              let monthlySalaryGrowth = monthlyRate(fromAnnual: realAnnualSalaryGrowth),
              var assets = finiteDouble(input.investableAssets),
              var monthlyIncome = finiteDouble(input.annualAfterTaxIncome / 12),
              let monthlyExpense = finiteDouble(input.currentMonthlyExpense),
              let targetDouble = finiteDouble(target) else {
            return invalidFIRE("参数超出可计算范围")
        }

        let ageLimitedMonths = (input.lifeExpectancy - input.currentAge) * 12
        let limit = min(maximumFIREMonths, ageLimitedMonths)

        for month in 1...limit {
            let surplus = monthlyIncome - monthlyExpense
            assets = assets * (1 + monthlyReturn) + surplus
            monthlyIncome *= 1 + monthlySalaryGrowth

            guard assets.isFinite, monthlyIncome.isFinite else {
                return invalidFIRE("计算结果超出可表示范围")
            }
            if assets >= targetDouble {
                guard let projectedAssets = decimal(fromFinite: assets) else {
                    return invalidFIRE("计算结果超出可表示范围")
                }
                return FIREResult(
                    status: .reachable,
                    targetAssets: target,
                    emergencyFund: emergencyFund,
                    monthlySurplus: initialMonthlySurplus,
                    monthsToReach: month,
                    retirementAge: Decimal(input.currentAge) + Decimal(month) / 12,
                    projectedRetirementAssets: projectedAssets,
                    monthlySafeWithdrawal: projectedAssets * input.safeWithdrawalRate / 12
                )
            }
        }

        return FIREResult(
            status: .unreachable,
            targetAssets: target,
            emergencyFund: emergencyFund,
            monthlySurplus: initialMonthlySurplus,
            monthsToReach: nil,
            retirementAge: nil,
            projectedRetirementAssets: nil,
            monthlySafeWithdrawal: nil
        )
    }

    static func calculateRunway(_ input: RunwayInput) -> RunwayResult {
        guard input.investableAssets >= 0,
              input.monthlyExpense >= 0,
              input.passiveMonthlyIncome >= 0 else {
            return .invalid("金额不能为负数")
        }
        guard let annualReturn = finiteDouble(input.annualReturnRate),
              let inflation = finiteDouble(input.inflationRate),
              annualReturn > -1,
              inflation > -1 else {
            return .invalid("收益率和通胀率必须大于 -100%")
        }

        let realAnnualReturn = (1 + annualReturn) / (1 + inflation) - 1
        guard realAnnualReturn.isFinite,
              realAnnualReturn > -1,
              let monthlyReturn = monthlyRate(fromAnnual: realAnnualReturn),
              let assets = finiteDouble(input.investableAssets),
              let expense = finiteDouble(input.monthlyExpense),
              let passiveIncome = finiteDouble(input.passiveMonthlyIncome) else {
            return .invalid("实际收益率必须大于 -100%")
        }

        let gap = expense - passiveIncome
        if gap <= 0 {
            return .sustainable
        }
        if assets <= 0 {
            return .depleted(months: 0)
        }
        if monthlyReturn >= 0, assets * monthlyReturn >= gap {
            return .sustainable
        }
        if abs(monthlyReturn) < 1e-12 {
            return .depleted(months: max(1, Int(ceil(assets / gap))))
        }

        let denominator = gap - assets * monthlyReturn
        let ratio = gap / denominator
        let months = log(ratio) / log(1 + monthlyReturn)
        guard months.isFinite, months >= 0 else {
            return .invalid("参数超出可计算范围")
        }
        return .depleted(months: max(1, Int(ceil(months))))
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

    private static func monthlyRate(fromAnnual annualRate: Double) -> Double? {
        let monthly = pow(1 + annualRate, 1 / 12) - 1
        return monthly.isFinite && monthly > -1 ? monthly : nil
    }

    private static func finiteDouble(_ value: Decimal) -> Double? {
        let result = NSDecimalNumber(decimal: value).doubleValue
        return result.isFinite ? result : nil
    }

    private static func decimal(fromFinite value: Double) -> Decimal? {
        guard value.isFinite else { return nil }
        return Decimal(string: String(value), locale: Locale(identifier: "en_US_POSIX"))
    }
}
