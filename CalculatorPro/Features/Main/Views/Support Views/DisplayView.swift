import SwiftUI

// 计算结果显示区域
struct DisplayView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    
    let height: CGFloat
    let colorScheme: ColorScheme
    let duration: TimeInterval
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // 默认显示0
            Text("0")
                .foregroundColor(.white)
                .font(.system(size: 70, weight: .light))
                .opacity(self.mainViewModel.result.isEmpty ? 0.6 : 0)
            
            // 当前输入或计算结果
            Text(mainViewModel.result)
                .foregroundColor(.white)
                .font(.system(size: 70, weight: .light))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: height * 0.2, alignment: .bottomTrailing)
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
