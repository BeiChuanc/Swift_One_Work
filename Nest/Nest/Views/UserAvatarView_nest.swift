import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Nest: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Nest: [UIColor] = [
        ColorConfig_Nest.primaryGradientStart_Nest,
        ColorConfig_Nest.secondaryGradientStart_Nest,
        UIColor(hexstring_Nest: "#63B3ED"),
        UIColor(hexstring_Nest: "#F6AD55"),
        UIColor(hexstring_Nest: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Nest: UIImageView = {
        let imageView_Nest = UIImageView()
        imageView_Nest.contentMode = .scaleAspectFill
        imageView_Nest.clipsToBounds = true
        imageView_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        return imageView_Nest
    }()
    
    // MARK: - 属性
    
    var userId_Nest: Int?
    var isCurrentUser_Nest: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Nest()
        observeUserState_Nest()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Nest.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Nest() {
        addSubview(imageView_Nest)
        
        imageView_Nest.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Nest() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Nest),
            name: UserViewModel_Nest.userStateDidChangeNotification_Nest,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Nest(userId_Nest: Int) {
        self.userId_Nest = userId_Nest
        
        // 判断是否是当前登录用户
        let currentUser_Nest = UserViewModel_Nest.shared_Nest.getCurrentUser_Nest()
        isCurrentUser_Nest = (currentUser_Nest.userId_Nest == userId_Nest)
        
        // 加载头像
        if isCurrentUser_Nest {
            loadCurrentUserAvatar_Nest(user_Nest: currentUser_Nest)
        } else {
            loadOtherUserAvatar_Nest(userId_Nest: userId_Nest)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Nest(user_Nest: LoginUserModel_Nest) {
        guard let headPath_Nest = user_Nest.userHead_Nest, !headPath_Nest.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Nest(color_Nest: ColorConfig_Nest.primaryGradientStart_Nest)
            return
        }
        
        loadAvatarFromPath_Nest(path_Nest: headPath_Nest, defaultColor_Nest: ColorConfig_Nest.primaryGradientStart_Nest)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Nest(userId_Nest: Int) {
        let userInfo_Nest = UserViewModel_Nest.shared_Nest.getUserById_Nest(userId_nest: userId_Nest)
        let color_Nest = Self.defaultAvatarColors_Nest[userId_Nest % Self.defaultAvatarColors_Nest.count]
        
        guard let headPath_Nest = userInfo_Nest.userHead_Nest, !headPath_Nest.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Nest(color_Nest: color_Nest)
            return
        }
        
        loadAvatarFromPath_Nest(path_Nest: headPath_Nest, defaultColor_Nest: color_Nest)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Nest(path_Nest: String, defaultColor_Nest: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Nest = UIImage(named: path_Nest) {
            imageView_Nest.image = assetImage_Nest
            imageView_Nest.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Nest = UIImage(contentsOfFile: path_Nest) {
            imageView_Nest.image = localImage_Nest
            imageView_Nest.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Nest.hasPrefix("http://") || path_Nest.hasPrefix("https://") {
            if let url_Nest = URL(string: path_Nest) {
                imageView_Nest.kf.setImage(
                    with: url_Nest,
                    placeholder: createPlaceholderImage_Nest(color_Nest: defaultColor_Nest),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Nest(color_Nest: defaultColor_Nest)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Nest: 图标颜色
    func setDefaultAvatar_Nest(color_Nest: UIColor) {
        imageView_Nest.image = UIImage(systemName: "person.circle.fill")
        imageView_Nest.tintColor = color_Nest
        imageView_Nest.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Nest(color_Nest: UIColor) -> UIImage? {
        let size_Nest = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Nest, false, 0)
        
        // 绘制圆形背景
        color_Nest.withAlphaComponent(0.2).setFill()
        let circlePath_Nest = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Nest))
        circlePath_Nest.fill()
        
        // 绘制人物图标
        if let icon_Nest = UIImage(systemName: "person.fill") {
            color_Nest.setFill()
            icon_Nest.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Nest = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Nest
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Nest() {
        if let userId_Nest = userId_Nest {
            configure_Nest(userId_Nest: userId_Nest)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Nest: UserAvatarView_Nest {

    // MARK: - 属性

    /// 点击回调
    var onTapped_Nest: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Nest()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Nest() {
        super.setupUI_Nest()
        
        // 启用用户交互
        isUserInteractionEnabled = true
        imageView_Nest.isUserInteractionEnabled = true

        // 添加点击手势（绑定到整个头像组件，避免局部区域点击失效）
        let tapSelfGesture_Nest = UITapGestureRecognizer(target: self, action: #selector(handleTap_Nest))
        addGestureRecognizer(tapSelfGesture_Nest)
        let tapGesture_Nest = UITapGestureRecognizer(target: self, action: #selector(handleTap_Nest))
        imageView_Nest.addGestureRecognizer(tapGesture_Nest)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Nest() {
        let currentUser_Nest = UserViewModel_Nest.shared_Nest.getCurrentUser_Nest()
        isCurrentUser_Nest = true
        userId_Nest = currentUser_Nest.userId_Nest
        
        guard let headPath_Nest = currentUser_Nest.userHead_Nest, !headPath_Nest.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Nest(color_Nest: ColorConfig_Nest.primaryGradientStart_Nest)
            return
        }
        
        loadAvatarFromPath_Nest(path_Nest: headPath_Nest, defaultColor_Nest: ColorConfig_Nest.primaryGradientStart_Nest)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Nest(color_Nest: UIColor) -> UIImage? {
        let size_Nest = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Nest, false, 0)
        
        // 绘制渐变背景
        let context_Nest = UIGraphicsGetCurrentContext()
        let colors_Nest = [
            ColorConfig_Nest.primaryGradientStart_Nest.cgColor,
            ColorConfig_Nest.primaryGradientEnd_Nest.cgColor
        ]
        let colorSpace_Nest = CGColorSpaceCreateDeviceRGB()
        let gradient_Nest = CGGradient(colorsSpace: colorSpace_Nest, colors: colors_Nest as CFArray, locations: nil)
        
        context_Nest?.drawLinearGradient(
            gradient_Nest!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Nest.width, y: size_Nest.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Nest = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Nest.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Nest = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Nest
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Nest() {
        // 缩放动画
        animatePressDown_Nest {
            self.animatePressUp_Nest()
        }
        
        // 触觉反馈
        let generator_Nest = UIImpactFeedbackGenerator(style: .light)
        generator_Nest.impactOccurred()
        
        // 触发回调
        onTapped_Nest?()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Nest() {
        loadCurrentUserAvatar_Nest()
    }
}
