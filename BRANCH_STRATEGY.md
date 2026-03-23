# 分支策略规范

## 🎯 分支结构

### 主要分支
```
dev (开发分支)
  ├── 所有功能开发在此分支进行
  ├── 日常提交和合并
  ├── 功能测试和集成测试
  └── 准备发布时合并到main

main (主分支)
  ├── 仅包含可发布的稳定版本
  ├── 从dev分支合并而来
  ├── 每个提交都应该是可发布的
  └── 打标签标记版本号
```

### 功能分支 (可选)
```
feature/xxx (功能分支)
  ├── 从dev分支创建
  ├── 用于开发独立功能
  ├── 完成后合并回dev分支
  └── 删除功能分支

hotfix/xxx (热修复分支)
  ├── 从main分支创建 (紧急修复)
  ├── 修复后合并到main和dev
  └── 删除热修复分支
```

## 🚀 工作流程

### 1. 初始设置
```bash
# 克隆项目
git clone git@github.com:chdtyzhy/openClaw-test.git
cd openClaw-test

# 切换到开发分支
git checkout dev

# 确认当前分支
git branch  # 应该显示 * dev
```

### 2. 日常开发
```bash
# 确保在dev分支
git checkout dev

# 拉取最新代码
git pull origin dev

# 进行开发工作
# ... 编写代码 ...

# 提交更改
git add .
git commit -m "feat: 添加XX功能"

# 推送到远程dev分支
git push origin dev
```

### 3. 功能开发 (如果需要)
```bash
# 从dev分支创建功能分支
git checkout -b feature/new-calculator-function

# 开发功能
# ... 编写代码 ...

# 提交更改
git add .
git commit -m "feat: 实现新的计算器功能"

# 切换回dev分支
git checkout dev

# 合并功能分支
git merge feature/new-calculator-function

# 删除功能分支 (本地)
git branch -d feature/new-calculator-function

# 推送到远程
git push origin dev
```

### 4. 发布准备
```bash
# 确保dev分支稳定且通过测试
# 切换到main分支
git checkout main

# 拉取最新main分支
git pull origin main

# 合并dev分支到main
git merge dev

# 打版本标签
git tag -a v1.0.0 -m "版本 1.0.0"

# 推送main分支和标签
git push origin main
git push origin --tags
```

## 📋 提交规范

### 提交消息格式
```
<类型>: <描述>

[可选正文]
[可选脚注]
```

### 类型说明
```
feat:     新功能
fix:      修复bug
docs:     文档更新
style:    代码格式调整
refactor: 代码重构
test:     测试相关
chore:    构建过程或辅助工具变动
```

### 示例
```bash
# 新功能
git commit -m "feat: 添加科学计算功能"

# 修复bug
git commit -m "fix: 修复百分比计算错误"

# 文档更新
git commit -m "docs: 更新使用指南"

# 代码重构
git commit -m "refactor: 优化计算引擎性能"
```

## 🔧 分支保护规则

### dev分支
```
✅ 允许: 直接推送
✅ 允许: 合并请求
✅ 要求: 代码审查 (可选)
✅ 要求: 通过测试
```

### main分支
```
✅ 允许: 从dev分支合并
❌ 禁止: 直接推送
✅ 要求: 代码审查
✅ 要求: 通过所有测试
✅ 要求: 版本标签
```

## 📊 分支状态检查

### 常用命令
```bash
# 查看所有分支
git branch -a

# 查看分支状态
git status

# 查看提交历史
git log --oneline --graph

# 查看远程分支
git remote show origin

# 查看分支差异
git diff dev main
```

### 分支同步
```bash
# 更新本地dev分支
git checkout dev
git pull origin dev

# 更新本地main分支
git checkout main
git pull origin main

# 查看未合并的提交
git log dev --not main
git log main --not dev
```

## 🎯 最佳实践

### 1. 保持分支同步
```
✅ 定期从远程拉取更新
✅ 及时推送本地更改
✅ 解决合并冲突
```

### 2. 提交规范
```
✅ 小步提交，频繁提交
✅ 清晰的提交消息
✅ 相关的更改一起提交
```

### 3. 分支管理
```
✅ 及时删除已合并的功能分支
✅ 保持分支历史清晰
✅ 使用有意义的命名
```

### 4. 代码质量
```
✅ 提交前运行测试
✅ 代码审查 (如果团队合作)
✅ 保持代码风格一致
```

## 🚨 常见问题

### 问题1: 错误的分支操作
```
❌ 错误: 在main分支直接开发
✅ 正确: 在dev分支开发，然后合并到main
```

### 问题2: 忘记切换分支
```bash
# 检查当前分支
git branch

# 如果不在dev分支，切换到dev
git checkout dev
```

### 问题3: 合并冲突
```bash
# 拉取最新代码时发现冲突
git pull origin dev

# 解决冲突后
git add .
git commit -m "fix: 解决合并冲突"
git push origin dev
```

### 问题4: 误提交到main分支
```bash
# 如果误提交到main分支
git checkout dev
git cherry-pick <误提交的哈希值>
git checkout main
git reset --hard HEAD~1  # 回退main分支
git push origin main --force  # 强制推送 (谨慎使用)
```

## 🔗 相关资源

### GitHub设置
```
1. 分支保护规则: Settings → Branches → Branch protection rules
2. 默认分支: Settings → Branches → Default branch (设置为dev)
3. 合并选项: Settings → Merge button (建议启用)
```

### 工具推荐
```
1. Git GUI客户端: GitHub Desktop, GitKraken, SourceTree
2. IDE集成: VS Code, IntelliJ IDEA, Xcode
3. 命令行工具: git, tig (终端Git浏览器)
```

---
**最后更新**: 2026年3月23日
**当前分支策略**: dev为主开发分支，main为发布分支
**负责人**: 项目维护者
**状态**: 已实施