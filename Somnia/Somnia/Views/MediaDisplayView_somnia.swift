import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Somnia {
    case image_Somnia
    case video_Somnia
    case none_Somnia
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Somnia: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Somnia: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Somnia: "#667eea"), UIColor(hexstring_Somnia: "#764ba2")),  // 紫色
        (UIColor(hexstring_Somnia: "#f093fb"), UIColor(hexstring_Somnia: "#f5576c")),  // 粉红
        (UIColor(hexstring_Somnia: "#4facfe"), UIColor(hexstring_Somnia: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Somnia: "#43e97b"), UIColor(hexstring_Somnia: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Somnia: "#fa709a"), UIColor(hexstring_Somnia: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Somnia: [CGColor] = [
        UIColor(hexstring_Somnia: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Somnia: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Somnia: UIImageView = {
        let imageView_Somnia = UIImageView()
        imageView_Somnia.contentMode = .scaleAspectFill
        imageView_Somnia.clipsToBounds = true
        imageView_Somnia.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia
        imageView_Somnia.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Somnia
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Somnia: UIView = {
        let view_Somnia = UIView()
        view_Somnia.isUserInteractionEnabled = false
        return view_Somnia
    }()
    
    /// 视频播放图标
    private let playIconView_Somnia: UIView = {
        let view_Somnia = UIView()
        view_Somnia.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Somnia.layer.cornerRadius = 30
        view_Somnia.isHidden = true
        return view_Somnia
    }()
    
    private let playIconImageView_Somnia: UIImageView = {
        let imageView_Somnia = UIImageView()
        imageView_Somnia.image = UIImage(systemName: "play.fill")
        imageView_Somnia.tintColor = .white
        imageView_Somnia.contentMode = .scaleAspectFit
        return imageView_Somnia
    }()
    
    /// 占位符图标
    private let placeholderIconView_Somnia: UIImageView = {
        let imageView_Somnia = UIImageView()
        imageView_Somnia.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Somnia.tintColor = ColorConfig_Somnia.textPlaceholder_Somnia
        imageView_Somnia.contentMode = .scaleAspectFit
        return imageView_Somnia
    }()
    
    // MARK: - 属性
    
    private var mediaType_Somnia: MediaType_Somnia = .none_Somnia
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Somnia()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Somnia() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Somnia)
        addSubview(iconContainerView_Somnia)
        addSubview(placeholderIconView_Somnia)
        addSubview(playIconView_Somnia)
        playIconView_Somnia.addSubview(playIconImageView_Somnia)
        
        imageView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 直接展示 UIImage 对象（从相册选取图片后使用，无需存储路径）
    /// - Parameter image_Somnia: 要展示的图片
    func configureWithImage_Somnia(image_Somnia: UIImage) {
        mediaType_Somnia = .image_Somnia
        clearOldContent_Somnia()
        imageView_Somnia.image = image_Somnia
        placeholderIconView_Somnia.isHidden = true
        playIconView_Somnia.isHidden = true
    }

    /// 配置媒体展示
    func configure_Somnia(mediaPath_Somnia: String?, isVideo_Somnia: Bool = false) {
        guard let path_Somnia = mediaPath_Somnia, !path_Somnia.isEmpty else {
            showPlaceholder_Somnia()
            return
        }
        
        mediaType_Somnia = isVideo_Somnia ? .video_Somnia : .image_Somnia
        playIconView_Somnia.isHidden = !isVideo_Somnia
        
        loadMedia_Somnia(path_Somnia: path_Somnia, isVideo_Somnia: isVideo_Somnia)
    }
    
    /// 加载媒体
    private func loadMedia_Somnia(path_Somnia: String, isVideo_Somnia: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Somnia = UIImage(systemName: path_Somnia) {
            loadSystemIcon_Somnia(image_Somnia: systemImage_Somnia, path_Somnia: path_Somnia)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Somnia = UIImage(named: path_Somnia) {
            loadImageSuccess_Somnia(image_Somnia: assetImage_Somnia)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Somnia.hasPrefix("http://") || path_Somnia.hasPrefix("https://") {
            loadNetworkImage_Somnia(urlString_Somnia: path_Somnia)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Somnia = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Somnia = documentsPath_Somnia.appendingPathComponent(path_Somnia)
        
        if let documentImage_Somnia = UIImage(contentsOfFile: fileURL_Somnia.path) {
            loadImageSuccess_Somnia(image_Somnia: documentImage_Somnia)
            print("✅ 从文档目录加载媒体: \(path_Somnia)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Somnia = UIImage(contentsOfFile: path_Somnia) {
            loadImageSuccess_Somnia(image_Somnia: localImage_Somnia)
            return
        }

        // 6. 尝试从 Bundle 中加载视频文件并提取缩略图（mp4 / mov / m4v）
        if let videoURL_Somnia = bundleVideoURL_Somnia(named: path_Somnia) {
            mediaType_Somnia = .video_Somnia
            playIconView_Somnia.isHidden = false
            generateVideoThumbnail_Somnia(url_Somnia: videoURL_Somnia)
            return
        }

        // 7. 尝试从文档目录加载视频文件并提取缩略图
        for ext_Somnia in ["mp4", "mov", "m4v"] {
            let videoFileURL_Somnia = documentsPath_Somnia.appendingPathComponent("\(path_Somnia).\(ext_Somnia)")
            if FileManager.default.fileExists(atPath: videoFileURL_Somnia.path) {
                mediaType_Somnia = .video_Somnia
                playIconView_Somnia.isHidden = false
                generateVideoThumbnail_Somnia(url_Somnia: videoFileURL_Somnia)
                return
            }
        }
        
        // 8. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Somnia)")
        showPlaceholder_Somnia()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Somnia() {
        imageView_Somnia.image = nil
        imageView_Somnia.layer.sublayers?.removeAll()
        iconContainerView_Somnia.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Somnia(image_Somnia: UIImage, path_Somnia: String) {
        clearOldContent_Somnia()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Somnia = Self.gradientColors_Somnia[abs(path_Somnia.hashValue) % Self.gradientColors_Somnia.count]
        
        // 添加渐变背景
        let gradientColors_Somnia = [selectedGradient_Somnia.0.cgColor, selectedGradient_Somnia.1.cgColor]
        addGradientLayer_Somnia(colors_Somnia: gradientColors_Somnia)
        
        // 在独立容器上显示图标
        let iconImageView_Somnia = UIImageView(image: image_Somnia)
        iconImageView_Somnia.tintColor = .white
        iconImageView_Somnia.contentMode = .scaleAspectFit
        iconImageView_Somnia.alpha = 0.9
        iconContainerView_Somnia.addSubview(iconImageView_Somnia)
        iconImageView_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Somnia.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Somnia(urlString_Somnia: String) {
        clearOldContent_Somnia()
        
        if let url_Somnia = URL(string: urlString_Somnia) {
            imageView_Somnia.kf.setImage(
                with: url_Somnia,
                placeholder: createPlaceholderImage_Somnia(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Somnia.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Somnia(image_Somnia: UIImage) {
        clearOldContent_Somnia()
        imageView_Somnia.image = image_Somnia
        placeholderIconView_Somnia.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Somnia(colors_Somnia: [CGColor]) {
        let gradientLayer_Somnia = CAGradientLayer()
        gradientLayer_Somnia.frame = bounds
        gradientLayer_Somnia.colors = colors_Somnia
        gradientLayer_Somnia.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Somnia.endPoint = CGPoint(x: 1, y: 1)
        imageView_Somnia.layer.insertSublayer(gradientLayer_Somnia, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Somnia() {
        mediaType_Somnia = .none_Somnia
        clearOldContent_Somnia()
        placeholderIconView_Somnia.isHidden = false
        playIconView_Somnia.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Somnia(colors_Somnia: Self.placeholderGradientColors_Somnia)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Somnia() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Somnia.backgroundPrimary_Somnia.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Somnia = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Somnia
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Somnia == .none_Somnia {
            imageView_Somnia.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中按名称查找视频文件（依次尝试 mp4 / mov / m4v 扩展名）
    /// - Parameter named_Somnia: 不含扩展名的资源名
    /// - Returns: 找到时返回文件 URL，否则返回 nil
    static func bundleVideoURL_Somnia(named named_Somnia: String) -> URL? {
        for ext_Somnia in ["mp4", "mov", "m4v"] {
            if let url_Somnia = Bundle.main.url(forResource: named_Somnia, withExtension: ext_Somnia) {
                return url_Somnia
            }
        }
        return nil
    }

    /// 在 Bundle 中按名称查找视频文件（实例方法，内部调用静态版本）
    private func bundleVideoURL_Somnia(named named_Somnia: String) -> URL? {
        return MediaDisplayView_Somnia.bundleVideoURL_Somnia(named: named_Somnia)
    }

    /// 从视频 URL 异步提取第一帧作为缩略图，成功后刷新 imageView
    /// - Parameter url_Somnia: 视频文件 URL
    private func generateVideoThumbnail_Somnia(url_Somnia: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset_Somnia     = AVURLAsset(url: url_Somnia)
            let generator_Somnia = AVAssetImageGenerator(asset: asset_Somnia)
            generator_Somnia.appliesPreferredTrackTransform = true
            generator_Somnia.maximumSize = CGSize(width: 600, height: 600)
            let time_Somnia = CMTime(seconds: 0.1, preferredTimescale: 600)
            do {
                let cgImage_Somnia = try generator_Somnia.copyCGImage(at: time_Somnia, actualTime: nil)
                let thumb_Somnia   = UIImage(cgImage: cgImage_Somnia)
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Somnia(image_Somnia: thumb_Somnia)
                    self?.playIconView_Somnia.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Somnia() }
            }
        }
    }
}
