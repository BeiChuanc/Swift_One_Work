import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Lumia {
    case image_Lumia
    case video_Lumia
    case none_Lumia
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Lumia: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Lumia: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Lumia: "#667eea"), UIColor(hexstring_Lumia: "#764ba2")),  // 紫色
        (UIColor(hexstring_Lumia: "#f093fb"), UIColor(hexstring_Lumia: "#f5576c")),  // 粉红
        (UIColor(hexstring_Lumia: "#4facfe"), UIColor(hexstring_Lumia: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Lumia: "#43e97b"), UIColor(hexstring_Lumia: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Lumia: "#fa709a"), UIColor(hexstring_Lumia: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Lumia: [CGColor] = [
        UIColor(hexstring_Lumia: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Lumia: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Lumia: UIImageView = {
        let imageView_Lumia = UIImageView()
        imageView_Lumia.contentMode = .scaleAspectFill
        imageView_Lumia.clipsToBounds = true
        imageView_Lumia.backgroundColor = ColorConfig_Lumia.backgroundPrimary_Lumia
        imageView_Lumia.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Lumia
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Lumia: UIView = {
        let view_Lumia = UIView()
        view_Lumia.isUserInteractionEnabled = false
        return view_Lumia
    }()
    
    /// 视频播放图标
    private let playIconView_Lumia: UIView = {
        let view_Lumia = UIView()
        view_Lumia.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Lumia.layer.cornerRadius = 30
        view_Lumia.isHidden = true
        return view_Lumia
    }()
    
    private let playIconImageView_Lumia: UIImageView = {
        let imageView_Lumia = UIImageView()
        imageView_Lumia.image = UIImage(systemName: "play.fill")
        imageView_Lumia.tintColor = .white
        imageView_Lumia.contentMode = .scaleAspectFit
        return imageView_Lumia
    }()
    
    /// 占位符图标
    private let placeholderIconView_Lumia: UIImageView = {
        let imageView_Lumia = UIImageView()
        imageView_Lumia.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Lumia.tintColor = ColorConfig_Lumia.textPlaceholder_Lumia
        imageView_Lumia.contentMode = .scaleAspectFit
        return imageView_Lumia
    }()
    
    // MARK: - 属性
    
    private var mediaType_Lumia: MediaType_Lumia = .none_Lumia
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Lumia() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Lumia)
        addSubview(iconContainerView_Lumia)
        addSubview(placeholderIconView_Lumia)
        addSubview(playIconView_Lumia)
        playIconView_Lumia.addSubview(playIconImageView_Lumia)
        
        imageView_Lumia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Lumia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 直接展示 UIImage 对象（从相册选取图片后使用，无需存储路径）
    /// - Parameter image_Lumia: 要展示的图片
    func configureWithImage_Lumia(image_Lumia: UIImage) {
        mediaType_Lumia = .image_Lumia
        clearOldContent_Lumia()
        imageView_Lumia.image = image_Lumia
        placeholderIconView_Lumia.isHidden = true
        playIconView_Lumia.isHidden = true
    }

    /// 配置媒体展示
    func configure_Lumia(mediaPath_Lumia: String?, isVideo_Lumia: Bool = false) {
        guard let path_Lumia = mediaPath_Lumia, !path_Lumia.isEmpty else {
            showPlaceholder_Lumia()
            return
        }
        
        mediaType_Lumia = isVideo_Lumia ? .video_Lumia : .image_Lumia
        playIconView_Lumia.isHidden = !isVideo_Lumia
        
        loadMedia_Lumia(path_Lumia: path_Lumia, isVideo_Lumia: isVideo_Lumia)
    }
    
    /// 加载媒体
    private func loadMedia_Lumia(path_Lumia: String, isVideo_Lumia: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Lumia = UIImage(systemName: path_Lumia) {
            loadSystemIcon_Lumia(image_Lumia: systemImage_Lumia, path_Lumia: path_Lumia)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Lumia = UIImage(named: path_Lumia) {
            loadImageSuccess_Lumia(image_Lumia: assetImage_Lumia)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Lumia.hasPrefix("http://") || path_Lumia.hasPrefix("https://") {
            loadNetworkImage_Lumia(urlString_Lumia: path_Lumia)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Lumia = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Lumia = documentsPath_Lumia.appendingPathComponent(path_Lumia)
        
        if let documentImage_Lumia = UIImage(contentsOfFile: fileURL_Lumia.path) {
            loadImageSuccess_Lumia(image_Lumia: documentImage_Lumia)
            print("✅ 从文档目录加载媒体: \(path_Lumia)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Lumia = UIImage(contentsOfFile: path_Lumia) {
            loadImageSuccess_Lumia(image_Lumia: localImage_Lumia)
            return
        }

        // 6. 尝试从 Bundle 中加载视频文件并提取缩略图（mp4 / mov / m4v）
        if let videoURL_Lumia = bundleVideoURL_Lumia(named: path_Lumia) {
            mediaType_Lumia = .video_Lumia
            playIconView_Lumia.isHidden = false
            generateVideoThumbnail_Lumia(url_Lumia: videoURL_Lumia)
            return
        }

        // 7. 尝试从文档目录加载视频文件并提取缩略图
        for ext_Lumia in ["mp4", "mov", "m4v"] {
            let videoFileURL_Lumia = documentsPath_Lumia.appendingPathComponent("\(path_Lumia).\(ext_Lumia)")
            if FileManager.default.fileExists(atPath: videoFileURL_Lumia.path) {
                mediaType_Lumia = .video_Lumia
                playIconView_Lumia.isHidden = false
                generateVideoThumbnail_Lumia(url_Lumia: videoFileURL_Lumia)
                return
            }
        }
        
        // 8. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Lumia)")
        showPlaceholder_Lumia()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Lumia() {
        imageView_Lumia.image = nil
        imageView_Lumia.layer.sublayers?.removeAll()
        iconContainerView_Lumia.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Lumia(image_Lumia: UIImage, path_Lumia: String) {
        clearOldContent_Lumia()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Lumia = Self.gradientColors_Lumia[abs(path_Lumia.hashValue) % Self.gradientColors_Lumia.count]
        
        // 添加渐变背景
        let gradientColors_Lumia = [selectedGradient_Lumia.0.cgColor, selectedGradient_Lumia.1.cgColor]
        addGradientLayer_Lumia(colors_Lumia: gradientColors_Lumia)
        
        // 在独立容器上显示图标
        let iconImageView_Lumia = UIImageView(image: image_Lumia)
        iconImageView_Lumia.tintColor = .white
        iconImageView_Lumia.contentMode = .scaleAspectFit
        iconImageView_Lumia.alpha = 0.9
        iconContainerView_Lumia.addSubview(iconImageView_Lumia)
        iconImageView_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Lumia.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Lumia(urlString_Lumia: String) {
        clearOldContent_Lumia()
        
        if let url_Lumia = URL(string: urlString_Lumia) {
            imageView_Lumia.kf.setImage(
                with: url_Lumia,
                placeholder: createPlaceholderImage_Lumia(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Lumia.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Lumia(image_Lumia: UIImage) {
        clearOldContent_Lumia()
        imageView_Lumia.image = image_Lumia
        placeholderIconView_Lumia.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Lumia(colors_Lumia: [CGColor]) {
        let gradientLayer_Lumia = CAGradientLayer()
        gradientLayer_Lumia.frame = bounds
        gradientLayer_Lumia.colors = colors_Lumia
        gradientLayer_Lumia.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Lumia.endPoint = CGPoint(x: 1, y: 1)
        imageView_Lumia.layer.insertSublayer(gradientLayer_Lumia, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Lumia() {
        mediaType_Lumia = .none_Lumia
        clearOldContent_Lumia()
        placeholderIconView_Lumia.isHidden = false
        playIconView_Lumia.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Lumia(colors_Lumia: Self.placeholderGradientColors_Lumia)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Lumia() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Lumia.backgroundPrimary_Lumia.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Lumia = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Lumia
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Lumia == .none_Lumia {
            imageView_Lumia.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中按名称查找视频文件（依次尝试 mp4 / mov / m4v 扩展名）
    /// - Parameter named_Lumia: 不含扩展名的资源名
    /// - Returns: 找到时返回文件 URL，否则返回 nil
    static func bundleVideoURL_Lumia(named named_Lumia: String) -> URL? {
        for ext_Lumia in ["mp4", "mov", "m4v"] {
            if let url_Lumia = Bundle.main.url(forResource: named_Lumia, withExtension: ext_Lumia) {
                return url_Lumia
            }
        }
        return nil
    }

    /// 在 Bundle 中按名称查找视频文件（实例方法，内部调用静态版本）
    private func bundleVideoURL_Lumia(named named_Lumia: String) -> URL? {
        return MediaDisplayView_Lumia.bundleVideoURL_Lumia(named: named_Lumia)
    }

    /// 从视频 URL 异步提取第一帧作为缩略图，成功后刷新 imageView
    /// - Parameter url_Lumia: 视频文件 URL
    private func generateVideoThumbnail_Lumia(url_Lumia: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset_Lumia     = AVURLAsset(url: url_Lumia)
            let generator_Lumia = AVAssetImageGenerator(asset: asset_Lumia)
            generator_Lumia.appliesPreferredTrackTransform = true
            generator_Lumia.maximumSize = CGSize(width: 600, height: 600)
            let time_Lumia = CMTime(seconds: 0.1, preferredTimescale: 600)
            do {
                let cgImage_Lumia = try generator_Lumia.copyCGImage(at: time_Lumia, actualTime: nil)
                let thumb_Lumia   = UIImage(cgImage: cgImage_Lumia)
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Lumia(image_Lumia: thumb_Lumia)
                    self?.playIconView_Lumia.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Lumia() }
            }
        }
    }
}
