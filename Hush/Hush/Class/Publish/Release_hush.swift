import Foundation
import UIKit
import SnapKit
import AVFoundation

// MARK: 发布页面

/// 发布页面
/// 功能：用户发布街头随拍帖子，支持输入标题、内容，选择图片或视频，发布前验证登录状态
/// 设计：自定义顶部导航栏、大面积媒体预览区、卡片式输入区、渐变发布按钮
/// 关键方法：_handlePublish_Hush（发布逻辑）、_saveImageToDocuments_Hush（图片持久化）
class Release_Hush: UIViewController {

    // MARK: - 自定义导航栏组件

    /// 自定义顶部导航栏容器
    private let _navBar_Hush = UIView()

    /// 导航栏顶部装饰渐变（橙红横条）
    private let _navTopBand_Hush = UIView()
    private var _navTopBandGradient_Hush: CAGradientLayer?

    /// 导航栏渐变装饰线
    private let _navAccentLine_Hush = UIView()
    private var _navAccentGradient_Hush: CAGradientLayer?

    /// 关闭按钮
    private let _closeBtn_Hush = UIButton(type: .system)

    /// 导航标题
    private let _navTitle_Hush = UILabel()

    /// 导航副标题
    private let _navSubtitle_Hush = UILabel()

    /// 胶片卷装饰图标（导航栏右侧，低透明度）
    private let _filmIconView_Hush = UIImageView()

    // MARK: - 内容区组件

    /// 主滚动视图
    private let _scrollView_Hush = UIScrollView()

    /// 内容容器
    private let _contentView_Hush = UIView()

    // MARK: - 媒体选择区组件

    /// 媒体选择容器
    private let _mediaContainerView_Hush = UIView()

    /// 媒体边框装饰层（虚线渐变描边）
    private let _mediaDashLayer_Hush = CAShapeLayer()

    /// 媒体展示组件（选择后显示）
    private let _mediaDisplayView_Hush = MediaDisplayView_Hush()

    /// 占位视图（未选择时显示）
    private let _mediaPlaceholderView_Hush = UIView()

    /// 占位背景渐变层
    private var _mediaPlaceholderBgGradient_Hush: CAGradientLayer?

    /// 相机图标光晕圆圈
    private let _cameraHaloView_Hush = UIView()
    private var _cameraHaloGradient_Hush: CAGradientLayer?

    /// 相机图标（占位区）
    private let _cameraIconView_Hush = UIImageView()

    /// 占位主文字
    private let _mediaHintLabel_Hush = UILabel()

    /// 占位副文字
    private let _mediaSubHintLabel_Hush = UILabel()

    /// 底部操作提示标签（Photo · Video）
    private let _mediaTypeChipsView_Hush = UIView()

    /// 更换媒体按钮（已选择后右上角显示）
    private let _changeMediaBtn_Hush = UIButton(type: .system)

    // MARK: - 标题输入区组件

    /// 标题卡片容器
    private let _titleCard_Hush = UIView()

    /// 标题卡片左侧渐变色条
    private let _titleAccentStrip_Hush = UIView()
    private var _titleStripGradient_Hush: CAGradientLayer?

    /// 标题字段标签
    private let _titleSectionLabel_Hush = UILabel()

    /// 标题输入框
    private let _titleField_Hush = UITextField()

    /// 标题字数统计
    private let _titleCountLabel_Hush = UILabel()

    // MARK: - 内容输入区组件

    /// 内容卡片容器
    private let _contentCard_Hush = UIView()

    /// 内容卡片左侧渐变色条
    private let _contentAccentStrip_Hush = UIView()
    private var _contentStripGradient_Hush: CAGradientLayer?

    /// 内容字段标签
    private let _contentSectionLabel_Hush = UILabel()

    /// 内容文本输入框
    private let _contentTextView_Hush = UITextView()

    /// 内容占位符文字
    private let _contentPlaceholderLabel_Hush = UILabel()

    /// 内容字数统计
    private let _contentCountLabel_Hush = UILabel()

    // MARK: - 底部操作区组件

    /// 发布按钮
    private let _publishButton_Hush = UIButton(type: .custom)

    /// 发布按钮渐变图层
    private var _publishGradientLayer_Hush: CAGradientLayer?

    /// EULA 按钮
    private let _eulaButton_Hush = UIButton(type: .system)

    // MARK: - 数据属性

    /// 已选择的图片
    private var _selectedImage_Hush: UIImage?

    /// 已选择的视频 URL
    private var _selectedVideoURL_Hush: URL?

    private let _titleMaxCount_Hush = 60
    private let _contentMaxCount_Hush = 500
    private let _contentPlaceholder_Hush = "Share your street candid story..."

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUI_Hush()
        _setupConstraints_Hush()
        _setupKeyboardObservers_Hush()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 每次切换到发布 Tab 时重置表单，避免残留数据
        _clearForm_Hush()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if _publishGradientLayer_Hush == nil {
            _applyPublishGradient_Hush()
        } else {
            _publishGradientLayer_Hush?.frame = _publishButton_Hush.bounds
            _publishGradientLayer_Hush?.cornerRadius = 28
        }
        _navAccentGradient_Hush?.frame = _navAccentLine_Hush.bounds
        _navTopBandGradient_Hush?.frame = _navTopBand_Hush.bounds
        _titleStripGradient_Hush?.frame = _titleAccentStrip_Hush.bounds
        _contentStripGradient_Hush?.frame = _contentAccentStrip_Hush.bounds
        _mediaPlaceholderBgGradient_Hush?.frame = _mediaPlaceholderView_Hush.bounds
        _cameraHaloGradient_Hush?.frame = _cameraHaloView_Hush.bounds
        // 虚线边框路径同步更新（inset 1pt 确保描边不被 clipsToBounds 裁切）
        _mediaDashLayer_Hush.path = UIBezierPath(
            roundedRect: _mediaContainerView_Hush.bounds.insetBy(dx: 1, dy: 1),
            cornerRadius: 19
        ).cgPath
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 设置

    private func _setupUI_Hush() {
        view.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        _setupNavBar_Hush()
        _setupScrollContent_Hush()
        _setupMediaArea_Hush()
        _setupTitleCard_Hush()
        _setupContentCard_Hush()
        _setupBottomActions_Hush()
    }

    // MARK: 自定义导航栏

    /// 搭建自定义顶部导航栏
    /// 设计：顶部橙红渐变细条 + 居中标题 + 副标题 + 胶片卷装饰图标 + 渐变底部分割线
    private func _setupNavBar_Hush() {
        _navBar_Hush.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        view.addSubview(_navBar_Hush)

        // 顶部橙红渐变装饰条（4pt 高，横贯全宽）
        _navBar_Hush.addSubview(_navTopBand_Hush)
        let topBandGrad_Hush = CAGradientLayer()
        topBandGrad_Hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor
        ]
        topBandGrad_Hush.startPoint = CGPoint(x: 0, y: 0.5)
        topBandGrad_Hush.endPoint = CGPoint(x: 1, y: 0.5)
        _navTopBand_Hush.layer.addSublayer(topBandGrad_Hush)
        _navTopBandGradient_Hush = topBandGrad_Hush

        // 胶片卷装饰图标（右侧，低透明度）
        let filmConfig_Hush = UIImage.SymbolConfiguration(pointSize: 38, weight: .ultraLight)
        _filmIconView_Hush.image = UIImage(systemName: "film.stack", withConfiguration: filmConfig_Hush)
        _filmIconView_Hush.tintColor = ColorConfig_Hush.primaryGradientStart_Hush.withAlphaComponent(0.18)
        _filmIconView_Hush.contentMode = .scaleAspectFit
        _navBar_Hush.addSubview(_filmIconView_Hush)

        // 大标题（粗黑，居中）
        _navTitle_Hush.text = "New Story"
        _navTitle_Hush.font = .systemFont(ofSize: 20, weight: .black)
        _navTitle_Hush.textColor = ColorConfig_Hush.textPrimary_Hush
        _navTitle_Hush.textAlignment = .center
        _navBar_Hush.addSubview(_navTitle_Hush)

        // 副标题（带 ▌ 前缀强调）
        let subtitleAttrs_Hush = NSMutableAttributedString()
        subtitleAttrs_Hush.append(NSAttributedString(
            string: "▌ ",
            attributes: [.foregroundColor: ColorConfig_Hush.primaryGradientStart_Hush,
                         .font: UIFont.systemFont(ofSize: 11, weight: .black)]
        ))
        subtitleAttrs_Hush.append(NSAttributedString(
            string: "Share your street moment",
            attributes: [.foregroundColor: ColorConfig_Hush.textSecondary_Hush,
                         .font: UIFont.systemFont(ofSize: 11, weight: .medium)]
        ))
        _navSubtitle_Hush.attributedText = subtitleAttrs_Hush
        _navSubtitle_Hush.textAlignment = .center
        _navBar_Hush.addSubview(_navSubtitle_Hush)

        // 渐变底部装饰线（橙→红→透明，居左）
        _navBar_Hush.addSubview(_navAccentLine_Hush)
        let navGrad_Hush = CAGradientLayer()
        navGrad_Hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor,
            UIColor.clear.cgColor
        ]
        navGrad_Hush.locations = [0, 0.5, 1]
        navGrad_Hush.startPoint = CGPoint(x: 0, y: 0.5)
        navGrad_Hush.endPoint = CGPoint(x: 1, y: 0.5)
        _navAccentLine_Hush.layer.addSublayer(navGrad_Hush)
        _navAccentGradient_Hush = navGrad_Hush
    }

    // MARK: 滚动内容容器

    private func _setupScrollContent_Hush() {
        _scrollView_Hush.showsVerticalScrollIndicator = false
        _scrollView_Hush.alwaysBounceVertical = true
        _scrollView_Hush.keyboardDismissMode = .interactive
        // 底部留出 100pt 避免内容被浮动底栏遮挡
        _scrollView_Hush.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        view.addSubview(_scrollView_Hush)
        _scrollView_Hush.addSubview(_contentView_Hush)
    }

    // MARK: 媒体选择区

    /// 搭建媒体选择区域
    /// 设计：虚线描边 + 深色暗调占位背景 + 光晕圆圈相机图标 + 类型标签行 + 选中后全面积预览
    private func _setupMediaArea_Hush() {
        // 外层容器（不裁剪，用于展示虚线边框与阴影）
        _mediaContainerView_Hush.backgroundColor = ColorConfig_Hush.cardBackground_Hush
        _mediaContainerView_Hush.layer.cornerRadius = 20
        _mediaContainerView_Hush.clipsToBounds = true
        _mediaContainerView_Hush.layer.shadowColor = ColorConfig_Hush.primaryGradientStart_Hush.cgColor
        _mediaContainerView_Hush.layer.shadowOffset = CGSize(width: 0, height: 4)
        _mediaContainerView_Hush.layer.shadowOpacity = 0.12
        _mediaContainerView_Hush.layer.shadowRadius = 14
        _mediaContainerView_Hush.isUserInteractionEnabled = true
        _mediaContainerView_Hush.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(_pickMediaTapped_Hush))
        )
        _contentView_Hush.addSubview(_mediaContainerView_Hush)

        // 虚线渐变描边（橙色，在容器外层渲染）
        _mediaDashLayer_Hush.strokeColor = ColorConfig_Hush.primaryGradientStart_Hush.withAlphaComponent(0.55).cgColor
        _mediaDashLayer_Hush.fillColor = UIColor.clear.cgColor
        _mediaDashLayer_Hush.lineWidth = 2
        _mediaDashLayer_Hush.lineDashPattern = [9, 5]
        _mediaContainerView_Hush.layer.addSublayer(_mediaDashLayer_Hush)

        // 媒体展示（隐藏状态）
        _mediaDisplayView_Hush.isHidden = true
        _mediaContainerView_Hush.addSubview(_mediaDisplayView_Hush)

        // 占位视图（全面积覆盖）
        _mediaPlaceholderView_Hush.isUserInteractionEnabled = false
        _mediaContainerView_Hush.addSubview(_mediaPlaceholderView_Hush)

        // 占位深色渐变背景（暗调摄影风格：深灰→略暖黑）
        let bgGrad_Hush = CAGradientLayer()
        bgGrad_Hush.colors = [
            UIColor(hexstring_Hush: "#2E2926").cgColor,
            UIColor(hexstring_Hush: "#1A1614").cgColor
        ]
        bgGrad_Hush.startPoint = CGPoint(x: 0.5, y: 0)
        bgGrad_Hush.endPoint = CGPoint(x: 0.5, y: 1)
        _mediaPlaceholderView_Hush.layer.insertSublayer(bgGrad_Hush, at: 0)
        _mediaPlaceholderBgGradient_Hush = bgGrad_Hush

        // 相机图标光晕圆圈（渐变橙环）
        _cameraHaloView_Hush.layer.cornerRadius = 52
        _mediaPlaceholderView_Hush.addSubview(_cameraHaloView_Hush)
        let haloGrad_Hush = CAGradientLayer()
        haloGrad_Hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.withAlphaComponent(0.22).cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.withAlphaComponent(0.08).cgColor
        ]
        haloGrad_Hush.startPoint = CGPoint(x: 0, y: 0)
        haloGrad_Hush.endPoint = CGPoint(x: 1, y: 1)
        haloGrad_Hush.cornerRadius = 52
        _cameraHaloView_Hush.layer.addSublayer(haloGrad_Hush)
        _cameraHaloGradient_Hush = haloGrad_Hush

        // 相机图标（白色，居中）
        let camConfig_Hush = UIImage.SymbolConfiguration(pointSize: 38, weight: .thin)
        _cameraIconView_Hush.image = UIImage(systemName: "camera.aperture", withConfiguration: camConfig_Hush)
        _cameraIconView_Hush.tintColor = .white.withAlphaComponent(0.90)
        _cameraIconView_Hush.contentMode = .scaleAspectFit
        _mediaPlaceholderView_Hush.addSubview(_cameraIconView_Hush)

        // 主提示文字（白色）
        _mediaHintLabel_Hush.text = "Tap to add your shot"
        _mediaHintLabel_Hush.font = .systemFont(ofSize: 15, weight: .semibold)
        _mediaHintLabel_Hush.textColor = .white
        _mediaHintLabel_Hush.textAlignment = .center
        _mediaPlaceholderView_Hush.addSubview(_mediaHintLabel_Hush)

        // 副提示文字（橙色）
        _mediaSubHintLabel_Hush.text = "Photo  ·  Video"
        _mediaSubHintLabel_Hush.font = .systemFont(ofSize: 12, weight: .medium)
        _mediaSubHintLabel_Hush.textColor = ColorConfig_Hush.primaryGradientStart_Hush
        _mediaSubHintLabel_Hush.textAlignment = .center
        _mediaPlaceholderView_Hush.addSubview(_mediaSubHintLabel_Hush)

        // 底部类型徽章行（装饰性两个胶囊标签）
        _mediaTypeChipsView_Hush.isUserInteractionEnabled = false
        _mediaPlaceholderView_Hush.addSubview(_mediaTypeChipsView_Hush)
        _buildMediaTypeChips_Hush()

        // 更换媒体按钮（选择后右上角显示）
        var changeBtnConfig_Hush = UIButton.Configuration.plain()
        changeBtnConfig_Hush.title = "Change"
        changeBtnConfig_Hush.baseForegroundColor = .white
        changeBtnConfig_Hush.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer {
            var a = $0; a.font = .systemFont(ofSize: 12, weight: .semibold); return a
        }
        changeBtnConfig_Hush.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 12, bottom: 5, trailing: 12)
        _changeMediaBtn_Hush.configuration = changeBtnConfig_Hush
        _changeMediaBtn_Hush.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        _changeMediaBtn_Hush.layer.cornerRadius = 14
        _changeMediaBtn_Hush.isHidden = true
        _changeMediaBtn_Hush.addTarget(self, action: #selector(_pickMediaTapped_Hush), for: .touchUpInside)
        _mediaContainerView_Hush.addSubview(_changeMediaBtn_Hush)
    }

    /// 构建媒体区底部类型装饰标签（纯视觉）
    private func _buildMediaTypeChips_Hush() {
        let items_Hush: [(String, String)] = [("photo.fill", "Photo"), ("video.fill", "Video")]
        var lastView: UIView? = nil
        for (icon_Hush, text_Hush) in items_Hush {
            let chip_Hush = UIView()
            chip_Hush.backgroundColor = UIColor.white.withAlphaComponent(0.10)
            chip_Hush.layer.cornerRadius = 12
            chip_Hush.layer.borderWidth = 0.5
            chip_Hush.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
            _mediaTypeChipsView_Hush.addSubview(chip_Hush)

            let iconCfg_Hush = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
            let iconView_Hush = UIImageView(image: UIImage(systemName: icon_Hush, withConfiguration: iconCfg_Hush))
            iconView_Hush.tintColor = ColorConfig_Hush.primaryGradientStart_Hush
            iconView_Hush.contentMode = .scaleAspectFit
            chip_Hush.addSubview(iconView_Hush)

            let lbl_Hush = UILabel()
            lbl_Hush.text = text_Hush
            lbl_Hush.font = .systemFont(ofSize: 11, weight: .medium)
            lbl_Hush.textColor = .white.withAlphaComponent(0.80)
            chip_Hush.addSubview(lbl_Hush)

            iconView_Hush.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(10)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(12)
            }
            lbl_Hush.snp.makeConstraints { make in
                make.leading.equalTo(iconView_Hush.snp.trailing).offset(5)
                make.trailing.equalToSuperview().inset(10)
                make.centerY.equalToSuperview()
            }
            chip_Hush.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.height.equalTo(26)
                if let last = lastView {
                    make.leading.equalTo(last.snp.trailing).offset(10)
                } else {
                    make.leading.equalToSuperview()
                }
            }
            lastView = chip_Hush
        }
        lastView?.snp.makeConstraints { $0.trailing.equalToSuperview() }
    }

    // MARK: 标题输入卡片

    /// 搭建标题输入卡片（左侧渐变色条 + 字段标签 + 输入框 + 字数统计）
    private func _setupTitleCard_Hush() {
        _setupInputCard_Hush(
            card: _titleCard_Hush,
            strip: _titleAccentStrip_Hush,
            gradient: &_titleStripGradient_Hush
        )
        _contentView_Hush.addSubview(_titleCard_Hush)

        // 字段标签（带铅笔图标 + 字距）
        let titleIconAttrs_Hush = NSMutableAttributedString()
        let titleIconAttachment_Hush = NSTextAttachment()
        let titleIconCfg_Hush = UIImage.SymbolConfiguration(pointSize: 9, weight: .bold)
        titleIconAttachment_Hush.image = UIImage(systemName: "pencil.line", withConfiguration: titleIconCfg_Hush)?
            .withTintColor(ColorConfig_Hush.primaryGradientStart_Hush, renderingMode: .alwaysOriginal)
        titleIconAttrs_Hush.append(NSAttributedString(attachment: titleIconAttachment_Hush))
        titleIconAttrs_Hush.append(NSAttributedString(
            string: "  TITLE",
            attributes: [.font: UIFont.systemFont(ofSize: 10, weight: .bold),
                         .foregroundColor: ColorConfig_Hush.primaryGradientStart_Hush,
                         .kern: 1.2]
        ))
        _titleSectionLabel_Hush.attributedText = titleIconAttrs_Hush
        _titleCard_Hush.addSubview(_titleSectionLabel_Hush)

        // 输入框
        _titleField_Hush.placeholder = "Give your shot a title..."
        _titleField_Hush.font = .systemFont(ofSize: 16, weight: .semibold)
        _titleField_Hush.textColor = ColorConfig_Hush.textPrimary_Hush
        _titleField_Hush.backgroundColor = .clear
        _titleField_Hush.returnKeyType = .next
        _titleField_Hush.delegate = self
        _titleField_Hush.addTarget(self, action: #selector(_titleChanged_Hush(_:)), for: .editingChanged)
        _titleCard_Hush.addSubview(_titleField_Hush)

        // 字数统计
        _titleCountLabel_Hush.text = "0/\(_titleMaxCount_Hush)"
        _titleCountLabel_Hush.font = .systemFont(ofSize: 11)
        _titleCountLabel_Hush.textColor = ColorConfig_Hush.textPlaceholder_Hush
        _titleCountLabel_Hush.textAlignment = .right
        _titleCard_Hush.addSubview(_titleCountLabel_Hush)
    }

    // MARK: 内容输入卡片

    /// 搭建内容输入卡片（左侧渐变色条 + 字段标签 + 多行输入框 + 字数统计）
    private func _setupContentCard_Hush() {
        _setupInputCard_Hush(
            card: _contentCard_Hush,
            strip: _contentAccentStrip_Hush,
            gradient: &_contentStripGradient_Hush
        )
        _contentView_Hush.addSubview(_contentCard_Hush)

        // 字段标签（带引言图标 + 字距）
        let contentIconAttrs_Hush = NSMutableAttributedString()
        let contentIconAttachment_Hush = NSTextAttachment()
        let contentIconCfg_Hush = UIImage.SymbolConfiguration(pointSize: 9, weight: .bold)
        contentIconAttachment_Hush.image = UIImage(systemName: "text.quote", withConfiguration: contentIconCfg_Hush)?
            .withTintColor(ColorConfig_Hush.primaryGradientStart_Hush, renderingMode: .alwaysOriginal)
        contentIconAttrs_Hush.append(NSAttributedString(attachment: contentIconAttachment_Hush))
        contentIconAttrs_Hush.append(NSAttributedString(
            string: "  YOUR STORY",
            attributes: [.font: UIFont.systemFont(ofSize: 10, weight: .bold),
                         .foregroundColor: ColorConfig_Hush.primaryGradientStart_Hush,
                         .kern: 1.2]
        ))
        _contentSectionLabel_Hush.attributedText = contentIconAttrs_Hush
        _contentCard_Hush.addSubview(_contentSectionLabel_Hush)

        // 多行文本输入框
        _contentTextView_Hush.font = .systemFont(ofSize: 14, weight: .regular)
        _contentTextView_Hush.textColor = ColorConfig_Hush.textPrimary_Hush
        _contentTextView_Hush.backgroundColor = .clear
        _contentTextView_Hush.delegate = self
        _contentTextView_Hush.isScrollEnabled = false
        _contentTextView_Hush.textContainerInset = .zero
        _contentTextView_Hush.textContainer.lineFragmentPadding = 0
        _contentCard_Hush.addSubview(_contentTextView_Hush)

        // 占位符
        _contentPlaceholderLabel_Hush.text = _contentPlaceholder_Hush
        _contentPlaceholderLabel_Hush.font = .systemFont(ofSize: 14, weight: .regular)
        _contentPlaceholderLabel_Hush.textColor = ColorConfig_Hush.textPlaceholder_Hush
        _contentPlaceholderLabel_Hush.numberOfLines = 0
        _contentPlaceholderLabel_Hush.isUserInteractionEnabled = false
        _contentCard_Hush.addSubview(_contentPlaceholderLabel_Hush)

        // 字数统计
        _contentCountLabel_Hush.text = "0/\(_contentMaxCount_Hush)"
        _contentCountLabel_Hush.font = .systemFont(ofSize: 11)
        _contentCountLabel_Hush.textColor = ColorConfig_Hush.textPlaceholder_Hush
        _contentCountLabel_Hush.textAlignment = .right
        _contentCard_Hush.addSubview(_contentCountLabel_Hush)
    }

    /// 通用卡片外观设置（白底 + 圆角 + 阴影 + 左侧渐变色条）
    private func _setupInputCard_Hush(
        card: UIView,
        strip: UIView,
        gradient: inout CAGradientLayer?
    ) {
        card.backgroundColor = ColorConfig_Hush.cardBackground_Hush
        card.layer.cornerRadius = 16
        card.clipsToBounds = true
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowOpacity = 0.05
        card.layer.shadowRadius = 8

        card.addSubview(strip)
        let grad_Hush = CAGradientLayer()
        grad_Hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor
        ]
        grad_Hush.startPoint = CGPoint(x: 0.5, y: 0)
        grad_Hush.endPoint = CGPoint(x: 0.5, y: 1)
        strip.layer.addSublayer(grad_Hush)
        gradient = grad_Hush
    }

    // MARK: 底部操作区

    /// 搭建发布按钮与 EULA 链接
    private func _setupBottomActions_Hush() {
        // 发布按钮（大圆角 pill 样式）
        _publishButton_Hush.layer.cornerRadius = 28
        _publishButton_Hush.clipsToBounds = false
        _publishButton_Hush.addTarget(self, action: #selector(_publishTapped_Hush), for: .touchUpInside)
        _publishButton_Hush.addTarget(self, action: #selector(_publishPressDown_Hush), for: .touchDown)
        _publishButton_Hush.addTarget(self, action: #selector(_publishPressUp_Hush), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        _contentView_Hush.addSubview(_publishButton_Hush)

        // 按钮内容（相机图标 + 文字）
        var btnConfig_Hush = UIButton.Configuration.plain()
        btnConfig_Hush.image = UIImage(
            systemName: "camera.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        )
        btnConfig_Hush.imagePadding = 10
        btnConfig_Hush.imagePlacement = .leading
        btnConfig_Hush.title = "Publish Story"
        btnConfig_Hush.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var o = attrs; o.font = .systemFont(ofSize: 17, weight: .bold); return o
        }
        btnConfig_Hush.baseForegroundColor = .white
        _publishButton_Hush.configuration = btnConfig_Hush

        // EULA 按钮（下划线）
        let eulaAttrs_Hush: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: ColorConfig_Hush.textSecondary_Hush,
            .font: UIFont.systemFont(ofSize: 12)
        ]
        _eulaButton_Hush.setAttributedTitle(NSAttributedString(string: "EULA", attributes: eulaAttrs_Hush), for: .normal)
        _eulaButton_Hush.addTarget(self, action: #selector(_eulaTapped_Hush), for: .touchUpInside)
        _contentView_Hush.addSubview(_eulaButton_Hush)
    }

    /// 为发布按钮应用橙红渐变背景（渐变层同步圆角，确保视觉一致）
    private func _applyPublishGradient_Hush() {
        _publishGradientLayer_Hush?.removeFromSuperlayer()
        let grad_Hush = UIColor.createPrimaryGradientLayer_Hush(frame_Hush: _publishButton_Hush.bounds)
        // 渐变层圆角与按钮保持一致，避免边角溢出
        grad_Hush.cornerRadius = 28
        _publishButton_Hush.layer.insertSublayer(grad_Hush, at: 0)
        _publishGradientLayer_Hush = grad_Hush

        // 按钮橙色阴影
        _publishButton_Hush.layer.shadowColor = ColorConfig_Hush.primaryGradientStart_Hush.cgColor
        _publishButton_Hush.layer.shadowOffset = CGSize(width: 0, height: 6)
        _publishButton_Hush.layer.shadowOpacity = 0.35
        _publishButton_Hush.layer.shadowRadius = 12
        _publishButton_Hush.layer.masksToBounds = false
    }

    // MARK: - 约束布局

    private func _setupConstraints_Hush() {
        // 自定义导航栏
        _navBar_Hush.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(76)
        }
        _navTopBand_Hush.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(4)
        }
        _filmIconView_Hush.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(_navTitle_Hush)
            make.width.height.equalTo(46)
        }
        _navTitle_Hush.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(_navSubtitle_Hush.snp.top).offset(-3)
        }
        _navSubtitle_Hush.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(12)
        }
        _navAccentLine_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.width.equalToSuperview().multipliedBy(0.5)
            make.bottom.equalToSuperview()
            make.height.equalTo(1.5)
        }

        // 滚动视图
        _scrollView_Hush.snp.makeConstraints { make in
            make.top.equalTo(_navBar_Hush.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        _contentView_Hush.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(_scrollView_Hush)
        }

        // 媒体选择区（16:9.5 比例）
        _mediaContainerView_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(_mediaContainerView_Hush.snp.width).multipliedBy(0.62)
        }
        _mediaDisplayView_Hush.snp.makeConstraints { $0.edges.equalToSuperview() }
        _mediaPlaceholderView_Hush.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 光晕圆圈：上移，为下方三行文字 + chips 留足空间
        _cameraHaloView_Hush.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-38)
            make.width.height.equalTo(100)
        }
        _cameraIconView_Hush.snp.makeConstraints { make in
            make.center.equalTo(_cameraHaloView_Hush)
            make.width.height.equalTo(48)
        }
        // 主提示文字：光晕下方
        _mediaHintLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(_cameraHaloView_Hush.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }
        // 副提示文字：主文字下方
        _mediaSubHintLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(_mediaHintLabel_Hush.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
        // chips 标签行：副文字下方，顺序排列，避免遮挡
        _mediaTypeChipsView_Hush.snp.makeConstraints { make in
            make.top.equalTo(_mediaSubHintLabel_Hush.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }
        _changeMediaBtn_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }

        // 标题卡片
        _titleCard_Hush.snp.makeConstraints { make in
            make.top.equalTo(_mediaContainerView_Hush.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        _titleAccentStrip_Hush.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(4)
        }
        _titleSectionLabel_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(18)
        }
        _titleField_Hush.snp.makeConstraints { make in
            make.top.equalTo(_titleSectionLabel_Hush.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(36)
        }
        _titleCountLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(_titleField_Hush.snp.bottom).offset(6)
            make.trailing.equalToSuperview().inset(14)
            make.bottom.equalToSuperview().inset(12)
        }

        // 内容卡片
        _contentCard_Hush.snp.makeConstraints { make in
            make.top.equalTo(_titleCard_Hush.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        _contentAccentStrip_Hush.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(4)
        }
        _contentSectionLabel_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(18)
        }
        _contentTextView_Hush.snp.makeConstraints { make in
            make.top.equalTo(_contentSectionLabel_Hush.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-14)
            make.height.greaterThanOrEqualTo(100)
        }
        _contentPlaceholderLabel_Hush.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(_contentTextView_Hush)
        }
        _contentCountLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(_contentTextView_Hush.snp.bottom).offset(6)
            make.trailing.equalToSuperview().inset(14)
            make.bottom.equalToSuperview().inset(12)
        }

        // 发布按钮
        _publishButton_Hush.snp.makeConstraints { make in
            make.top.equalTo(_contentCard_Hush.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(56)
        }

        // EULA
        _eulaButton_Hush.snp.makeConstraints { make in
            make.top.equalTo(_publishButton_Hush.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 键盘观察

    private func _setupKeyboardObservers_Hush() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(_keyboardWillShow_Hush(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(_keyboardWillHide_Hush(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    // MARK: - 事件处理

    /// 关闭/返回按钮点击：清空表单并切换回 Home Tab
    @objc private func _closeTapped_Hush() {
        view.endEditing(true)
        _clearForm_Hush()
        _switchToHome_Hush()
    }

    /// 媒体选择区域点击
    @objc private func _pickMediaTapped_Hush() {
        MediaPickerHelper_Hush.pickMedia_Hush(from: self) { [weak self] result_Hush in
            guard let self = self else { return }
            switch result_Hush {
            case .photo_Hush(let image_Hush):
                self._selectedImage_Hush = image_Hush
                self._selectedVideoURL_Hush = nil
                self._mediaDisplayView_Hush.configureWithImage_Hush(image_Hush: image_Hush)
                self._showMediaPreview_Hush()
            case .video_Hush(let url_Hush):
                self._selectedVideoURL_Hush = url_Hush
                self._selectedImage_Hush = nil
                self._generateVideoThumbnail_Hush(url_Hush: url_Hush)
            case .cancelled_Hush:
                break
            }
        }
    }

    /// 标题文字变化回调，更新字数统计
    @objc private func _titleChanged_Hush(_ tf: UITextField) {
        let count = tf.text?.count ?? 0
        _titleCountLabel_Hush.text = "\(count)/\(_titleMaxCount_Hush)"
        _titleCountLabel_Hush.textColor = count > _titleMaxCount_Hush
            ? ColorConfig_Hush.primaryGradientEnd_Hush
            : ColorConfig_Hush.textPlaceholder_Hush
    }

    /// 发布按钮点击：校验 → 处理媒体 → 发布 → 关闭
    @objc private func _publishTapped_Hush() {
        if !UserViewModel_Hush.shared_Hush.isLoggedIn_Hush {
            Navigation_Hush.toLogin_Hush(style_hush: .present_hush)
            return
        }
        guard let titleText_Hush = _titleField_Hush.text,
              !titleText_Hush.trimmingCharacters(in: .whitespaces).isEmpty else {
            Utils_Hush.showWarning_Hush(message_Hush: "Please enter a title.")
            _titleField_Hush.becomeFirstResponder()
            return
        }
        let contentText_Hush = _contentTextView_Hush.text ?? ""
        guard !contentText_Hush.trimmingCharacters(in: .whitespaces).isEmpty else {
            Utils_Hush.showWarning_Hush(message_Hush: "Please enter some content.")
            _contentTextView_Hush.becomeFirstResponder()
            return
        }
        guard _selectedImage_Hush != nil || _selectedVideoURL_Hush != nil else {
            Utils_Hush.showWarning_Hush(message_Hush: "Please select a photo or video.")
            return
        }

        let mediaPath_Hush: String
        let mediaType_Hush: Int
        if let videoURL_Hush = _selectedVideoURL_Hush {
            mediaPath_Hush = videoURL_Hush.absoluteString
            mediaType_Hush = 1
        } else if let image_Hush = _selectedImage_Hush {
            mediaPath_Hush = _saveImageToDocuments_Hush(image_Hush: image_Hush)
            mediaType_Hush = 0
        } else { return }

        TitleViewModel_Hush.shared_Hush.releasePost_Hush(
            title_hush: titleText_Hush.trimmingCharacters(in: .whitespaces),
            content_hush: contentText_Hush.trimmingCharacters(in: .whitespaces),
            media_hush: mediaPath_Hush,
            type_hush: mediaType_Hush
        )
        _clearForm_Hush()
        _switchToHome_Hush()
    }

    @objc private func _publishPressDown_Hush() {
        _publishButton_Hush.animatePressDown_Hush(completion_Hush: nil)
    }

    @objc private func _publishPressUp_Hush() {
        _publishButton_Hush.animatePressUp_Hush(completion_Hush: nil)
    }

    @objc private func _eulaTapped_Hush() {
        ProtocolHelper_Hush.showProtocol_Hush(type_Hush: .eula_Hush, content_Hush: "eula.png", from: self)
    }

    @objc private func _keyboardWillShow_Hush(_ notification: Notification) {
        guard let frame_Hush = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        _scrollView_Hush.contentInset.bottom = frame_Hush.height + 16
        _scrollView_Hush.scrollIndicatorInsets.bottom = frame_Hush.height
    }

    @objc private func _keyboardWillHide_Hush(_ notification: Notification) {
        _scrollView_Hush.contentInset.bottom = 0
        _scrollView_Hush.scrollIndicatorInsets.bottom = 0
    }

    // MARK: - 私有辅助方法

    /// 显示媒体预览并展示更换按钮
    private func _showMediaPreview_Hush() {
        _mediaPlaceholderView_Hush.isHidden = true
        _mediaDisplayView_Hush.isHidden = false
        _changeMediaBtn_Hush.isHidden = false
    }

    /// 从视频 URL 提取第一帧缩略图
    private func _generateVideoThumbnail_Hush(url_Hush: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let asset_Hush = AVURLAsset(url: url_Hush)
            let gen_Hush = AVAssetImageGenerator(asset: asset_Hush)
            gen_Hush.appliesPreferredTrackTransform = true
            let time_Hush = CMTime(seconds: 0.1, preferredTimescale: 600)
            do {
                let cgImg_Hush = try gen_Hush.copyCGImage(at: time_Hush, actualTime: nil)
                let thumb_Hush = UIImage(cgImage: cgImg_Hush)
                DispatchQueue.main.async {
                    self?._mediaDisplayView_Hush.configureWithImage_Hush(image_Hush: thumb_Hush)
                    self?._showMediaPreview_Hush()
                }
            } catch {
                DispatchQueue.main.async {
                    self?._mediaDisplayView_Hush.configure_Hush(mediaPath_Hush: nil, isVideo_Hush: true)
                    self?._showMediaPreview_Hush()
                }
            }
        }
    }

    /// 将图片保存到沙盒 Documents 目录，返回文件名
    private func _saveImageToDocuments_Hush(image_Hush: UIImage) -> String {
        let fileName_Hush = "hush_post_\(Int(Date().timeIntervalSince1970)).jpg"
        let dir_Hush = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url_Hush = dir_Hush.appendingPathComponent(fileName_Hush)
        if let data_Hush = image_Hush.jpegData(compressionQuality: 0.8) {
            try? data_Hush.write(to: url_Hush)
            print("图片已保存到沙盒：\(fileName_Hush)")
        }
        return fileName_Hush
    }

    /// 切换回 Home Tab（index 0）
    private func _switchToHome_Hush() {
        if let tabBar_hush = tabBarController as? TabBar_Hush {
            tabBar_hush.switchTab_Hush(to: 0)
        } else {
            tabBarController?.selectedIndex = 0
        }
    }

    /// 发布成功后清空表单
    private func _clearForm_Hush() {
        _titleField_Hush.text = nil
        _titleCountLabel_Hush.text = "0/\(_titleMaxCount_Hush)"
        _contentTextView_Hush.text = nil
        _contentPlaceholderLabel_Hush.isHidden = false
        _contentCountLabel_Hush.text = "0/\(_contentMaxCount_Hush)"
        _selectedImage_Hush = nil
        _selectedVideoURL_Hush = nil
        _mediaDisplayView_Hush.isHidden = true
        _mediaPlaceholderView_Hush.isHidden = false
        _changeMediaBtn_Hush.isHidden = true
    }
}

// MARK: - UITextFieldDelegate

extension Release_Hush: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        _contentTextView_Hush.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension Release_Hush: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.count
        _contentPlaceholderLabel_Hush.isHidden = !textView.text.isEmpty
        _contentCountLabel_Hush.text = "\(count)/\(_contentMaxCount_Hush)"
        _contentCountLabel_Hush.textColor = count > _contentMaxCount_Hush
            ? ColorConfig_Hush.primaryGradientEnd_Hush
            : ColorConfig_Hush.textPlaceholder_Hush
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        _contentPlaceholderLabel_Hush.isHidden = true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        _contentPlaceholderLabel_Hush.isHidden = textView.text.isEmpty
    }
}

// MARK: - UILabel 字距扩展

private extension UILabel {
    /// 设置字母间距
    func letterSpacing_Hush(spacing_Hush: CGFloat) {
        guard let text = text else { return }
        let attrs: [NSAttributedString.Key: Any] = [
            .kern: spacing_Hush,
            .foregroundColor: textColor as Any,
            .font: font as Any
        ]
        attributedText = NSAttributedString(string: text, attributes: attrs)
    }
}
