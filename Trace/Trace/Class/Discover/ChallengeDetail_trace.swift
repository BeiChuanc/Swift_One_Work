import UIKit
import SnapKit

// MARK: - 挑战详情页

/// 挑战详情页视图控制器
/// 核心作用：展示单个轻量挑战的完整信息，展示预制参与记录，支持用户快速输入自己的参与记录
/// 设计思路：滚动主体 + 固定底部输入条；输入条随键盘弹起自动上移；每条记录右上角提供举报入口
/// 关键属性：challenge_Trace（传入挑战模型），localParticipations_Trace（可变的本地参与记录列表），inputBarBottomConstraint_Trace（输入条底部约束，跟随键盘变化）
class ChallengeDetail_Trace: UIViewController {

    // MARK: - 外部传入属性

    /// 当前展示的挑战模型（由调用方在跳转前赋值）
    var challenge_Trace: ChallengeModel_Trace?

    // MARK: - 私有数据

    /// 本地可变的参与记录列表（基于预制数据，用户发布后追加）
    private var localParticipations_Trace: [ChallengeParticipation_Trace] = []

    // MARK: - UI 组件

    /// 滚动容器
    private let scrollView_Trace: UIScrollView = {
        let sv_Trace = UIScrollView()
        sv_Trace.showsVerticalScrollIndicator = false
        sv_Trace.alwaysBounceVertical = true
        sv_Trace.keyboardDismissMode = .interactive
        return sv_Trace
    }()

    /// 滚动内容根容器
    private let contentContainer_Trace = UIView()

    // MARK: 头部卡

    private let headerCard_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.layer.cornerRadius = 24
        v_Trace.layer.masksToBounds = true
        return v_Trace
    }()

    private let headerGradientLayer_Trace = CAGradientLayer()

    private let badgeLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lbl_Trace.textColor = .white
        lbl_Trace.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        lbl_Trace.layer.cornerRadius = 9
        lbl_Trace.layer.masksToBounds = true
        lbl_Trace.textAlignment = .center
        return lbl_Trace
    }()

    private let emojiLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 52)
        lbl_Trace.textAlignment = .center
        return lbl_Trace
    }()

    private let titleLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl_Trace.textColor = .white
        lbl_Trace.numberOfLines = 2
        return lbl_Trace
    }()

    private let descLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl_Trace.textColor = UIColor.white.withAlphaComponent(0.8)
        lbl_Trace.numberOfLines = 0
        return lbl_Trace
    }()

    private let participantRow_Trace = UIView()

    // MARK: 记录分区

    private let sectionTitle_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.text = "Recent Traces"
        lbl_Trace.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        lbl_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
        return lbl_Trace
    }()

    private let recordsStack_Trace: UIStackView = {
        let sv_Trace = UIStackView()
        sv_Trace.axis = .vertical
        sv_Trace.spacing = 14
        return sv_Trace
    }()

    // MARK: 底部输入条

    /// 输入条容器（固定底部，跟随键盘）
    private let inputBarView_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.backgroundColor = .white
        // 顶部细线（颜色与 divider 一致，明确输入条边界）
        let separator_Trace = UIView()
        separator_Trace.backgroundColor = ColorConfig_Trace.divider_Trace
        v_Trace.addSubview(separator_Trace)
        separator_Trace.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
        return v_Trace
    }()

    /// 输入框
    private let inputField_Trace: UITextField = {
        let tf_Trace = UITextField()
        tf_Trace.placeholder = "Share your trace..."
        tf_Trace.font = UIFont.systemFont(ofSize: 15)
        tf_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
        // 使用主背景浅灰（#F7FAFC），与白色输入条形成对比，使 20pt 圆角和水平间距可见
        tf_Trace.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        tf_Trace.layer.cornerRadius = 20
        tf_Trace.layer.masksToBounds = true
        tf_Trace.returnKeyType = .send
        // 左侧内边距
        let leftPadding_Trace = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        tf_Trace.leftView = leftPadding_Trace
        tf_Trace.leftViewMode = .always
        // 右侧内边距（避免光标贴边）
        let rightPadding_Trace = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        tf_Trace.rightView = rightPadding_Trace
        tf_Trace.rightViewMode = .always
        return tf_Trace
    }()

    /// 发送按钮（渐变圆形；图标通过子视图 sendIcon_Trace 渲染，避免被 CAGradientLayer 遮挡）
    private let sendBtn_Trace: UIButton = {
        let btn_Trace = UIButton(type: .custom)
        btn_Trace.layer.cornerRadius = 20
        btn_Trace.layer.masksToBounds = true
        return btn_Trace
    }()

    /// 发送按钮内的箭头图标（作为子视图，始终在渐变层之上）
    private let sendIcon_Trace: UIImageView = {
        let iv_Trace = UIImageView()
        let cfg_Trace = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        iv_Trace.image = UIImage(systemName: "arrow.up", withConfiguration: cfg_Trace)
        iv_Trace.tintColor = .white
        iv_Trace.contentMode = .scaleAspectFit
        iv_Trace.isUserInteractionEnabled = false
        return iv_Trace
    }()

    /// 发送按钮渐变层
    private let sendGradient_Trace = CAGradientLayer()

    /// 输入条底部约束（用于跟随键盘上移）
    private var inputBarBottomConstraint_Trace: Constraint?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        localParticipations_Trace = challenge_Trace?.participations_Trace ?? []
        setupNavBar_Trace()
        setupLayout_Trace()
        configureContent_Trace()
        subscribeKeyboard_Trace()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 统一使用 setNavigationBarHidden 维护 UINavigationController 内部状态
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer_Trace.frame = headerCard_Trace.bounds
        sendGradient_Trace.frame = sendBtn_Trace.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 自定义导航栏

    private func setupNavBar_Trace() {
        let navBar_Trace = UIView()
        navBar_Trace.backgroundColor = .clear
        view.addSubview(navBar_Trace)
        navBar_Trace.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
        }

        let backBtn_Trace = UIButton(type: .system)
        let cfg_Trace = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        backBtn_Trace.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg_Trace), for: .normal)
        backBtn_Trace.tintColor = ColorConfig_Trace.textPrimary_Trace
        backBtn_Trace.addTarget(self, action: #selector(handleBack_Trace), for: .touchUpInside)
        navBar_Trace.addSubview(backBtn_Trace)
        backBtn_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
    }

    // MARK: - 布局搭建

    private func setupLayout_Trace() {
        // 底部输入条（固定，跟随键盘）
        view.addSubview(inputBarView_Trace)
        inputBarView_Trace.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(68)
            inputBarBottomConstraint_Trace = make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).constraint
        }

        // 发送按钮渐变（先插入渐变层，再将图标视图叠在上面）
        sendGradient_Trace.startPoint = CGPoint(x: 0, y: 0)
        sendGradient_Trace.endPoint = CGPoint(x: 1, y: 1)
        sendBtn_Trace.layer.insertSublayer(sendGradient_Trace, at: 0)
        // 图标作为 subview 永远在 CALayer 之上
        sendBtn_Trace.addSubview(sendIcon_Trace)
        sendIcon_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }

        inputBarView_Trace.addSubview(inputField_Trace)
        inputBarView_Trace.addSubview(sendBtn_Trace)

        // 发送按钮：距屏幕右边缘 16pt
        sendBtn_Trace.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        // 输入框：左侧距屏幕 16pt，右侧与发送按钮间距 10pt，圆角 Pill 样式
        inputField_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(sendBtn_Trace.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }

        sendBtn_Trace.addTarget(self, action: #selector(handleSend_Trace), for: .touchUpInside)
        inputField_Trace.delegate = self

        // 滚动区（从导航栏底部到输入条顶部）
        view.addSubview(scrollView_Trace)
        scrollView_Trace.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(48)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputBarView_Trace.snp.top)
        }

        scrollView_Trace.addSubview(contentContainer_Trace)
        contentContainer_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Trace)
        }

        // 头部卡
        contentContainer_Trace.addSubview(headerCard_Trace)
        headerCard_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        headerCard_Trace.addSubview(badgeLabel_Trace)
        headerCard_Trace.addSubview(emojiLabel_Trace)
        headerCard_Trace.addSubview(titleLabel_Trace)
        headerCard_Trace.addSubview(descLabel_Trace)
        headerCard_Trace.addSubview(participantRow_Trace)

        badgeLabel_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(60)
        }
        emojiLabel_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-20)
        }
        titleLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(badgeLabel_Trace.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        descLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Trace.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        participantRow_Trace.snp.makeConstraints { make in
            make.top.equalTo(descLabel_Trace.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(28)
        }
        buildParticipantRow_Trace()

        // Recent Traces 标题
        contentContainer_Trace.addSubview(sectionTitle_Trace)
        sectionTitle_Trace.snp.makeConstraints { make in
            make.top.equalTo(headerCard_Trace.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(20)
        }

        // 记录卡片列表
        contentContainer_Trace.addSubview(recordsStack_Trace)
        recordsStack_Trace.snp.makeConstraints { make in
            make.top.equalTo(sectionTitle_Trace.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    /// 搭建参与人数行：最多展示3个叠层头像（UserAvatarView_Trace）+ 人数 + 说明文字
    private func buildParticipantRow_Trace() {
        let avatarSize_Trace: CGFloat = 24
        let maxAvatars_Trace = 3
        let displayCount_Trace = min(localParticipations_Trace.count, maxAvatars_Trace)

        // 叠层头像（每个向右偏移 -8pt 形成叠放效果，根据 userId 获取真实用户数据）
        var previousAvatarView_Trace: UIView? = nil
        for idx_Trace in 0..<displayCount_Trace {
            let p_Trace = localParticipations_Trace[idx_Trace]
            let av_Trace = UserAvatarView_Trace()
            av_Trace.configure_Trace(userId_Trace: p_Trace.authorUserId_Trace)
            // 白色圆圈边框增强叠层视觉区分
            av_Trace.layer.borderWidth = 1.5
            av_Trace.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
            participantRow_Trace.addSubview(av_Trace)
            av_Trace.snp.makeConstraints { make in
                if let prev_Trace = previousAvatarView_Trace {
                    make.leading.equalTo(prev_Trace.snp.trailing).offset(-8)
                } else {
                    make.leading.equalToSuperview()
                }
                make.centerY.equalToSuperview()
                make.width.height.equalTo(avatarSize_Trace)
            }
            previousAvatarView_Trace = av_Trace
        }

        // 无参与记录时保留 person.2.fill 图标兜底
        if displayCount_Trace == 0 {
            let iconView_Trace = UIImageView()
            let cfg_Trace = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
            iconView_Trace.image = UIImage(systemName: "person.2.fill", withConfiguration: cfg_Trace)
            iconView_Trace.tintColor = UIColor.white.withAlphaComponent(0.85)
            iconView_Trace.contentMode = .scaleAspectFit
            participantRow_Trace.addSubview(iconView_Trace)
            iconView_Trace.snp.makeConstraints { make in
                make.leading.centerY.equalToSuperview()
                make.width.height.equalTo(18)
            }
            previousAvatarView_Trace = iconView_Trace
        }

        let countLabel_Trace = UILabel()
        countLabel_Trace.tag = 9001
        countLabel_Trace.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        countLabel_Trace.textColor = UIColor.white.withAlphaComponent(0.85)

        let joiningLabel_Trace = UILabel()
        joiningLabel_Trace.text = "joining this challenge"
        joiningLabel_Trace.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        joiningLabel_Trace.textColor = UIColor.white.withAlphaComponent(0.65)

        participantRow_Trace.addSubview(countLabel_Trace)
        participantRow_Trace.addSubview(joiningLabel_Trace)

        countLabel_Trace.snp.makeConstraints { make in
            if let prev_Trace = previousAvatarView_Trace {
                make.leading.equalTo(prev_Trace.snp.trailing).offset(8)
            } else {
                make.leading.equalToSuperview()
            }
            make.centerY.equalToSuperview()
        }
        joiningLabel_Trace.snp.makeConstraints { make in
            make.leading.equalTo(countLabel_Trace.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }
    }

    // MARK: - 内容填充

    private func configureContent_Trace() {
        guard let challenge_trace = challenge_Trace else { return }

        // 头部渐变
        headerGradientLayer_Trace.colors = [
            UIColor(hexstring_Trace: challenge_trace.gradientStart_Trace).cgColor,
            UIColor(hexstring_Trace: challenge_trace.gradientEnd_Trace).cgColor
        ]
        headerGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        headerGradientLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
        if headerGradientLayer_Trace.superlayer == nil {
            headerCard_Trace.layer.insertSublayer(headerGradientLayer_Trace, at: 0)
        }

        // 发送按钮渐变
        sendGradient_Trace.colors = [
            UIColor(hexstring_Trace: challenge_trace.gradientStart_Trace).cgColor,
            UIColor(hexstring_Trace: challenge_trace.gradientEnd_Trace).cgColor
        ]

        // 头部内容
        badgeLabel_Trace.text = "  \(challenge_trace.isOfficial_Trace ? "OFFICIAL ★" : "COMMUNITY")  "
        emojiLabel_Trace.text = challenge_trace.emoji_Trace
        titleLabel_Trace.text = challenge_trace.title_Trace
        descLabel_Trace.text = challenge_trace.description_Trace

        // 参与人数
        if let countLbl_trace = participantRow_Trace.viewWithTag(9001) as? UILabel {
            countLbl_trace.text = "\(challenge_trace.participants_Trace)"
        }

        // 渲染记录卡片
        refreshRecords_Trace()
    }

    /// 刷新参与记录卡片列表
    private func refreshRecords_Trace() {
        recordsStack_Trace.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index_trace, participation_trace) in localParticipations_Trace.enumerated() {
            let card_trace = makeParticipationCard_Trace(
                participation_trace: participation_trace,
                index_trace: index_trace,
                animated_trace: index_trace >= (localParticipations_Trace.count - 1)
            )
            recordsStack_Trace.addArrangedSubview(card_trace)
        }
    }

    /// 将本地参与记录同步回 challenge 模型，确保退出重进后数据不丢失
    private func saveParticipations_Trace() {
        challenge_Trace?.participations_Trace = localParticipations_Trace
    }

    // MARK: - 记录卡片构建

    /// 构建单条参与记录卡片
    /// - Parameters:
    ///   - participation_trace: 参与记录数据
    ///   - index_trace: 在列表中的位置（用于入场动画延迟）
    ///   - animated_trace: 是否播放入场动画（新增记录为 true）
    /// - Returns: 白色阴影卡片视图
    private func makeParticipationCard_Trace(
        participation_trace: ChallengeParticipation_Trace,
        index_trace: Int,
        animated_trace: Bool
    ) -> UIView {
        let card_Trace = UIView()
        card_Trace.backgroundColor = .white
        card_Trace.layer.cornerRadius = 16
        card_Trace.layer.shadowColor = UIColor.black.cgColor
        card_Trace.layer.shadowOffset = CGSize(width: 0, height: 3)
        card_Trace.layer.shadowRadius = 10
        card_Trace.layer.shadowOpacity = 0.07

        // 渐变左边条
        let accentView_Trace = UIView()
        accentView_Trace.layer.cornerRadius = 2
        if let challenge_trace = challenge_Trace {
            let accentGrad_Trace = CAGradientLayer()
            accentGrad_Trace.colors = [
                UIColor(hexstring_Trace: challenge_trace.gradientStart_Trace).cgColor,
                UIColor(hexstring_Trace: challenge_trace.gradientEnd_Trace).cgColor
            ]
            accentGrad_Trace.startPoint = CGPoint(x: 0, y: 0)
            accentGrad_Trace.endPoint = CGPoint(x: 0, y: 1)
            accentGrad_Trace.cornerRadius = 2
            accentGrad_Trace.frame = CGRect(x: 0, y: 0, width: 3, height: 80)
            accentView_Trace.layer.addSublayer(accentGrad_Trace)
        } else {
            accentView_Trace.backgroundColor = ColorConfig_Trace.primaryGradientStart_Trace
        }

        // 根据参与者 UID 获取真实用户数据，填充头像与用户名
        let participantUser_Trace = UserViewModel_Trace.shared_Trace.getUserById_Trace(userId_trace: participation_trace.authorUserId_Trace)
        let avatarView_Trace = UserAvatarView_Trace()
        avatarView_Trace.configure_Trace(userId_Trace: participation_trace.authorUserId_Trace)

        // 用户名（优先使用真实用户名，兜底 "Unknown"）
        let nameLabel_Trace = UILabel()
        nameLabel_Trace.text = participantUser_Trace.userName_Trace ?? "Unknown"
        nameLabel_Trace.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        nameLabel_Trace.textColor = ColorConfig_Trace.textPrimary_Trace

        // 右上角操作按钮：自己的记录显示删除（trash），他人记录显示举报（ellipsis）
        let isOwn_Trace = UserViewModel_Trace.shared_Trace.isCurrentUser_Trace(userId_trace: participation_trace.authorUserId_Trace)
        let actionBtn_Trace = UIButton(type: .system)
        let iconName_Trace = isOwn_Trace ? "trash" : "ellipsis"
        let iconCfg_Trace = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        actionBtn_Trace.setImage(UIImage(systemName: iconName_Trace, withConfiguration: iconCfg_Trace), for: .normal)
        actionBtn_Trace.tintColor = ColorConfig_Trace.textPlaceholder_Trace

        // 内容文字
        let contentLabel_Trace = UILabel()
        contentLabel_Trace.text = participation_trace.content_Trace
        contentLabel_Trace.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        contentLabel_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
        contentLabel_Trace.numberOfLines = 0

        card_Trace.addSubview(accentView_Trace)
        card_Trace.addSubview(avatarView_Trace)
        card_Trace.addSubview(nameLabel_Trace)
        card_Trace.addSubview(actionBtn_Trace)
        card_Trace.addSubview(contentLabel_Trace)

        accentView_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-14)
            make.width.equalTo(3)
        }
        avatarView_Trace.snp.makeConstraints { make in
            make.leading.equalTo(accentView_Trace.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(14)
            make.width.height.equalTo(36)
        }
        nameLabel_Trace.snp.makeConstraints { make in
            make.leading.equalTo(avatarView_Trace.snp.trailing).offset(10)
            make.centerY.equalTo(avatarView_Trace)
            make.trailing.lessThanOrEqualTo(actionBtn_Trace.snp.leading).offset(-6)
        }
        // 操作按钮固定右上角
        actionBtn_Trace.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalTo(avatarView_Trace)
            make.width.height.equalTo(28)
        }
        contentLabel_Trace.snp.makeConstraints { make in
            make.leading.equalTo(avatarView_Trace.snp.leading)
            make.top.equalTo(avatarView_Trace.snp.bottom).offset(10)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-14)
        }

        // 操作按钮事件：自己的记录弹确认后删除，他人的记录弹举报 action sheet
        let capturedParticipation_Trace = participation_trace
        actionBtn_Trace.addAction(UIAction { [weak self] _ in
            guard let self_Trace = self else { return }
            ReportDeleteHelper_Trace.addButtonAnimation_Trace(button_Trace: actionBtn_Trace)
            if isOwn_Trace {
                // 自己的记录：弹确认对话框后删除
                let alert_Trace = UIAlertController(
                    title: "Delete Record",
                    message: "Are you sure you want to delete this record?",
                    preferredStyle: .alert
                )
                alert_Trace.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                    self_Trace.localParticipations_Trace.removeAll { $0 === capturedParticipation_Trace }
                    self_Trace.saveParticipations_Trace()
                    self_Trace.refreshRecords_Trace()
                })
                alert_Trace.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self_Trace.present(alert_Trace, animated: true)
            } else {
                // 他人的记录：弹举报 action sheet，确认后移除记录并保存
                UIAlertController.report_Trace(with: false) {
                    self_Trace.localParticipations_Trace.removeAll { $0 === capturedParticipation_Trace }
                    self_Trace.saveParticipations_Trace()
                    self_Trace.refreshRecords_Trace()
                }
            }
        }, for: .touchUpInside)

        // 入场动画
        if animated_trace {
            card_Trace.alpha = 0
            card_Trace.transform = CGAffineTransform(translationX: 0, y: 20)
            let delay_Trace = Double(index_trace % 3) * 0.1
            UIView.animate(
                withDuration: AnimationConfig_Trace.durationNormal_Trace,
                delay: delay_Trace,
                options: [.curveEaseOut]
            ) {
                card_Trace.alpha = 1
                card_Trace.transform = .identity
            }
        }

        return card_Trace
    }

    // MARK: - 键盘处理

    /// 注册键盘通知
    private func subscribeKeyboard_Trace() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Trace(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Trace(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    /// 键盘弹起：输入条随键盘上移
    @objc private func keyboardWillShow_Trace(_ notification: Notification) {
        guard let info_trace = notification.userInfo,
              let keyboardFrame_trace = info_trace[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_trace = info_trace[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        let keyboardHeight_trace = keyboardFrame_trace.height
        let safeBottom_trace = view.safeAreaInsets.bottom
        inputBarBottomConstraint_Trace?.update(offset: -(keyboardHeight_trace - safeBottom_trace))

        UIView.animate(withDuration: duration_trace, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
        // 滚动到底部展示最新内容
        DispatchQueue.main.asyncAfter(deadline: .now() + duration_trace) {
            let bottomOffset_trace = CGPoint(
                x: 0,
                y: max(0, self.scrollView_Trace.contentSize.height - self.scrollView_Trace.bounds.height)
            )
            self.scrollView_Trace.setContentOffset(bottomOffset_trace, animated: true)
        }
    }

    /// 键盘收起：输入条回到底部
    @objc private func keyboardWillHide_Trace(_ notification: Notification) {
        guard let info_trace = notification.userInfo,
              let duration_trace = info_trace[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        inputBarBottomConstraint_Trace?.update(offset: 0)
        UIView.animate(withDuration: duration_trace, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - 事件处理

    /// 返回上一页
    @objc private func handleBack_Trace() {
        Navigation_Trace.pop_Trace()
    }

    /// 发送参与记录
    @objc private func handleSend_Trace() {
        let text_trace = inputField_Trace.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text_trace.isEmpty else { return }

        // 未登录先跳转登录页
        guard UserViewModel_Trace.shared_Trace.isLoggedIn_Trace else {
            inputField_Trace.resignFirstResponder()
            Navigation_Trace.toLogin_Trace()
            return
        }

        // 获取当前用户 UID，直接存入参与记录
        let currentUser_trace = UserViewModel_Trace.shared_Trace.getCurrentUser_Trace()
        let currentUserId_trace = currentUser_trace.userId_Trace ?? 0

        let newRecord_trace = ChallengeParticipation_Trace(
            authorUserId_Trace: currentUserId_trace,
            content_Trace: text_trace
        )

        // 追加到本地列表，同步回 challenge 模型后刷新
        localParticipations_Trace.insert(newRecord_trace, at: 0)
        saveParticipations_Trace()
        inputField_Trace.text = nil
        inputField_Trace.resignFirstResponder()

        // 刷新记录区并播放新卡片入场动画
        refreshRecords_Trace()
        showToast_Trace(message_trace: "Trace shared ✦")
    }

    /// 底部悬浮 toast 提示
    /// - Parameter message_trace: 提示文字
    private func showToast_Trace(message_trace: String) {
        let toast_Trace = UILabel()
        toast_Trace.text = message_trace
        toast_Trace.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        toast_Trace.textColor = .white
        toast_Trace.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toast_Trace.textAlignment = .center
        toast_Trace.layer.cornerRadius = 16
        toast_Trace.layer.masksToBounds = true
        view.addSubview(toast_Trace)
        toast_Trace.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(inputBarView_Trace.snp.top).offset(-12)
            make.height.equalTo(32)
            make.width.greaterThanOrEqualTo(120)
            make.leading.greaterThanOrEqualToSuperview().offset(40)
            make.trailing.lessThanOrEqualToSuperview().offset(-40)
        }
        toast_Trace.alpha = 0
        UIView.animate(withDuration: 0.25) {
            toast_Trace.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5) {
                toast_Trace.alpha = 0
            } completion: { _ in
                toast_Trace.removeFromSuperview()
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension ChallengeDetail_Trace: UITextFieldDelegate {

    /// 点击键盘 Return（Send）触发发送
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend_Trace()
        return true
    }
}
