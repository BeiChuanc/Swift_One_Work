import Foundation
import UIKit
import SnapKit
import CHTCollectionViewWaterfallLayout

// MARK: - 发现页搜索栏

/// 发现页搜索栏
/// 功能：搜索情绪记录
class DiscoverSearchBar_Wanderbell: UIView {
    
    private let searchField_Wanderbell: UITextField = {
        let field_wanderbell = UITextField()
        field_wanderbell.placeholder = "Search emotions..."
        field_wanderbell.font = UIFont.systemFont(ofSize: 16)
        field_wanderbell.backgroundColor = .white
        field_wanderbell.layer.cornerRadius = 20
        field_wanderbell.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 40))
        field_wanderbell.leftViewMode = .always
        field_wanderbell.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 40))
        field_wanderbell.rightViewMode = .always
        return field_wanderbell
    }()
    
    var onSearchTextChanged_Wanderbell: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI_Wanderbell() {
        addSubview(searchField_Wanderbell)
        
        searchField_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(44)
        }
        
        searchField_Wanderbell.addTarget(self, action: #selector(textFieldChanged_Wanderbell), for: .editingChanged)
    }
    
    @objc private func textFieldChanged_Wanderbell() {
        onSearchTextChanged_Wanderbell?(searchField_Wanderbell.text ?? "")
    }
}

// MARK: - 情绪筛选栏

/// 情绪筛选栏
/// 功能：横向滚动的情绪标签筛选
class EmotionFilterBar_Wanderbell: UIView {
    
    private let scrollView_Wanderbell: UIScrollView = {
        let scrollView_wanderbell = UIScrollView()
        scrollView_wanderbell.showsHorizontalScrollIndicator = false
        return scrollView_wanderbell
    }()
    
    private let stackView_Wanderbell: UIStackView = {
        let stack_wanderbell = UIStackView()
        stack_wanderbell.axis = .horizontal
        stack_wanderbell.spacing = 12
        return stack_wanderbell
    }()
    
    private var selectedEmotions_Wanderbell: Set<EmotionType_Wanderbell> = []
    
    var onFilterChanged_Wanderbell: (([EmotionType_Wanderbell]) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI_Wanderbell() {
        addSubview(scrollView_Wanderbell)
        scrollView_Wanderbell.addSubview(stackView_Wanderbell)
        
        scrollView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        // 添加所有情绪标签
        let emotionTypes_wanderbell = EmotionType_Wanderbell.getAllBasicTypes_Wanderbell()
        for emotionType_wanderbell in emotionTypes_wanderbell {
            let tag_wanderbell = createEmotionTag_Wanderbell(emotionType_wanderbell: emotionType_wanderbell)
            stackView_Wanderbell.addArrangedSubview(tag_wanderbell)
        }
    }
    
    private func createEmotionTag_Wanderbell(emotionType_wanderbell: EmotionType_Wanderbell) -> UIButton {
        let button_wanderbell = UIButton(type: .custom)
        button_wanderbell.setTitle(emotionType_wanderbell.rawValue, for: .normal)
        button_wanderbell.setTitleColor(ColorConfig_Wanderbell.textSecondary_Wanderbell, for: .normal)
        button_wanderbell.setTitleColor(.white, for: .selected)
        button_wanderbell.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button_wanderbell.backgroundColor = ColorConfig_Wanderbell.backgroundSecondary_Wanderbell
        button_wanderbell.layer.cornerRadius = 16
        button_wanderbell.layer.borderWidth = 1
        button_wanderbell.layer.borderColor = ColorConfig_Wanderbell.border_Wanderbell.cgColor
        button_wanderbell.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        button_wanderbell.tag = emotionType_wanderbell.hashValue
        button_wanderbell.addTarget(self, action: #selector(tagTapped_Wanderbell(_:)), for: .touchUpInside)
        
        return button_wanderbell
    }
    
    @objc private func tagTapped_Wanderbell(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        let emotionTypes_wanderbell = EmotionType_Wanderbell.getAllBasicTypes_Wanderbell()
        for emotionType_wanderbell in emotionTypes_wanderbell {
            if sender.tag == emotionType_wanderbell.hashValue {
                if sender.isSelected {
                    selectedEmotions_Wanderbell.insert(emotionType_wanderbell)
                    sender.backgroundColor = emotionType_wanderbell.getColor_Wanderbell()
                } else {
                    selectedEmotions_Wanderbell.remove(emotionType_wanderbell)
                    sender.backgroundColor = ColorConfig_Wanderbell.backgroundSecondary_Wanderbell
                }
                break
            }
        }
        
        onFilterChanged_Wanderbell?(Array(selectedEmotions_Wanderbell))
    }
}

// MARK: - 情绪分享卡片

/// 情绪分享卡片（增强版）
/// 功能：瀑布流中的单个情绪记录卡片，展示标题、内容、媒体
/// 设计：圆角卡片、媒体预览、情绪标识、完整信息
class EmotionShareCard_Wanderbell: UICollectionViewCell {
    
    static let reuseIdentifier_Wanderbell = "EmotionShareCard_Wanderbell"
    
    // MARK: - 属性
    
    /// 当前帖子模型
    private var currentPost_Wanderbell: TitleModel_Wanderbell?
    
    /// 点赞按钮点击回调
    var onLikeButtonTapped_Wanderbell: ((TitleModel_Wanderbell) -> Void)?
    
    /// 头像点击回调
    var onAvatarTapped_Wanderbell: ((TitleModel_Wanderbell) -> Void)?
    
    // MARK: - UI组件
    
    private let containerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = .white
        view_wanderbell.layer.cornerRadius = 16
        view_wanderbell.layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        view_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 2)
        view_wanderbell.layer.shadowRadius = 8
        view_wanderbell.layer.shadowOpacity = 0.12
        return view_wanderbell
    }()
    
    /// 用户信息容器
    private let userInfoView_Wanderbell = UIView()
    
    /// 用户头像（使用通用组件）
    private let userAvatarView_Wanderbell = UserAvatarView_Wanderbell()
    
    private let usernameLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return label_wanderbell
    }()
    
    /// 媒体展示视图
    private let mediaView_Wanderbell = MediaDisplayView_Wanderbell()
    
    /// 情绪标签（小图标+名称）
    private let emotionTagView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.layer.cornerRadius = 12
        return view_wanderbell
    }()
    
    private let emotionIconImageView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    private let emotionNameLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return label_wanderbell
    }()
    
    /// 帖子标题
    private let titleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.title3_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        label_wanderbell.numberOfLines = 2
        return label_wanderbell
    }()
    
    /// 帖子内容
    private let contentLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        label_wanderbell.numberOfLines = 0
        return label_wanderbell
    }()
    
    /// 底部工具栏
    private let toolbarView_Wanderbell = UIView()
    
    private let likeButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .custom)
        let config_wanderbell = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        button_wanderbell.setImage(UIImage(systemName: "heart", withConfiguration: config_wanderbell), for: .normal)
        button_wanderbell.setImage(UIImage(systemName: "heart.fill", withConfiguration: config_wanderbell), for: .selected)
        button_wanderbell.tintColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        return button_wanderbell
    }()
    
    private let commentButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .custom)
        let config_wanderbell = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        button_wanderbell.setImage(UIImage(systemName: "bubble.left", withConfiguration: config_wanderbell), for: .normal)
        button_wanderbell.tintColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        button_wanderbell.titleLabel?.font = FontConfig_Wanderbell.caption_Wanderbell()
        return button_wanderbell
    }()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Wanderbell() {
        contentView.addSubview(containerView_Wanderbell)
        
        emotionTagView_Wanderbell.addSubview(emotionIconImageView_Wanderbell)
        emotionTagView_Wanderbell.addSubview(emotionNameLabel_Wanderbell)
        
        userInfoView_Wanderbell.addSubview(userAvatarView_Wanderbell)
        userInfoView_Wanderbell.addSubview(usernameLabel_Wanderbell)
        
        toolbarView_Wanderbell.addSubview(likeButton_Wanderbell)
        toolbarView_Wanderbell.addSubview(commentButton_Wanderbell)
        
        containerView_Wanderbell.addSubview(userInfoView_Wanderbell)
        containerView_Wanderbell.addSubview(mediaView_Wanderbell)
        containerView_Wanderbell.addSubview(emotionTagView_Wanderbell)
        containerView_Wanderbell.addSubview(titleLabel_Wanderbell)
        containerView_Wanderbell.addSubview(contentLabel_Wanderbell)
        containerView_Wanderbell.addSubview(toolbarView_Wanderbell)
        
        containerView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        
        // 用户信息区域
        userInfoView_Wanderbell.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(12)
            make.height.equalTo(32)
        }
        
        userAvatarView_Wanderbell.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        usernameLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(userAvatarView_Wanderbell.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        // 媒体视图
        mediaView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(userInfoView_Wanderbell.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(180)
        }
        
        // 情绪标签
        emotionTagView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Wanderbell.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(12)
            make.height.equalTo(24)
        }
        
        emotionIconImageView_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        
        emotionNameLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(emotionIconImageView_Wanderbell.snp.right).offset(4)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
        }
        
        // 标题
        titleLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(emotionTagView_Wanderbell.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(12)
        }
        
        // 内容
        contentLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Wanderbell.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(12)
        }
        
        // 工具栏
        toolbarView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Wanderbell.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(32)
        }
        
        likeButton_Wanderbell.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        commentButton_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(likeButton_Wanderbell.snp.right).offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        // 添加点击事件
        likeButton_Wanderbell.addTarget(self, action: #selector(likeButtonTapped_Wanderbell), for: .touchUpInside)
        
        // 添加头像点击手势
        let avatarTapGesture_wanderbell = UITapGestureRecognizer(target: self, action: #selector(avatarTapped_Wanderbell))
        userAvatarView_Wanderbell.addGestureRecognizer(avatarTapGesture_wanderbell)
        userAvatarView_Wanderbell.isUserInteractionEnabled = true
    }
    
    // MARK: - 配置方法
    
    /// 配置卡片 - 使用帖子数据
    /// 功能：用帖子模型配置卡片
    /// 参数：
    /// - post_wanderbell: 帖子模型
    func configure_Wanderbell(with post_wanderbell: TitleModel_Wanderbell) {
        // 保存当前帖子
        currentPost_Wanderbell = post_wanderbell
        
        // 配置用户信息
        usernameLabel_Wanderbell.text = post_wanderbell.titleUserName_Wanderbell
        
        // 配置用户头像（使用通用组件，自动判断是否是当前用户）
        userAvatarView_Wanderbell.configure_Wanderbell(userId_wanderbell: post_wanderbell.titleUserId_Wanderbell)
        
        // 根据帖子内容推测情绪类型
        let emotionType_wanderbell = inferEmotionType_Wanderbell(from: post_wanderbell)
        
        // 配置媒体视图
        let mediaPath_wanderbell = post_wanderbell.titleMeidas_Wanderbell.first ?? ""
        mediaView_Wanderbell.configure_Wanderbell(mediaPath_wanderbell: mediaPath_wanderbell, isVideo_wanderbell: false)
        
        // 配置情绪标签
        emotionTagView_Wanderbell.backgroundColor = emotionType_wanderbell.getColor_Wanderbell().withAlphaComponent(0.15)
        emotionIconImageView_Wanderbell.image = UIImage(systemName: emotionType_wanderbell.getIcon_Wanderbell())
        emotionIconImageView_Wanderbell.tintColor = emotionType_wanderbell.getColor_Wanderbell()
        emotionNameLabel_Wanderbell.text = emotionType_wanderbell.rawValue
        emotionNameLabel_Wanderbell.textColor = emotionType_wanderbell.getColor_Wanderbell()
        
        // 配置标题
        titleLabel_Wanderbell.text = post_wanderbell.title_Wanderbell
        
        // 配置内容
        contentLabel_Wanderbell.text = post_wanderbell.titleContent_Wanderbell
        
        // 配置点赞按钮状态（只显示图标，不显示数量）
        updateLikeButtonState_Wanderbell()
        
        // 配置评论数
        commentButton_Wanderbell.setTitle(" \(post_wanderbell.reviews_Wanderbell.count)", for: .normal)
        commentButton_Wanderbell.setTitleColor(ColorConfig_Wanderbell.textSecondary_Wanderbell, for: .normal)
    }
    
    /// 更新点赞按钮状态
    /// 功能：根据当前用户是否点赞更新按钮样式
    private func updateLikeButtonState_Wanderbell() {
        guard let post_wanderbell = currentPost_Wanderbell else { return }
        
        let isLiked_wanderbell = TitleViewModel_Wanderbell.shared_Wanderbell.isLikedPost_Wanderbell(
            post_wanderbell: post_wanderbell
        )
        
        likeButton_Wanderbell.isSelected = isLiked_wanderbell
        likeButton_Wanderbell.tintColor = isLiked_wanderbell
            ? UIColor(hexstring_Wanderbell: "#FC8181")
            : ColorConfig_Wanderbell.textSecondary_Wanderbell
    }
    
    // MARK: - 事件处理
    
    /// 点赞按钮点击
    @objc private func likeButtonTapped_Wanderbell() {
        guard let post_wanderbell = currentPost_Wanderbell else { return }
        
        // 按钮动画
        likeButton_Wanderbell.animatePulse_Wanderbell()
        
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .medium)
        generator_wanderbell.impactOccurred()
        
        // 触发回调
        onLikeButtonTapped_Wanderbell?(post_wanderbell)
        
        // 更新按钮状态
        updateLikeButtonState_Wanderbell()
    }
    
    /// 头像点击
    @objc private func avatarTapped_Wanderbell() {
        guard let post_wanderbell = currentPost_Wanderbell else { return }
        
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .light)
        generator_wanderbell.impactOccurred()
        
        // 触发回调
        onAvatarTapped_Wanderbell?(post_wanderbell)
    }
    
    /// 推测情绪类型
    /// 功能：根据帖子标题和内容推测情绪类型
    /// 参数：
    /// - post_wanderbell: 帖子模型
    /// 返回值：EmotionType_Wanderbell - 推测的情绪类型
    private func inferEmotionType_Wanderbell(from post_wanderbell: TitleModel_Wanderbell) -> EmotionType_Wanderbell {
        let title_wanderbell = post_wanderbell.title_Wanderbell.lowercased()
        let content_wanderbell = post_wanderbell.titleContent_Wanderbell.lowercased()
        let text_wanderbell = title_wanderbell + " " + content_wanderbell
        
        // 关键词匹配
        if text_wanderbell.contains("sunshine") || text_wanderbell.contains("joy") || text_wanderbell.contains("smiling") || text_wanderbell.contains("happy") {
            return .happy_wanderbell
        }
        if text_wanderbell.contains("calm") || text_wanderbell.contains("peace") || text_wanderbell.contains("still") {
            return .calm_wanderbell
        }
        if text_wanderbell.contains("sad") || text_wanderbell.contains("heavy") || text_wanderbell.contains("overwhelming") {
            return .sad_wanderbell
        }
        if text_wanderbell.contains("anxiety") || text_wanderbell.contains("worry") || text_wanderbell.contains("racing") {
            return .anxious_wanderbell
        }
        if text_wanderbell.contains("anger") || text_wanderbell.contains("fire") || text_wanderbell.contains("frustration") {
            return .angry_wanderbell
        }
        if text_wanderbell.contains("excitement") || text_wanderbell.contains("energy") || text_wanderbell.contains("possible") {
            return .excited_wanderbell
        }
        if text_wanderbell.contains("tired") || text_wanderbell.contains("exhausted") || text_wanderbell.contains("rest") {
            return .tired_wanderbell
        }
        
        // 默认返回平静
        return .calm_wanderbell
    }
}
