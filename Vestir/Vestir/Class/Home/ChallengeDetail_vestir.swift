import Foundation
import UIKit
import SnapKit

// MARK: 穿搭挑战详情页

/// 穿搭挑战详情页
/// 功能：展示挑战说明、讨论区评论列表（带举报/删除）、底部发送评论输入栏
/// 设计：渐变头部 + 讨论区卡片 + 浮动输入栏
class ChallengeDetail_Vestir: UIViewController {

    // MARK: - 属性

    var challenge_Vestir: OutfitChallenge_Vestir?

    // MARK: - 渐变头部（复用发现页同色系）

    private let headerShadow_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = .clear
        v_Vestir.layer.shadowColor = UIColor(hexstring_Vestir: "#6B21A8").cgColor
        v_Vestir.layer.shadowOpacity = 0.28
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 8)
        v_Vestir.layer.shadowRadius = 18
        return v_Vestir
    }()

    private let headerCard_Vestir = ChallengeHeaderCard_Vestir()

    private let decoCircle_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.10)
        v_Vestir.layer.cornerRadius = 44
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    private lazy var backBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn_Vestir.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg_Vestir), for: .normal)
        btn_Vestir.tintColor = .white
        btn_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.22)
        btn_Vestir.layer.cornerRadius = 16
        btn_Vestir.clipsToBounds = true
        btn_Vestir.addTarget(self, action: #selector(backTapped_Vestir), for: .touchUpInside)
        return btn_Vestir
    }()

    /// 挑战主题徽章
    private let themeBadge_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lbl_Vestir.textColor = .white
        lbl_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.22)
        lbl_Vestir.layer.cornerRadius = 9
        lbl_Vestir.clipsToBounds = true
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    private let challengeTitleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        lbl_Vestir.textColor = .white
        lbl_Vestir.numberOfLines = 2
        return lbl_Vestir
    }()

    private let challengeDescLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.76)
        lbl_Vestir.numberOfLines = 3
        return lbl_Vestir
    }()

    /// 参与人数 + 剩余天数 胶囊行
    private let statsRow_Vestir: UIView = UIView()
    private let participantsLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.88)
        return lbl_Vestir
    }()
    private let daysLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.88)
        return lbl_Vestir
    }()

    // MARK: - 讨论区滚动容器

    private let scrollView_Vestir: UIScrollView = {
        let sv_Vestir = UIScrollView()
        sv_Vestir.showsVerticalScrollIndicator = false
        sv_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        sv_Vestir.contentInsetAdjustmentBehavior = .never
        return sv_Vestir
    }()

    private let contentView_Vestir = UIView()

    private let discussionSectionRow_Vestir: UIView = UIView()
    private let discussionDot_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.primaryGradientStart_Vestir
        v_Vestir.layer.cornerRadius = 4
        return v_Vestir
    }()
    private let discussionTitle_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Discussion"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        return lbl_Vestir
    }()

    private let discussionCountBadge_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.tagPillText_Vestir
        lbl_Vestir.backgroundColor = ColorConfig_Vestir.tagPill_Vestir
        lbl_Vestir.layer.cornerRadius = 9
        lbl_Vestir.clipsToBounds = true
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    private let commentsStack_Vestir: UIStackView = {
        let sv_Vestir = UIStackView()
        sv_Vestir.axis = .vertical
        sv_Vestir.spacing = 10
        return sv_Vestir
    }()

    // MARK: - 底部输入栏

    private let inputBar_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.backgroundSecondary_Vestir
        v_Vestir.layer.cornerRadius = 24
        v_Vestir.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v_Vestir.layer.shadowColor = ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor
        v_Vestir.layer.shadowOpacity = 0.10
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: -4)
        v_Vestir.layer.shadowRadius = 12
        return v_Vestir
    }()

    private let inputField_Vestir: UITextField = {
        let tf_Vestir = UITextField()
        tf_Vestir.placeholder = "Join the discussion..."
        tf_Vestir.font = UIFont.systemFont(ofSize: 14)
        tf_Vestir.borderStyle = .none
        tf_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        tf_Vestir.layer.cornerRadius = 20
        tf_Vestir.setLeftPadding_Vestir(icon: "bubble.left.fill",
                                        tintColor: ColorConfig_Vestir.primaryGradientStart_Vestir)
        tf_Vestir.returnKeyType = .send
        return tf_Vestir
    }()

    private let sendBtnView_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.layer.cornerRadius = 19
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    private let sendGradLayer_Vestir: CAGradientLayer = {
        let g_Vestir = CAGradientLayer()
        g_Vestir.colors = [
            UIColor(hexstring_Vestir: "#6B21A8").cgColor,
            UIColor(hexstring_Vestir: "#4338CA").cgColor,
            UIColor(hexstring_Vestir: "#0369A1").cgColor
        ]
        g_Vestir.locations = [0, 0.52, 1.0]
        g_Vestir.startPoint = CGPoint(x: 0, y: 0.5)
        g_Vestir.endPoint = CGPoint(x: 1, y: 0.5)
        return g_Vestir
    }()

    private lazy var sendBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        btn_Vestir.setImage(UIImage(systemName: "arrow.up", withConfiguration: cfg_Vestir), for: .normal)
        btn_Vestir.tintColor = .white
        btn_Vestir.addTarget(self, action: #selector(sendTapped_Vestir), for: .touchUpInside)
        return btn_Vestir
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Vestir()
        setupConstraints_Vestir()
        loadData_Vestir()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sendGradLayer_Vestir.frame = sendBtnView_Vestir.bounds
        if headerShadow_Vestir.bounds.width > 0 {
            headerShadow_Vestir.layer.shadowPath = UIBezierPath(
                roundedRect: headerShadow_Vestir.bounds, cornerRadius: 0
            ).cgPath
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        headerShadow_Vestir.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaInsets.top + 160)
        }
        inputBar_Vestir.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaInsets.bottom + 72)
        }
    }

    // MARK: - UI 搭建

    private func setupUI_Vestir() {
        view.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir

        view.addSubview(headerShadow_Vestir)
        headerShadow_Vestir.addSubview(headerCard_Vestir)
        headerCard_Vestir.addSubview(decoCircle_Vestir)
        headerCard_Vestir.addSubview(backBtn_Vestir)
        headerCard_Vestir.addSubview(themeBadge_Vestir)
        headerCard_Vestir.addSubview(challengeTitleLabel_Vestir)
        headerCard_Vestir.addSubview(challengeDescLabel_Vestir)
        headerCard_Vestir.addSubview(statsRow_Vestir)
        statsRow_Vestir.addSubview(participantsLabel_Vestir)
        statsRow_Vestir.addSubview(daysLabel_Vestir)

        view.addSubview(scrollView_Vestir)
        scrollView_Vestir.addSubview(contentView_Vestir)
        contentView_Vestir.addSubview(discussionSectionRow_Vestir)
        discussionSectionRow_Vestir.addSubview(discussionDot_Vestir)
        discussionSectionRow_Vestir.addSubview(discussionTitle_Vestir)
        discussionSectionRow_Vestir.addSubview(discussionCountBadge_Vestir)
        contentView_Vestir.addSubview(commentsStack_Vestir)

        view.addSubview(inputBar_Vestir)
        inputBar_Vestir.addSubview(inputField_Vestir)
        inputBar_Vestir.addSubview(sendBtnView_Vestir)
        sendBtnView_Vestir.layer.insertSublayer(sendGradLayer_Vestir, at: 0)
        sendBtnView_Vestir.addSubview(sendBtn_Vestir)

        inputField_Vestir.delegate = self
    }

    private func setupConstraints_Vestir() {
        headerShadow_Vestir.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(view.safeAreaInsets.top + 160)
        }
        headerCard_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }

        decoCircle_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(88)
            make.trailing.equalToSuperview().offset(22)
            make.top.equalToSuperview().offset(-22)
        }
        backBtn_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.width.height.equalTo(32)
        }
        themeBadge_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.top.equalTo(backBtn_Vestir.snp.bottom).offset(16)
            make.height.equalTo(22)
        }
        challengeTitleLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(themeBadge_Vestir.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
        }
        challengeDescLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(challengeTitleLabel_Vestir.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
        }
        statsRow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(challengeDescLabel_Vestir.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
            make.bottom.lessThanOrEqualToSuperview().offset(-14)
            make.height.equalTo(20)
        }
        participantsLabel_Vestir.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        daysLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(participantsLabel_Vestir.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
        }

        inputBar_Vestir.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(view.safeAreaInsets.bottom + 72)
        }
        inputField_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(sendBtnView_Vestir.snp.leading).offset(-8)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(44)
        }
        sendBtnView_Vestir.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalTo(inputField_Vestir)
            make.width.height.equalTo(38)
        }
        sendBtn_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }

        scrollView_Vestir.snp.makeConstraints { make in
            make.top.equalTo(headerShadow_Vestir.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputBar_Vestir.snp.top)
        }
        contentView_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }
        discussionSectionRow_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(24)
        }
        discussionDot_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }
        discussionTitle_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(discussionDot_Vestir.snp.trailing).offset(7)
            make.centerY.equalToSuperview()
        }
        discussionCountBadge_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(discussionTitle_Vestir.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(24)
        }
        commentsStack_Vestir.snp.makeConstraints { make in
            make.top.equalTo(discussionSectionRow_Vestir.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    // MARK: - 数据加载

    private func loadData_Vestir() {
        guard let c_Vestir = challenge_Vestir else { return }

        themeBadge_Vestir.text = "  \(c_Vestir.theme_Vestir)  "
        challengeTitleLabel_Vestir.text = c_Vestir.title_Vestir
        challengeDescLabel_Vestir.text = c_Vestir.desc_Vestir
        participantsLabel_Vestir.text = "👥 \(c_Vestir.participantCount_Vestir) participants"
        daysLabel_Vestir.text = "⏳ \(c_Vestir.daysRemaining_Vestir) days left"
        discussionCountBadge_Vestir.text = "  \(c_Vestir.discussions_Vestir.count)  "

        rebuildDiscussions_Vestir()
    }

    private func rebuildDiscussions_Vestir() {
        commentsStack_Vestir.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let c_Vestir = challenge_Vestir else { return }

        if c_Vestir.discussions_Vestir.isEmpty {
            let emptyLbl_Vestir = UILabel()
            emptyLbl_Vestir.text = "Be the first to join the discussion ✨"
            emptyLbl_Vestir.font = UIFont.systemFont(ofSize: 14)
            emptyLbl_Vestir.textColor = ColorConfig_Vestir.textPlaceholder_Vestir
            emptyLbl_Vestir.textAlignment = .center
            commentsStack_Vestir.addArrangedSubview(emptyLbl_Vestir)
            return
        }

        for (idx_Vestir, comment_Vestir) in c_Vestir.discussions_Vestir.enumerated() {
            let cell_Vestir = buildDiscussionCell_Vestir(comment_vestir: comment_Vestir)
            cell_Vestir.alpha = 0
            commentsStack_Vestir.addArrangedSubview(cell_Vestir)
            cell_Vestir.animateFadeIn_Vestir(delay_Vestir: Double(idx_Vestir) * 0.05)
        }
    }

    /// 构建讨论评论 Cell（带举报/删除按钮）
    private func buildDiscussionCell_Vestir(comment_vestir: Comment_Vestir) -> UIView {
        let cell_Vestir = UIView()
        cell_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        cell_Vestir.layer.cornerRadius = 16
        cell_Vestir.layer.borderWidth = 1
        cell_Vestir.layer.borderColor = ColorConfig_Vestir.divider_Vestir.cgColor
        cell_Vestir.clipsToBounds = true

        // 左侧渐变色条
        let accentBar_Vestir = UIView()
        let barGrad_Vestir = CAGradientLayer()
        barGrad_Vestir.colors = [
            ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor,
            ColorConfig_Vestir.primaryGradientEnd_Vestir.cgColor
        ]
        barGrad_Vestir.startPoint = CGPoint(x: 0.5, y: 0)
        barGrad_Vestir.endPoint = CGPoint(x: 0.5, y: 1)
        accentBar_Vestir.layer.addSublayer(barGrad_Vestir)

        let avatarRing_Vestir = UIView()
        avatarRing_Vestir.backgroundColor = ColorConfig_Vestir.primaryGradientStart_Vestir.withAlphaComponent(0.12)
        avatarRing_Vestir.layer.cornerRadius = 16
        avatarRing_Vestir.clipsToBounds = true

        let avatarView_Vestir = UserAvatarView_Vestir()
        avatarView_Vestir.layer.cornerRadius = 13
        avatarView_Vestir.clipsToBounds = true
        avatarView_Vestir.configure_Vestir(userId_Vestir: comment_vestir.commentUserId_Vestir)

        let nameLabel_Vestir = UILabel()
        nameLabel_Vestir.text = comment_vestir.commentUserName_Vestir
        nameLabel_Vestir.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        nameLabel_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir

        let contentLabel_Vestir = UILabel()
        contentLabel_Vestir.text = comment_vestir.commentContent_Vestir
        contentLabel_Vestir.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        contentLabel_Vestir.textColor = ColorConfig_Vestir.textSecondary_Vestir
        contentLabel_Vestir.numberOfLines = 0

        // 举报/删除按钮（使用 ReportDeleteHelper）
        // 构造一个临时 TitleModel 让 ReportDeleteHelper 能正确显示弹窗并触发 completion
        // 挑战讨论不归属于 TitleViewModel，所以真正的数据移除在 completion 中完成
        let proxyPost_Vestir = TitleModel_Vestir(
            titleId_Vestir: -(challenge_Vestir?.challengeId_Vestir ?? 0),  // 负数确保不与真实帖子 ID 冲突
            titleUserId_Vestir: comment_vestir.commentUserId_Vestir,
            titleUserName_Vestir: comment_vestir.commentUserName_Vestir,
            titleMeidas_Vestir: [],
            title_Vestir: challenge_Vestir?.title_Vestir ?? "Challenge",
            titleContent_Vestir: "",
            reviews_Vestir: [],
            likes_Vestir: 0
        )
        let commentId_Vestir = comment_vestir.commentId_Vestir  // 捕获 ID，供 completion 内使用

        let reportBtn_Vestir = ReportDeleteHelper_Vestir.createCommentReportButton_Vestir(
            comment_Vestir: comment_vestir,
            post_Vestir: proxyPost_Vestir,
            size_Vestir: 13,
            color_Vestir: ColorConfig_Vestir.textPlaceholder_Vestir,
            from: self
        ) { [weak self] in
            // ReportDeleteHelper 的 deleteComment / reportComment 只操作 TitleViewModel，
            // 挑战讨论数据存储在 OutfitChallenge.discussions_Vestir，需在此手动移除
            self?.challenge_Vestir?.discussions_Vestir.removeAll {
                $0.commentId_Vestir == commentId_Vestir
            }
            self?.rebuildDiscussions_Vestir()
            self?.discussionCountBadge_Vestir.text =
                "  \(self?.challenge_Vestir?.discussions_Vestir.count ?? 0)  "
        }

        cell_Vestir.addSubview(accentBar_Vestir)
        cell_Vestir.addSubview(avatarRing_Vestir)
        avatarRing_Vestir.addSubview(avatarView_Vestir)
        cell_Vestir.addSubview(nameLabel_Vestir)
        cell_Vestir.addSubview(contentLabel_Vestir)
        cell_Vestir.addSubview(reportBtn_Vestir)

        accentBar_Vestir.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(3)
        }
        avatarRing_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(accentBar_Vestir.snp.trailing).offset(10)
            make.width.height.equalTo(32)
        }
        avatarView_Vestir.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(26)
        }
        nameLabel_Vestir.snp.makeConstraints { make in
            make.centerY.equalTo(avatarRing_Vestir)
            make.leading.equalTo(avatarRing_Vestir.snp.trailing).offset(8)
        }
        reportBtn_Vestir.snp.makeConstraints { make in
            make.centerY.equalTo(avatarRing_Vestir)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(26)
        }
        contentLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(avatarRing_Vestir.snp.bottom).offset(6)
            make.leading.equalTo(accentBar_Vestir.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-10)
        }

        DispatchQueue.main.async { barGrad_Vestir.frame = accentBar_Vestir.bounds }
        return cell_Vestir
    }

    // MARK: - 事件处理

    @objc private func backTapped_Vestir() { Navigation_Vestir.pop_Vestir() }

    @objc private func sendTapped_Vestir() {
        sendDiscussion_Vestir()
    }

    private func sendDiscussion_Vestir() {
        guard
            let challenge_Vestir = challenge_Vestir,
            let text_Vestir = inputField_Vestir.text,
            !text_Vestir.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            inputField_Vestir.animateShake_Vestir()
            return
        }

        guard UserViewModel_Vestir.shared_Vestir.isLoggedIn_Vestir else {
            Navigation_Vestir.toLogin_Vestir(style_vestir: .present_vestir)
            return
        }

        let user_Vestir = UserViewModel_Vestir.shared_Vestir.getCurrentUser_Vestir()
        let newId_Vestir = (challenge_Vestir.discussions_Vestir.map { $0.commentId_Vestir }.max() ?? 0) + 1
        let comment_Vestir = Comment_Vestir(
            commentId_Vestir: newId_Vestir,
            commentUserId_Vestir: user_Vestir.userId_Vestir ?? 0,
            commentUserName_Vestir: user_Vestir.userName_Vestir ?? "User",
            commentContent_Vestir: text_Vestir
        )
        challenge_Vestir.discussions_Vestir.append(comment_Vestir)

        inputField_Vestir.text = ""
        inputField_Vestir.resignFirstResponder()
        rebuildDiscussions_Vestir()
        discussionCountBadge_Vestir.text = "  \(challenge_Vestir.discussions_Vestir.count)  "

        // 滚动到最新评论
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            let bottom_Vestir = self.scrollView_Vestir.contentSize.height
                - self.scrollView_Vestir.bounds.height
            if bottom_Vestir > 0 {
                self.scrollView_Vestir.setContentOffset(
                    CGPoint(x: 0, y: bottom_Vestir), animated: true
                )
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension ChallengeDetail_Vestir: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendDiscussion_Vestir()
        return false
    }
}

// MARK: - 挑战详情渐变背景（深紫→靛蓝→湛蓝）

fileprivate final class ChallengeHeaderCard_Vestir: UIView {
    private let g_Vestir: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(hexstring_Vestir: "#6B21A8").cgColor,
            UIColor(hexstring_Vestir: "#4338CA").cgColor,
            UIColor(hexstring_Vestir: "#0369A1").cgColor
        ]
        g.locations = [0, 0.52, 1.0]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 1)
        return g
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(g_Vestir, at: 0)
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 24
        clipsToBounds = true
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() { super.layoutSubviews(); g_Vestir.frame = bounds }
}
