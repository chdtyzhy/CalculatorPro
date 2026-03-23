//
//  ScreenAdapter.swift
//  CalculatorPro
//
//  Created by Your Name on 2026/03/23.
//

import SwiftUI
import UIKit

/// 屏幕适配器 - 处理不同iOS设备的屏幕适配
public class ScreenAdapter {
    
    // MARK: - 单例
    public static let shared = ScreenAdapter()
    
    // MARK: - 设备类型
    public enum DeviceType {
        case iPhoneSE
        case iPhoneStandard
        case iPhonePlus
        case iPhonePro
        case iPhoneProMax
        case iPad
        case iPadPro
        case unknown
        
        var description: String {
            switch self {
            case .iPhoneSE: return "iPhone SE"
            case .iPhoneStandard: return "iPhone 标准尺寸"
            case .iPhonePlus: return "iPhone Plus"
            case .iPhonePro: return "iPhone Pro"
            case .iPhoneProMax: return "iPhone Pro Max"
            case .iPad: return "iPad"
            case .iPadPro: return "iPad Pro"
            case .unknown: return "未知设备"
            }
        }
    }
    
    // MARK: - 屏幕尺寸类别
    public enum ScreenSizeClass {
        case compact  // 紧凑 (iPhone竖屏)
        case regular  // 常规 (iPad, iPhone横屏)
        
        var isCompact: Bool {
            return self == .compact
        }
        
        var isRegular: Bool {
            return self == .regular
        }
    }
    
    // MARK: - 方向
    public enum Orientation {
        case portrait
        case landscape
        case unknown
        
        var isPortrait: Bool {
            return self == .portrait
        }
        
        var isLandscape: Bool {
            return self == .landscape
        }
    }
    
    // MARK: - 属性
    
    /// 当前设备类型
    public private(set) var deviceType: DeviceType = .unknown
    
    /// 当前屏幕尺寸类别
    public private(set) var screenSizeClass: ScreenSizeClass = .compact
    
    /// 当前方向
    public private(set) var orientation: Orientation = .unknown
    
    /// 屏幕宽度
    public private(set) var screenWidth: CGFloat = 0
    
    /// 屏幕高度
    public private(set) var screenHeight: CGFloat = 0
    
    /// 安全区域Insets
    public private(set) var safeAreaInsets: UIEdgeInsets = .zero
    
    /// 是否是小屏幕设备
    public var isSmallScreen: Bool {
        return screenWidth <= 375 && orientation.isPortrait
    }
    
    /// 是否是大屏幕设备
    public var isLargeScreen: Bool {
        return screenWidth >= 428 || deviceType == .iPad || deviceType == .iPadPro
    }
    
    /// 是否是横屏模式
    public var isLandscape: Bool {
        return orientation.isLandscape
    }
    
    /// 是否是竖屏模式
    public var isPortrait: Bool {
        return orientation.isPortrait
    }
    
    // MARK: - 初始化
    private init() {
        updateScreenInfo()
        setupNotifications()
    }
    
    deinit {
        removeNotifications()
    }
    
    // MARK: - 屏幕信息更新
    private func updateScreenInfo() {
        let screen = UIScreen.main
        let bounds = screen.bounds
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        
        // 屏幕尺寸
        screenWidth = bounds.width
        screenHeight = bounds.height
        
        // 方向判断
        if screenWidth < screenHeight {
            orientation = .portrait
        } else if screenWidth > screenHeight {
            orientation = .landscape
        } else {
            orientation = .unknown
        }
        
        // 设备类型判断
        deviceType = detectDeviceType()
        
        // 屏幕尺寸类别
        screenSizeClass = detectScreenSizeClass()
        
        // 安全区域
        if let window = windowScene?.windows.first {
            safeAreaInsets = window.safeAreaInsets
        }
        
        print("屏幕适配器更新: \(deviceType.description), \(orientation.isPortrait ? "竖屏" : "横屏"), 尺寸: \(Int(screenWidth))×\(Int(screenHeight))")
    }
    
    // MARK: - 设备检测
    private func detectDeviceType() -> DeviceType {
        let screen = UIScreen.main
        let nativeBounds = screen.nativeBounds
        let scale = screen.scale
        
        // 基于物理像素判断
        let width = nativeBounds.width
        let height = nativeBounds.height
        
        // iPhone检测
        if UIDevice.current.userInterfaceIdiom == .phone {
            switch (width, height) {
            case (640, 1136):  // iPhone 5/5S/SE 1st
                return .iPhoneSE
            case (750, 1334):  // iPhone 6/6S/7/8/SE 2nd/3rd
                return .iPhoneStandard
            case (828, 1792):  // iPhone XR/11
                return .iPhoneStandard
            case (1080, 1920): // iPhone 6+/6S+/7+/8+
                return .iPhonePlus
            case (1125, 2436): // iPhone X/XS/11 Pro
                return .iPhonePro
            case (1170, 2532): // iPhone 12/13/14/15
                return .iPhonePro
            case (1284, 2778): // iPhone 12 Pro Max/13 Pro Max/14 Plus
                return .iPhoneProMax
            case (1290, 2796): // iPhone 14 Pro Max/15 Pro Max
                return .iPhoneProMax
            default:
                // 基于屏幕尺寸推断
                if screenWidth <= 375 {
                    return .iPhoneSE
                } else if screenWidth <= 390 {
                    return .iPhoneStandard
                } else if screenWidth <= 428 {
                    return .iPhonePro
                } else {
                    return .iPhoneProMax
                }
            }
        }
        // iPad检测
        else if UIDevice.current.userInterfaceIdiom == .pad {
            if width >= 2048 && height >= 2732 {
                return .iPadPro
            } else {
                return .iPad
            }
        }
        
        return .unknown
    }
    
    private func detectScreenSizeClass() -> ScreenSizeClass {
        // 基于当前水平和垂直尺寸类别
        let horizontalSizeClass = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.rootViewController?.traitCollection.horizontalSizeClass
        
        let verticalSizeClass = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.rootViewController?.traitCollection.verticalSizeClass
        
        // 如果水平方向是Regular，就是常规尺寸
        if horizontalSizeClass == .regular {
            return .regular
        } else {
            return .compact
        }
    }
    
    // MARK: - 通知
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceOrientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidBecomeKey),
            name: UIWindow.didBecomeKeyNotification,
            object: nil
        )
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func deviceOrientationDidChange() {
        DispatchQueue.main.async {
            self.updateScreenInfo()
        }
    }
    
    @objc private func windowDidBecomeKey() {
        DispatchQueue.main.async {
            self.updateScreenInfo()
        }
    }
    
    // MARK: - 公共方法
    
    /// 获取适配的字体大小
    public func adaptiveFontSize(baseSize: CGFloat) -> CGFloat {
        let multiplier: CGFloat
        
        switch deviceType {
        case .iPhoneSE:
            multiplier = 0.9
        case .iPhoneStandard:
            multiplier = 1.0
        case .iPhonePlus:
            multiplier = 1.05
        case .iPhonePro:
            multiplier = 1.1
        case .iPhoneProMax:
            multiplier = 1.15
        case .iPad, .iPadPro:
            multiplier = 1.3
        case .unknown:
            multiplier = 1.0
        }
        
        // 横屏时稍微增大字体
        if isLandscape {
            return baseSize * multiplier * 1.05
        }
        
        return baseSize * multiplier
    }
    
    /// 获取适配的间距
    public func adaptiveSpacing(baseSpacing: CGFloat) -> CGFloat {
        let multiplier: CGFloat
        
        if isSmallScreen {
            multiplier = 0.85
        } else if isLargeScreen {
            multiplier = 1.2
        } else {
            multiplier = 1.0
        }
        
        return baseSpacing * multiplier
    }
    
    /// 获取适配的按钮尺寸
    public func adaptiveButtonSize(baseSize: CGFloat) -> CGFloat {
        let multiplier: CGFloat
        
        if isSmallScreen {
            multiplier = 0.9
        } else if isLargeScreen {
            multiplier = 1.15
        } else {
            multiplier = 1.0
        }
        
        // 横屏时按钮可以稍微大一点
        if isLandscape {
            return baseSize * multiplier * 1.1
        }
        
        return baseSize * multiplier
    }
    
    /// 获取网格列数 (用于计算器按钮布局)
    public func gridColumnCount(for buttonType: ButtonType = .number) -> Int {
        switch buttonType {
        case .number:
            if isLandscape {
                return 6  // 横屏更多列
            } else if isLargeScreen {
                return 5  // 大屏幕更多列
            } else {
                return 4  // 标准4列
            }
        case .function:
            if isLandscape {
                return 8
            } else if isLargeScreen {
                return 6
            } else {
                return 5
            }
        case .scientific:
            if isLandscape {
                return 10
            } else if isLargeScreen {
                return 8
            } else {
                return 6
            }
        }
    }
    
    /// 获取安全区域调整
    public func safeAreaAdjustment(for edge: Edge) -> CGFloat {
        switch edge {
        case .top:
            return safeAreaInsets.top
        case .bottom:
            return safeAreaInsets.bottom
        case .leading:
            return safeAreaInsets.left
        case .trailing:
            return safeAreaInsets.right
        }
    }
    
    /// 检查是否支持分屏或多任务
    public var supportsSplitView: Bool {
        return deviceType == .iPad || deviceType == .iPadPro
    }
    
    /// 检查是否支持画中画
    public var supportsPictureInPicture: Bool {
        return deviceType == .iPad || deviceType == .iPadPro
    }
    
    /// 获取推荐的计算器布局模式
    public var recommendedLayoutMode: LayoutMode {
        if isLandscape {
            return .landscapeScientific
        } else if isLargeScreen {
            return .portraitEnhanced
        } else {
            return .portraitStandard
        }
    }
    
    // MARK: - 类型定义
    public enum ButtonType {
        case number      // 数字按钮
        case function    // 功能按钮 (加减乘除等)
        case scientific  // 科学计算按钮
    }
    
    public enum Edge {
        case top, bottom, leading, trailing
    }
    
    public enum LayoutMode {
        case portraitStandard      // 竖屏标准布局
        case portraitEnhanced      // 竖屏增强布局 (大屏幕)
        case landscapeScientific   // 横屏科学计算布局
        case landscapeExtended     // 横屏扩展布局
    }
}

// MARK: - SwiftUI视图修饰符
extension View {
    /// 自适应字体大小
    func adaptiveFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        modifier(AdaptiveFontModifier(baseSize: size, weight: weight, design: design))
    }
    
    /// 自适应间距
    func adaptivePadding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        modifier(AdaptivePaddingModifier(edges: edges, baseLength: length))
    }
    
    /// 安全区域适配
    func safeAreaAdapted(_ edges: Edge.Set = .all) -> some View {
        modifier(SafeAreaAdaptedModifier(edges: edges))
    }
    
    /// 设备特定修饰符
    @ViewBuilder
    func deviceSpecific<Content: View>(@ViewBuilder content: @escaping (ScreenAdapter.DeviceType) -> Content) -> some View {
        let adapter = ScreenAdapter.shared
        content(adapter.deviceType)
    }
}

// MARK: - 修饰符实现
struct AdaptiveFontModifier: ViewModifier {
    let baseSize: CGFloat
    let weight: Font.Weight
    let design: Font.Design
    
    func body(content: Content) -> some View {
        let adapter = ScreenAdapter.shared
        let adaptiveSize = adapter.adaptiveFontSize(baseSize: baseSize)
        
        content
            .font(.system(size: adaptiveSize, weight: weight, design: design))
    }
}

struct AdaptivePaddingModifier: ViewModifier {
    let edges: Edge.Set
    let baseLength: CGFloat?
    
    func body(content: Content) -> some View {
        let adapter = ScreenAdapter.shared
        let length = baseLength ?? 16 // 默认间距
        let adaptiveLength = adapter.adaptiveSpacing(baseSpacing: length)
        
        content
            .padding(edges, adaptiveLength)
    }
}

struct SafeAreaAdaptedModifier: ViewModifier {
    let edges: Edge.Set
    
    func body(content: Content) -> some View {
        let adapter = ScreenAdapter.shared
        
        content
            .padding(.top, edges.contains(.top) ? adapter.safeAreaAdjustment(for: .top) : 0)
            .padding(.bottom, edges.contains(.bottom) ? adapter.safeAreaAdjustment(for: .bottom) : 0)
            .padding(.leading, edges.contains(.leading) ? adapter.safeAreaAdjustment(for: .leading) : 0)
            .padding(.trailing, edges.contains(.trailing) ? adapter.safeAreaAdjustment(for: .trailing) : 0)
    }
}

// MARK: - 预览支持
#if DEBUG
struct ScreenAdapter_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // iPhone SE预览
            PreviewView(deviceName: "iPhone SE (3rd generation)")
                .previewDevice("iPhone SE (3rd generation)")
            
            // iPhone 15 Pro预览
            PreviewView(deviceName: "iPhone 15 Pro")
                .previewDevice("iPhone 15 Pro")
            
            // iPhone 15 Pro Max预览
            PreviewView(deviceName: "iPhone 15 Pro Max")
                .previewDevice("iPhone 15 Pro Max")
            
            // iPad预览
            PreviewView(deviceName: "iPad Pro (12.9-inch)")
                .previewDevice("iPad Pro (12.9-inch)")
        }
    }
}

struct PreviewView: View {
    let deviceName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(deviceName)
                .font(.headline)
            
            Text("屏幕宽度: \(Int(ScreenAdapter.shared.screenWidth))")
            Text("屏幕高度: \(Int(ScreenAdapter.shared.screenHeight))")
            Text("设备类型: \(ScreenAdapter.shared.deviceType.description)")
            Text("方向: \(ScreenAdapter.shared.isPortrait ? "竖屏" : "横屏")")
            Text("字体大小示例: 16 → \(Int(ScreenAdapter.shared.adaptiveFontSize(baseSize: 16)))")
        }
        .padding()
    }
}
#endif