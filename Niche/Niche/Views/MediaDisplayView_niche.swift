import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Niche {
    case image_Niche
    case video_Niche
    case none_Niche
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Niche: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Niche: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Niche: "#667eea"), UIColor(hexstring_Niche: "#764ba2")),  // 紫色
        (UIColor(hexstring_Niche: "#f093fb"), UIColor(hexstring_Niche: "#f5576c")),  // 粉红
        (UIColor(hexstring_Niche: "#4facfe"), UIColor(hexstring_Niche: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Niche: "#43e97b"), UIColor(hexstring_Niche: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Niche: "#fa709a"), UIColor(hexstring_Niche: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Niche: [CGColor] = [
        UIColor(hexstring_Niche: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Niche: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Niche: UIImageView = {
        let imageView_Niche = UIImageView()
        imageView_Niche.contentMode = .scaleAspectFill
        imageView_Niche.clipsToBounds = true
        imageView_Niche.backgroundColor = ColorConfig_Niche.backgroundPrimary_Niche
        imageView_Niche.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Niche
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Niche: UIView = {
        let view_Niche = UIView()
        view_Niche.isUserInteractionEnabled = false
        return view_Niche
    }()
    
    /// 视频播放图标
    private let playIconView_Niche: UIView = {
        let view_Niche = UIView()
        view_Niche.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Niche.layer.cornerRadius = 30
        view_Niche.isHidden = true
        return view_Niche
    }()
    
    private let playIconImageView_Niche: UIImageView = {
        let imageView_Niche = UIImageView()
        imageView_Niche.image = UIImage(systemName: "play.fill")
        imageView_Niche.tintColor = .white
        imageView_Niche.contentMode = .scaleAspectFit
        return imageView_Niche
    }()
    
    /// 占位符图标
    private let placeholderIconView_Niche: UIImageView = {
        let imageView_Niche = UIImageView()
        imageView_Niche.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Niche.tintColor = ColorConfig_Niche.textPlaceholder_Niche
        imageView_Niche.contentMode = .scaleAspectFit
        return imageView_Niche
    }()
    
    // MARK: - 属性
    
    private var mediaType_Niche: MediaType_Niche = .none_Niche
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Niche()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Niche() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Niche)
        addSubview(iconContainerView_Niche)
        addSubview(placeholderIconView_Niche)
        addSubview(playIconView_Niche)
        playIconView_Niche.addSubview(playIconImageView_Niche)
        
        imageView_Niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 直接展示 UIImage 对象（从相册选取图片后使用，无需存储路径）
    /// - Parameter image_Niche: 要展示的图片
    func configureWithImage_Niche(image_Niche: UIImage) {
        mediaType_Niche = .image_Niche
        clearOldContent_Niche()
        imageView_Niche.image = image_Niche
        placeholderIconView_Niche.isHidden = true
        playIconView_Niche.isHidden = true
    }

    /// 配置媒体展示
    func configure_Niche(mediaPath_Niche: String?, isVideo_Niche: Bool = false) {
        guard let path_Niche = mediaPath_Niche, !path_Niche.isEmpty else {
            showPlaceholder_Niche()
            return
        }
        
        mediaType_Niche = isVideo_Niche ? .video_Niche : .image_Niche
        playIconView_Niche.isHidden = !isVideo_Niche
        
        loadMedia_Niche(path_Niche: path_Niche, isVideo_Niche: isVideo_Niche)
    }
    
    /// 加载媒体
    private func loadMedia_Niche(path_Niche: String, isVideo_Niche: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Niche = UIImage(systemName: path_Niche) {
            loadSystemIcon_Niche(image_Niche: systemImage_Niche, path_Niche: path_Niche)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Niche = UIImage(named: path_Niche) {
            loadImageSuccess_Niche(image_Niche: assetImage_Niche)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Niche.hasPrefix("http://") || path_Niche.hasPrefix("https://") {
            loadNetworkImage_Niche(urlString_Niche: path_Niche)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Niche = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Niche = documentsPath_Niche.appendingPathComponent(path_Niche)
        
        if let documentImage_Niche = UIImage(contentsOfFile: fileURL_Niche.path) {
            loadImageSuccess_Niche(image_Niche: documentImage_Niche)
            print("✅ 从文档目录加载媒体: \(path_Niche)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Niche = UIImage(contentsOfFile: path_Niche) {
            loadImageSuccess_Niche(image_Niche: localImage_Niche)
            return
        }

        // 6. 尝试从 Bundle 中加载视频文件并提取缩略图（mp4 / mov / m4v）
        if let videoURL_Niche = bundleVideoURL_Niche(named: path_Niche) {
            mediaType_Niche = .video_Niche
            playIconView_Niche.isHidden = false
            generateVideoThumbnail_Niche(url_Niche: videoURL_Niche)
            return
        }

        // 7. 尝试从文档目录加载视频文件并提取缩略图
        for ext_Niche in ["mp4", "mov", "m4v"] {
            let videoFileURL_Niche = documentsPath_Niche.appendingPathComponent("\(path_Niche).\(ext_Niche)")
            if FileManager.default.fileExists(atPath: videoFileURL_Niche.path) {
                mediaType_Niche = .video_Niche
                playIconView_Niche.isHidden = false
                generateVideoThumbnail_Niche(url_Niche: videoFileURL_Niche)
                return
            }
        }
        
        // 8. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Niche)")
        showPlaceholder_Niche()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Niche() {
        imageView_Niche.image = nil
        imageView_Niche.layer.sublayers?.removeAll()
        iconContainerView_Niche.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Niche(image_Niche: UIImage, path_Niche: String) {
        clearOldContent_Niche()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Niche = Self.gradientColors_Niche[abs(path_Niche.hashValue) % Self.gradientColors_Niche.count]
        
        // 添加渐变背景
        let gradientColors_Niche = [selectedGradient_Niche.0.cgColor, selectedGradient_Niche.1.cgColor]
        addGradientLayer_Niche(colors_Niche: gradientColors_Niche)
        
        // 在独立容器上显示图标
        let iconImageView_Niche = UIImageView(image: image_Niche)
        iconImageView_Niche.tintColor = .white
        iconImageView_Niche.contentMode = .scaleAspectFit
        iconImageView_Niche.alpha = 0.9
        iconContainerView_Niche.addSubview(iconImageView_Niche)
        iconImageView_Niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Niche.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Niche(urlString_Niche: String) {
        clearOldContent_Niche()
        
        if let url_Niche = URL(string: urlString_Niche) {
            imageView_Niche.kf.setImage(
                with: url_Niche,
                placeholder: createPlaceholderImage_Niche(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Niche.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Niche(image_Niche: UIImage) {
        clearOldContent_Niche()
        imageView_Niche.image = image_Niche
        placeholderIconView_Niche.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Niche(colors_Niche: [CGColor]) {
        let gradientLayer_Niche = CAGradientLayer()
        gradientLayer_Niche.frame = bounds
        gradientLayer_Niche.colors = colors_Niche
        gradientLayer_Niche.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Niche.endPoint = CGPoint(x: 1, y: 1)
        imageView_Niche.layer.insertSublayer(gradientLayer_Niche, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Niche() {
        mediaType_Niche = .none_Niche
        clearOldContent_Niche()
        placeholderIconView_Niche.isHidden = false
        playIconView_Niche.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Niche(colors_Niche: Self.placeholderGradientColors_Niche)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Niche() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Niche.backgroundPrimary_Niche.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Niche = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Niche
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Niche == .none_Niche {
            imageView_Niche.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中按名称查找视频文件（依次尝试 mp4 / mov / m4v 扩展名）
    /// - Parameter named_Niche: 不含扩展名的资源名
    /// - Returns: 找到时返回文件 URL，否则返回 nil
    static func bundleVideoURL_Niche(named named_Niche: String) -> URL? {
        for ext_Niche in ["mp4", "mov", "m4v"] {
            if let url_Niche = Bundle.main.url(forResource: named_Niche, withExtension: ext_Niche) {
                return url_Niche
            }
        }
        return nil
    }

    /// 在 Bundle 中按名称查找视频文件（实例方法，内部调用静态版本）
    private func bundleVideoURL_Niche(named named_Niche: String) -> URL? {
        return MediaDisplayView_Niche.bundleVideoURL_Niche(named: named_Niche)
    }

    /// 从视频 URL 异步提取第一帧作为缩略图，成功后刷新 imageView
    /// - Parameter url_Niche: 视频文件 URL
    private func generateVideoThumbnail_Niche(url_Niche: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset_Niche     = AVURLAsset(url: url_Niche)
            let generator_Niche = AVAssetImageGenerator(asset: asset_Niche)
            generator_Niche.appliesPreferredTrackTransform = true
            generator_Niche.maximumSize = CGSize(width: 600, height: 600)
            let time_Niche = CMTime(seconds: 0.1, preferredTimescale: 600)
            do {
                let cgImage_Niche = try generator_Niche.copyCGImage(at: time_Niche, actualTime: nil)
                let thumb_Niche   = UIImage(cgImage: cgImage_Niche)
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Niche(image_Niche: thumb_Niche)
                    self?.playIconView_Niche.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Niche() }
            }
        }
    }
}
