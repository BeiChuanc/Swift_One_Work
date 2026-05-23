import UIKit
import SnapKit

// MARK: 季节挑战详情/评论页面

/// 季节挑战详情页面
/// 功能：展示挑战主题、描述，并提供评论区供用户互动讨论
/// 设计：沉浸式头部（渐变 + 季节大 Emoji 装饰 + 统计行）+ 卡片式评论列表 + 精致输入栏
/// 关键属性：challengeModel_Hush（需在跳转前注入）
class SeasonChallengeDetail_Hush: UIViewController {

    // MARK: - 公开属性

    /// 挑战数据模型（跳转前注入）
    var challengeModel_Hush: SeasonChallengeModel_Hush?

    // MARK: - 私有属性

    private var comments_Hush: [Comment_Hush] = []

    // MARK: - UI 组件 - 头部

    private let headerView_Hush = UIView()
    private var headerGradient_Hush: CAGradientLayer?

    /// 背景装饰大 Emoji
    private let bgEmojiLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.font = UIFont.systemFont(ofSize: 120)
        lb_hush.alpha = 0.12
        return lb_hush
    }()

    /// 季节 Chip
    private let seasonChip_Hush: UIView = {
        let v_hush = UIView()
        v_hush.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v_hush.layer.cornerRadius = 13
        return v_hush
    }()
    private let seasonChipLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = .white
        lb_hush.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        return lb_hush
    }()

    /// 挑战主题大标题
    private let themeLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = .white
        lb_hush.font = UIFont.systemFont(ofSize: 24, weight: .black)
        lb_hush.numberOfLines = 0
        return lb_hush
    }()

    /// 挑战描述
    private let descLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = UIColor.white.withAlphaComponent(0.8)
        lb_hush.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lb_hush.numberOfLines = 2
        return lb_hush
    }()

    /// 统计信息栏（分隔线 + 参与人数 + 评论数）
    private let statsBar_Hush = UIView()
    private let participantStat_Hush = StatChip_Hush()
    private let commentStat_Hush = StatChip_Hush()

    /// 头部底部曲线过渡
    private let headerCurve_Hush: UIView = {
        let v_hush = UIView()
        v_hush.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        v_hush.layer.cornerRadius = 24
        v_hush.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v_hush
    }()

    // MARK: - UI 组件 - 评论区

    private let tableView_Hush: UITableView = {
        let tb_hush = UITableView()
        tb_hush.separatorStyle = .none
        tb_hush.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        tb_hush.showsVerticalScrollIndicator = false
        tb_hush.estimatedRowHeight = 100
        tb_hush.rowHeight = UITableView.automaticDimension
        tb_hush.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 20, right: 0)
        return tb_hush
    }()

    // MARK: - UI 组件 - 底部输入栏

    private let inputBar_Hush: UIView = {
        let v_hush = UIView()
        v_hush.backgroundColor = ColorConfig_Hush.cardBackground_Hush
        v_hush.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        v_hush.layer.shadowOffset = CGSize(width: 0, height: -3)
        v_hush.layer.shadowRadius = 10
        v_hush.layer.shadowOpacity = 1
        return v_hush
    }()

    private let commentField_Hush: UITextField = {
        let tf_hush = UITextField()
        tf_hush.placeholder = "Share your thoughts..."
        tf_hush.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tf_hush.textColor = ColorConfig_Hush.textPrimary_Hush
        tf_hush.backgroundColor = UIColor(hexstring_Hush: "#F4F1EC")
        tf_hush.layer.cornerRadius = 22
        tf_hush.addLeftPadding_Hush(18)
        tf_hush.addRightPadding_Hush(18)
        tf_hush.returnKeyType = .send
        return tf_hush
    }()

    private let sendButton_Hush: UIButton = {
        let bt_hush = UIButton(type: .custom)
        let config_hush = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        bt_hush.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: config_hush), for: .normal)
        bt_hush.tintColor = .white
        bt_hush.backgroundColor = UIColor(hexstring_Hush: "#FF6B35")
        bt_hush.layer.cornerRadius = 22
        bt_hush.clipsToBounds = true
        return bt_hush
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        setupNavBar_Hush()
        setupHeaderView_Hush()
        setupTableView_Hush()
        setupInputBar_Hush()
        loadData_Hush()
        setupKeyboardObservers_Hush()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Hush?.frame = headerView_Hush.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers_Hush()
    }

    // MARK: - 布局

    private func setupNavBar_Hush() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        let backBtn_hush = BackButton_Hush()
        backBtn_hush.onTapped_Hush = { Navigation_Hush.pop_Hush() }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn_hush)
    }

    /// 构建沉浸式头部
    private func setupHeaderView_Hush() {
        view.addSubview(headerView_Hush)
        headerView_Hush.clipsToBounds = true

        // 渐变背景
        let grad_hush = CAGradientLayer()
        grad_hush.startPoint = CGPoint(x: 0, y: 0)
        grad_hush.endPoint = CGPoint(x: 1, y: 1)
        headerView_Hush.layer.insertSublayer(grad_hush, at: 0)
        headerGradient_Hush = grad_hush

        headerView_Hush.addSubview(bgEmojiLabel_Hush)
        headerView_Hush.addSubview(seasonChip_Hush)
        seasonChip_Hush.addSubview(seasonChipLabel_Hush)
        headerView_Hush.addSubview(themeLabel_Hush)
        headerView_Hush.addSubview(descLabel_Hush)
        headerView_Hush.addSubview(statsBar_Hush)
        statsBar_Hush.addSubview(participantStat_Hush)
        statsBar_Hush.addSubview(commentStat_Hush)
        headerView_Hush.addSubview(headerCurve_Hush)

        let topInset_hush = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44

        headerView_Hush.snp.makeConstraints { make_hush in
            make_hush.top.left.right.equalToSuperview()
            make_hush.height.equalTo(260 + topInset_hush)
        }
        bgEmojiLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.right.equalToSuperview().offset(10)
            make_hush.bottom.equalTo(statsBar_Hush.snp.top).offset(30)
        }
        seasonChip_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalToSuperview().offset(topInset_hush + 56)
            make_hush.left.equalToSuperview().offset(22)
            make_hush.height.equalTo(26)
        }
        seasonChipLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12))
        }
        themeLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(seasonChip_Hush.snp.bottom).offset(10)
            make_hush.left.right.equalToSuperview().inset(22)
        }
        descLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(themeLabel_Hush.snp.bottom).offset(8)
            make_hush.left.right.equalToSuperview().inset(22)
        }
        statsBar_Hush.snp.makeConstraints { make_hush in
            make_hush.left.right.equalToSuperview().inset(22)
            make_hush.bottom.equalToSuperview().offset(-32)
            make_hush.height.equalTo(32)
        }
        participantStat_Hush.snp.makeConstraints { make_hush in
            make_hush.left.top.bottom.equalToSuperview()
        }
        commentStat_Hush.snp.makeConstraints { make_hush in
            make_hush.left.equalTo(participantStat_Hush.snp.right).offset(10)
            make_hush.top.bottom.equalToSuperview()
        }
        headerCurve_Hush.snp.makeConstraints { make_hush in
            make_hush.left.right.bottom.equalToSuperview()
            make_hush.height.equalTo(32)
        }
    }

    private func setupTableView_Hush() {
        view.addSubview(tableView_Hush)
        tableView_Hush.delegate = self
        tableView_Hush.dataSource = self
        tableView_Hush.register(ChallengeCommentCell_Hush.self, forCellReuseIdentifier: ChallengeCommentCell_Hush.reuseId_Hush)

        let sectionHeader_hush = makeSectionHeader_Hush()
        tableView_Hush.tableHeaderView = sectionHeader_hush
        sectionHeader_hush.frame = CGRect(x: 0, y: 0, width: APPSCREEN_Hush.WIDTH_Hush, height: 50)

        tableView_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(headerView_Hush.snp.bottom).offset(-8)
            make_hush.left.right.equalToSuperview()
            make_hush.bottom.equalTo(view.safeAreaLayoutGuide).offset(-64)
        }
    }

    private func setupInputBar_Hush() {
        view.addSubview(inputBar_Hush)
        inputBar_Hush.addSubview(commentField_Hush)
        inputBar_Hush.addSubview(sendButton_Hush)

        inputBar_Hush.snp.makeConstraints { make_hush in
            make_hush.left.right.equalToSuperview()
            make_hush.bottom.equalTo(view.safeAreaLayoutGuide)
            make_hush.height.equalTo(64)
        }
        commentField_Hush.snp.makeConstraints { make_hush in
            make_hush.left.equalToSuperview().offset(16)
            make_hush.centerY.equalToSuperview()
            make_hush.right.equalTo(sendButton_Hush.snp.left).offset(-10)
            make_hush.height.equalTo(44)
        }
        sendButton_Hush.snp.makeConstraints { make_hush in
            make_hush.right.equalToSuperview().offset(-16)
            make_hush.centerY.equalToSuperview()
            make_hush.width.height.equalTo(44)
        }

        commentField_Hush.delegate = self
        sendButton_Hush.addTarget(self, action: #selector(onSendComment_Hush), for: .touchUpInside)
    }

    private func makeSectionHeader_Hush() -> UIView {
        let v_hush = UIView()
        v_hush.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush

        let titleLb_hush = UILabel()
        titleLb_hush.text = "Discussion"
        titleLb_hush.textColor = ColorConfig_Hush.textPrimary_Hush
        titleLb_hush.font = UIFont.systemFont(ofSize: 16, weight: .bold)

        v_hush.addSubview(titleLb_hush)
        titleLb_hush.snp.makeConstraints { make_hush in
            make_hush.left.equalToSuperview().offset(20)
            make_hush.bottom.equalToSuperview().offset(-8)
        }
        return v_hush
    }

    // MARK: - 数据加载

    private func loadData_Hush() {
        guard let model_hush = challengeModel_Hush else { return }

        let themeColor_hush = UIColor(hexstring_Hush: model_hush.coverColorHex_Hush)
        headerGradient_Hush?.colors = [
            themeColor_hush.cgColor,
            themeColor_hush.withAlphaComponent(0.7).cgColor,
            UIColor(hexstring_Hush: "#1A1B25").withAlphaComponent(0.9).cgColor,
        ]
        headerGradient_Hush?.locations = [0.0, 0.55, 1.0]

        let emoji_hush = themeEmoji_Hush(theme_hush: model_hush.theme_Hush, season_hush: model_hush.season_Hush)
        bgEmojiLabel_Hush.text = emoji_hush
        seasonChipLabel_Hush.text = "\(emoji_hush)  \(model_hush.season_Hush)"
        themeLabel_Hush.text = model_hush.theme_Hush
        descLabel_Hush.text = model_hush.challengeDescription_Hush

        participantStat_Hush.configure_Hush(icon_hush: "person.2.fill",
                                             value_hush: "\(model_hush.participantCount_Hush)",
                                             label_hush: "Joined")
        comments_Hush = TitleViewModel_Hush.shared_Hush.getChallengeComments_Hush(challengeId_hush: model_hush.challengeId_Hush)
        commentStat_Hush.configure_Hush(icon_hush: "bubble.left.and.bubble.right.fill",
                                         value_hush: "\(comments_Hush.count)",
                                         label_hush: "Comments")

        tableView_Hush.reloadData()
    }

    /// 根据挑战主题关键词匹配独立 Emoji（与卡片保持一致）
    private func themeEmoji_Hush(theme_hush: String, season_hush: String) -> String {
        let lower_hush = theme_hush.lowercased()
        if lower_hush.contains("ray") || lower_hush.contains("light") || lower_hush.contains("dawn") || lower_hush.contains("sunrise") { return "🌅" }
        if lower_hush.contains("rain") || lower_hush.contains("reflection") || lower_hush.contains("puddle") { return "🌧️" }
        if lower_hush.contains("bloom") || lower_hush.contains("flower") || lower_hush.contains("blossom") || lower_hush.contains("corner") { return "🌺" }
        if lower_hush.contains("dusk") || lower_hush.contains("wind") || lower_hush.contains("breeze") { return "🌬️" }
        if lower_hush.contains("ice") || lower_hush.contains("cold") && lower_hush.contains("afternoon") { return "🧊" }
        if lower_hush.contains("barefoot") || lower_hush.contains("asphalt") { return "👣" }
        if lower_hush.contains("fallen") || lower_hush.contains("first") && lower_hush.contains("leaf") { return "🍂" }
        if lower_hush.contains("golden") || lower_hush.contains("alley") { return "🍁" }
        if lower_hush.contains("market") { return "🎑" }
        if lower_hush.contains("warm") || lower_hush.contains("lamp") || lower_hush.contains("candle") { return "🕯️" }
        if lower_hush.contains("breath") || lower_hush.contains("steam") { return "💨" }
        if lower_hush.contains("empty") || (lower_hush.contains("street") && lower_hush.contains("winter")) { return "🌨️" }
        switch season_hush {
        case "Spring": return "🌸"
        case "Summer": return "☀️"
        case "Autumn": return "🍂"
        default:       return "❄️"
        }
    }

    // MARK: - 键盘处理

    private func setupKeyboardObservers_Hush() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow_Hush(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide_Hush(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func removeKeyboardObservers_Hush() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow_Hush(_ note: Notification) {
        guard let frame_hush = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let offset_hush = frame_hush.height - view.safeAreaInsets.bottom
        inputBar_Hush.snp.updateConstraints { make_hush in
            make_hush.bottom.equalTo(view.safeAreaLayoutGuide).offset(-offset_hush)
        }
        UIView.animate(withDuration: AnimationConfig_Hush.durationNormal_Hush) { self.view.layoutIfNeeded() }
    }

    @objc private func keyboardWillHide_Hush(_ note: Notification) {
        inputBar_Hush.snp.updateConstraints { make_hush in
            make_hush.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        UIView.animate(withDuration: AnimationConfig_Hush.durationNormal_Hush) { self.view.layoutIfNeeded() }
    }

    // MARK: - 发送评论

    @objc private func onSendComment_Hush() {
        guard let text_hush = commentField_Hush.text,
              !text_hush.trimmingCharacters(in: .whitespaces).isEmpty,
              let id_hush = challengeModel_Hush?.challengeId_Hush else { return }

        let ok_hush = TitleViewModel_Hush.shared_Hush.releaseChallengeComment_Hush(
            challengeId_hush: id_hush, content_hush: text_hush)
        guard ok_hush else { return }

        commentField_Hush.text = nil
        view.endEditing(true)
        comments_Hush = TitleViewModel_Hush.shared_Hush.getChallengeComments_Hush(challengeId_hush: id_hush)

        // 刷新评论数统计
        commentStat_Hush.configure_Hush(icon_hush: "bubble.left.and.bubble.right.fill",
                                         value_hush: "\(comments_Hush.count)",
                                         label_hush: "Comments")
        tableView_Hush.reloadData()
        let lastRow_hush = IndexPath(row: comments_Hush.count - 1, section: 0)
        tableView_Hush.scrollToRow(at: lastRow_hush, at: .bottom, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension SeasonChallengeDetail_Hush: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments_Hush.isEmpty ? 1 : comments_Hush.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if comments_Hush.isEmpty {
            let cell_hush = UITableViewCell()
            cell_hush.selectionStyle = .none
            cell_hush.backgroundColor = .clear
            let lb_hush = UILabel()
            lb_hush.text = "Be the first to share your thoughts ✨"
            lb_hush.textColor = ColorConfig_Hush.textPlaceholder_Hush
            lb_hush.font = UIFont.systemFont(ofSize: 13)
            lb_hush.textAlignment = .center
            cell_hush.contentView.addSubview(lb_hush)
            lb_hush.snp.makeConstraints { make_hush in
                make_hush.center.equalToSuperview()
                make_hush.left.right.equalToSuperview().inset(20)
                make_hush.top.bottom.equalToSuperview().inset(32)
            }
            return cell_hush
        }
        let cell_hush = tableView.dequeueReusableCell(
            withIdentifier: ChallengeCommentCell_Hush.reuseId_Hush, for: indexPath
        ) as! ChallengeCommentCell_Hush
        cell_hush.configure_Hush(comment_hush: comments_Hush[indexPath.row])
        return cell_hush
    }
}

// MARK: - UITextFieldDelegate

extension SeasonChallengeDetail_Hush: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onSendComment_Hush(); return true
    }
}

// MARK: - 统计 Chip 组件

/// 头部统计信息小胶囊（图标 + 数字 + 标签）
private class StatChip_Hush: UIView {

    private let iconView_Hush: UIImageView = {
        let iv_hush = UIImageView()
        iv_hush.tintColor = UIColor.white.withAlphaComponent(0.75)
        iv_hush.contentMode = .scaleAspectFit
        return iv_hush
    }()
    private let valueLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = .white
        lb_hush.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        return lb_hush
    }()
    private let nameLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = UIColor.white.withAlphaComponent(0.6)
        lb_hush.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        return lb_hush
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white.withAlphaComponent(0.15)
        layer.cornerRadius = 16
        setupLayout_Hush()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupLayout_Hush() {
        addSubview(iconView_Hush)
        addSubview(valueLabel_Hush)
        addSubview(nameLabel_Hush)

        iconView_Hush.snp.makeConstraints { make_hush in
            make_hush.left.equalToSuperview().offset(10)
            make_hush.centerY.equalToSuperview()
            make_hush.width.height.equalTo(14)
        }
        valueLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.left.equalTo(iconView_Hush.snp.right).offset(5)
            make_hush.centerY.equalToSuperview()
        }
        nameLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.left.equalTo(valueLabel_Hush.snp.right).offset(4)
            make_hush.centerY.equalToSuperview()
            make_hush.right.equalToSuperview().offset(-10)
        }
    }

    /// 填充数据
    func configure_Hush(icon_hush: String, value_hush: String, label_hush: String) {
        let cfg_hush = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        iconView_Hush.image = UIImage(systemName: icon_hush, withConfiguration: cfg_hush)
        valueLabel_Hush.text = value_hush
        nameLabel_Hush.text = label_hush
    }
}

// MARK: - 评论 Cell

/// 挑战评论列表卡片式 Cell
/// 挑战评论列表卡片式 Cell
/// 功能：展示评论用户真实头像（UserAvatarView_Hush）、用户名和评论内容
private class ChallengeCommentCell_Hush: UITableViewCell {

    static let reuseId_Hush = "ChallengeCommentCell_Hush"

    /// 卡片容器（白色圆角背景）
    private let cardView_Hush: UIView = {
        let v_hush = UIView()
        v_hush.backgroundColor = .white
        v_hush.layer.cornerRadius = 16
        v_hush.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        v_hush.layer.shadowOffset = CGSize(width: 0, height: 2)
        v_hush.layer.shadowRadius = 6
        v_hush.layer.shadowOpacity = 1
        return v_hush
    }()

    /// 真实用户头像（与帖子详情保持一致）
    private let avatarView_Hush = UserAvatarView_Hush()

    private let nameLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = ColorConfig_Hush.textPrimary_Hush
        lb_hush.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        return lb_hush
    }()

    private let contentLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = ColorConfig_Hush.textSecondary_Hush
        lb_hush.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lb_hush.numberOfLines = 0
        return lb_hush
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupUI_Hush()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupUI_Hush() {
        contentView.addSubview(cardView_Hush)
        cardView_Hush.addSubview(avatarView_Hush)
        cardView_Hush.addSubview(nameLabel_Hush)
        cardView_Hush.addSubview(contentLabel_Hush)

        cardView_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalToSuperview().offset(6)
            make_hush.left.right.equalToSuperview().inset(16)
            make_hush.bottom.equalToSuperview().offset(-6)
        }
        avatarView_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalToSuperview().offset(14)
            make_hush.left.equalToSuperview().offset(14)
            make_hush.width.height.equalTo(40)
        }
        nameLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(avatarView_Hush)
            make_hush.left.equalTo(avatarView_Hush.snp.right).offset(12)
            make_hush.right.equalToSuperview().offset(-14)
        }
        contentLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(nameLabel_Hush.snp.bottom).offset(4)
            make_hush.left.equalTo(avatarView_Hush.snp.right).offset(12)
            make_hush.right.equalToSuperview().offset(-14)
            make_hush.bottom.equalToSuperview().offset(-14)
        }
    }

    /// 绑定评论数据，通过 userId 加载真实头像
    /// - Parameter comment_hush: 评论模型
    func configure_Hush(comment_hush: Comment_Hush) {
        nameLabel_Hush.text = comment_hush.commentUserName_Hush
        contentLabel_Hush.text = comment_hush.commentContent_Hush
        avatarView_Hush.configure_Hush(userId_Hush: comment_hush.commentUserId_Hush)
    }
}
