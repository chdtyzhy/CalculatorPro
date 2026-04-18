//
//  Config.template.swift
//  环境配置模板
//
//  使用方法：
//  1. 复制此文件为 Config.swift
//  2. 填写实际配置值
//  3. 确保 Config.swift 在 .gitignore 中
//

import Foundation

struct AppConfig {
    // API 配置
    static let apiBaseURL = "https://api.example.com"
    static let apiKey = "YOUR_API_KEY_HERE"
    
    // 功能开关
    static let enableAnalytics = true
    static let enableDebugLogs = false
    
    // 应用设置
    static let appName = "CalculatorPro"
    static let version = "1.0.0"
    static let buildNumber = "1"
}

// 在代码中使用：
// let url = AppConfig.apiBaseURL + "/endpoint"