import SwiftUI
import PhotosUI

// MARK: - 发布页
// 核心作用：发布新帖子，支持普通帖子和话题帖子
// 设计思路：现代化设计 + 相册媒体选择 + 标题内容编辑 + 标签选择
// 关键功能：帖子类型切换、媒体选择、标签管理、发布验证、登录检查

/// 发布页
struct Release_platbell: View {
    
    @ObservedObject var titleVM_platbell = TitleViewModel_platbell.shared_platbell
    @ObservedObject var router_platbell = Router_platbell.shared_platbell
    @ObservedObject var userVM_platbell = UserViewModel_platbell.shared_platbell
    
    /// 帖子类型（0=普通，1=话题）
    @State private var postType_platbell: Int = 0
    
    /// 标题
    @State private var title_platbell: String = ""
    
    /// 内容
    @State private var content_platbell: String = ""
    
    /// 选中的媒体项（PhotosPicker）
    @State private var selectedPhotoItem_platbell: PhotosPickerItem?
    
    /// 选中的媒体图片
    @State private var selectedMediaImage_platbell: UIImage?
    
    /// 媒体路径（用于保存和显示）
    @State private var mediaPath_platbell: String?
    
    /// 是否是视频
    @State private var isVideo_platbell: Bool = false
    
    /// 选中的标签
    @State private var selectedTags_platbell: [String] = []
    
    /// 是否显示标签选择器
    @State private var showTagPicker_platbell = false
    
    /// 是否显示EULA
    @State private var showEula_platbell = false
    
    /// 预设标签列表
    private let availableTags_platbell = [
        "Design", "UI/UX", "Inspiration", "Tech", "Innovation", 
        "Future", "Teamwork", "Success", "Growth", "Learning", 
        "Mindset", "Fun", "Creative", "Adventure", "Ideas", "Nature"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 渐变背景
                backgroundView_platbell
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 顶部标题（参考首页和发现页风格）
                        headerDecoration_platbell
                            .padding(.top, 16)
                        
                        // 帖子类型选择（优化动画）
                        postTypeSelector_platbell
                        
                        // 媒体选择区域（从相册选择）
                        mediaSelectionArea_platbell
                        
                        // 标题输入
                        titleInputField_platbell
                        
                        // 内容输入
                        contentInputField_platbell
                        
                        // 标签选择（仅话题帖子，带平滑过渡）
                        if postType_platbell == 1 {
                            tagSelectionArea_platbell
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                        }
                        
                        // 发布按钮（内容下方20的位置）
                        publishButton_platbell
                            .padding(.top, 20)
                        
                        // EULA按钮（发布按钮下方20的位置）
                        eulaButton_platbell
                            .padding(.top, 20)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .sheet(isPresented: $showEula_platbell) {
            NavigationStack {
                ProtocolContentView_platbell(
                    type_platbell: .terms_platbell,
                    content_platbell: "eula.png"
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            showEula_platbell = false
                        }
                    }
                }
            }
        }
        .onChange(of: selectedPhotoItem_platbell) { newItem_platbell in
            Task {
                await loadSelectedMedia_platbell(from: newItem_platbell)
            }
        }
    }
    
    // MARK: - 子视图
    
    /// 渐变背景
    private var backgroundView_platbell: some View {
        LinearGradient(
            colors: [
                ThemeColors_platbell.secondaryStart_platbell.opacity(0.08),
                ThemeColors_platbell.primaryStart_platbell.opacity(0.05),
                Color(.systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    /// 顶部标题区域（参考首页和发现页风格）
    private var headerDecoration_platbell: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                // 装饰性图标
                ZStack {
                    Circle()
                        .fill(
                            ThemeColors_platbell.gradient_platbell(at: 1)
                                .opacity(0.2)
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(
                            ThemeColors_platbell.gradient_platbell(at: 1)
                        )
                        .rotationEffect(.degrees(0))
                        .breathing_platbell(isEnabled_platbell: true, duration_platbell: 2.5, scaleRange_platbell: 0.1)
                }
                .shadow(
                    color: ThemeColors_platbell.secondaryStart_platbell.opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Create Post")
                        .font(.system(size: 32, weight: .bold))
                        .gradientText_platbell(gradientIndex_platbell: 1)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(ThemeColors_platbell.accentGreenStart_platbell)
                        
                        Text("Share your moment")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // 快速提示卡片
            quickTipsCard_platbell
        }
    }
    
    /// 快速提示卡片
    private var quickTipsCard_platbell: some View {
        HStack(spacing: 12) {
            // 媒体提示
            QuickTipItem_platbell(
                icon_platbell: "photo.fill",
                text_platbell: "Add Media",
                gradientIndex_platbell: 2
            )
            
            // 标题提示
            QuickTipItem_platbell(
                icon_platbell: "textformat.size",
                text_platbell: "Add Title",
                gradientIndex_platbell: 3
            )
            
            // 内容提示
            QuickTipItem_platbell(
                icon_platbell: "doc.text",
                text_platbell: "Add Content",
                gradientIndex_platbell: 4
            )
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            ThemeColors_platbell.secondaryStart_platbell.opacity(0.3),
                            ThemeColors_platbell.accentGreenStart_platbell.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    /// 帖子类型选择器（优化动画）
    private var postTypeSelector_platbell: some View {
        HStack(spacing: 12) {
            // 普通帖子
            TypeButton_platbell(
                icon_platbell: "doc.text.fill",
                title_platbell: "Normal",
                subtitle_platbell: "Share freely",
                isSelected_platbell: postType_platbell == 0,
                gradientIndex_platbell: 0
            ) {
                // 平滑的弹簧动画
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)) {
                    postType_platbell = 0
                    selectedTags_platbell = []
                }
                
                // 触觉反馈
                let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback_platbell.impactOccurred()
            }
            
            // 话题帖子
            TypeButton_platbell(
                icon_platbell: "tag.fill",
                title_platbell: "Topic",
                subtitle_platbell: "With tags",
                isSelected_platbell: postType_platbell == 1,
                gradientIndex_platbell: 1
            ) {
                // 平滑的弹簧动画
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)) {
                    postType_platbell = 1
                }
                
                // 触觉反馈
                let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback_platbell.impactOccurred()
            }
        }
    }
    
    /// 媒体选择区域（从相册选择）
    private var mediaSelectionArea_platbell: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 2))
                
                Text("Media")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // 媒体预览或占位符
            if let image_platbell = selectedMediaImage_platbell {
                // 显示选中的图片
                ZStack(alignment: .topTrailing) {
                    PhotosPicker(
                        selection: $selectedPhotoItem_platbell,
                        matching: .any(of: [.images, .videos])
                    ) {
                        Image(uiImage: image_platbell)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        ThemeColors_platbell.gradient_platbell(at: 2),
                                        lineWidth: 2
                                    )
                            )
                            .overlay(
                                // 视频播放图标
                                isVideo_platbell ? 
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.6))
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.white)
                                } : nil
                            )
                    }
                    
                    // 删除按钮
                    Button(action: {
                        handleDeleteMedia_platbell()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.7))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .padding(12)
                }
            } else {
                // 占位符 - 点击整个区域选择媒体
                PhotosPicker(
                    selection: $selectedPhotoItem_platbell,
                    matching: .any(of: [.images, .videos])
                ) {
                    ZStack {
                        ThemeColors_platbell.gradient_platbell(at: 2)
                            .opacity(0.3)
                        
                        VStack(spacing: 12) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("Tap to add media")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .frame(height: 200)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                ThemeColors_platbell.gradient_platbell(at: 2),
                                lineWidth: 2
                            )
                    )
                }
            }
        }
    }
    
    /// 标题输入框
    private var titleInputField_platbell: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "textformat.size")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 3))
                
                Text("Title")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(title_platbell.count)/50")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            TextField("Enter an eye-catching title", text: $title_platbell)
                .font(.system(size: 18, weight: .semibold))
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            title_platbell.isEmpty
                                ? AnyShapeStyle(Color(.systemGray4))
                                : AnyShapeStyle(ThemeColors_platbell.gradient_platbell(at: 3)),
                            lineWidth: 1.5
                        )
                )
                .onChange(of: title_platbell) { newValue_platbell in
                    if newValue_platbell.count > 50 {
                        title_platbell = String(newValue_platbell.prefix(50))
                    }
                }
        }
    }
    
    /// 内容输入框
    private var contentInputField_platbell: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 4))
                
                Text("Content")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(content_platbell.count)/200")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            TextEditor(text: $content_platbell)
                .font(.system(size: 15))
                .frame(height: 150)
                .padding(12)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            content_platbell.isEmpty
                                ? AnyShapeStyle(Color(.systemGray4))
                                : AnyShapeStyle(ThemeColors_platbell.gradient_platbell(at: 4)),
                            lineWidth: 1.5
                        )
                )
                .onChange(of: content_platbell) { newValue_platbell in
                    if newValue_platbell.count > 200 {
                        content_platbell = String(newValue_platbell.prefix(200))
                    }
                }
        }
    }
    
    /// 标签选择区域
    private var tagSelectionArea_platbell: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "tag.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 1))
                
                Text("Tags")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    showTagPicker_platbell = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 12, weight: .semibold))
                        
                        Text("Add Tags")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(ThemeColors_platbell.secondaryStart_platbell)
                }
            }
            
            // 已选标签显示
            if selectedTags_platbell.isEmpty {
                Text("No tags selected")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            } else {
                TagCloud_platbell(
                    tags_platbell: selectedTags_platbell,
                    gradientIndex_platbell: 1,
                    isClickable_platbell: true,
                    onTagTapped_platbell: { tag_platbell in
                        removeTag_platbell(tag_platbell)
                    }
                )
                .frame(height: calculateTagHeight_platbell())
                .padding(12)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            ThemeColors_platbell.gradient_platbell(at: 1),
                            lineWidth: 1.5
                        )
                )
            }
        }
        .sheet(isPresented: $showTagPicker_platbell) {
            TagPickerSheet_platbell(
                availableTags_platbell: availableTags_platbell,
                selectedTags_platbell: $selectedTags_platbell
            )
        }
    }
    
    /// 发布按钮
    private var publishButton_platbell: some View {
        Button(action: {
            publishPost_platbell()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16, weight: .bold))
                
                Text("Publish Post")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ThemeColors_platbell.gradient_platbell(at: 1))
            )
            .shadow(
                color: ThemeColors_platbell.secondaryStart_platbell.opacity(0.4),
                radius: 12,
                x: 0,
                y: 6
            )
        }
    }
    
    /// EULA按钮
    private var eulaButton_platbell: some View {
        Button {
            showEula_platbell = true
        } label: {
            Text("EULA")
                .font(.system(size: 15, weight: .bold))
                .underline()
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - 事件处理
    
    /// 发布帖子（优化验证逻辑）
    private func publishPost_platbell() {
        // 1. 优先检查是否登录
        guard userVM_platbell.isLoggedIn_platbell else {
            
            // 延迟跳转到登录页
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                router_platbell.dismissFullScreen_platbell()
                router_platbell.toLogin_platbellui()
            }
            return
        }
        
        // 2. 验证媒体是否为空
        guard selectedMediaImage_platbell != nil || mediaPath_platbell != nil else {
            Utils_platbell.showWarning_platbell(
                message_platbell: "Please select media",
                delay_platbell: 1.5
            )
            return
        }
        
        // 3. 验证标题是否为空
        guard !title_platbell.isEmpty else {
            Utils_platbell.showWarning_platbell(
                message_platbell: "Please enter a title",
                delay_platbell: 1.5
            )
            return
        }
        
        // 4. 验证内容是否为空
        guard !content_platbell.isEmpty else {
            Utils_platbell.showWarning_platbell(
                message_platbell: "Please enter content",
                delay_platbell: 1.5
            )
            return
        }
        
        // 5. 如果是话题帖子，验证是否选择了标签
        if postType_platbell == 1 && selectedTags_platbell.isEmpty {
            Utils_platbell.showWarning_platbell(
                message_platbell: "Please add at least one tag",
                delay_platbell: 1.5
            )
            return
        }
        
        // 发布帖子
        let mediaPath_platbell = mediaPath_platbell ?? "placeholder"
        titleVM_platbell.releasePost_platbell(
            title_platbell: title_platbell,
            content_platbell: content_platbell,
            media_platbell: mediaPath_platbell,
            type_platbell: postType_platbell,
            tags_platbell: selectedTags_platbell
        )
        
        // 显示成功提示
        Utils_platbell.showSuccess_platbell(
            message_platbell: "Post published successfully",
            delay_platbell: 1.5
        )
        
        // 清除页面数据
        clearFormData_platbell()
        
        // 关闭页面
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            router_platbell.dismissFullScreen_platbell()
        }
    }
    
    /// 清除表单数据
    /// 功能：重置所有表单字段为初始状态
    private func clearFormData_platbell() {
        // 重置帖子类型为普通帖子
        postType_platbell = 0
        
        // 清空标题和内容
        title_platbell = ""
        content_platbell = ""
        
        // 清空媒体相关数据
        selectedPhotoItem_platbell = nil
        selectedMediaImage_platbell = nil
        mediaPath_platbell = nil
        isVideo_platbell = false
        
        // 清空标签
        selectedTags_platbell = []
    }
    
    /// 删除媒体
    /// 功能：清除已选择的媒体图片和相关状态
    private func handleDeleteMedia_platbell() {
        // 清空媒体相关状态
        selectedMediaImage_platbell = nil
        selectedPhotoItem_platbell = nil
        mediaPath_platbell = nil
        isVideo_platbell = false
        
        // 触觉反馈
        let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback_platbell.impactOccurred()
        
        // 显示提示
        Utils_platbell.showInfo_platbell(
            message_platbell: "Media removed",
            delay_platbell: 1.0
        )
    }
    
    /// 加载选中的媒体
    /// - Parameter item_platbell: PhotosPicker选中的项
    private func loadSelectedMedia_platbell(from item_platbell: PhotosPickerItem?) async {
        guard let item_platbell = item_platbell else { return }
        
        // 检查是否是视频
        if let contentType_platbell = item_platbell.supportedContentTypes.first {
            isVideo_platbell = contentType_platbell.identifier.contains("video")
        }
        
        // 加载图片数据
        if let data_platbell = try? await item_platbell.loadTransferable(type: Data.self),
           let image_platbell = UIImage(data: data_platbell) {
            await MainActor.run {
                selectedMediaImage_platbell = image_platbell
                
                // 保存图片到临时路径（实际项目中应该保存到文档目录）
                mediaPath_platbell = "selected_media_\(UUID().uuidString)"
            }
        }
    }
    
    /// 移除标签
    private func removeTag_platbell(_ tag_platbell: String) {
        withAnimation(AnimationPresets_platbell.quickSpring_platbell) {
            selectedTags_platbell.removeAll { $0 == tag_platbell }
        }
        
        let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .light)
        impactFeedback_platbell.impactOccurred()
    }
    
    /// 计算标签高度
    private func calculateTagHeight_platbell() -> CGFloat {
        let count_platbell = selectedTags_platbell.count
        if count_platbell <= 4 {
            return 40
        } else if count_platbell <= 8 {
            return 80
        } else {
            return 120
        }
    }
}

// MARK: - 帖子类型按钮

/// 帖子类型按钮
struct TypeButton_platbell: View {
    
    let icon_platbell: String
    let title_platbell: String
    let subtitle_platbell: String
    let isSelected_platbell: Bool
    let gradientIndex_platbell: Int
    let action_platbell: () -> Void
    
    var body: some View {
        Button(action: action_platbell) {
            VStack(spacing: 12) {
                // 图标
                ZStack {
                    Circle()
                        .fill(
                            isSelected_platbell
                                ? AnyShapeStyle(ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell))
                                : AnyShapeStyle(Color(.systemGray5))
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon_platbell)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(isSelected_platbell ? .white : .secondary)
                }
                
                VStack(spacing: 4) {
                    Text(title_platbell)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle_platbell)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected_platbell
                            ? ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell)
                            : LinearGradient(colors: [Color(.systemGray4)], startPoint: .leading, endPoint: .trailing),
                        lineWidth: isSelected_platbell ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected_platbell
                    ? ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count].opacity(0.2)
                    : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 快速提示项

/// 快速提示项组件
struct QuickTipItem_platbell: View {
    let icon_platbell: String
    let text_platbell: String
    let gradientIndex_platbell: Int
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell)
                            .opacity(0.2)
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon_platbell)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(
                        ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell)
                    )
            }
            
            Text(text_platbell)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 提示项

/// 提示项
struct TipItem_platbell: View {
    let text_platbell: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(ThemeColors_platbell.warmStart_platbell)
                .frame(width: 6, height: 6)
            
            Text(text_platbell)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 标签选择器Sheet

/// 标签选择器
struct TagPickerSheet_platbell: View {
    
    let availableTags_platbell: [String]
    @Binding var selectedTags_platbell: [String]
    @Environment(\.dismiss) var dismiss_platbell
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 已选标签
                    if !selectedTags_platbell.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Selected Tags (\(selectedTags_platbell.count))")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                            
                            TagCloud_platbell(
                                tags_platbell: selectedTags_platbell,
                                gradientIndex_platbell: 1,
                                isClickable_platbell: true,
                                onTagTapped_platbell: { tag_platbell in
                                    withAnimation {
                                        selectedTags_platbell.removeAll { $0 == tag_platbell }
                                    }
                                }
                            )
                            .frame(height: calculateTagHeight_platbell(count_platbell: selectedTags_platbell.count))
                        }
                        .padding(.horizontal)
                    }
                    
                    // 可选标签
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Available Tags")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(availableTags_platbell.indices, id: \.self) { index_platbell in
                                let tag_platbell = availableTags_platbell[index_platbell]
                                
                                Button(action: {
                                    toggleTag_platbell(tag_platbell)
                                }) {
                                    Text(tag_platbell)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(
                                            selectedTags_platbell.contains(tag_platbell)
                                                ? .white
                                                : ThemeColors_platbell.allStartColors_platbell[index_platbell % ThemeColors_platbell.allStartColors_platbell.count]
                                        )
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            selectedTags_platbell.contains(tag_platbell)
                                                ? AnyShapeStyle(ThemeColors_platbell.gradient_platbell(at: index_platbell % ThemeColors_platbell.allGradients_platbell.count))
                                                : AnyShapeStyle(Color(.systemGray6))
                                        )
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Select Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss_platbell()
                    }
                }
            }
        }
    }
    
    private func toggleTag_platbell(_ tag_platbell: String) {
        withAnimation(AnimationPresets_platbell.standardSpring_platbell) {
            if selectedTags_platbell.contains(tag_platbell) {
                selectedTags_platbell.removeAll { $0 == tag_platbell }
            } else {
                if selectedTags_platbell.count < 5 {
                    selectedTags_platbell.append(tag_platbell)
                } else {
                    Utils_platbell.showWarning_platbell(message_platbell: "Maximum 5 tags allowed")
                }
            }
        }
        
        let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .light)
        impactFeedback_platbell.impactOccurred()
    }
    
    private func calculateTagHeight_platbell(count_platbell: Int) -> CGFloat {
        if count_platbell <= 4 {
            return 40
        } else if count_platbell <= 8 {
            return 80
        } else {
            return 120
        }
    }
}

// MARK: - 预览

#Preview {
    Release_platbell()
}
