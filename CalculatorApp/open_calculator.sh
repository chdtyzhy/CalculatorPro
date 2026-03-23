#!/bin/bash

echo "正在打开 Calculator Pro 预览..."
echo ""
echo "请确保已安装现代浏览器 (Chrome、Edge、Firefox等)"
echo ""

# 检查文件是否存在
if [ ! -f "calculator_preview.html" ]; then
    echo "错误: 找不到 calculator_preview.html 文件"
    echo "请确保在正确的目录中运行此脚本"
    echo "正确目录: openClaw-test/CalculatorApp/"
    read -p "按回车键退出..."
    exit 1
fi

# 尝试用默认命令打开
if command -v xdg-open &> /dev/null; then
    # Linux
    xdg-open calculator_preview.html
elif command -v open &> /dev/null; then
    # Mac
    open calculator_preview.html
elif command -v start &> /dev/null; then
    # Windows (如果安装了WSL或Cygwin)
    start calculator_preview.html
else
    echo "无法自动打开文件，请手动操作:"
    echo "1. 打开浏览器 (Chrome、Edge、Firefox等)"
    echo "2. 按 Ctrl+O (Windows/Linux) 或 Cmd+O (Mac)"
    echo "3. 选择 calculator_preview.html 文件"
    echo "4. 点击打开"
fi

echo ""
read -p "按回车键退出..."