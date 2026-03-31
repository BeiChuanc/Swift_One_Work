import UIKit
import SnapKit

// MARK: - 帖子卡片 Cell

/// 帖子卡片 TableViewCell
/// 核心作用：在首页帖子流中展示单条帖子，包含作者信息、标题、内容摘要、互动操作栏。
/// 设计思路：卡片式布局，白底圆角阴影，渐变点赞按钮，动画反馈。
/// 关键属性：onLikeTapped_Flick（点赞回调）、onAvatarTapped_Flick（头像回调）
/// 头像点击原理：使用透明 UIButton 覆盖头像区域。
/// UITableViewCell 内的 UIControl（UIButton）被点击时，UIKit 不会触发行选中，
/// 因此 didSelectRowAt（跳转详情）与头像导航不再冲突，无需任何额外拦截。
class PostCardCell_Flick: UITableViewCell {
    
    // MARK: - 复用标识
    
    static let reuseId_Flick = "PostCardCell_Flick"
    
    // MARK: - 回调
    
    /// 点赞按钮点击回调
    var onLikeTapped_Flick: (() -> Void)?
    
    /// 头像点击回调（仅非当前登录用户帖子有效）
    var onAvatarTapped_Flick: (() -> Void)?
    
    // MARK: - 头像渐变圆环（非本人帖子时显示，暗示可点击进入用户中心）
    
    /// 渐变圆环容器
    private let avatarRingView_Flick: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.isHidden = true
        return v
    }()
    /// 渐变圆环 CAGradientLayer（懒初始化，bounds 有效时创建）
    private var avatarRingLayer_Flick: CAGradientLayer?
    
    // MARK: - UI 组件
    
    /// 卡片容器（圆角阴影白底）
    private let cardView_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Flick.cardBackground_Flick
        v.layer.cornerRadius = 16
        v.layer.shadowColor = ColorConfig_Flick.shadowColor_Flick.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 12
        v.layer.shadowOpacity = 1
        v.layer.masksToBounds = false
        return v
    }()
    
    /// 用户头像
    private let avatarView_Flick = UserAvatarView_Flick()
    
    /// 透明头像点击按钮（UIControl 被点击时 UITableView 不触发行选中，彻底避免冲突）
    private let avatarTapBtn_Flick: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .clear
        return btn
    }()
    
    /// 用户名标签（左上角紧凑，字号偏小）
    private let userNameLabel_Flick: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        l.textColor = ColorConfig_Flick.textSecondary_Flick
        return l
    }()
    
    /// 时间/话题装饰标签（右上角对齐，与用户名同行）
    private let timeLabel_Flick: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        l.textColor = ColorConfig_Flick.textPlaceholder_Flick
        return l
    }()
    
    /// 帖子标题标签
    private let titleLabel_Flick: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        l.textColor = ColorConfig_Flick.textPrimary_Flick
        l.numberOfLines = 2
        return l
    }()
    
    /// 帖子内容摘要
    private let contentLabel_Flick: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor = ColorConfig_Flick.textSecondary_Flick
        l.numberOfLines = 3
        return l
    }()
    
    /// 分割线
    private let dividerView_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Flick.divider_Flick
        return v
    }()
    
    /// 点赞按钮
    private let likeButton_Flick: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(systemName: "heart"), for: .normal)
        b.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        b.tintColor = ColorConfig_Flick.textPlaceholder_Flick
        b.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        b.setTitleColor(ColorConfig_Flick.textSecondary_Flick, for: .normal)
        b.setTitleColor(UIColor(hexstring_Flick: "#E53E3E"), for: .selected)
        b.contentHorizontalAlignment = .left
        b.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        b.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        return b
    }()
    
    /// 评论按钮
    private let commentButton_Flick: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(systemName: "bubble.left"), for: .normal)
        b.tintColor = ColorConfig_Flick.textPlaceholder_Flick
        b.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        b.setTitleColor(ColorConfig_Flick.textSecondary_Flick, for: .normal)
        b.contentHorizontalAlignment = .left
        b.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        b.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        b.isUserInteractionEnabled = false
        return b
    }()
    
    /// 查看详情箭头
    private let arrowLabel_Flick: UILabel = {
        let l = UILabel()
        l.text = "Read more"
        l.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        l.textColor = ColorConfig_Flick.primaryGradientStart_Flick
        return l
    }()
    
    // MARK: - 初始化
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Flick()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateAvatarRingFrame_Flick()
    }
    
    // MARK: - UI 布局
    
    /// 搭建卡片内部所有子视图及约束
    /// 布局结构：
    ///   [头像(28) + 用户名]  ← 左上角紧凑行（头像小尺寸，与名字水平对齐）
    ///   [帖子标题]            ← 突出主标题
    ///   [内容摘要]            ← 副文本
    ///   [分割线]
    ///   [点赞] [评论] [Read more]
    private func setupUI_Flick() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView_Flick)
        cardView_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-6)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        // ── 左上角作者行 ──────────────────────────────────────
        
        // 头像渐变圆环（比头像大 4pt，置于头像底层）
        cardView_Flick.addSubview(avatarRingView_Flick)
        avatarRingView_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(12)
            make.width.height.equalTo(32)
        }
        avatarRingView_Flick.layer.cornerRadius = 16
        avatarRingView_Flick.clipsToBounds = true

        // 头像（28x28，紧贴左上角）
        cardView_Flick.addSubview(avatarView_Flick)
        avatarView_Flick.snp.makeConstraints { make in
            make.center.equalTo(avatarRingView_Flick)
            make.width.height.equalTo(26)
        }
        
        // 透明头像按钮（覆盖头像区域，UIControl 被点击时 UITableView 不触发行选中）
        cardView_Flick.addSubview(avatarTapBtn_Flick)
        avatarTapBtn_Flick.snp.makeConstraints { make in
            make.edges.equalTo(avatarRingView_Flick)
        }
        avatarTapBtn_Flick.addTarget(self, action: #selector(handleAvatarTap_Flick), for: .touchUpInside)
        
        // 用户名（与头像水平居中对齐，紧靠头像右侧）
        cardView_Flick.addSubview(userNameLabel_Flick)
        userNameLabel_Flick.snp.makeConstraints { make in
            make.centerY.equalTo(avatarRingView_Flick)
            make.left.equalTo(avatarRingView_Flick.snp.right).offset(8)
            make.right.lessThanOrEqualToSuperview().offset(-14)
        }
        
        // 时间/副标（右侧与用户名垂直对齐，隐藏到底部操作行右侧）
        cardView_Flick.addSubview(timeLabel_Flick)
        timeLabel_Flick.snp.makeConstraints { make in
            make.centerY.equalTo(avatarRingView_Flick)
            make.right.equalToSuperview().offset(-14)
        }
        
        // ── 内容区 ────────────────────────────────────────────
        
        // 帖子标题（紧跟头像行下方，更突出）
        cardView_Flick.addSubview(titleLabel_Flick)
        titleLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView_Flick.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
        }
        
        // 帖子内容摘要
        cardView_Flick.addSubview(contentLabel_Flick)
        contentLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Flick.snp.bottom).offset(6)
            make.left.right.equalTo(titleLabel_Flick)
        }
        
        // ── 底部操作行 ────────────────────────────────────────
        
        // 分割线
        cardView_Flick.addSubview(dividerView_Flick)
        dividerView_Flick.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Flick.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
            make.height.equalTo(0.5)
        }
        
        // 点赞按钮
        cardView_Flick.addSubview(likeButton_Flick)
        likeButton_Flick.snp.makeConstraints { make in
            make.top.equalTo(dividerView_Flick.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-12)
            make.width.equalTo(70)
            make.height.equalTo(28)
        }
        
        // 评论按钮
        cardView_Flick.addSubview(commentButton_Flick)
        commentButton_Flick.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton_Flick)
            make.left.equalTo(likeButton_Flick.snp.right).offset(16)
            make.width.equalTo(70)
            make.height.equalTo(28)
        }
        
        // 查看详情
        cardView_Flick.addSubview(arrowLabel_Flick)
        arrowLabel_Flick.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton_Flick)
            make.right.equalToSuperview().offset(-14)
        }
        
        // 绑定点赞按钮
        likeButton_Flick.addTarget(self, action: #selector(handleLikeTap_Flick), for: .touchUpInside)
    }
    
    // MARK: - 公共配置方法
    
    /// 配置 Cell 内容
    /// - Parameters:
    ///   - post_flick: 帖子数据模型
    ///   - isLiked_flick: 当前用户是否已点赞
    /// 头像策略：内部自动判断帖子作者是否为当前登录用户；
    ///            他人帖子显示渐变圆环并启用透明按钮；本人帖子隐藏圆环并禁用按钮
    func configure_Flick(post_flick: TitleModel_Flick, isLiked_flick: Bool) {
        avatarView_Flick.configure_Flick(userId_Flick: post_flick.titleUserId_Flick)
        userNameLabel_Flick.text = "@\(post_flick.titleUserName_Flick)"
        timeLabel_Flick.text = "Idea · \(post_flick.reviews_Flick.count) thoughts"
        titleLabel_Flick.text = post_flick.title_Flick
        contentLabel_Flick.text = post_flick.titleContent_Flick
        likeButton_Flick.setTitle(" \(post_flick.likes_Flick)", for: .normal)
        likeButton_Flick.setTitle(" \(post_flick.likes_Flick)", for: .selected)
        commentButton_Flick.setTitle(" \(post_flick.reviews_Flick.count)", for: .normal)
        
        // 更新点赞状态
        likeButton_Flick.isSelected = isLiked_flick
        updateLikeButtonAppearance_Flick(liked_flick: isLiked_flick)
        
        // 本人帖子：禁用透明按钮、隐藏渐变圆环
        // 他人帖子：启用透明按钮、显示渐变圆环（提示可点击）
        let isCurrentUserPost_Flick = UserViewModel_Flick.shared_Flick.isCurrentUser_Flick(
            userId_flick: post_flick.titleUserId_Flick
        )
        avatarTapBtn_Flick.isHidden  = isCurrentUserPost_Flick
        avatarRingView_Flick.isHidden = isCurrentUserPost_Flick
        if !isCurrentUserPost_Flick { setNeedsLayout() }
    }
    
    // MARK: - 私有方法
    
    /// 懒初始化/更新头像渐变圆环 frame（在 layoutSubviews 时调用，确保 bounds 有效）
    private func updateAvatarRingFrame_Flick() {
        guard !avatarRingView_Flick.isHidden,
              avatarRingView_Flick.bounds.width > 0 else { return }
        if let existing = avatarRingLayer_Flick {
            existing.frame = avatarRingView_Flick.bounds
            existing.cornerRadius = avatarRingView_Flick.bounds.width / 2
            return
        }
        let ring = CAGradientLayer()
        ring.frame = avatarRingView_Flick.bounds
        ring.cornerRadius = avatarRingView_Flick.bounds.width / 2
        ring.colors = [
            ColorConfig_Flick.primaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.secondaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.primaryGradientEnd_Flick.cgColor
        ]
        ring.startPoint = CGPoint(x: 0, y: 0)
        ring.endPoint   = CGPoint(x: 1, y: 1)
        avatarRingView_Flick.layer.insertSublayer(ring, at: 0)
        avatarRingLayer_Flick = ring
    }
    
    /// 更新点赞按钮外观（颜色）
    private func updateLikeButtonAppearance_Flick(liked_flick: Bool) {
        UIView.animate(withDuration: AnimationConfig_Flick.durationFast_Flick) {
            self.likeButton_Flick.tintColor = liked_flick
                ? UIColor(hexstring_Flick: "#E53E3E")
                : ColorConfig_Flick.textPlaceholder_Flick
        }
    }
    
    // MARK: - 事件处理
    
    /// 处理点赞按钮点击
    @objc private func handleLikeTap_Flick() {
        likeButton_Flick.isSelected.toggle()
        updateLikeButtonAppearance_Flick(liked_flick: likeButton_Flick.isSelected)
        likeButton_Flick.animatePulse_Flick()
        let generator_Flick = UIImpactFeedbackGenerator(style: .light)
        generator_Flick.impactOccurred()
        onLikeTapped_Flick?()
    }
    
    /// 处理头像按钮点击（UIButton 被点击时 UITableView 不触发行选中，无冲突）
    @objc private func handleAvatarTap_Flick() {
        avatarView_Flick.animatePressDown_Flick { [weak self] in
            self?.avatarView_Flick.animatePressUp_Flick()
        }
        let generator_Flick = UIImpactFeedbackGenerator(style: .light)
        generator_Flick.impactOccurred()
        onAvatarTapped_Flick?()
    }
}
