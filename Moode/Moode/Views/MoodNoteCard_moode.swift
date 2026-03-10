import Foundation
import UIKit
import SnapKit

// MARK: - 情绪便签卡片通用组件

/// 情绪便签卡片组件
/// 功能：展示单条情绪便签，左侧情绪渐变色条 + 媒体缩略图 + 右侧文字内容，底部展示作者头像及互动数据
/// 设计思路：媒体图占据左侧视觉焦点，文字内容排列在右侧，底部行头像从色条右侧起始避免重叠
/// 关键方法：configure_Moode 绑定数据，onLikeTapped_Moode / onCardTapped_Moode 提供回调
class MoodNoteCard_Moode: UICollectionViewCell {

    // MARK: - 复用标识

    /// Cell 复用标识符
    static let reuseIdentifier_Moode = "MoodNoteCard_Moode"

    // MARK: - UI 组件

    /// 卡片容器（带圆角和阴影）
    private let cardView_Moode: UIView = {
        let view_Moode = UIView()
        view_Moode.backgroundColor = .white
        view_Moode.layer.cornerRadius = 20
        view_Moode.layer.shadowColor = UIColor(hexstring_Moode: "#9BB5F0").cgColor
        view_Moode.layer.shadowOffset = CGSize(width: 0, height: 5)
        view_Moode.layer.shadowRadius = 14
        view_Moode.layer.shadowOpacity = 0.15
        view_Moode.clipsToBounds = false
        return view_Moode
    }()

    /// 左侧情绪渐变色条（宽6pt，上下缩进12pt，圆角4pt）
    private let moodStripe_Moode: UIView = {
        let view_Moode = UIView()
        view_Moode.layer.cornerRadius = 4
        view_Moode.clipsToBounds = true
        return view_Moode
    }()

    /// 色条渐变图层（在 layoutSubviews 中按当前情绪重建，确保 bounds 正确）
    private var stripeGradientLayer_Moode: CAGradientLayer?

    /// 媒体缩略图展示组件（使用 MediaDisplayView_Moode，位于色条右侧）
    private let mediaView_Moode: MediaDisplayView_Moode = {
        let v_Moode = MediaDisplayView_Moode()
        v_Moode.layer.cornerRadius = 14
        v_Moode.clipsToBounds = true
        return v_Moode
    }()

    /// 情绪 Badge（Emoji + 名称），使用 backgroundColor 避免 CAGradientLayer 帧不同步
    private let moodBadge_Moode: UIView = {
        let view_Moode = UIView()
        view_Moode.layer.cornerRadius = 11
        view_Moode.clipsToBounds = true
        return view_Moode
    }()

    /// 当前情绪类型（供 layoutSubviews 重建色条渐变用）
    private var currentMood_Moode: MoodType_Moode?

    /// 右上角举报/删除按钮
    private let reportBtn_Moode: UIButton = {
        let btn_Moode = UIButton(type: .system)
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        btn_Moode.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg_Moode), for: .normal)
        btn_Moode.tintColor = .white
        btn_Moode.backgroundColor = UIColor.black.withAlphaComponent(0.42)
        btn_Moode.layer.cornerRadius = 13
        btn_Moode.clipsToBounds = true
        return btn_Moode
    }()

    /// 情绪 Emoji 标签
    private let moodEmojiLabel_Moode: UILabel = {
        let label_Moode = UILabel()
        label_Moode.font = .systemFont(ofSize: 13)
        label_Moode.textAlignment = .center
        return label_Moode
    }()

    /// 情绪名称标签
    private let moodNameLabel_Moode: UILabel = {
        let label_Moode = UILabel()
        label_Moode.font = .systemFont(ofSize: 10, weight: .bold)
        label_Moode.textColor = .white
        label_Moode.textAlignment = .center
        return label_Moode
    }()

    /// 帖子标题（2 行，加粗，位于媒体右侧）
    private let titleLabel_Moode: UILabel = {
        let label_Moode = UILabel()
        label_Moode.font = .systemFont(ofSize: 15, weight: .heavy)
        label_Moode.textColor = ColorConfig_Moode.textPrimary_Moode
        label_Moode.numberOfLines = 2
        return label_Moode
    }()

    /// 帖子内容摘要（最多2行，超出截断）
    private let contentLabel_Moode: UILabel = {
        let label_Moode = UILabel()
        label_Moode.font = .systemFont(ofSize: 12)
        label_Moode.textColor = ColorConfig_Moode.textSecondary_Moode
        label_Moode.numberOfLines = 2
        label_Moode.lineBreakMode = .byTruncatingTail
        return label_Moode
    }()

    /// 底部分割线
    private let divider_Moode: UIView = {
        let view_Moode = UIView()
        view_Moode.backgroundColor = ColorConfig_Moode.divider_Moode
        return view_Moode
    }()

    /// 作者头像（使用 UserAvatarView_Moode，从色条右侧起始，不与色条重叠）
    private let avatarView_Moode: UserAvatarView_Moode = {
        let view_Moode = UserAvatarView_Moode()
        return view_Moode
    }()

    /// 作者名称标签
    private let authorLabel_Moode: UILabel = {
        let label_Moode = UILabel()
        label_Moode.font = .systemFont(ofSize: 12, weight: .medium)
        label_Moode.textColor = ColorConfig_Moode.textSecondary_Moode
        return label_Moode
    }()

    /// 评论图标（与点赞图标等尺寸，14x14pt）
    private let commentIconView_Moode: UIImageView = {
        let iv_Moode = UIImageView()
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        iv_Moode.image = UIImage(systemName: "bubble.left", withConfiguration: cfg_Moode)
        iv_Moode.tintColor = ColorConfig_Moode.textPlaceholder_Moode
        iv_Moode.contentMode = .scaleAspectFit
        return iv_Moode
    }()

    /// 评论数标签
    private let commentCountLabel_Moode: UILabel = {
        let label_Moode = UILabel()
        label_Moode.font = .systemFont(ofSize: 11)
        label_Moode.textColor = ColorConfig_Moode.textPlaceholder_Moode
        return label_Moode
    }()

    /// 点赞按钮（与评论图标等尺寸，14x14pt）
    private let likeButton_Moode: UIButton = {
        let btn_Moode = UIButton(type: .custom)
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        btn_Moode.setImage(UIImage(systemName: "heart", withConfiguration: cfg_Moode), for: .normal)
        btn_Moode.setImage(UIImage(systemName: "heart.fill", withConfiguration: cfg_Moode), for: .selected)
        btn_Moode.tintColor = ColorConfig_Moode.textPlaceholder_Moode
        return btn_Moode
    }()

    /// 点赞数标签
    private let likeCountLabel_Moode: UILabel = {
        let label_Moode = UILabel()
        label_Moode.font = .systemFont(ofSize: 11)
        label_Moode.textColor = ColorConfig_Moode.textPlaceholder_Moode
        return label_Moode
    }()

    // MARK: - 数据与回调

    /// 当前绑定的帖子模型
    private var post_Moode: TitleModel_Moode?

    /// 点赞按钮点击回调
    var onLikeTapped_Moode: ((TitleModel_Moode) -> Void)?

    /// 卡片点击回调
    var onCardTapped_Moode: ((TitleModel_Moode) -> Void)?

    /// 头像点击回调（携带帖子作者 userId）
    var onAvatarTapped_Moode: ((Int) -> Void)?

    /// 举报/删除按钮回调（由外部 VC 注入，区分自己/他人帖子）
    var onReportTapped_Moode: ((TitleModel_Moode) -> Void)?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Moode()
        setupGestures_Moode()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 布局更新

    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrames_Moode()
    }

    // MARK: - UI 构建

    /// 构建卡片布局：左侧色条 → 媒体缩略图 → 右侧文字内容 → 底部互动行
    private func setupUI_Moode() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView_Moode)
        cardView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }

        // 左侧情绪色条（全高，宽6pt）
        cardView_Moode.addSubview(moodStripe_Moode)
        moodStripe_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.width.equalTo(6)
        }

        // 媒体缩略图（色条右侧，正方形 90x90pt）
        cardView_Moode.addSubview(mediaView_Moode)
        mediaView_Moode.snp.makeConstraints { make in
            make.left.equalTo(moodStripe_Moode.snp.right).offset(10)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(90)
        }

        // 举报按钮（右上角悬浮，26x26pt，圆形半透明背景）
        cardView_Moode.addSubview(reportBtn_Moode)
        reportBtn_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(26)
        }
        reportBtn_Moode.addTarget(self, action: #selector(handleReportTapped_Moode), for: .touchUpInside)

        // 情绪 Badge（举报按钮左侧，emoji + 名称）
        cardView_Moode.addSubview(moodBadge_Moode)
        moodBadge_Moode.addSubview(moodEmojiLabel_Moode)
        moodBadge_Moode.addSubview(moodNameLabel_Moode)
        moodBadge_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.right.equalTo(reportBtn_Moode.snp.left).offset(-4)
            make.height.equalTo(22)
        }
        moodEmojiLabel_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(6)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }
        moodNameLabel_Moode.snp.makeConstraints { make in
            make.left.equalTo(moodEmojiLabel_Moode.snp.right).offset(3)
            make.right.equalToSuperview().offset(-7)
            make.centerY.equalToSuperview()
        }

        // 标题（媒体右侧，Badge 左侧）
        cardView_Moode.addSubview(titleLabel_Moode)
        titleLabel_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalTo(mediaView_Moode.snp.right).offset(10)
            make.right.equalTo(moodBadge_Moode.snp.left).offset(-6)
        }

        // 内容摘要（标题下方，最多2行，不超过媒体底部）
        cardView_Moode.addSubview(contentLabel_Moode)
        contentLabel_Moode.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Moode.snp.bottom).offset(5)
            make.left.equalTo(mediaView_Moode.snp.right).offset(10)
            make.right.equalToSuperview().offset(-12)
            // 内容最多与媒体等高，超出时截断
            make.bottom.lessThanOrEqualTo(mediaView_Moode.snp.bottom)
        }

        // 分割线（媒体底部下方 10pt）
        cardView_Moode.addSubview(divider_Moode)
        divider_Moode.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Moode.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
            make.height.equalTo(0.5)
        }

        // 底部行：头像从色条右侧起始，避免与渐变色条重叠
        cardView_Moode.addSubview(avatarView_Moode)
        avatarView_Moode.snp.makeConstraints { make in
            make.left.equalTo(moodStripe_Moode.snp.right).offset(10)
            make.top.equalTo(divider_Moode.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-10)
            make.width.height.equalTo(24)
        }

        cardView_Moode.addSubview(authorLabel_Moode)
        authorLabel_Moode.snp.makeConstraints { make in
            make.left.equalTo(avatarView_Moode.snp.right).offset(6)
            make.centerY.equalTo(avatarView_Moode)
        }

        // 先全部 addSubview，再从右到左设置约束（避免引用未入层级的视图）
        cardView_Moode.addSubview(likeCountLabel_Moode)
        cardView_Moode.addSubview(likeButton_Moode)
        cardView_Moode.addSubview(commentCountLabel_Moode)
        cardView_Moode.addSubview(commentIconView_Moode)

        // 点赞数（最右）
        likeCountLabel_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(avatarView_Moode)
        }

        // 点赞按钮（点赞数左侧，14x14pt）
        likeButton_Moode.snp.makeConstraints { make in
            make.right.equalTo(likeCountLabel_Moode.snp.left).offset(-3)
            make.centerY.equalTo(avatarView_Moode)
            make.width.height.equalTo(14)
        }

        // 评论数
        commentCountLabel_Moode.snp.makeConstraints { make in
            make.right.equalTo(likeButton_Moode.snp.left).offset(-10)
            make.centerY.equalTo(avatarView_Moode)
        }

        // 评论图标（与点赞图标等尺寸，14x14pt）
        commentIconView_Moode.snp.makeConstraints { make in
            make.right.equalTo(commentCountLabel_Moode.snp.left).offset(-3)
            make.centerY.equalTo(avatarView_Moode)
            make.width.height.equalTo(14)
        }

        likeButton_Moode.addTarget(self, action: #selector(handleLikeTapped_Moode), for: .touchUpInside)
    }

    /// 设置手势
    private func setupGestures_Moode() {
        let tap_Moode = UITapGestureRecognizer(target: self, action: #selector(handleCardTapped_Moode))
        cardView_Moode.addGestureRecognizer(tap_Moode)
        cardView_Moode.isUserInteractionEnabled = true

        // 头像点击手势（独立于卡片手势，需先开启交互）
        avatarView_Moode.isUserInteractionEnabled = true
        let avatarTap_Moode = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTapped_Moode))
        avatarView_Moode.addGestureRecognizer(avatarTap_Moode)
    }

    /// 在 layoutSubviews 中重建色条渐变（bounds 已确定，帧一定正确）
    private func updateGradientFrames_Moode() {
        guard let mood_Moode = currentMood_Moode else { return }
        stripeGradientLayer_Moode?.removeFromSuperlayer()
        let stripe_Moode = mood_Moode.createGradientLayer_Moode(frame_Moode: moodStripe_Moode.bounds)
        moodStripe_Moode.layer.insertSublayer(stripe_Moode, at: 0)
        stripeGradientLayer_Moode = stripe_Moode
    }

    // MARK: - 数据绑定

    /// 绑定帖子数据到卡片
    /// - Parameter post_moode: 要展示的帖子模型
    /// - Parameter isLiked_moode: 当前用户是否已点赞
    func configure_Moode(post_moode: TitleModel_Moode, isLiked_moode: Bool) {
        self.post_Moode = post_moode
        let mood_moode = post_moode.moodType_Moode

        // 绑定文字内容
        titleLabel_Moode.text = post_moode.title_Moode
        contentLabel_Moode.text = post_moode.titleContent_Moode
        authorLabel_Moode.text = post_moode.titleUserName_Moode
        likeCountLabel_Moode.text = "\(post_moode.likes_Moode)"
        commentCountLabel_Moode.text = "\(post_moode.reviews_Moode.count)"

        // 配置作者头像（UserAvatarView_Moode）
        avatarView_Moode.configure_Moode(userId_Moode: post_moode.titleUserId_Moode)

        // 配置媒体缩略图（取第一个媒体路径）
        let mediaPath_moode = post_moode.titleMeidas_Moode.first
        mediaView_Moode.configure_Moode(mediaPath_Moode: mediaPath_moode)

        // 配置点赞状态
        likeButton_Moode.isSelected = isLiked_moode
        likeButton_Moode.tintColor = isLiked_moode
            ? UIColor(hexstring_Moode: "#FF6B6B")
            : ColorConfig_Moode.textPlaceholder_Moode
        likeCountLabel_Moode.textColor = isLiked_moode
            ? UIColor(hexstring_Moode: "#FF6B6B")
            : ColorConfig_Moode.textPlaceholder_Moode

        // Emoji 和情绪名称
        moodEmojiLabel_Moode.text = mood_moode.emoji_Moode
        moodNameLabel_Moode.text = mood_moode.displayName_Moode

        // 存储情绪类型，供 layoutSubviews 重建色条渐变
        currentMood_Moode = mood_moode

        // Badge 使用情绪渐变起始色作为背景
        moodBadge_Moode.backgroundColor = mood_moode.gradientStart_Moode

        // 根据是否为自己的帖子切换右上角按钮图标：自己→删除(trash)，他人→举报(ellipsis)
        let isMyPost_moode = UserViewModel_Moode.shared_Moode.isCurrentUser_Moode(
            userId_moode: post_moode.titleUserId_Moode
        )
        let cfg_moode = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let iconName_moode = isMyPost_moode ? "trash" : "ellipsis"
        reportBtn_Moode.setImage(UIImage(systemName: iconName_moode, withConfiguration: cfg_moode), for: .normal)
        reportBtn_Moode.tintColor = isMyPost_moode
            ? UIColor(hexstring_Moode: "#FF6B6B")
            : .white
        reportBtn_Moode.backgroundColor = isMyPost_moode
            ? UIColor(hexstring_Moode: "#FF6B6B").withAlphaComponent(0.22)
            : UIColor.black.withAlphaComponent(0.28)

        // 触发 layoutSubviews 重建渐变（此时 bounds 已确定）
        setNeedsLayout()
        layoutIfNeeded()
    }

    // MARK: - 事件处理

    /// 处理点赞按钮点击
    @objc private func handleLikeTapped_Moode() {
        guard let post_moode = post_Moode else { return }

        let generator_Moode = UIImpactFeedbackGenerator(style: .medium)
        generator_Moode.impactOccurred()

        likeButton_Moode.animatePressDown_Moode {
            self.likeButton_Moode.animatePulse_Moode()
        }

        // 切换为已点赞时添加光晕效果
        if !likeButton_Moode.isSelected {
            likeButton_Moode.layer.addGlowEffect_Moode(
                color_Moode: UIColor(hexstring_Moode: "#FF6B6B"),
                radius_Moode: 8
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.likeButton_Moode.layer.removeGlowEffect_Moode()
            }
        }

        onLikeTapped_Moode?(post_moode)
    }

    /// 处理举报/删除按钮点击，触发 onReportTapped_Moode 回调
    @objc private func handleReportTapped_Moode() {
        guard let post_moode = post_Moode else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onReportTapped_Moode?(post_moode)
    }

    /// 处理头像点击，触发 onAvatarTapped_Moode 回调并携带作者 userId
    @objc private func handleAvatarTapped_Moode() {
        guard let userId_Moode = post_Moode?.titleUserId_Moode else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onAvatarTapped_Moode?(userId_Moode)
    }

    /// 处理卡片点击
    @objc private func handleCardTapped_Moode() {
        guard let post_moode = post_Moode else { return }

        cardView_Moode.animatePressDown_Moode {
            self.cardView_Moode.animatePressUp_Moode()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.onCardTapped_Moode?(post_moode)
        }
    }

    // MARK: - 复用清理

    override func prepareForReuse() {
        super.prepareForReuse()
        post_Moode = nil
        onAvatarTapped_Moode = nil
        onReportTapped_Moode = nil
        titleLabel_Moode.text = nil
        contentLabel_Moode.text = nil
        authorLabel_Moode.text = nil
        likeCountLabel_Moode.text = nil
        commentCountLabel_Moode.text = nil
        stripeGradientLayer_Moode?.removeFromSuperlayer()
        stripeGradientLayer_Moode = nil
        currentMood_Moode = nil
        moodBadge_Moode.backgroundColor = .clear
        likeButton_Moode.isSelected = false
        likeButton_Moode.tintColor = ColorConfig_Moode.textPlaceholder_Moode
        likeButton_Moode.layer.removeGlowEffect_Moode()
    }
}
