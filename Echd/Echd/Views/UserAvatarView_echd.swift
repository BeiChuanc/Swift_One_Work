import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Echd: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Echd: [UIColor] = [
        ColorConfig_Echd.primaryGradientStart_Echd,
        ColorConfig_Echd.secondaryGradientStart_Echd,
        UIColor(hexstring_Echd: "#63B3ED"),
        UIColor(hexstring_Echd: "#F6AD55"),
        UIColor(hexstring_Echd: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Echd: UIImageView = {
        let imageView_Echd = UIImageView()
        imageView_Echd.contentMode = .scaleAspectFill
        imageView_Echd.clipsToBounds = true
        imageView_Echd.backgroundColor = ColorConfig_Echd.backgroundPrimary_Echd
        return imageView_Echd
    }()
    
    // MARK: - 属性
    
    var userId_Echd: Int?
    var isCurrentUser_Echd: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Echd()
        observeUserState_Echd()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Echd.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Echd() {
        addSubview(imageView_Echd)
        
        imageView_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Echd() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Echd),
            name: UserViewModel_Echd.userStateDidChangeNotification_Echd,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Echd(userId_Echd: Int) {
        self.userId_Echd = userId_Echd
        
        // 判断是否是当前登录用户
        let currentUser_Echd = UserViewModel_Echd.shared_Echd.getCurrentUser_Echd()
        isCurrentUser_Echd = (currentUser_Echd.userId_Echd == userId_Echd)
        
        // 加载头像
        if isCurrentUser_Echd {
            loadCurrentUserAvatar_Echd(user_Echd: currentUser_Echd)
        } else {
            loadOtherUserAvatar_Echd(userId_Echd: userId_Echd)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Echd(user_Echd: LoginUserModel_Echd) {
        guard let headPath_Echd = user_Echd.userHead_Echd, !headPath_Echd.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Echd(color_Echd: ColorConfig_Echd.primaryGradientStart_Echd)
            return
        }
        
        loadAvatarFromPath_Echd(path_Echd: headPath_Echd, defaultColor_Echd: ColorConfig_Echd.primaryGradientStart_Echd)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Echd(userId_Echd: Int) {
        let userInfo_Echd = UserViewModel_Echd.shared_Echd.getUserById_Echd(userId_echd: userId_Echd)
        let color_Echd = Self.defaultAvatarColors_Echd[userId_Echd % Self.defaultAvatarColors_Echd.count]
        
        guard let headPath_Echd = userInfo_Echd.userHead_Echd, !headPath_Echd.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Echd(color_Echd: color_Echd)
            return
        }
        
        loadAvatarFromPath_Echd(path_Echd: headPath_Echd, defaultColor_Echd: color_Echd)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Echd(path_Echd: String, defaultColor_Echd: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Echd = UIImage(named: path_Echd) {
            imageView_Echd.image = assetImage_Echd
            imageView_Echd.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Echd = UIImage(contentsOfFile: path_Echd) {
            imageView_Echd.image = localImage_Echd
            imageView_Echd.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Echd.hasPrefix("http://") || path_Echd.hasPrefix("https://") {
            if let url_Echd = URL(string: path_Echd) {
                imageView_Echd.kf.setImage(
                    with: url_Echd,
                    placeholder: createPlaceholderImage_Echd(color_Echd: defaultColor_Echd),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Echd(color_Echd: defaultColor_Echd)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Echd: 图标颜色
    func setDefaultAvatar_Echd(color_Echd: UIColor) {
        imageView_Echd.image = UIImage(systemName: "person.circle.fill")
        imageView_Echd.tintColor = color_Echd
        imageView_Echd.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Echd(color_Echd: UIColor) -> UIImage? {
        let size_Echd = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Echd, false, 0)
        
        // 绘制圆形背景
        color_Echd.withAlphaComponent(0.2).setFill()
        let circlePath_Echd = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Echd))
        circlePath_Echd.fill()
        
        // 绘制人物图标
        if let icon_Echd = UIImage(systemName: "person.fill") {
            color_Echd.setFill()
            icon_Echd.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Echd = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Echd
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Echd() {
        if let userId_Echd = userId_Echd {
            configure_Echd(userId_Echd: userId_Echd)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Echd: UserAvatarView_Echd {

    // MARK: - 属性

    /// 点击回调
    var onTapped_Echd: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Echd()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Echd() {
        super.setupUI_Echd()
        
        // 启用用户交互
        isUserInteractionEnabled = true
        imageView_Echd.isUserInteractionEnabled = true

        // 添加点击手势（绑定到整个头像组件，避免局部区域点击失效）
        let tapSelfGesture_Echd = UITapGestureRecognizer(target: self, action: #selector(handleTap_Echd))
        addGestureRecognizer(tapSelfGesture_Echd)
        let tapGesture_Echd = UITapGestureRecognizer(target: self, action: #selector(handleTap_Echd))
        imageView_Echd.addGestureRecognizer(tapGesture_Echd)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Echd() {
        let currentUser_Echd = UserViewModel_Echd.shared_Echd.getCurrentUser_Echd()
        isCurrentUser_Echd = true
        userId_Echd = currentUser_Echd.userId_Echd
        
        guard let headPath_Echd = currentUser_Echd.userHead_Echd, !headPath_Echd.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Echd(color_Echd: ColorConfig_Echd.primaryGradientStart_Echd)
            return
        }
        
        loadAvatarFromPath_Echd(path_Echd: headPath_Echd, defaultColor_Echd: ColorConfig_Echd.primaryGradientStart_Echd)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Echd(color_Echd: UIColor) -> UIImage? {
        let size_Echd = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Echd, false, 0)
        
        // 绘制渐变背景
        let context_Echd = UIGraphicsGetCurrentContext()
        let colors_Echd = [
            ColorConfig_Echd.primaryGradientStart_Echd.cgColor,
            ColorConfig_Echd.primaryGradientEnd_Echd.cgColor
        ]
        let colorSpace_Echd = CGColorSpaceCreateDeviceRGB()
        let gradient_Echd = CGGradient(colorsSpace: colorSpace_Echd, colors: colors_Echd as CFArray, locations: nil)
        
        context_Echd?.drawLinearGradient(
            gradient_Echd!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Echd.width, y: size_Echd.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Echd = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Echd.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Echd = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Echd
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Echd() {
        // 缩放动画
        animatePressDown_Echd {
            self.animatePressUp_Echd()
        }
        
        // 触觉反馈
        let generator_Echd = UIImpactFeedbackGenerator(style: .light)
        generator_Echd.impactOccurred()
        
        // 触发回调
        onTapped_Echd?()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Echd() {
        loadCurrentUserAvatar_Echd()
    }
}
