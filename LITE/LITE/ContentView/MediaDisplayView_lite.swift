import SwiftUI

// MARK: - 媒体展示组件
// 核心作用：展示图片或视频，支持多种媒体来源
// 设计思路：自动识别媒体类型，支持本地图片、Assets图片、网络图片、系统图标
// 关键特性：渐变装饰、占位符、视频播放图标、加载状态
// 优化：UI与逻辑解耦，业务逻辑统一使用工具类处理

/// 媒体展示视图
/// 用于展示各种类型的媒体内容
struct MediaDisplayView_lite: View {
    
    /// 媒体路径
    let mediaPath_lite: String?
    
    /// 是否是视频
    let isVideo_lite: Bool
    
    /// 圆角半径
    var cornerRadius_lite: CGFloat = 12
    
    /// 是否可点击
    var isClickable_lite: Bool = false
    
    /// 点击回调
    var onTapped_lite: (() -> Void)?
    
    var body: some View {
        Group {
            if isClickable_lite {
                // 可点击模式：添加点击手势
                mediaContentWrapper_lite
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onTapped_lite?()
                    }
            } else {
                // 不可点击模式：不添加手势，让事件传递给父视图
                mediaContentWrapper_lite
            }
        }
        .cornerRadius(cornerRadius_lite)
    }
    
    /// 媒体内容包装器
    @ViewBuilder
    private var mediaContentWrapper_lite: some View {
        if let path_lite = mediaPath_lite, !path_lite.isEmpty {
            mediaContent_lite(path_lite: path_lite)
        } else {
            placeholderView_lite
        }
    }
    
    // MARK: - 媒体内容视图
    
    /// 根据路径类型展示不同的媒体内容
    @ViewBuilder
    private func mediaContent_lite(path_lite: String) -> some View {
        if MediaUtils_lite.isSystemIcon_lite(name_lite: path_lite) {
            // 系统图标
            systemIconView_lite(iconName_lite: path_lite)
        } else if path_lite.hasPrefix("http://") || path_lite.hasPrefix("https://") {
            // 网络图片
            networkImageView_lite(urlString_lite: path_lite)
        } else {
            // 本地图片或 Assets 图片
            localImageView_lite(imageName_lite: path_lite)
        }
    }
    
    // MARK: - 系统图标视图
    
    /// 系统图标视图（带渐变背景）
    @ViewBuilder
    private func systemIconView_lite(iconName_lite: String) -> some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                gradient: Gradient(
                    colors: MediaConfig_lite.getGradientColors_lite(for: iconName_lite)
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 系统图标
            Image(systemName: iconName_lite)
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.9))
        }
        .overlay(
            videoPlayIcon_lite
        )
    }
    
    // MARK: - 网络图片视图
    
    /// 网络图片视图
    @ViewBuilder
    private func networkImageView_lite(urlString_lite: String) -> some View {
        if let url_lite = URL(string: urlString_lite) {
            AsyncImage(url: url_lite) { phase_lite in
                switch phase_lite {
                case .empty:
                    // 加载中
                    loadingView_lite
                    
                case .success(let image_lite):
                    // 加载成功
                    image_lite
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay(videoPlayIcon_lite)
                    
                case .failure:
                    // 加载失败
                    placeholderView_lite
                    
                @unknown default:
                    placeholderView_lite
                }
            }
        } else {
            placeholderView_lite
        }
    }
    
    // MARK: - 本地图片视图
    
    /// 本地图片视图
    /// 加载优先级：Assets -> 视频缩略图 -> 文档目录 -> 占位符
    @ViewBuilder
    private func localImageView_lite(imageName_lite: String) -> some View {
        // 1. 先尝试从 Assets 加载
        if let image_lite = UIImage(named: imageName_lite) {
            Image(uiImage: image_lite)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(videoPlayIcon_lite)
        }
        // 2. 如果是视频，尝试从 Bundle 中的视频文件生成缩略图
        else if isVideo_lite, 
                let thumbnail_lite = MediaUtils_lite.loadVideoThumbnail_lite(
                    videoName_lite: imageName_lite
                ) {
            Image(uiImage: thumbnail_lite)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(videoPlayIcon_lite)
        }
        // 3. 尝试从文档目录加载
        else if let image_lite = MediaUtils_lite.loadImageFromDocuments_lite(
            imageName_lite: imageName_lite
        ) {
            Image(uiImage: image_lite)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(videoPlayIcon_lite)
        }
        // 4. 显示占位符
        else {
            placeholderView_lite
        }
    }
    
    // MARK: - 占位符视图
    
    /// 占位符视图
    private var placeholderView_lite: some View {
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
    private var loadingView_lite: some View {
        ZStack {
            Color.gray.opacity(0.2)
            
            ProgressView()
                .scaleEffect(1.5)
        }
    }
    
    // MARK: - 视频播放图标
    
    /// 视频播放图标
    @ViewBuilder
    private var videoPlayIcon_lite: some View {
        if isVideo_lite {
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
    
}
