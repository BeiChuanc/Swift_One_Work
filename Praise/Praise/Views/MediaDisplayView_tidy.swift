import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Tidy {
    case image_Tidy
    case video_Tidy
    case none_Tidy
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Tidy: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Tidy: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Tidy: "#667eea"), UIColor(hexstring_Tidy: "#764ba2")),  // 紫色
        (UIColor(hexstring_Tidy: "#f093fb"), UIColor(hexstring_Tidy: "#f5576c")),  // 粉红
        (UIColor(hexstring_Tidy: "#4facfe"), UIColor(hexstring_Tidy: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Tidy: "#43e97b"), UIColor(hexstring_Tidy: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Tidy: "#fa709a"), UIColor(hexstring_Tidy: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Tidy: [CGColor] = [
        UIColor(hexstring_Tidy: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Tidy: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Tidy: UIImageView = {
        let imageView_Tidy = UIImageView()
        imageView_Tidy.contentMode = .scaleAspectFill
        imageView_Tidy.clipsToBounds = true
        imageView_Tidy.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        imageView_Tidy.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Tidy
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Tidy: UIView = {
        let view_Tidy = UIView()
        view_Tidy.isUserInteractionEnabled = false
        return view_Tidy
    }()
    
    /// 视频播放图标
    private let playIconView_Tidy: UIView = {
        let view_Tidy = UIView()
        view_Tidy.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Tidy.layer.cornerRadius = 30
        view_Tidy.isHidden = true
        return view_Tidy
    }()
    
    private let playIconImageView_Tidy: UIImageView = {
        let imageView_Tidy = UIImageView()
        imageView_Tidy.image = UIImage(systemName: "play.fill")
        imageView_Tidy.tintColor = .white
        imageView_Tidy.contentMode = .scaleAspectFit
        return imageView_Tidy
    }()
    
    /// 占位符图标
    private let placeholderIconView_Tidy: UIImageView = {
        let imageView_Tidy = UIImageView()
        imageView_Tidy.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Tidy.tintColor = ColorConfig_Tidy.textPlaceholder_Tidy
        imageView_Tidy.contentMode = .scaleAspectFit
        return imageView_Tidy
    }()
    
    // MARK: - 属性
    
    private var mediaType_Tidy: MediaType_Tidy = .none_Tidy
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Tidy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Tidy() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Tidy)
        addSubview(iconContainerView_Tidy)
        addSubview(placeholderIconView_Tidy)
        addSubview(playIconView_Tidy)
        playIconView_Tidy.addSubview(playIconImageView_Tidy)
        
        imageView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 直接展示 UIImage 对象（从相册选取图片后使用，无需存储路径）
    /// - Parameter image_Tidy: 要展示的图片
    func configureWithImage_Tidy(image_Tidy: UIImage) {
        mediaType_Tidy = .image_Tidy
        clearOldContent_Tidy()
        imageView_Tidy.image = image_Tidy
        placeholderIconView_Tidy.isHidden = true
        playIconView_Tidy.isHidden = true
    }

    /// 配置媒体展示
    func configure_Tidy(mediaPath_Tidy: String?, isVideo_Tidy: Bool = false) {
        guard let path_Tidy = mediaPath_Tidy, !path_Tidy.isEmpty else {
            showPlaceholder_Tidy()
            return
        }
        
        mediaType_Tidy = isVideo_Tidy ? .video_Tidy : .image_Tidy
        playIconView_Tidy.isHidden = !isVideo_Tidy
        
        loadMedia_Tidy(path_Tidy: path_Tidy, isVideo_Tidy: isVideo_Tidy)
    }
    
    /// 加载媒体
    private func loadMedia_Tidy(path_Tidy: String, isVideo_Tidy: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Tidy = UIImage(systemName: path_Tidy) {
            loadSystemIcon_Tidy(image_Tidy: systemImage_Tidy, path_Tidy: path_Tidy)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Tidy = UIImage(named: path_Tidy) {
            loadImageSuccess_Tidy(image_Tidy: assetImage_Tidy)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Tidy.hasPrefix("http://") || path_Tidy.hasPrefix("https://") {
            loadNetworkImage_Tidy(urlString_Tidy: path_Tidy)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Tidy = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Tidy = documentsPath_Tidy.appendingPathComponent(path_Tidy)
        
        if let documentImage_Tidy = UIImage(contentsOfFile: fileURL_Tidy.path) {
            loadImageSuccess_Tidy(image_Tidy: documentImage_Tidy)
            print("✅ 从文档目录加载媒体: \(path_Tidy)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Tidy = UIImage(contentsOfFile: path_Tidy) {
            loadImageSuccess_Tidy(image_Tidy: localImage_Tidy)
            return
        }

        // 6. 尝试从 Bundle 中加载视频文件并提取缩略图（mp4 / mov / m4v）
        if let videoURL_Tidy = bundleVideoURL_Tidy(named: path_Tidy) {
            mediaType_Tidy = .video_Tidy
            playIconView_Tidy.isHidden = false
            generateVideoThumbnail_Tidy(url_Tidy: videoURL_Tidy)
            return
        }

        // 7. 尝试从文档目录加载视频文件并提取缩略图
        for ext_Tidy in ["mp4", "mov", "m4v"] {
            let videoFileURL_Tidy = documentsPath_Tidy.appendingPathComponent("\(path_Tidy).\(ext_Tidy)")
            if FileManager.default.fileExists(atPath: videoFileURL_Tidy.path) {
                mediaType_Tidy = .video_Tidy
                playIconView_Tidy.isHidden = false
                generateVideoThumbnail_Tidy(url_Tidy: videoFileURL_Tidy)
                return
            }
        }
        
        // 8. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Tidy)")
        showPlaceholder_Tidy()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Tidy() {
        imageView_Tidy.image = nil
        imageView_Tidy.layer.sublayers?.removeAll()
        iconContainerView_Tidy.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Tidy(image_Tidy: UIImage, path_Tidy: String) {
        clearOldContent_Tidy()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Tidy = Self.gradientColors_Tidy[abs(path_Tidy.hashValue) % Self.gradientColors_Tidy.count]
        
        // 添加渐变背景
        let gradientColors_Tidy = [selectedGradient_Tidy.0.cgColor, selectedGradient_Tidy.1.cgColor]
        addGradientLayer_Tidy(colors_Tidy: gradientColors_Tidy)
        
        // 在独立容器上显示图标
        let iconImageView_Tidy = UIImageView(image: image_Tidy)
        iconImageView_Tidy.tintColor = .white
        iconImageView_Tidy.contentMode = .scaleAspectFit
        iconImageView_Tidy.alpha = 0.9
        iconContainerView_Tidy.addSubview(iconImageView_Tidy)
        iconImageView_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Tidy.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Tidy(urlString_Tidy: String) {
        clearOldContent_Tidy()
        
        if let url_Tidy = URL(string: urlString_Tidy) {
            imageView_Tidy.kf.setImage(
                with: url_Tidy,
                placeholder: createPlaceholderImage_Tidy(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Tidy.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Tidy(image_Tidy: UIImage) {
        clearOldContent_Tidy()
        imageView_Tidy.image = image_Tidy
        placeholderIconView_Tidy.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Tidy(colors_Tidy: [CGColor]) {
        let gradientLayer_Tidy = CAGradientLayer()
        gradientLayer_Tidy.frame = bounds
        gradientLayer_Tidy.colors = colors_Tidy
        gradientLayer_Tidy.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Tidy.endPoint = CGPoint(x: 1, y: 1)
        imageView_Tidy.layer.insertSublayer(gradientLayer_Tidy, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Tidy() {
        mediaType_Tidy = .none_Tidy
        clearOldContent_Tidy()
        placeholderIconView_Tidy.isHidden = false
        playIconView_Tidy.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Tidy(colors_Tidy: Self.placeholderGradientColors_Tidy)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Tidy() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Tidy.backgroundPrimary_Tidy.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Tidy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Tidy
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Tidy == .none_Tidy {
            imageView_Tidy.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中按名称查找视频文件（依次尝试 mp4 / mov / m4v 扩展名）
    /// - Parameter named_Tidy: 不含扩展名的资源名
    /// - Returns: 找到时返回文件 URL，否则返回 nil
    static func bundleVideoURL_Tidy(named named_Tidy: String) -> URL? {
        for ext_Tidy in ["mp4", "mov", "m4v"] {
            if let url_Tidy = Bundle.main.url(forResource: named_Tidy, withExtension: ext_Tidy) {
                return url_Tidy
            }
        }
        return nil
    }

    /// 在 Bundle 中按名称查找视频文件（实例方法，内部调用静态版本）
    private func bundleVideoURL_Tidy(named named_Tidy: String) -> URL? {
        return MediaDisplayView_Tidy.bundleVideoURL_Tidy(named: named_Tidy)
    }

    /// 从视频 URL 异步提取第一帧作为缩略图，成功后刷新 imageView
    /// - Parameter url_Tidy: 视频文件 URL
    private func generateVideoThumbnail_Tidy(url_Tidy: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset_Tidy     = AVURLAsset(url: url_Tidy)
            let generator_Tidy = AVAssetImageGenerator(asset: asset_Tidy)
            generator_Tidy.appliesPreferredTrackTransform = true
            generator_Tidy.maximumSize = CGSize(width: 600, height: 600)
            let time_Tidy = CMTime(seconds: 0.1, preferredTimescale: 600)
            do {
                let cgImage_Tidy = try generator_Tidy.copyCGImage(at: time_Tidy, actualTime: nil)
                let thumb_Tidy   = UIImage(cgImage: cgImage_Tidy)
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Tidy(image_Tidy: thumb_Tidy)
                    self?.playIconView_Tidy.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Tidy() }
            }
        }
    }
}
