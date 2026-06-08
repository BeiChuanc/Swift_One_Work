import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Vestir {
    case image_Vestir
    case video_Vestir
    case none_Vestir
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Vestir: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Vestir: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Vestir: "#667eea"), UIColor(hexstring_Vestir: "#764ba2")),  // 紫色
        (UIColor(hexstring_Vestir: "#f093fb"), UIColor(hexstring_Vestir: "#f5576c")),  // 粉红
        (UIColor(hexstring_Vestir: "#4facfe"), UIColor(hexstring_Vestir: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Vestir: "#43e97b"), UIColor(hexstring_Vestir: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Vestir: "#fa709a"), UIColor(hexstring_Vestir: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Vestir: [CGColor] = [
        UIColor(hexstring_Vestir: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Vestir: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Vestir: UIImageView = {
        let imageView_Vestir = UIImageView()
        imageView_Vestir.contentMode = .scaleAspectFill
        imageView_Vestir.clipsToBounds = true
        imageView_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        imageView_Vestir.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Vestir
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Vestir: UIView = {
        let view_Vestir = UIView()
        view_Vestir.isUserInteractionEnabled = false
        return view_Vestir
    }()
    
    /// 视频播放图标
    private let playIconView_Vestir: UIView = {
        let view_Vestir = UIView()
        view_Vestir.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Vestir.layer.cornerRadius = 30
        view_Vestir.isHidden = true
        return view_Vestir
    }()
    
    private let playIconImageView_Vestir: UIImageView = {
        let imageView_Vestir = UIImageView()
        imageView_Vestir.image = UIImage(systemName: "play.fill")
        imageView_Vestir.tintColor = .white
        imageView_Vestir.contentMode = .scaleAspectFit
        return imageView_Vestir
    }()
    
    /// 占位符图标
    private let placeholderIconView_Vestir: UIImageView = {
        let imageView_Vestir = UIImageView()
        imageView_Vestir.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Vestir.tintColor = ColorConfig_Vestir.textPlaceholder_Vestir
        imageView_Vestir.contentMode = .scaleAspectFit
        return imageView_Vestir
    }()
    
    // MARK: - 属性

    /// 自定义占位符渐变颜色（外部注入，若设置则覆盖默认紫色配色，实现每张卡片颜色多样）
    var customPlaceholderColors_Vestir: [CGColor]? = nil

    private var mediaType_Vestir: MediaType_Vestir = .none_Vestir
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Vestir()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Vestir() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Vestir)
        addSubview(iconContainerView_Vestir)
        addSubview(placeholderIconView_Vestir)
        addSubview(playIconView_Vestir)
        playIconView_Vestir.addSubview(playIconImageView_Vestir)
        
        imageView_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Vestir.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Vestir.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Vestir.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 直接展示 UIImage 对象（从相册选取图片后使用，无需存储路径）
    /// - Parameter image_Vestir: 要展示的图片
    func configureWithImage_Vestir(image_Vestir: UIImage) {
        mediaType_Vestir = .image_Vestir
        clearOldContent_Vestir()
        imageView_Vestir.image = image_Vestir
        placeholderIconView_Vestir.isHidden = true
        playIconView_Vestir.isHidden = true
    }

    /// 配置媒体展示
    func configure_Vestir(mediaPath_Vestir: String?, isVideo_Vestir: Bool = false) {
        guard let path_Vestir = mediaPath_Vestir, !path_Vestir.isEmpty else {
            showPlaceholder_Vestir()
            return
        }
        
        mediaType_Vestir = isVideo_Vestir ? .video_Vestir : .image_Vestir
        playIconView_Vestir.isHidden = !isVideo_Vestir
        
        loadMedia_Vestir(path_Vestir: path_Vestir, isVideo_Vestir: isVideo_Vestir)
    }
    
    /// 加载媒体
    private func loadMedia_Vestir(path_Vestir: String, isVideo_Vestir: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Vestir = UIImage(systemName: path_Vestir) {
            loadSystemIcon_Vestir(image_Vestir: systemImage_Vestir, path_Vestir: path_Vestir)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Vestir = UIImage(named: path_Vestir) {
            loadImageSuccess_Vestir(image_Vestir: assetImage_Vestir)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Vestir.hasPrefix("http://") || path_Vestir.hasPrefix("https://") {
            loadNetworkImage_Vestir(urlString_Vestir: path_Vestir)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Vestir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Vestir = documentsPath_Vestir.appendingPathComponent(path_Vestir)
        
        if let documentImage_Vestir = UIImage(contentsOfFile: fileURL_Vestir.path) {
            loadImageSuccess_Vestir(image_Vestir: documentImage_Vestir)
            print("✅ 从文档目录加载媒体: \(path_Vestir)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Vestir = UIImage(contentsOfFile: path_Vestir) {
            loadImageSuccess_Vestir(image_Vestir: localImage_Vestir)
            return
        }

        // 6. 尝试从 Bundle 中加载视频文件并提取缩略图（mp4 / mov / m4v）
        if let videoURL_Vestir = bundleVideoURL_Vestir(named: path_Vestir) {
            mediaType_Vestir = .video_Vestir
            playIconView_Vestir.isHidden = false
            generateVideoThumbnail_Vestir(url_Vestir: videoURL_Vestir)
            return
        }

        // 7. 尝试从文档目录加载视频文件并提取缩略图
        for ext_Vestir in ["mp4", "mov", "m4v"] {
            let videoFileURL_Vestir = documentsPath_Vestir.appendingPathComponent("\(path_Vestir).\(ext_Vestir)")
            if FileManager.default.fileExists(atPath: videoFileURL_Vestir.path) {
                mediaType_Vestir = .video_Vestir
                playIconView_Vestir.isHidden = false
                generateVideoThumbnail_Vestir(url_Vestir: videoFileURL_Vestir)
                return
            }
        }
        
        // 8. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Vestir)")
        showPlaceholder_Vestir()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Vestir() {
        imageView_Vestir.image = nil
        imageView_Vestir.layer.sublayers?.removeAll()
        iconContainerView_Vestir.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Vestir(image_Vestir: UIImage, path_Vestir: String) {
        clearOldContent_Vestir()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Vestir = Self.gradientColors_Vestir[abs(path_Vestir.hashValue) % Self.gradientColors_Vestir.count]
        
        // 添加渐变背景
        let gradientColors_Vestir = [selectedGradient_Vestir.0.cgColor, selectedGradient_Vestir.1.cgColor]
        addGradientLayer_Vestir(colors_Vestir: gradientColors_Vestir)
        
        // 在独立容器上显示图标
        let iconImageView_Vestir = UIImageView(image: image_Vestir)
        iconImageView_Vestir.tintColor = .white
        iconImageView_Vestir.contentMode = .scaleAspectFit
        iconImageView_Vestir.alpha = 0.9
        iconContainerView_Vestir.addSubview(iconImageView_Vestir)
        iconImageView_Vestir.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Vestir.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Vestir(urlString_Vestir: String) {
        clearOldContent_Vestir()
        
        if let url_Vestir = URL(string: urlString_Vestir) {
            imageView_Vestir.kf.setImage(
                with: url_Vestir,
                placeholder: createPlaceholderImage_Vestir(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Vestir.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Vestir(image_Vestir: UIImage) {
        clearOldContent_Vestir()
        imageView_Vestir.image = image_Vestir
        placeholderIconView_Vestir.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Vestir(colors_Vestir: [CGColor]) {
        let gradientLayer_Vestir = CAGradientLayer()
        gradientLayer_Vestir.frame = bounds
        gradientLayer_Vestir.colors = colors_Vestir
        gradientLayer_Vestir.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Vestir.endPoint = CGPoint(x: 1, y: 1)
        imageView_Vestir.layer.insertSublayer(gradientLayer_Vestir, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Vestir() {
        mediaType_Vestir = .none_Vestir
        clearOldContent_Vestir()
        placeholderIconView_Vestir.isHidden = false
        playIconView_Vestir.isHidden = true

        // 优先使用外部注入的自定义渐变色，回退至默认紫色配色
        let colors_Vestir = customPlaceholderColors_Vestir ?? Self.placeholderGradientColors_Vestir
        addGradientLayer_Vestir(colors_Vestir: colors_Vestir)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Vestir() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Vestir.backgroundPrimary_Vestir.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Vestir = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Vestir
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Vestir == .none_Vestir {
            imageView_Vestir.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中按名称查找视频文件（依次尝试 mp4 / mov / m4v 扩展名）
    /// - Parameter named_Vestir: 不含扩展名的资源名
    /// - Returns: 找到时返回文件 URL，否则返回 nil
    static func bundleVideoURL_Vestir(named named_Vestir: String) -> URL? {
        for ext_Vestir in ["mp4", "mov", "m4v"] {
            if let url_Vestir = Bundle.main.url(forResource: named_Vestir, withExtension: ext_Vestir) {
                return url_Vestir
            }
        }
        return nil
    }

    /// 在 Bundle 中按名称查找视频文件（实例方法，内部调用静态版本）
    private func bundleVideoURL_Vestir(named named_Vestir: String) -> URL? {
        return MediaDisplayView_Vestir.bundleVideoURL_Vestir(named: named_Vestir)
    }

    /// 从视频 URL 异步提取第一帧作为缩略图，成功后刷新 imageView
    /// - Parameter url_Vestir: 视频文件 URL
    private func generateVideoThumbnail_Vestir(url_Vestir: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset_Vestir     = AVURLAsset(url: url_Vestir)
            let generator_Vestir = AVAssetImageGenerator(asset: asset_Vestir)
            generator_Vestir.appliesPreferredTrackTransform = true
            generator_Vestir.maximumSize = CGSize(width: 600, height: 600)
            let time_Vestir = CMTime(seconds: 0.1, preferredTimescale: 600)
            do {
                let cgImage_Vestir = try generator_Vestir.copyCGImage(at: time_Vestir, actualTime: nil)
                let thumb_Vestir   = UIImage(cgImage: cgImage_Vestir)
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Vestir(image_Vestir: thumb_Vestir)
                    self?.playIconView_Vestir.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Vestir() }
            }
        }
    }
}
