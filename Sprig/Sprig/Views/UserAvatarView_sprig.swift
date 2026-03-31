import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: - 用户头像组件

/// 用户头像视图
class UserAvatarView_Sprig: UIView {
    
    // MARK: - 静态常量
    
    /// 用户默认头像颜色数组
    static let defaultAvatarColors_Sprig: [UIColor] = [
        ColorConfig_Sprig.primaryGradientStart_Sprig,
        ColorConfig_Sprig.secondaryGradientStart_Sprig,
        UIColor(hexstring_Sprig: "#63B3ED"),
        UIColor(hexstring_Sprig: "#F6AD55"),
        UIColor(hexstring_Sprig: "#FC8181")
    ]
    
    // MARK: - UI组件
    
    /// 头像图片视图
    let imageView_Sprig: UIImageView = {
        let imageView_Sprig = UIImageView()
        imageView_Sprig.contentMode = .scaleAspectFill
        imageView_Sprig.clipsToBounds = true
        imageView_Sprig.backgroundColor = ColorConfig_Sprig.backgroundPrimary_Sprig
        return imageView_Sprig
    }()
    
    // MARK: - 属性
    
    var userId_Sprig: Int?
    var isCurrentUser_Sprig: Bool = false
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Sprig()
        observeUserState_Sprig()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置圆形
        imageView_Sprig.layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - UI设置
    
    /// 设置基础UI布局，子类可重写以自定义布局
    func setupUI_Sprig() {
        addSubview(imageView_Sprig)
        
        imageView_Sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    /// 监听用户状态变化
    func observeUserState_Sprig() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Sprig),
            name: UserViewModel_Sprig.userStateDidChangeNotification_Sprig,
            object: nil
        )
    }
    
    // MARK: - 公共方法
    
    /// 配置用户头像
    func configure_Sprig(userId_Sprig: Int) {
        self.userId_Sprig = userId_Sprig
        
        // 判断是否是当前登录用户
        let currentUser_Sprig = UserViewModel_Sprig.shared_Sprig.getCurrentUser_Sprig()
        isCurrentUser_Sprig = (currentUser_Sprig.userId_Sprig == userId_Sprig)
        
        // 加载头像
        if isCurrentUser_Sprig {
            loadCurrentUserAvatar_Sprig(user_Sprig: currentUser_Sprig)
        } else {
            loadOtherUserAvatar_Sprig(userId_Sprig: userId_Sprig)
        }
    }
    
    /// 加载当前登录用户头像
    private func loadCurrentUserAvatar_Sprig(user_Sprig: LoginUserModel_Sprig) {
        guard let headPath_Sprig = user_Sprig.userHead_Sprig, !headPath_Sprig.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Sprig(color_Sprig: ColorConfig_Sprig.primaryGradientStart_Sprig)
            return
        }
        
        loadAvatarFromPath_Sprig(path_Sprig: headPath_Sprig, defaultColor_Sprig: ColorConfig_Sprig.primaryGradientStart_Sprig)
    }
    
    /// 加载其他用户头像
    private func loadOtherUserAvatar_Sprig(userId_Sprig: Int) {
        let userInfo_Sprig = UserViewModel_Sprig.shared_Sprig.getUserById_Sprig(userId_sprig: userId_Sprig)
        let color_Sprig = Self.defaultAvatarColors_Sprig[userId_Sprig % Self.defaultAvatarColors_Sprig.count]
        
        guard let headPath_Sprig = userInfo_Sprig.userHead_Sprig, !headPath_Sprig.isEmpty else {
            // 使用默认头像，不同用户不同颜色
            setDefaultAvatar_Sprig(color_Sprig: color_Sprig)
            return
        }
        
        loadAvatarFromPath_Sprig(path_Sprig: headPath_Sprig, defaultColor_Sprig: color_Sprig)
    }
    
    /// 从路径加载头像
    func loadAvatarFromPath_Sprig(path_Sprig: String, defaultColor_Sprig: UIColor) {
        // 1. 尝试从Assets加载
        if let assetImage_Sprig = UIImage(named: path_Sprig) {
            imageView_Sprig.image = assetImage_Sprig
            imageView_Sprig.contentMode = .scaleAspectFill
            return
        }
        
        // 2. 尝试从相册路径加载
        if let localImage_Sprig = UIImage(contentsOfFile: path_Sprig) {
            imageView_Sprig.image = localImage_Sprig
            imageView_Sprig.contentMode = .scaleAspectFill
            return
        }
        
        // 3. 尝试从网络URL加载
        if path_Sprig.hasPrefix("http://") || path_Sprig.hasPrefix("https://") {
            if let url_Sprig = URL(string: path_Sprig) {
                imageView_Sprig.kf.setImage(
                    with: url_Sprig,
                    placeholder: createPlaceholderImage_Sprig(color_Sprig: defaultColor_Sprig),
                    options: [.transition(.fade(0.2))]
                )
            }
            return
        }
        
        // 4. 都失败则使用默认头像
        setDefaultAvatar_Sprig(color_Sprig: defaultColor_Sprig)
    }
    
    /// 设置默认头像（系统图标）
    /// - Parameter color_Sprig: 图标颜色
    func setDefaultAvatar_Sprig(color_Sprig: UIColor) {
        imageView_Sprig.image = UIImage(systemName: "person.circle.fill")
        imageView_Sprig.tintColor = color_Sprig
        imageView_Sprig.contentMode = .scaleAspectFit
    }
    
    /// 创建占位符图片
    func createPlaceholderImage_Sprig(color_Sprig: UIColor) -> UIImage? {
        let size_Sprig = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Sprig, false, 0)
        
        // 绘制圆形背景
        color_Sprig.withAlphaComponent(0.2).setFill()
        let circlePath_Sprig = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size_Sprig))
        circlePath_Sprig.fill()
        
        // 绘制人物图标
        if let icon_Sprig = UIImage(systemName: "person.fill") {
            color_Sprig.setFill()
            icon_Sprig.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Sprig = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Sprig
    }
    
    // MARK: - 事件处理
    
    /// 处理用户状态变化，子类可重写以自定义行为
    @objc func handleUserStateChange_Sprig() {
        if let userId_Sprig = userId_Sprig {
            configure_Sprig(userId_Sprig: userId_Sprig)
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 登录用户头像组件

/// 登录用户头像组件
class CurrentUserAvatarView_Sprig: UserAvatarView_Sprig {
    
    // MARK: - UI组件
    
    /// 编辑按钮（可选）
    private let editButton_Sprig: UIButton = {
        let button_Sprig = UIButton(type: .custom)
        button_Sprig.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        button_Sprig.tintColor = ColorConfig_Sprig.primaryGradientStart_Sprig
        button_Sprig.backgroundColor = .white
        button_Sprig.isHidden = true
        return button_Sprig
    }()
    
    // MARK: - 属性
    
    /// 是否显示编辑按钮
    var showEditButton_Sprig: Bool = false {
        didSet {
            editButton_Sprig.isHidden = !showEditButton_Sprig
        }
    }
    
    /// 点击回调
    var onTapped_Sprig: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadCurrentUserAvatar_Sprig()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置编辑按钮圆形
        editButton_Sprig.layer.cornerRadius = editButton_Sprig.bounds.width / 2
    }
    
    // MARK: - UI设置（重写）
    
    override func setupUI_Sprig() {
        super.setupUI_Sprig()
        
        // 启用用户交互
        imageView_Sprig.isUserInteractionEnabled = true
        
        // 添加编辑按钮
        addSubview(editButton_Sprig)
        editButton_Sprig.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().offset(2)
            make.width.height.equalTo(28)
        }
        
        // 添加点击手势
        let tapGesture_Sprig = UITapGestureRecognizer(target: self, action: #selector(handleTap_Sprig))
        imageView_Sprig.addGestureRecognizer(tapGesture_Sprig)
        
        editButton_Sprig.addTarget(self, action: #selector(handleEditTap_Sprig), for: .touchUpInside)
    }
    
    // MARK: - 加载头像
    
    /// 加载当前登录用户头像
    func loadCurrentUserAvatar_Sprig() {
        let currentUser_Sprig = UserViewModel_Sprig.shared_Sprig.getCurrentUser_Sprig()
        isCurrentUser_Sprig = true
        userId_Sprig = currentUser_Sprig.userId_Sprig
        
        guard let headPath_Sprig = currentUser_Sprig.userHead_Sprig, !headPath_Sprig.isEmpty else {
            // 使用默认头像
            setDefaultAvatar_Sprig(color_Sprig: ColorConfig_Sprig.primaryGradientStart_Sprig)
            return
        }
        
        loadAvatarFromPath_Sprig(path_Sprig: headPath_Sprig, defaultColor_Sprig: ColorConfig_Sprig.primaryGradientStart_Sprig)
    }
    
    /// 创建渐变占位符图片（重写父类方法，使用渐变效果）
    override func createPlaceholderImage_Sprig(color_Sprig: UIColor) -> UIImage? {
        let size_Sprig = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size_Sprig, false, 0)
        
        // 绘制渐变背景
        let context_Sprig = UIGraphicsGetCurrentContext()
        let colors_Sprig = [
            ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor
        ]
        let colorSpace_Sprig = CGColorSpaceCreateDeviceRGB()
        let gradient_Sprig = CGGradient(colorsSpace: colorSpace_Sprig, colors: colors_Sprig as CFArray, locations: nil)
        
        context_Sprig?.drawLinearGradient(
            gradient_Sprig!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size_Sprig.width, y: size_Sprig.height),
            options: []
        )
        
        // 绘制人物图标
        if let icon_Sprig = UIImage(systemName: "person.fill") {
            UIColor.white.setFill()
            icon_Sprig.draw(in: CGRect(x: 25, y: 25, width: 50, height: 50))
        }
        
        let image_Sprig = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image_Sprig
    }
    
    // MARK: - 事件处理
    
    /// 处理头像点击事件
    @objc private func handleTap_Sprig() {
        // 缩放动画
        animatePressDown_Sprig {
            self.animatePressUp_Sprig()
        }
        
        // 触觉反馈
        let generator_Sprig = UIImpactFeedbackGenerator(style: .light)
        generator_Sprig.impactOccurred()
        
        // 触发回调
        onTapped_Sprig?()
    }
    
    /// 处理编辑按钮点击事件
    @objc private func handleEditTap_Sprig() {
        // 触发回调（可用于打开相册选择）
        onTapped_Sprig?()
        
        // 触觉反馈
        let generator_Sprig = UIImpactFeedbackGenerator(style: .medium)
        generator_Sprig.impactOccurred()
    }
    
    /// 重写用户状态变化处理（重新加载当前用户头像）
    @objc override func handleUserStateChange_Sprig() {
        loadCurrentUserAvatar_Sprig()
    }
}
