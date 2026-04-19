import SwiftUI

// 计算结果显示区域
struct DisplayView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    
    let height: CGFloat
    let colorScheme: ColorScheme
    let duration: TimeInterval
    
    // 格式化显示内容（将运算符符号替换为显示符号）
    private var displayText: String {
        return mainViewModel.result
            .replacingOccurrences(of: "/", with: "÷")
            .replacingOccurrences(of: "*", with: "×")
            .replacingOccurrences(of: "-", with: "−")
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // 表达式显示区域（如 "89×6"，小字体灰色）
            if !mainViewModel.currentExpression.isEmpty {
                Text(mainViewModel.currentExpression)
                    .foregroundColor(Color(white: 0.5))
                    .font(.system(size: 28, weight: .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            
            Spacer(minLength: 0)
            
            // 结果显示区域（大字体白色）
            ZStack(alignment: .bottomTrailing) {
                // 默认显示0
                Text("0")
                    .foregroundColor(.white)
                    .font(.system(size: 70, weight: .light))
                    .opacity(self.mainViewModel.result.isEmpty ? 0.6 : 0)
                
                // 当前输入或计算结果
                Text(displayText)
                    .foregroundColor(.white)
                    .font(.system(size: 70, weight: .light))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: height * 0.25, alignment: .bottomTrailing)
        .padding(.horizontal, 16)
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView(height: 818, colorScheme: .dark, duration: 0.3)
            .environmentObject(MainViewModel())
            .padding(2)
    }
}
