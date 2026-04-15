import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Epoch {
    case image_Epoch
    case video_Epoch
    case none_Epoch
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Epoch: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Epoch: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Epoch: "#667eea"), UIColor(hexstring_Epoch: "#764ba2")),  // 紫色
        (UIColor(hexstring_Epoch: "#f093fb"), UIColor(hexstring_Epoch: "#f5576c")),  // 粉红
        (UIColor(hexstring_Epoch: "#4facfe"), UIColor(hexstring_Epoch: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Epoch: "#43e97b"), UIColor(hexstring_Epoch: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Epoch: "#fa709a"), UIColor(hexstring_Epoch: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Epoch: [CGColor] = [
        UIColor(hexstring_Epoch: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Epoch: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Epoch: UIImageView = {
        let imageView_Epoch = UIImageView()
        imageView_Epoch.contentMode = .scaleAspectFill
        imageView_Epoch.clipsToBounds = true
        imageView_Epoch.backgroundColor = ColorConfig_Epoch.backgroundPrimary_Epoch
        imageView_Epoch.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Epoch
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.isUserInteractionEnabled = false
        return view_Epoch
    }()
    
    /// 视频播放图标
    private let playIconView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Epoch.layer.cornerRadius = 30
        view_Epoch.isHidden = true
        return view_Epoch
    }()
    
    private let playIconImageView_Epoch: UIImageView = {
        let imageView_Epoch = UIImageView()
        imageView_Epoch.image = UIImage(systemName: "play.fill")
        imageView_Epoch.tintColor = .white
        imageView_Epoch.contentMode = .scaleAspectFit
        return imageView_Epoch
    }()
    
    /// 占位符图标
    private let placeholderIconView_Epoch: UIImageView = {
        let imageView_Epoch = UIImageView()
        imageView_Epoch.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Epoch.tintColor = ColorConfig_Epoch.textPlaceholder_Epoch
        imageView_Epoch.contentMode = .scaleAspectFit
        return imageView_Epoch
    }()
    
    // MARK: - 属性
    
    private var mediaType_Epoch: MediaType_Epoch = .none_Epoch
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Epoch() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Epoch)
        addSubview(iconContainerView_Epoch)
        addSubview(placeholderIconView_Epoch)
        addSubview(playIconView_Epoch)
        playIconView_Epoch.addSubview(playIconImageView_Epoch)
        
        imageView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 直接展示 UIImage 对象（从相册选取图片后使用，无需存储路径）
    /// - Parameter image_Epoch: 要展示的图片
    func configureWithImage_Epoch(image_Epoch: UIImage) {
        mediaType_Epoch = .image_Epoch
        clearOldContent_Epoch()
        imageView_Epoch.image = image_Epoch
        placeholderIconView_Epoch.isHidden = true
        playIconView_Epoch.isHidden = true
    }

    /// 配置媒体展示
    func configure_Epoch(mediaPath_Epoch: String?, isVideo_Epoch: Bool = false) {
        guard let path_Epoch = mediaPath_Epoch, !path_Epoch.isEmpty else {
            showPlaceholder_Epoch()
            return
        }
        
        mediaType_Epoch = isVideo_Epoch ? .video_Epoch : .image_Epoch
        playIconView_Epoch.isHidden = !isVideo_Epoch
        
        loadMedia_Epoch(path_Epoch: path_Epoch, isVideo_Epoch: isVideo_Epoch)
    }
    
    /// 加载媒体
    private func loadMedia_Epoch(path_Epoch: String, isVideo_Epoch: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Epoch = UIImage(systemName: path_Epoch) {
            loadSystemIcon_Epoch(image_Epoch: systemImage_Epoch, path_Epoch: path_Epoch)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Epoch = UIImage(named: path_Epoch) {
            loadImageSuccess_Epoch(image_Epoch: assetImage_Epoch)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Epoch.hasPrefix("http://") || path_Epoch.hasPrefix("https://") {
            loadNetworkImage_Epoch(urlString_Epoch: path_Epoch)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Epoch = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Epoch = documentsPath_Epoch.appendingPathComponent(path_Epoch)
        
        if let documentImage_Epoch = UIImage(contentsOfFile: fileURL_Epoch.path) {
            loadImageSuccess_Epoch(image_Epoch: documentImage_Epoch)
            print("✅ 从文档目录加载媒体: \(path_Epoch)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Epoch = UIImage(contentsOfFile: path_Epoch) {
            loadImageSuccess_Epoch(image_Epoch: localImage_Epoch)
            return
        }

        // 6. 尝试从 Bundle 中加载视频文件并提取缩略图（mp4 / mov / m4v）
        if let videoURL_Epoch = bundleVideoURL_Epoch(named: path_Epoch) {
            mediaType_Epoch = .video_Epoch
            playIconView_Epoch.isHidden = false
            generateVideoThumbnail_Epoch(url_Epoch: videoURL_Epoch)
            return
        }

        // 7. 尝试从文档目录加载视频文件并提取缩略图
        for ext_Epoch in ["mp4", "mov", "m4v"] {
            let videoFileURL_Epoch = documentsPath_Epoch.appendingPathComponent("\(path_Epoch).\(ext_Epoch)")
            if FileManager.default.fileExists(atPath: videoFileURL_Epoch.path) {
                mediaType_Epoch = .video_Epoch
                playIconView_Epoch.isHidden = false
                generateVideoThumbnail_Epoch(url_Epoch: videoFileURL_Epoch)
                return
            }
        }
        
        // 8. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Epoch)")
        showPlaceholder_Epoch()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Epoch() {
        imageView_Epoch.image = nil
        imageView_Epoch.layer.sublayers?.removeAll()
        iconContainerView_Epoch.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Epoch(image_Epoch: UIImage, path_Epoch: String) {
        clearOldContent_Epoch()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Epoch = Self.gradientColors_Epoch[abs(path_Epoch.hashValue) % Self.gradientColors_Epoch.count]
        
        // 添加渐变背景
        let gradientColors_Epoch = [selectedGradient_Epoch.0.cgColor, selectedGradient_Epoch.1.cgColor]
        addGradientLayer_Epoch(colors_Epoch: gradientColors_Epoch)
        
        // 在独立容器上显示图标
        let iconImageView_Epoch = UIImageView(image: image_Epoch)
        iconImageView_Epoch.tintColor = .white
        iconImageView_Epoch.contentMode = .scaleAspectFit
        iconImageView_Epoch.alpha = 0.9
        iconContainerView_Epoch.addSubview(iconImageView_Epoch)
        iconImageView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Epoch.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Epoch(urlString_Epoch: String) {
        clearOldContent_Epoch()
        
        if let url_Epoch = URL(string: urlString_Epoch) {
            imageView_Epoch.kf.setImage(
                with: url_Epoch,
                placeholder: createPlaceholderImage_Epoch(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Epoch.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Epoch(image_Epoch: UIImage) {
        clearOldContent_Epoch()
        imageView_Epoch.image = image_Epoch
        placeholderIconView_Epoch.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Epoch(colors_Epoch: [CGColor]) {
        let gradientLayer_Epoch = CAGradientLayer()
        gradientLayer_Epoch.frame = bounds
        gradientLayer_Epoch.colors = colors_Epoch
        gradientLayer_Epoch.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Epoch.endPoint = CGPoint(x: 1, y: 1)
        imageView_Epoch.layer.insertSublayer(gradientLayer_Epoch, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Epoch() {
        mediaType_Epoch = .none_Epoch
        clearOldContent_Epoch()
        placeholderIconView_Epoch.isHidden = false
        playIconView_Epoch.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Epoch(colors_Epoch: Self.placeholderGradientColors_Epoch)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Epoch() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Epoch.backgroundPrimary_Epoch.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Epoch = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Epoch
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Epoch == .none_Epoch {
            imageView_Epoch.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中按名称查找视频文件（依次尝试 mp4 / mov / m4v 扩展名）
    /// - Parameter named_Epoch: 不含扩展名的资源名
    /// - Returns: 找到时返回文件 URL，否则返回 nil
    static func bundleVideoURL_Epoch(named named_Epoch: String) -> URL? {
        for ext_Epoch in ["mp4", "mov", "m4v"] {
            if let url_Epoch = Bundle.main.url(forResource: named_Epoch, withExtension: ext_Epoch) {
                return url_Epoch
            }
        }
        return nil
    }

    /// 在 Bundle 中按名称查找视频文件（实例方法，内部调用静态版本）
    private func bundleVideoURL_Epoch(named named_Epoch: String) -> URL? {
        return MediaDisplayView_Epoch.bundleVideoURL_Epoch(named: named_Epoch)
    }

    /// 从视频 URL 异步提取第一帧作为缩略图，成功后刷新 imageView
    /// - Parameter url_Epoch: 视频文件 URL
    private func generateVideoThumbnail_Epoch(url_Epoch: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset_Epoch     = AVURLAsset(url: url_Epoch)
            let generator_Epoch = AVAssetImageGenerator(asset: asset_Epoch)
            generator_Epoch.appliesPreferredTrackTransform = true
            generator_Epoch.maximumSize = CGSize(width: 600, height: 600)
            let time_Epoch = CMTime(seconds: 0.1, preferredTimescale: 600)
            do {
                let cgImage_Epoch = try generator_Epoch.copyCGImage(at: time_Epoch, actualTime: nil)
                let thumb_Epoch   = UIImage(cgImage: cgImage_Epoch)
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Epoch(image_Epoch: thumb_Epoch)
                    self?.playIconView_Epoch.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Epoch() }
            }
        }
    }
}
