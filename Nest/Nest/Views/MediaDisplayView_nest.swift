import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Nest {
    case image_Nest
    case video_Nest
    case none_Nest
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Nest: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Nest: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Nest: "#667eea"), UIColor(hexstring_Nest: "#764ba2")),  // 紫色
        (UIColor(hexstring_Nest: "#f093fb"), UIColor(hexstring_Nest: "#f5576c")),  // 粉红
        (UIColor(hexstring_Nest: "#4facfe"), UIColor(hexstring_Nest: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Nest: "#43e97b"), UIColor(hexstring_Nest: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Nest: "#fa709a"), UIColor(hexstring_Nest: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Nest: [CGColor] = [
        UIColor(hexstring_Nest: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Nest: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Nest: UIImageView = {
        let imageView_Nest = UIImageView()
        imageView_Nest.contentMode = .scaleAspectFill
        imageView_Nest.clipsToBounds = true
        imageView_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        imageView_Nest.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Nest
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Nest: UIView = {
        let view_Nest = UIView()
        view_Nest.isUserInteractionEnabled = false
        return view_Nest
    }()
    
    /// 视频播放图标
    private let playIconView_Nest: UIView = {
        let view_Nest = UIView()
        view_Nest.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Nest.layer.cornerRadius = 30
        view_Nest.isHidden = true
        return view_Nest
    }()
    
    private let playIconImageView_Nest: UIImageView = {
        let imageView_Nest = UIImageView()
        imageView_Nest.image = UIImage(systemName: "play.fill")
        imageView_Nest.tintColor = .white
        imageView_Nest.contentMode = .scaleAspectFit
        return imageView_Nest
    }()
    
    /// 占位符图标
    private let placeholderIconView_Nest: UIImageView = {
        let imageView_Nest = UIImageView()
        imageView_Nest.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Nest.tintColor = ColorConfig_Nest.textPlaceholder_Nest
        imageView_Nest.contentMode = .scaleAspectFit
        return imageView_Nest
    }()
    
    // MARK: - 属性
    
    private var mediaType_Nest: MediaType_Nest = .none_Nest
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Nest()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Nest() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Nest)
        addSubview(iconContainerView_Nest)
        addSubview(placeholderIconView_Nest)
        addSubview(playIconView_Nest)
        playIconView_Nest.addSubview(playIconImageView_Nest)
        
        imageView_Nest.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Nest.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Nest.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Nest.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Nest.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 直接展示 UIImage 对象（从相册选取图片后使用，无需存储路径）
    /// - Parameter image_Nest: 要展示的图片
    func configureWithImage_Nest(image_Nest: UIImage) {
        mediaType_Nest = .image_Nest
        clearOldContent_Nest()
        imageView_Nest.image = image_Nest
        placeholderIconView_Nest.isHidden = true
        playIconView_Nest.isHidden = true
    }

    /// 配置媒体展示
    func configure_Nest(mediaPath_Nest: String?, isVideo_Nest: Bool = false) {
        guard let path_Nest = mediaPath_Nest, !path_Nest.isEmpty else {
            showPlaceholder_Nest()
            return
        }
        
        mediaType_Nest = isVideo_Nest ? .video_Nest : .image_Nest
        playIconView_Nest.isHidden = !isVideo_Nest
        
        loadMedia_Nest(path_Nest: path_Nest, isVideo_Nest: isVideo_Nest)
    }
    
    /// 加载媒体
    private func loadMedia_Nest(path_Nest: String, isVideo_Nest: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Nest = UIImage(systemName: path_Nest) {
            loadSystemIcon_Nest(image_Nest: systemImage_Nest, path_Nest: path_Nest)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Nest = UIImage(named: path_Nest) {
            loadImageSuccess_Nest(image_Nest: assetImage_Nest)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Nest.hasPrefix("http://") || path_Nest.hasPrefix("https://") {
            loadNetworkImage_Nest(urlString_Nest: path_Nest)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Nest = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Nest = documentsPath_Nest.appendingPathComponent(path_Nest)
        
        if let documentImage_Nest = UIImage(contentsOfFile: fileURL_Nest.path) {
            loadImageSuccess_Nest(image_Nest: documentImage_Nest)
            print("✅ 从文档目录加载媒体: \(path_Nest)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Nest = UIImage(contentsOfFile: path_Nest) {
            loadImageSuccess_Nest(image_Nest: localImage_Nest)
            return
        }

        // 6. 尝试从 Bundle 中加载视频文件并提取缩略图（mp4 / mov / m4v）
        if let videoURL_Nest = bundleVideoURL_Nest(named: path_Nest) {
            mediaType_Nest = .video_Nest
            playIconView_Nest.isHidden = false
            generateVideoThumbnail_Nest(url_Nest: videoURL_Nest)
            return
        }

        // 7. 尝试从文档目录加载视频文件并提取缩略图
        for ext_Nest in ["mp4", "mov", "m4v"] {
            let videoFileURL_Nest = documentsPath_Nest.appendingPathComponent("\(path_Nest).\(ext_Nest)")
            if FileManager.default.fileExists(atPath: videoFileURL_Nest.path) {
                mediaType_Nest = .video_Nest
                playIconView_Nest.isHidden = false
                generateVideoThumbnail_Nest(url_Nest: videoFileURL_Nest)
                return
            }
        }
        
        // 8. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Nest)")
        showPlaceholder_Nest()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Nest() {
        imageView_Nest.image = nil
        imageView_Nest.layer.sublayers?.removeAll()
        iconContainerView_Nest.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Nest(image_Nest: UIImage, path_Nest: String) {
        clearOldContent_Nest()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Nest = Self.gradientColors_Nest[abs(path_Nest.hashValue) % Self.gradientColors_Nest.count]
        
        // 添加渐变背景
        let gradientColors_Nest = [selectedGradient_Nest.0.cgColor, selectedGradient_Nest.1.cgColor]
        addGradientLayer_Nest(colors_Nest: gradientColors_Nest)
        
        // 在独立容器上显示图标
        let iconImageView_Nest = UIImageView(image: image_Nest)
        iconImageView_Nest.tintColor = .white
        iconImageView_Nest.contentMode = .scaleAspectFit
        iconImageView_Nest.alpha = 0.9
        iconContainerView_Nest.addSubview(iconImageView_Nest)
        iconImageView_Nest.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Nest.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Nest(urlString_Nest: String) {
        clearOldContent_Nest()
        
        if let url_Nest = URL(string: urlString_Nest) {
            imageView_Nest.kf.setImage(
                with: url_Nest,
                placeholder: createPlaceholderImage_Nest(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Nest.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Nest(image_Nest: UIImage) {
        clearOldContent_Nest()
        imageView_Nest.image = image_Nest
        placeholderIconView_Nest.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Nest(colors_Nest: [CGColor]) {
        let gradientLayer_Nest = CAGradientLayer()
        gradientLayer_Nest.frame = bounds
        gradientLayer_Nest.colors = colors_Nest
        gradientLayer_Nest.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Nest.endPoint = CGPoint(x: 1, y: 1)
        imageView_Nest.layer.insertSublayer(gradientLayer_Nest, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Nest() {
        mediaType_Nest = .none_Nest
        clearOldContent_Nest()
        placeholderIconView_Nest.isHidden = false
        playIconView_Nest.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Nest(colors_Nest: Self.placeholderGradientColors_Nest)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Nest() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Nest.backgroundPrimary_Nest.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Nest = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Nest
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Nest == .none_Nest {
            imageView_Nest.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中按名称查找视频文件（依次尝试 mp4 / mov / m4v 扩展名）
    /// - Parameter named_Nest: 不含扩展名的资源名
    /// - Returns: 找到时返回文件 URL，否则返回 nil
    static func bundleVideoURL_Nest(named named_Nest: String) -> URL? {
        for ext_Nest in ["mp4", "mov", "m4v"] {
            if let url_Nest = Bundle.main.url(forResource: named_Nest, withExtension: ext_Nest) {
                return url_Nest
            }
        }
        return nil
    }

    /// 在 Bundle 中按名称查找视频文件（实例方法，内部调用静态版本）
    private func bundleVideoURL_Nest(named named_Nest: String) -> URL? {
        return MediaDisplayView_Nest.bundleVideoURL_Nest(named: named_Nest)
    }

    /// 从视频 URL 异步提取第一帧作为缩略图，成功后刷新 imageView
    /// - Parameter url_Nest: 视频文件 URL
    private func generateVideoThumbnail_Nest(url_Nest: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset_Nest     = AVURLAsset(url: url_Nest)
            let generator_Nest = AVAssetImageGenerator(asset: asset_Nest)
            generator_Nest.appliesPreferredTrackTransform = true
            generator_Nest.maximumSize = CGSize(width: 600, height: 600)
            let time_Nest = CMTime(seconds: 0.1, preferredTimescale: 600)
            do {
                let cgImage_Nest = try generator_Nest.copyCGImage(at: time_Nest, actualTime: nil)
                let thumb_Nest   = UIImage(cgImage: cgImage_Nest)
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Nest(image_Nest: thumb_Nest)
                    self?.playIconView_Nest.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Nest() }
            }
        }
    }
}
