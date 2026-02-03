import SwiftUI
import PhotosUI
import AVKit

// MARK: - 媒体上传展示组件
// 核心作用：用于发布页面的媒体上传和预览
// 设计思路：支持图片/视频上传、预览、删除功能
// 关键功能：媒体选择、预览展示、删除按钮

/// 媒体上传视图
struct MediaUploadView_blisslink: View {
    
    // MARK: - 属性
    
    /// 选中的媒体项
    @Binding var selectedMedia_blisslink: PhotosPickerItem?
    
    /// 选中的媒体图片
    @Binding var selectedMediaImage_blisslink: UIImage?
    
    /// 选中的媒体名称
    @Binding var selectedMediaName_blisslink: String
    
    /// 是否是视频
    @Binding var isVideo_blisslink: Bool
    
    /// 删除回调
    var onDelete_blisslink: (() -> Void)?
    
    // MARK: - 视图主体
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12.h_baseswiftui) {
            // 标签
            HStack(spacing: 8.w_baseswiftui) {
                Image(systemName: "photo.fill")
                    .font(.system(size: 16.sp_baseswiftui, weight: .semibold))
                    .foregroundColor(Color(hex: "667EEA"))
                
                Text("Media")
                    .font(.system(size: 16.sp_baseswiftui, weight: .semibold))
                    .foregroundColor(.primary)
                
                // 必填标识
                Text("*")
                    .font(.system(size: 18.sp_baseswiftui, weight: .bold))
                    .foregroundColor(.red)
                
                Spacer()
                
                // 媒体类型标识
                if selectedMediaImage_blisslink != nil {
                    HStack(spacing: 6.w_baseswiftui) {
                        Image(systemName: isVideo_blisslink ? "video.fill" : "photo.fill")
                            .font(.system(size: 12.sp_baseswiftui))
                        
                        Text(isVideo_blisslink ? "Video" : "Photo")
                            .font(.system(size: 12.sp_baseswiftui, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "667EEA"))
                    .padding(.horizontal, 10.w_baseswiftui)
                    .padding(.vertical, 4.h_baseswiftui)
                    .background(
                        Capsule()
                            .fill(Color(hex: "667EEA").opacity(0.1))
                    )
                }
            }
            
            ZStack(alignment: .topTrailing) {
                // 媒体选择/预览
                if selectedMediaImage_blisslink != nil {
                    // 显示已选媒体
                    mediaPreviewView_blisslink
                } else {
                    // 显示选择器
                    mediaPickerView_blisslink
                }
                
                // 删除媒体按钮（仅在有媒体时显示）
                if selectedMediaImage_blisslink != nil {
                    Button(action: {
                        handleDelete_blisslink()
                    }) {
                        ZStack {
                            // 外层光晕
                            Circle()
                                .fill(Color.red.opacity(0.2))
                                .frame(width: 38.w_baseswiftui, height: 38.h_baseswiftui)
                            
                            // 内层背景
                            Circle()
                                .fill(Color.red)
                                .frame(width: 32.w_baseswiftui, height: 32.h_baseswiftui)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 14.sp_baseswiftui, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(12.w_baseswiftui)
                }
            }
        }
    }
    
    // MARK: - 媒体预览视图
    
    private var mediaPreviewView_blisslink: some View {
        ZStack {
            if let image_blisslink = selectedMediaImage_blisslink {
                // 媒体图片
                Image(uiImage: image_blisslink)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 280.h_baseswiftui)
                    .clipped()
                    .cornerRadius(18.w_baseswiftui)
                
                // 底部渐变遮罩
                VStack {
                    Spacer()
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.3)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 80.h_baseswiftui)
                }
                .cornerRadius(18.w_baseswiftui)
                
                // 视频标识
                if isVideo_blisslink {
                    ZStack {
                        // 外层光晕
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 75.w_baseswiftui, height: 75.h_baseswiftui)
                            .blur(radius: 10)
                        
                        // 主背景
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 65.w_baseswiftui, height: 65.h_baseswiftui)
                        
                        Image(systemName: "play.fill")
                            .font(.system(size: 30.sp_baseswiftui))
                            .foregroundColor(.white)
                            .offset(x: 2.w_baseswiftui)
                    }
                }
                
                // 底部媒体信息
                VStack {
                    Spacer()
                    HStack(spacing: 8.w_baseswiftui) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16.sp_baseswiftui))
                            .foregroundColor(.white)
                        
                        Text(isVideo_blisslink ? "Video selected" : "Photo selected")
                            .font(.system(size: 13.sp_baseswiftui, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16.w_baseswiftui)
                    .padding(.bottom, 16.h_baseswiftui)
                }
            }
        }
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - 媒体选择器视图
    
    private var mediaPickerView_blisslink: some View {
        PhotosPicker(selection: $selectedMedia_blisslink, matching: .any(of: [.images, .videos])) {
            ZStack {
                // 背景渐变
                RoundedRectangle(cornerRadius: 18.w_baseswiftui)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "667EEA").opacity(0.05),
                                Color(hex: "764BA2").opacity(0.08)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 280.h_baseswiftui)
                
                // 虚线边框
                RoundedRectangle(cornerRadius: 18.w_baseswiftui)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 2.5.w_baseswiftui, dash: [10, 5])
                    )
                    .frame(height: 280.h_baseswiftui)
                
                VStack(spacing: 20.h_baseswiftui) {
                    // 主图标
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "667EEA").opacity(0.15),
                                        Color(hex: "764BA2").opacity(0.15)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100.w_baseswiftui, height: 100.h_baseswiftui)
                        
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 50.sp_baseswiftui, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    VStack(spacing: 8.h_baseswiftui) {
                        Text("Tap to upload photo or video")
                            .font(.system(size: 16.sp_baseswiftui, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        // 支持格式标签
                        HStack(spacing: 8.w_baseswiftui) {
                            formatTag_blisslink(icon_blisslink: "photo.fill", text_blisslink: "JPG/PNG")
                            formatTag_blisslink(icon_blisslink: "video.fill", text_blisslink: "MP4")
                        }
                    }
                }
            }
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
    
    /// 格式标签
    private func formatTag_blisslink(icon_blisslink: String, text_blisslink: String) -> some View {
        HStack(spacing: 4.w_baseswiftui) {
            Image(systemName: icon_blisslink)
                .font(.system(size: 10.sp_baseswiftui))
            
            Text(text_blisslink)
                .font(.system(size: 11.sp_baseswiftui, weight: .medium))
        }
        .foregroundColor(.secondary)
        .padding(.horizontal, 10.w_baseswiftui)
        .padding(.vertical, 5.h_baseswiftui)
        .background(
            Capsule()
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    // MARK: - 事件处理
    
    /// 删除媒体
    private func handleDelete_blisslink() {
        onDelete_blisslink?()
    }
}

// MARK: - 媒体展示组件（通用）
// 核心作用：展示各种来源的媒体内容（图片/视频）
// 设计思路：自动识别媒体来源（本地、Assets、网络、文档目录、系统图标）
// 关键功能：智能加载、占位符、视频标识

/// 媒体展示视图（通用）
struct MediaDisplayView_blisslink: View {
    
    /// 媒体路径
    let mediaPath_blisslink: String?
    
    /// 是否是视频
    let isVideo_blisslink: Bool
    
    /// 圆角半径
    var cornerRadius_blisslink: CGFloat = 12.w_baseswiftui
    
    /// 高度
    var height_blisslink: CGFloat?
    
    /// 是否可点击
    var isClickable_blisslink: Bool = false
    
    /// 点击回调
    var onTapped_blisslink: (() -> Void)?
    
    @State private var loadedImage_blisslink: UIImage?
    @State private var isLoading_blisslink: Bool = false
    
    var body: some View {
        Group {
            if let path_blisslink = mediaPath_blisslink, !path_blisslink.isEmpty {
                mediaContent_blisslink(path_blisslink: path_blisslink)
            } else {
                placeholderView_blisslink
            }
        }
        .cornerRadius(cornerRadius_blisslink)
        .onTapGesture {
            if isClickable_blisslink {
                onTapped_blisslink?()
            }
        }
        .onAppear {
            loadMedia_blisslink()
        }
    }
    
    // MARK: - 媒体内容视图
    
    /// 根据路径类型展示不同的媒体内容
    @ViewBuilder
    private func mediaContent_blisslink(path_blisslink: String) -> some View {
        ZStack {
            if let image_blisslink = loadedImage_blisslink {
                Image(uiImage: image_blisslink)
                    .resizable()
                    .scaledToFill()
                    .frame(height: height_blisslink)
                    .clipped()
            } else if isSystemIcon_blisslink(path_blisslink: path_blisslink) {
                systemIconView_blisslink(iconName_blisslink: path_blisslink)
            } else if isLoading_blisslink {
                loadingView_blisslink
            } else {
                placeholderView_blisslink
            }
            
            // 视频播放图标
            if isVideo_blisslink {
                videoPlayIcon_blisslink
            }
        }
        .frame(height: height_blisslink)
    }
    
    // MARK: - 系统图标视图
    
    /// 系统图标视图（带渐变背景）
    @ViewBuilder
    private func systemIconView_blisslink(iconName_blisslink: String) -> some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                gradient: Gradient(colors: gradientColors_blisslink(for: iconName_blisslink)),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 系统图标
            Image(systemName: iconName_blisslink)
                .font(.system(size: 80.sp_baseswiftui))
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(height: height_blisslink)
    }
    
    // MARK: - 占位符视图
    
    /// 占位符视图
    private var placeholderView_blisslink: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "667EEA").opacity(0.2),
                    Color(hex: "764BA2").opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 占位符图标
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48.sp_baseswiftui))
                .foregroundColor(.gray.opacity(0.5))
        }
        .frame(height: height_blisslink)
    }
    
    // MARK: - 加载中视图
    
    /// 加载中视图
    private var loadingView_blisslink: some View {
        ZStack {
            Color.gray.opacity(0.2)
            
            ProgressView()
                .scaleEffect(1.5)
        }
        .frame(height: height_blisslink)
    }
    
    // MARK: - 视频播放图标
    
    /// 视频播放图标
    private var videoPlayIcon_blisslink: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.6))
                .frame(width: 60.w_baseswiftui, height: 60.h_baseswiftui)
            
            Image(systemName: "play.fill")
                .font(.system(size: 28.sp_baseswiftui))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - 辅助方法
    
    /// 加载媒体
    private func loadMedia_blisslink() {
        guard let path_blisslink = mediaPath_blisslink, !path_blisslink.isEmpty else {
            return
        }
        
        // 如果是系统图标，不需要加载
        if isSystemIcon_blisslink(path_blisslink: path_blisslink) {
            return
        }
        
        isLoading_blisslink = true
        
        // 1. 尝试从 Assets 加载
        if let image_blisslink = UIImage(named: path_blisslink) {
            loadedImage_blisslink = image_blisslink
            isLoading_blisslink = false
            return
        }
        
        // 2. 尝试从文档目录加载
        let fileManager_blisslink = FileManager.default
        if let documentsDirectory_blisslink = fileManager_blisslink.urls(for: .documentDirectory, in: .userDomainMask).first {
            // 尝试带扩展名
            var fileURL_blisslink = documentsDirectory_blisslink.appendingPathComponent("\(path_blisslink).jpg")
            
            if let image_blisslink = UIImage(contentsOfFile: fileURL_blisslink.path) {
                loadedImage_blisslink = image_blisslink
                isLoading_blisslink = false
                print("✅ 从文档目录加载媒体：\(path_blisslink)")
                return
            }
            
            // 尝试不带扩展名
            fileURL_blisslink = documentsDirectory_blisslink.appendingPathComponent(path_blisslink)
            if let image_blisslink = UIImage(contentsOfFile: fileURL_blisslink.path) {
                loadedImage_blisslink = image_blisslink
                isLoading_blisslink = false
                print("✅ 从文档目录加载媒体：\(path_blisslink)")
                return
            }
        }
        
        // 3. 尝试作为完整路径加载
        if let image_blisslink = UIImage(contentsOfFile: path_blisslink) {
            loadedImage_blisslink = image_blisslink
            isLoading_blisslink = false
            return
        }
        
        print("⚠️ 无法加载媒体：\(path_blisslink)")
        isLoading_blisslink = false
    }
    
    /// 判断是否是系统图标
    private func isSystemIcon_blisslink(path_blisslink: String) -> Bool {
        return UIImage(systemName: path_blisslink) != nil
    }
    
    /// 根据路径生成渐变色
    private func gradientColors_blisslink(for path_blisslink: String) -> [Color] {
        let gradients_blisslink: [[Color]] = [
            [Color(hex: "667eea"), Color(hex: "764ba2")],  // 紫色
            [Color(hex: "f093fb"), Color(hex: "f5576c")],  // 粉红
            [Color(hex: "4facfe"), Color(hex: "00f2fe")],  // 蓝色
            [Color(hex: "43e97b"), Color(hex: "38f9d7")],  // 绿色
            [Color(hex: "fa709a"), Color(hex: "fee140")]   // 暖色
        ]
        
        let index_blisslink = abs(path_blisslink.hashValue) % gradients_blisslink.count
        return gradients_blisslink[index_blisslink]
    }
}
