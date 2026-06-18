import Foundation
import UIKit
import SnapKit

// MARK: - 帖子详情页（Premium 重构版）

/// 帖子详情视图控制器
/// 核心作用：展示帖子媒体、标题、内容、点赞/评论，支持互动操作
/// 设计思路：全宽媒体 + 底部渐变遮罩 + 圆角浮层信息卡 + Pill 互动行 + 卡片式评论
class Detail_Sylva: UIViewController {

    // MARK: - 公开属性

    var titleModel_Sylva: TitleModel_Sylva?

    // MARK: - 私有属性

    private let scrollView_Sylva   = UIScrollView()
    private let contentView_Sylva  = UIView()

    private let mediaDisplayView_Sylva = MediaDisplayView_Sylva()
    /// 信息卡片（存储属性，用于向 contentView 撑开高度，防止触摸事件被父视图 frame 拦截）
    private let infoCardView_Sylva = UIView()
    /// 媒体底部渐变遮罩（增强层次感）
    private let mediaGradientLayer_Sylva = CAGradientLayer()

    private let authorAvatarView_Sylva = UserAvatarView_Sylva()
    private let authorNameLabel_Sylva  = UILabel()
    private let postTitleLabel_Sylva   = UILabel()
    private let postContentLabel_Sylva = UILabel()
    private let likeButton_Sylva       = UIButton(type: .system)
    private let likesCountLabel_Sylva  = UILabel()
    private let commentsCountLabel_Sylva = UILabel()
    private let commentsContainer_Sylva  = UIStackView()

    private let commentBar_Sylva        = UIView()
    private let commentInput_Sylva      = UITextField()
    private let submitCommentButton_Sylva = UIButton(type: .system)
    private var commentBarBottomConstraint_Sylva: Constraint?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Sylva: "#F7FAFA")
        setupScrollContent_Sylva()
        setupFloatingNavButtons_Sylva()
        setupCommentBar_Sylva()
        observeNotifications_Sylva()
        loadPostData_Sylva()

        let tap_sylva = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Sylva))
        tap_sylva.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_sylva)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 媒体底部渐变 frame 同步
        let mediaHeight_sylva = APPSCREEN_Sylva.WIDTH_Sylva * 0.78
        mediaGradientLayer_Sylva.frame = CGRect(
            x: 0, y: mediaHeight_sylva - 100,
            width: APPSCREEN_Sylva.WIDTH_Sylva, height: 100
        )
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - UI 搭建

    private func setupScrollContent_Sylva() {
        scrollView_Sylva.showsVerticalScrollIndicator = false
        scrollView_Sylva.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_Sylva)
        scrollView_Sylva.addSubview(contentView_Sylva)
        scrollView_Sylva.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-72)
        }
        contentView_Sylva.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }

        setupMediaArea_Sylva()
        setupInfoCard_Sylva()
    }

    /// 搭建全宽媒体区（含底部渐变遮罩）
    private func setupMediaArea_Sylva() {
        mediaDisplayView_Sylva.isUserInteractionEnabled = true
        contentView_Sylva.addSubview(mediaDisplayView_Sylva)
        mediaDisplayView_Sylva.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(APPSCREEN_Sylva.WIDTH_Sylva * 0.78)
        }

        // 底部渐变遮罩（透明 → 半透明黑，增强卡片浮层层次感）
        mediaGradientLayer_Sylva.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.45).cgColor
        ]
        mediaGradientLayer_Sylva.locations = [0.0, 1.0]
        mediaDisplayView_Sylva.layer.addSublayer(mediaGradientLayer_Sylva)

        let mediaTap_sylva = UITapGestureRecognizer(target: self, action: #selector(mediaTapped_Sylva))
        mediaDisplayView_Sylva.addGestureRecognizer(mediaTap_sylva)
    }

    /// 搭建浮层信息卡（从媒体底部上浮）
    private func setupInfoCard_Sylva() {
        // 使用存储属性 infoCardView_Sylva，补充 bottom 约束撑开 contentView 高度
        // 若用局部变量且不设 bottom，contentView 高度 = 媒体高度，下方内容虽可见但触摸被拦截
        infoCardView_Sylva.backgroundColor = .white
        infoCardView_Sylva.layer.cornerRadius = 28
        infoCardView_Sylva.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        infoCardView_Sylva.layer.shadowColor  = UIColor.black.cgColor
        infoCardView_Sylva.layer.shadowOpacity = 0.08
        infoCardView_Sylva.layer.shadowRadius  = 16
        infoCardView_Sylva.layer.shadowOffset  = CGSize(width: 0, height: -4)
        contentView_Sylva.addSubview(infoCardView_Sylva)
        infoCardView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(mediaDisplayView_Sylva.snp.bottom).offset(-28)
            make.leading.trailing.equalToSuperview()
            // bottom 连接到 contentView，撑开滚动内容高度，确保整个卡片在可交互 frame 内
            make.bottom.equalToSuperview()
        }
        let infoCard_sylva = infoCardView_Sylva

        // 作者行
        setupAuthorRow_Sylva(in: infoCard_sylva)
        // 标题
        postTitleLabel_Sylva.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        postTitleLabel_Sylva.textColor = UIColor(hexstring_Sylva: "#1B4332")
        postTitleLabel_Sylva.numberOfLines = 0
        infoCard_sylva.addSubview(postTitleLabel_Sylva)
        postTitleLabel_Sylva.snp.makeConstraints { make in
            make.top.equalTo(authorAvatarView_Sylva.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        // 内容
        postContentLabel_Sylva.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        postContentLabel_Sylva.textColor = ColorConfig_Sylva.textSecondary_Sylva
        postContentLabel_Sylva.numberOfLines = 0
        postContentLabel_Sylva.lineBreakMode = .byWordWrapping
        infoCard_sylva.addSubview(postContentLabel_Sylva)
        postContentLabel_Sylva.snp.makeConstraints { make in
            make.top.equalTo(postTitleLabel_Sylva.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        // 互动统计行
        let actionRow_sylva = setupInteractionRow_Sylva(in: infoCard_sylva)
        // 分割线
        let div_sylva = UIView()
        div_sylva.backgroundColor = ColorConfig_Sylva.divider_Sylva
        infoCard_sylva.addSubview(div_sylva)
        div_sylva.snp.makeConstraints { make in
            make.top.equalTo(actionRow_sylva.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(0.5)
        }
        // 评论区标题行
        setupCommentsSection_Sylva(in: infoCard_sylva, divider: div_sylva)
    }

    /// 作者行（头像 + 名字 + 查看资料箭头）
    private func setupAuthorRow_Sylva(in card: UIView) {
        authorAvatarView_Sylva.layer.cornerRadius = 22
        authorAvatarView_Sylva.layer.masksToBounds = true
        authorAvatarView_Sylva.layer.borderWidth = 2
        authorAvatarView_Sylva.layer.borderColor = UIColor(hexstring_Sylva: "#95D5B2").cgColor
        card.addSubview(authorAvatarView_Sylva)
        authorAvatarView_Sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(44)
        }

        authorNameLabel_Sylva.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        authorNameLabel_Sylva.textColor = UIColor(hexstring_Sylva: "#40916C")
        card.addSubview(authorNameLabel_Sylva)
        authorNameLabel_Sylva.snp.makeConstraints { make in
            make.leading.equalTo(authorAvatarView_Sylva.snp.trailing).offset(12)
            make.centerY.equalTo(authorAvatarView_Sylva).offset(-7)
        }

        let subLabel_sylva = UILabel()
        subLabel_sylva.text = "View profile →"
        subLabel_sylva.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        subLabel_sylva.textColor = ColorConfig_Sylva.textPlaceholder_Sylva
        card.addSubview(subLabel_sylva)
        subLabel_sylva.snp.makeConstraints { make in
            make.leading.equalTo(authorNameLabel_Sylva)
            make.top.equalTo(authorNameLabel_Sylva.snp.bottom).offset(3)
        }

        authorAvatarView_Sylva.isUserInteractionEnabled = true
        let tap_sylva = UITapGestureRecognizer(target: self, action: #selector(authorTapped_Sylva))
        authorAvatarView_Sylva.addGestureRecognizer(tap_sylva)
    }

    /// 互动统计行（Pill 样式点赞 + 评论数）
    private func setupInteractionRow_Sylva(in card: UIView) -> UIView {
        let row_sylva = UIView()
        card.addSubview(row_sylva)
        row_sylva.snp.makeConstraints { make in
            make.top.equalTo(postContentLabel_Sylva.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        // 点赞 Pill
        let likePill_sylva = UIView()
        likePill_sylva.backgroundColor = UIColor(hexstring_Sylva: "#F0FFF4")
        likePill_sylva.layer.cornerRadius = 16
        likePill_sylva.layer.borderWidth  = 1
        likePill_sylva.layer.borderColor  = UIColor(hexstring_Sylva: "#B7E4C7").cgColor
        row_sylva.addSubview(likePill_sylva)

        let likeIconCfg_sylva = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        likeButton_Sylva.setImage(UIImage(systemName: "heart.fill", withConfiguration: likeIconCfg_sylva), for: .normal)
        likeButton_Sylva.tintColor = ColorConfig_Sylva.textPlaceholder_Sylva
        likeButton_Sylva.addTarget(self, action: #selector(likeTapped_Sylva), for: .touchUpInside)
        likePill_sylva.addSubview(likeButton_Sylva)

        likesCountLabel_Sylva.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        likesCountLabel_Sylva.textColor = UIColor(hexstring_Sylva: "#40916C")
        likePill_sylva.addSubview(likesCountLabel_Sylva)

        // 评论 Pill
        let commentPill_sylva = UIView()
        commentPill_sylva.backgroundColor = UIColor(hexstring_Sylva: "#F7FAFA")
        commentPill_sylva.layer.cornerRadius = 16
        commentPill_sylva.layer.borderWidth  = 1
        commentPill_sylva.layer.borderColor  = ColorConfig_Sylva.border_Sylva.cgColor
        row_sylva.addSubview(commentPill_sylva)

        let commentIconCfg_sylva = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let commentIcon_sylva = UIImageView(image: UIImage(systemName: "bubble.left.fill", withConfiguration: commentIconCfg_sylva))
        commentIcon_sylva.tintColor = ColorConfig_Sylva.textPlaceholder_Sylva
        commentPill_sylva.addSubview(commentIcon_sylva)

        commentsCountLabel_Sylva.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        commentsCountLabel_Sylva.textColor = ColorConfig_Sylva.textSecondary_Sylva
        commentPill_sylva.addSubview(commentsCountLabel_Sylva)

        // 先加入层级，再统一约束
        likePill_sylva.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.height.equalTo(32)
        }
        likeButton_Sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        likesCountLabel_Sylva.snp.makeConstraints { make in
            make.leading.equalTo(likeButton_Sylva.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-12)
        }
        commentPill_sylva.snp.makeConstraints { make in
            make.leading.equalTo(likePill_sylva.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(32)
        }
        commentIcon_sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        commentsCountLabel_Sylva.snp.makeConstraints { make in
            make.leading.equalTo(commentIcon_sylva.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-12)
        }

        return row_sylva
    }

    /// 搭建评论区（标题 + 列表容器）
    private func setupCommentsSection_Sylva(in card: UIView, divider: UIView) {
        let titleRow_sylva = UIView()
        let titleLabel_sylva = UILabel()
        titleLabel_sylva.text = "Comments"
        titleLabel_sylva.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel_sylva.textColor = UIColor(hexstring_Sylva: "#1B4332")
        titleRow_sylva.addSubview(titleLabel_sylva)
        titleLabel_sylva.snp.makeConstraints { make in make.leading.centerY.equalToSuperview() }

        let countBadge_sylva = UIView()
        countBadge_sylva.backgroundColor = UIColor(hexstring_Sylva: "#D8F3DC")
        countBadge_sylva.layer.cornerRadius = 10
        titleRow_sylva.addSubview(countBadge_sylva)

        commentsCountLabel_Sylva.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        commentsCountLabel_Sylva.textColor = UIColor(hexstring_Sylva: "#40916C")
        countBadge_sylva.addSubview(commentsCountLabel_Sylva)

        card.addSubview(titleRow_sylva)
        titleRow_sylva.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(28)
        }
        countBadge_sylva.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel_sylva.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(30)
        }
        commentsCountLabel_Sylva.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }

        commentsContainer_Sylva.axis    = .vertical
        commentsContainer_Sylva.spacing = 8
        card.addSubview(commentsContainer_Sylva)
        commentsContainer_Sylva.snp.makeConstraints { make in
            make.top.equalTo(titleRow_sylva.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    /// 搭建顶部浮层导航按钮（返回 + 举报/删除，直接加到 view 用 safeAreaLayoutGuide）
    private func setupFloatingNavButtons_Sylva() {
        let backBtn_sylva = UIButton(type: .system)
        let backCfg_sylva = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        backBtn_sylva.setImage(UIImage(systemName: "chevron.left", withConfiguration: backCfg_sylva), for: .normal)
        backBtn_sylva.tintColor = .white
        backBtn_sylva.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        backBtn_sylva.layer.cornerRadius = 18
        backBtn_sylva.addTarget(self, action: #selector(backTapped_Sylva), for: .touchUpInside)
        view.addSubview(backBtn_sylva)
        backBtn_sylva.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }

        if let post_sylva = titleModel_Sylva {
            let reportBtn_sylva = ReportDeleteHelper_Sylva.createPostReportButton_Sylva(
                post_Sylva: post_sylva,
                size_Sylva: 18,
                color_Sylva: .white,
                from: self
            ) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            reportBtn_sylva.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            reportBtn_sylva.layer.cornerRadius = 18
            view.addSubview(reportBtn_sylva)
            reportBtn_sylva.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
                make.trailing.equalToSuperview().offset(-16)
                make.width.height.equalTo(36)
            }
        }
    }

    /// 搭建底部评论输入栏
    private func setupCommentBar_Sylva() {
        commentBar_Sylva.backgroundColor = .white
        commentBar_Sylva.layer.shadowColor  = UIColor.black.cgColor
        commentBar_Sylva.layer.shadowOpacity = 0.08
        commentBar_Sylva.layer.shadowRadius  = 12
        commentBar_Sylva.layer.shadowOffset  = CGSize(width: 0, height: -3)
        view.addSubview(commentBar_Sylva)
        commentBar_Sylva.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            // 去掉头像后高度适当调高至 72pt
            make.height.equalTo(72 + view.safeAreaInsets.bottom)
            commentBarBottomConstraint_Sylva = make.bottom.equalTo(view.snp.bottom).constraint
        }

        // 不再展示头像，输入框直接从左边距开始
        commentInput_Sylva.backgroundColor = UIColor(hexstring_Sylva: "#F0FFF4")
        commentInput_Sylva.layer.cornerRadius = 22
        commentInput_Sylva.layer.borderWidth  = 1.5
        commentInput_Sylva.layer.borderColor  = UIColor(hexstring_Sylva: "#95D5B2").cgColor
        commentInput_Sylva.font = UIFont.systemFont(ofSize: 14)
        commentInput_Sylva.setPlaceholder_Sylva(placeholder_Sylva: "Add a comment...", color_Sylva: ColorConfig_Sylva.textPlaceholder_Sylva)
        commentInput_Sylva.setLeftPadding_Sylva(padding_Sylva: 18)
        commentInput_Sylva.returnKeyType = .send
        commentInput_Sylva.delegate = self
        commentBar_Sylva.addSubview(commentInput_Sylva)

        let sendCfg_sylva = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        submitCommentButton_Sylva.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: sendCfg_sylva), for: .normal)
        submitCommentButton_Sylva.tintColor = .white
        submitCommentButton_Sylva.backgroundColor = UIColor(hexstring_Sylva: "#40916C")
        submitCommentButton_Sylva.layer.cornerRadius = 20
        submitCommentButton_Sylva.layer.shadowColor  = UIColor(hexstring_Sylva: "#40916C").cgColor
        submitCommentButton_Sylva.layer.shadowOpacity = 0.35
        submitCommentButton_Sylva.layer.shadowRadius  = 6
        submitCommentButton_Sylva.layer.shadowOffset  = CGSize(width: 0, height: 3)
        submitCommentButton_Sylva.addTarget(self, action: #selector(submitCommentTapped_Sylva), for: .touchUpInside)
        commentBar_Sylva.addSubview(submitCommentButton_Sylva)

        // 统一约束：输入框从左侧 16pt 开始，右侧接发送按钮
        submitCommentButton_Sylva.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.top.equalToSuperview().offset(14)
            make.width.height.equalTo(40)
        }
        commentInput_Sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(submitCommentButton_Sylva.snp.leading).offset(-10)
            make.top.equalToSuperview().offset(14)
            make.height.equalTo(44)
        }
    }

    // MARK: - 数据加载

    private func loadPostData_Sylva() {
        guard let post_sylva = titleModel_Sylva else { return }
        let latest_sylva = TitleViewModel_Sylva.shared_Sylva.getPosts_Sylva()
            .first(where: { $0.titleId_Sylva == post_sylva.titleId_Sylva }) ?? post_sylva
        titleModel_Sylva = latest_sylva

        if let media_sylva = latest_sylva.titleMeidas_Sylva.first {
            mediaDisplayView_Sylva.configure_Sylva(mediaPath_Sylva: media_sylva)
        }
        authorAvatarView_Sylva.configure_Sylva(userId_Sylva: latest_sylva.titleUserId_Sylva)
        authorNameLabel_Sylva.text  = latest_sylva.titleUserName_Sylva
        postTitleLabel_Sylva.text   = latest_sylva.title_Sylva
        postContentLabel_Sylva.text = latest_sylva.titleContent_Sylva

        let isLiked_sylva = TitleViewModel_Sylva.shared_Sylva.isLikedPost_Sylva(post_sylva: latest_sylva)
        likeButton_Sylva.tintColor = isLiked_sylva
            ? UIColor(hexstring_Sylva: "#E53E3E")
            : ColorConfig_Sylva.textPlaceholder_Sylva
        likesCountLabel_Sylva.text  = "\(latest_sylva.likes_Sylva)"
        refreshComments_Sylva(post_Sylva: latest_sylva)
    }

    private func refreshComments_Sylva(post_Sylva: TitleModel_Sylva) {
        commentsContainer_Sylva.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let visible_sylva = post_Sylva.reviews_Sylva.filter { shouldShowComment_Sylva($0) }
        commentsCountLabel_Sylva.text = "\(visible_sylva.count)"

        if visible_sylva.isEmpty {
            let emptyView_sylva = buildEmptyCommentView_Sylva()
            commentsContainer_Sylva.addArrangedSubview(emptyView_sylva)
            return
        }

        for (idx_sylva, comment_sylva) in visible_sylva.enumerated() {
            let row_sylva = makeCommentCard_Sylva(
                comment_Sylva: comment_sylva,
                post_Sylva: post_Sylva,
                isLast_Sylva: idx_sylva == visible_sylva.count - 1
            )
            commentsContainer_Sylva.addArrangedSubview(row_sylva)
            row_sylva.animateFadeIn_Sylva(delay_Sylva: 0.04 * Double(idx_sylva))
        }
    }

    private func shouldShowComment_Sylva(_ comment: Comment_Sylva) -> Bool {
        let uid_sylva = UserViewModel_Sylva.shared_Sylva.getCurrentUser_Sylva().userId_Sylva
        if comment.commentUserId_Sylva == uid_sylva { return true }
        return LocalData_Sylva.shared_Sylva.userList_Sylva.contains { $0.userId_Sylva == comment.commentUserId_Sylva }
    }

    /// 构建评论卡片（白色卡片 + 绿色作者名 + 评论内容）
    private func makeCommentCard_Sylva(comment_Sylva: Comment_Sylva, post_Sylva: TitleModel_Sylva, isLast_Sylva: Bool) -> UIView {
        let card_sylva = UIView()
        card_sylva.backgroundColor = UIColor(hexstring_Sylva: "#F7FAFA")
        card_sylva.layer.cornerRadius = 14

        let avatar_sylva = UserAvatarView_Sylva()
        avatar_sylva.configure_Sylva(userId_Sylva: comment_Sylva.commentUserId_Sylva)
        avatar_sylva.layer.cornerRadius = 16
        avatar_sylva.layer.masksToBounds = true
        card_sylva.addSubview(avatar_sylva)

        let nameLbl_sylva = UILabel()
        nameLbl_sylva.text = comment_Sylva.commentUserName_Sylva
        nameLbl_sylva.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        nameLbl_sylva.textColor = UIColor(hexstring_Sylva: "#40916C")
        card_sylva.addSubview(nameLbl_sylva)

        let contentLbl_sylva = UILabel()
        contentLbl_sylva.text = comment_Sylva.commentContent_Sylva
        contentLbl_sylva.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        contentLbl_sylva.textColor = ColorConfig_Sylva.textPrimary_Sylva
        contentLbl_sylva.numberOfLines = 0
        card_sylva.addSubview(contentLbl_sylva)

        let reportBtn_sylva = ReportDeleteHelper_Sylva.createCommentReportButton_Sylva(
            comment_Sylva: comment_Sylva,
            post_Sylva: post_Sylva,
            size_Sylva: 14,
            color_Sylva: ColorConfig_Sylva.textPlaceholder_Sylva,
            from: self
        ) { [weak self] in self?.loadPostData_Sylva() }
        card_sylva.addSubview(reportBtn_sylva)

        // 统一约束
        avatar_sylva.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(32)
        }
        reportBtn_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-8)
            make.width.height.equalTo(28)
        }
        nameLbl_sylva.snp.makeConstraints { make in
            make.leading.equalTo(avatar_sylva.snp.trailing).offset(8)
            make.top.equalTo(avatar_sylva)
            make.trailing.equalTo(reportBtn_sylva.snp.leading).offset(-4)
        }
        contentLbl_sylva.snp.makeConstraints { make in
            make.top.equalTo(nameLbl_sylva.snp.bottom).offset(4)
            make.leading.equalTo(nameLbl_sylva)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }

        return card_sylva
    }

    /// 构建评论空状态视图
    private func buildEmptyCommentView_Sylva() -> UIView {
        let view_sylva = UIView()
        let icon_sylva = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right"))
        icon_sylva.tintColor = UIColor(hexstring_Sylva: "#B7E4C7")
        icon_sylva.contentMode = .scaleAspectFit
        view_sylva.addSubview(icon_sylva)

        let lbl_sylva = UILabel()
        lbl_sylva.text = "No comments yet — be the first!"
        lbl_sylva.font = UIFont.systemFont(ofSize: 13)
        lbl_sylva.textColor = ColorConfig_Sylva.textPlaceholder_Sylva
        lbl_sylva.textAlignment = .center
        view_sylva.addSubview(lbl_sylva)

        icon_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(32)
        }
        lbl_sylva.snp.makeConstraints { make in
            make.top.equalTo(icon_sylva.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
        }
        return view_sylva
    }

    // MARK: - 通知

    private func observeNotifications_Sylva() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onTitleStateChanged_Sylva),
            name: TitleViewModel_Sylva.titleStateDidChangeNotification_Sylva, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow_Sylva(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide_Sylva(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    @objc private func onTitleStateChanged_Sylva() { loadPostData_Sylva() }

    @objc private func keyboardWillShow_Sylva(_ notification: Notification) {
        guard let info_sylva = notification.userInfo,
              let frame_sylva = info_sylva[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_sylva = info_sylva[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        commentBarBottomConstraint_Sylva?.update(offset: -frame_sylva.height)
        UIView.animate(withDuration: duration_sylva) { self.view.layoutIfNeeded() }
    }

    @objc private func keyboardWillHide_Sylva(_ notification: Notification) {
        guard let duration_sylva = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        commentBarBottomConstraint_Sylva?.update(offset: 0)
        UIView.animate(withDuration: duration_sylva) { self.view.layoutIfNeeded() }
    }

    // MARK: - 事件

    @objc private func backTapped_Sylva() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func dismissKeyboard_Sylva() { view.endEditing(true) }

    @objc private func mediaTapped_Sylva() {
        guard let media_sylva = titleModel_Sylva?.titleMeidas_Sylva.first else { return }
        let vc_sylva = MediaPlayerPage_Sylva()
        vc_sylva.mediaPath_Sylva = media_sylva
        vc_sylva.modalPresentationStyle = .fullScreen
        present(vc_sylva, animated: true)
    }

    @objc private func authorTapped_Sylva() {
        guard let post_sylva = titleModel_Sylva else { return }
        let user_sylva = UserViewModel_Sylva.shared_Sylva.getUserById_Sylva(userId_sylva: post_sylva.titleUserId_Sylva)
        Navigation_Sylva.toUserInfo_Sylva(with: user_sylva)
    }

    @objc private func likeTapped_Sylva() {
        guard let post_sylva = titleModel_Sylva else { return }
        likeButton_Sylva.animatePulse_Sylva()
        TitleViewModel_Sylva.shared_Sylva.likePost_Sylva(post_sylva: post_sylva)
    }

    @objc private func submitCommentTapped_Sylva() {
        let text_sylva = commentInput_Sylva.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !text_sylva.isEmpty, let post_sylva = titleModel_Sylva else { return }
        submitCommentButton_Sylva.animatePulse_Sylva()
        commentInput_Sylva.text = ""
        view.endEditing(true)
        TitleViewModel_Sylva.shared_Sylva.releaseComment_Sylva(post_sylva: post_sylva, content_sylva: text_sylva)
    }
}

// MARK: - UITextFieldDelegate

extension Detail_Sylva: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submitCommentTapped_Sylva(); return true
    }
}
