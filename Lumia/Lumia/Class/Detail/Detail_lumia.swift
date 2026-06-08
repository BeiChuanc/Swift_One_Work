import Foundation
import UIKit
import SnapKit

// MARK: - 帖子详情页

/// 帖子详情视图控制器
/// 核心作用：展示帖子完整内容（媒体、标题、正文、评论列表），支持点赞、发表评论、举报/删除
/// 设计思路：
///   - tableView 明确约束 top~bottom(commentBar.top)，评论栏固定高度贴底
///   - 返回按钮 & 举报按钮均为浮层，不影响 tableView 布局
///   - 发送按钮渐变 frame 在 viewDidLayoutSubviews 中更新
class Detail_Lumia: UIViewController {

    // MARK: - 公开属性

    var titleModel_Lumia: TitleModel_Lumia?

    // MARK: - 私有属性

    private var currentPost_Lumia: TitleModel_Lumia? {
        guard let id_Lumia = titleModel_Lumia?.titleId_Lumia else { return titleModel_Lumia }
        return TitleViewModel_Lumia.shared_Lumia.getPosts_Lumia().first {
            $0.titleId_Lumia == id_Lumia
        } ?? titleModel_Lumia
    }

    // MARK: - UI组件

    private lazy var tableView_Lumia: UITableView = {
        let tv_Lumia = UITableView(frame: .zero, style: .plain)
        tv_Lumia.separatorStyle = .none
        tv_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F4EEF8")
        tv_Lumia.showsVerticalScrollIndicator = false
        tv_Lumia.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
        tv_Lumia.keyboardDismissMode = .onDrag
        tv_Lumia.contentInsetAdjustmentBehavior = .never
        return tv_Lumia
    }()

    private let backButton_Lumia = BackButton_Lumia()

    private let reportButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        btn_Lumia.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = .white
        btn_Lumia.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn_Lumia.layer.cornerRadius = 19
        btn_Lumia.layer.borderWidth = 1
        btn_Lumia.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        return btn_Lumia
    }()

    private let commentBar_Lumia = UIView()
    private var commentBarBottom_Lumia: Constraint?

    private let commentField_Lumia: UITextField = {
        let tf_Lumia = UITextField()
        tf_Lumia.placeholder = "Write a comment..."
        tf_Lumia.font = UIFont.systemFont(ofSize: 14)
        tf_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#EDE8F5")
        tf_Lumia.layer.cornerRadius = 15
        tf_Lumia.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        tf_Lumia.leftViewMode = .always
        tf_Lumia.returnKeyType = .send
        return tf_Lumia
    }()

    private let sendCommentButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        btn_Lumia.setImage(UIImage(systemName: "arrow.up", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = .white
        btn_Lumia.layer.cornerRadius = 20
        btn_Lumia.clipsToBounds = true
        return btn_Lumia
    }()

    /// 送礼按钮：使用 Assets 中的 gift_btn 图片，大小与发送按钮保持一致
    private let giftButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        btn_Lumia.setImage(UIImage(named: "gift_btn"), for: .normal)
        btn_Lumia.contentMode = .scaleAspectFit
        btn_Lumia.imageView?.contentMode = .scaleAspectFit
        btn_Lumia.layer.cornerRadius = 20
        btn_Lumia.clipsToBounds = true
        return btn_Lumia
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lumia()
        setupKeyboardObservers_Lumia()
        setupObservers_Lumia()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        tableView_Lumia.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 渐变在布局完成后更新 frame
        let sublayers_Lumia = sendCommentButton_Lumia.layer.sublayers ?? []
        if let grad_Lumia = sublayers_Lumia.compactMap({ $0 as? CAGradientLayer }).first {
            grad_Lumia.frame = sendCommentButton_Lumia.bounds
        } else if sendCommentButton_Lumia.bounds.width > 0 {
            let grad_Lumia = CAGradientLayer()
            grad_Lumia.colors = [
                ColorConfig_Lumia.primaryGradientStart_Lumia.cgColor,
                ColorConfig_Lumia.primaryGradientEnd_Lumia.cgColor
            ]
            grad_Lumia.startPoint = CGPoint(x: 0, y: 0)
            grad_Lumia.endPoint = CGPoint(x: 1, y: 1)
            grad_Lumia.frame = sendCommentButton_Lumia.bounds
            sendCommentButton_Lumia.layer.insertSublayer(grad_Lumia, at: 0)
        }
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        view.backgroundColor = UIColor(hexstring_Lumia: "#F4EEF8")

        // 评论栏先布局，固定高度贴底
        view.addSubview(commentBar_Lumia)
        commentBar_Lumia.backgroundColor = .white
        commentBar_Lumia.layer.shadowColor = UIColor(hexstring_Lumia: "#B794F6").cgColor
        commentBar_Lumia.layer.shadowOpacity = 0.12
        commentBar_Lumia.layer.shadowRadius = 10
        commentBar_Lumia.layer.shadowOffset = CGSize(width: 0, height: -3)
        commentBar_Lumia.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
            commentBarBottom_Lumia = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint
        }
        setupCommentBarContent_Lumia()

        // tableView：明确 bottom = commentBar.top，避免评论栏覆盖内容
        view.addSubview(tableView_Lumia)
        tableView_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(commentBar_Lumia.snp.top)
        }
        tableView_Lumia.delegate = self
        tableView_Lumia.dataSource = self
        tableView_Lumia.register(
            DetailCommentCell_Lumia.self,
            forCellReuseIdentifier: DetailCommentCell_Lumia.reuseId_Lumia
        )
        setupTableHeader_Lumia()

        // 返回按钮（浮层左上）
        view.addSubview(backButton_Lumia)
        backButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        backButton_Lumia.onTapped_Lumia = { Navigation_Lumia.pop_Lumia() }

        // 举报按钮（浮层右上）
        view.addSubview(reportButton_Lumia)
        reportButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(38)
        }
        reportButton_Lumia.addTarget(self, action: #selector(handleReport_Lumia), for: .touchUpInside)
    }

    private func setupCommentBarContent_Lumia() {
        // 发送按钮：固定在评论栏最右侧
        commentBar_Lumia.addSubview(sendCommentButton_Lumia)
        sendCommentButton_Lumia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        sendCommentButton_Lumia.addTarget(self, action: #selector(handleSendComment_Lumia), for: .touchUpInside)

        // 送礼按钮：位于发送按钮左侧 10pt，尺寸与发送按钮一致（40×40）
        commentBar_Lumia.addSubview(giftButton_Lumia)
        giftButton_Lumia.snp.makeConstraints { make in
            make.trailing.equalTo(sendCommentButton_Lumia.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        giftButton_Lumia.addTarget(self, action: #selector(handleGift_Lumia), for: .touchUpInside)

        // 输入框：右侧跟随礼物按钮
        commentBar_Lumia.addSubview(commentField_Lumia)
        commentField_Lumia.delegate = self
        commentField_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(giftButton_Lumia.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }
    }

    private func setupTableHeader_Lumia() {
        guard let post_Lumia = currentPost_Lumia else { return }
        let header_Lumia = DetailHeaderView_Lumia(post: post_Lumia, viewController: self)
        header_Lumia.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 520)
        header_Lumia.onSizeChanged_Lumia = { [weak self] height_Lumia in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableView_Lumia.tableHeaderView?.frame.size.height = height_Lumia
                self.tableView_Lumia.tableHeaderView = self.tableView_Lumia.tableHeaderView
            }
        }
        tableView_Lumia.tableHeaderView = header_Lumia
    }

    // MARK: - 数据刷新

    private func reloadTableHeader_Lumia() {
        guard let post_Lumia = currentPost_Lumia else { return }
        if let header_Lumia = tableView_Lumia.tableHeaderView as? DetailHeaderView_Lumia {
            header_Lumia.update_Lumia(post: post_Lumia)
        }
        tableView_Lumia.reloadData()
    }

    // MARK: - 通知

    private func setupObservers_Lumia() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleTitleChange_Lumia),
            name: TitleViewModel_Lumia.titleStateDidChangeNotification_Lumia, object: nil
        )
    }

    @objc private func handleTitleChange_Lumia() { reloadTableHeader_Lumia() }
    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 键盘

    private func setupKeyboardObservers_Lumia() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleKeyboardWillShow_Lumia(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleKeyboardWillHide_Lumia(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    @objc private func handleKeyboardWillShow_Lumia(_ notification: Notification) {
        guard let kbFrame_Lumia = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_Lumia = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        commentBarBottom_Lumia?.update(offset: -(kbFrame_Lumia.height - view.safeAreaInsets.bottom))
        UIView.animate(withDuration: duration_Lumia) { self.view.layoutIfNeeded() }
    }

    @objc private func handleKeyboardWillHide_Lumia(_ notification: Notification) {
        guard let duration_Lumia = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        commentBarBottom_Lumia?.update(offset: 0)
        UIView.animate(withDuration: duration_Lumia) { self.view.layoutIfNeeded() }
    }

    // MARK: - 事件

    @objc private func handleSendComment_Lumia() {
        let text_Lumia = commentField_Lumia.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !text_Lumia.isEmpty, let post_Lumia = currentPost_Lumia else { return }
        commentField_Lumia.text = ""
        view.endEditing(true)
        Task { @MainActor in
            TitleViewModel_Lumia.shared_Lumia.releaseComment_Lumia(post_lumia: post_Lumia, content_lumia: text_Lumia)
        }
    }

    /// 点击送礼按钮：弹出礼物选择面板 GiftPage_Lumia
    @objc private func handleGift_Lumia() {
        view.endEditing(true)
        let giftPage_Lumia = GiftPage_Lumia()
        giftPage_Lumia.modalPresentationStyle = .overFullScreen
        giftPage_Lumia.modalTransitionStyle = .crossDissolve
        present(giftPage_Lumia, animated: true)
    }

    @objc private func handleReport_Lumia() {
        guard let post_Lumia = currentPost_Lumia else { return }
        let isMyPost_Lumia = UserViewModel_Lumia.shared_Lumia.isCurrentUser_Lumia(userId_lumia: post_Lumia.titleUserId_Lumia)
        if isMyPost_Lumia {
            ReportDeleteHelper_Lumia.delete_Lumia(post_Lumia: post_Lumia, from: self) { Navigation_Lumia.pop_Lumia() }
        } else {
            ReportDeleteHelper_Lumia.report_Lumia(post_Lumia: post_Lumia, from: self) { Navigation_Lumia.pop_Lumia() }
        }
    }
}

// MARK: - UITableViewDelegate & DataSource

extension Detail_Lumia: UITableViewDelegate, UITableViewDataSource {

    /// 过滤后的可见评论
    /// 逻辑：移除已被举报用户（从本地用户列表删除的用户）发出的评论；登录用户自己的评论始终保留
    private var visibleComments_Lumia: [Comment_Lumia] {
        guard let post_Lumia = currentPost_Lumia else { return [] }
        let validUserIds_Lumia = Set(
            LocalData_Lumia.shared_Lumia.userList_Lumia.compactMap { $0.userId_Lumia }
        )
        let myId_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia().userId_Lumia
        return post_Lumia.reviews_Lumia.filter { comment_Lumia in
            comment_Lumia.commentUserId_Lumia == myId_Lumia
                || validUserIds_Lumia.contains(comment_Lumia.commentUserId_Lumia)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleComments_Lumia.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_Lumia = tableView.dequeueReusableCell(
            withIdentifier: DetailCommentCell_Lumia.reuseId_Lumia, for: indexPath
        ) as! DetailCommentCell_Lumia
        guard let post_Lumia = currentPost_Lumia else { return cell_Lumia }
        let comments_Lumia = visibleComments_Lumia
        guard indexPath.row < comments_Lumia.count else { return cell_Lumia }
        cell_Lumia.configure_Lumia(comment: comments_Lumia[indexPath.row], post: post_Lumia, from: self)
        return cell_Lumia
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
}

// MARK: - UITextFieldDelegate

extension Detail_Lumia: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendComment_Lumia()
        return true
    }
}

// MARK: - 帖子详情页 Header

/// 帖子详情顶部 Header
/// 设计要点：
///   1. 媒体透明 UIButton 最先添加（z 最低），用于点击进入播放
///   2. 渐变遮罩（isUserInteractionEnabled=false）其次
///   3. 内容白卡次之
///   4. 用户信息（头像环/名字）最后添加（z 最高），确保可见且不被白卡遮挡
///   5. 高度由 contentCard.frame.maxY+16 在 layoutSubviews 中实时计算，保证评论 Cell 可见
private class DetailHeaderView_Lumia: UIView {

    var onSizeChanged_Lumia: ((CGFloat) -> Void)?
    private var post_Lumia: TitleModel_Lumia
    private weak var vc_Lumia: UIViewController?

    // MARK: - 媒体区

    private let mediaView_Lumia: MediaDisplayView_Lumia = {
        let mv_Lumia = MediaDisplayView_Lumia()
        mv_Lumia.layer.cornerRadius = 0
        mv_Lumia.clipsToBounds = true
        return mv_Lumia
    }()

    /// 透明点击按钮覆盖媒体区（比 gesture recognizer 更可靠）
    private let mediaTapButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        btn_Lumia.backgroundColor = .clear
        return btn_Lumia
    }()

    private let mediaGradient_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.isUserInteractionEnabled = false
        return v_Lumia
    }()
    private var mediaGradientLayer_Lumia: CAGradientLayer?

    // MARK: - 内容白卡（z 低于用户信息）

    private let contentCard_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = .white
        v_Lumia.layer.cornerRadius = 24
        v_Lumia.layer.shadowColor = UIColor(hexstring_Lumia: "#B794F6").cgColor
        v_Lumia.layer.shadowOpacity = 0.12
        v_Lumia.layer.shadowRadius = 16
        v_Lumia.layer.shadowOffset = CGSize(width: 0, height: 6)
        return v_Lumia
    }()

    private let titleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#1A1030")
        lbl_Lumia.numberOfLines = 0
        return lbl_Lumia
    }()

    private let contentLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 14.5, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#6B5A90")
        lbl_Lumia.numberOfLines = 0
        lbl_Lumia.lineBreakMode = .byWordWrapping
        return lbl_Lumia
    }()

    // MARK: - 点赞行

    private let likeButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        btn_Lumia.isUserInteractionEnabled = true
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        btn_Lumia.setImage(UIImage(systemName: "heart", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.setImage(UIImage(systemName: "heart.fill", withConfiguration: cfg_Lumia), for: .selected)
        btn_Lumia.tintColor = ColorConfig_Lumia.secondaryGradientStart_Lumia
        return btn_Lumia
    }()

    private let likeCountBadge_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.isUserInteractionEnabled = false
        v_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#FBB6CE", alpha_Lumia: 0.18)
        v_Lumia.layer.cornerRadius = 12
        v_Lumia.layer.borderWidth = 1
        v_Lumia.layer.borderColor = UIColor(hexstring_Lumia: "#FBB6CE", alpha_Lumia: 0.40).cgColor
        return v_Lumia
    }()

    private let likeCountLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl_Lumia.textColor = ColorConfig_Lumia.secondaryGradientStart_Lumia
        return lbl_Lumia
    }()

    // MARK: - 评论区标题

    private let commentDot_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = ColorConfig_Lumia.primaryGradientStart_Lumia
        v_Lumia.layer.cornerRadius = 4
        return v_Lumia
    }()

    private let commentSectionTitle_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#3A1A6A")
        return lbl_Lumia
    }()

    // MARK: - 用户信息（最后添加，z 最高，不被白卡遮挡）

    private let avatarRing_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.layer.cornerRadius = 22
        v_Lumia.layer.borderWidth = 2.5
        v_Lumia.layer.borderColor = UIColor.white.cgColor
        return v_Lumia
    }()

    private let avatarView_Lumia = UserAvatarView_Lumia()

    private let userNameLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lbl_Lumia.textColor = .white
        return lbl_Lumia
    }()

    private let filmTag_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "📷 Film"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.80)
        return lbl_Lumia
    }()

    // MARK: - 初始化

    init(post: TitleModel_Lumia, viewController: UIViewController) {
        self.post_Lumia = post
        self.vc_Lumia = viewController
        super.init(frame: .zero)
        setupUI_Lumia()
        configure_Lumia(with: post)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        mediaGradientLayer_Lumia?.frame = mediaGradient_Lumia.bounds
        // 用 contentCard 的实际 maxY + 间距 = header 实际需要的高度，比 systemLayoutSizeFitting 更可靠
        let newH_Lumia = contentCard_Lumia.frame.maxY + 16
        if newH_Lumia > 100 && abs(bounds.height - newH_Lumia) > 1 {
            onSizeChanged_Lumia?(newH_Lumia)
        }
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        backgroundColor = UIColor(hexstring_Lumia: "#F4EEF8")

        // ① 媒体视图
        addSubview(mediaView_Lumia)
        mediaView_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(300)
        }

        // ② 媒体透明点击按钮（z 刚好在媒体上方，低于用户信息 overlay）
        addSubview(mediaTapButton_Lumia)
        mediaTapButton_Lumia.snp.makeConstraints { make in
            make.edges.equalTo(mediaView_Lumia)
        }
        mediaTapButton_Lumia.addTarget(self, action: #selector(handleMediaTap_Lumia), for: .touchUpInside)

        // ③ 媒体底部渐变遮罩（不拦截触摸）
        addSubview(mediaGradient_Lumia)
        mediaGradient_Lumia.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(mediaView_Lumia.snp.bottom)
            make.height.equalTo(110)
        }
        let mgLayer_Lumia = CAGradientLayer()
        mgLayer_Lumia.colors = [
            UIColor.black.withAlphaComponent(0).cgColor,
            UIColor.black.withAlphaComponent(0.62).cgColor
        ]
        mgLayer_Lumia.startPoint = CGPoint(x: 0.5, y: 0)
        mgLayer_Lumia.endPoint = CGPoint(x: 0.5, y: 1)
        mediaGradient_Lumia.layer.insertSublayer(mgLayer_Lumia, at: 0)
        mediaGradientLayer_Lumia = mgLayer_Lumia

        // ④ 内容白卡（在用户信息之前添加，z 低于用户信息 overlay）
        addSubview(contentCard_Lumia)
        contentCard_Lumia.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Lumia.snp.bottom).offset(-20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        setupContentCard_Lumia()

        // ⑤ 用户信息 overlay（最后添加，z 最高，覆盖在白卡顶部区域上方）
        addSubview(avatarRing_Lumia)
        avatarRing_Lumia.snp.makeConstraints { make in
            make.bottom.equalTo(mediaView_Lumia.snp.bottom).offset(-14)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(44)
        }
        avatarRing_Lumia.addSubview(avatarView_Lumia)
        avatarView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview().inset(2.5) }
        avatarView_Lumia.layer.cornerRadius = 18
        avatarView_Lumia.clipsToBounds = true
        let avatarTap_Lumia = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap_Lumia))
        avatarRing_Lumia.addGestureRecognizer(avatarTap_Lumia)
        avatarRing_Lumia.isUserInteractionEnabled = true

        addSubview(userNameLabel_Lumia)
        userNameLabel_Lumia.snp.makeConstraints { make in
            make.leading.equalTo(avatarRing_Lumia.snp.trailing).offset(10)
            make.bottom.equalTo(avatarRing_Lumia.snp.centerY).offset(1)
        }

        addSubview(filmTag_Lumia)
        filmTag_Lumia.snp.makeConstraints { make in
            make.leading.equalTo(userNameLabel_Lumia)
            make.top.equalTo(avatarRing_Lumia.snp.centerY).offset(2)
        }
    }

    /// 构建内容白卡内部布局
    private func setupContentCard_Lumia() {
        contentCard_Lumia.addSubview(titleLabel_Lumia)
        titleLabel_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
        }

        contentCard_Lumia.addSubview(contentLabel_Lumia)
        contentLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Lumia.snp.bottom).offset(10)
            make.leading.trailing.equalTo(titleLabel_Lumia)
        }

        contentCard_Lumia.addSubview(likeButton_Lumia)
        likeButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Lumia.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(36)
        }
        likeButton_Lumia.addTarget(self, action: #selector(handleLike_Lumia), for: .touchUpInside)

        contentCard_Lumia.addSubview(likeCountBadge_Lumia)
        likeCountBadge_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton_Lumia)
            make.leading.equalTo(likeButton_Lumia.snp.trailing).offset(6)
            make.height.equalTo(24)
        }
        likeCountBadge_Lumia.addSubview(likeCountLabel_Lumia)
        likeCountLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
        }

        let divider_Lumia = UIView()
        divider_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#E8DCFF")
        contentCard_Lumia.addSubview(divider_Lumia)
        divider_Lumia.snp.makeConstraints { make in
            make.top.equalTo(likeButton_Lumia.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(0.5)
        }

        contentCard_Lumia.addSubview(commentDot_Lumia)
        commentDot_Lumia.snp.makeConstraints { make in
            make.top.equalTo(divider_Lumia.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(8)
            make.bottom.equalToSuperview().offset(-16)
        }

        contentCard_Lumia.addSubview(commentSectionTitle_Lumia)
        commentSectionTitle_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(commentDot_Lumia)
            make.leading.equalTo(commentDot_Lumia.snp.trailing).offset(8)
        }
    }

    // MARK: - 数据绑定

    func configure_Lumia(with post: TitleModel_Lumia) {
        self.post_Lumia = post
        avatarView_Lumia.configure_Lumia(userId_Lumia: post.titleUserId_Lumia)
        userNameLabel_Lumia.text = post.titleUserName_Lumia
        mediaView_Lumia.configure_Lumia(mediaPath_Lumia: post.titleMeidas_Lumia.first)
        titleLabel_Lumia.text = post.title_Lumia
        contentLabel_Lumia.text = post.titleContent_Lumia
        likeCountLabel_Lumia.text = "\(post.likes_Lumia) likes"
        likeButton_Lumia.isSelected = TitleViewModel_Lumia.shared_Lumia.isLikedPost_Lumia(post_lumia: post)
        commentSectionTitle_Lumia.text = "Comments (\(post.reviews_Lumia.count))"
        setNeedsLayout()
    }

    func update_Lumia(post: TitleModel_Lumia) { configure_Lumia(with: post) }

    // MARK: - 事件

    @objc private func handleLike_Lumia() {
        likeButton_Lumia.animatePulse_Lumia()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Task { @MainActor in
            TitleViewModel_Lumia.shared_Lumia.likePost_Lumia(post_lumia: self.post_Lumia)
        }
    }

    @objc private func handleAvatarTap_Lumia() {
        let user_Lumia = UserViewModel_Lumia.shared_Lumia.getUserById_Lumia(userId_lumia: post_Lumia.titleUserId_Lumia)
        Navigation_Lumia.toUserInfo_Lumia(with: user_Lumia)
    }

    @objc private func handleMediaTap_Lumia() {
        guard let mediaPath_Lumia = post_Lumia.titleMeidas_Lumia.first else { return }
        let player_Lumia = MediaPlayerPage_Lumia()
        player_Lumia.mediaPath_Lumia = mediaPath_Lumia
        // fullScreen 避免 iOS 13+ 默认 pageSheet 导致的卡顿和未完全覆盖屏幕问题
        player_Lumia.modalPresentationStyle = .fullScreen
        player_Lumia.modalTransitionStyle = .crossDissolve
        Navigation_Lumia.present_Lumia(viewController: player_Lumia)
    }
}

// MARK: - 评论 Cell

/// 帖子详情评论 Cell（渐变左竖条 + 头像环 + 用户名 + 内容 + 举报按钮）
private class DetailCommentCell_Lumia: UITableViewCell {

    static let reuseId_Lumia = "DetailCommentCell_Lumia"

    private var currentComment_Lumia: Comment_Lumia?
    private var currentPost_Lumia: TitleModel_Lumia?
    private weak var fromVC_Lumia: UIViewController?

    private let cardView_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = .white
        v_Lumia.layer.cornerRadius = 16
        v_Lumia.layer.shadowColor = UIColor(hexstring_Lumia: "#B794F6").cgColor
        v_Lumia.layer.shadowOpacity = 0.08
        v_Lumia.layer.shadowRadius = 8
        v_Lumia.layer.shadowOffset = CGSize(width: 0, height: 3)
        return v_Lumia
    }()

    private let accentBar_Lumia = UIView()
    private var accentGradient_Lumia: CAGradientLayer?

    private let avatarRing_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.layer.cornerRadius = 18
        v_Lumia.layer.borderWidth = 1.5
        v_Lumia.layer.borderColor = UIColor(hexstring_Lumia: "#B794F6", alpha_Lumia: 0.45).cgColor
        v_Lumia.backgroundColor = .white
        return v_Lumia
    }()

    private let avatarView_Lumia = UserAvatarView_Lumia()

    private let nameLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#3A1A6A")
        return lbl_Lumia
    }()

    private let commentLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Lumia.textColor = UIColor(hexstring_Lumia: "#7060A0")
        lbl_Lumia.numberOfLines = 0
        return lbl_Lumia
    }()

    private let reportButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        btn_Lumia.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg_Lumia), for: .normal)
        btn_Lumia.tintColor = UIColor(hexstring_Lumia: "#C4B0E0")
        return btn_Lumia
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        accentGradient_Lumia?.frame = accentBar_Lumia.bounds
    }

    private func setupUI_Lumia() {
        contentView.addSubview(cardView_Lumia)
        cardView_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-5)
        }

        cardView_Lumia.addSubview(accentBar_Lumia)
        accentBar_Lumia.layer.cornerRadius = 1.5
        accentBar_Lumia.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        accentBar_Lumia.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(3)
        }
        let grad_Lumia = CAGradientLayer()
        grad_Lumia.colors = [
            ColorConfig_Lumia.primaryGradientStart_Lumia.cgColor,
            ColorConfig_Lumia.primaryGradientEnd_Lumia.cgColor
        ]
        grad_Lumia.startPoint = CGPoint(x: 0.5, y: 0)
        grad_Lumia.endPoint = CGPoint(x: 0.5, y: 1)
        grad_Lumia.cornerRadius = 1.5
        accentBar_Lumia.layer.insertSublayer(grad_Lumia, at: 0)
        accentGradient_Lumia = grad_Lumia

        cardView_Lumia.addSubview(avatarRing_Lumia)
        avatarRing_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(accentBar_Lumia.snp.trailing).offset(12)
            make.width.height.equalTo(36)
        }
        avatarRing_Lumia.addSubview(avatarView_Lumia)
        avatarView_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview().inset(2) }
        avatarView_Lumia.layer.cornerRadius = 15
        avatarView_Lumia.clipsToBounds = true

        cardView_Lumia.addSubview(reportButton_Lumia)
        reportButton_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(28)
        }
        reportButton_Lumia.addTarget(self, action: #selector(handleReport_Lumia), for: .touchUpInside)

        cardView_Lumia.addSubview(nameLabel_Lumia)
        nameLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(avatarRing_Lumia)
            make.leading.equalTo(avatarRing_Lumia.snp.trailing).offset(10)
            make.trailing.equalTo(reportButton_Lumia.snp.leading).offset(-4)
        }

        cardView_Lumia.addSubview(commentLabel_Lumia)
        commentLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Lumia.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel_Lumia)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    func configure_Lumia(comment: Comment_Lumia, post: TitleModel_Lumia, from vc: UIViewController) {
        currentComment_Lumia = comment
        currentPost_Lumia = post
        fromVC_Lumia = vc
        avatarView_Lumia.configure_Lumia(userId_Lumia: comment.commentUserId_Lumia)
        nameLabel_Lumia.text = comment.commentUserName_Lumia
        commentLabel_Lumia.text = comment.commentContent_Lumia
    }

    @objc private func handleReport_Lumia() {
        guard let c_Lumia = currentComment_Lumia, let p_Lumia = currentPost_Lumia, let vc_Lumia = fromVC_Lumia else { return }
        ReportDeleteHelper_Lumia.report_Lumia(comment_Lumia: c_Lumia, post_Lumia: p_Lumia, from: vc_Lumia)
    }
}
