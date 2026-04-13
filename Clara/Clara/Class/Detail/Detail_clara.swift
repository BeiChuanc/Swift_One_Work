import Foundation
import UIKit
import SnapKit

// MARK: - 帖子详情页

/// 帖子详情页面
/// 核心功能：展示单篇帖子的媒体、标题、内容、作者信息、点赞操作和评论列表
/// 设计思路：UITableView 多段布局（0=帖子主体, 1=评论列表）；
///           订阅 TitleViewModel 通知，数据变动时自动刷新；
///           帖子被举报/删除后弹出后页面，评论举报后删除对应评论行
/// 关键属性：
///   - titleModel_Clara: 当前展示的帖子模型（外部注入）
/// 关键方法：
///   - refreshPost_Clara: 从 ViewModel 重新拉取最新帖子数据并刷新
///   - sendComment_Clara: 发布评论
///   - likePost_Clara: 点赞/取消点赞
class Detail_Clara: UIViewController {

    // MARK: - 属性

    var titleModel_Clara: TitleModel_Clara?

    // MARK: - UI 组件

    /// 主表格视图（0 段 = 帖子头部，1 段 = 评论列表）
    private let tableView_Clara: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = ColorConfig_Clara.backgroundPrimary_Clara
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.keyboardDismissMode = .interactive
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "empty")
        tv.register(DetailHeaderCell_Clara.self, forCellReuseIdentifier: DetailHeaderCell_Clara.reuseId_Clara)
        tv.register(CommentCell_Clara.self, forCellReuseIdentifier: CommentCell_Clara.reuseId_Clara)
        return tv
    }()

    /// 底部评论输入栏（透明背景，融入主题）
    private let commentBar_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let commentField_Clara: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Add a comment..."
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = ColorConfig_Clara.textPrimary_Clara
        tf.backgroundColor = ColorConfig_Clara.backgroundPrimary_Clara
        tf.layer.cornerRadius = 18
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        tf.leftViewMode = .always
        tf.returnKeyType = .send
        return tf
    }()

    private let commentSendBtn_Clara: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        btn.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = ColorConfig_Clara.primaryGradientStart_Clara
        return btn
    }()

    /// 底部送礼按钮
    private let giftButton_Clara: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "gift_btn"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()

    private var commentBarBottomConstraint_Clara: Constraint?

    // MARK: - 生命周期

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.updateThemeBackgroundFrame_Clara()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 隐藏系统导航栏，使用自定义悬浮返回/更多按钮覆盖于媒体区
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshPost_Clara()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyThemeBackground_Clara()
        setupTableView_Clara()
        setupCommentBar_Clara()
        setupFloatingNavButtons_Clara()
        setupNotifications_Clara()
        setupKeyboardObservers_Clara()
    }

    // MARK: - 自定义悬浮导航按钮

    /// 添加悬浮于媒体区顶部的返回按钮和举报/删除按钮
    private func setupFloatingNavButtons_Clara() {
        // 返回按钮（左侧）
        let backBtn = UIButton(type: .system)
        let backCfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        backBtn.setImage(UIImage(systemName: "arrow.left", withConfiguration: backCfg), for: .normal)
        backBtn.tintColor = .white
        backBtn.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        backBtn.layer.cornerRadius = 18
        backBtn.layer.borderWidth = 1
        backBtn.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        backBtn.addTarget(self, action: #selector(backTapped_Clara), for: .touchUpInside)
        view.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }

        updateFloatingReportButton_Clara()
    }

    /// 更新右侧悬浮举报/删除按钮（刷新帖子后同步更新）
    private func updateFloatingReportButton_Clara() {
        guard let post = titleModel_Clara else { return }
        // 移除旧按钮
        view.subviews
            .filter { $0.tag == 9901 }
            .forEach { $0.removeFromSuperview() }

        let btn = ReportDeleteHelper_Clara.createPostReportButton_Clara(
            post_Clara: post,
            size_Clara: 15,
            color_Clara: .white,
            from: self
        ) { [weak self] in
            self?.handlePostRemoved_Clara()
        }
        btn.tag = 9901
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.right.equalToSuperview().inset(16)
            make.width.height.equalTo(36)
        }
    }

    // MARK: - UI 搭建

    private func setupTableView_Clara() {
        view.addSubview(tableView_Clara)
        // 透明背景，使 view 层的多拼色渐变透出
        tableView_Clara.backgroundColor = .clear
        // contentInsetAdjustmentBehavior = .never 使媒体图延伸至屏幕顶部（覆盖状态栏区域）
        tableView_Clara.contentInsetAdjustmentBehavior = .never
        tableView_Clara.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        tableView_Clara.delegate = self
        tableView_Clara.dataSource = self
    }

    private func setupCommentBar_Clara() {
        view.addSubview(commentBar_Clara)
        commentBar_Clara.snp.makeConstraints { make in
            make.top.equalTo(tableView_Clara.snp.bottom)
            make.left.right.equalToSuperview()
            commentBarBottomConstraint_Clara = make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).constraint
            make.height.equalTo(56)
        }

        // 顶部细分隔线（替代阴影，视觉上融入页面）
        let divider = UIView()
        divider.backgroundColor = ColorConfig_Clara.divider_Clara
        commentBar_Clara.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }

        // 输入框背景卡片（圆角，轻微白底）
        let fieldBg = UIView()
        fieldBg.backgroundColor = ColorConfig_Clara.cardBackground_Clara
        fieldBg.layer.cornerRadius = 20
        commentBar_Clara.addSubview(fieldBg)
        fieldBg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.bottom.equalToSuperview().inset(8)
        }

        commentBar_Clara.addSubview(commentSendBtn_Clara)
        commentSendBtn_Clara.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        commentSendBtn_Clara.addTarget(self, action: #selector(sendComment_Clara), for: .touchUpInside)

        commentBar_Clara.addSubview(giftButton_Clara)
        giftButton_Clara.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
            make.right.equalTo(commentSendBtn_Clara.snp.left).offset(-10)
            make.left.equalTo(fieldBg.snp.right).offset(8)
        }
        giftButton_Clara.addTarget(self, action: #selector(showGiftView_Clara), for: .touchUpInside)

        fieldBg.addSubview(commentField_Clara)
        commentField_Clara.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().inset(12)
            make.top.bottom.equalToSuperview()
        }
        commentField_Clara.delegate = self
    }

    // MARK: - 数据刷新

    /// 从 TitleViewModel 重新拉取最新帖子（数据变动时自动调用）
    private func refreshPost_Clara() {
        guard let current = titleModel_Clara else { return }
        // 在帖子列表中查找最新版本
        let updated = TitleViewModel_Clara.shared_Clara.getPosts_Clara()
            .first(where: { $0.titleId_Clara == current.titleId_Clara })
        if let latest = updated {
            titleModel_Clara = latest
        }
        updateFloatingReportButton_Clara()
        tableView_Clara.reloadData()
    }

    /// 帖子被移除后的处理（刷新或回退）
    private func handlePostRemoved_Clara() {
        let stillExists = TitleViewModel_Clara.shared_Clara.getPosts_Clara()
            .contains(where: { $0.titleId_Clara == titleModel_Clara?.titleId_Clara })
        if !stillExists {
            navigationController?.popViewController(animated: true)
        } else {
            refreshPost_Clara()
        }
    }

    // MARK: - 通知

    private func setupNotifications_Clara() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTitleStateChange_Clara),
            name: TitleViewModel_Clara.titleStateDidChangeNotification_Clara,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Clara),
            name: UserViewModel_Clara.userStateDidChangeNotification_Clara,
            object: nil
        )
    }

    @objc private func handleTitleStateChange_Clara() {
        refreshPost_Clara()
    }

    @objc private func handleUserStateChange_Clara() {
        // 用户状态变化（如拉黑/举报）后，评论区需要重新按可见规则过滤
        tableView_Clara.reloadData()
    }

    // MARK: - 键盘适配

    private func setupKeyboardObservers_Clara() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange_Clara(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    @objc private func keyboardWillChange_Clara(_ notification: Notification) {
        guard let info = notification.userInfo,
              let endFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        else { return }

        let kbHeight = max(0, view.frame.height - endFrame.origin.y)
        let safeBottom = view.safeAreaInsets.bottom
        let offset = kbHeight > 0 ? kbHeight - safeBottom : 0
        commentBarBottomConstraint_Clara?.update(offset: -offset)
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }

    // MARK: - 事件响应

    @objc private func backTapped_Clara() {
        navigationController?.popViewController(animated: true)
    }

    /// 展示送礼弹层
    @objc private func showGiftView_Clara() {
        let giftViewController_Clara = GiftView_Clara()
        giftViewController_Clara.modalPresentationStyle = .overFullScreen
        Navigation_Clara.present_Clara(
            viewController: giftViewController_Clara,
            animated: false,
            from: self
        )
    }

    /// 发布评论
    @objc private func sendComment_Clara() {
        guard let post = titleModel_Clara else { return }
        let text = commentField_Clara.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }
        commentField_Clara.text = ""
        view.endEditing(true)
        TitleViewModel_Clara.shared_Clara.releaseComment_Clara(post_clara: post, content_clara: text)
    }

    /// 点赞/取消点赞
    private func likePost_Clara() {
        guard let post = titleModel_Clara else { return }
        TitleViewModel_Clara.shared_Clara.likePost_Clara(post_clara: post)
    }

    /// 过滤可见评论：隐藏已被举报用户（且非当前登录用户）发布的评论
    /// - Parameter post_Clara: 当前帖子
    /// - Returns: 可展示的评论列表
    private func visibleComments_Clara(post_Clara: TitleModel_Clara) -> [Comment_Clara] {
        let currentUserId = UserViewModel_Clara.shared_Clara.getCurrentUser_Clara().userId_Clara
        let availableUserIds = Set(
            LocalData_Clara.shared_Clara.userList_Clara.compactMap { $0.userId_Clara }
        )
        return post_Clara.reviews_Clara.filter { comment in
            if currentUserId == comment.commentUserId_Clara {
                return true
            }
            return availableUserIds.contains(comment.commentUserId_Clara)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableView 代理

extension Detail_Clara: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        guard let post = titleModel_Clara else { return 0 }
        return visibleComments_Clara(post_Clara: post).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // 帖子主体
            let cell = tableView.dequeueReusableCell(
                withIdentifier: DetailHeaderCell_Clara.reuseId_Clara,
                for: indexPath
            ) as! DetailHeaderCell_Clara
            if let post = titleModel_Clara {
                cell.configure_Clara(post_Clara: post) { [weak self] in
                    self?.likePost_Clara()
                }
            }
            return cell
        } else {
            // 评论
            guard let post = titleModel_Clara else { return UITableViewCell() }
            let comments = visibleComments_Clara(post_Clara: post)
            guard indexPath.row < comments.count else { return UITableViewCell() }
            let comment = comments[indexPath.row]
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CommentCell_Clara.reuseId_Clara,
                for: indexPath
            ) as! CommentCell_Clara
            cell.configure_Clara(
                comment_Clara: comment,
                post_Clara: post,
                viewController_Clara: self
            ) { [weak self] in
                self?.refreshPost_Clara()
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 480 : 70
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    /// 评论区标题头
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 1 else { return nil }
        let header = UIView()
        header.backgroundColor = .clear
        let label = UILabel()
        let count = titleModel_Clara.map { visibleComments_Clara(post_Clara: $0).count } ?? 0
        label.text = "Comments (\(count))"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = ColorConfig_Clara.textSecondary_Clara
        header.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 36 : 0
    }
}

// MARK: - UITextFieldDelegate

extension Detail_Clara: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendComment_Clara()
        return true
    }
}

// MARK: - 帖子主体 Cell

/// 帖子详情主体单元格
/// 功能：展示媒体（MediaDisplayView）、标题、正文、作者头像+用户名、点赞按钮
class DetailHeaderCell_Clara: UITableViewCell {

    static let reuseId_Clara = "DetailHeaderCell_Clara"

    // MARK: - UI

    private let mediaView_Clara = MediaDisplayView_Clara()

    private let titleLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        l.textColor = ColorConfig_Clara.textPrimary_Clara
        l.numberOfLines = 0
        return l
    }()

    private let contentLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = ColorConfig_Clara.textSecondary_Clara
        l.numberOfLines = 0
        return l
    }()

    private let authorAvatar_Clara: UserAvatarView_Clara = {
        let v = UserAvatarView_Clara()
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    private let authorNameLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        l.textColor = ColorConfig_Clara.textSecondary_Clara
        return l
    }()

    private let likeButton_Clara: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = ColorConfig_Clara.primaryGradientStart_Clara
        return btn
    }()

    private let likeCountLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        l.textColor = ColorConfig_Clara.textSecondary_Clara
        return l
    }()

    private var onLikeTap_Clara: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI_Clara()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Clara() {
        // 媒体区（延伸至顶部边缘，含底部渐变叠层增强可读性）
        contentView.addSubview(mediaView_Clara)
        mediaView_Clara.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.width * 0.78)
        }
        mediaView_Clara.layer.cornerRadius = 0

        // 媒体区底部渐变叠层（黑色半透明，增强文字对比）
        let gradientOverlay = UIView()
        gradientOverlay.isUserInteractionEnabled = false
        contentView.addSubview(gradientOverlay)
        gradientOverlay.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(mediaView_Clara.snp.bottom)
            make.height.equalTo(80)
        }
        // 实际渐变在 layoutSubviews 阶段由 CAGradientLayer 应用
        DispatchQueue.main.async {
            let gl = CAGradientLayer()
            gl.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.35).cgColor]
            gl.startPoint = CGPoint(x: 0.5, y: 0)
            gl.endPoint = CGPoint(x: 0.5, y: 1)
            gl.frame = gradientOverlay.bounds
            gradientOverlay.layer.insertSublayer(gl, at: 0)
        }

        contentView.addSubview(titleLabel_Clara)
        titleLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Clara.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }

        contentView.addSubview(contentLabel_Clara)
        contentLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Clara.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
        }

        let divider = UIView()
        divider.backgroundColor = ColorConfig_Clara.divider_Clara
        contentView.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Clara.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(0.5)
        }

        // 作者行
        contentView.addSubview(authorAvatar_Clara)
        authorAvatar_Clara.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(32)
            make.bottom.equalToSuperview().inset(14)
        }

        contentView.addSubview(authorNameLabel_Clara)
        authorNameLabel_Clara.snp.makeConstraints { make in
            make.left.equalTo(authorAvatar_Clara.snp.right).offset(10)
            make.centerY.equalTo(authorAvatar_Clara)
        }

        // 点赞区
        contentView.addSubview(likeButton_Clara)
        likeButton_Clara.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(40)
            make.centerY.equalTo(authorAvatar_Clara)
            make.width.height.equalTo(28)
        }
        likeButton_Clara.addTarget(self, action: #selector(likeTapped_Clara), for: .touchUpInside)

        contentView.addSubview(likeCountLabel_Clara)
        likeCountLabel_Clara.snp.makeConstraints { make in
            make.left.equalTo(likeButton_Clara.snp.right).offset(4)
            make.centerY.equalTo(likeButton_Clara)
        }
    }

    /// 配置单元格内容
    func configure_Clara(post_Clara: TitleModel_Clara, onLike_Clara: @escaping () -> Void) {
        onLikeTap_Clara = onLike_Clara

        let mediaPath = post_Clara.titleMeidas_Clara.first
        let isVideo = mediaPath?.hasSuffix(".mp4") == true || mediaPath?.hasSuffix(".mov") == true
        mediaView_Clara.configure_Clara(mediaPath_Clara: mediaPath, isVideo_Clara: isVideo)

        titleLabel_Clara.text = post_Clara.title_Clara
        contentLabel_Clara.text = post_Clara.titleContent_Clara
        authorAvatar_Clara.configure_Clara(userId_Clara: post_Clara.titleUserId_Clara)
        authorNameLabel_Clara.text = post_Clara.titleUserName_Clara

        let isLiked = TitleViewModel_Clara.shared_Clara.isLikedPost_Clara(post_clara: post_Clara)
        let iconName = isLiked ? "heart.fill" : "heart"
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        likeButton_Clara.setImage(UIImage(systemName: iconName, withConfiguration: cfg), for: .normal)
        likeButton_Clara.tintColor = isLiked ? .systemRed : ColorConfig_Clara.textSecondary_Clara
        likeCountLabel_Clara.text = "\(post_Clara.likes_Clara)"
    }

    @objc private func likeTapped_Clara() {
        onLikeTap_Clara?()
    }
}

// MARK: - 评论 Cell

/// 评论单元格
/// 功能：展示评论用户头像、用户名、评论内容，右上角提供举报按钮（举报后删除该评论）
class CommentCell_Clara: UITableViewCell {

    static let reuseId_Clara = "CommentCell_Clara"

    // MARK: - UI

    private let cardView_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Clara.cardBackground_Clara
        v.layer.cornerRadius = 12
        return v
    }()

    private let avatarView_Clara: UserAvatarView_Clara = {
        let v = UserAvatarView_Clara()
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    private let nameLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        l.textColor = ColorConfig_Clara.textPrimary_Clara
        return l
    }()

    private let commentLabel_Clara: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13)
        l.textColor = ColorConfig_Clara.textSecondary_Clara
        l.numberOfLines = 0
        return l
    }()

    private weak var reportButton_Clara: UIButton?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI_Clara()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Clara() {
        contentView.addSubview(cardView_Clara)
        cardView_Clara.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.left.right.equalToSuperview().inset(16)
        }

        cardView_Clara.addSubview(avatarView_Clara)
        avatarView_Clara.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(12)
            make.width.height.equalTo(32)
        }

        cardView_Clara.addSubview(nameLabel_Clara)
        nameLabel_Clara.snp.makeConstraints { make in
            make.left.equalTo(avatarView_Clara.snp.right).offset(10)
            make.top.equalTo(avatarView_Clara.snp.top)
        }

        cardView_Clara.addSubview(commentLabel_Clara)
        commentLabel_Clara.snp.makeConstraints { make in
            make.left.equalTo(nameLabel_Clara.snp.left)
            make.right.equalToSuperview().inset(40)
            make.top.equalTo(nameLabel_Clara.snp.bottom).offset(3)
            make.bottom.equalToSuperview().inset(12)
        }
    }

    /// 配置评论单元格
    func configure_Clara(
        comment_Clara: Comment_Clara,
        post_Clara: TitleModel_Clara,
        viewController_Clara: UIViewController,
        completion_Clara: (() -> Void)? = nil
    ) {
        avatarView_Clara.configure_Clara(userId_Clara: comment_Clara.commentUserId_Clara)
        nameLabel_Clara.text = comment_Clara.commentUserName_Clara
        commentLabel_Clara.text = comment_Clara.commentContent_Clara

        // 移除旧按钮，创建新举报/删除按钮
        reportButton_Clara?.removeFromSuperview()
        let btn = ReportDeleteHelper_Clara.createCommentReportButton_Clara(
            comment_Clara: comment_Clara,
            post_Clara: post_Clara,
            size_Clara: 16,
            color_Clara: ColorConfig_Clara.textPlaceholder_Clara,
            from: viewController_Clara,
            completion_Clara: completion_Clara
        )
        cardView_Clara.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().inset(10)
            make.width.height.equalTo(28)
        }
        reportButton_Clara = btn
    }
}
