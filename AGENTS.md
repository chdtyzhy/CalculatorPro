# CalculatorPro - AI 编码指引

## 项目概况

- 产品：CalculatorPro，一款完全离线运行的 iPhone 计算器。
- 语言与框架：Swift 5 / SwiftUI。
- 架构：MVVM 风格，计算状态、输入处理器和界面分层管理。
- 最低支持版本：iOS 16.0。
- Xcode 工程入口：`CalculatorPro.xcodeproj`。
- App Target 与 Scheme：`CalculatorPro`。
- 第三方依赖：无。

## 目录索引

- `CalculatorPro/Common/Controllers/`：App 启动入口。
- `CalculatorPro/Common/Utils/`：公共颜色和字体工具。
- `CalculatorPro/Common/Extensions/`：Foundation 公共扩展。
- `CalculatorPro/Features/Main/Models/`：计算器状态、按键和运算类型。
- `CalculatorPro/Features/Main/ViewModels/`：输入处理器和主 ViewModel。
- `CalculatorPro/Features/Main/Views/`：SwiftUI 页面与控件。
- `CalculatorPro/Resources/`：`Info.plist`、启动页和字体资源。
- `CalculatorPro/Assets.xcassets/`：App 图标与颜色资源。
- `docs/`：GitHub Pages 对外网页。
- `scripts/`：可重复执行的构建与验证脚本。

修改工程配置、版本、测试或公开网页前，先阅读
[SOURCE_OF_TRUTH.md](SOURCE_OF_TRUTH.md)，确认对应内容的唯一真源。

## 最高优先级规则

1. **根因明确前不改正式逻辑**：修改已有计算行为前，必须先追踪真实状态链路，确认问题发生的位置和条件，禁止用“先改一下看看”的方式试错。
2. **计算链路必须完整追踪**：输入从 `DialPad` 进入 `MainViewModel`，再由 `ButtonHandler` 修改 `CalculatorState`；排查问题时必须沿这条链路检查，不能只在 View 层修显示结果。
3. **默认保持顺序计算语义**：除非用户明确要求改变规则，连续运算必须从左到右执行，不自动改为数学运算符优先级。
4. **公共逻辑改动先搜影响范围**：修改公共状态、处理器、颜色、字体或格式化扩展前，先搜索全部调用方和使用点。
5. **新增或修改 UI 先查现有规范**：动手前阅读 [UI设计规范.md](UI设计规范.md)，并检查现有 SwiftUI 组件和语义颜色，优先复用已有能力。
6. **不得修改历史工程备份**：`project.pbxproj.backup*` 只是历史文件，不是工程真源，任何情况下都不要编辑。
7. **必须保留用户已有改动**：工作区可能存在未提交修改，只处理当前任务涉及的文件；暂存和提交时也必须精确控制范围。
8. **验证结论必须真实**：当前 Xcode 工程包含 `CalculatorProTests` 单元测试 Target；测试结论必须来自当前 XCTest 实际输出。

执行口径：

- 根因未明确前，只允许查调用链、补充必要日志、缩小范围和复现问题。
- 优先修改状态层、处理器或格式化逻辑等根因位置，不在 UI 层掩盖错误结果。
- 一次修改只解决一个明确问题；发现多个问题时分别分析、修改和验证。
- 临时诊断代码或日志在验证完成后必须删除，只有长期有价值的正式逻辑才能保留。

## UI 与组件规则

- 保持四列、五行键盘在所有支持的 iPhone 尺寸上稳定显示。
- 固定格式控件必须保持尺寸稳定；动态文字不得导致键盘缩放、位移或跳动。
- 修改纵向间距时，同时检查 Safe Area、小屏设备和 Pro Max 设备的完整显示情况。
- 优先复用 `CalculatorButtons`、`CalculatorPad`、`DisplayView`、公共颜色和字体工具，不在单个页面重复实现同类样式。
- 不要新增只有图标、没有完整交互和状态处理的按钮。
- 不要为了单个截图或临时演示向正式代码加入永久测试状态。
- UI 改动完成后，默认至少进行模拟器构建；涉及布局风险时，再检查相应尺寸的模拟器截图。

## 计算行为规则

- 支持加、减、乘、除、百分比、正负号、小数点、清空、退格和等号操作。
- 除数为零或结果不是有限数值时，显示 `未定义`。
- 最大输入位数由 `CalculatorState.maxDigits` 统一控制。
- 数值显示格式统一由 Foundation 扩展处理，不要在 View 中复制格式化规则。
- 连续运算保持从左到右的系统计算器式行为。
- 修改计算行为时，必须覆盖正常输入、连续运算、小数、负数、百分比、除零、清空和退格等相关边界。
- 新增或修改测试时，应直接测试正式业务实现，并通过 `CalculatorProTests` Target 执行，不使用历史模拟脚本冒充正式测试。

## 版本与发布规则

- `MARKETING_VERSION` 必须使用三段式数字版本，例如 `1.0.0`。
- `CURRENT_PROJECT_VERSION` 必须是正整数构建号。
- `CFBundleShortVersionString` 必须读取 `$(MARKETING_VERSION)`，禁止在 `Info.plist` 中再维护一份硬编码版本号。
- 隐私政策真源为 `docs/privacy-policy.html`。
- 技术支持页面真源为 `docs/support.html`。
- GitHub Pages 从 `master` 分支的 `docs/` 目录发布。
- App Store 截图放在 `AppStoreScreenshots/`，按显示屏尺寸分目录管理。

## 日志与验证规则

- 验证结论必须基于构建结果、实际输出或截图，不基于“看起来应该没问题”。
- 调试日志要覆盖输入、状态变化、分支命中和最终结果，并使用统一关键字方便过滤。
- 验证完成后删除本次排查加入的临时日志和测试入口。
- 文档修改以链接、路径、格式和内容覆盖检查为主。
- Swift、资源或工程配置修改，默认运行完整验证脚本。

完整验证命令：

```bash
./scripts/verify.sh
```

只执行构建：

```bash
./scripts/build.sh
```

脚本通过命令级 `DEVELOPER_DIR` 使用 `/Applications/Xcode.app`，不会修改系统全局的 `xcode-select` 配置。

最低验证口径：

- 仅修改文档：检查本地链接和路径，并运行 `git diff --check`。
- 修改 Swift 或资源：运行 `./scripts/verify.sh`。
- 修改工程或发布配置：运行 `./scripts/verify.sh`，并核对输出中的版本号与构建号。
- 修改 UI：构建成功；用户明确要求或布局风险较高时，再检查对应设备的模拟器截图。
- 修改公开网页：检查 HTML 内容，并验证线上 URL 返回成功状态。

## 项目特有验证限制

- 当前 `CalculatorPro.xcodeproj` 包含 App Target 和 `CalculatorProTests` XCTest Target。
- `CalculatorProTests/CalculatorTests.swift` 通过现有 `CalculatorPro` Scheme 执行。
- `test_calculator.swift` 复制了一份历史计算逻辑，只能作为参考，不能证明正式实现正确。
- `test_results.md` 是历史人工记录，不代表当前版本的实时测试结果。
- 默认验收标准为静态检查、App build 成功和当前 XCTest 全部通过。

## 适用场景速查

| 我要做什么 | 先检查什么 | 最低验证 |
| --- | --- | --- |
| 修改计算结果或按键行为 | `DialPad` → `MainViewModel` → `ButtonHandler` → `CalculatorState` | `./scripts/verify.sh` + 对应边界输入 |
| 修改数字显示格式 | Foundation 扩展、`DisplayView` 和全部调用点 | `./scripts/verify.sh` |
| 修改键盘或显示区布局 | `UI设计规范.md`、现有组件、Safe Area | build + 对应尺寸截图 |
| 修改颜色或字体 | 公共 Utils、Assets 和全部使用点 | `./scripts/verify.sh` |
| 修改版本号或构建号 | `SOURCE_OF_TRUTH.md`、Xcode build settings、`Info.plist` | `./scripts/verify.sh` 并核对版本输出 |
| 修改隐私政策或支持页 | `docs/` 真源与 GitHub Pages 地址 | HTML 检查 + 线上 URL 验证 |
| 生成 App Store 截图 | 当前真实 App、目标模拟器尺寸、稳定状态栏 | 检查 PNG 像素尺寸和画面内容 |
| 新增或执行单元测试 | `CalculatorProTests` Target 与正式业务实现 | `./scripts/verify.sh`，不得把历史脚本当成 XCTest |

## 提交与交付规则

- 用户未明确要求时，不创建提交。
- 构建产物和 DerivedData 必须保留在仓库外，不加入版本控制。
- 产品代码、公开网页和工程治理改动应分别提交；只有它们共同构成同一个交付物时才允许合并。
- 提交前检查暂存范围，禁止夹带用户未要求提交的修改。
- 交付时必须说明修改文件、已执行的验证以及仍未验证的风险。
