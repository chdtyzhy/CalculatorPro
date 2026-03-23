@echo off
echo 正在打开 Calculator Pro 预览...
echo.
echo 请确保已安装现代浏览器 (Chrome、Edge、Firefox等)
echo.

REM 检查文件是否存在
if not exist "calculator_preview.html" (
    echo 错误: 找不到 calculator_preview.html 文件
    echo 请确保在正确的目录中运行此脚本
    echo 正确目录: openClaw-test/CalculatorApp/
    pause
    exit /b 1
)

REM 尝试用默认浏览器打开
start calculator_preview.html

echo.
echo 如果浏览器没有自动打开，请手动:
echo 1. 打开浏览器 (Chrome、Edge、Firefox等)
echo 2. 按 Ctrl+O
echo 3. 选择 calculator_preview.html 文件
echo 4. 点击打开
echo.
pause