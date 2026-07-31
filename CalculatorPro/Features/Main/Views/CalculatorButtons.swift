import SwiftUI

// 计算器键盘容器
struct CalculatorButtons: View {
    @EnvironmentObject var appModel: MainViewModel
    var stackSpacing: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let buttonWidth = (geometry.size.width - stackSpacing * 3) / 4
            let buttonHeight = (geometry.size.height - stackSpacing * 4) / 5
            
            if #available(iOS 26.0, *) {
                GlassEffectContainer(spacing: stackSpacing) {
                    keypad(buttonWidth: buttonWidth, buttonHeight: buttonHeight)
                }
            } else {
                keypad(buttonWidth: buttonWidth, buttonHeight: buttonHeight)
            }
        }
        .environmentObject(appModel)
    }

    private func keypad(buttonWidth: CGFloat, buttonHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: stackSpacing) {
                // 第一行：删除、清空、百分号、除号
            HStack(spacing: stackSpacing) {
                    CalculatorPad(dialPad: .revert)
                        .frame(width: buttonWidth, height: buttonHeight)
                    CalculatorPad(dialPad: .clear)
                        .frame(width: buttonWidth, height: buttonHeight)
                    CalculatorPad(dialPad: .percentage)
                        .frame(width: buttonWidth, height: buttonHeight)
                    CalculatorPad(dialPad: .divide)
                        .frame(width: buttonWidth, height: buttonHeight)
            }
                
                // 第二行：7、8、9、乘号
            HStack(spacing: stackSpacing) {
                    CalculatorPad(dialPad: .seven)
                        .frame(width: buttonWidth, height: buttonHeight)
                    CalculatorPad(dialPad: .eight)
                        .frame(width: buttonWidth, height: buttonHeight)
                    CalculatorPad(dialPad: .nine)
                        .frame(width: buttonWidth, height: buttonHeight)
                    CalculatorPad(dialPad: .multiply)
                        .frame(width: buttonWidth, height: buttonHeight)
            }
                
                // 第三行：4、5、6、减号
            HStack(spacing: stackSpacing) {
                    CalculatorPad(dialPad: .four)
                        .frame(width: buttonWidth, height: buttonHeight)
                    CalculatorPad(dialPad: .five)
                        .frame(width: buttonWidth, height: buttonHeight)
                    CalculatorPad(dialPad: .six)
                        .frame(width: buttonWidth, height: buttonHeight)
                    CalculatorPad(dialPad: .substract)
                        .frame(width: buttonWidth, height: buttonHeight)
            }
                
                // 第四行：1、2、3、加号
            HStack(spacing: stackSpacing) {
                    CalculatorPad(dialPad: .one)
                        .frame(width: buttonWidth, height: buttonHeight)
                    CalculatorPad(dialPad: .two)
                        .frame(width: buttonWidth, height: buttonHeight)
                    CalculatorPad(dialPad: .three)
                        .frame(width: buttonWidth, height: buttonHeight)
                    CalculatorPad(dialPad: .plus)
                        .frame(width: buttonWidth, height: buttonHeight)
            }
                
                // 第五行：正负号、0、小数点、等号（与系统计算器一致）
            HStack(spacing: stackSpacing) {
                    CalculatorPad(dialPad: .plusMinus)
                        .frame(width: buttonWidth, height: buttonHeight)
                    CalculatorPad(dialPad: .zero)
                        .frame(width: buttonWidth, height: buttonHeight)
                    CalculatorPad(dialPad: .decimal)
                        .frame(width: buttonWidth, height: buttonHeight)
                    CalculatorPad(dialPad: .equal)
                        .frame(width: buttonWidth, height: buttonHeight)
            }
        }
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
