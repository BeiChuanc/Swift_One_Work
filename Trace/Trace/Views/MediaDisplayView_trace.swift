import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Trace {
    case image_Trace
    case video_Trace
    case none_Trace
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持本地图片、Assets图片、网络图片
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Trace: UIView {
    
    // MARK: - 静态常量
    
    /// 渐变色配置（用于系统图标背景）
    private static let gradientColors_Trace: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Trace: "#667eea"), UIColor(hexstring_Trace: "#764ba2")),  // 紫色
        (UIColor(hexstring_Trace: "#f093fb"), UIColor(hexstring_Trace: "#f5576c")),  // 粉红
        (UIColor(hexstring_Trace: "#4facfe"), UIColor(hexstring_Trace: "#00f2fe")),  // 蓝色
        (UIColor(hexstring_Trace: "#43e97b"), UIColor(hexstring_Trace: "#38f9d7")),  // 绿色
        (UIColor(hexstring_Trace: "#fa709a"), UIColor(hexstring_Trace: "#fee140"))   // 暖色
    ]
    
    /// 占位符渐变色配置
    private static let placeholderGradientColors_Trace: [CGColor] = [
        UIColor(hexstring_Trace: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Trace: "#764ba2").withAlphaComponent(0.3).cgColor
    ]
    
    // MARK: - UI组件
    
    /// 图片视图
    private let imageView_Trace: UIImageView = {
        let imageView_Trace = UIImageView()
        imageView_Trace.contentMode = .scaleAspectFill
        imageView_Trace.clipsToBounds = true
        imageView_Trace.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        imageView_Trace.isUserInteractionEnabled = true // 允许添加子视图
        return imageView_Trace
    }()
    
    /// 图标容器视图（用于放置系统图标）
    private let iconContainerView_Trace: UIView = {
        let view_Trace = UIView()
        view_Trace.isUserInteractionEnabled = false
        return view_Trace
    }()
    
    /// 视频播放图标
    private let playIconView_Trace: UIView = {
        let view_Trace = UIView()
        view_Trace.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Trace.layer.cornerRadius = 30
        view_Trace.isHidden = true
        return view_Trace
    }()
    
    private let playIconImageView_Trace: UIImageView = {
        let imageView_Trace = UIImageView()
        imageView_Trace.image = UIImage(systemName: "play.fill")
        imageView_Trace.tintColor = .white
        imageView_Trace.contentMode = .scaleAspectFit
        return imageView_Trace
    }()
    
    /// 占位符图标
    private let placeholderIconView_Trace: UIImageView = {
        let imageView_Trace = UIImageView()
        imageView_Trace.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_Trace.tintColor = ColorConfig_Trace.textPlaceholder_Trace
        imageView_Trace.contentMode = .scaleAspectFit
        return imageView_Trace
    }()
    
    // MARK: - 属性
    
    private var mediaType_Trace: MediaType_Trace = .none_Trace
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Trace()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Trace() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        addSubview(imageView_Trace)
        addSubview(iconContainerView_Trace)
        addSubview(placeholderIconView_Trace)
        addSubview(playIconView_Trace)
        playIconView_Trace.addSubview(playIconImageView_Trace)
        
        imageView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconContainerView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeholderIconView_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        playIconView_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playIconImageView_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }
    
    // MARK: - 公共方法
    
    /// 配置媒体展示
    func configure_Trace(mediaPath_Trace: String?, isVideo_Trace: Bool = false) {
        guard let path_Trace = mediaPath_Trace, !path_Trace.isEmpty else {
            showPlaceholder_Trace()
            return
        }
        
        mediaType_Trace = isVideo_Trace ? .video_Trace : .image_Trace
        playIconView_Trace.isHidden = !isVideo_Trace
        
        loadMedia_Trace(path_Trace: path_Trace, isVideo_Trace: isVideo_Trace)
    }
    
    /// 加载媒体
    private func loadMedia_Trace(path_Trace: String, isVideo_Trace: Bool) {
        // 1. 检查是否是系统图标（SF Symbols）
        if let systemImage_Trace = UIImage(systemName: path_Trace) {
            loadSystemIcon_Trace(image_Trace: systemImage_Trace, path_Trace: path_Trace)
            return
        }
        
        // 2. 尝试从Assets加载
        if let assetImage_Trace = UIImage(named: path_Trace) {
            loadImageSuccess_Trace(image_Trace: assetImage_Trace)
            return
        }
        
        // 3. 尝试作为网络URL加载
        if path_Trace.hasPrefix("http://") || path_Trace.hasPrefix("https://") {
            loadNetworkImage_Trace(urlString_Trace: path_Trace)
            return
        }
        
        // 4. 尝试从文档目录加载（支持文件名）
        let documentsPath_Trace = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Trace = documentsPath_Trace.appendingPathComponent(path_Trace)
        
        if let documentImage_Trace = UIImage(contentsOfFile: fileURL_Trace.path) {
            loadImageSuccess_Trace(image_Trace: documentImage_Trace)
            print("✅ 从文档目录加载媒体: \(path_Trace)")
            return
        }
        
        // 5. 尝试作为完整本地文件路径加载
        if let localImage_Trace = UIImage(contentsOfFile: path_Trace) {
            loadImageSuccess_Trace(image_Trace: localImage_Trace)
            return
        }
        
        // 6. 如果都失败，显示占位符
        print("⚠️ 无法加载媒体: \(path_Trace)")
        showPlaceholder_Trace()
    }
    
    /// 清理旧内容
    /// 功能：移除旧的图片、渐变图层和图标视图
    private func clearOldContent_Trace() {
        imageView_Trace.image = nil
        imageView_Trace.layer.sublayers?.removeAll()
        iconContainerView_Trace.subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// 加载系统图标
    private func loadSystemIcon_Trace(image_Trace: UIImage, path_Trace: String) {
        clearOldContent_Trace()
        
        // 根据路径哈希值选择渐变色
        let selectedGradient_Trace = Self.gradientColors_Trace[abs(path_Trace.hashValue) % Self.gradientColors_Trace.count]
        
        // 添加渐变背景
        let gradientColors_Trace = [selectedGradient_Trace.0.cgColor, selectedGradient_Trace.1.cgColor]
        addGradientLayer_Trace(colors_Trace: gradientColors_Trace)
        
        // 在独立容器上显示图标
        let iconImageView_Trace = UIImageView(image: image_Trace)
        iconImageView_Trace.tintColor = .white
        iconImageView_Trace.contentMode = .scaleAspectFit
        iconImageView_Trace.alpha = 0.9
        iconContainerView_Trace.addSubview(iconImageView_Trace)
        iconImageView_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        placeholderIconView_Trace.isHidden = true
    }
    
    /// 加载网络图片
    private func loadNetworkImage_Trace(urlString_Trace: String) {
        clearOldContent_Trace()
        
        if let url_Trace = URL(string: urlString_Trace) {
            imageView_Trace.kf.setImage(
                with: url_Trace,
                placeholder: createPlaceholderImage_Trace(),
                options: [.transition(.fade(0.3))]
            )
        }
        
        placeholderIconView_Trace.isHidden = true
    }
    
    /// 图片加载成功
    private func loadImageSuccess_Trace(image_Trace: UIImage) {
        clearOldContent_Trace()
        imageView_Trace.image = image_Trace
        placeholderIconView_Trace.isHidden = true
    }
    
    /// 添加渐变图层
    private func addGradientLayer_Trace(colors_Trace: [CGColor]) {
        let gradientLayer_Trace = CAGradientLayer()
        gradientLayer_Trace.frame = bounds
        gradientLayer_Trace.colors = colors_Trace
        gradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
        imageView_Trace.layer.insertSublayer(gradientLayer_Trace, at: 0)
    }
    
    /// 显示占位符
    private func showPlaceholder_Trace() {
        mediaType_Trace = .none_Trace
        clearOldContent_Trace()
        placeholderIconView_Trace.isHidden = false
        playIconView_Trace.isHidden = true
        
        // 创建美观的渐变占位符
        addGradientLayer_Trace(colors_Trace: Self.placeholderGradientColors_Trace)
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Trace() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        ColorConfig_Trace.backgroundPrimary_Trace.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image_Trace = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Trace
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层大小
        if mediaType_Trace == .none_Trace {
            imageView_Trace.layer.sublayers?.first?.frame = bounds
        }
    }
}
