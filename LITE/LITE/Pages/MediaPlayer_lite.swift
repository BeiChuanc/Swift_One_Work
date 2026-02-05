import SwiftUI
import AVKit

// MARK: - 媒体播放器页面
// 核心作用：全屏展示图片或视频媒体，支持多种媒体来源
// 设计思路：支持系统图标、网络图片、本地图片、Assets图片、Bundle视频、文档目录图片
// 关键特性：全屏展示、缩放手势、视频播放控制、返回按钮

/// 媒体播放器页面
struct MediaPlayer_lite: View {
    
    /// 媒体路径
    let mediaUrl_lite: String
    
    /// 是否是视频
    let isVideo_lite: Bool
    
    /// 路由管理器
    @ObservedObject var router_lite = Router_lite.shared_lite
    
    /// 缩放比例
    @State private var scale_lite: CGFloat = 1.0
    @State private var lastScale_lite: CGFloat = 1.0
    
    /// 偏移量
    @State private var offset_lite: CGSize = .zero
    @State private var lastOffset_lite: CGSize = .zero
    
    var body: some View {
        ZStack {
            // 背景
            Color.black
                .ignoresSafeArea()
            
            // 媒体内容
            mediaContentView_lite
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 左上角返回按钮
            VStack {
                HStack {
                    Button(action: {
                        handleBack_lite()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.6))
                                .frame(width: 44.w_lite, height: 44.h_lite)
                            
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18.sp_lite, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.leading, 20.w_lite)
                    .padding(.top, 50.h_lite)
                    
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
    private var mediaContentView_lite: some View {
        if isVideo_lite {
            // 视频播放器
            videoPlayerView_lite
        } else {
            // 图片展示（支持缩放和拖动）
            imageView_lite
        }
    }
    
    // MARK: - 视频播放器视图
    
    /// 视频播放器视图
    /// 核心作用：播放视频，支持Bundle视频和网络视频
    @ViewBuilder
    private var videoPlayerView_lite: some View {
        if let videoURL_lite = getVideoURL_lite() {
            VideoPlayer(player: AVPlayer(url: videoURL_lite))
                .ignoresSafeArea()
                .onAppear {
                    print("✅ 开始播放视频：\(videoURL_lite)")
                }
        } else {
            // 视频加载失败占位符
            VStack(spacing: 20.h_lite) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60.sp_lite))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Video not found")
                    .font(.system(size: 18.sp_lite, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    /// 获取视频URL
    /// 核心作用：根据路径获取视频的URL，支持Bundle和网络视频
    /// - Returns: 视频URL或nil
    private func getVideoURL_lite() -> URL? {
        // 1. 检查是否是网络视频
        if mediaUrl_lite.hasPrefix("http://") || mediaUrl_lite.hasPrefix("https://") {
            return URL(string: mediaUrl_lite)
        }
        
        // 2. 检查是否是Bundle中的视频
        let fileName_lite: String
        if mediaUrl_lite.hasSuffix(".mp4") {
            fileName_lite = mediaUrl_lite.replacingOccurrences(of: ".mp4", with: "")
        } else {
            fileName_lite = mediaUrl_lite
        }
        
        if let videoPath_lite = Bundle.main.path(forResource: fileName_lite, ofType: "mp4") {
            return URL(fileURLWithPath: videoPath_lite)
        }
        
        // 3. 检查文档目录
        let fileManager_lite = FileManager.default
        if let documentsDirectory_lite = fileManager_lite.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL_lite = documentsDirectory_lite.appendingPathComponent("\(mediaUrl_lite).mp4")
            if fileManager_lite.fileExists(atPath: fileURL_lite.path) {
                return fileURL_lite
            }
        }
        
        print("⚠️ 无法找到视频：\(mediaUrl_lite)")
        return nil
    }
    
    // MARK: - 图片展示视图
    
    /// 图片展示视图（支持缩放和拖动）
    /// 核心作用：展示图片，支持双指缩放和拖动
    @ViewBuilder
    private var imageView_lite: some View {
        GeometryReader { geometry_lite in
            ZStack {
                if let image_lite = loadImage_lite() {
                    Image(uiImage: image_lite)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry_lite.size.width, height: geometry_lite.size.height)
                        .scaleEffect(scale_lite)
                        .offset(offset_lite)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value_lite in
                                    scale_lite = lastScale_lite * value_lite
                                }
                                .onEnded { _ in
                                    // 限制缩放范围
                                    if scale_lite < 1.0 {
                                        withAnimation(.spring()) {
                                            scale_lite = 1.0
                                        }
                                    } else if scale_lite > 5.0 {
                                        scale_lite = 5.0
                                    }
                                    lastScale_lite = scale_lite
                                }
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value_lite in
                                    offset_lite = CGSize(
                                        width: lastOffset_lite.width + value_lite.translation.width,
                                        height: lastOffset_lite.height + value_lite.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset_lite = offset_lite
                                }
                        )
                        .onTapGesture(count: 2) {
                            // 双击重置缩放
                            withAnimation(.spring()) {
                                scale_lite = 1.0
                                lastScale_lite = 1.0
                                offset_lite = .zero
                                lastOffset_lite = .zero
                            }
                        }
                } else {
                    // 图片加载失败占位符
                    VStack(spacing: 20.h_lite) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 60.sp_lite))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("Image not found")
                            .font(.system(size: 18.sp_lite, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
    }
    
    /// 加载图片
    /// 核心作用：根据路径加载图片，支持多种来源
    /// - Returns: UIImage或nil
    private func loadImage_lite() -> UIImage? {
        // 1. 检查是否是系统图标
        if UIImage(systemName: mediaUrl_lite) != nil {
            // 将系统图标转换为带背景的图片
            return createImageFromSystemIcon_lite(iconName: mediaUrl_lite)
        }
        
        // 2. 检查是否是网络图片（这里只做标记，实际需要异步加载）
        if mediaUrl_lite.hasPrefix("http://") || mediaUrl_lite.hasPrefix("https://") {
            // 注意：这里需要异步加载，暂时返回nil
            print("⚠️ 网络图片需要异步加载：\(mediaUrl_lite)")
            return nil
        }
        
        // 3. 尝试从 Assets 加载
        if let image_lite = UIImage(named: mediaUrl_lite) {
            return image_lite
        }
        
        // 4. 尝试从文档目录加载
        if let image_lite = loadImageFromDocuments_lite() {
            return image_lite
        }
        
        print("⚠️ 无法加载图片：\(mediaUrl_lite)")
        return nil
    }
    
    /// 从文档目录加载图片
    /// - Returns: UIImage或nil
    private func loadImageFromDocuments_lite() -> UIImage? {
        let fileManager_lite = FileManager.default
        guard let documentsDirectory_lite = fileManager_lite.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        // 尝试带 .jpg 扩展名
        var fileURL_lite = documentsDirectory_lite.appendingPathComponent("\(mediaUrl_lite).jpg")
        if let image_lite = UIImage(contentsOfFile: fileURL_lite.path) {
            return image_lite
        }
        
        // 尝试不带扩展名
        fileURL_lite = documentsDirectory_lite.appendingPathComponent(mediaUrl_lite)
        if let image_lite = UIImage(contentsOfFile: fileURL_lite.path) {
            return image_lite
        }
        
        return nil
    }
    
    /// 从系统图标创建图片
    /// 核心作用：将系统图标渲染成带渐变背景的图片
    /// - Parameter iconName: 系统图标名称
    /// - Returns: UIImage
    private func createImageFromSystemIcon_lite(iconName: String) -> UIImage? {
        let size_lite = CGSize(width: 300, height: 300)
        let renderer_lite = UIGraphicsImageRenderer(size: size_lite)
        
        return renderer_lite.image { context_lite in
            // 绘制渐变背景
            let colors_lite: [UIColor] = [
                UIColor(red: 0.4, green: 0.49, blue: 0.92, alpha: 1.0),
                UIColor(red: 0.46, green: 0.29, blue: 0.64, alpha: 1.0)
            ]
            
            if let gradient_lite = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors_lite.map { $0.cgColor } as CFArray,
                locations: [0.0, 1.0]
            ) {
                context_lite.cgContext.drawLinearGradient(
                    gradient_lite,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: size_lite.width, y: size_lite.height),
                    options: []
                )
            }
            
            // 绘制系统图标
            if let systemImage_lite = UIImage(systemName: iconName) {
                let iconSize_lite: CGFloat = 120
                let iconRect_lite = CGRect(
                    x: (size_lite.width - iconSize_lite) / 2,
                    y: (size_lite.height - iconSize_lite) / 2,
                    width: iconSize_lite,
                    height: iconSize_lite
                )
                
                systemImage_lite.withTintColor(.white.withAlphaComponent(0.9), renderingMode: .alwaysOriginal)
                    .draw(in: iconRect_lite)
            }
        }
    }
    
    // MARK: - 事件处理
    
    /// 处理返回操作
    /// 核心作用：返回上一页或关闭全屏
    private func handleBack_lite() {
        // 触觉反馈
        let generator_lite = UIImpactFeedbackGenerator(style: .light)
        generator_lite.impactOccurred()
        
        // 检查是否是全屏模式
        if router_lite.presentedFullScreen_lite != nil {
            router_lite.dismissFullScreen_lite()
        } else {
            router_lite.pop_lite()
        }
    }
}
