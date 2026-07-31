import SwiftUI

// 计算结果显示区域
struct DisplayView: View {
    @Environment(\.calculatorTheme) private var theme
    @EnvironmentObject var mainViewModel: MainViewModel
    
    let height: CGFloat
    let colorScheme: ColorScheme
    let duration: TimeInterval

    private var expressionText: String {
        if !mainViewModel.secondaryDisplayText.isEmpty {
            return mainViewModel.secondaryDisplayText
        }
        return mainViewModel.currentExpression.isEmpty ? "" : mainViewModel.primaryDisplayText
    }

    private var resultText: String {
        mainViewModel.currentExpression.isEmpty
            ? mainViewModel.primaryDisplayText
            : mainViewModel.result
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            Text(expressionText.isEmpty ? " " : expressionText)
                .foregroundColor(theme.secondaryInk)
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .accessibilityHidden(true)
            
            Spacer(minLength: 0)
            
            Text(resultText)
                .foregroundColor(theme.primaryInk)
                .font(.system(size: 54, weight: .medium, design: .rounded))
                .minimumScaleFactor(0.35)
                .lineLimit(1)
                .allowsTightening(true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(.horizontal, 4)
        .padding(.vertical, 12)
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView(height: 818, colorScheme: .dark, duration: 0.3)
            .environmentObject(MainViewModel())
            .padding(2)
    }
}
