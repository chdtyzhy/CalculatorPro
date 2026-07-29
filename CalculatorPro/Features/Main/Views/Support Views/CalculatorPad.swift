import SwiftUI

// 单个计算器按钮
struct CalculatorPad: View {
    @EnvironmentObject var appModel: MainViewModel
    var dialPad: DialPad
    
    // 按钮背景颜色（根据类型区分）
    private var buttonBackgroundColor: Color {
        switch dialPad {
        case .clear, .plusMinus, .percentage, .revert:
            return .functionKey
        case .divide, .multiply, .substract, .plus:
            return .operationKey
        case .equal:
            return .equalKey
        default:
            return .numberKey
        }
    }
    
    // 按钮文字颜色
    private var buttonForegroundColor: Color {
        switch dialPad {
        case .clear, .plusMinus, .percentage, .revert:
            return .primaryInk
        case .divide, .multiply, .substract, .plus, .equal:
            return Color.white
        default:
            return .primaryInk
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
        Button {
            appModel.performAction(for: dialPad)
        } label: {
            Text(displayText)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundColor(buttonForegroundColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .calculatorKeySurface(color: buttonBackgroundColor)
        .accessibilityLabel(displayText)
    }
}

private extension View {
    @ViewBuilder
    func calculatorKeySurface(color: Color) -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(
                .regular.tint(color).interactive(),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
        } else {
            background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(color)
                    .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
            )
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
