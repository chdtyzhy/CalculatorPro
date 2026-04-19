import XCTest
@testable import CalculatorPro

// 计算器功能测试
// 对比系统计算器与本项目的计算结果

class CalculatorTests: XCTestCase {
    
    var viewModel: MainViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = MainViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
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
        tapNumber("9")
        
        print("【测试】+/- → 9 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "-9", "先切换正负号再输入9应该是 -9")
    }
    
    func testMinusAsNegativeSign() {
        // 测试: 初始状态按减号输入负数 -9
        tap(.substract)  // 初始状态按减号作为负号
        tapNumber("9")
        
        print("【测试】初始按减号 → 9 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "-9", "初始按减号输入9应该是 -9")
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
    
    func testNegativeMultiplyByNegativeUsingMinusSign() {
        // 测试: -9 × -6 = 54 (使用减号作为负号方式)
        // 输入 -9
        tapNumber("9")
        tap(.substract)  // 作为运算符，结果应该保留
        viewModel.reset()
        // 重新用正确方式：先输入 9，切换正负
        tapNumber("9")
        viewModel.set(operation: .plusMinus)  // -9
        tap(.multiply)  // 乘号，result 重置为 0
        tap(.substract)  // 减号作为负号（因为 resultReady = true）
        tapNumber("6")  // -6
        tap(.equal)
        
        print("【测试】-9 × -6 (使用减号作为负号) = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "54", "-9 × -6 应该等于 54")
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
}
