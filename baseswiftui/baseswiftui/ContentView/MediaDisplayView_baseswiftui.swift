import SwiftUI

// MARK: - 媒体展示组件
// 核心作用：展示图片或视频，支持多种媒体来源
// 设计思路：自动识别媒体类型，支持本地图片、Assets图片、网络图片、系统图标
// 关键特性：渐变装饰、占位符、视频播放图标、加载状态
// 优化：UI与逻辑解耦，业务逻辑统一使用工具类处理

/// 媒体展示视图
/// 用于展示各种类型的媒体内容
struct MediaDisplayView_baseswiftui: View {
    
    /// 媒体路径
    let mediaPath_baseswiftui: String?
    
    /// 是否是视频
    let isVideo_baseswiftui: Bool
    
    /// 圆角半径
    var cornerRadius_baseswiftui: CGFloat = 12
    
    /// 是否可点击
    var isClickable_baseswiftui: Bool = false
    
    /// 点击回调
    var onTapped_baseswiftui: (() -> Void)?
    
    var body: some View {
        Group {
            if isClickable_baseswiftui {
                // 可点击模式：添加点击手势
                mediaContentWrapper_baseswiftui
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onTapped_baseswiftui?()
                    }
            } else {
                // 不可点击模式：不添加手势，让事件传递给父视图
                mediaContentWrapper_baseswiftui
            }
        }
        .cornerRadius(cornerRadius_baseswiftui)
    }
    
    /// 媒体内容包装器
    @ViewBuilder
    private var mediaContentWrapper_baseswiftui: some View {
        if let path_baseswiftui = mediaPath_baseswiftui, !path_baseswiftui.isEmpty {
            mediaContent_baseswiftui(path_baseswiftui: path_baseswiftui)
        } else {
            placeholderView_baseswiftui
        }
    }
    
    // MARK: - 媒体内容视图
    
    /// 根据路径类型展示不同的媒体内容
    @ViewBuilder
    private func mediaContent_baseswiftui(path_baseswiftui: String) -> some View {
        if MediaUtils_baseswiftui.isSystemIcon_baseswiftui(name_baseswiftui: path_baseswiftui) {
            // 系统图标
            systemIconView_baseswiftui(iconName_baseswiftui: path_baseswiftui)
        } else if path_baseswiftui.hasPrefix("http://") || path_baseswiftui.hasPrefix("https://") {
            // 网络图片
            networkImageView_baseswiftui(urlString_baseswiftui: path_baseswiftui)
        } else {
            // 本地图片或 Assets 图片
            localImageView_baseswiftui(imageName_baseswiftui: path_baseswiftui)
        }
    }
    
    // MARK: - 系统图标视图
    
    /// 系统图标视图（带渐变背景）
    @ViewBuilder
    private func systemIconView_baseswiftui(iconName_baseswiftui: String) -> some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                gradient: Gradient(
                    colors: MediaConfig_baseswiftui.getGradientColors_baseswiftui(for: iconName_baseswiftui)
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 系统图标
            Image(systemName: iconName_baseswiftui)
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.9))
        }
        .overlay(
            videoPlayIcon_baseswiftui
        )
    }
    
    // MARK: - 网络图片视图
    
    /// 网络图片视图
    @ViewBuilder
    private func networkImageView_baseswiftui(urlString_baseswiftui: String) -> some View {
        if let url_baseswiftui = URL(string: urlString_baseswiftui) {
            AsyncImage(url: url_baseswiftui) { phase_baseswiftui in
                switch phase_baseswiftui {
                case .empty:
                    // 加载中
                    loadingView_baseswiftui
                    
                case .success(let image_baseswiftui):
                    // 加载成功
                    image_baseswiftui
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay(videoPlayIcon_baseswiftui)
                    
                case .failure:
                    // 加载失败
                    placeholderView_baseswiftui
                    
                @unknown default:
                    placeholderView_baseswiftui
                }
            }
        } else {
            placeholderView_baseswiftui
        }
    }
    
    // MARK: - 本地图片视图
    
    /// 本地图片视图
    /// 加载优先级：Assets -> 视频缩略图 -> 文档目录 -> 占位符
    @ViewBuilder
    private func localImageView_baseswiftui(imageName_baseswiftui: String) -> some View {
        // 1. 先尝试从 Assets 加载
        if let image_baseswiftui = UIImage(named: imageName_baseswiftui) {
            Image(uiImage: image_baseswiftui)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(videoPlayIcon_baseswiftui)
        }
        // 2. 如果是视频，尝试从 Bundle 中的视频文件生成缩略图
        else if isVideo_baseswiftui, 
                let thumbnail_baseswiftui = MediaUtils_baseswiftui.loadVideoThumbnail_baseswiftui(
                    videoName_baseswiftui: imageName_baseswiftui
                ) {
            Image(uiImage: thumbnail_baseswiftui)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(videoPlayIcon_baseswiftui)
        }
        // 3. 尝试从文档目录加载
        else if let image_baseswiftui = MediaUtils_baseswiftui.loadImageFromDocuments_baseswiftui(
            imageName_baseswiftui: imageName_baseswiftui
        ) {
            Image(uiImage: image_baseswiftui)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(videoPlayIcon_baseswiftui)
        }
        // 4. 显示占位符
        else {
            placeholderView_baseswiftui
        }
    }
    
    // MARK: - 占位符视图
    
    /// 占位符视图
    private var placeholderView_baseswiftui: some View {
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
    private var loadingView_baseswiftui: some View {
        ZStack {
            Color.gray.opacity(0.2)
            
            ProgressView()
                .scaleEffect(1.5)
        }
    }
    
    // MARK: - 视频播放图标
    
    /// 视频播放图标
    @ViewBuilder
    private var videoPlayIcon_baseswiftui: some View {
        if isVideo_baseswiftui {
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
