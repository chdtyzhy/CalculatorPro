#!/usr/bin/env python3
"""
应用工厂 - iOS应用自动化生成和发布系统
将整个流程自动化：市场调研 → 代码生成 → 测试 → 上架 → 监控
"""

import os
import sys
import json
import subprocess
import shutil
from datetime import datetime
from typing import Dict, List, Optional
import argparse

class AppFactory:
    """iOS应用自动化工厂"""
    
    def __init__(self, app_name: str, app_type: str = "tip_calculator"):
        self.app_name = app_name
        self.app_type = app_type
        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        self.timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # 配置
        self.config = {
            "app_name": app_name,
            "app_type": app_type,
            "pricing": 8.00,  # 人民币定价
            "target_income": 2000,  # 目标月收入
            "development_days": 7,
            "platform": "ios",
            "tech_stack": "react_native",
            "features": ["tip_calculation", "split_bill", "history", "dark_mode"]
        }
        
        # 路径
        self.dirs = {
            "templates": os.path.join(self.base_dir, "templates"),
            "output": os.path.join(self.base_dir, "output", f"{app_name}_{self.timestamp}"),
            "reports": os.path.join(self.base_dir, "reports"),
            "logs": os.path.join(self.base_dir, "logs")
        }
        
        self._setup_directories()
    
    def _setup_directories(self):
        """创建必要的目录结构"""
        for dir_path in self.dirs.values():
            os.makedirs(dir_path, exist_ok=True)
    
    def log(self, message: str, level: str = "INFO"):
        """日志记录"""
        log_file = os.path.join(self.dirs["logs"], f"{self.timestamp}.log")
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"[{timestamp}] [{level}] {message}\n"
        
        with open(log_file, "a", encoding="utf-8") as f:
            f.write(log_entry)
        
        # 控制台输出
        colors = {
            "INFO": "\033[94m",  # 蓝色
            "SUCCESS": "\033[92m",  # 绿色
            "WARNING": "\033[93m",  # 黄色
            "ERROR": "\033[91m",  # 红色
        }
        color = colors.get(level, "\033[0m")
        print(f"{color}[{level}] {message}\033[0m")
    
    def run_command(self, command: str, cwd: str = None) -> tuple:
        """运行shell命令"""
        self.log(f"执行命令: {command}")
        
        try:
            result = subprocess.run(
                command,
                shell=True,
                cwd=cwd or self.base_dir,
                capture_output=True,
                text=True,
                timeout=300  # 5分钟超时
            )
            
            if result.returncode == 0:
                self.log(f"命令成功: {command}", "SUCCESS")
            else:
                self.log(f"命令失败: {command}\n错误: {result.stderr}", "ERROR")
            
            return result.returncode, result.stdout, result.stderr
        except subprocess.TimeoutExpired:
            self.log(f"命令超时: {command}", "ERROR")
            return -1, "", "命令执行超时"
        except Exception as e:
            self.log(f"命令异常: {command}\n异常: {str(e)}", "ERROR")
            return -1, "", str(e)
    
    def market_research(self) -> Dict:
        """市场调研自动化"""
        self.log("开始市场调研...")
        
        # 这里可以集成实际的API调用，如App Store数据抓取
        # 目前使用模拟数据
        research_result = {
            "competitors": [
                {"name": "Quick Tip Calculator", "price": 12.00, "rating": 4.5, "reviews": 1200},
                {"name": "Tip & Split", "price": 6.00, "rating": 4.2, "reviews": 850},
                {"name": "Easy Tip Calculator", "price": 8.00, "rating": 4.3, "reviews": 950}
            ],
            "recommended_price": 8.00,
            "differentiation_points": [
                "无广告体验",
                "完整历史记录",
                "深色/浅色主题",
                "AA制分摊计算",
                "多货币支持"
            ],
            "estimated_market_size": "每月5000次下载",
            "recommended_features": ["history", "dark_mode", "multi_currency", "widget"]
        }
        
        # 保存调研结果
        research_file = os.path.join(self.dirs["reports"], f"market_research_{self.timestamp}.json")
        with open(research_file, "w", encoding="utf-8") as f:
            json.dump(research_result, f, indent=2, ensure_ascii=False)
        
        self.log(f"市场调研完成，结果保存到: {research_file}", "SUCCESS")
        return research_result
    
    def generate_code(self) -> bool:
        """代码生成"""
        self.log("开始代码生成...")
        
        try:
            # 复制模板代码
            template_dir = self.dirs["templates"]
            output_dir = self.dirs["output"]
            
            # 如果模板目录不存在，使用当前目录作为基础
            if not os.path.exists(template_dir):
                template_dir = self.base_dir
            
            # 复制文件
            for item in os.listdir(template_dir):
                if item.startswith(".") or item in ["templates", "output", "reports", "logs"]:
                    continue
                
                src = os.path.join(template_dir, item)
                dst = os.path.join(output_dir, item)
                
                if os.path.isdir(src):
                    shutil.copytree(src, dst, dirs_exist_ok=True)
                else:
                    shutil.copy2(src, dst)
            
            # 更新配置文件
            package_json = os.path.join(output_dir, "package.json")
            if os.path.exists(package_json):
                with open(package_json, "r", encoding="utf-8") as f:
                    package_data = json.load(f)
                
                package_data["name"] = self.app_name.lower().replace(" ", "-")
                package_data["displayName"] = self.app_name
                
                with open(package_json, "w", encoding="utf-8") as f:
                    json.dump(package_data, f, indent=2)
            
            # 更新App.tsx中的应用名称
            app_tsx = os.path.join(output_dir, "App.tsx")
            if os.path.exists(app_tsx):
                with open(app_tsx, "r", encoding="utf-8") as f:
                    content = f.read()
                
                # 替换应用标题
                content = content.replace("小费计算器", self.app_name)
                
                with open(app_tsx, "w", encoding="utf-8") as f:
                    f.write(content)
            
            self.log(f"代码生成完成，输出目录: {output_dir}", "SUCCESS")
            return True
            
        except Exception as e:
            self.log(f"代码生成失败: {str(e)}", "ERROR")
            return False
    
    def setup_environment(self) -> bool:
        """设置开发环境"""
        self.log("设置开发环境...")
        
        output_dir = self.dirs["output"]
        
        # 1. 检查Node.js
        code, stdout, stderr = self.run_command("node --version", output_dir)
        if code != 0:
            self.log("Node.js未安装，请先安装Node.js", "ERROR")
            return False
        
        # 2. 配置npm淘宝镜像（中国用户）
        self.run_command("npm config set registry https://registry.npmmirror.com", output_dir)
        self.run_command("npm config set disturl https://npmmirror.com/dist", output_dir)
        
        # 3. 安装依赖
        code, stdout, stderr = self.run_command("npm install", output_dir)
        if code != 0:
            self.log("依赖安装失败，尝试使用yarn...", "WARNING")
            self.run_command("npm install -g yarn", output_dir)
            self.run_command("yarn config set registry https://registry.npmmirror.com", output_dir)
            code, stdout, stderr = self.run_command("yarn install", output_dir)
        
        if code == 0:
            self.log("环境设置完成", "SUCCESS")
            return True
        else:
            self.log("环境设置失败", "ERROR")
            return False
    
    def run_tests(self) -> bool:
        """运行测试"""
        self.log("运行测试...")
        
        output_dir = self.dirs["output"]
        
        # 1. TypeScript检查
        code, stdout, stderr = self.run_command("npx tsc --noEmit", output_dir)
        if code != 0:
            self.log("TypeScript检查失败", "WARNING")
        
        # 2. ESLint检查
        code, stdout, stderr = self.run_command("npx eslint src/ --ext .js,.jsx,.ts,.tsx --fix", output_dir)
        if code != 0:
            self.log("ESLint检查发现问题", "WARNING")
        
        # 3. 运行Jest测试
        code, stdout, stderr = self.run_command("npm test -- --watchAll=false --passWithNoTests", output_dir)
        
        if code == 0:
            self.log("测试通过", "SUCCESS")
            return True
        else:
            self.log("测试失败", "ERROR")
            return False
    
    def build_app(self, platform: str = "ios") -> bool:
        """构建应用"""
        self.log(f"构建{platform.upper()}应用...")
        
        output_dir = self.dirs["output"]
        
        if platform.lower() == "ios":
            # 检查是否在macOS上
            if sys.platform != "darwin":
                self.log("iOS构建需要macOS系统", "ERROR")
                return False
            
            # 构建iOS应用
            code, stdout, stderr = self.run_command("npx react-native run-ios --simulator", output_dir)
            
            if code == 0:
                self.log("iOS应用构建成功", "SUCCESS")
                return True
            else:
                self.log("iOS应用构建失败", "ERROR")
                return False
        
        elif platform.lower() == "android":
            # 构建Android应用
            code, stdout, stderr = self.run_command("cd android && ./gradlew assembleRelease", output_dir)
            
            if code == 0:
                self.log("Android应用构建成功", "SUCCESS")
                return True
            else:
                self.log("Android应用构建失败", "ERROR")
                return False
        
        else:
            self.log(f"不支持的平台: {platform}", "ERROR")
            return False
    
    def create_app_store_listing(self) -> Dict:
        """创建App Store上架材料"""
        self.log("创建App Store上架材料...")
        
        listing = {
            "app_name": self.app_name,
            "description": f"{self.app_name} - 智能小费计算器，支持AA制分摊和完整历史记录。简洁易用，无广告干扰。",
            "keywords": ["小费", "计算器", "AA制", "分摊", "餐厅", "账单", "分享"],
            "price": self.config["pricing"],
            "screenshots": [
                "需要提供: 主界面截图",
                "需要提供: 计算结果截图", 
                "需要提供: 历史记录截图",
                "需要提供: 设置界面截图"
            ],
            "promo_text": "精准计算，公平分摊",
            "support_url": "https://yourwebsite.com/support",
            "privacy_policy_url": "https://yourwebsite.com/privacy",
            "categories": ["工具", "财务"],
            "age_rating": "4+"
        }
        
        # 保存上架材料
        listing_file = os.path.join(self.dirs["reports"], f"app_store_listing_{self.timestamp}.json")
        with open(listing_file, "w", encoding="utf-8") as f:
            json.dump(listing, f, indent=2, ensure_ascii=False)
        
        self.log(f"App Store上架材料创建完成: {listing_file}", "SUCCESS")
        return listing
    
    def generate_income_report(self) -> Dict:
        """生成收入预测报告"""
        self.log("生成收入预测报告...")
        
        monthly_downloads = [50, 100, 200, 300, 500]
        price = self.config["pricing"]
        apple_cut = 0.3  # 苹果分成30%
        
        report = {
            "pricing_analysis": {
                "your_price": price,
                "competitor_avg": 8.67,
                "price_advantage": "比竞品平均便宜7.7%"
            },
            "income_projections": [
                {
                    "month": i + 1,
                    "estimated_downloads": downloads,
                    "revenue_before_apple": downloads * price,
                    "revenue_after_apple": downloads * price * (1 - apple_cut),
                    "cumulative_income": sum([d * price * (1 - apple_cut) for d in monthly_downloads[:i+1]])
                }
                for i, downloads in enumerate(monthly_downloads)
            ],
            "break_even_analysis": {
                "development_cost": 0,  # 你的时间成本
                "apple_developer_fee": 688,  # 年费
                "break_even_downloads": int(688 / (price * (1 - apple_cut))),
                "break_even_months": 2
            },
            "recommendations": [
                f"定价策略: ¥{price:.2f} (有竞争力)",
                "营销重点: 强调无广告、历史记录功能",
                "更新计划: 每月小更新，每季度大更新",
                "扩展计划: 成功后开发系列工具应用"
            ]
        }
        
        # 保存收入报告
        report_file = os.path.join(self.dirs["reports"], f"income_report_{self.timestamp}.json")
        with open(report_file, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        
        self.log(f"收入预测报告生成完成: {report_file}", "SUCCESS")
        return report
    
    def run_full_pipeline(self):
        """运行完整自动化流水线"""
        self.log("=" * 60, "INFO")
        self.log(f"开始 {self.app_name} 应用自动化流水线", "INFO")
        self.log("=" * 60, "INFO")
        
        results = {}
        
        # 1. 市场调研
        self.log("\n📊 阶段1: 市场调研", "INFO")
        results["market_research"] = self.market_research()
        
        # 2. 代码生成
        self.log("\n💻 阶段2: 代码生成", "INFO")
        results["code_generation"] = self.generate_code()
        
        if not results["code_generation"]:
            self.log("代码生成失败，停止流水线", "ERROR")
            return results
        
        # 3. 环境设置
        self.log("\n⚙️ 阶段3: 环境设置", "INFO")
        results["environment_setup"] = self.setup_environment()
        
        if not results["environment_setup"]:
            self.log("环境设置失败，停止流水线", "ERROR")
            return results
        
        # 4. 运行测试
        self.log("\n🧪 阶段4: 测试", "INFO")
        results["testing"] = self.run_tests()
        
        # 5. 构建应用
        self.log("\n🔨 阶段5: 构建应用", "INFO")
        results["build"] = self.build_app("ios")
        
        # 6. 创建上架材料
        self.log("\n📱 阶段6: App Store上架材料", "INFO")
        results["app_store_listing"] = self.create_app_store_listing()
        
        # 7. 收入预测
        self.log("\n💰 阶段7: 收入预测", "INFO")
        results["income_report"] = self.generate_income_report()
        
        # 生成总结报告
        self.log("\n" + "=" * 60, "INFO")
        self.log("自动化流水线完成总结", "SUCCESS")
        self.log("=" * 60, "INFO")
        
        success_count = sum([1 for k, v in results.items() if v and k not in ["market_research", "app_store_listing", "income_report"]])
        total_count = 4  # 代码生成、环境设置、测试、构建
        
        self.log(f"✅ 成功步骤: {success_count}/{total_count}")
        
        if success_count == total_count:
            self.log("🎉 恭喜！应用已准备好上架！", "SUCCESS")
            self.log(f"📁 项目目录: {self.dirs['output']}")
            self.log(f"📄 报告目录: {self.dirs['reports']}")
            self.log("下一步建议:")
            self.log("1. 在App Store Connect创建应用")
            self.log("2. 准备应用图标和截图")
            self.log("3. 使用fastlane自动上传")
            self.log("4. 提交审核并等待发布")
        else:
            self.log("⚠️ 部分步骤失败，请检查日志", "WARNING")
        
        return results

def main():
    """主函数"""
    parser = argparse.ArgumentParser(description="iOS应用自动化工厂")
    parser.add_argument("--name", required=True, help="应用名称")
    parser.add_argument("--type", default="tip_calculator", help="应用类型 (tip_calculator, unit_converter, etc.)")
    parser.add_argument("--pipeline", action="store_true", help="运行完整流水线")
    parser.add_argument("--research", action="store_true", help="仅运行市场调研")
    parser.add_argument("--generate", action="store_true", help="仅生成代码")
    parser.add_argument("--test", action="store_true", help="仅运行测试")
    parser.add_argument("--build", action="store_true", help="仅构建应用")
    
    args = parser.parse_args()
    
    # 创建应用工厂实例
    factory = AppFactory(args.name, args.type)
    
    if args.research:
        factory.market_research()
    elif args.generate:
        factory.generate_code()
    elif args.test:
        factory.setup_environment()
        factory.run_tests()
    elif args.build:
        factory.setup_environment()
        factory.build_app("ios")
    elif args.pipeline or (not any([args.research, args.generate, args.test, args.build])):
        # 默认运行完整流水线
        factory.run_full_pipeline()
    
    # 保存配置
    config_file = os.path.join(factory.dirs["output"], "factory_config.json")
    with open(config_file, "w", encoding="utf-8") as f:
        json.dump(factory.config, f, indent=2, ensure_ascii=False)
    
    factory.log(f"配置保存到: {config_file}", "INFO")

if __name__ == "__main__":
    main()