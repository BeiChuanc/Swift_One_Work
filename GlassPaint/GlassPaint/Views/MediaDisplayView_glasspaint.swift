import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Glasspaint {
    case image_Glasspaint
    case video_Glasspaint
    case none_Glasspaint
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Glasspaint: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Glasspaint: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Glasspaint: "#667eea"), UIColor(hexstring_Glasspaint: "#764ba2")),  // 紫色
        (UIColor(hexstring_Glasspaint: "#f093fb"), UIColor(hexstring_Glasspaint: "#f5576c")),  // 粉红
        (UIColor(hexstring_Glasspaint: "#4facfe"), UIColor(hexstring_Glasspaint: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Glasspaint: "#43e97b"), UIColor(hexstring_Glasspaint: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Glasspaint: "#fa709a"), UIColor(hexstring_Glasspaint: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Glasspaint: [CGColor] = [
        UIColor(hexstring_Glasspaint: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Glasspaint: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Glasspaint: UIImageView = {
        let imageView_Glasspaint = UIImageView()
        imageView_Glasspaint.contentMode = .scaleAspectFill
        imageView_Glasspaint.clipsToBounds = true
        imageView_Glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        imageView_Glasspaint.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Glasspaint
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Glasspaint: UIView = {
        let view_Glasspaint = UIView()
        view_Glasspaint.isUserInteractionEnabled = false
        return view_Glasspaint
    }()
    
    /// 视频播放图标
    private let playIconView_Glasspaint: UIView = {
        let view_Glasspaint = UIView()
        view_Glasspaint.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Glasspaint.layer.cornerRadius = 30
        view_Glasspaint.isHidden = true
        return view_Glasspaint
    }()
    
    private let playIconImageView_Glasspaint: UIImageView = {
        let imageView_Glasspaint = UIImageView()
        imageView_Glasspaint.image = UIImage(systemName: "play.fill")
        imageView_Glasspaint.tintColor = .white
        imageView_Glasspaint.contentMode = .scaleAspectFit
        return imageView_Glasspaint
    }()
    
    /// 占位符图标
    private let placeholderIconView_Glasspaint: UIImageView = {
        let imageView_Glasspaint = UIImageView()
        imageView_Glasspaint.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Glasspaint.tintColor = ColorConfig_Glasspaint.textPlaceholder_Glasspaint
        imageView_Glasspaint.contentMode = .scaleAspectFit
        return imageView_Glasspaint
    }()
    
    // MARK: - 属性
    
    private var mediaType_Glasspaint: MediaType_Glasspaint = .none_Glasspaint
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Glasspaint() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Glasspaint)
        addSubview(iconContainerView_Glasspaint)
        addSubview(placeholderIconView_Glasspaint)
        addSubview(playIconView_Glasspaint)
        playIconView_Glasspaint.addSubview(playIconImageView_Glasspaint)
        
        imageView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 配置媒体展示
    func configure_Glasspaint(mediaPath_Glasspaint: String?, isVideo_Glasspaint: Bool = false) {
        guard let path_Glasspaint = mediaPath_Glasspaint, !path_Glasspaint.isEmpty else {
            showPlaceholder_Glasspaint()
            return
        }
        
        mediaType_Glasspaint = isVideo_Glasspaint ? .video_Glasspaint : .image_Glasspaint
        playIconView_Glasspaint.isHidden = !isVideo_Glasspaint
        
        loadMedia_Glasspaint(path_Glasspaint: path_Glasspaint, isVideo_Glasspaint: isVideo_Glasspaint)
    }
    
    /// 加载媒体
    private func loadMedia_Glasspaint(path_Glasspaint: String, isVideo_Glasspaint: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Glasspaint = UIImage(systemName: path_Glasspaint) {
            loadSystemIcon_Glasspaint(image_Glasspaint: systemImage_Glasspaint, path_Glasspaint: path_Glasspaint)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Glasspaint = UIImage(named: path_Glasspaint) {
            loadImageSuccess_Glasspaint(image_Glasspaint: assetImage_Glasspaint)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Glasspaint.hasPrefix("http://") || path_Glasspaint.hasPrefix("https://") {
            loadNetworkImage_Glasspaint(urlString_Glasspaint: path_Glasspaint)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Glasspaint = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Glasspaint = documentsPath_Glasspaint.appendingPathComponent(path_Glasspaint)
        
        if let documentImage_Glasspaint = UIImage(contentsOfFile: fileURL_Glasspaint.path) {
            loadImageSuccess_Glasspaint(image_Glasspaint: documentImage_Glasspaint)
            print("✅ 从文档目录加载媒体: \(path_Glasspaint)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Glasspaint = UIImage(contentsOfFile: path_Glasspaint) {
            loadImageSuccess_Glasspaint(image_Glasspaint: localImage_Glasspaint)
            return
        }
        
        // 6. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Glasspaint)")
        showPlaceholder_Glasspaint()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Glasspaint() {
        imageView_Glasspaint.image = nil
        imageView_Glasspaint.layer.sublayers?.removeAll()
        iconContainerView_Glasspaint.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Glasspaint(image_Glasspaint: UIImage, path_Glasspaint: String) {
        clearOldContent_Glasspaint()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Glasspaint = Self.gradientColors_Glasspaint[abs(path_Glasspaint.hashValue) % Self.gradientColors_Glasspaint.count]
        
        // 添加渐变背景
        let gradientColors_Glasspaint = [selectedGradient_Glasspaint.0.cgColor, selectedGradient_Glasspaint.1.cgColor]
        addGradientLayer_Glasspaint(colors_Glasspaint: gradientColors_Glasspaint)
        
        // 在独立容器上显示图标
        let iconImageView_Glasspaint = UIImageView(image: image_Glasspaint)
        iconImageView_Glasspaint.tintColor = .white
        iconImageView_Glasspaint.contentMode = .scaleAspectFit
        iconImageView_Glasspaint.alpha = 0.9
        iconContainerView_Glasspaint.addSubview(iconImageView_Glasspaint)
        iconImageView_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Glasspaint.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Glasspaint(urlString_Glasspaint: String) {
        clearOldContent_Glasspaint()
        
        if let url_Glasspaint = URL(string: urlString_Glasspaint) {
            imageView_Glasspaint.kf.setImage(
                with: url_Glasspaint,
                placeholder: createPlaceholderImage_Glasspaint(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Glasspaint.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Glasspaint(image_Glasspaint: UIImage) {
        clearOldContent_Glasspaint()
        imageView_Glasspaint.image = image_Glasspaint
        placeholderIconView_Glasspaint.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Glasspaint(colors_Glasspaint: [CGColor]) {
        let gradientLayer_Glasspaint = CAGradientLayer()
        gradientLayer_Glasspaint.frame = bounds
        gradientLayer_Glasspaint.colors = colors_Glasspaint
        gradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        imageView_Glasspaint.layer.insertSublayer(gradientLayer_Glasspaint, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Glasspaint() {
        mediaType_Glasspaint = .none_Glasspaint
        clearOldContent_Glasspaint()
        placeholderIconView_Glasspaint.isHidden = false
        playIconView_Glasspaint.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Glasspaint(colors_Glasspaint: Self.placeholderGradientColors_Glasspaint)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Glasspaint() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Glasspaint.backgroundPrimary_Glasspaint.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Glasspaint = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Glasspaint
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Glasspaint == .none_Glasspaint {
            imageView_Glasspaint.layer.sublayers?.first?.frame = bounds
        }
    }
}
