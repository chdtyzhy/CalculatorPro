import Foundation
import SwiftUI
import XCTest
@testable import CalculatorPro

// 计算器功能测试
// 对比系统计算器与本项目的计算结果

class CalculatorTests: XCTestCase {
    
    var viewModel: MainViewModel!
    private let testDefaultsName = "CalculatorProTests.History"
    private var testDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: testDefaultsName)!
        testDefaults.removePersistentDomain(forName: testDefaultsName)
        viewModel = makeViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        testDefaults.removePersistentDomain(forName: testDefaultsName)
        testDefaults = nil
        super.tearDown()
    }

    func makeViewModel() -> MainViewModel {
        MainViewModel(userDefaults: testDefaults)
    }

    func testAutomaticReviewRequestDoesNotOccurDuringFirstFourLaunches() {
        let date = Date(timeIntervalSince1970: 1_000_000)

        for _ in 1...4 {
            let manager = AppReviewManager(userDefaults: testDefaults, now: { date })
            XCTAssertFalse(manager.recordLaunchAndShouldRequestAutomaticReview())
        }
    }

    func testAutomaticReviewRequestOccursOnFifthLaunch() {
        let date = Date(timeIntervalSince1970: 1_000_000)

        for _ in 1...4 {
            let manager = AppReviewManager(userDefaults: testDefaults, now: { date })
            XCTAssertFalse(manager.recordLaunchAndShouldRequestAutomaticReview())
        }

        let fifthLaunchManager = AppReviewManager(userDefaults: testDefaults, now: { date })
        XCTAssertTrue(fifthLaunchManager.recordLaunchAndShouldRequestAutomaticReview())
    }

    func testAutomaticReviewRequestDoesNotOccurWithinThirtyDaysOfLastAutomaticRequest() {
        let firstRequestDate = Date(timeIntervalSince1970: 1_000_000)
        triggerFirstReviewRequest(at: firstRequestDate)

        let datesWithinThirtyDays = [
            firstRequestDate.addingTimeInterval(10 * 24 * 60 * 60),
            firstRequestDate.addingTimeInterval(29 * 24 * 60 * 60)
        ]

        for date in datesWithinThirtyDays {
            let manager = AppReviewManager(userDefaults: testDefaults, now: { date })
            XCTAssertFalse(manager.recordLaunchAndShouldRequestAutomaticReview())
        }
    }

    func testAutomaticReviewRequestOccursThirtyDaysAfterLastAutomaticRequest() {
        let firstRequestDate = Date(timeIntervalSince1970: 1_000_000)
        triggerFirstReviewRequest(at: firstRequestDate)

        let dayBeforeEligible = firstRequestDate.addingTimeInterval(29 * 24 * 60 * 60)
        let earlyLaunchManager = AppReviewManager(
            userDefaults: testDefaults,
            now: { dayBeforeEligible }
        )
        XCTAssertFalse(earlyLaunchManager.recordLaunchAndShouldRequestAutomaticReview())

        let thirtiethDay = firstRequestDate.addingTimeInterval(30 * 24 * 60 * 60)
        let manager = AppReviewManager(userDefaults: testDefaults, now: { thirtiethDay })

        XCTAssertTrue(manager.recordLaunchAndShouldRequestAutomaticReview())
    }

    func testReviewManagerCountsOnlyOncePerAppSession() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let manager = AppReviewManager(userDefaults: testDefaults, now: { date })

        XCTAssertFalse(manager.recordLaunchAndShouldRequestAutomaticReview())
        XCTAssertFalse(manager.recordLaunchAndShouldRequestAutomaticReview())

        for _ in 2...4 {
            let nextLaunchManager = AppReviewManager(userDefaults: testDefaults, now: { date })
            XCTAssertFalse(nextLaunchManager.recordLaunchAndShouldRequestAutomaticReview())
        }

        let fifthLaunchManager = AppReviewManager(userDefaults: testDefaults, now: { date })
        XCTAssertTrue(fifthLaunchManager.recordLaunchAndShouldRequestAutomaticReview())
    }

    private func triggerFirstReviewRequest(at date: Date) {
        for launch in 1...5 {
            let manager = AppReviewManager(userDefaults: testDefaults, now: { date })
            XCTAssertEqual(manager.recordLaunchAndShouldRequestAutomaticReview(), launch == 5)
        }
    }

    func testVersionComparisonUsesThreeNumericComponents() {
        XCTAssertEqual(AppUpdateManager.compareVersions("1.2.3", "1.2.3"), .orderedSame)
        XCTAssertEqual(AppUpdateManager.compareVersions("1.2.4", "1.2.3"), .orderedDescending)
        XCTAssertEqual(AppUpdateManager.compareVersions("1.2.3", "1.3.0"), .orderedAscending)
        XCTAssertNil(AppUpdateManager.compareVersions("1.2", "1.2.0"))
        XCTAssertNil(AppUpdateManager.compareVersions("1.a.0", "1.0.0"))
    }

    func testUpdateCheckDecodesNewerAppStoreVersion() async {
        let storeURL = URL(string: "https://apps.apple.com/app/id123456789")!
        let manager = makeUpdateManager(
            currentVersion: "1.0.0",
            responseJSON: """
            {"results":[{"version":"1.1.0","trackViewUrl":"\(storeURL.absoluteString)"}]}
            """
        )

        let result = await manager.checkForUpdate()

        XCTAssertEqual(result, .updateAvailable(.init(version: "1.1.0", storeURL: storeURL)))
    }

    func testUpdateCheckReportsCurrentVersion() async {
        let manager = makeUpdateManager(
            currentVersion: "1.1.0",
            responseJSON: """
            {"results":[{"version":"1.1.0","trackViewUrl":"https://apps.apple.com/app/id123456789"}]}
            """
        )

        let result = await manager.checkForUpdate()
        XCTAssertEqual(result, .upToDate)
    }

    func testUpdateCheckHandlesNetworkFailure() async {
        let manager = AppUpdateManager(
            bundleIdentifier: "com.example.calculator",
            currentVersion: "1.0.0",
            loadData: { _ in throw URLError(.notConnectedToInternet) }
        )

        let result = await manager.checkForUpdate()
        XCTAssertEqual(result, .unavailable)
    }

    private func makeUpdateManager(
        currentVersion: String,
        responseJSON: String
    ) -> AppUpdateManager {
        AppUpdateManager(
            bundleIdentifier: "com.example.calculator",
            currentVersion: currentVersion,
            loadData: { request in
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (Data(responseJSON.utf8), response)
            }
        )
    }
    
    // MARK: - 辅助方法：模拟按钮点击
    func tap(_ pad: DialPad) {
        viewModel.performAction(for: pad)
    }
    
    func tapNumber(_ number: String) {
        for char in number {
            switch char {
            case "0": tap(.zero)
            case "1": tap(.one)
            case "2": tap(.two)
            case "3": tap(.three)
            case "4": tap(.four)
            case "5": tap(.five)
            case "6": tap(.six)
            case "7": tap(.seven)
            case "8": tap(.eight)
            case "9": tap(.nine)
            case ".": tap(.decimal)
            default: break
            }
        }
    }

    func tapSignedNumber(_ number: String) {
        if number.hasPrefix("-") {
            tap(.plusMinus)
            tapNumber(String(number.dropFirst()))
        } else {
            tapNumber(number)
        }
    }

    func assertNewDigitStartsCleanCalculation(
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        tap(.six)

        XCTAssertEqual(viewModel.result, "6", file: file, line: line)
        XCTAssertEqual(viewModel.currentExpression, "", file: file, line: line)
        XCTAssertEqual(viewModel.previousResult, "", file: file, line: line)
        XCTAssertEqual(viewModel.primaryDisplayText, "6", file: file, line: line)
        XCTAssertEqual(viewModel.secondaryDisplayText, "", file: file, line: line)
    }
    
    // MARK: - 基础运算测试
    func testBasicDivision() {
        // 测试: 9 ÷ 8
        tapNumber("9")
        tap(.divide)
        tapNumber("8")
        tap(.equal)
        
        print("【测试】9 ÷ 8 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "1.125", "9 ÷ 8 应该等于 1.125")
    }
    
    func testBasicMultiplication() {
        // 测试: 7 × 8
        tapNumber("7")
        tap(.multiply)
        tapNumber("8")
        tap(.equal)
        
        print("【测试】7 × 8 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "56", "7 × 8 应该等于 56")
    }
    
    func testBasicSubtraction() {
        // 测试: 15 − 7
        tapNumber("15")
        tap(.substract)
        tapNumber("7")
        tap(.equal)
        
        print("【测试】15 − 7 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "8", "15 − 7 应该等于 8")
    }
    
    func testBasicAddition() {
        // 测试: 23 + 45
        tapNumber("23")
        tap(.plus)
        tapNumber("45")
        tap(.equal)
        
        print("【测试】23 + 45 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "68", "23 + 45 应该等于 68")
    }
    
    // MARK: - 浮点数运算测试
    func testFloatDivision() {
        // 测试: 1 ÷ 3
        tapNumber("1")
        tap(.divide)
        tapNumber("3")
        tap(.equal)
        
        print("【测试】1 ÷ 3 = \(viewModel.result)")
        // 保留6位小数
        XCTAssertEqual(viewModel.result, "0.333333", "1 ÷ 3 应该约等于 0.333333")
    }
    
    func testFloatAddition() {
        // 测试: 0.1 + 0.2
        tapNumber("0.1")
        tap(.plus)
        tapNumber("0.2")
        tap(.equal)
        
        print("【测试】0.1 + 0.2 = \(viewModel.result)")
        // 注意：浮点数精度问题 0.1 + 0.2 = 0.30000000000000004
        // 本项目会格式化为 0.3
        XCTAssertEqual(viewModel.result, "0.3", "0.1 + 0.2 应该等于 0.3")
    }
    
    func testFloatMultiplication() {
        // 测试: 2.5 × 4
        tapNumber("2.5")
        tap(.multiply)
        tapNumber("4")
        tap(.equal)
        
        print("【测试】2.5 × 4 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "10", "2.5 × 4 应该等于 10")
    }
    
    // MARK: - 连续运算测试
    func testChainOperation1() {
        // 测试: 5 + 3 × 2
        // 注意：本项目按顺序计算，不是按数学优先级
        tapNumber("5")
        tap(.plus)
        tapNumber("3")
        tap(.multiply)
        tapNumber("2")
        tap(.equal)
        
        print("【测试】5 + 3 × 2 = \(viewModel.result)")
        // 本项目是顺序计算: (5+3)*2 = 16
        // 数学优先级应该是: 5+(3*2) = 11
        // 系统计算器通常是顺序计算
        XCTAssertEqual(viewModel.result, "16", "5 + 3 × 2 顺序计算等于 16")
    }
    
    func testChainOperation2() {
        // 测试: 100 ÷ 10 ÷ 2
        tapNumber("100")
        tap(.divide)
        tapNumber("10")
        tap(.divide)
        tapNumber("2")
        tap(.equal)
        
        print("【测试】100 ÷ 10 ÷ 2 = \(viewModel.result)")
        // 顺序计算: (100/10)/2 = 5
        XCTAssertEqual(viewModel.result, "5", "100 ÷ 10 ÷ 2 应该等于 5")
    }
    
    func testChainOperation3() {
        // 测试: 10 − 5 + 3
        tapNumber("10")
        tap(.substract)
        tapNumber("5")
        tap(.plus)
        tapNumber("3")
        tap(.equal)
        
        print("【测试】10 − 5 + 3 = \(viewModel.result)")
        // 顺序计算: (10-5)+3 = 8
        XCTAssertEqual(viewModel.result, "8", "10 − 5 + 3 应该等于 8")
    }
    
    // MARK: - 百分比测试
    func testPercentage() {
        // 测试: 50 %
        tapNumber("50")
        tap(.percentage)
        
        print("【测试】50 % = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "0.5", "50% 应该等于 0.5")
    }

    func testPercentageInEachOperationContext() {
        let cases: [(DialPad, String)] = [
            (.plus, "220"),
            (.substract, "180"),
            (.multiply, "20"),
            (.divide, "2000")
        ]

        for (operation, expected) in cases {
            viewModel = makeViewModel()
            tapNumber("200")
            tap(operation)
            tapNumber("10")
            tap(.percentage)
            XCTAssertEqual(viewModel.result, expected)
        }
    }

    func testDivideByZeroPercentageIsUndefined() {
        tapNumber("200")
        tap(.divide)
        tapNumber("0")
        tap(.percentage)

        XCTAssertEqual(viewModel.result, "未定义")
    }
    
    // MARK: - 边界条件测试
    func testZeroDivision() {
        // 测试: 0 ÷ 5
        tapNumber("0")
        tap(.divide)
        tapNumber("5")
        tap(.equal)
        
        print("【测试】0 ÷ 5 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "0", "0 ÷ 5 应该等于 0")
    }
    
    func testDivideByZero() {
        // 测试: 1 ÷ 0 (应该显示"未定义")
        tapNumber("1")
        tap(.divide)
        tapNumber("0")
        tap(.equal)
        
        print("【测试】1 ÷ 0 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "未定义", "1 ÷ 0 应该显示未定义")
    }
    
    func testLargeNumber() {
        // 测试: 999999 + 1
        tapNumber("999999")
        tap(.plus)
        tapNumber("1")
        tap(.equal)
        
        print("【测试】999999 + 1 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "1000000", "999999 + 1 应该等于 1000000")
    }
    
    // MARK: - 正负号测试
    func testPlusMinusAfterNumber() {
        // 测试: 9 → +/- = -9
        tapNumber("9")
        viewModel.set(operation: .plusMinus)
        
        print("【测试】9 → +/- = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "-9", "9 切换正负号应该是 -9")
    }
    
    func testPlusMinusBeforeNumber() {
        // 测试: +/- → 9 = -9
        viewModel.set(operation: .plusMinus)
        XCTAssertEqual(viewModel.currentExpression, "(-")
        tapNumber("9")
        
        print("【测试】+/- → 9 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "-9", "先切换正负号再输入9应该是 -9")
        XCTAssertEqual(viewModel.currentExpression, "(-9)")
    }

    func testPlusMinusAfterPendingOperatorShowsNegativeInputIntentWithoutZero() {
        tapNumber("56")
        tap(.plus)
        tap(.plusMinus)

        XCTAssertEqual(viewModel.result, "-0")
        XCTAssertEqual(viewModel.currentExpression, "56+(-")
        XCTAssertEqual(viewModel.primaryDisplayText, "56+(−")
    }

    func testPlusMinusAfterPendingOperatorAcceptsNumberAndEquals() {
        tapNumber("56")
        tap(.plus)
        tap(.plusMinus)
        tapNumber("2")

        XCTAssertEqual(viewModel.currentExpression, "56+(-2)")

        tap(.equal)
        XCTAssertEqual(viewModel.result, "54")
        XCTAssertEqual(viewModel.previousResult, "56+(-2)")
    }

    func testNegativeSecondOperandKeepsSequentialContinuousOperation() {
        tapNumber("56")
        tap(.plus)
        tap(.plusMinus)
        tapNumber("2")
        tap(.multiply)
        tapNumber("3")
        tap(.equal)

        XCTAssertEqual(viewModel.result, "162")
        XCTAssertEqual(viewModel.previousResult, "56+(-2)×3")
    }

    func testPlusMinusAfterPendingOperatorCanToggleBackToPositiveOperand() {
        tapNumber("56")
        tap(.plus)
        tap(.plusMinus)
        tap(.plusMinus)

        XCTAssertEqual(viewModel.result, "0")
        XCTAssertEqual(viewModel.currentExpression, "56+")

        tapNumber("2")
        tap(.equal)
        XCTAssertEqual(viewModel.result, "58")
        XCTAssertEqual(viewModel.previousResult, "56+2")
    }

    func testEnteredSecondOperandCanToggleNegativeAndBackToPositive() {
        tapNumber("56")
        tap(.plus)
        tapNumber("2")
        tap(.plusMinus)
        XCTAssertEqual(viewModel.currentExpression, "56+(-2)")

        tap(.plusMinus)
        XCTAssertEqual(viewModel.currentExpression, "56+2")

        tap(.equal)
        XCTAssertEqual(viewModel.result, "58")
        XCTAssertEqual(viewModel.previousResult, "56+2")
    }

    func testNativeStyleNegativeOperandsKeepSequentialChainSemantics() {
        tap(.plusMinus)
        tapNumber("150")
        tap(.substract)
        tapNumber("2")
        tap(.plus)
        tapNumber("2")
        tap(.plus)
        tap(.plusMinus)
        tapNumber("2")

        XCTAssertEqual(viewModel.currentExpression, "(-150)−2+2+(-2)")

        tap(.equal)
        XCTAssertEqual(viewModel.result, "-152")
        XCTAssertEqual(viewModel.previousResult, "(-150)−2+2+(-2)")
    }

    func testNegativeDecimalSecondOperandUsesParentheses() {
        tapNumber("5")
        tap(.plus)
        tap(.plusMinus)
        tap(.decimal)
        XCTAssertEqual(viewModel.currentExpression, "5+(-0.)")

        tapNumber("25")
        XCTAssertEqual(viewModel.currentExpression, "5+(-0.25)")

        tap(.equal)
        XCTAssertEqual(viewModel.result, "4.75")
        XCTAssertEqual(viewModel.previousResult, "5+(-0.25)")
    }

    func testRevertCancelsPendingNegativeOperandWithoutCorruptingExpression() {
        tapNumber("56")
        tap(.plus)
        tap(.plusMinus)
        tap(.revert)

        XCTAssertEqual(viewModel.result, "0")
        XCTAssertEqual(viewModel.currentExpression, "56+")

        tapNumber("3")
        tap(.equal)
        XCTAssertEqual(viewModel.result, "59")
        XCTAssertEqual(viewModel.previousResult, "56+3")
    }
    
    func testInitialMinusStartsSubtractionFromZero() {
        tap(.substract)

        XCTAssertEqual(viewModel.result, "0")
        XCTAssertEqual(viewModel.currentExpression, "0−")

        tapNumber("9")
        tap(.equal)

        XCTAssertEqual(viewModel.result, "-9")
        XCTAssertEqual(viewModel.previousResult, "0−9")
    }
    
    func testNegativeMultiplyByNegative() {
        // 测试: -9 × -6 = 54
        // 输入 -9
        tapNumber("9")
        viewModel.set(operation: .plusMinus)
        // 点击乘号
        tap(.multiply)
        // 输入 -6 (通过 +/- 方式)
        viewModel.set(operation: .plusMinus)  // 先切换到 -0
        tapNumber("6")
        // 点击等号
        tap(.equal)
        
        print("【测试】-9 × -6 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "54", "-9 × -6 应该等于 54")
    }
    
    func testMinusReplacesPendingMultiplyOperator() {
        tapNumber("6")
        tap(.multiply)
        tap(.substract)

        XCTAssertEqual(viewModel.result, "6")
        XCTAssertEqual(viewModel.currentExpression, "6−")

        tapNumber("2")
        tap(.equal)

        XCTAssertEqual(viewModel.result, "4")
        XCTAssertEqual(viewModel.previousResult, "6−2")
    }
    
    func testTogglePlusMinus() {
        // 测试正负号切换
        tapNumber("5")
        viewModel.set(operation: .plusMinus)  // -5
        XCTAssertEqual(viewModel.result, "-5")
        
        viewModel.set(operation: .plusMinus)  // 5
        XCTAssertEqual(viewModel.result, "5")
        
        viewModel.set(operation: .plusMinus)  // -5
        XCTAssertEqual(viewModel.result, "-5")
    }
    
    // MARK: - 退格测试
    func testRevert() {
        // 测试退格
        tapNumber("123")
        tap(.revert)  // 退格，应该显示 12
        
        print("【测试】123 → 退格 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "12", "123 退格后应该是 12")
        
        tap(.revert)  // 退格，应该显示 1
        XCTAssertEqual(viewModel.result, "1", "12 退格后应该是 1")
        
        tap(.revert)  // 退格，应该显示 0
        XCTAssertEqual(viewModel.result, "0", "1 退格后应该是 0")
    }
    
    func testRevertOnNegative() {
        // 测试负数退格
        tapNumber("9")
        viewModel.set(operation: .plusMinus)  // -9
        tap(.revert)  // 退格，应该变为 -0 然后 0
        
        print("【测试】-9 → 退格 = \(viewModel.result)")
        // 退格后剩负号，应该重置为0
        XCTAssertEqual(viewModel.result, "0", "-9 退格后应该变为 0")
    }
    
    // MARK: - 清除测试
    func testClear() {
        // 测试清除
        tapNumber("123")
        tap(.plus)
        tapNumber("456")
        tap(.clear)  // 清除
        
        print("【测试】123 + 456 → 清除后 result = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "", "清除后 result 应该为空")
    }
    
    // MARK: - 小数点测试
    func testDecimalInput() {
        // 测试小数输入
        tapNumber("3")
        tap(.decimal)
        tapNumber("14")
        
        print("【测试】3.14 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "3.14", "3.14 应该正确显示")
    }
    
    func testMultipleDecimalPoints() {
        // 测试重复输入小数点（应该忽略第二次）
        tapNumber("1")
        tap(.decimal)
        tap(.decimal)  // 应该被忽略
        tapNumber("5")
        
        print("【测试】1..5 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "1.5", "重复小数点应该被忽略")
    }
    
    // MARK: - 未定义状态测试
    func testUndefinedState() {
        // 测试未定义状态后输入数字
        tapNumber("1")
        tap(.divide)
        tapNumber("0")
        tap(.equal)  // 显示"未定义"
        
        XCTAssertEqual(viewModel.result, "未定义")
        
        // 输入数字后应该重新开始
        tapNumber("5")
        XCTAssertEqual(viewModel.result, "5", "未定义后输入数字应该重新开始")
    }
    
    func testUndefinedStateThenClear() {
        // 测试未定义状态后清除
        tapNumber("1")
        tap(.divide)
        tapNumber("0")
        tap(.equal)  // 显示"未定义"
        
        XCTAssertEqual(viewModel.result, "未定义")
        
        // 退格应该重置为0
        tap(.revert)
        XCTAssertEqual(viewModel.result, "0", "未定义后退格应该变为 0")
    }
    
    // MARK: - 表达式显示测试
    func testNewDigitAfterNegativeResultClearsCompletedExpression() {
        tapNumber("89")
        tap(.multiply)
        tapNumber("2")
        tap(.plusMinus)
        tap(.equal)

        XCTAssertEqual(viewModel.result, "-178")
        XCTAssertEqual(viewModel.previousResult, "89×(-2)")

        assertNewDigitStartsCleanCalculation()
    }

    func testNewDigitAfterPositiveResultClearsCompletedExpression() {
        tapNumber("2")
        tap(.plus)
        tapNumber("3")
        tap(.equal)

        XCTAssertEqual(viewModel.result, "5")
        XCTAssertEqual(viewModel.previousResult, "2+3")

        assertNewDigitStartsCleanCalculation()
    }

    func testNewDigitAfterPercentageClearsCompletedExpression() {
        tapNumber("50")
        tap(.percentage)

        XCTAssertEqual(viewModel.result, "0.5")
        XCTAssertEqual(viewModel.previousResult, "50%")

        assertNewDigitStartsCleanCalculation()
    }

    func testNewDigitAfterUndefinedClearsEarlierCompletedExpression() {
        tapNumber("2")
        tap(.plus)
        tapNumber("3")
        tap(.equal)
        tapNumber("1")
        tap(.divide)
        tapNumber("0")
        tap(.equal)

        XCTAssertEqual(viewModel.result, "未定义")

        assertNewDigitStartsCleanCalculation()
    }

    func testNewDigitAfterRepeatedEqualClearsCompletedExpression() {
        tapNumber("2")
        tap(.plus)
        tapNumber("3")
        tap(.equal)
        tap(.equal)

        XCTAssertEqual(viewModel.result, "8")
        XCTAssertEqual(viewModel.previousResult, "5+3")

        assertNewDigitStartsCleanCalculation()
    }

    func testExpressionDisplay() {
        // 测试表达式显示
        tapNumber("8")
        tap(.multiply)
        
        print("【测试】表达式显示（运算符后）: \(viewModel.currentExpression)")
        XCTAssertEqual(viewModel.currentExpression, "8×", "输入 8 × 应该显示 8×")
        
        tapNumber("7")
        
        print("【测试】表达式显示（输入第二个操作数后）: \(viewModel.currentExpression)")
        XCTAssertEqual(viewModel.currentExpression, "8×7", "输入 8 × 7 应该显示 8×7")
    }

    func testActiveExpressionUsesPrimaryDisplayUntilCalculationCompletes() {
        tapNumber("9")
        tap(.multiply)

        XCTAssertEqual(viewModel.primaryDisplayText, "9×")
        XCTAssertEqual(viewModel.secondaryDisplayText, "")

        tapNumber("2")
        XCTAssertEqual(viewModel.primaryDisplayText, "9×2")
        XCTAssertEqual(viewModel.secondaryDisplayText, "")

        tap(.equal)
        XCTAssertEqual(viewModel.primaryDisplayText, "18")
        XCTAssertEqual(viewModel.secondaryDisplayText, "9×2")
    }

    func testContinuousOperationKeepsFullExpression() {
        tapNumber("5")
        tap(.plus)
        tapNumber("3")
        tap(.multiply)
        tapNumber("2")

        XCTAssertEqual(viewModel.currentExpression, "5+3×2")

        tap(.equal)
        XCTAssertEqual(viewModel.result, "16")
        XCTAssertEqual(viewModel.previousResult, "5+3×2")
    }

    func testCompletedCalculationIsPersistedAndReloaded() {
        tapNumber("12")
        tap(.plus)
        tapNumber("8")
        tap(.equal)

        XCTAssertEqual(viewModel.history.count, 1)
        XCTAssertEqual(viewModel.history.first?.expression, "12+8")
        XCTAssertEqual(viewModel.history.first?.result, "20")
        XCTAssertEqual(viewModel.history.first?.copyText, "12+8 = 20")

        let reloadedViewModel = makeViewModel()
        XCTAssertEqual(reloadedViewModel.history, viewModel.history)
    }

    func testReuseHistoryEntryUsesResultAsNextOperand() {
        tapNumber("7")
        tap(.multiply)
        tapNumber("6")
        tap(.equal)

        let entry = viewModel.history[0]
        viewModel.reset()
        viewModel.reuse(entry)
        tap(.plus)
        tapNumber("8")
        tap(.equal)

        XCTAssertEqual(viewModel.result, "50")
        XCTAssertEqual(viewModel.previousResult, "42+8")
    }

    func testHistoryCanBeDeletedAndCleared() {
        tapNumber("1")
        tap(.plus)
        tapNumber("1")
        tap(.equal)
        tapNumber("3")
        tap(.percentage)

        XCTAssertEqual(viewModel.history.count, 2)
        viewModel.deleteHistory(at: IndexSet(integer: 0))
        XCTAssertEqual(viewModel.history.count, 1)

        viewModel.clearHistory()
        XCTAssertTrue(viewModel.history.isEmpty)
        XCTAssertTrue(makeViewModel().history.isEmpty)
    }

    func testHistoryCategoryIsEditablePersistentAndIncludedWhenCopied() {
        XCTAssertEqual(
            CalculationHistoryEntry.presetCategories,
            ["房租", "餐饮", "购物", "交通", "水电", "工资"]
        )

        tapNumber("3500")
        tap(.plus)
        tapNumber("0")
        tap(.equal)
        let entryID = viewModel.history[0].id

        viewModel.updateCategory(for: entryID, category: "  本月房租  ")
        XCTAssertEqual(viewModel.history[0].category, "本月房租")
        XCTAssertEqual(viewModel.history[0].copyText, "[本月房租] 3500+0 = 3500")
        XCTAssertEqual(makeViewModel().history[0].category, "本月房租")

        viewModel.updateCategory(for: entryID, category: "   ")
        XCTAssertNil(viewModel.history[0].category)
    }
    
    // MARK: - 连续运算边界测试
    func testContinuousOperations() {
        // 测试连续运算: 10 + 20 + 30 + 40
        tapNumber("10")
        tap(.plus)
        tapNumber("20")
        tap(.plus)
        tapNumber("30")
        tap(.plus)
        tapNumber("40")
        tap(.equal)
        
        print("【测试】10 + 20 + 30 + 40 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "100", "10 + 20 + 30 + 40 应该等于 100")
    }
    
    func testImmediateEqualAfterOperator() {
        // 测试运算符后直接按等号
        tapNumber("5")
        tap(.plus)
        tap(.equal)
        
        print("【测试】5 + = \(viewModel.result)")
        // 应该等于 5 + 5 = 10 (系统计算器通常这样处理)
        XCTAssertEqual(viewModel.result, "10", "5 + = 应该等于 10")
    }

    func testImmediateEqualAfterEachOperator() {
        let cases: [(DialPad, String)] = [
            (.plus, "10"),
            (.substract, "0"),
            (.multiply, "25"),
            (.divide, "1")
        ]

        for (operation, expected) in cases {
            viewModel = makeViewModel()
            tapNumber("5")
            tap(operation)
            tap(.equal)
            XCTAssertEqual(viewModel.result, expected)
        }
    }

    func testReplacingPendingOperatorDoesNotCalculateWithPlaceholderZero() {
        tapNumber("8")
        tap(.multiply)
        tap(.plus)
        tapNumber("2")
        tap(.equal)

        XCTAssertEqual(viewModel.result, "10")
        XCTAssertEqual(viewModel.previousResult, "8+2")
    }

    func testReplacingDivideOperatorDoesNotEnterUndefinedState() {
        tapNumber("8")
        tap(.divide)
        tap(.plus)
        tapNumber("2")
        tap(.equal)

        XCTAssertEqual(viewModel.result, "10")
    }

    func testCalculationResultRetainsInternalPrecision() {
        tapNumber("1")
        tap(.divide)
        tapNumber("3")
        tap(.equal)
        XCTAssertEqual(viewModel.result, "0.333333")

        tap(.multiply)
        tapNumber("3")
        tap(.equal)
        XCTAssertEqual(viewModel.result, "1")
    }

    func testRevertImmediatelyAfterOperatorDoesNotCorruptExpression() {
        tapNumber("12")
        tap(.plus)
        tap(.revert)

        XCTAssertEqual(viewModel.currentExpression, "12+")
        tapNumber("3")
        tap(.equal)
        XCTAssertEqual(viewModel.result, "15")
        XCTAssertEqual(viewModel.previousResult, "12+3")
    }

    func testMaximumInputDigits() {
        tapNumber("12345678901")
        XCTAssertEqual(viewModel.result, "1234567890")
    }

    func testMaximumLengthIntegerMultiplicationIsExact() {
        tapNumber("9999999999")
        tap(.multiply)
        tapNumber("9999999999")
        tap(.equal)

        XCTAssertEqual(viewModel.result, "99999999980000000001")
    }

    func testNegativeAndDecimalInputsHonorMaximumDigitCount() {
        tap(.plusMinus)
        tapNumber("1234567890")
        XCTAssertEqual(viewModel.result, "-1234567890")

        viewModel = makeViewModel()
        tapNumber("1.234567890")
        XCTAssertEqual(viewModel.result, "1.234567890")
    }

    func testRevertNegativeSecondOperandKeepsExpressionAndValueConsistent() {
        tapNumber("5")
        tap(.plus)
        tap(.plusMinus)
        tapNumber("2")
        tap(.revert)

        XCTAssertEqual(viewModel.result, "0")
        XCTAssertEqual(viewModel.currentExpression, "5+")

        tapNumber("3")
        tap(.equal)
        XCTAssertEqual(viewModel.result, "8")
        XCTAssertEqual(viewModel.previousResult, "5+3")
    }

    func testPercentageCompletesExpressionState() {
        tapNumber("200")
        tap(.plus)
        tapNumber("10")
        tap(.percentage)

        XCTAssertEqual(viewModel.result, "220")
        XCTAssertEqual(viewModel.currentExpression, "")
        XCTAssertEqual(viewModel.previousResult, "200+10%")
    }

    func testRepeatedEqualReusesLastOperation() {
        tapNumber("2")
        tap(.plus)
        tapNumber("3")
        tap(.equal)
        XCTAssertEqual(viewModel.result, "5")

        tap(.equal)
        XCTAssertEqual(viewModel.result, "8")

        tap(.equal)
        XCTAssertEqual(viewModel.result, "11")
    }

    func testRepeatedEqualForEachOperator() {
        let cases: [(DialPad, String, String, String, String)] = [
            (.plus, "2", "3", "5", "8"),
            (.substract, "10", "2", "8", "6"),
            (.multiply, "3", "2", "6", "12"),
            (.divide, "20", "2", "10", "5")
        ]

        for (operation, lhs, rhs, firstResult, repeatedResult) in cases {
            viewModel = makeViewModel()
            tapNumber(lhs)
            tap(operation)
            tapNumber(rhs)
            tap(.equal)
            XCTAssertEqual(viewModel.result, firstResult)

            tap(.equal)
            XCTAssertEqual(viewModel.result, repeatedResult)
        }
    }

    func testRepeatedEqualStateDoesNotLeakIntoNewInputOrPercentage() {
        tapNumber("2")
        tap(.plus)
        tapNumber("3")
        tap(.equal)
        tap(.equal)

        tapNumber("4")
        tap(.equal)
        XCTAssertEqual(viewModel.result, "4")

        viewModel = makeViewModel()
        tapNumber("2")
        tap(.plus)
        tapNumber("3")
        tap(.equal)
        tap(.percentage)
        tap(.equal)
        XCTAssertEqual(viewModel.result, "0.05")
    }

    func testPercentageAfterCompletedCalculationUsesDisplayedResult() {
        tapNumber("2")
        tap(.plus)
        tapNumber("3")
        tap(.equal)
        tap(.percentage)

        XCTAssertEqual(viewModel.result, "0.05")
        XCTAssertEqual(viewModel.previousResult, "5%")
    }

    func testMaximumDigitCountAppliesToSecondOperand() {
        tapNumber("1")
        tap(.plus)
        tap(.plusMinus)
        tapNumber("12345678901")
        XCTAssertEqual(viewModel.result, "-1234567890")
        XCTAssertEqual(viewModel.currentExpression, "1+(-1234567890)")

        viewModel = makeViewModel()
        tapNumber("1")
        tap(.plus)
        tapNumber("1.2345678901")
        XCTAssertEqual(viewModel.result, "1.234567890")
        XCTAssertEqual(viewModel.currentExpression, "1+1.234567890")
    }

    func testRevertKeepsExpressionConsistentAcrossOperandForms() {
        tapNumber("5")
        tap(.plus)
        tapNumber("12.3")
        tap(.revert)
        XCTAssertEqual(viewModel.result, "12.")
        XCTAssertEqual(viewModel.currentExpression, "5+12.")

        viewModel = makeViewModel()
        tapNumber("5")
        tap(.plus)
        tap(.plusMinus)
        tapNumber("12")
        tap(.revert)
        XCTAssertEqual(viewModel.result, "-1")
        XCTAssertEqual(viewModel.currentExpression, "5+(-1)")

        tap(.revert)
        XCTAssertEqual(viewModel.result, "0")
        XCTAssertEqual(viewModel.currentExpression, "5+")
    }

    func testAllSmallIntegerOperandCombinations() {
        let operations: [(DialPad, (Decimal, Decimal) -> Decimal)] = [
            (.plus, +),
            (.substract, -),
            (.multiply, *),
            (.divide, /)
        ]

        for lhs in -20...20 {
            for rhs in -20...20 {
                for (operation, calculate) in operations {
                    if operation == .divide && rhs == 0 { continue }

                    viewModel = makeViewModel()
                    tapSignedNumber(String(lhs))
                    tap(operation)
                    tapSignedNumber(String(rhs))
                    tap(.equal)

                    let expected = calculate(Decimal(lhs), Decimal(rhs)).clean(places: 6)
                    XCTAssertEqual(
                        viewModel.result,
                        expected,
                        "\(lhs) \(operation.rawValue) \(rhs)"
                    )
                }
            }
        }
    }

    func testDecimalOperandMatrix() {
        let operands = ["0.1", "1.25", "-2.5", "99.999"]
        let operations: [(DialPad, (Decimal, Decimal) -> Decimal)] = [
            (.plus, +),
            (.substract, -),
            (.multiply, *),
            (.divide, /)
        ]

        for lhs in operands {
            for rhs in operands {
                for (operation, calculate) in operations {
                    viewModel = makeViewModel()
                    tapSignedNumber(lhs)
                    tap(operation)
                    tapSignedNumber(rhs)
                    tap(.equal)

                    let expected = calculate(
                        Decimal(string: lhs)!,
                        Decimal(string: rhs)!
                    ).clean(places: 6)
                    XCTAssertEqual(
                        viewModel.result,
                        expected,
                        "\(lhs) \(operation.rawValue) \(rhs)"
                    )
                }
            }
        }
    }
    
    // MARK: - 综合测试报告
    func testFullReport() {
        print("\n========== 计算器功能测试报告 ==========\n")
        
        // 基础运算
        tapNumber("9")
        tap(.divide)
        tapNumber("8")
        tap(.equal)
        print("✓ 9 ÷ 8 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "1.125")
        
        viewModel.reset()
        
        tapNumber("7")
        tap(.multiply)
        tapNumber("8")
        tap(.equal)
        print("✓ 7 × 8 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "56")
        
        viewModel.reset()
        
        tapNumber("15")
        tap(.substract)
        tapNumber("7")
        tap(.equal)
        print("✓ 15 − 7 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "8")
        
        viewModel.reset()
        
        tapNumber("23")
        tap(.plus)
        tapNumber("45")
        tap(.equal)
        print("✓ 23 + 45 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "68")
        
        viewModel.reset()
        
        // 负数运算
        tapNumber("9")
        viewModel.set(operation: .plusMinus)
        tap(.multiply)
        viewModel.set(operation: .plusMinus)
        tapNumber("6")
        tap(.equal)
        print("✓ -9 × -6 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "54")
        
        viewModel.reset()
        
        // 除以零
        tapNumber("1")
        tap(.divide)
        tapNumber("0")
        tap(.equal)
        print("✓ 1 ÷ 0 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "未定义")
        
        viewModel.reset()
        
        // 退格
        tapNumber("123")
        tap(.revert)
        print("✓ 123 → 退格 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "12")

        viewModel.reset()

        print("\n========== 测试完成 ==========\n")
    }

    // MARK: - RevertHandler 边界测试:右操作数被完整退格后,后续运算符必须替换,不能产生异常算式

    func testRevertThenOperatorDoesNotProduceDoubleOperatorExpression() {
        // 5 + 0 → 退格 → display="0", expression="5+", pendingOp=plus
        // 如果不修复,继续按 "+" 会先计算 5+0=5,再把 "+" 追加到 "5+" 末尾,得到 "5++"。
        tapNumber("5")
        tap(.plus)
        tap(.zero)
        tap(.revert)

        XCTAssertEqual(viewModel.result, "0")
        XCTAssertEqual(viewModel.currentExpression, "5+")

        tap(.plus)
        XCTAssertEqual(viewModel.currentExpression, "5+")

        tapNumber("3")
        tap(.equal)
        XCTAssertEqual(viewModel.result, "8")
        XCTAssertEqual(viewModel.previousResult, "5+3")
    }

    func testRevertNegativeThenOperatorDoesNotProduceDoubleOperatorExpression() {
        // 5 + -2 → 退格(-2 → 0)→ "+" → 5 + 3 = 8
        tapNumber("5")
        tap(.plus)
        tap(.plusMinus)
        tapNumber("2")
        tap(.revert)

        XCTAssertEqual(viewModel.result, "0")
        XCTAssertEqual(viewModel.currentExpression, "5+")

        tap(.substract)
        XCTAssertEqual(viewModel.currentExpression, "5−")

        tapNumber("3")
        tap(.equal)
        XCTAssertEqual(viewModel.result, "2")
        XCTAssertEqual(viewModel.previousResult, "5−3")
    }

    func testRevertThenReplaceWithDifferentOperator() {
        // 5 × 0 → 退格 → "+" → 应替换待执行运算符为 "+",而不是计算 5×0 后再追加
        tapNumber("5")
        tap(.multiply)
        tap(.zero)
        tap(.revert)

        XCTAssertEqual(viewModel.currentExpression, "5×")

        tap(.plus)
        XCTAssertEqual(viewModel.currentExpression, "5+")
        tapNumber("3")
        tap(.equal)
        XCTAssertEqual(viewModel.result, "8")
        XCTAssertEqual(viewModel.previousResult, "5+3")
    }

    // MARK: - 【临时】超限输入复现（定位后删除）

    func testReproMaxDigitsBlankDisplay() {
        for i in 1...25 {
            tap(.eight)
            NSLog(
                "[REPRO-MAXDIGITS] tap %d -> result=%@ expr=%@ primary=%@",
                i, viewModel.result, viewModel.currentExpression, viewModel.primaryDisplayText
            )
        }
        NSLog("[REPRO-MAXDIGITS] final result=%@ expr=%@", viewModel.result, viewModel.currentExpression)
    }

    func testReproMaxDigitsBlankDisplaySnapshot() {
        for _ in 1...25 { tap(.eight) }

        let view = MainView(appModel: self.viewModel)
            .frame(width: 402, height: 874)

        let controller = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.view.layoutIfNeeded()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
        controller.view.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer(bounds: controller.view.bounds)
        let image = renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
        if let data = image.pngData() {
            try? data.write(to: URL(fileURLWithPath: "/tmp/repro-maxdigits.png"))
        }
        NSLog("[REPRO-MAXDIGITS] snapshot saved, resultText=%@", viewModel.primaryDisplayText)
    }

    // 【临时】字体渲染变体诊断（定位后删除）
    func testReproFontVariantMatrix() {
        let s10 = "8888888888"
        let matrix = VStack(alignment: .trailing, spacing: 18) {
            ForEach(0..<10, id: \.self) { idx in
                switch idx {
                case 0:
                    Text(s10).font(.system(size: 54, weight: .medium, design: .rounded))
                        .minimumScaleFactor(0.35).lineLimit(1).allowsTightening(true)
                case 1:
                    Text(s10).font(.system(size: 54, weight: .medium))
                        .minimumScaleFactor(0.35).lineLimit(1).allowsTightening(true)
                case 2:
                    Text(s10).font(.system(size: 54, weight: .light, design: .rounded))
                        .minimumScaleFactor(0.35).lineLimit(1).allowsTightening(true)
                case 3:
                    Text(s10).font(.system(size: 54, weight: .medium, design: .rounded))
                        .lineLimit(1)
                case 4:
                    Text(s10).font(.system(size: 40, weight: .medium, design: .rounded))
                        .minimumScaleFactor(0.35).lineLimit(1).allowsTightening(true)
                case 5:
                    Text("888888888").font(.system(size: 54, weight: .medium, design: .rounded))
                        .minimumScaleFactor(0.35).lineLimit(1).allowsTightening(true)
                case 6:
                    Text("1234567890").font(.system(size: 54, weight: .medium, design: .rounded))
                        .minimumScaleFactor(0.35).lineLimit(1).allowsTightening(true)
                case 7:
                    Text(s10).font(.system(size: 70, weight: .light))
                        .minimumScaleFactor(0.5).lineLimit(1)
                case 8:
                    Text(s10).font(.system(size: 54, weight: .medium, design: .rounded))
                        .minimumScaleFactor(0.35).lineLimit(1)
                default:
                    Text(" ").font(.system(size: 20, weight: .regular, design: .rounded))
                        .lineLimit(1).minimumScaleFactor(0.6)
                }
            }
        }
        .frame(width: 370)
        .padding(16)
        .background(Color.black)

        let controller = UIHostingController(
            rootView: matrix.frame(width: 402, height: 874)
        )
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.view.layoutIfNeeded()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
        controller.view.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer(bounds: controller.view.bounds)
        let image = renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
        if let data = image.pngData() {
            try? data.write(to: URL(fileURLWithPath: "/tmp/repro-variants.png"))
        }
        NSLog("[REPRO-MAXDIGITS] variant matrix saved")
    }
}
