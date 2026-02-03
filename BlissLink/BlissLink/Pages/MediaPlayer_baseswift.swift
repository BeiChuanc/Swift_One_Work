import SwiftUI
import AVKit

// MARK: - 媒体播放器页面
// 核心作用：全屏展示图片或视频媒体，支持多种媒体来源
// 设计思路：支持系统图标、网络图片、本地图片、Assets图片、Bundle视频、文档目录图片
// 关键特性：全屏展示、缩放手势、视频播放控制、返回按钮

/// 媒体播放器页面
struct MediaPlayer_baseswift: View {
    
    /// 媒体路径
    let mediaUrl_baseswiftui: String
    
    /// 是否是视频
    let isVideo_baseswiftui: Bool
    
    /// 路由管理器
    @ObservedObject var router_baseswiftui = Router_baseswiftui.shared_baseswiftui
    
    /// 缩放比例
    @State private var scale_blisslink: CGFloat = 1.0
    @State private var lastScale_blisslink: CGFloat = 1.0
    
    /// 偏移量
    @State private var offset_blisslink: CGSize = .zero
    @State private var lastOffset_blisslink: CGSize = .zero
    
    var body: some View {
        ZStack {
            // 背景
            Color.black
                .ignoresSafeArea()
            
            // 媒体内容
            mediaContentView_blisslink
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 左上角返回按钮
            VStack {
                HStack {
                    Button(action: {
                        handleBack_blisslink()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.6))
                                .frame(width: 44.w_baseswiftui, height: 44.h_baseswiftui)
                            
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18.sp_baseswiftui, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.leading, 20.w_baseswiftui)
                    .padding(.top, 50.h_baseswiftui)
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .statusBar(hidden: true)
    }
    
    // MARK: - 媒体内容视图
    
    /// 媒体内容视图
    /// 核心作用：根据媒体类型展示不同的内容
    @ViewBuilder
    private var mediaContentView_blisslink: some View {
        if isVideo_baseswiftui {
            // 视频播放器
            videoPlayerView_blisslink
        } else {
            // 图片展示（支持缩放和拖动）
            imageView_blisslink
        }
    }
    
    // MARK: - 视频播放器视图
    
    /// 视频播放器视图
    /// 核心作用：播放视频，支持Bundle视频和网络视频
    @ViewBuilder
    private var videoPlayerView_blisslink: some View {
        if let videoURL_blisslink = getVideoURL_blisslink() {
            VideoPlayer(player: AVPlayer(url: videoURL_blisslink))
                .ignoresSafeArea()
                .onAppear {
                    print("✅ 开始播放视频：\(videoURL_blisslink)")
                }
        } else {
            // 视频加载失败占位符
            VStack(spacing: 20.h_baseswiftui) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60.sp_baseswiftui))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Video not found")
                    .font(.system(size: 18.sp_baseswiftui, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    /// 获取视频URL
    /// 核心作用：根据路径获取视频的URL，支持Bundle和网络视频
    /// - Returns: 视频URL或nil
    private func getVideoURL_blisslink() -> URL? {
        // 1. 检查是否是网络视频
        if mediaUrl_baseswiftui.hasPrefix("http://") || mediaUrl_baseswiftui.hasPrefix("https://") {
            return URL(string: mediaUrl_baseswiftui)
        }
        
        // 2. 检查是否是Bundle中的视频
        let fileName_blisslink: String
        if mediaUrl_baseswiftui.hasSuffix(".mp4") {
            fileName_blisslink = mediaUrl_baseswiftui.replacingOccurrences(of: ".mp4", with: "")
        } else {
            fileName_blisslink = mediaUrl_baseswiftui
        }
        
        if let videoPath_blisslink = Bundle.main.path(forResource: fileName_blisslink, ofType: "mp4") {
            return URL(fileURLWithPath: videoPath_blisslink)
        }
        
        // 3. 检查文档目录
        let fileManager_blisslink = FileManager.default
        if let documentsDirectory_blisslink = fileManager_blisslink.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL_blisslink = documentsDirectory_blisslink.appendingPathComponent("\(mediaUrl_baseswiftui).mp4")
            if fileManager_blisslink.fileExists(atPath: fileURL_blisslink.path) {
                return fileURL_blisslink
            }
        }
        
        print("⚠️ 无法找到视频：\(mediaUrl_baseswiftui)")
        return nil
    }
    
    // MARK: - 图片展示视图
    
    /// 图片展示视图（支持缩放和拖动）
    /// 核心作用：展示图片，支持双指缩放和拖动
    @ViewBuilder
    private var imageView_blisslink: some View {
        GeometryReader { geometry_blisslink in
            ZStack {
                if let image_blisslink = loadImage_blisslink() {
                    Image(uiImage: image_blisslink)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry_blisslink.size.width, height: geometry_blisslink.size.height)
                        .scaleEffect(scale_blisslink)
                        .offset(offset_blisslink)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value_blisslink in
                                    scale_blisslink = lastScale_blisslink * value_blisslink
                                }
                                .onEnded { _ in
                                    // 限制缩放范围
                                    if scale_blisslink < 1.0 {
                                        withAnimation(.spring()) {
                                            scale_blisslink = 1.0
                                        }
                                    } else if scale_blisslink > 5.0 {
                                        scale_blisslink = 5.0
                                    }
                                    lastScale_blisslink = scale_blisslink
                                }
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value_blisslink in
                                    offset_blisslink = CGSize(
                                        width: lastOffset_blisslink.width + value_blisslink.translation.width,
                                        height: lastOffset_blisslink.height + value_blisslink.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset_blisslink = offset_blisslink
                                }
                        )
                        .onTapGesture(count: 2) {
                            // 双击重置缩放
                            withAnimation(.spring()) {
                                scale_blisslink = 1.0
                                lastScale_blisslink = 1.0
                                offset_blisslink = .zero
                                lastOffset_blisslink = .zero
                            }
                        }
                } else {
                    // 图片加载失败占位符
                    VStack(spacing: 20.h_baseswiftui) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 60.sp_baseswiftui))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("Image not found")
                            .font(.system(size: 18.sp_baseswiftui, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
    }
    
    /// 加载图片
    /// 核心作用：根据路径加载图片，支持多种来源
    /// - Returns: UIImage或nil
    private func loadImage_blisslink() -> UIImage? {
        // 1. 检查是否是系统图标
        if let systemImage_blisslink = UIImage(systemName: mediaUrl_baseswiftui) {
            // 将系统图标转换为带背景的图片
            return createImageFromSystemIcon_blisslink(iconName: mediaUrl_baseswiftui)
        }
        
        // 2. 检查是否是网络图片（这里只做标记，实际需要异步加载）
        if mediaUrl_baseswiftui.hasPrefix("http://") || mediaUrl_baseswiftui.hasPrefix("https://") {
            // 注意：这里需要异步加载，暂时返回nil
            print("⚠️ 网络图片需要异步加载：\(mediaUrl_baseswiftui)")
            return nil
        }
        
        // 3. 尝试从 Assets 加载
        if let image_blisslink = UIImage(named: mediaUrl_baseswiftui) {
            return image_blisslink
        }
        
        // 4. 尝试从文档目录加载
        if let image_blisslink = loadImageFromDocuments_blisslink() {
            return image_blisslink
        }
        
        print("⚠️ 无法加载图片：\(mediaUrl_baseswiftui)")
        return nil
    }
    
    /// 从文档目录加载图片
    /// - Returns: UIImage或nil
    private func loadImageFromDocuments_blisslink() -> UIImage? {
        let fileManager_blisslink = FileManager.default
        guard let documentsDirectory_blisslink = fileManager_blisslink.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        // 尝试带 .jpg 扩展名
        var fileURL_blisslink = documentsDirectory_blisslink.appendingPathComponent("\(mediaUrl_baseswiftui).jpg")
        if let image_blisslink = UIImage(contentsOfFile: fileURL_blisslink.path) {
            return image_blisslink
        }
        
        // 尝试不带扩展名
        fileURL_blisslink = documentsDirectory_blisslink.appendingPathComponent(mediaUrl_baseswiftui)
        if let image_blisslink = UIImage(contentsOfFile: fileURL_blisslink.path) {
            return image_blisslink
        }
        
        return nil
    }
    
    /// 从系统图标创建图片
    /// 核心作用：将系统图标渲染成带渐变背景的图片
    /// - Parameter iconName: 系统图标名称
    /// - Returns: UIImage
    private func createImageFromSystemIcon_blisslink(iconName: String) -> UIImage? {
        let size_blisslink = CGSize(width: 300, height: 300)
        let renderer_blisslink = UIGraphicsImageRenderer(size: size_blisslink)
        
        return renderer_blisslink.image { context_blisslink in
            // 绘制渐变背景
            let colors_blisslink: [UIColor] = [
                UIColor(red: 0.4, green: 0.49, blue: 0.92, alpha: 1.0),
                UIColor(red: 0.46, green: 0.29, blue: 0.64, alpha: 1.0)
            ]
            
            if let gradient_blisslink = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors_blisslink.map { $0.cgColor } as CFArray,
                locations: [0.0, 1.0]
            ) {
                context_blisslink.cgContext.drawLinearGradient(
                    gradient_blisslink,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: size_blisslink.width, y: size_blisslink.height),
                    options: []
                )
            }
            
            // 绘制系统图标
            if let systemImage_blisslink = UIImage(systemName: iconName) {
                let iconSize_blisslink: CGFloat = 120
                let iconRect_blisslink = CGRect(
                    x: (size_blisslink.width - iconSize_blisslink) / 2,
                    y: (size_blisslink.height - iconSize_blisslink) / 2,
                    width: iconSize_blisslink,
                    height: iconSize_blisslink
                )
                
                systemImage_blisslink.withTintColor(.white.withAlphaComponent(0.9), renderingMode: .alwaysOriginal)
                    .draw(in: iconRect_blisslink)
            }
        }
    }
    
    // MARK: - 事件处理
    
    /// 处理返回操作
    /// 核心作用：返回上一页或关闭全屏
    private func handleBack_blisslink() {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
        
        // 检查是否是全屏模式
        if router_baseswiftui.presentedFullScreen_baseswiftui != nil {
            router_baseswiftui.dismissFullScreen_baseswiftui()
        } else {
            router_baseswiftui.pop_baseswiftui()
        }
    }
}
