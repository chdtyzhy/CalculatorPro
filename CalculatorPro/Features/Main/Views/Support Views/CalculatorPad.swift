import SwiftUI

// 单个计算器按钮
struct CalculatorPad: View {
    @EnvironmentObject var appModel: MainViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    // 按钮点击动画缩放比例
    @State var scale: CGFloat = 1
    @State var foregroundColor = Color.white
    
    let animationDuration: TimeInterval = 0.15
    
    var dialPad: DialPad
    var color: Color = .label
    
    // 按钮背景颜色（根据类型区分）
    private var buttonBackgroundColor: Color {
        switch dialPad {
        case .clear, .plusMinus, .percentage, .revert:
            // 功能按钮：浅灰色
            return Color(white: 0.65)
        case .divide, .multiply, .substract, .plus, .equal:
            // 运算符：橙色
            return Color.orange
        default:
            // 数字按钮：深灰色
            return Color(white: 0.22)
        }
    }
    
    // 按钮文字颜色
    private var buttonForegroundColor: Color {
        switch dialPad {
        case .clear, .plusMinus, .percentage, .revert:
            // 功能按钮：黑色文字
            return Color.black
        default:
            // 其他：白色文字
            return Color.white
        }
    }
    
    // 按钮显示的文字（使用细线符号）
    private var displayText: String {
        switch dialPad {
        case .multiply:
            return "×"  // 细线乘号
        case .divide:
            return "÷"  // 除号
        case .substract:
            return "−"  // 细线减号
        case .plus:
            return "+"  // 加号
        case .equal:
            return "="  // 等号
        default:
            return dialPad.rawValue
        }
    }
    
    var body: some View {
        Circle()
            .foregroundColor(buttonBackgroundColor)
            .overlay(
                Text(displayText)
                    .font(.system(size: 34, weight: .regular, design: .default))
                    .foregroundColor(buttonForegroundColor)
            )
            .aspectRatio(1, contentMode: .fit)
            .scaleEffect(scale)
            .onTapGesture {
                // 执行对应操作
                self.appModel.performAction(for: dialPad)
                
                // 点击动画效果
                withAnimation(.easeInOut(duration: animationDuration)) {
                    scale = 0.95
                }
                
                // 恢复原始大小
                Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: false) { _ in
                    withAnimation(.default) {
                        scale = 1
                    }
                }
            }
    }
}

struct CalculatorPad_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorPad(dialPad: .one)
            .environmentObject(MainViewModel())
            .frame(width: 70, height: 70)
    }
}
