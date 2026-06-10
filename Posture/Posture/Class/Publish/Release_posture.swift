
import Foundation
import UIKit
import SnapKit

// MARK: 发布页面

/// 发布页面控制器
/// 核心作用：创建包含媒体、标题、内容的社区帖子。
/// 设计思路：UI 层拆分为顶部头图（紧凑横排）、媒体卡（01）、标题卡（02）、内容卡（03）和发布操作区。
///          顺序调整为媒体优先，以引导用户先添加图片/视频再填写文字内容。
/// 关键属性：`titleField_Posture`、`contentTextView_Posture`、`mediaPath_Posture` 保存表单数据。
/// 关键方法：`handlePublish_Posture()` 校验并发布，`clearForm_Posture()` 清理页面。
@MainActor
class Release_Posture: UIViewController {

    // MARK: - 表单输入属性

    /// 标题输入框
    private let titleField_Posture = UITextField()

    /// 内容输入框
    private let contentTextView_Posture = UITextView()

    /// 媒体预览视图
    private let mediaView_Posture = MediaDisplayView_Posture()

    /// 媒体占位视图（未选择时显示，选择后隐藏）
    private let mediaPlaceholder_Posture = UIView()

    /// 字数统计标签
    private let charCountLabel_Posture = UILabel()

    /// 已选择媒体路径
    private var mediaPath_Posture: String?

    /// 是否已选媒体
    private var hasMedia_Posture: Bool = false

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Posture()
        setupKeyboardObservers_Posture()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    /// 搭建发布页主体 UI
    /// 区块顺序：顶部头图 → 媒体(01) → 标题(02) → 内容(03) → 发布操作区
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupUI_Posture() {
        view.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture

        // 背景装饰光晕
        let glow1_Posture = makeGlowBlob_Posture(
            color: ColorConfig_Posture.primaryGradientStart_Posture.withAlphaComponent(0.2),
            size: 200
        )
        let glow2_Posture = makeGlowBlob_Posture(
            color: ColorConfig_Posture.secondaryGradientStart_Posture.withAlphaComponent(0.14),
            size: 160
        )
        view.addSubview(glow1_Posture)
        view.addSubview(glow2_Posture)
        glow1_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-50)
            make.trailing.equalToSuperview().offset(60)
            make.width.height.equalTo(200)
        }
        glow2_Posture.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(40)
            make.leading.equalToSuperview().offset(-50)
            make.width.height.equalTo(160)
        }

        // 滚动容器
        let scrollView_Posture = UIScrollView()
        scrollView_Posture.showsVerticalScrollIndicator = false
        scrollView_Posture.keyboardDismissMode = .interactive
        // 禁止自动添加安全区 inset，避免头图卡片与屏幕顶部出现间隙
        scrollView_Posture.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_Posture)

        let contentView_Posture = UIView()
        scrollView_Posture.addSubview(contentView_Posture)

        scrollView_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Posture.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Posture.contentLayoutGuide)
            make.width.equalTo(scrollView_Posture.frameLayoutGuide)
        }

        // 各区块（媒体移至最前）
        let headerCard_Posture   = buildHeaderCard_Posture()
        let mediaCard_Posture    = buildMediaCard_Posture()
        let titleCard_Posture    = buildTitleCard_Posture()
        let contentCard_Posture  = buildContentCard_Posture()
        let publishSection_Posture = buildPublishSection_Posture()

        [headerCard_Posture, mediaCard_Posture, titleCard_Posture,
         contentCard_Posture, publishSection_Posture].forEach { contentView_Posture.addSubview($0) }

        let sideInset_Posture = 18

        headerCard_Posture.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        mediaCard_Posture.snp.makeConstraints { make in
            make.top.equalTo(headerCard_Posture.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(sideInset_Posture)
        }
        titleCard_Posture.snp.makeConstraints { make in
            make.top.equalTo(mediaCard_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(sideInset_Posture)
        }
        contentCard_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleCard_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(sideInset_Posture)
        }
        publishSection_Posture.snp.makeConstraints { make in
            make.top.equalTo(contentCard_Posture.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(sideInset_Posture)
            make.bottom.equalToSuperview().offset(-38)
        }
    }

    // MARK: - 区块构建

    /// 构建顶部灵感头图卡片（紧凑布局：图标与标题横排，减少垂直高度）
    /// - Parameters: 无
    /// - Returns: UIView - 渐变头图卡片
    /// - Throws: 无
    private func buildHeaderCard_Posture() -> UIView {
        let container_Posture = UIView()
        container_Posture.clipsToBounds = false

        let gradientCard_Posture = UIView()
        gradientCard_Posture.layer.cornerRadius = 36
        gradientCard_Posture.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gradientCard_Posture.clipsToBounds = true
        gradientCard_Posture.backgroundColor = ColorConfig_Posture.primaryGradientStart_Posture

        let gradientLayer_Posture = CAGradientLayer()
        gradientLayer_Posture.colors = [
            ColorConfig_Posture.primaryGradientStart_Posture.cgColor,
            ColorConfig_Posture.primaryGradientEnd_Posture.cgColor,
            UIColor(hexstring_Posture: "#667EEA").cgColor
        ]
        gradientLayer_Posture.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Posture.endPoint   = CGPoint(x: 1, y: 1)
        gradientCard_Posture.layer.insertSublayer(gradientLayer_Posture, at: 0)

        // 右侧大背景人形图标（装饰）
        let heroIcon_Posture = UIImageView(image: UIImage(systemName: "figure.strengthtraining.traditional"))
        heroIcon_Posture.tintColor = UIColor.white.withAlphaComponent(0.15)
        heroIcon_Posture.contentMode = .scaleAspectFit

        // 左侧小图标容器（与标题横排）
        let iconContainer_Posture = UIView()
        iconContainer_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        iconContainer_Posture.layer.cornerRadius = 16

        let iconView_Posture = UIImageView(image: UIImage(systemName: "square.and.pencil"))
        iconView_Posture.tintColor = .white
        iconView_Posture.contentMode = .scaleAspectFit
        iconContainer_Posture.addSubview(iconView_Posture)
        iconView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }

        // 标题（与图标同行，字体缩小以减少折行）
        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = "Share Your Posture Story"
        titleLabel_Posture.font = .systemFont(ofSize: 22, weight: .heavy)
        titleLabel_Posture.textColor = .white
        titleLabel_Posture.numberOfLines = 2

        // 副标题（单行）
        let subtitleLabel_Posture = UILabel()
        subtitleLabel_Posture.text = "A tiny win, a mindful break, or a new habit worth sharing."
        subtitleLabel_Posture.font = .systemFont(ofSize: 12, weight: .medium)
        subtitleLabel_Posture.textColor = UIColor.white.withAlphaComponent(0.82)
        subtitleLabel_Posture.numberOfLines = 2

        // 装饰胶囊行
        let chipStack_Posture = UIStackView()
        chipStack_Posture.axis = .horizontal
        chipStack_Posture.spacing = 8

        [("sparkles", "Inspire"), ("heart.fill", "Encourage"), ("bolt.fill", "Motivate")].forEach { item_Posture in
            chipStack_Posture.addArrangedSubview(makeHeaderInspireChip_Posture(icon: item_Posture.0, title: item_Posture.1))
        }

        gradientCard_Posture.addSubview(heroIcon_Posture)
        gradientCard_Posture.addSubview(iconContainer_Posture)
        gradientCard_Posture.addSubview(titleLabel_Posture)
        gradientCard_Posture.addSubview(subtitleLabel_Posture)
        gradientCard_Posture.addSubview(chipStack_Posture)

        let safeTop_Posture: CGFloat = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?.safeAreaInsets.top ?? 44

        heroIcon_Posture.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(safeTop_Posture + 8)
            make.width.height.equalTo(100)
        }
        // 小图标与标题横排：图标居中对齐标题
        iconContainer_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Posture + 14)
            make.leading.equalToSuperview().offset(24)
            make.width.height.equalTo(34)
        }
        titleLabel_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(iconContainer_Posture)
            make.leading.equalTo(iconContainer_Posture.snp.trailing).offset(10)
            make.trailing.equalTo(heroIcon_Posture.snp.leading).offset(-8)
        }
        subtitleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(iconContainer_Posture.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().inset(24)
        }
        chipStack_Posture.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Posture.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-18)
        }

        container_Posture.addSubview(gradientCard_Posture)
        gradientCard_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        DispatchQueue.main.async {
            gradientLayer_Posture.frame = gradientCard_Posture.bounds
        }

        return container_Posture
    }

    /// 构建媒体选择卡片（步骤01，移至最前以引导用户优先上传媒体）
    /// 设计：固定高度媒体区域容器（占位/预览共享），下方 Photo/Video 双按钮横排
    /// - Parameters: 无
    /// - Returns: UIView - 媒体卡片
    /// - Throws: 无
    private func buildMediaCard_Posture() -> UIView {
        let card_Posture = makeCard_Posture()

        let stepBadge_Posture    = makeStepBadge_Posture(text: "01")
        let cardTitle_Posture    = makeCardTitle_Posture(text: "Add Media")
        let subtitleLabel_Posture = makeCardSubtitle_Posture(text: "A photo or video brings your story to life.")

        // 固定高度媒体容器，占位与预览叠放，通过 isHidden 切换
        let mediaContainer_Posture = UIView()
        mediaContainer_Posture.layer.cornerRadius = 20
        mediaContainer_Posture.clipsToBounds = true

        // 占位视图
        mediaPlaceholder_Posture.backgroundColor = ColorConfig_Posture.primaryGradientStart_Posture.withAlphaComponent(0.06)
        mediaPlaceholder_Posture.layer.borderColor = ColorConfig_Posture.primaryGradientStart_Posture.withAlphaComponent(0.22).cgColor
        mediaPlaceholder_Posture.layer.borderWidth = 1.5
        mediaPlaceholder_Posture.layer.cornerRadius = 20

        let placeholderIcon_Posture = UIImageView(image: UIImage(systemName: "photo.badge.plus"))
        placeholderIcon_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture.withAlphaComponent(0.55)
        placeholderIcon_Posture.contentMode = .scaleAspectFit

        let placeholderHint_Posture = UILabel()
        placeholderHint_Posture.text = "Photo or video"
        placeholderHint_Posture.font = .systemFont(ofSize: 13, weight: .semibold)
        placeholderHint_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        placeholderHint_Posture.textAlignment = .center

        mediaPlaceholder_Posture.addSubview(placeholderIcon_Posture)
        mediaPlaceholder_Posture.addSubview(placeholderHint_Posture)
        placeholderIcon_Posture.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-12)
            make.width.height.equalTo(32)
        }
        placeholderHint_Posture.snp.makeConstraints { make in
            make.top.equalTo(placeholderIcon_Posture.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // 媒体预览（默认隐藏）
        mediaView_Posture.layer.cornerRadius = 20
        mediaView_Posture.clipsToBounds = true
        mediaView_Posture.isHidden = true

        mediaContainer_Posture.addSubview(mediaPlaceholder_Posture)
        mediaContainer_Posture.addSubview(mediaView_Posture)
        mediaPlaceholder_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }
        mediaView_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // Photo / Video 双按钮横排
        let photoBtn_Posture = makeMediaPickButton_Posture(icon: "photo.fill", title: "Photo", isPrimary: true)
        photoBtn_Posture.addAction(UIAction { [weak self] _ in self?.pickMedia_Posture() }, for: .touchUpInside)

        let videoBtn_Posture = makeMediaPickButton_Posture(icon: "video.fill", title: "Video", isPrimary: false)
        videoBtn_Posture.addAction(UIAction { [weak self] _ in self?.pickMedia_Posture() }, for: .touchUpInside)

        let btnStack_Posture = UIStackView(arrangedSubviews: [photoBtn_Posture, videoBtn_Posture])
        btnStack_Posture.axis = .horizontal
        btnStack_Posture.spacing = 12
        btnStack_Posture.distribution = .fillEqually

        // 支持格式提示
        let formatLabel_Posture = UILabel()
        formatLabel_Posture.text = "JPG · PNG · MP4 · MOV"
        formatLabel_Posture.font = .systemFont(ofSize: 11, weight: .semibold)
        formatLabel_Posture.textColor = ColorConfig_Posture.textPlaceholder_Posture
        formatLabel_Posture.textAlignment = .center

        card_Posture.addSubview(stepBadge_Posture)
        card_Posture.addSubview(cardTitle_Posture)
        card_Posture.addSubview(subtitleLabel_Posture)
        card_Posture.addSubview(mediaContainer_Posture)
        card_Posture.addSubview(btnStack_Posture)
        card_Posture.addSubview(formatLabel_Posture)

        stepBadge_Posture.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(32)
        }
        cardTitle_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(stepBadge_Posture)
            make.leading.equalTo(stepBadge_Posture.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(20)
        }
        subtitleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(stepBadge_Posture.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        // 媒体区域固定高度（占位和预览共用此容器）
        mediaContainer_Posture.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(140)
        }
        btnStack_Posture.snp.makeConstraints { make in
            make.top.equalTo(mediaContainer_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(46)
        }
        formatLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(btnStack_Posture.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(18)
        }

        return card_Posture
    }

    /// 构建标题输入卡片（步骤02，带彩色左竖条 + 图标 + 建议提示行）
    /// - Parameters: 无
    /// - Returns: UIView - 标题输入卡片
    /// - Throws: 无
    private func buildTitleCard_Posture() -> UIView {
        let card_Posture = makeCard_Posture()

        let stepBadge_Posture = makeStepBadge_Posture(text: "02")
        let cardTitle_Posture = makeCardTitle_Posture(text: "Title")

        // 输入框容器（灰底 + 左侧彩色竖条 + pencil 图标）
        let fieldContainer_Posture = UIView()
        fieldContainer_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        fieldContainer_Posture.layer.cornerRadius = 18

        let accentBar_Posture = UIView()
        accentBar_Posture.backgroundColor = ColorConfig_Posture.primaryGradientStart_Posture
        accentBar_Posture.layer.cornerRadius = 2

        let pencilIcon_Posture = UIImageView(image: UIImage(systemName: "pencil.circle.fill"))
        pencilIcon_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
        pencilIcon_Posture.contentMode = .scaleAspectFit

        configureTitleField_Posture()

        fieldContainer_Posture.addSubview(accentBar_Posture)
        fieldContainer_Posture.addSubview(pencilIcon_Posture)
        fieldContainer_Posture.addSubview(titleField_Posture)

        accentBar_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.equalTo(3)
            make.height.equalTo(26)
        }
        pencilIcon_Posture.snp.makeConstraints { make in
            make.leading.equalTo(accentBar_Posture.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }
        titleField_Posture.snp.makeConstraints { make in
            make.leading.equalTo(pencilIcon_Posture.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(14)
            make.top.bottom.equalToSuperview()
        }

        // 底部提示行（左：建议文案，右：字符建议）
        let hintRow_Posture = UIView()

        let sparkIcon_Posture = UIImageView(image: UIImage(systemName: "sparkles"))
        sparkIcon_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
        sparkIcon_Posture.contentMode = .scaleAspectFit

        let hintLabel_Posture = UILabel()
        hintLabel_Posture.text = "A specific title earns more views"
        hintLabel_Posture.font = .systemFont(ofSize: 11, weight: .medium)
        hintLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture

        let charHintLabel_Posture = UILabel()
        charHintLabel_Posture.text = "Aim for under 60 chars"
        charHintLabel_Posture.font = .systemFont(ofSize: 11, weight: .medium)
        charHintLabel_Posture.textColor = ColorConfig_Posture.textPlaceholder_Posture
        charHintLabel_Posture.textAlignment = .right

        hintRow_Posture.addSubview(sparkIcon_Posture)
        hintRow_Posture.addSubview(hintLabel_Posture)
        hintRow_Posture.addSubview(charHintLabel_Posture)

        sparkIcon_Posture.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        hintLabel_Posture.snp.makeConstraints { make in
            make.leading.equalTo(sparkIcon_Posture.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
        }
        charHintLabel_Posture.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
        }

        card_Posture.addSubview(stepBadge_Posture)
        card_Posture.addSubview(cardTitle_Posture)
        card_Posture.addSubview(fieldContainer_Posture)
        card_Posture.addSubview(hintRow_Posture)

        stepBadge_Posture.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(32)
        }
        cardTitle_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(stepBadge_Posture)
            make.leading.equalTo(stepBadge_Posture.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(20)
        }
        fieldContainer_Posture.snp.makeConstraints { make in
            make.top.equalTo(stepBadge_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }
        hintRow_Posture.snp.makeConstraints { make in
            make.top.equalTo(fieldContainer_Posture.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(18)
            make.height.equalTo(16)
        }

        return card_Posture
    }

    /// 构建内容输入卡片（步骤03，含快速话题标签行 + 自定义 placeholder + 字数统计浮层）
    /// - Parameters: 无
    /// - Returns: UIView - 内容输入卡片
    /// - Throws: 无
    private func buildContentCard_Posture() -> UIView {
        let card_Posture = makeCard_Posture()

        let stepBadge_Posture    = makeStepBadge_Posture(text: "03")
        let cardTitle_Posture    = makeCardTitle_Posture(text: "Content")
        let subtitleLabel_Posture = makeCardSubtitle_Posture(text: "Share your posture habit or story in a few lines.")

        // 快速话题标签横行（点击自动插入 #话题）
        let tagScrollView_Posture = UIScrollView()
        tagScrollView_Posture.showsHorizontalScrollIndicator = false
        tagScrollView_Posture.alwaysBounceHorizontal = true

        let tagStack_Posture = UIStackView()
        tagStack_Posture.axis = .horizontal
        tagStack_Posture.spacing = 8

        [("🧘", "Stretch"), ("💺", "Desk"), ("🎯", "Habit"), ("🦴", "Back"), ("💆", "Neck")].forEach { item_Posture in
            tagStack_Posture.addArrangedSubview(makeTopicTag_Posture(emoji: item_Posture.0, text: item_Posture.1))
        }

        tagScrollView_Posture.addSubview(tagStack_Posture)
        tagStack_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        // 文本框容器（含模拟 placeholder 和右下角字数统计）
        let textContainer_Posture = UIView()
        textContainer_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        textContainer_Posture.layer.cornerRadius = 18

        // 模拟 placeholder（tag 9001 用于 delegate 查找）
        let placeholderLabel_Posture = UILabel()
        placeholderLabel_Posture.text = "e.g. I set a 2-min shoulder roll break every hour..."
        placeholderLabel_Posture.font = .systemFont(ofSize: 14, weight: .regular)
        placeholderLabel_Posture.textColor = ColorConfig_Posture.textPlaceholder_Posture
        placeholderLabel_Posture.numberOfLines = 2
        placeholderLabel_Posture.tag = 9001

        // 内容输入框
        contentTextView_Posture.font = .systemFont(ofSize: 14, weight: .regular)
        contentTextView_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        contentTextView_Posture.backgroundColor = .clear
        // 底部留空给字数统计
        contentTextView_Posture.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 34, right: 12)
        contentTextView_Posture.delegate = self

        // 字数统计（右下角浮层）
        charCountLabel_Posture.text = "0 / 280"
        charCountLabel_Posture.font = .systemFont(ofSize: 11, weight: .bold)
        charCountLabel_Posture.textColor = ColorConfig_Posture.textPlaceholder_Posture
        charCountLabel_Posture.textAlignment = .right

        textContainer_Posture.addSubview(contentTextView_Posture)
        textContainer_Posture.addSubview(placeholderLabel_Posture)
        textContainer_Posture.addSubview(charCountLabel_Posture)

        contentTextView_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(130)
        }
        placeholderLabel_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
        }
        charCountLabel_Posture.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(12)
        }

        card_Posture.addSubview(stepBadge_Posture)
        card_Posture.addSubview(cardTitle_Posture)
        card_Posture.addSubview(subtitleLabel_Posture)
        card_Posture.addSubview(tagScrollView_Posture)
        card_Posture.addSubview(textContainer_Posture)

        stepBadge_Posture.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(32)
        }
        cardTitle_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(stepBadge_Posture)
            make.leading.equalTo(stepBadge_Posture.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(20)
        }
        subtitleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(stepBadge_Posture.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        tagScrollView_Posture.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Posture.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(30)
        }
        textContainer_Posture.snp.makeConstraints { make in
            make.top.equalTo(tagScrollView_Posture.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(18)
        }

        return card_Posture
    }

    /// 构建发布操作区（渐变发布按钮 + EULA 链接）
    /// - Parameters: 无
    /// - Returns: UIView - 发布操作区
    /// - Throws: 无
    private func buildPublishSection_Posture() -> UIView {
        let container_Posture = UIView()

        let btnContainer_Posture = UIView()
        btnContainer_Posture.layer.cornerRadius = 28
        btnContainer_Posture.clipsToBounds = true
        btnContainer_Posture.layer.shadowColor = ColorConfig_Posture.primaryGradientStart_Posture.cgColor
        btnContainer_Posture.layer.shadowOpacity = 0.45
        btnContainer_Posture.layer.shadowRadius = 18
        btnContainer_Posture.layer.shadowOffset = CGSize(width: 0, height: 10)

        let publishGradient_Posture = CAGradientLayer()
        publishGradient_Posture.colors = [
            ColorConfig_Posture.primaryGradientStart_Posture.cgColor,
            UIColor(hexstring_Posture: "#667EEA").cgColor
        ]
        publishGradient_Posture.startPoint = CGPoint(x: 0, y: 0)
        publishGradient_Posture.endPoint   = CGPoint(x: 1, y: 0)
        btnContainer_Posture.layer.insertSublayer(publishGradient_Posture, at: 0)

        let publishButton_Posture = UIButton(type: .system)
        publishButton_Posture.setTitle("Publish Story", for: .normal)
        publishButton_Posture.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        publishButton_Posture.tintColor = .white
        publishButton_Posture.setTitleColor(.white, for: .normal)
        publishButton_Posture.titleLabel?.font = .systemFont(ofSize: 17, weight: .heavy)
        publishButton_Posture.backgroundColor = .clear
        publishButton_Posture.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        publishButton_Posture.addAction(UIAction { [weak self] _ in
            self?.animatePublishButton_Posture(button: publishButton_Posture) {
                self?.handlePublish_Posture()
            }
        }, for: .touchUpInside)

        btnContainer_Posture.addSubview(publishButton_Posture)
        publishButton_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }

        let eulaButton_Posture = UIButton(type: .system)
        let eulaAttr_Posture = NSAttributedString(string: "EULA", attributes: [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: ColorConfig_Posture.textPlaceholder_Posture
        ])
        let mutable_Posture = NSMutableAttributedString(attributedString: eulaAttr_Posture)
        let eulaRange_Posture = (eulaAttr_Posture.string as NSString).range(of: "EULA")
        mutable_Posture.addAttributes([
            .foregroundColor: ColorConfig_Posture.primaryGradientStart_Posture,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ], range: eulaRange_Posture)
        eulaButton_Posture.setAttributedTitle(mutable_Posture, for: .normal)
        eulaButton_Posture.addAction(UIAction { [weak self] _ in
            guard let self_Posture = self else { return }
            ProtocolHelper_Posture.showProtocol_Posture(type_Posture: .eula_Posture, content_Posture: "eula.png", from: self_Posture)
        }, for: .touchUpInside)

        container_Posture.addSubview(btnContainer_Posture)
        container_Posture.addSubview(eulaButton_Posture)

        btnContainer_Posture.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(58)
        }
        eulaButton_Posture.snp.makeConstraints { make in
            make.top.equalTo(btnContainer_Posture.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
        }

        DispatchQueue.main.async {
            publishGradient_Posture.frame = btnContainer_Posture.bounds
        }

        return container_Posture
    }

    // MARK: - UI 辅助元素

    /// 创建背景光晕圆
    /// - Parameters:
    ///   - color: 光晕颜色
    ///   - size: 圆的尺寸
    /// - Returns: UIView - 光晕视图
    /// - Throws: 无
    private func makeGlowBlob_Posture(color: UIColor, size: CGFloat) -> UIView {
        let view_Posture = UIView()
        view_Posture.backgroundColor = color
        view_Posture.layer.cornerRadius = size / 2
        view_Posture.isUserInteractionEnabled = false
        return view_Posture
    }

    /// 创建通用卡片容器
    /// - Parameters: 无
    /// - Returns: UIView - 白色圆角阴影卡片
    /// - Throws: 无
    private func makeCard_Posture() -> UIView {
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 28
        card_Posture.layer.shadowColor = ColorConfig_Posture.shadowColor_Posture.cgColor
        card_Posture.layer.shadowOpacity = 1
        card_Posture.layer.shadowRadius = 18
        card_Posture.layer.shadowOffset = CGSize(width: 0, height: 10)
        return card_Posture
    }

    /// 创建步骤序号徽章
    /// - Parameter text: 步骤文字（如 "01"）
    /// - Returns: UILabel - 已配置的徽章
    /// - Throws: 无
    private func makeStepBadge_Posture(text: String) -> UILabel {
        let label_Posture = UILabel()
        label_Posture.text = text
        label_Posture.font = .systemFont(ofSize: 12, weight: .heavy)
        label_Posture.textColor = ColorConfig_Posture.primaryGradientStart_Posture
        label_Posture.textAlignment = .center
        label_Posture.backgroundColor = ColorConfig_Posture.primaryGradientStart_Posture.withAlphaComponent(0.12)
        label_Posture.layer.cornerRadius = 16
        label_Posture.clipsToBounds = true
        return label_Posture
    }

    /// 创建卡片主标题标签
    /// - Parameter text: 标题文字
    /// - Returns: UILabel - 已配置的标题标签
    /// - Throws: 无
    private func makeCardTitle_Posture(text: String) -> UILabel {
        let label_Posture = UILabel()
        label_Posture.text = text
        label_Posture.font = .systemFont(ofSize: 18, weight: .heavy)
        label_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        return label_Posture
    }

    /// 创建卡片副标题标签
    /// - Parameter text: 副标题文字
    /// - Returns: UILabel - 已配置的副标题标签
    /// - Throws: 无
    private func makeCardSubtitle_Posture(text: String) -> UILabel {
        let label_Posture = UILabel()
        label_Posture.text = text
        label_Posture.font = .systemFont(ofSize: 13, weight: .medium)
        label_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        label_Posture.numberOfLines = 2
        return label_Posture
    }

    /// 创建头图区灵感胶囊
    /// - Parameters:
    ///   - icon: SF Symbols 图标名
    ///   - title: 胶囊文字
    /// - Returns: UIView - 灵感胶囊视图
    /// - Throws: 无
    private func makeHeaderInspireChip_Posture(icon: String, title: String) -> UIView {
        let container_Posture = UIView()
        container_Posture.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        container_Posture.layer.cornerRadius = 16

        let iconView_Posture = UIImageView(image: UIImage(systemName: icon))
        iconView_Posture.tintColor = .white
        iconView_Posture.contentMode = .scaleAspectFit

        let label_Posture = UILabel()
        label_Posture.text = title
        label_Posture.font = .systemFont(ofSize: 11, weight: .bold)
        label_Posture.textColor = .white

        container_Posture.addSubview(iconView_Posture)
        container_Posture.addSubview(label_Posture)

        iconView_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(13)
        }
        label_Posture.snp.makeConstraints { make in
            make.leading.equalTo(iconView_Posture.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        container_Posture.snp.makeConstraints { make in
            make.height.equalTo(30)
        }

        return container_Posture
    }

    /// 创建媒体选择按钮（Photo / Video）
    /// - Parameters:
    ///   - icon: SF Symbols 图标名
    ///   - title: 按钮文字
    ///   - isPrimary: true 为实色主按钮，false 为轻色次要按钮
    /// - Returns: UIButton - 已配置的媒体选择按钮
    /// - Throws: 无
    private func makeMediaPickButton_Posture(icon: String, title: String, isPrimary: Bool) -> UIButton {
        let btn_Posture = UIButton(type: .system)
        btn_Posture.setTitle(title, for: .normal)
        btn_Posture.setImage(UIImage(systemName: icon), for: .normal)
        btn_Posture.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        btn_Posture.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)

        if isPrimary {
            btn_Posture.tintColor = .white
            btn_Posture.setTitleColor(.white, for: .normal)
            btn_Posture.backgroundColor = ColorConfig_Posture.primaryGradientStart_Posture
        } else {
            btn_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
            btn_Posture.setTitleColor(ColorConfig_Posture.primaryGradientStart_Posture, for: .normal)
            btn_Posture.backgroundColor = ColorConfig_Posture.primaryGradientStart_Posture.withAlphaComponent(0.1)
        }

        btn_Posture.layer.cornerRadius = 20
        return btn_Posture
    }

    /// 创建快速话题标签按钮（点击后将 #话题 插入内容输入框）
    /// - Parameters:
    ///   - emoji: 表情前缀
    ///   - text: 话题文字（不含 #）
    /// - Returns: UIButton - 话题标签按钮
    /// - Throws: 无
    private func makeTopicTag_Posture(emoji: String, text: String) -> UIButton {
        let btn_Posture = UIButton(type: .custom)
        btn_Posture.setTitle("\(emoji) \(text)", for: .normal)
        btn_Posture.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        btn_Posture.setTitleColor(ColorConfig_Posture.textSecondary_Posture, for: .normal)
        btn_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        btn_Posture.layer.cornerRadius = 14
        btn_Posture.layer.borderWidth = 1
        btn_Posture.layer.borderColor = ColorConfig_Posture.primaryGradientStart_Posture.withAlphaComponent(0.2).cgColor
        btn_Posture.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)

        btn_Posture.addAction(UIAction { [weak self] _ in
            guard let self_Posture = self else { return }
            let tag_Posture = "#\(text) "
            let current_Posture = self_Posture.contentTextView_Posture.text ?? ""
            guard !current_Posture.contains(tag_Posture) else { return }
            self_Posture.contentTextView_Posture.text = current_Posture + tag_Posture
            // 同步更新 placeholder 可见性和字数统计
            self_Posture.textViewDidChange(self_Posture.contentTextView_Posture)
        }, for: .touchUpInside)

        return btn_Posture
    }

    // MARK: - 表单辅助

    /// 配置标题输入框样式（无 leftView padding，由容器内 accentBar + icon 承担间距）
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func configureTitleField_Posture() {
        titleField_Posture.placeholder = "e.g. Two-Minute Neck Reset at My Desk"
        titleField_Posture.font = .systemFont(ofSize: 14, weight: .semibold)
        titleField_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        titleField_Posture.backgroundColor = .clear
    }

    /// 发布按钮点击弹性动画
    /// - Parameters:
    ///   - button: 按钮视图
    ///   - completion: 动画完成后的回调
    /// - Returns: Void
    /// - Throws: 无
    private func animatePublishButton_Posture(button: UIButton, completion: @escaping () -> Void) {
        button.animatePressDown_Posture {
            button.animatePressUp_Posture {
                completion()
            }
        }
    }

    // MARK: - 键盘监听

    /// 注册点击收键盘手势
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupKeyboardObservers_Posture() {
        let tap_Posture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Posture))
        tap_Posture.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Posture)
    }

    /// 收起键盘
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    @objc private func dismissKeyboard_Posture() {
        view.endEditing(true)
    }

    // MARK: - 业务逻辑

    /// 调起系统媒体选择器
    /// 选择成功后切换 mediaPlaceholder → mediaView
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func pickMedia_Posture() {
        MediaPickerHelper_Posture.pickMedia_Posture(from: self) { [weak self] result_Posture in
            guard let self_Posture = self else { return }
            switch result_Posture {
            case .photo_Posture(let image_Posture):
                self_Posture.mediaView_Posture.configureWithImage_Posture(image_Posture: image_Posture)
                self_Posture.mediaPath_Posture = self_Posture.saveImage_Posture(image_Posture: image_Posture)
                self_Posture.hasMedia_Posture = true
            case .video_Posture(let url_Posture):
                self_Posture.mediaPath_Posture = url_Posture.path
                self_Posture.mediaView_Posture.configure_Posture(mediaPath_Posture: url_Posture.path, isVideo_Posture: true)
                self_Posture.hasMedia_Posture = true
            case .cancelled_Posture:
                return
            }
            // 切换到预览态
            self_Posture.mediaPlaceholder_Posture.isHidden = true
            self_Posture.mediaView_Posture.isHidden = false
        }
    }

    /// 保存图片到临时目录
    /// - Parameter image_Posture: 原始图片
    /// - Returns: String? - 保存路径，失败时返回 nil
    /// - Throws: 无
    private func saveImage_Posture(image_Posture: UIImage) -> String? {
        guard let data_Posture = image_Posture.jpegData(compressionQuality: 0.9) else { return nil }
        let url_Posture = FileManager.default.temporaryDirectory
            .appendingPathComponent("posture_post_\(Date().timeIntervalSince1970).jpg")
        do {
            try data_Posture.write(to: url_Posture)
            return url_Posture.path
        } catch {
            print("媒体保存失败: \(error.localizedDescription)")
            return nil
        }
    }

    /// 校验表单并发布帖子
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func handlePublish_Posture() {
        guard UserViewModel_Posture.shared_Posture.isLoggedIn_Posture else {
            Navigation_Posture.toLogin_Posture(style_posture: .present_posture)
            return
        }
        let title_Posture   = (titleField_Posture.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let content_Posture = contentTextView_Posture.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title_Posture.isEmpty, !content_Posture.isEmpty,
              let media_Posture = mediaPath_Posture, !media_Posture.isEmpty else {
            Utils_Posture.showWarning_Posture(message_Posture: "Title, content, and media are required.")
            return
        }
        TitleViewModel_Posture.shared_Posture.releasePost_Posture(
            title_posture: title_Posture,
            content_posture: content_Posture,
            media_posture: media_Posture
        )
        clearForm_Posture()
    }

    /// 清理发布表单，恢复初始状态
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func clearForm_Posture() {
        titleField_Posture.text = nil
        contentTextView_Posture.text = nil
        mediaPath_Posture = nil
        hasMedia_Posture = false
        mediaView_Posture.configure_Posture(mediaPath_Posture: nil)
        // 恢复媒体占位态
        mediaPlaceholder_Posture.isHidden = false
        mediaView_Posture.isHidden = true
        charCountLabel_Posture.text = "0 / 280"
        // 恢复内容框 placeholder
        contentTextView_Posture.superview?.viewWithTag(9001)?.isHidden = false
    }
}

// MARK: - UITextViewDelegate

extension Release_Posture: UITextViewDelegate {

    /// 开始编辑时隐藏模拟 placeholder
    /// - Parameter textView: 内容输入框
    /// - Returns: Void
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.superview?.viewWithTag(9001)?.isHidden = true
    }

    /// 结束编辑时，若内容为空则恢复 placeholder
    /// - Parameter textView: 内容输入框
    /// - Returns: Void
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.superview?.viewWithTag(9001)?.isHidden = false
        }
    }

    /// 文本变化时更新字数统计并控制 placeholder 可见性
    /// - Parameter textView: 内容输入框
    /// - Returns: Void
    func textViewDidChange(_ textView: UITextView) {
        let count_Posture = textView.text.count
        charCountLabel_Posture.text = "\(count_Posture) / 280"
        charCountLabel_Posture.textColor = count_Posture > 280
            ? .systemRed
            : ColorConfig_Posture.textPlaceholder_Posture

        // 超出字数截断
        if count_Posture > 280 {
            textView.text = String(textView.text.prefix(280))
            charCountLabel_Posture.text = "280 / 280"
        }

        // 同步 placeholder 可见性
        textView.superview?.viewWithTag(9001)?.isHidden = !textView.text.isEmpty
    }
}
