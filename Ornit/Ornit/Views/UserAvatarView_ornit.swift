import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Ornit: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Ornit: [UIColor] = [
        ColorConfig_Ornit.primaryGradientStart_Ornit,
        ColorConfig_Ornit.secondaryGradientStart_Ornit,
        UIColor(hexstring_Ornit: "#63B3ED"),
        UIColor(hexstring_Ornit: "#F6AD55"),
        UIColor(hexstring_Ornit: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Ornit: UIImageView = {
        let imageView_Ornit = UIImageView()
        imageView_Ornit.contentMode = .scaleAspectFill
        imageView_Ornit.clipsToBounds = true
        imageView_Ornit.backgroundColor = ColorConfig_Ornit.backgroundPrimary_Ornit
        return imageView_Ornit
    }()
    
    // MARK: - 属性
    
    var userId_Ornit: Int?
    var isCurrentUser_Ornit: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Ornit()
        observeUserState_Ornit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Ornit.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Ornit() {
        addSubview(imageView_Ornit)
        
        imageView_Ornit.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Ornit() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Ornit),
            name: UserViewModel_Ornit.userStateDidChangeNotification_Ornit,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Ornit(userId_Ornit: Int) {
        self.userId_Ornit = userId_Ornit
        
        // 判断是否是当前登录用户
        let currentUser_Ornit = UserViewModel_Ornit.shared_Ornit.getCurrentUser_Ornit()
        isCurrentUser_Ornit = (currentUser_Ornit.userId_Ornit == userId_Ornit)
        
        // 加载头像
        if isCurrentUser_Ornit {
            loadCurrentUserAvatar_Ornit(user_Ornit: currentUser_Ornit)
        } else {
            loadOtherUserAvatar_Ornit(userId_Ornit: userId_Ornit)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Ornit(user_Ornit: LoginUserModel_Ornit) {
        guard let headPath_Ornit = user_Ornit.userHead_Ornit, !headPath_Ornit.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Ornit(color_Ornit: ColorConfig_Ornit.primaryGradientStart_Ornit)
            return
        }
        
        loadAvatarFromPath_Ornit(path_Ornit: headPath_Ornit, defaultColor_Ornit: ColorConfig_Ornit.primaryGradientStart_Ornit)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Ornit(userId_Ornit: Int) {
        let userInfo_Ornit = UserViewModel_Ornit.shared_Ornit.getUserById_Ornit(userId_ornit: userId_Ornit)
        let color_Ornit = Self.defaultAvatarColors_Ornit[userId_Ornit % Self.defaultAvatarColors_Ornit.count]
        
        guard let headPath_Ornit = userInfo_Ornit.userHead_Ornit, !headPath_Ornit.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Ornit(color_Ornit: color_Ornit)
            return
        }
        
        loadAvatarFromPath_Ornit(path_Ornit: headPath_Ornit, defaultColor_Ornit: color_Ornit)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Ornit(path_Ornit: String, defaultColor_Ornit: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Ornit = UIImage(named: path_Ornit) {
            imageView_Ornit.image = assetImage_Ornit
            imageView_Ornit.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Ornit = UIImage(contentsOfFile: path_Ornit) {
            imageView_Ornit.image = localImage_Ornit
            imageView_Ornit.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Ornit.hasPrefix("http://") || path_Ornit.hasPrefix("https://") {
            if let url_Ornit = URL(string: path_Ornit) {
                imageView_Ornit.kf.setImage(
                    with: url_Ornit,
                    placeholder: createPlaceholderImage_Ornit(color_Ornit: defaultColor_Ornit),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Ornit(color_Ornit: defaultColor_Ornit)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Ornit: 图标颜色
    func setDefaultAvatar_Ornit(color_Ornit: UIColor) {
        imageView_Ornit.image = UIImage(systemName: "person.circle.fill")
        imageView_Ornit.tintColor = color_Ornit
        imageView_Ornit.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Ornit(color_Ornit: UIColor) -> UIImage? {
        let size_Ornit = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Ornit, false, 0)
        
        // 绘制圆形背景
        color_Ornit.withAlphaComponent(0.2).setFill()
        let circlePath_Ornit = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Ornit))
        circlePath_Ornit.fill()
        
        // 绘制人物图标
        if let icon_Ornit = UIImage(systemName: "person.fill") {
            color_Ornit.setFill()
            icon_Ornit.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Ornit = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Ornit
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Ornit() {
        if let userId_Ornit = userId_Ornit {
            configure_Ornit(userId_Ornit: userId_Ornit)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Ornit: UserAvatarView_Ornit {

    // MARK: - 属性

    /// 点击回调
    var onTapped_Ornit: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Ornit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Ornit() {
        super.setupUI_Ornit()
        
        // 启用用户交互
        isUserInteractionEnabled = true
        imageView_Ornit.isUserInteractionEnabled = true

        // 添加点击手势（绑定到整个头像组件，避免局部区域点击失效）
        let tapSelfGesture_Ornit = UITapGestureRecognizer(target: self, action: #selector(handleTap_Ornit))
        addGestureRecognizer(tapSelfGesture_Ornit)
        let tapGesture_Ornit = UITapGestureRecognizer(target: self, action: #selector(handleTap_Ornit))
        imageView_Ornit.addGestureRecognizer(tapGesture_Ornit)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Ornit() {
        let currentUser_Ornit = UserViewModel_Ornit.shared_Ornit.getCurrentUser_Ornit()
        isCurrentUser_Ornit = true
        userId_Ornit = currentUser_Ornit.userId_Ornit
        
        guard let headPath_Ornit = currentUser_Ornit.userHead_Ornit, !headPath_Ornit.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Ornit(color_Ornit: ColorConfig_Ornit.primaryGradientStart_Ornit)
            return
        }
        
        loadAvatarFromPath_Ornit(path_Ornit: headPath_Ornit, defaultColor_Ornit: ColorConfig_Ornit.primaryGradientStart_Ornit)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Ornit(color_Ornit: UIColor) -> UIImage? {
        let size_Ornit = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Ornit, false, 0)
        
        // 绘制渐变背景
        let context_Ornit = UIGraphicsGetCurrentContext()
        let colors_Ornit = [
            ColorConfig_Ornit.primaryGradientStart_Ornit.cgColor,
            ColorConfig_Ornit.primaryGradientEnd_Ornit.cgColor
        ]
        let colorSpace_Ornit = CGColorSpaceCreateDeviceRGB()
        let gradient_Ornit = CGGradient(colorsSpace: colorSpace_Ornit, colors: colors_Ornit as CFArray, locations: nil)
        
        context_Ornit?.drawLinearGradient(
            gradient_Ornit!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Ornit.width, y: size_Ornit.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Ornit = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Ornit.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Ornit = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Ornit
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Ornit() {
        // 缩放动画
        animatePressDown_Ornit {
            self.animatePressUp_Ornit()
        }
        
        // 触觉反馈
        let generator_Ornit = UIImpactFeedbackGenerator(style: .light)
        generator_Ornit.impactOccurred()
        
        // 触发回调
        onTapped_Ornit?()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Ornit() {
        loadCurrentUserAvatar_Ornit()
    }
}
