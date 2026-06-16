import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Retrs: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Retrs: [UIColor] = [
        ColorConfig_Retrs.primaryGradientStart_Retrs,
        ColorConfig_Retrs.secondaryGradientStart_Retrs,
        UIColor(hexstring_Retrs: "#63B3ED"),
        UIColor(hexstring_Retrs: "#F6AD55"),
        UIColor(hexstring_Retrs: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Retrs: UIImageView = {
        let imageView_Retrs = UIImageView()
        imageView_Retrs.contentMode = .scaleAspectFill
        imageView_Retrs.clipsToBounds = true
        imageView_Retrs.backgroundColor = ColorConfig_Retrs.backgroundPrimary_Retrs
        return imageView_Retrs
    }()
    
    // MARK: - 属性
    
    var userId_Retrs: Int?
    var isCurrentUser_Retrs: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Retrs()
        observeUserState_Retrs()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Retrs.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Retrs() {
        addSubview(imageView_Retrs)
        
        imageView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Retrs() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Retrs),
            name: UserViewModel_Retrs.userStateDidChangeNotification_Retrs,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Retrs(userId_Retrs: Int) {
        self.userId_Retrs = userId_Retrs
        
        // 判断是否是当前登录用户
        let currentUser_Retrs = UserViewModel_Retrs.shared_Retrs.getCurrentUser_Retrs()
        isCurrentUser_Retrs = (currentUser_Retrs.userId_Retrs == userId_Retrs)
        
        // 加载头像
        if isCurrentUser_Retrs {
            loadCurrentUserAvatar_Retrs(user_Retrs: currentUser_Retrs)
        } else {
            loadOtherUserAvatar_Retrs(userId_Retrs: userId_Retrs)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Retrs(user_Retrs: LoginUserModel_Retrs) {
        guard let headPath_Retrs = user_Retrs.userHead_Retrs, !headPath_Retrs.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Retrs(color_Retrs: ColorConfig_Retrs.primaryGradientStart_Retrs)
            return
        }
        
        loadAvatarFromPath_Retrs(path_Retrs: headPath_Retrs, defaultColor_Retrs: ColorConfig_Retrs.primaryGradientStart_Retrs)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Retrs(userId_Retrs: Int) {
        let userInfo_Retrs = UserViewModel_Retrs.shared_Retrs.getUserById_Retrs(userId_retrs: userId_Retrs)
        let color_Retrs = Self.defaultAvatarColors_Retrs[userId_Retrs % Self.defaultAvatarColors_Retrs.count]
        
        guard let headPath_Retrs = userInfo_Retrs.userHead_Retrs, !headPath_Retrs.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Retrs(color_Retrs: color_Retrs)
            return
        }
        
        loadAvatarFromPath_Retrs(path_Retrs: headPath_Retrs, defaultColor_Retrs: color_Retrs)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Retrs(path_Retrs: String, defaultColor_Retrs: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Retrs = UIImage(named: path_Retrs) {
            imageView_Retrs.image = assetImage_Retrs
            imageView_Retrs.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Retrs = UIImage(contentsOfFile: path_Retrs) {
            imageView_Retrs.image = localImage_Retrs
            imageView_Retrs.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Retrs.hasPrefix("http://") || path_Retrs.hasPrefix("https://") {
            if let url_Retrs = URL(string: path_Retrs) {
                imageView_Retrs.kf.setImage(
                    with: url_Retrs,
                    placeholder: createPlaceholderImage_Retrs(color_Retrs: defaultColor_Retrs),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Retrs(color_Retrs: defaultColor_Retrs)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Retrs: 图标颜色
    func setDefaultAvatar_Retrs(color_Retrs: UIColor) {
        imageView_Retrs.image = UIImage(systemName: "person.circle.fill")
        imageView_Retrs.tintColor = color_Retrs
        imageView_Retrs.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Retrs(color_Retrs: UIColor) -> UIImage? {
        let size_Retrs = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Retrs, false, 0)
        
        // 绘制圆形背景
        color_Retrs.withAlphaComponent(0.2).setFill()
        let circlePath_Retrs = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Retrs))
        circlePath_Retrs.fill()
        
        // 绘制人物图标
        if let icon_Retrs = UIImage(systemName: "person.fill") {
            color_Retrs.setFill()
            icon_Retrs.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Retrs = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Retrs
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Retrs() {
        if let userId_Retrs = userId_Retrs {
            configure_Retrs(userId_Retrs: userId_Retrs)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Retrs: UserAvatarView_Retrs {

    // MARK: - 属性

    /// 点击回调
    var onTapped_Retrs: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Retrs()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Retrs() {
        super.setupUI_Retrs()
        
        // 启用用户交互
        isUserInteractionEnabled = true
        imageView_Retrs.isUserInteractionEnabled = true

        // 添加点击手势（绑定到整个头像组件，避免局部区域点击失效）
        let tapSelfGesture_Retrs = UITapGestureRecognizer(target: self, action: #selector(handleTap_Retrs))
        addGestureRecognizer(tapSelfGesture_Retrs)
        let tapGesture_Retrs = UITapGestureRecognizer(target: self, action: #selector(handleTap_Retrs))
        imageView_Retrs.addGestureRecognizer(tapGesture_Retrs)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Retrs() {
        let currentUser_Retrs = UserViewModel_Retrs.shared_Retrs.getCurrentUser_Retrs()
        isCurrentUser_Retrs = true
        userId_Retrs = currentUser_Retrs.userId_Retrs
        
        guard let headPath_Retrs = currentUser_Retrs.userHead_Retrs, !headPath_Retrs.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Retrs(color_Retrs: ColorConfig_Retrs.primaryGradientStart_Retrs)
            return
        }
        
        loadAvatarFromPath_Retrs(path_Retrs: headPath_Retrs, defaultColor_Retrs: ColorConfig_Retrs.primaryGradientStart_Retrs)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Retrs(color_Retrs: UIColor) -> UIImage? {
        let size_Retrs = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Retrs, false, 0)
        
        // 绘制渐变背景
        let context_Retrs = UIGraphicsGetCurrentContext()
        let colors_Retrs = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
        ]
        let colorSpace_Retrs = CGColorSpaceCreateDeviceRGB()
        let gradient_Retrs = CGGradient(colorsSpace: colorSpace_Retrs, colors: colors_Retrs as CFArray, locations: nil)
        
        context_Retrs?.drawLinearGradient(
            gradient_Retrs!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Retrs.width, y: size_Retrs.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Retrs = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Retrs.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Retrs = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Retrs
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Retrs() {
        // 缩放动画
        animatePressDown_Retrs {
            self.animatePressUp_Retrs()
        }
        
        // 触觉反馈
        let generator_Retrs = UIImpactFeedbackGenerator(style: .light)
        generator_Retrs.impactOccurred()
        
        // 触发回调
        onTapped_Retrs?()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Retrs() {
        loadCurrentUserAvatar_Retrs()
    }
}
