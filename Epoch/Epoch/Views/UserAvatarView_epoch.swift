import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Epoch: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Epoch: [UIColor] = [
        ColorConfig_Epoch.primaryGradientStart_Epoch,
        ColorConfig_Epoch.secondaryGradientStart_Epoch,
        UIColor(hexstring_Epoch: "#63B3ED"),
        UIColor(hexstring_Epoch: "#F6AD55"),
        UIColor(hexstring_Epoch: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Epoch: UIImageView = {
        let imageView_Epoch = UIImageView()
        imageView_Epoch.contentMode = .scaleAspectFill
        imageView_Epoch.clipsToBounds = true
        imageView_Epoch.backgroundColor = ColorConfig_Epoch.backgroundPrimary_Epoch
        return imageView_Epoch
    }()
    
    // MARK: - 属性
    
    var userId_Epoch: Int?
    var isCurrentUser_Epoch: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
        observeUserState_Epoch()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Epoch.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Epoch() {
        addSubview(imageView_Epoch)
        
        imageView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Epoch() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Epoch),
            name: UserViewModel_Epoch.userStateDidChangeNotification_Epoch,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Epoch(userId_Epoch: Int) {
        self.userId_Epoch = userId_Epoch
        
        // 判断是否是当前登录用户
        let currentUser_Epoch = UserViewModel_Epoch.shared_Epoch.getCurrentUser_Epoch()
        isCurrentUser_Epoch = (currentUser_Epoch.userId_Epoch == userId_Epoch)
        
        // 加载头像
        if isCurrentUser_Epoch {
            loadCurrentUserAvatar_Epoch(user_Epoch: currentUser_Epoch)
        } else {
            loadOtherUserAvatar_Epoch(userId_Epoch: userId_Epoch)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Epoch(user_Epoch: LoginUserModel_Epoch) {
        guard let headPath_Epoch = user_Epoch.userHead_Epoch, !headPath_Epoch.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Epoch(color_Epoch: ColorConfig_Epoch.primaryGradientStart_Epoch)
            return
        }
        
        loadAvatarFromPath_Epoch(path_Epoch: headPath_Epoch, defaultColor_Epoch: ColorConfig_Epoch.primaryGradientStart_Epoch)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Epoch(userId_Epoch: Int) {
        let userInfo_Epoch = UserViewModel_Epoch.shared_Epoch.getUserById_Epoch(userId_epoch: userId_Epoch)
        let color_Epoch = Self.defaultAvatarColors_Epoch[userId_Epoch % Self.defaultAvatarColors_Epoch.count]
        
        guard let headPath_Epoch = userInfo_Epoch.userHead_Epoch, !headPath_Epoch.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Epoch(color_Epoch: color_Epoch)
            return
        }
        
        loadAvatarFromPath_Epoch(path_Epoch: headPath_Epoch, defaultColor_Epoch: color_Epoch)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Epoch(path_Epoch: String, defaultColor_Epoch: UIColor) {
        // 1. 优先加载系统图标，占位资源统一走系统符号
        if let systemImage_Epoch = UIImage(systemName: path_Epoch) {
            let config_epoch = UIImage.SymbolConfiguration(pointSize: 42, weight: .regular)
            imageView_Epoch.image = systemImage_Epoch.applyingSymbolConfiguration(config_epoch)
            imageView_Epoch.tintColor = defaultColor_Epoch
            imageView_Epoch.contentMode = .scaleAspectFit
            return
        }

        // 2. 尝试从Assets加载
        if let assetImage_Epoch = UIImage(named: path_Epoch) {
            imageView_Epoch.image = assetImage_Epoch
            imageView_Epoch.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从相册路径加载
        if let localImage_Epoch = UIImage(contentsOfFile: path_Epoch) {
            imageView_Epoch.image = localImage_Epoch
            imageView_Epoch.contentMode = .scaleAspectFill
            return
        }
        
        // 4. 尝试从网络URL加载
        if path_Epoch.hasPrefix("http://") || path_Epoch.hasPrefix("https://") {
            if let url_Epoch = URL(string: path_Epoch) {
                imageView_Epoch.kf.setImage(
                    with: url_Epoch,
                    placeholder: createPlaceholderImage_Epoch(color_Epoch: defaultColor_Epoch),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 5. 都失败则使用默认头像
        setDefaultAvatar_Epoch(color_Epoch: defaultColor_Epoch)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Epoch: 图标颜色
    func setDefaultAvatar_Epoch(color_Epoch: UIColor) {
        let config_epoch = UIImage.SymbolConfiguration(pointSize: 42, weight: .regular)
        imageView_Epoch.image = UIImage(systemName: "person.crop.circle.fill")?.applyingSymbolConfiguration(config_epoch)
        imageView_Epoch.tintColor = color_Epoch
        imageView_Epoch.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Epoch(color_Epoch: UIColor) -> UIImage? {
        let size_Epoch = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Epoch, false, 0)
        
        // 绘制圆形背景
        color_Epoch.withAlphaComponent(0.2).setFill()
        let circlePath_Epoch = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Epoch))
        circlePath_Epoch.fill()
        
        // 绘制人物图标
        if let icon_Epoch = UIImage(systemName: "person.fill") {
            color_Epoch.setFill()
            icon_Epoch.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Epoch = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Epoch
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Epoch() {
        if let userId_Epoch = userId_Epoch {
            configure_Epoch(userId_Epoch: userId_Epoch)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Epoch: UserAvatarView_Epoch {

    // MARK: - 属性

    /// 点击回调
    var onTapped_Epoch: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Epoch()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Epoch() {
        super.setupUI_Epoch()
        
        // 启用用户交互
        isUserInteractionEnabled = true
        imageView_Epoch.isUserInteractionEnabled = true

        // 添加点击手势（绑定到整个头像组件，避免局部区域点击失效）
        let tapSelfGesture_Epoch = UITapGestureRecognizer(target: self, action: #selector(handleTap_Epoch))
        addGestureRecognizer(tapSelfGesture_Epoch)
        let tapGesture_Epoch = UITapGestureRecognizer(target: self, action: #selector(handleTap_Epoch))
        imageView_Epoch.addGestureRecognizer(tapGesture_Epoch)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Epoch() {
        let currentUser_Epoch = UserViewModel_Epoch.shared_Epoch.getCurrentUser_Epoch()
        isCurrentUser_Epoch = true
        userId_Epoch = currentUser_Epoch.userId_Epoch
        
        guard let headPath_Epoch = currentUser_Epoch.userHead_Epoch, !headPath_Epoch.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Epoch(color_Epoch: ColorConfig_Epoch.primaryGradientStart_Epoch)
            return
        }
        
        loadAvatarFromPath_Epoch(path_Epoch: headPath_Epoch, defaultColor_Epoch: ColorConfig_Epoch.primaryGradientStart_Epoch)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Epoch(color_Epoch: UIColor) -> UIImage? {
        let size_Epoch = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Epoch, false, 0)
        
        // 绘制渐变背景
        let context_Epoch = UIGraphicsGetCurrentContext()
        let colors_Epoch = [
            ColorConfig_Epoch.primaryGradientStart_Epoch.cgColor,
            ColorConfig_Epoch.primaryGradientEnd_Epoch.cgColor
        ]
        let colorSpace_Epoch = CGColorSpaceCreateDeviceRGB()
        let gradient_Epoch = CGGradient(colorsSpace: colorSpace_Epoch, colors: colors_Epoch as CFArray, locations: nil)
        
        context_Epoch?.drawLinearGradient(
            gradient_Epoch!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Epoch.width, y: size_Epoch.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Epoch = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Epoch.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Epoch = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Epoch
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Epoch() {
        // 缩放动画
        animatePressDown_Epoch {
            self.animatePressUp_Epoch()
        }
        
        // 触觉反馈
        let generator_Epoch = UIImpactFeedbackGenerator(style: .light)
        generator_Epoch.impactOccurred()
        
        // 触发回调
        onTapped_Epoch?()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Epoch() {
        loadCurrentUserAvatar_Epoch()
    }
}
