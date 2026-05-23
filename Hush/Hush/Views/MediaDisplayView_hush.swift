import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Hush {
    case image_Hush
    case video_Hush
    case none_Hush
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Hush: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Hush: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Hush: "#667eea"), UIColor(hexstring_Hush: "#764ba2")),  // 紫色
        (UIColor(hexstring_Hush: "#f093fb"), UIColor(hexstring_Hush: "#f5576c")),  // 粉红
        (UIColor(hexstring_Hush: "#4facfe"), UIColor(hexstring_Hush: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Hush: "#43e97b"), UIColor(hexstring_Hush: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Hush: "#fa709a"), UIColor(hexstring_Hush: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Hush: [CGColor] = [
        UIColor(hexstring_Hush: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Hush: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Hush: UIImageView = {
        let imageView_Hush = UIImageView()
        imageView_Hush.contentMode = .scaleAspectFill
        imageView_Hush.clipsToBounds = true
        imageView_Hush.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        imageView_Hush.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Hush
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.isUserInteractionEnabled = false
        return view_Hush
    }()
    
    /// 视频播放图标
    private let playIconView_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Hush.layer.cornerRadius = 30
        view_Hush.isHidden = true
        return view_Hush
    }()
    
    private let playIconImageView_Hush: UIImageView = {
        let imageView_Hush = UIImageView()
        imageView_Hush.image = UIImage(systemName: "play.fill")
        imageView_Hush.tintColor = .white
        imageView_Hush.contentMode = .scaleAspectFit
        return imageView_Hush
    }()
    
    /// 占位符图标
    private let placeholderIconView_Hush: UIImageView = {
        let imageView_Hush = UIImageView()
        imageView_Hush.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Hush.tintColor = ColorConfig_Hush.textPlaceholder_Hush
        imageView_Hush.contentMode = .scaleAspectFit
        return imageView_Hush
    }()
    
    // MARK: - 属性
    
    private var mediaType_Hush: MediaType_Hush = .none_Hush
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Hush()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Hush() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Hush)
        addSubview(iconContainerView_Hush)
        addSubview(placeholderIconView_Hush)
        addSubview(playIconView_Hush)
        playIconView_Hush.addSubview(playIconImageView_Hush)
        
        imageView_Hush.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Hush.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 直接展示 UIImage 对象（从相册选取图片后使用，无需存储路径）
    /// - Parameter image_Hush: 要展示的图片
    func configureWithImage_Hush(image_Hush: UIImage) {
        mediaType_Hush = .image_Hush
        clearOldContent_Hush()
        imageView_Hush.image = image_Hush
        placeholderIconView_Hush.isHidden = true
        playIconView_Hush.isHidden = true
    }

    /// 配置媒体展示
    func configure_Hush(mediaPath_Hush: String?, isVideo_Hush: Bool = false) {
        guard let path_Hush = mediaPath_Hush, !path_Hush.isEmpty else {
            showPlaceholder_Hush()
            return
        }
        
        mediaType_Hush = isVideo_Hush ? .video_Hush : .image_Hush
        playIconView_Hush.isHidden = !isVideo_Hush
        
        loadMedia_Hush(path_Hush: path_Hush, isVideo_Hush: isVideo_Hush)
    }
    
    /// 加载媒体
    private func loadMedia_Hush(path_Hush: String, isVideo_Hush: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Hush = UIImage(systemName: path_Hush) {
            loadSystemIcon_Hush(image_Hush: systemImage_Hush, path_Hush: path_Hush)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Hush = UIImage(named: path_Hush) {
            loadImageSuccess_Hush(image_Hush: assetImage_Hush)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Hush.hasPrefix("http://") || path_Hush.hasPrefix("https://") {
            loadNetworkImage_Hush(urlString_Hush: path_Hush)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Hush = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Hush = documentsPath_Hush.appendingPathComponent(path_Hush)
        
        if let documentImage_Hush = UIImage(contentsOfFile: fileURL_Hush.path) {
            loadImageSuccess_Hush(image_Hush: documentImage_Hush)
            print("✅ 从文档目录加载媒体: \(path_Hush)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Hush = UIImage(contentsOfFile: path_Hush) {
            loadImageSuccess_Hush(image_Hush: localImage_Hush)
            return
        }

        // 6. 尝试从 Bundle 中加载视频文件并提取缩略图（mp4 / mov / m4v）
        if let videoURL_Hush = bundleVideoURL_Hush(named: path_Hush) {
            mediaType_Hush = .video_Hush
            playIconView_Hush.isHidden = false
            generateVideoThumbnail_Hush(url_Hush: videoURL_Hush)
            return
        }

        // 7. 尝试从文档目录加载视频文件并提取缩略图
        for ext_Hush in ["mp4", "mov", "m4v"] {
            let videoFileURL_Hush = documentsPath_Hush.appendingPathComponent("\(path_Hush).\(ext_Hush)")
            if FileManager.default.fileExists(atPath: videoFileURL_Hush.path) {
                mediaType_Hush = .video_Hush
                playIconView_Hush.isHidden = false
                generateVideoThumbnail_Hush(url_Hush: videoFileURL_Hush)
                return
            }
        }
        
        // 8. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Hush)")
        showPlaceholder_Hush()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Hush() {
        imageView_Hush.image = nil
        imageView_Hush.layer.sublayers?.removeAll()
        iconContainerView_Hush.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Hush(image_Hush: UIImage, path_Hush: String) {
        clearOldContent_Hush()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Hush = Self.gradientColors_Hush[abs(path_Hush.hashValue) % Self.gradientColors_Hush.count]
        
        // 添加渐变背景
        let gradientColors_Hush = [selectedGradient_Hush.0.cgColor, selectedGradient_Hush.1.cgColor]
        addGradientLayer_Hush(colors_Hush: gradientColors_Hush)
        
        // 在独立容器上显示图标
        let iconImageView_Hush = UIImageView(image: image_Hush)
        iconImageView_Hush.tintColor = .white
        iconImageView_Hush.contentMode = .scaleAspectFit
        iconImageView_Hush.alpha = 0.9
        iconContainerView_Hush.addSubview(iconImageView_Hush)
        iconImageView_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Hush.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Hush(urlString_Hush: String) {
        clearOldContent_Hush()
        
        if let url_Hush = URL(string: urlString_Hush) {
            imageView_Hush.kf.setImage(
                with: url_Hush,
                placeholder: createPlaceholderImage_Hush(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Hush.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Hush(image_Hush: UIImage) {
        clearOldContent_Hush()
        imageView_Hush.image = image_Hush
        placeholderIconView_Hush.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Hush(colors_Hush: [CGColor]) {
        let gradientLayer_Hush = CAGradientLayer()
        gradientLayer_Hush.frame = bounds
        gradientLayer_Hush.colors = colors_Hush
        gradientLayer_Hush.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Hush.endPoint = CGPoint(x: 1, y: 1)
        imageView_Hush.layer.insertSublayer(gradientLayer_Hush, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Hush() {
        mediaType_Hush = .none_Hush
        clearOldContent_Hush()
        placeholderIconView_Hush.isHidden = false
        playIconView_Hush.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Hush(colors_Hush: Self.placeholderGradientColors_Hush)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Hush() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Hush.backgroundPrimary_Hush.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Hush = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Hush
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Hush == .none_Hush {
            imageView_Hush.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中按名称查找视频文件（依次尝试 mp4 / mov / m4v 扩展名）
    /// - Parameter named_Hush: 不含扩展名的资源名
    /// - Returns: 找到时返回文件 URL，否则返回 nil
    static func bundleVideoURL_Hush(named named_Hush: String) -> URL? {
        for ext_Hush in ["mp4", "mov", "m4v"] {
            if let url_Hush = Bundle.main.url(forResource: named_Hush, withExtension: ext_Hush) {
                return url_Hush
            }
        }
        return nil
    }

    /// 在 Bundle 中按名称查找视频文件（实例方法，内部调用静态版本）
    private func bundleVideoURL_Hush(named named_Hush: String) -> URL? {
        return MediaDisplayView_Hush.bundleVideoURL_Hush(named: named_Hush)
    }

    /// 从视频 URL 异步提取第一帧作为缩略图，成功后刷新 imageView
    /// - Parameter url_Hush: 视频文件 URL
    private func generateVideoThumbnail_Hush(url_Hush: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset_Hush     = AVURLAsset(url: url_Hush)
            let generator_Hush = AVAssetImageGenerator(asset: asset_Hush)
            generator_Hush.appliesPreferredTrackTransform = true
            generator_Hush.maximumSize = CGSize(width: 600, height: 600)
            let time_Hush = CMTime(seconds: 0.1, preferredTimescale: 600)
            do {
                let cgImage_Hush = try generator_Hush.copyCGImage(at: time_Hush, actualTime: nil)
                let thumb_Hush   = UIImage(cgImage: cgImage_Hush)
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Hush(image_Hush: thumb_Hush)
                    self?.playIconView_Hush.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Hush() }
            }
        }
    }
}
