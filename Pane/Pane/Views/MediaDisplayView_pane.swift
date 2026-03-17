import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Pane {
    case image_Pane
    case video_Pane
    case none_Pane
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Pane: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Pane: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Pane: "#667eea"), UIColor(hexstring_Pane: "#764ba2")),  // 紫色
        (UIColor(hexstring_Pane: "#f093fb"), UIColor(hexstring_Pane: "#f5576c")),  // 粉红
        (UIColor(hexstring_Pane: "#4facfe"), UIColor(hexstring_Pane: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Pane: "#43e97b"), UIColor(hexstring_Pane: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Pane: "#fa709a"), UIColor(hexstring_Pane: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Pane: [CGColor] = [
        UIColor(hexstring_Pane: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Pane: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Pane: UIImageView = {
        let imageView_Pane = UIImageView()
        imageView_Pane.contentMode = .scaleAspectFill
        imageView_Pane.clipsToBounds = true
        imageView_Pane.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane
        imageView_Pane.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Pane
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Pane: UIView = {
        let view_Pane = UIView()
        view_Pane.isUserInteractionEnabled = false
        return view_Pane
    }()
    
    /// 视频播放图标
    private let playIconView_Pane: UIView = {
        let view_Pane = UIView()
        view_Pane.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Pane.layer.cornerRadius = 30
        view_Pane.isHidden = true
        return view_Pane
    }()
    
    private let playIconImageView_Pane: UIImageView = {
        let imageView_Pane = UIImageView()
        imageView_Pane.image = UIImage(systemName: "play.fill")
        imageView_Pane.tintColor = .white
        imageView_Pane.contentMode = .scaleAspectFit
        return imageView_Pane
    }()
    
    /// 占位符图标
    private let placeholderIconView_Pane: UIImageView = {
        let imageView_Pane = UIImageView()
        imageView_Pane.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Pane.tintColor = ColorConfig_Pane.textPlaceholder_Pane
        imageView_Pane.contentMode = .scaleAspectFit
        return imageView_Pane
    }()
    
    // MARK: - 属性
    
    private var mediaType_Pane: MediaType_Pane = .none_Pane
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Pane()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Pane() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Pane)
        addSubview(iconContainerView_Pane)
        addSubview(placeholderIconView_Pane)
        addSubview(playIconView_Pane)
        playIconView_Pane.addSubview(playIconImageView_Pane)
        
        imageView_Pane.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Pane.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Pane.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Pane.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Pane.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 直接展示 UIImage 对象（从相册选取图片后使用，无需存储路径）
    /// - Parameter image_pane: 要展示的图片
    func configureWithImage_Pane(image_pane: UIImage) {
        mediaType_Pane = .image_Pane
        clearOldContent_Pane()
        imageView_Pane.image = image_pane
        placeholderIconView_Pane.isHidden = true
        playIconView_Pane.isHidden = true
    }

    /// 配置媒体展示
    func configure_Pane(mediaPath_Pane: String?, isVideo_Pane: Bool = false) {
        guard let path_Pane = mediaPath_Pane, !path_Pane.isEmpty else {
            showPlaceholder_Pane()
            return
        }
        
        mediaType_Pane = isVideo_Pane ? .video_Pane : .image_Pane
        playIconView_Pane.isHidden = !isVideo_Pane
        
        loadMedia_Pane(path_Pane: path_Pane, isVideo_Pane: isVideo_Pane)
    }
    
    /// 加载媒体
    private func loadMedia_Pane(path_Pane: String, isVideo_Pane: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Pane = UIImage(systemName: path_Pane) {
            loadSystemIcon_Pane(image_Pane: systemImage_Pane, path_Pane: path_Pane)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Pane = UIImage(named: path_Pane) {
            loadImageSuccess_Pane(image_Pane: assetImage_Pane)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Pane.hasPrefix("http://") || path_Pane.hasPrefix("https://") {
            loadNetworkImage_Pane(urlString_Pane: path_Pane)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Pane = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Pane = documentsPath_Pane.appendingPathComponent(path_Pane)
        
        if let documentImage_Pane = UIImage(contentsOfFile: fileURL_Pane.path) {
            loadImageSuccess_Pane(image_Pane: documentImage_Pane)
            print("✅ 从文档目录加载媒体: \(path_Pane)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Pane = UIImage(contentsOfFile: path_Pane) {
            loadImageSuccess_Pane(image_Pane: localImage_Pane)
            return
        }

        // 6. 尝试从 Bundle 中加载视频文件并提取缩略图（mp4 / mov / m4v）
        if let videoURL_Pane = bundleVideoURL_Pane(named: path_Pane) {
            mediaType_Pane = .video_Pane
            playIconView_Pane.isHidden = false
            generateVideoThumbnail_Pane(url_Pane: videoURL_Pane)
            return
        }

        // 7. 尝试从文档目录加载视频文件并提取缩略图
        for ext_pane in ["mp4", "mov", "m4v"] {
            let videoFileURL_Pane = documentsPath_Pane.appendingPathComponent("\(path_Pane).\(ext_pane)")
            if FileManager.default.fileExists(atPath: videoFileURL_Pane.path) {
                mediaType_Pane = .video_Pane
                playIconView_Pane.isHidden = false
                generateVideoThumbnail_Pane(url_Pane: videoFileURL_Pane)
                return
            }
        }
        
        // 8. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Pane)")
        showPlaceholder_Pane()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Pane() {
        imageView_Pane.image = nil
        imageView_Pane.layer.sublayers?.removeAll()
        iconContainerView_Pane.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Pane(image_Pane: UIImage, path_Pane: String) {
        clearOldContent_Pane()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Pane = Self.gradientColors_Pane[abs(path_Pane.hashValue) % Self.gradientColors_Pane.count]
        
        // 添加渐变背景
        let gradientColors_Pane = [selectedGradient_Pane.0.cgColor, selectedGradient_Pane.1.cgColor]
        addGradientLayer_Pane(colors_Pane: gradientColors_Pane)
        
        // 在独立容器上显示图标
        let iconImageView_Pane = UIImageView(image: image_Pane)
        iconImageView_Pane.tintColor = .white
        iconImageView_Pane.contentMode = .scaleAspectFit
        iconImageView_Pane.alpha = 0.9
        iconContainerView_Pane.addSubview(iconImageView_Pane)
        iconImageView_Pane.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Pane.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Pane(urlString_Pane: String) {
        clearOldContent_Pane()
        
        if let url_Pane = URL(string: urlString_Pane) {
            imageView_Pane.kf.setImage(
                with: url_Pane,
                placeholder: createPlaceholderImage_Pane(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Pane.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Pane(image_Pane: UIImage) {
        clearOldContent_Pane()
        imageView_Pane.image = image_Pane
        placeholderIconView_Pane.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Pane(colors_Pane: [CGColor]) {
        let gradientLayer_Pane = CAGradientLayer()
        gradientLayer_Pane.frame = bounds
        gradientLayer_Pane.colors = colors_Pane
        gradientLayer_Pane.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Pane.endPoint = CGPoint(x: 1, y: 1)
        imageView_Pane.layer.insertSublayer(gradientLayer_Pane, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Pane() {
        mediaType_Pane = .none_Pane
        clearOldContent_Pane()
        placeholderIconView_Pane.isHidden = false
        playIconView_Pane.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Pane(colors_Pane: Self.placeholderGradientColors_Pane)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Pane() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Pane.backgroundPrimary_Pane.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Pane = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Pane
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Pane == .none_Pane {
            imageView_Pane.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中按名称查找视频文件（依次尝试 mp4 / mov / m4v 扩展名）
    /// - Parameter named_pane: 不含扩展名的资源名
    /// - Returns: 找到时返回文件 URL，否则返回 nil
    static func bundleVideoURL_Pane(named named_pane: String) -> URL? {
        for ext_pane in ["mp4", "mov", "m4v"] {
            if let url_pane = Bundle.main.url(forResource: named_pane, withExtension: ext_pane) {
                return url_pane
            }
        }
        return nil
    }

    /// 在 Bundle 中按名称查找视频文件（实例方法，内部调用静态版本）
    private func bundleVideoURL_Pane(named named_pane: String) -> URL? {
        return MediaDisplayView_Pane.bundleVideoURL_Pane(named: named_pane)
    }

    /// 从视频 URL 异步提取第一帧作为缩略图，成功后刷新 imageView
    /// - Parameter url_Pane: 视频文件 URL
    private func generateVideoThumbnail_Pane(url_Pane: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset_pane     = AVURLAsset(url: url_Pane)
            let generator_pane = AVAssetImageGenerator(asset: asset_pane)
            generator_pane.appliesPreferredTrackTransform = true
            generator_pane.maximumSize = CGSize(width: 600, height: 600)
            let time_pane = CMTime(seconds: 0.1, preferredTimescale: 600)
            do {
                let cgImage_pane = try generator_pane.copyCGImage(at: time_pane, actualTime: nil)
                let thumb_pane   = UIImage(cgImage: cgImage_pane)
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Pane(image_Pane: thumb_pane)
                    self?.playIconView_Pane.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Pane() }
            }
        }
    }
}
