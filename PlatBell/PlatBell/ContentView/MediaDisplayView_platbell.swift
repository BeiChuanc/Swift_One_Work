import SwiftUI

// MARK: - 媒体展示组件
// 核心作用：展示图片或视频，支持多种媒体来源
// 设计思路：自动识别媒体类型，支持本地图片、Assets图片、网络图片、系统图标
// 关键特性：渐变装饰、占位符、视频播放图标、加载状态
// 优化：UI与逻辑解耦，业务逻辑统一使用工具类处理

/// 媒体展示视图
/// 用于展示各种类型的媒体内容
struct MediaDisplayView_platbell: View {
    
    /// 媒体路径
    let mediaPath_platbell: String?
    
    /// 是否是视频
    let isVideo_platbell: Bool
    
    /// 圆角半径
    var cornerRadius_platbell: CGFloat = 12
    
    /// 是否可点击
    var isClickable_platbell: Bool = false
    
    /// 点击回调
    var onTapped_platbell: (() -> Void)?
    
    var body: some View {
        Group {
            if isClickable_platbell {
                // 可点击模式：添加点击手势
                mediaContentWrapper_platbell
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onTapped_platbell?()
                    }
            } else {
                // 不可点击模式：不添加手势，让事件传递给父视图
                mediaContentWrapper_platbell
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius_platbell))
    }
    
    /// 媒体内容包装器
    @ViewBuilder
    private var mediaContentWrapper_platbell: some View {
        if let path_platbell = mediaPath_platbell, !path_platbell.isEmpty {
            mediaContent_platbell(path_platbell: path_platbell)
        } else {
            placeholderView_platbell
        }
    }
    
    // MARK: - 媒体内容视图
    
    /// 根据路径类型展示不同的媒体内容
    @ViewBuilder
    private func mediaContent_platbell(path_platbell: String) -> some View {
        if MediaUtils_platbell.isSystemIcon_platbell(name_platbell: path_platbell) {
            // 系统图标
            systemIconView_platbell(iconName_platbell: path_platbell)
        } else if path_platbell.hasPrefix("http://") || path_platbell.hasPrefix("https://") {
            // 网络图片
            networkImageView_platbell(urlString_platbell: path_platbell)
        } else {
            // 本地图片或 Assets 图片
            localImageView_platbell(imageName_platbell: path_platbell)
        }
    }
    
    // MARK: - 系统图标视图
    
    /// 系统图标视图（带渐变背景）
    @ViewBuilder
    private func systemIconView_platbell(iconName_platbell: String) -> some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                gradient: Gradient(
                    colors: MediaConfig_platbell.getGradientColors_platbell(for: iconName_platbell)
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 系统图标
            Image(systemName: iconName_platbell)
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.9))
        }
        .overlay(
            videoPlayIcon_platbell
        )
    }
    
    // MARK: - 网络图片视图
    
    /// 网络图片视图
    @ViewBuilder
    private func networkImageView_platbell(urlString_platbell: String) -> some View {
        if let url_platbell = URL(string: urlString_platbell) {
            AsyncImage(url: url_platbell) { phase_platbell in
                switch phase_platbell {
                case .empty:
                    // 加载中
                    loadingView_platbell
                    
                case .success(let image_platbell):
                    // 加载成功
                    image_platbell
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay(videoPlayIcon_platbell)
                    
                case .failure:
                    // 加载失败
                    placeholderView_platbell
                    
                @unknown default:
                    placeholderView_platbell
                }
            }
        } else {
            placeholderView_platbell
        }
    }
    
    // MARK: - 本地图片视图
    
    /// 本地图片视图
    /// 加载优先级：Assets -> 视频缩略图 -> 文档目录 -> 占位符
    @ViewBuilder
    private func localImageView_platbell(imageName_platbell: String) -> some View {
        // 1. 先尝试从 Assets 加载
        if let image_platbell = UIImage(named: imageName_platbell) {
            Image(uiImage: image_platbell)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(videoPlayIcon_platbell)
        }
        // 2. 如果是视频，尝试从 Bundle 中的视频文件生成缩略图
        else if isVideo_platbell, 
                let thumbnail_platbell = MediaUtils_platbell.loadVideoThumbnail_platbell(
                    videoName_platbell: imageName_platbell
                ) {
            Image(uiImage: thumbnail_platbell)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(videoPlayIcon_platbell)
        }
        // 3. 尝试从文档目录加载
        else if let image_platbell = MediaUtils_platbell.loadImageFromDocuments_platbell(
            imageName_platbell: imageName_platbell
        ) {
            Image(uiImage: image_platbell)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(videoPlayIcon_platbell)
        }
        // 4. 显示占位符
        else {
            placeholderView_platbell
        }
    }
    
    // MARK: - 占位符视图
    
    /// 占位符视图
    private var placeholderView_platbell: some View {
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
    private var loadingView_platbell: some View {
        ZStack {
            Color.gray.opacity(0.2)
            
            ProgressView()
                .scaleEffect(1.5)
        }
    }
    
    // MARK: - 视频播放图标
    
    /// 视频播放图标
    @ViewBuilder
    private var videoPlayIcon_platbell: some View {
        if isVideo_platbell {
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
