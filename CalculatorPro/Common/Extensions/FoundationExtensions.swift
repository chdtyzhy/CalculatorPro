import UIKit

// Double 扩展：格式化输出
extension Double {
    // 清理数字显示：整数不显示小数点，小数去除末尾的0
    func clean(places: Int) -> String {
        if self.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", self)
        }
        let format = "%." + String(places) + "f"
        var formatted = String(format: format, self)
        while formatted.hasSuffix("0") {
            formatted.removeLast()
        }
        if formatted.hasSuffix(".") {
            formatted.removeLast()
        }
        return formatted
    }
}
