import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Doze {
    case image_Doze
    case video_Doze
    case none_Doze
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Doze: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Doze: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Doze: "#667eea"), UIColor(hexstring_Doze: "#764ba2")),  // 紫色
        (UIColor(hexstring_Doze: "#f093fb"), UIColor(hexstring_Doze: "#f5576c")),  // 粉红
        (UIColor(hexstring_Doze: "#4facfe"), UIColor(hexstring_Doze: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Doze: "#43e97b"), UIColor(hexstring_Doze: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Doze: "#fa709a"), UIColor(hexstring_Doze: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Doze: [CGColor] = [
        UIColor(hexstring_Doze: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Doze: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Doze: UIImageView = {
        let imageView_Doze = UIImageView()
        imageView_Doze.contentMode = .scaleAspectFill
        imageView_Doze.clipsToBounds = true
        imageView_Doze.backgroundColor = ColorConfig_Doze.backgroundPrimary_Doze
        imageView_Doze.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Doze
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Doze: UIView = {
        let view_Doze = UIView()
        view_Doze.isUserInteractionEnabled = false
        return view_Doze
    }()
    
    /// 视频播放图标
    private let playIconView_Doze: UIView = {
        let view_Doze = UIView()
        view_Doze.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Doze.layer.cornerRadius = 30
        view_Doze.isHidden = true
        return view_Doze
    }()
    
    private let playIconImageView_Doze: UIImageView = {
        let imageView_Doze = UIImageView()
        imageView_Doze.image = UIImage(systemName: "play.fill")
        imageView_Doze.tintColor = .white
        imageView_Doze.contentMode = .scaleAspectFit
        return imageView_Doze
    }()
    
    /// 占位符图标
    private let placeholderIconView_Doze: UIImageView = {
        let imageView_Doze = UIImageView()
        imageView_Doze.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Doze.tintColor = ColorConfig_Doze.textPlaceholder_Doze
        imageView_Doze.contentMode = .scaleAspectFit
        return imageView_Doze
    }()
    
    // MARK: - 属性
    
    private var mediaType_Doze: MediaType_Doze = .none_Doze
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Doze()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Doze() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Doze)
        addSubview(iconContainerView_Doze)
        addSubview(placeholderIconView_Doze)
        addSubview(playIconView_Doze)
        playIconView_Doze.addSubview(playIconImageView_Doze)
        
        imageView_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Doze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Doze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Doze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 配置媒体展示
    func configure_Doze(mediaPath_Doze: String?, isVideo_Doze: Bool = false) {
        guard let path_Doze = mediaPath_Doze, !path_Doze.isEmpty else {
            showPlaceholder_Doze()
            return
        }
        
        mediaType_Doze = isVideo_Doze ? .video_Doze : .image_Doze
        playIconView_Doze.isHidden = !isVideo_Doze
        
        loadMedia_Doze(path_Doze: path_Doze, isVideo_Doze: isVideo_Doze)
    }
    
    /// 加载媒体
    private func loadMedia_Doze(path_Doze: String, isVideo_Doze: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Doze = UIImage(systemName: path_Doze) {
            loadSystemIcon_Doze(image_Doze: systemImage_Doze, path_Doze: path_Doze)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Doze = UIImage(named: path_Doze) {
            loadImageSuccess_Doze(image_Doze: assetImage_Doze)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Doze.hasPrefix("http://") || path_Doze.hasPrefix("https://") {
            loadNetworkImage_Doze(urlString_Doze: path_Doze)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Doze = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Doze = documentsPath_Doze.appendingPathComponent(path_Doze)
        
        if let documentImage_Doze = UIImage(contentsOfFile: fileURL_Doze.path) {
            loadImageSuccess_Doze(image_Doze: documentImage_Doze)
            print("✅ 从文档目录加载媒体: \(path_Doze)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Doze = UIImage(contentsOfFile: path_Doze) {
            loadImageSuccess_Doze(image_Doze: localImage_Doze)
            return
        }
        
        // 6. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Doze)")
        showPlaceholder_Doze()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Doze() {
        imageView_Doze.image = nil
        imageView_Doze.layer.sublayers?.removeAll()
        iconContainerView_Doze.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Doze(image_Doze: UIImage, path_Doze: String) {
        clearOldContent_Doze()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Doze = Self.gradientColors_Doze[abs(path_Doze.hashValue) % Self.gradientColors_Doze.count]
        
        // 添加渐变背景
        let gradientColors_Doze = [selectedGradient_Doze.0.cgColor, selectedGradient_Doze.1.cgColor]
        addGradientLayer_Doze(colors_Doze: gradientColors_Doze)
        
        // 在独立容器上显示图标
        let iconImageView_Doze = UIImageView(image: image_Doze)
        iconImageView_Doze.tintColor = .white
        iconImageView_Doze.contentMode = .scaleAspectFit
        iconImageView_Doze.alpha = 0.9
        iconContainerView_Doze.addSubview(iconImageView_Doze)
        iconImageView_Doze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Doze.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Doze(urlString_Doze: String) {
        clearOldContent_Doze()
        
        if let url_Doze = URL(string: urlString_Doze) {
            imageView_Doze.kf.setImage(
                with: url_Doze,
                placeholder: createPlaceholderImage_Doze(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Doze.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Doze(image_Doze: UIImage) {
        clearOldContent_Doze()
        imageView_Doze.image = image_Doze
        placeholderIconView_Doze.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Doze(colors_Doze: [CGColor]) {
        let gradientLayer_Doze = CAGradientLayer()
        gradientLayer_Doze.frame = bounds
        gradientLayer_Doze.colors = colors_Doze
        gradientLayer_Doze.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Doze.endPoint = CGPoint(x: 1, y: 1)
        imageView_Doze.layer.insertSublayer(gradientLayer_Doze, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Doze() {
        mediaType_Doze = .none_Doze
        clearOldContent_Doze()
        placeholderIconView_Doze.isHidden = false
        playIconView_Doze.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Doze(colors_Doze: Self.placeholderGradientColors_Doze)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Doze() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Doze.backgroundPrimary_Doze.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Doze = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Doze
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Doze == .none_Doze {
            imageView_Doze.layer.sublayers?.first?.frame = bounds
        }
    }
}
