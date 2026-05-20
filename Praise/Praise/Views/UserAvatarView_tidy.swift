import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Tidy: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Tidy: [UIColor] = [
        ColorConfig_Tidy.primaryGradientStart_Tidy,
        ColorConfig_Tidy.secondaryGradientStart_Tidy,
        ColorConfig_Tidy.primaryGradientEnd_Tidy,
        ColorConfig_Tidy.tidyGold_Tidy,
        ColorConfig_Tidy.categoryStorage_Tidy
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Tidy: UIImageView = {
        let imageView_Tidy = UIImageView()
        imageView_Tidy.contentMode = .scaleAspectFill
        imageView_Tidy.clipsToBounds = true
        imageView_Tidy.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        return imageView_Tidy
    }()
    
    // MARK: - 属性
    
    var userId_Tidy: Int?
    var isCurrentUser_Tidy: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Tidy()
        observeUserState_Tidy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Tidy.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Tidy() {
        addSubview(imageView_Tidy)
        
        imageView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Tidy() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Tidy),
            name: UserViewModel_Tidy.userStateDidChangeNotification_Tidy,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Tidy(userId_Tidy: Int) {
        self.userId_Tidy = userId_Tidy
        
        // 判断是否是当前登录用户
        let currentUser_Tidy = UserViewModel_Tidy.shared_Tidy.getCurrentUser_Tidy()
        isCurrentUser_Tidy = (currentUser_Tidy.userId_Tidy == userId_Tidy)
        
        // 加载头像
        if isCurrentUser_Tidy {
            loadCurrentUserAvatar_Tidy(user_Tidy: currentUser_Tidy)
        } else {
            loadOtherUserAvatar_Tidy(userId_Tidy: userId_Tidy)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Tidy(user_Tidy: LoginUserModel_Tidy) {
        guard let headPath_Tidy = user_Tidy.userHead_Tidy, !headPath_Tidy.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Tidy(color_Tidy: ColorConfig_Tidy.primaryGradientStart_Tidy)
            return
        }
        
        loadAvatarFromPath_Tidy(path_Tidy: headPath_Tidy, defaultColor_Tidy: ColorConfig_Tidy.primaryGradientStart_Tidy)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Tidy(userId_Tidy: Int) {
        let userInfo_Tidy = UserViewModel_Tidy.shared_Tidy.getUserById_Tidy(userId_tidy: userId_Tidy)
        let color_Tidy = Self.defaultAvatarColors_Tidy[userId_Tidy % Self.defaultAvatarColors_Tidy.count]
        
        guard let headPath_Tidy = userInfo_Tidy.userHead_Tidy, !headPath_Tidy.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Tidy(color_Tidy: color_Tidy)
            return
        }
        
        loadAvatarFromPath_Tidy(path_Tidy: headPath_Tidy, defaultColor_Tidy: color_Tidy)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Tidy(path_Tidy: String, defaultColor_Tidy: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Tidy = UIImage(named: path_Tidy) {
            imageView_Tidy.image = assetImage_Tidy
            imageView_Tidy.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Tidy = UIImage(contentsOfFile: path_Tidy) {
            imageView_Tidy.image = localImage_Tidy
            imageView_Tidy.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Tidy.hasPrefix("http://") || path_Tidy.hasPrefix("https://") {
            if let url_Tidy = URL(string: path_Tidy) {
                imageView_Tidy.kf.setImage(
                    with: url_Tidy,
                    placeholder: createPlaceholderImage_Tidy(color_Tidy: defaultColor_Tidy),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Tidy(color_Tidy: defaultColor_Tidy)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Tidy: 图标颜色
    func setDefaultAvatar_Tidy(color_Tidy: UIColor) {
        imageView_Tidy.image = UIImage(systemName: "person.circle.fill")
        imageView_Tidy.tintColor = color_Tidy
        imageView_Tidy.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Tidy(color_Tidy: UIColor) -> UIImage? {
        let size_Tidy = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Tidy, false, 0)
        
        // 绘制圆形背景
        color_Tidy.withAlphaComponent(0.2).setFill()
        let circlePath_Tidy = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Tidy))
        circlePath_Tidy.fill()
        
        // 绘制人物图标
        if let icon_Tidy = UIImage(systemName: "person.fill") {
            color_Tidy.setFill()
            icon_Tidy.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Tidy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Tidy
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Tidy() {
        if let userId_Tidy = userId_Tidy {
            configure_Tidy(userId_Tidy: userId_Tidy)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Tidy: UserAvatarView_Tidy {
    
    // MARK: - UI组件
    
    /// 编辑按钮（可选）
    private let editButton_Tidy: UIButton = {
        let button_Tidy = UIButton(type: .custom)
        button_Tidy.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        button_Tidy.tintColor = ColorConfig_Tidy.primaryGradientStart_Tidy
        button_Tidy.backgroundColor = .white
        button_Tidy.isHidden = true
        return button_Tidy
    }()
    
    // MARK: - 属性
    
    /// 是否显示编辑按钮
    var showEditButton_Tidy: Bool = false {
        didSet {
            editButton_Tidy.isHidden = !showEditButton_Tidy
        }
    }
    
    /// 点击回调
    var onTapped_Tidy: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Tidy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置编辑按钮圆形
        editButton_Tidy.layer.cornerRadius = editButton_Tidy.bounds.width / 2
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Tidy() {
        super.setupUI_Tidy()
        
        // 启用用户交互
        imageView_Tidy.isUserInteractionEnabled = true
        
        // 添加编辑按钮
        addSubview(editButton_Tidy)
        editButton_Tidy.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().offset(2)
            make.width.height.equalTo(28)
        }
        
        // 添加点击手势
        let tapGesture_Tidy = UITapGestureRecognizer(target: self, action: #selector(handleTap_Tidy))
        imageView_Tidy.addGestureRecognizer(tapGesture_Tidy)
        
        editButton_Tidy.addTarget(self, action: #selector(handleEditTap_Tidy), for: .touchUpInside)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Tidy() {
        let currentUser_Tidy = UserViewModel_Tidy.shared_Tidy.getCurrentUser_Tidy()
        isCurrentUser_Tidy = true
        userId_Tidy = currentUser_Tidy.userId_Tidy
        
        guard let headPath_Tidy = currentUser_Tidy.userHead_Tidy, !headPath_Tidy.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Tidy(color_Tidy: ColorConfig_Tidy.primaryGradientStart_Tidy)
            return
        }
        
        loadAvatarFromPath_Tidy(path_Tidy: headPath_Tidy, defaultColor_Tidy: ColorConfig_Tidy.primaryGradientStart_Tidy)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Tidy(color_Tidy: UIColor) -> UIImage? {
        let size_Tidy = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Tidy, false, 0)
        
        // 绘制渐变背景
        let context_Tidy = UIGraphicsGetCurrentContext()
        let colors_Tidy = [
            ColorConfig_Tidy.primaryGradientStart_Tidy.cgColor,
            ColorConfig_Tidy.primaryGradientEnd_Tidy.cgColor
        ]
        let colorSpace_Tidy = CGColorSpaceCreateDeviceRGB()
        let gradient_Tidy = CGGradient(colorsSpace: colorSpace_Tidy, colors: colors_Tidy as CFArray, locations: nil)
        
        context_Tidy?.drawLinearGradient(
            gradient_Tidy!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Tidy.width, y: size_Tidy.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Tidy = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Tidy.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Tidy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Tidy
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Tidy() {
        // 缩放动画
        animatePressDown_Tidy {
            self.animatePressUp_Tidy()
        }
        
        // 触觉反馈
        let generator_Tidy = UIImpactFeedbackGenerator(style: .light)
        generator_Tidy.impactOccurred()
        
        // 触发回调
        onTapped_Tidy?()
    }
    
    /// 处理编辑按钮点击事件
    @objc private func handleEditTap_Tidy() {
        // 触发回调（可用于打开相册选择）
        onTapped_Tidy?()
        
        // 触觉反馈
        let generator_Tidy = UIImpactFeedbackGenerator(style: .medium)
        generator_Tidy.impactOccurred()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Tidy() {
        loadCurrentUserAvatar_Tidy()
    }
}
