import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Wanderbell {
    case image_wanderbell
    case video_wanderbell
    case none_wanderbell
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Wanderbell: UIView {
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.contentMode = .scaleAspectFill
        imageView_wanderbell.clipsToBounds = true
        imageView_wanderbell.backgroundColor = ColorConfig_Wanderbell.backgroundPrimary_Wanderbell
        imageView_wanderbell.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_wanderbell
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.isUserInteractionEnabled = false
        return view_wanderbell
    }()
    
    /// 视频播放图标
    private let playIconView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_wanderbell.layer.cornerRadius = 30
        view_wanderbell.isHidden = true
        return view_wanderbell
    }()
    
    private let playIconImageView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "play.fill")
        imageView_wanderbell.tintColor = .white
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    /// 占位符图标
    private let placeholderIconView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_wanderbell.tintColor = ColorConfig_Wanderbell.textPlaceholder_Wanderbell
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    // MARK: - 属性
    
    private var mediaType_Wanderbell: MediaType_Wanderbell = .none_wanderbell
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Wanderbell() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Wanderbell)
        addSubview(iconContainerView_Wanderbell)
        addSubview(placeholderIconView_Wanderbell)
        addSubview(playIconView_Wanderbell)
        playIconView_Wanderbell.addSubview(playIconImageView_Wanderbell)
        
        imageView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Wanderbell.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Wanderbell.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Wanderbell.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 配置媒体展示
    /// 功能：根据媒体路径加载并展示图片或视频
    /// 参数：
    /// - mediaPath_wanderbell: 媒体路径（可以是本地路径、Assets名称或网络URL）
    /// - isVideo_wanderbell: 是否是视频
    func configure_Wanderbell(mediaPath_wanderbell: String?, isVideo_wanderbell: Bool = false) {
        guard let path_wanderbell = mediaPath_wanderbell, !path_wanderbell.isEmpty else {
            showPlaceholder_Wanderbell()
            return
        }
        
        mediaType_Wanderbell = isVideo_wanderbell ? .video_wanderbell : .image_wanderbell
        playIconView_Wanderbell.isHidden = !isVideo_wanderbell
        
        loadMedia_Wanderbell(path_wanderbell: path_wanderbell, isVideo_wanderbell: isVideo_wanderbell)
    }
    
    /// 加载媒体
    private func loadMedia_Wanderbell(path_wanderbell: String, isVideo_wanderbell: Bool) {
        placeholderIconView_Wanderbell.isHidden = true
        
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_wanderbell = UIImage(systemName: path_wanderbell) {
            // 清理旧内容
            imageView_Wanderbell.image = nil
            imageView_Wanderbell.layer.sublayers?.removeAll()
            iconContainerView_Wanderbell.subviews.forEach { $0.removeFromSuperview() }
            
            // 使用随机渐变色增加视觉多样性
            let gradients_wanderbell: [(UIColor, UIColor)] = [
                (UIColor(hexstring_Wanderbell: "#667eea"), UIColor(hexstring_Wanderbell: "#764ba2")),  // 紫色
                (UIColor(hexstring_Wanderbell: "#f093fb"), UIColor(hexstring_Wanderbell: "#f5576c")),  // 粉红
                (UIColor(hexstring_Wanderbell: "#4facfe"), UIColor(hexstring_Wanderbell: "#00f2fe")),  // 蓝色
                (UIColor(hexstring_Wanderbell: "#43e97b"), UIColor(hexstring_Wanderbell: "#38f9d7")),  // 绿色
                (UIColor(hexstring_Wanderbell: "#fa709a"), UIColor(hexstring_Wanderbell: "#fee140"))   // 暖色
            ]
            
            let selectedGradient_wanderbell = gradients_wanderbell[abs(path_wanderbell.hashValue) % gradients_wanderbell.count]
            
            let gradientLayer_wanderbell = CAGradientLayer()
            gradientLayer_wanderbell.frame = bounds
            gradientLayer_wanderbell.colors = [
                selectedGradient_wanderbell.0.cgColor,
                selectedGradient_wanderbell.1.cgColor
            ]
            gradientLayer_wanderbell.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer_wanderbell.endPoint = CGPoint(x: 1, y: 1)
            
            imageView_Wanderbell.layer.insertSublayer(gradientLayer_wanderbell, at: 0)
            
            // 在独立容器上显示图标（不直接添加到imageView）
            let iconImageView_wanderbell = UIImageView(image: systemImage_wanderbell)
            iconImageView_wanderbell.tintColor = .white
            iconImageView_wanderbell.contentMode = .scaleAspectFit
            iconImageView_wanderbell.alpha = 0.9
            iconContainerView_Wanderbell.addSubview(iconImageView_wanderbell)
            iconImageView_wanderbell.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(80)
            }
            
            placeholderIconView_Wanderbell.isHidden = true
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_wanderbell = UIImage(named: path_wanderbell) {
            imageView_Wanderbell.layer.sublayers?.removeAll()
            iconContainerView_Wanderbell.subviews.forEach { $0.removeFromSuperview() }
            imageView_Wanderbell.image = assetImage_wanderbell
            placeholderIconView_Wanderbell.isHidden = true
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_wanderbell.hasPrefix("http://") || path_wanderbell.hasPrefix("https://") {
            imageView_Wanderbell.layer.sublayers?.removeAll()
            iconContainerView_Wanderbell.subviews.forEach { $0.removeFromSuperview() }
            
            if let url_wanderbell = URL(string: path_wanderbell) {
                imageView_Wanderbell.kf.setImage(
                    with: url_wanderbell,
                    placeholder: createPlaceholderImage_Wanderbell(),
                    options: [.transition(.fade(0.3))]
                )
            }
            placeholderIconView_Wanderbell.isHidden = true
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_wanderbell = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_wanderbell = documentsPath_wanderbell.appendingPathComponent(path_wanderbell)
        
        if let documentImage_wanderbell = UIImage(contentsOfFile: fileURL_wanderbell.path) {
            imageView_Wanderbell.layer.sublayers?.removeAll()
            iconContainerView_Wanderbell.subviews.forEach { $0.removeFromSuperview() }
            imageView_Wanderbell.image = documentImage_wanderbell
            placeholderIconView_Wanderbell.isHidden = true
            print("✅ 从文档目录加载媒体: \(path_wanderbell)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_wanderbell = UIImage(contentsOfFile: path_wanderbell) {
            imageView_Wanderbell.layer.sublayers?.removeAll()
            iconContainerView_Wanderbell.subviews.forEach { $0.removeFromSuperview() }
            imageView_Wanderbell.image = localImage_wanderbell
            placeholderIconView_Wanderbell.isHidden = true
            return
        }
        
        // 6. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_wanderbell)")
        showPlaceholder_Wanderbell()
    }
    
    /// 显示占位符
    private func showPlaceholder_Wanderbell() {
        mediaType_Wanderbell = .none_wanderbell
        imageView_Wanderbell.image = nil
        iconContainerView_Wanderbell.subviews.forEach { $0.removeFromSuperview() }
        placeholderIconView_Wanderbell.isHidden = false
        playIconView_Wanderbell.isHidden = true
        
        // 创建美观的渐变占位符
        imageView_Wanderbell.layer.sublayers?.removeAll()
        
        // 根据卡片位置使用不同的渐变颜色
        let colors_wanderbell: [CGColor] = [
            UIColor(hexstring_Wanderbell: "#667eea").withAlphaComponent(0.3).cgColor,
            UIColor(hexstring_Wanderbell: "#764ba2").withAlphaComponent(0.3).cgColor
        ]
        
        let gradientLayer_wanderbell = CAGradientLayer()
        gradientLayer_wanderbell.colors = colors_wanderbell
        gradientLayer_wanderbell.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_wanderbell.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer_wanderbell.frame = bounds
        
        imageView_Wanderbell.layer.insertSublayer(gradientLayer_wanderbell, at: 0)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Wanderbell() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Wanderbell.backgroundPrimary_Wanderbell.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_wanderbell = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_wanderbell
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Wanderbell == .none_wanderbell {
            imageView_Wanderbell.layer.sublayers?.first?.frame = bounds
        }
    }
}
