import UIKit
import SnapKit

// MARK: - 帖子详情页

/// 帖子详情页控制器
/// 功能：展示帖子完整内容（作者、媒体、标题、正文、点赞）、评论列表及内嵌评论输入框
/// 设计：波浪渐变顶部悬浮栏 + TableView（帖子内容为 headerView，评论输入为 footerView，评论为 cell）
/// 数据：通过 NotificationCenter 监听 TitleViewModel / UserViewModel 状态变更自动刷新
class Detail_Flick: UIViewController {

    // MARK: - 属性

    /// 外部传入的帖子模型（原始引用）
    var titleModel_Flick: TitleModel_Flick?

    /// 从 ViewModel 获取最新帖子状态（帖子被举报/删除后从列表移除则返回 nil，用于自动 pop）
    private var currentPost_Flick: TitleModel_Flick? {
        guard let orig = titleModel_Flick else { return nil }
        return TitleViewModel_Flick.shared_Flick.getPosts_Flick()
            .first { $0.titleId_Flick == orig.titleId_Flick }
    }

    // MARK: - UI

    /// 主列表（帖子内容 = headerView，评论输入 = footerView，评论 = cell）
    private lazy var tableView_Flick: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
        tv.separatorStyle  = .none
        tv.showsVerticalScrollIndicator = false
        // 禁止自动 inset，确保渐变头部贴顶
        tv.contentInsetAdjustmentBehavior = .never
        tv.keyboardDismissMode = .onDrag
        tv.register(DetailCommentCell_Flick.self, forCellReuseIdentifier: DetailCommentCell_Flick.reuseId_Flick)
        tv.delegate   = self
        tv.dataSource = self
        return tv
    }()

    /// 帖子内容区（作为 tableHeaderView）
    private lazy var postHeaderView_Flick: DetailPostHeaderView_Flick = {
        let v = DetailPostHeaderView_Flick()
        v.onLikeTapped_Flick = { [weak self] in
            guard let post = self?.currentPost_Flick else { return }
            TitleViewModel_Flick.shared_Flick.likePost_Flick(post_flick: post)
        }
        v.onMediaTapped_Flick = { [weak self] path_flick in
            self?.presentMediaPlayerPage_Flick(path_flick: path_flick)
        }
        return v
    }()

    /// 评论输入区（作为 tableFooterView，随列表滚动，非悬浮）
    private lazy var commentInputView_Flick: DetailCommentInputView_Flick = {
        let v = DetailCommentInputView_Flick()
        v.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 72)
        v.onSend_Flick = { [weak self] text in
            guard let post = self?.currentPost_Flick else { return }
            TitleViewModel_Flick.shared_Flick.releaseComment_Flick(post_flick: post, content_flick: text)
        }
        return v
    }()

    /// 顶部悬浮按钮栏（不随 tableView 滚动）
    private let topOverlay_Flick = UIView()
    private let backBtn_Flick    = BackButton_Flick()

    /// 右上角举报 / 删除按钮
    private let actionBtn_Flick: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor.white.withValues(alpha: 0.18)
        btn.layer.cornerRadius = 18
        btn.tintColor = .white
        return btn
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Flick()
        configureContent_Flick()
        bindNotifications_Flick()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 首次出现后补触发 Cell 布局，确保 CALayer 渐变在有效 bounds 下渲染
        tableView_Flick.visibleCells.forEach { $0.setNeedsLayout(); $0.layoutIfNeeded() }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizeTableHeader_Flick()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - UI 设置

    private func setupUI_Flick() {
        view.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick

        view.addSubview(tableView_Flick)
        tableView_Flick.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 帖子内容头部（初始给估算高度，viewDidLayoutSubviews 自适应）
        postHeaderView_Flick.frame = CGRect(x: 0, y: 0,
                                            width: UIScreen.main.bounds.width, height: 580)
        tableView_Flick.tableHeaderView = postHeaderView_Flick

        // 评论输入区作为 footerView（内嵌，非悬浮）
        tableView_Flick.tableFooterView = commentInputView_Flick

        setupTopOverlay_Flick()
        setupKeyboard_Flick()
    }

    /// 设置顶部悬浮按钮栏（返回 + 举报/删除）
    private func setupTopOverlay_Flick() {
        view.addSubview(topOverlay_Flick)
        topOverlay_Flick.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(96)
        }
        topOverlay_Flick.isUserInteractionEnabled = true

        topOverlay_Flick.addSubview(backBtn_Flick)
        backBtn_Flick.snp.makeConstraints { make in
            make.top.equalTo(topOverlay_Flick.safeAreaLayoutGuide.snp.top).offset(8)
            make.left.equalToSuperview().inset(16)
            make.width.height.equalTo(44)
        }
        backBtn_Flick.onTapped_Flick = { [weak self] in
            Navigation_Flick.pop_Flick(from: self)
        }

        topOverlay_Flick.addSubview(actionBtn_Flick)
        actionBtn_Flick.snp.makeConstraints { make in
            make.centerY.equalTo(backBtn_Flick)
            make.right.equalToSuperview().inset(16)
            make.width.height.equalTo(36)
        }
        actionBtn_Flick.addTarget(self, action: #selector(actionBtnTapped_Flick), for: .touchUpInside)
    }

    /// 根据内容自适应 tableHeaderView 高度
    private func resizeTableHeader_Flick() {
        guard let hv = tableView_Flick.tableHeaderView, tableView_Flick.bounds.width > 0 else { return }
        let w = tableView_Flick.bounds.width
        let size = hv.systemLayoutSizeFitting(
            CGSize(width: w, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        if abs(hv.frame.height - size.height) > 1 {
            hv.frame.size.height = size.height
            tableView_Flick.tableHeaderView = hv
        }
    }

    // MARK: - 数据配置

    /// 从 ViewModel 加载并渲染帖子数据
    private func configureContent_Flick() {
        guard let post = currentPost_Flick else { return }
        postHeaderView_Flick.configure_Flick(post: post, from: self)
        refreshActionBtnIcon_Flick(post: post)
        resizeTableHeader_Flick()
        tableView_Flick.reloadData()
    }

    /// 根据是否本人帖子更新右上角图标（删除 / 举报）
    private func refreshActionBtnIcon_Flick(post: TitleModel_Flick) {
        let isOwner  = UserViewModel_Flick.shared_Flick.isCurrentUser_Flick(userId_flick: post.titleUserId_Flick)
        let iconName = isOwner ? "trash" : "ellipsis"
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        actionBtn_Flick.setImage(UIImage(systemName: iconName, withConfiguration: cfg), for: .normal)
    }

    /// 全屏打开媒体浏览（MediaPlayerPage_Flick，内部以 dismiss 关闭）
    /// - Parameter path_flick: 当前页媒体路径（与 MediaDisplayView_Flick 一致）
    private func presentMediaPlayerPage_Flick(path_flick: String) {
        guard !path_flick.isEmpty else { return }
        let playerVC_Flick = MediaPlayerPage_Flick()
        playerVC_Flick.mediaPath_Flick = path_flick
        playerVC_Flick.modalPresentationStyle = .fullScreen
        Navigation_Flick.present_Flick(viewController: playerVC_Flick, from: self)
    }

    // MARK: - 通知绑定

    private func bindNotifications_Flick() {
        [TitleViewModel_Flick.titleStateDidChangeNotification_Flick,
         UserViewModel_Flick.userStateDidChangeNotification_Flick].forEach {
            NotificationCenter.default.addObserver(self,
                selector: #selector(onDataChanged_Flick), name: $0, object: nil)
        }
    }

    /// 数据变更响应：帖子被删除时自动返回上一页
    @objc private func onDataChanged_Flick() {
        guard let post = currentPost_Flick else {
            Navigation_Flick.pop_Flick(from: self)
            return
        }
        postHeaderView_Flick.configure_Flick(post: post, from: self)
        refreshActionBtnIcon_Flick(post: post)
        resizeTableHeader_Flick()
        tableView_Flick.reloadData()
    }

    // MARK: - 事件处理

    /// 举报 / 删除帖子（完成后若帖子已不在列表则返回上一级）
    @objc private func actionBtnTapped_Flick() {
        guard let post = currentPost_Flick else { return }
        ReportDeleteHelper_Flick.runPostReportOrDeleteFromDetail_Flick(
            post_Flick: post,
            actionButton_Flick: actionBtn_Flick,
            from: self,
            completion_Flick: { [weak self] in
                guard let self = self else { return }
                if self.currentPost_Flick == nil {
                    Navigation_Flick.pop_Flick(from: self)
                }
            }
        )
    }

    // MARK: - 键盘适配（调整 contentInset 使 footerView 可见）

    private func setupKeyboard_Flick() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbShow_Flick(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbHide_Flick(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func kbShow_Flick(_ n: Notification) {
        guard let info = n.userInfo,
              let rect = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let dur  = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        let kbHeight = rect.height - view.safeAreaInsets.bottom
        tableView_Flick.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbHeight, right: 0)
        // 滚动到底部使输入框可见
        let bottomOffset = CGPoint(
            x: 0,
            y: max(0, tableView_Flick.contentSize.height - tableView_Flick.bounds.height + kbHeight)
        )
        UIView.animate(withDuration: dur) {
            self.tableView_Flick.contentOffset = bottomOffset
        }
    }

    @objc private func kbHide_Flick(_ n: Notification) {
        guard let dur = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        UIView.animate(withDuration: dur) {
            self.tableView_Flick.contentInset = .zero
        }
    }
}

// MARK: - UITableViewDataSource / Delegate

extension Detail_Flick: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPost_Flick?.reviews_Flick.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let comment = currentPost_Flick?.reviews_Flick[safe: indexPath.row],
              let post = currentPost_Flick else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(
            withIdentifier: DetailCommentCell_Flick.reuseId_Flick, for: indexPath
        ) as! DetailCommentCell_Flick
        cell.configure_Flick(comment: comment, post: post, from: self)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - Array 安全下标扩展（仅文件内使用）

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - 帖子内容头部视图

/// 帖子内容头部视图
/// 功能：作为 tableHeaderView，展示渐变波浪背景、作者信息（UserAvatarView_Flick）、标题、媒体分页、
///        正文、点赞/评论操作栏及评论区标题
/// 设计：懒初始化波浪 mask，避免空 path 遮盖渐变
private class DetailPostHeaderView_Flick: UIView, UIGestureRecognizerDelegate {

    // MARK: - 渐变背景

    private let gradientBg_Flick = UIView()
    private var gradLayer_Flick: CAGradientLayer?
    private var waveMask_Flick: CAShapeLayer?

    // MARK: - 作者信息

    private let authorAvatarView_Flick: UserAvatarView_Flick = {
        let v = UserAvatarView_Flick()
        v.clipsToBounds = true
        return v
    }()
    private let authorName_Flick: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .white
        l.lineBreakMode = .byTruncatingTail
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return l
    }()

    /// 关注作者（未关注显示 Follow，已关注显示 Followed；本人帖子隐藏）
    private lazy var followBtn_Flick: UIButton = {
        let btn_flick = UIButton(type: .system)
        btn_flick.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        btn_flick.setTitle("Follow", for: .normal)
        btn_flick.setTitle("Followed", for: .selected)
        btn_flick.setTitleColor(.white, for: .normal)
        btn_flick.setTitleColor(.white, for: .selected)
        btn_flick.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        btn_flick.layer.cornerRadius = 16
        btn_flick.clipsToBounds = true
        btn_flick.setContentCompressionResistancePriority(.required, for: .horizontal)
        btn_flick.addTarget(self, action: #selector(followBtnTapped_Flick), for: .touchUpInside)
        return btn_flick
    }()

    /// 当前绑定帖子（关注按钮逻辑用）
    private var postForFollow_Flick: TitleModel_Flick?

    // MARK: - 标题

    private let titleLabel_Flick: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 21, weight: .bold)
        l.textColor = .white
        l.numberOfLines = 3
        return l
    }()

    // MARK: - 媒体分页（使用 MediaDisplayView_Flick 组件）

    /// 横向分页滚动容器，每页为一个 MediaDisplayView_Flick 实例
    private let mediaScroll_Flick: UIScrollView = {
        let sv = UIScrollView()
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.layer.cornerRadius = 16
        sv.clipsToBounds = true
        return sv
    }()
    private let pageControl_Flick: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = ColorConfig_Flick.primaryGradientStart_Flick
        pc.pageIndicatorTintColor = ColorConfig_Flick.textPlaceholder_Flick
        return pc
    }()
    private var mediaPaths_Flick: [String] = []

    // MARK: - 正文

    private let contentLabel_Flick: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15)
        l.textColor = ColorConfig_Flick.textPrimary_Flick
        l.numberOfLines = 0
        return l
    }()

    // MARK: - 操作栏

    private let actionRow_Flick = UIView()
    private let likeBtn_Flick: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        btn.setImage(UIImage(systemName: "heart", withConfiguration: cfg), for: .normal)
        btn.setImage(UIImage(systemName: "heart.fill", withConfiguration: cfg), for: .selected)
        btn.tintColor = ColorConfig_Flick.primaryGradientStart_Flick
        return btn
    }()
    private let likeCountLabel_Flick: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = ColorConfig_Flick.textSecondary_Flick
        return l
    }()
    private let commentCountLabel_Flick: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = ColorConfig_Flick.textSecondary_Flick
        return l
    }()

    // MARK: - 评论区标题 / 空状态

    private let commentsSectionStack_Flick: UIStackView = {
        let sv = UIStackView()
        sv.axis    = .vertical
        sv.spacing = 10
        sv.alignment = .leading
        return sv
    }()
    private let commentsTitleLabel_Flick: UILabel = {
        let l = UILabel()
        l.text = "Comments"
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = ColorConfig_Flick.textPrimary_Flick
        return l
    }()
    private let emptyCommentLabel_Flick: UILabel = {
        let l = UILabel()
        l.text = "Be the first to comment ✨"
        l.font = .systemFont(ofSize: 13)
        l.textColor = ColorConfig_Flick.textPlaceholder_Flick
        l.textAlignment = .center
        return l
    }()

    /// 点赞按钮点击回调（由 VC 注入）
    var onLikeTapped_Flick: (() -> Void)?

    /// 点击媒体分页区域回调（传入当前页媒体路径，供打开全屏播放器）
    var onMediaTapped_Flick: ((String) -> Void)?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Flick()
    }
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Flick?.frame = gradientBg_Flick.bounds
        applyWaveMask_Flick()
        refreshMediaLayout_Flick()
    }

    // MARK: - UI 设置

    private func setupUI_Flick() {
        backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick

        // 渐变背景
        addSubview(gradientBg_Flick)
        gradientBg_Flick.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(215)
        }
        let g = UIColor.createPrimaryGradientLayer_Flick(
            frame_Flick: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 215)
        )
        gradientBg_Flick.layer.insertSublayer(g, at: 0)
        gradLayer_Flick = g

        // 装饰星点
        for (txt, x, y, sz, alpha) in [("✦", 30.0, 40.0, 12.0, 0.4),
                                        ("✦", 290.0, 65.0, 8.0, 0.3),
                                        ("✦", 340.0, 28.0, 7.0, 0.5)] {
            let lbl = UILabel()
            lbl.text = txt
            lbl.font = .systemFont(ofSize: CGFloat(sz))
            lbl.textColor = UIColor.white.withValues(alpha: CGFloat(alpha))
            gradientBg_Flick.addSubview(lbl)
            lbl.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(x)
                make.top.equalToSuperview().offset(y)
            }
        }

        // 作者头像（统一使用 UserAvatarView_Flick）
        gradientBg_Flick.addSubview(authorAvatarView_Flick)
        authorAvatarView_Flick.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(46)
            make.width.height.equalTo(40)
        }

        // 关注（靠右，与昵称同一行）
        gradientBg_Flick.addSubview(followBtn_Flick)
        followBtn_Flick.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalTo(authorAvatarView_Flick)
            make.height.equalTo(32)
        }

        // 作者名（与关注按钮之间留白，长昵称截断）
        gradientBg_Flick.addSubview(authorName_Flick)
        authorName_Flick.snp.makeConstraints { make in
            make.left.equalTo(authorAvatarView_Flick.snp.right).offset(10)
            make.centerY.equalTo(authorAvatarView_Flick)
            make.right.lessThanOrEqualTo(followBtn_Flick.snp.left).offset(-8)
        }

        // 帖子标题（贴近渐变底部）
        gradientBg_Flick.addSubview(titleLabel_Flick)
        titleLabel_Flick.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(14)
        }

        // 媒体分页（使用 MediaDisplayView_Flick，支持图片/视频/占位符）
        addSubview(mediaScroll_Flick)
        mediaScroll_Flick.snp.makeConstraints { make in
            make.top.equalTo(gradientBg_Flick.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(220)
        }
        let mediaTap_Flick = UITapGestureRecognizer(target: self, action: #selector(handleMediaAreaTap_Flick))
        mediaTap_Flick.cancelsTouchesInView = false
        mediaTap_Flick.delegate = self
        mediaScroll_Flick.addGestureRecognizer(mediaTap_Flick)

        addSubview(pageControl_Flick)
        pageControl_Flick.snp.makeConstraints { make in
            make.top.equalTo(mediaScroll_Flick.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.height.equalTo(18)
        }

        // 正文
        addSubview(contentLabel_Flick)
        contentLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(pageControl_Flick.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
        }

        // 操作栏
        setupActionRow_Flick()

        // 评论区（StackView 控制空状态显隐）
        addSubview(commentsSectionStack_Flick)
        commentsSectionStack_Flick.snp.makeConstraints { make in
            make.top.equalTo(actionRow_Flick.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(12)
        }
        commentsSectionStack_Flick.addArrangedSubview(commentsTitleLabel_Flick)
        commentsSectionStack_Flick.addArrangedSubview(emptyCommentLabel_Flick)
        emptyCommentLabel_Flick.snp.makeConstraints { $0.left.right.equalToSuperview() }
    }

    /// 设置操作栏（分割线 + 点赞 + 评论数）
    private func setupActionRow_Flick() {
        addSubview(actionRow_Flick)
        actionRow_Flick.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Flick.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(46)
        }

        let topDiv = UIView()
        topDiv.backgroundColor = ColorConfig_Flick.divider_Flick
        actionRow_Flick.addSubview(topDiv)
        topDiv.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1)
        }

        actionRow_Flick.addSubview(likeBtn_Flick)
        likeBtn_Flick.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        likeBtn_Flick.addTarget(self, action: #selector(likeTapped_Flick), for: .touchUpInside)

        actionRow_Flick.addSubview(likeCountLabel_Flick)
        likeCountLabel_Flick.snp.makeConstraints { make in
            make.left.equalTo(likeBtn_Flick.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }

        let commentIcon = UIImageView()
        let iconCfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        commentIcon.image = UIImage(systemName: "bubble.left", withConfiguration: iconCfg)
        commentIcon.tintColor = ColorConfig_Flick.textSecondary_Flick
        actionRow_Flick.addSubview(commentIcon)
        commentIcon.snp.makeConstraints { make in
            make.left.equalTo(likeCountLabel_Flick.snp.right).offset(18)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }

        actionRow_Flick.addSubview(commentCountLabel_Flick)
        commentCountLabel_Flick.snp.makeConstraints { make in
            make.left.equalTo(commentIcon.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }

        let botDiv = UIView()
        botDiv.backgroundColor = ColorConfig_Flick.divider_Flick
        actionRow_Flick.addSubview(botDiv)
        botDiv.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    @objc private func likeTapped_Flick() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onLikeTapped_Flick?()
    }

    /// 点击媒体区域：按当前分页索引取路径并交给宿主打开全屏页
    @objc private func handleMediaAreaTap_Flick() {
        let w_flick = mediaScroll_Flick.bounds.width
        guard w_flick > 0, !mediaPaths_Flick.isEmpty else { return }
        let page_flick = Int(round(mediaScroll_Flick.contentOffset.x / w_flick))
        let idx_flick = min(max(0, page_flick), mediaPaths_Flick.count - 1)
        let path_flick = mediaPaths_Flick[idx_flick]
        guard !path_flick.isEmpty else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onMediaTapped_Flick?(path_flick)
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }

    /// 关注 / 取消关注：走 `UserViewModel_Flick.followUser_Flick`，状态由通知刷新 `configure_Flick`
    @objc private func followBtnTapped_Flick() {
        guard let post_flick = postForFollow_Flick else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        var prew_flick = UserViewModel_Flick.shared_Flick.getUserById_Flick(userId_flick: post_flick.titleUserId_Flick)
        prew_flick.userName_Flick = post_flick.titleUserName_Flick
        UserViewModel_Flick.shared_Flick.followUser_Flick(user_flick: prew_flick)
    }

    /// 更新关注按钮选中态与背景（与 `isFollowing_Flick` 一致）
    private func refreshFollowButton_Flick(post_flick: TitleModel_Flick) {
        let isOwn_flick = UserViewModel_Flick.shared_Flick.isCurrentUser_Flick(userId_flick: post_flick.titleUserId_Flick)
        followBtn_Flick.isHidden = isOwn_flick
        guard !isOwn_flick else {
            authorName_Flick.snp.remakeConstraints { make in
                make.left.equalTo(authorAvatarView_Flick.snp.right).offset(10)
                make.centerY.equalTo(authorAvatarView_Flick)
                make.right.lessThanOrEqualToSuperview().inset(20)
            }
            return
        }
        authorName_Flick.snp.remakeConstraints { make in
            make.left.equalTo(authorAvatarView_Flick.snp.right).offset(10)
            make.centerY.equalTo(authorAvatarView_Flick)
            make.right.lessThanOrEqualTo(followBtn_Flick.snp.left).offset(-8)
        }
        var prew_flick = UserViewModel_Flick.shared_Flick.getUserById_Flick(userId_flick: post_flick.titleUserId_Flick)
        prew_flick.userName_Flick = post_flick.titleUserName_Flick
        let following_flick = UserViewModel_Flick.shared_Flick.isFollowing_Flick(user_flick: prew_flick)
        followBtn_Flick.isSelected = following_flick
        followBtn_Flick.backgroundColor = following_flick
            ? UIColor.white.withValues(alpha: 0.32)
            : UIColor.white.withValues(alpha: 0.18)
    }

    // MARK: - 数据绑定

    /// 绑定帖子数据到所有 UI 元素
    /// - Parameters:
    ///   - post: 帖子模型
    ///   - vc: 宿主 ViewController（用于举报/删除回调）
    func configure_Flick(post: TitleModel_Flick, from vc: UIViewController) {
        postForFollow_Flick = post
        authorAvatarView_Flick.configure_Flick(userId_Flick: post.titleUserId_Flick)
        authorName_Flick.text = post.titleUserName_Flick
        refreshFollowButton_Flick(post_flick: post)

        titleLabel_Flick.text   = post.title_Flick
        contentLabel_Flick.text = post.titleContent_Flick

        // 点赞状态
        let isLiked = TitleViewModel_Flick.shared_Flick.isLikedPost_Flick(post_flick: post)
        likeBtn_Flick.isSelected  = isLiked
        likeCountLabel_Flick.text = "\(post.likes_Flick)"
        commentCountLabel_Flick.text = "\(post.reviews_Flick.count)"

        // 评论空状态
        emptyCommentLabel_Flick.isHidden = !post.reviews_Flick.isEmpty

        // 媒体（使用 MediaDisplayView_Flick 组件渲染）
        mediaPaths_Flick = post.titleMeidas_Flick
        pageControl_Flick.numberOfPages = mediaPaths_Flick.count
        pageControl_Flick.isHidden = mediaPaths_Flick.count <= 1
        rebuildMediaViews_Flick()

        setNeedsLayout()
    }

    // MARK: - 媒体分页（MediaDisplayView_Flick）

    /// 重建媒体滚动视图内的 MediaDisplayView_Flick 实例
    /// 每个媒体路径对应一个 MediaDisplayView_Flick，支持图片/视频/占位符自动识别
    private func rebuildMediaViews_Flick() {
        mediaScroll_Flick.subviews.forEach { $0.removeFromSuperview() }
        let w = UIScreen.main.bounds.width - 32
        let paths = mediaPaths_Flick.isEmpty ? [String?](repeating: nil, count: 1) : mediaPaths_Flick.map { Optional($0) }
        for (i, path) in paths.enumerated() {
            let mv = MediaDisplayView_Flick()
            mv.configure_Flick(mediaPath_Flick: path)
            mediaScroll_Flick.addSubview(mv)
            mv.frame = CGRect(x: CGFloat(i) * w, y: 0, width: w, height: 220)
        }
        mediaScroll_Flick.contentSize = CGSize(width: CGFloat(paths.count) * w, height: 220)
    }

    /// layoutSubviews 时同步更新各 MediaDisplayView_Flick 的 frame（适配实际宽度）
    private func refreshMediaLayout_Flick() {
        let w = mediaScroll_Flick.bounds.width
        guard w > 0 else { return }
        let count = max(1, mediaPaths_Flick.isEmpty ? 1 : mediaPaths_Flick.count)
        for (i, sv) in mediaScroll_Flick.subviews.enumerated() {
            sv.frame = CGRect(x: CGFloat(i) * w, y: 0, width: w, height: mediaScroll_Flick.bounds.height)
        }
        mediaScroll_Flick.contentSize = CGSize(width: CGFloat(count) * w, height: mediaScroll_Flick.bounds.height)
    }

    // MARK: - 波浪遮罩（懒初始化）

    /// bounds 有效时才创建 mask 并挂载，避免空 path 使渐变不可见
    private func applyWaveMask_Flick() {
        let b = gradientBg_Flick.bounds
        guard b.width > 0 else { return }
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: b.width, y: 0))
        path.addLine(to: CGPoint(x: b.width, y: b.height - 22))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: b.height - 22),
            controlPoint: CGPoint(x: b.width / 2, y: b.height + 20)
        )
        path.close()
        if waveMask_Flick == nil {
            let mask = CAShapeLayer()
            mask.fillColor = UIColor.black.cgColor
            gradientBg_Flick.layer.mask = mask
            waveMask_Flick = mask
        }
        waveMask_Flick?.path = path.cgPath
    }
}

// MARK: - 内嵌评论输入视图

/// 评论输入视图（可作 tableFooterView 随列表滚动，或挑战详情等场景底部固定）
/// 功能：输入框 + 渐变发送按钮；
/// challengeStyleBottomFlush_Flick 时底栏与白卡片同色铺满、输入区用线框区分，避免「灰底+白卡片+灰输入」三层嵌套观感
class DetailCommentInputView_Flick: UIView {

    /// 发送回调（参数为去除首尾空白后的评论内容）
    var onSend_Flick: ((String) -> Void)?

    /// 自定义 placeholder 文案
    var placeholder_Flick: String = "Write a comment..." {
        didSet { inputField_Flick.placeholder = placeholder_Flick }
    }

    /// 挑战详情等全屏底栏：白卡片底边贴父视图底边，仅保留顶部圆角，消除 Home 指示条上方空隙
    var challengeStyleBottomFlush_Flick: Bool = false {
        didSet {
            guard challengeStyleBottomFlush_Flick != oldValue else { return }
            applyChallengeStyleBottomFlush_Flick()
        }
    }

    /// 白卡片底边约束（用于切换贴底 / 默认内边距）
    private var containerCardBottomConstraint_Flick: Constraint?

    private let containerCard_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor  = UIColor.black.withValues(alpha: 0.06).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius  = 8
        return v
    }()

    private let inputField_Flick: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Write a comment..."
        tf.font = .systemFont(ofSize: 14)
        tf.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
        tf.layer.cornerRadius = 12
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        tf.leftViewMode = .always
        tf.returnKeyType = .send
        return tf
    }()

    private let sendBtn_Flick: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        btn.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.layer.cornerRadius = 16
        btn.clipsToBounds = true
        return btn
    }()

    private var sendGrad_Flick: CAGradientLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Flick()
    }
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 懒初始化发送按钮渐变
        guard sendBtn_Flick.bounds.width > 0 else { return }
        if let g = sendGrad_Flick { g.frame = sendBtn_Flick.bounds; return }
        let g = UIColor.createPrimaryGradientLayer_Flick(frame_Flick: sendBtn_Flick.bounds)
        g.cornerRadius = 16
        sendBtn_Flick.layer.insertSublayer(g, at: 0)
        sendGrad_Flick = g
    }

    private func setupUI_Flick() {
        backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick

        addSubview(containerCard_Flick)
        layoutContainerCard_Flick()
        applyChallengeStyleBottomFlush_Flick()

        containerCard_Flick.addSubview(inputField_Flick)
        inputField_Flick.delegate = self

        containerCard_Flick.addSubview(sendBtn_Flick)
        sendBtn_Flick.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        sendBtn_Flick.addTarget(self, action: #selector(sendTapped_Flick), for: .touchUpInside)

        // 输入框较矮、相对白卡片垂直居中；右侧止于发送按钮左侧
        inputField_Flick.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.right.equalTo(sendBtn_Flick.snp.left).offset(-8)
            make.height.equalTo(34)
            make.centerY.equalToSuperview()
        }
    }

    /// 白卡片相对父视图边距（挑战贴底模式铺满宽度，与外层同色，视觉上只有「一栏白底 + 线框输入区」）
    private func layoutContainerCard_Flick() {
        containerCard_Flick.snp.remakeConstraints { make in
            if challengeStyleBottomFlush_Flick {
                make.left.right.top.equalToSuperview()
            } else {
                make.left.right.equalToSuperview().inset(16)
                make.top.equalToSuperview().inset(10)
            }
            containerCardBottomConstraint_Flick = make.bottom.equalToSuperview()
                .inset(challengeStyleBottomFlush_Flick ? 0 : 10).constraint
        }
    }

    /// 按 challengeStyleBottomFlush_Flick 更新白卡片布局、圆角与输入框样式
    private func applyChallengeStyleBottomFlush_Flick() {
        layoutContainerCard_Flick()
        if challengeStyleBottomFlush_Flick {
            backgroundColor = .white
            containerCard_Flick.layer.shadowOpacity = 0
            inputField_Flick.backgroundColor = .clear
            inputField_Flick.layer.borderWidth = 1
            inputField_Flick.layer.borderColor = UIColor.black.withValues(alpha: 0.08).cgColor
            inputField_Flick.clipsToBounds = true
        } else {
            backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
            containerCard_Flick.layer.shadowOpacity = 1
            inputField_Flick.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
            inputField_Flick.layer.borderWidth = 0
            inputField_Flick.layer.borderColor = nil
            inputField_Flick.clipsToBounds = true
        }
        if #available(iOS 11.0, *) {
            if challengeStyleBottomFlush_Flick {
                containerCard_Flick.layer.maskedCorners = [
                    .layerMinXMinYCorner, .layerMaxXMinYCorner
                ]
            } else {
                containerCard_Flick.layer.maskedCorners = [
                    .layerMinXMinYCorner, .layerMaxXMinYCorner,
                    .layerMinXMaxYCorner, .layerMaxXMaxYCorner
                ]
            }
        }
    }

    @objc private func sendTapped_Flick() {
        guard let text = inputField_Flick.text?.trimmingCharacters(in: .whitespaces),
              !text.isEmpty else { return }
        onSend_Flick?(text)
        inputField_Flick.text = nil
        inputField_Flick.resignFirstResponder()
    }

}

extension DetailCommentInputView_Flick: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped_Flick()
        return true
    }
}

// MARK: - 评论 Cell

/// 详情页评论 Cell
/// 功能：展示评论用户头像（UserAvatarView_Flick）、名称、评论内容，右上角举报/删除按钮
/// 设计：白色圆角卡片 + 柔和阴影
private class DetailCommentCell_Flick: UITableViewCell {

    static let reuseId_Flick = "DetailCommentCell_Flick"

    private let containerView_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 14
        v.layer.shadowColor  = UIColor.black.withValues(alpha: 0.04).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius  = 6
        return v
    }()

    private let userAvatarView_Flick: UserAvatarView_Flick = {
        let v = UserAvatarView_Flick()
        v.clipsToBounds = true
        return v
    }()
    private let nameLabel_Flick: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = ColorConfig_Flick.textPrimary_Flick
        return l
    }()
    private let contentLabel_Flick: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = ColorConfig_Flick.textSecondary_Flick
        l.numberOfLines = 0
        return l
    }()

    /// 举报/删除按钮（每次 configure 时重建）
    private var reportBtn_Flick: UIButton?

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Flick()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Flick() {
        backgroundColor = .clear
        selectionStyle  = .none

        contentView.addSubview(containerView_Flick)
        containerView_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(6)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(6)
        }

        containerView_Flick.addSubview(userAvatarView_Flick)
        userAvatarView_Flick.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(14)
            make.width.height.equalTo(36)
        }

        containerView_Flick.addSubview(nameLabel_Flick)
        nameLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(userAvatarView_Flick)
            make.left.equalTo(userAvatarView_Flick.snp.right).offset(10)
            make.right.lessThanOrEqualToSuperview().inset(44)
        }

        containerView_Flick.addSubview(contentLabel_Flick)
        contentLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Flick.snp.bottom).offset(4)
            make.left.equalTo(userAvatarView_Flick.snp.right).offset(10)
            make.right.equalToSuperview().inset(14)
            make.bottom.equalToSuperview().inset(14)
        }
    }

    // MARK: - 数据绑定

    /// 绑定评论数据
    /// - Parameters:
    ///   - comment: 评论模型
    ///   - post: 所属帖子（举报时需要）
    ///   - vc: 宿主 ViewController
    func configure_Flick(comment: Comment_Flick, post: TitleModel_Flick, from vc: UIViewController) {
        userAvatarView_Flick.configure_Flick(userId_Flick: comment.commentUserId_Flick)
        nameLabel_Flick.text = comment.commentUserName_Flick
        contentLabel_Flick.text = comment.commentContent_Flick

        // 移除旧按钮，重建（cell 复用时上下文可能变化）
        reportBtn_Flick?.removeFromSuperview()
        let btn = ReportDeleteHelper_Flick.createCommentReportButton_Flick(
            comment_Flick: comment,
            post_Flick: post,
            size_Flick: 13,
            color_Flick: ColorConfig_Flick.textPlaceholder_Flick,
            from: vc
        )
        containerView_Flick.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.right.equalToSuperview().inset(10)
            make.width.height.equalTo(28)
        }
        reportBtn_Flick = btn
    }
}
