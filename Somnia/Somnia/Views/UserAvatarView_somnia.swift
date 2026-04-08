import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Somnia: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Somnia: [UIColor] = [
        ColorConfig_Somnia.primaryGradientStart_Somnia,
        ColorConfig_Somnia.secondaryGradientStart_Somnia,
        UIColor(hexstring_Somnia: "#63B3ED"),
        UIColor(hexstring_Somnia: "#F6AD55"),
        UIColor(hexstring_Somnia: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Somnia: UIImageView = {
        let imageView_Somnia = UIImageView()
        imageView_Somnia.contentMode = .scaleAspectFill
        imageView_Somnia.clipsToBounds = true
        imageView_Somnia.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia
        return imageView_Somnia
    }()
    
    // MARK: - 属性
    
    var userId_Somnia: Int?
    var isCurrentUser_Somnia: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Somnia()
        observeUserState_Somnia()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Somnia.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Somnia() {
        addSubview(imageView_Somnia)
        
        imageView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Somnia() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Somnia),
            name: UserViewModel_Somnia.userStateDidChangeNotification_Somnia,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Somnia(userId_Somnia: Int) {
        self.userId_Somnia = userId_Somnia
        
        // 判断是否是当前登录用户
        let currentUser_Somnia = UserViewModel_Somnia.shared_Somnia.getCurrentUser_Somnia()
        isCurrentUser_Somnia = (currentUser_Somnia.userId_Somnia == userId_Somnia)
        
        // 加载头像
        if isCurrentUser_Somnia {
            loadCurrentUserAvatar_Somnia(user_Somnia: currentUser_Somnia)
        } else {
            loadOtherUserAvatar_Somnia(userId_Somnia: userId_Somnia)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Somnia(user_Somnia: LoginUserModel_Somnia) {
        guard let headPath_Somnia = user_Somnia.userHead_Somnia, !headPath_Somnia.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Somnia(color_Somnia: ColorConfig_Somnia.primaryGradientStart_Somnia)
            return
        }
        
        loadAvatarFromPath_Somnia(path_Somnia: headPath_Somnia, defaultColor_Somnia: ColorConfig_Somnia.primaryGradientStart_Somnia)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Somnia(userId_Somnia: Int) {
        let userInfo_Somnia = UserViewModel_Somnia.shared_Somnia.getUserById_Somnia(userId_somnia: userId_Somnia)
        let color_Somnia = Self.defaultAvatarColors_Somnia[userId_Somnia % Self.defaultAvatarColors_Somnia.count]
        
        guard let headPath_Somnia = userInfo_Somnia.userHead_Somnia, !headPath_Somnia.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Somnia(color_Somnia: color_Somnia)
            return
        }
        
        loadAvatarFromPath_Somnia(path_Somnia: headPath_Somnia, defaultColor_Somnia: color_Somnia)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Somnia(path_Somnia: String, defaultColor_Somnia: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Somnia = UIImage(named: path_Somnia) {
            imageView_Somnia.image = assetImage_Somnia
            imageView_Somnia.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Somnia = UIImage(contentsOfFile: path_Somnia) {
            imageView_Somnia.image = localImage_Somnia
            imageView_Somnia.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Somnia.hasPrefix("http://") || path_Somnia.hasPrefix("https://") {
            if let url_Somnia = URL(string: path_Somnia) {
                imageView_Somnia.kf.setImage(
                    with: url_Somnia,
                    placeholder: createPlaceholderImage_Somnia(color_Somnia: defaultColor_Somnia),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Somnia(color_Somnia: defaultColor_Somnia)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Somnia: 图标颜色
    func setDefaultAvatar_Somnia(color_Somnia: UIColor) {
        imageView_Somnia.image = UIImage(systemName: "person.circle.fill")
        imageView_Somnia.tintColor = color_Somnia
        imageView_Somnia.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Somnia(color_Somnia: UIColor) -> UIImage? {
        let size_Somnia = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Somnia, false, 0)
        
        // 绘制圆形背景
        color_Somnia.withAlphaComponent(0.2).setFill()
        let circlePath_Somnia = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Somnia))
        circlePath_Somnia.fill()
        
        // 绘制人物图标
        if let icon_Somnia = UIImage(systemName: "person.fill") {
            color_Somnia.setFill()
            icon_Somnia.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Somnia = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Somnia
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Somnia() {
        if let userId_Somnia = userId_Somnia {
            configure_Somnia(userId_Somnia: userId_Somnia)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Somnia: UserAvatarView_Somnia {
    
    // MARK: - 属性

    /// 点击回调
    var onTapped_Somnia: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Somnia()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置（重写）

    override func setupUI_Somnia() {
        super.setupUI_Somnia()
        imageView_Somnia.isUserInteractionEnabled = true
        let tapGesture_Somnia = UITapGestureRecognizer(target: self, action: #selector(handleTap_Somnia))
        imageView_Somnia.addGestureRecognizer(tapGesture_Somnia)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Somnia() {
        let currentUser_Somnia = UserViewModel_Somnia.shared_Somnia.getCurrentUser_Somnia()
        isCurrentUser_Somnia = true
        userId_Somnia = currentUser_Somnia.userId_Somnia
        
        guard let headPath_Somnia = currentUser_Somnia.userHead_Somnia, !headPath_Somnia.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Somnia(color_Somnia: ColorConfig_Somnia.primaryGradientStart_Somnia)
            return
        }
        
        loadAvatarFromPath_Somnia(path_Somnia: headPath_Somnia, defaultColor_Somnia: ColorConfig_Somnia.primaryGradientStart_Somnia)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Somnia(color_Somnia: UIColor) -> UIImage? {
        let size_Somnia = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Somnia, false, 0)
        
        // 绘制渐变背景
        let context_Somnia = UIGraphicsGetCurrentContext()
        let colors_Somnia = [
            ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
            ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
        ]
        let colorSpace_Somnia = CGColorSpaceCreateDeviceRGB()
        let gradient_Somnia = CGGradient(colorsSpace: colorSpace_Somnia, colors: colors_Somnia as CFArray, locations: nil)
        
        context_Somnia?.drawLinearGradient(
            gradient_Somnia!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Somnia.width, y: size_Somnia.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Somnia = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Somnia.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Somnia = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Somnia
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Somnia() {
        // 缩放动画
        animatePressDown_Somnia {
            self.animatePressUp_Somnia()
        }
        
        // 触觉反馈
        let generator_Somnia = UIImpactFeedbackGenerator(style: .light)
        generator_Somnia.impactOccurred()
        
        // 触发回调
        onTapped_Somnia?()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Somnia() {
        loadCurrentUserAvatar_Somnia()
    }
}
