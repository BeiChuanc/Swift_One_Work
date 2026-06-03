import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Bague {
    case image_Bague
    case video_Bague
    case none_Bague
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Bague: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Bague: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Bague: "#667eea"), UIColor(hexstring_Bague: "#764ba2")),  // 紫色
        (UIColor(hexstring_Bague: "#f093fb"), UIColor(hexstring_Bague: "#f5576c")),  // 粉红
        (UIColor(hexstring_Bague: "#4facfe"), UIColor(hexstring_Bague: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Bague: "#43e97b"), UIColor(hexstring_Bague: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Bague: "#fa709a"), UIColor(hexstring_Bague: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Bague: [CGColor] = [
        UIColor(hexstring_Bague: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Bague: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Bague: UIImageView = {
        let imageView_Bague = UIImageView()
        imageView_Bague.contentMode = .scaleAspectFill
        imageView_Bague.clipsToBounds = true
        imageView_Bague.backgroundColor = ColorConfig_Bague.backgroundPrimary_Bague
        imageView_Bague.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Bague
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Bague: UIView = {
        let view_Bague = UIView()
        view_Bague.isUserInteractionEnabled = false
        return view_Bague
    }()
    
    /// 视频播放图标
    private let playIconView_Bague: UIView = {
        let view_Bague = UIView()
        view_Bague.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Bague.layer.cornerRadius = 30
        view_Bague.isHidden = true
        return view_Bague
    }()
    
    private let playIconImageView_Bague: UIImageView = {
        let imageView_Bague = UIImageView()
        imageView_Bague.image = UIImage(systemName: "play.fill")
        imageView_Bague.tintColor = .white
        imageView_Bague.contentMode = .scaleAspectFit
        return imageView_Bague
    }()
    
    /// 占位符图标
    private let placeholderIconView_Bague: UIImageView = {
        let imageView_Bague = UIImageView()
        imageView_Bague.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Bague.tintColor = ColorConfig_Bague.textPlaceholder_Bague
        imageView_Bague.contentMode = .scaleAspectFit
        return imageView_Bague
    }()
    
    // MARK: - 属性
    
    private var mediaType_Bague: MediaType_Bague = .none_Bague
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Bague()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Bague() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Bague)
        addSubview(iconContainerView_Bague)
        addSubview(placeholderIconView_Bague)
        addSubview(playIconView_Bague)
        playIconView_Bague.addSubview(playIconImageView_Bague)
        
        imageView_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 直接展示 UIImage 对象（从相册选取图片后使用，无需存储路径）
    /// - Parameter image_Bague: 要展示的图片
    func configureWithImage_Bague(image_Bague: UIImage) {
        mediaType_Bague = .image_Bague
        clearOldContent_Bague()
        imageView_Bague.image = image_Bague
        placeholderIconView_Bague.isHidden = true
        playIconView_Bague.isHidden = true
    }

    /// 配置媒体展示
    func configure_Bague(mediaPath_Bague: String?, isVideo_Bague: Bool = false) {
        guard let path_Bague = mediaPath_Bague, !path_Bague.isEmpty else {
            showPlaceholder_Bague()
            return
        }
        
        mediaType_Bague = isVideo_Bague ? .video_Bague : .image_Bague
        playIconView_Bague.isHidden = !isVideo_Bague
        
        loadMedia_Bague(path_Bague: path_Bague, isVideo_Bague: isVideo_Bague)
    }
    
    /// 加载媒体
    private func loadMedia_Bague(path_Bague: String, isVideo_Bague: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Bague = UIImage(systemName: path_Bague) {
            loadSystemIcon_Bague(image_Bague: systemImage_Bague, path_Bague: path_Bague)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Bague = UIImage(named: path_Bague) {
            loadImageSuccess_Bague(image_Bague: assetImage_Bague)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Bague.hasPrefix("http://") || path_Bague.hasPrefix("https://") {
            loadNetworkImage_Bague(urlString_Bague: path_Bague)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Bague = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Bague = documentsPath_Bague.appendingPathComponent(path_Bague)
        
        if let documentImage_Bague = UIImage(contentsOfFile: fileURL_Bague.path) {
            loadImageSuccess_Bague(image_Bague: documentImage_Bague)
            print("✅ 从文档目录加载媒体: \(path_Bague)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Bague = UIImage(contentsOfFile: path_Bague) {
            loadImageSuccess_Bague(image_Bague: localImage_Bague)
            return
        }

        // 6. 尝试从 Bundle 中加载视频文件并提取缩略图（mp4 / mov / m4v）
        if let videoURL_Bague = bundleVideoURL_Bague(named: path_Bague) {
            mediaType_Bague = .video_Bague
            playIconView_Bague.isHidden = false
            generateVideoThumbnail_Bague(url_Bague: videoURL_Bague)
            return
        }

        // 7. 尝试从文档目录加载视频文件并提取缩略图
        for ext_Bague in ["mp4", "mov", "m4v"] {
            let videoFileURL_Bague = documentsPath_Bague.appendingPathComponent("\(path_Bague).\(ext_Bague)")
            if FileManager.default.fileExists(atPath: videoFileURL_Bague.path) {
                mediaType_Bague = .video_Bague
                playIconView_Bague.isHidden = false
                generateVideoThumbnail_Bague(url_Bague: videoFileURL_Bague)
                return
            }
        }
        
        // 8. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Bague)")
        showPlaceholder_Bague()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Bague() {
        imageView_Bague.image = nil
        imageView_Bague.layer.sublayers?.removeAll()
        iconContainerView_Bague.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Bague(image_Bague: UIImage, path_Bague: String) {
        clearOldContent_Bague()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Bague = Self.gradientColors_Bague[abs(path_Bague.hashValue) % Self.gradientColors_Bague.count]
        
        // 添加渐变背景
        let gradientColors_Bague = [selectedGradient_Bague.0.cgColor, selectedGradient_Bague.1.cgColor]
        addGradientLayer_Bague(colors_Bague: gradientColors_Bague)
        
        // 在独立容器上显示图标
        let iconImageView_Bague = UIImageView(image: image_Bague)
        iconImageView_Bague.tintColor = .white
        iconImageView_Bague.contentMode = .scaleAspectFit
        iconImageView_Bague.alpha = 0.9
        iconContainerView_Bague.addSubview(iconImageView_Bague)
        iconImageView_Bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Bague.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Bague(urlString_Bague: String) {
        clearOldContent_Bague()
        
        if let url_Bague = URL(string: urlString_Bague) {
            imageView_Bague.kf.setImage(
                with: url_Bague,
                placeholder: createPlaceholderImage_Bague(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Bague.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Bague(image_Bague: UIImage) {
        clearOldContent_Bague()
        imageView_Bague.image = image_Bague
        placeholderIconView_Bague.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Bague(colors_Bague: [CGColor]) {
        let gradientLayer_Bague = CAGradientLayer()
        gradientLayer_Bague.frame = bounds
        gradientLayer_Bague.colors = colors_Bague
        gradientLayer_Bague.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Bague.endPoint = CGPoint(x: 1, y: 1)
        imageView_Bague.layer.insertSublayer(gradientLayer_Bague, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Bague() {
        mediaType_Bague = .none_Bague
        clearOldContent_Bague()
        placeholderIconView_Bague.isHidden = false
        playIconView_Bague.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Bague(colors_Bague: Self.placeholderGradientColors_Bague)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Bague() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Bague.backgroundPrimary_Bague.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Bague = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Bague
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Bague == .none_Bague {
            imageView_Bague.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中按名称查找视频文件（依次尝试 mp4 / mov / m4v 扩展名）
    /// - Parameter named_Bague: 不含扩展名的资源名
    /// - Returns: 找到时返回文件 URL，否则返回 nil
    static func bundleVideoURL_Bague(named named_Bague: String) -> URL? {
        for ext_Bague in ["mp4", "mov", "m4v"] {
            if let url_Bague = Bundle.main.url(forResource: named_Bague, withExtension: ext_Bague) {
                return url_Bague
            }
        }
        return nil
    }

    /// 在 Bundle 中按名称查找视频文件（实例方法，内部调用静态版本）
    private func bundleVideoURL_Bague(named named_Bague: String) -> URL? {
        return MediaDisplayView_Bague.bundleVideoURL_Bague(named: named_Bague)
    }

    /// 从视频 URL 异步提取第一帧作为缩略图，成功后刷新 imageView
    /// - Parameter url_Bague: 视频文件 URL
    private func generateVideoThumbnail_Bague(url_Bague: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset_Bague     = AVURLAsset(url: url_Bague)
            let generator_Bague = AVAssetImageGenerator(asset: asset_Bague)
            generator_Bague.appliesPreferredTrackTransform = true
            generator_Bague.maximumSize = CGSize(width: 600, height: 600)
            let time_Bague = CMTime(seconds: 0.1, preferredTimescale: 600)
            do {
                let cgImage_Bague = try generator_Bague.copyCGImage(at: time_Bague, actualTime: nil)
                let thumb_Bague   = UIImage(cgImage: cgImage_Bague)
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Bague(image_Bague: thumb_Bague)
                    self?.playIconView_Bague.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Bague() }
            }
        }
    }
}
