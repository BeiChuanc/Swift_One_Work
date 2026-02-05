import SwiftUI
import PhotosUI

// MARK: - 发布页
// 核心作用：发布新的穿搭帖子
// 设计思路：现代化、有趣、创意的发布界面，强调视觉吸引力和用户体验
// 关键功能：媒体上传、标题编辑、内容编辑、发布管理

/// 发布页主视图
struct Release_lite: View {
    
    @ObservedObject private var titleVM_lite = TitleViewModel_lite.shared_lite
    @ObservedObject private var userVM_lite = UserViewModel_lite.shared_lite
    
    // 表单数据
    @State private var postTitle_lite = ""
    @State private var postContent_lite = ""
    @State private var selectedMediaType_lite: MediaType_lite = .image_lite
    @State private var mediaPlaceholder_lite = "post_placeholder"
    
    // UI状态
    @State private var showMediaPicker_lite = false
    @State private var showEula_lite = false
    @State private var isPublishing_lite = false
    
    // 照片选择器相关
    @State private var selectedPhotoItem_lite: PhotosPickerItem?
    @State private var selectedImage_lite: UIImage?
    @State private var hasSelectedMedia_lite = false
    
    // 键盘控制
    @FocusState private var titleFieldFocused_lite: Bool
    @FocusState private var contentFieldFocused_lite: Bool
    
    var body: some View {
        ZStack {
            // 动态渐变背景
            AnimatedReleaseBackground_lite()
                .ignoresSafeArea()
            
            // 装饰性浮动元素
            FloatingReleaseElements_lite()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部导航栏
                headerView_lite
                    .padding(.horizontal, 20.w_lite)
                    .padding(.top, 10.h_lite)
                
                // 内容区域
                ScrollView {
                    VStack(spacing: 24.h_lite) {
                        // 媒体上传区域
                        mediaUploadSection_lite
                        
                        // 标题输入区域
                        titleInputSection_lite
                        
                        // 内容输入区域
                        contentInputSection_lite
                        
                        // 发布按钮
                        publishButton_lite
                        
                        // EULA按钮
                        eulaButton_lite
                    }
                    .padding(.horizontal, 20.w_lite)
                    .padding(.top, 24.h_lite)
                    .padding(.bottom, 100.h_lite)
                }
            }
        }
        .onTapGesture {
            // 点击空白区域收起键盘
            titleFieldFocused_lite = false
            contentFieldFocused_lite = false
        }
        .sheet(isPresented: $showEula_lite) {
            NavigationStack {
                ProtocolContentView_lite(
                    type_lite: .terms_lite,
                    content_lite: "eula.png"
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            showEula_lite = false
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 顶部导航栏
    
    /// 顶部导航栏
    private var headerView_lite: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6.h_lite) {
                // 装饰图标和标题
                HStack(spacing: 8.w_lite) {
                    Image(systemName: "plus.app.fill")
                        .font(.system(size: 26.sp_lite, weight: .bold))
                        .foregroundColor(Color(hex: "f5576c"))
                        .shadow(color: Color(hex: "f5576c").opacity(0.5), radius: 4)
                    
                    Text("Create Post")
                        .font(.system(size: 32.sp_lite, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                Text("Share your style with the world")
                    .font(.system(size: 14.sp_lite, weight: .medium))
                    .foregroundColor(Color(hex: "495057"))
            }
            
            Spacer()
        }
    }
    
    // MARK: - 媒体上传区域
    
    /// 媒体上传区域
    private var mediaUploadSection_lite: some View {
        VStack(alignment: .leading, spacing: 12.h_lite) {
            // 标题
            HStack(spacing: 6.w_lite) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 16.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "f093fb"))
                
                Text("Upload Media")
                    .font(.system(size: 18.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                
                Text("(Required)")
                    .font(.system(size: 13.sp_lite, weight: .medium))
                    .foregroundColor(Color(hex: "f5576c"))
            }
            
            // 媒体选择器
            PhotosPicker(
                selection: $selectedPhotoItem_lite,
                matching: selectedMediaType_lite == .image_lite ? .images : .videos
            ) {
                ZStack {
                    // 背景
                    RoundedRectangle(cornerRadius: 20.w_lite)
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color(hex: "F8F9FA")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20.w_lite)
                                .stroke(
                                    LinearGradient(
                                        colors: hasSelectedMedia_lite ?
                                            [Color(hex: "43e97b").opacity(0.5), Color(hex: "38f9d7").opacity(0.5)] :
                                            [Color(hex: "f093fb").opacity(0.3), Color(hex: "f5576c").opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 2, dash: hasSelectedMedia_lite ? [0] : [8, 4])
                                )
                        )
                    
                    // 已选图片预览或上传提示
                    if let selectedImage_lite = selectedImage_lite {
                        // 显示选中的图片
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: selectedImage_lite)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 280.h_lite)
                                .clipped()
                                .cornerRadius(20.w_lite)
                            
                            // 成功标记
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "43e97b"))
                                    .frame(width: 40.w_lite, height: 40.h_lite)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 18.sp_lite, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(12.w_lite)
                            .shadow(color: Color(hex: "43e97b").opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                    } else {
                        // 上传提示界面
                        VStack(spacing: 16.h_lite) {
                            // 图标
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "f093fb").opacity(0.15), Color(hex: "f5576c").opacity(0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80.w_lite, height: 80.h_lite)
                                
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 36.sp_lite, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            
                            // 文字提示
                            VStack(spacing: 6.h_lite) {
                                Text("Tap to Upload")
                                    .font(.system(size: 18.sp_lite, weight: .bold))
                                    .foregroundColor(Color(hex: "212529"))
                                
                                Text("Image or Video • Max 1 file")
                                    .font(.system(size: 13.sp_lite, weight: .medium))
                                    .foregroundColor(Color(hex: "6C757D"))
                            }
                            
                            // 媒体类型选择
                            HStack(spacing: 12.w_lite) {
                                MediaTypeButton_lite(
                                    type_lite: .image_lite,
                                    isSelected_lite: selectedMediaType_lite == .image_lite
                                ) {
                                    selectedMediaType_lite = .image_lite
                                    // 切换类型时清空已选内容
                                    selectedPhotoItem_lite = nil
                                    selectedImage_lite = nil
                                    hasSelectedMedia_lite = false
                                }
                                
                                MediaTypeButton_lite(
                                    type_lite: .video_lite,
                                    isSelected_lite: selectedMediaType_lite == .video_lite
                                ) {
                                    selectedMediaType_lite = .video_lite
                                    // 切换类型时清空已选内容
                                    selectedPhotoItem_lite = nil
                                    selectedImage_lite = nil
                                    hasSelectedMedia_lite = false
                                }
                            }
                        }
                        .padding(.vertical, 40.h_lite)
                    }
                }
                .frame(height: 280.h_lite)
            }
            .buttonStyle(ScaleButtonStyle_lite())
            .onChange(of: selectedPhotoItem_lite) { _, newItem_lite in
                // 处理选中的照片
                Task {
                    if let newItem_lite = newItem_lite {
                        if let data_lite = try? await newItem_lite.loadTransferable(type: Data.self),
                           let image_lite = UIImage(data: data_lite) {
                            await MainActor.run {
                                selectedImage_lite = image_lite
                                hasSelectedMedia_lite = true
                                Utils_lite.showSuccess_lite(message_lite: "Media uploaded successfully")
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 标题输入区域
    
    /// 标题输入区域
    private var titleInputSection_lite: some View {
        VStack(alignment: .leading, spacing: 12.h_lite) {
            // 标题
            HStack(spacing: 6.w_lite) {
                Image(systemName: "text.alignleft")
                    .font(.system(size: 16.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "667eea"))
                
                Text("Post Title")
                    .font(.system(size: 18.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                
                Text("(Required)")
                    .font(.system(size: 13.sp_lite, weight: .medium))
                    .foregroundColor(Color(hex: "f5576c"))
                
                Spacer()
                
                // 字数统计
                Text("\(postTitle_lite.count)/50")
                    .font(.system(size: 12.sp_lite, weight: .medium))
                    .foregroundColor(postTitle_lite.count > 50 ? Color(hex: "f5576c") : Color(hex: "ADB5BD"))
            }
            
            // 输入框
            TextField("Give your outfit a catchy title...", text: $postTitle_lite)
                .font(.system(size: 16.sp_lite, weight: .medium))
                .padding(18.w_lite)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16.w_lite)
                            .fill(Color.white)
                        
                        RoundedRectangle(cornerRadius: 16.w_lite)
                            .stroke(
                                titleFieldFocused_lite ?
                                    LinearGradient(
                                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        colors: [Color(hex: "E9ECEF"), Color(hex: "E9ECEF")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                lineWidth: 2
                            )
                    }
                )
                .shadow(
                    color: titleFieldFocused_lite ? Color(hex: "667eea").opacity(0.2) : Color.black.opacity(0.05),
                    radius: titleFieldFocused_lite ? 12 : 8,
                    x: 0,
                    y: 4
                )
                .focused($titleFieldFocused_lite)
        }
    }
    
    // MARK: - 内容输入区域
    
    /// 内容输入区域
    private var contentInputSection_lite: some View {
        VStack(alignment: .leading, spacing: 12.h_lite) {
            // 标题
            HStack(spacing: 6.w_lite) {
                Image(systemName: "doc.text")
                    .font(.system(size: 16.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "667eea"))
                
                Text("Description")
                    .font(.system(size: 18.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "212529"))
                
                Text("(Required)")
                    .font(.system(size: 13.sp_lite, weight: .medium))
                    .foregroundColor(Color(hex: "f5576c"))
                
                Spacer()
                
                // 字数统计
                Text("\(postContent_lite.count)/500")
                    .font(.system(size: 12.sp_lite, weight: .medium))
                    .foregroundColor(postContent_lite.count > 500 ? Color(hex: "f5576c") : Color(hex: "ADB5BD"))
            }
            
            // 输入框
            ZStack(alignment: .topLeading) {
                if postContent_lite.isEmpty && !contentFieldFocused_lite {
                    Text("Describe your outfit, styling tips, or the story behind it...")
                        .font(.system(size: 16.sp_lite))
                        .foregroundColor(Color(hex: "ADB5BD"))
                        .padding(.horizontal, 18.w_lite)
                        .padding(.vertical, 18.h_lite)
                }
                
                TextEditor(text: $postContent_lite)
                    .font(.system(size: 16.sp_lite, weight: .medium))
                    .frame(height: 150.h_lite)
                    .padding(.horizontal, 12.w_lite)
                    .padding(.vertical, 12.h_lite)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .focused($contentFieldFocused_lite)
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16.w_lite)
                        .fill(Color.white)
                    
                    RoundedRectangle(cornerRadius: 16.w_lite)
                        .stroke(
                            contentFieldFocused_lite ?
                                LinearGradient(
                                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) :
                                LinearGradient(
                                    colors: [Color(hex: "E9ECEF"), Color(hex: "E9ECEF")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                            lineWidth: 2
                        )
                }
            )
            .shadow(
                color: contentFieldFocused_lite ? Color(hex: "667eea").opacity(0.2) : Color.black.opacity(0.05),
                radius: contentFieldFocused_lite ? 12 : 8,
                x: 0,
                y: 4
            )
        }
    }
    
    // MARK: - 发布按钮
    
    /// 发布按钮
    private var publishButton_lite: some View {
        Button {
            publishPost_lite()
        } label: {
            HStack(spacing: 10.w_lite) {
                if isPublishing_lite {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20.sp_lite, weight: .bold))
                }
                
                Text(isPublishing_lite ? "Publishing..." : "Publish Post")
                    .font(.system(size: 18.sp_lite, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18.h_lite)
            .background(
                ZStack {
                    LinearGradient(
                        colors: canPublish_lite ?
                            [Color(hex: "f093fb"), Color(hex: "f5576c")] :
                            [Color(hex: "ADB5BD"), Color(hex: "6C757D")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // 高光效果
                    if canPublish_lite {
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
            )
            .cornerRadius(20.w_lite)
            .shadow(
                color: canPublish_lite ? Color(hex: "f093fb").opacity(0.4) : Color.clear,
                radius: canPublish_lite ? 15 : 0,
                x: 0,
                y: canPublish_lite ? 8 : 0
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20.w_lite)
                    .stroke(Color.white.opacity(canPublish_lite ? 0.5 : 0), lineWidth: 1.5)
            )
        }
        .buttonStyle(ScaleButtonStyle_lite())
        .disabled(!canPublish_lite || isPublishing_lite)
        .padding(.top, 8.h_lite)
    }
    
    // MARK: - EULA按钮
    
    /// EULA按钮
    private var eulaButton_lite: some View {
        Button {
            showEula_lite = true
        } label: {
            HStack(spacing: 6.w_lite) {
                Image(systemName: "doc.text")
                    .font(.system(size: 13.sp_lite, weight: .bold))
                
                Text("EULA")
                    .font(.system(size: 15.sp_lite, weight: .bold))
                    .underline()
            }
            .foregroundColor(Color(hex: "6C757D"))
        }
        .padding(.top, 12.h_lite)
        .padding(.bottom, 20.h_lite)
    }
    
    // MARK: - 辅助方法
    
    /// 是否可以发布
    private var canPublish_lite: Bool {
        return !postTitle_lite.isEmpty &&
               !postContent_lite.isEmpty &&
               postTitle_lite.count <= 50 &&
               postContent_lite.count <= 500 &&
               hasSelectedMedia_lite &&
               userVM_lite.isLoggedIn_lite
    }
    
    /// 发布帖子
    private func publishPost_lite() {
        guard canPublish_lite else { return }
        
        isPublishing_lite = true
        
        // 保存图片到文档目录
        var savedMediaName_lite = mediaPlaceholder_lite
        if let selectedImage_lite = selectedImage_lite {
            savedMediaName_lite = saveImageToDocuments_lite(image_lite: selectedImage_lite) ?? mediaPlaceholder_lite
        }
        
        // 模拟发布延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            titleVM_lite.releasePost_lite(
                title_lite: postTitle_lite,
                content_lite: postContent_lite,
                media_lite: savedMediaName_lite
            )
            
            isPublishing_lite = false
            
            // 清空表单
            postTitle_lite = ""
            postContent_lite = ""
            selectedPhotoItem_lite = nil
            selectedImage_lite = nil
            hasSelectedMedia_lite = false
        }
    }
    
    /// 保存图片到文档目录
    /// - Parameter image_lite: 要保存的图片
    /// - Returns: 保存后的文件名，失败返回 nil
    private func saveImageToDocuments_lite(image_lite: UIImage) -> String? {
        guard let data_lite = image_lite.jpegData(compressionQuality: 0.8) else {
            print("❌ 图片转换为数据失败")
            return nil
        }
        
        let fileManager_lite = FileManager.default
        guard let documentsDirectory_lite = fileManager_lite.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            print("❌ 无法获取文档目录")
            return nil
        }
        
        // 生成唯一文件名
        let fileName_lite = "post_\(Int(Date().timeIntervalSince1970 * 1000)).jpg"
        let fileURL_lite = documentsDirectory_lite.appendingPathComponent(fileName_lite)
        
        do {
            try data_lite.write(to: fileURL_lite)
            print("✅ 图片保存成功：\(fileName_lite)")
            return fileName_lite
        } catch {
            print("❌ 图片保存失败：\(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - 媒体类型枚举

/// 媒体类型
enum MediaType_lite: Equatable {
    case image_lite
    case video_lite
    
    var title_lite: String {
        switch self {
        case .image_lite: return "Image"
        case .video_lite: return "Video"
        }
    }
    
    var icon_lite: String {
        switch self {
        case .image_lite: return "photo"
        case .video_lite: return "video"
        }
    }
}

// MARK: - 媒体类型按钮

/// 媒体类型按钮
struct MediaTypeButton_lite: View {
    
    let type_lite: MediaType_lite
    let isSelected_lite: Bool
    let action_lite: () -> Void
    
    var body: some View {
        Button(action: action_lite) {
            HStack(spacing: 6.w_lite) {
                Image(systemName: type_lite.icon_lite + ".fill")
                    .font(.system(size: 14.sp_lite, weight: .bold))
                
                Text(type_lite.title_lite)
                    .font(.system(size: 13.sp_lite, weight: .bold))
            }
            .foregroundColor(isSelected_lite ? .white : Color(hex: "6C757D"))
            .padding(.horizontal, 16.w_lite)
            .padding(.vertical, 8.h_lite)
            .background(
                ZStack {
                    if isSelected_lite {
                        LinearGradient(
                            colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color(hex: "F8F9FA")
                    }
                }
            )
            .cornerRadius(20.w_lite)
            .overlay(
                RoundedRectangle(cornerRadius: 20.w_lite)
                    .stroke(
                        isSelected_lite ? Color.white.opacity(0.5) : Color(hex: "E9ECEF"),
                        lineWidth: 1.5
                    )
            )
            .shadow(
                color: isSelected_lite ? Color(hex: "f093fb").opacity(0.3) : Color.clear,
                radius: isSelected_lite ? 8 : 0,
                x: 0,
                y: isSelected_lite ? 4 : 0
            )
        }
        .buttonStyle(ScaleButtonStyle_lite())
    }
}

// MARK: - 动态背景组件

/// 发布页动态渐变背景
struct AnimatedReleaseBackground_lite: View {
    
    @State private var animateGradient_lite = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "f093fb"),
                Color(hex: "f5576c"),
                Color(hex: "667eea"),
                Color(hex: "f093fb")
            ],
            startPoint: animateGradient_lite ? .topLeading : .bottomLeading,
            endPoint: animateGradient_lite ? .bottomTrailing : .topTrailing
        )
        .opacity(0.08)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                animateGradient_lite.toggle()
            }
        }
    }
}

/// 发布页浮动装饰元素
struct FloatingReleaseElements_lite: View {
    
    @State private var animate1_lite = false
    @State private var animate2_lite = false
    
    var body: some View {
        ZStack {
            // 元素1
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "f093fb").opacity(0.15), Color(hex: "f5576c").opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200.w_lite, height: 200.h_lite)
                .blur(radius: 40)
                .offset(
                    x: animate1_lite ? -30.w_lite : 30.w_lite,
                    y: animate1_lite ? -80.h_lite : -40.h_lite
                )
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animate1_lite)
            
            // 元素2
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "667eea").opacity(0.15), Color(hex: "764ba2").opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 220.w_lite, height: 220.h_lite)
                .blur(radius: 45)
                .offset(
                    x: animate2_lite ? UIScreen.main.bounds.width - 100.w_lite : UIScreen.main.bounds.width - 150.w_lite,
                    y: animate2_lite ? UIScreen.main.bounds.height - 200.h_lite : UIScreen.main.bounds.height - 260.h_lite
                )
                .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true), value: animate2_lite)
        }
        .onAppear {
            animate1_lite = true
            animate2_lite = true
        }
    }
}

// MARK: - 按钮样式

/// 缩放按钮样式
struct ScaleButtonStyle_lite: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
