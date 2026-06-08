import Foundation
import UIKit
import SnapKit

// MARK: 发布页面

/// 发布页面
/// 功能：输入标题/内容、从相册选取媒体、选择风格标签（自动附加到帖子）、确认发布
/// 设计：
///   • 渐变导航区（深紫→靛蓝，仿横幅卡风格）+ 装饰圆 + 白色文字
///   • 用户身份行（头像 + 当前用户名 + 角色徽章）
///   • 媒体选取卡：虚线渐变边框 + 玫瑰粉→薰衣草空态渐变
///   • 风格标签云（可交互，选中即高亮，发布时以 #标签 附到正文）
///   • 输入卡：渐变左装饰条 + 标题字数统计 + 渐变分隔线
///   • 发布按钮：深渐变 + 紫色发光阴影
class Release_Vestir: UIViewController {

    // MARK: - 私有属性

    private var selectedImage_Vestir: UIImage?
    private var selectedVideoURL_Vestir: URL?
    private var isVideoSelected_Vestir: Bool = false
    /// 已选中的风格标签（发布时追加到内容末尾）
    private var selectedTags_Vestir: Set<String> = []

    // MARK: - 渐变导航区组件

    /// 导航区阴影容器（不裁剪）
    private let navShadow_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = .clear
        v_Vestir.layer.shadowColor = UIColor(hexstring_Vestir: "#6B21A8").cgColor
        v_Vestir.layer.shadowOpacity = 0.35
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 8)
        v_Vestir.layer.shadowRadius = 20
        return v_Vestir
    }()

    /// 渐变导航卡（自管理渐变，与发现页横幅同色系）
    private let navCard_Vestir = ReleaseNavGradientCard_Vestir()

    /// 装饰圆 1（右上，白色 12% alpha）
    private let navDecoCircle1_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.12)
        v_Vestir.layer.cornerRadius = 52
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    /// 装饰圆 2（左下，天蓝 20% alpha）
    private let navDecoCircle2_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#93C5FD", alpha_Vestir: 0.20)
        v_Vestir.layer.cornerRadius = 36
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    /// 关闭按钮（白色半透明圆形背景）
    private let closeBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        let config_Vestir = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        btn_Vestir.setImage(UIImage(systemName: "xmark", withConfiguration: config_Vestir), for: .normal)
        btn_Vestir.tintColor = .white
        btn_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.22)
        btn_Vestir.layer.cornerRadius = 16
        btn_Vestir.clipsToBounds = true
        return btn_Vestir
    }()

    /// 导航主标题
    private let navTitleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Share Your Style"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        lbl_Vestir.textColor = .white
        return lbl_Vestir
    }()

    /// 导航副标题
    private let navSubtitleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Express your unique fashion story"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.72)
        return lbl_Vestir
    }()

    /// 装饰符号 ✦（右上角）
    private let navSparkleLbl_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "✦"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 22, weight: .light)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.50)
        return lbl_Vestir
    }()

    // MARK: - 滚动容器

    private let scrollView_Vestir: UIScrollView = {
        let sv_Vestir = UIScrollView()
        sv_Vestir.showsVerticalScrollIndicator = false
        sv_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        sv_Vestir.alwaysBounceVertical = true
        return sv_Vestir
    }()

    private let contentView_Vestir = UIView()

    // MARK: - 媒体区域标题行

    private let mediaSectionRow_Vestir: UIView = UIView()
    private let mediaSectionDot_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.primaryGradientStart_Vestir
        v_Vestir.layer.cornerRadius = 4
        return v_Vestir
    }()

    private let mediaSectionLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Photo or Video"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        return lbl_Vestir
    }()

    private let mediaOptionalBadge_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = " Required "
        lbl_Vestir.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        lbl_Vestir.textColor = ColorConfig_Vestir.heartColor_Vestir
        lbl_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#FFF1F2")
        lbl_Vestir.layer.cornerRadius = 6
        lbl_Vestir.clipsToBounds = true
        return lbl_Vestir
    }()

    // MARK: - 媒体选取卡片

    /// 媒体卡片阴影容器
    private let mediaCardShadow_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = .clear
        v_Vestir.layer.shadowColor = ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor
        v_Vestir.layer.shadowOpacity = 0.22
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 8)
        v_Vestir.layer.shadowRadius = 18
        return v_Vestir
    }()

    /// 媒体卡片内容容器（圆角 20）
    private let mediaPickerCard_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.layer.cornerRadius = 20
        v_Vestir.clipsToBounds = true
        v_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        return v_Vestir
    }()

    /// 虚线渐变边框层（CAShapeLayer，无媒体时显示）
    private let dashedBorderLayer_Vestir: CAShapeLayer = {
        let layer_Vestir = CAShapeLayer()
        layer_Vestir.fillColor = UIColor.clear.cgColor
        layer_Vestir.strokeColor = ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor
        layer_Vestir.lineWidth = 2
        layer_Vestir.lineDashPattern = [8, 5]
        layer_Vestir.opacity = 0.55
        return layer_Vestir
    }()

    private let mediaDisplayView_Vestir: MediaDisplayView_Vestir = {
        let mv_Vestir = MediaDisplayView_Vestir()
        mv_Vestir.layer.cornerRadius = 0
        mv_Vestir.clipsToBounds = true
        return mv_Vestir
    }()

    /// 空态遮罩（渐变背景 + 图标组合 + 提示行）
    private let emptyStateOverlay_Vestir: UIView = UIView()
    private var emptyStateGrad_Vestir: CAGradientLayer?

    /// 主图标（相机）
    private let mediaIconBig_Vestir: UIImageView = {
        let iv_Vestir = UIImageView()
        let config_Vestir = UIImage.SymbolConfiguration(pointSize: 40, weight: .thin)
        iv_Vestir.image = UIImage(systemName: "camera.viewfinder", withConfiguration: config_Vestir)
        iv_Vestir.tintColor = UIColor(white: 1.0, alpha: 0.95)
        iv_Vestir.contentMode = .scaleAspectFit
        return iv_Vestir
    }()

    /// 空态主提示文字
    private let mediaHintLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Add Photo or Video"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.95)
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    /// 空态副提示文字
    private let mediaSubHintLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Tap anywhere to browse your gallery"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.68)
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    /// 格式提示行（底部）
    private let mediaFormatRow_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
        v_Vestir.layer.cornerRadius = 12
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    private let mediaFormatLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "📷 JPG · PNG  |  🎬 MP4 · MOV"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.80)
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    // MARK: - 风格标签区域（功能闭环：选中标签发布时附加为 #hashtag）

    private let tagsSectionRow_Vestir: UIView = UIView()
    private let tagsSectionDot_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.heartColor_Vestir
        v_Vestir.layer.cornerRadius = 4
        return v_Vestir
    }()

    private let tagsSectionLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Style Tags"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        return lbl_Vestir
    }()

    private let tagsHintLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Tap to add hashtags to your post"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPlaceholder_Vestir
        return lbl_Vestir
    }()

    /// 标签云容器（流式布局）
    private let tagsCloudCard_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.backgroundSecondary_Vestir
        v_Vestir.layer.cornerRadius = 16
        v_Vestir.clipsToBounds = true
        v_Vestir.layer.borderWidth = 1
        v_Vestir.layer.borderColor = ColorConfig_Vestir.divider_Vestir.cgColor
        return v_Vestir
    }()

    /// 全部可选风格标签
    private let allStyleTags_Vestir = [
        "Casual", "Chic", "Street", "Minimal",
        "Luxury", "Y2K", "Boho", "Vintage",
        "Athleisure", "Romantic", "Edgy", "Preppy"
    ]

    /// 标签按钮列表（由 buildTagButtons_Vestir 生成）
    private var tagBtns_Vestir: [UIButton] = []

    // MARK: - 内容输入区域标题行

    private let inputSectionRow_Vestir: UIView = UIView()
    private let inputSectionDot_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.warmGradientStart_Vestir
        v_Vestir.layer.cornerRadius = 4
        return v_Vestir
    }()

    private let inputSectionLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Post Details"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        return lbl_Vestir
    }()

    // MARK: - 内容输入卡片

    private let inputCardShadow_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = .clear
        v_Vestir.layer.shadowColor = ColorConfig_Vestir.warmGradientStart_Vestir.cgColor
        v_Vestir.layer.shadowOpacity = 0.18
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 6)
        v_Vestir.layer.shadowRadius = 14
        return v_Vestir
    }()

    private let inputCard_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.backgroundSecondary_Vestir
        v_Vestir.layer.cornerRadius = 20
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    /// 标题区左侧渐变装饰条
    private let titleAccentBar_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.layer.cornerRadius = 2
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    private let titleField_Vestir: UITextField = {
        let tf_Vestir = UITextField()
        tf_Vestir.placeholder = "Add a captivating title..."
        tf_Vestir.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        tf_Vestir.borderStyle = .none
        tf_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        return tf_Vestir
    }()

    /// 标题字数统计（最多 50 字）
    private let titleCharCount_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "0/50"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPlaceholder_Vestir
        lbl_Vestir.textAlignment = .right
        return lbl_Vestir
    }()

    /// 渐变分隔线容器
    private let gradDivider_Vestir: UIView = UIView()

    private let contentTextView_Vestir: UITextView = {
        let tv_Vestir = UITextView()
        tv_Vestir.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tv_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        tv_Vestir.backgroundColor = .clear
        tv_Vestir.textContainerInset = .zero
        tv_Vestir.textContainer.lineFragmentPadding = 0
        tv_Vestir.isScrollEnabled = false
        return tv_Vestir
    }()

    private let placeholderLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Share your outfit story..."
        lbl_Vestir.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPlaceholder_Vestir
        lbl_Vestir.numberOfLines = 0
        return lbl_Vestir
    }()

    // MARK: - 发布按钮（深渐变 + 发光阴影）

    private let publishBtnShadow_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = .clear
        v_Vestir.layer.shadowColor = UIColor(hexstring_Vestir: "#6B21A8").cgColor
        v_Vestir.layer.shadowOpacity = 0.50
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 8)
        v_Vestir.layer.shadowRadius = 22
        return v_Vestir
    }()

    private let publishBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        btn_Vestir.setTitle("Share Outfit", for: .normal)
        btn_Vestir.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn_Vestir.setTitleColor(.white, for: .normal)
        btn_Vestir.layer.cornerRadius = 28
        btn_Vestir.clipsToBounds = true
        return btn_Vestir
    }()

    private let publishGradient_Vestir = CAGradientLayer()

    // MARK: - EULA

    private let eulaLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        let gray_Vestir: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: ColorConfig_Vestir.textPlaceholder_Vestir
        ]
        let link_Vestir: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
            .foregroundColor: ColorConfig_Vestir.primaryGradientStart_Vestir,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let str_Vestir = NSMutableAttributedString(
            string: "", attributes: gray_Vestir
        )
        str_Vestir.append(NSAttributedString(
            string: "EULA", attributes: link_Vestir
        ))
        lbl_Vestir.attributedText = str_Vestir
        lbl_Vestir.textAlignment = .center
        lbl_Vestir.numberOfLines = 2
        lbl_Vestir.isUserInteractionEnabled = true
        return lbl_Vestir
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Vestir()
        setupConstraints_Vestir()
        buildTagButtons_Vestir()
        setupActions_Vestir()
        animateIn_Vestir()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshGradients_Vestir()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        navShadow_Vestir.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaInsets.top + 88)
        }
    }

    // MARK: - UI 搭建

    private func setupUI_Vestir() {
        view.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir

        // 渐变导航区
        view.addSubview(navShadow_Vestir)
        navShadow_Vestir.addSubview(navCard_Vestir)
        navCard_Vestir.addSubview(navDecoCircle1_Vestir)
        navCard_Vestir.addSubview(navDecoCircle2_Vestir)
        navCard_Vestir.addSubview(closeBtn_Vestir)
        navCard_Vestir.addSubview(navSparkleLbl_Vestir)
        navCard_Vestir.addSubview(navTitleLabel_Vestir)
        navCard_Vestir.addSubview(navSubtitleLabel_Vestir)

        // 滚动容器
        view.addSubview(scrollView_Vestir)
        scrollView_Vestir.addSubview(contentView_Vestir)

        // 媒体区域
        contentView_Vestir.addSubview(mediaSectionRow_Vestir)
        mediaSectionRow_Vestir.addSubview(mediaSectionDot_Vestir)
        mediaSectionRow_Vestir.addSubview(mediaSectionLabel_Vestir)
        mediaSectionRow_Vestir.addSubview(mediaOptionalBadge_Vestir)

        contentView_Vestir.addSubview(mediaCardShadow_Vestir)
        mediaCardShadow_Vestir.addSubview(mediaPickerCard_Vestir)
        mediaPickerCard_Vestir.layer.addSublayer(dashedBorderLayer_Vestir)
        mediaPickerCard_Vestir.addSubview(mediaDisplayView_Vestir)
        mediaPickerCard_Vestir.addSubview(emptyStateOverlay_Vestir)
        emptyStateOverlay_Vestir.addSubview(mediaIconBig_Vestir)
        emptyStateOverlay_Vestir.addSubview(mediaHintLabel_Vestir)
        emptyStateOverlay_Vestir.addSubview(mediaSubHintLabel_Vestir)
        emptyStateOverlay_Vestir.addSubview(mediaFormatRow_Vestir)
        mediaFormatRow_Vestir.addSubview(mediaFormatLabel_Vestir)

        // 风格标签区域
        contentView_Vestir.addSubview(tagsSectionRow_Vestir)
        tagsSectionRow_Vestir.addSubview(tagsSectionDot_Vestir)
        tagsSectionRow_Vestir.addSubview(tagsSectionLabel_Vestir)
        tagsSectionRow_Vestir.addSubview(tagsHintLabel_Vestir)
        contentView_Vestir.addSubview(tagsCloudCard_Vestir)

        // 内容输入区域
        contentView_Vestir.addSubview(inputSectionRow_Vestir)
        inputSectionRow_Vestir.addSubview(inputSectionDot_Vestir)
        inputSectionRow_Vestir.addSubview(inputSectionLabel_Vestir)

        contentView_Vestir.addSubview(inputCardShadow_Vestir)
        inputCardShadow_Vestir.addSubview(inputCard_Vestir)
        inputCard_Vestir.addSubview(titleAccentBar_Vestir)
        inputCard_Vestir.addSubview(titleField_Vestir)
        inputCard_Vestir.addSubview(titleCharCount_Vestir)
        inputCard_Vestir.addSubview(gradDivider_Vestir)
        inputCard_Vestir.addSubview(contentTextView_Vestir)
        inputCard_Vestir.addSubview(placeholderLabel_Vestir)

        // 发布按钮
        contentView_Vestir.addSubview(publishBtnShadow_Vestir)
        publishBtnShadow_Vestir.addSubview(publishBtn_Vestir)
        contentView_Vestir.addSubview(eulaLabel_Vestir)

        // 发布按钮渐变（深紫→靛蓝→湛蓝）
        publishGradient_Vestir.colors = [
            UIColor(hexstring_Vestir: "#6B21A8").cgColor,
            UIColor(hexstring_Vestir: "#4338CA").cgColor,
            UIColor(hexstring_Vestir: "#0369A1").cgColor
        ]
        publishGradient_Vestir.locations = [0, 0.52, 1.0]
        publishGradient_Vestir.startPoint = CGPoint(x: 0, y: 0.5)
        publishGradient_Vestir.endPoint = CGPoint(x: 1, y: 0.5)
        publishGradient_Vestir.cornerRadius = 28
        publishBtn_Vestir.layer.insertSublayer(publishGradient_Vestir, at: 0)

        contentTextView_Vestir.delegate = self
        titleField_Vestir.addTarget(
            self, action: #selector(titleFieldChanged_Vestir), for: .editingChanged
        )
        titleField_Vestir.placeHolderTextColor_Vestir(ColorConfig_Vestir.textPlaceholder_Vestir)
    }

    private func setupConstraints_Vestir() {
        // ─── 渐变导航区 ───
        navShadow_Vestir.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(view.safeAreaInsets.top + 88)
        }

        navCard_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        navDecoCircle1_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(104)
            make.trailing.equalToSuperview().offset(28)
            make.top.equalToSuperview().offset(-30)
        }

        navDecoCircle2_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(72)
            make.leading.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(20)
        }

        closeBtn_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-14)
            make.width.height.equalTo(32)
        }

        navTitleLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
        }

        navSubtitleLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(navTitleLabel_Vestir)
            make.top.equalTo(navTitleLabel_Vestir.snp.bottom).offset(2)
            make.bottom.lessThanOrEqualToSuperview().offset(-6)
        }

        navSparkleLbl_Vestir.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(navTitleLabel_Vestir)
        }

        // ─── 滚动容器 ───
        scrollView_Vestir.snp.makeConstraints { make in
            make.top.equalTo(navShadow_Vestir.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        contentView_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        // ─── 媒体区域标题行 ───
        mediaSectionRow_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(22)
        }

        mediaSectionDot_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }

        mediaSectionLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(mediaSectionDot_Vestir.snp.trailing).offset(7)
            make.centerY.equalToSuperview()
        }

        mediaOptionalBadge_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(mediaSectionLabel_Vestir.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(18)
        }

        // ─── 媒体卡片 ───
        mediaCardShadow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(mediaSectionRow_Vestir.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(250)
        }

        mediaPickerCard_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mediaDisplayView_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        emptyStateOverlay_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mediaIconBig_Vestir.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-28)
            make.width.height.equalTo(56)
        }

        mediaHintLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(mediaIconBig_Vestir.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        mediaSubHintLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(mediaHintLabel_Vestir.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }

        mediaFormatRow_Vestir.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-16)
            make.centerX.equalToSuperview()
            make.height.equalTo(28)
        }

        mediaFormatLabel_Vestir.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
        }

        // ─── 风格标签区域 ───
        tagsSectionRow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(mediaCardShadow_Vestir.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(22)
        }

        tagsSectionDot_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }

        tagsSectionLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(tagsSectionDot_Vestir.snp.trailing).offset(7)
            make.centerY.equalToSuperview()
        }

        tagsHintLabel_Vestir.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        tagsCloudCard_Vestir.snp.makeConstraints { make in
            make.top.equalTo(tagsSectionRow_Vestir.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(104)
        }

        // ─── 内容输入区域 ───
        inputSectionRow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(tagsCloudCard_Vestir.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(22)
        }

        inputSectionDot_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }

        inputSectionLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(inputSectionDot_Vestir.snp.trailing).offset(7)
            make.centerY.equalToSuperview()
        }

        inputCardShadow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(inputSectionRow_Vestir.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        inputCard_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleAccentBar_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(14)
            make.width.equalTo(4)
            make.height.equalTo(34)
        }

        titleField_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(titleAccentBar_Vestir.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-60)
            make.height.equalTo(34)
        }

        titleCharCount_Vestir.snp.makeConstraints { make in
            make.centerY.equalTo(titleField_Vestir)
            make.trailing.equalToSuperview().offset(-14)
        }

        gradDivider_Vestir.snp.makeConstraints { make in
            make.top.equalTo(titleField_Vestir.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview()
            make.height.equalTo(1.5)
        }

        contentTextView_Vestir.snp.makeConstraints { make in
            make.top.equalTo(gradDivider_Vestir.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.greaterThanOrEqualTo(100)
        }

        placeholderLabel_Vestir.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(contentTextView_Vestir)
        }

        // ─── 发布按钮 ───
        publishBtnShadow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(inputCardShadow_Vestir.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(56)
        }

        publishBtn_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        eulaLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(publishBtnShadow_Vestir.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-100)
        }
    }

    // MARK: - 渐变刷新

    /// 刷新所有 CAGradientLayer frame 及阴影路径（viewDidLayoutSubviews 调用）
    private func refreshGradients_Vestir() {
        // 媒体空态渐变（玫瑰粉→薰衣草）
        if emptyStateOverlay_Vestir.bounds.width > 0 {
            emptyStateGrad_Vestir?.removeFromSuperlayer()
            let g_Vestir = CAGradientLayer()
            g_Vestir.frame = emptyStateOverlay_Vestir.bounds
            g_Vestir.colors = [
                UIColor(hexstring_Vestir: "#F9A8D4").cgColor,
                UIColor(hexstring_Vestir: "#C4B5FD").cgColor
            ]
            g_Vestir.startPoint = CGPoint(x: 0, y: 0)
            g_Vestir.endPoint = CGPoint(x: 1, y: 1)
            emptyStateOverlay_Vestir.layer.insertSublayer(g_Vestir, at: 0)
            emptyStateGrad_Vestir = g_Vestir
        }

        // 虚线边框（无媒体时显示，环绕卡片内边 2pt）
        let borderInset: CGFloat = 4
        let borderBounds = mediaPickerCard_Vestir.bounds.insetBy(dx: borderInset, dy: borderInset)
        let borderPath_Vestir = UIBezierPath(roundedRect: borderBounds, cornerRadius: 18)
        dashedBorderLayer_Vestir.path = borderPath_Vestir.cgPath
        dashedBorderLayer_Vestir.frame = mediaPickerCard_Vestir.bounds

        // 标题区左侧渐变竖条
        titleAccentBar_Vestir.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }
        if titleAccentBar_Vestir.bounds.width > 0 {
            let ag_Vestir = CAGradientLayer()
            ag_Vestir.frame = titleAccentBar_Vestir.bounds
            ag_Vestir.colors = [
                ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor,
                ColorConfig_Vestir.primaryGradientEnd_Vestir.cgColor
            ]
            ag_Vestir.startPoint = CGPoint(x: 0.5, y: 0)
            ag_Vestir.endPoint = CGPoint(x: 0.5, y: 1)
            ag_Vestir.cornerRadius = 2
            titleAccentBar_Vestir.layer.insertSublayer(ag_Vestir, at: 0)
        }

        // 输入卡渐变分隔线
        gradDivider_Vestir.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }
        if gradDivider_Vestir.bounds.width > 0 {
            let dg_Vestir = CAGradientLayer()
            dg_Vestir.frame = gradDivider_Vestir.bounds
            dg_Vestir.colors = [
                ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor,
                ColorConfig_Vestir.primaryGradientEnd_Vestir.cgColor,
                UIColor.clear.cgColor
            ]
            dg_Vestir.locations = [0, 0.5, 1.0]
            dg_Vestir.startPoint = CGPoint(x: 0, y: 0.5)
            dg_Vestir.endPoint = CGPoint(x: 1, y: 0.5)
            gradDivider_Vestir.layer.addSublayer(dg_Vestir)
        }

        // 发布按钮渐变 frame 同步
        publishGradient_Vestir.frame = publishBtn_Vestir.bounds

        // 阴影路径（提升性能）
        if publishBtnShadow_Vestir.bounds.width > 0 {
            let p_Vestir = UIBezierPath(
                roundedRect: publishBtnShadow_Vestir.bounds, cornerRadius: 28
            )
            publishBtnShadow_Vestir.layer.shadowPath = p_Vestir.cgPath
        }
        if mediaCardShadow_Vestir.bounds.width > 0 {
            let p_Vestir = UIBezierPath(
                roundedRect: mediaCardShadow_Vestir.bounds, cornerRadius: 20
            )
            mediaCardShadow_Vestir.layer.shadowPath = p_Vestir.cgPath
        }
        if navShadow_Vestir.bounds.width > 0 {
            let p_Vestir = UIBezierPath(roundedRect: navShadow_Vestir.bounds, cornerRadius: 0)
            navShadow_Vestir.layer.shadowPath = p_Vestir.cgPath
        }
    }

    // MARK: - 标签云构建

    /// 动态创建风格标签按钮并做流式布局（标签云）
    private func buildTagButtons_Vestir() {
        tagBtns_Vestir.forEach { $0.removeFromSuperview() }
        tagBtns_Vestir = []

        let hSpacing_Vestir: CGFloat = 8
        let vSpacing_Vestir: CGFloat = 8
        let pillH_Vestir: CGFloat = 28
        let padding_Vestir: CGFloat = 14
        let availW_Vestir = UIScreen.main.bounds.width - 32 - padding_Vestir * 2

        var x: CGFloat = padding_Vestir
        var y: CGFloat = padding_Vestir

        for tag_Vestir in allStyleTags_Vestir {
            let btn_Vestir = UIButton(type: .system)
            btn_Vestir.setTitle("  \(tag_Vestir)  ", for: .normal)
            btn_Vestir.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            btn_Vestir.setTitleColor(ColorConfig_Vestir.tagPillText_Vestir, for: .normal)
            btn_Vestir.backgroundColor = ColorConfig_Vestir.tagPill_Vestir
            btn_Vestir.layer.cornerRadius = 12
            btn_Vestir.clipsToBounds = true
            btn_Vestir.addTarget(self, action: #selector(tagBtnTapped_Vestir(_:)), for: .touchUpInside)

            let btnW_Vestir = btn_Vestir.intrinsicContentSize.width + 4

            if x > padding_Vestir && x + btnW_Vestir > availW_Vestir + padding_Vestir {
                x = padding_Vestir
                y += pillH_Vestir + vSpacing_Vestir
            }

            btn_Vestir.frame = CGRect(x: x, y: y, width: btnW_Vestir, height: pillH_Vestir)
            tagsCloudCard_Vestir.addSubview(btn_Vestir)
            tagBtns_Vestir.append(btn_Vestir)
            x += btnW_Vestir + hSpacing_Vestir
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Vestir() {
        closeBtn_Vestir.addTarget(self, action: #selector(closeTapped_Vestir), for: .touchUpInside)
        publishBtn_Vestir.addTarget(self, action: #selector(publishTapped_Vestir), for: .touchUpInside)

        let mediaTap_Vestir = UITapGestureRecognizer(
            target: self, action: #selector(mediaPickerTapped_Vestir)
        )
        mediaPickerCard_Vestir.addGestureRecognizer(mediaTap_Vestir)
        mediaPickerCard_Vestir.isUserInteractionEnabled = true

        let eulaTap_Vestir = UITapGestureRecognizer(
            target: self, action: #selector(eulaTapped_Vestir)
        )
        eulaLabel_Vestir.addGestureRecognizer(eulaTap_Vestir)
    }

    /// 入场动画：卡片依次从底部弹入
    private func animateIn_Vestir() {
        [mediaCardShadow_Vestir,
         tagsCloudCard_Vestir, inputCardShadow_Vestir, publishBtnShadow_Vestir]
            .enumerated().forEach { idx_Vestir, v_Vestir in
                v_Vestir.alpha = 0
                v_Vestir.animateSlideInFromBottom_Vestir(
                    offset_Vestir: 40, delay_Vestir: 0.06 + Double(idx_Vestir) * 0.07
                )
            }
    }

    // MARK: - 媒体展示状态更新

    private func updateMediaDisplay_Vestir() {
        if let img_Vestir = selectedImage_Vestir {
            mediaDisplayView_Vestir.configureWithImage_Vestir(image_Vestir: img_Vestir)
            emptyStateOverlay_Vestir.isHidden = true
            dashedBorderLayer_Vestir.isHidden = true
        } else if let url_Vestir = selectedVideoURL_Vestir {
            mediaDisplayView_Vestir.configure_Vestir(
                mediaPath_Vestir: url_Vestir.path, isVideo_Vestir: true
            )
            emptyStateOverlay_Vestir.isHidden = true
            dashedBorderLayer_Vestir.isHidden = true
        } else {
            mediaDisplayView_Vestir.configure_Vestir(mediaPath_Vestir: nil)
            emptyStateOverlay_Vestir.isHidden = false
            dashedBorderLayer_Vestir.isHidden = false
        }
    }

    // MARK: - 页面数据清空

    private func clearPageData_Vestir() {
        titleField_Vestir.text = ""
        titleCharCount_Vestir.text = "0/50"
        contentTextView_Vestir.text = ""
        placeholderLabel_Vestir.isHidden = false
        selectedImage_Vestir = nil
        selectedVideoURL_Vestir = nil
        isVideoSelected_Vestir = false
        selectedTags_Vestir = []
        tagBtns_Vestir.forEach { resetTagButton_Vestir($0) }
        updateMediaDisplay_Vestir()
    }

    /// 重置单个标签按钮为未选中样式
    private func resetTagButton_Vestir(_ btn_Vestir: UIButton) {
        btn_Vestir.setTitleColor(ColorConfig_Vestir.tagPillText_Vestir, for: .normal)
        btn_Vestir.backgroundColor = ColorConfig_Vestir.tagPill_Vestir
    }

    // MARK: - 事件处理

    @objc private func closeTapped_Vestir() {
        Navigation_Vestir.dismiss_Vestir()
    }

    @objc private func titleFieldChanged_Vestir() {
        let count_Vestir = titleField_Vestir.text?.count ?? 0
        titleCharCount_Vestir.text = "\(count_Vestir)/50"
        titleCharCount_Vestir.textColor = count_Vestir > 40
            ? ColorConfig_Vestir.heartColor_Vestir
            : ColorConfig_Vestir.textPlaceholder_Vestir
    }

    /// 标签按钮点击：切换选中/未选中状态，同步 selectedTags_Vestir
    @objc private func tagBtnTapped_Vestir(_ sender: UIButton) {
        let raw_Vestir = sender.title(for: .normal) ?? ""
        let tag_Vestir = raw_Vestir.trimmingCharacters(in: .whitespaces)
        sender.animatePressDown_Vestir {
            sender.animatePressUp_Vestir()
        }
        if selectedTags_Vestir.contains(tag_Vestir) {
            selectedTags_Vestir.remove(tag_Vestir)
            resetTagButton_Vestir(sender)
        } else {
            selectedTags_Vestir.insert(tag_Vestir)
            sender.setTitleColor(.white, for: .normal)
            sender.backgroundColor = ColorConfig_Vestir.primaryGradientStart_Vestir
        }
    }

    @objc private func mediaPickerTapped_Vestir() {
        mediaPickerCard_Vestir.animatePressDown_Vestir {
            self.mediaPickerCard_Vestir.animatePressUp_Vestir()
        }
        MediaPickerHelper_Vestir.pickMedia_Vestir(from: self) { [weak self] result_vestir in
            guard let self = self else { return }
            switch result_vestir {
            case .photo_Vestir(let img_vestir):
                self.selectedImage_Vestir = img_vestir
                self.selectedVideoURL_Vestir = nil
                self.isVideoSelected_Vestir = false
                self.updateMediaDisplay_Vestir()
            case .video_Vestir(let url_vestir):
                self.selectedImage_Vestir = nil
                self.selectedVideoURL_Vestir = url_vestir
                self.isVideoSelected_Vestir = true
                self.updateMediaDisplay_Vestir()
            case .cancelled_Vestir:
                break
            }
        }
    }

    @objc private func publishTapped_Vestir() {
        publishBtn_Vestir.animatePressDown_Vestir {
            self.publishBtn_Vestir.animatePressUp_Vestir()
        }

        guard UserViewModel_Vestir.shared_Vestir.isLoggedIn_Vestir else {
            Navigation_Vestir.toLogin_Vestir(style_vestir: .present_vestir)
            return
        }

        guard let title_vestir = titleField_Vestir.text, !title_vestir.isEmpty else {
            titleField_Vestir.animateShake_Vestir()
            Utils_Vestir.showWarning_Vestir(message_Vestir: "Please add a title")
            return
        }

        let rawContent_vestir = contentTextView_Vestir.text ?? ""
        guard !rawContent_vestir.isEmpty else {
            contentTextView_Vestir.animateShake_Vestir()
            Utils_Vestir.showWarning_Vestir(message_Vestir: "Please add some content")
            return
        }

        // 将选中的风格标签以 #hashtag 形式追加到正文末尾
        let tagSuffix_vestir = selectedTags_Vestir.isEmpty ? "" :
            "\n\n" + selectedTags_Vestir.sorted().map { "#\($0)" }.joined(separator: " ")
        let fullContent_vestir = rawContent_vestir + tagSuffix_vestir

        var mediaPath_vestir = ""
        if let img_vestir = selectedImage_Vestir {
            if let data_vestir = img_vestir.jpegData(compressionQuality: 0.8) {
                let fileName_vestir = "post_\(Date().timeIntervalSince1970).jpg"
                let url_vestir = FileManager.default.urls(
                    for: .documentDirectory, in: .userDomainMask
                )[0].appendingPathComponent(fileName_vestir)
                try? data_vestir.write(to: url_vestir)
                mediaPath_vestir = fileName_vestir
            }
        } else if let videoURL_vestir = selectedVideoURL_Vestir {
            mediaPath_vestir = videoURL_vestir.path
        } else {
            Utils_Vestir.showWarning_Vestir(message_Vestir: "Please select a photo or video")
            return
        }

        Task { @MainActor in
            TitleViewModel_Vestir.shared_Vestir.releasePost_Vestir(
                title_vestir: title_vestir,
                content_vestir: fullContent_vestir,
                media_vestir: mediaPath_vestir
            )
            self.clearPageData_Vestir()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                Navigation_Vestir.dismiss_Vestir()
            }
        }
    }

    @objc private func eulaTapped_Vestir() {
        eulaLabel_Vestir.animatePulse_Vestir()
        ProtocolHelper_Vestir.showProtocol_Vestir(
            type_Vestir: .eula_Vestir,
            content_Vestir: "eula.png",
            from: self
        )
    }
}

// MARK: - UITextViewDelegate

extension Release_Vestir: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel_Vestir.isHidden = !textView.text.isEmpty
    }
}

// MARK: - 发布页导航区渐变背景视图

/// 自管理渐变的导航背景卡（深紫→靛蓝→湛蓝，与发现页横幅同色系）
/// 在自身 layoutSubviews 中更新 CAGradientLayer frame，避免时序问题
fileprivate final class ReleaseNavGradientCard_Vestir: UIView {

    private let gradLayer_Vestir: CAGradientLayer = {
        let g_Vestir = CAGradientLayer()
        g_Vestir.colors = [
            UIColor(hexstring_Vestir: "#6B21A8").cgColor,
            UIColor(hexstring_Vestir: "#4338CA").cgColor,
            UIColor(hexstring_Vestir: "#0369A1").cgColor
        ]
        g_Vestir.locations = [0, 0.52, 1.0]
        g_Vestir.startPoint = CGPoint(x: 0, y: 0)
        g_Vestir.endPoint = CGPoint(x: 1, y: 1)
        return g_Vestir
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(gradLayer_Vestir, at: 0)
        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Vestir.frame = bounds
    }
}
