import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Doze: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Doze: [UIColor] = [
        ColorConfig_Doze.primaryGradientStart_Doze,
        ColorConfig_Doze.secondaryGradientStart_Doze,
        UIColor(hexstring_Doze: "#63B3ED"),
        UIColor(hexstring_Doze: "#F6AD55"),
        UIColor(hexstring_Doze: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Doze: UIImageView = {
        let imageView_Doze = UIImageView()
        imageView_Doze.contentMode = .scaleAspectFill
        imageView_Doze.clipsToBounds = true
        imageView_Doze.backgroundColor = ColorConfig_Doze.backgroundPrimary_Doze
        return imageView_Doze
    }()
    
    /// 在线状态指示器（登录用户专属）
    let onlineIndicator_Doze: UIView = {
        let view_Doze = UIView()
        view_Doze.backgroundColor = UIColor(hexstring_Doze: "#48BB78") // 绿色
        view_Doze.layer.borderWidth = 2
        view_Doze.layer.borderColor = UIColor.white.cgColor
        view_Doze.isHidden = true
        return view_Doze
    }()
    
    // MARK: - 属性
    
    var userId_Doze: Int?
    var isCurrentUser_Doze: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Doze()
        observeUserState_Doze()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Doze.layer.cornerRadius = bounds.width / 2
        onlineIndicator_Doze.layer.cornerRadius = onlineIndicator_Doze.bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Doze() {
        addSubview(imageView_Doze)
        addSubview(onlineIndicator_Doze)
        
        imageView_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        onlineIndicator_Doze.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.width.height.equalTo(12)
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Doze() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Doze),
            name: UserViewModel_Doze.userStateDidChangeNotification_Doze,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Doze(userId_Doze: Int) {
        self.userId_Doze = userId_Doze
        
        // 判断是否是当前登录用户
        let currentUser_Doze = UserViewModel_Doze.shared_Doze.getCurrentUser_Doze()
        isCurrentUser_Doze = (currentUser_Doze.userId_Doze == userId_Doze)
        
        // 显示/隐藏在线指示器
        onlineIndicator_Doze.isHidden = !isCurrentUser_Doze
        
        // 加载头像
        if isCurrentUser_Doze {
            loadCurrentUserAvatar_Doze(user_Doze: currentUser_Doze)
        } else {
            loadOtherUserAvatar_Doze(userId_Doze: userId_Doze)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Doze(user_Doze: LoginUserModel_Doze) {
        guard let headPath_Doze = user_Doze.userHead_Doze, !headPath_Doze.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Doze(color_Doze: ColorConfig_Doze.primaryGradientStart_Doze)
            return
        }
        
        loadAvatarFromPath_Doze(path_Doze: headPath_Doze, defaultColor_Doze: ColorConfig_Doze.primaryGradientStart_Doze)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Doze(userId_Doze: Int) {
        let userInfo_Doze = UserViewModel_Doze.shared_Doze.getUserById_Doze(userId_doze: userId_Doze)
        let color_Doze = Self.defaultAvatarColors_Doze[userId_Doze % Self.defaultAvatarColors_Doze.count]
        
        guard let headPath_Doze = userInfo_Doze.userHead_Doze, !headPath_Doze.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Doze(color_Doze: color_Doze)
            return
        }
        
        loadAvatarFromPath_Doze(path_Doze: headPath_Doze, defaultColor_Doze: color_Doze)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Doze(path_Doze: String, defaultColor_Doze: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Doze = UIImage(named: path_Doze) {
            imageView_Doze.image = assetImage_Doze
            imageView_Doze.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Doze = UIImage(contentsOfFile: path_Doze) {
            imageView_Doze.image = localImage_Doze
            imageView_Doze.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Doze.hasPrefix("http://") || path_Doze.hasPrefix("https://") {
            if let url_Doze = URL(string: path_Doze) {
                imageView_Doze.kf.setImage(
                    with: url_Doze,
                    placeholder: createPlaceholderImage_Doze(color_Doze: defaultColor_Doze),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Doze(color_Doze: defaultColor_Doze)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Doze: 图标颜色
    func setDefaultAvatar_Doze(color_Doze: UIColor) {
        imageView_Doze.image = UIImage(systemName: "person.circle.fill")
        imageView_Doze.tintColor = color_Doze
        imageView_Doze.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Doze(color_Doze: UIColor) -> UIImage? {
        let size_Doze = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Doze, false, 0)
        
        // 绘制圆形背景
        color_Doze.withAlphaComponent(0.2).setFill()
        let circlePath_Doze = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Doze))
        circlePath_Doze.fill()
        
        // 绘制人物图标
        if let icon_Doze = UIImage(systemName: "person.fill") {
            color_Doze.setFill()
            icon_Doze.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Doze = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Doze
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Doze() {
        if let userId_Doze = userId_Doze {
            configure_Doze(userId_Doze: userId_Doze)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Doze: UserAvatarView_Doze {
    
    // MARK: - UI组件
    
    /// 编辑按钮（可选）
    private let editButton_Doze: UIButton = {
        let button_Doze = UIButton(type: .custom)
        button_Doze.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        button_Doze.tintColor = ColorConfig_Doze.primaryGradientStart_Doze
        button_Doze.backgroundColor = .white
        button_Doze.isHidden = true
        return button_Doze
    }()
    
    // MARK: - 属性
    
    /// 是否显示编辑按钮
    var showEditButton_Doze: Bool = false {
        didSet {
            editButton_Doze.isHidden = !showEditButton_Doze
        }
    }
    
    /// 点击回调
    var onTapped_Doze: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Doze()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置编辑按钮圆形
        editButton_Doze.layer.cornerRadius = editButton_Doze.bounds.width / 2
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Doze() {
        super.setupUI_Doze()
        
        // 启用用户交互
        imageView_Doze.isUserInteractionEnabled = true
        
        // 添加编辑按钮
        addSubview(editButton_Doze)
        editButton_Doze.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().offset(2)
            make.width.height.equalTo(28)
        }
        
        // 修改在线指示器尺寸
        onlineIndicator_Doze.snp.remakeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.width.height.equalTo(14)
        }
        
        // 默认显示在线状态
        onlineIndicator_Doze.isHidden = false
        
        // 添加点击手势
        let tapGesture_Doze = UITapGestureRecognizer(target: self, action: #selector(handleTap_Doze))
        imageView_Doze.addGestureRecognizer(tapGesture_Doze)
        
        editButton_Doze.addTarget(self, action: #selector(handleEditTap_Doze), for: .touchUpInside)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Doze() {
        let currentUser_Doze = UserViewModel_Doze.shared_Doze.getCurrentUser_Doze()
        isCurrentUser_Doze = true
        userId_Doze = currentUser_Doze.userId_Doze
        
        guard let headPath_Doze = currentUser_Doze.userHead_Doze, !headPath_Doze.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Doze(color_Doze: ColorConfig_Doze.primaryGradientStart_Doze)
            return
        }
        
        loadAvatarFromPath_Doze(path_Doze: headPath_Doze, defaultColor_Doze: ColorConfig_Doze.primaryGradientStart_Doze)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Doze(color_Doze: UIColor) -> UIImage? {
        let size_Doze = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Doze, false, 0)
        
        // 绘制渐变背景
        let context_Doze = UIGraphicsGetCurrentContext()
        let colors_Doze = [
            ColorConfig_Doze.primaryGradientStart_Doze.cgColor,
            ColorConfig_Doze.primaryGradientEnd_Doze.cgColor
        ]
        let colorSpace_Doze = CGColorSpaceCreateDeviceRGB()
        let gradient_Doze = CGGradient(colorsSpace: colorSpace_Doze, colors: colors_Doze as CFArray, locations: nil)
        
        context_Doze?.drawLinearGradient(
            gradient_Doze!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Doze.width, y: size_Doze.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Doze = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Doze.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Doze = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Doze
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Doze() {
        // 缩放动画
        animatePressDown_Doze {
            self.animatePressUp_Doze()
        }
        
        // 触觉反馈
        let generator_Doze = UIImpactFeedbackGenerator(style: .light)
        generator_Doze.impactOccurred()
        
        // 触发回调
        onTapped_Doze?()
    }
    
    /// 处理编辑按钮点击事件
    @objc private func handleEditTap_Doze() {
        // 触发回调（可用于打开相册选择）
        onTapped_Doze?()
        
        // 触觉反馈
        let generator_Doze = UIImpactFeedbackGenerator(style: .medium)
        generator_Doze.impactOccurred()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Doze() {
        loadCurrentUserAvatar_Doze()
    }
}
