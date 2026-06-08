import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Vestir: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Vestir: [UIColor] = [
        ColorConfig_Vestir.primaryGradientStart_Vestir,
        ColorConfig_Vestir.secondaryGradientStart_Vestir,
        UIColor(hexstring_Vestir: "#63B3ED"),
        UIColor(hexstring_Vestir: "#F6AD55"),
        UIColor(hexstring_Vestir: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Vestir: UIImageView = {
        let imageView_Vestir = UIImageView()
        imageView_Vestir.contentMode = .scaleAspectFill
        imageView_Vestir.clipsToBounds = true
        imageView_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        return imageView_Vestir
    }()
    
    // MARK: - 属性
    
    var userId_Vestir: Int?
    var isCurrentUser_Vestir: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Vestir()
        observeUserState_Vestir()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Vestir.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Vestir() {
        addSubview(imageView_Vestir)
        
        imageView_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Vestir() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Vestir),
            name: UserViewModel_Vestir.userStateDidChangeNotification_Vestir,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Vestir(userId_Vestir: Int) {
        self.userId_Vestir = userId_Vestir
        
        // 判断是否是当前登录用户
        let currentUser_Vestir = UserViewModel_Vestir.shared_Vestir.getCurrentUser_Vestir()
        isCurrentUser_Vestir = (currentUser_Vestir.userId_Vestir == userId_Vestir)
        
        // 加载头像
        if isCurrentUser_Vestir {
            loadCurrentUserAvatar_Vestir(user_Vestir: currentUser_Vestir)
        } else {
            loadOtherUserAvatar_Vestir(userId_Vestir: userId_Vestir)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Vestir(user_Vestir: LoginUserModel_Vestir) {
        guard let headPath_Vestir = user_Vestir.userHead_Vestir, !headPath_Vestir.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Vestir(color_Vestir: ColorConfig_Vestir.primaryGradientStart_Vestir)
            return
        }
        
        loadAvatarFromPath_Vestir(path_Vestir: headPath_Vestir, defaultColor_Vestir: ColorConfig_Vestir.primaryGradientStart_Vestir)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Vestir(userId_Vestir: Int) {
        let userInfo_Vestir = UserViewModel_Vestir.shared_Vestir.getUserById_Vestir(userId_vestir: userId_Vestir)
        let color_Vestir = Self.defaultAvatarColors_Vestir[userId_Vestir % Self.defaultAvatarColors_Vestir.count]
        
        guard let headPath_Vestir = userInfo_Vestir.userHead_Vestir, !headPath_Vestir.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Vestir(color_Vestir: color_Vestir)
            return
        }
        
        loadAvatarFromPath_Vestir(path_Vestir: headPath_Vestir, defaultColor_Vestir: color_Vestir)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Vestir(path_Vestir: String, defaultColor_Vestir: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Vestir = UIImage(named: path_Vestir) {
            imageView_Vestir.image = assetImage_Vestir
            imageView_Vestir.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Vestir = UIImage(contentsOfFile: path_Vestir) {
            imageView_Vestir.image = localImage_Vestir
            imageView_Vestir.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Vestir.hasPrefix("http://") || path_Vestir.hasPrefix("https://") {
            if let url_Vestir = URL(string: path_Vestir) {
                imageView_Vestir.kf.setImage(
                    with: url_Vestir,
                    placeholder: createPlaceholderImage_Vestir(color_Vestir: defaultColor_Vestir),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Vestir(color_Vestir: defaultColor_Vestir)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Vestir: 图标颜色
    func setDefaultAvatar_Vestir(color_Vestir: UIColor) {
        imageView_Vestir.image = UIImage(systemName: "person.circle.fill")
        imageView_Vestir.tintColor = color_Vestir
        imageView_Vestir.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Vestir(color_Vestir: UIColor) -> UIImage? {
        let size_Vestir = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Vestir, false, 0)
        
        // 绘制圆形背景
        color_Vestir.withAlphaComponent(0.2).setFill()
        let circlePath_Vestir = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Vestir))
        circlePath_Vestir.fill()
        
        // 绘制人物图标
        if let icon_Vestir = UIImage(systemName: "person.fill") {
            color_Vestir.setFill()
            icon_Vestir.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Vestir = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Vestir
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Vestir() {
        if let userId_Vestir = userId_Vestir {
            configure_Vestir(userId_Vestir: userId_Vestir)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Vestir: UserAvatarView_Vestir {

    // MARK: - 属性

    /// 点击回调
    var onTapped_Vestir: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Vestir()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Vestir() {
        super.setupUI_Vestir()
        
        // 启用用户交互
        isUserInteractionEnabled = true
        imageView_Vestir.isUserInteractionEnabled = true

        // 添加点击手势（绑定到整个头像组件，避免局部区域点击失效）
        let tapSelfGesture_Vestir = UITapGestureRecognizer(target: self, action: #selector(handleTap_Vestir))
        addGestureRecognizer(tapSelfGesture_Vestir)
        let tapGesture_Vestir = UITapGestureRecognizer(target: self, action: #selector(handleTap_Vestir))
        imageView_Vestir.addGestureRecognizer(tapGesture_Vestir)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Vestir() {
        let currentUser_Vestir = UserViewModel_Vestir.shared_Vestir.getCurrentUser_Vestir()
        isCurrentUser_Vestir = true
        userId_Vestir = currentUser_Vestir.userId_Vestir
        
        guard let headPath_Vestir = currentUser_Vestir.userHead_Vestir, !headPath_Vestir.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Vestir(color_Vestir: ColorConfig_Vestir.primaryGradientStart_Vestir)
            return
        }
        
        loadAvatarFromPath_Vestir(path_Vestir: headPath_Vestir, defaultColor_Vestir: ColorConfig_Vestir.primaryGradientStart_Vestir)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Vestir(color_Vestir: UIColor) -> UIImage? {
        let size_Vestir = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Vestir, false, 0)
        
        // 绘制渐变背景
        let context_Vestir = UIGraphicsGetCurrentContext()
        let colors_Vestir = [
            ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor,
            ColorConfig_Vestir.primaryGradientEnd_Vestir.cgColor
        ]
        let colorSpace_Vestir = CGColorSpaceCreateDeviceRGB()
        let gradient_Vestir = CGGradient(colorsSpace: colorSpace_Vestir, colors: colors_Vestir as CFArray, locations: nil)
        
        context_Vestir?.drawLinearGradient(
            gradient_Vestir!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Vestir.width, y: size_Vestir.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Vestir = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Vestir.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Vestir = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Vestir
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Vestir() {
        // 缩放动画
        animatePressDown_Vestir {
            self.animatePressUp_Vestir()
        }
        
        // 触觉反馈
        let generator_Vestir = UIImpactFeedbackGenerator(style: .light)
        generator_Vestir.impactOccurred()
        
        // 触发回调
        onTapped_Vestir?()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Vestir() {
        loadCurrentUserAvatar_Vestir()
    }
}
