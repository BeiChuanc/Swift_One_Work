import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Pane: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Pane: [UIColor] = [
        ColorConfig_Pane.primaryGradientStart_Pane,
        ColorConfig_Pane.secondaryGradientStart_Pane,
        UIColor(hexstring_Pane: "#63B3ED"),
        UIColor(hexstring_Pane: "#F6AD55"),
        UIColor(hexstring_Pane: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Pane: UIImageView = {
        let imageView_Pane = UIImageView()
        imageView_Pane.contentMode = .scaleAspectFill
        imageView_Pane.clipsToBounds = true
        imageView_Pane.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane
        return imageView_Pane
    }()
    
    /// 在线状态指示器（登录用户专属）
    let onlineIndicator_Pane: UIView = {
        let view_Pane = UIView()
        view_Pane.backgroundColor = UIColor(hexstring_Pane: "#48BB78") // 绿色
        view_Pane.layer.borderWidth = 2
        view_Pane.layer.borderColor = UIColor.white.cgColor
        view_Pane.isHidden = true
        return view_Pane
    }()
    
    // MARK: - 属性
    
    var userId_Pane: Int?
    var isCurrentUser_Pane: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Pane()
        observeUserState_Pane()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Pane.layer.cornerRadius = bounds.width / 2
        onlineIndicator_Pane.layer.cornerRadius = onlineIndicator_Pane.bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Pane() {
        addSubview(imageView_Pane)
        addSubview(onlineIndicator_Pane)
        
        imageView_Pane.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        onlineIndicator_Pane.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.width.height.equalTo(12)
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Pane() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Pane),
            name: UserViewModel_Pane.userStateDidChangeNotification_Pane,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Pane(userId_Pane: Int) {
        self.userId_Pane = userId_Pane
        
        // 判断是否是当前登录用户
        let currentUser_Pane = UserViewModel_Pane.shared_Pane.getCurrentUser_Pane()
        isCurrentUser_Pane = (currentUser_Pane.userId_Pane == userId_Pane)
        
        // 显示/隐藏在线指示器
        onlineIndicator_Pane.isHidden = !isCurrentUser_Pane
        
        // 加载头像
        if isCurrentUser_Pane {
            loadCurrentUserAvatar_Pane(user_Pane: currentUser_Pane)
        } else {
            loadOtherUserAvatar_Pane(userId_Pane: userId_Pane)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Pane(user_Pane: LoginUserModel_Pane) {
        guard let headPath_Pane = user_Pane.userHead_Pane, !headPath_Pane.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Pane(color_Pane: ColorConfig_Pane.primaryGradientStart_Pane)
            return
        }
        
        loadAvatarFromPath_Pane(path_Pane: headPath_Pane, defaultColor_Pane: ColorConfig_Pane.primaryGradientStart_Pane)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Pane(userId_Pane: Int) {
        let userInfo_Pane = UserViewModel_Pane.shared_Pane.getUserById_Pane(userId_pane: userId_Pane)
        let color_Pane = Self.defaultAvatarColors_Pane[userId_Pane % Self.defaultAvatarColors_Pane.count]
        
        guard let headPath_Pane = userInfo_Pane.userHead_Pane, !headPath_Pane.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Pane(color_Pane: color_Pane)
            return
        }
        
        loadAvatarFromPath_Pane(path_Pane: headPath_Pane, defaultColor_Pane: color_Pane)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Pane(path_Pane: String, defaultColor_Pane: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Pane = UIImage(named: path_Pane) {
            imageView_Pane.image = assetImage_Pane
            imageView_Pane.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Pane = UIImage(contentsOfFile: path_Pane) {
            imageView_Pane.image = localImage_Pane
            imageView_Pane.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Pane.hasPrefix("http://") || path_Pane.hasPrefix("https://") {
            if let url_Pane = URL(string: path_Pane) {
                imageView_Pane.kf.setImage(
                    with: url_Pane,
                    placeholder: createPlaceholderImage_Pane(color_Pane: defaultColor_Pane),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Pane(color_Pane: defaultColor_Pane)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Pane: 图标颜色
    func setDefaultAvatar_Pane(color_Pane: UIColor) {
        imageView_Pane.image = UIImage(systemName: "person.circle.fill")
        imageView_Pane.tintColor = color_Pane
        imageView_Pane.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Pane(color_Pane: UIColor) -> UIImage? {
        let size_Pane = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Pane, false, 0)
        
        // 绘制圆形背景
        color_Pane.withAlphaComponent(0.2).setFill()
        let circlePath_Pane = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Pane))
        circlePath_Pane.fill()
        
        // 绘制人物图标
        if let icon_Pane = UIImage(systemName: "person.fill") {
            color_Pane.setFill()
            icon_Pane.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Pane = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Pane
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Pane() {
        if let userId_Pane = userId_Pane {
            configure_Pane(userId_Pane: userId_Pane)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Pane: UserAvatarView_Pane {
    
    // MARK: - UI组件
    
    /// 编辑按钮（可选）
    private let editButton_Pane: UIButton = {
        let button_Pane = UIButton(type: .custom)
        button_Pane.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        button_Pane.tintColor = ColorConfig_Pane.primaryGradientStart_Pane
        button_Pane.backgroundColor = .white
        button_Pane.isHidden = true
        return button_Pane
    }()
    
    // MARK: - 属性
    
    /// 是否显示编辑按钮
    var showEditButton_Pane: Bool = false {
        didSet {
            editButton_Pane.isHidden = !showEditButton_Pane
        }
    }
    
    /// 点击回调
    var onTapped_Pane: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Pane()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置编辑按钮圆形
        editButton_Pane.layer.cornerRadius = editButton_Pane.bounds.width / 2
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Pane() {
        super.setupUI_Pane()
        
        // 启用用户交互
        imageView_Pane.isUserInteractionEnabled = true
        
        // 添加编辑按钮
        addSubview(editButton_Pane)
        editButton_Pane.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().offset(2)
            make.width.height.equalTo(28)
        }
        
        // 修改在线指示器尺寸
        onlineIndicator_Pane.snp.remakeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.width.height.equalTo(14)
        }
        
        // 默认显示在线状态
        onlineIndicator_Pane.isHidden = false
        
        // 添加点击手势
        let tapGesture_Pane = UITapGestureRecognizer(target: self, action: #selector(handleTap_Pane))
        imageView_Pane.addGestureRecognizer(tapGesture_Pane)
        
        editButton_Pane.addTarget(self, action: #selector(handleEditTap_Pane), for: .touchUpInside)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Pane() {
        let currentUser_Pane = UserViewModel_Pane.shared_Pane.getCurrentUser_Pane()
        isCurrentUser_Pane = true
        userId_Pane = currentUser_Pane.userId_Pane
        
        guard let headPath_Pane = currentUser_Pane.userHead_Pane, !headPath_Pane.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Pane(color_Pane: ColorConfig_Pane.primaryGradientStart_Pane)
            return
        }
        
        loadAvatarFromPath_Pane(path_Pane: headPath_Pane, defaultColor_Pane: ColorConfig_Pane.primaryGradientStart_Pane)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Pane(color_Pane: UIColor) -> UIImage? {
        let size_Pane = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Pane, false, 0)
        
        // 绘制渐变背景
        let context_Pane = UIGraphicsGetCurrentContext()
        let colors_Pane = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        let colorSpace_Pane = CGColorSpaceCreateDeviceRGB()
        let gradient_Pane = CGGradient(colorsSpace: colorSpace_Pane, colors: colors_Pane as CFArray, locations: nil)
        
        context_Pane?.drawLinearGradient(
            gradient_Pane!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Pane.width, y: size_Pane.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Pane = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Pane.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Pane = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Pane
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Pane() {
        // 缩放动画
        animatePressDown_Pane {
            self.animatePressUp_Pane()
        }
        
        // 触觉反馈
        let generator_Pane = UIImpactFeedbackGenerator(style: .light)
        generator_Pane.impactOccurred()
        
        // 触发回调
        onTapped_Pane?()
    }
    
    /// 处理编辑按钮点击事件
    @objc private func handleEditTap_Pane() {
        // 触发回调（可用于打开相册选择）
        onTapped_Pane?()
        
        // 触觉反馈
        let generator_Pane = UIImpactFeedbackGenerator(style: .medium)
        generator_Pane.impactOccurred()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Pane() {
        loadCurrentUserAvatar_Pane()
    }
}
