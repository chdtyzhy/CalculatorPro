import SwiftUI

// 主界面视图
struct MainView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @StateObject var appModel: MainViewModel = MainViewModel()
    @State private var isShowingHistory = false
    @State private var isShowingAbout = false
    
    let duration: TimeInterval = 0.3
    
    var body: some View {
        GeometryReader { proxy in
            let width: CGFloat = proxy.size.width
            // 按钮宽度按屏幕宽度计算（4 列），保持最大尺寸
            let buttonWidth = (width - 16 * 2 - 12 * 3) / 4
            // 键盘总高度 = 5 行按钮 + 4 个间距，使按钮正好填满
            let keypadHeight = buttonWidth * 5 + 12 * 4
            
            ZStack(alignment: .topLeading) {
                Color.background
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("计算器")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondaryInk)

                        Spacer()

                        HStack(spacing: 10) {
                            Button(action: { isShowingAbout = true }) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primaryInk)
                                    .frame(width: 36, height: 36)
                            }
                            .adaptiveGlassButtonStyle(tint: .numberKey)
                            .accessibilityLabel("关于与隐私")

                            Button(action: { isShowingHistory = true }) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primaryInk)
                                    .frame(width: 36, height: 36)
                            }
                            .adaptiveGlassButtonStyle(tint: .numberKey)
                            .accessibilityLabel("计算历史")
                        }
                    }
                    // Native glass adds material outside the label's 36pt frame.
                    // Reserve the full control height so it cannot overlap the display.
                    .frame(minHeight: 52)

                    DisplayView(height: 0, colorScheme: colorScheme, duration: duration)
                        .environmentObject(appModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                    
                    // 键盘区域（固定高度，贴底）
                    CalculatorButtons(stackSpacing: 12)
                        .environmentObject(appModel)
                        .frame(height: keypadHeight)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
        .sheet(isPresented: $isShowingHistory) {
            HistoryView(isPresented: $isShowingHistory)
                .environmentObject(appModel)
        }
        .sheet(isPresented: $isShowingAbout) {
            AboutView(isPresented: $isShowingAbout)
        }
    }
}

private struct AboutView: View {
    @Binding var isPresented: Bool

    private let privacyURL = URL(string: "https://chdtyzhy.github.io/CalculatorPro/privacy-policy.html")!
    private let supportURL = URL(string: "https://chdtyzhy.github.io/CalculatorPro/support.html")!
    private let feedbackURL = URL(string: "https://github.com/chdtyzhy/CalculatorPro/issues/new")!

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
        }
    }
}

private struct HistoryView: View {
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
                    .foregroundColor(.secondaryInk)
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
                                            .foregroundColor(entry.category == nil ? .secondaryInk : .equalKey)
                                            .lineLimit(1)
                                    }
                                    .buttonStyle(.plain)
                                    .layoutPriority(1)

                                    Spacer(minLength: 8)

                                    Text(entry.expression)
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundColor(.secondaryInk)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.75)
                                }

                                Button {
                                    appModel.reuse(entry)
                                    isPresented = false
                                } label: {
                                    Text(entry.result)
                                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primaryInk)
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
                            .foregroundColor(.secondaryInk)
                    }

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .frame(width: 32, height: 32)
                    }
                    .adaptiveGlassButtonStyle(tint: .numberKey)
                    .accessibilityLabel("关闭")
                }

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(CalculationHistoryEntry.presetCategories, id: \.self) { category in
                        Button {
                            save(category)
                        } label: {
                            Label(category, systemImage: icon(for: category))
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(entry.category == category ? .white : .primaryInk)
                                .frame(maxWidth: .infinity, minHeight: 46)
                        }
                        .adaptiveGlassButtonStyle(
                            tint: entry.category == category ? .equalKey : .numberKey
                        )
                    }
                }

                HStack(spacing: 10) {
                    Image(systemName: "pencil")
                        .foregroundColor(.secondaryInk)
                    TextField("自定义类别", text: $customCategory)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .onSubmit(saveCustomCategory)
                    Button(action: saveCustomCategory) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .bold))
                            .frame(width: 32, height: 32)
                    }
                    .adaptiveGlassButtonStyle(tint: .numberKey)
                    .disabled(customCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 14)
                .frame(height: 50)
                .adaptiveGlassSurface()

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
        .background(Color.background.ignoresSafeArea())
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

private extension View {
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
    func adaptiveGlassSurface() -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else {
            background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.numberKey)
                    .shadow(color: .black.opacity(0.08), radius: 5, y: 2)
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
