import Foundation
import UIKit
import SnapKit

// MARK: - 帖子详情页

/// 帖子详情页面
/// 核心作用：展示帖子完整内容（媒体、标题、正文、点赞、评论），支持举报/删除帖子与评论
/// 设计风格：沉浸式深色渐变顶部横幅 + 白色内容卡片 + 评论流 + 底部输入栏
/// 关键属性：
///   - titleModel_Doze: 外部传入的帖子数据模型
/// 关键方法：
///   - reloadPost_Doze: 从 TitleViewModel 拉取最新数据后刷新 UI
///   - refreshComments_Doze: 清空并重建评论列表视图
class Detail_Doze: UIViewController {

    // MARK: - 外部数据

    /// 外部传入帖子模型
    var titleModel_Doze: TitleModel_Doze?

    // MARK: - 常量

    /// 底部输入栏高度
    private let inputBarHeight_Doze: CGFloat = 64

    // MARK: - 顶部导航栏

    /// 顶部渐变横幅（作为沉浸式背景）
    private let heroBg_Doze: UIView = {
        let v = UIView()
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v.layer.cornerRadius = 28
        v.clipsToBounds = true
        return v
    }()

    private let heroGradient_Doze: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [
            UIColor(hexstring_Doze: "#1A0A3B").cgColor,
            UIColor(hexstring_Doze: "#2D1558").cgColor,
            ColorConfig_Doze.primaryGradientStart_Doze.cgColor
        ]
        gl.locations = [0, 0.6, 1]
        gl.startPoint = CGPoint(x: 0, y: 0)
        gl.endPoint = CGPoint(x: 1, y: 1)
        return gl
    }()

    /// 返回按钮
    private let backBtn_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        btn.layer.cornerRadius = 18
        return btn
    }()

    /// 右上角操作按钮（举报 or 删除）
    private let actionBtn_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        btn.layer.cornerRadius = 18
        return btn
    }()

    // MARK: - 内容区 ScrollView

    private let scrollView_Doze: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentView_Doze = UIView()

    // MARK: - 作者行

    private let authorAvatarView_Doze = UserAvatarView_Doze()

    private let authorNameLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        lbl.textColor = .white
        return lbl
    }()

    private let petBadge_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        lbl.textColor = UIColor.white.withAlphaComponent(0.7)
        lbl.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        lbl.layer.cornerRadius = 8
        lbl.clipsToBounds = true
        lbl.textAlignment = .center
        return lbl
    }()

    // MARK: - 媒体展示

    private let mediaView_Doze = MediaDisplayView_Doze()

    // MARK: - 内容卡片

    private let contentCard_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 24
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 16
        v.layer.shadowOpacity = 1
        return v
    }()

    private let postTitleLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lbl.textColor = ColorConfig_Doze.textPrimary_Doze
        lbl.numberOfLines = 0
        return lbl
    }()

    private let postContentLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = ColorConfig_Doze.textSecondary_Doze
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()

    // MARK: - 点赞行

    private let likesIcon_Doze: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        iv.image = UIImage(systemName: "heart.fill", withConfiguration: cfg)
        iv.tintColor = ColorConfig_Doze.secondaryGradientStart_Doze
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let likesLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl.textColor = ColorConfig_Doze.textSecondary_Doze
        lbl.setContentHuggingPriority(.required, for: .horizontal)
        lbl.setContentCompressionResistancePriority(.required, for: .horizontal)
        return lbl
    }()

    /// 透明点赞按钮，覆盖图标与数字区域，触发点赞/取消点赞
    private let likeBtn_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        return btn
    }()

    // MARK: - 评论区

    /// 评论区标题行（"Comments" + 数量）
    private let commentHeaderLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = ColorConfig_Doze.textPrimary_Doze
        return lbl
    }()

    /// 评论列表容器（动态添加子视图）
    private let commentsContainer_Doze = UIView()

    // MARK: - 底部评论输入栏

    private let inputBar_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: -2)
        v.layer.shadowRadius = 12
        v.layer.shadowOpacity = 1
        return v
    }()

    private let commentTextField_Doze: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Add a comment..."
        tf.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tf.textColor = ColorConfig_Doze.textPrimary_Doze
        tf.backgroundColor = UIColor(hexstring_Doze: "#F7F5FF")
        tf.layer.cornerRadius = 20
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        tf.leftViewMode = .always
        tf.returnKeyType = .send
        return tf
    }()

    private let sendBtn_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = ColorConfig_Doze.primaryGradientStart_Doze
        btn.layer.cornerRadius = 20
        return btn
    }()

    // MARK: - 送礼按钮

    /// 送礼按钮，位于发送按钮左侧 10pt，使用 gift_btn 图标
    private let giftBtn_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "gift_btn")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Doze: "#F7F5FF")
        setupHero_Doze()
        setupScrollView_Doze()
        setupInputBar_Doze()
        setupNotifications_Doze()
        loadData_Doze()
        setupKeyboardDismiss_Doze()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heroGradient_Doze.frame = heroBg_Doze.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 通知监听

    /// 注册 TitleViewModel 数据变更通知，自动刷新页面
    private func setupNotifications_Doze() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDataChanged_Doze),
            name: TitleViewModel_Doze.titleStateDidChangeNotification_Doze,
            object: nil
        )
    }

    /// 数据变更时拉取最新帖子并刷新 UI
    @objc private func onDataChanged_Doze() {
        reloadPost_Doze()
    }

    /// 从 TitleViewModel 同步最新帖子数据
    private func reloadPost_Doze() {
        guard let current_Doze = titleModel_Doze else { return }
        let latest_Doze = TitleViewModel_Doze.shared_Doze.getPosts_Doze()
            .first(where: { $0.titleId_Doze == current_Doze.titleId_Doze })
        if let latest_Doze = latest_Doze {
            titleModel_Doze = latest_Doze
        }
        loadData_Doze()
    }

    // MARK: - 顶部横幅搭建

    private func setupHero_Doze() {
        view.addSubview(heroBg_Doze)
        heroBg_Doze.layer.addSublayer(heroGradient_Doze)
        // 高度由内部内容撑开，不固定，避免中间出现大空白
        heroBg_Doze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }

        // 返回按钮
        heroBg_Doze.addSubview(backBtn_Doze)
        backBtn_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.width.height.equalTo(36)
        }
        backBtn_Doze.addTarget(self, action: #selector(backTapped_Doze), for: .touchUpInside)

        // 操作按钮
        heroBg_Doze.addSubview(actionBtn_Doze)
        actionBtn_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(backBtn_Doze)
            make.width.height.equalTo(36)
        }
        actionBtn_Doze.addTarget(self, action: #selector(actionTapped_Doze), for: .touchUpInside)

        // 作者行：紧跟在导航按钮下方，不留大空隙
        heroBg_Doze.addSubview(authorAvatarView_Doze)
        authorAvatarView_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(backBtn_Doze.snp.bottom).offset(14)
            make.width.height.equalTo(44)
        }

        heroBg_Doze.addSubview(authorNameLabel_Doze)
        authorNameLabel_Doze.snp.makeConstraints { make in
            make.left.equalTo(authorAvatarView_Doze.snp.right).offset(10)
            make.centerY.equalTo(authorAvatarView_Doze).offset(-8)
        }

        heroBg_Doze.addSubview(petBadge_Doze)
        petBadge_Doze.snp.makeConstraints { make in
            make.left.equalTo(authorAvatarView_Doze.snp.right).offset(10)
            make.top.equalTo(authorNameLabel_Doze.snp.bottom).offset(4)
            make.height.equalTo(18)
            // 撑开横幅底部高度
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    // MARK: - ScrollView 搭建

    private func setupScrollView_Doze() {
        view.addSubview(scrollView_Doze)
        scrollView_Doze.snp.makeConstraints { make in
            make.top.equalTo(heroBg_Doze.snp.bottom).offset(-20)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-inputBarHeight_Doze)
        }

        scrollView_Doze.addSubview(contentView_Doze)
        contentView_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        setupContentCard_Doze()
    }

    /// 搭建内容卡片
    private func setupContentCard_Doze() {
        // 媒体视图（圆角卡片内上方）
        contentView_Doze.addSubview(mediaView_Doze)
        mediaView_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(220)
        }

        // 内容卡片
        contentView_Doze.addSubview(contentCard_Doze)
        contentCard_Doze.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Doze.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
        }

        contentCard_Doze.addSubview(postTitleLabel_Doze)
        postTitleLabel_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(16)
        }

        contentCard_Doze.addSubview(postContentLabel_Doze)
        postContentLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(postTitleLabel_Doze.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
        }

        // 分隔线
        let sep_Doze = UIView()
        sep_Doze.backgroundColor = ColorConfig_Doze.divider_Doze
        contentCard_Doze.addSubview(sep_Doze)
        sep_Doze.snp.makeConstraints { make in
            make.top.equalTo(postContentLabel_Doze.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(0.5)
        }

        // 点赞行
        contentCard_Doze.addSubview(likesIcon_Doze)
        contentCard_Doze.addSubview(likesLabel_Doze)
        likesIcon_Doze.snp.makeConstraints { make in
            make.top.equalTo(sep_Doze.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(22)
            make.bottom.equalToSuperview().offset(-14)
        }
        likesLabel_Doze.snp.makeConstraints { make in
            make.left.equalTo(likesIcon_Doze.snp.right).offset(6)
            make.centerY.equalTo(likesIcon_Doze)
        }

        // 透明点赞按钮：覆盖图标与数字，允许整体点击
        contentCard_Doze.addSubview(likeBtn_Doze)
        likeBtn_Doze.snp.makeConstraints { make in
            make.left.equalTo(likesIcon_Doze)
            make.right.equalTo(likesLabel_Doze.snp.right).offset(8)
            make.centerY.equalTo(likesIcon_Doze)
            make.height.equalTo(36)
        }
        likeBtn_Doze.addTarget(self, action: #selector(handleLikeTap_Doze), for: .touchUpInside)

        // 评论区容器
        contentView_Doze.addSubview(commentHeaderLabel_Doze)
        commentHeaderLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(contentCard_Doze.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(20)
        }

        contentView_Doze.addSubview(commentsContainer_Doze)
        commentsContainer_Doze.snp.makeConstraints { make in
            make.top.equalTo(commentHeaderLabel_Doze.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    // MARK: - 底部输入栏

    private func setupInputBar_Doze() {
        view.addSubview(inputBar_Doze)
        inputBar_Doze.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(inputBarHeight_Doze + view.safeAreaInsets.bottom)
        }

        // 发送按钮：固定在最右侧
        inputBar_Doze.addSubview(sendBtn_Doze)
        sendBtn_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(40)
        }
        sendBtn_Doze.addTarget(self, action: #selector(sendComment_Doze), for: .touchUpInside)

        // 送礼按钮：发送按钮左侧 10pt
        inputBar_Doze.addSubview(giftBtn_Doze)
        giftBtn_Doze.snp.makeConstraints { make in
            make.right.equalTo(sendBtn_Doze.snp.left).offset(-10)
            make.centerY.equalTo(sendBtn_Doze)
            make.width.height.equalTo(40)
        }
        giftBtn_Doze.addTarget(self, action: #selector(handleGift_Doze), for: .touchUpInside)

        // 输入框：左侧固定，右侧延伸至送礼按钮左侧 8pt
        inputBar_Doze.addSubview(commentTextField_Doze)
        commentTextField_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(giftBtn_Doze.snp.left).offset(-8)
            make.centerY.equalTo(sendBtn_Doze)
            make.height.equalTo(40)
        }
        commentTextField_Doze.delegate = self
    }

    // MARK: - 数据加载

    /// 加载所有数据并刷新 UI
    private func loadData_Doze() {
        guard let post_Doze = titleModel_Doze else { return }

        // 更新操作按钮图标（自己的帖子 = 删除，他人的 = 举报）
        let isOwner_Doze = UserViewModel_Doze.shared_Doze.isCurrentUser_Doze(
            userId_doze: post_Doze.titleUserId_Doze
        )
        let iconName_Doze = isOwner_Doze ? "trash" : "exclamationmark.triangle"
        let cfg_Doze = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        actionBtn_Doze.setImage(UIImage(systemName: iconName_Doze, withConfiguration: cfg_Doze), for: .normal)

        // 作者信息
        authorAvatarView_Doze.configure_Doze(userId_Doze: post_Doze.titleUserId_Doze)
        authorNameLabel_Doze.text = post_Doze.titleUserName_Doze
        petBadge_Doze.text = "  \(post_Doze.petCategory_Doze.rawValue)  "

        // 媒体
        mediaView_Doze.configure_Doze(mediaPath_Doze: post_Doze.titleMeidas_Doze.first)

        // 标题 / 内容
        postTitleLabel_Doze.text = post_Doze.title_Doze
        postContentLabel_Doze.text = post_Doze.titleContent_Doze

        // 点赞（同步图标颜色：已点赞为主题色，未点赞为次要色）
        likesLabel_Doze.text = "\(post_Doze.likes_Doze) likes"
        let isLiked_Doze = TitleViewModel_Doze.shared_Doze.isLikedPost_Doze(post_doze: post_Doze)
        likesIcon_Doze.tintColor = isLiked_Doze
            ? ColorConfig_Doze.primaryGradientStart_Doze
            : ColorConfig_Doze.secondaryGradientStart_Doze

        // 评论
        let count_Doze = post_Doze.reviews_Doze.count
        commentHeaderLabel_Doze.text = "Comments (\(count_Doze))"
        refreshComments_Doze(post_Doze: post_Doze)
    }

    /// 清空并重建评论列表视图
    private func refreshComments_Doze(post_Doze: TitleModel_Doze) {
        commentsContainer_Doze.subviews.forEach { $0.removeFromSuperview() }

        if post_Doze.reviews_Doze.isEmpty {
            let emptyLbl_Doze = UILabel()
            emptyLbl_Doze.text = "No comments yet. Be the first! 🐾"
            emptyLbl_Doze.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            emptyLbl_Doze.textColor = ColorConfig_Doze.textPlaceholder_Doze
            emptyLbl_Doze.textAlignment = .center
            commentsContainer_Doze.addSubview(emptyLbl_Doze)
            emptyLbl_Doze.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(20)
                make.centerX.equalToSuperview()
            }
            return
        }

        var prevView_Doze: UIView? = nil
        for comment_Doze in post_Doze.reviews_Doze {
            let row_Doze = buildCommentRow_Doze(comment_Doze: comment_Doze, post_Doze: post_Doze)
            commentsContainer_Doze.addSubview(row_Doze)
            row_Doze.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                if let prev_Doze = prevView_Doze {
                    make.top.equalTo(prev_Doze.snp.bottom).offset(2)
                } else {
                    make.top.equalToSuperview()
                }
            }
            prevView_Doze = row_Doze
        }
        prevView_Doze?.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
        }
    }

    /// 构建单条评论视图
    /// - Parameters:
    ///   - comment_Doze: 评论模型
    ///   - post_Doze: 所属帖子（举报/删除时需要传递）
    /// - Returns: 评论行视图
    private func buildCommentRow_Doze(
        comment_Doze: Comment_Doze,
        post_Doze: TitleModel_Doze
    ) -> UIView {
        let row_Doze = UIView()
        row_Doze.backgroundColor = .white
        row_Doze.layer.cornerRadius = 16

        // 头像
        let avatar_Doze = UserAvatarView_Doze()
        avatar_Doze.configure_Doze(userId_Doze: comment_Doze.commentUserId_Doze)
        row_Doze.addSubview(avatar_Doze)
        avatar_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(14)
            make.width.height.equalTo(34)
        }

        // 用户名
        let nameLbl_Doze = UILabel()
        nameLbl_Doze.text = comment_Doze.commentUserName_Doze
        nameLbl_Doze.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        nameLbl_Doze.textColor = ColorConfig_Doze.textPrimary_Doze
        row_Doze.addSubview(nameLbl_Doze)
        nameLbl_Doze.snp.makeConstraints { make in
            make.left.equalTo(avatar_Doze.snp.right).offset(10)
            make.top.equalTo(avatar_Doze)
        }

        // 评论内容
        let contentLbl_Doze = UILabel()
        contentLbl_Doze.text = comment_Doze.commentContent_Doze
        contentLbl_Doze.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        contentLbl_Doze.textColor = ColorConfig_Doze.textSecondary_Doze
        contentLbl_Doze.numberOfLines = 0
        row_Doze.addSubview(contentLbl_Doze)
        contentLbl_Doze.snp.makeConstraints { make in
            make.left.equalTo(nameLbl_Doze)
            make.top.equalTo(nameLbl_Doze.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-14)
        }

        // 举报/删除按钮 — 使用 ReportDeleteHelper_Doze 统一处理
        let moreBtn_Doze = ReportDeleteHelper_Doze.createCommentReportButton_Doze(
            comment_Doze: comment_Doze,
            post_Doze: post_Doze,
            size_Doze: 12,
            color_Doze: ColorConfig_Doze.textPlaceholder_Doze,
            from: self
        ) { [weak self] in
            self?.reloadPost_Doze()
        }
        row_Doze.addSubview(moreBtn_Doze)
        moreBtn_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.width.height.equalTo(28)
        }
        contentLbl_Doze.snp.makeConstraints { make in
            make.right.equalTo(moreBtn_Doze.snp.left).offset(-8)
        }

        return row_Doze
    }

    // MARK: - 事件处理

    /// 返回按钮
    @objc private func backTapped_Doze() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Doze.pop_Doze()
    }

    /// 帖子举报/删除按钮 — 统一使用 ReportDeleteHelper_Doze
    @objc private func actionTapped_Doze() {
        guard let post_Doze = titleModel_Doze else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        let isOwner_Doze = UserViewModel_Doze.shared_Doze.isCurrentUser_Doze(
            userId_doze: post_Doze.titleUserId_Doze
        )
        if isOwner_Doze {
            ReportDeleteHelper_Doze.delete_Doze(
                post_Doze: post_Doze,
                from: self
            ) {
                Navigation_Doze.pop_Doze()
            }
        } else {
            ReportDeleteHelper_Doze.report_Doze(
                post_Doze: post_Doze,
                from: self
            ) {
                Navigation_Doze.pop_Doze()
            }
        }
    }

    /// 点击点赞图标 → 调用 TitleViewModel 点赞/取消点赞并刷新图标颜色
    @objc private func handleLikeTap_Doze() {
        guard let post_Doze = titleModel_Doze else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        TitleViewModel_Doze.shared_Doze.likePost_Doze(post_doze: post_Doze)
        likesIcon_Doze.animatePulse_Doze()
    }

    /// 点击送礼按钮 → 以 overFullScreen 方式弹起礼物界面（GiftView_Doze 自带入场动画）
    @objc private func handleGift_Doze() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        giftBtn_Doze.animatePulse_Doze()
        let giftVC_Doze = GiftView_Doze()
        giftVC_Doze.modalPresentationStyle = .overFullScreen
        giftVC_Doze.modalTransitionStyle   = .crossDissolve
        present(giftVC_Doze, animated: false)
    }

    @objc private func sendComment_Doze() {
        guard let post_Doze = titleModel_Doze else { return }
        let text_Doze = (commentTextField_Doze.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text_Doze.isEmpty else { return }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        TitleViewModel_Doze.shared_Doze.releaseComment_Doze(
            post_doze: post_Doze,
            content_doze: text_Doze
        )
        commentTextField_Doze.text = nil
        view.endEditing(true)
        // 通知已触发 reloadPost_Doze 自动刷新
    }

    // MARK: - 键盘

    private func setupKeyboardDismiss_Doze() {
        let tap_Doze = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Doze))
        tap_Doze.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Doze)
    }

    @objc private func dismissKeyboard_Doze() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate

extension Detail_Doze: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendComment_Doze()
        return true
    }
}
