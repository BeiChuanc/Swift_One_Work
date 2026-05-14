import Foundation
import UIKit
import SnapKit

// MARK: 主题合集详情页
// 设计思路：
//   每个主题拥有专属渐变配色 Header（全屏延伸），展示主题标题、副标题、主题图标；
//   内容区展示该主题下的弹幕列表（按 postId % themes.count 筛选），
//   每条弹幕卡片带举报和收藏按钮；
//   底部浮动"发布弹幕"按钮，点击切换至 Release Tab，参与主题互动。
// 关键属性：
//   theme_Echd     — 当前主题数据（由 Home 页传入）
//   themeIndex_Echd — 主题下标（0-3），用于筛选帖子

// MARK: - 主题数据模型（Home 与 ThemeCollection 共享）

/// 弹幕主题数据模型
/// 功能：定义主题的视觉配色、图标和文案，供 Home 卡片和 ThemeCollection 页面复用
struct DanmakuTheme_Echd {

    /// 主题 ID（对应帖子筛选下标）
    let id_Echd: Int

    /// 主题标题（中文）
    let title_Echd: String

    /// 主题副标题
    let subtitle_Echd: String

    /// SF Symbol 图标名
    let icon_Echd: String

    /// 渐变起始色
    let gradientStart_Echd: UIColor

    /// 渐变结束色
    let gradientEnd_Echd: UIColor

    // MARK: - 静态主题定义

    /// 全部主题合集（4个，按主题氛围设计独立配色）
    static let all_Echd: [DanmakuTheme_Echd] = [
        DanmakuTheme_Echd(
            id_Echd: 0,
            title_Echd: "To My Future Self",
            subtitle_Echd: "A letter to who you'll become",
            icon_Echd: "envelope.heart.fill",
            gradientStart_Echd: UIColor(hexstring_Echd: "#7C3AED"),
            gradientEnd_Echd: UIColor(hexstring_Echd: "#4F46E5")
        ),
        DanmakuTheme_Echd(
            id_Echd: 1,
            title_Echd: "Graduation Season",
            subtitle_Echd: "Youth never ends, see you again",
            icon_Echd: "graduationcap.fill",
            gradientStart_Echd: UIColor(hexstring_Echd: "#F59E0B"),
            gradientEnd_Echd: UIColor(hexstring_Echd: "#EF4444")
        ),
        DanmakuTheme_Echd(
            id_Echd: 2,
            title_Echd: "Holiday Wishes",
            subtitle_Echd: "Let wishes drift through time",
            icon_Echd: "star.fill",
            gradientStart_Echd: UIColor(hexstring_Echd: "#EC4899"),
            gradientEnd_Echd: UIColor(hexstring_Echd: "#8B5CF6")
        ),
        DanmakuTheme_Echd(
            id_Echd: 3,
            title_Echd: "City Moments",
            subtitle_Echd: "Capture the warmth of the city",
            icon_Echd: "building.2.fill",
            gradientStart_Echd: UIColor(hexstring_Echd: "#10B981"),
            gradientEnd_Echd: UIColor(hexstring_Echd: "#0EA5E9")
        )
    ]
}

// MARK: - ThemeCollection 页视图控制器

/// 主题合集详情页视图控制器
class ThemeCollection_Echd: UIViewController {

    // MARK: - 初始化属性

    private let theme_Echd: DanmakuTheme_Echd
    private let themeIndex_Echd: Int

    init(theme: DanmakuTheme_Echd, themeIndex: Int) {
        self.theme_Echd = theme
        self.themeIndex_Echd = themeIndex
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI组件 / Header

    private let headerView_Echd = UIView()
    private var headerGradient_Echd: CAGradientLayer?
    private let backButton_Echd = BackButton_Echd()

    private let themeIconView_Echd: UIImageView = {
        let iv_Echd = UIImageView()
        iv_Echd.contentMode = .scaleAspectFit
        return iv_Echd
    }()

    private let themeTitleLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 26, weight: .black)
        label_Echd.textColor = .white
        return label_Echd
    }()

    private let themeSubLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_Echd.textColor = UIColor.white.withAlphaComponent(0.78)
        return label_Echd
    }()

    private let themeCountLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label_Echd.textColor = .white
        label_Echd.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        label_Echd.layer.cornerRadius = 10
        label_Echd.clipsToBounds = true
        label_Echd.textAlignment = .center
        return label_Echd
    }()

    // MARK: - UI组件 / 列表

    private let scrollView_Echd: UIScrollView = {
        let sv_Echd = UIScrollView()
        sv_Echd.showsVerticalScrollIndicator = false
        sv_Echd.alwaysBounceVertical = true
        return sv_Echd
    }()

    private let contentView_Echd = UIView()
    private let cardsStack_Echd: UIStackView = {
        let sv_Echd = UIStackView()
        sv_Echd.axis = .vertical
        sv_Echd.spacing = 14
        return sv_Echd
    }()

    // MARK: - UI组件 / 底部评论输入栏（替代原浮动按钮）

    /// 评论输入栏容器
    private let commentBar_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = .white
        view_Echd.layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        view_Echd.layer.shadowOffset = CGSize(width: 0, height: -2)
        view_Echd.layer.shadowRadius = 8
        view_Echd.layer.shadowOpacity = 1
        return view_Echd
    }()

    /// 评论输入框容器（圆角）
    private let commentInputWrap_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor(hexstring_Echd: "#F3F4F6")
        view_Echd.layer.cornerRadius = 20
        return view_Echd
    }()

    /// 评论输入框
    private let commentTextField_Echd: UITextField = {
        let tf_Echd = UITextField()
        tf_Echd.placeholder = "Join the discussion..."
        tf_Echd.font = UIFont.systemFont(ofSize: 14)
        tf_Echd.textColor = UIColor(hexstring_Echd: "#1F2937")
        tf_Echd.backgroundColor = .clear
        tf_Echd.borderStyle = .none
        tf_Echd.autocorrectionType = .no
        tf_Echd.returnKeyType = .send
        return tf_Echd
    }()

    /// 发送按钮（主题渐变色）
    private let commentSendBtn_Echd: UIButton = {
        let btn_Echd = UIButton(type: .custom)
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        btn_Echd.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: cfg_Echd), for: .normal)
        btn_Echd.layer.cornerRadius = 20
        return btn_Echd
    }()

    // 保留以兼容 viewDidLayoutSubviews 引用（已无实际用途）
    private var publishBtnGradient_Echd: CAGradientLayer?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshThemeDanmaku_Echd()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Echd: "#F8F7FF")
        setupUI_Echd()
        setupConstraints_Echd()
        fillThemeData_Echd()
        observeNotifications_Echd()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Echd?.frame = headerView_Echd.bounds
        applyHeaderArc_Echd()
        // 发送按钮使用主题色（无渐变图层）
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - UI设置

    private func setupUI_Echd() {
        // Header
        headerView_Echd.clipsToBounds = true
        view.addSubview(headerView_Echd)

        let grad_Echd = CAGradientLayer()
        grad_Echd.colors = [theme_Echd.gradientStart_Echd.cgColor, theme_Echd.gradientEnd_Echd.cgColor]
        grad_Echd.startPoint = CGPoint(x: 0, y: 0)
        grad_Echd.endPoint = CGPoint(x: 1, y: 1)
        headerView_Echd.layer.insertSublayer(grad_Echd, at: 0)
        headerGradient_Echd = grad_Echd

        headerView_Echd.addSubview(themeIconView_Echd)
        headerView_Echd.addSubview(themeTitleLabel_Echd)
        headerView_Echd.addSubview(themeSubLabel_Echd)
        headerView_Echd.addSubview(themeCountLabel_Echd)

        view.addSubview(backButton_Echd)
        backButton_Echd.onTapped_Echd = { Navigation_Echd.pop_Echd() }

        // 讨论列表
        view.addSubview(scrollView_Echd)
        scrollView_Echd.addSubview(contentView_Echd)
        contentView_Echd.addSubview(cardsStack_Echd)

        // 底部评论输入栏
        view.addSubview(commentBar_Echd)
        commentBar_Echd.addSubview(commentInputWrap_Echd)
        commentInputWrap_Echd.addSubview(commentTextField_Echd)
        commentBar_Echd.addSubview(commentSendBtn_Echd)

        // 发送按钮使用主题色
        commentSendBtn_Echd.tintColor = theme_Echd.gradientStart_Echd
        commentSendBtn_Echd.addTarget(self, action: #selector(sendCommentTapped_Echd), for: .touchUpInside)
        commentTextField_Echd.delegate = self

        // 键盘处理
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow_Echd(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide_Echd(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)

        let tapDismiss_Echd = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Echd))
        tapDismiss_Echd.cancelsTouchesInView = false
        scrollView_Echd.addGestureRecognizer(tapDismiss_Echd)

        // 底部预留 100pt，确保最后一条讨论始终可见，不被输入栏压盖
        scrollView_Echd.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        scrollView_Echd.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }

    private func applyHeaderArc_Echd() {
        let w_Echd = headerView_Echd.bounds.width
        let h_Echd = headerView_Echd.bounds.height
        let path_Echd = UIBezierPath()
        path_Echd.move(to: .zero)
        path_Echd.addLine(to: CGPoint(x: w_Echd, y: 0))
        path_Echd.addLine(to: CGPoint(x: w_Echd, y: h_Echd - 18))
        path_Echd.addQuadCurve(
            to: CGPoint(x: 0, y: h_Echd - 18),
            controlPoint: CGPoint(x: w_Echd / 2, y: h_Echd + 18)
        )
        path_Echd.close()
        let mask_Echd = CAShapeLayer(); mask_Echd.path = path_Echd.cgPath
        headerView_Echd.layer.mask = mask_Echd
    }

    // MARK: - 约束

    private func setupConstraints_Echd() {
        let sw_Echd = UIScreen.main.bounds.width

        headerView_Echd.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(160)
        }
        backButton_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        themeIconView_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(10)
            make.width.height.equalTo(110)
        }
        themeTitleLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalTo(backButton_Echd.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(themeIconView_Echd.snp.leading).offset(-8)
        }
        themeSubLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(themeTitleLabel_Echd.snp.bottom).offset(6)
            make.leading.equalTo(backButton_Echd.snp.trailing).offset(8)
        }
        themeCountLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(themeSubLabel_Echd.snp.bottom).offset(12)
            make.leading.equalTo(backButton_Echd.snp.trailing).offset(8)
            make.height.equalTo(22)
        }

        // 评论输入栏固定在底部
        commentBar_Echd.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        commentSendBtn_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(40)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
        }
        commentInputWrap_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalTo(commentSendBtn_Echd.snp.leading).offset(-8)
            make.centerY.equalTo(commentSendBtn_Echd)
            make.height.equalTo(40)
        }
        commentTextField_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }

        // scrollView 底部紧贴评论栏顶部，内容不会被压盖
        scrollView_Echd.snp.makeConstraints { make in
            make.top.equalTo(headerView_Echd.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(commentBar_Echd.snp.top)
        }
        contentView_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(sw_Echd)
        }
        cardsStack_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    // MARK: - 数据填充

    /// 填充 Header 主题数据
    private func fillThemeData_Echd() {
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 50, weight: .thin)
        themeIconView_Echd.image = UIImage(systemName: theme_Echd.icon_Echd, withConfiguration: cfg_Echd)
        themeIconView_Echd.tintColor = UIColor.white.withAlphaComponent(0.14)
        themeTitleLabel_Echd.text = theme_Echd.title_Echd
        themeSubLabel_Echd.text = theme_Echd.subtitle_Echd
    }

    /// 刷新主题讨论列表（来自 DanmakuFavVM，按 danmakuId % themes.count 筛选）
    private func refreshThemeDanmaku_Echd() {
        cardsStack_Echd.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let all_Echd = DanmakuFavVM_Echd.shared_Echd.getAllDanmaku_Echd()
        let filtered_Echd = all_Echd.filter {
            $0.danmakuId_Echd % DanmakuTheme_Echd.all_Echd.count == themeIndex_Echd
        }

        themeCountLabel_Echd.text = "  \(filtered_Echd.count) discussions  "

        if filtered_Echd.isEmpty {
            let lbl_Echd = UILabel()
            lbl_Echd.text = "No discussions in \"\(theme_Echd.title_Echd)\" yet.\nBe the first to share a thought! ✦"
            lbl_Echd.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            lbl_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
            lbl_Echd.textAlignment = .center
            lbl_Echd.numberOfLines = 0
            let wrap_Echd = UIView()
            wrap_Echd.addSubview(lbl_Echd)
            lbl_Echd.snp.makeConstraints { make in make.edges.equalToSuperview().inset(24) }
            cardsStack_Echd.addArrangedSubview(wrap_Echd)
            return
        }

        for item_Echd in filtered_Echd {
            cardsStack_Echd.addArrangedSubview(buildDiscussionCard_Echd(danmaku: item_Echd))
        }
    }

    /// 构建主题讨论卡片（DanmakuModel_Echd）
    /// 移除点赞数和收藏按钮（红框部分），仅展示内容、作者、举报按钮
    private func buildDiscussionCard_Echd(danmaku: DanmakuModel_Echd) -> UIView {
        let card_Echd = UIView()
        card_Echd.backgroundColor = .white
        card_Echd.layer.cornerRadius = 16
        card_Echd.layer.shadowColor = theme_Echd.gradientStart_Echd.withAlphaComponent(0.15).cgColor
        card_Echd.layer.shadowOffset = CGSize(width: 0, height: 4)
        card_Echd.layer.shadowRadius = 12
        card_Echd.layer.shadowOpacity = 1

        // 左侧主题色竖条
        let bar_Echd = UIView()
        bar_Echd.backgroundColor = theme_Echd.gradientStart_Echd
        bar_Echd.layer.cornerRadius = 2.5
        card_Echd.addSubview(bar_Echd)

        // 主题角标
        let tagLbl_Echd = UILabel()
        tagLbl_Echd.text = "  \(theme_Echd.title_Echd)  "
        tagLbl_Echd.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        tagLbl_Echd.textColor = .white
        tagLbl_Echd.backgroundColor = theme_Echd.gradientStart_Echd
        tagLbl_Echd.layer.cornerRadius = 9
        tagLbl_Echd.clipsToBounds = true
        card_Echd.addSubview(tagLbl_Echd)

        // 弹幕符号
        let icon_Echd = UILabel()
        icon_Echd.text = "►"
        icon_Echd.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        icon_Echd.textColor = theme_Echd.gradientStart_Echd
        card_Echd.addSubview(icon_Echd)

        // 正文（不截断，展示完整讨论内容）
        let contentLbl_Echd = UILabel()
        contentLbl_Echd.text = danmaku.content_Echd
        contentLbl_Echd.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        contentLbl_Echd.textColor = UIColor(hexstring_Echd: "#1F2937")
        contentLbl_Echd.numberOfLines = 0
        card_Echd.addSubview(contentLbl_Echd)

        // 作者行（头像 + 昵称 + 举报按钮）
        let authorNameLbl_Echd = UILabel()
        authorNameLbl_Echd.text = danmaku.authorName_Echd
        authorNameLbl_Echd.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        authorNameLbl_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
        card_Echd.addSubview(authorNameLbl_Echd)

        // 时间戳
        let fmt_Echd = DateFormatter(); fmt_Echd.dateFormat = "MM/dd"
        let timeLbl_Echd = UILabel()
        timeLbl_Echd.text = fmt_Echd.string(from: Date(timeIntervalSince1970: danmaku.timestamp_Echd))
        timeLbl_Echd.font = UIFont.systemFont(ofSize: 10)
        timeLbl_Echd.textColor = UIColor(hexstring_Echd: "#D1D5DB")
        card_Echd.addSubview(timeLbl_Echd)

        // 举报按钮（右上角，使用 ReportDeleteHelper）
        let reportBtn_Echd = UIButton(type: .system)
        let rCfg_Echd = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        reportBtn_Echd.setImage(UIImage(systemName: "ellipsis", withConfiguration: rCfg_Echd), for: .normal)
        reportBtn_Echd.tintColor = UIColor(hexstring_Echd: "#9CA3AF")
        reportBtn_Echd.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            ReportDeleteHelper_Echd.reportDanmaku_Echd(
                danmaku_Echd: danmaku,
                from: self,
                completion_Echd: { [weak self] in
                    self?.refreshThemeDanmaku_Echd()
                    Utils_Echd.showInfo_Echd(message_Echd: "This spark will no longer appear.")
                }
            )
        }, for: .touchUpInside)
        card_Echd.addSubview(reportBtn_Echd)

        // 约束
        bar_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-14)
            make.width.equalTo(4)
        }
        reportBtn_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(26)
        }
        tagLbl_Echd.snp.makeConstraints { make in
            make.leading.equalTo(bar_Echd.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(14)
            make.height.equalTo(20)
            make.trailing.lessThanOrEqualTo(reportBtn_Echd.snp.leading).offset(-8)
        }
        icon_Echd.snp.makeConstraints { make in
            make.leading.equalTo(bar_Echd.snp.trailing).offset(10)
            make.top.equalTo(tagLbl_Echd.snp.bottom).offset(8)
        }
        contentLbl_Echd.snp.makeConstraints { make in
            make.leading.equalTo(icon_Echd.snp.trailing).offset(6)
            make.top.equalTo(tagLbl_Echd.snp.bottom).offset(6)
            make.trailing.equalToSuperview().offset(-14)
        }
        authorNameLbl_Echd.snp.makeConstraints { make in
            make.leading.equalTo(bar_Echd.snp.trailing).offset(10)
            make.top.equalTo(contentLbl_Echd.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-14)
        }
        timeLbl_Echd.snp.makeConstraints { make in
            make.leading.equalTo(authorNameLbl_Echd.snp.trailing).offset(8)
            make.centerY.equalTo(authorNameLbl_Echd)
        }

        return card_Echd
    }

    // MARK: - 评论发送

    /// 发送评论（需登录），发布后刷新讨论列表
    @objc private func sendCommentTapped_Echd() {
        guard let text_Echd = commentTextField_Echd.text,
              !text_Echd.trimmingCharacters(in: .whitespaces).isEmpty else {
            commentTextField_Echd.animateShake_Echd()
            return
        }
        // 未登录提示
        guard UserViewModel_Echd.shared_Echd.isLoggedIn_Echd else {
            Navigation_Echd.toLogin_Echd(style_echd: .present_echd)
            return
        }
        commentSendBtn_Echd.animatePulse_Echd()
        let user_Echd = UserViewModel_Echd.shared_Echd.getCurrentUser_Echd()
        DanmakuFavVM_Echd.shared_Echd.publishDanmaku_Echd(
            content_echd: text_Echd.trimmingCharacters(in: .whitespaces),
            authorName_echd: user_Echd.userName_Echd ?? "Anonymous",
            authorId_echd: user_Echd.userId_Echd ?? 0,
            themeIndex_echd: themeIndex_Echd   // 确保新条目出现在当前主题列表中
        )
        commentTextField_Echd.text = nil
        commentTextField_Echd.resignFirstResponder()
        refreshThemeDanmaku_Echd()
        Utils_Echd.showInfo_Echd(message_Echd: "Your spark has joined the discussion! ✦")
    }

    @objc private func dismissKeyboard_Echd() { view.endEditing(true) }

    // MARK: - 键盘处理

    @objc private func keyboardWillShow_Echd(_ notification: Notification) {
        guard let kbFrame_Echd = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        UIView.animate(withDuration: 0.3) {
            self.commentBar_Echd.snp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(-kbFrame_Echd.height)
            }
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide_Echd(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.commentBar_Echd.snp.updateConstraints { make in
                make.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - 通知监听

    private func observeNotifications_Echd() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleDataChange_Echd),
            name: DanmakuFavVM_Echd.danmakuChangedNotification_Echd, object: nil
        )
    }

    @objc private func handleDataChange_Echd() { refreshThemeDanmaku_Echd() }
}

// MARK: - UITextFieldDelegate

extension ThemeCollection_Echd: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendCommentTapped_Echd()
        return true
    }
}
