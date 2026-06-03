import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Bague: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Bague: [UIColor] = [
        ColorConfig_Bague.primaryGradientStart_Bague,
        ColorConfig_Bague.secondaryGradientStart_Bague,
        UIColor(hexstring_Bague: "#63B3ED"),
        UIColor(hexstring_Bague: "#F6AD55"),
        UIColor(hexstring_Bague: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Bague: UIImageView = {
        let imageView_Bague = UIImageView()
        imageView_Bague.contentMode = .scaleAspectFill
        imageView_Bague.clipsToBounds = true
        imageView_Bague.backgroundColor = ColorConfig_Bague.backgroundPrimary_Bague
        return imageView_Bague
    }()
    
    // MARK: - 属性
    
    var userId_Bague: Int?
    var isCurrentUser_Bague: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Bague()
        observeUserState_Bague()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Bague.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Bague() {
        addSubview(imageView_Bague)
        
        imageView_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Bague() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Bague),
            name: UserViewModel_Bague.userStateDidChangeNotification_Bague,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Bague(userId_Bague: Int) {
        self.userId_Bague = userId_Bague
        
        // 判断是否是当前登录用户
        let currentUser_Bague = UserViewModel_Bague.shared_Bague.getCurrentUser_Bague()
        isCurrentUser_Bague = (currentUser_Bague.userId_Bague == userId_Bague)
        
        // 加载头像
        if isCurrentUser_Bague {
            loadCurrentUserAvatar_Bague(user_Bague: currentUser_Bague)
        } else {
            loadOtherUserAvatar_Bague(userId_Bague: userId_Bague)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Bague(user_Bague: LoginUserModel_Bague) {
        guard let headPath_Bague = user_Bague.userHead_Bague, !headPath_Bague.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Bague(color_Bague: ColorConfig_Bague.primaryGradientStart_Bague)
            return
        }
        
        loadAvatarFromPath_Bague(path_Bague: headPath_Bague, defaultColor_Bague: ColorConfig_Bague.primaryGradientStart_Bague)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Bague(userId_Bague: Int) {
        let userInfo_Bague = UserViewModel_Bague.shared_Bague.getUserById_Bague(userId_bague: userId_Bague)
        let color_Bague = Self.defaultAvatarColors_Bague[userId_Bague % Self.defaultAvatarColors_Bague.count]
        
        guard let headPath_Bague = userInfo_Bague.userHead_Bague, !headPath_Bague.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Bague(color_Bague: color_Bague)
            return
        }
        
        loadAvatarFromPath_Bague(path_Bague: headPath_Bague, defaultColor_Bague: color_Bague)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Bague(path_Bague: String, defaultColor_Bague: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Bague = UIImage(named: path_Bague) {
            imageView_Bague.image = assetImage_Bague
            imageView_Bague.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Bague = UIImage(contentsOfFile: path_Bague) {
            imageView_Bague.image = localImage_Bague
            imageView_Bague.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Bague.hasPrefix("http://") || path_Bague.hasPrefix("https://") {
            if let url_Bague = URL(string: path_Bague) {
                imageView_Bague.kf.setImage(
                    with: url_Bague,
                    placeholder: createPlaceholderImage_Bague(color_Bague: defaultColor_Bague),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Bague(color_Bague: defaultColor_Bague)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Bague: 图标颜色
    func setDefaultAvatar_Bague(color_Bague: UIColor) {
        imageView_Bague.image = UIImage(systemName: "person.circle.fill")
        imageView_Bague.tintColor = color_Bague
        imageView_Bague.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Bague(color_Bague: UIColor) -> UIImage? {
        let size_Bague = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Bague, false, 0)
        
        // 绘制圆形背景
        color_Bague.withAlphaComponent(0.2).setFill()
        let circlePath_Bague = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Bague))
        circlePath_Bague.fill()
        
        // 绘制人物图标
        if let icon_Bague = UIImage(systemName: "person.fill") {
            color_Bague.setFill()
            icon_Bague.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Bague = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Bague
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Bague() {
        if let userId_Bague = userId_Bague {
            configure_Bague(userId_Bague: userId_Bague)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Bague: UserAvatarView_Bague {

    // MARK: - 属性

    /// 点击回调
    var onTapped_Bague: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Bague()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Bague() {
        super.setupUI_Bague()
        
        // 启用用户交互
        isUserInteractionEnabled = true
        imageView_Bague.isUserInteractionEnabled = true

        // 添加点击手势（绑定到整个头像组件，避免局部区域点击失效）
        let tapSelfGesture_Bague = UITapGestureRecognizer(target: self, action: #selector(handleTap_Bague))
        addGestureRecognizer(tapSelfGesture_Bague)
        let tapGesture_Bague = UITapGestureRecognizer(target: self, action: #selector(handleTap_Bague))
        imageView_Bague.addGestureRecognizer(tapGesture_Bague)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Bague() {
        let currentUser_Bague = UserViewModel_Bague.shared_Bague.getCurrentUser_Bague()
        isCurrentUser_Bague = true
        userId_Bague = currentUser_Bague.userId_Bague
        
        guard let headPath_Bague = currentUser_Bague.userHead_Bague, !headPath_Bague.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Bague(color_Bague: ColorConfig_Bague.primaryGradientStart_Bague)
            return
        }
        
        loadAvatarFromPath_Bague(path_Bague: headPath_Bague, defaultColor_Bague: ColorConfig_Bague.primaryGradientStart_Bague)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Bague(color_Bague: UIColor) -> UIImage? {
        let size_Bague = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Bague, false, 0)
        
        // 绘制渐变背景
        let context_Bague = UIGraphicsGetCurrentContext()
        let colors_Bague = [
            ColorConfig_Bague.primaryGradientStart_Bague.cgColor,
            ColorConfig_Bague.primaryGradientEnd_Bague.cgColor
        ]
        let colorSpace_Bague = CGColorSpaceCreateDeviceRGB()
        let gradient_Bague = CGGradient(colorsSpace: colorSpace_Bague, colors: colors_Bague as CFArray, locations: nil)
        
        context_Bague?.drawLinearGradient(
            gradient_Bague!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Bague.width, y: size_Bague.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Bague = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Bague.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Bague = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Bague
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Bague() {
        // 缩放动画
        animatePressDown_Bague {
            self.animatePressUp_Bague()
        }
        
        // 触觉反馈
        let generator_Bague = UIImpactFeedbackGenerator(style: .light)
        generator_Bague.impactOccurred()
        
        // 触发回调
        onTapped_Bague?()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Bague() {
        loadCurrentUserAvatar_Bague()
    }
}
