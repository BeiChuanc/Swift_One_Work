import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Clara: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Clara: [UIColor] = [
        ColorConfig_Clara.primaryGradientStart_Clara,
        ColorConfig_Clara.secondaryGradientStart_Clara,
        UIColor(hexstring_Clara: "#63B3ED"),
        UIColor(hexstring_Clara: "#F6AD55"),
        UIColor(hexstring_Clara: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Clara: UIImageView = {
        let imageView_Clara = UIImageView()
        imageView_Clara.contentMode = .scaleAspectFill
        imageView_Clara.clipsToBounds = true
        imageView_Clara.backgroundColor = ColorConfig_Clara.backgroundPrimary_Clara
        return imageView_Clara
    }()
    
    // MARK: - 属性
    
    var userId_Clara: Int?
    var isCurrentUser_Clara: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Clara()
        observeUserState_Clara()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Clara.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Clara() {
        addSubview(imageView_Clara)
        
        imageView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Clara() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Clara),
            name: UserViewModel_Clara.userStateDidChangeNotification_Clara,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Clara(userId_Clara: Int) {
        self.userId_Clara = userId_Clara
        
        // 判断是否是当前登录用户
        let currentUser_Clara = UserViewModel_Clara.shared_Clara.getCurrentUser_Clara()
        isCurrentUser_Clara = (currentUser_Clara.userId_Clara == userId_Clara)
        
        // 加载头像
        if isCurrentUser_Clara {
            loadCurrentUserAvatar_Clara(user_Clara: currentUser_Clara)
        } else {
            loadOtherUserAvatar_Clara(userId_Clara: userId_Clara)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Clara(user_Clara: LoginUserModel_Clara) {
        guard let headPath_Clara = user_Clara.userHead_Clara, !headPath_Clara.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Clara(color_Clara: ColorConfig_Clara.primaryGradientStart_Clara)
            return
        }
        
        loadAvatarFromPath_Clara(path_Clara: headPath_Clara, defaultColor_Clara: ColorConfig_Clara.primaryGradientStart_Clara)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Clara(userId_Clara: Int) {
        let userInfo_Clara = UserViewModel_Clara.shared_Clara.getUserById_Clara(userId_clara: userId_Clara)
        let color_Clara = Self.defaultAvatarColors_Clara[userId_Clara % Self.defaultAvatarColors_Clara.count]
        
        guard let headPath_Clara = userInfo_Clara.userHead_Clara, !headPath_Clara.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Clara(color_Clara: color_Clara)
            return
        }
        
        loadAvatarFromPath_Clara(path_Clara: headPath_Clara, defaultColor_Clara: color_Clara)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Clara(path_Clara: String, defaultColor_Clara: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Clara = UIImage(named: path_Clara) {
            imageView_Clara.image = assetImage_Clara
            imageView_Clara.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Clara = UIImage(contentsOfFile: path_Clara) {
            imageView_Clara.image = localImage_Clara
            imageView_Clara.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Clara.hasPrefix("http://") || path_Clara.hasPrefix("https://") {
            if let url_Clara = URL(string: path_Clara) {
                imageView_Clara.kf.setImage(
                    with: url_Clara,
                    placeholder: createPlaceholderImage_Clara(color_Clara: defaultColor_Clara),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Clara(color_Clara: defaultColor_Clara)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Clara: 图标颜色
    func setDefaultAvatar_Clara(color_Clara: UIColor) {
        imageView_Clara.image = UIImage(systemName: "person.circle.fill")
        imageView_Clara.tintColor = color_Clara
        imageView_Clara.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Clara(color_Clara: UIColor) -> UIImage? {
        let size_Clara = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Clara, false, 0)
        
        // 绘制圆形背景
        color_Clara.withAlphaComponent(0.2).setFill()
        let circlePath_Clara = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Clara))
        circlePath_Clara.fill()
        
        // 绘制人物图标
        if let icon_Clara = UIImage(systemName: "person.fill") {
            color_Clara.setFill()
            icon_Clara.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Clara = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Clara
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Clara() {
        if let userId_Clara = userId_Clara {
            configure_Clara(userId_Clara: userId_Clara)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Clara: UserAvatarView_Clara {

    // MARK: - 属性

    /// 点击回调
    var onTapped_Clara: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Clara()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Clara() {
        super.setupUI_Clara()
        
        // 启用用户交互
        isUserInteractionEnabled = true
        imageView_Clara.isUserInteractionEnabled = true

        // 添加点击手势（绑定到整个头像组件，避免局部区域点击失效）
        let tapSelfGesture_Clara = UITapGestureRecognizer(target: self, action: #selector(handleTap_Clara))
        addGestureRecognizer(tapSelfGesture_Clara)
        let tapGesture_Clara = UITapGestureRecognizer(target: self, action: #selector(handleTap_Clara))
        imageView_Clara.addGestureRecognizer(tapGesture_Clara)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Clara() {
        let currentUser_Clara = UserViewModel_Clara.shared_Clara.getCurrentUser_Clara()
        isCurrentUser_Clara = true
        userId_Clara = currentUser_Clara.userId_Clara
        
        guard let headPath_Clara = currentUser_Clara.userHead_Clara, !headPath_Clara.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Clara(color_Clara: ColorConfig_Clara.primaryGradientStart_Clara)
            return
        }
        
        loadAvatarFromPath_Clara(path_Clara: headPath_Clara, defaultColor_Clara: ColorConfig_Clara.primaryGradientStart_Clara)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Clara(color_Clara: UIColor) -> UIImage? {
        let size_Clara = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Clara, false, 0)
        
        // 绘制渐变背景
        let context_Clara = UIGraphicsGetCurrentContext()
        let colors_Clara = [
            ColorConfig_Clara.primaryGradientStart_Clara.cgColor,
            ColorConfig_Clara.primaryGradientEnd_Clara.cgColor
        ]
        let colorSpace_Clara = CGColorSpaceCreateDeviceRGB()
        let gradient_Clara = CGGradient(colorsSpace: colorSpace_Clara, colors: colors_Clara as CFArray, locations: nil)
        
        context_Clara?.drawLinearGradient(
            gradient_Clara!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Clara.width, y: size_Clara.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Clara = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Clara.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Clara = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Clara
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Clara() {
        // 缩放动画
        animatePressDown_Clara {
            self.animatePressUp_Clara()
        }
        
        // 触觉反馈
        let generator_Clara = UIImpactFeedbackGenerator(style: .light)
        generator_Clara.impactOccurred()
        
        // 触发回调
        onTapped_Clara?()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Clara() {
        loadCurrentUserAvatar_Clara()
    }
}
