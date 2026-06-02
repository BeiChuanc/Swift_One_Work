import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Breeze: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Breeze: [UIColor] = [
        ColorConfig_Breeze.primaryGradientStart_Breeze,
        ColorConfig_Breeze.secondaryGradientStart_Breeze,
        UIColor(hexstring_Breeze: "#63B3ED"),
        UIColor(hexstring_Breeze: "#F6AD55"),
        UIColor(hexstring_Breeze: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Breeze: UIImageView = {
        let imageView_Breeze = UIImageView()
        imageView_Breeze.contentMode = .scaleAspectFill
        imageView_Breeze.clipsToBounds = true
        imageView_Breeze.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        return imageView_Breeze
    }()
    
    // MARK: - 属性
    
    var userId_Breeze: Int?
    var isCurrentUser_Breeze: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Breeze()
        observeUserState_Breeze()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Breeze.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Breeze() {
        addSubview(imageView_Breeze)
        
        imageView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Breeze() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Breeze),
            name: UserViewModel_Breeze.userStateDidChangeNotification_Breeze,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Breeze(userId_Breeze: Int) {
        self.userId_Breeze = userId_Breeze
        
        // 判断是否是当前登录用户
        let currentUser_Breeze = UserViewModel_Breeze.shared_Breeze.getCurrentUser_Breeze()
        isCurrentUser_Breeze = (currentUser_Breeze.userId_Breeze == userId_Breeze)
        
        // 加载头像
        if isCurrentUser_Breeze {
            loadCurrentUserAvatar_Breeze(user_Breeze: currentUser_Breeze)
        } else {
            loadOtherUserAvatar_Breeze(userId_Breeze: userId_Breeze)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Breeze(user_Breeze: LoginUserModel_Breeze) {
        guard let headPath_Breeze = user_Breeze.userHead_Breeze, !headPath_Breeze.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Breeze(color_Breeze: ColorConfig_Breeze.primaryGradientStart_Breeze)
            return
        }
        
        loadAvatarFromPath_Breeze(path_Breeze: headPath_Breeze, defaultColor_Breeze: ColorConfig_Breeze.primaryGradientStart_Breeze)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Breeze(userId_Breeze: Int) {
        let userInfo_Breeze = UserViewModel_Breeze.shared_Breeze.getUserById_Breeze(userId_breeze: userId_Breeze)
        let color_Breeze = Self.defaultAvatarColors_Breeze[userId_Breeze % Self.defaultAvatarColors_Breeze.count]
        
        guard let headPath_Breeze = userInfo_Breeze.userHead_Breeze, !headPath_Breeze.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Breeze(color_Breeze: color_Breeze)
            return
        }
        
        loadAvatarFromPath_Breeze(path_Breeze: headPath_Breeze, defaultColor_Breeze: color_Breeze)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Breeze(path_Breeze: String, defaultColor_Breeze: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Breeze = UIImage(named: path_Breeze) {
            imageView_Breeze.image = assetImage_Breeze
            imageView_Breeze.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Breeze = UIImage(contentsOfFile: path_Breeze) {
            imageView_Breeze.image = localImage_Breeze
            imageView_Breeze.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Breeze.hasPrefix("http://") || path_Breeze.hasPrefix("https://") {
            if let url_Breeze = URL(string: path_Breeze) {
                imageView_Breeze.kf.setImage(
                    with: url_Breeze,
                    placeholder: createPlaceholderImage_Breeze(color_Breeze: defaultColor_Breeze),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Breeze(color_Breeze: defaultColor_Breeze)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Breeze: 图标颜色
    func setDefaultAvatar_Breeze(color_Breeze: UIColor) {
        imageView_Breeze.image = UIImage(systemName: "person.circle.fill")
        imageView_Breeze.tintColor = color_Breeze
        imageView_Breeze.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Breeze(color_Breeze: UIColor) -> UIImage? {
        let size_Breeze = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Breeze, false, 0)
        
        // 绘制圆形背景
        color_Breeze.withAlphaComponent(0.2).setFill()
        let circlePath_Breeze = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Breeze))
        circlePath_Breeze.fill()
        
        // 绘制人物图标
        if let icon_Breeze = UIImage(systemName: "person.fill") {
            color_Breeze.setFill()
            icon_Breeze.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Breeze = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Breeze
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Breeze() {
        if let userId_Breeze = userId_Breeze {
            configure_Breeze(userId_Breeze: userId_Breeze)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Breeze: UserAvatarView_Breeze {

    // MARK: - 属性

    /// 点击回调
    var onTapped_Breeze: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Breeze()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Breeze() {
        super.setupUI_Breeze()
        
        // 启用用户交互
        isUserInteractionEnabled = true
        imageView_Breeze.isUserInteractionEnabled = true

        // 添加点击手势（绑定到整个头像组件，避免局部区域点击失效）
        let tapSelfGesture_Breeze = UITapGestureRecognizer(target: self, action: #selector(handleTap_Breeze))
        addGestureRecognizer(tapSelfGesture_Breeze)
        let tapGesture_Breeze = UITapGestureRecognizer(target: self, action: #selector(handleTap_Breeze))
        imageView_Breeze.addGestureRecognizer(tapGesture_Breeze)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Breeze() {
        let currentUser_Breeze = UserViewModel_Breeze.shared_Breeze.getCurrentUser_Breeze()
        isCurrentUser_Breeze = true
        userId_Breeze = currentUser_Breeze.userId_Breeze
        
        guard let headPath_Breeze = currentUser_Breeze.userHead_Breeze, !headPath_Breeze.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Breeze(color_Breeze: ColorConfig_Breeze.primaryGradientStart_Breeze)
            return
        }
        
        loadAvatarFromPath_Breeze(path_Breeze: headPath_Breeze, defaultColor_Breeze: ColorConfig_Breeze.primaryGradientStart_Breeze)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Breeze(color_Breeze: UIColor) -> UIImage? {
        let size_Breeze = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Breeze, false, 0)
        
        // 绘制渐变背景
        let context_Breeze = UIGraphicsGetCurrentContext()
        let colors_Breeze = [
            ColorConfig_Breeze.primaryGradientStart_Breeze.cgColor,
            ColorConfig_Breeze.primaryGradientEnd_Breeze.cgColor
        ]
        let colorSpace_Breeze = CGColorSpaceCreateDeviceRGB()
        let gradient_Breeze = CGGradient(colorsSpace: colorSpace_Breeze, colors: colors_Breeze as CFArray, locations: nil)
        
        context_Breeze?.drawLinearGradient(
            gradient_Breeze!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Breeze.width, y: size_Breeze.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Breeze = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Breeze.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Breeze = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Breeze
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Breeze() {
        // 缩放动画
        animatePressDown_Breeze {
            self.animatePressUp_Breeze()
        }
        
        // 触觉反馈
        let generator_Breeze = UIImpactFeedbackGenerator(style: .light)
        generator_Breeze.impactOccurred()
        
        // 触发回调
        onTapped_Breeze?()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Breeze() {
        loadCurrentUserAvatar_Breeze()
    }
}
