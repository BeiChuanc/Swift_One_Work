import Foundation
import UIKit
import SnapKit

// MARK: 发布页面 - 重构版 v2

/// 发布帖子控制器
/// 核心作用：输入标题、内容，选取媒体（图片/视频），点击发布提交帖子
/// 设计思路：沉浸式渐变头部（含步骤指示器）+ 大媒体选区 + 分离式表单卡片 + 渐变发布按钮
/// 关键逻辑：发布前校验登录状态及表单非空，成功后清空页面数据
class Release_Retrs: UIViewController {

    // MARK: - 属性

    private let titleVM_Retrs = TitleViewModel_Retrs.shared_Retrs
    private let userVM_Retrs  = UserViewModel_Retrs.shared_Retrs

    /// 主滚动视图
    private let scrollView_Retrs   = UIScrollView()
    private let contentView_Retrs  = UIView()

    /// 渐变头部
    private let headerView_Retrs      = UIView()
    private let headerGradLayer_Retrs = CAGradientLayer()
    private let navTitleLabel_Retrs   = UILabel()
    private let navSubLabel_Retrs     = UILabel()

    /// 媒体选区
    private let mediaCard_Retrs            = UIView()
    private let mediaDashLayer_Retrs       = CAShapeLayer()
    private let mediaDisplayView_Retrs     = MediaDisplayView_Retrs()
    private let mediaPlaceholderWrap_Retrs = UIView()
    private let mediaHintLabel_Retrs       = UILabel()
    private let mediaChangeBadge_Retrs     = UIView()
    private var selectedImage_Retrs: UIImage?
    private var selectedVideoURL_Retrs: URL?
    private var mediaPath_Retrs: String = ""

    /// 表单区域
    private let titleCard_Retrs          = UIView()
    private let titleField_Retrs         = UITextField()
    private let descCard_Retrs           = UIView()
    private let contentTextView_Retrs    = UITextView()
    private let contentPlaceholder_Retrs = UILabel()
    private let charCountLabel_Retrs     = UILabel()

    /// 发布按钮
    private let publishBtn_Retrs       = UIButton(type: .system)
    private let publishGradLayer_Retrs = CAGradientLayer()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Retrs: "#F7FAFC")
        setupScrollView_Retrs()
        setupHeaderView_Retrs()
        setupMediaCard_Retrs()
        setupTitleCard_Retrs()
        setupDescCard_Retrs()
        setupPublishArea_Retrs()
        setupConstraints_Retrs()

        let tap_Retrs = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Retrs))
        tap_Retrs.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Retrs)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow_Retrs(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide_Retrs(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradLayer_Retrs.frame = headerView_Retrs.bounds
        publishGradLayer_Retrs.frame = publishBtn_Retrs.bounds
        // 虚线边框跟随媒体卡片 bounds 更新
        updateDashBorder_Retrs()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    /// 主滚动视图
    private func setupScrollView_Retrs() {
        scrollView_Retrs.showsVerticalScrollIndicator = false
        scrollView_Retrs.alwaysBounceVertical = true
        scrollView_Retrs.backgroundColor = .clear
        scrollView_Retrs.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_Retrs)
        scrollView_Retrs.addSubview(contentView_Retrs)
        contentView_Retrs.backgroundColor = .clear
    }

    /// 渐变头部：标题 + 副标题 + 步骤指示器 + 装饰图标
    private func setupHeaderView_Retrs() {
        headerGradLayer_Retrs.colors = [
            UIColor(hexstring_Retrs: "#B794F6").cgColor,
            UIColor(hexstring_Retrs: "#90CDF4").cgColor
        ]
        headerGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0)
        headerGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 1)
        headerView_Retrs.layer.insertSublayer(headerGradLayer_Retrs, at: 0)
        headerView_Retrs.layer.cornerRadius = 30
        headerView_Retrs.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Retrs.clipsToBounds = true
        contentView_Retrs.addSubview(headerView_Retrs)

        // 装饰气泡群
        addDecorBubble_Retrs(to: headerView_Retrs, alpha_Retrs: 0.11, size_Retrs: 150, top_Retrs: -40, right_Retrs: 20)
        addDecorBubble_Retrs(to: headerView_Retrs, alpha_Retrs: 0.08, size_Retrs: 80,  bottom_Retrs: 20, left_Retrs: -20)
        addDecorBubble_Retrs(to: headerView_Retrs, alpha_Retrs: 0.06, size_Retrs: 55,  bottom_Retrs: -10, right_Retrs: 60)

        // 右侧装饰图标（大相机图标）
        let camBg_Retrs = UIView()
        camBg_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        camBg_Retrs.layer.cornerRadius = 28
        headerView_Retrs.addSubview(camBg_Retrs)
        camBg_Retrs.snp.makeConstraints { make in
            make.width.height.equalTo(56)
        }

        let camIcon_Retrs = UIImageView(
            image: UIImage(systemName: "camera.aperture",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 26, weight: .medium))
        )
        camIcon_Retrs.tintColor = UIColor.white.withAlphaComponent(0.9)
        camIcon_Retrs.contentMode = .scaleAspectFit
        camBg_Retrs.addSubview(camIcon_Retrs)
        camIcon_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }

        // 主标题
        navTitleLabel_Retrs.text = "New Post"
        navTitleLabel_Retrs.font = UIFont.systemFont(ofSize: 30, weight: .black)
        navTitleLabel_Retrs.textColor = .white
        headerView_Retrs.addSubview(navTitleLabel_Retrs)

        // 副标题
        navSubLabel_Retrs.text = "Share your CCD story with the world"
        navSubLabel_Retrs.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        navSubLabel_Retrs.textColor = UIColor.white.withAlphaComponent(0.75)
        headerView_Retrs.addSubview(navSubLabel_Retrs)

        // 步骤指示器
        let stepBar_Retrs = buildStepBar_Retrs()
        headerView_Retrs.addSubview(stepBar_Retrs)

        let safeTop_Retrs = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 44

        camBg_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Retrs + 18)
            make.trailing.equalToSuperview().offset(-22)
        }
        navTitleLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(camBg_Retrs)
            make.leading.equalToSuperview().offset(22)
        }
        navSubLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(navTitleLabel_Retrs.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(22)
        }
        stepBar_Retrs.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.trailing.equalToSuperview().offset(-22)
            make.bottom.equalToSuperview().offset(-18)
            make.height.equalTo(32)
        }
    }

    /// 构建步骤指示器（Upload → Write → Publish）
    /// - Returns: 配置好的步骤条 UIView
    private func buildStepBar_Retrs() -> UIView {
        let bar_Retrs = UIView()
        bar_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        bar_Retrs.layer.cornerRadius = 16

        let steps_Retrs: [(String, String)] = [
            ("photo.on.rectangle", "Upload"),
            ("pencil.and.outline", "Write"),
            ("paperplane.fill",    "Publish")
        ]

        let stack_Retrs = UIStackView()
        stack_Retrs.axis = .horizontal
        stack_Retrs.distribution = .fillEqually
        stack_Retrs.alignment = .center
        bar_Retrs.addSubview(stack_Retrs)
        stack_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }

        for (idx_Retrs, step_Retrs) in steps_Retrs.enumerated() {
            let cell_Retrs = UIView()

            let iconView_Retrs = UIImageView(
                image: UIImage(systemName: step_Retrs.0,
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold))
            )
            iconView_Retrs.tintColor = idx_Retrs == 0
                ? .white
                : UIColor.white.withAlphaComponent(0.45)
            iconView_Retrs.contentMode = .scaleAspectFit

            let lbl_Retrs = UILabel()
            lbl_Retrs.text = step_Retrs.1
            lbl_Retrs.font = UIFont.systemFont(ofSize: 10, weight: idx_Retrs == 0 ? .bold : .regular)
            lbl_Retrs.textColor = idx_Retrs == 0
                ? .white
                : UIColor.white.withAlphaComponent(0.45)

            cell_Retrs.addSubview(iconView_Retrs)
            cell_Retrs.addSubview(lbl_Retrs)
            iconView_Retrs.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalToSuperview().offset(12)
                make.width.height.equalTo(12)
            }
            lbl_Retrs.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalTo(iconView_Retrs.snp.trailing).offset(5)
            }

            // 步骤间分隔线（非最后一步）
            if idx_Retrs < steps_Retrs.count - 1 {
                let sep_Retrs = UIView()
                sep_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.25)
                cell_Retrs.addSubview(sep_Retrs)
                sep_Retrs.snp.makeConstraints { make in
                    make.trailing.equalToSuperview()
                    make.centerY.equalToSuperview()
                    make.width.equalTo(1)
                    make.height.equalTo(14)
                }
            }
            stack_Retrs.addArrangedSubview(cell_Retrs)
        }
        return bar_Retrs
    }

    /// 辅助：向目标视图添加装饰气泡
    private func addDecorBubble_Retrs(
        to view_Retrs: UIView, alpha_Retrs: CGFloat, size_Retrs: CGFloat,
        top_Retrs: CGFloat? = nil, bottom_Retrs: CGFloat? = nil,
        left_Retrs: CGFloat? = nil, right_Retrs: CGFloat? = nil
    ) {
        let bubble_Retrs = UIView()
        bubble_Retrs.backgroundColor = UIColor.white.withAlphaComponent(alpha_Retrs)
        bubble_Retrs.layer.cornerRadius = size_Retrs / 2
        view_Retrs.addSubview(bubble_Retrs)
        bubble_Retrs.snp.makeConstraints { make in
            make.width.height.equalTo(size_Retrs)
            if let t = top_Retrs    { make.top.equalToSuperview().offset(t) }
            if let b = bottom_Retrs { make.bottom.equalToSuperview().offset(b) }
            if let l = left_Retrs   { make.leading.equalToSuperview().offset(l) }
            if let r = right_Retrs  { make.trailing.equalToSuperview().offset(r) }
        }
    }

    // MARK: - 媒体选区

    /// 媒体选区卡片（带虚线边框 + 渐变图标占位）
    private func setupMediaCard_Retrs() {
        mediaCard_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#F7FAFC")
        mediaCard_Retrs.layer.cornerRadius = 22
        mediaCard_Retrs.clipsToBounds = false
        mediaCard_Retrs.layer.shadowColor = UIColor(hexstring_Retrs: "#B794F6").withAlphaComponent(0.13).cgColor
        mediaCard_Retrs.layer.shadowOffset = CGSize(width: 0, height: 6)
        mediaCard_Retrs.layer.shadowOpacity = 1.0
        mediaCard_Retrs.layer.shadowRadius = 18
        contentView_Retrs.addSubview(mediaCard_Retrs)

        // 虚线边框（通过 CAShapeLayer 实现，单独层不受 clipsToBounds 裁切）
        mediaDashLayer_Retrs.strokeColor = UIColor(hexstring_Retrs: "#B794F6").withAlphaComponent(0.4).cgColor
        mediaDashLayer_Retrs.fillColor   = UIColor.clear.cgColor
        mediaDashLayer_Retrs.lineWidth   = 1.5
        mediaDashLayer_Retrs.lineDashPattern = [8, 5]
        mediaCard_Retrs.layer.addSublayer(mediaDashLayer_Retrs)

        // 媒体预览层（选中后覆盖全卡片）
        mediaDisplayView_Retrs.layer.cornerRadius = 22
        mediaDisplayView_Retrs.clipsToBounds = true
        mediaCard_Retrs.addSubview(mediaDisplayView_Retrs)
        mediaDisplayView_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 空状态占位内容
        mediaCard_Retrs.addSubview(mediaPlaceholderWrap_Retrs)
        mediaPlaceholderWrap_Retrs.snp.makeConstraints { make in make.center.equalToSuperview() }

        // 渐变圆角图标背景
        let iconBg_Retrs = ReleaseGradView_Retrs(
            colors_Retrs: [UIColor(hexstring_Retrs: "#B794F6"), UIColor(hexstring_Retrs: "#90CDF4")],
            startPoint_Retrs: CGPoint(x: 0, y: 0), endPoint_Retrs: CGPoint(x: 1, y: 1)
        )
        iconBg_Retrs.layer.cornerRadius = 22
        iconBg_Retrs.clipsToBounds = true
        mediaPlaceholderWrap_Retrs.addSubview(iconBg_Retrs)
        iconBg_Retrs.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }

        let uploadIcon_Retrs = UIImageView(
            image: UIImage(systemName: "arrow.up.circle.fill",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))
        )
        uploadIcon_Retrs.tintColor = .white
        uploadIcon_Retrs.contentMode = .scaleAspectFit
        iconBg_Retrs.addSubview(uploadIcon_Retrs)
        uploadIcon_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(38)
        }

        mediaHintLabel_Retrs.text = "Tap to Upload Media"
        mediaHintLabel_Retrs.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        mediaHintLabel_Retrs.textColor = UIColor(hexstring_Retrs: "#8B6BA8")
        mediaHintLabel_Retrs.textAlignment = .center
        mediaPlaceholderWrap_Retrs.addSubview(mediaHintLabel_Retrs)
        mediaHintLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Retrs.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }

        // 格式标签行
        let tagsRow_Retrs = buildFormatTagsRow_Retrs()
        mediaPlaceholderWrap_Retrs.addSubview(tagsRow_Retrs)
        tagsRow_Retrs.snp.makeConstraints { make in
            make.top.equalTo(mediaHintLabel_Retrs.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        // 已选媒体后出现的"更换"徽章（右下角）
        mediaChangeBadge_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#B794F6")
        mediaChangeBadge_Retrs.layer.cornerRadius = 20
        mediaChangeBadge_Retrs.layer.shadowColor = UIColor(hexstring_Retrs: "#B794F6").withAlphaComponent(0.35).cgColor
        mediaChangeBadge_Retrs.layer.shadowOffset = CGSize(width: 0, height: 4)
        mediaChangeBadge_Retrs.layer.shadowOpacity = 1
        mediaChangeBadge_Retrs.layer.shadowRadius = 8
        mediaChangeBadge_Retrs.isHidden = true
        mediaCard_Retrs.addSubview(mediaChangeBadge_Retrs)
        mediaChangeBadge_Retrs.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-14)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(40)
            make.width.equalTo(110)
        }
        let changeIcon_Retrs = UIImageView(
            image: UIImage(systemName: "arrow.2.circlepath",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold))
        )
        changeIcon_Retrs.tintColor = .white
        changeIcon_Retrs.contentMode = .scaleAspectFit
        mediaChangeBadge_Retrs.addSubview(changeIcon_Retrs)
        changeIcon_Retrs.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }
        let changeLabel_Retrs = UILabel()
        changeLabel_Retrs.text = "Change"
        changeLabel_Retrs.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        changeLabel_Retrs.textColor = .white
        mediaChangeBadge_Retrs.addSubview(changeLabel_Retrs)
        changeLabel_Retrs.snp.makeConstraints { make in
            make.leading.equalTo(changeIcon_Retrs.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-14)
        }

        let tap_Retrs = UITapGestureRecognizer(target: self, action: #selector(pickMediaTapped_Retrs))
        mediaCard_Retrs.addGestureRecognizer(tap_Retrs)
        mediaCard_Retrs.isUserInteractionEnabled = true
    }

    /// 构建媒体格式标签行（PHOTO / VIDEO / MOV）
    /// - Returns: 横向标签排列的 UIStackView
    private func buildFormatTagsRow_Retrs() -> UIView {
        let stack_Retrs = UIStackView()
        stack_Retrs.axis = .horizontal
        stack_Retrs.spacing = 8
        stack_Retrs.alignment = .center
        for (tag_Retrs, color_Retrs) in [
            ("PHOTO", "#B794F6"),
            ("VIDEO", "#90CDF4"),
            ("MOV",   "#B794F6")
        ] {
            let pill_Retrs = UIView()
            pill_Retrs.backgroundColor = UIColor(hexstring_Retrs: color_Retrs).withAlphaComponent(0.12)
            pill_Retrs.layer.cornerRadius = 10
            let lbl_Retrs = UILabel()
            lbl_Retrs.text = tag_Retrs
            lbl_Retrs.font = UIFont.systemFont(ofSize: 10, weight: .bold)
            lbl_Retrs.textColor = UIColor(hexstring_Retrs: color_Retrs)
            pill_Retrs.addSubview(lbl_Retrs)
            lbl_Retrs.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(4)
                make.leading.trailing.equalToSuperview().inset(10)
            }
            stack_Retrs.addArrangedSubview(pill_Retrs)
        }
        return stack_Retrs
    }

    /// 更新虚线边框路径（在 layoutSubviews 后调用）
    private func updateDashBorder_Retrs() {
        let path_Retrs = UIBezierPath(roundedRect: mediaCard_Retrs.bounds, cornerRadius: 22)
        mediaDashLayer_Retrs.path = path_Retrs.cgPath
        mediaDashLayer_Retrs.frame = mediaCard_Retrs.bounds
    }

    // MARK: - 表单

    /// 标题输入卡片
    private func setupTitleCard_Retrs() {
        styleInputCard_Retrs(titleCard_Retrs)
        contentView_Retrs.addSubview(titleCard_Retrs)

        let header_Retrs = makeSectionHeader_Retrs(title_Retrs: "Post Title", icon_Retrs: "pencil.line",
                                                   accentColor_Retrs: UIColor(hexstring_Retrs: "#B794F6"))
        titleCard_Retrs.addSubview(header_Retrs)
        header_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(20)
        }

        // 左侧紫色强调条
        let accentBar_Retrs = makeAccentBar_Retrs(color_Retrs: UIColor(hexstring_Retrs: "#B794F6"))
        titleCard_Retrs.addSubview(accentBar_Retrs)
        accentBar_Retrs.snp.makeConstraints { make in
            make.top.equalTo(header_Retrs.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(18)
            make.width.equalTo(4)
            make.height.equalTo(50)
        }

        let fieldWrap_Retrs = makeInputWrap_Retrs()
        titleCard_Retrs.addSubview(fieldWrap_Retrs)
        fieldWrap_Retrs.snp.makeConstraints { make in
            make.top.equalTo(header_Retrs.snp.bottom).offset(10)
            make.leading.equalTo(accentBar_Retrs.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-18)
        }

        titleField_Retrs.placeholder = "Give your post an awesome title"
        titleField_Retrs.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleField_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        titleField_Retrs.backgroundColor = .clear
        titleField_Retrs.autocorrectionType = .no
        titleField_Retrs.leftView = makeIconPad_Retrs(iconName_Retrs: "textformat.alt",
                                                      color_Retrs: UIColor(hexstring_Retrs: "#B794F6"))
        titleField_Retrs.leftViewMode = .always
        fieldWrap_Retrs.addSubview(titleField_Retrs)
        titleField_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 描述输入卡片
    private func setupDescCard_Retrs() {
        styleInputCard_Retrs(descCard_Retrs)
        contentView_Retrs.addSubview(descCard_Retrs)

        let header_Retrs = makeSectionHeader_Retrs(title_Retrs: "Description", icon_Retrs: "text.alignleft",
                                                   accentColor_Retrs: UIColor(hexstring_Retrs: "#90CDF4"))
        descCard_Retrs.addSubview(header_Retrs)
        header_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(20)
        }

        // 左侧蓝色强调条
        let accentBar_Retrs = makeAccentBar_Retrs(color_Retrs: UIColor(hexstring_Retrs: "#90CDF4"))
        descCard_Retrs.addSubview(accentBar_Retrs)
        accentBar_Retrs.snp.makeConstraints { make in
            make.top.equalTo(header_Retrs.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(18)
            make.width.equalTo(4)
            make.height.equalTo(140)
        }

        let tvWrap_Retrs = makeInputWrap_Retrs()
        descCard_Retrs.addSubview(tvWrap_Retrs)
        tvWrap_Retrs.snp.makeConstraints { make in
            make.top.equalTo(header_Retrs.snp.bottom).offset(10)
            make.leading.equalTo(accentBar_Retrs.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(140)
        }

        contentTextView_Retrs.font = UIFont.systemFont(ofSize: 14)
        contentTextView_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        contentTextView_Retrs.backgroundColor = .clear
        contentTextView_Retrs.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        contentTextView_Retrs.delegate = self
        tvWrap_Retrs.addSubview(contentTextView_Retrs)
        contentTextView_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }

        contentPlaceholder_Retrs.text = "Describe your CCD moment in detail..."
        contentPlaceholder_Retrs.font = UIFont.systemFont(ofSize: 14)
        contentPlaceholder_Retrs.textColor = ColorConfig_Retrs.textPlaceholder_Retrs
        tvWrap_Retrs.addSubview(contentPlaceholder_Retrs)
        contentPlaceholder_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
        }

        // 字数统计行
        let countRow_Retrs = UIView()
        descCard_Retrs.addSubview(countRow_Retrs)
        countRow_Retrs.snp.makeConstraints { make in
            make.top.equalTo(tvWrap_Retrs.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-14)
            make.height.equalTo(18)
        }

        let tipLabel_Retrs = UILabel()
        tipLabel_Retrs.text = "✦ Engaging descriptions get more likes"
        tipLabel_Retrs.font = UIFont.systemFont(ofSize: 10)
        tipLabel_Retrs.textColor = UIColor(hexstring_Retrs: "#B794F6").withAlphaComponent(0.6)
        countRow_Retrs.addSubview(tipLabel_Retrs)
        tipLabel_Retrs.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }

        charCountLabel_Retrs.text = "0 / 200"
        charCountLabel_Retrs.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        charCountLabel_Retrs.textColor = ColorConfig_Retrs.textPlaceholder_Retrs
        charCountLabel_Retrs.textAlignment = .right
        countRow_Retrs.addSubview(charCountLabel_Retrs)
        charCountLabel_Retrs.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
        }
    }

    /// 为输入卡片应用统一样式（白色背景 + 圆角 + 紫色调阴影）
    private func styleInputCard_Retrs(_ card_Retrs: UIView) {
        card_Retrs.backgroundColor = .white
        card_Retrs.layer.cornerRadius = 20
        card_Retrs.clipsToBounds = false
        card_Retrs.layer.shadowColor = UIColor(hexstring_Retrs: "#B794F6").withAlphaComponent(0.11).cgColor
        card_Retrs.layer.shadowOffset = CGSize(width: 0, height: 5)
        card_Retrs.layer.shadowOpacity = 1.0
        card_Retrs.layer.shadowRadius = 14
    }

    /// 创建区块标题行（彩色圆点 + 标题 + 图标）
    private func makeSectionHeader_Retrs(title_Retrs: String, icon_Retrs: String,
                                         accentColor_Retrs: UIColor) -> UIView {
        let row_Retrs = UIView()
        let dot_Retrs = UIView()
        dot_Retrs.backgroundColor = accentColor_Retrs
        dot_Retrs.layer.cornerRadius = 3
        row_Retrs.addSubview(dot_Retrs)
        dot_Retrs.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(6)
        }
        let lbl_Retrs = UILabel()
        lbl_Retrs.text = title_Retrs
        lbl_Retrs.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        lbl_Retrs.textColor = accentColor_Retrs.withAlphaComponent(0.85)
        row_Retrs.addSubview(lbl_Retrs)
        lbl_Retrs.snp.makeConstraints { make in
            make.leading.equalTo(dot_Retrs.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        let iv_Retrs = UIImageView(
            image: UIImage(systemName: icon_Retrs,
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .medium))
        )
        iv_Retrs.tintColor = accentColor_Retrs.withAlphaComponent(0.5)
        iv_Retrs.contentMode = .scaleAspectFit
        row_Retrs.addSubview(iv_Retrs)
        iv_Retrs.snp.makeConstraints { make in
            make.leading.equalTo(lbl_Retrs.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(13)
            make.trailing.equalToSuperview()
        }
        return row_Retrs
    }

    /// 创建左侧强调竖条（渐变色）
    private func makeAccentBar_Retrs(color_Retrs: UIColor) -> UIView {
        let bar_Retrs = ReleaseGradView_Retrs(
            colors_Retrs: [color_Retrs, color_Retrs.withAlphaComponent(0.3)],
            startPoint_Retrs: CGPoint(x: 0.5, y: 0),
            endPoint_Retrs: CGPoint(x: 0.5, y: 1)
        )
        bar_Retrs.layer.cornerRadius = 2
        bar_Retrs.clipsToBounds = true
        return bar_Retrs
    }

    /// 创建输入框背景容器（浅紫 + 圆角）
    private func makeInputWrap_Retrs() -> UIView {
        let wrap_Retrs = UIView()
        wrap_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#EEF2FF")
        wrap_Retrs.layer.cornerRadius = 14
        return wrap_Retrs
    }

    /// 创建输入框左侧图标 pad（leftView 用）
    private func makeIconPad_Retrs(iconName_Retrs: String, color_Retrs: UIColor) -> UIView {
        let pad_Retrs = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 50))
        let iv_Retrs  = UIImageView(
            image: UIImage(systemName: iconName_Retrs,
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .medium))
        )
        iv_Retrs.tintColor = color_Retrs
        iv_Retrs.contentMode = .scaleAspectFit
        iv_Retrs.frame = CGRect(x: 12, y: 13, width: 18, height: 24)
        pad_Retrs.addSubview(iv_Retrs)
        return pad_Retrs
    }

    // MARK: - 发布区域

    /// 发布按钮 + EULA 链接
    private func setupPublishArea_Retrs() {
        // 水平渐变（紫 → 蓝）
        publishGradLayer_Retrs.colors = [
            UIColor(hexstring_Retrs: "#B794F6").cgColor,
            UIColor(hexstring_Retrs: "#90CDF4").cgColor
        ]
        publishGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0.5)
        publishGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 0.5)
        publishGradLayer_Retrs.cornerRadius = 30
        publishBtn_Retrs.layer.insertSublayer(publishGradLayer_Retrs, at: 0)
        publishBtn_Retrs.layer.cornerRadius = 30
        publishBtn_Retrs.layer.shadowColor = UIColor(hexstring_Retrs: "#B794F6").withAlphaComponent(0.45).cgColor
        publishBtn_Retrs.layer.shadowOffset = CGSize(width: 0, height: 8)
        publishBtn_Retrs.layer.shadowOpacity = 1
        publishBtn_Retrs.layer.shadowRadius = 14
        publishBtn_Retrs.setTitle("  Publish Now", for: .normal)
        publishBtn_Retrs.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        publishBtn_Retrs.setTitleColor(.white, for: .normal)
        publishBtn_Retrs.addTarget(self, action: #selector(publishTapped_Retrs), for: .touchUpInside)
        contentView_Retrs.addSubview(publishBtn_Retrs)

        // 发送图标（文字左侧）
        let sendIV_Retrs = UIImageView(
            image: UIImage(systemName: "paperplane.fill",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold))
        )
        sendIV_Retrs.tintColor = UIColor.white.withAlphaComponent(0.9)
        sendIV_Retrs.contentMode = .scaleAspectFit
        publishBtn_Retrs.addSubview(sendIV_Retrs)
        sendIV_Retrs.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
            make.width.height.equalTo(17)
        }

        // EULA 链接
        let eulaBtn_Retrs = UIButton(type: .system)
        eulaBtn_Retrs.setAttributedTitle(
            NSAttributedString(string: "EULA", attributes: [
                .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                .foregroundColor: UIColor(hexstring_Retrs: "#B794F6").withAlphaComponent(0.65),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]), for: .normal
        )
        eulaBtn_Retrs.titleLabel?.numberOfLines = 1
        eulaBtn_Retrs.titleLabel?.adjustsFontSizeToFitWidth = true
        eulaBtn_Retrs.addTarget(self, action: #selector(eulaTapped_Retrs), for: .touchUpInside)
        contentView_Retrs.addSubview(eulaBtn_Retrs)
        eulaBtn_Retrs.snp.makeConstraints { make in
            make.top.equalTo(publishBtn_Retrs.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(20)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-130)
        }
    }

    // MARK: - 约束

    private func setupConstraints_Retrs() {
        let screenW_Retrs = UIScreen.main.bounds.width
        let safeTop_Retrs = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 44

        scrollView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(screenW_Retrs)
        }

        // 头部：安全区 + 内容高度
        headerView_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(safeTop_Retrs + 150)
        }

        // 媒体卡片（高度 230pt，突显上传优先级）
        mediaCard_Retrs.snp.makeConstraints { make in
            make.top.equalTo(headerView_Retrs.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(230)
        }

        // 标题卡片
        titleCard_Retrs.snp.makeConstraints { make in
            make.top.equalTo(mediaCard_Retrs.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        // 描述卡片
        descCard_Retrs.snp.makeConstraints { make in
            make.top.equalTo(titleCard_Retrs.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        // 发布按钮（胶囊形，高 60pt）
        publishBtn_Retrs.snp.makeConstraints { make in
            make.top.equalTo(descCard_Retrs.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(60)
        }
    }

    // MARK: - 事件

    @objc private func dismissKeyboard_Retrs() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow_Retrs(_ notification: Notification) {
        guard let kbFrame_Retrs = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        scrollView_Retrs.contentInset.bottom = kbFrame_Retrs.height + 20
    }

    @objc private func keyboardWillHide_Retrs(_ notification: Notification) {
        scrollView_Retrs.contentInset.bottom = 0
    }

    /// 选取媒体（图片或视频）
    @objc private func pickMediaTapped_Retrs() {
        MediaPickerHelper_Retrs.pickMedia_Retrs(from: self) { [weak self] result_Retrs in
            guard let self else { return }
            switch result_Retrs {
            case .photo_Retrs(let image_Retrs):
                self.selectedImage_Retrs    = image_Retrs
                self.selectedVideoURL_Retrs = nil
                self.mediaDisplayView_Retrs.configureWithImage_Retrs(image_Retrs: image_Retrs)
                self.mediaPath_Retrs = self.saveImageToDocuments_Retrs(image_Retrs: image_Retrs) ?? ""
                self.updateMediaPickerState_Retrs(hasMedia: true)
            case .video_Retrs(let url_Retrs):
                self.selectedVideoURL_Retrs = url_Retrs
                self.selectedImage_Retrs    = nil
                self.mediaPath_Retrs        = url_Retrs.path
                self.mediaDisplayView_Retrs.configure_Retrs(mediaPath_Retrs: url_Retrs.lastPathComponent, isVideo_Retrs: true)
                self.updateMediaPickerState_Retrs(hasMedia: true)
            case .cancelled_Retrs:
                break
            }
        }
    }

    /// 更新媒体选区视觉状态（显示/隐藏占位与更换徽章）
    /// - Parameter hasMedia: 是否已选择媒体
    private func updateMediaPickerState_Retrs(hasMedia: Bool) {
        mediaPlaceholderWrap_Retrs.isHidden = hasMedia
        mediaDashLayer_Retrs.isHidden       = hasMedia
        mediaChangeBadge_Retrs.isHidden     = !hasMedia
    }

    @objc private func eulaTapped_Retrs() {
        ProtocolHelper_Retrs.showProtocol_Retrs(type_Retrs: .eula_Retrs, content_Retrs: "eula.png", from: self)
    }

    /// 确认发布：校验 → 调用 ViewModel → 清空表单
    @objc private func publishTapped_Retrs() {
        publishBtn_Retrs.animatePressDown_Retrs { [weak self] in
            self?.publishBtn_Retrs.animatePressUp_Retrs()
        }

        guard userVM_Retrs.isLoggedIn_Retrs else {
            Navigation_Retrs.toLogin_Retrs(style_retrs: .present_retrs)
            return
        }

        let titleText_Retrs   = titleField_Retrs.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let contentText_Retrs = contentTextView_Retrs.text.trimmingCharacters(in: .whitespaces)

        guard !titleText_Retrs.isEmpty else {
            titleField_Retrs.animateShake_Retrs()
            Utils_Retrs.showWarning_Retrs(message_Retrs: "Please enter a title")
            return
        }
        guard !contentText_Retrs.isEmpty else {
            contentTextView_Retrs.animateShake_Retrs()
            Utils_Retrs.showWarning_Retrs(message_Retrs: "Please add some content")
            return
        }
        guard !mediaPath_Retrs.isEmpty else {
            mediaCard_Retrs.animateShake_Retrs()
            Utils_Retrs.showWarning_Retrs(message_Retrs: "Please add a photo or video")
            return
        }

        titleVM_Retrs.releasePost_Retrs(
            title_retrs: titleText_Retrs,
            content_retrs: contentText_Retrs,
            media_retrs: mediaPath_Retrs
        )
        clearForm_Retrs()
    }

    /// 清空所有表单数据，重置页面初始状态
    private func clearForm_Retrs() {
        titleField_Retrs.text      = ""
        contentTextView_Retrs.text = ""
        contentPlaceholder_Retrs.isHidden = false
        charCountLabel_Retrs.text  = "0 / 200"
        selectedImage_Retrs        = nil
        selectedVideoURL_Retrs     = nil
        mediaPath_Retrs            = ""
        mediaDisplayView_Retrs.configure_Retrs(mediaPath_Retrs: nil)
        updateMediaPickerState_Retrs(hasMedia: false)
    }

    /// 保存图片到沙盒文档目录，返回完整文件路径
    private func saveImageToDocuments_Retrs(image_Retrs: UIImage) -> String? {
        let fileName_Retrs = "post_img_\(Int(Date().timeIntervalSince1970)).jpg"
        let docURL_Retrs   = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Retrs  = docURL_Retrs.appendingPathComponent(fileName_Retrs)
        guard let data_Retrs = image_Retrs.jpegData(compressionQuality: 0.8) else { return nil }
        try? data_Retrs.write(to: fileURL_Retrs)
        return fileURL_Retrs.path
    }
}

// MARK: - UITextViewDelegate

extension Release_Retrs: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        contentPlaceholder_Retrs.isHidden = !textView.text.isEmpty
        let count_Retrs = min(textView.text.count, 200)
        charCountLabel_Retrs.text = "\(count_Retrs) / 200"
        charCountLabel_Retrs.textColor = textView.text.count > 200
            ? UIColor(hexstring_Retrs: "#FF6B9D")
            : ColorConfig_Retrs.textPlaceholder_Retrs
    }
}

// MARK: - 渐变层辅助视图（模块内私有）

/// 自动追踪父视图尺寸的渐变背景 UIView
private class ReleaseGradView_Retrs: UIView {

    private let gradLayer_Retrs = CAGradientLayer()

    /// 初始化渐变视图
    /// - Parameters:
    ///   - colors_Retrs: 渐变颜色数组（从起点到终点）
    ///   - startPoint_Retrs: 渐变起始点（0~1 归一化坐标）
    ///   - endPoint_Retrs: 渐变结束点（0~1 归一化坐标）
    init(colors_Retrs: [UIColor], startPoint_Retrs: CGPoint, endPoint_Retrs: CGPoint) {
        super.init(frame: .zero)
        gradLayer_Retrs.colors     = colors_Retrs.map { $0.cgColor }
        gradLayer_Retrs.startPoint = startPoint_Retrs
        gradLayer_Retrs.endPoint   = endPoint_Retrs
        layer.addSublayer(gradLayer_Retrs)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Retrs.frame = bounds
    }
}
