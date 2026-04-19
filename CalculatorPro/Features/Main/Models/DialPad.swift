import Foundation

// 计算器按键枚举
enum DialPad: String {
    case zero = "0"
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case clear = "AC"           // 清空
    case plusMinus = "+/-"      // 正负切换
    case percentage = "%"       // 百分比
    case divide = "÷"           // 除号
    case multiply = "x"         // 乘号
    case substract = "-"        // 减号
    case plus = "+"             // 加号
    case decimal = "."          // 小数点
    case revert = "⌫"           // 退格删除
    case equal = "="            // 等于
    
    // 获取运算符对应的计算符号
    func getOperator() -> String {
        switch self {
        case .plus:
            return "+"
        case .substract:
            return "-"
        case .multiply:
            return "*"
        case .divide:
            return "/"
        default:
            return ""
        }
    }
}
