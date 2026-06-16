import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Retrs {
    case image_Retrs
    case video_Retrs
    case none_Retrs
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Retrs: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Retrs: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Retrs: "#667eea"), UIColor(hexstring_Retrs: "#764ba2")),  // 紫色
        (UIColor(hexstring_Retrs: "#f093fb"), UIColor(hexstring_Retrs: "#f5576c")),  // 粉红
        (UIColor(hexstring_Retrs: "#4facfe"), UIColor(hexstring_Retrs: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Retrs: "#43e97b"), UIColor(hexstring_Retrs: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Retrs: "#fa709a"), UIColor(hexstring_Retrs: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Retrs: [CGColor] = [
        UIColor(hexstring_Retrs: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Retrs: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Retrs: UIImageView = {
        let imageView_Retrs = UIImageView()
        imageView_Retrs.contentMode = .scaleAspectFill
        imageView_Retrs.clipsToBounds = true
        imageView_Retrs.backgroundColor = ColorConfig_Retrs.backgroundPrimary_Retrs
        imageView_Retrs.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Retrs
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Retrs: UIView = {
        let view_Retrs = UIView()
        view_Retrs.isUserInteractionEnabled = false
        return view_Retrs
    }()
    
    /// 视频播放图标
    private let playIconView_Retrs: UIView = {
        let view_Retrs = UIView()
        view_Retrs.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Retrs.layer.cornerRadius = 30
        view_Retrs.isHidden = true
        return view_Retrs
    }()
    
    private let playIconImageView_Retrs: UIImageView = {
        let imageView_Retrs = UIImageView()
        imageView_Retrs.image = UIImage(systemName: "play.fill")
        imageView_Retrs.tintColor = .white
        imageView_Retrs.contentMode = .scaleAspectFit
        return imageView_Retrs
    }()
    
    /// 占位符图标
    private let placeholderIconView_Retrs: UIImageView = {
        let imageView_Retrs = UIImageView()
        imageView_Retrs.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Retrs.tintColor = ColorConfig_Retrs.textPlaceholder_Retrs
        imageView_Retrs.contentMode = .scaleAspectFit
        return imageView_Retrs
    }()
    
    // MARK: - 属性
    
    private var mediaType_Retrs: MediaType_Retrs = .none_Retrs
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Retrs()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Retrs() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Retrs)
        addSubview(iconContainerView_Retrs)
        addSubview(placeholderIconView_Retrs)
        addSubview(playIconView_Retrs)
        playIconView_Retrs.addSubview(playIconImageView_Retrs)
        
        imageView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 直接展示 UIImage 对象（从相册选取图片后使用，无需存储路径）
    /// - Parameter image_Retrs: 要展示的图片
    func configureWithImage_Retrs(image_Retrs: UIImage) {
        mediaType_Retrs = .image_Retrs
        clearOldContent_Retrs()
        imageView_Retrs.image = image_Retrs
        placeholderIconView_Retrs.isHidden = true
        playIconView_Retrs.isHidden = true
    }

    /// 配置媒体展示
    func configure_Retrs(mediaPath_Retrs: String?, isVideo_Retrs: Bool = false) {
        guard let path_Retrs = mediaPath_Retrs, !path_Retrs.isEmpty else {
            showPlaceholder_Retrs()
            return
        }
        
        mediaType_Retrs = isVideo_Retrs ? .video_Retrs : .image_Retrs
        playIconView_Retrs.isHidden = !isVideo_Retrs
        
        loadMedia_Retrs(path_Retrs: path_Retrs, isVideo_Retrs: isVideo_Retrs)
    }
    
    /// 加载媒体
    private func loadMedia_Retrs(path_Retrs: String, isVideo_Retrs: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Retrs = UIImage(systemName: path_Retrs) {
            loadSystemIcon_Retrs(image_Retrs: systemImage_Retrs, path_Retrs: path_Retrs)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Retrs = UIImage(named: path_Retrs) {
            loadImageSuccess_Retrs(image_Retrs: assetImage_Retrs)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Retrs.hasPrefix("http://") || path_Retrs.hasPrefix("https://") {
            loadNetworkImage_Retrs(urlString_Retrs: path_Retrs)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Retrs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Retrs = documentsPath_Retrs.appendingPathComponent(path_Retrs)
        
        if let documentImage_Retrs = UIImage(contentsOfFile: fileURL_Retrs.path) {
            loadImageSuccess_Retrs(image_Retrs: documentImage_Retrs)
            print("✅ 从文档目录加载媒体: \(path_Retrs)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Retrs = UIImage(contentsOfFile: path_Retrs) {
            loadImageSuccess_Retrs(image_Retrs: localImage_Retrs)
            return
        }

        // 6. 尝试从 Bundle 中加载视频文件并提取缩略图（mp4 / mov / m4v）
        if let videoURL_Retrs = bundleVideoURL_Retrs(named: path_Retrs) {
            mediaType_Retrs = .video_Retrs
            playIconView_Retrs.isHidden = false
            generateVideoThumbnail_Retrs(url_Retrs: videoURL_Retrs)
            return
        }

        // 7. 尝试从文档目录加载视频文件并提取缩略图
        for ext_Retrs in ["mp4", "mov", "m4v"] {
            let videoFileURL_Retrs = documentsPath_Retrs.appendingPathComponent("\(path_Retrs).\(ext_Retrs)")
            if FileManager.default.fileExists(atPath: videoFileURL_Retrs.path) {
                mediaType_Retrs = .video_Retrs
                playIconView_Retrs.isHidden = false
                generateVideoThumbnail_Retrs(url_Retrs: videoFileURL_Retrs)
                return
            }
        }
        
        // 8. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Retrs)")
        showPlaceholder_Retrs()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Retrs() {
        imageView_Retrs.image = nil
        imageView_Retrs.layer.sublayers?.removeAll()
        iconContainerView_Retrs.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Retrs(image_Retrs: UIImage, path_Retrs: String) {
        clearOldContent_Retrs()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Retrs = Self.gradientColors_Retrs[abs(path_Retrs.hashValue) % Self.gradientColors_Retrs.count]
        
        // 添加渐变背景
        let gradientColors_Retrs = [selectedGradient_Retrs.0.cgColor, selectedGradient_Retrs.1.cgColor]
        addGradientLayer_Retrs(colors_Retrs: gradientColors_Retrs)
        
        // 在独立容器上显示图标
        let iconImageView_Retrs = UIImageView(image: image_Retrs)
        iconImageView_Retrs.tintColor = .white
        iconImageView_Retrs.contentMode = .scaleAspectFit
        iconImageView_Retrs.alpha = 0.9
        iconContainerView_Retrs.addSubview(iconImageView_Retrs)
        iconImageView_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Retrs.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Retrs(urlString_Retrs: String) {
        clearOldContent_Retrs()
        
        if let url_Retrs = URL(string: urlString_Retrs) {
            imageView_Retrs.kf.setImage(
                with: url_Retrs,
                placeholder: createPlaceholderImage_Retrs(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Retrs.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Retrs(image_Retrs: UIImage) {
        clearOldContent_Retrs()
        imageView_Retrs.image = image_Retrs
        placeholderIconView_Retrs.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Retrs(colors_Retrs: [CGColor]) {
        let gradientLayer_Retrs = CAGradientLayer()
        gradientLayer_Retrs.frame = bounds
        gradientLayer_Retrs.colors = colors_Retrs
        gradientLayer_Retrs.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Retrs.endPoint = CGPoint(x: 1, y: 1)
        imageView_Retrs.layer.insertSublayer(gradientLayer_Retrs, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Retrs() {
        mediaType_Retrs = .none_Retrs
        clearOldContent_Retrs()
        placeholderIconView_Retrs.isHidden = false
        playIconView_Retrs.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Retrs(colors_Retrs: Self.placeholderGradientColors_Retrs)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Retrs() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Retrs.backgroundPrimary_Retrs.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Retrs = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Retrs
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Retrs == .none_Retrs {
            imageView_Retrs.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中按名称查找视频文件（依次尝试 mp4 / mov / m4v 扩展名）
    /// - Parameter named_Retrs: 不含扩展名的资源名
    /// - Returns: 找到时返回文件 URL，否则返回 nil
    static func bundleVideoURL_Retrs(named named_Retrs: String) -> URL? {
        for ext_Retrs in ["mp4", "mov", "m4v"] {
            if let url_Retrs = Bundle.main.url(forResource: named_Retrs, withExtension: ext_Retrs) {
                return url_Retrs
            }
        }
        return nil
    }

    /// 在 Bundle 中按名称查找视频文件（实例方法，内部调用静态版本）
    private func bundleVideoURL_Retrs(named named_Retrs: String) -> URL? {
        return MediaDisplayView_Retrs.bundleVideoURL_Retrs(named: named_Retrs)
    }

    /// 从视频 URL 异步提取第一帧作为缩略图，成功后刷新 imageView
    /// - Parameter url_Retrs: 视频文件 URL
    private func generateVideoThumbnail_Retrs(url_Retrs: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset_Retrs     = AVURLAsset(url: url_Retrs)
            let generator_Retrs = AVAssetImageGenerator(asset: asset_Retrs)
            generator_Retrs.appliesPreferredTrackTransform = true
            generator_Retrs.maximumSize = CGSize(width: 600, height: 600)
            let time_Retrs = CMTime(seconds: 0.1, preferredTimescale: 600)
            do {
                let cgImage_Retrs = try generator_Retrs.copyCGImage(at: time_Retrs, actualTime: nil)
                let thumb_Retrs   = UIImage(cgImage: cgImage_Retrs)
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Retrs(image_Retrs: thumb_Retrs)
                    self?.playIconView_Retrs.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Retrs() }
            }
        }
    }
}
