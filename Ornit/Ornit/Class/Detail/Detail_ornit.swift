import UIKit
import SnapKit

// MARK: 帖子详情页面

/// 帖子详情页面
/// 功能：展示帖子全文、媒体、点赞、评论列表，右上角举报/删除按钮，底部评论输入框
/// 设计：全宽媒体区 + 白色浮起内容卡片（上圆角叠于媒体之上）+ 森绿色点赞/评论交互 + 底部输入栏
class Detail_Ornit: UIViewController {

    // MARK: - 公共属性

    /// 帖子模型（由导航传入）
    var titleModel_Ornit: TitleModel_Ornit?

    // MARK: - 私有数据属性

    /// 当前帖子最新数据（从 TitleViewModel 查找，支持实时刷新）
    private var currentPost_Ornit: TitleModel_Ornit? {
        guard let id_ornit = titleModel_Ornit?.titleId_Ornit else { return titleModel_Ornit }
        return TitleViewModel_Ornit.shared_Ornit.getPosts_Ornit().first { $0.titleId_Ornit == id_ornit }
            ?? titleModel_Ornit
    }

    // MARK: - 容器组件

    private let scrollView_Ornit = UIScrollView()
    private let contentView_Ornit = UIView()

    /// 白色内容卡片（叠于媒体区下方，上圆角）
    private let contentCard_Ornit = UIView()

    // MARK: - 媒体区组件

    /// 媒体展示视图（全宽，占顶部 290pt）
    private let mediaView_Ornit = MediaDisplayView_Ornit()

    /// 顶部浮层导航（返回 + 举报按钮，叠加于媒体上方）
    private let overlayNav_Ornit = UIView()

    /// 顶部渐变遮罩图层（保证按钮在任何媒体背景下清晰可见）
    private var overlayGradient_Ornit: CAGradientLayer?

    // MARK: - 内容区组件

    /// 帖子标题
    private let postTitleLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 22, weight: .black)
        label_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        label_ornit.numberOfLines = 0
        return label_ornit
    }()

    /// 发布者信息行（可点击跳转用户中心）
    private let authorRow_Ornit = UIView()
    private let authorAvatarView_Ornit = UserAvatarView_Ornit()

    private let authorNameLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label_ornit.textColor = ColorConfig_Ornit.textSecondary_Ornit
        return label_ornit
    }()

    /// "View Profile" 小标签
    private let viewProfileChip_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.text = "View Profile →"
        label_ornit.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label_ornit.textColor = ColorConfig_Ornit.naturePrimary_Ornit
        return label_ornit
    }()

    /// 帖子正文内容
    private let postContentLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label_ornit.textColor = ColorConfig_Ornit.textSecondary_Ornit
        label_ornit.numberOfLines = 0
        label_ornit.lineBreakMode = .byWordWrapping
        return label_ornit
    }()

    // MARK: - 点赞/评论统计行

    private let likeRow_Ornit = UIView()

    /// 点赞按钮（心形，点击触发动画）
    private let likeButton_Ornit: UIButton = {
        let btn_ornit = UIButton(type: .system)
        let config_ornit = UIImage.SymbolConfiguration(pointSize: 19, weight: .medium)
        btn_ornit.setImage(UIImage(systemName: "heart", withConfiguration: config_ornit), for: .normal)
        btn_ornit.setImage(UIImage(systemName: "heart.fill", withConfiguration: config_ornit), for: .selected)
        btn_ornit.tintColor = UIColor(hexstring_Ornit: "#FC8181")
        return btn_ornit
    }()

    /// 点赞数量标签
    private let likeCountLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label_ornit.textColor = ColorConfig_Ornit.textSecondary_Ornit
        return label_ornit
    }()

    /// 评论数图标
    private let commentIconView_Ornit: UIImageView = {
        let config_ornit = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        let iv_ornit = UIImageView(
            image: UIImage(systemName: "bubble.left", withConfiguration: config_ornit)
        )
        iv_ornit.tintColor = ColorConfig_Ornit.natureTeal_Ornit
        iv_ornit.contentMode = .scaleAspectFit
        return iv_ornit
    }()

    /// 评论数量标签
    private let commentCountLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label_ornit.textColor = ColorConfig_Ornit.textSecondary_Ornit
        return label_ornit
    }()

    // MARK: - 评论区组件

    /// 评论区分割线
    private let commentDivider_Ornit: UIView = {
        let v_ornit = UIView()
        v_ornit.backgroundColor = ColorConfig_Ornit.divider_Ornit
        return v_ornit
    }()

    /// 评论区标题标签（含图标和数量）
    private let commentTitleLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        return label_ornit
    }()

    /// 评论列表纵向容器
    private let commentsStack_Ornit: UIStackView = {
        let sv_ornit = UIStackView()
        sv_ornit.axis = .vertical
        sv_ornit.spacing = 10
        return sv_ornit
    }()

    /// 无评论时的空状态提示
    private let noCommentLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.text = "No comments yet. Be the first!"
        label_ornit.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label_ornit.textColor = ColorConfig_Ornit.textPlaceholder_Ornit
        label_ornit.textAlignment = .center
        label_ornit.isHidden = true
        return label_ornit
    }()

    // MARK: - 底部输入栏组件

    /// 底部评论输入容器
    private let commentInputContainer_Ornit = UIView()

    /// 评论输入框（森绿色浅底背景）
    private let commentField_Ornit: UITextField = {
        let tf_ornit = UITextField()
        tf_ornit.placeholder = "Add a comment..."
        tf_ornit.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tf_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        tf_ornit.backgroundColor = ColorConfig_Ornit.tagBackground_Ornit
        tf_ornit.layer.cornerRadius = 20
        tf_ornit.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        tf_ornit.leftViewMode = .always
        tf_ornit.returnKeyType = .send
        return tf_ornit
    }()

    /// 发送评论按钮（森绿色圆形）
    private let sendCommentButton_Ornit: UIButton = {
        let btn_ornit = UIButton(type: .custom)
        let config_ornit = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        btn_ornit.setImage(
            UIImage(systemName: "arrow.up", withConfiguration: config_ornit),
            for: .normal
        )
        btn_ornit.tintColor = .white
        btn_ornit.backgroundColor = ColorConfig_Ornit.naturePrimary_Ornit
        btn_ornit.layer.cornerRadius = 20
        return btn_ornit
    }()

    /// 输入栏底部约束（键盘弹起时动态更新）
    private var inputBottomConstraint_Ornit: Constraint?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Ornit.backgroundNature_Ornit
        setupScrollView_Ornit()
        setupMediaSection_Ornit()
        setupContentSection_Ornit()
        setupCommentSection_Ornit()
        setupInputBar_Ornit()
        setupOverlayNav_Ornit()
        setupNotifications_Ornit()
        refreshUI_Ornit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overlayGradient_Ornit?.frame = overlayNav_Ornit.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 通知监听

    private func setupNotifications_Ornit() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTitleChange_Ornit),
            name: TitleViewModel_Ornit.titleStateDidChangeNotification_Ornit,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Ornit(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Ornit(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func handleTitleChange_Ornit() {
        // 帖子被删除时自动返回上一页
        if currentPost_Ornit == nil {
            Navigation_Ornit.pop_Ornit(animated: true)
            return
        }
        refreshUI_Ornit()
    }

    @objc private func keyboardWillShow_Ornit(_ notification: Notification) {
        guard let frame_ornit = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let duration_ornit = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        UIView.animate(withDuration: duration_ornit) {
            self.inputBottomConstraint_Ornit?.update(offset: -frame_ornit.height + self.view.safeAreaInsets.bottom)
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide_Ornit(_ notification: Notification) {
        let duration_ornit = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        UIView.animate(withDuration: duration_ornit) {
            self.inputBottomConstraint_Ornit?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - 数据刷新

    private func refreshUI_Ornit() {
        guard let post_ornit = currentPost_Ornit else { return }

        let mediaPath_ornit = post_ornit.titleMeidas_Ornit.first
        mediaView_Ornit.configure_Ornit(mediaPath_Ornit: mediaPath_ornit)

        postTitleLabel_Ornit.text = post_ornit.title_Ornit
        postContentLabel_Ornit.text = post_ornit.titleContent_Ornit
        authorAvatarView_Ornit.configure_Ornit(userId_Ornit: post_ornit.titleUserId_Ornit)
        authorNameLabel_Ornit.text = post_ornit.titleUserName_Ornit
        likeCountLabel_Ornit.text = "\(post_ornit.likes_Ornit)"
        commentCountLabel_Ornit.text = "\(post_ornit.reviews_Ornit.count)"
        likeButton_Ornit.isSelected = TitleViewModel_Ornit.shared_Ornit.isLikedPost_Ornit(post_ornit: post_ornit)

        refreshComments_Ornit(post_ornit: post_ornit)
    }

    /// 刷新评论列表并更新评论区标题计数
    /// 自动过滤已被举报（从本地用户列表移除）的用户所发评论
    private func refreshComments_Ornit(post_ornit: TitleModel_Ornit) {
        commentsStack_Ornit.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let currentUserId_ornit = UserViewModel_Ornit.shared_Ornit.getCurrentUser_Ornit().userId_Ornit ?? -1
        let activeUserIds_ornit = Set(
            LocalData_Ornit.shared_Ornit.userList_Ornit.compactMap { $0.userId_Ornit }
        )

        // 过滤掉已被举报移除的用户评论（保留当前登录用户自己的评论）
        let visibleComments_ornit = post_ornit.reviews_Ornit.filter { comment_ornit in
            comment_ornit.commentUserId_Ornit == currentUserId_ornit ||
            activeUserIds_ornit.contains(comment_ornit.commentUserId_Ornit)
        }

        noCommentLabel_Ornit.isHidden = !visibleComments_ornit.isEmpty
        commentTitleLabel_Ornit.text = "Comments (\(visibleComments_ornit.count))"

        for comment_ornit in visibleComments_ornit {
            commentsStack_Ornit.addArrangedSubview(
                makeCommentCell_Ornit(comment_ornit: comment_ornit, post_ornit: post_ornit)
            )
        }
    }

    // MARK: - UI 搭建

    /// 构建全页滚动容器
    private func setupScrollView_Ornit() {
        scrollView_Ornit.showsVerticalScrollIndicator = false
        scrollView_Ornit.contentInsetAdjustmentBehavior = .never
        scrollView_Ornit.keyboardDismissMode = .interactive
        scrollView_Ornit.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        view.addSubview(scrollView_Ornit)
        scrollView_Ornit.addSubview(contentView_Ornit)

        scrollView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview()
        }
        contentView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview()
            make_ornit.width.equalToSuperview()
        }
    }

    /// 构建顶部全宽媒体展示区（290pt）
    private func setupMediaSection_Ornit() {
        contentView_Ornit.addSubview(mediaView_Ornit)
        mediaView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(290)
        }
    }

    /// 构建白色内容卡片及帖子信息区（标题/发布者/正文/点赞统计）
    private func setupContentSection_Ornit() {
        // 白色浮起内容卡片，上圆角叠于媒体底部
        contentCard_Ornit.backgroundColor = .white
        contentCard_Ornit.layer.cornerRadius = 24
        contentCard_Ornit.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentCard_Ornit.layer.shadowColor = UIColor.black.withValues(alpha: 0.06).cgColor
        contentCard_Ornit.layer.shadowOffset = CGSize(width: 0, height: -4)
        contentCard_Ornit.layer.shadowOpacity = 1
        contentCard_Ornit.layer.shadowRadius = 8
        contentView_Ornit.addSubview(contentCard_Ornit)

        contentCard_Ornit.addSubview(postTitleLabel_Ornit)

        // 发布者行（头像 + 昵称 + "View Profile" 跳转提示）
        authorRow_Ornit.addSubview(authorAvatarView_Ornit)
        authorRow_Ornit.addSubview(authorNameLabel_Ornit)
        authorRow_Ornit.addSubview(viewProfileChip_Ornit)
        contentCard_Ornit.addSubview(authorRow_Ornit)

        contentCard_Ornit.addSubview(postContentLabel_Ornit)

        // 点赞与评论统计行
        likeRow_Ornit.addSubview(likeButton_Ornit)
        likeRow_Ornit.addSubview(likeCountLabel_Ornit)

        // 竖向分隔
        let statDivider_ornit = UIView()
        statDivider_ornit.backgroundColor = ColorConfig_Ornit.divider_Ornit
        likeRow_Ornit.addSubview(statDivider_ornit)

        likeRow_Ornit.addSubview(commentIconView_Ornit)
        likeRow_Ornit.addSubview(commentCountLabel_Ornit)
        contentCard_Ornit.addSubview(likeRow_Ornit)

        // 约束
        contentCard_Ornit.snp.makeConstraints { make_ornit in
            // 卡片顶部叠入媒体区 26pt，制造浮起效果
            make_ornit.top.equalTo(mediaView_Ornit.snp.bottom).offset(-26)
            make_ornit.leading.trailing.equalToSuperview()
        }

        postTitleLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalToSuperview().offset(28)
            make_ornit.leading.equalToSuperview().offset(20)
            make_ornit.trailing.equalToSuperview().offset(-20)
        }

        authorRow_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(postTitleLabel_Ornit.snp.bottom).offset(14)
            make_ornit.leading.equalToSuperview().offset(20)
            make_ornit.trailing.equalToSuperview().offset(-20)
            make_ornit.height.equalTo(38)
        }

        authorAvatarView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.centerY.equalToSuperview()
            make_ornit.width.height.equalTo(34)
        }

        authorNameLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(authorAvatarView_Ornit.snp.trailing).offset(8)
            make_ornit.centerY.equalToSuperview()
        }

        viewProfileChip_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview()
            make_ornit.centerY.equalToSuperview()
        }

        postContentLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(authorRow_Ornit.snp.bottom).offset(14)
            make_ornit.leading.equalToSuperview().offset(20)
            make_ornit.trailing.equalToSuperview().offset(-20)
        }

        likeRow_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(postContentLabel_Ornit.snp.bottom).offset(18)
            make_ornit.leading.equalToSuperview().offset(20)
            make_ornit.height.equalTo(38)
        }

        likeButton_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.centerY.equalToSuperview()
            make_ornit.width.height.equalTo(30)
        }

        likeCountLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(likeButton_Ornit.snp.trailing).offset(4)
            make_ornit.centerY.equalToSuperview()
        }

        statDivider_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(likeCountLabel_Ornit.snp.trailing).offset(14)
            make_ornit.centerY.equalToSuperview()
            make_ornit.width.equalTo(1)
            make_ornit.height.equalTo(18)
        }

        commentIconView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(statDivider_ornit.snp.trailing).offset(14)
            make_ornit.centerY.equalToSuperview()
            make_ornit.width.height.equalTo(20)
        }

        commentCountLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(commentIconView_Ornit.snp.trailing).offset(5)
            make_ornit.centerY.equalToSuperview()
            make_ornit.trailing.equalToSuperview()
        }

        likeButton_Ornit.addTarget(self, action: #selector(likeTapped_Ornit), for: .touchUpInside)

        authorRow_Ornit.isUserInteractionEnabled = true
        authorRow_Ornit.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(authorTapped_Ornit))
        )
    }

    /// 构建评论区（分割线 + 标题 + 评论列表 + 空状态）
    private func setupCommentSection_Ornit() {
        contentCard_Ornit.addSubview(commentDivider_Ornit)
        contentCard_Ornit.addSubview(commentTitleLabel_Ornit)
        contentCard_Ornit.addSubview(commentsStack_Ornit)
        contentCard_Ornit.addSubview(noCommentLabel_Ornit)

        commentDivider_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(likeRow_Ornit.snp.bottom).offset(18)
            make_ornit.leading.equalToSuperview().offset(20)
            make_ornit.trailing.equalToSuperview().offset(-20)
            make_ornit.height.equalTo(0.5)
        }

        commentTitleLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(commentDivider_Ornit.snp.bottom).offset(18)
            make_ornit.leading.equalToSuperview().offset(20)
        }

        commentsStack_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(commentTitleLabel_Ornit.snp.bottom).offset(14)
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.bottom.equalToSuperview().offset(-24)
        }

        noCommentLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(commentTitleLabel_Ornit.snp.bottom).offset(20)
            make_ornit.centerX.equalToSuperview()
        }

        // contentCard 的底部决定 contentView 的高度
        contentCard_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.bottom.equalToSuperview()
        }
    }

    /// 构建浮层顶部导航（返回 + 举报按钮，带渐变遮罩保证可见性）
    private func setupOverlayNav_Ornit() {
        view.addSubview(overlayNav_Ornit)
        overlayNav_Ornit.backgroundColor = .clear

        // 顶部暗色渐变遮罩，确保按钮在任何媒体背景上清晰可见
        let gradient_ornit = CAGradientLayer()
        gradient_ornit.colors = [
            UIColor.black.withValues(alpha: 0.38).cgColor,
            UIColor.clear.cgColor
        ]
        gradient_ornit.startPoint = CGPoint(x: 0.5, y: 0)
        gradient_ornit.endPoint = CGPoint(x: 0.5, y: 1)
        overlayNav_Ornit.layer.insertSublayer(gradient_ornit, at: 0)
        overlayGradient_Ornit = gradient_ornit

        let backView_ornit = BackButton_Ornit()
        backView_ornit.onTapped_Ornit = { [weak self] in
            Navigation_Ornit.pop_Ornit(from: self)
        }
        overlayNav_Ornit.addSubview(backView_ornit)

        overlayNav_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalToSuperview()
            make_ornit.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(100)
        }

        backView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make_ornit.width.height.equalTo(40)
        }

        // 举报/删除按钮（右上角）
        if let post_ornit = titleModel_Ornit {
            let reportBtn_ornit = ReportDeleteHelper_Ornit.createPostReportButton_Ornit(
                post_Ornit: post_ornit,
                size_Ornit: 18,
                color_Ornit: .white,
                from: self,
                completion_Ornit: { [weak self] in
                    guard let self = self else { return }
                    Navigation_Ornit.pop_Ornit(from: self)
                }
            )
            overlayNav_Ornit.addSubview(reportBtn_ornit)
            reportBtn_ornit.snp.makeConstraints { make_ornit in
                make_ornit.trailing.equalToSuperview().offset(-16)
                make_ornit.centerY.equalTo(backView_ornit)
                make_ornit.width.height.equalTo(36)
            }
        }
    }

    /// 构建底部评论输入栏（白色背景 + 森绿色主题）
    private func setupInputBar_Ornit() {
        commentInputContainer_Ornit.backgroundColor = .white
        commentInputContainer_Ornit.layer.shadowColor = UIColor.black.withValues(alpha: 0.05).cgColor
        commentInputContainer_Ornit.layer.shadowOffset = CGSize(width: 0, height: -2)
        commentInputContainer_Ornit.layer.shadowOpacity = 1
        commentInputContainer_Ornit.layer.shadowRadius = 6
        view.addSubview(commentInputContainer_Ornit)

        // 顶部分割线
        let topLine_ornit = UIView()
        topLine_ornit.backgroundColor = ColorConfig_Ornit.divider_Ornit
        commentInputContainer_Ornit.addSubview(topLine_ornit)

        commentInputContainer_Ornit.addSubview(commentField_Ornit)
        commentInputContainer_Ornit.addSubview(sendCommentButton_Ornit)

        commentInputContainer_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(62)
            inputBottomConstraint_Ornit = make_ornit.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).constraint
        }

        topLine_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(0.5)
        }

        sendCommentButton_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-14)
            make_ornit.centerY.equalToSuperview()
            make_ornit.width.height.equalTo(40)
        }

        commentField_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(14)
            make_ornit.trailing.equalTo(sendCommentButton_Ornit.snp.leading).offset(-10)
            make_ornit.centerY.equalToSuperview()
            make_ornit.height.equalTo(40)
        }

        commentField_Ornit.delegate = self
        sendCommentButton_Ornit.addTarget(self, action: #selector(sendCommentTapped_Ornit), for: .touchUpInside)
    }

    // MARK: - 辅助方法

    /// 创建评论卡片（头像 + 昵称 + 内容 + 举报按钮）
    /// - Parameters:
    ///   - comment_ornit: 评论数据
    ///   - post_ornit: 所属帖子（用于举报）
    /// - Returns: 配置完成的评论卡片 UIView
    private func makeCommentCell_Ornit(comment_ornit: Comment_Ornit, post_ornit: TitleModel_Ornit) -> UIView {
        let card_ornit = UIView()
        card_ornit.backgroundColor = .white
        card_ornit.layer.cornerRadius = 14
        card_ornit.layer.shadowColor = ColorConfig_Ornit.natureTeal_Ornit.withValues(alpha: 0.1).cgColor
        card_ornit.layer.shadowOffset = CGSize(width: 0, height: 2)
        card_ornit.layer.shadowOpacity = 1
        card_ornit.layer.shadowRadius = 5

        let avatarView_ornit = UserAvatarView_Ornit()
        avatarView_ornit.configure_Ornit(userId_Ornit: comment_ornit.commentUserId_Ornit)
        card_ornit.addSubview(avatarView_ornit)

        let nameLabel_ornit = UILabel()
        nameLabel_ornit.text = comment_ornit.commentUserName_Ornit
        nameLabel_ornit.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        nameLabel_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        card_ornit.addSubview(nameLabel_ornit)

        let contentLabel_ornit = UILabel()
        contentLabel_ornit.text = comment_ornit.commentContent_Ornit
        contentLabel_ornit.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        contentLabel_ornit.textColor = ColorConfig_Ornit.textSecondary_Ornit
        contentLabel_ornit.numberOfLines = 0
        card_ornit.addSubview(contentLabel_ornit)

        let reportBtn_ornit = ReportDeleteHelper_Ornit.createCommentReportButton_Ornit(
            comment_Ornit: comment_ornit,
            post_Ornit: post_ornit,
            size_Ornit: 13,
            color_Ornit: ColorConfig_Ornit.textPlaceholder_Ornit,
            from: self,
            completion_Ornit: { [weak self] in
                self?.refreshUI_Ornit()
            }
        )
        card_ornit.addSubview(reportBtn_ornit)

        avatarView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(12)
            make_ornit.top.equalToSuperview().offset(12)
            make_ornit.width.height.equalTo(32)
        }

        nameLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(avatarView_ornit.snp.trailing).offset(8)
            make_ornit.centerY.equalTo(avatarView_ornit)
            make_ornit.trailing.equalTo(reportBtn_ornit.snp.leading).offset(-4)
        }

        reportBtn_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-10)
            make_ornit.top.equalToSuperview().offset(10)
            make_ornit.width.height.equalTo(24)
        }

        contentLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(avatarView_ornit.snp.bottom).offset(8)
            make_ornit.leading.equalToSuperview().offset(12)
            make_ornit.trailing.equalToSuperview().offset(-12)
            make_ornit.bottom.equalToSuperview().offset(-12)
        }

        return card_ornit
    }

    // MARK: - 事件处理

    /// 点赞按钮点击，触发心跳动画
    @objc private func likeTapped_Ornit() {
        guard let post_ornit = currentPost_Ornit else { return }
        UIView.animate(withDuration: 0.15, animations: {
            self.likeButton_Ornit.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.likeButton_Ornit.transform = .identity
            }
        }
        TitleViewModel_Ornit.shared_Ornit.likePost_Ornit(post_ornit: post_ornit)
    }

    /// 发布者行点击，跳转用户中心
    @objc private func authorTapped_Ornit() {
        guard let post_ornit = currentPost_Ornit else { return }
        let user_ornit = UserViewModel_Ornit.shared_Ornit.getUserById_Ornit(userId_ornit: post_ornit.titleUserId_Ornit)
        Navigation_Ornit.toUserInfo_Ornit(with: user_ornit)
    }

    /// 发送评论按钮/键盘 Return 键触发
    @objc private func sendCommentTapped_Ornit() {
        guard let text_ornit = commentField_Ornit.text?.trimmingCharacters(in: .whitespaces),
              !text_ornit.isEmpty,
              let post_ornit = currentPost_Ornit else { return }

        commentField_Ornit.text = ""
        view.endEditing(true)
        TitleViewModel_Ornit.shared_Ornit.releaseComment_Ornit(post_ornit: post_ornit, content_ornit: text_ornit)
    }
}

// MARK: - UITextFieldDelegate

extension Detail_Ornit: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendCommentTapped_Ornit()
        return true
    }
}
