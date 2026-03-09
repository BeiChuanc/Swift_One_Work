import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Moode {
    case image_Moode
    case video_Moode
    case none_Moode
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Moode: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Moode: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Moode: "#667eea"), UIColor(hexstring_Moode: "#764ba2")),  // 紫色
        (UIColor(hexstring_Moode: "#f093fb"), UIColor(hexstring_Moode: "#f5576c")),  // 粉红
        (UIColor(hexstring_Moode: "#4facfe"), UIColor(hexstring_Moode: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Moode: "#43e97b"), UIColor(hexstring_Moode: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Moode: "#fa709a"), UIColor(hexstring_Moode: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Moode: [CGColor] = [
        UIColor(hexstring_Moode: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Moode: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Moode: UIImageView = {
        let imageView_Moode = UIImageView()
        imageView_Moode.contentMode = .scaleAspectFill
        imageView_Moode.clipsToBounds = true
        imageView_Moode.backgroundColor = ColorConfig_Moode.backgroundPrimary_Moode
        imageView_Moode.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Moode
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Moode: UIView = {
        let view_Moode = UIView()
        view_Moode.isUserInteractionEnabled = false
        return view_Moode
    }()
    
    /// 视频播放图标
    private let playIconView_Moode: UIView = {
        let view_Moode = UIView()
        view_Moode.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Moode.layer.cornerRadius = 30
        view_Moode.isHidden = true
        return view_Moode
    }()
    
    private let playIconImageView_Moode: UIImageView = {
        let imageView_Moode = UIImageView()
        imageView_Moode.image = UIImage(systemName: "play.fill")
        imageView_Moode.tintColor = .white
        imageView_Moode.contentMode = .scaleAspectFit
        return imageView_Moode
    }()
    
    /// 占位符图标
    private let placeholderIconView_Moode: UIImageView = {
        let imageView_Moode = UIImageView()
        imageView_Moode.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Moode.tintColor = ColorConfig_Moode.textPlaceholder_Moode
        imageView_Moode.contentMode = .scaleAspectFit
        return imageView_Moode
    }()
    
    // MARK: - 属性
    
    private var mediaType_Moode: MediaType_Moode = .none_Moode
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Moode()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Moode() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Moode)
        addSubview(iconContainerView_Moode)
        addSubview(placeholderIconView_Moode)
        addSubview(playIconView_Moode)
        playIconView_Moode.addSubview(playIconImageView_Moode)
        
        imageView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 配置媒体展示
    func configure_Moode(mediaPath_Moode: String?, isVideo_Moode: Bool = false) {
        guard let path_Moode = mediaPath_Moode, !path_Moode.isEmpty else {
            showPlaceholder_Moode()
            return
        }
        
        mediaType_Moode = isVideo_Moode ? .video_Moode : .image_Moode
        playIconView_Moode.isHidden = !isVideo_Moode
        
        loadMedia_Moode(path_Moode: path_Moode, isVideo_Moode: isVideo_Moode)
    }
    
    /// 加载媒体
    private func loadMedia_Moode(path_Moode: String, isVideo_Moode: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Moode = UIImage(systemName: path_Moode) {
            loadSystemIcon_Moode(image_Moode: systemImage_Moode, path_Moode: path_Moode)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Moode = UIImage(named: path_Moode) {
            loadImageSuccess_Moode(image_Moode: assetImage_Moode)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Moode.hasPrefix("http://") || path_Moode.hasPrefix("https://") {
            loadNetworkImage_Moode(urlString_Moode: path_Moode)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Moode = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Moode = documentsPath_Moode.appendingPathComponent(path_Moode)
        
        if let documentImage_Moode = UIImage(contentsOfFile: fileURL_Moode.path) {
            loadImageSuccess_Moode(image_Moode: documentImage_Moode)
            print("✅ 从文档目录加载媒体: \(path_Moode)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Moode = UIImage(contentsOfFile: path_Moode) {
            loadImageSuccess_Moode(image_Moode: localImage_Moode)
            return
        }
        
        // 6. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Moode)")
        showPlaceholder_Moode()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Moode() {
        imageView_Moode.image = nil
        imageView_Moode.layer.sublayers?.removeAll()
        iconContainerView_Moode.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Moode(image_Moode: UIImage, path_Moode: String) {
        clearOldContent_Moode()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Moode = Self.gradientColors_Moode[abs(path_Moode.hashValue) % Self.gradientColors_Moode.count]
        
        // 添加渐变背景
        let gradientColors_Moode = [selectedGradient_Moode.0.cgColor, selectedGradient_Moode.1.cgColor]
        addGradientLayer_Moode(colors_Moode: gradientColors_Moode)
        
        // 在独立容器上显示图标
        let iconImageView_Moode = UIImageView(image: image_Moode)
        iconImageView_Moode.tintColor = .white
        iconImageView_Moode.contentMode = .scaleAspectFit
        iconImageView_Moode.alpha = 0.9
        iconContainerView_Moode.addSubview(iconImageView_Moode)
        iconImageView_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Moode.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Moode(urlString_Moode: String) {
        clearOldContent_Moode()
        
        if let url_Moode = URL(string: urlString_Moode) {
            imageView_Moode.kf.setImage(
                with: url_Moode,
                placeholder: createPlaceholderImage_Moode(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Moode.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Moode(image_Moode: UIImage) {
        clearOldContent_Moode()
        imageView_Moode.image = image_Moode
        placeholderIconView_Moode.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Moode(colors_Moode: [CGColor]) {
        let gradientLayer_Moode = CAGradientLayer()
        gradientLayer_Moode.frame = bounds
        gradientLayer_Moode.colors = colors_Moode
        gradientLayer_Moode.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Moode.endPoint = CGPoint(x: 1, y: 1)
        imageView_Moode.layer.insertSublayer(gradientLayer_Moode, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Moode() {
        mediaType_Moode = .none_Moode
        clearOldContent_Moode()
        placeholderIconView_Moode.isHidden = false
        playIconView_Moode.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Moode(colors_Moode: Self.placeholderGradientColors_Moode)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Moode() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Moode.backgroundPrimary_Moode.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Moode = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Moode
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Moode == .none_Moode {
            imageView_Moode.layer.sublayers?.first?.frame = bounds
        }
    }
}
