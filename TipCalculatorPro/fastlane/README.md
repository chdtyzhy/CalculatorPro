# Fastlane 自动化配置

Fastlane 是自动化 iOS 和 Android 应用部署的工具，可以自动化：
- 截图生成
- 代码签名
- 测试发布
- App Store 和 Google Play 上架

## 安装 Fastlane

```bash
# 安装 fastlane
sudo gem install fastlane -NV

# 或使用 Homebrew
brew install fastlane
```

## 初始化 Fastlane

```bash
cd /path/to/TipCalculatorPro

# iOS 配置
fastlane init

# 会要求输入 Apple ID 和密码
# 选择手动配置（Manual setup）
```

## 目录结构

```
fastlane/
├── Appfile           # 应用配置（Apple ID, Bundle ID 等）
├── Fastfile          # 自动化脚本定义
├── Matchfile         # 代码签名管理
├── Deliverfile       # App Store 发布配置
└── screenshots/      # 自动生成的截图
```

## 基本配置

### Appfile
```ruby
app_identifier("com.yourname.tipcalculatorpro") # Bundle ID
apple_id("your@apple.id") # Apple ID 邮箱
team_id("YOUR_TEAM_ID") # 开发者团队 ID
```

### Fastfile - 基础版本
```ruby
default_platform(:ios)

platform :ios do
  desc "提交应用到 TestFlight"
  lane :beta do
    build_app(scheme: "TipCalculatorPro")
    upload_to_testflight
  end

  desc "提交应用到 App Store"
  lane :release do
    build_app(scheme: "TipCalculatorPro")
    upload_to_app_store
  end

  desc "运行测试"
  lane :test do
    run_tests(scheme: "TipCalculatorPro")
  end
end
```

## 常用命令

```bash
# 运行测试
fastlane ios test

# 构建并上传到 TestFlight
fastlane ios beta

# 发布到 App Store
fastlane ios release

# 自动截图（需要配置截图脚本）
fastlane ios screenshots
```

## 自动化构建流程

### 1. 本地构建测试
```bash
./automate.sh all
```

### 2. 使用 Fastlane 发布
```bash
fastlane ios beta   # 测试版
fastlane ios release # 正式版
```

## GitHub Actions 集成

可以配置 GitHub Actions 在每次推送时自动运行测试和构建：

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Install dependencies
        run: npm install
      - name: Run tests
        run: npm test
```

## 注意事项

1. **Apple ID 安全**：建议使用 App Store Connect API 密钥代替密码
2. **代码签名**：建议使用 match 管理证书
3. **双因素认证**：需要处理 Apple ID 的双因素认证
4. **中国网络**：可能需要配置代理

## 进阶功能

### 自动截图
配置截图脚本，自动在多种设备上截图

### 自动本地化
管理多语言版本

### 版本号自动递增
根据 Git 提交自动递增版本号

### 发布通知
发布成功后自动发送通知（Slack、邮件等）

## 故障排除

### 常见问题
1. **证书问题**：使用 match 统一管理证书
2. **网络问题**：配置代理或使用国内镜像
3. **权限问题**：确保 Apple ID 有足够的权限

### 获取帮助
- [Fastlane 官方文档](https://docs.fastlane.tools)
- [Fastlane 中文社区](https://fastlane.tools/cn/)
- GitHub Issues