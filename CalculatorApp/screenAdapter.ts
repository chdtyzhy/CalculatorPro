// screenAdapter.ts
// iOS屏幕适配工具 - React Native版本

import { Dimensions, Platform, PixelRatio, StatusBar } from 'react-native';

// 设备类型
export enum DeviceType {
  iPhoneSE = 'iPhoneSE',
  iPhoneStandard = 'iPhoneStandard',
  iPhonePlus = 'iPhonePlus',
  iPhonePro = 'iPhonePro',
  iPhoneProMax = 'iPhoneProMax',
  iPad = 'iPad',
  iPadPro = 'iPadPro',
  Unknown = 'Unknown',
}

// 屏幕方向
export enum Orientation {
  Portrait = 'Portrait',
  Landscape = 'Landscape',
  Unknown = 'Unknown',
}

// 屏幕尺寸类别
export enum ScreenSizeClass {
  Compact = 'Compact',  // 紧凑 (iPhone竖屏)
  Regular = 'Regular',  // 常规 (iPad, iPhone横屏)
}

// 屏幕适配器类
class ScreenAdapter {
  // 单例实例
  private static instance: ScreenAdapter;

  // 设备信息
  private deviceType: DeviceType = DeviceType.Unknown;
  private orientation: Orientation = Orientation.Unknown;
  private screenSizeClass: ScreenSizeClass = ScreenSizeClass.Compact;
  
  // 屏幕尺寸
  private screenWidth: number = 0;
  private screenHeight: number = 0;
  private pixelRatio: number = 1;
  
  // 安全区域
  private safeAreaInsets = {
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
  };

  // 私有构造函数
  private constructor() {
    this.updateScreenInfo();
    this.setupEventListeners();
  }

  // 获取单例
  public static getInstance(): ScreenAdapter {
    if (!ScreenAdapter.instance) {
      ScreenAdapter.instance = new ScreenAdapter();
    }
    return ScreenAdapter.instance;
  }

  // 更新屏幕信息
  private updateScreenInfo(): void {
    const { width, height } = Dimensions.get('window');
    const { width: screenWidth, height: screenHeight } = Dimensions.get('screen');
    
    this.screenWidth = width;
    this.screenHeight = height;
    this.pixelRatio = PixelRatio.get();
    
    // 判断方向
    this.orientation = width < height ? Orientation.Portrait : Orientation.Landscape;
    
    // 检测设备类型
    this.deviceType = this.detectDeviceType();
    
    // 检测屏幕尺寸类别
    this.screenSizeClass = this.detectScreenSizeClass();
    
    // 计算安全区域
    this.calculateSafeArea();
    
    console.log(`屏幕适配器更新: ${this.deviceType}, ${this.orientation}, 尺寸: ${width}×${height}`);
  }

  // 检测设备类型
  private detectDeviceType(): DeviceType {
    const { width, height } = Dimensions.get('window');
    const scale = PixelRatio.get();
    const physicalWidth = width * scale;
    const physicalHeight = height * scale;
    
    // 判断是否是iPad
    if (Platform.OS === 'ios' && Platform.isPad) {
      if (physicalWidth >= 2048 && physicalHeight >= 2732) {
        return DeviceType.iPadPro;
      }
      return DeviceType.iPad;
    }
    
    // iPhone设备判断
    if (Platform.OS === 'ios') {
      // 基于物理像素判断
      switch (true) {
        // iPhone SE系列
        case (physicalWidth === 640 && physicalHeight === 1136): // iPhone 5/5S/SE 1st
        case (physicalWidth === 750 && physicalHeight === 1334): // iPhone 6/6S/7/8/SE 2nd/3rd
          return DeviceType.iPhoneSE;
        
        // iPhone标准尺寸
        case (physicalWidth === 828 && physicalHeight === 1792): // iPhone XR/11
        case (physicalWidth === 1170 && physicalHeight === 2532): // iPhone 12/13/14/15
          return DeviceType.iPhoneStandard;
        
        // iPhone Plus尺寸
        case (physicalWidth === 1080 && physicalHeight === 1920): // iPhone 6+/6S+/7+/8+
        case (physicalWidth === 1284 && physicalHeight === 2778): // iPhone 12 Pro Max/13 Pro Max/14 Plus
          return DeviceType.iPhonePlus;
        
        // iPhone Pro尺寸
        case (physicalWidth === 1125 && physicalHeight === 2436): // iPhone X/XS/11 Pro
        case (physicalWidth === 1179 && physicalHeight === 2556): // iPhone 14 Pro
          return DeviceType.iPhonePro;
        
        // iPhone Pro Max尺寸
        case (physicalWidth === 1242 && physicalHeight === 2688): // iPhone XS Max/11 Pro Max
        case (physicalWidth === 1290 && physicalHeight === 2796): // iPhone 14 Pro Max/15 Pro Max
          return DeviceType.iPhoneProMax;
        
        default:
          // 基于逻辑像素推断
          if (width <= 375) return DeviceType.iPhoneSE;
          if (width <= 390) return DeviceType.iPhoneStandard;
          if (width <= 428) return DeviceType.iPhonePro;
          return DeviceType.iPhoneProMax;
      }
    }
    
    return DeviceType.Unknown;
  }

  // 检测屏幕尺寸类别
  private detectScreenSizeClass(): ScreenSizeClass {
    const { width, height } = Dimensions.get('window');
    
    // 如果宽度大于某个阈值，认为是Regular
    if (width >= 768 || (this.orientation === Orientation.Landscape && width >= 480)) {
      return ScreenSizeClass.Regular;
    }
    
    return ScreenSizeClass.Compact;
  }

  // 计算安全区域
  private calculateSafeArea(): void {
    // 这里简化处理，实际项目中应该使用react-native-safe-area-context
    const { height } = Dimensions.get('window');
    const statusBarHeight = StatusBar.currentHeight || 0;
    
    // iPhone X及以后的安全区域
    if (this.deviceType === DeviceType.iPhonePro || 
        this.deviceType === DeviceType.iPhoneProMax ||
        this.deviceType === DeviceType.iPhoneStandard) {
      this.safeAreaInsets = {
        top: statusBarHeight + 24, // 状态栏 + 刘海区域
        bottom: 34, // Home Indicator高度
        left: 0,
        right: 0,
      };
    } else if (this.deviceType === DeviceType.iPad || this.deviceType === DeviceType.iPadPro) {
      this.safeAreaInsets = {
        top: statusBarHeight + 24,
        bottom: 20,
        left: 0,
        right: 0,
      };
    } else {
      // 传统iPhone
      this.safeAreaInsets = {
        top: statusBarHeight,
        bottom: 0,
        left: 0,
        right: 0,
      };
    }
  }

  // 设置事件监听
  private setupEventListeners(): void {
    Dimensions.addEventListener('change', () => {
      this.updateScreenInfo();
    });
  }

  // 移除事件监听
  public cleanup(): void {
    Dimensions.removeEventListener('change', () => {
      this.updateScreenInfo();
    });
  }

  // 公共属性访问器

  // 获取设备类型
  public getDeviceType(): DeviceType {
    return this.deviceType;
  }

  // 获取屏幕方向
  public getOrientation(): Orientation {
    return this.orientation;
  }

  // 获取屏幕尺寸类别
  public getScreenSizeClass(): ScreenSizeClass {
    return this.screenSizeClass;
  }

  // 获取屏幕宽度
  public getScreenWidth(): number {
    return this.screenWidth;
  }

  // 获取屏幕高度
  public getScreenHeight(): number {
    return this.screenHeight;
  }

  // 获取像素密度
  public getPixelRatio(): number {
    return this.pixelRatio;
  }

  // 获取安全区域
  public getSafeAreaInsets() {
    return { ...this.safeAreaInsets };
  }

  // 是否是小屏幕设备
  public isSmallScreen(): boolean {
    return this.screenWidth <= 375 && this.orientation === Orientation.Portrait;
  }

  // 是否是大屏幕设备
  public isLargeScreen(): boolean {
    return this.screenWidth >= 428 || 
           this.deviceType === DeviceType.iPad || 
           this.deviceType === DeviceType.iPadPro;
  }

  // 是否是横屏
  public isLandscape(): boolean {
    return this.orientation === Orientation.Landscape;
  }

  // 是否是竖屏
  public isPortrait(): boolean {
    return this.orientation === Orientation.Portrait;
  }

  // 适配方法

  // 自适应字体大小
  public adaptiveFontSize(baseSize: number): number {
    let multiplier = 1.0;
    
    switch (this.deviceType) {
      case DeviceType.iPhoneSE:
        multiplier = 0.9;
        break;
      case DeviceType.iPhoneStandard:
        multiplier = 1.0;
        break;
      case DeviceType.iPhonePlus:
        multiplier = 1.05;
        break;
      case DeviceType.iPhonePro:
        multiplier = 1.1;
        break;
      case DeviceType.iPhoneProMax:
        multiplier = 1.15;
        break;
      case DeviceType.iPad:
      case DeviceType.iPadPro:
        multiplier = 1.3;
        break;
      default:
        multiplier = 1.0;
    }
    
    // 横屏时稍微增大字体
    if (this.isLandscape()) {
      return baseSize * multiplier * 1.05;
    }
    
    return baseSize * multiplier;
  }

  // 自适应间距
  public adaptiveSpacing(baseSpacing: number): number {
    let multiplier = 1.0;
    
    if (this.isSmallScreen()) {
      multiplier = 0.85;
    } else if (this.isLargeScreen()) {
      multiplier = 1.2;
    } else {
      multiplier = 1.0;
    }
    
    return baseSpacing * multiplier;
  }

  // 自适应按钮尺寸
  public adaptiveButtonSize(baseSize: number): number {
    let multiplier = 1.0;
    
    if (this.isSmallScreen()) {
      multiplier = 0.9;
    } else if (this.isLargeScreen()) {
      multiplier = 1.15;
    } else {
      multiplier = 1.0;
    }
    
    // 横屏时按钮可以稍微大一点
    if (this.isLandscape()) {
      return baseSize * multiplier * 1.1;
    }
    
    return baseSize * multiplier;
  }

  // 获取网格列数
  public gridColumnCount(buttonType: 'number' | 'function' | 'scientific' = 'number'): number {
    switch (buttonType) {
      case 'number':
        if (this.isLandscape()) return 6;
        if (this.isLargeScreen()) return 5;
        return 4;
      case 'function':
        if (this.isLandscape()) return 8;
        if (this.isLargeScreen()) return 6;
        return 5;
      case 'scientific':
        if (this.isLandscape()) return 10;
        if (this.isLargeScreen()) return 8;
        return 6;
      default:
        return 4;
    }
  }

  // 获取安全区域调整值
  public safeAreaAdjustment(edge: 'top' | 'bottom' | 'left' | 'right'): number {
    return this.safeAreaInsets[edge];
  }

  // 是否支持分屏
  public supportsSplitView(): boolean {
    return this.deviceType === DeviceType.iPad || this.deviceType === DeviceType.iPadPro;
  }

  // 推荐的计算器布局模式
  public recommendedLayoutMode(): 'portraitStandard' | 'portraitEnhanced' | 'landscapeScientific' | 'landscapeExtended' {
    if (this.isLandscape()) {
      return 'landscapeScientific';
    } else if (this.isLargeScreen()) {
      return 'portraitEnhanced';
    } else {
      return 'portraitStandard';
    }
  }

  // 设备描述
  public getDeviceDescription(): string {
    return `${this.deviceType} - ${this.orientation} - ${this.screenWidth}×${this.screenHeight}`;
  }
}

// 导出单例
export const screenAdapter = ScreenAdapter.getInstance();

// 工具函数

// 像素转dp
export function px2dp(px: number): number {
  return px / PixelRatio.get();
}

// dp转像素
export function dp2px(dp: number): number {
  return dp * PixelRatio.get();
}

// 响应式宽度 (基于百分比)
export function responsiveWidth(percent: number): number {
  const { width } = Dimensions.get('window');
  return (width * percent) / 100;
}

// 响应式高度 (基于百分比)
export function responsiveHeight(percent: number): number {
  const { height } = Dimensions.get('window');
  return (height * percent) / 100;
}

// 字体缩放
export function scaleFont(size: number): number {
  const { width } = Dimensions.get('window');
  const scale = width / 375; // 基于375宽度(iPhone 6/7/8)作为基准
  return Math.round(size * scale);
}

// 设备特定样式
export function deviceSpecificStyles<T>(
  styles: {
    [K in DeviceType]?: T;
  } & {
    default: T;
  }
): T {
  const deviceType = screenAdapter.getDeviceType();
  return styles[deviceType] || styles.default;
}

// 方向特定样式
export function orientationSpecificStyles<T>(
  portrait: T,
  landscape: T
): T {
  return screenAdapter.isPortrait() ? portrait : landscape;
}

// 导出类型
export type { ScreenAdapter };

// 默认导出
export default screenAdapter;