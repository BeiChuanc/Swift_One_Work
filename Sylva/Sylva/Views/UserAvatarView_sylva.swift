import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Sylva: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Sylva: [UIColor] = [
        ColorConfig_Sylva.primaryGradientStart_Sylva,
        ColorConfig_Sylva.secondaryGradientStart_Sylva,
        UIColor(hexstring_Sylva: "#63B3ED"),
        UIColor(hexstring_Sylva: "#F6AD55"),
        UIColor(hexstring_Sylva: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Sylva: UIImageView = {
        let imageView_Sylva = UIImageView()
        imageView_Sylva.contentMode = .scaleAspectFill
        imageView_Sylva.clipsToBounds = true
        imageView_Sylva.backgroundColor = ColorConfig_Sylva.backgroundPrimary_Sylva
        return imageView_Sylva
    }()
    
    // MARK: - 属性
    
    var userId_Sylva: Int?
    var isCurrentUser_Sylva: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Sylva()
        observeUserState_Sylva()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Sylva.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Sylva() {
        addSubview(imageView_Sylva)
        
        imageView_Sylva.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Sylva() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Sylva),
            name: UserViewModel_Sylva.userStateDidChangeNotification_Sylva,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Sylva(userId_Sylva: Int) {
        self.userId_Sylva = userId_Sylva
        
        // 判断是否是当前登录用户
        let currentUser_Sylva = UserViewModel_Sylva.shared_Sylva.getCurrentUser_Sylva()
        isCurrentUser_Sylva = (currentUser_Sylva.userId_Sylva == userId_Sylva)
        
        // 加载头像
        if isCurrentUser_Sylva {
            loadCurrentUserAvatar_Sylva(user_Sylva: currentUser_Sylva)
        } else {
            loadOtherUserAvatar_Sylva(userId_Sylva: userId_Sylva)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Sylva(user_Sylva: LoginUserModel_Sylva) {
        guard let headPath_Sylva = user_Sylva.userHead_Sylva, !headPath_Sylva.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Sylva(color_Sylva: ColorConfig_Sylva.primaryGradientStart_Sylva)
            return
        }
        
        loadAvatarFromPath_Sylva(path_Sylva: headPath_Sylva, defaultColor_Sylva: ColorConfig_Sylva.primaryGradientStart_Sylva)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Sylva(userId_Sylva: Int) {
        let userInfo_Sylva = UserViewModel_Sylva.shared_Sylva.getUserById_Sylva(userId_sylva: userId_Sylva)
        let color_Sylva = Self.defaultAvatarColors_Sylva[userId_Sylva % Self.defaultAvatarColors_Sylva.count]
        
        guard let headPath_Sylva = userInfo_Sylva.userHead_Sylva, !headPath_Sylva.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Sylva(color_Sylva: color_Sylva)
            return
        }
        
        loadAvatarFromPath_Sylva(path_Sylva: headPath_Sylva, defaultColor_Sylva: color_Sylva)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Sylva(path_Sylva: String, defaultColor_Sylva: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Sylva = UIImage(named: path_Sylva) {
            imageView_Sylva.image = assetImage_Sylva
            imageView_Sylva.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Sylva = UIImage(contentsOfFile: path_Sylva) {
            imageView_Sylva.image = localImage_Sylva
            imageView_Sylva.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Sylva.hasPrefix("http://") || path_Sylva.hasPrefix("https://") {
            if let url_Sylva = URL(string: path_Sylva) {
                imageView_Sylva.kf.setImage(
                    with: url_Sylva,
                    placeholder: createPlaceholderImage_Sylva(color_Sylva: defaultColor_Sylva),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Sylva(color_Sylva: defaultColor_Sylva)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Sylva: 图标颜色
    func setDefaultAvatar_Sylva(color_Sylva: UIColor) {
        imageView_Sylva.image = UIImage(systemName: "person.circle.fill")
        imageView_Sylva.tintColor = color_Sylva
        imageView_Sylva.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Sylva(color_Sylva: UIColor) -> UIImage? {
        let size_Sylva = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Sylva, false, 0)
        
        // 绘制圆形背景
        color_Sylva.withAlphaComponent(0.2).setFill()
        let circlePath_Sylva = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Sylva))
        circlePath_Sylva.fill()
        
        // 绘制人物图标
        if let icon_Sylva = UIImage(systemName: "person.fill") {
            color_Sylva.setFill()
            icon_Sylva.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Sylva = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Sylva
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Sylva() {
        if let userId_Sylva = userId_Sylva {
            configure_Sylva(userId_Sylva: userId_Sylva)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Sylva: UserAvatarView_Sylva {

    // MARK: - 属性

    /// 点击回调
    var onTapped_Sylva: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Sylva()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Sylva() {
        super.setupUI_Sylva()
        
        // 启用用户交互
        isUserInteractionEnabled = true
        imageView_Sylva.isUserInteractionEnabled = true

        // 添加点击手势（绑定到整个头像组件，避免局部区域点击失效）
        let tapSelfGesture_Sylva = UITapGestureRecognizer(target: self, action: #selector(handleTap_Sylva))
        addGestureRecognizer(tapSelfGesture_Sylva)
        let tapGesture_Sylva = UITapGestureRecognizer(target: self, action: #selector(handleTap_Sylva))
        imageView_Sylva.addGestureRecognizer(tapGesture_Sylva)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Sylva() {
        let currentUser_Sylva = UserViewModel_Sylva.shared_Sylva.getCurrentUser_Sylva()
        isCurrentUser_Sylva = true
        userId_Sylva = currentUser_Sylva.userId_Sylva
        
        guard let headPath_Sylva = currentUser_Sylva.userHead_Sylva, !headPath_Sylva.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Sylva(color_Sylva: ColorConfig_Sylva.primaryGradientStart_Sylva)
            return
        }
        
        loadAvatarFromPath_Sylva(path_Sylva: headPath_Sylva, defaultColor_Sylva: ColorConfig_Sylva.primaryGradientStart_Sylva)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Sylva(color_Sylva: UIColor) -> UIImage? {
        let size_Sylva = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Sylva, false, 0)
        
        // 绘制渐变背景
        let context_Sylva = UIGraphicsGetCurrentContext()
        let colors_Sylva = [
            ColorConfig_Sylva.primaryGradientStart_Sylva.cgColor,
            ColorConfig_Sylva.primaryGradientEnd_Sylva.cgColor
        ]
        let colorSpace_Sylva = CGColorSpaceCreateDeviceRGB()
        let gradient_Sylva = CGGradient(colorsSpace: colorSpace_Sylva, colors: colors_Sylva as CFArray, locations: nil)
        
        context_Sylva?.drawLinearGradient(
            gradient_Sylva!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Sylva.width, y: size_Sylva.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Sylva = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Sylva.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Sylva = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Sylva
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Sylva() {
        // 缩放动画
        animatePressDown_Sylva {
            self.animatePressUp_Sylva()
        }
        
        // 触觉反馈
        let generator_Sylva = UIImpactFeedbackGenerator(style: .light)
        generator_Sylva.impactOccurred()
        
        // 触发回调
        onTapped_Sylva?()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Sylva() {
        loadCurrentUserAvatar_Sylva()
    }
}
