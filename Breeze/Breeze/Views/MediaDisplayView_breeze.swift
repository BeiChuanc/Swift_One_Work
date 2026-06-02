import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Breeze {
    case image_Breeze
    case video_Breeze
    case none_Breeze
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Breeze: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Breeze: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Breeze: "#667eea"), UIColor(hexstring_Breeze: "#764ba2")),  // 紫色
        (UIColor(hexstring_Breeze: "#f093fb"), UIColor(hexstring_Breeze: "#f5576c")),  // 粉红
        (UIColor(hexstring_Breeze: "#4facfe"), UIColor(hexstring_Breeze: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Breeze: "#43e97b"), UIColor(hexstring_Breeze: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Breeze: "#fa709a"), UIColor(hexstring_Breeze: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Breeze: [CGColor] = [
        UIColor(hexstring_Breeze: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Breeze: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Breeze: UIImageView = {
        let imageView_Breeze = UIImageView()
        imageView_Breeze.contentMode = .scaleAspectFill
        imageView_Breeze.clipsToBounds = true
        imageView_Breeze.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        imageView_Breeze.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Breeze
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Breeze: UIView = {
        let view_Breeze = UIView()
        view_Breeze.isUserInteractionEnabled = false
        return view_Breeze
    }()
    
    /// 视频播放图标
    private let playIconView_Breeze: UIView = {
        let view_Breeze = UIView()
        view_Breeze.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Breeze.layer.cornerRadius = 30
        view_Breeze.isHidden = true
        return view_Breeze
    }()
    
    private let playIconImageView_Breeze: UIImageView = {
        let imageView_Breeze = UIImageView()
        imageView_Breeze.image = UIImage(systemName: "play.fill")
        imageView_Breeze.tintColor = .white
        imageView_Breeze.contentMode = .scaleAspectFit
        return imageView_Breeze
    }()
    
    /// 占位符图标
    private let placeholderIconView_Breeze: UIImageView = {
        let imageView_Breeze = UIImageView()
        imageView_Breeze.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Breeze.tintColor = ColorConfig_Breeze.textPlaceholder_Breeze
        imageView_Breeze.contentMode = .scaleAspectFit
        return imageView_Breeze
    }()
    
    // MARK: - 属性
    
    private var mediaType_Breeze: MediaType_Breeze = .none_Breeze
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Breeze()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Breeze() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Breeze)
        addSubview(iconContainerView_Breeze)
        addSubview(placeholderIconView_Breeze)
        addSubview(playIconView_Breeze)
        playIconView_Breeze.addSubview(playIconImageView_Breeze)
        
        imageView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 直接展示 UIImage 对象（从相册选取图片后使用，无需存储路径）
    /// - Parameter image_Breeze: 要展示的图片
    func configureWithImage_Breeze(image_Breeze: UIImage) {
        mediaType_Breeze = .image_Breeze
        clearOldContent_Breeze()
        imageView_Breeze.image = image_Breeze
        placeholderIconView_Breeze.isHidden = true
        playIconView_Breeze.isHidden = true
    }

    /// 配置媒体展示
    func configure_Breeze(mediaPath_Breeze: String?, isVideo_Breeze: Bool = false) {
        guard let path_Breeze = mediaPath_Breeze, !path_Breeze.isEmpty else {
            showPlaceholder_Breeze()
            return
        }
        
        mediaType_Breeze = isVideo_Breeze ? .video_Breeze : .image_Breeze
        playIconView_Breeze.isHidden = !isVideo_Breeze
        
        loadMedia_Breeze(path_Breeze: path_Breeze, isVideo_Breeze: isVideo_Breeze)
    }
    
    /// 加载媒体
    private func loadMedia_Breeze(path_Breeze: String, isVideo_Breeze: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Breeze = UIImage(systemName: path_Breeze) {
            loadSystemIcon_Breeze(image_Breeze: systemImage_Breeze, path_Breeze: path_Breeze)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Breeze = UIImage(named: path_Breeze) {
            loadImageSuccess_Breeze(image_Breeze: assetImage_Breeze)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Breeze.hasPrefix("http://") || path_Breeze.hasPrefix("https://") {
            loadNetworkImage_Breeze(urlString_Breeze: path_Breeze)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Breeze = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Breeze = documentsPath_Breeze.appendingPathComponent(path_Breeze)
        
        if let documentImage_Breeze = UIImage(contentsOfFile: fileURL_Breeze.path) {
            loadImageSuccess_Breeze(image_Breeze: documentImage_Breeze)
            print("✅ 从文档目录加载媒体: \(path_Breeze)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Breeze = UIImage(contentsOfFile: path_Breeze) {
            loadImageSuccess_Breeze(image_Breeze: localImage_Breeze)
            return
        }

        // 6. 尝试从 Bundle 中加载视频文件并提取缩略图（mp4 / mov / m4v）
        if let videoURL_Breeze = bundleVideoURL_Breeze(named: path_Breeze) {
            mediaType_Breeze = .video_Breeze
            playIconView_Breeze.isHidden = false
            generateVideoThumbnail_Breeze(url_Breeze: videoURL_Breeze)
            return
        }

        // 7. 尝试从文档目录加载视频文件并提取缩略图
        for ext_Breeze in ["mp4", "mov", "m4v"] {
            let videoFileURL_Breeze = documentsPath_Breeze.appendingPathComponent("\(path_Breeze).\(ext_Breeze)")
            if FileManager.default.fileExists(atPath: videoFileURL_Breeze.path) {
                mediaType_Breeze = .video_Breeze
                playIconView_Breeze.isHidden = false
                generateVideoThumbnail_Breeze(url_Breeze: videoFileURL_Breeze)
                return
            }
        }
        
        // 8. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Breeze)")
        showPlaceholder_Breeze()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Breeze() {
        imageView_Breeze.image = nil
        imageView_Breeze.layer.sublayers?.removeAll()
        iconContainerView_Breeze.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Breeze(image_Breeze: UIImage, path_Breeze: String) {
        clearOldContent_Breeze()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Breeze = Self.gradientColors_Breeze[abs(path_Breeze.hashValue) % Self.gradientColors_Breeze.count]
        
        // 添加渐变背景
        let gradientColors_Breeze = [selectedGradient_Breeze.0.cgColor, selectedGradient_Breeze.1.cgColor]
        addGradientLayer_Breeze(colors_Breeze: gradientColors_Breeze)
        
        // 在独立容器上显示图标
        let iconImageView_Breeze = UIImageView(image: image_Breeze)
        iconImageView_Breeze.tintColor = .white
        iconImageView_Breeze.contentMode = .scaleAspectFit
        iconImageView_Breeze.alpha = 0.9
        iconContainerView_Breeze.addSubview(iconImageView_Breeze)
        iconImageView_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Breeze.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Breeze(urlString_Breeze: String) {
        clearOldContent_Breeze()
        
        if let url_Breeze = URL(string: urlString_Breeze) {
            imageView_Breeze.kf.setImage(
                with: url_Breeze,
                placeholder: createPlaceholderImage_Breeze(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Breeze.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Breeze(image_Breeze: UIImage) {
        clearOldContent_Breeze()
        imageView_Breeze.image = image_Breeze
        placeholderIconView_Breeze.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Breeze(colors_Breeze: [CGColor]) {
        let gradientLayer_Breeze = CAGradientLayer()
        gradientLayer_Breeze.frame = bounds
        gradientLayer_Breeze.colors = colors_Breeze
        gradientLayer_Breeze.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Breeze.endPoint = CGPoint(x: 1, y: 1)
        imageView_Breeze.layer.insertSublayer(gradientLayer_Breeze, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Breeze() {
        mediaType_Breeze = .none_Breeze
        clearOldContent_Breeze()
        placeholderIconView_Breeze.isHidden = false
        playIconView_Breeze.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Breeze(colors_Breeze: Self.placeholderGradientColors_Breeze)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Breeze() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Breeze.backgroundPrimary_Breeze.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Breeze = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Breeze
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Breeze == .none_Breeze {
            imageView_Breeze.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中按名称查找视频文件（依次尝试 mp4 / mov / m4v 扩展名）
    /// - Parameter named_Breeze: 不含扩展名的资源名
    /// - Returns: 找到时返回文件 URL，否则返回 nil
    static func bundleVideoURL_Breeze(named named_Breeze: String) -> URL? {
        for ext_Breeze in ["mp4", "mov", "m4v"] {
            if let url_Breeze = Bundle.main.url(forResource: named_Breeze, withExtension: ext_Breeze) {
                return url_Breeze
            }
        }
        return nil
    }

    /// 在 Bundle 中按名称查找视频文件（实例方法，内部调用静态版本）
    private func bundleVideoURL_Breeze(named named_Breeze: String) -> URL? {
        return MediaDisplayView_Breeze.bundleVideoURL_Breeze(named: named_Breeze)
    }

    /// 从视频 URL 异步提取第一帧作为缩略图，成功后刷新 imageView
    /// - Parameter url_Breeze: 视频文件 URL
    private func generateVideoThumbnail_Breeze(url_Breeze: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset_Breeze     = AVURLAsset(url: url_Breeze)
            let generator_Breeze = AVAssetImageGenerator(asset: asset_Breeze)
            generator_Breeze.appliesPreferredTrackTransform = true
            generator_Breeze.maximumSize = CGSize(width: 600, height: 600)
            let time_Breeze = CMTime(seconds: 0.1, preferredTimescale: 600)
            do {
                let cgImage_Breeze = try generator_Breeze.copyCGImage(at: time_Breeze, actualTime: nil)
                let thumb_Breeze   = UIImage(cgImage: cgImage_Breeze)
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Breeze(image_Breeze: thumb_Breeze)
                    self?.playIconView_Breeze.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Breeze() }
            }
        }
    }
}
