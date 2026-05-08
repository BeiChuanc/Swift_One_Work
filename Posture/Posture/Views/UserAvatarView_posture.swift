import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Posture: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Posture: [UIColor] = [
        ColorConfig_Posture.primaryGradientStart_Posture,
        ColorConfig_Posture.secondaryGradientStart_Posture,
        UIColor(hexstring_Posture: "#63B3ED"),
        UIColor(hexstring_Posture: "#F6AD55"),
        UIColor(hexstring_Posture: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Posture: UIImageView = {
        let imageView_Posture = UIImageView()
        imageView_Posture.contentMode = .scaleAspectFill
        imageView_Posture.clipsToBounds = true
        imageView_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        return imageView_Posture
    }()
    
    // MARK: - 属性
    
    var userId_Posture: Int?
    var isCurrentUser_Posture: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Posture()
        observeUserState_Posture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Posture.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Posture() {
        addSubview(imageView_Posture)
        
        imageView_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Posture() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Posture),
            name: UserViewModel_Posture.userStateDidChangeNotification_Posture,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Posture(userId_Posture: Int) {
        self.userId_Posture = userId_Posture
        
        // 判断是否是当前登录用户
        let currentUser_Posture = UserViewModel_Posture.shared_Posture.getCurrentUser_Posture()
        isCurrentUser_Posture = (currentUser_Posture.userId_Posture == userId_Posture)
        
        // 加载头像
        if isCurrentUser_Posture {
            loadCurrentUserAvatar_Posture(user_Posture: currentUser_Posture)
        } else {
            loadOtherUserAvatar_Posture(userId_Posture: userId_Posture)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Posture(user_Posture: LoginUserModel_Posture) {
        guard let headPath_Posture = user_Posture.userHead_Posture, !headPath_Posture.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Posture(color_Posture: ColorConfig_Posture.primaryGradientStart_Posture)
            return
        }
        
        loadAvatarFromPath_Posture(path_Posture: headPath_Posture, defaultColor_Posture: ColorConfig_Posture.primaryGradientStart_Posture)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Posture(userId_Posture: Int) {
        let userInfo_Posture = UserViewModel_Posture.shared_Posture.getUserById_Posture(userId_posture: userId_Posture)
        let color_Posture = Self.defaultAvatarColors_Posture[userId_Posture % Self.defaultAvatarColors_Posture.count]
        
        guard let headPath_Posture = userInfo_Posture.userHead_Posture, !headPath_Posture.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Posture(color_Posture: color_Posture)
            return
        }
        
        loadAvatarFromPath_Posture(path_Posture: headPath_Posture, defaultColor_Posture: color_Posture)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Posture(path_Posture: String, defaultColor_Posture: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Posture = UIImage(named: path_Posture) {
            imageView_Posture.image = assetImage_Posture
            imageView_Posture.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Posture = UIImage(contentsOfFile: path_Posture) {
            imageView_Posture.image = localImage_Posture
            imageView_Posture.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Posture.hasPrefix("http://") || path_Posture.hasPrefix("https://") {
            if let url_Posture = URL(string: path_Posture) {
                imageView_Posture.kf.setImage(
                    with: url_Posture,
                    placeholder: createPlaceholderImage_Posture(color_Posture: defaultColor_Posture),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Posture(color_Posture: defaultColor_Posture)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Posture: 图标颜色
    func setDefaultAvatar_Posture(color_Posture: UIColor) {
        imageView_Posture.image = UIImage(systemName: "person.circle.fill")
        imageView_Posture.tintColor = color_Posture
        imageView_Posture.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Posture(color_Posture: UIColor) -> UIImage? {
        let size_Posture = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Posture, false, 0)
        
        // 绘制圆形背景
        color_Posture.withAlphaComponent(0.2).setFill()
        let circlePath_Posture = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Posture))
        circlePath_Posture.fill()
        
        // 绘制人物图标
        if let icon_Posture = UIImage(systemName: "person.fill") {
            color_Posture.setFill()
            icon_Posture.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Posture = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Posture
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Posture() {
        if let userId_Posture = userId_Posture {
            configure_Posture(userId_Posture: userId_Posture)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Posture: UserAvatarView_Posture {

    // MARK: - 属性

    /// 点击回调
    var onTapped_Posture: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Posture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Posture() {
        super.setupUI_Posture()
        
        // 启用用户交互
        isUserInteractionEnabled = true
        imageView_Posture.isUserInteractionEnabled = true

        // 添加点击手势（绑定到整个头像组件，避免局部区域点击失效）
        let tapSelfGesture_Posture = UITapGestureRecognizer(target: self, action: #selector(handleTap_Posture))
        addGestureRecognizer(tapSelfGesture_Posture)
        let tapGesture_Posture = UITapGestureRecognizer(target: self, action: #selector(handleTap_Posture))
        imageView_Posture.addGestureRecognizer(tapGesture_Posture)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Posture() {
        let currentUser_Posture = UserViewModel_Posture.shared_Posture.getCurrentUser_Posture()
        isCurrentUser_Posture = true
        userId_Posture = currentUser_Posture.userId_Posture
        
        guard let headPath_Posture = currentUser_Posture.userHead_Posture, !headPath_Posture.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Posture(color_Posture: ColorConfig_Posture.primaryGradientStart_Posture)
            return
        }
        
        loadAvatarFromPath_Posture(path_Posture: headPath_Posture, defaultColor_Posture: ColorConfig_Posture.primaryGradientStart_Posture)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Posture(color_Posture: UIColor) -> UIImage? {
        let size_Posture = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Posture, false, 0)
        
        // 绘制渐变背景
        let context_Posture = UIGraphicsGetCurrentContext()
        let colors_Posture = [
            ColorConfig_Posture.primaryGradientStart_Posture.cgColor,
            ColorConfig_Posture.primaryGradientEnd_Posture.cgColor
        ]
        let colorSpace_Posture = CGColorSpaceCreateDeviceRGB()
        let gradient_Posture = CGGradient(colorsSpace: colorSpace_Posture, colors: colors_Posture as CFArray, locations: nil)
        
        context_Posture?.drawLinearGradient(
            gradient_Posture!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Posture.width, y: size_Posture.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Posture = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Posture.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Posture = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Posture
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Posture() {
        // 缩放动画
        animatePressDown_Posture {
            self.animatePressUp_Posture()
        }
        
        // 触觉反馈
        let generator_Posture = UIImpactFeedbackGenerator(style: .light)
        generator_Posture.impactOccurred()
        
        // 触发回调
        onTapped_Posture?()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Posture() {
        loadCurrentUserAvatar_Posture()
    }
}
