import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Hush: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Hush: [UIColor] = [
        ColorConfig_Hush.primaryGradientStart_Hush,
        ColorConfig_Hush.secondaryGradientStart_Hush,
        UIColor(hexstring_Hush: "#63B3ED"),
        UIColor(hexstring_Hush: "#F6AD55"),
        UIColor(hexstring_Hush: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Hush: UIImageView = {
        let imageView_Hush = UIImageView()
        imageView_Hush.contentMode = .scaleAspectFill
        imageView_Hush.clipsToBounds = true
        imageView_Hush.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        return imageView_Hush
    }()
    
    // MARK: - 属性
    
    var userId_Hush: Int?
    var isCurrentUser_Hush: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Hush()
        observeUserState_Hush()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Hush.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Hush() {
        addSubview(imageView_Hush)
        
        imageView_Hush.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Hush() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Hush),
            name: UserViewModel_Hush.userStateDidChangeNotification_Hush,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Hush(userId_Hush: Int) {
        self.userId_Hush = userId_Hush
        
        // 判断是否是当前登录用户
        let currentUser_Hush = UserViewModel_Hush.shared_Hush.getCurrentUser_Hush()
        isCurrentUser_Hush = (currentUser_Hush.userId_Hush == userId_Hush)
        
        // 加载头像
        if isCurrentUser_Hush {
            loadCurrentUserAvatar_Hush(user_Hush: currentUser_Hush)
        } else {
            loadOtherUserAvatar_Hush(userId_Hush: userId_Hush)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Hush(user_Hush: LoginUserModel_Hush) {
        guard let headPath_Hush = user_Hush.userHead_Hush, !headPath_Hush.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Hush(color_Hush: ColorConfig_Hush.primaryGradientStart_Hush)
            return
        }
        
        loadAvatarFromPath_Hush(path_Hush: headPath_Hush, defaultColor_Hush: ColorConfig_Hush.primaryGradientStart_Hush)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Hush(userId_Hush: Int) {
        let userInfo_Hush = UserViewModel_Hush.shared_Hush.getUserById_Hush(userId_hush: userId_Hush)
        let color_Hush = Self.defaultAvatarColors_Hush[userId_Hush % Self.defaultAvatarColors_Hush.count]
        
        guard let headPath_Hush = userInfo_Hush.userHead_Hush, !headPath_Hush.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Hush(color_Hush: color_Hush)
            return
        }
        
        loadAvatarFromPath_Hush(path_Hush: headPath_Hush, defaultColor_Hush: color_Hush)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Hush(path_Hush: String, defaultColor_Hush: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Hush = UIImage(named: path_Hush) {
            imageView_Hush.image = assetImage_Hush
            imageView_Hush.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Hush = UIImage(contentsOfFile: path_Hush) {
            imageView_Hush.image = localImage_Hush
            imageView_Hush.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Hush.hasPrefix("http://") || path_Hush.hasPrefix("https://") {
            if let url_Hush = URL(string: path_Hush) {
                imageView_Hush.kf.setImage(
                    with: url_Hush,
                    placeholder: createPlaceholderImage_Hush(color_Hush: defaultColor_Hush),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Hush(color_Hush: defaultColor_Hush)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Hush: 图标颜色
    func setDefaultAvatar_Hush(color_Hush: UIColor) {
        imageView_Hush.image = UIImage(systemName: "person.circle.fill")
        imageView_Hush.tintColor = color_Hush
        imageView_Hush.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Hush(color_Hush: UIColor) -> UIImage? {
        let size_Hush = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Hush, false, 0)
        
        // 绘制圆形背景
        color_Hush.withAlphaComponent(0.2).setFill()
        let circlePath_Hush = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Hush))
        circlePath_Hush.fill()
        
        // 绘制人物图标
        if let icon_Hush = UIImage(systemName: "person.fill") {
            color_Hush.setFill()
            icon_Hush.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Hush = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Hush
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Hush() {
        if let userId_Hush = userId_Hush {
            configure_Hush(userId_Hush: userId_Hush)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Hush: UserAvatarView_Hush {

    // MARK: - 属性

    /// 点击回调
    var onTapped_Hush: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Hush()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Hush() {
        super.setupUI_Hush()
        
        // 启用用户交互
        isUserInteractionEnabled = true
        imageView_Hush.isUserInteractionEnabled = true

        // 添加点击手势（绑定到整个头像组件，避免局部区域点击失效）
        let tapSelfGesture_Hush = UITapGestureRecognizer(target: self, action: #selector(handleTap_Hush))
        addGestureRecognizer(tapSelfGesture_Hush)
        let tapGesture_Hush = UITapGestureRecognizer(target: self, action: #selector(handleTap_Hush))
        imageView_Hush.addGestureRecognizer(tapGesture_Hush)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Hush() {
        let currentUser_Hush = UserViewModel_Hush.shared_Hush.getCurrentUser_Hush()
        isCurrentUser_Hush = true
        userId_Hush = currentUser_Hush.userId_Hush
        
        guard let headPath_Hush = currentUser_Hush.userHead_Hush, !headPath_Hush.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Hush(color_Hush: ColorConfig_Hush.primaryGradientStart_Hush)
            return
        }
        
        loadAvatarFromPath_Hush(path_Hush: headPath_Hush, defaultColor_Hush: ColorConfig_Hush.primaryGradientStart_Hush)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Hush(color_Hush: UIColor) -> UIImage? {
        let size_Hush = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Hush, false, 0)
        
        // 绘制渐变背景
        let context_Hush = UIGraphicsGetCurrentContext()
        let colors_Hush = [
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor
        ]
        let colorSpace_Hush = CGColorSpaceCreateDeviceRGB()
        let gradient_Hush = CGGradient(colorsSpace: colorSpace_Hush, colors: colors_Hush as CFArray, locations: nil)
        
        context_Hush?.drawLinearGradient(
            gradient_Hush!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Hush.width, y: size_Hush.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Hush = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Hush.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Hush = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Hush
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Hush() {
        // 缩放动画
        animatePressDown_Hush {
            self.animatePressUp_Hush()
        }
        
        // 触觉反馈
        let generator_Hush = UIImpactFeedbackGenerator(style: .light)
        generator_Hush.impactOccurred()
        
        // 触发回调
        onTapped_Hush?()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Hush() {
        loadCurrentUserAvatar_Hush()
    }
}
