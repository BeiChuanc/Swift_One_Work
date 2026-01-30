import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Base_one {
    case image_Base_one
    case video_Base_one
    case none_Base_one
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Base_one: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Base_one: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Base_one: "#667eea"), UIColor(hexstring_Base_one: "#764ba2")),  // 紫色
        (UIColor(hexstring_Base_one: "#f093fb"), UIColor(hexstring_Base_one: "#f5576c")),  // 粉红
        (UIColor(hexstring_Base_one: "#4facfe"), UIColor(hexstring_Base_one: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Base_one: "#43e97b"), UIColor(hexstring_Base_one: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Base_one: "#fa709a"), UIColor(hexstring_Base_one: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Base_one: [CGColor] = [
        UIColor(hexstring_Base_one: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Base_one: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Base_one: UIImageView = {
        let imageView_Base_one = UIImageView()
        imageView_Base_one.contentMode = .scaleAspectFill
        imageView_Base_one.clipsToBounds = true
        imageView_Base_one.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        imageView_Base_one.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Base_one
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Base_one: UIView = {
        let view_Base_one = UIView()
        view_Base_one.isUserInteractionEnabled = false
        return view_Base_one
    }()
    
    /// 视频播放图标
    private let playIconView_Base_one: UIView = {
        let view_Base_one = UIView()
        view_Base_one.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Base_one.layer.cornerRadius = 30
        view_Base_one.isHidden = true
        return view_Base_one
    }()
    
    private let playIconImageView_Base_one: UIImageView = {
        let imageView_Base_one = UIImageView()
        imageView_Base_one.image = UIImage(systemName: "play.fill")
        imageView_Base_one.tintColor = .white
        imageView_Base_one.contentMode = .scaleAspectFit
        return imageView_Base_one
    }()
    
    /// 占位符图标
    private let placeholderIconView_Base_one: UIImageView = {
        let imageView_Base_one = UIImageView()
        imageView_Base_one.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Base_one.tintColor = ColorConfig_Base_one.textPlaceholder_Base_one
        imageView_Base_one.contentMode = .scaleAspectFit
        return imageView_Base_one
    }()
    
    // MARK: - 属性
    
    private var mediaType_Base_one: MediaType_Base_one = .none_Base_one
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Base_one()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Base_one() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Base_one)
        addSubview(iconContainerView_Base_one)
        addSubview(placeholderIconView_Base_one)
        addSubview(playIconView_Base_one)
        playIconView_Base_one.addSubview(playIconImageView_Base_one)
        
        imageView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 配置媒体展示
    func configure_Base_one(mediaPath_Base_one: String?, isVideo_Base_one: Bool = false) {
        guard let path_Base_one = mediaPath_Base_one, !path_Base_one.isEmpty else {
            showPlaceholder_Base_one()
            return
        }
        
        mediaType_Base_one = isVideo_Base_one ? .video_Base_one : .image_Base_one
        playIconView_Base_one.isHidden = !isVideo_Base_one
        
        loadMedia_Base_one(path_Base_one: path_Base_one, isVideo_Base_one: isVideo_Base_one)
    }
    
    /// 加载媒体
    private func loadMedia_Base_one(path_Base_one: String, isVideo_Base_one: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Base_one = UIImage(systemName: path_Base_one) {
            loadSystemIcon_Base_one(image_Base_one: systemImage_Base_one, path_Base_one: path_Base_one)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Base_one = UIImage(named: path_Base_one) {
            loadImageSuccess_Base_one(image_Base_one: assetImage_Base_one)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Base_one.hasPrefix("http://") || path_Base_one.hasPrefix("https://") {
            loadNetworkImage_Base_one(urlString_Base_one: path_Base_one)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Base_one = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Base_one = documentsPath_Base_one.appendingPathComponent(path_Base_one)
        
        if let documentImage_Base_one = UIImage(contentsOfFile: fileURL_Base_one.path) {
            loadImageSuccess_Base_one(image_Base_one: documentImage_Base_one)
            print("✅ 从文档目录加载媒体: \(path_Base_one)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Base_one = UIImage(contentsOfFile: path_Base_one) {
            loadImageSuccess_Base_one(image_Base_one: localImage_Base_one)
            return
        }
        
        // 6. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Base_one)")
        showPlaceholder_Base_one()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Base_one() {
        imageView_Base_one.image = nil
        imageView_Base_one.layer.sublayers?.removeAll()
        iconContainerView_Base_one.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Base_one(image_Base_one: UIImage, path_Base_one: String) {
        clearOldContent_Base_one()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Base_one = Self.gradientColors_Base_one[abs(path_Base_one.hashValue) % Self.gradientColors_Base_one.count]
        
        // 添加渐变背景
        let gradientColors_Base_one = [selectedGradient_Base_one.0.cgColor, selectedGradient_Base_one.1.cgColor]
        addGradientLayer_Base_one(colors_Base_one: gradientColors_Base_one)
        
        // 在独立容器上显示图标
        let iconImageView_Base_one = UIImageView(image: image_Base_one)
        iconImageView_Base_one.tintColor = .white
        iconImageView_Base_one.contentMode = .scaleAspectFit
        iconImageView_Base_one.alpha = 0.9
        iconContainerView_Base_one.addSubview(iconImageView_Base_one)
        iconImageView_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Base_one.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Base_one(urlString_Base_one: String) {
        clearOldContent_Base_one()
        
        if let url_Base_one = URL(string: urlString_Base_one) {
            imageView_Base_one.kf.setImage(
                with: url_Base_one,
                placeholder: createPlaceholderImage_Base_one(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Base_one.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Base_one(image_Base_one: UIImage) {
        clearOldContent_Base_one()
        imageView_Base_one.image = image_Base_one
        placeholderIconView_Base_one.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Base_one(colors_Base_one: [CGColor]) {
        let gradientLayer_Base_one = CAGradientLayer()
        gradientLayer_Base_one.frame = bounds
        gradientLayer_Base_one.colors = colors_Base_one
        gradientLayer_Base_one.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Base_one.endPoint = CGPoint(x: 1, y: 1)
        imageView_Base_one.layer.insertSublayer(gradientLayer_Base_one, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Base_one() {
        mediaType_Base_one = .none_Base_one
        clearOldContent_Base_one()
        placeholderIconView_Base_one.isHidden = false
        playIconView_Base_one.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Base_one(colors_Base_one: Self.placeholderGradientColors_Base_one)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Base_one() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Base_one.backgroundPrimary_Base_one.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Base_one = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Base_one
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Base_one == .none_Base_one {
            imageView_Base_one.layer.sublayers?.first?.frame = bounds
        }
    }
}
