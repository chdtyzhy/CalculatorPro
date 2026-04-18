//
//  CalculatorProApp.swift
//  计算器应用入口
//

import SwiftUI
import Combine

@main
struct CalculatorProApp: App {
    // 暂时注释掉复杂的 AppState
    // @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            // 使用新版计算器视图
            CalculatorView()
                // .environmentObject(appState)
                .onAppear {
                    configureAppearance()
                }
        }
    }
    
    private func configureAppearance() {
        // 简化外观配置
        #if os(iOS)
        // 只在 iOS 上配置基本外观
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        #endif
    }
}

// MARK: - 应用状态管理
class AppState: ObservableObject {
    @Published var isActive = true
    @Published var launchCount = 0
    @Published var lastLaunchDate = Date()
    @Published var theme: AppTheme = .system
    
    init() {
        loadAppData()
    }
    
    private func loadAppData() {
        let defaults = UserDefaults.standard
        
        // 加载启动数据
        launchCount = defaults.integer(forKey: "launchCount")
        if let lastDate = defaults.object(forKey: "lastLaunchDate") as? Date {
            lastLaunchDate = lastDate
        }
        
        // 加载主题设置
        if let themeName = defaults.string(forKey: "appTheme"),
           let savedTheme = AppTheme(rawValue: themeName) {
            theme = savedTheme
        }
        
        // 更新启动数据
        launchCount += 1
        lastLaunchDate = Date()
        
        defaults.set(launchCount, forKey: "launchCount")
        defaults.set(lastLaunchDate, forKey: "lastLaunchDate")
    }
    
    func saveTheme() {
        UserDefaults.standard.set(theme.rawValue, forKey: "appTheme")
    }
}

// MARK: - 主题管理
enum AppTheme: String, CaseIterable, Equatable {
    case light = "浅色"
    case dark = "深色"
    case system = "跟随系统"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

// MARK: - 设置视图（已移除，因为不被使用）