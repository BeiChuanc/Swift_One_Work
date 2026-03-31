import UIKit
import SnapKit

// MARK: - 挑战补全单元格

/// 挑战补全单元格
/// 功能：展示单条用户补全内容，右上角提供举报/删除按钮
class ChallengeCompletionCell_Flick: UITableViewCell {

    // MARK: - UI 组件

    private let cardView_Flick: UIView = {
        let v_flick = UIView()
        v_flick.backgroundColor = UIColor(hexstring_Flick: "#1C1C2E")
        v_flick.layer.cornerRadius = 16
        v_flick.clipsToBounds = true
        return v_flick
    }()

    private let leftBar_Flick: UIView = {
        let v_flick = UIView()
        v_flick.backgroundColor = UIColor(hexstring_Flick: "#A78BFA")
        v_flick.layer.cornerRadius = 2
        return v_flick
    }()

    private let contentLabel_Flick: UILabel = {
        let lbl_flick = UILabel()
        lbl_flick.textColor = .white
        lbl_flick.font = .systemFont(ofSize: 15, weight: .regular)
        lbl_flick.numberOfLines = 0
        return lbl_flick
    }()

    private let userNameLabel_Flick: UILabel = {
        let lbl_flick = UILabel()
        lbl_flick.textColor = UIColor(hexstring_Flick: "#A78BFA")
        lbl_flick.font = .systemFont(ofSize: 12, weight: .medium)
        return lbl_flick
    }()

    /// 举报/删除按钮（右上角）
    let actionBtn_Flick: UIButton = {
        let btn_flick = UIButton(type: .custom)
        let img_flick = UIImage(systemName: "ellipsis")?.withRenderingMode(.alwaysTemplate)
        btn_flick.setImage(img_flick, for: .normal)
        btn_flick.tintColor = UIColor(hexstring_Flick: "#8884A0")
        btn_flick.backgroundColor = UIColor(hexstring_Flick: "#2A2A3E")
        btn_flick.layer.cornerRadius = 12
        btn_flick.clipsToBounds = true
        return btn_flick
    }()

    // MARK: - 回调

    /// 举报/删除按钮点击回调
    var onActionTapped_Flick: (() -> Void)?

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Flick()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - 私有方法

    private func setupUI_Flick() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(cardView_Flick)
        cardView_Flick.addSubview(leftBar_Flick)
        cardView_Flick.addSubview(userNameLabel_Flick)
        cardView_Flick.addSubview(contentLabel_Flick)
        cardView_Flick.addSubview(actionBtn_Flick)

        cardView_Flick.snp.makeConstraints { make_flick in
            make_flick.top.equalToSuperview().offset(6)
            make_flick.bottom.equalToSuperview().offset(-6)
            make_flick.left.equalToSuperview().offset(16)
            make_flick.right.equalToSuperview().offset(-16)
        }
        leftBar_Flick.snp.makeConstraints { make_flick in
            make_flick.top.equalToSuperview().offset(14)
            make_flick.bottom.equalToSuperview().offset(-14)
            make_flick.left.equalToSuperview().offset(14)
            make_flick.width.equalTo(3)
        }
        userNameLabel_Flick.snp.makeConstraints { make_flick in
            make_flick.top.equalToSuperview().offset(14)
            make_flick.left.equalTo(leftBar_Flick.snp.right).offset(10)
            make_flick.right.equalTo(actionBtn_Flick.snp.left).offset(-8)
        }
        contentLabel_Flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(userNameLabel_Flick.snp.bottom).offset(6)
            make_flick.left.equalTo(leftBar_Flick.snp.right).offset(10)
            make_flick.right.equalToSuperview().offset(-14)
            make_flick.bottom.equalToSuperview().offset(-14)
        }
        actionBtn_Flick.snp.makeConstraints { make_flick in
            make_flick.top.equalToSuperview().offset(12)
            make_flick.right.equalToSuperview().offset(-12)
            make_flick.width.height.equalTo(24)
        }
        actionBtn_Flick.addTarget(self, action: #selector(handleAction_Flick), for: .touchUpInside)
    }

    @objc private func handleAction_Flick() {
        onActionTapped_Flick?()
    }

    /// 配置单元格内容
    /// - Parameter completion_flick: 补全评论对象
    func configure_Flick(completion_flick: Comment_Flick) {
        userNameLabel_Flick.text = "@\(completion_flick.commentUserName_Flick)"
        contentLabel_Flick.text = completion_flick.commentContent_Flick
    }
}

// MARK: - 挑战详情页面

/// 官方半截碎念挑战详情页
/// 功能：展示挑战前半段，列表展示用户补全，底部固定输入栏补全后半段；补全列表项举报/删除走 ReportDeleteHelper_Flick
/// 设计：深色系渐变页面；表头在首次布局即算准高度；底栏贴屏底 + 白卡片贴底无安全区缝；iOS15+ 关闭 section 顶距避免首屏下移
class ChallengeDetail_Flick: UIViewController {

    // MARK: - 数据属性

    /// 当前挑战对象（由外部注入）
    var challenge_Flick: HalfChallenge_Flick?

    // MARK: - 私有属性

    private let cellId_Flick = "ChallengeCompletionCell"
    private var completions_Flick: [Comment_Flick] = []

    /// 底部输入栏相对屏幕底边的约束（键盘弹出时上移）
    private var inputBarBottomConstraint_Flick: Constraint?

    /// 表头已按该列表宽度完成高度适配（宽度变化时重新计算，避免进入页后表头高度突变导致整体上移）
    private var challengeHeaderLaidWidth_Flick: CGFloat = 0

    /// 底部输入栏总高度（略高于详情页评论栏，便于点击与视觉呼吸感）
    private let commentInputBarHeight_Flick: CGFloat = 88

    // MARK: - UI 组件

    private let gradientLayer_Flick: CAGradientLayer = {
        let gl_flick = CAGradientLayer()
        gl_flick.colors = [
            UIColor(hexstring_Flick: "#0D0D1A").cgColor,
            UIColor(hexstring_Flick: "#1A1040").cgColor,
            UIColor(hexstring_Flick: "#0D0D1A").cgColor
        ]
        gl_flick.locations = [0, 0.5, 1]
        return gl_flick
    }()

    private lazy var backBtn_Flick: BackButton_Flick = {
        let btn_flick = BackButton_Flick()
        btn_flick.onTapped_Flick = { [weak self] in
            Navigation_Flick.pop_Flick()
        }
        return btn_flick
    }()

    private lazy var tableView_Flick: UITableView = {
        let tv_flick = UITableView(frame: .zero, style: .grouped)
        tv_flick.backgroundColor = .clear
        tv_flick.separatorStyle = .none
        tv_flick.showsVerticalScrollIndicator = false
        tv_flick.contentInsetAdjustmentBehavior = .never
        tv_flick.keyboardDismissMode = .onDrag
        if #available(iOS 15.0, *) {
            // 分组表默认首段顶部留白会在首屏布局后出现，易与表头高度变更叠加产生「下移」观感
            tv_flick.sectionHeaderTopPadding = 0
        }
        return tv_flick
    }()

    /// 底部行内评论输入视图
    private lazy var commentInputView_Flick: DetailCommentInputView_Flick = {
        let view_flick = DetailCommentInputView_Flick()
        view_flick.placeholder_Flick = "Complete the other half..."
        view_flick.challengeStyleBottomFlush_Flick = true
        view_flick.onSend_Flick = { [weak self] text_flick in
            self?.submitCompletion_Flick(content_flick: text_flick)
        }
        return view_flick
    }()

    // MARK: - 表头视图

    private lazy var headerView_Flick: UIView = buildHeaderView_Flick()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground_Flick()
        setupLayout_Flick()
        setupTableView_Flick()
        loadCompletions_Flick()
        observeNotifications_Flick()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer_Flick.frame = view.bounds
        let width_flick = tableView_Flick.bounds.width
        guard width_flick > 0, width_flick != challengeHeaderLaidWidth_Flick else { return }
        challengeHeaderLaidWidth_Flick = width_flick
        applyChallengeTableHeaderHeight_Flick(width_flick: width_flick)
    }

    /// 在列表宽度确定后立刻计算表头高度并赋值，避免推迟到 viewDidAppear 造成整块内容自上而下跳动
    /// - Parameter width_flick: 与 tableView 同宽
    private func applyChallengeTableHeaderHeight_Flick(width_flick: CGFloat) {
        guard let header_flick = tableView_Flick.tableHeaderView else { return }
        header_flick.frame = CGRect(x: 0, y: 0, width: width_flick, height: header_flick.frame.height)
        header_flick.setNeedsLayout()
        header_flick.layoutIfNeeded()
        let targetSize_flick = CGSize(width: width_flick, height: 0)
        let newH_flick = header_flick.systemLayoutSizeFitting(
            targetSize_flick,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        guard newH_flick > 1 else { return }
        header_flick.frame = CGRect(x: 0, y: 0, width: width_flick, height: newH_flick)
        tableView_Flick.tableHeaderView = header_flick
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 私有方法 - 初始化

    private func setupBackground_Flick() {
        view.layer.insertSublayer(gradientLayer_Flick, at: 0)
    }

    private func setupLayout_Flick() {
        view.addSubview(tableView_Flick)
        view.addSubview(commentInputView_Flick)
        view.addSubview(backBtn_Flick)

        // 返回按钮与 BackButton_Flick 实际圆形尺寸一致，避免宽热区遮挡表头标签/日期区域
        backBtn_Flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make_flick.left.equalToSuperview().offset(16)
            make_flick.width.height.equalTo(44)
        }
        commentInputView_Flick.snp.makeConstraints { make_flick in
            make_flick.left.right.equalToSuperview()
            make_flick.height.equalTo(commentInputBarHeight_Flick)
            // 贴屏幕底边，避免安全区在输入栏下方露出渐变空隙
            inputBarBottomConstraint_Flick = make_flick.bottom.equalToSuperview().constraint
        }
        tableView_Flick.snp.makeConstraints { make_flick in
            make_flick.top.left.right.equalToSuperview()
            make_flick.bottom.equalTo(commentInputView_Flick.snp.top)
        }
    }

    private func setupTableView_Flick() {
        tableView_Flick.delegate = self
        tableView_Flick.dataSource = self
        tableView_Flick.register(ChallengeCompletionCell_Flick.self, forCellReuseIdentifier: cellId_Flick)
        tableView_Flick.tableHeaderView = headerView_Flick
        tableView_Flick.tableFooterView = nil
    }

    private func loadCompletions_Flick() {
        completions_Flick = challenge_Flick?.completions_Flick ?? []
    }

    private func observeNotifications_Flick() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleChallengeStateChange_Flick),
            name: TitleViewModel_Flick.challengeStateDidChangeNotification_Flick,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardShow_Flick(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardHide_Flick(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // MARK: - 私有方法 - 构建表头视图

    private func buildHeaderView_Flick() -> UIView {
        let container_flick = UIView()
        container_flick.backgroundColor = .clear

        // 顶部空白（为安全区 + 返回按钮留足空间，避免与标签/日期行重叠）
        let topSpacer_flick = UIView()
        container_flick.addSubview(topSpacer_flick)
        topSpacer_flick.snp.makeConstraints { make_flick in
            make_flick.top.left.right.equalToSuperview()
            make_flick.height.equalTo(104)
        }

        // 标签胶囊
        let tagLabel_flick = UILabel()
        tagLabel_flick.text = challenge_Flick?.tag_Flick ?? "Challenge"
        tagLabel_flick.textColor = UIColor(hexstring_Flick: "#C4B5FD")
        tagLabel_flick.font = .systemFont(ofSize: 12, weight: .semibold)
        tagLabel_flick.backgroundColor = UIColor(hexstring_Flick: "#A78BFA").withValues(alpha: 0.25)
        tagLabel_flick.textAlignment = .center
        tagLabel_flick.layer.cornerRadius = 10
        tagLabel_flick.clipsToBounds = true
        container_flick.addSubview(tagLabel_flick)
        tagLabel_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(topSpacer_flick.snp.bottom).offset(8)
            make_flick.left.equalToSuperview().offset(24)
            make_flick.height.equalTo(22)
            make_flick.width.greaterThanOrEqualTo(60)
        }
        tagLabel_flick.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        // 日期标签
        let dateLabel_flick = UILabel()
        dateLabel_flick.text = challenge_Flick?.publishDate_Flick ?? ""
        dateLabel_flick.textColor = UIColor(hexstring_Flick: "#6B7280")
        dateLabel_flick.font = .systemFont(ofSize: 12)
        container_flick.addSubview(dateLabel_flick)
        dateLabel_flick.snp.makeConstraints { make_flick in
            make_flick.centerY.equalTo(tagLabel_flick)
            make_flick.left.equalTo(tagLabel_flick.snp.right).offset(10)
        }

        // "Flick Challenge" 标题
        let titleLabel_flick = UILabel()
        titleLabel_flick.text = "Flick Challenge"
        titleLabel_flick.textColor = UIColor(hexstring_Flick: "#7C3AED").withValues(alpha: 0.7)
        titleLabel_flick.font = .systemFont(ofSize: 13, weight: .medium)
        container_flick.addSubview(titleLabel_flick)
        titleLabel_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(tagLabel_flick.snp.bottom).offset(14)
            make_flick.left.equalToSuperview().offset(24)
        }

        // 前半段主体文字（大号，带引号装饰）
        let quoteLabel_flick = UILabel()
        quoteLabel_flick.text = "\u{201C}\(challenge_Flick?.firstHalf_Flick ?? "")\u{201D}"
        quoteLabel_flick.textColor = .white
        quoteLabel_flick.font = UIFont(name: "Georgia-Italic", size: 22) ?? .italicSystemFont(ofSize: 22)
        quoteLabel_flick.numberOfLines = 0
        container_flick.addSubview(quoteLabel_flick)
        quoteLabel_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(titleLabel_flick.snp.bottom).offset(10)
            make_flick.left.equalToSuperview().offset(24)
            make_flick.right.equalToSuperview().offset(-24)
        }

        // 下划线分割
        let divider_flick = UIView()
        divider_flick.backgroundColor = UIColor(hexstring_Flick: "#A78BFA").withValues(alpha: 0.3)
        container_flick.addSubview(divider_flick)
        divider_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(quoteLabel_flick.snp.bottom).offset(20)
            make_flick.left.equalToSuperview().offset(24)
            make_flick.right.equalToSuperview().offset(-24)
            make_flick.height.equalTo(1)
        }

        // 完成数提示
        let countLabel_flick = UILabel()
        countLabel_flick.textColor = UIColor(hexstring_Flick: "#9CA3AF")
        countLabel_flick.font = .systemFont(ofSize: 13)
        countLabel_flick.tag = 9901 // 用于后续刷新
        // 直接使用局部引用设置初始文案，避免访问 lazy var headerView_Flick（防止重入崩溃）
        let initCount_flick = challenge_Flick?.completions_Flick.count ?? 0
        countLabel_flick.text = initCount_flick == 0
            ? "Be the first to complete it ✨"
            : "\(initCount_flick) people completed this challenge"
        container_flick.addSubview(countLabel_flick)
        countLabel_flick.snp.makeConstraints { make_flick in
            make_flick.top.equalTo(divider_flick.snp.bottom).offset(14)
            make_flick.left.equalToSuperview().offset(24)
            make_flick.bottom.equalToSuperview().offset(-8)
        }

        return container_flick
    }

    /// 更新完成数标签内容（从 tableHeaderView 中查找，避免访问 lazy var 重入）
    private func updateCountLabel_Flick() {
        let count_flick = challenge_Flick?.completions_Flick.count ?? 0
        let text_flick = count_flick == 0
            ? "Be the first to complete it ✨"
            : "\(count_flick) people completed this challenge"
        // 通过 tableHeaderView 查找，headerView_Flick 此时已完成初始化
        (tableView_Flick.tableHeaderView?.viewWithTag(9901) as? UILabel)?.text = text_flick
    }

    // MARK: - 私有方法 - 提交补全

    private func submitCompletion_Flick(content_flick: String) {
        guard let challenge_flick = challenge_Flick else { return }
        TitleViewModel_Flick.shared_Flick.addChallengeCompletion_Flick(
            challenge_flick: challenge_flick,
            content_flick: content_flick
        )
    }

    // MARK: - 事件处理

    @objc private func handleChallengeStateChange_Flick() {
        loadCompletions_Flick()
        updateCountLabel_Flick()
        tableView_Flick.reloadData()
    }

    @objc private func handleKeyboardShow_Flick(_ notification_flick: Notification) {
        guard let info_flick = notification_flick.userInfo,
              let kbFrame_flick = (info_flick[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let dur_flick = info_flick[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveRaw_flick = info_flick[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        let kbInView_flick = view.convert(kbFrame_flick, from: nil)
        let overlap_flick = max(0, view.bounds.maxY - kbInView_flick.minY)
        let curve_flick = UIView.AnimationOptions(rawValue: curveRaw_flick << 16)
        UIView.animate(
            withDuration: dur_flick,
            delay: 0,
            options: curve_flick,
            animations: {
                self.inputBarBottomConstraint_Flick?.update(offset: -overlap_flick)
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }

    @objc private func handleKeyboardHide_Flick(_ notification_flick: Notification) {
        guard let info_flick = notification_flick.userInfo,
              let dur_flick = info_flick[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveRaw_flick = info_flick[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        let curve_flick = UIView.AnimationOptions(rawValue: curveRaw_flick << 16)
        UIView.animate(
            withDuration: dur_flick,
            delay: 0,
            options: curve_flick,
            animations: {
                self.inputBarBottomConstraint_Flick?.update(offset: 0)
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }

    // MARK: - 私有方法 - 举报/删除补全

    private func showCompletionActions_Flick(at indexPath_flick: IndexPath) {
        guard let challenge_flick = challenge_Flick,
              indexPath_flick.row < completions_Flick.count else { return }
        let completion_flick = completions_Flick[indexPath_flick.row]
        let currentUserId_flick = UserViewModel_Flick.shared_Flick.getCurrentUser_Flick().userId_Flick ?? 0
        let isOwn_flick = completion_flick.commentUserId_Flick == currentUserId_flick
        if isOwn_flick {
            ReportDeleteHelper_Flick.deleteChallengeCompletion_Flick(
                comment_Flick: completion_flick,
                challenge_Flick: challenge_flick,
                from: self
            )
        } else {
            ReportDeleteHelper_Flick.reportChallengeCompletion_Flick(
                comment_Flick: completion_flick,
                challenge_Flick: challenge_flick,
                from: self
            )
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ChallengeDetail_Flick: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        completions_Flick.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_flick = tableView.dequeueReusableCell(
            withIdentifier: cellId_Flick, for: indexPath
        ) as! ChallengeCompletionCell_Flick
        cell_flick.configure_Flick(completion_flick: completions_Flick[indexPath.row])
        cell_flick.onActionTapped_Flick = { [weak self] in
            self?.showCompletionActions_Flick(at: indexPath)
        }
        return cell_flick
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { nil }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 0 }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? { nil }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 0 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
