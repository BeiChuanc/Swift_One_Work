import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
/// 功能：展示用户头像，自动判断是登录用户还是其他用户
/// 支持：系统默认图标、本地图片、相册上传、网络图片
class UserAvatarView_Wanderbell: UIView {
    
    // MARK: - UI组件
    
    /// 头像图片视图
    private let imageView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.contentMode = .scaleAspectFill
        imageView_wanderbell.clipsToBounds = true
        imageView_wanderbell.backgroundColor = ColorConfig_Wanderbell.backgroundPrimary_Wanderbell
        return imageView_wanderbell
    }()
    
    /// 在线状态指示器（登录用户专属）
    private let onlineIndicator_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = UIColor(hexstring_Wanderbell: "#48BB78") // 绿色
        view_wanderbell.layer.borderWidth = 2
        view_wanderbell.layer.borderColor = UIColor.white.cgColor
        view_wanderbell.isHidden = true
        return view_wanderbell
    }()
    
    // MARK: - 属性
    
    private var userId_Wanderbell: Int?
    private var isCurrentUser_Wanderbell: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
        observeUserState_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Wanderbell.layer.cornerRadius = bounds.width / 2
        onlineIndicator_Wanderbell.layer.cornerRadius = onlineIndicator_Wanderbell.bounds.width / 2
    }
    
    // MARK: - UI设置
    
    private func setupUI_Wanderbell() {
        addSubview(imageView_Wanderbell)
        addSubview(onlineIndicator_Wanderbell)
        
        imageView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        onlineIndicator_Wanderbell.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.width.height.equalTo(12)
        }
    }
    
    /// 监听用户状态变化
    private func observeUserState_Wanderbell() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Wanderbell),
            name: UserViewModel_Wanderbell.userStateDidChangeNotification_Wanderbell,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    /// 功能：根据用户ID自动加载对应头像，并判断是否是当前登录用户
    /// 参数：
    /// - userId_wanderbell: 用户ID
    func configure_Wanderbell(userId_wanderbell: Int) {
        self.userId_Wanderbell = userId_wanderbell
        
        // 判断是否是当前登录用户
        let currentUser_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell()
        isCurrentUser_Wanderbell = (currentUser_wanderbell.userId_Wanderbell == userId_wanderbell)
        
        // 显示/隐藏在线指示器
        onlineIndicator_Wanderbell.isHidden = !isCurrentUser_Wanderbell
        
        // 加载头像
        if isCurrentUser_Wanderbell {
            loadCurrentUserAvatar_Wanderbell(user_wanderbell: currentUser_wanderbell)
        } else {
            loadOtherUserAvatar_Wanderbell(userId_wanderbell: userId_wanderbell)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Wanderbell(user_wanderbell: LoginUserModel_Wanderbell) {
        guard let headPath_wanderbell = user_wanderbell.userHead_Wanderbell, !headPath_wanderbell.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Wanderbell(color_wanderbell: ColorConfig_Wanderbell.primaryGradientStart_Wanderbell)
            return
        }
        
        loadAvatarFromPath_Wanderbell(path_wanderbell: headPath_wanderbell, defaultColor_wanderbell: ColorConfig_Wanderbell.primaryGradientStart_Wanderbell)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Wanderbell(userId_wanderbell: Int) {
        let userInfo_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getUserById_Wanderbell(userId_wanderbell: userId_wanderbell)
        
        guard let headPath_wanderbell = userInfo_wanderbell.userHead_Wanderbell, !headPath_wanderbell.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            let colors_wanderbell: [UIColor] = [
                ColorConfig_Wanderbell.primaryGradientStart_Wanderbell,
                ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell,
                UIColor(hexstring_Wanderbell: "#63B3ED"),
                UIColor(hexstring_Wanderbell: "#F6AD55"),
                UIColor(hexstring_Wanderbell: "#FC8181")
            ]
            let color_wanderbell = colors_wanderbell[userId_wanderbell % colors_wanderbell.count]
            setDefaultAvatar_Wanderbell(color_wanderbell: color_wanderbell)
            return
        }
        
        let colors_wanderbell: [UIColor] = [
            ColorConfig_Wanderbell.primaryGradientStart_Wanderbell,
            ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell,
            UIColor(hexstring_Wanderbell: "#63B3ED"),
            UIColor(hexstring_Wanderbell: "#F6AD55"),
            UIColor(hexstring_Wanderbell: "#FC8181")
        ]
        let color_wanderbell = colors_wanderbell[userId_wanderbell % colors_wanderbell.count]
        loadAvatarFromPath_Wanderbell(path_wanderbell: headPath_wanderbell, defaultColor_wanderbell: color_wanderbell)
    }
    
    /// 从路径加载头像
    private func loadAvatarFromPath_Wanderbell(path_wanderbell: String, defaultColor_wanderbell: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_wanderbell = UIImage(named: path_wanderbell) {
            imageView_Wanderbell.image = assetImage_wanderbell
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_wanderbell = UIImage(contentsOfFile: path_wanderbell) {
            imageView_Wanderbell.image = localImage_wanderbell
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_wanderbell.hasPrefix("http://") || path_wanderbell.hasPrefix("https://") {
            if let url_wanderbell = URL(string: path_wanderbell) {
                imageView_Wanderbell.kf.setImage(
                    with: url_wanderbell,
                    placeholder: createPlaceholderImage_Wanderbell(color_wanderbell: defaultColor_wanderbell),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Wanderbell(color_wanderbell: defaultColor_wanderbell)
    }
    
    /// 设置默认头像（系统图标）
    private func setDefaultAvatar_Wanderbell(color_wanderbell: UIColor) {
        imageView_Wanderbell.image = UIImage(systemName: "person.circle.fill")
        imageView_Wanderbell.tintColor = color_wanderbell
        imageView_Wanderbell.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Wanderbell(color_wanderbell: UIColor) -> UIImage? {
        let size_wanderbell = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_wanderbell, false, 0)
        
        // 绘制圆形背景
        color_wanderbell.withAlphaComponent(0.2).setFill()
        let circlePath_wanderbell = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_wanderbell))
        circlePath_wanderbell.fill()
        
        // 绘制人物图标
        if let icon_wanderbell = UIImage(systemName: "person.fill") {
            color_wanderbell.setFill()
            icon_wanderbell.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_wanderbell = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_wanderbell
    }
    
    // MARK: - 事件处理
    
    @objc private func handleUserStateChange_Wanderbell() {
        if let userId_wanderbell = userId_Wanderbell {
            configure_Wanderbell(userId_wanderbell: userId_wanderbell)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
/// 功能：专门用于展示当前登录用户的头像，支持编辑功能
/// 特点：可点击、可编辑、带在线状态标识
class CurrentUserAvatarView_Wanderbell: UIView {
    
    // MARK: - UI组件
    
    /// 头像图片视图
    private let imageView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.contentMode = .scaleAspectFill
        imageView_wanderbell.clipsToBounds = true
        imageView_wanderbell.backgroundColor = ColorConfig_Wanderbell.backgroundPrimary_Wanderbell
        imageView_wanderbell.isUserInteractionEnabled = true
        return imageView_wanderbell
    }()
    
    /// 编辑按钮（可选）
    private let editButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .custom)
        button_wanderbell.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        button_wanderbell.tintColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
        button_wanderbell.backgroundColor = .white
        button_wanderbell.isHidden = true
        return button_wanderbell
    }()
    
    /// 在线状态指示器
    private let onlineIndicator_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = UIColor(hexstring_Wanderbell: "#48BB78") // 绿色
        view_wanderbell.layer.borderWidth = 2
        view_wanderbell.layer.borderColor = UIColor.white.cgColor
        return view_wanderbell
    }()
    
    // MARK: - 属性
    
    /// 是否显示编辑按钮
    var showEditButton_Wanderbell: Bool = false {
        didSet {
            editButton_Wanderbell.isHidden = !showEditButton_Wanderbell
        }
    }
    
    /// 点击回调
    var onTapped_Wanderbell: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
        loadCurrentUserAvatar_Wanderbell()
        observeUserState_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Wanderbell.layer.cornerRadius = bounds.width / 2
        editButton_Wanderbell.layer.cornerRadius = editButton_Wanderbell.bounds.width / 2
        onlineIndicator_Wanderbell.layer.cornerRadius = onlineIndicator_Wanderbell.bounds.width / 2
    }
    
    // MARK: - UI设置
    
    private func setupUI_Wanderbell() {
        addSubview(imageView_Wanderbell)
        addSubview(onlineIndicator_Wanderbell)
        addSubview(editButton_Wanderbell)
        
        imageView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        onlineIndicator_Wanderbell.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.width.height.equalTo(14)
        }
        
        editButton_Wanderbell.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().offset(2)
            make.width.height.equalTo(28)
        }
        
        // 添加点击手势
        let tapGesture_wanderbell = UITapGestureRecognizer(target: self, action: #selector(handleTap_Wanderbell))
        imageView_Wanderbell.addGestureRecognizer(tapGesture_wanderbell)
        
        editButton_Wanderbell.addTarget(self, action: #selector(handleEditTap_Wanderbell), for: .touchUpInside)
    }
    
    /// 监听用户状态变化
    private func observeUserState_Wanderbell() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Wanderbell),
            name: UserViewModel_Wanderbell.userStateDidChangeNotification_Wanderbell,
            object: nil
        )
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Wanderbell() {
        let currentUser_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell()
        
        guard let headPath_wanderbell = currentUser_wanderbell.userHead_Wanderbell, !headPath_wanderbell.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Wanderbell()
            return
        }
        
        loadAvatarFromPath_Wanderbell(path_wanderbell: headPath_wanderbell)
    }
    
    /// 从路径加载头像
    private func loadAvatarFromPath_Wanderbell(path_wanderbell: String) {
        // 1. 尝试从Assets加载
        if let assetImage_wanderbell = UIImage(named: path_wanderbell) {
            imageView_Wanderbell.image = assetImage_wanderbell
            imageView_Wanderbell.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册本地路径加载（用户上传的照片）
        if let localImage_wanderbell = UIImage(contentsOfFile: path_wanderbell) {
            imageView_Wanderbell.image = localImage_wanderbell
            imageView_Wanderbell.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_wanderbell.hasPrefix("http://") || path_wanderbell.hasPrefix("https://") {
            if let url_wanderbell = URL(string: path_wanderbell) {
                imageView_Wanderbell.kf.setImage(
                    with: url_wanderbell,
                    placeholder: createPlaceholderImage_Wanderbell(),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Wanderbell()
    }
    
    /// 设置默认头像
    private func setDefaultAvatar_Wanderbell() {
        imageView_Wanderbell.image = UIImage(systemName: "person.crop.circle.fill")
        imageView_Wanderbell.tintColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
        imageView_Wanderbell.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    private func createPlaceholderImage_Wanderbell() -> UIImage? {
        let size_wanderbell = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_wanderbell, false, 0)
        
        // 绘制渐变背景
        let context_wanderbell = UIGraphicsGetCurrentContext()
        let colors_wanderbell = [
            ColorConfig_Wanderbell.primaryGradientStart_Wanderbell.cgColor,
            ColorConfig_Wanderbell.primaryGradientEnd_Wanderbell.cgColor
        ]
        let colorSpace_wanderbell = CGColorSpaceCreateDeviceRGB()
        let gradient_wanderbell = CGGradient(colorsSpace: colorSpace_wanderbell, colors: colors_wanderbell as CFArray, locations: nil)
        
        context_wanderbell?.drawLinearGradient(
            gradient_wanderbell!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_wanderbell.width, y: size_wanderbell.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_wanderbell = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_wanderbell.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_wanderbell = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_wanderbell
    }
    
    // MARK: - 事件处理
    
    @objc private func handleTap_Wanderbell() {
        // 缩放动画
        animatePressDown_Wanderbell {
            self.animatePressUp_Wanderbell()
        }
        
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .light)
        generator_wanderbell.impactOccurred()
        
        // 触发回调
        onTapped_Wanderbell?()
    }
    
    @objc private func handleEditTap_Wanderbell() {
        // 触发回调（可用于打开相册选择）
        onTapped_Wanderbell?()
        
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .medium)
        generator_wanderbell.impactOccurred()
    }
    
    @objc private func handleUserStateChange_Wanderbell() {
        loadCurrentUserAvatar_Wanderbell()
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
