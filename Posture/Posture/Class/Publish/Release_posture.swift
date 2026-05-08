
import Foundation
import UIKit
import SnapKit

// MARK: 发布页面

/// 发布页面控制器
/// 核心作用：创建包含标题、内容和单个媒体的社区帖子。
/// 设计思路：页面负责采集与校验输入，发布动作统一调用 `TitleViewModel_Posture.releasePost_Posture`。
/// UI 层拆分为顶部灵感头图、分步表单卡片、媒体卡片和发布操作区，通过滚动容器承载全部内容。
/// 关键属性：`titleField_Posture`、`contentTextView_Posture`、`mediaPath_Posture` 保存表单数据。
/// 关键方法：`handlePublish_Posture()` 校验登录与内容并发布，`clearForm_Posture()` 清理页面。
@MainActor
class Release_Posture: UIViewController {

    // MARK: - 表单输入属性

    /// 标题输入框
    private let titleField_Posture = UITextField()

    /// 内容输入框
    private let contentTextView_Posture = UITextView()

    /// 媒体预览
    private let mediaView_Posture = MediaDisplayView_Posture()

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

        // 各区块
        let headerCard_Posture = buildHeaderCard_Posture()
        let titleCard_Posture = buildInputCard_Posture(
            step: "01",
            stepTitle: "Title",
            stepSubtitle: "Give your posture story a clear he   adline.",
            content: titleField_Posture
        )
        let contentCard_Posture = buildContentCard_Posture()
        let mediaCard_Posture = buildMediaCard_Posture()
        let publishSection_Posture = buildPublishSection_Posture()

        [headerCard_Posture, titleCard_Posture, contentCard_Posture,
         mediaCard_Posture, publishSection_Posture].forEach { contentView_Posture.addSubview($0) }

        let sideInset_Posture = 18

        headerCard_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(0)
            make.leading.trailing.equalToSuperview()
        }

        titleCard_Posture.snp.makeConstraints { make in
            make.top.equalTo(headerCard_Posture.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(sideInset_Posture)
        }

        contentCard_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleCard_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(sideInset_Posture)
        }

        mediaCard_Posture.snp.makeConstraints { make in
            make.top.equalTo(contentCard_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(sideInset_Posture)
        }

        publishSection_Posture.snp.makeConstraints { make in
            make.top.equalTo(mediaCard_Posture.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(sideInset_Posture)
            make.bottom.equalToSuperview().offset(-38)
        }
    }

    // MARK: - 区块构建方法

    /// 构建顶部灵感头图卡片
    /// - Parameters: 无
    /// - Returns: UIView - 包含渐变背景、标题和提示语的头图视图
    /// - Throws: 无
    private func buildHeaderCard_Posture() -> UIView {
        let container_Posture = UIView()
        container_Posture.clipsToBounds = false

        // 渐变背景
        let gradientCard_Posture = UIView()
        gradientCard_Posture.layer.cornerRadius = 36
        gradientCard_Posture.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gradientCard_Posture.clipsToBounds = true
        gradientCard_Posture.layer.shadowColor = ColorConfig_Posture.primaryGradientStart_Posture.cgColor
        gradientCard_Posture.layer.shadowOpacity = 0.35
        gradientCard_Posture.layer.shadowRadius = 22
        gradientCard_Posture.layer.shadowOffset = CGSize(width: 0, height: 12)
        gradientCard_Posture.backgroundColor = ColorConfig_Posture.primaryGradientStart_Posture

        // 渐变层
        let gradientLayer_Posture = CAGradientLayer()
        gradientLayer_Posture.colors = [
            ColorConfig_Posture.primaryGradientStart_Posture.cgColor,
            ColorConfig_Posture.primaryGradientEnd_Posture.cgColor,
            UIColor(hexstring_Posture: "#667EEA").cgColor
        ]
        gradientLayer_Posture.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Posture.endPoint = CGPoint(x: 1, y: 1)
        gradientCard_Posture.layer.insertSublayer(gradientLayer_Posture, at: 0)

        // 大图标
        let heroIcon_Posture = UIImageView(image: UIImage(systemName: "figure.strengthtraining.traditional"))
        heroIcon_Posture.tintColor = UIColor.white.withAlphaComponent(0.18)
        heroIcon_Posture.contentMode = .scaleAspectFit

        // 标题
        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = "Share Your Posture Story"
        titleLabel_Posture.font = .systemFont(ofSize: 28, weight: .heavy)
        titleLabel_Posture.textColor = .white
        titleLabel_Posture.numberOfLines = 2

        // 副标题
        let subtitleLabel_Posture = UILabel()
        subtitleLabel_Posture.text = "A tiny win, a mindful break,\nor a new habit worth sharing."
        subtitleLabel_Posture.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel_Posture.textColor = UIColor.white.withAlphaComponent(0.82)
        subtitleLabel_Posture.numberOfLines = 2

        // 装饰胶囊
        let chipStack_Posture = UIStackView()
        chipStack_Posture.axis = .horizontal
        chipStack_Posture.spacing = 8

        [("sparkles", "Inspire"), ("heart.fill", "Encourage"), ("bolt.fill", "Motivate")].forEach { chip_Posture in
            let chip_Posture = makeHeaderInspireChip_Posture(icon: chip_Posture.0, title: chip_Posture.1)
            chipStack_Posture.addArrangedSubview(chip_Posture)
        }

        gradientCard_Posture.addSubview(heroIcon_Posture)
        gradientCard_Posture.addSubview(titleLabel_Posture)
        gradientCard_Posture.addSubview(subtitleLabel_Posture)
        gradientCard_Posture.addSubview(chipStack_Posture)

        heroIcon_Posture.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(28)
            make.top.equalToSuperview().offset(24)
            make.width.height.equalTo(130)
        }

        // 头图卡片在加入 view 层级前就需要激活约束，无法引用 view.safeAreaLayoutGuide（不同视图树会崩溃）
        // 改为从 UIWindowScene 读取当前 safe area top，转换为对 superview 的纯偏移约束
        let safeTop_Posture: CGFloat = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?.safeAreaInsets.top ?? 44
        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Posture + 16)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalTo(heroIcon_Posture.snp.leading).offset(-12)
        }

        subtitleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        chipStack_Posture.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Posture.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-26)
        }

        container_Posture.addSubview(gradientCard_Posture)
        gradientCard_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 渐变层在 layoutSubviews 后再设置 frame，先暂定一个大值
        DispatchQueue.main.async {
            gradientLayer_Posture.frame = gradientCard_Posture.bounds
        }

        return container_Posture
    }

    /// 构建通用输入卡片（用于标题步骤）
    /// - Parameters:
    ///   - step: 步骤编号文字
    ///   - stepTitle: 步骤标题
    ///   - stepSubtitle: 步骤说明
    ///   - content: 放入卡片内的输入控件
    /// - Returns: UIView - 输入卡片
    /// - Throws: 无
    private func buildInputCard_Posture(step: String, stepTitle: String, stepSubtitle: String, content: UIView) -> UIView {
        let card_Posture = makeCard_Posture()

        let stepBadge_Posture = makeStepBadge_Posture(text: step)
        let titleLabel_Posture = makeCardTitle_Posture(text: stepTitle)
        let subtitleLabel_Posture = makeCardSubtitle_Posture(text: stepSubtitle)

        // 标题输入框配置
        configureTitleField_Posture()

        card_Posture.addSubview(stepBadge_Posture)
        card_Posture.addSubview(titleLabel_Posture)
        card_Posture.addSubview(subtitleLabel_Posture)
        card_Posture.addSubview(content)

        stepBadge_Posture.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(32)
        }

        titleLabel_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(stepBadge_Posture)
            make.leading.equalTo(stepBadge_Posture.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(20)
        }

        subtitleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(stepBadge_Posture.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        content.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Posture.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
            make.height.equalTo(54)
        }

        return card_Posture
    }

    /// 构建内容输入卡片（带字数统计）
    /// - Parameters: 无
    /// - Returns: UIView - 内容输入卡片
    /// - Throws: 无
    private func buildContentCard_Posture() -> UIView {
        let card_Posture = makeCard_Posture()

        let stepBadge_Posture = makeStepBadge_Posture(text: "02")
        let titleLabel_Posture = makeCardTitle_Posture(text: "Content")
        let subtitleLabel_Posture = makeCardSubtitle_Posture(text: "Describe your posture habit or story in a few lines.")

        // 内容输入框样式
        contentTextView_Posture.font = .systemFont(ofSize: 14, weight: .regular)
        contentTextView_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        contentTextView_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        contentTextView_Posture.layer.cornerRadius = 18
        contentTextView_Posture.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        contentTextView_Posture.delegate = self

        // 字数统计
        charCountLabel_Posture.text = "0 / 280"
        charCountLabel_Posture.font = .systemFont(ofSize: 11, weight: .bold)
        charCountLabel_Posture.textColor = ColorConfig_Posture.textPlaceholder_Posture
        charCountLabel_Posture.textAlignment = .right

        // 灵感提示
        let inspirationView_Posture = buildInspirationTip_Posture()

        card_Posture.addSubview(stepBadge_Posture)
        card_Posture.addSubview(titleLabel_Posture)
        card_Posture.addSubview(subtitleLabel_Posture)
        card_Posture.addSubview(contentTextView_Posture)
        card_Posture.addSubview(charCountLabel_Posture)
        card_Posture.addSubview(inspirationView_Posture)

        stepBadge_Posture.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(32)
        }

        titleLabel_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(stepBadge_Posture)
            make.leading.equalTo(stepBadge_Posture.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(20)
        }

        subtitleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(stepBadge_Posture.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        contentTextView_Posture.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Posture.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(130)
        }

        charCountLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(contentTextView_Posture.snp.bottom).offset(6)
            make.trailing.equalToSuperview().inset(20)
        }

        inspirationView_Posture.snp.makeConstraints { make in
            make.top.equalTo(charCountLabel_Posture.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }

        return card_Posture
    }

    /// 构建媒体选择卡片
    /// - Parameters: 无
    /// - Returns: UIView - 媒体选择与预览卡片
    /// - Throws: 无
    private func buildMediaCard_Posture() -> UIView {
        let card_Posture = makeCard_Posture()

        let stepBadge_Posture = makeStepBadge_Posture(text: "03")
        let titleLabel_Posture = makeCardTitle_Posture(text: "Add Media")
        let subtitleLabel_Posture = makeCardSubtitle_Posture(text: "A single photo or video brings your story to life.")

        // 媒体预览区，默认高度 180
        mediaView_Posture.layer.cornerRadius = 20
        mediaView_Posture.clipsToBounds = true

        // 选择媒体按钮
        let pickButton_Posture = UIButton(type: .system)
        pickButton_Posture.setTitle("Browse Library", for: .normal)
        pickButton_Posture.setImage(UIImage(systemName: "photo.stack"), for: .normal)
        pickButton_Posture.tintColor = .white
        pickButton_Posture.setTitleColor(.white, for: .normal)
        pickButton_Posture.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        pickButton_Posture.backgroundColor = ColorConfig_Posture.primaryGradientStart_Posture
        pickButton_Posture.layer.cornerRadius = 22
        pickButton_Posture.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        pickButton_Posture.addAction(UIAction { [weak self] _ in self?.pickMedia_Posture() }, for: .touchUpInside)

        // 支持格式提示
        let formatLabel_Posture = UILabel()
        formatLabel_Posture.text = "JPG · PNG · MP4 · MOV"
        formatLabel_Posture.font = .systemFont(ofSize: 11, weight: .semibold)
        formatLabel_Posture.textColor = ColorConfig_Posture.textPlaceholder_Posture
        formatLabel_Posture.textAlignment = .center

        card_Posture.addSubview(stepBadge_Posture)
        card_Posture.addSubview(titleLabel_Posture)
        card_Posture.addSubview(subtitleLabel_Posture)
        card_Posture.addSubview(mediaView_Posture)
        card_Posture.addSubview(pickButton_Posture)
        card_Posture.addSubview(formatLabel_Posture)

        stepBadge_Posture.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(32)
        }

        titleLabel_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(stepBadge_Posture)
            make.leading.equalTo(stepBadge_Posture.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(20)
        }

        subtitleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(stepBadge_Posture.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        mediaView_Posture.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(180)
        }

        pickButton_Posture.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }

        formatLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(pickButton_Posture.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }

        return card_Posture
    }

    /// 构建发布操作区（发布按钮 + EULA）
    /// - Parameters: 无
    /// - Returns: UIView - 发布操作区
    /// - Throws: 无
    private func buildPublishSection_Posture() -> UIView {
        let container_Posture = UIView()

        // 发布按钮容器（用于承载渐变）
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
        publishGradient_Posture.endPoint = CGPoint(x: 1, y: 0)
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
        publishButton_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // EULA 按钮
        let eulaButton_Posture = UIButton(type: .system)
        let eulaAttr_Posture = NSAttributedString(string: "By publishing you agree to our EULA", attributes: [
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
            make.bottom.equalToSuperview()
        }

        // 渐变层 frame 在渲染后更新
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
            make.height.equalTo(32)
        }

        return container_Posture
    }

    /// 构建内容灵感提示区
    /// - Parameters: 无
    /// - Returns: UIView - 灵感提示行
    /// - Throws: 无
    private func buildInspirationTip_Posture() -> UIView {
        let container_Posture = UIView()
        container_Posture.backgroundColor = ColorConfig_Posture.primaryGradientEnd_Posture.withAlphaComponent(0.12)
        container_Posture.layer.cornerRadius = 16

        let bulbIcon_Posture = UIImageView(image: UIImage(systemName: "lightbulb.fill"))
        bulbIcon_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
        bulbIcon_Posture.contentMode = .scaleAspectFit

        let tipLabel_Posture = UILabel()
        tipLabel_Posture.text = "Tip: a story with a specific body part or situation gets more responses."
        tipLabel_Posture.font = .systemFont(ofSize: 12, weight: .medium)
        tipLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        tipLabel_Posture.numberOfLines = 2

        container_Posture.addSubview(bulbIcon_Posture)
        container_Posture.addSubview(tipLabel_Posture)

        bulbIcon_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(16)
        }
        tipLabel_Posture.snp.makeConstraints { make in
            make.leading.equalTo(bulbIcon_Posture.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(14)
            make.top.bottom.equalToSuperview().inset(12)
        }

        return container_Posture
    }

    // MARK: - 表单辅助

    /// 配置标题输入框样式
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func configureTitleField_Posture() {
        titleField_Posture.placeholder = "e.g. Two-Minute Neck Reset at My Desk"
        titleField_Posture.font = .systemFont(ofSize: 14, weight: .semibold)
        titleField_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        titleField_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        titleField_Posture.layer.cornerRadius = 18
        titleField_Posture.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        titleField_Posture.leftViewMode = .always
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

    /// 注册键盘显示/隐藏通知
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

    /// 选择单个图片或视频
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
                break
            }
        }
    }

    /// 保存图片到临时目录
    /// - Parameter image_Posture: 图片
    /// - Returns: String? - 保存路径
    /// - Throws: 无
    private func saveImage_Posture(image_Posture: UIImage) -> String? {
        guard let data_Posture = image_Posture.jpegData(compressionQuality: 0.9) else { return nil }
        let url_Posture = FileManager.default.temporaryDirectory.appendingPathComponent("posture_post_\(Date().timeIntervalSince1970).jpg")
        do {
            try data_Posture.write(to: url_Posture)
            return url_Posture.path
        } catch {
            print("媒体保存失败: \(error.localizedDescription)")
            return nil
        }
    }

    /// 发布帖子
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func handlePublish_Posture() {
        guard UserViewModel_Posture.shared_Posture.isLoggedIn_Posture else {
            Navigation_Posture.toLogin_Posture(style_posture: .present_posture)
            return
        }
        let title_Posture = (titleField_Posture.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
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

    /// 清理发布表单
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func clearForm_Posture() {
        titleField_Posture.text = nil
        contentTextView_Posture.text = nil
        mediaPath_Posture = nil
        hasMedia_Posture = false
        mediaView_Posture.configure_Posture(mediaPath_Posture: nil)
        charCountLabel_Posture.text = "0 / 280"
    }
}

// MARK: - UITextViewDelegate

extension Release_Posture: UITextViewDelegate {

    /// 文本变化时更新字数统计
    /// - Parameter textView: 当前内容输入框
    /// - Returns: Void
    /// - Throws: 无
    func textViewDidChange(_ textView: UITextView) {
        let count_Posture = textView.text.count
        charCountLabel_Posture.text = "\(count_Posture) / 280"
        let isOver_Posture = count_Posture > 280
        charCountLabel_Posture.textColor = isOver_Posture
            ? UIColor.systemRed
            : ColorConfig_Posture.textPlaceholder_Posture
        if isOver_Posture {
            textView.text = String(textView.text.prefix(280))
            charCountLabel_Posture.text = "280 / 280"
        }
    }
}
