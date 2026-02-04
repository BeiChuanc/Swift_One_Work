import SwiftUI
import AVKit

// MARK: - 媒体展示组件
// 核心作用：展示图片或视频，支持多种媒体来源
// 设计思路：自动识别媒体类型，支持本地图片、Assets图片、网络图片、系统图标
// 关键特性：渐变装饰、占位符、视频播放图标、加载状态

/// 媒体类型枚举
enum MediaType_blisslink {
    /// 图片
    case image_blisslink
    /// 视频
    case video_blisslink
    /// 无媒体
    case none_blisslink
}

/// 媒体展示视图
/// 用于展示各种类型的媒体内容
struct MediaDisplayView_blisslink: View {
    
    /// 媒体路径
    let mediaPath_blisslink: String?
    
    /// 是否是视频
    let isVideo_blisslink: Bool
    
    /// 圆角半径
    var cornerRadius_blisslink: CGFloat = 12
    
    /// 是否可点击
    var isClickable_blisslink: Bool = false
    
    /// 点击回调
    var onTapped_blisslink: (() -> Void)?
    
    @State private var mediaType_blisslink: MediaType_blisslink = .none_blisslink
    
    var body: some View {
        Group {
            if isClickable_blisslink {
                // 可点击模式：添加点击手势
                mediaContentWrapper_blisslink
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onTapped_blisslink?()
                    }
            } else {
                // 不可点击模式：不添加手势，让事件传递给父视图
                mediaContentWrapper_blisslink
            }
        }
        .cornerRadius(cornerRadius_blisslink)
    }
    
    /// 媒体内容包装器
    @ViewBuilder
    private var mediaContentWrapper_blisslink: some View {
        if let path = mediaPath_blisslink, !path.isEmpty {
            mediaContent_blisslink(path: path)
        } else {
            placeholderView_blisslink
        }
    }
    
    // MARK: - 媒体内容视图
    
    /// 根据路径类型展示不同的媒体内容
    @ViewBuilder
    private func mediaContent_blisslink(path: String) -> some View {
        if isSystemIcon_blisslink(path: path) {
            // 系统图标
            systemIconView_blisslink(iconName: path)
        } else if path.hasPrefix("http://") || path.hasPrefix("https://") {
            // 网络图片
            networkImageView_blisslink(urlString: path)
        } else {
            // 本地图片或 Assets 图片
            localImageView_blisslink(imageName: path)
        }
    }
    
    // MARK: - 系统图标视图
    
    /// 系统图标视图（带渐变背景）
    @ViewBuilder
    private func systemIconView_blisslink(iconName: String) -> some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                gradient: Gradient(colors: gradientColors_blisslink(for: iconName)),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 系统图标
            Image(systemName: iconName)
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.9))
        }
        .overlay(
            videoPlayIcon_blisslink
        )
    }
    
    // MARK: - 网络图片视图
    
    /// 网络图片视图
    @ViewBuilder
    private func networkImageView_blisslink(urlString: String) -> some View {
        if let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    // 加载中
                    loadingView_blisslink
                    
                case .success(let image):
                    // 加载成功
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay(videoPlayIcon_blisslink)
                    
                case .failure:
                    // 加载失败
                    placeholderView_blisslink
                    
                @unknown default:
                    placeholderView_blisslink
                }
            }
        } else {
            placeholderView_blisslink
        }
    }
    
    // MARK: - 本地图片视图
    
    /// 本地图片视图
    @ViewBuilder
    private func localImageView_blisslink(imageName: String) -> some View {
        // 1. 先尝试从 Assets 加载
        if let image = UIImage(named: imageName) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(videoPlayIcon_blisslink)
        } 
        // 2. 如果是视频，尝试从 Bundle 中的视频文件生成缩略图
        else if isVideo_blisslink, let thumbnail = loadVideoThumbnail_blisslink(videoName: imageName) {
            Image(uiImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(videoPlayIcon_blisslink)
        }
        // 3. 尝试从文档目录加载
        else if let image = loadImageFromDocuments_blisslink(imageName: imageName) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(videoPlayIcon_blisslink)
        }
        // 4. 显示占位符
        else {
            placeholderView_blisslink
        }
    }
    
    /// 从文档目录加载图片
    /// - Parameter imageName: 图片名称（可能带或不带扩展名）
    /// - Returns: UIImage 或 nil
    private func loadImageFromDocuments_blisslink(imageName: String) -> UIImage? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        // 尝试带 .jpg 扩展名
        var fileURL = documentsDirectory.appendingPathComponent("\(imageName).jpg")
        if let image = UIImage(contentsOfFile: fileURL.path) {
            print("✅ 从文档目录加载图片：\(imageName).jpg")
            return image
        }
        
        // 尝试不带扩展名（文件名本身可能已包含扩展名）
        fileURL = documentsDirectory.appendingPathComponent(imageName)
        if let image = UIImage(contentsOfFile: fileURL.path) {
            print("✅ 从文档目录加载图片：\(imageName)")
            return image
        }
        
        print("⚠️ 无法从文档目录加载图片：\(imageName)")
        return nil
    }
    
    /// 从Bundle中的视频文件生成缩略图
    /// 核心作用：为项目中的视频资源（如media_one.mp4）生成预览缩略图
    /// - Parameter videoName: 视频文件名（不带扩展名或带.mp4扩展名）
    /// - Returns: UIImage 或 nil
    private func loadVideoThumbnail_blisslink(videoName: String) -> UIImage? {
        // 1. 处理文件名，确保有.mp4扩展名
        let fileName_blisslink: String
        if videoName.hasSuffix(".mp4") {
            fileName_blisslink = videoName
        } else {
            fileName_blisslink = "\(videoName).mp4"
        }
        
        // 2. 从主Bundle中查找视频文件
        guard let videoPath_blisslink = Bundle.main.path(forResource: fileName_blisslink.replacingOccurrences(of: ".mp4", with: ""), ofType: "mp4") else {
            print("⚠️ 无法在Bundle中找到视频文件：\(fileName_blisslink)")
            return nil
        }
        
        let videoURL_blisslink = URL(fileURLWithPath: videoPath_blisslink)
        
        // 3. 使用AVAssetImageGenerator生成缩略图
        let asset_blisslink = AVAsset(url: videoURL_blisslink)
        let imageGenerator_blisslink = AVAssetImageGenerator(asset: asset_blisslink)
        imageGenerator_blisslink.appliesPreferredTrackTransform = true  // 保持视频方向
        
        // 设置生成缩略图的时间点（视频开始后1秒）
        let time_blisslink = CMTime(seconds: 1.0, preferredTimescale: 600)
        
        do {
            let cgImage_blisslink = try imageGenerator_blisslink.copyCGImage(at: time_blisslink, actualTime: nil)
            let thumbnail_blisslink = UIImage(cgImage: cgImage_blisslink)
            print("✅ 成功从Bundle视频生成缩略图：\(fileName_blisslink)")
            return thumbnail_blisslink
        } catch {
            print("❌ 生成视频缩略图失败：\(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - 占位符视图
    
    /// 占位符视图
    private var placeholderView_blisslink: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.2),
                    Color.purple.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 占位符图标
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))
        }
    }
    
    // MARK: - 加载中视图
    
    /// 加载中视图
    private var loadingView_blisslink: some View {
        ZStack {
            Color.gray.opacity(0.2)
            
            ProgressView()
                .scaleEffect(1.5)
        }
    }
    
    // MARK: - 视频播放图标
    
    /// 视频播放图标
    @ViewBuilder
    private var videoPlayIcon_blisslink: some View {
        if isVideo_blisslink {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.6))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "play.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - 工具方法
    
    /// 判断是否是系统图标
    private func isSystemIcon_blisslink(path: String) -> Bool {
        return UIImage(systemName: path) != nil
    }
    
    /// 根据路径生成渐变色
    private func gradientColors_blisslink(for path: String) -> [Color] {
        let gradients: [[Color]] = [
            [Color(hex: "667eea"), Color(hex: "764ba2")],  // 紫色
            [Color(hex: "f093fb"), Color(hex: "f5576c")],  // 粉红
            [Color(hex: "4facfe"), Color(hex: "00f2fe")],  // 蓝色
            [Color(hex: "43e97b"), Color(hex: "38f9d7")],  // 绿色
            [Color(hex: "fa709a"), Color(hex: "fee140")]   // 暖色
        ]
        
        let index = abs(path.hashValue) % gradients.count
        return gradients[index]
    }
}
