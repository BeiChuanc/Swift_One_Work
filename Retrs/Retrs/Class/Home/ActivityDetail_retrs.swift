import Foundation
import UIKit
import SnapKit

// MARK: 主题活动详情页

/// 主题打卡活动详情控制器
/// 核心作用：展示主题信息、讨论区帖子列表、底部发布输入框
/// 设计思路：渐变头部（主题专属色）+ 讨论区卡片列表 + 固定底部发布栏
class ActivityDetail_Retrs: UIViewController {

    // MARK: - 属性

    /// 外部注入的主题活动数据
    var activity_Retrs: ThemeActivity_Retrs?

    private let userVM_Retrs  = UserViewModel_Retrs.shared_Retrs
    private let titleVM_Retrs = TitleViewModel_Retrs.shared_Retrs

    private let scrollView_Retrs  = UIScrollView()
    private let contentView_Retrs = UIView()

    /// 渐变头部
    private let headerView_Retrs      = UIView()
    private let headerGradLayer_Retrs = CAGradientLayer()
    private let backBtn_Retrs         = UIButton(type: .system)
    private let emojiLabel_Retrs      = UILabel()
    private let titleLabel_Retrs      = UILabel()
    private let descLabel_Retrs       = UILabel()
    private let statsRow_Retrs        = UIView()
    private let participantCountLabel_Retrs = UILabel()   // 参与人数，供 joinTapped 更新

    /// 讨论区
    private let discussTitle_Retrs  = UILabel()
    private let discussStack_Retrs  = UIStackView()

    /// 底部发布栏
    private let inputBar_Retrs       = UIView()
    private let inputWrap_Retrs      = UIView()
    private let inputField_Retrs     = UITextField()
    private let sendBtn_Retrs        = UIButton(type: .system)
    private let sendGradLayer_Retrs  = CAGradientLayer()
    private let joinBtn_Retrs        = UIButton(type: .system)
    private let joinGradLayer_Retrs  = CAGradientLayer()
    private var inputBarBottomConstraint_Retrs: Constraint?

    /// 当前讨论内容（模拟用帖子列表）
    private var discussPosts_Retrs: [TitleModel_Retrs] = []

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Retrs.backgroundPrimary_Retrs
        setupScrollView_Retrs()
        setupHeaderView_Retrs()
        setupDiscussSection_Retrs()
        setupInputBar_Retrs()
        setupConstraints_Retrs()
        loadDiscussData_Retrs()

        let tap_Retrs = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Retrs))
        tap_Retrs.cancelsTouchesInView = false
        scrollView_Retrs.addGestureRecognizer(tap_Retrs)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow_Retrs(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide_Retrs(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradLayer_Retrs.frame  = headerView_Retrs.bounds
        sendGradLayer_Retrs.frame    = sendBtn_Retrs.bounds
        joinGradLayer_Retrs.frame    = joinBtn_Retrs.bounds
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 主滚动视图

    private func setupScrollView_Retrs() {
        scrollView_Retrs.showsVerticalScrollIndicator = false
        scrollView_Retrs.alwaysBounceVertical = true
        scrollView_Retrs.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_Retrs)
        scrollView_Retrs.addSubview(contentView_Retrs)
    }

    // MARK: - 渐变头部

    private func setupHeaderView_Retrs() {
        let colors_Retrs = activity_Retrs?.gradient_Retrs
            ?? [ColorConfig_Retrs.primaryGradientStart_Retrs, ColorConfig_Retrs.primaryGradientEnd_Retrs]

        headerGradLayer_Retrs.colors = colors_Retrs.map { $0.cgColor }
        headerGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0)
        headerGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 1)
        headerView_Retrs.layer.insertSublayer(headerGradLayer_Retrs, at: 0)
        headerView_Retrs.layer.cornerRadius = 30
        headerView_Retrs.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Retrs.clipsToBounds = true
        contentView_Retrs.addSubview(headerView_Retrs)

        // 装饰气泡
        addBubble_Retrs(alpha: 0.1, size: 130, top: -30, trailing: 10)
        addBubble_Retrs(alpha: 0.07, size: 80, bottom: -10, leading: -15)

        // 返回按钮
        backBtn_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        backBtn_Retrs.layer.cornerRadius = 18
        backBtn_Retrs.layer.borderWidth  = 1
        backBtn_Retrs.layer.borderColor  = UIColor.white.withAlphaComponent(0.35).cgColor
        backBtn_Retrs.setImage(
            UIImage(systemName: "arrow.left",
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)),
            for: .normal)
        backBtn_Retrs.tintColor = .white
        backBtn_Retrs.addTarget(self, action: #selector(backTapped_Retrs), for: .touchUpInside)
        headerView_Retrs.addSubview(backBtn_Retrs)

        // 主题 emoji
        emojiLabel_Retrs.text = activity_Retrs?.emoji_Retrs ?? "📸"
        emojiLabel_Retrs.font = UIFont.systemFont(ofSize: 40)
        headerView_Retrs.addSubview(emojiLabel_Retrs)

        // 主题名称
        titleLabel_Retrs.text = activity_Retrs?.title_Retrs ?? "Theme Challenge"
        titleLabel_Retrs.font = UIFont.systemFont(ofSize: 26, weight: .black)
        titleLabel_Retrs.textColor = .white
        headerView_Retrs.addSubview(titleLabel_Retrs)

        // 主题描述
        descLabel_Retrs.text = activity_Retrs?.description_Retrs ?? ""
        descLabel_Retrs.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descLabel_Retrs.textColor = UIColor.white.withAlphaComponent(0.82)
        descLabel_Retrs.numberOfLines = 2
        headerView_Retrs.addSubview(descLabel_Retrs)

        // 统计行（参与人数 + 标签）
        headerView_Retrs.addSubview(statsRow_Retrs)
        let personIcon_Retrs = UIImageView(image: UIImage(systemName: "person.3.fill"))
        personIcon_Retrs.tintColor = UIColor.white.withAlphaComponent(0.8)
        personIcon_Retrs.contentMode = .scaleAspectFit
        statsRow_Retrs.addSubview(personIcon_Retrs)
        personIcon_Retrs.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        let countLbl_Retrs = participantCountLabel_Retrs
        countLbl_Retrs.text = "\(activity_Retrs?.participants_Retrs ?? 0) participants"
        countLbl_Retrs.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        countLbl_Retrs.textColor = UIColor.white.withAlphaComponent(0.9)
        statsRow_Retrs.addSubview(countLbl_Retrs)
        countLbl_Retrs.snp.makeConstraints { make in
            make.leading.equalTo(personIcon_Retrs.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
        }
        // 标签 pills
        var lastPill_Retrs: UIView? = countLbl_Retrs
        for tag_Retrs in (activity_Retrs?.tags_Retrs ?? []).prefix(3) {
            let pill_Retrs = UIView()
            pill_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.22)
            pill_Retrs.layer.cornerRadius = 10
            let tagLbl_Retrs = UILabel()
            tagLbl_Retrs.text = "#\(tag_Retrs)"
            tagLbl_Retrs.font = UIFont.systemFont(ofSize: 10, weight: .bold)
            tagLbl_Retrs.textColor = .white
            pill_Retrs.addSubview(tagLbl_Retrs)
            tagLbl_Retrs.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(4)
                make.leading.trailing.equalToSuperview().inset(8)
            }
            statsRow_Retrs.addSubview(pill_Retrs)
            pill_Retrs.snp.makeConstraints { make in
                make.leading.equalTo(lastPill_Retrs!.snp.trailing).offset(8)
                make.centerY.equalToSuperview()
            }
            lastPill_Retrs = pill_Retrs
        }
        statsRow_Retrs.snp.makeConstraints { make in make.height.equalTo(24) }

        let safeTop_Retrs = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 44

        backBtn_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Retrs + 14)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(36)
        }
        emojiLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(backBtn_Retrs.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(22)
        }
        titleLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(emojiLabel_Retrs.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(22)
            make.trailing.equalToSuperview().offset(-22)
        }
        descLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Retrs.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(22)
            make.trailing.equalToSuperview().offset(-22)
        }
        statsRow_Retrs.snp.makeConstraints { make in
            make.top.equalTo(descLabel_Retrs.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(22)
            make.trailing.equalToSuperview().offset(-22)
            make.bottom.equalToSuperview().offset(-22)
        }
    }

    private func addBubble_Retrs(alpha: CGFloat, size: CGFloat,
                                  top: CGFloat? = nil, bottom: CGFloat? = nil,
                                  leading: CGFloat? = nil, trailing: CGFloat? = nil) {
        let v_Retrs = UIView()
        v_Retrs.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Retrs.layer.cornerRadius = size / 2
        headerView_Retrs.addSubview(v_Retrs)
        v_Retrs.snp.makeConstraints { make in
            make.width.height.equalTo(size)
            if let t = top     { make.top.equalToSuperview().offset(t) }
            if let b = bottom  { make.bottom.equalToSuperview().offset(b) }
            if let l = leading { make.leading.equalToSuperview().offset(l) }
            if let r = trailing { make.trailing.equalToSuperview().offset(r) }
        }
    }

    // MARK: - 讨论区

    private func setupDiscussSection_Retrs() {
        // 区块标题
        let dot_Retrs = UIView()
        dot_Retrs.backgroundColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        dot_Retrs.layer.cornerRadius = 3
        contentView_Retrs.addSubview(dot_Retrs)
        dot_Retrs.tag = 8801

        discussTitle_Retrs.text = "Discussion"
        discussTitle_Retrs.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        discussTitle_Retrs.textColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        contentView_Retrs.addSubview(discussTitle_Retrs)

        // 帖子卡片栈
        discussStack_Retrs.axis = .vertical
        discussStack_Retrs.spacing = 12
        contentView_Retrs.addSubview(discussStack_Retrs)
    }

    // MARK: - 底部输入栏

    private func setupInputBar_Retrs() {
        view.addSubview(inputBar_Retrs)
        inputBar_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.97)
        inputBar_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            .withAlphaComponent(0.1).cgColor
        inputBar_Retrs.layer.shadowOffset = CGSize(width: 0, height: -2)
        inputBar_Retrs.layer.shadowOpacity = 1
        inputBar_Retrs.layer.shadowRadius  = 8

        // 参与打卡按钮（渐变）
        joinGradLayer_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
        ]
        joinGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0.5)
        joinGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 0.5)
        joinGradLayer_Retrs.cornerRadius = 18
        joinBtn_Retrs.layer.insertSublayer(joinGradLayer_Retrs, at: 0)
        joinBtn_Retrs.layer.cornerRadius = 18
        joinBtn_Retrs.setTitle("Join Challenge", for: .normal)
        joinBtn_Retrs.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        joinBtn_Retrs.setTitleColor(.white, for: .normal)
        joinBtn_Retrs.addTarget(self, action: #selector(joinTapped_Retrs), for: .touchUpInside)
        inputBar_Retrs.addSubview(joinBtn_Retrs)

        // 输入框
        inputWrap_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#EEF2FF")
        inputWrap_Retrs.layer.cornerRadius = 18
        inputBar_Retrs.addSubview(inputWrap_Retrs)

        inputField_Retrs.placeholder = "Share your thoughts..."
        inputField_Retrs.font = UIFont.systemFont(ofSize: 13)
        inputField_Retrs.backgroundColor = .clear
        inputField_Retrs.returnKeyType = .send
        inputField_Retrs.delegate = self
        let lp_Retrs = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 36))
        inputField_Retrs.leftView = lp_Retrs
        inputField_Retrs.leftViewMode = .always
        inputWrap_Retrs.addSubview(inputField_Retrs)
        inputField_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 发送按钮
        sendGradLayer_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
        ]
        sendGradLayer_Retrs.cornerRadius = 16
        sendBtn_Retrs.layer.insertSublayer(sendGradLayer_Retrs, at: 0)
        sendBtn_Retrs.layer.cornerRadius = 16
        sendBtn_Retrs.clipsToBounds = true
        let sendIV_Retrs = UIImageView(image: UIImage(systemName: "paperplane.fill",
                                                       withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)))
        sendIV_Retrs.tintColor = .white
        sendIV_Retrs.contentMode = .scaleAspectFit
        sendIV_Retrs.isUserInteractionEnabled = false
        sendBtn_Retrs.addSubview(sendIV_Retrs)
        sendIV_Retrs.snp.makeConstraints { make in make.center.equalToSuperview(); make.width.height.equalTo(16) }
        sendBtn_Retrs.addTarget(self, action: #selector(sendTapped_Retrs), for: .touchUpInside)
        inputBar_Retrs.addSubview(sendBtn_Retrs)
    }

    // MARK: - 约束

    private func setupConstraints_Retrs() {
        let screenW_Retrs = UIScreen.main.bounds.width
        let safeBottom_Retrs = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0

        scrollView_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputBar_Retrs.snp.top)
        }
        contentView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(screenW_Retrs)
        }
        headerView_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        if let dot_Retrs = contentView_Retrs.viewWithTag(8801) {
            dot_Retrs.snp.makeConstraints { make in
                make.top.equalTo(headerView_Retrs.snp.bottom).offset(20)
                make.leading.equalToSuperview().offset(20)
                make.width.height.equalTo(6)
            }
            discussTitle_Retrs.snp.makeConstraints { make in
                make.centerY.equalTo(dot_Retrs)
                make.leading.equalTo(dot_Retrs.snp.trailing).offset(8)
            }
        }
        discussStack_Retrs.snp.makeConstraints { make in
            make.top.equalTo(discussTitle_Retrs.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-20)
        }

        inputBar_Retrs.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(60 + safeBottom_Retrs)
            inputBarBottomConstraint_Retrs = make.bottom.equalToSuperview().constraint
        }
        joinBtn_Retrs.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview().offset(-safeBottom_Retrs / 2)
            make.width.equalTo(110)
            make.height.equalTo(36)
        }
        sendBtn_Retrs.snp.makeConstraints { make in
            make.trailing.equalTo(joinBtn_Retrs.snp.leading).offset(-8)
            make.centerY.equalToSuperview().offset(-safeBottom_Retrs / 2)
            make.width.height.equalTo(32)
        }
        inputWrap_Retrs.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalTo(sendBtn_Retrs.snp.leading).offset(-8)
            make.centerY.equalToSuperview().offset(-safeBottom_Retrs / 2)
            make.height.equalTo(36)
        }
    }

    // MARK: - 数据加载

    private func loadDiscussData_Retrs() {
        // 使用现有帖子作为讨论内容展示
        discussPosts_Retrs = Array(titleVM_Retrs.getPosts_Retrs().prefix(5))
        rebuildDiscussCards_Retrs()
    }

    private func rebuildDiscussCards_Retrs() {
        discussStack_Retrs.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if discussPosts_Retrs.isEmpty {
            let lbl_Retrs = UILabel()
            lbl_Retrs.text = "Be the first to join this challenge!"
            lbl_Retrs.font = UIFont.systemFont(ofSize: 13)
            lbl_Retrs.textColor = ColorConfig_Retrs.textPlaceholder_Retrs
            lbl_Retrs.textAlignment = .center
            discussStack_Retrs.addArrangedSubview(lbl_Retrs)
            return
        }
        for post_Retrs in discussPosts_Retrs {
            discussStack_Retrs.addArrangedSubview(buildDiscussCard_Retrs(post_Retrs: post_Retrs))
        }
    }

    private func buildDiscussCard_Retrs(post_Retrs: TitleModel_Retrs) -> UIView {
        let card_Retrs = UIView()
        card_Retrs.backgroundColor = .white
        card_Retrs.layer.cornerRadius = 16
        card_Retrs.clipsToBounds = false
        card_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            .withAlphaComponent(0.08).cgColor
        card_Retrs.layer.shadowOffset = CGSize(width: 0, height: 3)
        card_Retrs.layer.shadowOpacity = 1
        card_Retrs.layer.shadowRadius  = 8

        let av_Retrs = UserAvatarView_Retrs()
        av_Retrs.configure_Retrs(userId_Retrs: post_Retrs.titleUserId_Retrs)
        card_Retrs.addSubview(av_Retrs)
        av_Retrs.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(36)
        }

        let nameLbl_Retrs = UILabel()
        nameLbl_Retrs.text = post_Retrs.titleUserName_Retrs
        nameLbl_Retrs.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        nameLbl_Retrs.textColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        card_Retrs.addSubview(nameLbl_Retrs)
        nameLbl_Retrs.snp.makeConstraints { make in
            make.top.equalTo(av_Retrs)
            make.leading.equalTo(av_Retrs.snp.trailing).offset(10)
        }

        let titleLbl_Retrs = UILabel()
        titleLbl_Retrs.text = post_Retrs.title_Retrs
        titleLbl_Retrs.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        titleLbl_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        titleLbl_Retrs.numberOfLines = 2
        card_Retrs.addSubview(titleLbl_Retrs)
        titleLbl_Retrs.snp.makeConstraints { make in
            make.top.equalTo(nameLbl_Retrs.snp.bottom).offset(3)
            make.leading.equalTo(nameLbl_Retrs)
            make.trailing.equalToSuperview().offset(-12)
        }

        let contentLbl_Retrs = UILabel()
        contentLbl_Retrs.text = post_Retrs.titleContent_Retrs
        contentLbl_Retrs.font = UIFont.systemFont(ofSize: 11)
        contentLbl_Retrs.textColor = ColorConfig_Retrs.textSecondary_Retrs
        contentLbl_Retrs.numberOfLines = 2
        card_Retrs.addSubview(contentLbl_Retrs)
        contentLbl_Retrs.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_Retrs.snp.bottom).offset(4)
            make.leading.equalTo(nameLbl_Retrs)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }

        let tap_Retrs = ActivityDiscussTap_Retrs(post_Retrs: post_Retrs)
        card_Retrs.addGestureRecognizer(tap_Retrs)
        card_Retrs.isUserInteractionEnabled = true
        return card_Retrs
    }

    // MARK: - 事件

    @objc private func backTapped_Retrs()      { Navigation_Retrs.pop_Retrs() }
    @objc private func dismissKeyboard_Retrs() { view.endEditing(true) }

    @objc private func joinTapped_Retrs() {
        joinBtn_Retrs.animatePulse_Retrs()
        // 更新参与人数并刷新显示
        if activity_Retrs != nil {
            activity_Retrs!.participants_Retrs += 1
            participantCountLabel_Retrs.text = "\(activity_Retrs!.participants_Retrs) participants"
        }
        // 修改按钮为已加入状态
        joinBtn_Retrs.setTitle("Joined ✓", for: .normal)
        joinBtn_Retrs.isEnabled = false
        joinGradLayer_Retrs.colors = [
            UIColor(hexstring_Retrs: "#A0AEC0").cgColor,
            UIColor(hexstring_Retrs: "#A0AEC0").cgColor
        ]
        Utils_Retrs.showSuccess_Retrs(
            message_Retrs: "You joined the challenge!",
            image_Retrs: UIImage(systemName: "checkmark.circle.fill")
        )
    }

    @objc private func sendTapped_Retrs() {
        let text_Retrs = inputField_Retrs.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !text_Retrs.isEmpty else { return }
        sendBtn_Retrs.animatePulse_Retrs()
        Utils_Retrs.showSuccess_Retrs(message_Retrs: "Comment posted!", image_Retrs: UIImage(systemName: "checkmark.circle.fill"))
        inputField_Retrs.text = ""
        view.endEditing(true)
    }

    @objc private func keyboardWillShow_Retrs(_ notification: Notification) {
        guard let frame_Retrs = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        inputBarBottomConstraint_Retrs?.update(offset: -frame_Retrs.height)
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

    @objc private func keyboardWillHide_Retrs(_ notification: Notification) {
        inputBarBottomConstraint_Retrs?.update(offset: 0)
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }
}

extension ActivityDetail_Retrs: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped_Retrs(); return true
    }
}

// MARK: - 主题活动数据模型

/// 主题打卡活动模型
struct ThemeActivity_Retrs {
    var id_Retrs: Int
    var title_Retrs: String
    var emoji_Retrs: String
    var description_Retrs: String
    var participants_Retrs: Int
    var gradient_Retrs: [UIColor]
    var tags_Retrs: [String]
    var isHot_Retrs: Bool

    /// 预设活动列表
    static let activities_Retrs: [ThemeActivity_Retrs] = [
        ThemeActivity_Retrs(
            id_Retrs: 1, title_Retrs: "Street Retro", emoji_Retrs: "🛸",
            description_Retrs: "Capture vintage vibes on city streets with your CCD lens — freeze the smoky, grainy moments that last forever.",
            participants_Retrs: 2847,
            gradient_Retrs: [UIColor(hexstring_Retrs: "#B794F6"), UIColor(hexstring_Retrs: "#667EEA")],
            tags_Retrs: ["Street", "Retro", "CCD"], isHot_Retrs: true
        ),
        ThemeActivity_Retrs(
            id_Retrs: 2, title_Retrs: "Japanese Aesthetic", emoji_Retrs: "🌸",
            description_Retrs: "Soft tones, delicate light — use CCD to recreate the quiet beauty of Japanese everyday life.",
            participants_Retrs: 3521,
            gradient_Retrs: [UIColor(hexstring_Retrs: "#FBB6CE"), UIColor(hexstring_Retrs: "#B794F6")],
            tags_Retrs: ["Japan", "Soft", "Film"], isHot_Retrs: true
        ),
        ThemeActivity_Retrs(
            id_Retrs: 3, title_Retrs: "Old Town Snapshots", emoji_Retrs: "🏮",
            description_Retrs: "Wander through historic alleys — let CCD warm tones and grain breathe life into every old door and brick.",
            participants_Retrs: 1963,
            gradient_Retrs: [UIColor(hexstring_Retrs: "#F6AD55"), UIColor(hexstring_Retrs: "#FC8181")],
            tags_Retrs: ["OldTown", "Snap", "Culture"], isHot_Retrs: false
        )
    ]
}

// MARK: - 讨论卡片点击手势（内部辅助）

private class ActivityDiscussTap_Retrs: UITapGestureRecognizer {
    private let post_Retrs: TitleModel_Retrs
    init(post_Retrs: TitleModel_Retrs) {
        self.post_Retrs = post_Retrs
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap_Retrs))
    }
    @objc private func handleTap_Retrs() {
        Navigation_Retrs.toTitleDetail_Retrs(titleModel_retrs: post_Retrs)
    }
}
