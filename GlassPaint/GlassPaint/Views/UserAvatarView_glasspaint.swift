import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Glasspaint: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Glasspaint: [UIColor] = [
        ColorConfig_Glasspaint.primaryGradientStart_Glasspaint,
        ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint,
        UIColor(hexstring_Glasspaint: "#63B3ED"),
        UIColor(hexstring_Glasspaint: "#F6AD55"),
        UIColor(hexstring_Glasspaint: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Glasspaint: UIImageView = {
        let imageView_Glasspaint = UIImageView()
        imageView_Glasspaint.contentMode = .scaleAspectFill
        imageView_Glasspaint.clipsToBounds = true
        imageView_Glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        return imageView_Glasspaint
    }()
    
    // MARK: - 属性
    
    var userId_Glasspaint: Int?
    var isCurrentUser_Glasspaint: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Glasspaint()
        observeUserState_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        layer.cornerRadius = bounds.width / 2
        imageView_Glasspaint.layer.cornerRadius = bounds.width / 2
        imageView_Glasspaint.layer.masksToBounds = true
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Glasspaint() {
        addSubview(imageView_Glasspaint)
        
        imageView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Glasspaint() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Glasspaint),
            name: UserViewModel_Glasspaint.userStateDidChangeNotification_Glasspaint,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Glasspaint(userId_Glasspaint: Int) {
        self.userId_Glasspaint = userId_Glasspaint
        
        // 判断是否是当前登录用户
        let currentUser_Glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getCurrentUser_Glasspaint()
        isCurrentUser_Glasspaint = (currentUser_Glasspaint.userId_Glasspaint == userId_Glasspaint)
        
        // 加载头像
        if isCurrentUser_Glasspaint {
            loadCurrentUserAvatar_Glasspaint(user_Glasspaint: currentUser_Glasspaint)
        } else {
            loadOtherUserAvatar_Glasspaint(userId_Glasspaint: userId_Glasspaint)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Glasspaint(user_Glasspaint: LoginUserModel_Glasspaint) {
        guard let headPath_Glasspaint = user_Glasspaint.userHead_Glasspaint, !headPath_Glasspaint.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Glasspaint(color_Glasspaint: ColorConfig_Glasspaint.primaryGradientStart_Glasspaint)
            return
        }
        
        loadAvatarFromPath_Glasspaint(path_Glasspaint: headPath_Glasspaint, defaultColor_Glasspaint: ColorConfig_Glasspaint.primaryGradientStart_Glasspaint)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Glasspaint(userId_Glasspaint: Int) {
        let userInfo_Glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getUserById_Glasspaint(userId_glasspaint: userId_Glasspaint)
        let color_Glasspaint = Self.defaultAvatarColors_Glasspaint[userId_Glasspaint % Self.defaultAvatarColors_Glasspaint.count]
        
        guard let headPath_Glasspaint = userInfo_Glasspaint.userHead_Glasspaint, !headPath_Glasspaint.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Glasspaint(color_Glasspaint: color_Glasspaint)
            return
        }
        
        loadAvatarFromPath_Glasspaint(path_Glasspaint: headPath_Glasspaint, defaultColor_Glasspaint: color_Glasspaint)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Glasspaint(path_Glasspaint: String, defaultColor_Glasspaint: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Glasspaint = UIImage(named: path_Glasspaint) {
            imageView_Glasspaint.image = assetImage_Glasspaint
            imageView_Glasspaint.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Glasspaint = UIImage(contentsOfFile: path_Glasspaint) {
            imageView_Glasspaint.image = localImage_Glasspaint
            imageView_Glasspaint.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Glasspaint.hasPrefix("http://") || path_Glasspaint.hasPrefix("https://") {
            if let url_Glasspaint = URL(string: path_Glasspaint) {
                imageView_Glasspaint.kf.setImage(
                    with: url_Glasspaint,
                    placeholder: createPlaceholderImage_Glasspaint(color_Glasspaint: defaultColor_Glasspaint),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Glasspaint(color_Glasspaint: defaultColor_Glasspaint)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Glasspaint: 图标颜色
    func setDefaultAvatar_Glasspaint(color_Glasspaint: UIColor) {
        imageView_Glasspaint.image = UIImage(systemName: "person.circle.fill")
        imageView_Glasspaint.tintColor = color_Glasspaint
        imageView_Glasspaint.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Glasspaint(color_Glasspaint: UIColor) -> UIImage? {
        let size_Glasspaint = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Glasspaint, false, 0)
        
        // 绘制圆形背景
        color_Glasspaint.withAlphaComponent(0.2).setFill()
        let circlePath_Glasspaint = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Glasspaint))
        circlePath_Glasspaint.fill()
        
        // 绘制人物图标
        if let icon_Glasspaint = UIImage(systemName: "person.fill") {
            color_Glasspaint.setFill()
            icon_Glasspaint.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Glasspaint = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Glasspaint
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Glasspaint() {
        if let userId_Glasspaint = userId_Glasspaint {
            configure_Glasspaint(userId_Glasspaint: userId_Glasspaint)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Glasspaint: UserAvatarView_Glasspaint {
    
    // MARK: - UI组件
    
    /// 编辑按钮（可选）
    private let editButton_Glasspaint: UIButton = {
        let button_Glasspaint = UIButton(type: .custom)
        button_Glasspaint.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        button_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        button_Glasspaint.backgroundColor = .white
        button_Glasspaint.isHidden = true
        return button_Glasspaint
    }()
    
    // MARK: - 属性
    
    /// 是否显示编辑按钮
    var showEditButton_Glasspaint: Bool = false {
        didSet {
            editButton_Glasspaint.isHidden = !showEditButton_Glasspaint
        }
    }
    
    /// 点击回调
    var onTapped_Glasspaint: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置编辑按钮圆形
        editButton_Glasspaint.layer.cornerRadius = editButton_Glasspaint.bounds.width / 2
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Glasspaint() {
        super.setupUI_Glasspaint()
        
        // 启用用户交互
        imageView_Glasspaint.isUserInteractionEnabled = true
        
        // 添加编辑按钮
        addSubview(editButton_Glasspaint)
        editButton_Glasspaint.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().offset(2)
            make.width.height.equalTo(28)
        }
        
        // 添加点击手势
        let tapGesture_Glasspaint = UITapGestureRecognizer(target: self, action: #selector(handleTap_Glasspaint))
        imageView_Glasspaint.addGestureRecognizer(tapGesture_Glasspaint)
        
        editButton_Glasspaint.addTarget(self, action: #selector(handleEditTap_Glasspaint), for: .touchUpInside)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Glasspaint() {
        let currentUser_Glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getCurrentUser_Glasspaint()
        isCurrentUser_Glasspaint = true
        userId_Glasspaint = currentUser_Glasspaint.userId_Glasspaint
        
        guard let headPath_Glasspaint = currentUser_Glasspaint.userHead_Glasspaint, !headPath_Glasspaint.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Glasspaint(color_Glasspaint: ColorConfig_Glasspaint.primaryGradientStart_Glasspaint)
            return
        }
        
        loadAvatarFromPath_Glasspaint(path_Glasspaint: headPath_Glasspaint, defaultColor_Glasspaint: ColorConfig_Glasspaint.primaryGradientStart_Glasspaint)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Glasspaint(color_Glasspaint: UIColor) -> UIImage? {
        let size_Glasspaint = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Glasspaint, false, 0)
        
        // 绘制渐变背景
        let context_Glasspaint = UIGraphicsGetCurrentContext()
        let colors_Glasspaint = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor,
            ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint.cgColor
        ]
        let colorSpace_Glasspaint = CGColorSpaceCreateDeviceRGB()
        let gradient_Glasspaint = CGGradient(colorsSpace: colorSpace_Glasspaint, colors: colors_Glasspaint as CFArray, locations: nil)
        
        context_Glasspaint?.drawLinearGradient(
            gradient_Glasspaint!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Glasspaint.width, y: size_Glasspaint.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Glasspaint = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Glasspaint.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Glasspaint = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Glasspaint
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Glasspaint() {
        // 缩放动画
        animatePressDown_Glasspaint {
            self.animatePressUp_Glasspaint()
        }
        
        // 触觉反馈
        let generator_Glasspaint = UIImpactFeedbackGenerator(style: .light)
        generator_Glasspaint.impactOccurred()
        
        // 触发回调
        onTapped_Glasspaint?()
    }
    
    /// 处理编辑按钮点击事件
    @objc private func handleEditTap_Glasspaint() {
        // 触发回调（可用于打开相册选择）
        onTapped_Glasspaint?()
        
        // 触觉反馈
        let generator_Glasspaint = UIImpactFeedbackGenerator(style: .medium)
        generator_Glasspaint.impactOccurred()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Glasspaint() {
        loadCurrentUserAvatar_Glasspaint()
    }
}
