import UIKit
import SnapKit

// MARK: - 帖子卡片单元格

/// 帖子卡片单元格
/// 功能：展示社区帖子封面媒体（图片/视频）、分类标签、标题、作者头像/姓名及点赞数
/// 支持两种样式：homeStyle（大卡片，首页竖排）和 discoverStyle（小卡片，双列瀑布流）
/// 设计：白色圆角卡片、柔和阴影、点赞按钮带脉冲动画，触摸有弹性缩放反馈
/// 封面媒体使用 MediaDisplayView_Base_one，作者头像使用 UserAvatarView_Base_one
class PostCardCell_Base_one: UICollectionViewCell {
    
    // MARK: - 样式枚举
    
    /// 帖子卡片展示样式
    enum CardStyle_Base_one {
        case homeStyle_base_one
        case discoverStyle_base_one
    }
    
    // MARK: - 事件回调
    
    var onLikeTapped_Base_one: (() -> Void)?
    var onCardTapped_Base_one: (() -> Void)?
    /// 举报/删除按钮点击回调，携带当前帖子模型
    var onMoreTapped_Base_one: ((TitleModel_Base_one) -> Void)?
    /// 作者头像点击回调，携带作者 userId（供外部判断是否跳转用户中心）
    var onAvatarTapped_Base_one: ((Int) -> Void)?
    
    // MARK: - UI 组件
    
    /// 卡片主容器
    private let cardView_Base_one: UIView = {
        let v_base_one = UIView()
        v_base_one.backgroundColor = ColorConfig_Base_one.cardBackground_Base_one
        v_base_one.layer.cornerRadius = 16
        v_base_one.clipsToBounds = false
        return v_base_one
    }()
    
    /// 封面媒体视图（使用 MediaDisplayView_Base_one 展示图片/视频）
    private let coverMedia_Base_one: MediaDisplayView_Base_one = {
        let v = MediaDisplayView_Base_one()
        v.layer.cornerRadius = 12
        v.clipsToBounds = true
        return v
    }()

    /// 右上角举报/删除按钮（自己的帖子显示 trash，他人帖子显示 ellipsis）
    private let moreButton_Base_one: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        btn.layer.cornerRadius = 13
        btn.tintColor = .white
        return btn
    }()

    /// 底部作者区分割线
    private let authorDivider_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.divider_Base_one
        return v
    }()
    
    /// 分类标签徽章（白底+分类色文字）
    private let categoryBadge_Base_one: UILabel = {
        let lb_base_one = UILabel()
        lb_base_one.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lb_base_one.textColor = ColorConfig_Base_one.tidyMint_Base_one
        lb_base_one.textAlignment = .center
        lb_base_one.layer.cornerRadius = 8
        lb_base_one.clipsToBounds = true
        lb_base_one.backgroundColor = UIColor.white.withAlphaComponent(0.88)
        return lb_base_one
    }()
    
    /// 帖子标题
    private let titleLabel_Base_one: UILabel = {
        let lb_base_one = UILabel()
        lb_base_one.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lb_base_one.textColor = ColorConfig_Base_one.textPrimary_Base_one
        lb_base_one.numberOfLines = 2
        lb_base_one.lineBreakMode = .byTruncatingTail
        return lb_base_one
    }()
    
    /// 帖子简介（仅 homeStyle 显示）
    private let contentLabel_Base_one: UILabel = {
        let lb_base_one = UILabel()
        lb_base_one.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb_base_one.textColor = ColorConfig_Base_one.textSecondary_Base_one
        lb_base_one.numberOfLines = 2
        lb_base_one.lineBreakMode = .byTruncatingTail
        return lb_base_one
    }()
    
    /// 作者头像（使用 UserAvatarView_Base_one 展示真实用户头像）
    private let authorAvatarView_Base_one: UserAvatarView_Base_one = {
        let v = UserAvatarView_Base_one()
        return v
    }()
    
    /// 作者名
    private let authorLabel_Base_one: UILabel = {
        let lb_base_one = UILabel()
        lb_base_one.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lb_base_one.textColor = ColorConfig_Base_one.textSecondary_Base_one
        return lb_base_one
    }()
    
    /// 点赞按钮
    private let likeButton_Base_one: UIButton = {
        let btn_base_one = UIButton(type: .custom)
        btn_base_one.setImage(UIImage(systemName: "heart"), for: .normal)
        btn_base_one.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        btn_base_one.tintColor = ColorConfig_Base_one.tidyWarm_Base_one
        return btn_base_one
    }()
    
    /// 点赞数标签
    private let likeCountLabel_Base_one: UILabel = {
        let lb_base_one = UILabel()
        lb_base_one.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lb_base_one.textColor = ColorConfig_Base_one.textSecondary_Base_one
        return lb_base_one
    }()
    
    // MARK: - 属性
    
    private var currentPost_Base_one: TitleModel_Base_one?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Base_one()
        setupGestures_Base_one()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Base_one()
        setupGestures_Base_one()
    }
    
    // MARK: - UI 搭建
    
    private func setupUI_Base_one() {
        backgroundColor = .clear
        
        contentView.layer.shadowColor = ColorConfig_Base_one.shadowColor_Base_one.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowRadius = 12
        contentView.layer.shadowOpacity = 1
        contentView.layer.masksToBounds = false
        
        contentView.addSubview(cardView_Base_one)
        cardView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 封面媒体（顶部，圆角与卡片顶部匹配）
        cardView_Base_one.addSubview(coverMedia_Base_one)
        // 分类徽章叠加在封面左上角，举报/删除按钮叠加在右上角
        cardView_Base_one.addSubview(categoryBadge_Base_one)
        cardView_Base_one.addSubview(moreButton_Base_one)
        moreButton_Base_one.addTarget(self, action: #selector(moreButtonTapped_Base_one), for: .touchUpInside)
        // 标题、简介、分割线
        cardView_Base_one.addSubview(titleLabel_Base_one)
        cardView_Base_one.addSubview(contentLabel_Base_one)
        cardView_Base_one.addSubview(authorDivider_Base_one)
        // 作者行
        cardView_Base_one.addSubview(authorAvatarView_Base_one)
        cardView_Base_one.addSubview(authorLabel_Base_one)
        cardView_Base_one.addSubview(likeButton_Base_one)
        cardView_Base_one.addSubview(likeCountLabel_Base_one)
        
        likeButton_Base_one.addTarget(self, action: #selector(likeTapped_Base_one), for: .touchUpInside)
        
        applyHomeStyleLayout_Base_one()
    }
    
    private func setupGestures_Base_one() {
        let tap_base_one = UITapGestureRecognizer(target: self, action: #selector(cardTapped_Base_one))
        contentView.addGestureRecognizer(tap_base_one)
        /// 头像独立点击手势（阻止事件冒泡到卡片点击）
        let avatarTap_base_one = UITapGestureRecognizer(target: self, action: #selector(avatarTapped_Base_one))
        authorAvatarView_Base_one.isUserInteractionEnabled = true
        authorAvatarView_Base_one.addGestureRecognizer(avatarTap_base_one)
    }
    
    // MARK: - 布局方案
    
    /// 首页大卡片布局
    private func applyHomeStyleLayout_Base_one() {
        coverMedia_Base_one.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(140)
        }
        categoryBadge_Base_one.snp.remakeConstraints { make in
            make.top.equalTo(coverMedia_Base_one).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(20)
        }
        moreButton_Base_one.snp.remakeConstraints { make in
            make.top.equalTo(coverMedia_Base_one).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(26)
        }
        titleLabel_Base_one.snp.remakeConstraints { make in
            make.top.equalTo(coverMedia_Base_one.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        contentLabel_Base_one.snp.remakeConstraints { make in
            make.top.equalTo(titleLabel_Base_one.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        contentLabel_Base_one.isHidden = false
        authorDivider_Base_one.snp.remakeConstraints { make in
            make.top.equalTo(contentLabel_Base_one.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(0.5)
        }
        authorDivider_Base_one.isHidden = false
        authorAvatarView_Base_one.snp.remakeConstraints { make in
            make.top.equalTo(authorDivider_Base_one.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(20)
            make.bottom.equalToSuperview().offset(-12)
        }
        authorLabel_Base_one.snp.remakeConstraints { make in
            make.centerY.equalTo(authorAvatarView_Base_one)
            make.leading.equalTo(authorAvatarView_Base_one.snp.trailing).offset(6)
        }
        likeCountLabel_Base_one.snp.remakeConstraints { make in
            make.centerY.equalTo(authorAvatarView_Base_one)
            make.trailing.equalToSuperview().offset(-12)
        }
        likeButton_Base_one.snp.remakeConstraints { make in
            make.centerY.equalTo(likeCountLabel_Base_one)
            make.trailing.equalTo(likeCountLabel_Base_one.snp.leading).offset(-4)
            make.width.height.equalTo(20)
        }
    }
    
    /// 发现页小卡片布局
    private func applyDiscoverStyleLayout_Base_one() {
        coverMedia_Base_one.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(110)
        }
        categoryBadge_Base_one.snp.remakeConstraints { make in
            make.top.equalTo(coverMedia_Base_one).offset(8)
            make.leading.equalToSuperview().offset(8)
            make.height.equalTo(18)
        }
        moreButton_Base_one.snp.remakeConstraints { make in
            make.top.equalTo(coverMedia_Base_one).offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.width.height.equalTo(24)
        }
        titleLabel_Base_one.snp.remakeConstraints { make in
            make.top.equalTo(coverMedia_Base_one.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        contentLabel_Base_one.isHidden = true
        contentLabel_Base_one.snp.remakeConstraints { make in
            make.top.equalTo(titleLabel_Base_one.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(0)
        }
        authorDivider_Base_one.isHidden = true
        authorDivider_Base_one.snp.remakeConstraints { make in
            make.height.equalTo(0)
            make.top.equalTo(titleLabel_Base_one.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        authorAvatarView_Base_one.snp.remakeConstraints { make in
            make.top.equalTo(titleLabel_Base_one.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(18)
            make.bottom.equalToSuperview().offset(-10)
        }
        authorLabel_Base_one.snp.remakeConstraints { make in
            make.centerY.equalTo(authorAvatarView_Base_one)
            make.leading.equalTo(authorAvatarView_Base_one.snp.trailing).offset(5)
        }
        likeCountLabel_Base_one.snp.remakeConstraints { make in
            make.centerY.equalTo(authorAvatarView_Base_one)
            make.trailing.equalToSuperview().offset(-10)
        }
        likeButton_Base_one.snp.remakeConstraints { make in
            make.centerY.equalTo(likeCountLabel_Base_one)
            make.trailing.equalTo(likeCountLabel_Base_one.snp.leading).offset(-3)
            make.width.height.equalTo(16)
        }
    }
    
    // MARK: - 数据绑定
    
    /// 配置帖子卡片
    /// - Parameters:
    ///   - post_base_one: 帖子模型
    ///   - style_base_one: 展示样式（默认 homeStyle）
    func configure_Base_one(post_base_one: TitleModel_Base_one, style_base_one: CardStyle_Base_one = .homeStyle_base_one) {
        currentPost_Base_one = post_base_one
        
        switch style_base_one {
        case .homeStyle_base_one:    applyHomeStyleLayout_Base_one()
        case .discoverStyle_base_one: applyDiscoverStyleLayout_Base_one()
        }
        
        titleLabel_Base_one.text = post_base_one.title_Base_one
        contentLabel_Base_one.text = post_base_one.titleContent_Base_one
        authorLabel_Base_one.text = post_base_one.titleUserName_Base_one
        likeCountLabel_Base_one.text = "\(post_base_one.likes_Base_one)"
        
        // 分类徽章
        let category_base_one = post_base_one.titleCategory_Base_one
        let categoryColor_base_one = ColorConfig_Base_one.colorForCategory_Base_one(category_base_one)
        categoryBadge_Base_one.text = "  \(categoryDisplayName_Base_one(category_base_one))  "
        categoryBadge_Base_one.backgroundColor = UIColor.white.withAlphaComponent(0.88)
        categoryBadge_Base_one.textColor = categoryColor_base_one

        // 分类色动态阴影
        contentView.layer.shadowColor = categoryColor_base_one.withAlphaComponent(0.22).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 5)
        contentView.layer.shadowRadius = 14

        // 使用 MediaDisplayView_Base_one 展示封面媒体（取第一个媒体路径）
        let mediaPath_base_one = post_base_one.titleMeidas_Base_one.first
        coverMedia_Base_one.configure_Base_one(mediaPath_Base_one: mediaPath_base_one, isVideo_Base_one: false)
        
        // 使用 UserAvatarView_Base_one 展示作者头像
        authorAvatarView_Base_one.configure_Base_one(userId_Base_one: post_base_one.titleUserId_Base_one)

        // 根据是否是当前用户的帖子，切换按钮图标（trash = 删除，ellipsis = 举报）
        let isMyPost_base_one = UserViewModel_Base_one.shared_Base_one.isCurrentUser_Base_one(
            userId_base_one: post_base_one.titleUserId_Base_one
        )
        let iconName_base_one = isMyPost_base_one ? "trash" : "ellipsis"
        let iconSize_base_one: CGFloat = style_base_one == .homeStyle_base_one ? 11 : 10
        let iconCfg_base_one = UIImage.SymbolConfiguration(pointSize: iconSize_base_one, weight: .semibold)
        moreButton_Base_one.setImage(UIImage(systemName: iconName_base_one, withConfiguration: iconCfg_base_one), for: .normal)

        // 点赞状态
        let isLiked_base_one = TitleViewModel_Base_one.shared_Base_one.isLikedPost_Base_one(post_base_one: post_base_one)
        likeButton_Base_one.isSelected = isLiked_base_one
        likeCountLabel_Base_one.textColor = isLiked_base_one
            ? ColorConfig_Base_one.tidyWarm_Base_one
            : ColorConfig_Base_one.textSecondary_Base_one
    }
    
    // MARK: - 事件处理

    /// 举报/删除按钮点击（带弹性缩放动画）
    @objc private func moreButtonTapped_Base_one() {
        guard let post_base_one = currentPost_Base_one else { return }
        UIView.animate(withDuration: 0.10, animations: {
            self.moreButton_Base_one.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(withDuration: 0.10) {
                self.moreButton_Base_one.transform = .identity
            }
        }
        onMoreTapped_Base_one?(post_base_one)
    }
    
    @objc private func likeTapped_Base_one() {
        likeButton_Base_one.animatePulse_Base_one()
        onLikeTapped_Base_one?()
        
        let isSelected_base_one = likeButton_Base_one.isSelected
        likeButton_Base_one.isSelected = !isSelected_base_one
        if let count_base_one = Int(likeCountLabel_Base_one.text ?? "0") {
            likeCountLabel_Base_one.text = "\(likeButton_Base_one.isSelected ? count_base_one + 1 : max(0, count_base_one - 1))"
        }
        likeCountLabel_Base_one.textColor = likeButton_Base_one.isSelected
            ? ColorConfig_Base_one.tidyWarm_Base_one
            : ColorConfig_Base_one.textSecondary_Base_one
    }
    
    @objc private func cardTapped_Base_one() {
        onCardTapped_Base_one?()
    }

    /// 点击作者头像回调
    @objc private func avatarTapped_Base_one() {
        guard let userId_base_one = currentPost_Base_one?.titleUserId_Base_one else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onAvatarTapped_Base_one?(userId_base_one)
    }
    
    // MARK: - 触摸反馈
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animatePressDown_Base_one()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animatePressUp_Base_one()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animatePressUp_Base_one()
    }
    
    // MARK: - 工具方法
    
    private func categoryDisplayName_Base_one(_ id_base_one: String) -> String {
        switch id_base_one {
        case "living_room": return "Living"
        case "bedroom":     return "Bedroom"
        case "kitchen":     return "Kitchen"
        case "bathroom":    return "Bath"
        case "study":       return "Study"
        case "storage":     return "Storage"
        case "garden":      return "Garden"
        default:            return "Home"
        }
    }
}
