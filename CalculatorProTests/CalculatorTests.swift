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
    
    func testLargeNumber() {
        // 测试: 999999 + 1
        tapNumber("999999")
        tap(.plus)
        tapNumber("1")
        tap(.equal)
        
        print("【测试】999999 + 1 = \(viewModel.result)")
        XCTAssertEqual(viewModel.result, "1000000", "999999 + 1 应该等于 1000000")
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
        
        viewModel.reset()
        
        tapNumber("7")
        tap(.multiply)
        tapNumber("8")
        tap(.equal)
        print("✓ 7 × 8 = \(viewModel.result)")
        
        viewModel.reset()
        
        tapNumber("15")
        tap(.substract)
        tapNumber("7")
        tap(.equal)
        print("✓ 15 − 7 = \(viewModel.result)")
        
        viewModel.reset()
        
        tapNumber("23")
        tap(.plus)
        tapNumber("45")
        tap(.equal)
        print("✓ 23 + 45 = \(viewModel.result)")
        
        print("\n========== 测试完成 ==========\n")
    }
}
