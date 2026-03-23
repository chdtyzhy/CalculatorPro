#!/bin/bash
# Tip Calculator Pro 自动化脚本
# 使用方法：./automate.sh [命令]

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "命令 $1 未找到，请先安装"
        exit 1
    fi
}

# 检查环境
check_environment() {
    print_step "检查开发环境..."
    
    check_command node
    check_command npm
    check_command npx
    
    print_success "基础环境检查通过"
    
    # 检查Node版本
    NODE_VERSION=$(node --version | cut -d'v' -f2)
    if [[ $(echo "$NODE_VERSION < 18.0.0" | bc) -eq 1 ]]; then
        print_warning "Node版本较低 ($NODE_VERSION)，建议升级到18+"
    else
        print_success "Node版本 $NODE_VERSION ✓"
    fi
    
    # 检查iOS环境
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v xcodebuild &> /dev/null; then
            print_success "检测到macOS系统，Xcode可用"
        else
            print_error "未检测到Xcode，请先安装Xcode"
            exit 1
        fi
    else
        print_warning "非macOS系统，iOS开发需要macOS"
    fi
}

# 安装依赖
install_deps() {
    print_step "安装项目依赖..."
    
    # 配置淘宝镜像（中国用户）
    print_step "配置淘宝镜像..."
    npm config set registry https://registry.npmmirror.com
    npm config set disturl https://npmmirror.com/dist
    
    # 安装依赖
    npm install --verbose
    
    # 如果安装失败，尝试使用yarn
    if [ $? -ne 0 ]; then
        print_warning "npm安装失败，尝试使用yarn..."
        npm install -g yarn
        yarn config set registry https://registry.npmmirror.com
        yarn install
    fi
    
    print_success "依赖安装完成"
}

# 清理缓存
clean_cache() {
    print_step "清理缓存..."
    
    rm -rf node_modules
    rm -rf $TMPDIR/react-*
    rm -rf $TMPDIR/metro-*
    rm -rf $TMPDIR/haste-map-*
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        rm -rf ~/Library/Developer/Xcode/DerivedData/*
    fi
    
    print_success "缓存清理完成"
}

# 启动开发服务器
start_dev() {
    print_step "启动开发服务器..."
    
    # 启动Metro bundler
    npx react-native start &
    METRO_PID=$!
    
    # 等待几秒让服务器启动
    sleep 5
    
    print_success "开发服务器已启动 (PID: $METRO_PID)"
    echo "按 Ctrl+C 停止服务器"
    
    # 保持脚本运行
    wait $METRO_PID
}

# 运行iOS
run_ios() {
    print_step "启动iOS模拟器..."
    
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "iOS开发需要macOS系统"
        exit 1
    fi
    
    # 检查模拟器
    if command -v xcrun &> /dev/null; then
        print_step "可用的iOS模拟器："
        xcrun simctl list devices | grep -E "iPhone.*Booted" || echo "无运行的模拟器"
    fi
    
    # 启动应用
    npx react-native run-ios
    
    if [ $? -eq 0 ]; then
        print_success "iOS应用启动成功"
    else
        print_error "iOS启动失败"
        exit 1
    fi
}

# 运行测试
run_tests() {
    print_step "运行测试..."
    
    # 运行Jest测试
    npm test -- --watchAll=false
    
    if [ $? -eq 0 ]; then
        print_success "测试通过"
    else
        print_error "测试失败"
        exit 1
    fi
}

# 代码检查
lint_code() {
    print_step "代码检查..."
    
    # ESLint检查
    npx eslint src/ --ext .js,.jsx,.ts,.tsx
    
    if [ $? -eq 0 ]; then
        print_success "代码检查通过"
    else
        print_warning "代码检查发现问题"
    fi
    
    # TypeScript检查
    npx tsc --noEmit
    
    if [ $? -eq 0 ]; then
        print_success "TypeScript检查通过"
    else
        print_warning "TypeScript检查发现问题"
    fi
}

# 构建Android APK（可选）
build_android() {
    print_step "构建Android APK..."
    
    cd android
    
    # 清理gradle缓存
    ./gradlew clean
    
    # 构建release APK
    ./gradlew assembleRelease
    
    if [ $? -eq 0 ]; then
        print_success "Android APK构建成功"
        print_step "APK位置: android/app/build/outputs/apk/release/app-release.apk"
    else
        print_error "Android构建失败"
        exit 1
    fi
    
    cd ..
}

# 生成版本号
generate_version() {
    print_step "生成新版本号..."
    
    # 从package.json读取当前版本
    CURRENT_VERSION=$(node -p "require('./package.json').version")
    
    # 询问版本更新类型
    echo "当前版本: $CURRENT_VERSION"
    echo "选择版本更新类型:"
    echo "1) patch (补丁版本，0.0.X)"
    echo "2) minor (次版本，0.X.0)"  
    echo "3) major (主版本，X.0.0)"
    echo "4) 自定义版本号"
    
    read -p "请输入选择 [1-4]: " choice
    
    case $choice in
        1)
            NEW_VERSION=$(npm version patch --no-git-tag-version)
            ;;
        2)
            NEW_VERSION=$(npm version minor --no-git-tag-version)
            ;;
        3)
            NEW_VERSION=$(npm version major --no-git-tag-version)
            ;;
        4)
            read -p "请输入新版本号 (例如: 1.2.3): " custom_version
            npm version $custom_version --no-git-tag-version
            NEW_VERSION=$custom_version
            ;;
        *)
            print_error "无效选择"
            exit 1
            ;;
    esac
    
    print_success "版本号更新为: $NEW_VERSION"
}

# 创建Git提交
git_commit() {
    print_step "创建Git提交..."
    
    # 检查git状态
    if ! git status --porcelain | grep -q .; then
        print_warning "没有文件变更可提交"
        return
    fi
    
    # 显示变更
    git status
    
    # 添加所有变更
    git add .
    
    # 提交
    read -p "请输入提交信息: " commit_message
    git commit -m "$commit_message"
    
    print_success "Git提交完成"
}

# 显示帮助
show_help() {
    echo -e "${BLUE}Tip Calculator Pro 自动化脚本${NC}"
    echo ""
    echo "使用方法: ./automate.sh [命令]"
    echo ""
    echo "可用命令:"
    echo "  setup        - 设置开发环境"
    echo "  install      - 安装依赖"
    echo "  clean        - 清理缓存"
    echo "  start        - 启动开发服务器"
    echo "  ios          - 运行iOS模拟器"
    echo "  test         - 运行测试"
    echo "  lint         - 代码检查"
    echo "  android      - 构建Android APK (可选)"
    echo "  version      - 生成新版本号"
    echo "  commit       - 创建Git提交"
    echo "  all          - 运行完整流程 (安装→检查→测试→运行)"
    echo "  help         - 显示此帮助"
    echo ""
    echo "示例:"
    echo "  ./automate.sh setup     # 首次设置环境"
    echo "  ./automate.sh all       # 运行完整开发流程"
    echo "  ./automate.sh ios       # 启动iOS模拟器"
}

# 完整流程
run_all() {
    print_step "开始完整自动化流程..."
    
    check_environment
    install_deps
    lint_code
    run_tests
    run_ios
    
    print_success "完整流程执行完成！"
}

# 主函数
main() {
    local command=${1:-"help"}
    
    case $command in
        "setup")
            check_environment
            install_deps
            ;;
        "install")
            install_deps
            ;;
        "clean")
            clean_cache
            ;;
        "start")
            start_dev
            ;;
        "ios")
            run_ios
            ;;
        "test")
            run_tests
            ;;
        "lint")
            lint_code
            ;;
        "android")
            build_android
            ;;
        "version")
            generate_version
            ;;
        "commit")
            git_commit
            ;;
        "all")
            run_all
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# 执行主函数
main "$@"