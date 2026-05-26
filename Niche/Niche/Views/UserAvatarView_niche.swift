import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Niche: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Niche: [UIColor] = [
        ColorConfig_Niche.primaryGradientStart_Niche,
        ColorConfig_Niche.secondaryGradientStart_Niche,
        UIColor(hexstring_Niche: "#63B3ED"),
        UIColor(hexstring_Niche: "#F6AD55"),
        UIColor(hexstring_Niche: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Niche: UIImageView = {
        let imageView_Niche = UIImageView()
        imageView_Niche.contentMode = .scaleAspectFill
        imageView_Niche.clipsToBounds = true
        imageView_Niche.backgroundColor = ColorConfig_Niche.backgroundPrimary_Niche
        return imageView_Niche
    }()
    
    // MARK: - 属性
    
    var userId_Niche: Int?
    var isCurrentUser_Niche: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Niche()
        observeUserState_Niche()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Niche.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Niche() {
        addSubview(imageView_Niche)
        
        imageView_Niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Niche() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Niche),
            name: UserViewModel_Niche.userStateDidChangeNotification_Niche,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Niche(userId_Niche: Int) {
        self.userId_Niche = userId_Niche
        
        // 判断是否是当前登录用户
        let currentUser_Niche = UserViewModel_Niche.shared_Niche.getCurrentUser_Niche()
        isCurrentUser_Niche = (currentUser_Niche.userId_Niche == userId_Niche)
        
        // 加载头像
        if isCurrentUser_Niche {
            loadCurrentUserAvatar_Niche(user_Niche: currentUser_Niche)
        } else {
            loadOtherUserAvatar_Niche(userId_Niche: userId_Niche)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Niche(user_Niche: LoginUserModel_Niche) {
        guard let headPath_Niche = user_Niche.userHead_Niche, !headPath_Niche.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Niche(color_Niche: ColorConfig_Niche.primaryGradientStart_Niche)
            return
        }
        
        loadAvatarFromPath_Niche(path_Niche: headPath_Niche, defaultColor_Niche: ColorConfig_Niche.primaryGradientStart_Niche)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Niche(userId_Niche: Int) {
        let userInfo_Niche = UserViewModel_Niche.shared_Niche.getUserById_Niche(userId_niche: userId_Niche)
        let color_Niche = Self.defaultAvatarColors_Niche[userId_Niche % Self.defaultAvatarColors_Niche.count]
        
        guard let headPath_Niche = userInfo_Niche.userHead_Niche, !headPath_Niche.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Niche(color_Niche: color_Niche)
            return
        }
        
        loadAvatarFromPath_Niche(path_Niche: headPath_Niche, defaultColor_Niche: color_Niche)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Niche(path_Niche: String, defaultColor_Niche: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Niche = UIImage(named: path_Niche) {
            imageView_Niche.image = assetImage_Niche
            imageView_Niche.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Niche = UIImage(contentsOfFile: path_Niche) {
            imageView_Niche.image = localImage_Niche
            imageView_Niche.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Niche.hasPrefix("http://") || path_Niche.hasPrefix("https://") {
            if let url_Niche = URL(string: path_Niche) {
                imageView_Niche.kf.setImage(
                    with: url_Niche,
                    placeholder: createPlaceholderImage_Niche(color_Niche: defaultColor_Niche),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Niche(color_Niche: defaultColor_Niche)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Niche: 图标颜色
    func setDefaultAvatar_Niche(color_Niche: UIColor) {
        imageView_Niche.image = UIImage(systemName: "person.circle.fill")
        imageView_Niche.tintColor = color_Niche
        imageView_Niche.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Niche(color_Niche: UIColor) -> UIImage? {
        let size_Niche = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Niche, false, 0)
        
        // 绘制圆形背景
        color_Niche.withAlphaComponent(0.2).setFill()
        let circlePath_Niche = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Niche))
        circlePath_Niche.fill()
        
        // 绘制人物图标
        if let icon_Niche = UIImage(systemName: "person.fill") {
            color_Niche.setFill()
            icon_Niche.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Niche = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Niche
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Niche() {
        if let userId_Niche = userId_Niche {
            configure_Niche(userId_Niche: userId_Niche)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Niche: UserAvatarView_Niche {

    // MARK: - 属性

    /// 点击回调
    var onTapped_Niche: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Niche()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Niche() {
        super.setupUI_Niche()
        
        // 启用用户交互
        isUserInteractionEnabled = true
        imageView_Niche.isUserInteractionEnabled = true

        // 添加点击手势（绑定到整个头像组件，避免局部区域点击失效）
        let tapSelfGesture_Niche = UITapGestureRecognizer(target: self, action: #selector(handleTap_Niche))
        addGestureRecognizer(tapSelfGesture_Niche)
        let tapGesture_Niche = UITapGestureRecognizer(target: self, action: #selector(handleTap_Niche))
        imageView_Niche.addGestureRecognizer(tapGesture_Niche)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Niche() {
        let currentUser_Niche = UserViewModel_Niche.shared_Niche.getCurrentUser_Niche()
        isCurrentUser_Niche = true
        userId_Niche = currentUser_Niche.userId_Niche
        
        guard let headPath_Niche = currentUser_Niche.userHead_Niche, !headPath_Niche.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Niche(color_Niche: ColorConfig_Niche.primaryGradientStart_Niche)
            return
        }
        
        loadAvatarFromPath_Niche(path_Niche: headPath_Niche, defaultColor_Niche: ColorConfig_Niche.primaryGradientStart_Niche)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Niche(color_Niche: UIColor) -> UIImage? {
        let size_Niche = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Niche, false, 0)
        
        // 绘制渐变背景
        let context_Niche = UIGraphicsGetCurrentContext()
        let colors_Niche = [
            ColorConfig_Niche.primaryGradientStart_Niche.cgColor,
            ColorConfig_Niche.primaryGradientEnd_Niche.cgColor
        ]
        let colorSpace_Niche = CGColorSpaceCreateDeviceRGB()
        let gradient_Niche = CGGradient(colorsSpace: colorSpace_Niche, colors: colors_Niche as CFArray, locations: nil)
        
        context_Niche?.drawLinearGradient(
            gradient_Niche!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Niche.width, y: size_Niche.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Niche = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Niche.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Niche = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Niche
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Niche() {
        // 缩放动画
        animatePressDown_Niche {
            self.animatePressUp_Niche()
        }
        
        // 触觉反馈
        let generator_Niche = UIImpactFeedbackGenerator(style: .light)
        generator_Niche.impactOccurred()
        
        // 触发回调
        onTapped_Niche?()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Niche() {
        loadCurrentUserAvatar_Niche()
    }
}
