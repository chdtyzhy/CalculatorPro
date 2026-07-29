import UIKit

// Decimal 扩展：格式化输出
extension Decimal {
    // 清理数字显示：整数不显示小数点，小数去除末尾的0
    func clean(places: Int) -> String {
        var value = self
        var rounded = Decimal()
        NSDecimalRound(&rounded, &value, places, .plain)
        return NSDecimalNumber(decimal: rounded).stringValue
    }
}
