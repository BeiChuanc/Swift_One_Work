import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Lens: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Lens: [UIColor] = [
        UIColor(hexstring_Lens: "#B794F6"),
        UIColor(hexstring_Lens: "#FBB6CE"),
        UIColor(hexstring_Lens: "#63B3ED"),
        UIColor(hexstring_Lens: "#F6AD55"),
        UIColor(hexstring_Lens: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Lens: UIImageView = {
        let imageView_Lens = UIImageView()
        imageView_Lens.contentMode = .scaleAspectFill
        imageView_Lens.clipsToBounds = true
        imageView_Lens.backgroundColor = UIColor(hexstring_Lens: "#F7FAFC")
        return imageView_Lens
    }()
    
    // MARK: - 属性
    
    var userId_Lens: Int?
    var isCurrentUser_Lens: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lens()
        observeUserState_Lens()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Lens.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Lens() {
        addSubview(imageView_Lens)
        
        imageView_Lens.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Lens() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Lens),
            name: UserViewModel_Lens.userStateDidChangeNotification_Lens,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Lens(userId_Lens: Int) {
        self.userId_Lens = userId_Lens
        
        // 判断是否是当前登录用户
        let currentUser_Lens = UserViewModel_Lens.shared_Lens.getCurrentUser_Lens()
        isCurrentUser_Lens = (currentUser_Lens.userId_Lens == userId_Lens)
        
        // 加载头像
        if isCurrentUser_Lens {
            loadCurrentUserAvatar_Lens(user_Lens: currentUser_Lens)
        } else {
            loadOtherUserAvatar_Lens(userId_Lens: userId_Lens)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Lens(user_Lens: LoginUserModel_Lens) {
        guard let headPath_Lens = user_Lens.userHead_Lens, !headPath_Lens.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Lens(color_Lens: UIColor(hexstring_Lens: "#B794F6"))
            return
        }
        
        loadAvatarFromPath_Lens(path_Lens: headPath_Lens, defaultColor_Lens: UIColor(hexstring_Lens: "#B794F6"))
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Lens(userId_Lens: Int) {
        let userInfo_Lens = UserViewModel_Lens.shared_Lens.getUserById_Lens(userId_lens: userId_Lens)
        let color_Lens = Self.defaultAvatarColors_Lens[userId_Lens % Self.defaultAvatarColors_Lens.count]
        
        guard let headPath_Lens = userInfo_Lens.userHead_Lens, !headPath_Lens.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Lens(color_Lens: color_Lens)
            return
        }
        
        loadAvatarFromPath_Lens(path_Lens: headPath_Lens, defaultColor_Lens: color_Lens)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Lens(path_Lens: String, defaultColor_Lens: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Lens = UIImage(named: path_Lens) {
            imageView_Lens.image = assetImage_Lens
            imageView_Lens.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Lens = UIImage(contentsOfFile: path_Lens) {
            imageView_Lens.image = localImage_Lens
            imageView_Lens.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Lens.hasPrefix("http://") || path_Lens.hasPrefix("https://") {
            if let url_Lens = URL(string: path_Lens) {
                imageView_Lens.kf.setImage(
                    with: url_Lens,
                    placeholder: createPlaceholderImage_Lens(color_Lens: defaultColor_Lens),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Lens(color_Lens: defaultColor_Lens)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Lens: 图标颜色
    func setDefaultAvatar_Lens(color_Lens: UIColor) {
        imageView_Lens.image = UIImage(systemName: "person.circle.fill")
        imageView_Lens.tintColor = color_Lens
        imageView_Lens.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Lens(color_Lens: UIColor) -> UIImage? {
        let size_Lens = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Lens, false, 0)
        
        // 绘制圆形背景
        color_Lens.withAlphaComponent(0.2).setFill()
        let circlePath_Lens = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Lens))
        circlePath_Lens.fill()
        
        // 绘制人物图标
        if let icon_Lens = UIImage(systemName: "person.fill") {
            color_Lens.setFill()
            icon_Lens.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Lens = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Lens
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Lens() {
        if let userId_Lens = userId_Lens {
            configure_Lens(userId_Lens: userId_Lens)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Lens: UserAvatarView_Lens {

    // MARK: - 属性

    /// 点击回调
    var onTapped_Lens: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Lens()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Lens() {
        super.setupUI_Lens()
        
        // 启用用户交互
        isUserInteractionEnabled = true
        imageView_Lens.isUserInteractionEnabled = true

        // 添加点击手势（绑定到整个头像组件，避免局部区域点击失效）
        let tapSelfGesture_Lens = UITapGestureRecognizer(target: self, action: #selector(handleTap_Lens))
        addGestureRecognizer(tapSelfGesture_Lens)
        let tapGesture_Lens = UITapGestureRecognizer(target: self, action: #selector(handleTap_Lens))
        imageView_Lens.addGestureRecognizer(tapGesture_Lens)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Lens() {
        let currentUser_Lens = UserViewModel_Lens.shared_Lens.getCurrentUser_Lens()
        isCurrentUser_Lens = true
        userId_Lens = currentUser_Lens.userId_Lens
        
        guard let headPath_Lens = currentUser_Lens.userHead_Lens, !headPath_Lens.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Lens(color_Lens: UIColor(hexstring_Lens: "#B794F6"))
            return
        }
        
        loadAvatarFromPath_Lens(path_Lens: headPath_Lens, defaultColor_Lens: UIColor(hexstring_Lens: "#B794F6"))
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Lens(color_Lens: UIColor) -> UIImage? {
        let size_Lens = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Lens, false, 0)
        
        // 绘制渐变背景
        let context_Lens = UIGraphicsGetCurrentContext()
        let colors_Lens = [
            UIColor(hexstring_Lens: "#B794F6").cgColor,
            UIColor(hexstring_Lens: "#90CDF4").cgColor
        ]
        let colorSpace_Lens = CGColorSpaceCreateDeviceRGB()
        let gradient_Lens = CGGradient(colorsSpace: colorSpace_Lens, colors: colors_Lens as CFArray, locations: nil)
        
        context_Lens?.drawLinearGradient(
            gradient_Lens!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Lens.width, y: size_Lens.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Lens = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Lens.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Lens = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Lens
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Lens() {
        
        // 触觉反馈
        let generator_Lens = UIImpactFeedbackGenerator(style: .light)
        generator_Lens.impactOccurred()
        
        // 触发回调
        onTapped_Lens?()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Lens() {
        loadCurrentUserAvatar_Lens()
    }
}
