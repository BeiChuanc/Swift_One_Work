import Foundation
import UIKit
import SnapKit

// MARK: - 帖子详情页
// 核心作用：展示单篇帖子完整内容（媒体、标题、正文、点赞、评论），
//           支持发布评论、举报/删除帖子及评论。
// 设计思路：UITableView 为主容器；帖子内容作 tableHeaderView，评论为 rows；
//           底部评论输入栏跟随键盘；数据通过通知自动响应。
// 关键属性：titleModel_Moode（入口帖子），通过 TitleViewModel 实时同步最新数据

/// 帖子详情页控制器
class Detail_Moode: UIViewController {

    // MARK: - 公开属性

    var titleModel_Moode: TitleModel_Moode?

    // MARK: - 私有属性

    private var currentPost_Moode: TitleModel_Moode? {
        guard let id = titleModel_Moode?.titleId_Moode else { return nil }
        return TitleViewModel_Moode.shared_Moode.getPosts_Moode()
            .first { $0.titleId_Moode == id }
    }

    // MARK: - UI 组件

    private let tableView_Moode: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = ColorConfig_Moode.backgroundPrimary_Moode
        tv.separatorStyle  = .none
        tv.keyboardDismissMode = .interactive
        tv.contentInsetAdjustmentBehavior = .never
        tv.register(CommentCell_Moode.self, forCellReuseIdentifier: CommentCell_Moode.reuseId_Moode)
        return tv
    }()

    /// 底部输入栏容器
    private let inputBar_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.shadowColor   = UIColor.black.cgColor
        v.layer.shadowOffset  = CGSize(width: 0, height: -2)
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius  = 12
        return v
    }()

    /// 当前用户微型头像（输入栏左侧）
    private let myAvatarView_Moode = UserAvatarView_Moode(frame: .zero)

    /// 评论输入框（圆角胶囊）
    private let commentInput_Moode: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Add a comment..."
        tf.font = .systemFont(ofSize: 14)
        tf.textColor = ColorConfig_Moode.textPrimary_Moode
        tf.tintColor = ColorConfig_Moode.primaryGradientStart_Moode
        tf.backgroundColor = ColorConfig_Moode.backgroundPrimary_Moode
        tf.layer.cornerRadius = 20
        tf.layer.borderWidth  = 1
        tf.layer.borderColor  = UIColor(hexstring_Moode: "#E2E8F0").cgColor
        tf.leftView  = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        tf.leftViewMode  = .always
        tf.returnKeyType = .send
        return tf
    }()

    /// 发送按钮（system 类型确保 tintColor 对 SF Symbol 生效）
    private let sendBtn_Moode: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        btn.backgroundColor = ColorConfig_Moode.primaryGradientStart_Moode
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        btn.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        return btn
    }()

    private var inputBarBottom_Moode: Constraint?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Moode.backgroundPrimary_Moode
        setupLayout_Moode()
        buildHeaderView_Moode()
        observeNotifications_Moode()
        observeKeyboard_Moode()
        commentInput_Moode.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 布局完成后确保 tableHeaderView 高度正确（防止 viewDidLoad 时 width=0 导致高度错误）
        layoutHeader_Moode()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 布局

    private func setupLayout_Moode() {
        view.addSubview(tableView_Moode)
        tableView_Moode.delegate   = self
        tableView_Moode.dataSource = self
        tableView_Moode.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        tableView_Moode.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 88, right: 0)

        // 输入栏
        view.addSubview(inputBar_Moode)
        inputBar_Moode.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            inputBarBottom_Moode = make.bottom.equalToSuperview().constraint
            make.height.equalTo(72)
        }

        // 发送按钮（先 addSubview，再 insertSublayer，确保渐变层可见）
        inputBar_Moode.addSubview(sendBtn_Moode)
        sendBtn_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview().offset(-4)
            make.width.height.equalTo(40)
        }
        sendBtn_Moode.addTarget(self, action: #selector(handleSend_Moode), for: .touchUpInside)

        // 输入框（左侧直接 16pt，不再需要头像占位）
        inputBar_Moode.addSubview(commentInput_Moode)
        commentInput_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(sendBtn_Moode.snp.left).offset(-10)
            make.centerY.equalToSuperview().offset(-4)
            make.height.equalTo(40)
        }
    }

    // MARK: - 构建 TableHeaderView

    private func buildHeaderView_Moode() {
        guard let post = currentPost_Moode ?? titleModel_Moode else { return }
        let header = PostHeaderView_Moode(post_moode: post, owner_moode: self)
        header.onLikeTapped_Moode = { [weak self] in self?.handleLike_Moode() }
        // 初始 width 使用屏幕宽度，避免 viewDidLoad 时 view.bounds.width 尚为 0 导致高度计算错误
        let screenW = UIScreen.main.bounds.width
        header.frame = CGRect(x: 0, y: 0, width: screenW, height: 1)
        tableView_Moode.tableHeaderView = header
        layoutHeader_Moode()
    }

    /// 重新计算并更新 tableHeaderView 高度
    /// 使用屏幕宽度作为计算基准，防止布局时序导致宽度为 0
    /// 内置高度守卫避免反复更新引发无限循环
    private func layoutHeader_Moode() {
        guard let header = tableView_Moode.tableHeaderView else { return }
        header.setNeedsLayout()
        header.layoutIfNeeded()
        let screenW = UIScreen.main.bounds.width
        let newH = header.systemLayoutSizeFitting(
            CGSize(width: screenW, height: UIView.layoutFittingCompressedSize.height)
        ).height
        // 高度未变化则跳过，防止触发 viewDidLayoutSubviews → layoutHeader 无限循环
        guard abs(header.frame.size.height - newH) > 1 else { return }
        header.frame.size.height = newH
        tableView_Moode.tableHeaderView = header
    }

    // MARK: - 通知

    private func observeNotifications_Moode() {
        [TitleViewModel_Moode.titleStateDidChangeNotification_Moode,
         UserViewModel_Moode.userStateDidChangeNotification_Moode].forEach {
            NotificationCenter.default.addObserver(self, selector: #selector(onDataChanged_Moode), name: $0, object: nil)
        }
    }

    @objc private func onDataChanged_Moode() {
        if currentPost_Moode == nil {
            Navigation_Moode.pop_Moode(animated: true)
            return
        }
        buildHeaderView_Moode()
        tableView_Moode.reloadData()
    }

    // MARK: - 键盘

    private func observeKeyboard_Moode() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow_Moode(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide_Moode(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow_Moode(_ n: Notification) {
        guard let frame = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let dur   = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        inputBarBottom_Moode?.update(offset: -frame.height)
        UIView.animate(withDuration: dur) { self.view.layoutIfNeeded() }
    }

    @objc private func keyboardWillHide_Moode(_ n: Notification) {
        guard let dur = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        inputBarBottom_Moode?.update(offset: 0)
        UIView.animate(withDuration: dur) { self.view.layoutIfNeeded() }
    }

    // MARK: - 事件

    @objc private func handleSend_Moode() {
        let text = commentInput_Moode.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !text.isEmpty, let post = currentPost_Moode ?? titleModel_Moode else { return }
        // 发送动画
        UIView.animate(withDuration: 0.1, animations: {
            self.sendBtn_Moode.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        }) { _ in
            UIView.animate(withDuration: 0.15) { self.sendBtn_Moode.transform = .identity }
        }
        commentInput_Moode.text = nil
        commentInput_Moode.resignFirstResponder()
        TitleViewModel_Moode.shared_Moode.releaseComment_Moode(post_moode: post, content_moode: text)
    }

    private func handleLike_Moode() {
        guard let post = currentPost_Moode ?? titleModel_Moode else { return }
        TitleViewModel_Moode.shared_Moode.likePost_Moode(post_moode: post)
    }
}

// MARK: - UITableView

extension Detail_Moode: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPost_Moode?.reviews_Moode.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CommentCell_Moode.reuseId_Moode, for: indexPath
        ) as! CommentCell_Moode
        if let post = currentPost_Moode ?? titleModel_Moode,
           let comment = post.reviews_Moode[safeIdx: indexPath.row] {
            cell.configure_Moode(comment: comment, post: post, owner: self)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 80 }
}

// MARK: - UITextFieldDelegate

extension Detail_Moode: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend_Moode(); return true
    }
}

// MARK: - PostHeaderView_Moode

/// 帖子内容区（tableHeaderView）
/// 包含：沉浸式情绪 Banner + 装饰圆 + 浮动 emoji / 作者信息卡 / 媒体 / 标题正文 / 互动行 / 评论区标题
private class PostHeaderView_Moode: UIView {

    var onLikeTapped_Moode: (() -> Void)?

    // MARK: Banner 区

    private let bannerView_Moode = UIView()
    private let bannerGrad_Moode = CAGradientLayer()

    private let decCircle1_Moode: UIView = {
        let v = UIView(); v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.layer.cornerRadius = 80; v.isUserInteractionEnabled = false; return v
    }()
    private let decCircle2_Moode: UIView = {
        let v = UIView(); v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 55; v.isUserInteractionEnabled = false; return v
    }()
    private let decCircle3_Moode: UIView = {
        let v = UIView(); v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.layer.cornerRadius = 35; v.isUserInteractionEnabled = false; return v
    }()

    // MARK: 导航栏（覆盖在 Banner 上）

    private let navOverlay_Moode = UIView()
    /// 半透明圆形返回按钮（直接贴合 banner 色调）
    private let backBtn_Moode: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 18
        return btn
    }()
    private var actionBtn_Moode: UIButton?

    // MARK: 内容卡

    private let cardView_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()

    // 作者区
    private let authorAvatarView_Moode = UserAvatarView_Moode(frame: .zero)
    private let authorGradRing_Moode   = CAGradientLayer()
    private let authorNameLbl_Moode: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = ColorConfig_Moode.textPrimary_Moode; return l
    }()
    private let authorSubLbl_Moode: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 12)
        l.textColor = ColorConfig_Moode.textSecondary_Moode; return l
    }()
    private let moodMiniPill_Moode: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 11, weight: .medium)
        l.textColor = .white; l.textAlignment = .center
        l.layer.cornerRadius = 10; l.clipsToBounds = true; return l
    }()

    // 媒体
    private let mediaView_Moode   = MediaDisplayView_Moode()
    private var mediaH_Moode: Constraint?

    // 文字
    private let titleLbl_Moode: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 22, weight: .heavy)
        l.textColor = ColorConfig_Moode.textPrimary_Moode
        l.numberOfLines = 0; return l
    }()
    private let contentLbl_Moode: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 15)
        l.textColor = ColorConfig_Moode.textSecondary_Moode
        l.numberOfLines = 0; l.lineBreakMode = .byWordWrapping
        l.lineSpacing_Moode(spacing: 4)
        return l
    }()

    // 互动行
    private let actionRow_Moode    = UIView()
    private let likeBtn_Moode      = UIButton(type: .system)
    private let likeCountLbl_Moode: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = ColorConfig_Moode.textSecondary_Moode; return l
    }()
    private let commentCountPill_Moode: UIView = {
        let v = UIView(); v.backgroundColor = UIColor(hexstring_Moode: "#EDF2F7")
        v.layer.cornerRadius = 14; return v
    }()
    private let commentCountLbl_Moode: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = ColorConfig_Moode.textSecondary_Moode; return l
    }()
    private let commentIconLbl_Moode: UILabel = {
        let l = UILabel(); l.text = "💬"; l.font = .systemFont(ofSize: 15); return l
    }()

    // 评论区 header
    private let commentSectionBg_Moode: UIView = {
        let v = UIView(); v.backgroundColor = UIColor(hexstring_Moode: "#F7FAFC")
        v.layer.cornerRadius = 16; return v
    }()
    private let commentSectionEmoji_Moode: UILabel = {
        let l = UILabel(); l.text = "✨"; l.font = .systemFont(ofSize: 18); return l
    }()
    private let commentSectionLbl_Moode: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = ColorConfig_Moode.textPrimary_Moode; return l
    }()
    private let commentSectionBadge_Moode: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 12, weight: .bold)
        l.textColor = .white; l.textAlignment = .center
        l.layer.cornerRadius = 11; l.clipsToBounds = true; return l
    }()
    private let commentSectionBadgeGrad_Moode = CAGradientLayer()

    private let cardDivider_Moode: UIView = {
        let v = UIView(); v.backgroundColor = UIColor(hexstring_Moode: "#EDF2F7"); return v
    }()

    // MARK: 数据
    private var post_Moode: TitleModel_Moode
    private weak var owner_Moode: UIViewController?

    // MARK: 初始化
    init(post_moode: TitleModel_Moode, owner_moode: UIViewController) {
        self.post_Moode  = post_moode
        self.owner_Moode = owner_moode
        super.init(frame: .zero)
        setupUI_Moode()
        bindPost_Moode(post_moode)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI 搭建

    private func setupUI_Moode() {
        backgroundColor = ColorConfig_Moode.backgroundPrimary_Moode

        // ── Banner ──────────────────────────────────────
        addSubview(bannerView_Moode)
        bannerView_Moode.clipsToBounds = true
        bannerView_Moode.layer.insertSublayer(bannerGrad_Moode, at: 0)
        bannerView_Moode.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(140)
        }

        // 装饰圆（禁用交互）
        bannerView_Moode.addSubview(decCircle1_Moode)
        decCircle1_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(160)
            make.top.equalToSuperview().offset(-50)
            make.right.equalToSuperview().offset(50)
        }
        bannerView_Moode.addSubview(decCircle2_Moode)
        decCircle2_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.bottom.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(-30)
        }
        bannerView_Moode.addSubview(decCircle3_Moode)
        decCircle3_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(70)
            make.top.equalToSuperview().offset(60)
            make.left.equalToSuperview().offset(30)
        }

        // ── 自定义导航栏（覆盖在 Banner 上，不受 clipsToBounds 影响）──
        addSubview(navOverlay_Moode)
        navOverlay_Moode.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(88)
        }
        navOverlay_Moode.addSubview(backBtn_Moode)
        backBtn_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(36)
        }
        backBtn_Moode.addTarget(self, action: #selector(handleBack_Moode), for: .touchUpInside)

        // ── 内容卡片 ──────────────────────────────────
        addSubview(cardView_Moode)
        cardView_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(118)
            make.left.right.bottom.equalToSuperview()
        }

        // 作者区
        let avatarWrap = UIView()
        cardView_Moode.addSubview(avatarWrap)
        avatarWrap.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(46)
        }
        // 渐变环
        authorGradRing_Moode.colors     = [ColorConfig_Moode.primaryGradientStart_Moode.cgColor,
                                            ColorConfig_Moode.primaryGradientEnd_Moode.cgColor]
        authorGradRing_Moode.startPoint  = CGPoint(x: 0, y: 0)
        authorGradRing_Moode.endPoint    = CGPoint(x: 1, y: 1)
        authorGradRing_Moode.cornerRadius = 23
        avatarWrap.layer.insertSublayer(authorGradRing_Moode, at: 0)
        avatarWrap.addSubview(authorAvatarView_Moode)
        authorAvatarView_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }

        cardView_Moode.addSubview(authorNameLbl_Moode)
        authorNameLbl_Moode.snp.makeConstraints { make in
            make.centerY.equalTo(avatarWrap)
            make.left.equalTo(avatarWrap.snp.right).offset(12)
        }
        cardView_Moode.addSubview(moodMiniPill_Moode)
        moodMiniPill_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalTo(avatarWrap)
            make.height.equalTo(26)
        }

        // 标题（媒体上方）
        cardView_Moode.addSubview(titleLbl_Moode)
        titleLbl_Moode.snp.makeConstraints { make in
            make.top.equalTo(avatarWrap.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }

        // 媒体（无媒体时高度 0）
        mediaView_Moode.layer.cornerRadius = 18
        mediaView_Moode.clipsToBounds = true
        cardView_Moode.addSubview(mediaView_Moode)
        mediaView_Moode.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_Moode.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
            mediaH_Moode = make.height.equalTo(220).constraint
        }

        // 正文
        cardView_Moode.addSubview(contentLbl_Moode)
        contentLbl_Moode.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Moode.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
        }

        // 分隔线
        cardView_Moode.addSubview(cardDivider_Moode)
        cardDivider_Moode.snp.makeConstraints { make in
            make.top.equalTo(contentLbl_Moode.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }

        // 互动行
        cardView_Moode.addSubview(actionRow_Moode)
        actionRow_Moode.snp.makeConstraints { make in
            make.top.equalTo(cardDivider_Moode.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(32)
        }
        // 点赞按钮
        actionRow_Moode.addSubview(likeBtn_Moode)
        likeBtn_Moode.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        likeBtn_Moode.addTarget(self, action: #selector(handleLike_Moode), for: .touchUpInside)
        // 点赞数
        actionRow_Moode.addSubview(likeCountLbl_Moode)
        likeCountLbl_Moode.snp.makeConstraints { make in
            make.left.equalTo(likeBtn_Moode.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }
        // 评论数胶囊
        actionRow_Moode.addSubview(commentCountPill_Moode)
        commentCountPill_Moode.snp.makeConstraints { make in
            make.left.equalTo(likeCountLbl_Moode.snp.right).offset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(28)
        }
        commentCountPill_Moode.addSubview(commentIconLbl_Moode)
        commentCountPill_Moode.addSubview(commentCountLbl_Moode)
        commentIconLbl_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        commentCountLbl_Moode.snp.makeConstraints { make in
            make.left.equalTo(commentIconLbl_Moode.snp.right).offset(4)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }

        // 评论区 Header
        cardView_Moode.addSubview(commentSectionBg_Moode)
        commentSectionBg_Moode.snp.makeConstraints { make in
            make.top.equalTo(actionRow_Moode.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-8)
        }
        commentSectionBg_Moode.addSubview(commentSectionEmoji_Moode)
        commentSectionEmoji_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
        }
        commentSectionBg_Moode.addSubview(commentSectionLbl_Moode)
        commentSectionLbl_Moode.snp.makeConstraints { make in
            make.left.equalTo(commentSectionEmoji_Moode.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        // 评论数徽标
        commentSectionBg_Moode.addSubview(commentSectionBadge_Moode)
        commentSectionBadge_Moode.snp.makeConstraints { make in
            make.left.equalTo(commentSectionLbl_Moode.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(22)
        }
        commentSectionBadgeGrad_Moode.colors     = [ColorConfig_Moode.primaryGradientStart_Moode.cgColor,
                                                      ColorConfig_Moode.primaryGradientEnd_Moode.cgColor]
        commentSectionBadgeGrad_Moode.startPoint  = CGPoint(x: 0, y: 0)
        commentSectionBadgeGrad_Moode.endPoint    = CGPoint(x: 1, y: 0)
        commentSectionBadgeGrad_Moode.cornerRadius = 11
        commentSectionBadge_Moode.layer.insertSublayer(commentSectionBadgeGrad_Moode, at: 0)
    }

    // MARK: - 数据绑定

    private func bindPost_Moode(_ post: TitleModel_Moode) {
        let mood = post.moodType_Moode

        // Banner 渐变 + emoji + 胶囊
        bannerGrad_Moode.colors    = [mood.gradientStart_Moode.cgColor, mood.gradientEnd_Moode.cgColor]
        bannerGrad_Moode.startPoint = CGPoint(x: 0, y: 0)
        bannerGrad_Moode.endPoint   = CGPoint(x: 1, y: 1)

        // 作者
        authorAvatarView_Moode.configure_Moode(userId_Moode: post.titleUserId_Moode)
        authorNameLbl_Moode.text = post.titleUserName_Moode
        moodMiniPill_Moode.text  = " \(mood.emoji_Moode) \(mood.displayName_Moode) "
        moodMiniPill_Moode.backgroundColor = mood.gradientStart_Moode.withAlphaComponent(0.85)

        // 媒体
        let mediaPaths = post.titleMeidas_Moode.filter { !$0.isEmpty }
        if let first = mediaPaths.first {
            mediaView_Moode.isHidden = false
            mediaH_Moode?.update(offset: 220)
            mediaView_Moode.configure_Moode(mediaPath_Moode: first)
        } else {
            mediaView_Moode.isHidden = true
            mediaH_Moode?.update(offset: 0)
        }

        // 标题 / 正文
        titleLbl_Moode.text   = post.title_Moode
        contentLbl_Moode.text = post.titleContent_Moode

        // 点赞
        let isLiked = TitleViewModel_Moode.shared_Moode.isLikedPost_Moode(post_moode: post)
        let iconName = isLiked ? "heart.fill" : "heart"
        // 与评论胶囊（高度28）保持视觉一致，图标缩小至16pt
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        likeBtn_Moode.setImage(UIImage(systemName: iconName, withConfiguration: cfg), for: .normal)
        likeBtn_Moode.tintColor = isLiked
            ? UIColor(hexstring_Moode: "#FC8181")
            : ColorConfig_Moode.textSecondary_Moode
        likeCountLbl_Moode.text = "\(post.likes_Moode)"

        // 评论数
        let cnt = post.reviews_Moode.count
        commentCountLbl_Moode.text  = "\(cnt)"
        commentSectionLbl_Moode.text = "Comments"
        commentSectionBadge_Moode.text = " \(cnt) "

        // 举报/删除按钮（重建避免重复）
        actionBtn_Moode?.removeFromSuperview()
        if let owner = owner_Moode {
            let btn = ReportDeleteHelper_Moode.createPostReportButton_Moode(
                post_Moode: post,
                size_Moode: 16,
                color_Moode: UIColor.white.withAlphaComponent(0.92),
                from: owner
            )
            btn.backgroundColor = UIColor.white.withAlphaComponent(0.20)
            btn.layer.cornerRadius = 18
            navOverlay_Moode.addSubview(btn)
            btn.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-16)
                make.bottom.equalToSuperview().offset(-12)
                make.width.height.equalTo(36)
            }
            actionBtn_Moode = btn
        }
    }

    // MARK: - 布局更新

    override func layoutSubviews() {
        super.layoutSubviews()
        bannerGrad_Moode.frame              = bannerView_Moode.bounds
        authorGradRing_Moode.frame          = CGRect(origin: .zero, size: CGSize(width: 46, height: 46))
        commentSectionBadgeGrad_Moode.frame = commentSectionBadge_Moode.bounds
    }

    // MARK: - 事件

    @objc private func handleBack_Moode() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Moode.pop_Moode(animated: true)
    }

    @objc private func handleLike_Moode() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        // 心跳动画
        UIView.animate(withDuration: 0.12, animations: {
            self.likeBtn_Moode.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        }) { _ in
            UIView.animate(withDuration: 0.10) { self.likeBtn_Moode.transform = .identity }
        }
        onLikeTapped_Moode?()
    }
}

// MARK: - CommentCell_Moode

/// 评论单元格 — 卡片风格，带渐变头像环 + 举报按钮
class CommentCell_Moode: UITableViewCell {

    static let reuseId_Moode = "CommentCell_Moode"

    // MARK: UI

    private let cardBg_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.shadowColor   = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.05
        v.layer.shadowRadius  = 6
        v.layer.shadowOffset  = CGSize(width: 0, height: 2)
        return v
    }()

    private let avatarView_Moode  = UserAvatarView_Moode(frame: .zero)
    private let avatarRing_Moode  = CAGradientLayer()

    private let nameLbl_Moode: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 13, weight: .bold)
        l.textColor = ColorConfig_Moode.textPrimary_Moode; return l
    }()
    private let contentLbl_Moode: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 14)
        l.textColor = ColorConfig_Moode.textSecondary_Moode
        l.numberOfLines = 0; return l
    }()

    private var reportBtn_Moode: UIButton?

    // MARK: 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupCellUI_Moode()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupCellUI_Moode() {
        contentView.addSubview(cardBg_Moode)
        cardBg_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-6)
        }

        // 头像容器（渐变环）
        let avatarWrap = UIView()
        cardBg_Moode.addSubview(avatarWrap)
        avatarWrap.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(14)
            make.width.height.equalTo(38)
        }
        avatarRing_Moode.colors       = [UIColor(hexstring_Moode: "#B794F6").cgColor,
                                          UIColor(hexstring_Moode: "#90CDF4").cgColor]
        avatarRing_Moode.startPoint    = CGPoint(x: 0, y: 0)
        avatarRing_Moode.endPoint      = CGPoint(x: 1, y: 1)
        avatarRing_Moode.cornerRadius  = 19
        avatarWrap.layer.insertSublayer(avatarRing_Moode, at: 0)
        avatarWrap.addSubview(avatarView_Moode)
        avatarView_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(32)
        }

        cardBg_Moode.addSubview(nameLbl_Moode)
        nameLbl_Moode.snp.makeConstraints { make in
            make.top.equalTo(avatarWrap).offset(2)
            make.left.equalTo(avatarWrap.snp.right).offset(10)
            make.right.equalToSuperview().offset(-46)
        }

        cardBg_Moode.addSubview(contentLbl_Moode)
        contentLbl_Moode.snp.makeConstraints { make in
            make.top.equalTo(nameLbl_Moode.snp.bottom).offset(4)
            make.left.equalTo(nameLbl_Moode)
            make.right.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-14)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarRing_Moode.frame = cardBg_Moode.subviews.first?.bounds ?? .zero
    }

    // MARK: 配置

    /// 绑定评论数据并注入举报按钮
    func configure_Moode(comment: Comment_Moode, post: TitleModel_Moode, owner: UIViewController) {
        avatarView_Moode.configure_Moode(userId_Moode: comment.commentUserId_Moode)
        nameLbl_Moode.text    = comment.commentUserName_Moode
        contentLbl_Moode.text = comment.commentContent_Moode

        reportBtn_Moode?.removeFromSuperview()
        let btn = ReportDeleteHelper_Moode.createCommentReportButton_Moode(
            comment_Moode: comment, post_Moode: post,
            size_Moode: 13, color_Moode: ColorConfig_Moode.textPlaceholder_Moode,
            from: owner
        )
        cardBg_Moode.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(28)
        }
        reportBtn_Moode = btn
    }
}

// MARK: - UILabel 行间距扩展

private extension UILabel {
    /// 设置行间距（无 text 时无副作用）
    func lineSpacing_Moode(spacing: CGFloat) {
        guard let text = text else { return }
        let para = NSMutableParagraphStyle()
        para.lineSpacing = spacing
        attributedText = NSAttributedString(
            string: text,
            attributes: [.paragraphStyle: para]
        )
    }
}

// MARK: - Array 安全下标

private extension Array {
    subscript(safeIdx index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}

