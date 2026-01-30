import SwiftUI
import AVKit

// MARK: - 媒体展示组件
// 核心作用：展示图片或视频，支持多种媒体来源
// 设计思路：自动识别媒体类型，支持本地图片、Assets图片、网络图片、系统图标
// 关键特性：渐变装饰、占位符、视频播放图标、加载状态

/// 媒体类型枚举
enum MediaType_baseswiftui {
    /// 图片
    case image_baseswiftui
    /// 视频
    case video_baseswiftui
    /// 无媒体
    case none_baseswiftui
}

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
    
    @State private var mediaType_baseswiftui: MediaType_baseswiftui = .none_baseswiftui
    
    var body: some View {
        Group {
            if let path = mediaPath_baseswiftui, !path.isEmpty {
                mediaContent_baseswiftui(path: path)
            } else {
                placeholderView_baseswiftui
            }
        }
        .cornerRadius(cornerRadius_baseswiftui)
        .onTapGesture {
            if isClickable_baseswiftui {
                onTapped_baseswiftui?()
            }
        }
    }
    
    // MARK: - 媒体内容视图
    
    /// 根据路径类型展示不同的媒体内容
    @ViewBuilder
    private func mediaContent_baseswiftui(path: String) -> some View {
        if isSystemIcon_baseswiftui(path: path) {
            // 系统图标
            systemIconView_baseswiftui(iconName: path)
        } else if path.hasPrefix("http://") || path.hasPrefix("https://") {
            // 网络图片
            networkImageView_baseswiftui(urlString: path)
        } else {
            // 本地图片或 Assets 图片
            localImageView_baseswiftui(imageName: path)
        }
    }
    
    // MARK: - 系统图标视图
    
    /// 系统图标视图（带渐变背景）
    @ViewBuilder
    private func systemIconView_baseswiftui(iconName: String) -> some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                gradient: Gradient(colors: gradientColors_baseswiftui(for: iconName)),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 系统图标
            Image(systemName: iconName)
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
    private func networkImageView_baseswiftui(urlString: String) -> some View {
        if let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    // 加载中
                    loadingView_baseswiftui
                    
                case .success(let image):
                    // 加载成功
                    image
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
    @ViewBuilder
    private func localImageView_baseswiftui(imageName: String) -> some View {
        if let image = UIImage(named: imageName) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(videoPlayIcon_baseswiftui)
        } else {
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
    
    // MARK: - 工具方法
    
    /// 判断是否是系统图标
    private func isSystemIcon_baseswiftui(path: String) -> Bool {
        return UIImage(systemName: path) != nil
    }
    
    /// 根据路径生成渐变色
    private func gradientColors_baseswiftui(for path: String) -> [Color] {
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

// MARK: - Color 扩展（支持十六进制）

extension Color {
    /// 从十六进制字符串创建颜色
    /// - Parameter hex: 十六进制字符串（如 "667eea" 或 "#667eea"）
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
