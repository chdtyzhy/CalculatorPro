import SwiftUI

// 主界面视图
struct MainView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @StateObject var appModel: MainViewModel = MainViewModel()
    
    let duration: TimeInterval = 0.3
    
    var body: some View {
        GeometryReader { proxy in
            let height: CGFloat = proxy.size.height
            
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                // 黑色背景
                Color.background
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 20) {
                    // 顶部工具栏
                    HStack {
                        // 历史记录图标
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // 计算器模式图标
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 22))
                            .foregroundColor(.orange)
                    }
                    
                    // 显示屏
                    DisplayView(height: height, colorScheme: colorScheme, duration: duration)
                        .environmentObject(appModel)
                        .padding(.horizontal, -18)
                    
                    Spacer(minLength: 10)
                    
                    // 键盘区域
                    CalculatorButtons(stackSpacing: 12)
                        .environmentObject(appModel)
                        .frame(height: height * 0.65)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
