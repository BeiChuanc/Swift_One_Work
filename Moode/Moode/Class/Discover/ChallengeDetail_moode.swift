import Foundation
import UIKit
import SnapKit

// MARK: - 挑战详情页

/// 情绪挑战详情页
/// 功能：展示挑战信息（渐变头部 + emoji + 标题 + 参与人数 + 官方标识）、
///       预制挑战评论列表（UITableView），以及底部输入栏支持用户发送评论
/// 设计：沉浸式渐变头部 + 白色圆角内容区 + 固定底部输入框（随键盘上移）
class ChallengeDetail_Moode: UIViewController {

    // MARK: - 数据

    /// 挑战数据，由外部（Navigation_Moode）注入
    var challenge_Moode: MoodChallenge_Moode?

    /// 当前展示的评论列表（预制 + 用户新增）
    private var comments_Moode: [Comment_Moode] = []

    // MARK: - 渐变头部

    private let headerView_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.clipsToBounds = true
        v_Moode.layer.cornerRadius = 28
        v_Moode.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return v_Moode
    }()
    private var headerGradient_Moode: CAGradientLayer?

    /// 大号装饰 Emoji
    private let decorEmoji_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 72)
        l_Moode.alpha = 0.22
        return l_Moode
    }()

    /// 装饰圆圈
    private let decCircle1_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        v_Moode.layer.cornerRadius = 60
        return v_Moode
    }()

    private let decCircle2_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v_Moode.layer.cornerRadius = 40
        return v_Moode
    }()

    /// 返回按钮
    private let backBtn_Moode: UIButton = {
        let btn_Moode = UIButton(type: .system)
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn_Moode.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg_Moode), for: .normal)
        btn_Moode.tintColor = .white
        btn_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        btn_Moode.layer.cornerRadius = 18
        return btn_Moode
    }()

    /// 官方 / 社区标识胶囊
    private let sourceBadge_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 11, weight: .bold)
        l_Moode.textColor = .white
        l_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        l_Moode.layer.cornerRadius = 10
        l_Moode.clipsToBounds = true
        l_Moode.textAlignment = .center
        return l_Moode
    }()

    /// 挑战标题
    private let titleLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 28, weight: .heavy)
        l_Moode.textColor = .white
        l_Moode.numberOfLines = 2
        return l_Moode
    }()

    /// 参与人数
    private let participantLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 13, weight: .medium)
        l_Moode.textColor = UIColor.white.withAlphaComponent(0.80)
        return l_Moode
    }()

    private let participantIcon_Moode: UIImageView = {
        let iv_Moode = UIImageView()
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        iv_Moode.image = UIImage(systemName: "person.2.fill", withConfiguration: cfg_Moode)
        iv_Moode.tintColor = UIColor.white.withAlphaComponent(0.80)
        iv_Moode.contentMode = .scaleAspectFit
        return iv_Moode
    }()

    // MARK: - 内容区

    /// 底部白色圆角内容卡片
    private let contentCard_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor(hexstring_Moode: "#F8F6FF")
        v_Moode.layer.cornerRadius = 24
        v_Moode.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v_Moode
    }()

    /// 评论区标题行
    private let sectionLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Community Comments"
        l_Moode.font = .systemFont(ofSize: 16, weight: .bold)
        l_Moode.textColor = UIColor(hexstring_Moode: "#1A1A2E")
        return l_Moode
    }()

    private let sectionAccent_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor(hexstring_Moode: "#A78BFA")
        v_Moode.layer.cornerRadius = 2
        return v_Moode
    }()

    /// 评论列表
    private let tableView_Moode: UITableView = {
        let tv_Moode = UITableView(frame: .zero, style: .plain)
        tv_Moode.backgroundColor = .clear
        tv_Moode.separatorStyle = .none
        tv_Moode.showsVerticalScrollIndicator = false
        tv_Moode.register(ChallengeCommentCell_Moode.self,
                          forCellReuseIdentifier: ChallengeCommentCell_Moode.reuseId_Moode)
        return tv_Moode
    }()

    // MARK: - 底部输入栏

    private let inputBar_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = .white
        v_Moode.layer.cornerRadius = 24
        v_Moode.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v_Moode.layer.shadowColor = UIColor.black.cgColor
        v_Moode.layer.shadowOpacity = 0.06
        v_Moode.layer.shadowRadius = 10
        v_Moode.layer.shadowOffset = CGSize(width: 0, height: -2)
        return v_Moode
    }()

    private let inputField_Moode: UITextField = {
        let tf_Moode = UITextField()
        tf_Moode.placeholder = "Share your thoughts..."
        tf_Moode.font = .systemFont(ofSize: 14)
        tf_Moode.textColor = UIColor(hexstring_Moode: "#1A1A2E")
        tf_Moode.backgroundColor = UIColor(hexstring_Moode: "#F5F3FF")
        tf_Moode.layer.cornerRadius = 18
        tf_Moode.returnKeyType = .send
        // 左内边距
        let pad_Moode = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        tf_Moode.leftView = pad_Moode
        tf_Moode.leftViewMode = .always
        return tf_Moode
    }()

    private let sendBtn_Moode: UIButton = {
        let btn_Moode = UIButton(type: .system)
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        btn_Moode.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg_Moode), for: .normal)
        btn_Moode.tintColor = .white
        btn_Moode.backgroundColor = UIColor(hexstring_Moode: "#A78BFA")
        btn_Moode.layer.cornerRadius = 18
        return btn_Moode
    }()

    /// 底部输入栏底部约束（随键盘上移）
    private var inputBarBottomConstraint_Moode: Constraint?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Moode: "#F8F6FF")
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI_Moode()
        setupKeyboard_Moode()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 每次显示时（含从子页面返回）重新加载预制评论，保证数据一致
        bindData_Moode()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderGradient_Moode()
    }

    // MARK: - UI 搭建

    private func setupUI_Moode() {
        setupHeader_Moode()
        setupContentCard_Moode()
        setupInputBar_Moode()
    }

    /// 搭建渐变头部
    private func setupHeader_Moode() {
        view.addSubview(headerView_Moode)
        headerView_Moode.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(220)
        }

        // 装饰圆
        headerView_Moode.addSubview(decCircle1_Moode)
        decCircle1_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(-20)
            make.width.height.equalTo(120)
        }
        headerView_Moode.addSubview(decCircle2_Moode)
        decCircle2_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(10)
            make.width.height.equalTo(80)
        }

        // 大号装饰 Emoji
        headerView_Moode.addSubview(decorEmoji_Moode)
        decorEmoji_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-10)
        }

        // 返回按钮
        headerView_Moode.addSubview(backBtn_Moode)
        backBtn_Moode.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
        backBtn_Moode.addTarget(self, action: #selector(handleBack_Moode), for: .touchUpInside)

        // 官方标识
        headerView_Moode.addSubview(sourceBadge_Moode)
        sourceBadge_Moode.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(18)
            make.left.equalTo(backBtn_Moode.snp.right).offset(10)
            make.height.equalTo(24)
        }
        sourceBadge_Moode.snp.makeConstraints { _ in }

        // 参与人数行（位于头部可见区靠下，留出与白卡重叠区的安全距离）
        headerView_Moode.addSubview(participantIcon_Moode)
        headerView_Moode.addSubview(participantLabel_Moode)
        participantIcon_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-36)
            make.width.equalTo(18)
            make.height.equalTo(14)
        }
        participantLabel_Moode.snp.makeConstraints { make in
            make.left.equalTo(participantIcon_Moode.snp.right).offset(6)
            make.centerY.equalTo(participantIcon_Moode)
        }

        // 挑战标题（参与人数行正上方，向上留足间距）
        headerView_Moode.addSubview(titleLabel_Moode)
        titleLabel_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-90)
            make.bottom.equalTo(participantIcon_Moode.snp.top).offset(-8)
        }
    }

    /// 搭建评论列表内容区
    private func setupContentCard_Moode() {
        view.addSubview(contentCard_Moode)
        contentCard_Moode.snp.makeConstraints { make in
            make.top.equalTo(headerView_Moode.snp.bottom).offset(-16)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        // 区域标题
        let sectionRow_Moode = UIView()
        contentCard_Moode.addSubview(sectionRow_Moode)
        sectionRow_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(22)
        }
        sectionRow_Moode.addSubview(sectionAccent_Moode)
        sectionAccent_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(18)
        }
        sectionRow_Moode.addSubview(sectionLabel_Moode)
        sectionLabel_Moode.snp.makeConstraints { make in
            make.left.equalTo(sectionAccent_Moode.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }

        // 评论表格
        contentCard_Moode.addSubview(tableView_Moode)
        tableView_Moode.snp.makeConstraints { make in
            make.top.equalTo(sectionRow_Moode.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-80)
        }
        tableView_Moode.dataSource = self
        tableView_Moode.delegate = self
    }

    /// 搭建底部输入栏
    private func setupInputBar_Moode() {
        view.addSubview(inputBar_Moode)
        inputBar_Moode.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            inputBarBottomConstraint_Moode = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint
            make.height.equalTo(72)
        }

        inputBar_Moode.addSubview(inputField_Moode)
        inputField_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(36)
        }
        inputField_Moode.delegate = self

        inputBar_Moode.addSubview(sendBtn_Moode)
        sendBtn_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
            make.left.equalTo(inputField_Moode.snp.right).offset(8)
        }
        sendBtn_Moode.addTarget(self, action: #selector(handleSend_Moode), for: .touchUpInside)
    }

    // MARK: - 渐变更新

    /// 根据挑战情绪类型更新头部渐变
    private func updateHeaderGradient_Moode() {
        guard let challenge_Moode = challenge_Moode else { return }
        if headerGradient_Moode == nil {
            let grad_Moode = challenge_Moode.moodType_Moode.createGradientLayer_Moode(
                frame_Moode: headerView_Moode.bounds
            )
            headerView_Moode.layer.insertSublayer(grad_Moode, at: 0)
            headerGradient_Moode = grad_Moode
        }
        headerGradient_Moode?.frame = headerView_Moode.bounds
    }

    // MARK: - 数据绑定

    /// 绑定挑战数据到 UI，并加载预制评论
    private func bindData_Moode() {
        guard let challenge_Moode = challenge_Moode else { return }
        decorEmoji_Moode.text = challenge_Moode.emoji_Moode
        titleLabel_Moode.text = challenge_Moode.title_Moode
        sourceBadge_Moode.text = challenge_Moode.isOfficial_Moode ? "  ✦ Official  " : "  ◈ Community  "

        let count_Moode = challenge_Moode.participantCount_Moode
        participantLabel_Moode.text = count_Moode >= 1000
            ? String(format: "%.1fk participants", Double(count_Moode) / 1000)
            : "\(count_Moode) participants"

        // 加载预制评论
        comments_Moode = LocalData_Moode.shared_Moode.challengeComments_Moode[challenge_Moode.challengeId_Moode] ?? []
        tableView_Moode.reloadData()
    }

    // MARK: - 键盘处理

    private func setupKeyboard_Moode() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleKeyboardWillShow_Moode(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleKeyboardWillHide_Moode(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
        let tap_Moode = UITapGestureRecognizer(target: self, action: #selector(handleBgTap_Moode))
        tap_Moode.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Moode)
    }

    @objc private func handleKeyboardWillShow_Moode(_ notification_moode: Notification) {
        guard let kbFrame_moode = notification_moode.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_moode = notification_moode.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        let safeBottom_moode = view.safeAreaInsets.bottom
        UIView.animate(withDuration: duration_moode) {
            self.inputBarBottomConstraint_Moode?.update(offset: -(kbFrame_moode.height - safeBottom_moode))
            self.view.layoutIfNeeded()
        }
    }

    @objc private func handleKeyboardWillHide_Moode(_ notification_moode: Notification) {
        guard let duration_moode = notification_moode.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        UIView.animate(withDuration: duration_moode) {
            self.inputBarBottomConstraint_Moode?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }

    @objc private func handleBgTap_Moode() {
        view.endEditing(true)
    }

    // MARK: - 事件处理

    @objc private func handleBack_Moode() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        navigationController?.popViewController(animated: true)
    }

    /// 发送评论：登录校验 → 非空校验 → 插入评论 → 刷新列表
    @objc private func handleSend_Moode() {
        guard UserViewModel_Moode.shared_Moode.isLoggedIn_Moode else {
            Navigation_Moode.toLogin_Moode()
            return
        }
        let text_moode = inputField_Moode.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !text_moode.isEmpty else { return }

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let currentUser_moode = UserViewModel_Moode.shared_Moode.getCurrentUser_Moode()
        let newComment_moode = Comment_Moode(
            commentId_Moode: 9900 + comments_Moode.count,
            commentUserId_Moode: currentUser_moode.userId_Moode ?? 0,
            commentUserName_Moode: currentUser_moode.userName_Moode ?? "Me",
            commentContent_Moode: text_moode
        )
        comments_Moode.append(newComment_moode)
        inputField_Moode.text = ""
        view.endEditing(true)
        tableView_Moode.reloadData()
        // 滚动到最新评论
        let lastIndexPath_moode = IndexPath(row: comments_Moode.count - 1, section: 0)
        tableView_Moode.scrollToRow(at: lastIndexPath_moode, at: .bottom, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension ChallengeDetail_Moode: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments_Moode.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_moode = tableView.dequeueReusableCell(
            withIdentifier: ChallengeCommentCell_Moode.reuseId_Moode,
            for: indexPath
        ) as? ChallengeCommentCell_Moode else { return UITableViewCell() }

        let comment_moode = comments_Moode[indexPath.row]
        cell_moode.configure_Moode(comment_moode: comment_moode)

        // 举报/删除回调：操作后从本地列表移除并刷新
        cell_moode.onReportTapped_Moode = { [weak self] targetComment_moode in
            guard let self = self else { return }
            let isMyComment_moode = UserViewModel_Moode.shared_Moode.isCurrentUser_Moode(
                userId_moode: targetComment_moode.commentUserId_Moode
            )
            // 移除评论并刷新列表
            let removeComment_moode: () -> Void = { [weak self] in
                guard let self = self else { return }
                self.comments_Moode.removeAll { $0.commentId_Moode == targetComment_moode.commentId_Moode }
                self.tableView_Moode.reloadData()
            }
            if isMyComment_moode {
                // 自己的评论：弹确认框，确认后删除
                let alert_moode = UIAlertController(
                    title: "Delete Comment",
                    message: "Are you sure you want to delete this comment?",
                    preferredStyle: .alert
                )
                alert_moode.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                    removeComment_moode()
                    Utils_Moode.showSuccess_Moode(message_Moode: "Deleted successfully.")
                })
                alert_moode.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert_moode, animated: true)
            } else {
                // 他人评论：弹举报 ActionSheet，选择原因后移除并提示成功
                UIAlertController.report_Moode(with: false) {
                    removeComment_moode()
                    Utils_Moode.showSuccess_Moode(
                        message_Moode: "This comment will no longer appear."
                    )
                }
            }
        }
        return cell_moode
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UITextFieldDelegate

extension ChallengeDetail_Moode: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend_Moode()
        return false
    }
}

// MARK: - 挑战评论单元格

/// 挑战评论单元格
/// 功能：展示头像（UserAvatarView）+ 用户名 + 评论内容 + 右上角举报/删除按钮，白色圆角卡片样式
/// 关键方法：configure_Moode 绑定 Comment_Moode 数据；onReportTapped_Moode 由外部 VC 注入
class ChallengeCommentCell_Moode: UITableViewCell {

    static let reuseId_Moode = "ChallengeCommentCell_Moode"

    // MARK: - 回调

    /// 举报/删除按钮回调，携带评论模型，由外部 VC 处理操作逻辑
    var onReportTapped_Moode: ((Comment_Moode) -> Void)?

    // MARK: - 私有数据

    private var comment_Moode: Comment_Moode?

    // MARK: - UI 组件

    private let cardView_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = .white
        v_Moode.layer.cornerRadius = 16
        v_Moode.layer.shadowColor = UIColor(hexstring_Moode: "#8B5CF6").cgColor
        v_Moode.layer.shadowOpacity = 0.06
        v_Moode.layer.shadowRadius = 8
        v_Moode.layer.shadowOffset = CGSize(width: 0, height: 2)
        return v_Moode
    }()

    private let avatarView_Moode = UserAvatarView_Moode()

    private let nameLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 13, weight: .semibold)
        l_Moode.textColor = UIColor(hexstring_Moode: "#1A1A2E")
        return l_Moode
    }()

    private let contentLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 13)
        l_Moode.textColor = UIColor(hexstring_Moode: "#444466")
        l_Moode.numberOfLines = 0
        return l_Moode
    }()

    /// 右上角举报/删除按钮（26×26pt，半透明背景圆形）
    private let reportBtn_Moode: UIButton = {
        let btn_Moode = UIButton(type: .system)
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        btn_Moode.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg_Moode), for: .normal)
        btn_Moode.tintColor = UIColor(hexstring_Moode: "#6C5CE7")
        btn_Moode.backgroundColor = UIColor(hexstring_Moode: "#E8E4FF")
        btn_Moode.layer.cornerRadius = 13
        btn_Moode.clipsToBounds = true
        return btn_Moode
    }()

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI_Moode()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI 搭建

    private func setupUI_Moode() {
        contentView.addSubview(cardView_Moode)
        cardView_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-6)
        }

        // 举报按钮（右上角，26×26pt）
        cardView_Moode.addSubview(reportBtn_Moode)
        reportBtn_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(26)
        }
        reportBtn_Moode.addTarget(self, action: #selector(handleReportTapped_Moode), for: .touchUpInside)

        cardView_Moode.addSubview(avatarView_Moode)
        avatarView_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(14)
            make.width.height.equalTo(32)
        }

        cardView_Moode.addSubview(nameLabel_Moode)
        nameLabel_Moode.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Moode)
            make.left.equalTo(avatarView_Moode.snp.right).offset(10)
            // 右侧为举报按钮留出空间
            make.right.equalTo(reportBtn_Moode.snp.left).offset(-6)
        }

        cardView_Moode.addSubview(contentLabel_Moode)
        contentLabel_Moode.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Moode.snp.bottom).offset(5)
            make.left.equalTo(avatarView_Moode.snp.right).offset(10)
            make.right.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-14)
        }
    }

    // MARK: - 事件处理

    /// 举报按钮点击
    @objc private func handleReportTapped_Moode() {
        guard let comment_Moode = comment_Moode else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onReportTapped_Moode?(comment_Moode)
    }

    // MARK: - 数据绑定

    /// 绑定评论数据，并根据是否为自己评论切换按钮图标
    /// - Parameter comment_moode: 评论模型
    func configure_Moode(comment_moode: Comment_Moode) {
        comment_Moode = comment_moode
        nameLabel_Moode.text = comment_moode.commentUserName_Moode
        contentLabel_Moode.text = comment_moode.commentContent_Moode
        avatarView_Moode.configure_Moode(userId_Moode: comment_moode.commentUserId_Moode)

        // 自己的评论显示删除图标（trash），他人评论显示举报图标（ellipsis）
        let isMyComment_moode = UserViewModel_Moode.shared_Moode.isCurrentUser_Moode(
            userId_moode: comment_moode.commentUserId_Moode
        )
        let cfg_moode = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let iconName_moode = isMyComment_moode ? "trash" : "ellipsis"
        reportBtn_Moode.setImage(UIImage(systemName: iconName_moode, withConfiguration: cfg_moode), for: .normal)
        reportBtn_Moode.tintColor = isMyComment_moode
            ? UIColor(hexstring_Moode: "#FF6B6B")
            : UIColor(hexstring_Moode: "#6C5CE7")
        reportBtn_Moode.backgroundColor = isMyComment_moode
            ? UIColor(hexstring_Moode: "#FF6B6B").withAlphaComponent(0.18)
            : UIColor(hexstring_Moode: "#E8E4FF")
    }

    // MARK: - 复用清理

    override func prepareForReuse() {
        super.prepareForReuse()
        comment_Moode = nil
        onReportTapped_Moode = nil
    }
}
