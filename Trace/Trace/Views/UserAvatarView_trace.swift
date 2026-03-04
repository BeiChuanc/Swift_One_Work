import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Trace: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Trace: [UIColor] = [
        ColorConfig_Trace.primaryGradientStart_Trace,
        ColorConfig_Trace.secondaryGradientStart_Trace,
        UIColor(hexstring_Trace: "#63B3ED"),
        UIColor(hexstring_Trace: "#F6AD55"),
        UIColor(hexstring_Trace: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Trace: UIImageView = {
        let imageView_Trace = UIImageView()
        imageView_Trace.contentMode = .scaleAspectFill
        imageView_Trace.clipsToBounds = true
        imageView_Trace.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        return imageView_Trace
    }()
    
    /// 在线状态指示器（登录用户专属）
    let onlineIndicator_Trace: UIView = {
        let view_Trace = UIView()
        view_Trace.backgroundColor = UIColor(hexstring_Trace: "#48BB78") // 绿色
        view_Trace.layer.borderWidth = 2
        view_Trace.layer.borderColor = UIColor.white.cgColor
        view_Trace.isHidden = true
        return view_Trace
    }()
    
    // MARK: - 属性
    
    var userId_Trace: Int?
    var isCurrentUser_Trace: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Trace()
        observeUserState_Trace()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Trace.layer.cornerRadius = bounds.width / 2
        onlineIndicator_Trace.layer.cornerRadius = onlineIndicator_Trace.bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Trace() {
        addSubview(imageView_Trace)
        addSubview(onlineIndicator_Trace)
        
        imageView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        onlineIndicator_Trace.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.width.height.equalTo(12)
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Trace() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Trace),
            name: UserViewModel_Trace.userStateDidChangeNotification_Trace,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Trace(userId_Trace: Int) {
        self.userId_Trace = userId_Trace
        
        // 判断是否是当前登录用户
        let currentUser_Trace = UserViewModel_Trace.shared_Trace.getCurrentUser_Trace()
        isCurrentUser_Trace = (currentUser_Trace.userId_Trace == userId_Trace)
        
        // 显示/隐藏在线指示器
        onlineIndicator_Trace.isHidden = !isCurrentUser_Trace
        
        // 加载头像
        if isCurrentUser_Trace {
            loadCurrentUserAvatar_Trace(user_Trace: currentUser_Trace)
        } else {
            loadOtherUserAvatar_Trace(userId_Trace: userId_Trace)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Trace(user_Trace: LoginUserModel_Trace) {
        guard let headPath_Trace = user_Trace.userHead_Trace, !headPath_Trace.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Trace(color_Trace: ColorConfig_Trace.primaryGradientStart_Trace)
            return
        }
        
        loadAvatarFromPath_Trace(path_Trace: headPath_Trace, defaultColor_Trace: ColorConfig_Trace.primaryGradientStart_Trace)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Trace(userId_Trace: Int) {
        let userInfo_Trace = UserViewModel_Trace.shared_Trace.getUserById_Trace(userId_trace: userId_Trace)
        let color_Trace = Self.defaultAvatarColors_Trace[userId_Trace % Self.defaultAvatarColors_Trace.count]
        
        guard let headPath_Trace = userInfo_Trace.userHead_Trace, !headPath_Trace.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Trace(color_Trace: color_Trace)
            return
        }
        
        loadAvatarFromPath_Trace(path_Trace: headPath_Trace, defaultColor_Trace: color_Trace)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Trace(path_Trace: String, defaultColor_Trace: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Trace = UIImage(named: path_Trace) {
            imageView_Trace.image = assetImage_Trace
            imageView_Trace.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Trace = UIImage(contentsOfFile: path_Trace) {
            imageView_Trace.image = localImage_Trace
            imageView_Trace.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Trace.hasPrefix("http://") || path_Trace.hasPrefix("https://") {
            if let url_Trace = URL(string: path_Trace) {
                imageView_Trace.kf.setImage(
                    with: url_Trace,
                    placeholder: createPlaceholderImage_Trace(color_Trace: defaultColor_Trace),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Trace(color_Trace: defaultColor_Trace)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Trace: 图标颜色
    func setDefaultAvatar_Trace(color_Trace: UIColor) {
        imageView_Trace.image = UIImage(systemName: "person.circle.fill")
        imageView_Trace.tintColor = color_Trace
        imageView_Trace.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Trace(color_Trace: UIColor) -> UIImage? {
        let size_Trace = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Trace, false, 0)
        
        // 绘制圆形背景
        color_Trace.withAlphaComponent(0.2).setFill()
        let circlePath_Trace = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Trace))
        circlePath_Trace.fill()
        
        // 绘制人物图标
        if let icon_Trace = UIImage(systemName: "person.fill") {
            color_Trace.setFill()
            icon_Trace.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Trace = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Trace
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Trace() {
        if let userId_Trace = userId_Trace {
            configure_Trace(userId_Trace: userId_Trace)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Trace: UserAvatarView_Trace {
    
    // MARK: - UI组件
    
    /// 编辑按钮（可选）
    private let editButton_Trace: UIButton = {
        let button_Trace = UIButton(type: .custom)
        button_Trace.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        button_Trace.tintColor = ColorConfig_Trace.primaryGradientStart_Trace
        button_Trace.backgroundColor = .white
        button_Trace.isHidden = true
        return button_Trace
    }()
    
    // MARK: - 属性
    
    /// 是否显示编辑按钮
    var showEditButton_Trace: Bool = false {
        didSet {
            editButton_Trace.isHidden = !showEditButton_Trace
        }
    }
    
    /// 点击回调
    var onTapped_Trace: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Trace()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置编辑按钮圆形
        editButton_Trace.layer.cornerRadius = editButton_Trace.bounds.width / 2
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Trace() {
        super.setupUI_Trace()
        
        // 启用用户交互
        imageView_Trace.isUserInteractionEnabled = true
        
        // 添加编辑按钮
        addSubview(editButton_Trace)
        editButton_Trace.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().offset(2)
            make.width.height.equalTo(28)
        }
        
        // 修改在线指示器尺寸
        onlineIndicator_Trace.snp.remakeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.width.height.equalTo(14)
        }
        
        // 默认显示在线状态
        onlineIndicator_Trace.isHidden = false
        
        // 添加点击手势
        let tapGesture_Trace = UITapGestureRecognizer(target: self, action: #selector(handleTap_Trace))
        imageView_Trace.addGestureRecognizer(tapGesture_Trace)
        
        editButton_Trace.addTarget(self, action: #selector(handleEditTap_Trace), for: .touchUpInside)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Trace() {
        let currentUser_Trace = UserViewModel_Trace.shared_Trace.getCurrentUser_Trace()
        isCurrentUser_Trace = true
        userId_Trace = currentUser_Trace.userId_Trace
        
        guard let headPath_Trace = currentUser_Trace.userHead_Trace, !headPath_Trace.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Trace(color_Trace: ColorConfig_Trace.primaryGradientStart_Trace)
            return
        }
        
        loadAvatarFromPath_Trace(path_Trace: headPath_Trace, defaultColor_Trace: ColorConfig_Trace.primaryGradientStart_Trace)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Trace(color_Trace: UIColor) -> UIImage? {
        let size_Trace = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Trace, false, 0)
        
        // 绘制渐变背景
        let context_Trace = UIGraphicsGetCurrentContext()
        let colors_Trace = [
            ColorConfig_Trace.primaryGradientStart_Trace.cgColor,
            ColorConfig_Trace.primaryGradientEnd_Trace.cgColor
        ]
        let colorSpace_Trace = CGColorSpaceCreateDeviceRGB()
        let gradient_Trace = CGGradient(colorsSpace: colorSpace_Trace, colors: colors_Trace as CFArray, locations: nil)
        
        context_Trace?.drawLinearGradient(
            gradient_Trace!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Trace.width, y: size_Trace.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Trace = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Trace.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Trace = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Trace
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Trace() {
        // 缩放动画
        animatePressDown_Trace {
            self.animatePressUp_Trace()
        }
        
        // 触觉反馈
        let generator_Trace = UIImpactFeedbackGenerator(style: .light)
        generator_Trace.impactOccurred()
        
        // 触发回调
        onTapped_Trace?()
    }
    
    /// 处理编辑按钮点击事件
    @objc private func handleEditTap_Trace() {
        // 触发回调（可用于打开相册选择）
        onTapped_Trace?()
        
        // 触觉反馈
        let generator_Trace = UIImpactFeedbackGenerator(style: .medium)
        generator_Trace.impactOccurred()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Trace() {
        loadCurrentUserAvatar_Trace()
    }
}
