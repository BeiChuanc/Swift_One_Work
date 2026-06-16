import Foundation
import UIKit
import SnapKit

// MARK: 发布页面

/// 发布页面视图控制器
/// 功能：填写标题、内容，从相册选取图片或视频，提交发布帖子
/// 设计：个人化头部（用户头像）+ 大型媒体上传区（虚线边框+呼吸动画）
///       统一表单卡片（图标 + 输入框 + 字符计数）+ 彩色渐变发布按钮
/// 关键逻辑：优先校验登录态，再校验表单，发布后清空表单
class Release_Niche: UIViewController {

    // MARK: - 私有属性

    /// 已选取的媒体图片
    private var _selectedImage_niche: UIImage?
    /// 已选取的视频 URL
    private var _selectedVideoURL_niche: URL?
    /// 媒体上传区虚线边框图层
    private var _dashedBorderLayer_niche: CAShapeLayer?

    // MARK: - UI 组件 / 头部区域

    /// 头部背景（渐变光晕）
    private let _headerBg_niche = UIView()

    /// 装饰性右上角气泡
    private let _headerBlob_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = ColorConfig_Niche.primaryGradientStart_Niche.withValues(alpha: 0.13)
        v_niche.layer.cornerRadius = 50
        v_niche.isUserInteractionEnabled = false
        return v_niche
    }()

    /// 标题装饰符
    private let _titleDecorLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "✦"
        l_niche.font = UIFont.systemFont(ofSize: 15)
        l_niche.textColor = ColorConfig_Niche.primaryGradientStart_Niche
        return l_niche
    }()

    /// 页面主标题
    private let _pageTitleLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Create Your Post"
        l_niche.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        l_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        return l_niche
    }()

    /// 副标题
    private let _headerSubtitle_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Share your vibe with the tribe"
        l_niche.font = UIFont.systemFont(ofSize: 13)
        l_niche.textColor = ColorConfig_Niche.textSecondary_Niche
        return l_niche
    }()


    // MARK: - UI 组件 / 媒体上传区

    /// 媒体上传整体容器
    private let _mediaZone_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor(hexstring_Niche: "#F8F6FF")
        v_niche.layer.cornerRadius = 20
        v_niche.isUserInteractionEnabled = true
        return v_niche
    }()

    /// 占位内容栈（上传图标 + 文字 + 类型胶囊）
    private let _uploadStack_niche: UIStackView = {
        let sv_niche = UIStackView()
        sv_niche.axis = .vertical
        sv_niche.alignment = .center
        sv_niche.spacing = 10
        sv_niche.isUserInteractionEnabled = false
        return sv_niche
    }()

    /// 上传图标容器（渐变圆背景）
    private let _uploadIconBg_niche: UIView = {
        let v_niche = UIView()
        v_niche.layer.cornerRadius = 30
        return v_niche
    }()

    private let _uploadIcon_niche: UIImageView = {
        let iv_niche = UIImageView()
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
        iv_niche.image = UIImage(systemName: "plus.viewfinder", withConfiguration: cfg_niche)
        iv_niche.tintColor = .white
        iv_niche.contentMode = .scaleAspectFit
        return iv_niche
    }()

    private let _uploadTitleLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Add Photo or Video"
        l_niche.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        l_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        return l_niche
    }()

    private let _uploadHintLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "From your camera roll"
        l_niche.font = UIFont.systemFont(ofSize: 12)
        l_niche.textColor = ColorConfig_Niche.textSecondary_Niche
        return l_niche
    }()

    /// 支持类型胶囊横排
    private let _typePillRow_niche: UIStackView = {
        let sv_niche = UIStackView()
        sv_niche.axis = .horizontal
        sv_niche.spacing = 8
        sv_niche.alignment = .center
        return sv_niche
    }()

    /// 媒体展示视图（有媒体时显示）
    private let _mediaDisplayView_niche = MediaDisplayView_Niche()

    /// 已选媒体后的更换按钮（玻璃风格）
    private let _changeMediaBtn_niche: UIButton = {
        let btn_niche = UIButton(type: .custom)
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn_niche.setImage(UIImage(systemName: "arrow.triangle.2.circlepath", withConfiguration: cfg_niche), for: .normal)
        btn_niche.tintColor = .white
        btn_niche.backgroundColor = UIColor.black.withValues(alpha: 0.45)
        btn_niche.layer.cornerRadius = 20
        btn_niche.isHidden = true
        return btn_niche
    }()

    /// 已选媒体类型标签（左上角胶囊）
    private let _mediaTypeBadge_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        l_niche.textColor = .white
        l_niche.textAlignment = .center
        l_niche.layer.cornerRadius = 9
        l_niche.layer.masksToBounds = true
        l_niche.isHidden = true
        return l_niche
    }()

    // MARK: - UI 组件 / 表单区域

    /// 表单卡片容器
    private let _formCard_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = .white
        v_niche.layer.cornerRadius = 20
        v_niche.layer.shadowColor = UIColor.black.withValues(alpha: 0.06).cgColor
        v_niche.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_niche.layer.shadowRadius = 14
        v_niche.layer.shadowOpacity = 1
        return v_niche
    }()

    /// 标题区块标签
    private let _titleSectionLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "TITLE"
        l_niche.font = UIFont.systemFont(ofSize: 10, weight: .heavy)
        l_niche.textColor = ColorConfig_Niche.primaryGradientStart_Niche
        l_niche.letterSpacing_Niche(spacing: 1.5)
        return l_niche
    }()

    /// 标题图标
    private let _titleIcon_niche: UIImageView = {
        let iv_niche = UIImageView()
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        iv_niche.image = UIImage(systemName: "pencil.line", withConfiguration: cfg_niche)
        iv_niche.tintColor = ColorConfig_Niche.primaryGradientStart_Niche
        iv_niche.contentMode = .scaleAspectFit
        return iv_niche
    }()

    /// 标题输入框
    private let _titleField_niche: UITextField = {
        let tf_niche = UITextField()
        tf_niche.placeholder = "Give your story a title..."
        tf_niche.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tf_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        tf_niche.backgroundColor = .clear
        tf_niche.autocapitalizationType = .sentences
        tf_niche.autocorrectionType = .no
        return tf_niche
    }()

    /// 表单内分割线
    private let _formDivider_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = ColorConfig_Niche.divider_Niche
        return v_niche
    }()

    /// 内容区块标签
    private let _contentSectionLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "STORY"
        l_niche.font = UIFont.systemFont(ofSize: 10, weight: .heavy)
        l_niche.textColor = ColorConfig_Niche.secondaryGradientStart_Niche
        l_niche.letterSpacing_Niche(spacing: 1.5)
        return l_niche
    }()

    /// 内容图标
    private let _contentIcon_niche: UIImageView = {
        let iv_niche = UIImageView()
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        iv_niche.image = UIImage(systemName: "text.alignleft", withConfiguration: cfg_niche)
        iv_niche.tintColor = ColorConfig_Niche.secondaryGradientStart_Niche
        iv_niche.contentMode = .scaleAspectFit
        return iv_niche
    }()

    /// 内容输入框
    private let _contentTextView_niche: UITextView = {
        let tv_niche = UITextView()
        tv_niche.font = UIFont.systemFont(ofSize: 15)
        tv_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        tv_niche.backgroundColor = .clear
        tv_niche.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tv_niche.textContainer.lineFragmentPadding = 0
        return tv_niche
    }()

    /// 内容占位符
    private let _contentPlaceholder_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "What's your story? Share the vibe..."
        l_niche.font = UIFont.systemFont(ofSize: 15)
        l_niche.textColor = ColorConfig_Niche.textPlaceholder_Niche
        l_niche.numberOfLines = 0
        return l_niche
    }()

    /// 字符计数标签
    private let _charCountLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "0/500"
        l_niche.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        l_niche.textColor = ColorConfig_Niche.textPlaceholder_Niche
        l_niche.textAlignment = .right
        return l_niche
    }()

    // MARK: - UI 组件 / 操作区域

    /// 发布按钮（渐变）
    private let _publishButton_niche: UIButton = {
        let btn_niche = UIButton(type: .custom)
        btn_niche.layer.cornerRadius = 18
        btn_niche.clipsToBounds = true
        return btn_niche
    }()

    /// 发布按钮图标
    private let _publishIcon_niche: UIImageView = {
        let iv_niche = UIImageView()
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)
        iv_niche.image = UIImage(systemName: "paperplane.fill", withConfiguration: cfg_niche)
        iv_niche.tintColor = .white
        iv_niche.contentMode = .scaleAspectFit
        iv_niche.isUserInteractionEnabled = false
        return iv_niche
    }()

    /// 发布按钮文字
    private let _publishLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Publish to Tribe"
        l_niche.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        l_niche.textColor = .white
        l_niche.isUserInteractionEnabled = false
        return l_niche
    }()

    /// EULA 链接
    private let _eulaButton_niche: UIButton = {
        let btn_niche = UIButton(type: .system)
        let attrs_niche: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorConfig_Niche.textSecondary_Niche,
            .font: UIFont.systemFont(ofSize: 12),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        btn_niche.setAttributedTitle(
            NSAttributedString(string: "EULA", attributes: attrs_niche),
            for: .normal
        )
        return btn_niche
    }()

    /// 滚动视图
    private let _scrollView_niche: UIScrollView = {
        let sv_niche = UIScrollView()
        sv_niche.showsVerticalScrollIndicator = false
        sv_niche.keyboardDismissMode = .onDrag
        return sv_niche
    }()

    private let _contentView_niche = UIView()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Niche()
        setupActions_Niche()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshPublishGradient_Niche()
        refreshHeaderGradient_Niche()
        refreshUploadIconGradient_Niche()
        refreshDashedBorder_Niche()
        refreshMediaTypeBadgeGradient_Niche()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 构建

    private func setupUI_Niche() {
        view.backgroundColor = UIColor(hexstring_Niche: "#F4F0FF")

        // ── 头部 ──────────────────────────────────────
        view.addSubview(_headerBg_niche)
        _headerBg_niche.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(150)
        }

        _headerBg_niche.addSubview(_headerBlob_niche)
        _headerBlob_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-10)
            make.trailing.equalToSuperview().offset(10)
            make.width.height.equalTo(100)
        }

        // 标题装饰符
        _headerBg_niche.addSubview(_titleDecorLabel_niche)
        _titleDecorLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(18)
            make.leading.equalToSuperview().offset(20)
        }

        // 主标题
        _headerBg_niche.addSubview(_pageTitleLabel_niche)
        _pageTitleLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_titleDecorLabel_niche.snp.bottom).offset(2)
            make.leading.equalToSuperview().offset(20)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
        }

        // 副标题
        _headerBg_niche.addSubview(_headerSubtitle_niche)
        _headerSubtitle_niche.snp.makeConstraints { make in
            make.top.equalTo(_pageTitleLabel_niche.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(20)
        }

        // ── 滚动区 ─────────────────────────────────────
        view.addSubview(_scrollView_niche)
        _scrollView_niche.snp.makeConstraints { make in
            make.top.equalTo(_headerBg_niche.snp.bottom).offset(-10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        _scrollView_niche.addSubview(_contentView_niche)
        _contentView_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        buildMediaZone_Niche()
        buildFormCard_Niche()
        buildActionArea_Niche()
    }

    // MARK: - 媒体上传区构建

    private func buildMediaZone_Niche() {
        _contentView_niche.addSubview(_mediaZone_niche)
        _mediaZone_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(220)
        }

        // 已选媒体展示（铺满，默认隐藏）
        _mediaZone_niche.addSubview(_mediaDisplayView_niche)
        _mediaDisplayView_niche.layer.cornerRadius = 20
        _mediaDisplayView_niche.isHidden = true
        _mediaDisplayView_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 占位内容栈（图标 + 标题 + 提示 + 类型胶囊）
        _mediaZone_niche.addSubview(_uploadStack_niche)
        _uploadStack_niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // 图标圆形背景
        _uploadStack_niche.addArrangedSubview(_uploadIconBg_niche)
        _uploadIconBg_niche.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }

        _uploadIconBg_niche.addSubview(_uploadIcon_niche)
        _uploadIcon_niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }

        _uploadStack_niche.addArrangedSubview(_uploadTitleLabel_niche)
        _uploadStack_niche.addArrangedSubview(_uploadHintLabel_niche)

        // 类型胶囊行
        buildTypePills_Niche()
        _uploadStack_niche.addArrangedSubview(_typePillRow_niche)
        _uploadStack_niche.setCustomSpacing(14, after: _uploadHintLabel_niche)

        // 更换媒体按钮（右下角）
        _mediaZone_niche.addSubview(_changeMediaBtn_niche)
        _changeMediaBtn_niche.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(40)
        }

        // 媒体类型徽章（左上角）
        _mediaZone_niche.addSubview(_mediaTypeBadge_niche)
        _mediaTypeBadge_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(48)
        }
    }

    /// 构建媒体类型胶囊（Photo / Video）
    private func buildTypePills_Niche() {
        let types_niche: [(emoji: String, name: String, color: UIColor)] = [
            ("📷", "Photo", ColorConfig_Niche.primaryGradientStart_Niche),
            ("🎬", "Video", ColorConfig_Niche.secondaryGradientStart_Niche)
        ]
        for item_niche in types_niche {
            let pill_niche = buildPill_Niche(emoji: item_niche.emoji, text: item_niche.name, color: item_niche.color)
            _typePillRow_niche.addArrangedSubview(pill_niche)
        }
    }

    private func buildPill_Niche(emoji: String, text: String, color: UIColor) -> UIView {
        let pill_niche = UIView()
        pill_niche.backgroundColor = color.withValues(alpha: 0.12)
        pill_niche.layer.cornerRadius = 12

        let label_niche = UILabel()
        label_niche.text = "\(emoji) \(text)"
        label_niche.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label_niche.textColor = color

        pill_niche.addSubview(label_niche)
        label_niche.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        return pill_niche
    }

    // MARK: - 表单卡片构建

    private func buildFormCard_Niche() {
        _contentView_niche.addSubview(_formCard_niche)
        _formCard_niche.snp.makeConstraints { make in
            make.top.equalTo(_mediaZone_niche.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(18)
        }

        // ── 标题区块 ──
        _formCard_niche.addSubview(_titleSectionLabel_niche)
        _titleSectionLabel_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalToSuperview().offset(18)
        }

        // 先都 addSubview 到 _formCard_niche 再设约束，避免跨层级崩溃
        _formCard_niche.addSubview(_titleIcon_niche)
        _formCard_niche.addSubview(_titleField_niche)

        _titleIcon_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.top.equalTo(_titleSectionLabel_niche.snp.bottom).offset(8)
            make.width.height.equalTo(22)
        }

        _titleField_niche.snp.makeConstraints { make in
            make.leading.equalTo(_titleIcon_niche.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-18)
            make.centerY.equalTo(_titleIcon_niche)
            make.height.equalTo(44)
        }
        _titleField_niche.placeHolderTextColor_Niche(ColorConfig_Niche.textPlaceholder_Niche)

        // ── 分割线 ──
        _formCard_niche.addSubview(_formDivider_niche)
        _formDivider_niche.snp.makeConstraints { make in
            make.top.equalTo(_titleField_niche.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(0.5)
        }

        // ── 内容区块 ──
        _formCard_niche.addSubview(_contentSectionLabel_niche)
        _contentSectionLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_formDivider_niche.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(18)
        }

        _formCard_niche.addSubview(_contentIcon_niche)
        _formCard_niche.addSubview(_contentTextView_niche)
        _formCard_niche.addSubview(_contentPlaceholder_niche)
        _formCard_niche.addSubview(_charCountLabel_niche)

        _contentIcon_niche.snp.makeConstraints { make in
            make.top.equalTo(_contentSectionLabel_niche.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(22)
        }

        _contentTextView_niche.snp.makeConstraints { make in
            make.top.equalTo(_contentSectionLabel_niche.snp.bottom).offset(8)
            make.leading.equalTo(_contentIcon_niche.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(120)
        }

        _contentPlaceholder_niche.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(_contentTextView_niche)
        }

        _charCountLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_contentTextView_niche.snp.bottom).offset(6)
            make.trailing.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(-14)
        }
    }

    // MARK: - 操作区构建

    private func buildActionArea_Niche() {
        // 发布按钮（自定义内容，clipsToBounds 裁切渐变）
        _contentView_niche.addSubview(_publishButton_niche)
        _publishButton_niche.snp.makeConstraints { make in
            make.top.equalTo(_formCard_niche.snp.bottom).offset(22)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(56)
        }

        // 按钮内容：图标 + 文字
        _publishButton_niche.addSubview(_publishIcon_niche)
        _publishButton_niche.addSubview(_publishLabel_niche)

        _publishIcon_niche.snp.makeConstraints { make in
            make.trailing.equalTo(_publishLabel_niche.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        _publishLabel_niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        // EULA 链接
        _contentView_niche.addSubview(_eulaButton_niche)
        _eulaButton_niche.snp.makeConstraints { make in
            make.top.equalTo(_publishButton_niche.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
        }
    }

    // MARK: - 渐变图层刷新

    private func refreshPublishGradient_Niche() {
        _publishButton_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        guard !_publishButton_niche.bounds.isEmpty else { return }
        let grad_niche = CAGradientLayer()
        grad_niche.frame = _publishButton_niche.bounds
        grad_niche.colors = [
            ColorConfig_Niche.primaryGradientStart_Niche.cgColor,
            ColorConfig_Niche.primaryGradientEnd_Niche.cgColor
        ]
        grad_niche.startPoint = CGPoint(x: 0, y: 0.5)
        grad_niche.endPoint = CGPoint(x: 1, y: 0.5)
        grad_niche.cornerRadius = 18
        _publishButton_niche.layer.insertSublayer(grad_niche, at: 0)
    }

    private func refreshHeaderGradient_Niche() {
        _headerBg_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        guard !_headerBg_niche.bounds.isEmpty else { return }
        let grad_niche = CAGradientLayer()
        grad_niche.frame = _headerBg_niche.bounds
        grad_niche.colors = [UIColor.white.cgColor, UIColor(hexstring_Niche: "#F4F0FF").cgColor]
        grad_niche.startPoint = CGPoint(x: 0, y: 0)
        grad_niche.endPoint = CGPoint(x: 1, y: 1)
        _headerBg_niche.layer.insertSublayer(grad_niche, at: 0)
    }

    private func refreshUploadIconGradient_Niche() {
        _uploadIconBg_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        guard !_uploadIconBg_niche.bounds.isEmpty else { return }
        let grad_niche = UIColor.createPrimaryGradientLayer_Niche(frame_Niche: _uploadIconBg_niche.bounds)
        grad_niche.cornerRadius = 30
        _uploadIconBg_niche.layer.insertSublayer(grad_niche, at: 0)
    }

    /// 刷新媒体区虚线边框（每次布局更新时重建 CAShapeLayer）
    private func refreshDashedBorder_Niche() {
        guard !_mediaZone_niche.bounds.isEmpty, _mediaDisplayView_niche.isHidden else { return }
        _dashedBorderLayer_niche?.removeFromSuperlayer()
        let dashed_niche = CAShapeLayer()
        dashed_niche.strokeColor = ColorConfig_Niche.primaryGradientStart_Niche.withValues(alpha: 0.5).cgColor
        dashed_niche.lineDashPattern = [8, 5]
        dashed_niche.lineWidth = 2
        dashed_niche.fillColor = UIColor.clear.cgColor
        dashed_niche.path = UIBezierPath(
            roundedRect: _mediaZone_niche.bounds.insetBy(dx: 1, dy: 1),
            cornerRadius: 20
        ).cgPath
        _mediaZone_niche.layer.insertSublayer(dashed_niche, at: 0)
        _dashedBorderLayer_niche = dashed_niche
    }

    /// 刷新已选媒体类型徽章的渐变背景
    private func refreshMediaTypeBadgeGradient_Niche() {
        guard !_mediaTypeBadge_niche.isHidden, !_mediaTypeBadge_niche.bounds.isEmpty else { return }
        _mediaTypeBadge_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        let grad_niche = UIColor.createPrimaryGradientLayer_Niche(frame_Niche: _mediaTypeBadge_niche.bounds)
        grad_niche.cornerRadius = 9
        _mediaTypeBadge_niche.layer.insertSublayer(grad_niche, at: 0)
    }

    // MARK: - 行为绑定

    private func setupActions_Niche() {
        // 媒体区域点击
        _mediaZone_niche.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleMediaPick_Niche))
        )
        _changeMediaBtn_niche.addTarget(self, action: #selector(handleMediaPick_Niche), for: .touchUpInside)
        _publishButton_niche.addTarget(self, action: #selector(handlePublish_Niche), for: .touchUpInside)
        _eulaButton_niche.addTarget(self, action: #selector(handleEULA_Niche), for: .touchUpInside)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textViewDidChange_Niche),
            name: UITextView.textDidChangeNotification,
            object: _contentTextView_niche
        )
    }

    // MARK: - 事件处理

    @objc private func handleMediaPick_Niche() {
        MediaPickerHelper_Niche.pickMedia_Niche(from: self) { [weak self] result_niche in
            guard let self = self else { return }
            switch result_niche {
            case .photo_Niche(let image_niche):
                self._selectedImage_niche = image_niche
                self._selectedVideoURL_niche = nil
                self._mediaDisplayView_niche.configureWithImage_Niche(image_Niche: image_niche)
                self.showMediaSelected_Niche(type: "📷 Photo")
            case .video_Niche(let url_niche):
                self._selectedVideoURL_niche = url_niche
                self._selectedImage_niche = nil
                self._mediaDisplayView_niche.configure_Niche(mediaPath_Niche: url_niche.path, isVideo_Niche: true)
                self.showMediaSelected_Niche(type: "🎬 Video")
            case .cancelled_Niche:
                break
            }
        }
    }

    /// 切换到已选媒体状态
    private func showMediaSelected_Niche(type: String) {
        _uploadStack_niche.isHidden = true
        _mediaDisplayView_niche.isHidden = false
        _changeMediaBtn_niche.isHidden = false
        _mediaTypeBadge_niche.isHidden = false
        _mediaTypeBadge_niche.text = "  \(type)  "
        _dashedBorderLayer_niche?.removeFromSuperlayer()
        // 强制刷新徽章渐变
        _mediaTypeBadge_niche.setNeedsLayout()
        _mediaTypeBadge_niche.layoutIfNeeded()
        refreshMediaTypeBadgeGradient_Niche()
    }

    @objc private func handlePublish_Niche() {
        guard UserViewModel_Niche.shared_Niche.isLoggedIn_Niche else {
            Utils_Niche.showWarning_Niche(message_Niche: "Please sign in first")
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000)
                Navigation_Niche.toLogin_Niche(style_niche: .present_niche)
            }
            return
        }

        let title_niche   = _titleField_niche.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let content_niche = _contentTextView_niche.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !title_niche.isEmpty else {
            Utils_Niche.showWarning_Niche(message_Niche: "Please enter a title")
            _titleField_niche.animateShake_Niche()
            return
        }
        guard !content_niche.isEmpty else {
            Utils_Niche.showWarning_Niche(message_Niche: "Please add some content")
            return
        }
        guard _selectedImage_niche != nil || _selectedVideoURL_niche != nil else {
            Utils_Niche.showWarning_Niche(message_Niche: "Please add a photo or video")
            _mediaZone_niche.animateShake_Niche()
            return
        }

        let mediaPath_niche: String
        if let img_niche = _selectedImage_niche {
            mediaPath_niche = saveImageToDocuments_Niche(image: img_niche)
        } else if let vidURL_niche = _selectedVideoURL_niche {
            mediaPath_niche = vidURL_niche.path
        } else {
            mediaPath_niche = ""
        }

        _publishButton_niche.animatePressDown_Niche { self._publishButton_niche.animatePressUp_Niche() }

        Task { @MainActor in
            TitleViewModel_Niche.shared_Niche.releasePost_Niche(
                title_niche: title_niche,
                content_niche: content_niche,
                media_niche: mediaPath_niche
            )
            self.clearForm_Niche()
        }
    }

    @objc private func handleEULA_Niche() {
        ProtocolHelper_Niche.showProtocol_Niche(type_Niche: .eula_Niche, content_Niche: "eula.png", from: self)
    }

    @objc private func textViewDidChange_Niche() {
        let count_niche = _contentTextView_niche.text?.count ?? 0
        _contentPlaceholder_niche.isHidden = count_niche > 0
        _charCountLabel_niche.text = "\(count_niche)/500"
        // 字符数超出时变色提示
        if count_niche > 450 {
            _charCountLabel_niche.textColor = UIColor(hexstring_Niche: "#FC5252")
        } else if count_niche > 300 {
            _charCountLabel_niche.textColor = UIColor(hexstring_Niche: "#FDCB6E")
        } else {
            _charCountLabel_niche.textColor = ColorConfig_Niche.textPlaceholder_Niche
        }
    }

    private func clearForm_Niche() {
        _titleField_niche.text = nil
        _contentTextView_niche.text = nil
        _contentPlaceholder_niche.isHidden = false
        _charCountLabel_niche.text = "0/500"
        _charCountLabel_niche.textColor = ColorConfig_Niche.textPlaceholder_Niche
        _selectedImage_niche = nil
        _selectedVideoURL_niche = nil
        _mediaDisplayView_niche.isHidden = true
        _uploadStack_niche.isHidden = false
        _changeMediaBtn_niche.isHidden = true
        _mediaTypeBadge_niche.isHidden = true
        // 重建虚线边框
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    private func saveImageToDocuments_Niche(image: UIImage) -> String {
        let fileName_niche = "post_img_\(Int(Date().timeIntervalSince1970)).jpg"
        let docDir_niche   = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_niche  = docDir_niche.appendingPathComponent(fileName_niche)
        if let data_niche = image.jpegData(compressionQuality: 0.8) {
            try? data_niche.write(to: fileURL_niche)
        }
        return fileURL_niche.path
    }
}

// MARK: - UILabel 字母间距扩展

private extension UILabel {
    /// 设置字母间距（tracking）
    func letterSpacing_Niche(spacing: CGFloat) {
        guard let text_niche = text else { return }
        let attrs_niche: [NSAttributedString.Key: Any] = [
            .kern: spacing,
            .font: font as Any,
            .foregroundColor: textColor as Any
        ]
        attributedText = NSAttributedString(string: text_niche, attributes: attrs_niche)
    }
}
