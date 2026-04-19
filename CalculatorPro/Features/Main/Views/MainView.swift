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
                
                VStack(alignment: .leading, spacing: 16) {
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
                    
                    // 留白区域
                    Spacer(minLength: height * 0.08)
                    
                    // 显示屏
                    DisplayView(height: height, colorScheme: colorScheme, duration: duration)
                        .environmentObject(appModel)
                        .padding(.horizontal, -18)
                    
                    Spacer(minLength: 16)
                    
                    // 键盘区域
                    CalculatorButtons(stackSpacing: 12)
                        .environmentObject(appModel)
                        .frame(height: height * 0.58)
                }
                .padding(.horizontal, 16)
                .padding(.top, 50)
                .padding(.bottom, 30)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
