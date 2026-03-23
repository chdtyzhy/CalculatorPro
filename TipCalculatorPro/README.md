# Tip Calculator Pro
iOS付费应用开发项目

## 项目概述
一个简单实用的小费计算器，支持AA制分摊、历史记录等功能。

## 技术栈
- React Native 0.75+
- TypeScript（可选）
- Expo（可选，简化开发）
- 状态管理：Context API

## 功能列表
### 版本1.0（MVP）
- [ ] 账单金额输入
- [ ] 小费百分比选择（10%、15%、18%、20%、自定义）
- [ ] 人数选择（1-10人）
- [ ] 计算结果展示（小费金额、每人应付、总计）
- [ ] 历史记录（本地存储）

### 版本1.1
- [ ] 货币转换（免费API）
- [ ] 深色/浅色主题
- [ ] 分享功能（分享计算结果）
- [ ] 更多计算选项（税率、折扣）

### 版本1.2
- [ ] iCloud同步
- [ ] Widget（今日视图小组件）
- [ ] Apple Watch应用
- [ ] 数据分析图表

## 开发环境设置

### 1. 安装依赖
```bash
# 使用淘宝镜像加速（中国用户）
npm config set registry https://registry.npmmirror.com

# 安装React Native CLI
npm install -g react-native-cli

# 或使用Expo（推荐新手）
npm install -g expo-cli
```

### 2. 创建项目
```bash
# 使用React Native CLI
npx react-native init TipCalculatorPro --template react-native-template-typescript

# 或使用Expo
npx create-expo-app TipCalculatorPro --template
```

### 3. 运行项目
```bash
cd TipCalculatorPro

# iOS（需要Mac和Xcode）
npx react-native run-ios

# 或使用Expo
npx expo start
```

## 项目结构
```
TipCalculatorPro/
├── src/
│   ├── components/
│   │   ├── Calculator/
│   │   ├── History/
│   │   └── ThemeToggle/
│   ├── context/
│   │   ├── CalculationContext.tsx
│   │   └── ThemeContext.tsx
│   ├── utils/
│   │   ├── calculations.ts
│   │   └── storage.ts
│   └── screens/
│       └── HomeScreen.tsx
├── App.tsx
├── package.json
└── README.md
```

## 开发计划
### 第1天：项目搭建和基础UI
- [ ] 创建项目
- [ ] 安装必要依赖
- [ ] 设计基础UI布局

### 第2天：核心计算逻辑
- [ ] 实现计算函数
- [ ] 连接UI和逻辑
- [ ] 基础测试

### 第3天：历史记录功能
- [ ] 实现本地存储
- [ ] 历史记录列表
- [ ] 删除/清空功能

### 第4天：UI优化和主题
- [ ] 美化界面
- [ ] 添加深色主题
- [ ] 动画效果

### 第5天：测试和调试
- [ ] 单元测试
- [ ] 真机测试
- [ ] 性能优化

### 第6天：准备上架
- [ ] 应用图标设计
- [ ] 截图制作
- [ ] 应用描述编写

### 第7天：提交审核
- [ ] 打包应用
- [ ] 提交App Store
- [ ] 等待审核

## 收入预测
| 定价 | 月下载量 | 月收入（苹果分成后） |
|------|----------|-------------------|
| ¥8.00 | 100 | ¥560 |
| ¥8.00 | 500 | ¥2,800 |
| ¥8.00 | 1000 | ¥5,600 |

**保守估计**：3个月后稳定在¥2000-4000/月

## 注意事项
1. **苹果开发者账号**：需要¥688/年
2. **审核时间**：通常1-3天
3. **税务信息**：需要填写银行和税务信息
4. **本地化**：支持中英文