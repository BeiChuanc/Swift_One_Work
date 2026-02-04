import SwiftUI
import PhotosUI
import AVKit
import UniformTypeIdentifiers

// MARK: - 视频传输类型
// 核心作用：支持 PhotosPicker 加载视频
struct Movie: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let copy = URL.documentsDirectory.appending(path: "movie-\(UUID().uuidString).mov")
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Self.init(url: copy)
        }
    }
}

// MARK: - 发布页
// 核心作用：提供帖子发布功能，支持图片/视频上传、标题和内容编辑
// 设计思路：现代化UI设计，清晰的输入流程，实时验证
// 关键功能：媒体上传、内容编辑、发布验证

/// 发布页
struct Release_baseswift: View {
    
    // MARK: - ViewModels
    
    @ObservedObject var titleVM_blisslink = TitleViewModel_blisslink.shared_blisslink
    @ObservedObject var router_blisslink = Router_blisslink.shared_blisslink
    @ObservedObject var userVM_blisslink = UserViewModel_blisslink.shared_blisslink
    
    // MARK: - 状态
    
    @State private var selectedMedia_blisslink: PhotosPickerItem?
    @State private var selectedMediaImage_blisslink: UIImage?
    @State private var selectedMediaName_blisslink: String = ""
    @State private var isVideo_blisslink: Bool = false
    
    @State private var titleText_blisslink: String = ""
    @State private var contentText_blisslink: String = ""
    
    @State private var isPublishing_blisslink: Bool = false
    @State private var showEula_blissLink: Bool = false
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // 背景层（铺满整个屏幕）
            ZStack {
                // 主背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "FFF5F7"),
                        Color(hex: "F7FAFC"),
                        Color(hex: "F0F4FF")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 顶部装饰渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "FA8BFF").opacity(0.08),
                        Color(hex: "667EEA").opacity(0.06),
                        Color.clear
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottom
                )
                .frame(height: 300.h_blisslink)
                .frame(maxHeight: .infinity, alignment: .top)
                
                // 背景装饰圆圈
                Circle()
                    .fill(Color(hex: "FA8BFF").opacity(0.06))
                    .frame(width: 350.w_blisslink, height: 350.h_blisslink)
                    .offset(x: -170.w_blisslink, y: -220.h_blisslink)
                    .blur(radius: 55)
                
                Circle()
                    .fill(Color(hex: "2BD2FF").opacity(0.05))
                    .frame(width: 300.w_blisslink, height: 300.h_blisslink)
                    .offset(x: 150.w_blisslink, y: 200.h_blisslink)
                    .blur(radius: 50)
                
                Circle()
                    .fill(Color(hex: "764BA2").opacity(0.04))
                    .frame(width: 280.w_blisslink, height: 280.h_blisslink)
                    .offset(x: -80.w_blisslink, y: 500.h_blisslink)
                    .blur(radius: 48)
            }
            .ignoresSafeArea()
            
            // 内容层
            VStack(spacing: 0) {
                // 顶部导航栏
                topNavigationBar_blisslink
                
                // 进度指示器
                progressIndicator_blisslink
                    .padding(.horizontal, 20.w_blisslink)
                    .padding(.top, 16.h_blisslink)
                
                // 内容区域
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24.h_blisslink) {
                        // 媒体上传区域（使用通用组件）
                        MediaUploadView_blisslink(
                            selectedMedia_blisslink: $selectedMedia_blisslink,
                            selectedMediaImage_blisslink: $selectedMediaImage_blisslink,
                            selectedMediaName_blisslink: $selectedMediaName_blisslink,
                            isVideo_blisslink: $isVideo_blisslink,
                            onDelete_blisslink: {
                                handleDeleteMedia_blisslink()
                            }
                        )
                        .onChange(of: selectedMedia_blisslink) { oldValue_blisslink, newValue_blisslink in
                            loadSelectedMedia_blisslink()
                        }
                        
                        // 标题输入
                        titleInputSection_blisslink
                        
                        // 内容输入
                        contentInputSection_blisslink
                        
                        // 发布提示卡片
                        publishTipsCard_blisslink
                        
                        // 发布按钮
                        publishButton_blisslink
                            .padding(.top, 20.h_blisslink)

                        // EULA按钮
                        Button(action: {
                            showEula_blissLink = true
                        }) {
                            Text("EULA")
                                .font(.system(size: 15.sp_blisslink, weight: .bold))
                                .foregroundColor(.black)
                                .underline()
                        }
                        .padding(.top, 20.h_blisslink)
                        .sheet(isPresented: $showEula_blissLink) {
                            NavigationStack {
                                ProtocolContentView_blisslink(
                                    type_blisslink: .terms_blisslink,
                                    content_blisslink: "eula.png"
                                )
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarTrailing) {
                                        Button("Close") {
                                            showEula_blissLink = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20.w_blisslink)
                    .padding(.top, 20.h_blisslink)
                    .padding(.bottom, 100.h_blisslink)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - 顶部导航栏
    
    private var topNavigationBar_blisslink: some View {
        ZStack {
            // 标题（居中）
            HStack(spacing: 8.w_blisslink) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 20.sp_blisslink, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Create Post")
                    .font(.system(size: 18.sp_blisslink, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            // 右侧清除内容按钮
            HStack {
                Spacer()
                
                Button(action: {
                    handleClearContent_blisslink()
                }) {
                    ZStack {
                        Circle()
                            .fill(hasContent_blisslink ? Color.red.opacity(0.15) : Color.white.opacity(0.5))
                            .frame(width: 40.w_blisslink, height: 40.h_blisslink)
                        
                        Image(systemName: "trash.fill")
                            .font(.system(size: 16.sp_blisslink, weight: .semibold))
                            .foregroundColor(hasContent_blisslink ? .red : .gray)
                    }
                }
                .disabled(!hasContent_blisslink)
                .scaleEffect(hasContent_blisslink ? 1.0 : 0.95)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: hasContent_blisslink)
            }
        }
        .padding(.horizontal, 20.w_blisslink)
        .padding(.top, 10.h_blisslink)
        .padding(.bottom, 16.h_blisslink)
        .background(
            ZStack {
                // 半透明白色背景 + 模糊效果
                Color.white.opacity(0.85)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .top)
                
                // 底部渐变装饰线
                VStack {
                    Spacer()
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 3.h_blisslink)
                }
            }
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - 进度指示器
    
    private var progressIndicator_blisslink: some View {
        HStack(spacing: 12.w_blisslink) {
            // 媒体步骤
            progressStep_blisslink(
                icon_blisslink: "photo.fill",
                title_blisslink: "Media",
                isCompleted_blisslink: selectedMediaImage_blisslink != nil
            )
            
            // 连接线
            Rectangle()
                .fill(selectedMediaImage_blisslink != nil ? Color(hex: "667EEA") : Color.gray.opacity(0.3))
                .frame(height: 2.h_blisslink)
            
            // 标题步骤
            progressStep_blisslink(
                icon_blisslink: "text.alignleft",
                title_blisslink: "Title",
                isCompleted_blisslink: !titleText_blisslink.isEmpty
            )
            
            // 连接线
            Rectangle()
                .fill(!titleText_blisslink.isEmpty ? Color(hex: "667EEA") : Color.gray.opacity(0.3))
                .frame(height: 2.h_blisslink)
            
            // 内容步骤
            progressStep_blisslink(
                icon_blisslink: "doc.text.fill",
                title_blisslink: "Content",
                isCompleted_blisslink: !contentText_blisslink.isEmpty
            )
        }
        .padding(.horizontal, 20.w_blisslink)
        .padding(.vertical, 16.h_blisslink)
        .background(
            RoundedRectangle(cornerRadius: 14.w_blisslink)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }
    
    /// 进度步骤
    private func progressStep_blisslink(icon_blisslink: String, title_blisslink: String, isCompleted_blisslink: Bool) -> some View {
        VStack(spacing: 6.h_blisslink) {
            ZStack {
                Circle()
                    .fill(
                        isCompleted_blisslink ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40.w_blisslink, height: 40.h_blisslink)
                
                Image(systemName: isCompleted_blisslink ? "checkmark" : icon_blisslink)
                    .font(.system(size: 16.sp_blisslink, weight: .semibold))
                    .foregroundColor(isCompleted_blisslink ? .white : .gray)
            }
            
            Text(title_blisslink)
                .font(.system(size: 11.sp_blisslink, weight: isCompleted_blisslink ? .semibold : .medium))
                .foregroundColor(isCompleted_blisslink ? Color(hex: "667EEA") : .gray)
        }
        .scaleEffect(isCompleted_blisslink ? 1.0 : 0.95)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isCompleted_blisslink)
    }
    
    // MARK: - 标题输入区域
    
    private var titleInputSection_blisslink: some View {
        VStack(alignment: .leading, spacing: 12.h_blisslink) {
            // 标签
            HStack(spacing: 8.w_blisslink) {
                Image(systemName: "text.alignleft")
                    .font(.system(size: 16.sp_blisslink, weight: .semibold))
                    .foregroundColor(Color(hex: "667EEA"))
                
                Text("Title")
                    .font(.system(size: 16.sp_blisslink, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 字数统计
                Text("\(titleText_blisslink.count)/100")
                    .font(.system(size: 12.sp_blisslink, weight: .medium))
                    .foregroundColor(titleText_blisslink.count >= 100 ? .red : .secondary)
                    .padding(.horizontal, 10.w_blisslink)
                    .padding(.vertical, 4.h_blisslink)
                    .background(
                        Capsule()
                            .fill(titleText_blisslink.count >= 100 ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                    )
            }
            
            // 输入框
            HStack(spacing: 12.w_blisslink) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18.sp_blisslink))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                TextField("Give your post a catchy title", text: $titleText_blisslink)
                    .font(.system(size: 16.sp_blisslink, weight: .medium))
            }
            .padding(16.w_blisslink)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14.w_blisslink)
                        .fill(Color.white)
                    
                    RoundedRectangle(cornerRadius: 14.w_blisslink)
                        .stroke(
                            !titleText_blisslink.isEmpty ?
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "667EEA").opacity(0.5), Color(hex: "764BA2").opacity(0.5)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [Color.clear, Color.clear]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2.w_blisslink
                        )
                }
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
            .onChange(of: titleText_blisslink) { oldValue_blisslink, newValue_blisslink in
                // 限制100字符
                if newValue_blisslink.count > 100 {
                    titleText_blisslink = String(newValue_blisslink.prefix(100))
                }
            }
        }
    }
    
    // MARK: - 内容输入区域
    
    private var contentInputSection_blisslink: some View {
        VStack(alignment: .leading, spacing: 12.h_blisslink) {
            // 标签
            HStack(spacing: 8.w_blisslink) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 16.sp_blisslink, weight: .semibold))
                    .foregroundColor(Color(hex: "667EEA"))
                
                Text("Content")
                    .font(.system(size: 16.sp_blisslink, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 字数统计
                Text("\(contentText_blisslink.count)/500")
                    .font(.system(size: 12.sp_blisslink, weight: .medium))
                    .foregroundColor(contentText_blisslink.count >= 500 ? .red : .secondary)
                    .padding(.horizontal, 10.w_blisslink)
                    .padding(.vertical, 4.h_blisslink)
                    .background(
                        Capsule()
                            .fill(contentText_blisslink.count >= 500 ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                    )
            }
            
            // 内容编辑器容器
            ZStack(alignment: .topLeading) {
                // 占位符
                if contentText_blisslink.isEmpty {
                    VStack(alignment: .leading, spacing: 8.h_blisslink) {
                        HStack(spacing: 8.w_blisslink) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 16.sp_blisslink))
                                .foregroundColor(Color(hex: "F2C94C"))
                            
                            Text("Share your thoughts, experience, or achievement...")
                                .font(.system(size: 15.sp_blisslink))
                                .foregroundColor(.secondary.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 20.w_blisslink)
                    .padding(.vertical, 16.h_blisslink)
                }
                
                // 文本编辑器
                TextEditor(text: $contentText_blisslink)
                    .font(.system(size: 15.sp_blisslink))
                    .padding(.horizontal, 16.w_blisslink)
                    .padding(.vertical, 12.h_blisslink)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 180.h_blisslink)
                    .onChange(of: contentText_blisslink) { oldValue_blisslink, newValue_blisslink in
                        // 限制500字符
                        if newValue_blisslink.count > 500 {
                            contentText_blisslink = String(newValue_blisslink.prefix(500))
                        }
                    }
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14.w_blisslink)
                        .fill(Color.white)
                    
                    RoundedRectangle(cornerRadius: 14.w_blisslink)
                        .stroke(
                            !contentText_blisslink.isEmpty ?
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "667EEA").opacity(0.5), Color(hex: "764BA2").opacity(0.5)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [Color.clear, Color.clear]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2.w_blisslink
                        )
                }
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
        }
    }
    
    // MARK: - 发布提示卡片
    
    private var publishTipsCard_blisslink: some View {
        HStack(spacing: 12.w_blisslink) {
            // 图标
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "56CCF2").opacity(0.2), Color(hex: "2F80ED").opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44.w_blisslink, height: 44.h_blisslink)
                
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 22.sp_blisslink))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "56CCF2"), Color(hex: "2F80ED")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // 提示文字
            VStack(alignment: .leading, spacing: 4.h_blisslink) {
                Text("Share your yoga journey")
                    .font(.system(size: 14.sp_blisslink, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Inspire others with your practice achievements")
                    .font(.system(size: 12.sp_blisslink))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16.w_blisslink)
        .background(
            RoundedRectangle(cornerRadius: 14.w_blisslink)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "56CCF2").opacity(0.08),
                            Color(hex: "2F80ED").opacity(0.08)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14.w_blisslink)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "56CCF2").opacity(0.3), Color(hex: "2F80ED").opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.w_blisslink
                )
        )
    }
    
    // MARK: - 发布按钮
    
    private var publishButton_blisslink: some View {
        Button(action: {
            handlePublish_blisslink()
        }) {
            ZStack {
                // 背景渐变
                RoundedRectangle(cornerRadius: 16.w_blisslink)
                    .fill(
                        isValid_blisslink && !isPublishing_blisslink ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.4)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 56.h_blisslink)
                
                // 装饰光晕
                if isValid_blisslink && !isPublishing_blisslink {
                    RoundedRectangle(cornerRadius: 16.w_blisslink)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.3), Color.clear]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 28.h_blisslink)
                        .frame(maxHeight: .infinity, alignment: .top)
                }
                
                // 按钮内容
                HStack(spacing: 12.w_blisslink) {
                    if isPublishing_blisslink {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.0)
                        
                        Text("Publishing...")
                            .font(.system(size: 17.sp_blisslink, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20.sp_blisslink, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Publish Post")
                            .font(.system(size: 17.sp_blisslink, weight: .bold))
                            .foregroundColor(.white)
                        
                        if isValid_blisslink {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18.sp_blisslink))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .shadow(
                color: (isValid_blisslink && !isPublishing_blisslink) ? Color(hex: "667EEA").opacity(0.4) : Color.clear,
                radius: 20,
                x: 0,
                y: 10
            )
        }
        .disabled(!isValid_blisslink || isPublishing_blisslink)
        .scaleEffect((isValid_blisslink && !isPublishing_blisslink) ? 1.0 : 0.97)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isValid_blisslink)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isPublishing_blisslink)
    }
    
    // MARK: - 计算属性
    
    /// 验证输入是否有效
    private var isValid_blisslink: Bool {
        let hasMedia_blisslink = selectedMediaImage_blisslink != nil && !selectedMediaName_blisslink.isEmpty
        let hasTitle_blisslink = !titleText_blisslink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasContent_blisslink = !contentText_blisslink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        return hasMedia_blisslink && hasTitle_blisslink && hasContent_blisslink
    }
    
    /// 是否有内容（用于清除按钮）
    private var hasContent_blisslink: Bool {
        return selectedMediaImage_blisslink != nil || !titleText_blisslink.isEmpty || !contentText_blisslink.isEmpty
    }
    
    // MARK: - 事件处理
    
    /// 加载选中的媒体
    private func loadSelectedMedia_blisslink() {
        guard let selectedMedia_blisslink = selectedMedia_blisslink else { return }
        
        Task {
            // 先尝试加载视频
            if let movie_blisslink = try? await selectedMedia_blisslink.loadTransferable(type: Movie.self) {
                await MainActor.run {
                    // 提取视频缩略图
                    let thumbnail_blisslink = generateVideoThumbnail_blisslink(url_blisslink: movie_blisslink.url)
                    selectedMediaImage_blisslink = thumbnail_blisslink
                    
                    // 生成唯一的媒体名称
                    selectedMediaName_blisslink = "post_video_\(UUID().uuidString)"
                    isVideo_blisslink = true
                    
                    // 保存缩略图到文档目录
                    if let thumbnail_blisslink = thumbnail_blisslink {
                        saveMediaToDocuments_blisslink(image_blisslink: thumbnail_blisslink)
                    }
                    
                    // 触觉反馈
                    let generator_blisslink = UIImpactFeedbackGenerator(style: .medium)
                    generator_blisslink.impactOccurred()
                    
                    print("✅ 视频加载成功")
                }
                return
            }
            
            // 如果不是视频，尝试加载图片
            if let data_blisslink = try? await selectedMedia_blisslink.loadTransferable(type: Data.self) {
                if let image_blisslink = UIImage(data: data_blisslink) {
                    await MainActor.run {
                        selectedMediaImage_blisslink = image_blisslink
                        // 生成唯一的媒体名称
                        selectedMediaName_blisslink = "post_\(UUID().uuidString)"
                        isVideo_blisslink = false
                        
                        // 保存图片到文档目录
                        saveMediaToDocuments_blisslink(image_blisslink: image_blisslink)
                        
                        // 触觉反馈
                        let generator_blisslink = UIImpactFeedbackGenerator(style: .medium)
                        generator_blisslink.impactOccurred()
                        
                        print("✅ 图片加载成功")
                    }
                }
            }
        }
    }
    
    /// 生成视频缩略图
    /// - Parameter url_blisslink: 视频URL
    /// - Returns: 缩略图UIImage
    private func generateVideoThumbnail_blisslink(url_blisslink: URL) -> UIImage? {
        let asset_blisslink = AVAsset(url: url_blisslink)
        let imageGenerator_blisslink = AVAssetImageGenerator(asset: asset_blisslink)
        imageGenerator_blisslink.appliesPreferredTrackTransform = true
        
        // 设置缩略图大小
        imageGenerator_blisslink.maximumSize = CGSize(width: 1000, height: 1000)
        
        do {
            let cgImage_blisslink = try imageGenerator_blisslink.copyCGImage(at: .zero, actualTime: nil)
            let thumbnail_blisslink = UIImage(cgImage: cgImage_blisslink)
            print("✅ 视频缩略图生成成功")
            return thumbnail_blisslink
        } catch {
            print("❌ 视频缩略图生成失败：\(error.localizedDescription)")
            return nil
        }
    }
    
    /// 保存媒体到文档目录
    /// - Parameter image_blisslink: 要保存的图片
    private func saveMediaToDocuments_blisslink(image_blisslink: UIImage) {
        guard let data_blisslink = image_blisslink.jpegData(compressionQuality: 0.8) else { return }
        
        let fileManager_blisslink = FileManager.default
        guard let documentsDirectory_blisslink = fileManager_blisslink.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL_blisslink = documentsDirectory_blisslink.appendingPathComponent("\(selectedMediaName_blisslink).jpg")
        
        do {
            try data_blisslink.write(to: fileURL_blisslink)
            print("✅ 媒体保存成功：\(fileURL_blisslink.path)")
        } catch {
            print("❌ 媒体保存失败：\(error.localizedDescription)")
        }
    }
    
    /// 删除选中的媒体
    private func handleDeleteMedia_blisslink() {
        // 删除临时保存的文件
        if !selectedMediaName_blisslink.isEmpty && selectedMediaName_blisslink.hasPrefix("post_") {
            deleteMediaFromDocuments_blisslink()
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
            selectedMediaImage_blisslink = nil
            selectedMediaName_blisslink = ""
            selectedMedia_blisslink = nil
            isVideo_blisslink = false
        }
        
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
    }
    
    /// 从文档目录删除媒体
    private func deleteMediaFromDocuments_blisslink() {
        let fileManager_blisslink = FileManager.default
        guard let documentsDirectory_blisslink = fileManager_blisslink.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL_blisslink = documentsDirectory_blisslink.appendingPathComponent("\(selectedMediaName_blisslink).jpg")
        
        do {
            try fileManager_blisslink.removeItem(at: fileURL_blisslink)
            print("✅ 媒体删除成功：\(fileURL_blisslink.path)")
        } catch {
            print("❌ 媒体删除失败：\(error.localizedDescription)")
        }
    }
    
    /// 清除所有内容
    private func handleClearContent_blisslink() {
        // 触觉反馈
        let generator_blisslink = UINotificationFeedbackGenerator()
        generator_blisslink.notificationOccurred(.warning)
        
        // 删除媒体
        if selectedMediaImage_blisslink != nil {
            handleDeleteMedia_blisslink()
        }
        
        // 清除文本
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
            titleText_blisslink = ""
            contentText_blisslink = ""
        }
        
        Utils_blisslink.showInfo_blisslink(
            message_blisslink: "Content cleared",
            delay_blisslink: 1.0
        )
    }
    
    /// 处理发布
    private func handlePublish_blisslink() {
        // 检查是否登录
        if !userVM_blisslink.isLoggedIn_blisslink {
            Utils_blisslink.showWarning_blisslink(
                message_blisslink: "Please login first.",
                delay_blisslink: 1.5
            )
            
            // 延迟跳转到登录页面
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒
                router_blisslink.toLogin_blisslink()
            }
            return
        }
        
        // 验证输入
        guard isValid_blisslink else {
            Utils_blisslink.showWarning_blisslink(
                message_blisslink: "Please complete all fields.",
                delay_blisslink: 1.5
            )
            return
        }
        
        // 触觉反馈
        let generator_blisslink = UINotificationFeedbackGenerator()
        generator_blisslink.notificationOccurred(.success)
        
        // 开始发布
        isPublishing_blisslink = true
        
        // 模拟发布过程
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒
            
            // 调用ViewModel发布帖子
            titleVM_blisslink.releasePost_blisslink(
                title_blisslink: titleText_blisslink,
                content_blisslink: contentText_blisslink,
                media_blisslink: selectedMediaName_blisslink,
                type_blisslink: 0
            )
            
            isPublishing_blisslink = false
            
            // 延迟关闭页面
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            router_blisslink.dismissFullScreen_blisslink()
            
            // 清空表单
            clearForm_blisslink()
        }
    }
    
    /// 清空表单
    private func clearForm_blisslink() {
        selectedMediaImage_blisslink = nil
        selectedMediaName_blisslink = ""
        selectedMedia_blisslink = nil
        isVideo_blisslink = false
        titleText_blisslink = ""
        contentText_blisslink = ""
    }
}
