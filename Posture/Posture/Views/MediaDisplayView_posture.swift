import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Posture {
    case image_Posture
    case video_Posture
    case none_Posture
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Posture: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Posture: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Posture: "#667eea"), UIColor(hexstring_Posture: "#764ba2")),  // 紫色
        (UIColor(hexstring_Posture: "#f093fb"), UIColor(hexstring_Posture: "#f5576c")),  // 粉红
        (UIColor(hexstring_Posture: "#4facfe"), UIColor(hexstring_Posture: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Posture: "#43e97b"), UIColor(hexstring_Posture: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Posture: "#fa709a"), UIColor(hexstring_Posture: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Posture: [CGColor] = [
        UIColor(hexstring_Posture: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Posture: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Posture: UIImageView = {
        let imageView_Posture = UIImageView()
        imageView_Posture.contentMode = .scaleAspectFill
        imageView_Posture.clipsToBounds = true
        imageView_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        imageView_Posture.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Posture
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Posture: UIView = {
        let view_Posture = UIView()
        view_Posture.isUserInteractionEnabled = false
        return view_Posture
    }()
    
    /// 视频播放图标
    private let playIconView_Posture: UIView = {
        let view_Posture = UIView()
        view_Posture.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Posture.layer.cornerRadius = 30
        view_Posture.isHidden = true
        return view_Posture
    }()
    
    private let playIconImageView_Posture: UIImageView = {
        let imageView_Posture = UIImageView()
        imageView_Posture.image = UIImage(systemName: "play.fill")
        imageView_Posture.tintColor = .white
        imageView_Posture.contentMode = .scaleAspectFit
        return imageView_Posture
    }()
    
    /// 占位符图标
    private let placeholderIconView_Posture: UIImageView = {
        let imageView_Posture = UIImageView()
        imageView_Posture.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Posture.tintColor = ColorConfig_Posture.textPlaceholder_Posture
        imageView_Posture.contentMode = .scaleAspectFit
        return imageView_Posture
    }()
    
    // MARK: - 属性
    
    private var mediaType_Posture: MediaType_Posture = .none_Posture
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Posture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Posture() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Posture)
        addSubview(iconContainerView_Posture)
        addSubview(placeholderIconView_Posture)
        addSubview(playIconView_Posture)
        playIconView_Posture.addSubview(playIconImageView_Posture)
        
        imageView_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 直接展示 UIImage 对象（从相册选取图片后使用，无需存储路径）
    /// - Parameter image_Posture: 要展示的图片
    func configureWithImage_Posture(image_Posture: UIImage) {
        mediaType_Posture = .image_Posture
        clearOldContent_Posture()
        imageView_Posture.image = image_Posture
        placeholderIconView_Posture.isHidden = true
        playIconView_Posture.isHidden = true
    }

    /// 配置媒体展示
    func configure_Posture(mediaPath_Posture: String?, isVideo_Posture: Bool = false) {
        guard let path_Posture = mediaPath_Posture, !path_Posture.isEmpty else {
            showPlaceholder_Posture()
            return
        }
        
        mediaType_Posture = isVideo_Posture ? .video_Posture : .image_Posture
        playIconView_Posture.isHidden = !isVideo_Posture
        
        loadMedia_Posture(path_Posture: path_Posture, isVideo_Posture: isVideo_Posture)
    }
    
    /// 加载媒体
    private func loadMedia_Posture(path_Posture: String, isVideo_Posture: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Posture = UIImage(systemName: path_Posture) {
            loadSystemIcon_Posture(image_Posture: systemImage_Posture, path_Posture: path_Posture)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Posture = UIImage(named: path_Posture) {
            loadImageSuccess_Posture(image_Posture: assetImage_Posture)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Posture.hasPrefix("http://") || path_Posture.hasPrefix("https://") {
            loadNetworkImage_Posture(urlString_Posture: path_Posture)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Posture = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Posture = documentsPath_Posture.appendingPathComponent(path_Posture)
        
        if let documentImage_Posture = UIImage(contentsOfFile: fileURL_Posture.path) {
            loadImageSuccess_Posture(image_Posture: documentImage_Posture)
            print("✅ 从文档目录加载媒体: \(path_Posture)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Posture = UIImage(contentsOfFile: path_Posture) {
            loadImageSuccess_Posture(image_Posture: localImage_Posture)
            return
        }

        // 6. 尝试从 Bundle 中加载视频文件并提取缩略图（mp4 / mov / m4v）
        if let videoURL_Posture = bundleVideoURL_Posture(named: path_Posture) {
            mediaType_Posture = .video_Posture
            playIconView_Posture.isHidden = false
            generateVideoThumbnail_Posture(url_Posture: videoURL_Posture)
            return
        }

        // 7. 尝试从文档目录加载视频文件并提取缩略图
        for ext_Posture in ["mp4", "mov", "m4v"] {
            let videoFileURL_Posture = documentsPath_Posture.appendingPathComponent("\(path_Posture).\(ext_Posture)")
            if FileManager.default.fileExists(atPath: videoFileURL_Posture.path) {
                mediaType_Posture = .video_Posture
                playIconView_Posture.isHidden = false
                generateVideoThumbnail_Posture(url_Posture: videoFileURL_Posture)
                return
            }
        }
        
        // 8. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Posture)")
        showPlaceholder_Posture()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Posture() {
        imageView_Posture.image = nil
        imageView_Posture.layer.sublayers?.removeAll()
        iconContainerView_Posture.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Posture(image_Posture: UIImage, path_Posture: String) {
        clearOldContent_Posture()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Posture = Self.gradientColors_Posture[abs(path_Posture.hashValue) % Self.gradientColors_Posture.count]
        
        // 添加渐变背景
        let gradientColors_Posture = [selectedGradient_Posture.0.cgColor, selectedGradient_Posture.1.cgColor]
        addGradientLayer_Posture(colors_Posture: gradientColors_Posture)
        
        // 在独立容器上显示图标
        let iconImageView_Posture = UIImageView(image: image_Posture)
        iconImageView_Posture.tintColor = .white
        iconImageView_Posture.contentMode = .scaleAspectFit
        iconImageView_Posture.alpha = 0.9
        iconContainerView_Posture.addSubview(iconImageView_Posture)
        iconImageView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Posture.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Posture(urlString_Posture: String) {
        clearOldContent_Posture()
        
        if let url_Posture = URL(string: urlString_Posture) {
            imageView_Posture.kf.setImage(
                with: url_Posture,
                placeholder: createPlaceholderImage_Posture(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Posture.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Posture(image_Posture: UIImage) {
        clearOldContent_Posture()
        imageView_Posture.image = image_Posture
        placeholderIconView_Posture.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Posture(colors_Posture: [CGColor]) {
        let gradientLayer_Posture = CAGradientLayer()
        gradientLayer_Posture.frame = bounds
        gradientLayer_Posture.colors = colors_Posture
        gradientLayer_Posture.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Posture.endPoint = CGPoint(x: 1, y: 1)
        imageView_Posture.layer.insertSublayer(gradientLayer_Posture, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Posture() {
        mediaType_Posture = .none_Posture
        clearOldContent_Posture()
        placeholderIconView_Posture.isHidden = false
        playIconView_Posture.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Posture(colors_Posture: Self.placeholderGradientColors_Posture)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Posture() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Posture.backgroundPrimary_Posture.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Posture = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Posture
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Posture == .none_Posture {
            imageView_Posture.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中按名称查找视频文件（依次尝试 mp4 / mov / m4v 扩展名）
    /// - Parameter named_Posture: 不含扩展名的资源名
    /// - Returns: 找到时返回文件 URL，否则返回 nil
    static func bundleVideoURL_Posture(named named_Posture: String) -> URL? {
        for ext_Posture in ["mp4", "mov", "m4v"] {
            if let url_Posture = Bundle.main.url(forResource: named_Posture, withExtension: ext_Posture) {
                return url_Posture
            }
        }
        return nil
    }

    /// 在 Bundle 中按名称查找视频文件（实例方法，内部调用静态版本）
    private func bundleVideoURL_Posture(named named_Posture: String) -> URL? {
        return MediaDisplayView_Posture.bundleVideoURL_Posture(named: named_Posture)
    }

    /// 从视频 URL 异步提取第一帧作为缩略图，成功后刷新 imageView
    /// - Parameter url_Posture: 视频文件 URL
    private func generateVideoThumbnail_Posture(url_Posture: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset_Posture     = AVURLAsset(url: url_Posture)
            let generator_Posture = AVAssetImageGenerator(asset: asset_Posture)
            generator_Posture.appliesPreferredTrackTransform = true
            generator_Posture.maximumSize = CGSize(width: 600, height: 600)
            let time_Posture = CMTime(seconds: 0.1, preferredTimescale: 600)
            do {
                let cgImage_Posture = try generator_Posture.copyCGImage(at: time_Posture, actualTime: nil)
                let thumb_Posture   = UIImage(cgImage: cgImage_Posture)
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Posture(image_Posture: thumb_Posture)
                    self?.playIconView_Posture.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Posture() }
            }
        }
    }
}
