import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Moode: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Moode: [UIColor] = [
        ColorConfig_Moode.primaryGradientStart_Moode,
        ColorConfig_Moode.secondaryGradientStart_Moode,
        UIColor(hexstring_Moode: "#63B3ED"),
        UIColor(hexstring_Moode: "#F6AD55"),
        UIColor(hexstring_Moode: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Moode: UIImageView = {
        let imageView_Moode = UIImageView()
        imageView_Moode.contentMode = .scaleAspectFill
        imageView_Moode.clipsToBounds = true
        imageView_Moode.backgroundColor = ColorConfig_Moode.backgroundPrimary_Moode
        return imageView_Moode
    }()
    
    /// 在线状态指示器（登录用户专属）
    let onlineIndicator_Moode: UIView = {
        let view_Moode = UIView()
        view_Moode.backgroundColor = UIColor(hexstring_Moode: "#48BB78") // 绿色
        view_Moode.layer.borderWidth = 2
        view_Moode.layer.borderColor = UIColor.white.cgColor
        view_Moode.isHidden = true
        return view_Moode
    }()
    
    // MARK: - 属性
    
    var userId_Moode: Int?
    var isCurrentUser_Moode: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Moode()
        observeUserState_Moode()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Moode.layer.cornerRadius = bounds.width / 2
        onlineIndicator_Moode.layer.cornerRadius = onlineIndicator_Moode.bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Moode() {
        addSubview(imageView_Moode)
        addSubview(onlineIndicator_Moode)
        
        imageView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        onlineIndicator_Moode.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.width.height.equalTo(12)
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Moode() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Moode),
            name: UserViewModel_Moode.userStateDidChangeNotification_Moode,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Moode(userId_Moode: Int) {
        self.userId_Moode = userId_Moode
        
        // 判断是否是当前登录用户
        let currentUser_Moode = UserViewModel_Moode.shared_Moode.getCurrentUser_Moode()
        isCurrentUser_Moode = (currentUser_Moode.userId_Moode == userId_Moode)
        
        // 显示/隐藏在线指示器
        onlineIndicator_Moode.isHidden = !isCurrentUser_Moode
        
        // 加载头像
        if isCurrentUser_Moode {
            loadCurrentUserAvatar_Moode(user_Moode: currentUser_Moode)
        } else {
            loadOtherUserAvatar_Moode(userId_Moode: userId_Moode)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Moode(user_Moode: LoginUserModel_Moode) {
        guard let headPath_Moode = user_Moode.userHead_Moode, !headPath_Moode.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Moode(color_Moode: ColorConfig_Moode.primaryGradientStart_Moode)
            return
        }
        
        loadAvatarFromPath_Moode(path_Moode: headPath_Moode, defaultColor_Moode: ColorConfig_Moode.primaryGradientStart_Moode)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Moode(userId_Moode: Int) {
        let userInfo_Moode = UserViewModel_Moode.shared_Moode.getUserById_Moode(userId_moode: userId_Moode)
        let color_Moode = Self.defaultAvatarColors_Moode[userId_Moode % Self.defaultAvatarColors_Moode.count]
        
        guard let headPath_Moode = userInfo_Moode.userHead_Moode, !headPath_Moode.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Moode(color_Moode: color_Moode)
            return
        }
        
        loadAvatarFromPath_Moode(path_Moode: headPath_Moode, defaultColor_Moode: color_Moode)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Moode(path_Moode: String, defaultColor_Moode: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Moode = UIImage(named: path_Moode) {
            imageView_Moode.image = assetImage_Moode
            imageView_Moode.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Moode = UIImage(contentsOfFile: path_Moode) {
            imageView_Moode.image = localImage_Moode
            imageView_Moode.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Moode.hasPrefix("http://") || path_Moode.hasPrefix("https://") {
            if let url_Moode = URL(string: path_Moode) {
                imageView_Moode.kf.setImage(
                    with: url_Moode,
                    placeholder: createPlaceholderImage_Moode(color_Moode: defaultColor_Moode),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Moode(color_Moode: defaultColor_Moode)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Moode: 图标颜色
    func setDefaultAvatar_Moode(color_Moode: UIColor) {
        imageView_Moode.image = UIImage(systemName: "person.circle.fill")
        imageView_Moode.tintColor = color_Moode
        imageView_Moode.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Moode(color_Moode: UIColor) -> UIImage? {
        let size_Moode = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Moode, false, 0)
        
        // 绘制圆形背景
        color_Moode.withAlphaComponent(0.2).setFill()
        let circlePath_Moode = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Moode))
        circlePath_Moode.fill()
        
        // 绘制人物图标
        if let icon_Moode = UIImage(systemName: "person.fill") {
            color_Moode.setFill()
            icon_Moode.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Moode = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Moode
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Moode() {
        if let userId_Moode = userId_Moode {
            configure_Moode(userId_Moode: userId_Moode)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Moode: UserAvatarView_Moode {
    
    // MARK: - UI组件
    
    /// 编辑按钮（可选）
    private let editButton_Moode: UIButton = {
        let button_Moode = UIButton(type: .custom)
        button_Moode.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        button_Moode.tintColor = ColorConfig_Moode.primaryGradientStart_Moode
        button_Moode.backgroundColor = .white
        button_Moode.isHidden = true
        return button_Moode
    }()
    
    // MARK: - 属性
    
    /// 是否显示编辑按钮
    var showEditButton_Moode: Bool = false {
        didSet {
            editButton_Moode.isHidden = !showEditButton_Moode
        }
    }
    
    /// 点击回调
    var onTapped_Moode: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Moode()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置编辑按钮圆形
        editButton_Moode.layer.cornerRadius = editButton_Moode.bounds.width / 2
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Moode() {
        super.setupUI_Moode()
        
        // 启用用户交互
        imageView_Moode.isUserInteractionEnabled = true
        
        // 添加编辑按钮
        addSubview(editButton_Moode)
        editButton_Moode.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().offset(2)
            make.width.height.equalTo(28)
        }
        
        // 修改在线指示器尺寸
        onlineIndicator_Moode.snp.remakeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.width.height.equalTo(14)
        }
        
        // 默认显示在线状态
        onlineIndicator_Moode.isHidden = false
        
        // 添加点击手势
        let tapGesture_Moode = UITapGestureRecognizer(target: self, action: #selector(handleTap_Moode))
        imageView_Moode.addGestureRecognizer(tapGesture_Moode)
        
        editButton_Moode.addTarget(self, action: #selector(handleEditTap_Moode), for: .touchUpInside)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Moode() {
        let currentUser_Moode = UserViewModel_Moode.shared_Moode.getCurrentUser_Moode()
        isCurrentUser_Moode = true
        userId_Moode = currentUser_Moode.userId_Moode
        
        guard let headPath_Moode = currentUser_Moode.userHead_Moode, !headPath_Moode.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Moode(color_Moode: ColorConfig_Moode.primaryGradientStart_Moode)
            return
        }
        
        loadAvatarFromPath_Moode(path_Moode: headPath_Moode, defaultColor_Moode: ColorConfig_Moode.primaryGradientStart_Moode)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Moode(color_Moode: UIColor) -> UIImage? {
        let size_Moode = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Moode, false, 0)
        
        // 绘制渐变背景
        let context_Moode = UIGraphicsGetCurrentContext()
        let colors_Moode = [
            ColorConfig_Moode.primaryGradientStart_Moode.cgColor,
            ColorConfig_Moode.primaryGradientEnd_Moode.cgColor
        ]
        let colorSpace_Moode = CGColorSpaceCreateDeviceRGB()
        let gradient_Moode = CGGradient(colorsSpace: colorSpace_Moode, colors: colors_Moode as CFArray, locations: nil)
        
        context_Moode?.drawLinearGradient(
            gradient_Moode!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Moode.width, y: size_Moode.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Moode = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Moode.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Moode = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Moode
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Moode() {
        // 缩放动画
        animatePressDown_Moode {
            self.animatePressUp_Moode()
        }
        
        // 触觉反馈
        let generator_Moode = UIImpactFeedbackGenerator(style: .light)
        generator_Moode.impactOccurred()
        
        // 触发回调
        onTapped_Moode?()
    }
    
    /// 处理编辑按钮点击事件
    @objc private func handleEditTap_Moode() {
        // 触发回调（可用于打开相册选择）
        onTapped_Moode?()
        
        // 触觉反馈
        let generator_Moode = UIImpactFeedbackGenerator(style: .medium)
        generator_Moode.impactOccurred()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Moode() {
        loadCurrentUserAvatar_Moode()
    }
}
