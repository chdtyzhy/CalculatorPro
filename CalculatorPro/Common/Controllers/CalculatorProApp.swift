import SwiftUI
import StoreKit

// 应用入口
@main
struct CalculatorProApp: App {
    private let appReviewManager = AppReviewManager()

    var body: some Scene {
        WindowGroup {
            MainView()
                .modifier(AppReviewRequestModifier(manager: appReviewManager))
        }
    }
}

private struct AppReviewRequestModifier: ViewModifier {
    @Environment(\.requestReview) private var requestReview
    let manager: AppReviewManager

    func body(content: Content) -> some View {
        content.onAppear {
            guard !ProcessInfo.processInfo.arguments.contains(
                "-disableAutomaticReviewRequests"
            ) else {
                return
            }

            if manager.recordLaunchAndShouldRequestAutomaticReview() {
                // StoreKit 决定评分弹窗是否实际显示。
                requestReview()
            }
        }
    }
}
