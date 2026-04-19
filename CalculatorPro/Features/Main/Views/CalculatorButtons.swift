import SwiftUI

// 计算器键盘容器
struct CalculatorButtons: View {
    @EnvironmentObject var appModel: MainViewModel
    var stackSpacing: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            // 计算每个按钮的宽度（4列布局）
            let buttonWidth = (geometry.size.width - stackSpacing * 3) / 4
            
            VStack(alignment: .leading, spacing: stackSpacing) {
                // 第一行：删除、清空、百分号、除号
                HStack(spacing: stackSpacing) {
                    CalculatorPad(dialPad: .revert)
                        .frame(width: buttonWidth, height: buttonWidth)
                    CalculatorPad(dialPad: .clear)
                        .frame(width: buttonWidth, height: buttonWidth)
                    CalculatorPad(dialPad: .percentage)
                        .frame(width: buttonWidth, height: buttonWidth)
                    CalculatorPad(dialPad: .divide)
                        .frame(width: buttonWidth, height: buttonWidth)
                }
                
                // 第二行：7、8、9、乘号
                HStack(spacing: stackSpacing) {
                    CalculatorPad(dialPad: .seven)
                        .frame(width: buttonWidth, height: buttonWidth)
                    CalculatorPad(dialPad: .eight)
                        .frame(width: buttonWidth, height: buttonWidth)
                    CalculatorPad(dialPad: .nine)
                        .frame(width: buttonWidth, height: buttonWidth)
                    CalculatorPad(dialPad: .multiply)
                        .frame(width: buttonWidth, height: buttonWidth)
                }
                
                // 第三行：4、5、6、减号
                HStack(spacing: stackSpacing) {
                    CalculatorPad(dialPad: .four)
                        .frame(width: buttonWidth, height: buttonWidth)
                    CalculatorPad(dialPad: .five)
                        .frame(width: buttonWidth, height: buttonWidth)
                    CalculatorPad(dialPad: .six)
                        .frame(width: buttonWidth, height: buttonWidth)
                    CalculatorPad(dialPad: .substract)
                        .frame(width: buttonWidth, height: buttonWidth)
                }
                
                // 第四行：1、2、3、加号
                HStack(spacing: stackSpacing) {
                    CalculatorPad(dialPad: .one)
                        .frame(width: buttonWidth, height: buttonWidth)
                    CalculatorPad(dialPad: .two)
                        .frame(width: buttonWidth, height: buttonWidth)
                    CalculatorPad(dialPad: .three)
                        .frame(width: buttonWidth, height: buttonWidth)
                    CalculatorPad(dialPad: .plus)
                        .frame(width: buttonWidth, height: buttonWidth)
                }
                
                // 第五行：0（占2格宽度）、小数点、等号
                HStack(spacing: stackSpacing) {
                    CalculatorPad(dialPad: .zero)
                        .frame(width: buttonWidth * 2 + stackSpacing, height: buttonWidth)
                    CalculatorPad(dialPad: .decimal)
                        .frame(width: buttonWidth, height: buttonWidth)
                    CalculatorPad(dialPad: .equal)
                        .frame(width: buttonWidth, height: buttonWidth)
                }
            }
        }
        .environmentObject(appModel)
    }
}

struct CalculatorButtons_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorButtons(stackSpacing: 12)
            .frame(height: 450)
            .padding(24)
            .environmentObject(MainViewModel())
    }
}
