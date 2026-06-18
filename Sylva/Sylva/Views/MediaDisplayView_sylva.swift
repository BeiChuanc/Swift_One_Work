import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Sylva {
    case image_Sylva
    case video_Sylva
    case none_Sylva
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Sylva: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Sylva: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Sylva: "#667eea"), UIColor(hexstring_Sylva: "#764ba2")),  // 紫色
        (UIColor(hexstring_Sylva: "#f093fb"), UIColor(hexstring_Sylva: "#f5576c")),  // 粉红
        (UIColor(hexstring_Sylva: "#4facfe"), UIColor(hexstring_Sylva: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Sylva: "#43e97b"), UIColor(hexstring_Sylva: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Sylva: "#fa709a"), UIColor(hexstring_Sylva: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Sylva: [CGColor] = [
        UIColor(hexstring_Sylva: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Sylva: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Sylva: UIImageView = {
        let imageView_Sylva = UIImageView()
        imageView_Sylva.contentMode = .scaleAspectFill
        imageView_Sylva.clipsToBounds = true
        imageView_Sylva.backgroundColor = ColorConfig_Sylva.backgroundPrimary_Sylva
        imageView_Sylva.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Sylva
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Sylva: UIView = {
        let view_Sylva = UIView()
        view_Sylva.isUserInteractionEnabled = false
        return view_Sylva
    }()
    
    /// 视频播放图标
    private let playIconView_Sylva: UIView = {
        let view_Sylva = UIView()
        view_Sylva.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Sylva.layer.cornerRadius = 30
        view_Sylva.isHidden = true
        return view_Sylva
    }()
    
    private let playIconImageView_Sylva: UIImageView = {
        let imageView_Sylva = UIImageView()
        imageView_Sylva.image = UIImage(systemName: "play.fill")
        imageView_Sylva.tintColor = .white
        imageView_Sylva.contentMode = .scaleAspectFit
        return imageView_Sylva
    }()
    
    /// 占位符图标
    private let placeholderIconView_Sylva: UIImageView = {
        let imageView_Sylva = UIImageView()
        imageView_Sylva.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Sylva.tintColor = ColorConfig_Sylva.textPlaceholder_Sylva
        imageView_Sylva.contentMode = .scaleAspectFit
        return imageView_Sylva
    }()
    
    // MARK: - 属性
    
    private var mediaType_Sylva: MediaType_Sylva = .none_Sylva
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Sylva()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Sylva() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Sylva)
        addSubview(iconContainerView_Sylva)
        addSubview(placeholderIconView_Sylva)
        addSubview(playIconView_Sylva)
        playIconView_Sylva.addSubview(playIconImageView_Sylva)
        
        imageView_Sylva.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Sylva.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Sylva.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Sylva.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Sylva.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 直接展示 UIImage 对象（从相册选取图片后使用，无需存储路径）
    /// - Parameter image_Sylva: 要展示的图片
    func configureWithImage_Sylva(image_Sylva: UIImage) {
        mediaType_Sylva = .image_Sylva
        clearOldContent_Sylva()
        imageView_Sylva.image = image_Sylva
        placeholderIconView_Sylva.isHidden = true
        playIconView_Sylva.isHidden = true
    }

    /// 配置媒体展示
    func configure_Sylva(mediaPath_Sylva: String?, isVideo_Sylva: Bool = false) {
        guard let path_Sylva = mediaPath_Sylva, !path_Sylva.isEmpty else {
            showPlaceholder_Sylva()
            return
        }
        
        mediaType_Sylva = isVideo_Sylva ? .video_Sylva : .image_Sylva
        playIconView_Sylva.isHidden = !isVideo_Sylva
        
        loadMedia_Sylva(path_Sylva: path_Sylva, isVideo_Sylva: isVideo_Sylva)
    }
    
    /// 加载媒体
    private func loadMedia_Sylva(path_Sylva: String, isVideo_Sylva: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Sylva = UIImage(systemName: path_Sylva) {
            loadSystemIcon_Sylva(image_Sylva: systemImage_Sylva, path_Sylva: path_Sylva)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Sylva = UIImage(named: path_Sylva) {
            loadImageSuccess_Sylva(image_Sylva: assetImage_Sylva)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Sylva.hasPrefix("http://") || path_Sylva.hasPrefix("https://") {
            loadNetworkImage_Sylva(urlString_Sylva: path_Sylva)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Sylva = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Sylva = documentsPath_Sylva.appendingPathComponent(path_Sylva)
        
        if let documentImage_Sylva = UIImage(contentsOfFile: fileURL_Sylva.path) {
            loadImageSuccess_Sylva(image_Sylva: documentImage_Sylva)
            print("✅ 从文档目录加载媒体: \(path_Sylva)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Sylva = UIImage(contentsOfFile: path_Sylva) {
            loadImageSuccess_Sylva(image_Sylva: localImage_Sylva)
            return
        }

        // 6. 尝试从 Bundle 中加载视频文件并提取缩略图（mp4 / mov / m4v）
        if let videoURL_Sylva = bundleVideoURL_Sylva(named: path_Sylva) {
            mediaType_Sylva = .video_Sylva
            playIconView_Sylva.isHidden = false
            generateVideoThumbnail_Sylva(url_Sylva: videoURL_Sylva)
            return
        }

        // 7. 尝试从文档目录加载视频文件并提取缩略图
        for ext_Sylva in ["mp4", "mov", "m4v"] {
            let videoFileURL_Sylva = documentsPath_Sylva.appendingPathComponent("\(path_Sylva).\(ext_Sylva)")
            if FileManager.default.fileExists(atPath: videoFileURL_Sylva.path) {
                mediaType_Sylva = .video_Sylva
                playIconView_Sylva.isHidden = false
                generateVideoThumbnail_Sylva(url_Sylva: videoFileURL_Sylva)
                return
            }
        }
        
        // 8. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Sylva)")
        showPlaceholder_Sylva()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Sylva() {
        imageView_Sylva.image = nil
        imageView_Sylva.layer.sublayers?.removeAll()
        iconContainerView_Sylva.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Sylva(image_Sylva: UIImage, path_Sylva: String) {
        clearOldContent_Sylva()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Sylva = Self.gradientColors_Sylva[abs(path_Sylva.hashValue) % Self.gradientColors_Sylva.count]
        
        // 添加渐变背景
        let gradientColors_Sylva = [selectedGradient_Sylva.0.cgColor, selectedGradient_Sylva.1.cgColor]
        addGradientLayer_Sylva(colors_Sylva: gradientColors_Sylva)
        
        // 在独立容器上显示图标
        let iconImageView_Sylva = UIImageView(image: image_Sylva)
        iconImageView_Sylva.tintColor = .white
        iconImageView_Sylva.contentMode = .scaleAspectFit
        iconImageView_Sylva.alpha = 0.9
        iconContainerView_Sylva.addSubview(iconImageView_Sylva)
        iconImageView_Sylva.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Sylva.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Sylva(urlString_Sylva: String) {
        clearOldContent_Sylva()
        
        if let url_Sylva = URL(string: urlString_Sylva) {
            imageView_Sylva.kf.setImage(
                with: url_Sylva,
                placeholder: createPlaceholderImage_Sylva(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Sylva.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Sylva(image_Sylva: UIImage) {
        clearOldContent_Sylva()
        imageView_Sylva.image = image_Sylva
        placeholderIconView_Sylva.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Sylva(colors_Sylva: [CGColor]) {
        let gradientLayer_Sylva = CAGradientLayer()
        gradientLayer_Sylva.frame = bounds
        gradientLayer_Sylva.colors = colors_Sylva
        gradientLayer_Sylva.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Sylva.endPoint = CGPoint(x: 1, y: 1)
        imageView_Sylva.layer.insertSublayer(gradientLayer_Sylva, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Sylva() {
        mediaType_Sylva = .none_Sylva
        clearOldContent_Sylva()
        placeholderIconView_Sylva.isHidden = false
        playIconView_Sylva.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Sylva(colors_Sylva: Self.placeholderGradientColors_Sylva)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Sylva() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Sylva.backgroundPrimary_Sylva.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Sylva = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Sylva
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Sylva == .none_Sylva {
            imageView_Sylva.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中按名称查找视频文件（依次尝试 mp4 / mov / m4v 扩展名）
    /// - Parameter named_Sylva: 不含扩展名的资源名
    /// - Returns: 找到时返回文件 URL，否则返回 nil
    static func bundleVideoURL_Sylva(named named_Sylva: String) -> URL? {
        for ext_Sylva in ["mp4", "mov", "m4v"] {
            if let url_Sylva = Bundle.main.url(forResource: named_Sylva, withExtension: ext_Sylva) {
                return url_Sylva
            }
        }
        return nil
    }

    /// 在 Bundle 中按名称查找视频文件（实例方法，内部调用静态版本）
    private func bundleVideoURL_Sylva(named named_Sylva: String) -> URL? {
        return MediaDisplayView_Sylva.bundleVideoURL_Sylva(named: named_Sylva)
    }

    /// 从视频 URL 异步提取第一帧作为缩略图，成功后刷新 imageView
    /// - Parameter url_Sylva: 视频文件 URL
    private func generateVideoThumbnail_Sylva(url_Sylva: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset_Sylva     = AVURLAsset(url: url_Sylva)
            let generator_Sylva = AVAssetImageGenerator(asset: asset_Sylva)
            generator_Sylva.appliesPreferredTrackTransform = true
            generator_Sylva.maximumSize = CGSize(width: 600, height: 600)
            let time_Sylva = CMTime(seconds: 0.1, preferredTimescale: 600)
            do {
                let cgImage_Sylva = try generator_Sylva.copyCGImage(at: time_Sylva, actualTime: nil)
                let thumb_Sylva   = UIImage(cgImage: cgImage_Sylva)
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Sylva(image_Sylva: thumb_Sylva)
                    self?.playIconView_Sylva.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Sylva() }
            }
        }
    }
}
