import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Ornit {
    case image_Ornit
    case video_Ornit
    case none_Ornit
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Ornit: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Ornit: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Ornit: "#667eea"), UIColor(hexstring_Ornit: "#764ba2")),  // 紫色
        (UIColor(hexstring_Ornit: "#f093fb"), UIColor(hexstring_Ornit: "#f5576c")),  // 粉红
        (UIColor(hexstring_Ornit: "#4facfe"), UIColor(hexstring_Ornit: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Ornit: "#43e97b"), UIColor(hexstring_Ornit: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Ornit: "#fa709a"), UIColor(hexstring_Ornit: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Ornit: [CGColor] = [
        UIColor(hexstring_Ornit: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Ornit: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Ornit: UIImageView = {
        let imageView_Ornit = UIImageView()
        imageView_Ornit.contentMode = .scaleAspectFill
        imageView_Ornit.clipsToBounds = true
        imageView_Ornit.backgroundColor = ColorConfig_Ornit.backgroundPrimary_Ornit
        imageView_Ornit.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Ornit
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Ornit: UIView = {
        let view_Ornit = UIView()
        view_Ornit.isUserInteractionEnabled = false
        return view_Ornit
    }()
    
    /// 视频播放图标
    private let playIconView_Ornit: UIView = {
        let view_Ornit = UIView()
        view_Ornit.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Ornit.layer.cornerRadius = 30
        view_Ornit.isHidden = true
        return view_Ornit
    }()
    
    private let playIconImageView_Ornit: UIImageView = {
        let imageView_Ornit = UIImageView()
        imageView_Ornit.image = UIImage(systemName: "play.fill")
        imageView_Ornit.tintColor = .white
        imageView_Ornit.contentMode = .scaleAspectFit
        return imageView_Ornit
    }()
    
    /// 占位符图标
    private let placeholderIconView_Ornit: UIImageView = {
        let imageView_Ornit = UIImageView()
        imageView_Ornit.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Ornit.tintColor = ColorConfig_Ornit.textPlaceholder_Ornit
        imageView_Ornit.contentMode = .scaleAspectFit
        return imageView_Ornit
    }()
    
    // MARK: - 属性
    
    private var mediaType_Ornit: MediaType_Ornit = .none_Ornit
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Ornit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Ornit() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Ornit)
        addSubview(iconContainerView_Ornit)
        addSubview(placeholderIconView_Ornit)
        addSubview(playIconView_Ornit)
        playIconView_Ornit.addSubview(playIconImageView_Ornit)
        
        imageView_Ornit.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Ornit.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Ornit.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Ornit.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Ornit.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 直接展示 UIImage 对象（从相册选取图片后使用，无需存储路径）
    /// - Parameter image_Ornit: 要展示的图片
    func configureWithImage_Ornit(image_Ornit: UIImage) {
        mediaType_Ornit = .image_Ornit
        clearOldContent_Ornit()
        imageView_Ornit.image = image_Ornit
        placeholderIconView_Ornit.isHidden = true
        playIconView_Ornit.isHidden = true
    }

    /// 配置媒体展示
    func configure_Ornit(mediaPath_Ornit: String?, isVideo_Ornit: Bool = false) {
        guard let path_Ornit = mediaPath_Ornit, !path_Ornit.isEmpty else {
            showPlaceholder_Ornit()
            return
        }
        
        mediaType_Ornit = isVideo_Ornit ? .video_Ornit : .image_Ornit
        playIconView_Ornit.isHidden = !isVideo_Ornit
        
        loadMedia_Ornit(path_Ornit: path_Ornit, isVideo_Ornit: isVideo_Ornit)
    }
    
    /// 加载媒体
    private func loadMedia_Ornit(path_Ornit: String, isVideo_Ornit: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Ornit = UIImage(systemName: path_Ornit) {
            loadSystemIcon_Ornit(image_Ornit: systemImage_Ornit, path_Ornit: path_Ornit)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Ornit = UIImage(named: path_Ornit) {
            loadImageSuccess_Ornit(image_Ornit: assetImage_Ornit)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Ornit.hasPrefix("http://") || path_Ornit.hasPrefix("https://") {
            loadNetworkImage_Ornit(urlString_Ornit: path_Ornit)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Ornit = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Ornit = documentsPath_Ornit.appendingPathComponent(path_Ornit)
        
        if let documentImage_Ornit = UIImage(contentsOfFile: fileURL_Ornit.path) {
            loadImageSuccess_Ornit(image_Ornit: documentImage_Ornit)
            print("✅ 从文档目录加载媒体: \(path_Ornit)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Ornit = UIImage(contentsOfFile: path_Ornit) {
            loadImageSuccess_Ornit(image_Ornit: localImage_Ornit)
            return
        }

        // 6. 尝试从 Bundle 中加载视频文件并提取缩略图（mp4 / mov / m4v）
        if let videoURL_Ornit = bundleVideoURL_Ornit(named: path_Ornit) {
            mediaType_Ornit = .video_Ornit
            playIconView_Ornit.isHidden = false
            generateVideoThumbnail_Ornit(url_Ornit: videoURL_Ornit)
            return
        }

        // 7. 尝试从文档目录加载视频文件并提取缩略图
        for ext_Ornit in ["mp4", "mov", "m4v"] {
            let videoFileURL_Ornit = documentsPath_Ornit.appendingPathComponent("\(path_Ornit).\(ext_Ornit)")
            if FileManager.default.fileExists(atPath: videoFileURL_Ornit.path) {
                mediaType_Ornit = .video_Ornit
                playIconView_Ornit.isHidden = false
                generateVideoThumbnail_Ornit(url_Ornit: videoFileURL_Ornit)
                return
            }
        }
        
        // 8. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Ornit)")
        showPlaceholder_Ornit()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Ornit() {
        imageView_Ornit.image = nil
        imageView_Ornit.layer.sublayers?.removeAll()
        iconContainerView_Ornit.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Ornit(image_Ornit: UIImage, path_Ornit: String) {
        clearOldContent_Ornit()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Ornit = Self.gradientColors_Ornit[abs(path_Ornit.hashValue) % Self.gradientColors_Ornit.count]
        
        // 添加渐变背景
        let gradientColors_Ornit = [selectedGradient_Ornit.0.cgColor, selectedGradient_Ornit.1.cgColor]
        addGradientLayer_Ornit(colors_Ornit: gradientColors_Ornit)
        
        // 在独立容器上显示图标
        let iconImageView_Ornit = UIImageView(image: image_Ornit)
        iconImageView_Ornit.tintColor = .white
        iconImageView_Ornit.contentMode = .scaleAspectFit
        iconImageView_Ornit.alpha = 0.9
        iconContainerView_Ornit.addSubview(iconImageView_Ornit)
        iconImageView_Ornit.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Ornit.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Ornit(urlString_Ornit: String) {
        clearOldContent_Ornit()
        
        if let url_Ornit = URL(string: urlString_Ornit) {
            imageView_Ornit.kf.setImage(
                with: url_Ornit,
                placeholder: createPlaceholderImage_Ornit(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Ornit.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Ornit(image_Ornit: UIImage) {
        clearOldContent_Ornit()
        imageView_Ornit.image = image_Ornit
        placeholderIconView_Ornit.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Ornit(colors_Ornit: [CGColor]) {
        let gradientLayer_Ornit = CAGradientLayer()
        gradientLayer_Ornit.frame = bounds
        gradientLayer_Ornit.colors = colors_Ornit
        gradientLayer_Ornit.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Ornit.endPoint = CGPoint(x: 1, y: 1)
        imageView_Ornit.layer.insertSublayer(gradientLayer_Ornit, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Ornit() {
        mediaType_Ornit = .none_Ornit
        clearOldContent_Ornit()
        placeholderIconView_Ornit.isHidden = false
        playIconView_Ornit.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Ornit(colors_Ornit: Self.placeholderGradientColors_Ornit)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Ornit() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Ornit.backgroundPrimary_Ornit.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Ornit = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Ornit
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Ornit == .none_Ornit {
            imageView_Ornit.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中按名称查找视频文件（依次尝试 mp4 / mov / m4v 扩展名）
    /// - Parameter named_Ornit: 不含扩展名的资源名
    /// - Returns: 找到时返回文件 URL，否则返回 nil
    static func bundleVideoURL_Ornit(named named_Ornit: String) -> URL? {
        for ext_Ornit in ["mp4", "mov", "m4v"] {
            if let url_Ornit = Bundle.main.url(forResource: named_Ornit, withExtension: ext_Ornit) {
                return url_Ornit
            }
        }
        return nil
    }

    /// 在 Bundle 中按名称查找视频文件（实例方法，内部调用静态版本）
    private func bundleVideoURL_Ornit(named named_Ornit: String) -> URL? {
        return MediaDisplayView_Ornit.bundleVideoURL_Ornit(named: named_Ornit)
    }

    /// 从视频 URL 异步提取第一帧作为缩略图，成功后刷新 imageView
    /// - Parameter url_Ornit: 视频文件 URL
    private func generateVideoThumbnail_Ornit(url_Ornit: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset_Ornit     = AVURLAsset(url: url_Ornit)
            let generator_Ornit = AVAssetImageGenerator(asset: asset_Ornit)
            generator_Ornit.appliesPreferredTrackTransform = true
            generator_Ornit.maximumSize = CGSize(width: 600, height: 600)
            let time_Ornit = CMTime(seconds: 0.1, preferredTimescale: 600)
            do {
                let cgImage_Ornit = try generator_Ornit.copyCGImage(at: time_Ornit, actualTime: nil)
                let thumb_Ornit   = UIImage(cgImage: cgImage_Ornit)
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Ornit(image_Ornit: thumb_Ornit)
                    self?.playIconView_Ornit.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Ornit() }
            }
        }
    }
}
