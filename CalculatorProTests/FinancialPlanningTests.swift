import XCTest
@testable import CalculatorPro

final class FinancialPlanningTests: XCTestCase {
    func testFIREFormulaBaselineUsesMonthlySimulation() {
        let result = FinancialPlanningEngine.calculateFIRE(
            makeFIRE(
                income: 120_000,
                currentExpense: 0,
                assets: 0,
                retirementExpense: 400,
                annualReturn: 0,
                inflation: 0,
                salaryGrowth: 0
            )
        )

        XCTAssertEqual(result.targetAssets, 120_000)
        XCTAssertEqual(result.monthlySurplus, 10_000)
        XCTAssertEqual(result.monthsToReach, 12)
        XCTAssertEqual(result.retirementAge, 31)
        XCTAssertEqual(result.monthlySafeWithdrawal, 400)
    }

    func testFIREZeroAndNegativeSurplusCannotReachWithoutGrowth() {
        for income in [Decimal(120_000), Decimal(60_000)] {
            let result = FinancialPlanningEngine.calculateFIRE(
                makeFIRE(
                    income: income,
                    currentExpense: 10_000,
                    assets: 0,
                    retirementExpense: 8_000,
                    annualReturn: 0,
                    inflation: 0,
                    salaryGrowth: 0
                )
            )
            XCTAssertEqual(result.status, .unreachable)
            XCTAssertNil(result.monthsToReach)
        }
    }

    func testFIREAlreadyFundedIsAchievedImmediately() {
        let result = FinancialPlanningEngine.calculateFIRE(
            makeFIRE(assets: 3_000_000)
        )

        XCTAssertEqual(result.status, .achieved)
        XCTAssertEqual(result.monthsToReach, 0)
        XCTAssertEqual(result.projectedRetirementAssets, 3_000_000)
        XCTAssertEqual(result.monthlySafeWithdrawal, 10_000)
    }

    func testFIREReturnAndInflationBoundaryIsRejected() {
        let invalidReturn = FinancialPlanningEngine.calculateFIRE(
            makeFIRE(annualReturn: -1)
        )
        let invalidInflation = FinancialPlanningEngine.calculateFIRE(
            makeFIRE(inflation: -1)
        )

        XCTAssertEqual(invalidReturn.status, .invalid("收益率、通胀率和工资增长率必须大于 -100%"))
        XCTAssertEqual(invalidInflation.status, .invalid("收益率、通胀率和工资增长率必须大于 -100%"))
    }

    func testFIREStopsAfter720Months() {
        let result = FinancialPlanningEngine.calculateFIRE(
            makeFIRE(
                income: 12,
                currentExpense: 0,
                assets: 0,
                retirementExpense: 8_000,
                currentAge: 20,
                lifeExpectancy: 100,
                annualReturn: 0,
                inflation: 0,
                salaryGrowth: 0
            )
        )

        XCTAssertEqual(result.status, .unreachable)
        XCTAssertNil(result.monthsToReach)
    }

    func testRunwayDepletesAtExpectedMonth() {
        let result = FinancialPlanningEngine.calculateRunway(
            makeRunway(assets: 100_000, expense: 10_000)
        )

        XCTAssertEqual(result, .depleted(months: 10))
    }

    func testRunwayIsSustainableWhenPassiveIncomeCoversExpense() {
        let result = FinancialPlanningEngine.calculateRunway(
            makeRunway(assets: 0, expense: 10_000, passive: 10_000)
        )

        XCTAssertEqual(result, .sustainable)
    }

    func testRunwayIsSustainableWhenRealReturnCoversGap() {
        let result = FinancialPlanningEngine.calculateRunway(
            makeRunway(assets: 2_000_000, expense: 5_000, annualReturn: 0.06)
        )

        XCTAssertEqual(result, .sustainable)
    }

    func testRunwayRejectsNegativeHundredPercentReturn() {
        let result = FinancialPlanningEngine.calculateRunway(
            makeRunway(annualReturn: -1)
        )

        XCTAssertEqual(result, .invalid("收益率和通胀率必须大于 -100%"))
    }

    func testBundledAssumptionsHaveStableVersionAndFourPercentDefault() {
        let snapshot = BundledFinancialAssumptionsProvider().snapshot

        XCTAssertEqual(snapshot.version, BundledFinancialAssumptionsProvider.currentVersion)
        XCTAssertEqual(snapshot.version, "2026.1")
        XCTAssertEqual(snapshot.safeWithdrawalRate, 0.04)
    }

    func testViewModelRecalculatesImmediatelyWhenInputChanges() {
        let viewModel = FinancialPlanningViewModel()
        let initialTarget = viewModel.fireResult.targetAssets

        viewModel.retirementMonthlyExpense = "10000"

        XCTAssertNotEqual(viewModel.fireResult.targetAssets, initialTarget)
        XCTAssertEqual(viewModel.fireResult.targetAssets, 3_000_000)

        viewModel.runwayMonthlyExpense = "0"
        XCTAssertEqual(viewModel.runwayResult, .sustainable)
    }

    private func makeFIRE(
        income: Decimal = 240_000,
        currentExpense: Decimal = 10_000,
        assets: Decimal = 500_000,
        retirementExpense: Decimal = 8_000,
        currentAge: Int = 30,
        lifeExpectancy: Int = 90,
        annualReturn: Decimal = 0.07,
        inflation: Decimal = 0.03,
        salaryGrowth: Decimal = 0.03,
        withdrawal: Decimal = 0.04
    ) -> FIREInput {
        FIREInput(
            annualAfterTaxIncome: income,
            currentMonthlyExpense: currentExpense,
            investableAssets: assets,
            retirementMonthlyExpense: retirementExpense,
            currentAge: currentAge,
            lifeExpectancy: lifeExpectancy,
            annualReturnRate: annualReturn,
            inflationRate: inflation,
            salaryGrowthRate: salaryGrowth,
            safeWithdrawalRate: withdrawal
        )
    }

    private func makeRunway(
        assets: Decimal = 100_000,
        expense: Decimal = 10_000,
        passive: Decimal = 0,
        annualReturn: Decimal = 0,
        inflation: Decimal = 0
    ) -> RunwayInput {
        RunwayInput(
            investableAssets: assets,
            monthlyExpense: expense,
            passiveMonthlyIncome: passive,
            annualReturnRate: annualReturn,
            inflationRate: inflation
        )
    }
}
