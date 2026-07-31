import SwiftUI
import StoreKit
import PhotosUI

// 主界面视图
struct MainView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @AppStorage("calculatorTheme") private var selectedTheme = CalculatorTheme.mist.rawValue
    @AppStorage("customBackgroundActive") private var isCustomBackgroundActive = false
    @StateObject var appModel: MainViewModel = MainViewModel()
    @State private var isShowingHistory = false
    @State private var isShowingAbout = false
    @State private var isShowingThemes = false
    @State private var isShowingToolsMenu = false
    @State private var customBackgroundImage = CustomBackgroundStore.load()
    
    let duration: TimeInterval = 0.3

    private var activeTheme: CalculatorTheme {
        CalculatorTheme(rawValue: selectedTheme) ?? .mist
    }
    
    var body: some View {
        ZStack {
            activeTheme.background
                .ignoresSafeArea()

            if isCustomBackgroundActive, let customBackgroundImage {
                GeometryReader { proxy in
                    Image(uiImage: customBackgroundImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                }
                .ignoresSafeArea()

                activeTheme.background
                    .opacity(0.78)
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
            }

            GeometryReader { proxy in
                let width: CGFloat = proxy.size.width
                let horizontalPadding: CGFloat = width <= 375 ? 12 : 16
                let keypadSpacing: CGFloat = width <= 375 ? 8 : 10
                let contentWidth = min(width - horizontalPadding * 2, 400)
                let buttonWidth = (contentWidth - keypadSpacing * 3) / 4
                let buttonHeight = min(buttonWidth * 0.78, width <= 375 ? 58 : 68)
                let keypadHeight = buttonHeight * 5 + keypadSpacing * 4

                VStack(spacing: 0) {
                    HStack {
                        Spacer()

                        HStack(spacing: 0) {
                            Button(action: { isShowingToolsMenu = true }) {
                                Image(systemName: "square.grid.2x2")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(activeTheme.primaryInk)
                                    .frame(width: 28, height: 28)
                                    .compactToolbarSurface(tint: activeTheme.numberKey)
                            }
                            .buttonStyle(.plain)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                            .accessibilityLabel("工具")
                            .accessibilityIdentifier("tools-menu-entry")

                            Button(action: { isShowingAbout = true }) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(activeTheme.primaryInk)
                                    .frame(width: 28, height: 28)
                                    .compactToolbarSurface(tint: activeTheme.numberKey)
                            }
                            .buttonStyle(.plain)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                            .accessibilityLabel("关于与隐私")

                            Button(action: { isShowingThemes = true }) {
                                Image(systemName: "paintpalette")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(activeTheme.primaryInk)
                                    .frame(width: 28, height: 28)
                                    .compactToolbarSurface(tint: activeTheme.numberKey)
                            }
                            .buttonStyle(.plain)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                            .accessibilityLabel("更换主题")

                            Button(action: { isShowingHistory = true }) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(activeTheme.primaryInk)
                                    .frame(width: 28, height: 28)
                                    .compactToolbarSurface(tint: activeTheme.numberKey)
                            }
                            .buttonStyle(.plain)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                            .accessibilityLabel("计算历史")
                        }
                    }
                    .frame(height: 44)

                    DisplayView(height: 0, colorScheme: colorScheme, duration: duration)
                        .environmentObject(appModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 4)
                        .padding(.bottom, 10)
                    
                    CalculatorButtons(stackSpacing: keypadSpacing)
                        .environmentObject(appModel)
                        .frame(height: keypadHeight)
                }
                .frame(width: contentWidth)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)
            }
        }
        .sheet(isPresented: $isShowingHistory) {
            HistoryView(isPresented: $isShowingHistory)
                .environmentObject(appModel)
        }
        .sheet(isPresented: $isShowingAbout) {
            AboutView(isPresented: $isShowingAbout)
        }
        .sheet(isPresented: $isShowingToolsMenu) {
            ToolsMenuView()
        }
        .fullScreenCover(isPresented: $isShowingThemes) {
            ThemePickerView(
                selection: $selectedTheme,
                isPresented: $isShowingThemes,
                customBackgroundImage: $customBackgroundImage,
                isCustomBackgroundActive: $isCustomBackgroundActive
            )
        }
        .environment(\.calculatorTheme, activeTheme)
        .onAppear {
            if customBackgroundImage == nil {
                isCustomBackgroundActive = false
            }
        }
    }
}

private struct ThemePickerView: View {
    @Binding var selection: String
    @Binding var isPresented: Bool
    @Binding var customBackgroundImage: UIImage?
    @Binding var isCustomBackgroundActive: Bool
    @State private var photoSelection: PhotosPickerItem?
    @State private var backgroundErrorMessage: String?

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 22) {
                    LazyVGrid(columns: columns, spacing: 22) {
                        ForEach(CalculatorTheme.allCases) { option in
                            VStack(spacing: 10) {
                                ThemePreview(theme: option)

                                Text(option.name)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)

                                Button {
                                    selection = option.rawValue
                                    isCustomBackgroundActive = false
                                } label: {
                                    Text(isTemplateActive(option) ? "生效中" : "生效")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                }
                                .buttonStyle(.plain)
                                .background(
                                    Capsule()
                                        .fill(
                                            isTemplateActive(option)
                                                ? Color.gray.opacity(0.45)
                                                : Color.blue
                                        )
                                )
                                .disabled(isTemplateActive(option))
                                .accessibilityLabel(
                                    isTemplateActive(option)
                                        ? "\(option.name)皮肤，生效中"
                                        : "生效\(option.name)皮肤"
                                )
                            }
                        }
                    }

                    customBackgroundPanel
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 20)
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .onChange(of: photoSelection) { newValue in
                guard let newValue else { return }
                loadCustomBackground(from: newValue)
            }
            .alert(
                "无法保存背景图片",
                isPresented: Binding(
                    get: { backgroundErrorMessage != nil },
                    set: { if !$0 { backgroundErrorMessage = nil } }
                )
            ) {
                Button("知道了", role: .cancel) {}
            } message: {
                Text(backgroundErrorMessage ?? "")
            }
            .navigationTitle("换肤")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .accessibilityLabel("返回")
                }
            }
        }
    }

    private var customBackgroundPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("自定义背景", systemImage: "photo.on.rectangle.angled")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)

            Text("可选用一张本地照片作为计算器背景")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.secondary)

            if let customBackgroundImage {
                Image(uiImage: customBackgroundImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 96)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .accessibilityHidden(true)
            }

            PhotosPicker(selection: $photoSelection, matching: .images) {
                Label(
                    customBackgroundImage == nil ? "选择背景图片" : "重新选择图片",
                    systemImage: "photo.badge.plus"
                )
                .font(.system(size: 14, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.bordered)
            .tint(.secondary)
            .accessibilityLabel(customBackgroundImage == nil ? "选择背景图片" : "重新选择背景图片")

            if customBackgroundImage != nil {
                HStack(spacing: 12) {
                    Button {
                        isCustomBackgroundActive = true
                    } label: {
                        Text(isCustomBackgroundActive ? "生效中" : "生效")
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.bordered)
                    .tint(.secondary)
                    .disabled(isCustomBackgroundActive)
                    .accessibilityLabel(
                        isCustomBackgroundActive ? "自定义背景，生效中" : "生效自定义背景"
                    )

                    Button(role: .destructive, action: removeCustomBackground) {
                        Label("移除", systemImage: "trash")
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("移除自定义背景")
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
                )
        )
    }

    private func isTemplateActive(_ theme: CalculatorTheme) -> Bool {
        !isCustomBackgroundActive && selection == theme.rawValue
    }

    private func loadCustomBackground(from item: PhotosPickerItem) {
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else {
                    throw CustomBackgroundStore.StoreError.invalidImage
                }
                try CustomBackgroundStore.save(image)
                customBackgroundImage = image
                isCustomBackgroundActive = true
            } catch {
                backgroundErrorMessage = "请选择有效的照片后重试。"
            }
        }
    }

    private func removeCustomBackground() {
        do {
            try CustomBackgroundStore.remove()
            customBackgroundImage = nil
            isCustomBackgroundActive = false
            photoSelection = nil
        } catch {
            backgroundErrorMessage = "图片暂时无法移除，请稍后重试。"
        }
    }
}

private enum CustomBackgroundStore {
    enum StoreError: Error {
        case invalidImage
        case unavailableDirectory
        case encodingFailed
    }

    private static let filename = "calculator-custom-background.jpg"

    private static var fileURL: URL? {
        FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent(filename)
    }

    static func load() -> UIImage? {
        guard let fileURL else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }

    static func save(_ image: UIImage) throws {
        guard let fileURL else { throw StoreError.unavailableDirectory }
        guard let data = image.jpegData(compressionQuality: 0.86) else {
            throw StoreError.encodingFailed
        }

        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: fileURL, options: .atomic)
    }

    static func remove() throws {
        guard let fileURL else { throw StoreError.unavailableDirectory }
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        try FileManager.default.removeItem(at: fileURL)
    }
}

private struct ThemePreview: View {
    let theme: CalculatorTheme

    private let keys = [
        "⌫", "AC", "%", "÷",
        "7", "8", "9", "×",
        "4", "5", "6", "−",
        "1", "2", "3", "+",
        "+/−", "0", ".", "="
    ]

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 3),
        count: 4
    )

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Image(systemName: optionIcon)
                    .font(.system(size: 8, weight: .bold))
                Spacer()
                Image(systemName: "ellipsis")
                    .font(.system(size: 8, weight: .bold))
            }
            .foregroundColor(theme.primaryInk)

            VStack(alignment: .trailing, spacing: 2) {
                Text("89×(−2)")
                    .font(.system(size: 7, design: .rounded))
                    .foregroundColor(theme.secondaryInk)
                Text("6")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(theme.primaryInk)
            }
            .frame(maxWidth: .infinity, minHeight: 70, alignment: .bottomTrailing)

            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(Array(keys.enumerated()), id: \.offset) { index, key in
                    Text(key)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(keyForeground(at: index))
                        .frame(maxWidth: .infinity)
                        .frame(height: 26)
                        .background(
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(keyBackground(at: index))
                        )
                }
            }
        }
        .padding(9)
        .background(theme.background)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
        .accessibilityHidden(true)
    }

    private var optionIcon: String {
        theme.icon
    }

    private func keyBackground(at index: Int) -> Color {
        if [0, 1, 2, 16].contains(index) {
            return theme.functionKey
        }
        if [3, 7, 11, 15].contains(index) {
            return theme.operationKey
        }
        if index == 19 {
            return theme.equalKey
        }
        return theme.numberKey
    }

    private func keyForeground(at index: Int) -> Color {
        [3, 7, 11, 15, 19].contains(index) ? .white : theme.primaryInk
    }
}

private struct AboutView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview
    @Binding var isPresented: Bool
    @State private var isCheckingForUpdate = false
    @State private var isShowingUpdateAlert = false
    @State private var updateAlertTitle = ""
    @State private var updateAlertMessage = ""
    @State private var availableUpdateURL: URL?

    private let privacyURL = URL(string: "https://chdtyzhy.github.io/CalculatorPro/privacy-policy.html")!
    private let supportURL = URL(string: "https://chdtyzhy.github.io/CalculatorPro/support.html")!
    private let feedbackURL = URL(string: "https://github.com/chdtyzhy/CalculatorPro/issues/new")!
    private let appUpdateManager = AppUpdateManager()

    private var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "未知"
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    Label("计算记录仅保存在本机", systemImage: "iphone")
                    Label("不收集或上传用户数据", systemImage: "hand.raised.fill")
                } header: {
                    Text("芃芃计算器")
                }

                Section {
                    Button(action: requestRating) {
                        Label("给个好评", systemImage: "star")
                    }
                    .accessibilityLabel("给个好评")
                    .accessibilityIdentifier("about-rating-button")

                    Button(action: checkForUpdate) {
                        HStack {
                            Label("检查更新", systemImage: "arrow.triangle.2.circlepath")
                            Spacer()
                            if isCheckingForUpdate {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isCheckingForUpdate)
                    .accessibilityLabel("检查更新")
                    .accessibilityIdentifier("about-update-button")

                    LabeledContent("当前版本", value: currentVersion)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("当前版本 \(currentVersion)")
                        .accessibilityIdentifier("about-current-version")
                } header: {
                    Text("App Store")
                }

                Section {
                    Link(destination: privacyURL) {
                        Label("隐私政策", systemImage: "lock.shield")
                    }
                    Link(destination: supportURL) {
                        Label("技术支持", systemImage: "questionmark.circle")
                    }
                    Link(destination: feedbackURL) {
                        Label("反馈问题", systemImage: "bubble.left.and.exclamationmark.bubble.right")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("关于")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成") { isPresented = false }
                }
            }
            .alert(updateAlertTitle, isPresented: $isShowingUpdateAlert) {
                if let availableUpdateURL {
                    Button("前往 App Store") {
                        openURL(availableUpdateURL)
                    }
                }
                Button("知道了", role: .cancel) {}
            } message: {
                Text(updateAlertMessage)
            }
        }
    }

    private func requestRating() {
        // 手动请求不经过自动评分调度器，不改变其 30 天计时。
        requestReview()
    }

    private func checkForUpdate() {
        isCheckingForUpdate = true
        Task {
            let result = await appUpdateManager.checkForUpdate()
            isCheckingForUpdate = false

            switch result {
            case .upToDate:
                showAlert(title: "已是最新版本", message: "你正在使用最新版本。")
            case .updateAvailable(let storeInfo):
                showAlert(
                    title: "发现新版本 \(storeInfo.version)",
                    message: "前往 App Store 更新，体验最新功能。",
                    updateURL: storeInfo.storeURL
                )
            case .unavailable:
                showAlert(
                    title: "暂时无法检查更新",
                    message: "请检查网络连接后再试。"
                )
            }
        }
    }

    private func showAlert(title: String, message: String, updateURL: URL? = nil) {
        availableUpdateURL = updateURL
        updateAlertTitle = title
        updateAlertMessage = message
        isShowingUpdateAlert = true
    }
}

private struct HistoryView: View {
    @Environment(\.calculatorTheme) private var theme
    @EnvironmentObject private var appModel: MainViewModel
    @Binding var isPresented: Bool
    @State private var categoryEntry: CalculationHistoryEntry?

    var body: some View {
        NavigationView {
            Group {
                if appModel.history.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "clock")
                            .font(.system(size: 34))
                        Text("暂无计算记录")
                            .font(.headline)
                    }
                    .foregroundColor(theme.secondaryInk)
                } else {
                    List {
                        ForEach(appModel.history) { entry in
                            VStack(alignment: .trailing, spacing: 8) {
                                HStack(spacing: 12) {
                                    Button {
                                        categoryEntry = entry
                                    } label: {
                                        Label(entry.category ?? "添加类别", systemImage: "tag.fill")
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .foregroundColor(
                                                entry.category == nil
                                                    ? theme.secondaryInk
                                                    : theme.equalKey
                                            )
                                            .lineLimit(1)
                                    }
                                    .buttonStyle(.plain)
                                    .layoutPriority(1)

                                    Spacer(minLength: 8)

                                    Text(entry.expression)
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundColor(theme.secondaryInk)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.75)
                                }

                                Button {
                                    appModel.reuse(entry)
                                    isPresented = false
                                } label: {
                                    Text(entry.result)
                                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                                        .foregroundColor(theme.primaryInk)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .buttonStyle(.plain)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .contextMenu {
                                Button {
                                    categoryEntry = entry
                                } label: {
                                    Label("设置类别", systemImage: "tag")
                                }
                                Button {
                                    UIPasteboard.general.string = entry.copyText
                                } label: {
                                    Label("复制算式与结果", systemImage: "doc.on.doc")
                                }
                            }
                        }
                        .onDelete(perform: appModel.deleteHistory)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("计算历史")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成") { isPresented = false }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("清空", role: .destructive) { appModel.clearHistory() }
                        .disabled(appModel.history.isEmpty)
                        .opacity(appModel.history.isEmpty ? 0 : 1)
                }
            }
        }
        .sheet(item: $categoryEntry) { entry in
            CategoryPickerView(entry: entry)
                .environmentObject(appModel)
                .adaptiveCategorySheetPresentation()
        }
    }
}

private struct CategoryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.calculatorTheme) private var theme
    @EnvironmentObject private var appModel: MainViewModel
    let entry: CalculationHistoryEntry
    @State private var customCategory: String

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    init(entry: CalculationHistoryEntry) {
        self.entry = entry
        _customCategory = State(initialValue: entry.category ?? "")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("选择类别")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        Text("为这条计算添加用途")
                            .font(.subheadline)
                            .foregroundColor(theme.secondaryInk)
                    }

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .frame(width: 32, height: 32)
                    }
                    .adaptiveGlassButtonStyle(tint: theme.numberKey)
                    .accessibilityLabel("关闭")
                }

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(CalculationHistoryEntry.presetCategories, id: \.self) { category in
                        Button {
                            save(category)
                        } label: {
                            Label(category, systemImage: icon(for: category))
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(
                                    entry.category == category ? .white : theme.primaryInk
                                )
                                .frame(maxWidth: .infinity, minHeight: 46)
                        }
                        .adaptiveGlassButtonStyle(
                            tint: entry.category == category ? theme.equalKey : theme.numberKey
                        )
                    }
                }

                HStack(spacing: 10) {
                    Image(systemName: "pencil")
                        .foregroundColor(theme.secondaryInk)
                    TextField("自定义类别", text: $customCategory)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .onSubmit(saveCustomCategory)
                    Button(action: saveCustomCategory) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .bold))
                            .frame(width: 32, height: 32)
                    }
                    .adaptiveGlassButtonStyle(tint: theme.numberKey)
                    .disabled(customCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 14)
                .frame(height: 50)
                .adaptiveGlassSurface(tint: theme.numberKey)

                if entry.category != nil {
                    Button(role: .destructive) {
                        save("")
                    } label: {
                        Label("移除当前类别", systemImage: "tag.slash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .adaptiveKeyboardDismissal()
        .background(theme.background.ignoresSafeArea())
    }

    private func saveCustomCategory() {
        let trimmed = customCategory.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        save(trimmed)
    }

    private func save(_ category: String) {
        appModel.updateCategory(for: entry.id, category: category)
        dismiss()
    }

    private func icon(for category: String) -> String {
        switch category {
        case "房租": return "house.fill"
        case "餐饮": return "fork.knife"
        case "购物": return "bag.fill"
        case "交通": return "car.fill"
        case "水电": return "bolt.fill"
        case "工资": return "banknote.fill"
        default: return "tag.fill"
        }
    }
}

private struct LegacyGlassButtonStyle: ButtonStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint)
                    .shadow(color: .black.opacity(0.08), radius: 5, y: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension View {
    @ViewBuilder
    func adaptiveGlassButtonStyle(tint: Color) -> some View {
        if #available(iOS 26.0, *) {
            buttonStyle(.glass)
                .tint(tint)
        } else {
            buttonStyle(LegacyGlassButtonStyle(tint: tint))
        }
    }

    @ViewBuilder
    func adaptiveGlassSurface(tint: Color) -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(
                .regular.tint(tint),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
        } else {
            background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint)
                    .shadow(color: .black.opacity(0.08), radius: 5, y: 2)
            )
        }
    }

    @ViewBuilder
    func compactToolbarSurface(tint: Color) -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(.regular.tint(tint), in: Circle())
        } else {
            background(
                Circle()
                    .fill(tint)
                    .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
            )
        }
    }

    @ViewBuilder
    func adaptiveCategorySheetPresentation() -> some View {
        if #available(iOS 16.0, *) {
            presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        } else {
            self
        }
    }

    @ViewBuilder
    func adaptiveKeyboardDismissal() -> some View {
        if #available(iOS 16.0, *) {
            scrollDismissesKeyboard(.interactively)
        } else {
            self
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
