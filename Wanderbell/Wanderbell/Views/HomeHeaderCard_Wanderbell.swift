import Foundation
import UIKit
import SnapKit

// MARK: 首页头部卡片

/// 首页头部卡片视图
/// 功能：展示用户信息和快速记录按钮
/// 设计：渐变背景、圆角卡片、用户头像、问候语、快速记录按钮
class HomeHeaderCard_Wanderbell: UIView {
    
    // MARK: - UI组件
    
    /// 渐变背景图层
    private var gradientLayer_Wanderbell: CAGradientLayer?
    
    /// 用户头像（使用登录用户头像组件）
    private let avatarImageView_Wanderbell: CurrentUserAvatarView_Wanderbell = {
        let avatarView_wanderbell = CurrentUserAvatarView_Wanderbell()
        avatarView_wanderbell.showEditButton_Wanderbell = false // 首页头部不显示编辑按钮
        return avatarView_wanderbell
    }()
    
    /// 问候语标签
    private let greetingLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "How are you feeling today?"
        label_wanderbell.font = FontConfig_Wanderbell.title2_Wanderbell()
        label_wanderbell.textColor = .white
        label_wanderbell.numberOfLines = 2
        return label_wanderbell
    }()
    
    /// 用户名标签
    private let usernameLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Welcome back!"
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = UIColor.white.withAlphaComponent(0.9)
        return label_wanderbell
    }()
    
    /// 装饰图标
    private let decorImageView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "sparkles")
        imageView_wanderbell.tintColor = UIColor.white.withAlphaComponent(0.3)
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    /// 快速记录按钮
    private let quickRecordButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .custom)
        button_wanderbell.backgroundColor = .white
        button_wanderbell.setImage(UIImage(systemName: "plus"), for: .normal)
        button_wanderbell.tintColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
        button_wanderbell.imageView?.contentMode = .scaleAspectFit
        button_wanderbell.contentVerticalAlignment = .fill
        button_wanderbell.contentHorizontalAlignment = .fill
        button_wanderbell.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return button_wanderbell
    }()
    
    // MARK: - 回调
    
    /// 快速记录按钮点击回调
    var onQuickRecordTapped_Wanderbell: (() -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
        setupConstraints_Wanderbell()
        setupActions_Wanderbell()
        observeUserState_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层
        gradientLayer_Wanderbell?.frame = bounds
        
        // 更新圆角
        layer.cornerRadius = 20
        quickRecordButton_Wanderbell.layer.cornerRadius = 28
        
        // 添加光晕效果到快速记录按钮
        quickRecordButton_Wanderbell.layer.addGlowEffect_Wanderbell(
            color_wanderbell: ColorConfig_Wanderbell.primaryGradientStart_Wanderbell,
            radius_wanderbell: 8
        )
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Wanderbell() {
        // 设置渐变背景
        gradientLayer_Wanderbell = UIColor.createPrimaryGradientLayer_Wanderbell(frame_wanderbell: bounds)
        if let gradientLayer_wanderbell = gradientLayer_Wanderbell {
            layer.insertSublayer(gradientLayer_wanderbell, at: 0)
        }
        
        // 设置圆角和阴影
        layer.cornerRadius = 20
        layer.masksToBounds = true
        layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.2
        
        // 添加子视图
        addSubview(decorImageView_Wanderbell)
        addSubview(avatarImageView_Wanderbell)
        addSubview(greetingLabel_Wanderbell)
        addSubview(usernameLabel_Wanderbell)
        addSubview(quickRecordButton_Wanderbell)
        
        // 更新用户信息
        updateUserInfo_Wanderbell()
    }
    
    /// 设置约束
    private func setupConstraints_Wanderbell() {
        // 装饰图标
        decorImageView_Wanderbell.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-120)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(80)
        }
        
        // 用户头像
        avatarImageView_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        // 用户名标签
        usernameLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView_Wanderbell.snp.right).offset(16)
            make.top.equalTo(avatarImageView_Wanderbell.snp.top).offset(4)
            make.right.equalTo(quickRecordButton_Wanderbell.snp.left).offset(-16)
        }
        
        // 问候语标签
        greetingLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView_Wanderbell.snp.right).offset(16)
            make.top.equalTo(usernameLabel_Wanderbell.snp.bottom).offset(4)
            make.right.equalTo(quickRecordButton_Wanderbell.snp.left).offset(-16)
        }
        
        // 快速记录按钮
        quickRecordButton_Wanderbell.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(56)
        }
    }
    
    /// 设置交互
    private func setupActions_Wanderbell() {
        quickRecordButton_Wanderbell.addTarget(
            self,
            action: #selector(quickRecordButtonTapped_Wanderbell),
            for: .touchUpInside
        )
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
    
    // MARK: - 数据更新
    
    /// 更新用户信息
    private func updateUserInfo_Wanderbell() {
        let currentUser_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell()
        
        // 更新用户名
        if let username_wanderbell = currentUser_wanderbell.userName_Wanderbell {
            usernameLabel_Wanderbell.text = "Welcome back, \(username_wanderbell)!"
        } else {
            usernameLabel_Wanderbell.text = "Welcome!"
        }
        
        // 头像组件会自动更新，无需手动处理
        avatarImageView_Wanderbell.loadCurrentUserAvatar_Wanderbell()
    }
    
    // MARK: - 事件处理
    
    /// 快速记录按钮点击
    @objc private func quickRecordButtonTapped_Wanderbell() {
        // 按压动画
        quickRecordButton_Wanderbell.animatePressDown_Wanderbell { [weak self] in
            self?.quickRecordButton_Wanderbell.animatePressUp_Wanderbell { [weak self] in
                // 触发回调
                self?.onQuickRecordTapped_Wanderbell?()
            }
        }
        
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .medium)
        generator_wanderbell.impactOccurred()
    }
    
    /// 处理用户状态变化
    @objc private func handleUserStateChange_Wanderbell() {
        updateUserInfo_Wanderbell()
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
