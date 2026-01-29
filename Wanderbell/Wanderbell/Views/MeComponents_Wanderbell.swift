import Foundation
import UIKit
import SnapKit

// MARK: - 用户信息卡片

/// 用户信息卡片
/// 功能：展示用户头像、名字、简介、设置和编辑按钮
/// 设计：渐变背景、大头像、艺术字体
class UserInfoCard_Wanderbell: UIView {
    
    // MARK: - UI组件
    
    private let containerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = .white
        view_wanderbell.layer.cornerRadius = 24
        view_wanderbell.layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        view_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 4)
        view_wanderbell.layer.shadowRadius = 16
        view_wanderbell.layer.shadowOpacity = 0.15
        return view_wanderbell
    }()
    
    /// 渐变背景
    private let gradientView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.layer.cornerRadius = 24
        view_wanderbell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view_wanderbell.clipsToBounds = true
        return view_wanderbell
    }()
    
    private var gradientLayer_Wanderbell: CAGradientLayer?
    
    /// 用户头像
    private let avatarView_Wanderbell: CurrentUserAvatarView_Wanderbell = {
        let avatar_wanderbell = CurrentUserAvatarView_Wanderbell()
        avatar_wanderbell.showEditButton_Wanderbell = true
        return avatar_wanderbell
    }()
    
    /// 用户名
    private let usernameLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.title2_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        label_wanderbell.textAlignment = .center
        return label_wanderbell
    }()
    
    /// 用户简介
    private let introLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        label_wanderbell.textAlignment = .center
        label_wanderbell.numberOfLines = 3  // 增加行数
        return label_wanderbell
    }()
    
    /// 设置按钮
    private let settingsButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .system)
        button_wanderbell.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        button_wanderbell.tintColor = .white
        button_wanderbell.backgroundColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
        button_wanderbell.layer.cornerRadius = 20
        return button_wanderbell
    }()
    
    /// 编辑信息按钮
    private let editButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .system)
        button_wanderbell.setTitle("Edit Profile", for: .normal)
        button_wanderbell.titleLabel?.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        button_wanderbell.setTitleColor(.white, for: .normal)
        button_wanderbell.backgroundColor = ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell
        button_wanderbell.layer.cornerRadius = 16
        return button_wanderbell
    }()
    
    // MARK: - 回调
    
    var onSettingsTapped_Wanderbell: (() -> Void)?
    var onEditTapped_Wanderbell: (() -> Void)?
    
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
        
        // 创建渐变图层
        if gradientLayer_Wanderbell == nil {
            let gradient_wanderbell = UIColor.createPrimaryGradientLayer_Wanderbell(frame_wanderbell: CGRect(x: 0, y: 0, width: bounds.width, height: 100))
            gradient_wanderbell.opacity = 0.3
            gradientLayer_Wanderbell = gradient_wanderbell
            gradientView_Wanderbell.layer.insertSublayer(gradient_wanderbell, at: 0)
        } else {
            gradientLayer_Wanderbell?.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 100)
        }
    }
    
    private func setupUI_Wanderbell() {
        addSubview(containerView_Wanderbell)
        containerView_Wanderbell.addSubview(gradientView_Wanderbell)
        containerView_Wanderbell.addSubview(settingsButton_Wanderbell)
        containerView_Wanderbell.addSubview(avatarView_Wanderbell)
        containerView_Wanderbell.addSubview(usernameLabel_Wanderbell)
        containerView_Wanderbell.addSubview(introLabel_Wanderbell)
        containerView_Wanderbell.addSubview(editButton_Wanderbell)
        
        containerView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gradientView_Wanderbell.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(100)
        }
        
        settingsButton_Wanderbell.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(16)
            make.width.height.equalTo(40)
        }
        
        avatarView_Wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(80)
        }
        
        usernameLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Wanderbell.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
        }
        
        introLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel_Wanderbell.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(16)
        }
        
        editButton_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(introLabel_Wanderbell.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(140)
            make.height.equalTo(36)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }
    }
    
    private func setupActions_Wanderbell() {
        settingsButton_Wanderbell.addTarget(self, action: #selector(settingsTapped_Wanderbell), for: .touchUpInside)
        editButton_Wanderbell.addTarget(self, action: #selector(editTapped_Wanderbell), for: .touchUpInside)
    }
    
    func configure_Wanderbell(user_wanderbell: LoginUserModel_Wanderbell) {
        usernameLabel_Wanderbell.text = user_wanderbell.userName_Wanderbell ?? "Wanderer"
        
        // 获取用户详细信息
        if let userId_wanderbell = user_wanderbell.userId_Wanderbell {
            let userInfo_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getUserById_Wanderbell(userId_wanderbell: userId_wanderbell)
            
            // 显示简介，如果没有则显示默认文本
            if let intro_wanderbell = userInfo_wanderbell.userIntroduce_Wanderbell, !intro_wanderbell.isEmpty {
                introLabel_Wanderbell.text = intro_wanderbell
                introLabel_Wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
            } else {
                introLabel_Wanderbell.text = "Nothing yet."
                introLabel_Wanderbell.textColor = ColorConfig_Wanderbell.textPlaceholder_Wanderbell
            }
        }
        
        // 头像自动加载
        avatarView_Wanderbell.loadCurrentUserAvatar_Wanderbell()
    }
    
    @objc private func settingsTapped_Wanderbell() {
        settingsButton_Wanderbell.animatePulse_Wanderbell()
        onSettingsTapped_Wanderbell?()
        
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .medium)
        generator_wanderbell.impactOccurred()
    }
    
    @objc private func editTapped_Wanderbell() {
        editButton_Wanderbell.animatePulse_Wanderbell()
        onEditTapped_Wanderbell?()
        
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .light)
        generator_wanderbell.impactOccurred()
    }
}

// MARK: - 用户统计卡片

/// 用户统计卡片
/// 功能：展示帖子数、关注数、喜欢数
class UserStatsCard_Wanderbell: UIView {
    
    private let containerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        view_wanderbell.layer.cornerRadius = 20
        view_wanderbell.layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        view_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 2)
        view_wanderbell.layer.shadowRadius = 8
        view_wanderbell.layer.shadowOpacity = 0.1
        return view_wanderbell
    }()
    
    private let stackView_Wanderbell: UIStackView = {
        let stack_wanderbell = UIStackView()
        stack_wanderbell.axis = .horizontal
        stack_wanderbell.distribution = .fillEqually
        return stack_wanderbell
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI_Wanderbell() {
        addSubview(containerView_Wanderbell)
        containerView_Wanderbell.addSubview(stackView_Wanderbell)
        
        containerView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView_Wanderbell.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview().inset(16)
        }
    }
    
    func configure_Wanderbell(user_wanderbell: LoginUserModel_Wanderbell) {
        stackView_Wanderbell.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let postsCount_wanderbell = user_wanderbell.userPosts_Wanderbell.count
        let emotionsCount_wanderbell = user_wanderbell.userEmotionRecords_Wanderbell.count
        let followingCount_wanderbell = user_wanderbell.userFollow_Wanderbell.count
        
        let postsItem_wanderbell = createStatItem_Wanderbell(
            icon_wanderbell: "doc.text.fill",
            count_wanderbell: postsCount_wanderbell,
            label_wanderbell: "Posts"
        )
        
        let emotionsItem_wanderbell = createStatItem_Wanderbell(
            icon_wanderbell: "heart.fill",
            count_wanderbell: emotionsCount_wanderbell,
            label_wanderbell: "Records"
        )
        
        let followingItem_wanderbell = createStatItem_Wanderbell(
            icon_wanderbell: "person.2.fill",
            count_wanderbell: followingCount_wanderbell,
            label_wanderbell: "Following"
        )
        
        stackView_Wanderbell.addArrangedSubview(postsItem_wanderbell)
        stackView_Wanderbell.addArrangedSubview(emotionsItem_wanderbell)
        stackView_Wanderbell.addArrangedSubview(followingItem_wanderbell)
    }
    
    private func createStatItem_Wanderbell(icon_wanderbell: String, count_wanderbell: Int, label_wanderbell: String) -> UIView {
        let container_wanderbell = UIView()
        
        let iconView_wanderbell = UIImageView()
        iconView_wanderbell.image = UIImage(systemName: icon_wanderbell)
        iconView_wanderbell.tintColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
        iconView_wanderbell.contentMode = .scaleAspectFit
        
        let countLabel_wanderbell = UILabel()
        countLabel_wanderbell.text = "\(count_wanderbell)"
        countLabel_wanderbell.font = FontConfig_Wanderbell.number_Wanderbell(size_wanderbell: 24)
        countLabel_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        countLabel_wanderbell.textAlignment = .center
        countLabel_wanderbell.adjustsFontSizeToFitWidth = true
        countLabel_wanderbell.minimumScaleFactor = 0.8
        
        let nameLabel_wanderbell = UILabel()
        nameLabel_wanderbell.text = label_wanderbell
        nameLabel_wanderbell.font = FontConfig_Wanderbell.footnote_Wanderbell()
        nameLabel_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        nameLabel_wanderbell.textAlignment = .center
        nameLabel_wanderbell.numberOfLines = 1
        
        container_wanderbell.addSubview(iconView_wanderbell)
        container_wanderbell.addSubview(countLabel_wanderbell)
        container_wanderbell.addSubview(nameLabel_wanderbell)
        
        iconView_wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(4)
            make.width.height.equalTo(24)
        }
        
        countLabel_wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconView_wanderbell.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(4)
        }
        
        nameLabel_wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(countLabel_wanderbell.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(4)
            make.bottom.lessThanOrEqualToSuperview().offset(-4)
        }
        
        return container_wanderbell
    }
}

// MARK: - 内容切换器

/// 内容切换器
/// 功能：切换显示帖子或情绪记录
class ContentSwitcher_Wanderbell: UIView {
    
    private let containerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        view_wanderbell.layer.cornerRadius = 22
        return view_wanderbell
    }()
    
    /// 滑块背景
    private let sliderBackground_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.layer.cornerRadius = 18
        view_wanderbell.layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        view_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 2)
        view_wanderbell.layer.shadowRadius = 4
        view_wanderbell.layer.shadowOpacity = 0.2
        return view_wanderbell
    }()
    
    private let postsButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .custom)  // 改为custom避免系统颜色
        button_wanderbell.setTitle("Posts", for: .normal)
        button_wanderbell.titleLabel?.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        button_wanderbell.setTitleColor(ColorConfig_Wanderbell.textSecondary_Wanderbell, for: .normal)
        button_wanderbell.setTitleColor(.white, for: .selected)
        button_wanderbell.backgroundColor = .clear  // 背景透明
        button_wanderbell.isSelected = true
        return button_wanderbell
    }()
    
    private let emotionsButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .custom)  // 改为custom避免系统颜色
        button_wanderbell.setTitle("Emotions", for: .normal)
        button_wanderbell.titleLabel?.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        button_wanderbell.setTitleColor(ColorConfig_Wanderbell.textSecondary_Wanderbell, for: .normal)
        button_wanderbell.setTitleColor(.white, for: .selected)
        button_wanderbell.backgroundColor = .clear  // 背景透明
        return button_wanderbell
    }()
    
    /// 当前选中状态（true=Posts, false=Emotions）
    private var isShowingPosts_Wanderbell: Bool = true
    
    var onSwitchChanged_Wanderbell: ((Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
        setupActions_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI_Wanderbell() {
        addSubview(containerView_Wanderbell)
        containerView_Wanderbell.addSubview(sliderBackground_Wanderbell)
        containerView_Wanderbell.addSubview(postsButton_Wanderbell)
        containerView_Wanderbell.addSubview(emotionsButton_Wanderbell)
        
        containerView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 滑块初始位置（左侧）
        sliderBackground_Wanderbell.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(4)
            make.width.equalTo(containerView_Wanderbell.snp.width).multipliedBy(0.5).offset(-4)
        }
        
        postsButton_Wanderbell.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(4)
            make.right.equalTo(containerView_Wanderbell.snp.centerX).offset(-2)
        }
        
        emotionsButton_Wanderbell.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview().inset(4)
            make.left.equalTo(containerView_Wanderbell.snp.centerX).offset(2)
        }
        
        // 初始化滑块颜色
        sliderBackground_Wanderbell.backgroundColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
    }
    
    private func setupActions_Wanderbell() {
        postsButton_Wanderbell.addTarget(self, action: #selector(postsButtonTapped_Wanderbell), for: .touchUpInside)
        emotionsButton_Wanderbell.addTarget(self, action: #selector(emotionsButtonTapped_Wanderbell), for: .touchUpInside)
    }
    
    @objc private func postsButtonTapped_Wanderbell() {
        guard !isShowingPosts_Wanderbell else { return }  // 避免重复点击
        
        isShowingPosts_Wanderbell = true
        postsButton_Wanderbell.isSelected = true
        emotionsButton_Wanderbell.isSelected = false
        
        animateSlider_Wanderbell(toLeft_wanderbell: true)
        onSwitchChanged_Wanderbell?(true)
        
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .light)
        generator_wanderbell.impactOccurred()
    }
    
    @objc private func emotionsButtonTapped_Wanderbell() {
        guard isShowingPosts_Wanderbell else { return }  // 避免重复点击
        
        isShowingPosts_Wanderbell = false
        postsButton_Wanderbell.isSelected = false
        emotionsButton_Wanderbell.isSelected = true
        
        animateSlider_Wanderbell(toLeft_wanderbell: false)
        onSwitchChanged_Wanderbell?(false)
        
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .light)
        generator_wanderbell.impactOccurred()
    }
    
    /// 滑块动画
    private func animateSlider_Wanderbell(toLeft_wanderbell: Bool) {
        // 更新约束
        sliderBackground_Wanderbell.snp.remakeConstraints { make in
            if toLeft_wanderbell {
                make.left.top.bottom.equalToSuperview().inset(4)
            } else {
                make.right.top.bottom.equalToSuperview().inset(4)
            }
            make.width.equalTo(containerView_Wanderbell.snp.width).multipliedBy(0.5).offset(-4)
        }
        
        // 更新滑块颜色
        let newColor_wanderbell = toLeft_wanderbell 
            ? ColorConfig_Wanderbell.primaryGradientStart_Wanderbell 
            : ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell
        
        // 弹性动画
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut],
            animations: {
                self.layoutIfNeeded()
                self.sliderBackground_Wanderbell.backgroundColor = newColor_wanderbell
            }
        )
    }
}

// MARK: - 我的帖子单元格

/// 我的帖子单元格
/// 功能：展示用户发布的帖子
class MyPostCell_Wanderbell: UIView {
    
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
    
    private let titleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.title3_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        label_wanderbell.numberOfLines = 3  // 增加行数
        return label_wanderbell
    }()
    
    private let contentLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        label_wanderbell.numberOfLines = 3  // 增加行数
        return label_wanderbell
    }()
    
    private let statsLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.caption_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPlaceholder_Wanderbell
        return label_wanderbell
    }()
    
    private let iconView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "doc.text.fill")
        imageView_wanderbell.tintColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI_Wanderbell() {
        addSubview(containerView_Wanderbell)
        containerView_Wanderbell.addSubview(iconView_Wanderbell)
        containerView_Wanderbell.addSubview(titleLabel_Wanderbell)
        containerView_Wanderbell.addSubview(contentLabel_Wanderbell)
        containerView_Wanderbell.addSubview(statsLabel_Wanderbell)
        
        containerView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(110)
        }
        
        iconView_Wanderbell.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(16)
            make.width.height.equalTo(24)
        }
        
        titleLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(iconView_Wanderbell.snp.right).offset(12)
            make.top.equalTo(iconView_Wanderbell)
            make.right.equalToSuperview().offset(-16)
        }
        
        contentLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(titleLabel_Wanderbell)
            make.top.equalTo(titleLabel_Wanderbell.snp.bottom).offset(6)
            make.right.equalToSuperview().offset(-16)
        }
        
        statsLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(titleLabel_Wanderbell)
            make.top.equalTo(contentLabel_Wanderbell.snp.bottom).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    func configure_Wanderbell(post_wanderbell: TitleModel_Wanderbell) {
        titleLabel_Wanderbell.text = post_wanderbell.title_Wanderbell
        contentLabel_Wanderbell.text = post_wanderbell.titleContent_Wanderbell
        statsLabel_Wanderbell.text = "❤️ \(post_wanderbell.likes_Wanderbell)  💬 \(post_wanderbell.reviews_Wanderbell.count)"
    }
}
