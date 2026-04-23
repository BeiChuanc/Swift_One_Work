import Foundation
import UIKit
import SnapKit

// MARK: - 发布页面
/// 核心作用：让已登录用户发布帖子（标题 + 内容 + 媒体）。
/// 设计思路：
///   - contentInsetAdjustmentBehavior = .never 使渐变头部真正贴屏顶
///   - 头部标题 top 约束存储为 Constraint，在 viewSafeAreaInsetsDidChange 中动态更新
///   - 表单分区使用彩色图标标题、输入框聚焦高亮、媒体区气泡式空态
///   - 发布按钮带右侧图标，发布说明卡带渐变左边条
/// 关键逻辑：
///   - 校验登录状态、标题/内容/媒体是否为空
///   - 媒体可从相册选取图片或视频
///   - 发布后调用 TitleViewModel.addPost，清空所有输入
class Release_Nest: UIViewController {

    // MARK: - 私有状态

    private var selectedMediaPath_Nest: String?
    private var isMediaVideo_Nest: Bool = false
    /// 头部标题顶部约束，在安全区域变化时动态更新
    private var headerTitleTopConstraint_Nest: Constraint?

    // MARK: - UI 组件 - 滚动容器

    private let scrollView_Nest: UIScrollView = {
        let sv_Nest = UIScrollView()
        sv_Nest.showsVerticalScrollIndicator = false
        sv_Nest.keyboardDismissMode = .onDrag
        sv_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        sv_Nest.contentInsetAdjustmentBehavior = .never
        sv_Nest.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        return sv_Nest
    }()

    private let contentView_Nest = UIView()

    // MARK: - UI 组件 - 渐变头部

    private let headerView_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.clipsToBounds = true
        return v_Nest
    }()

    private var headerGradient_Nest: CAGradientLayer?
    private var publishBtnGradient_Nest: CAGradientLayer?

    private let decorCircle1_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.13)
        v_Nest.layer.cornerRadius = 70
        return v_Nest
    }()

    private let decorCircle2_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v_Nest.layer.cornerRadius = 46
        return v_Nest
    }()

    private let decorCircle3_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v_Nest.layer.cornerRadius = 28
        return v_Nest
    }()

    /// 头部右侧大型半透明装饰图标，用于填充视觉空白、增加设计感
    private let headerHeroIcon_Nest: UIImageView = {
        let iv_Nest = UIImageView()
        let config_Nest = UIImage.SymbolConfiguration(pointSize: 88, weight: .ultraLight)
        iv_Nest.image = UIImage(systemName: "pencil.and.sparkles", withConfiguration: config_Nest)
        iv_Nest.tintColor = UIColor.white.withAlphaComponent(0.14)
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    /// 标题上方小徽章容器：图标 + 文案，强化身份定位
    private let headerTopBadge_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        v_Nest.layer.cornerRadius = 14
        v_Nest.layer.borderWidth = 1
        v_Nest.layer.borderColor = UIColor.white.withAlphaComponent(0.28).cgColor
        return v_Nest
    }()

    private let headerBadgeIcon_Nest: UIImageView = {
        let iv_Nest = UIImageView()
        iv_Nest.image = UIImage(systemName: "sparkles")
        iv_Nest.tintColor = .white
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    private let headerBadgeLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Create & Share"
        lbl_Nest.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl_Nest.textColor = .white
        return lbl_Nest
    }()

    private let headerTitle_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "New Post"
        lbl_Nest.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        lbl_Nest.textColor = .white
        return lbl_Nest
    }()

    private let headerSubtitle_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Craft a title, write a caption, then attach your best visual."
        lbl_Nest.font = UIFont.systemFont(ofSize: 14)
        lbl_Nest.textColor = UIColor.white.withAlphaComponent(0.88)
        lbl_Nest.numberOfLines = 2
        return lbl_Nest
    }()

    private let stepPillsStack_Nest: UIStackView = {
        let sv_Nest = UIStackView()
        sv_Nest.axis = .horizontal
        sv_Nest.spacing = 8
        sv_Nest.alignment = .center
        return sv_Nest
    }()

    // MARK: - UI 组件 - 表单卡片骨架

    private let formCard_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        v_Nest.layer.cornerRadius = 28
        v_Nest.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v_Nest.layer.shadowColor = ColorConfig_Nest.shadowColor_Nest.cgColor
        v_Nest.layer.shadowOffset = CGSize(width: 0, height: -4)
        v_Nest.layer.shadowRadius = 20
        v_Nest.layer.shadowOpacity = 1
        return v_Nest
    }()

    private let formHandle_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.border_Nest
        v_Nest.layer.cornerRadius = 2.5
        return v_Nest
    }()

    // MARK: - UI 组件 - Tips 卡片

    private let tipsCard_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor(hexstring_Nest: "#EEF0FF", alpha_Nest: 1)
        v_Nest.layer.cornerRadius = 16
        v_Nest.layer.borderWidth = 1
        v_Nest.layer.borderColor = ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.18).cgColor
        v_Nest.clipsToBounds = true
        return v_Nest
    }()

    private let tipsAccentBar_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.secondaryGradientStart_Nest
        return v_Nest
    }()

    private let tipsIconView_Nest: UIImageView = {
        let iv_Nest = UIImageView()
        iv_Nest.image = UIImage(systemName: "lightbulb.fill")
        iv_Nest.tintColor = ColorConfig_Nest.secondaryGradientStart_Nest
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    private let tipsTitleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Quick tips"
        lbl_Nest.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        lbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        return lbl_Nest
    }()

    private let tipsSubtitleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Short title + vivid caption + clean visual = more reach."
        lbl_Nest.font = UIFont.systemFont(ofSize: 12)
        lbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        lbl_Nest.numberOfLines = 1
        return lbl_Nest
    }()

    // MARK: - UI 组件 - Title 分区

    private let titleSectionLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        return lbl_Nest
    }()

    private let titleHintLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Specific and easy to scan."
        lbl_Nest.font = UIFont.systemFont(ofSize: 12)
        lbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest
        return lbl_Nest
    }()

    private let titleField_Nest: UITextField = {
        let tf_Nest = UITextField()
        tf_Nest.placeholder = "Post title"
        tf_Nest.font = UIFont.systemFont(ofSize: 15)
        tf_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        tf_Nest.backgroundColor = .white
        tf_Nest.layer.cornerRadius = 14
        tf_Nest.layer.borderWidth = 1.5
        tf_Nest.layer.borderColor = ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.18).cgColor
        tf_Nest.returnKeyType = .next
        tf_Nest.autocorrectionType = .no
        return tf_Nest
    }()

    private let divider1_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.divider_Nest
        return v_Nest
    }()

    // MARK: - UI 组件 - Caption 分区

    private let contentSectionLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        return lbl_Nest
    }()

    private let contentCountLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "0/240"
        lbl_Nest.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest
        return lbl_Nest
    }()

    private let contentTextView_Nest: UITextView = {
        let tv_Nest = UITextView()
        tv_Nest.font = UIFont.systemFont(ofSize: 15)
        tv_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        tv_Nest.backgroundColor = .white
        tv_Nest.layer.cornerRadius = 14
        tv_Nest.layer.borderWidth = 1.5
        tv_Nest.layer.borderColor = ColorConfig_Nest.primaryGradientEnd_Nest.withAlphaComponent(0.18).cgColor
        tv_Nest.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        return tv_Nest
    }()

    private let contentPlaceholder_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Share your story..."
        lbl_Nest.font = UIFont.systemFont(ofSize: 15)
        lbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest
        lbl_Nest.isUserInteractionEnabled = false
        return lbl_Nest
    }()

    private let divider2_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.divider_Nest
        return v_Nest
    }()

    // MARK: - UI 组件 - Media 分区

    private let mediaSectionLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        return lbl_Nest
    }()

    private let mediaSectionHint_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Tap to pick."
        lbl_Nest.font = UIFont.systemFont(ofSize: 12)
        lbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest
        return lbl_Nest
    }()

    private let mediaContainer_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor(hexstring_Nest: "#F7F8FF", alpha_Nest: 1)
        v_Nest.layer.cornerRadius = 18
        v_Nest.layer.borderWidth = 1.5
        v_Nest.layer.borderColor = ColorConfig_Nest.secondaryGradientStart_Nest.withAlphaComponent(0.22).cgColor
        v_Nest.isUserInteractionEnabled = true
        return v_Nest
    }()

    private let mediaDisplayView_Nest: MediaDisplayView_Nest = {
        let mv_Nest = MediaDisplayView_Nest()
        mv_Nest.layer.cornerRadius = 15
        mv_Nest.clipsToBounds = true
        mv_Nest.isHidden = true
        return mv_Nest
    }()

    /// 媒体图标背景圆 — 气泡式空态核心元素
    private let mediaIconBg_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.1)
        v_Nest.layer.cornerRadius = 32
        return v_Nest
    }()

    private let mediaPickIconView_Nest: UIImageView = {
        let iv_Nest = UIImageView()
        iv_Nest.image = UIImage(systemName: "photo.badge.plus")
        iv_Nest.tintColor = ColorConfig_Nest.primaryGradientStart_Nest
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    private let mediaPickLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Tap to add a photo or video"
        lbl_Nest.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        lbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        return lbl_Nest
    }()

    private let mediaSubtitleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Photos and videos welcome"
        lbl_Nest.font = UIFont.systemFont(ofSize: 11)
        lbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest
        lbl_Nest.textAlignment = .center
        return lbl_Nest
    }()

    private let mediaChipsStack_Nest: UIStackView = {
        let sv_Nest = UIStackView()
        sv_Nest.axis = .horizontal
        sv_Nest.spacing = 8
        sv_Nest.alignment = .center
        return sv_Nest
    }()

    private let mediaStatusBadge_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Empty"
        lbl_Nest.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lbl_Nest.textColor = ColorConfig_Nest.primaryGradientStart_Nest
        lbl_Nest.backgroundColor = UIColor(hexstring_Nest: "#FFFFFF", alpha_Nest: 0.92)
        lbl_Nest.layer.cornerRadius = 11
        lbl_Nest.layer.masksToBounds = true
        lbl_Nest.textAlignment = .center
        return lbl_Nest
    }()

    // MARK: - UI 组件 - 底部操作区

    private let publishNoteCard_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor(hexstring_Nest: "#EEF5FF", alpha_Nest: 1)
        v_Nest.layer.cornerRadius = 16
        v_Nest.layer.borderWidth = 1
        v_Nest.layer.borderColor = ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.18).cgColor
        v_Nest.clipsToBounds = true
        return v_Nest
    }()

    private let noteAccentBar_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.primaryGradientStart_Nest
        return v_Nest
    }()

    private let publishNoteIconView_Nest: UIImageView = {
        let iv_Nest = UIImageView()
        iv_Nest.image = UIImage(systemName: "checkmark.shield.fill")
        iv_Nest.tintColor = ColorConfig_Nest.primaryGradientStart_Nest
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    private let publishNoteLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Your post will appear right away after publishing."
        lbl_Nest.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        lbl_Nest.numberOfLines = 2
        return lbl_Nest
    }()

    private let publishBtn_Nest: UIButton = {
        let btn_Nest = UIButton(type: .custom)
        btn_Nest.setTitle("Publish", for: .normal)
        btn_Nest.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn_Nest.setTitleColor(.white, for: .normal)
        btn_Nest.layer.cornerRadius = 26
        btn_Nest.layer.shadowColor = ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.45).cgColor
        btn_Nest.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn_Nest.layer.shadowRadius = 12
        btn_Nest.layer.shadowOpacity = 1
        return btn_Nest
    }()

    private let eulaBtn_Nest: UIButton = {
        let btn_Nest = UIButton(type: .custom)
        let attr_Nest = NSAttributedString(
            string: "EULA",
            attributes: [
                .foregroundColor: ColorConfig_Nest.primaryGradientStart_Nest,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: UIFont.systemFont(ofSize: 13)
            ]
        )
        btn_Nest.setAttributedTitle(attr_Nest, for: .normal)
        return btn_Nest
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Nest()
        setupConstraints_Nest()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    /// 安全区域变化时动态更新头部徽章 top 偏移，确保内容始终低于状态栏，适配各机型刘海/灵动岛。
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        headerTitleTopConstraint_Nest?.update(offset: view.safeAreaInsets.top + 16)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Nest?.frame = headerView_Nest.bounds
        publishBtnGradient_Nest?.frame = publishBtn_Nest.bounds
    }

    // MARK: - UI 构建

    /// 构建发布页所有 UI 元素并配置默认状态。
    /// 返回值：无。
    private func setupUI_Nest() {
        view.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        view.addSubview(scrollView_Nest)
        scrollView_Nest.addSubview(contentView_Nest)

        // 渐变头部
        let gradient_Nest = UIColor.createPrimaryGradientLayer_Nest(frame_Nest: .zero)
        headerView_Nest.layer.insertSublayer(gradient_Nest, at: 0)
        headerGradient_Nest = gradient_Nest
        headerView_Nest.addSubview(decorCircle1_Nest)
        headerView_Nest.addSubview(decorCircle2_Nest)
        headerView_Nest.addSubview(decorCircle3_Nest)
        // 右侧装饰大图标（最底层，放在 decorCircle 之后、内容之前）
        headerView_Nest.addSubview(headerHeroIcon_Nest)
        // 小徽章：先添加内部子视图再加到父视图
        headerTopBadge_Nest.addSubview(headerBadgeIcon_Nest)
        headerTopBadge_Nest.addSubview(headerBadgeLabel_Nest)
        headerView_Nest.addSubview(headerTopBadge_Nest)
        headerView_Nest.addSubview(headerTitle_Nest)
        headerView_Nest.addSubview(headerSubtitle_Nest)
        [
            makeStepPill_Nest(icon: "pencil", text: "1. Title"),
            makeStepPill_Nest(icon: "photo", text: "2. Media"),
            makeStepPill_Nest(icon: "paperplane.fill", text: "3. Publish")
        ].forEach { stepPillsStack_Nest.addArrangedSubview($0) }
        headerView_Nest.addSubview(stepPillsStack_Nest)
        contentView_Nest.addSubview(headerView_Nest)

        // 分区标题加彩色图标（AttributedString 方式，无额外视图）
        titleSectionLabel_Nest.attributedText = makeSectionAttrText_Nest(
            iconName: "pencil.circle.fill",
            iconColor: ColorConfig_Nest.primaryGradientStart_Nest,
            text: "Title"
        )
        contentSectionLabel_Nest.attributedText = makeSectionAttrText_Nest(
            iconName: "text.bubble.fill",
            iconColor: ColorConfig_Nest.primaryGradientEnd_Nest,
            text: "Caption"
        )
        mediaSectionLabel_Nest.attributedText = makeSectionAttrText_Nest(
            iconName: "photo.fill",
            iconColor: ColorConfig_Nest.secondaryGradientStart_Nest,
            text: "Media"
        )

        // 标题输入框左侧图标
        let tfIconContainer_Nest = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 50))
        let pencilIV_Nest = UIImageView()
        pencilIV_Nest.image = UIImage(systemName: "pencil")
        pencilIV_Nest.tintColor = ColorConfig_Nest.primaryGradientStart_Nest
        pencilIV_Nest.contentMode = .scaleAspectFit
        pencilIV_Nest.frame = CGRect(x: 12, y: 15, width: 18, height: 18)
        tfIconContainer_Nest.addSubview(pencilIV_Nest)
        titleField_Nest.leftView = tfIconContainer_Nest
        titleField_Nest.leftViewMode = .always

        // 表单卡片
        formCard_Nest.addSubview(formHandle_Nest)
        tipsCard_Nest.addSubview(tipsAccentBar_Nest)
        tipsCard_Nest.addSubview(tipsIconView_Nest)
        tipsCard_Nest.addSubview(tipsTitleLabel_Nest)
        tipsCard_Nest.addSubview(tipsSubtitleLabel_Nest)
        formCard_Nest.addSubview(tipsCard_Nest)
        formCard_Nest.addSubview(titleSectionLabel_Nest)
        formCard_Nest.addSubview(titleHintLabel_Nest)
        formCard_Nest.addSubview(titleField_Nest)
        formCard_Nest.addSubview(divider1_Nest)
        formCard_Nest.addSubview(contentSectionLabel_Nest)
        formCard_Nest.addSubview(contentCountLabel_Nest)
        contentTextView_Nest.addSubview(contentPlaceholder_Nest)
        contentTextView_Nest.delegate = self
        formCard_Nest.addSubview(contentTextView_Nest)
        formCard_Nest.addSubview(divider2_Nest)
        formCard_Nest.addSubview(mediaSectionLabel_Nest)
        formCard_Nest.addSubview(mediaSectionHint_Nest)

        // 媒体选取区域
        mediaContainer_Nest.addSubview(mediaIconBg_Nest)
        mediaContainer_Nest.addSubview(mediaPickIconView_Nest)
        mediaContainer_Nest.addSubview(mediaPickLabel_Nest)
        mediaContainer_Nest.addSubview(mediaSubtitleLabel_Nest)
        mediaChipsStack_Nest.addArrangedSubview(
            makeMediaChip_Nest(text: "JPG · PNG", icon: "photo", color: ColorConfig_Nest.primaryGradientStart_Nest)
        )
        mediaChipsStack_Nest.addArrangedSubview(
            makeMediaChip_Nest(text: "MP4 · MOV", icon: "video", color: ColorConfig_Nest.secondaryGradientStart_Nest)
        )
        mediaContainer_Nest.addSubview(mediaChipsStack_Nest)
        mediaContainer_Nest.addSubview(mediaDisplayView_Nest)
        mediaContainer_Nest.addSubview(mediaStatusBadge_Nest)
        mediaContainer_Nest.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onMediaTapped_Nest))
        )
        formCard_Nest.addSubview(mediaContainer_Nest)
        contentView_Nest.addSubview(formCard_Nest)

        titleField_Nest.delegate = self

        // 发布按钮渐变 + 右侧图标
        let btnGrad_Nest = UIColor.createPrimaryGradientLayer_Nest(frame_Nest: .zero)
        btnGrad_Nest.cornerRadius = 26
        publishBtn_Nest.layer.insertSublayer(btnGrad_Nest, at: 0)
        publishBtnGradient_Nest = btnGrad_Nest
        publishBtn_Nest.addTarget(self, action: #selector(onPublishTapped_Nest), for: .touchUpInside)
        let btnArrow_Nest = UIImageView(image: UIImage(systemName: "paperplane.fill"))
        btnArrow_Nest.tintColor = UIColor.white.withAlphaComponent(0.9)
        btnArrow_Nest.contentMode = .scaleAspectFit
        publishBtn_Nest.addSubview(btnArrow_Nest)
        btnArrow_Nest.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }

        publishNoteCard_Nest.addSubview(noteAccentBar_Nest)
        publishNoteCard_Nest.addSubview(publishNoteIconView_Nest)
        publishNoteCard_Nest.addSubview(publishNoteLabel_Nest)
        contentView_Nest.addSubview(publishNoteCard_Nest)
        contentView_Nest.addSubview(publishBtn_Nest)
        eulaBtn_Nest.addTarget(self, action: #selector(onEulaTapped_Nest), for: .touchUpInside)
        contentView_Nest.addSubview(eulaBtn_Nest)

        updateContentCount_Nest()
    }

    /// 配置发布页所有 SnapKit 约束。
    /// 返回值：无。
    private func setupConstraints_Nest() {
        scrollView_Nest.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Nest.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        // 头部（高度放大以容纳徽章行）
        headerView_Nest.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(234)
        }
        decorCircle1_Nest.snp.makeConstraints { make in
            make.width.height.equalTo(140)
            make.top.equalToSuperview().offset(-18)
            make.trailing.equalToSuperview().offset(32)
        }
        decorCircle2_Nest.snp.makeConstraints { make in
            make.width.height.equalTo(92)
            make.top.equalToSuperview().offset(106)
            make.trailing.equalToSuperview().offset(-28)
        }
        decorCircle3_Nest.snp.makeConstraints { make in
            make.width.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-10)
            make.leading.equalToSuperview().offset(24)
        }
        // 右侧漂浮大图标（垂直居中偏上）
        headerHeroIcon_Nest.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview().offset(-10)
            make.width.height.equalTo(114)
        }
        // 小徽章：动态 top constraint 挂在此处，适配灵动岛/刘海各机型
        headerTopBadge_Nest.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            headerTitleTopConstraint_Nest = make.top.equalToSuperview().offset(54).constraint
        }
        headerBadgeIcon_Nest.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        headerBadgeLabel_Nest.snp.makeConstraints { make in
            make.leading.equalTo(headerBadgeIcon_Nest.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(7)
            make.bottom.equalToSuperview().offset(-7)
        }
        // 标题相对徽章定位，随整体内容滚动
        headerTitle_Nest.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(headerTopBadge_Nest.snp.bottom).offset(10)
        }
        headerSubtitle_Nest.snp.makeConstraints { make in
            make.top.equalTo(headerTitle_Nest.snp.bottom).offset(8)
            make.leading.equalTo(headerTitle_Nest)
            make.trailing.equalToSuperview().offset(-130)
        }
        stepPillsStack_Nest.snp.makeConstraints { make in
            make.top.equalTo(headerSubtitle_Nest.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(20)
        }

        // 表单卡片（全宽，仅上圆角）
        formCard_Nest.snp.makeConstraints { make in
            make.top.equalTo(headerView_Nest.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        formHandle_Nest.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(44)
            make.height.equalTo(5)
        }

        // Tips 卡片
        tipsCard_Nest.snp.makeConstraints { make in
            make.top.equalTo(formHandle_Nest.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(54)
        }
        tipsAccentBar_Nest.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(4)
        }
        tipsIconView_Nest.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        tipsTitleLabel_Nest.snp.makeConstraints { make in
            make.leading.equalTo(tipsIconView_Nest.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(10)
        }
        tipsSubtitleLabel_Nest.snp.makeConstraints { make in
            make.top.equalTo(tipsTitleLabel_Nest.snp.bottom).offset(2)
            make.leading.equalTo(tipsTitleLabel_Nest)
            make.trailing.equalToSuperview().offset(-14)
        }

        // Title 分区
        titleSectionLabel_Nest.snp.makeConstraints { make in
            make.top.equalTo(tipsCard_Nest.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
        }
        titleHintLabel_Nest.snp.makeConstraints { make in
            make.centerY.equalTo(titleSectionLabel_Nest)
            make.trailing.equalToSuperview().offset(-16)
        }
        titleField_Nest.snp.makeConstraints { make in
            make.top.equalTo(titleSectionLabel_Nest.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(50)
        }
        divider1_Nest.snp.makeConstraints { make in
            make.top.equalTo(titleField_Nest.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(1)
        }

        // Caption 分区
        contentSectionLabel_Nest.snp.makeConstraints { make in
            make.top.equalTo(divider1_Nest.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        contentCountLabel_Nest.snp.makeConstraints { make in
            make.centerY.equalTo(contentSectionLabel_Nest)
            make.trailing.equalToSuperview().offset(-16)
        }
        contentTextView_Nest.snp.makeConstraints { make in
            make.top.equalTo(contentSectionLabel_Nest.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(136)
        }
        contentPlaceholder_Nest.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(14)
        }
        divider2_Nest.snp.makeConstraints { make in
            make.top.equalTo(contentTextView_Nest.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(1)
        }

        // Media 分区
        mediaSectionLabel_Nest.snp.makeConstraints { make in
            make.top.equalTo(divider2_Nest.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        mediaSectionHint_Nest.snp.makeConstraints { make in
            make.centerY.equalTo(mediaSectionLabel_Nest)
            make.trailing.equalToSuperview().offset(-16)
        }
        mediaContainer_Nest.snp.makeConstraints { make in
            make.top.equalTo(mediaSectionLabel_Nest.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(196)
            make.bottom.equalToSuperview().offset(-24)
        }
        // 媒体图标背景圆
        mediaIconBg_Nest.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-30)
            make.width.height.equalTo(64)
        }
        mediaPickIconView_Nest.snp.makeConstraints { make in
            make.center.equalTo(mediaIconBg_Nest)
            make.width.height.equalTo(28)
        }
        mediaPickLabel_Nest.snp.makeConstraints { make in
            make.top.equalTo(mediaIconBg_Nest.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        mediaSubtitleLabel_Nest.snp.makeConstraints { make in
            make.top.equalTo(mediaPickLabel_Nest.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        mediaChipsStack_Nest.snp.makeConstraints { make in
            make.top.equalTo(mediaSubtitleLabel_Nest.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        mediaDisplayView_Nest.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        mediaStatusBadge_Nest.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.width.greaterThanOrEqualTo(62)
            make.height.equalTo(22)
        }

        // 底部区域
        publishNoteCard_Nest.snp.makeConstraints { make in
            make.top.equalTo(formCard_Nest.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(52)
        }
        noteAccentBar_Nest.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(4)
        }
        publishNoteIconView_Nest.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        publishNoteLabel_Nest.snp.makeConstraints { make in
            make.leading.equalTo(publishNoteIconView_Nest.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-14)
        }
        publishBtn_Nest.snp.makeConstraints { make in
            make.top.equalTo(publishNoteCard_Nest.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(54)
        }
        eulaBtn_Nest.snp.makeConstraints { make in
            make.top.equalTo(publishBtn_Nest.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - UI 工厂方法

    /// 创建带彩色 SF 图标的分区标题 AttributedString。
    /// - Parameters:
    ///   - iconName: SF Symbol 名称。
    ///   - iconColor: 图标渲染颜色。
    ///   - text: 标题文案。
    /// - Returns: 图标 + 文字的 NSAttributedString。
    private func makeSectionAttrText_Nest(
        iconName: String,
        iconColor: UIColor,
        text: String
    ) -> NSAttributedString {
        let attachment_Nest = NSTextAttachment()
        let config_Nest = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        if let img_Nest = UIImage(systemName: iconName, withConfiguration: config_Nest)?
            .withTintColor(iconColor, renderingMode: .alwaysOriginal) {
            attachment_Nest.image = img_Nest
            attachment_Nest.bounds = CGRect(x: 0, y: -2.5, width: 16, height: 16)
        }
        let result_Nest = NSMutableAttributedString(attachment: attachment_Nest)
        result_Nest.append(NSAttributedString(
            string: "  \(text)",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                .foregroundColor: ColorConfig_Nest.textPrimary_Nest
            ]
        ))
        return result_Nest
    }

    /// 创建步骤引导 Pill 标签，用于紧凑展示发布三步骤。
    /// - Parameters:
    ///   - icon: SF Symbol 图标名。
    ///   - text: 步骤文案。
    /// - Returns: 配置完成的 UIView pill。
    private func makeStepPill_Nest(icon: String, text: String) -> UIView {
        let pill_Nest = UIView()
        pill_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        pill_Nest.layer.cornerRadius = 14
        pill_Nest.layer.borderWidth = 1
        pill_Nest.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor

        let iconView_Nest = UIImageView(image: UIImage(systemName: icon))
        iconView_Nest.tintColor = .white
        iconView_Nest.contentMode = .scaleAspectFit

        let label_Nest = UILabel()
        label_Nest.text = text
        label_Nest.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label_Nest.textColor = .white

        pill_Nest.addSubview(iconView_Nest)
        pill_Nest.addSubview(label_Nest)

        iconView_Nest.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(13)
        }
        label_Nest.snp.makeConstraints { make in
            make.leading.equalTo(iconView_Nest.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(7)
            make.bottom.equalToSuperview().offset(-7)
        }

        return pill_Nest
    }

    /// 创建媒体类型 Chip 标签，展示在媒体区底部。
    /// - Parameters:
    ///   - text: 格式文案（如 "JPG · PNG"）。
    ///   - icon: SF Symbol 图标名。
    ///   - color: 主题色。
    /// - Returns: 配置完成的 UIView chip。
    private func makeMediaChip_Nest(text: String, icon: String, color: UIColor) -> UIView {
        let chip_Nest = UIView()
        chip_Nest.backgroundColor = color.withAlphaComponent(0.1)
        chip_Nest.layer.cornerRadius = 12
        chip_Nest.layer.borderWidth = 1
        chip_Nest.layer.borderColor = color.withAlphaComponent(0.2).cgColor

        let iv_Nest = UIImageView(image: UIImage(systemName: icon))
        iv_Nest.tintColor = color
        iv_Nest.contentMode = .scaleAspectFit

        let lbl_Nest = UILabel()
        lbl_Nest.text = text
        lbl_Nest.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl_Nest.textColor = color

        chip_Nest.addSubview(iv_Nest)
        chip_Nest.addSubview(lbl_Nest)

        iv_Nest.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        lbl_Nest.snp.makeConstraints { make in
            make.leading.equalTo(iv_Nest.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-6)
        }

        return chip_Nest
    }

    // MARK: - 事件处理

    /// 打开媒体选择器并根据选择结果刷新预览状态。
    /// 返回值：无。
    @objc private func onMediaTapped_Nest() {
        MediaPickerHelper_Nest.pickMedia_Nest(from: self) { [weak self] result_Nest in
            guard let self else { return }
            switch result_Nest {
            case .photo_Nest(let image_Nest):
                self.isMediaVideo_Nest = false
                // 将图片保存到文档目录并记录路径
                if let data_Nest = image_Nest.jpegData(compressionQuality: 0.8) {
                    let fileName_Nest = "post_media_\(Int(Date().timeIntervalSince1970)).jpg"
                    let url_Nest = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        .appendingPathComponent(fileName_Nest)
                    try? data_Nest.write(to: url_Nest)
                    self.selectedMediaPath_Nest = fileName_Nest
                }
                self.mediaDisplayView_Nest.configureWithImage_Nest(image_Nest: image_Nest)
                self.showMediaPreview_Nest()

            case .video_Nest(let url_Nest):
                self.isMediaVideo_Nest = true
                self.selectedMediaPath_Nest = url_Nest.lastPathComponent
                self.mediaDisplayView_Nest.configure_Nest(mediaPath_Nest: url_Nest.path, isVideo_Nest: true)
                self.showMediaPreview_Nest()

            case .cancelled_Nest:
                break
            }
        }
    }

    /// 切换媒体区域为预览状态，隐藏空态元素并更新类型标签。
    /// 返回值：无。
    private func showMediaPreview_Nest() {
        mediaIconBg_Nest.isHidden = true
        mediaPickIconView_Nest.isHidden = true
        mediaPickLabel_Nest.isHidden = true
        mediaSubtitleLabel_Nest.isHidden = true
        mediaChipsStack_Nest.isHidden = true
        mediaDisplayView_Nest.isHidden = false
        mediaStatusBadge_Nest.text = isMediaVideo_Nest ? "Video" : "Photo"
        UIView.animate(withDuration: AnimationConfig_Nest.durationFast_Nest) {
            self.mediaContainer_Nest.layer.borderColor = ColorConfig_Nest.primaryGradientStart_Nest.cgColor
        }
    }

    /// 执行发布前校验并提交帖子。
    /// 返回值：无。
    @objc private func onPublishTapped_Nest() {
        guard UserViewModel_Nest.shared_Nest.isLoggedIn_Nest else {
            Navigation_Nest.toLogin_Nest(style_nest: .present_nest)
            return
        }
        let title_Nest = (titleField_Nest.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title_Nest.isEmpty else {
            Utils_Nest.showWarning_Nest(message_Nest: "Title cannot be empty")
            return
        }
        let content_Nest = (contentTextView_Nest.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content_Nest.isEmpty else {
            Utils_Nest.showWarning_Nest(message_Nest: "Content cannot be empty")
            return
        }
        guard let mediaPath_Nest = selectedMediaPath_Nest else {
            Utils_Nest.showWarning_Nest(message_Nest: "Please add a photo or video")
            return
        }
        TitleViewModel_Nest.shared_Nest.releasePost_Nest(
            title_nest: title_Nest,
            content_nest: content_Nest,
            media_nest: mediaPath_Nest,
            type_nest: isMediaVideo_Nest ? 1 : 0
        )
        clearForm_Nest()
        Navigation_Nest.dismiss_Nest(from: self)
    }

    /// 展示 EULA 协议弹层。
    /// 返回值：无。
    @objc private func onEulaTapped_Nest() {
        ProtocolHelper_Nest.showProtocol_Nest(
            type_Nest: .eula_Nest,
            content_Nest: "eula.png",
            from: self
        )
    }

    /// 清空所有输入并恢复默认展示状态。
    /// 返回值：无。
    private func clearForm_Nest() {
        titleField_Nest.text = nil
        contentTextView_Nest.text = nil
        contentPlaceholder_Nest.isHidden = false
        selectedMediaPath_Nest = nil
        isMediaVideo_Nest = false
        mediaIconBg_Nest.isHidden = false
        mediaPickIconView_Nest.isHidden = false
        mediaPickLabel_Nest.isHidden = false
        mediaSubtitleLabel_Nest.isHidden = false
        mediaChipsStack_Nest.isHidden = false
        mediaDisplayView_Nest.isHidden = true
        mediaStatusBadge_Nest.text = "Empty"
        mediaContainer_Nest.layer.borderColor = ColorConfig_Nest.secondaryGradientStart_Nest.withAlphaComponent(0.22).cgColor
        updateContentCount_Nest()
    }

    /// 更新正文输入字数提示，超过 200 字时切换为警示色。
    /// 返回值：无。
    private func updateContentCount_Nest() {
        let count_Nest = contentTextView_Nest.text.count
        contentCountLabel_Nest.text = "\(count_Nest)/240"
        contentCountLabel_Nest.textColor = count_Nest > 200
            ? ColorConfig_Nest.secondaryGradientStart_Nest
            : ColorConfig_Nest.textPlaceholder_Nest
    }
}

// MARK: - UITextViewDelegate

extension Release_Nest: UITextViewDelegate {

    /// 文本变化时更新占位提示与字数显示。
    /// - Parameter textView: 当前输入的文本视图。
    /// 返回值：无。
    func textViewDidChange(_ textView: UITextView) {
        contentPlaceholder_Nest.isHidden = !textView.text.isEmpty
        updateContentCount_Nest()
    }
}

// MARK: - UITextFieldDelegate

extension Release_Nest: UITextFieldDelegate {

    /// 点击键盘返回后切换到正文输入区域。
    /// - Parameter textField: 当前标题输入框。
    /// - Returns: 是否允许执行默认返回行为。
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentTextView_Nest.becomeFirstResponder()
        return true
    }
}
