import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Clara {
    case image_Clara
    case video_Clara
    case none_Clara
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Clara: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Clara: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Clara: "#667eea"), UIColor(hexstring_Clara: "#764ba2")),  // 紫色
        (UIColor(hexstring_Clara: "#f093fb"), UIColor(hexstring_Clara: "#f5576c")),  // 粉红
        (UIColor(hexstring_Clara: "#4facfe"), UIColor(hexstring_Clara: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Clara: "#43e97b"), UIColor(hexstring_Clara: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Clara: "#fa709a"), UIColor(hexstring_Clara: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Clara: [CGColor] = [
        UIColor(hexstring_Clara: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Clara: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Clara: UIImageView = {
        let imageView_Clara = UIImageView()
        imageView_Clara.contentMode = .scaleAspectFill
        imageView_Clara.clipsToBounds = true
        imageView_Clara.backgroundColor = ColorConfig_Clara.backgroundPrimary_Clara
        imageView_Clara.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Clara
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Clara: UIView = {
        let view_Clara = UIView()
        view_Clara.isUserInteractionEnabled = false
        return view_Clara
    }()
    
    /// 视频播放图标
    private let playIconView_Clara: UIView = {
        let view_Clara = UIView()
        view_Clara.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Clara.layer.cornerRadius = 30
        view_Clara.isHidden = true
        return view_Clara
    }()
    
    private let playIconImageView_Clara: UIImageView = {
        let imageView_Clara = UIImageView()
        imageView_Clara.image = UIImage(systemName: "play.fill")
        imageView_Clara.tintColor = .white
        imageView_Clara.contentMode = .scaleAspectFit
        return imageView_Clara
    }()
    
    /// 占位符图标
    private let placeholderIconView_Clara: UIImageView = {
        let imageView_Clara = UIImageView()
        imageView_Clara.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Clara.tintColor = ColorConfig_Clara.textPlaceholder_Clara
        imageView_Clara.contentMode = .scaleAspectFit
        return imageView_Clara
    }()
    
    // MARK: - 属性
    
    private var mediaType_Clara: MediaType_Clara = .none_Clara
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Clara()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Clara() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Clara)
        addSubview(iconContainerView_Clara)
        addSubview(placeholderIconView_Clara)
        addSubview(playIconView_Clara)
        playIconView_Clara.addSubview(playIconImageView_Clara)
        
        imageView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Clara.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Clara.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Clara.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 直接展示 UIImage 对象（从相册选取图片后使用，无需存储路径）
    /// - Parameter image_Clara: 要展示的图片
    func configureWithImage_Clara(image_Clara: UIImage) {
        mediaType_Clara = .image_Clara
        clearOldContent_Clara()
        imageView_Clara.image = image_Clara
        placeholderIconView_Clara.isHidden = true
        playIconView_Clara.isHidden = true
    }

    /// 配置媒体展示
    func configure_Clara(mediaPath_Clara: String?, isVideo_Clara: Bool = false) {
        guard let path_Clara = mediaPath_Clara, !path_Clara.isEmpty else {
            showPlaceholder_Clara()
            return
        }
        
        mediaType_Clara = isVideo_Clara ? .video_Clara : .image_Clara
        playIconView_Clara.isHidden = !isVideo_Clara
        
        loadMedia_Clara(path_Clara: path_Clara, isVideo_Clara: isVideo_Clara)
    }
    
    /// 加载媒体
    private func loadMedia_Clara(path_Clara: String, isVideo_Clara: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Clara = UIImage(systemName: path_Clara) {
            loadSystemIcon_Clara(image_Clara: systemImage_Clara, path_Clara: path_Clara)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Clara = UIImage(named: path_Clara) {
            loadImageSuccess_Clara(image_Clara: assetImage_Clara)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Clara.hasPrefix("http://") || path_Clara.hasPrefix("https://") {
            loadNetworkImage_Clara(urlString_Clara: path_Clara)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Clara = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Clara = documentsPath_Clara.appendingPathComponent(path_Clara)
        
        if let documentImage_Clara = UIImage(contentsOfFile: fileURL_Clara.path) {
            loadImageSuccess_Clara(image_Clara: documentImage_Clara)
            print("✅ 从文档目录加载媒体: \(path_Clara)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Clara = UIImage(contentsOfFile: path_Clara) {
            loadImageSuccess_Clara(image_Clara: localImage_Clara)
            return
        }

        // 6. 尝试从 Bundle 中加载视频文件并提取缩略图（mp4 / mov / m4v）
        if let videoURL_Clara = bundleVideoURL_Clara(named: path_Clara) {
            mediaType_Clara = .video_Clara
            playIconView_Clara.isHidden = false
            generateVideoThumbnail_Clara(url_Clara: videoURL_Clara)
            return
        }

        // 7. 尝试从文档目录加载视频文件并提取缩略图
        for ext_Clara in ["mp4", "mov", "m4v"] {
            let videoFileURL_Clara = documentsPath_Clara.appendingPathComponent("\(path_Clara).\(ext_Clara)")
            if FileManager.default.fileExists(atPath: videoFileURL_Clara.path) {
                mediaType_Clara = .video_Clara
                playIconView_Clara.isHidden = false
                generateVideoThumbnail_Clara(url_Clara: videoFileURL_Clara)
                return
            }
        }
        
        // 8. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Clara)")
        showPlaceholder_Clara()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Clara() {
        imageView_Clara.image = nil
        imageView_Clara.layer.sublayers?.removeAll()
        iconContainerView_Clara.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Clara(image_Clara: UIImage, path_Clara: String) {
        clearOldContent_Clara()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Clara = Self.gradientColors_Clara[abs(path_Clara.hashValue) % Self.gradientColors_Clara.count]
        
        // 添加渐变背景
        let gradientColors_Clara = [selectedGradient_Clara.0.cgColor, selectedGradient_Clara.1.cgColor]
        addGradientLayer_Clara(colors_Clara: gradientColors_Clara)
        
        // 在独立容器上显示图标
        let iconImageView_Clara = UIImageView(image: image_Clara)
        iconImageView_Clara.tintColor = .white
        iconImageView_Clara.contentMode = .scaleAspectFit
        iconImageView_Clara.alpha = 0.9
        iconContainerView_Clara.addSubview(iconImageView_Clara)
        iconImageView_Clara.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Clara.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Clara(urlString_Clara: String) {
        clearOldContent_Clara()
        
        if let url_Clara = URL(string: urlString_Clara) {
            imageView_Clara.kf.setImage(
                with: url_Clara,
                placeholder: createPlaceholderImage_Clara(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Clara.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Clara(image_Clara: UIImage) {
        clearOldContent_Clara()
        imageView_Clara.image = image_Clara
        placeholderIconView_Clara.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Clara(colors_Clara: [CGColor]) {
        let gradientLayer_Clara = CAGradientLayer()
        gradientLayer_Clara.frame = bounds
        gradientLayer_Clara.colors = colors_Clara
        gradientLayer_Clara.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Clara.endPoint = CGPoint(x: 1, y: 1)
        imageView_Clara.layer.insertSublayer(gradientLayer_Clara, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Clara() {
        mediaType_Clara = .none_Clara
        clearOldContent_Clara()
        placeholderIconView_Clara.isHidden = false
        playIconView_Clara.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Clara(colors_Clara: Self.placeholderGradientColors_Clara)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Clara() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Clara.backgroundPrimary_Clara.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Clara = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Clara
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Clara == .none_Clara {
            imageView_Clara.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中按名称查找视频文件（依次尝试 mp4 / mov / m4v 扩展名）
    /// - Parameter named_Clara: 不含扩展名的资源名
    /// - Returns: 找到时返回文件 URL，否则返回 nil
    static func bundleVideoURL_Clara(named named_Clara: String) -> URL? {
        for ext_Clara in ["mp4", "mov", "m4v"] {
            if let url_Clara = Bundle.main.url(forResource: named_Clara, withExtension: ext_Clara) {
                return url_Clara
            }
        }
        return nil
    }

    /// 在 Bundle 中按名称查找视频文件（实例方法，内部调用静态版本）
    private func bundleVideoURL_Clara(named named_Clara: String) -> URL? {
        return MediaDisplayView_Clara.bundleVideoURL_Clara(named: named_Clara)
    }

    /// 从视频 URL 异步提取第一帧作为缩略图，成功后刷新 imageView
    /// - Parameter url_Clara: 视频文件 URL
    private func generateVideoThumbnail_Clara(url_Clara: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset_Clara     = AVURLAsset(url: url_Clara)
            let generator_Clara = AVAssetImageGenerator(asset: asset_Clara)
            generator_Clara.appliesPreferredTrackTransform = true
            generator_Clara.maximumSize = CGSize(width: 600, height: 600)
            let time_Clara = CMTime(seconds: 0.1, preferredTimescale: 600)
            do {
                let cgImage_Clara = try generator_Clara.copyCGImage(at: time_Clara, actualTime: nil)
                let thumb_Clara   = UIImage(cgImage: cgImage_Clara)
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Clara(image_Clara: thumb_Clara)
                    self?.playIconView_Clara.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Clara() }
            }
        }
    }
}
