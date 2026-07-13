import SwiftUI

// 主界面视图
struct MainView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @StateObject var appModel: MainViewModel = MainViewModel()
    
    let duration: TimeInterval = 0.3
    
    var body: some View {
        GeometryReader { proxy in
            let width: CGFloat = proxy.size.width
            // 按钮宽度按屏幕宽度计算（4 列），保持最大尺寸
            let buttonWidth = (width - 16 * 2 - 12 * 3) / 4
            // 键盘总高度 = 5 行按钮 + 4 个间距，使按钮正好填满
            let keypadHeight = buttonWidth * 5 + 12 * 4
            
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                // 黑色背景
                Color.background
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 0) {
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
                    .padding(.top, 10)
                    
                    // 显示屏（填满中间剩余空间，"0" 底部对齐贴近键盘）
                    DisplayView(height: 0, colorScheme: colorScheme, duration: duration)
                        .environmentObject(appModel)
                        .padding(.horizontal, -18)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // 键盘区域（固定高度，贴底）
                    CalculatorButtons(stackSpacing: 12)
                        .environmentObject(appModel)
                        .frame(height: keypadHeight)
                }
                .padding(.horizontal, 16)
                .padding(.top, 40)
                .padding(.bottom, 40)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
