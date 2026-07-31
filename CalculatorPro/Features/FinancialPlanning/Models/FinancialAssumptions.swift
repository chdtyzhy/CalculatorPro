import Foundation

struct FinancialAssumptionsSnapshot: Equatable {
    let version: String
    let annualAfterTaxIncome: Decimal
    let currentMonthlyExpense: Decimal
    let investableAssets: Decimal
    let retirementMonthlyExpense: Decimal
    let currentAge: Int
    let lifeExpectancy: Int
    let annualReturnRate: Decimal
    let inflationRate: Decimal
    let salaryGrowthRate: Decimal
    let safeWithdrawalRate: Decimal
    let passiveMonthlyIncome: Decimal
}

protocol FinancialAssumptionsProvider {
    var snapshot: FinancialAssumptionsSnapshot { get }
}

struct BundledFinancialAssumptionsProvider: FinancialAssumptionsProvider {
    static let currentVersion = "2026.1"

    let snapshot = FinancialAssumptionsSnapshot(
        version: currentVersion,
        annualAfterTaxIncome: 240_000,
        currentMonthlyExpense: 10_000,
        investableAssets: 500_000,
        retirementMonthlyExpense: 8_000,
        currentAge: 30,
        lifeExpectancy: 90,
        annualReturnRate: 0.07,
        inflationRate: 0.03,
        salaryGrowthRate: 0.03,
        safeWithdrawalRate: 0.04,
        passiveMonthlyIncome: 0
    )
}
