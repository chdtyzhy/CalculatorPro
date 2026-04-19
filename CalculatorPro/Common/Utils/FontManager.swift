import SwiftUI

// 字体管理（未使用）
enum TypefaceOne {
    case regular
    
    func font(size: CGFloat) -> Font {
        switch self {
        case .regular:
            return .custom("BungeeLayers-Regular", size: size)
        }
    }
}
