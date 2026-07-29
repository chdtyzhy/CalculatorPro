import SwiftUI

// 计算结果显示区域
struct DisplayView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    
    let height: CGFloat
    let colorScheme: ColorScheme
    let duration: TimeInterval
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // 计算完成后，原生计算器会将完整算式缩到结果上方。
            if !mainViewModel.secondaryDisplayText.isEmpty {
                Text(mainViewModel.secondaryDisplayText)
                    .foregroundColor(.white.opacity(0.58))
                    .font(.system(size: 22, weight: .regular, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            
            Spacer(minLength: 0)
            
            // 输入过程中显示完整算式；计算完成后显示结果。
            Text(mainViewModel.primaryDisplayText)
                .foregroundColor(.white)
                .font(.system(size: 58, weight: .medium, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.displayBackground)
        )
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView(height: 818, colorScheme: .dark, duration: 0.3)
            .environmentObject(MainViewModel())
            .padding(2)
    }
}
