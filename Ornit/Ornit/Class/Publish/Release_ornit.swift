import UIKit
import SnapKit

// MARK: 发布页面

/// 发布帖子页面
/// 功能：输入标题和内容，从相册选取单个媒体（图片或视频），点击发布后校验并执行发布
/// 发布前检查登录状态、字段非空，发布后清空所有输入并关闭页面
/// 设计：琥珀橙渐变顶部 Header + 媒体选取区 + 快捷拍摄提示横条 + 表单输入卡片 + 渐变发布按钮
class Release_Ornit: UIViewController {

    // MARK: - 私有数据属性

    /// 当前选中的媒体路径（图片路径字符串或视频文件路径）
    private var selectedMediaPath_Ornit: String?

    /// 选中媒体的预览图（图片原图或视频封面缩略图）
    private var selectedMediaImage_Ornit: UIImage?

    // MARK: - 容器组件

    private let scrollView_Ornit = UIScrollView()
    private let contentView_Ornit = UIView()

    // MARK: - Header 组件

    /// 顶部渐变 Header 容器
    private let headerView_Ornit = UIView()

    /// Header 渐变图层（viewDidLayoutSubviews 中同步 frame）
    private var headerGradient_Ornit: CAGradientLayer?

    /// 顶栏主标题
    private let titleBarLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.text = "New Sighting"
        label_ornit.font = UIFont.systemFont(ofSize: 24, weight: .black)
        label_ornit.textColor = .white
        return label_ornit
    }()

    /// 顶栏副标题
    private let subtitleBarLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.text = "Share your birding moment"
        label_ornit.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_ornit.textColor = UIColor.white.withValues(alpha: 0.78)
        return label_ornit
    }()

    // MARK: - 媒体选取组件

    /// 媒体选取区外层容器
    private let mediaPickerView_Ornit = UIView()

    /// 媒体区内部渐变图层（viewDidLayoutSubviews 中同步 frame）
    private var mediaInnerGradient_Ornit: CAGradientLayer?

    /// 媒体预览图（选择媒体后显示，替换占位内容）
    private let mediaPreview_Ornit: UIImageView = {
        let iv_ornit = UIImageView()
        iv_ornit.contentMode = .scaleAspectFill
        iv_ornit.clipsToBounds = true
        iv_ornit.layer.cornerRadius = 16
        iv_ornit.isHidden = true
        return iv_ornit
    }()

    /// 媒体占位内容竖向堆叠（图标 + 主文字 + 提示文字）
    private let mediaPlaceholderStack_Ornit: UIStackView = {
        let sv_ornit = UIStackView()
        sv_ornit.axis = .vertical
        sv_ornit.alignment = .center
        sv_ornit.spacing = 8
        return sv_ornit
    }()

    /// 视频选中后的遮罩层（含播放图标）
    private let videoOverlay_Ornit: UIView = {
        let v_ornit = UIView()
        v_ornit.backgroundColor = UIColor.black.withValues(alpha: 0.35)
        v_ornit.layer.cornerRadius = 16
        v_ornit.isHidden = true
        return v_ornit
    }()

    // MARK: - 提示横条

    /// 快捷提示横向滚动视图（存为属性供 formCard 布局引用）
    private let tipsScrollView_Ornit: UIScrollView = {
        let sv_ornit = UIScrollView()
        sv_ornit.showsHorizontalScrollIndicator = false
        sv_ornit.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return sv_ornit
    }()

    // MARK: - 表单输入组件

    /// 白色表单卡片（阴影使用琥珀色调）
    private let formCard_Ornit = UIView()

    /// 标题输入框
    private let titleField_Ornit: UITextField = {
        let tf_ornit = UITextField()
        tf_ornit.placeholder = "Title of your sighting..."
        tf_ornit.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        tf_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        tf_ornit.returnKeyType = .next
        tf_ornit.backgroundColor = .clear
        return tf_ornit
    }()

    /// 内容输入 TextView
    private let contentTextView_Ornit: UITextView = {
        let tv_ornit = UITextView()
        tv_ornit.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tv_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        tv_ornit.backgroundColor = .clear
        tv_ornit.isScrollEnabled = false
        tv_ornit.textContainerInset = UIEdgeInsets(top: 10, left: 4, bottom: 32, right: 4)
        return tv_ornit
    }()

    /// 内容输入框占位符标签
    private let contentPlaceholder_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.text = "Describe your bird sighting, habitat, behavior..."
        label_ornit.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label_ornit.textColor = ColorConfig_Ornit.textPlaceholder_Ornit
        label_ornit.numberOfLines = 0
        return label_ornit
    }()

    /// 内容字符计数标签（右下角，随输入实时更新）
    private let charCountLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.text = "0 / 300"
        label_ornit.font = UIFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        label_ornit.textColor = ColorConfig_Ornit.textPlaceholder_Ornit
        label_ornit.textAlignment = .right
        return label_ornit
    }()

    // MARK: - 发布按钮

    /// 渐变发布按钮（含图标 + 文字）
    private let publishButton_Ornit: UIButton = {
        let btn_ornit = UIButton(type: .custom)
        btn_ornit.setTitle("  Publish Sighting", for: .normal)
        btn_ornit.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn_ornit.setTitleColor(.white, for: .normal)
        let config_ornit = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn_ornit.setImage(
            UIImage(systemName: "arrow.up.circle.fill", withConfiguration: config_ornit),
            for: .normal
        )
        btn_ornit.tintColor = .white
        btn_ornit.layer.cornerRadius = 16
        btn_ornit.layer.masksToBounds = true
        return btn_ornit
    }()

    /// 发布按钮渐变图层
    private var publishGradient_Ornit: CAGradientLayer?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Ornit.backgroundWarm_Ornit
        setupScrollView_Ornit()
        setupHeaderView_Ornit()
        setupMediaPicker_Ornit()
        setupTipsBar_Ornit()
        setupFormCard_Ornit()
        setupPublishButton_Ornit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Ornit?.frame = headerView_Ornit.bounds
        publishGradient_Ornit?.frame = publishButton_Ornit.bounds
        mediaInnerGradient_Ornit?.frame = mediaPickerView_Ornit.bounds
    }

    // MARK: - UI 搭建

    /// 构建全页滚动容器，键盘弹出时可交互滑动收起
    private func setupScrollView_Ornit() {
        scrollView_Ornit.showsVerticalScrollIndicator = false
        scrollView_Ornit.contentInsetAdjustmentBehavior = .never
        scrollView_Ornit.keyboardDismissMode = .interactive
        // 底部留出 Tab Bar 高度 + 安全距离，确保最后内容完整可见
        scrollView_Ornit.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        scrollView_Ornit.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        view.addSubview(scrollView_Ornit)
        scrollView_Ornit.addSubview(contentView_Ornit)

        scrollView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview()
        }
        contentView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview()
            make_ornit.width.equalToSuperview()
        }
    }

    /// 构建顶部渐变 Header（深琥珀 → 温暖橙渐变 + 装饰圆 + 羽毛图标）
    private func setupHeaderView_Ornit() {
        contentView_Ornit.addSubview(headerView_Ornit)

        // 深琥珀棕 → 温暖橙渐变
        let gradient_ornit = CAGradientLayer()
        gradient_ornit.colors = [
            ColorConfig_Ornit.publishGradientStart_Ornit.cgColor,
            ColorConfig_Ornit.publishGradientEnd_Ornit.cgColor
        ]
        gradient_ornit.startPoint = CGPoint(x: 0, y: 0)
        gradient_ornit.endPoint = CGPoint(x: 1, y: 1)
        headerView_Ornit.layer.insertSublayer(gradient_ornit, at: 0)
        headerGradient_Ornit = gradient_ornit

        // 四角统一圆角，与底部圆角保持一致
        headerView_Ornit.layer.cornerRadius = 28
        headerView_Ornit.clipsToBounds = true

        // 右上角大装饰圆
        let deco1_ornit = UIView()
        deco1_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.08)
        deco1_ornit.layer.cornerRadius = 68
        headerView_Ornit.addSubview(deco1_ornit)

        // 左下角小装饰圆
        let deco2_ornit = UIView()
        deco2_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.05)
        deco2_ornit.layer.cornerRadius = 38
        headerView_Ornit.addSubview(deco2_ornit)

        // 右下方中等装饰圆
        let deco3_ornit = UIView()
        deco3_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.04)
        deco3_ornit.layer.cornerRadius = 50
        headerView_Ornit.addSubview(deco3_ornit)

        headerView_Ornit.addSubview(titleBarLabel_Ornit)
        headerView_Ornit.addSubview(subtitleBarLabel_Ornit)

        // 装饰羽毛图标（半透明，右下角）
        let featherConfig_ornit = UIImage.SymbolConfiguration(pointSize: 44, weight: .thin)
        let featherIcon_ornit = UIImageView(
            image: UIImage(systemName: "feather", withConfiguration: featherConfig_ornit)
        )
        featherIcon_ornit.tintColor = UIColor.white.withValues(alpha: 0.16)
        headerView_Ornit.addSubview(featherIcon_ornit)

        headerView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(150)
        }

        deco1_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(46)
            make_ornit.top.equalToSuperview().offset(-30)
            make_ornit.width.height.equalTo(136)
        }

        deco2_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(-18)
            make_ornit.bottom.equalToSuperview().offset(22)
            make_ornit.width.height.equalTo(76)
        }

        deco3_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-70)
            make_ornit.bottom.equalToSuperview().offset(32)
            make_ornit.width.height.equalTo(100)
        }

        titleBarLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(24)
            make_ornit.top.equalToSuperview().offset(54)
        }

        subtitleBarLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(24)
            make_ornit.top.equalTo(titleBarLabel_Ornit.snp.bottom).offset(4)
        }

        featherIcon_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.bottom.equalToSuperview().offset(-12)
            make_ornit.width.height.equalTo(56)
        }

    }

    /// 构建媒体选取区（虚线琥珀色边框 + 渐变占位背景 + 预览图叠加）
    private func setupMediaPicker_Ornit() {
        mediaPickerView_Ornit.layer.cornerRadius = 18
        mediaPickerView_Ornit.clipsToBounds = true
        mediaPickerView_Ornit.layer.borderWidth = 1.8
        mediaPickerView_Ornit.layer.borderColor = ColorConfig_Ornit.publishAccent_Ornit.withValues(alpha: 0.4).cgColor
        mediaPickerView_Ornit.isUserInteractionEnabled = true
        contentView_Ornit.addSubview(mediaPickerView_Ornit)

        // 内部极淡琥珀渐变背景
        let innerGrad_ornit = CAGradientLayer()
        innerGrad_ornit.colors = [
            ColorConfig_Ornit.publishGradientStart_Ornit.withValues(alpha: 0.07).cgColor,
            ColorConfig_Ornit.publishGradientEnd_Ornit.withValues(alpha: 0.13).cgColor
        ]
        innerGrad_ornit.startPoint = CGPoint(x: 0, y: 0)
        innerGrad_ornit.endPoint = CGPoint(x: 1, y: 1)
        mediaPickerView_Ornit.layer.insertSublayer(innerGrad_ornit, at: 0)
        mediaInnerGradient_Ornit = innerGrad_ornit

        mediaPickerView_Ornit.addSubview(mediaPreview_Ornit)
        mediaPickerView_Ornit.addSubview(videoOverlay_Ornit)

        // 占位：相机图标
        let iconConfig_ornit = UIImage.SymbolConfiguration(pointSize: 36, weight: .light)
        let cameraIcon_ornit = UIImageView(
            image: UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: iconConfig_ornit)
        )
        cameraIcon_ornit.tintColor = ColorConfig_Ornit.publishAccent_Ornit
        cameraIcon_ornit.contentMode = .scaleAspectFit
        mediaPlaceholderStack_Ornit.addArrangedSubview(cameraIcon_ornit)

        // 占位：主提示文字
        let addTitle_ornit = UILabel()
        addTitle_ornit.text = "Add Photo or Video"
        addTitle_ornit.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        addTitle_ornit.textColor = ColorConfig_Ornit.publishAccent_Ornit
        mediaPlaceholderStack_Ornit.addArrangedSubview(addTitle_ornit)

        // 占位：次级提示文字
        let addHint_ornit = UILabel()
        addHint_ornit.text = "Tap to choose from library"
        addHint_ornit.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        addHint_ornit.textColor = ColorConfig_Ornit.textPlaceholder_Ornit
        mediaPlaceholderStack_Ornit.addArrangedSubview(addHint_ornit)

        mediaPickerView_Ornit.addSubview(mediaPlaceholderStack_Ornit)

        // 视频覆盖层：播放图标居中
        let videoConfig_ornit = UIImage.SymbolConfiguration(pointSize: 34, weight: .medium)
        let videoIcon_ornit = UIImageView(
            image: UIImage(systemName: "play.circle.fill", withConfiguration: videoConfig_ornit)
        )
        videoIcon_ornit.tintColor = .white
        videoIcon_ornit.contentMode = .scaleAspectFit
        videoOverlay_Ornit.addSubview(videoIcon_ornit)

        mediaPickerView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(headerView_Ornit.snp.bottom).offset(20)
            make_ornit.leading.equalToSuperview().offset(20)
            make_ornit.trailing.equalToSuperview().offset(-20)
            make_ornit.height.equalTo(188)
        }

        mediaPreview_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview()
        }
        videoOverlay_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview()
        }

        videoIcon_ornit.snp.makeConstraints { make_ornit in
            make_ornit.center.equalToSuperview()
            make_ornit.width.height.equalTo(50)
        }

        mediaPlaceholderStack_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.center.equalToSuperview()
        }

        cameraIcon_ornit.snp.makeConstraints { make_ornit in
            make_ornit.width.height.equalTo(50)
        }

        let tap_ornit = UITapGestureRecognizer(target: self, action: #selector(mediaTapped_Ornit))
        mediaPickerView_Ornit.addGestureRecognizer(tap_ornit)
    }

    /// 构建快捷拍摄提示横条（横向滚动小芯片）
    private func setupTipsBar_Ornit() {
        let tips_ornit: [(icon: String, text: String)] = [
            ("sun.max.fill", "Good lighting"),
            ("leaf.fill", "Show habitat"),
            ("location.fill", "Note location"),
            ("camera.fill", "Close-up shot"),
            ("eye.fill", "Note behavior")
        ]

        contentView_Ornit.addSubview(tipsScrollView_Ornit)

        let tipsStack_ornit = UIStackView()
        tipsStack_ornit.axis = .horizontal
        tipsStack_ornit.spacing = 8
        tipsStack_ornit.alignment = .center
        tipsScrollView_Ornit.addSubview(tipsStack_ornit)

        for tip_ornit in tips_ornit {
            let chip_ornit = makeTipChip_Ornit(icon_Ornit: tip_ornit.icon, text_Ornit: tip_ornit.text)
            tipsStack_ornit.addArrangedSubview(chip_ornit)
        }

        tipsScrollView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(mediaPickerView_Ornit.snp.bottom).offset(12)
            make_ornit.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(36)
        }

        tipsStack_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.bottom.leading.trailing.equalToSuperview()
            make_ornit.height.equalToSuperview()
        }
    }

    /// 创建单个提示芯片（图标 + 文字的圆角横条）
    /// - Parameters:
    ///   - icon_Ornit: SF Symbol 图标名称
    ///   - text_Ornit: 提示文字
    /// - Returns: 配置完成的 UIStackView 芯片容器
    private func makeTipChip_Ornit(icon_Ornit: String, text_Ornit: String) -> UIStackView {
        let stack_ornit = UIStackView()
        stack_ornit.axis = .horizontal
        stack_ornit.spacing = 5
        stack_ornit.alignment = .center
        stack_ornit.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        stack_ornit.isLayoutMarginsRelativeArrangement = true
        stack_ornit.backgroundColor = ColorConfig_Ornit.publishAccent_Ornit.withValues(alpha: 0.1)
        stack_ornit.layer.cornerRadius = 18

        let iconConfig_ornit = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        let iv_ornit = UIImageView(
            image: UIImage(systemName: icon_Ornit, withConfiguration: iconConfig_ornit)
        )
        iv_ornit.tintColor = ColorConfig_Ornit.publishAccent_Ornit
        iv_ornit.contentMode = .scaleAspectFit
        iv_ornit.snp.makeConstraints { make_ornit in
            make_ornit.width.height.equalTo(13)
        }

        let label_ornit = UILabel()
        label_ornit.text = text_Ornit
        label_ornit.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label_ornit.textColor = ColorConfig_Ornit.publishGradientStart_Ornit

        stack_ornit.addArrangedSubview(iv_ornit)
        stack_ornit.addArrangedSubview(label_ornit)

        return stack_ornit
    }

    /// 构建表单输入卡片（区段标题 + 标题输入框 + 内容输入区 + 字符计数）
    private func setupFormCard_Ornit() {
        formCard_Ornit.backgroundColor = .white
        formCard_Ornit.layer.cornerRadius = 20
        formCard_Ornit.layer.shadowColor = ColorConfig_Ornit.publishAccent_Ornit.withValues(alpha: 0.16).cgColor
        formCard_Ornit.layer.shadowOffset = CGSize(width: 0, height: 4)
        formCard_Ornit.layer.shadowOpacity = 1
        formCard_Ornit.layer.shadowRadius = 14
        contentView_Ornit.addSubview(formCard_Ornit)

        // 「Sighting Title」区段头
        let titleSection_ornit = makeSectionHeader_Ornit(
            icon_Ornit: "text.cursor",
            title_Ornit: "Sighting Title"
        )
        formCard_Ornit.addSubview(titleSection_ornit)

        // 标题输入框容器（浅暖背景圆角卡）
        let titleFieldBg_ornit = UIView()
        titleFieldBg_ornit.backgroundColor = ColorConfig_Ornit.backgroundWarm_Ornit
        titleFieldBg_ornit.layer.cornerRadius = 12
        titleFieldBg_ornit.layer.borderWidth = 1
        titleFieldBg_ornit.layer.borderColor = ColorConfig_Ornit.divider_Ornit.cgColor
        formCard_Ornit.addSubview(titleFieldBg_ornit)
        titleFieldBg_ornit.addSubview(titleField_Ornit)

        // 分割线
        let divider_ornit = UIView()
        divider_ornit.backgroundColor = ColorConfig_Ornit.divider_Ornit
        formCard_Ornit.addSubview(divider_ornit)

        // 「Details」区段头
        let detailSection_ornit = makeSectionHeader_Ornit(
            icon_Ornit: "square.and.pencil",
            title_Ornit: "Details"
        )
        formCard_Ornit.addSubview(detailSection_ornit)

        // 内容输入框容器
        let contentFieldBg_ornit = UIView()
        contentFieldBg_ornit.backgroundColor = ColorConfig_Ornit.backgroundWarm_Ornit
        contentFieldBg_ornit.layer.cornerRadius = 12
        contentFieldBg_ornit.layer.borderWidth = 1
        contentFieldBg_ornit.layer.borderColor = ColorConfig_Ornit.divider_Ornit.cgColor
        formCard_Ornit.addSubview(contentFieldBg_ornit)
        contentFieldBg_ornit.addSubview(contentTextView_Ornit)
        contentTextView_Ornit.addSubview(contentPlaceholder_Ornit)
        contentFieldBg_ornit.addSubview(charCountLabel_Ornit)

        // 约束：formCard 本身
        formCard_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(tipsScrollView_Ornit.snp.bottom).offset(16)
            make_ornit.leading.equalToSuperview().offset(20)
            make_ornit.trailing.equalToSuperview().offset(-20)
        }

        // 「标题」区段头
        titleSection_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalToSuperview().offset(20)
            make_ornit.leading.equalToSuperview().offset(16)
        }

        // 标题输入框容器
        titleFieldBg_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(titleSection_ornit.snp.bottom).offset(10)
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.height.equalTo(50)
        }

        titleField_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(14)
            make_ornit.trailing.equalToSuperview().offset(-14)
            make_ornit.centerY.equalToSuperview()
        }

        // 分割线
        divider_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(titleFieldBg_ornit.snp.bottom).offset(20)
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.height.equalTo(0.5)
        }

        // 「内容」区段头
        detailSection_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(divider_ornit.snp.bottom).offset(16)
            make_ornit.leading.equalToSuperview().offset(16)
        }

        // 内容输入框容器
        contentFieldBg_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(detailSection_ornit.snp.bottom).offset(10)
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.bottom.equalToSuperview().offset(-20)
        }

        contentTextView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.leading.trailing.equalToSuperview()
            make_ornit.bottom.equalToSuperview()
            make_ornit.height.greaterThanOrEqualTo(110)
        }

        contentPlaceholder_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalToSuperview().offset(10)
            make_ornit.leading.equalToSuperview().offset(10)
            make_ornit.trailing.equalToSuperview().offset(-10)
        }

        // 字符计数标签固定在内容容器右下角
        charCountLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-12)
            make_ornit.bottom.equalToSuperview().offset(-8)
        }

        titleField_Ornit.delegate = self
        contentTextView_Ornit.delegate = self
    }

    /// 创建区段标题视图（图标圆形背景 + 小标题文字）
    /// - Parameters:
    ///   - icon_Ornit: SF Symbol 图标名称
    ///   - title_Ornit: 区段标题文字
    /// - Returns: 水平排列的 UIStackView
    private func makeSectionHeader_Ornit(icon_Ornit: String, title_Ornit: String) -> UIStackView {
        let stack_ornit = UIStackView()
        stack_ornit.axis = .horizontal
        stack_ornit.spacing = 8
        stack_ornit.alignment = .center

        // 图标圆形背景
        let iconBg_ornit = UIView()
        iconBg_ornit.backgroundColor = ColorConfig_Ornit.publishAccent_Ornit.withValues(alpha: 0.12)
        iconBg_ornit.layer.cornerRadius = 12

        let iconConfig_ornit = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        let iv_ornit = UIImageView(
            image: UIImage(systemName: icon_Ornit, withConfiguration: iconConfig_ornit)
        )
        iv_ornit.tintColor = ColorConfig_Ornit.publishAccent_Ornit
        iv_ornit.contentMode = .scaleAspectFit
        iconBg_ornit.addSubview(iv_ornit)

        iv_ornit.snp.makeConstraints { make_ornit in
            make_ornit.center.equalToSuperview()
            make_ornit.width.height.equalTo(13)
        }
        iconBg_ornit.snp.makeConstraints { make_ornit in
            make_ornit.width.height.equalTo(24)
        }

        let label_ornit = UILabel()
        label_ornit.text = title_Ornit
        label_ornit.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label_ornit.textColor = ColorConfig_Ornit.textSecondary_Ornit

        stack_ornit.addArrangedSubview(iconBg_ornit)
        stack_ornit.addArrangedSubview(label_ornit)

        return stack_ornit
    }

    /// 构建发布按钮（渐变背景 + 图标 + 文字 + 阴影）及 EULA 说明
    private func setupPublishButton_Ornit() {
        // 用容器 View 承载阴影，按钮本身保持 masksToBounds = true 确保渐变层被正确裁切到圆角内
        let btnWrapper_ornit = UIView()
        btnWrapper_ornit.layer.cornerRadius = 16
        btnWrapper_ornit.layer.shadowColor = ColorConfig_Ornit.publishGradientEnd_Ornit.withValues(alpha: 0.45).cgColor
        btnWrapper_ornit.layer.shadowOffset = CGSize(width: 0, height: 6)
        btnWrapper_ornit.layer.shadowOpacity = 1
        btnWrapper_ornit.layer.shadowRadius = 14
        contentView_Ornit.addSubview(btnWrapper_ornit)
        btnWrapper_ornit.addSubview(publishButton_Ornit)

        // 发布按钮渐变（琥珀橙，从左到右）
        let btnGrad_ornit = CAGradientLayer()
        btnGrad_ornit.colors = [
            ColorConfig_Ornit.publishGradientStart_Ornit.cgColor,
            ColorConfig_Ornit.publishGradientEnd_Ornit.cgColor
        ]
        btnGrad_ornit.startPoint = CGPoint(x: 0, y: 0.5)
        btnGrad_ornit.endPoint = CGPoint(x: 1, y: 0.5)
        publishButton_Ornit.layer.insertSublayer(btnGrad_ornit, at: 0)
        publishGradient_Ornit = btnGrad_ornit

        // 按钮保持 masksToBounds = true，渐变层正确裁切到圆角
        publishButton_Ornit.layer.masksToBounds = true

        btnWrapper_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(formCard_Ornit.snp.bottom).offset(24)
            make_ornit.leading.equalToSuperview().offset(20)
            make_ornit.trailing.equalToSuperview().offset(-20)
            make_ornit.height.equalTo(56)
        }
        publishButton_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview()
        }
        publishButton_Ornit.addTarget(self, action: #selector(publishTapped_Ornit), for: .touchUpInside)

        // EULA 说明文字（富文本，含下划线链接）
        let eulaButton_ornit = UIButton(type: .system)
        let attrStr_ornit = NSMutableAttributedString(
            string: "By publishing, you agree to our ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: ColorConfig_Ornit.textSecondary_Ornit
            ]
        )
        attrStr_ornit.append(NSAttributedString(
            string: "EULA",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: ColorConfig_Ornit.publishAccent_Ornit,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        ))
        eulaButton_ornit.setAttributedTitle(attrStr_ornit, for: .normal)
        contentView_Ornit.addSubview(eulaButton_ornit)

        eulaButton_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(publishButton_Ornit.snp.bottom).offset(12)
            make_ornit.centerX.equalToSuperview()
            // 撑起 contentView 的底部
            make_ornit.bottom.equalToSuperview().offset(-100)
        }

        eulaButton_ornit.addTarget(self, action: #selector(eulaTapped_Ornit), for: .touchUpInside)
    }

    // MARK: - 数据重置

    /// 清空所有输入字段及媒体选择状态，用于发布成功后重置页面
    private func clearAllFields_Ornit() {
        titleField_Ornit.text = ""
        contentTextView_Ornit.text = ""
        contentPlaceholder_Ornit.isHidden = false
        charCountLabel_Ornit.text = "0 / 300"
        selectedMediaPath_Ornit = nil
        selectedMediaImage_Ornit = nil
        mediaPreview_Ornit.image = nil
        mediaPreview_Ornit.isHidden = true
        videoOverlay_Ornit.isHidden = true
        mediaPlaceholderStack_Ornit.isHidden = false
    }

    // MARK: - 事件处理

    /// 点击媒体选取区，弹出媒体选择器
    @objc private func mediaTapped_Ornit() {
        UIView.animate(withDuration: 0.1, animations: {
            self.mediaPickerView_Ornit.alpha = 0.7
        }) { _ in
            UIView.animate(withDuration: 0.1) { self.mediaPickerView_Ornit.alpha = 1 }
        }

        MediaPickerHelper_Ornit.pickMedia_Ornit(from: self) { [weak self] result_ornit in
            guard let self = self else { return }
            switch result_ornit {
            case .photo_Ornit(let image_ornit):
                self.selectedMediaImage_Ornit = image_ornit
                self.selectedMediaPath_Ornit = "user_photo_\(Int(Date().timeIntervalSince1970))"
                self.mediaPreview_Ornit.image = image_ornit
                self.mediaPreview_Ornit.isHidden = false
                self.videoOverlay_Ornit.isHidden = true
                self.mediaPlaceholderStack_Ornit.isHidden = true

            case .video_Ornit(let url_ornit):
                self.selectedMediaPath_Ornit = url_ornit.path
                self.mediaPlaceholderStack_Ornit.isHidden = true
                self.mediaPreview_Ornit.isHidden = false
                self.videoOverlay_Ornit.isHidden = false
                // 视频封面暂用琥珀渐变色占位
                self.mediaPreview_Ornit.image = nil
                self.mediaPreview_Ornit.backgroundColor = ColorConfig_Ornit.publishGradientEnd_Ornit.withValues(alpha: 0.3)

            case .cancelled_Ornit:
                break
            }
        }
    }

    /// 点击发布按钮，校验后调用 ViewModel 发布帖子
    @objc private func publishTapped_Ornit() {
        // 未登录时跳转登录页
        guard UserViewModel_Ornit.shared_Ornit.isLoggedIn_Ornit else {
            Navigation_Ornit.toLogin_Ornit()
            return
        }

        let title_ornit = titleField_Ornit.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let content_ornit = contentTextView_Ornit.text?.trimmingCharacters(in: .whitespaces) ?? ""

        guard !title_ornit.isEmpty else {
            Utils_Ornit.showWarning_Ornit(message_Ornit: "Please enter a title")
            return
        }
        guard !content_ornit.isEmpty else {
            Utils_Ornit.showWarning_Ornit(message_Ornit: "Please describe your sighting")
            return
        }
        guard let mediaPath_ornit = selectedMediaPath_Ornit, !mediaPath_ornit.isEmpty else {
            Utils_Ornit.showWarning_Ornit(message_Ornit: "Please add a photo or video")
            return
        }

        // 发布按钮弹跳动画
        UIView.animate(withDuration: 0.1, animations: {
            self.publishButton_Ornit.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.publishButton_Ornit.transform = .identity
            }
        }

        TitleViewModel_Ornit.shared_Ornit.releasePost_Ornit(
            title_ornit: title_ornit,
            content_ornit: content_ornit,
            media_ornit: mediaPath_ornit
        )

        // 发布成功：重置页面后延迟关闭
        clearAllFields_Ornit()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            Navigation_Ornit.dismiss_Ornit(from: self)
        }
    }

    /// 点击 EULA 按钮，弹出用户协议
    @objc private func eulaTapped_Ornit() {
        ProtocolHelper_Ornit.showProtocol_Ornit(
            type_Ornit: .eula_Ornit,
            content_Ornit: "eula",
            from: self
        )
    }
}

// MARK: - UITextFieldDelegate & UITextViewDelegate

extension Release_Ornit: UITextFieldDelegate, UITextViewDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentTextView_Ornit.becomeFirstResponder()
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        let count_ornit = textView.text.count
        contentPlaceholder_Ornit.isHidden = count_ornit > 0
        // 超过 300 字时计数标签变红提示
        let color_ornit: UIColor = count_ornit > 300
            ? UIColor(hexstring_Ornit: "#EF4444")
            : ColorConfig_Ornit.textPlaceholder_Ornit
        charCountLabel_Ornit.textColor = color_ornit
        charCountLabel_Ornit.text = "\(count_ornit) / 300"
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        contentPlaceholder_Ornit.isHidden = true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        contentPlaceholder_Ornit.isHidden = !textView.text.isEmpty
    }
}
