import XCTest

// CalculatorPro UI 自动化测试
// 覆盖：4×5 键盘可见性、基础运算点击、显示更新、未定义、清空、退格

final class CalculatorProUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("-disableAutomaticReviewRequests")
        app.launch()
        return app
    }

    private func primaryDisplay(_ app: XCUIApplication) -> XCUIElement {
        // 主显示区（包含结果数字）
        let display = app.staticTexts
            .matching(NSPredicate(format: "label MATCHES '^[0-9.\\-]+$' OR label == '未定义'"))
            .firstMatch
        return display
    }

    private func openAboutPage(in app: XCUIApplication) {
        let aboutButton = app.buttons["关于与隐私"]
        XCTAssertTrue(aboutButton.waitForExistence(timeout: 3), "应显示「关于与隐私」按钮")
        aboutButton.tap()
        XCTAssertTrue(app.navigationBars["关于"].waitForExistence(timeout: 3), "应打开「关于」页面")
    }

    // MARK: - 启动与布局

    func testLaunchShowsKeypad() throws {
        let app = launchApp()

        // 4×5 = 20 个按钮：10 个数字 + 4 个运算符 + 4 个功能键 + AC + ±/+/=/./%/⌫
        let expectedLabels: Set<String> = [
            "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
            "AC", "+/-", "%", "÷", "×", "−", "+", ".", "=", "⌫"
        ]
        for label in expectedLabels {
            XCTAssertTrue(app.buttons[label].waitForExistence(timeout: 2),
                          "键盘缺少按钮 \(label)")
        }

        // 工具栏按钮
        XCTAssertTrue(app.buttons["工具"].exists, "缺少「工具」按钮")
        XCTAssertTrue(app.buttons["关于与隐私"].exists, "缺少「关于与隐私」按钮")
        XCTAssertTrue(app.buttons["计算历史"].exists, "缺少「计算历史」按钮")

        // 初始显示 0
        XCTAssertTrue(primaryDisplay(app).waitForExistence(timeout: 2))
        XCTAssertEqual(primaryDisplay(app).label, "0")
    }

    func testFinancialPlanningEntryShowsBothModes() throws {
        let app = launchApp()
        let entry = app.buttons["tools-menu-entry"]
        XCTAssertTrue(entry.waitForExistence(timeout: 3), "应显示工具菜单入口")
        entry.tap()

        XCTAssertTrue(app.navigationBars["工具"].waitForExistence(timeout: 3))
        let financialTool = app.buttons["财务自由计算器"]
        XCTAssertTrue(financialTool.waitForExistence(timeout: 2), "应显示财务自由计算器入口")
        financialTool.tap()

        XCTAssertTrue(app.navigationBars["财务测算"].waitForExistence(timeout: 3))
        XCTAssertTrue(
            app.descendants(matching: .any)["fire-planning-content"].waitForExistence(timeout: 2),
            "默认应显示 FIRE 模式"
        )

        let runwaySegment = app.buttons["资产续航"]
        XCTAssertTrue(runwaySegment.waitForExistence(timeout: 2), "应显示资产续航分段")
        runwaySegment.tap()
        XCTAssertTrue(
            app.descendants(matching: .any)["runway-planning-content"].waitForExistence(timeout: 2),
            "切换后应显示资产续航模式"
        )
    }

    // MARK: - 关于页

    func testAboutShowsRatingAndUpdateControls() throws {
        let app = launchApp()
        openAboutPage(in: app)

        let ratingButton = app.buttons["about-rating-button"]
        XCTAssertTrue(ratingButton.waitForExistence(timeout: 3),
                      "关于页应提供手动评分入口")
        XCTAssertEqual(ratingButton.label, "给个好评",
                       "手动评分入口应提供清晰的无障碍名称")

        let updateButton = app.buttons["about-update-button"]
        XCTAssertTrue(updateButton.waitForExistence(timeout: 3),
                      "关于页应提供检查更新入口")
        XCTAssertEqual(updateButton.label, "检查更新",
                       "检查更新入口应提供清晰的无障碍名称")

        let version = app.descendants(matching: .any)["about-current-version"]
        XCTAssertTrue(version.waitForExistence(timeout: 2),
                      "关于页应显示当前版本")
        XCTAssertTrue(
            version.label.range(
                of: #"^当前版本 [0-9]+\.[0-9]+\.[0-9]+$"#,
                options: .regularExpression
            ) != nil,
            "当前版本应为三段式数字版本号，实际为 \(version.label)"
        )
    }

    // MARK: - 基础运算

    func testAddTwoNumbers() throws {
        let app = launchApp()
        let one = app.buttons["1"]
        let two = app.buttons["2"]
        let plus = app.buttons["+"]
        let equal = app.buttons["="]
        let display = primaryDisplay(app)

        XCTAssertTrue(one.waitForExistence(timeout: 3))

        one.tap()
        plus.tap()
        two.tap()
        equal.tap()

        XCTAssertEqual(display.label, "3", "1 + 2 应等于 3")
    }

    func testChainOperations() throws {
        let app = launchApp()
        let display = primaryDisplay(app)

        // 5 + 3 × 2 = 16（顺序计算）
        app.buttons["5"].tap()
        app.buttons["+"].tap()
        app.buttons["3"].tap()
        app.buttons["×"].tap()
        app.buttons["2"].tap()
        app.buttons["="].tap()

        XCTAssertEqual(display.label, "16", "5 + 3 × 2（顺序）应等于 16")
    }

    func testDivisionResult() throws {
        let app = launchApp()
        let display = primaryDisplay(app)

        app.buttons["9"].tap()
        app.buttons["÷"].tap()
        app.buttons["8"].tap()
        app.buttons["="].tap()

        XCTAssertEqual(display.label, "1.125", "9 ÷ 8 应等于 1.125")
    }

    // MARK: - 边界

    func testDivideByZeroShowsUndefined() throws {
        let app = launchApp()
        let display = primaryDisplay(app)

        app.buttons["1"].tap()
        app.buttons["÷"].tap()
        app.buttons["0"].tap()
        app.buttons["="].tap()

        let undefinedText = app.staticTexts["未定义"]
        XCTAssertTrue(undefinedText.waitForExistence(timeout: 2), "应显示「未定义」")
        XCTAssertTrue(undefinedText.exists, "1 ÷ 0 应显示未定义")
    }

    func testClearResetsDisplay() throws {
        let app = launchApp()
        let display = primaryDisplay(app)

        app.buttons["1"].tap()
        app.buttons["2"].tap()
        app.buttons["3"].tap()
        XCTAssertEqual(display.label, "123")

        app.buttons["AC"].tap()
        XCTAssertEqual(display.label, "0", "AC 后应回到 0")
    }

    func testRevertDeletesLastDigit() throws {
        let app = launchApp()
        let display = primaryDisplay(app)

        app.buttons["1"].tap()
        app.buttons["2"].tap()
        app.buttons["3"].tap()
        app.buttons["⌫"].tap()

        XCTAssertEqual(display.label, "12", "123 退格后应为 12")
    }

    func testDecimalInput() throws {
        let app = launchApp()
        let display = primaryDisplay(app)

        app.buttons["3"].tap()
        app.buttons["."].tap()
        app.buttons["1"].tap()
        app.buttons["4"].tap()

        XCTAssertEqual(display.label, "3.14", "应能输入 3.14")
    }

    // MARK: - 截图回归（用于人工目视检查）

    func testSnapshotAfterInteraction() throws {
        let app = launchApp()

        // 输入 12345 + 678 =
        for ch in "12345" { app.buttons[String(ch)].tap() }
        app.buttons["+"].tap()
        for ch in "678" { app.buttons[String(ch)].tap() }
        app.buttons["="].tap()

        // 让 UI 稳定
        let display = primaryDisplay(app)
        XCTAssertEqual(display.label, "13023", "12345 + 678 = 13023")

        // 截屏附带附件，便于 CI 收集
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.lifetime = .keepAlways
        attachment.name = "after-12345-plus-678"
        add(attachment)
    }
}
