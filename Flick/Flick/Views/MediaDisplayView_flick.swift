import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Flick {
    case image_Flick
    case video_Flick
    case none_Flick
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Flick: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Flick: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Flick: "#667eea"), UIColor(hexstring_Flick: "#764ba2")),  // 紫色
        (UIColor(hexstring_Flick: "#f093fb"), UIColor(hexstring_Flick: "#f5576c")),  // 粉红
        (UIColor(hexstring_Flick: "#4facfe"), UIColor(hexstring_Flick: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Flick: "#43e97b"), UIColor(hexstring_Flick: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Flick: "#fa709a"), UIColor(hexstring_Flick: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Flick: [CGColor] = [
        UIColor(hexstring_Flick: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Flick: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Flick: UIImageView = {
        let imageView_Flick = UIImageView()
        imageView_Flick.contentMode = .scaleAspectFill
        imageView_Flick.clipsToBounds = true
        imageView_Flick.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
        imageView_Flick.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Flick
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Flick: UIView = {
        let view_Flick = UIView()
        view_Flick.isUserInteractionEnabled = false
        return view_Flick
    }()
    
    /// 视频播放图标
    private let playIconView_Flick: UIView = {
        let view_Flick = UIView()
        view_Flick.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Flick.layer.cornerRadius = 30
        view_Flick.isHidden = true
        return view_Flick
    }()
    
    private let playIconImageView_Flick: UIImageView = {
        let imageView_Flick = UIImageView()
        imageView_Flick.image = UIImage(systemName: "play.fill")
        imageView_Flick.tintColor = .white
        imageView_Flick.contentMode = .scaleAspectFit
        return imageView_Flick
    }()
    
    /// 占位符图标
    private let placeholderIconView_Flick: UIImageView = {
        let imageView_Flick = UIImageView()
        imageView_Flick.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Flick.tintColor = ColorConfig_Flick.textPlaceholder_Flick
        imageView_Flick.contentMode = .scaleAspectFit
        return imageView_Flick
    }()
    
    // MARK: - 属性
    
    private var mediaType_Flick: MediaType_Flick = .none_Flick
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Flick()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Flick() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Flick)
        addSubview(iconContainerView_Flick)
        addSubview(placeholderIconView_Flick)
        addSubview(playIconView_Flick)
        playIconView_Flick.addSubview(playIconImageView_Flick)
        
        imageView_Flick.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Flick.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Flick.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Flick.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Flick.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 直接展示 UIImage 对象（从相册选取图片后使用，无需存储路径）
    /// - Parameter image_Flick: 要展示的图片
    func configureWithImage_Flick(image_Flick: UIImage) {
        mediaType_Flick = .image_Flick
        clearOldContent_Flick()
        imageView_Flick.image = image_Flick
        placeholderIconView_Flick.isHidden = true
        playIconView_Flick.isHidden = true
    }

    /// 配置媒体展示
    func configure_Flick(mediaPath_Flick: String?, isVideo_Flick: Bool = false) {
        guard let path_Flick = mediaPath_Flick, !path_Flick.isEmpty else {
            showPlaceholder_Flick()
            return
        }
        
        mediaType_Flick = isVideo_Flick ? .video_Flick : .image_Flick
        playIconView_Flick.isHidden = !isVideo_Flick
        
        loadMedia_Flick(path_Flick: path_Flick, isVideo_Flick: isVideo_Flick)
    }
    
    /// 加载媒体
    private func loadMedia_Flick(path_Flick: String, isVideo_Flick: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Flick = UIImage(systemName: path_Flick) {
            loadSystemIcon_Flick(image_Flick: systemImage_Flick, path_Flick: path_Flick)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Flick = UIImage(named: path_Flick) {
            loadImageSuccess_Flick(image_Flick: assetImage_Flick)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Flick.hasPrefix("http://") || path_Flick.hasPrefix("https://") {
            loadNetworkImage_Flick(urlString_Flick: path_Flick)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Flick = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Flick = documentsPath_Flick.appendingPathComponent(path_Flick)
        
        if let documentImage_Flick = UIImage(contentsOfFile: fileURL_Flick.path) {
            loadImageSuccess_Flick(image_Flick: documentImage_Flick)
            print("✅ 从文档目录加载媒体: \(path_Flick)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Flick = UIImage(contentsOfFile: path_Flick) {
            loadImageSuccess_Flick(image_Flick: localImage_Flick)
            return
        }

        // 6. 尝试从 Bundle 中加载视频文件并提取缩略图（mp4 / mov / m4v）
        if let videoURL_Flick = bundleVideoURL_Flick(named: path_Flick) {
            mediaType_Flick = .video_Flick
            playIconView_Flick.isHidden = false
            generateVideoThumbnail_Flick(url_Flick: videoURL_Flick)
            return
        }

        // 7. 尝试从文档目录加载视频文件并提取缩略图
        for ext_Flick in ["mp4", "mov", "m4v"] {
            let videoFileURL_Flick = documentsPath_Flick.appendingPathComponent("\(path_Flick).\(ext_Flick)")
            if FileManager.default.fileExists(atPath: videoFileURL_Flick.path) {
                mediaType_Flick = .video_Flick
                playIconView_Flick.isHidden = false
                generateVideoThumbnail_Flick(url_Flick: videoFileURL_Flick)
                return
            }
        }
        
        // 8. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Flick)")
        showPlaceholder_Flick()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Flick() {
        imageView_Flick.image = nil
        imageView_Flick.layer.sublayers?.removeAll()
        iconContainerView_Flick.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Flick(image_Flick: UIImage, path_Flick: String) {
        clearOldContent_Flick()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Flick = Self.gradientColors_Flick[abs(path_Flick.hashValue) % Self.gradientColors_Flick.count]
        
        // 添加渐变背景
        let gradientColors_Flick = [selectedGradient_Flick.0.cgColor, selectedGradient_Flick.1.cgColor]
        addGradientLayer_Flick(colors_Flick: gradientColors_Flick)
        
        // 在独立容器上显示图标
        let iconImageView_Flick = UIImageView(image: image_Flick)
        iconImageView_Flick.tintColor = .white
        iconImageView_Flick.contentMode = .scaleAspectFit
        iconImageView_Flick.alpha = 0.9
        iconContainerView_Flick.addSubview(iconImageView_Flick)
        iconImageView_Flick.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Flick.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Flick(urlString_Flick: String) {
        clearOldContent_Flick()
        
        if let url_Flick = URL(string: urlString_Flick) {
            imageView_Flick.kf.setImage(
                with: url_Flick,
                placeholder: createPlaceholderImage_Flick(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Flick.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Flick(image_Flick: UIImage) {
        clearOldContent_Flick()
        imageView_Flick.image = image_Flick
        placeholderIconView_Flick.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Flick(colors_Flick: [CGColor]) {
        let gradientLayer_Flick = CAGradientLayer()
        gradientLayer_Flick.frame = bounds
        gradientLayer_Flick.colors = colors_Flick
        gradientLayer_Flick.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Flick.endPoint = CGPoint(x: 1, y: 1)
        imageView_Flick.layer.insertSublayer(gradientLayer_Flick, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Flick() {
        mediaType_Flick = .none_Flick
        clearOldContent_Flick()
        placeholderIconView_Flick.isHidden = false
        playIconView_Flick.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Flick(colors_Flick: Self.placeholderGradientColors_Flick)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Flick() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Flick.backgroundPrimary_Flick.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Flick = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Flick
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Flick == .none_Flick {
            imageView_Flick.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中按名称查找视频文件（依次尝试 mp4 / mov / m4v 扩展名）
    /// - Parameter named_Flick: 不含扩展名的资源名
    /// - Returns: 找到时返回文件 URL，否则返回 nil
    static func bundleVideoURL_Flick(named named_Flick: String) -> URL? {
        for ext_Flick in ["mp4", "mov", "m4v"] {
            if let url_Flick = Bundle.main.url(forResource: named_Flick, withExtension: ext_Flick) {
                return url_Flick
            }
        }
        return nil
    }

    /// 在 Bundle 中按名称查找视频文件（实例方法，内部调用静态版本）
    private func bundleVideoURL_Flick(named named_Flick: String) -> URL? {
        return MediaDisplayView_Flick.bundleVideoURL_Flick(named: named_Flick)
    }

    /// 从视频 URL 异步提取第一帧作为缩略图，成功后刷新 imageView
    /// - Parameter url_Flick: 视频文件 URL
    private func generateVideoThumbnail_Flick(url_Flick: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset_Flick     = AVURLAsset(url: url_Flick)
            let generator_Flick = AVAssetImageGenerator(asset: asset_Flick)
            generator_Flick.appliesPreferredTrackTransform = true
            generator_Flick.maximumSize = CGSize(width: 600, height: 600)
            let time_Flick = CMTime(seconds: 0.1, preferredTimescale: 600)
            do {
                let cgImage_Flick = try generator_Flick.copyCGImage(at: time_Flick, actualTime: nil)
                let thumb_Flick   = UIImage(cgImage: cgImage_Flick)
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Flick(image_Flick: thumb_Flick)
                    self?.playIconView_Flick.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Flick() }
            }
        }
    }
}
