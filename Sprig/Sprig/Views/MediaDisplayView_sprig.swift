import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Sprig {
    case image_Sprig
    case video_Sprig
    case none_Sprig
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Sprig: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Sprig: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Sprig: "#667eea"), UIColor(hexstring_Sprig: "#764ba2")),  // 紫色
        (UIColor(hexstring_Sprig: "#f093fb"), UIColor(hexstring_Sprig: "#f5576c")),  // 粉红
        (UIColor(hexstring_Sprig: "#4facfe"), UIColor(hexstring_Sprig: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Sprig: "#43e97b"), UIColor(hexstring_Sprig: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Sprig: "#fa709a"), UIColor(hexstring_Sprig: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Sprig: [CGColor] = [
        UIColor(hexstring_Sprig: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Sprig: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Sprig: UIImageView = {
        let imageView_Sprig = UIImageView()
        imageView_Sprig.contentMode = .scaleAspectFill
        imageView_Sprig.clipsToBounds = true
        imageView_Sprig.backgroundColor = ColorConfig_Sprig.backgroundPrimary_Sprig
        imageView_Sprig.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Sprig
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Sprig: UIView = {
        let view_Sprig = UIView()
        view_Sprig.isUserInteractionEnabled = false
        return view_Sprig
    }()
    
    /// 视频播放图标
    private let playIconView_Sprig: UIView = {
        let view_Sprig = UIView()
        view_Sprig.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Sprig.layer.cornerRadius = 30
        view_Sprig.isHidden = true
        return view_Sprig
    }()
    
    private let playIconImageView_Sprig: UIImageView = {
        let imageView_Sprig = UIImageView()
        imageView_Sprig.image = UIImage(systemName: "play.fill")
        imageView_Sprig.tintColor = .white
        imageView_Sprig.contentMode = .scaleAspectFit
        return imageView_Sprig
    }()
    
    /// 占位符图标
    private let placeholderIconView_Sprig: UIImageView = {
        let imageView_Sprig = UIImageView()
        imageView_Sprig.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Sprig.tintColor = ColorConfig_Sprig.textPlaceholder_Sprig
        imageView_Sprig.contentMode = .scaleAspectFit
        return imageView_Sprig
    }()
    
    // MARK: - 属性
    
    private var mediaType_Sprig: MediaType_Sprig = .none_Sprig
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Sprig()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Sprig() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Sprig)
        addSubview(iconContainerView_Sprig)
        addSubview(placeholderIconView_Sprig)
        addSubview(playIconView_Sprig)
        playIconView_Sprig.addSubview(playIconImageView_Sprig)
        
        imageView_Sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 直接展示 UIImage 对象（从相册选取图片后使用，无需存储路径）
    /// - Parameter image_Sprig: 要展示的图片
    func configureWithImage_Sprig(image_Sprig: UIImage) {
        mediaType_Sprig = .image_Sprig
        clearOldContent_Sprig()
        imageView_Sprig.image = image_Sprig
        placeholderIconView_Sprig.isHidden = true
        playIconView_Sprig.isHidden = true
    }

    /// 配置媒体展示
    func configure_Sprig(mediaPath_Sprig: String?, isVideo_Sprig: Bool = false) {
        guard let path_Sprig = mediaPath_Sprig, !path_Sprig.isEmpty else {
            showPlaceholder_Sprig()
            return
        }
        
        mediaType_Sprig = isVideo_Sprig ? .video_Sprig : .image_Sprig
        playIconView_Sprig.isHidden = !isVideo_Sprig
        
        loadMedia_Sprig(path_Sprig: path_Sprig, isVideo_Sprig: isVideo_Sprig)
    }
    
    /// 加载媒体
    private func loadMedia_Sprig(path_Sprig: String, isVideo_Sprig: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Sprig = UIImage(systemName: path_Sprig) {
            loadSystemIcon_Sprig(image_Sprig: systemImage_Sprig, path_Sprig: path_Sprig)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Sprig = UIImage(named: path_Sprig) {
            loadImageSuccess_Sprig(image_Sprig: assetImage_Sprig)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Sprig.hasPrefix("http://") || path_Sprig.hasPrefix("https://") {
            loadNetworkImage_Sprig(urlString_Sprig: path_Sprig)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Sprig = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Sprig = documentsPath_Sprig.appendingPathComponent(path_Sprig)
        
        if let documentImage_Sprig = UIImage(contentsOfFile: fileURL_Sprig.path) {
            loadImageSuccess_Sprig(image_Sprig: documentImage_Sprig)
            print("✅ 从文档目录加载媒体: \(path_Sprig)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Sprig = UIImage(contentsOfFile: path_Sprig) {
            loadImageSuccess_Sprig(image_Sprig: localImage_Sprig)
            return
        }

        // 6. 尝试从 Bundle 中加载视频文件并提取缩略图（mp4 / mov / m4v）
        if let videoURL_Sprig = bundleVideoURL_Sprig(named: path_Sprig) {
            mediaType_Sprig = .video_Sprig
            playIconView_Sprig.isHidden = false
            generateVideoThumbnail_Sprig(url_Sprig: videoURL_Sprig)
            return
        }

        // 7. 尝试从文档目录加载视频文件并提取缩略图
        for ext_Sprig in ["mp4", "mov", "m4v"] {
            let videoFileURL_Sprig = documentsPath_Sprig.appendingPathComponent("\(path_Sprig).\(ext_Sprig)")
            if FileManager.default.fileExists(atPath: videoFileURL_Sprig.path) {
                mediaType_Sprig = .video_Sprig
                playIconView_Sprig.isHidden = false
                generateVideoThumbnail_Sprig(url_Sprig: videoFileURL_Sprig)
                return
            }
        }
        
        // 8. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Sprig)")
        showPlaceholder_Sprig()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Sprig() {
        imageView_Sprig.image = nil
        imageView_Sprig.layer.sublayers?.removeAll()
        iconContainerView_Sprig.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Sprig(image_Sprig: UIImage, path_Sprig: String) {
        clearOldContent_Sprig()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Sprig = Self.gradientColors_Sprig[abs(path_Sprig.hashValue) % Self.gradientColors_Sprig.count]
        
        // 添加渐变背景
        let gradientColors_Sprig = [selectedGradient_Sprig.0.cgColor, selectedGradient_Sprig.1.cgColor]
        addGradientLayer_Sprig(colors_Sprig: gradientColors_Sprig)
        
        // 在独立容器上显示图标
        let iconImageView_Sprig = UIImageView(image: image_Sprig)
        iconImageView_Sprig.tintColor = .white
        iconImageView_Sprig.contentMode = .scaleAspectFit
        iconImageView_Sprig.alpha = 0.9
        iconContainerView_Sprig.addSubview(iconImageView_Sprig)
        iconImageView_Sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Sprig.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Sprig(urlString_Sprig: String) {
        clearOldContent_Sprig()
        
        if let url_Sprig = URL(string: urlString_Sprig) {
            imageView_Sprig.kf.setImage(
                with: url_Sprig,
                placeholder: createPlaceholderImage_Sprig(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Sprig.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Sprig(image_Sprig: UIImage) {
        clearOldContent_Sprig()
        imageView_Sprig.image = image_Sprig
        placeholderIconView_Sprig.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Sprig(colors_Sprig: [CGColor]) {
        let gradientLayer_Sprig = CAGradientLayer()
        gradientLayer_Sprig.frame = bounds
        gradientLayer_Sprig.colors = colors_Sprig
        gradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Sprig.endPoint = CGPoint(x: 1, y: 1)
        imageView_Sprig.layer.insertSublayer(gradientLayer_Sprig, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Sprig() {
        mediaType_Sprig = .none_Sprig
        clearOldContent_Sprig()
        placeholderIconView_Sprig.isHidden = false
        playIconView_Sprig.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Sprig(colors_Sprig: Self.placeholderGradientColors_Sprig)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Sprig() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Sprig.backgroundPrimary_Sprig.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Sprig = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Sprig
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Sprig == .none_Sprig {
            imageView_Sprig.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中按名称查找视频文件（依次尝试 mp4 / mov / m4v 扩展名）
    /// - Parameter named_Sprig: 不含扩展名的资源名
    /// - Returns: 找到时返回文件 URL，否则返回 nil
    static func bundleVideoURL_Sprig(named named_Sprig: String) -> URL? {
        for ext_Sprig in ["mp4", "mov", "m4v"] {
            if let url_Sprig = Bundle.main.url(forResource: named_Sprig, withExtension: ext_Sprig) {
                return url_Sprig
            }
        }
        return nil
    }

    /// 在 Bundle 中按名称查找视频文件（实例方法，内部调用静态版本）
    private func bundleVideoURL_Sprig(named named_Sprig: String) -> URL? {
        return MediaDisplayView_Sprig.bundleVideoURL_Sprig(named: named_Sprig)
    }

    /// 从视频 URL 异步提取第一帧作为缩略图，成功后刷新 imageView
    /// - Parameter url_Sprig: 视频文件 URL
    private func generateVideoThumbnail_Sprig(url_Sprig: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset_Sprig     = AVURLAsset(url: url_Sprig)
            let generator_Sprig = AVAssetImageGenerator(asset: asset_Sprig)
            generator_Sprig.appliesPreferredTrackTransform = true
            generator_Sprig.maximumSize = CGSize(width: 600, height: 600)
            let time_Sprig = CMTime(seconds: 0.1, preferredTimescale: 600)
            do {
                let cgImage_Sprig = try generator_Sprig.copyCGImage(at: time_Sprig, actualTime: nil)
                let thumb_Sprig   = UIImage(cgImage: cgImage_Sprig)
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Sprig(image_Sprig: thumb_Sprig)
                    self?.playIconView_Sprig.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Sprig() }
            }
        }
    }
}
