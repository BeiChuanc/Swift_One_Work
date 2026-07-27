import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Maki: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Maki: [UIColor] = [
        UIColor(hexstring_Maki: "#B794F6"),
        UIColor(hexstring_Maki: "#FBB6CE"),
        UIColor(hexstring_Maki: "#63B3ED"),
        UIColor(hexstring_Maki: "#F6AD55"),
        UIColor(hexstring_Maki: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Maki: UIImageView = {
        let imageView_Maki = UIImageView()
        imageView_Maki.contentMode = .scaleAspectFill
        imageView_Maki.clipsToBounds = true
        imageView_Maki.backgroundColor = UIColor(hexstring_Maki: "#F7FAFC")
        return imageView_Maki
    }()
    
    // MARK: - 属性
    
    var userId_Maki: Int?
    var isCurrentUser_Maki: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Maki()
        observeUserState_Maki()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Maki.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Maki() {
        addSubview(imageView_Maki)
        
        imageView_Maki.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Maki() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Maki),
            name: UserViewModel_Maki.userStateDidChangeNotification_Maki,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Maki(userId_Maki: Int) {
        self.userId_Maki = userId_Maki
        
        // 判断是否是当前登录用户
        let currentUser_Maki = UserViewModel_Maki.shared_Maki.getCurrentUser_Maki()
        isCurrentUser_Maki = (currentUser_Maki.userId_Maki == userId_Maki)
        
        // 加载头像
        if isCurrentUser_Maki {
            loadCurrentUserAvatar_Maki(user_Maki: currentUser_Maki)
        } else {
            loadOtherUserAvatar_Maki(userId_Maki: userId_Maki)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Maki(user_Maki: LoginUserModel_Maki) {
        guard let headPath_Maki = user_Maki.userHead_Maki, !headPath_Maki.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Maki(color_Maki: UIColor(hexstring_Maki: "#B794F6"))
            return
        }
        
        loadAvatarFromPath_Maki(path_Maki: headPath_Maki, defaultColor_Maki: UIColor(hexstring_Maki: "#B794F6"))
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Maki(userId_Maki: Int) {
        let userInfo_Maki = UserViewModel_Maki.shared_Maki.getUserById_Maki(userId_maki: userId_Maki)
        let color_Maki = Self.defaultAvatarColors_Maki[userId_Maki % Self.defaultAvatarColors_Maki.count]
        
        guard let headPath_Maki = userInfo_Maki.userHead_Maki, !headPath_Maki.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Maki(color_Maki: color_Maki)
            return
        }
        
        loadAvatarFromPath_Maki(path_Maki: headPath_Maki, defaultColor_Maki: color_Maki)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Maki(path_Maki: String, defaultColor_Maki: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Maki = UIImage(named: path_Maki) {
            imageView_Maki.image = assetImage_Maki
            imageView_Maki.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Maki = UIImage(contentsOfFile: path_Maki) {
            imageView_Maki.image = localImage_Maki
            imageView_Maki.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Maki.hasPrefix("http://") || path_Maki.hasPrefix("https://") {
            if let url_Maki = URL(string: path_Maki) {
                imageView_Maki.kf.setImage(
                    with: url_Maki,
                    placeholder: createPlaceholderImage_Maki(color_Maki: defaultColor_Maki),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Maki(color_Maki: defaultColor_Maki)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Maki: 图标颜色
    func setDefaultAvatar_Maki(color_Maki: UIColor) {
        imageView_Maki.image = UIImage(systemName: "person.circle.fill")
        imageView_Maki.tintColor = color_Maki
        imageView_Maki.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Maki(color_Maki: UIColor) -> UIImage? {
        let size_Maki = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Maki, false, 0)
        
        // 绘制圆形背景
        color_Maki.withAlphaComponent(0.2).setFill()
        let circlePath_Maki = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Maki))
        circlePath_Maki.fill()
        
        // 绘制人物图标
        if let icon_Maki = UIImage(systemName: "person.fill") {
            color_Maki.setFill()
            icon_Maki.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Maki = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Maki
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Maki() {
        if let userId_Maki = userId_Maki {
            configure_Maki(userId_Maki: userId_Maki)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Maki: UserAvatarView_Maki {

    // MARK: - 属性

    /// 点击回调
    var onTapped_Maki: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Maki()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Maki() {
        super.setupUI_Maki()
        
        // 启用用户交互
        isUserInteractionEnabled = true
        imageView_Maki.isUserInteractionEnabled = true

        // 添加点击手势（绑定到整个头像组件，避免局部区域点击失效）
        let tapSelfGesture_Maki = UITapGestureRecognizer(target: self, action: #selector(handleTap_Maki))
        addGestureRecognizer(tapSelfGesture_Maki)
        let tapGesture_Maki = UITapGestureRecognizer(target: self, action: #selector(handleTap_Maki))
        imageView_Maki.addGestureRecognizer(tapGesture_Maki)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Maki() {
        let currentUser_Maki = UserViewModel_Maki.shared_Maki.getCurrentUser_Maki()
        isCurrentUser_Maki = true
        userId_Maki = currentUser_Maki.userId_Maki
        
        guard let headPath_Maki = currentUser_Maki.userHead_Maki, !headPath_Maki.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Maki(color_Maki: UIColor(hexstring_Maki: "#B794F6"))
            return
        }
        
        loadAvatarFromPath_Maki(path_Maki: headPath_Maki, defaultColor_Maki: UIColor(hexstring_Maki: "#B794F6"))
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Maki(color_Maki: UIColor) -> UIImage? {
        let size_Maki = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Maki, false, 0)
        
        // 绘制渐变背景
        let context_Maki = UIGraphicsGetCurrentContext()
        let colors_Maki = [
            UIColor(hexstring_Maki: "#B794F6").cgColor,
            UIColor(hexstring_Maki: "#90CDF4").cgColor
        ]
        let colorSpace_Maki = CGColorSpaceCreateDeviceRGB()
        let gradient_Maki = CGGradient(colorsSpace: colorSpace_Maki, colors: colors_Maki as CFArray, locations: nil)
        
        context_Maki?.drawLinearGradient(
            gradient_Maki!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Maki.width, y: size_Maki.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Maki = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Maki.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Maki = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Maki
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Maki() {
        
        // 触觉反馈
        let generator_Maki = UIImpactFeedbackGenerator(style: .light)
        generator_Maki.impactOccurred()
        
        // 触发回调
        onTapped_Maki?()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Maki() {
        loadCurrentUserAvatar_Maki()
    }
}
