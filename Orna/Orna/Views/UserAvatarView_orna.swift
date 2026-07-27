import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Orna: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Orna: [UIColor] = [
        UIColor(hexstring_Orna: "#B794F6"),
        UIColor(hexstring_Orna: "#FBB6CE"),
        UIColor(hexstring_Orna: "#63B3ED"),
        UIColor(hexstring_Orna: "#F6AD55"),
        UIColor(hexstring_Orna: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Orna: UIImageView = {
        let imageView_Orna = UIImageView()
        imageView_Orna.contentMode = .scaleAspectFill
        imageView_Orna.clipsToBounds = true
        imageView_Orna.backgroundColor = UIColor(hexstring_Orna: "#F7FAFC")
        return imageView_Orna
    }()
    
    // MARK: - 属性
    
    var userId_Orna: Int?
    var isCurrentUser_Orna: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Orna()
        observeUserState_Orna()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Orna.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Orna() {
        addSubview(imageView_Orna)
        
        imageView_Orna.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Orna() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Orna),
            name: UserViewModel_Orna.userStateDidChangeNotification_Orna,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Orna(userId_Orna: Int) {
        self.userId_Orna = userId_Orna
        
        // 判断是否是当前登录用户
        let currentUser_Orna = UserViewModel_Orna.shared_Orna.getCurrentUser_Orna()
        isCurrentUser_Orna = (currentUser_Orna.userId_Orna == userId_Orna)
        
        // 加载头像
        if isCurrentUser_Orna {
            loadCurrentUserAvatar_Orna(user_Orna: currentUser_Orna)
        } else {
            loadOtherUserAvatar_Orna(userId_Orna: userId_Orna)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Orna(user_Orna: LoginUserModel_Orna) {
        guard let headPath_Orna = user_Orna.userHead_Orna, !headPath_Orna.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Orna(color_Orna: UIColor(hexstring_Orna: "#B794F6"))
            return
        }
        
        loadAvatarFromPath_Orna(path_Orna: headPath_Orna, defaultColor_Orna: UIColor(hexstring_Orna: "#B794F6"))
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Orna(userId_Orna: Int) {
        let userInfo_Orna = UserViewModel_Orna.shared_Orna.getUserById_Orna(userId_orna: userId_Orna)
        let color_Orna = Self.defaultAvatarColors_Orna[userId_Orna % Self.defaultAvatarColors_Orna.count]
        
        guard let headPath_Orna = userInfo_Orna.userHead_Orna, !headPath_Orna.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Orna(color_Orna: color_Orna)
            return
        }
        
        loadAvatarFromPath_Orna(path_Orna: headPath_Orna, defaultColor_Orna: color_Orna)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Orna(path_Orna: String, defaultColor_Orna: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Orna = UIImage(named: path_Orna) {
            imageView_Orna.image = assetImage_Orna
            imageView_Orna.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Orna = UIImage(contentsOfFile: path_Orna) {
            imageView_Orna.image = localImage_Orna
            imageView_Orna.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Orna.hasPrefix("http://") || path_Orna.hasPrefix("https://") {
            if let url_Orna = URL(string: path_Orna) {
                imageView_Orna.kf.setImage(
                    with: url_Orna,
                    placeholder: createPlaceholderImage_Orna(color_Orna: defaultColor_Orna),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Orna(color_Orna: defaultColor_Orna)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Orna: 图标颜色
    func setDefaultAvatar_Orna(color_Orna: UIColor) {
        imageView_Orna.image = UIImage(systemName: "person.circle.fill")
        imageView_Orna.tintColor = color_Orna
        imageView_Orna.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Orna(color_Orna: UIColor) -> UIImage? {
        let size_Orna = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Orna, false, 0)
        
        // 绘制圆形背景
        color_Orna.withAlphaComponent(0.2).setFill()
        let circlePath_Orna = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Orna))
        circlePath_Orna.fill()
        
        // 绘制人物图标
        if let icon_Orna = UIImage(systemName: "person.fill") {
            color_Orna.setFill()
            icon_Orna.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Orna = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Orna
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Orna() {
        if let userId_Orna = userId_Orna {
            configure_Orna(userId_Orna: userId_Orna)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Orna: UserAvatarView_Orna {

    // MARK: - 属性

    /// 点击回调
    var onTapped_Orna: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Orna()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Orna() {
        super.setupUI_Orna()
        
        // 启用用户交互
        isUserInteractionEnabled = true
        imageView_Orna.isUserInteractionEnabled = true

        // 添加点击手势（绑定到整个头像组件，避免局部区域点击失效）
        let tapSelfGesture_Orna = UITapGestureRecognizer(target: self, action: #selector(handleTap_Orna))
        addGestureRecognizer(tapSelfGesture_Orna)
        let tapGesture_Orna = UITapGestureRecognizer(target: self, action: #selector(handleTap_Orna))
        imageView_Orna.addGestureRecognizer(tapGesture_Orna)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Orna() {
        let currentUser_Orna = UserViewModel_Orna.shared_Orna.getCurrentUser_Orna()
        isCurrentUser_Orna = true
        userId_Orna = currentUser_Orna.userId_Orna
        
        guard let headPath_Orna = currentUser_Orna.userHead_Orna, !headPath_Orna.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Orna(color_Orna: UIColor(hexstring_Orna: "#B794F6"))
            return
        }
        
        loadAvatarFromPath_Orna(path_Orna: headPath_Orna, defaultColor_Orna: UIColor(hexstring_Orna: "#B794F6"))
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Orna(color_Orna: UIColor) -> UIImage? {
        let size_Orna = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Orna, false, 0)
        
        // 绘制渐变背景
        let context_Orna = UIGraphicsGetCurrentContext()
        let colors_Orna = [
            UIColor(hexstring_Orna: "#B794F6").cgColor,
            UIColor(hexstring_Orna: "#90CDF4").cgColor
        ]
        let colorSpace_Orna = CGColorSpaceCreateDeviceRGB()
        let gradient_Orna = CGGradient(colorsSpace: colorSpace_Orna, colors: colors_Orna as CFArray, locations: nil)
        
        context_Orna?.drawLinearGradient(
            gradient_Orna!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Orna.width, y: size_Orna.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Orna = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Orna.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Orna = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Orna
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Orna() {
        
        // 触觉反馈
        let generator_Orna = UIImpactFeedbackGenerator(style: .light)
        generator_Orna.impactOccurred()
        
        // 触发回调
        onTapped_Orna?()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Orna() {
        loadCurrentUserAvatar_Orna()
    }
}
