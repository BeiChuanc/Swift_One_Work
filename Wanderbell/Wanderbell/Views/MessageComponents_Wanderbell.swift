import Foundation
import UIKit
import SnapKit

// MARK: - 推荐用户卡片

/// 推荐用户卡片
/// 功能：展示用户信息，支持点击查看详情和关注功能
/// 设计：立体卡片、渐变背景、关注按钮
class RecommendUserCard_Wanderbell: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = .white
        view_wanderbell.layer.cornerRadius = 20
        view_wanderbell.layer.masksToBounds = true  // 裁剪子视图，确保圆角生效
        return view_wanderbell
    }()
    
    /// 渐变背景视图
    private let gradientBackgroundView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        return view_wanderbell
    }()
    
    private var gradientLayer_Wanderbell: CAGradientLayer?
    
    /// 用户头像
    private let avatarView_Wanderbell = UserAvatarView_Wanderbell()
    
    /// 用户名
    private let usernameLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        label_wanderbell.textAlignment = .center
        label_wanderbell.numberOfLines = 2  // 允许换行
        label_wanderbell.adjustsFontSizeToFitWidth = true  // 自动缩小字体
        label_wanderbell.minimumScaleFactor = 0.8
        return label_wanderbell
    }()
    
    /// 用户简介
    private let introLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.caption_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        label_wanderbell.textAlignment = .center
        label_wanderbell.numberOfLines = 2
        return label_wanderbell
    }()
    
    /// 关注按钮
    private let followButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .custom)  // 使用 custom 类型，避免系统默认颜色
        button_wanderbell.setTitle("Follow", for: .normal)
        button_wanderbell.setTitle("Followed", for: .selected)  // 已关注显示 "Followed"
        button_wanderbell.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        button_wanderbell.setTitleColor(.white, for: .normal)
        button_wanderbell.setTitleColor(ColorConfig_Wanderbell.primaryGradientStart_Wanderbell, for: .selected)
        button_wanderbell.backgroundColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
        button_wanderbell.layer.cornerRadius = 14
        return button_wanderbell
    }()
    
    // MARK: - 属性
    
    private var userModel_Wanderbell: PrewUserModel_Wanderbell?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
        setupActions_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层
        if gradientLayer_Wanderbell == nil {
            let gradient_wanderbell = CAGradientLayer()
            gradient_wanderbell.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 80)
            gradient_wanderbell.colors = [
                ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell.withAlphaComponent(0.3).cgColor,
                ColorConfig_Wanderbell.secondaryGradientEnd_Wanderbell.withAlphaComponent(0.3).cgColor
            ]
            gradient_wanderbell.startPoint = CGPoint(x: 0, y: 0)
            gradient_wanderbell.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer_Wanderbell = gradient_wanderbell
            gradientBackgroundView_Wanderbell.layer.insertSublayer(gradient_wanderbell, at: 0)
        } else {
            gradientLayer_Wanderbell?.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 80)
        }
    }
    
    private func setupUI_Wanderbell() {
        // 设置外层阴影
        layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.15
        layer.masksToBounds = false  // 不裁剪阴影
        
        addSubview(containerView_Wanderbell)
        containerView_Wanderbell.addSubview(gradientBackgroundView_Wanderbell)
        containerView_Wanderbell.addSubview(avatarView_Wanderbell)
        containerView_Wanderbell.addSubview(usernameLabel_Wanderbell)
        containerView_Wanderbell.addSubview(introLabel_Wanderbell)
        containerView_Wanderbell.addSubview(followButton_Wanderbell)
        
        containerView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientBackgroundView_Wanderbell.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(80)
        }
        
        avatarView_Wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(56)
        }
        
        usernameLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Wanderbell.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(6)
        }
        
        introLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel_Wanderbell.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(6)
        }
        
        followButton_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(introLabel_Wanderbell.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(28)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }
    }
    
    private func setupActions_Wanderbell() {
        // 设置关注按钮点击事件
        followButton_Wanderbell.addTarget(self, action: #selector(followButtonTapped_Wanderbell), for: .touchUpInside)
        
        // 确保按钮可以交互
        followButton_Wanderbell.isUserInteractionEnabled = true
        
        // 整个卡片可点击
        let tapGesture_wanderbell = UITapGestureRecognizer(target: self, action: #selector(cardTapped_Wanderbell))
        tapGesture_wanderbell.cancelsTouchesInView = false  // 不取消子视图的触摸事件
        containerView_Wanderbell.addGestureRecognizer(tapGesture_wanderbell)
    }
    
    // MARK: - 配置
    
    func configure_Wanderbell(user_wanderbell: PrewUserModel_Wanderbell) {
        userModel_Wanderbell = user_wanderbell
        
        // 配置头像
        if let userId_wanderbell = user_wanderbell.userId_Wanderbell {
            avatarView_Wanderbell.configure_Wanderbell(userId_wanderbell: userId_wanderbell)
        }
        
        // 配置用户名
        usernameLabel_Wanderbell.text = user_wanderbell.userName_Wanderbell
        
        // 配置简介
        introLabel_Wanderbell.text = user_wanderbell.userIntroduce_Wanderbell
        
        // 配置关注按钮状态
        let isFollowing_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.isFollowing_Wanderbell(user_wanderbell: user_wanderbell)
        followButton_Wanderbell.isSelected = isFollowing_wanderbell
        followButton_Wanderbell.backgroundColor = isFollowing_wanderbell ? UIColor.white : ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
        followButton_Wanderbell.layer.borderWidth = isFollowing_wanderbell ? 1.5 : 0
        followButton_Wanderbell.layer.borderColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell.cgColor
    }
    
    // MARK: - 事件处理
    
    @objc private func followButtonTapped_Wanderbell() {
        guard let user_wanderbell = userModel_Wanderbell else {
            return 
        }
        
        
        // 检查登录状态
        if !UserViewModel_Wanderbell.shared_Wanderbell.isLoggedIn_Wanderbell {
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
                Navigation_Wanderbell.toLogin_Wanderbell(style_wanderbell: .push_wanderbell)
            }
            return
        }
        
        // 按压动画
        followButton_Wanderbell.animatePulse_Wanderbell()
        
        // 切换关注状态
        UserViewModel_Wanderbell.shared_Wanderbell.followUser_Wanderbell(user_wanderbell: user_wanderbell)
        
        // 更新按钮状态
        let isFollowing_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.isFollowing_Wanderbell(user_wanderbell: user_wanderbell)
        
        updateFollowButtonState_Wanderbell(isFollowing_wanderbell: isFollowing_wanderbell)
        
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .medium)
        generator_wanderbell.impactOccurred()
        
        // 显示成功提示
        let message_wanderbell = isFollowing_wanderbell ? "Followed successfully" : "Unfollowed"
        Utils_Wanderbell.showSuccess_Wanderbell(
            message_wanderbell: message_wanderbell,
            delay_wanderbell: 1.0
        )
    }
    
    /// 更新关注按钮状态
    /// 功能：统一处理按钮的视觉状态更新
    /// 参数：
    /// - isFollowing_wanderbell: 是否已关注
    private func updateFollowButtonState_Wanderbell(isFollowing_wanderbell: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.followButton_Wanderbell.isSelected = isFollowing_wanderbell
            self.followButton_Wanderbell.backgroundColor = isFollowing_wanderbell 
                ? UIColor.white 
                : ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
            self.followButton_Wanderbell.layer.borderWidth = isFollowing_wanderbell ? 1.5 : 0
            self.followButton_Wanderbell.layer.borderColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell.cgColor
            self.followButton_Wanderbell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.followButton_Wanderbell.transform = .identity
            }
        })
    }
    
    @objc private func cardTapped_Wanderbell(_ gesture_wanderbell: UITapGestureRecognizer) {
        guard let user_wanderbell = userModel_Wanderbell else { return }
        
        // 获取点击位置
        let location_wanderbell = gesture_wanderbell.location(in: containerView_Wanderbell)
        
        // 检查是否点击在关注按钮上，如果是则不处理卡片点击
        let buttonFrame_wanderbell = followButton_Wanderbell.frame
        if buttonFrame_wanderbell.contains(location_wanderbell) {
            return
        }
        
        // 按压动画
        containerView_Wanderbell.animatePressDown_Wanderbell {
            self.containerView_Wanderbell.animatePressUp_Wanderbell()
        }
        
        // 跳转到用户中心
        Navigation_Wanderbell.toUserInfo_Wanderbell(
            with: user_wanderbell,
            style_wanderbell: .push_wanderbell
        )
        
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .light)
        generator_wanderbell.impactOccurred()
    }
}

// MARK: - 聊天单元格

/// 聊天单元格
/// 功能：展示单个聊天的用户信息和最后一条消息
/// 设计：卡片式、头像、用户名、最后消息、时间
class ChatCell_Wanderbell: UIView {
    
    private let containerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        view_wanderbell.layer.cornerRadius = 16
        view_wanderbell.layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        view_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 2)
        view_wanderbell.layer.shadowRadius = 8
        view_wanderbell.layer.shadowOpacity = 0.1
        return view_wanderbell
    }()
    
    /// 渐变装饰条
    private let gradientBackgroundView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.layer.cornerRadius = 16
        view_wanderbell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view_wanderbell
    }()
    
    private var gradientLayer_Wanderbell: CAGradientLayer?
    
    /// 用户头像
    private let avatarView_Wanderbell = UserAvatarView_Wanderbell()
    
    /// 用户名
    private let usernameLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.body_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return label_wanderbell
    }()
    
    /// 最后一条消息
    private let lastMessageLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        label_wanderbell.numberOfLines = 1
        return label_wanderbell
    }()
    
    /// 时间标签
    private let timeLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.caption_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPlaceholder_Wanderbell
        return label_wanderbell
    }()
    
    /// 箭头图标
    private let arrowIcon_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "chevron.right")
        imageView_wanderbell.tintColor = ColorConfig_Wanderbell.textPlaceholder_Wanderbell
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    /// 未读消息角标
    private let badgeView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = UIColor(hexstring_Wanderbell: "#FC8181")
        view_wanderbell.layer.cornerRadius = 10
        view_wanderbell.isHidden = true
        return view_wanderbell
    }()
    
    private let badgeLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label_wanderbell.textColor = .white
        label_wanderbell.textAlignment = .center
        return label_wanderbell
    }()
    
    // MARK: - 属性
    
    private var userModel_Wanderbell: PrewUserModel_Wanderbell?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
        setupActions_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变图层
        if gradientLayer_Wanderbell == nil {
            let gradient_wanderbell = CAGradientLayer()
            gradient_wanderbell.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 4)
            gradient_wanderbell.colors = [
                ColorConfig_Wanderbell.primaryGradientStart_Wanderbell.cgColor,
                ColorConfig_Wanderbell.primaryGradientEnd_Wanderbell.cgColor
            ]
            gradient_wanderbell.startPoint = CGPoint(x: 0, y: 0)
            gradient_wanderbell.endPoint = CGPoint(x: 1, y: 0)
            gradientLayer_Wanderbell = gradient_wanderbell
            gradientBackgroundView_Wanderbell.layer.insertSublayer(gradient_wanderbell, at: 0)
        } else {
            gradientLayer_Wanderbell?.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 4)
        }
    }
    
    private func setupUI_Wanderbell() {
        addSubview(containerView_Wanderbell)
        containerView_Wanderbell.addSubview(gradientBackgroundView_Wanderbell)
        containerView_Wanderbell.addSubview(avatarView_Wanderbell)
        containerView_Wanderbell.addSubview(usernameLabel_Wanderbell)
        containerView_Wanderbell.addSubview(lastMessageLabel_Wanderbell)
        containerView_Wanderbell.addSubview(timeLabel_Wanderbell)
        containerView_Wanderbell.addSubview(arrowIcon_Wanderbell)
        
        badgeView_Wanderbell.addSubview(badgeLabel_Wanderbell)
        containerView_Wanderbell.addSubview(badgeView_Wanderbell)
        
        containerView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(80)
        }
        
        gradientBackgroundView_Wanderbell.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(4)
        }
        
        avatarView_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(52)
        }
        
        usernameLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(avatarView_Wanderbell.snp.right).offset(12)
            make.top.equalTo(avatarView_Wanderbell).offset(4)
            make.right.equalTo(timeLabel_Wanderbell.snp.left).offset(-8)
        }
        
        lastMessageLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(usernameLabel_Wanderbell)
            make.top.equalTo(usernameLabel_Wanderbell.snp.bottom).offset(4)
            make.right.equalTo(arrowIcon_Wanderbell.snp.left).offset(-8)
        }
        
        timeLabel_Wanderbell.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-40)
            make.top.equalTo(usernameLabel_Wanderbell)
        }
        
        arrowIcon_Wanderbell.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        badgeView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Wanderbell).offset(-4)
            make.right.equalTo(avatarView_Wanderbell).offset(4)
            make.width.height.greaterThanOrEqualTo(20)
            make.width.greaterThanOrEqualTo(badgeLabel_Wanderbell.snp.width).offset(8)
        }
        
        badgeLabel_Wanderbell.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupActions_Wanderbell() {
        let tapGesture_wanderbell = UITapGestureRecognizer(target: self, action: #selector(cellTapped_Wanderbell))
        containerView_Wanderbell.addGestureRecognizer(tapGesture_wanderbell)
    }
    
    // MARK: - 配置
    
    func configure_Wanderbell(user_wanderbell: PrewUserModel_Wanderbell) {
        userModel_Wanderbell = user_wanderbell
        
        // 配置头像
        if let userId_wanderbell = user_wanderbell.userId_Wanderbell {
            avatarView_Wanderbell.configure_Wanderbell(userId_wanderbell: userId_wanderbell)
        }
        
        // 配置用户名
        usernameLabel_Wanderbell.text = user_wanderbell.userName_Wanderbell
        
        // 获取最后一条消息
        if let userId_wanderbell = user_wanderbell.userId_Wanderbell,
           let lastMessage_wanderbell = MessageViewModel_Wanderbell.shared_Wanderbell.getLastMessageWithUser_Wanderbell(userId_wanderbell: userId_wanderbell) {
            lastMessageLabel_Wanderbell.text = lastMessage_wanderbell.content_Wanderbell
            timeLabel_Wanderbell.text = lastMessage_wanderbell.time_Wanderbell
        } else {
            lastMessageLabel_Wanderbell.text = "Start a conversation"
            timeLabel_Wanderbell.text = ""
        }
        
        // 配置渐变顶条颜色（根据userId变化）
        updateGradientColor_Wanderbell(userId_wanderbell: user_wanderbell.userId_Wanderbell ?? 0)
    }
    
    private func updateGradientColor_Wanderbell(userId_wanderbell: Int) {
        let colors_wanderbell: [(UIColor, UIColor)] = [
            (ColorConfig_Wanderbell.primaryGradientStart_Wanderbell, ColorConfig_Wanderbell.primaryGradientEnd_Wanderbell),
            (ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell, ColorConfig_Wanderbell.secondaryGradientEnd_Wanderbell),
            (UIColor(hexstring_Wanderbell: "#F6E05E"), UIColor(hexstring_Wanderbell: "#F6AD55")),
            (UIColor(hexstring_Wanderbell: "#63B3ED"), UIColor(hexstring_Wanderbell: "#4299E1")),
            (UIColor(hexstring_Wanderbell: "#FC8181"), UIColor(hexstring_Wanderbell: "#F56565"))
        ]
        
        let selectedColors_wanderbell = colors_wanderbell[userId_wanderbell % colors_wanderbell.count]
        gradientLayer_Wanderbell?.colors = [
            selectedColors_wanderbell.0.cgColor,
            selectedColors_wanderbell.1.cgColor
        ]
    }
    
    // MARK: - 事件处理
    
    @objc private func cellTapped_Wanderbell() {
        guard let user_wanderbell = userModel_Wanderbell else { return }
        
        // 按压动画
        containerView_Wanderbell.animatePressDown_Wanderbell {
            self.containerView_Wanderbell.animatePressUp_Wanderbell()
        }
        
        // 跳转到聊天页面
        Navigation_Wanderbell.toMessageUser_Wanderbell(
            with: user_wanderbell,
            style_wanderbell: .push_wanderbell
        )
        
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .light)
        generator_wanderbell.impactOccurred()
    }
}
