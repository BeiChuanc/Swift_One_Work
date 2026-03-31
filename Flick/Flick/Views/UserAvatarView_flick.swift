import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Flick: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Flick: [UIColor] = [
        ColorConfig_Flick.primaryGradientStart_Flick,
        ColorConfig_Flick.secondaryGradientStart_Flick,
        UIColor(hexstring_Flick: "#63B3ED"),
        UIColor(hexstring_Flick: "#F6AD55"),
        UIColor(hexstring_Flick: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Flick: UIImageView = {
        let imageView_Flick = UIImageView()
        imageView_Flick.contentMode = .scaleAspectFill
        imageView_Flick.clipsToBounds = true
        imageView_Flick.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
        return imageView_Flick
    }()
    
    // MARK: - 属性
    
    var userId_Flick: Int?
    var isCurrentUser_Flick: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Flick()
        observeUserState_Flick()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Flick.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Flick() {
        addSubview(imageView_Flick)
        
        imageView_Flick.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Flick() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Flick),
            name: UserViewModel_Flick.userStateDidChangeNotification_Flick,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Flick(userId_Flick: Int) {
        self.userId_Flick = userId_Flick
        
        // 判断是否是当前登录用户
        let currentUser_Flick = UserViewModel_Flick.shared_Flick.getCurrentUser_Flick()
        isCurrentUser_Flick = (currentUser_Flick.userId_Flick == userId_Flick)
        
        // 加载头像
        if isCurrentUser_Flick {
            loadCurrentUserAvatar_Flick(user_Flick: currentUser_Flick)
        } else {
            loadOtherUserAvatar_Flick(userId_Flick: userId_Flick)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Flick(user_Flick: LoginUserModel_Flick) {
        guard let headPath_Flick = user_Flick.userHead_Flick, !headPath_Flick.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Flick(color_Flick: ColorConfig_Flick.primaryGradientStart_Flick)
            return
        }
        
        loadAvatarFromPath_Flick(path_Flick: headPath_Flick, defaultColor_Flick: ColorConfig_Flick.primaryGradientStart_Flick)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Flick(userId_Flick: Int) {
        let userInfo_Flick = UserViewModel_Flick.shared_Flick.getUserById_Flick(userId_flick: userId_Flick)
        let color_Flick = Self.defaultAvatarColors_Flick[userId_Flick % Self.defaultAvatarColors_Flick.count]
        
        guard let headPath_Flick = userInfo_Flick.userHead_Flick, !headPath_Flick.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Flick(color_Flick: color_Flick)
            return
        }
        
        loadAvatarFromPath_Flick(path_Flick: headPath_Flick, defaultColor_Flick: color_Flick)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Flick(path_Flick: String, defaultColor_Flick: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Flick = UIImage(named: path_Flick) {
            imageView_Flick.image = assetImage_Flick
            imageView_Flick.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Flick = UIImage(contentsOfFile: path_Flick) {
            imageView_Flick.image = localImage_Flick
            imageView_Flick.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Flick.hasPrefix("http://") || path_Flick.hasPrefix("https://") {
            if let url_Flick = URL(string: path_Flick) {
                imageView_Flick.kf.setImage(
                    with: url_Flick,
                    placeholder: createPlaceholderImage_Flick(color_Flick: defaultColor_Flick),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Flick(color_Flick: defaultColor_Flick)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Flick: 图标颜色
    func setDefaultAvatar_Flick(color_Flick: UIColor) {
        imageView_Flick.image = UIImage(systemName: "person.circle.fill")
        imageView_Flick.tintColor = color_Flick
        imageView_Flick.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Flick(color_Flick: UIColor) -> UIImage? {
        let size_Flick = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Flick, false, 0)
        
        // 绘制圆形背景
        color_Flick.withAlphaComponent(0.2).setFill()
        let circlePath_Flick = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Flick))
        circlePath_Flick.fill()
        
        // 绘制人物图标
        if let icon_Flick = UIImage(systemName: "person.fill") {
            color_Flick.setFill()
            icon_Flick.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Flick = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Flick
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Flick() {
        if let userId_Flick = userId_Flick {
            configure_Flick(userId_Flick: userId_Flick)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Flick: UserAvatarView_Flick {
    
    // MARK: - UI组件
    
    /// 编辑按钮（可选）
    private let editButton_Flick: UIButton = {
        let button_Flick = UIButton(type: .custom)
        button_Flick.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        button_Flick.tintColor = ColorConfig_Flick.primaryGradientStart_Flick
        button_Flick.backgroundColor = .white
        button_Flick.isHidden = true
        return button_Flick
    }()
    
    // MARK: - 属性
    
    /// 是否显示编辑按钮
    var showEditButton_Flick: Bool = false {
        didSet {
            editButton_Flick.isHidden = !showEditButton_Flick
        }
    }
    
    /// 点击回调
    var onTapped_Flick: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Flick()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置编辑按钮圆形
        editButton_Flick.layer.cornerRadius = editButton_Flick.bounds.width / 2
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Flick() {
        super.setupUI_Flick()
        
        // 启用用户交互
        imageView_Flick.isUserInteractionEnabled = true
        
        // 添加编辑按钮
        addSubview(editButton_Flick)
        editButton_Flick.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().offset(2)
            make.width.height.equalTo(28)
        }
        
        // 添加点击手势
        let tapGesture_Flick = UITapGestureRecognizer(target: self, action: #selector(handleTap_Flick))
        imageView_Flick.addGestureRecognizer(tapGesture_Flick)
        
        editButton_Flick.addTarget(self, action: #selector(handleEditTap_Flick), for: .touchUpInside)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Flick() {
        let currentUser_Flick = UserViewModel_Flick.shared_Flick.getCurrentUser_Flick()
        isCurrentUser_Flick = true
        userId_Flick = currentUser_Flick.userId_Flick
        
        guard let headPath_Flick = currentUser_Flick.userHead_Flick, !headPath_Flick.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Flick(color_Flick: ColorConfig_Flick.primaryGradientStart_Flick)
            return
        }
        
        loadAvatarFromPath_Flick(path_Flick: headPath_Flick, defaultColor_Flick: ColorConfig_Flick.primaryGradientStart_Flick)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Flick(color_Flick: UIColor) -> UIImage? {
        let size_Flick = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Flick, false, 0)
        
        // 绘制渐变背景
        let context_Flick = UIGraphicsGetCurrentContext()
        let colors_Flick = [
            ColorConfig_Flick.primaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.primaryGradientEnd_Flick.cgColor
        ]
        let colorSpace_Flick = CGColorSpaceCreateDeviceRGB()
        let gradient_Flick = CGGradient(colorsSpace: colorSpace_Flick, colors: colors_Flick as CFArray, locations: nil)
        
        context_Flick?.drawLinearGradient(
            gradient_Flick!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Flick.width, y: size_Flick.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Flick = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Flick.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Flick = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Flick
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Flick() {
        // 缩放动画
        animatePressDown_Flick {
            self.animatePressUp_Flick()
        }
        
        // 触觉反馈
        let generator_Flick = UIImpactFeedbackGenerator(style: .light)
        generator_Flick.impactOccurred()
        
        // 触发回调
        onTapped_Flick?()
    }
    
    /// 处理编辑按钮点击事件
    @objc private func handleEditTap_Flick() {
        // 触发回调（可用于打开相册选择）
        onTapped_Flick?()
        
        // 触觉反馈
        let generator_Flick = UIImpactFeedbackGenerator(style: .medium)
        generator_Flick.impactOccurred()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Flick() {
        loadCurrentUserAvatar_Flick()
    }
}
