# iOS屏幕适配方案

## 🎯 适配目标

### 支持的设备范围
```
📱 iPhone系列 (全面适配):
  • iPhone SE (3rd/4th generation) - 小屏幕优化
  • iPhone 标准尺寸 (6/7/8/XR/11/12/13/14/15) - 标准优化
  • iPhone Plus/Pro/Pro Max - 大屏幕优化
  • 所有刘海屏设备 - 安全区域处理

📱 iPad系列 (完整支持):
  • iPad (第6代及以后)
  • iPad Air
  • iPad mini
  • iPad Pro (所有尺寸)
  • 横屏/分屏/画中画支持
```

### 适配的屏幕特性
```
🎯 横竖屏自适应: 自动调整布局和功能
🎯 安全区域处理: 刘海屏、Home Indicator、圆角
🎯 动态字体缩放: 根据屏幕尺寸智能缩放
🎯 响应式布局: 网格系统自动调整
🎯 间距优化: 不同设备使用最佳间距
🎯 触控区域: 确保最小44×44点触控区域
```

## 📱 技术实现

### 1. SwiftUI适配系统 (CalculatorProNative/)

#### 核心组件: `ScreenAdapter.swift`
```swift
// 设备类型检测
public enum DeviceType {
    case iPhoneSE          // 小屏幕设备
    case iPhoneStandard    // 标准尺寸
    case iPhonePlus       // Plus尺寸
    case iPhonePro        // Pro尺寸
    case iPhoneProMax     // Pro Max尺寸
    case iPad             // iPad标准
    case iPadPro          // iPad Pro
}

// 屏幕方向
public enum Orientation {
    case portrait    // 竖屏
    case landscape   // 横屏
}

// 屏幕尺寸类别
public enum ScreenSizeClass {
    case compact    // 紧凑 (iPhone竖屏)
    case regular    // 常规 (iPad, iPhone横屏)
}
```

#### 自适应方法
```swift
// 自适应字体大小
let fontSize = ScreenAdapter.shared.adaptiveFontSize(baseSize: 16)

// 自适应间距
let spacing = ScreenAdapter.shared.adaptiveSpacing(baseSpacing: 16)

// 自适应按钮尺寸
let buttonSize = ScreenAdapter.shared.adaptiveButtonSize(baseSize: 60)

// 网格列数 (根据屏幕调整)
let columns = ScreenAdapter.shared.gridColumnCount(for: .number)
```

#### SwiftUI修饰符
```swift
// 使用自适应修饰符
Text("Hello")
    .adaptiveFont(size: 16, weight: .medium)
    .adaptivePadding(.horizontal, 16)
    .safeAreaAdapted(.top)
```

### 2. React Native适配系统 (CalculatorApp/)

#### 核心组件: `screenAdapter.ts`
```typescript
// 设备类型
export enum DeviceType {
  iPhoneSE = 'iPhoneSE',
  iPhoneStandard = 'iPhoneStandard',
  iPhonePlus = 'iPhonePlus',
  iPhonePro = 'iPhonePro',
  iPhoneProMax = 'iPhoneProMax',
  iPad = 'iPad',
  iPadPro = 'iPadPro',
}

// 使用示例
const adapter = screenAdapter;
const fontSize = adapter.adaptiveFontSize(16);
const isLandscape = adapter.isLandscape();
const deviceType = adapter.getDeviceType();
```

#### 工具函数
```typescript
// 响应式宽度/高度
const width = responsiveWidth(50);  // 屏幕宽度的50%
const height = responsiveHeight(30); // 屏幕高度的30%

// 字体缩放
const scaledFont = scaleFont(16); // 基于375宽度基准缩放

// 像素转换
const dp = px2dp(100); // 像素转dp
const px = dp2px(50);  // dp转像素
```

#### 设备特定样式
```typescript
const styles = StyleSheet.create({
  container: deviceSpecificStyles({
    [DeviceType.iPhoneSE]: {
      padding: 12,
      fontSize: 14,
    },
    [DeviceType.iPad]: {
      padding: 24,
      fontSize: 18,
    },
    default: {
      padding: 16,
      fontSize: 16,
    },
  }),
});
```

## 🎨 设计系统适配

### 字体系统
```
🔤 基准字体大小: 基于375宽度(iPhone 6/7/8)设计
📐 缩放规则:
  • iPhone SE: 90%基准大小
  • iPhone标准: 100%基准大小
  • iPhone Pro: 110%基准大小
  • iPhone Pro Max: 115%基准大小
  • iPad: 130%基准大小
  • 横屏模式: 额外增加5%
```

### 间距系统
```
📏 基准间距: 16点 (1x)
📐 适配规则:
  • 小屏幕设备: 85%基准间距
  • 大屏幕设备: 120%基准间距
  • 标准设备: 100%基准间距
  • 横屏模式: 适当增加间距
```

### 按钮系统
```
🔘 最小触控区域: 44×44点 (Apple HIG要求)
📐 按钮尺寸适配:
  • 小屏幕: 90%基准尺寸
  • 大屏幕: 115%基准尺寸
  • 横屏: 110%基准尺寸
  • 确保所有按钮满足最小触控区域
```

### 网格系统
```
🔢 计算器按钮网格:
  • 竖屏标准: 4列数字按钮
  • 竖屏大屏: 5列数字按钮
  • 横屏模式: 6列数字按钮
  • 科学计算: 6-10列 (根据屏幕调整)
```

## 📊 设备具体适配方案

### iPhone SE (小屏幕优化)
```
📱 屏幕特点: 4.7英寸, 375×667点
🎯 适配策略:
  • 字体缩小10%
  • 间距缩小15%
  • 紧凑布局
  • 简化复杂界面
```

### iPhone 标准尺寸 (主流优化)
```
📱 屏幕特点: 6.1英寸, 390×844点
🎯 适配策略:
  • 标准字体大小
  • 标准间距
  • 平衡的信息密度
  • 最佳用户体验
```

### iPhone Pro Max (大屏幕优化)
```
📱 屏幕特点: 6.7英寸, 428×926点
🎯 适配策略:
  • 字体增大15%
  • 间距增大20%
  • 利用额外空间展示更多内容
  • 增强版布局
```

### iPad (平板优化)
```
📱 屏幕特点: 10.9-12.9英寸, 多种分辨率
🎯 适配策略:
  • 字体增大30%
  • 充分利用横屏空间
  • 分屏和多任务支持
  • 画中画支持
  • 增强的交互模式
```

## 🔧 横竖屏适配

### 竖屏模式 (默认)
```
📱 布局特点:
  • 垂直信息流
  • 紧凑的按钮布局
  • 适合单手操作
  • 标准计算器界面
```

### 横屏模式 (增强)
```
📱 布局特点:
  • 水平信息扩展
  • 科学计算面板常显
  • 更大的显示区域
  • 多列按钮布局
  • 专业计算器体验
```

### 自动切换逻辑
```swift
// SwiftUI自动检测
@Environment(\.horizontalSizeClass) var horizontalSizeClass
@Environment(\.verticalSizeClass) var verticalSizeClass

// React Native检测
const isLandscape = Dimensions.get('window').width > Dimensions.get('window').height
```

## 🎯 安全区域处理

### 刘海屏设备
```
⚠️ 需要处理区域:
  • 状态栏区域 (顶部)
  • Home Indicator区域 (底部)
  • 圆角区域 (四角)

✅ 解决方案:
  • SwiftUI: .safeAreaInset()、.ignoresSafeArea()
  • React Native: SafeAreaView、react-native-safe-area-context
  • 动态计算安全区域Insets
```

### 具体实现
```swift
// SwiftUI安全区域
VStack {
    // 内容
}
.safeAreaInset(edge: .top) {
    // 顶部安全区域内容
}
.safeAreaInset(edge: .bottom) {
    // 底部安全区域内容
}
```

```typescript
// React Native安全区域
import { SafeAreaView } from 'react-native-safe-area-context';

<SafeAreaView style={styles.container}>
  {/* 内容 */}
</SafeAreaView>
```

## 📱 测试验证

### 测试设备清单
```
✅ 必须测试设备:
  • iPhone SE (3rd/4th generation)
  • iPhone 13/14/15
  • iPhone 13/14/15 Pro
  • iPhone 13/14/15 Pro Max
  • iPad (第9代)
  • iPad Pro 12.9英寸

✅ 测试场景:
  • 竖屏正常使用
  • 横屏科学计算
  • 横竖屏切换
  • 分屏模式 (iPad)
  • 画中画模式 (iPad)
```

### 测试检查清单
```
🎯 布局检查:
  - [ ] 所有内容在安全区域内
  - [ ] 按钮满足最小触控区域
  - [ ] 文字清晰可读
  - [ ] 间距合理舒适

🎯 功能检查:
  - [ ] 横竖屏切换正常
  - [ ] 所有按钮可点击
  - [ ] 科学计算面板正常显示
  - [ ] 历史记录可滚动

🎯 性能检查:
  - [ ] 布局切换流畅
  - [ ] 无界面闪烁
  - [ ] 内存使用正常
  - [ ] 电池消耗合理
```

## 🚀 最佳实践

### 设计原则
```
1. 内容优先: 确保核心内容在任何屏幕都清晰可见
2. 渐进增强: 小屏幕基础功能，大屏幕增强功能
3. 一致性: 保持品牌和交互一致性
4. 无障碍: 确保所有用户都能使用
```

### 开发建议
```
1. 使用相对单位: 避免绝对像素值
2. 测试多种设备: 实际设备测试最可靠
3. 考虑未来设备: 设计要有扩展性
4. 用户可配置: 提供字体大小等设置
```

### 性能优化
```
1. 避免过度绘制: 简化复杂布局
2. 缓存布局计算: 避免重复计算
3. 懒加载: 大屏幕才加载的组件延迟加载
4. 图片优化: 使用适当分辨率的图片
```

## 📝 更新记录

### v1.0.0 (初始版本)
```
✅ 基础屏幕适配系统
✅ iPhone全系列支持
✅ 横竖屏适配
✅ 安全区域处理
```

### 计划增强
```
🔧 iPad专业布局优化
🔧 动态类型深度支持
🔧 分屏多任务支持
🔧 可访问性增强
```

---
**最后更新**: 2026年3月23日
**适配状态**: ✅ 全面适配iOS设备
**测试状态**: 需要实际设备测试验证
**维护**: 持续更新支持新设备