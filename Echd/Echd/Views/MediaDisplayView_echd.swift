import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Echd {
    case image_Echd
    case video_Echd
    case none_Echd
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Echd: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Echd: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Echd: "#667eea"), UIColor(hexstring_Echd: "#764ba2")),  // 紫色
        (UIColor(hexstring_Echd: "#f093fb"), UIColor(hexstring_Echd: "#f5576c")),  // 粉红
        (UIColor(hexstring_Echd: "#4facfe"), UIColor(hexstring_Echd: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Echd: "#43e97b"), UIColor(hexstring_Echd: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Echd: "#fa709a"), UIColor(hexstring_Echd: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Echd: [CGColor] = [
        UIColor(hexstring_Echd: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Echd: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Echd: UIImageView = {
        let imageView_Echd = UIImageView()
        imageView_Echd.contentMode = .scaleAspectFill
        imageView_Echd.clipsToBounds = true
        imageView_Echd.backgroundColor = ColorConfig_Echd.backgroundPrimary_Echd
        imageView_Echd.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Echd
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.isUserInteractionEnabled = false
        return view_Echd
    }()
    
    /// 视频播放图标
    private let playIconView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Echd.layer.cornerRadius = 30
        view_Echd.isHidden = true
        return view_Echd
    }()
    
    private let playIconImageView_Echd: UIImageView = {
        let imageView_Echd = UIImageView()
        imageView_Echd.image = UIImage(systemName: "play.fill")
        imageView_Echd.tintColor = .white
        imageView_Echd.contentMode = .scaleAspectFit
        return imageView_Echd
    }()
    
    /// 占位符图标
    private let placeholderIconView_Echd: UIImageView = {
        let imageView_Echd = UIImageView()
        imageView_Echd.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Echd.tintColor = ColorConfig_Echd.textPlaceholder_Echd
        imageView_Echd.contentMode = .scaleAspectFit
        return imageView_Echd
    }()
    
    // MARK: - 属性
    
    private var mediaType_Echd: MediaType_Echd = .none_Echd
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Echd()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Echd() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Echd)
        addSubview(iconContainerView_Echd)
        addSubview(placeholderIconView_Echd)
        addSubview(playIconView_Echd)
        playIconView_Echd.addSubview(playIconImageView_Echd)
        
        imageView_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Echd.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Echd.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Echd.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 直接展示 UIImage 对象（从相册选取图片后使用，无需存储路径）
    /// - Parameter image_Echd: 要展示的图片
    func configureWithImage_Echd(image_Echd: UIImage) {
        mediaType_Echd = .image_Echd
        clearOldContent_Echd()
        imageView_Echd.image = image_Echd
        placeholderIconView_Echd.isHidden = true
        playIconView_Echd.isHidden = true
    }

    /// 配置媒体展示
    func configure_Echd(mediaPath_Echd: String?, isVideo_Echd: Bool = false) {
        guard let path_Echd = mediaPath_Echd, !path_Echd.isEmpty else {
            showPlaceholder_Echd()
            return
        }
        
        mediaType_Echd = isVideo_Echd ? .video_Echd : .image_Echd
        playIconView_Echd.isHidden = !isVideo_Echd
        
        loadMedia_Echd(path_Echd: path_Echd, isVideo_Echd: isVideo_Echd)
    }
    
    /// 加载媒体
    private func loadMedia_Echd(path_Echd: String, isVideo_Echd: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Echd = UIImage(systemName: path_Echd) {
            loadSystemIcon_Echd(image_Echd: systemImage_Echd, path_Echd: path_Echd)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Echd = UIImage(named: path_Echd) {
            loadImageSuccess_Echd(image_Echd: assetImage_Echd)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Echd.hasPrefix("http://") || path_Echd.hasPrefix("https://") {
            loadNetworkImage_Echd(urlString_Echd: path_Echd)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Echd = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Echd = documentsPath_Echd.appendingPathComponent(path_Echd)
        
        if let documentImage_Echd = UIImage(contentsOfFile: fileURL_Echd.path) {
            loadImageSuccess_Echd(image_Echd: documentImage_Echd)
            print("✅ 从文档目录加载媒体: \(path_Echd)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Echd = UIImage(contentsOfFile: path_Echd) {
            loadImageSuccess_Echd(image_Echd: localImage_Echd)
            return
        }

        // 6. 尝试从 Bundle 中加载视频文件并提取缩略图（mp4 / mov / m4v）
        if let videoURL_Echd = bundleVideoURL_Echd(named: path_Echd) {
            mediaType_Echd = .video_Echd
            playIconView_Echd.isHidden = false
            generateVideoThumbnail_Echd(url_Echd: videoURL_Echd)
            return
        }

        // 7. 尝试从文档目录加载视频文件并提取缩略图
        for ext_Echd in ["mp4", "mov", "m4v"] {
            let videoFileURL_Echd = documentsPath_Echd.appendingPathComponent("\(path_Echd).\(ext_Echd)")
            if FileManager.default.fileExists(atPath: videoFileURL_Echd.path) {
                mediaType_Echd = .video_Echd
                playIconView_Echd.isHidden = false
                generateVideoThumbnail_Echd(url_Echd: videoFileURL_Echd)
                return
            }
        }
        
        // 8. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Echd)")
        showPlaceholder_Echd()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Echd() {
        imageView_Echd.image = nil
        imageView_Echd.layer.sublayers?.removeAll()
        iconContainerView_Echd.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Echd(image_Echd: UIImage, path_Echd: String) {
        clearOldContent_Echd()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Echd = Self.gradientColors_Echd[abs(path_Echd.hashValue) % Self.gradientColors_Echd.count]
        
        // 添加渐变背景
        let gradientColors_Echd = [selectedGradient_Echd.0.cgColor, selectedGradient_Echd.1.cgColor]
        addGradientLayer_Echd(colors_Echd: gradientColors_Echd)
        
        // 在独立容器上显示图标
        let iconImageView_Echd = UIImageView(image: image_Echd)
        iconImageView_Echd.tintColor = .white
        iconImageView_Echd.contentMode = .scaleAspectFit
        iconImageView_Echd.alpha = 0.9
        iconContainerView_Echd.addSubview(iconImageView_Echd)
        iconImageView_Echd.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Echd.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Echd(urlString_Echd: String) {
        clearOldContent_Echd()
        
        if let url_Echd = URL(string: urlString_Echd) {
            imageView_Echd.kf.setImage(
                with: url_Echd,
                placeholder: createPlaceholderImage_Echd(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Echd.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Echd(image_Echd: UIImage) {
        clearOldContent_Echd()
        imageView_Echd.image = image_Echd
        placeholderIconView_Echd.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Echd(colors_Echd: [CGColor]) {
        let gradientLayer_Echd = CAGradientLayer()
        gradientLayer_Echd.frame = bounds
        gradientLayer_Echd.colors = colors_Echd
        gradientLayer_Echd.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Echd.endPoint = CGPoint(x: 1, y: 1)
        imageView_Echd.layer.insertSublayer(gradientLayer_Echd, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Echd() {
        mediaType_Echd = .none_Echd
        clearOldContent_Echd()
        placeholderIconView_Echd.isHidden = false
        playIconView_Echd.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Echd(colors_Echd: Self.placeholderGradientColors_Echd)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Echd() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Echd.backgroundPrimary_Echd.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Echd = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Echd
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Echd == .none_Echd {
            imageView_Echd.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中按名称查找视频文件（依次尝试 mp4 / mov / m4v 扩展名）
    /// - Parameter named_Echd: 不含扩展名的资源名
    /// - Returns: 找到时返回文件 URL，否则返回 nil
    static func bundleVideoURL_Echd(named named_Echd: String) -> URL? {
        for ext_Echd in ["mp4", "mov", "m4v"] {
            if let url_Echd = Bundle.main.url(forResource: named_Echd, withExtension: ext_Echd) {
                return url_Echd
            }
        }
        return nil
    }

    /// 在 Bundle 中按名称查找视频文件（实例方法，内部调用静态版本）
    private func bundleVideoURL_Echd(named named_Echd: String) -> URL? {
        return MediaDisplayView_Echd.bundleVideoURL_Echd(named: named_Echd)
    }

    /// 从视频 URL 异步提取第一帧作为缩略图，成功后刷新 imageView
    /// - Parameter url_Echd: 视频文件 URL
    private func generateVideoThumbnail_Echd(url_Echd: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset_Echd     = AVURLAsset(url: url_Echd)
            let generator_Echd = AVAssetImageGenerator(asset: asset_Echd)
            generator_Echd.appliesPreferredTrackTransform = true
            generator_Echd.maximumSize = CGSize(width: 600, height: 600)
            let time_Echd = CMTime(seconds: 0.1, preferredTimescale: 600)
            do {
                let cgImage_Echd = try generator_Echd.copyCGImage(at: time_Echd, actualTime: nil)
                let thumb_Echd   = UIImage(cgImage: cgImage_Echd)
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Echd(image_Echd: thumb_Echd)
                    self?.playIconView_Echd.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Echd() }
            }
        }
    }
}
