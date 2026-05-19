import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Lumia: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Lumia: [UIColor] = [
        ColorConfig_Lumia.primaryGradientStart_Lumia,
        ColorConfig_Lumia.secondaryGradientStart_Lumia,
        UIColor(hexstring_Lumia: "#63B3ED"),
        UIColor(hexstring_Lumia: "#F6AD55"),
        UIColor(hexstring_Lumia: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Lumia: UIImageView = {
        let imageView_Lumia = UIImageView()
        imageView_Lumia.contentMode = .scaleAspectFill
        imageView_Lumia.clipsToBounds = true
        imageView_Lumia.backgroundColor = ColorConfig_Lumia.backgroundPrimary_Lumia
        return imageView_Lumia
    }()
    
    // MARK: - 属性
    
    var userId_Lumia: Int?
    var isCurrentUser_Lumia: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
        observeUserState_Lumia()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Lumia.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Lumia() {
        addSubview(imageView_Lumia)
        
        imageView_Lumia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Lumia() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Lumia),
            name: UserViewModel_Lumia.userStateDidChangeNotification_Lumia,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Lumia(userId_Lumia: Int) {
        self.userId_Lumia = userId_Lumia
        
        // 判断是否是当前登录用户
        let currentUser_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia()
        isCurrentUser_Lumia = (currentUser_Lumia.userId_Lumia == userId_Lumia)
        
        // 加载头像
        if isCurrentUser_Lumia {
            loadCurrentUserAvatar_Lumia(user_Lumia: currentUser_Lumia)
        } else {
            loadOtherUserAvatar_Lumia(userId_Lumia: userId_Lumia)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Lumia(user_Lumia: LoginUserModel_Lumia) {
        guard let headPath_Lumia = user_Lumia.userHead_Lumia, !headPath_Lumia.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Lumia(color_Lumia: ColorConfig_Lumia.primaryGradientStart_Lumia)
            return
        }
        
        loadAvatarFromPath_Lumia(path_Lumia: headPath_Lumia, defaultColor_Lumia: ColorConfig_Lumia.primaryGradientStart_Lumia)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Lumia(userId_Lumia: Int) {
        let userInfo_Lumia = UserViewModel_Lumia.shared_Lumia.getUserById_Lumia(userId_lumia: userId_Lumia)
        let color_Lumia = Self.defaultAvatarColors_Lumia[userId_Lumia % Self.defaultAvatarColors_Lumia.count]
        
        guard let headPath_Lumia = userInfo_Lumia.userHead_Lumia, !headPath_Lumia.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Lumia(color_Lumia: color_Lumia)
            return
        }
        
        loadAvatarFromPath_Lumia(path_Lumia: headPath_Lumia, defaultColor_Lumia: color_Lumia)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Lumia(path_Lumia: String, defaultColor_Lumia: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Lumia = UIImage(named: path_Lumia) {
            imageView_Lumia.image = assetImage_Lumia
            imageView_Lumia.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Lumia = UIImage(contentsOfFile: path_Lumia) {
            imageView_Lumia.image = localImage_Lumia
            imageView_Lumia.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Lumia.hasPrefix("http://") || path_Lumia.hasPrefix("https://") {
            if let url_Lumia = URL(string: path_Lumia) {
                imageView_Lumia.kf.setImage(
                    with: url_Lumia,
                    placeholder: createPlaceholderImage_Lumia(color_Lumia: defaultColor_Lumia),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Lumia(color_Lumia: defaultColor_Lumia)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Lumia: 图标颜色
    func setDefaultAvatar_Lumia(color_Lumia: UIColor) {
        imageView_Lumia.image = UIImage(systemName: "person.circle.fill")
        imageView_Lumia.tintColor = color_Lumia
        imageView_Lumia.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Lumia(color_Lumia: UIColor) -> UIImage? {
        let size_Lumia = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Lumia, false, 0)
        
        // 绘制圆形背景
        color_Lumia.withAlphaComponent(0.2).setFill()
        let circlePath_Lumia = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Lumia))
        circlePath_Lumia.fill()
        
        // 绘制人物图标
        if let icon_Lumia = UIImage(systemName: "person.fill") {
            color_Lumia.setFill()
            icon_Lumia.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Lumia = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Lumia
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Lumia() {
        if let userId_Lumia = userId_Lumia {
            configure_Lumia(userId_Lumia: userId_Lumia)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Lumia: UserAvatarView_Lumia {

    // MARK: - 属性

    /// 点击回调
    var onTapped_Lumia: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Lumia()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Lumia() {
        super.setupUI_Lumia()
        
        // 启用用户交互
        isUserInteractionEnabled = true
        imageView_Lumia.isUserInteractionEnabled = true

        // 添加点击手势（绑定到整个头像组件，避免局部区域点击失效）
        let tapSelfGesture_Lumia = UITapGestureRecognizer(target: self, action: #selector(handleTap_Lumia))
        addGestureRecognizer(tapSelfGesture_Lumia)
        let tapGesture_Lumia = UITapGestureRecognizer(target: self, action: #selector(handleTap_Lumia))
        imageView_Lumia.addGestureRecognizer(tapGesture_Lumia)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Lumia() {
        let currentUser_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia()
        isCurrentUser_Lumia = true
        userId_Lumia = currentUser_Lumia.userId_Lumia
        
        guard let headPath_Lumia = currentUser_Lumia.userHead_Lumia, !headPath_Lumia.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Lumia(color_Lumia: ColorConfig_Lumia.primaryGradientStart_Lumia)
            return
        }
        
        loadAvatarFromPath_Lumia(path_Lumia: headPath_Lumia, defaultColor_Lumia: ColorConfig_Lumia.primaryGradientStart_Lumia)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Lumia(color_Lumia: UIColor) -> UIImage? {
        let size_Lumia = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Lumia, false, 0)
        
        // 绘制渐变背景
        let context_Lumia = UIGraphicsGetCurrentContext()
        let colors_Lumia = [
            ColorConfig_Lumia.primaryGradientStart_Lumia.cgColor,
            ColorConfig_Lumia.primaryGradientEnd_Lumia.cgColor
        ]
        let colorSpace_Lumia = CGColorSpaceCreateDeviceRGB()
        let gradient_Lumia = CGGradient(colorsSpace: colorSpace_Lumia, colors: colors_Lumia as CFArray, locations: nil)
        
        context_Lumia?.drawLinearGradient(
            gradient_Lumia!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Lumia.width, y: size_Lumia.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Lumia = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Lumia.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Lumia = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Lumia
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Lumia() {
        // 缩放动画
        animatePressDown_Lumia {
            self.animatePressUp_Lumia()
        }
        
        // 触觉反馈
        let generator_Lumia = UIImpactFeedbackGenerator(style: .light)
        generator_Lumia.impactOccurred()
        
        // 触发回调
        onTapped_Lumia?()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Lumia() {
        loadCurrentUserAvatar_Lumia()
    }
}
