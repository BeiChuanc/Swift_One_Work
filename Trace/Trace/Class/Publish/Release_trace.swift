import UIKit
import SnapKit
import PhotosUI
import AVFoundation

// MARK: - 发布页

/// 帖子发布页视图控制器
/// 核心作用：提供标题输入、标签选择、内容输入、媒体选择功能，验证通过后调用 TitleViewModel_Trace 发布帖子
/// 设计思路：垂直滚动表单，顶部媒体区域 + 卡片式字段 + 底部渐变发布按钮
/// 关键属性：selectedImage_Trace（预览图），selectedTag_Trace（帖子标签），isVideo_Trace（是否视频）
class Release_Trace: UIViewController {
    
    // MARK: - 常量
    
    private let tags_Trace = ["Life", "Moments", "Night", "Nature", "Memory", "Stars", "Warmth", "Friends"]
    
    private static let tagColorMap_Trace: [String: (String, String)] = [
        "Life": ("#B794F6", "#90CDF4"), "Moments": ("#FBB6CE", "#FED7AA"),
        "Night": ("#553C9A", "#6B46C1"), "Nature": ("#68D391", "#38B2AC"),
        "Memory": ("#F6AD55", "#ED8936"), "Stars": ("#F6E05E", "#ECC94B"),
        "Warmth": ("#FC8181", "#F6AD55"), "Friends": ("#76E4F7", "#4299E1")
    ]
    
    // MARK: - 私有属性
    
    private var selectedTag_Trace: String = "Life"
    private var selectedImage_Trace: UIImage?
    private var isVideo_Trace: Bool = false
    private var tagButtons_Trace: [UIButton] = []
    
    // MARK: - UI 组件
    
    private let scrollView_Trace: UIScrollView = {
        let sv_Trace = UIScrollView()
        sv_Trace.showsVerticalScrollIndicator = false
        sv_Trace.alwaysBounceVertical = true
        sv_Trace.keyboardDismissMode = .onDrag
        // 禁止系统自动调整 contentInset，防止导航栏高度被叠加产生顶部空白
        sv_Trace.contentInsetAdjustmentBehavior = .never
        return sv_Trace
    }()
    
    private let contentView_Trace = UIView()
    
    // --- 顶部导航背景渐变 ---
    private let navGradView_Trace: UIView = {
        let v_Trace = UIView()
        return v_Trace
    }()
    private let navGradLayer_Trace = CAGradientLayer()
    
    // --- 顶部描述区域 ---
    private let headerDescView_Trace = UIView()
    
    // --- 媒体选择区域 ---
    
    private let mediaCard_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.backgroundColor = .white
        v_Trace.layer.cornerRadius = 20
        v_Trace.layer.masksToBounds = true
        return v_Trace
    }()
    
    private let mediaImageView_Trace: UIImageView = {
        let iv_Trace = UIImageView()
        iv_Trace.contentMode = .scaleAspectFill
        iv_Trace.clipsToBounds = true
        iv_Trace.isHidden = true
        return iv_Trace
    }()
    
    private let mediaPlaceholderView_Trace: UIView = {
        let v_Trace = UIView()
        return v_Trace
    }()
    
    private let mediaPlaceholderIcon_Trace: UIImageView = {
        let iv_Trace = UIImageView()
        let config_Trace = UIImage.SymbolConfiguration(pointSize: 36, weight: .light)
        iv_Trace.image = UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: config_Trace)
        iv_Trace.tintColor = UIColor(hexstring_Trace: "#CBD5E0")
        iv_Trace.contentMode = .scaleAspectFit
        return iv_Trace
    }()
    
    private let mediaPlaceholderLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.text = "Tap to add photo or video"
        lbl_Trace.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lbl_Trace.textColor = UIColor(hexstring_Trace: "#A0AEC0")
        lbl_Trace.textAlignment = .center
        return lbl_Trace
    }()
    
    /// 视频播放图标（选择视频后显示）
    private let videoPlayOverlay_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        v_Trace.isHidden = true
        return v_Trace
    }()
    
    private let videoPlayIcon_Trace: UIImageView = {
        let iv_Trace = UIImageView()
        let config_Trace = UIImage.SymbolConfiguration(pointSize: 44, weight: .medium)
        iv_Trace.image = UIImage(systemName: "play.circle.fill", withConfiguration: config_Trace)
        iv_Trace.tintColor = .white
        iv_Trace.contentMode = .scaleAspectFit
        return iv_Trace
    }()
    
    /// 更换媒体按钮（选中后右上角显示）
    private let changeMediaBtn_Trace: UIButton = {
        let btn_Trace = UIButton(type: .custom)
        btn_Trace.setTitle("Change", for: .normal)
        btn_Trace.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        btn_Trace.setTitleColor(.white, for: .normal)
        btn_Trace.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        btn_Trace.layer.cornerRadius = 12
        btn_Trace.layer.masksToBounds = true
        btn_Trace.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        btn_Trace.isHidden = true
        return btn_Trace
    }()
    
    // --- 标题输入卡片 ---
    
    private let titleCard_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.backgroundColor = .white
        v_Trace.layer.cornerRadius = 16
        v_Trace.layer.shadowColor = UIColor.black.cgColor
        v_Trace.layer.shadowOffset = CGSize(width: 0, height: 2)
        v_Trace.layer.shadowRadius = 8
        v_Trace.layer.shadowOpacity = 0.05
        return v_Trace
    }()
    
    private let titleField_Trace: UITextField = {
        let tf_Trace = UITextField()
        tf_Trace.placeholder = "Give your moment a title..."
        tf_Trace.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        tf_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
        tf_Trace.returnKeyType = .next
        tf_Trace.clearButtonMode = .whileEditing
        return tf_Trace
    }()
    
    // --- 标签选择 ---
    
    private let tagScrollView_Trace: UIScrollView = {
        let sv_Trace = UIScrollView()
        sv_Trace.showsHorizontalScrollIndicator = false
        sv_Trace.clipsToBounds = false
        return sv_Trace
    }()
    
    private let tagStackView_Trace: UIStackView = {
        let sv_Trace = UIStackView()
        sv_Trace.axis = .horizontal
        sv_Trace.spacing = 8
        sv_Trace.alignment = .center
        return sv_Trace
    }()
    
    // --- 内容输入卡片 ---
    
    private let contentCard_Trace: UIView = {
        let v_Trace = UIView()
        v_Trace.backgroundColor = .white
        v_Trace.layer.cornerRadius = 16
        v_Trace.layer.shadowColor = UIColor.black.cgColor
        v_Trace.layer.shadowOffset = CGSize(width: 0, height: 2)
        v_Trace.layer.shadowRadius = 8
        v_Trace.layer.shadowOpacity = 0.05
        return v_Trace
    }()
    
    private let contentTextView_Trace: UITextView = {
        let tv_Trace = UITextView()
        tv_Trace.font = UIFont.systemFont(ofSize: 15)
        tv_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
        tv_Trace.backgroundColor = .clear
        tv_Trace.textContainerInset = .zero
        tv_Trace.textContainer.lineFragmentPadding = 0
        tv_Trace.isScrollEnabled = false
        return tv_Trace
    }()
    
    private let contentPlaceholder_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.text = "Share the story behind this moment..."
        lbl_Trace.font = UIFont.systemFont(ofSize: 15)
        lbl_Trace.textColor = UIColor(hexstring_Trace: "#A0AEC0")
        lbl_Trace.numberOfLines = 2
        return lbl_Trace
    }()
    
    private let charCountLabel_Trace: UILabel = {
        let lbl_Trace = UILabel()
        lbl_Trace.text = "0 / 500"
        lbl_Trace.font = UIFont.systemFont(ofSize: 11)
        lbl_Trace.textColor = ColorConfig_Trace.textPlaceholder_Trace
        lbl_Trace.textAlignment = .right
        return lbl_Trace
    }()
    
    // --- 发布按钮 ---
    
    private lazy var publishButton_Trace: UIButton = {
        let btn_Trace = UIButton(type: .custom)
        btn_Trace.layer.cornerRadius = 26
        btn_Trace.layer.masksToBounds = true
        btn_Trace.addTarget(self, action: #selector(handlePublish_Trace), for: .touchUpInside)
        return btn_Trace
    }()
    
    private let publishGradLayer_Trace = CAGradientLayer()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation_Trace()
        setupUI_Trace()
        setupTagButtons_Trace()
        updateTagStates_Trace()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navGradLayer_Trace.frame = navGradView_Trace.bounds
        publishGradLayer_Trace.frame = publishButton_Trace.bounds
    }
    
    // MARK: - 导航栏配置
    
    private func setupNavigation_Trace() {
        title = "New Post"
        // 禁用大标题模式，避免导航栏撑开产生额外顶部空白
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = ColorConfig_Trace.primaryGradientStart_Trace
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(handleClose_Trace)
        )
    }
    
    // MARK: - UI 配置
    
    private func setupUI_Trace() {
        view.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace

        view.addSubview(scrollView_Trace)
        scrollView_Trace.addSubview(contentView_Trace)
        // 底部额外预留 110pt（浮动 TabBar 高度 80 + 底部偏移 30），确保内容可滚动至 TabBar 上方
        scrollView_Trace.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0)
        scrollView_Trace.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        contentView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        setupHeaderDesc_Trace()
        setupMediaSection_Trace()
        setupFormSection_Trace()
        // 发布按钮位于表单卡片下方，跟随 ScrollView 滚动显示
        setupPublishButton_Trace()
        setupEulaButton_Trace()
    }
    
    /// 顶部页眉描述区：图标 + 主标题 + 副标题
    /// 功能：向用户说明发布页的主题与用途，营造「留存时光」的氛围感
    private func setupHeaderDesc_Trace() {
        contentView_Trace.addSubview(headerDescView_Trace)
        headerDescView_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        // 图标背景圆
        let iconBg_Trace = UIView()
        iconBg_Trace.backgroundColor = ColorConfig_Trace.primaryGradientStart_Trace.withAlphaComponent(0.12)
        iconBg_Trace.layer.cornerRadius = 24
        
        let iconIV_Trace = UIImageView()
        let iconCfg_Trace = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        iconIV_Trace.image = UIImage(systemName: "square.and.pencil", withConfiguration: iconCfg_Trace)
        iconIV_Trace.tintColor = ColorConfig_Trace.primaryGradientStart_Trace
        iconIV_Trace.contentMode = .scaleAspectFit
        
        // 主标题
        let titleLbl_Trace = UILabel()
        titleLbl_Trace.text = "Share a Trace"
        titleLbl_Trace.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLbl_Trace.textColor = ColorConfig_Trace.textPrimary_Trace
        
        // 副标题
        let subLbl_Trace = UILabel()
        subLbl_Trace.text = "Capture the story behind this moment — title it, tag it, and let it live in your timeline."
        subLbl_Trace.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subLbl_Trace.textColor = ColorConfig_Trace.textSecondary_Trace
        subLbl_Trace.numberOfLines = 2
        
        // 右侧小徽章：Record · Share
        let badgeStack_Trace = UIStackView()
        badgeStack_Trace.axis = .horizontal
        badgeStack_Trace.spacing = 6
        badgeStack_Trace.alignment = .center
        ["✦ Record", "✦ Share", "✦ Remember"].forEach { text_trace in
            let badge_Trace = UILabel()
            badge_Trace.text = text_trace
            badge_Trace.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
            badge_Trace.textColor = ColorConfig_Trace.primaryGradientStart_Trace.withAlphaComponent(0.7)
            badgeStack_Trace.addArrangedSubview(badge_Trace)
        }
        
        headerDescView_Trace.addSubview(iconBg_Trace)
        iconBg_Trace.addSubview(iconIV_Trace)
        headerDescView_Trace.addSubview(titleLbl_Trace)
        headerDescView_Trace.addSubview(subLbl_Trace)
        headerDescView_Trace.addSubview(badgeStack_Trace)
        
        iconBg_Trace.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.width.height.equalTo(48)
        }
        iconIV_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }
        titleLbl_Trace.snp.makeConstraints { make in
            make.leading.equalTo(iconBg_Trace.snp.trailing).offset(12)
            make.trailing.equalToSuperview()
            make.top.equalTo(iconBg_Trace.snp.top).offset(2)
        }
        subLbl_Trace.snp.makeConstraints { make in
            make.leading.equalTo(iconBg_Trace.snp.trailing).offset(12)
            make.trailing.equalToSuperview()
            make.top.equalTo(titleLbl_Trace.snp.bottom).offset(4)
        }
        badgeStack_Trace.snp.makeConstraints { make in
            make.leading.equalTo(iconBg_Trace.snp.trailing).offset(12)
            make.top.equalTo(subLbl_Trace.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 媒体选择区域
    private func setupMediaSection_Trace() {
        contentView_Trace.addSubview(mediaCard_Trace)
        mediaCard_Trace.addSubview(mediaPlaceholderView_Trace)
        mediaCard_Trace.addSubview(mediaImageView_Trace)
        mediaCard_Trace.addSubview(videoPlayOverlay_Trace)
        videoPlayOverlay_Trace.addSubview(videoPlayIcon_Trace)
        mediaCard_Trace.addSubview(changeMediaBtn_Trace)
        mediaPlaceholderView_Trace.addSubview(mediaPlaceholderIcon_Trace)
        mediaPlaceholderView_Trace.addSubview(mediaPlaceholderLabel_Trace)
        
        mediaCard_Trace.snp.makeConstraints { make in
            make.top.equalTo(headerDescView_Trace.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(220)
        }
        
        // 占位符视图
        mediaPlaceholderView_Trace.snp.makeConstraints { make in make.edges.equalToSuperview() }
        mediaPlaceholderIcon_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview().offset(-16)
            make.width.height.equalTo(52)
        }
        mediaPlaceholderLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(mediaPlaceholderIcon_Trace.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        // 媒体预览
        mediaImageView_Trace.snp.makeConstraints { make in make.edges.equalToSuperview() }
        videoPlayOverlay_Trace.snp.makeConstraints { make in make.edges.equalToSuperview() }
        videoPlayIcon_Trace.snp.makeConstraints { make in make.center.equalToSuperview(); make.width.height.equalTo(56) }
        changeMediaBtn_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        // 渐变占位符背景
        let bg_Trace = CAGradientLayer()
        bg_Trace.colors = [
            UIColor(hexstring_Trace: "#F7F5FF").cgColor,
            UIColor(hexstring_Trace: "#EEF2FF").cgColor
        ]
        bg_Trace.startPoint = CGPoint(x: 0, y: 0)
        bg_Trace.endPoint = CGPoint(x: 1, y: 1)
        bg_Trace.cornerRadius = 20
        mediaCard_Trace.layer.insertSublayer(bg_Trace, at: 0)
        DispatchQueue.main.async { bg_Trace.frame = self.mediaCard_Trace.bounds }
        
        // 点击手势
        let tap_Trace = UITapGestureRecognizer(target: self, action: #selector(handleMediaTap_Trace))
        mediaCard_Trace.addGestureRecognizer(tap_Trace)
        mediaCard_Trace.isUserInteractionEnabled = true
        changeMediaBtn_Trace.addTarget(self, action: #selector(handleMediaTap_Trace), for: .touchUpInside)
    }
    
    /// 表单区域（标题 + 标签 + 内容）
    private func setupFormSection_Trace() {
        // --- 标题 section label ---
        let titleSectionLbl_Trace = makeSectionLabel_Trace(text_trace: "Title")
        contentView_Trace.addSubview(titleSectionLbl_Trace)
        titleSectionLbl_Trace.snp.makeConstraints { make in
            make.top.equalTo(mediaCard_Trace.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(24)
        }
        
        // --- 标题卡片 ---
        contentView_Trace.addSubview(titleCard_Trace)
        titleCard_Trace.addSubview(titleField_Trace)
        titleCard_Trace.snp.makeConstraints { make in
            make.top.equalTo(titleSectionLbl_Trace.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        titleField_Trace.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        titleField_Trace.delegate = self
        
        // --- Tag section label ---
        let tagSectionLbl_Trace = makeSectionLabel_Trace(text_trace: "Tag")
        contentView_Trace.addSubview(tagSectionLbl_Trace)
        tagSectionLbl_Trace.snp.makeConstraints { make in
            make.top.equalTo(titleCard_Trace.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(24)
        }
        
        contentView_Trace.addSubview(tagScrollView_Trace)
        tagScrollView_Trace.addSubview(tagStackView_Trace)
        tagScrollView_Trace.snp.makeConstraints { make in
            make.top.equalTo(tagSectionLbl_Trace.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(38)
        }
        tagStackView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.height.equalToSuperview()
        }
        
        // --- Content section label ---
        let contentSectionLbl_Trace = makeSectionLabel_Trace(text_trace: "Content")
        contentView_Trace.addSubview(contentSectionLbl_Trace)
        contentSectionLbl_Trace.snp.makeConstraints { make in
            make.top.equalTo(tagScrollView_Trace.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(24)
        }
        
        // --- 内容输入卡片 ---
        contentView_Trace.addSubview(contentCard_Trace)
        contentCard_Trace.addSubview(contentTextView_Trace)
        contentCard_Trace.addSubview(contentPlaceholder_Trace)
        contentCard_Trace.addSubview(charCountLabel_Trace)
        contentCard_Trace.snp.makeConstraints { make in
            make.top.equalTo(contentSectionLbl_Trace.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        contentPlaceholder_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.trailing.equalToSuperview().inset(14)
        }
        contentTextView_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.trailing.equalToSuperview().inset(14)
            make.height.greaterThanOrEqualTo(120)
        }
        charCountLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(contentTextView_Trace.snp.bottom).offset(8)
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-10)
        }
        contentTextView_Trace.delegate = self

        // contentCard 底部不再直接收尾，由后续 EULA 按钮区收尾
    }
    
    /// EULA 下划线文本按钮（发布按钮下方 10pt，作为滚动区底部收尾元素）
    /// 点击跳转 EULA 协议页，与 ProtocolHelper_Trace 联动
    private func setupEulaButton_Trace() {
        let eulaAttr_Trace = NSMutableAttributedString(string: "EULA")
        eulaAttr_Trace.addAttributes([
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: ColorConfig_Trace.textSecondary_Trace,
            .foregroundColor: ColorConfig_Trace.textSecondary_Trace,
            .font: UIFont.systemFont(ofSize: 12, weight: .regular)
        ], range: NSRange(location: 0, length: eulaAttr_Trace.length))

        let eulaBtn_Trace = UIButton(type: .custom)
        eulaBtn_Trace.setAttributedTitle(eulaAttr_Trace, for: .normal)
        eulaBtn_Trace.contentHorizontalAlignment = .center
        eulaBtn_Trace.addTarget(self, action: #selector(handleEulaTap_Trace), for: .touchUpInside)

        contentView_Trace.addSubview(eulaBtn_Trace)
        eulaBtn_Trace.snp.makeConstraints { make in
            // 紧贴发布按钮下方 10pt
            make.top.equalTo(publishButton_Trace.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(28)
            // ScrollView 内容区收尾约束
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    /// 确认发布按钮（跟随 ScrollView 滚动，位于表单卡片下方，EULA 按钮上方 10pt）
    private func setupPublishButton_Trace() {
        contentView_Trace.addSubview(publishButton_Trace)
        publishButton_Trace.snp.makeConstraints { make in
            make.top.equalTo(contentCard_Trace.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        // 渐变背景
        publishGradLayer_Trace.colors = [
            ColorConfig_Trace.primaryGradientStart_Trace.cgColor,
            ColorConfig_Trace.primaryGradientEnd_Trace.cgColor
        ]
        publishGradLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        publishGradLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
        publishGradLayer_Trace.cornerRadius = 26
        publishButton_Trace.layer.insertSublayer(publishGradLayer_Trace, at: 0)
        // 延迟一帧确保 bounds 已确定后再设置渐变 frame
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.publishGradLayer_Trace.frame = self.publishButton_Trace.bounds
        }
        // 标题 label 作为 subview 叠在渐变层之上（CAGradientLayer 会遮挡 setTitle 内容）
        let titleLbl_Trace = UILabel()
        titleLbl_Trace.text = "Publish Trace"
        titleLbl_Trace.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLbl_Trace.textColor = .white
        titleLbl_Trace.textAlignment = .center
        titleLbl_Trace.isUserInteractionEnabled = false
        publishButton_Trace.addSubview(titleLbl_Trace)
        titleLbl_Trace.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }
    
    // MARK: - 标签按钮构建
    
    private func setupTagButtons_Trace() {
        for (index_Trace, tag_Trace) in tags_Trace.enumerated() {
            let btn_Trace = UIButton(type: .custom)
            btn_Trace.tag = index_Trace
            btn_Trace.setTitle(tag_Trace, for: .normal)
            btn_Trace.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            btn_Trace.layer.cornerRadius = 16
            btn_Trace.layer.masksToBounds = true
            btn_Trace.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
            btn_Trace.addTarget(self, action: #selector(handleTagTap_Trace(_:)), for: .touchUpInside)
            btn_Trace.snp.makeConstraints { make in make.height.equalTo(32) }
            tagButtons_Trace.append(btn_Trace)
            tagStackView_Trace.addArrangedSubview(btn_Trace)
        }
    }
    
    private func updateTagStates_Trace() {
        for btn_Trace in tagButtons_Trace {
            let tag_Trace = tags_Trace[btn_Trace.tag]
            let colors_Trace = Self.tagColorMap_Trace[tag_Trace] ?? ("#B794F6", "#90CDF4")
            btn_Trace.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
            
            if tag_Trace == selectedTag_Trace {
                let grad_Trace = CAGradientLayer()
                grad_Trace.colors = [UIColor(hexstring_Trace: colors_Trace.0).cgColor, UIColor(hexstring_Trace: colors_Trace.1).cgColor]
                grad_Trace.startPoint = CGPoint(x: 0, y: 0)
                grad_Trace.endPoint = CGPoint(x: 1, y: 1)
                grad_Trace.cornerRadius = 16
                btn_Trace.layer.insertSublayer(grad_Trace, at: 0)
                btn_Trace.setTitleColor(.white, for: .normal)
                btn_Trace.layer.borderWidth = 0
                DispatchQueue.main.async { grad_Trace.frame = btn_Trace.bounds }
            } else {
                btn_Trace.backgroundColor = .white
                btn_Trace.setTitleColor(UIColor(hexstring_Trace: colors_Trace.0), for: .normal)
                btn_Trace.layer.borderWidth = 1.5
                btn_Trace.layer.borderColor = UIColor(hexstring_Trace: colors_Trace.0).withAlphaComponent(0.5).cgColor
            }
        }
    }
    
    // MARK: - 辅助方法

    /// 将选中图片持久化到 Documents 目录，返回文件名供 MediaDisplayView 加载
    /// - Parameter image_Trace: 需要保存的图片
    /// - Returns: 保存成功返回文件名（如 trace_post_1234567890.jpg），失败返回 nil
    private func saveImageToDisk_Trace(_ image_Trace: UIImage) -> String? {
        let fileName_Trace = "trace_post_\(Int(Date().timeIntervalSince1970)).jpg"
        let docs_Trace = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Trace = docs_Trace.appendingPathComponent(fileName_Trace)
        guard let data_Trace = image_Trace.jpegData(compressionQuality: 0.85) else {
            print("图片压缩失败，无法保存")
            return nil
        }
        do {
            try data_Trace.write(to: fileURL_Trace)
            print("图片已保存到 Documents: \(fileName_Trace)")
            return fileName_Trace
        } catch {
            print("图片保存失败: \(error)")
            return nil
        }
    }

    /// 发布成功后重置表单所有输入数据，保证下次进入页面是干净状态
    private func resetForm_Trace() {
        selectedImage_Trace = nil
        isVideo_Trace = false
        updateMediaPreview_Trace()

        titleField_Trace.text = ""
        contentTextView_Trace.text = ""
        charCountLabel_Trace.text = "0 / 500"
        contentPlaceholder_Trace.isHidden = false

        // 重置标签回第一项
        selectedTag_Trace = tags_Trace[0]
        updateTagStates_Trace()
    }

    /// 创建区域标题标签
    private func makeSectionLabel_Trace(text_trace: String) -> UILabel {
        let lbl_Trace = UILabel()
        lbl_Trace.text = text_trace.uppercased()
        lbl_Trace.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lbl_Trace.textColor = ColorConfig_Trace.textSecondary_Trace
        lbl_Trace.letterSpacing_Trace(spacing_trace: 1.2)
        return lbl_Trace
    }
    
    /// 更新媒体预览区域
    private func updateMediaPreview_Trace() {
        let hasMedia_Trace = selectedImage_Trace != nil
        mediaPlaceholderView_Trace.isHidden = hasMedia_Trace
        mediaImageView_Trace.isHidden = !hasMedia_Trace
        changeMediaBtn_Trace.isHidden = !hasMedia_Trace
        videoPlayOverlay_Trace.isHidden = !(hasMedia_Trace && isVideo_Trace)
        
        if let img_Trace = selectedImage_Trace {
            mediaImageView_Trace.image = img_Trace
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func handleClose_Trace() {
        Navigation_Trace.pop_Trace()
    }
    
    /// EULA 按钮点击：通过 ProtocolHelper_Trace 展示最终用户许可协议页面
    @objc private func handleEulaTap_Trace() {
        ProtocolHelper_Trace.showProtocol_Trace(
            type_Trace: .eula_Trace,
            content_Trace: "eula.png",
            from: self
        )
    }
    
    @objc private func handleMediaTap_Trace() {
        var config_Trace = PHPickerConfiguration()
        config_Trace.selectionLimit = 1
        config_Trace.filter = .any(of: [.images, .videos])
        let picker_Trace = PHPickerViewController(configuration: config_Trace)
        picker_Trace.delegate = self
        present(picker_Trace, animated: true)
    }
    
    @objc private func handleTagTap_Trace(_ sender: UIButton) {
        selectedTag_Trace = tags_Trace[sender.tag]
        sender.animatePressDown_Trace { sender.animatePressUp_Trace() }
        updateTagStates_Trace()
    }
    
    /// 处理发布按钮点击
    @objc private func handlePublish_Trace() {
        view.endEditing(true)
        
        // 1. 验证登录状态
        guard UserViewModel_Trace.shared_Trace.isLoggedIn_Trace else {
            Utils_Trace.showWarning_Trace(message_Trace: "Please login first.")
            Task {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                Navigation_Trace.toLogin_Trace(style_trace: .present_trace)
            }
            return
        }
        
        // 2. 验证标题
        let title_Trace = titleField_Trace.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !title_Trace.isEmpty else {
            Utils_Trace.showWarning_Trace(message_Trace: "Please enter a title.")
            titleField_Trace.becomeFirstResponder()
            return
        }
        
        // 3. 验证内容
        let content_Trace = contentTextView_Trace.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !content_Trace.isEmpty else {
            Utils_Trace.showWarning_Trace(message_Trace: "Please write something about this moment.")
            contentTextView_Trace.becomeFirstResponder()
            return
        }
        
        // 4. 验证媒体
        guard selectedImage_Trace != nil else {
            Utils_Trace.showWarning_Trace(message_Trace: "Please add a photo or video.")
            return
        }
        
        // 5. 将选中图片持久化到本地，获取可被 MediaDisplayView 加载的文件名
        let mediaFileName_Trace: String
        if let img_Trace = selectedImage_Trace,
           let savedName_Trace = saveImageToDisk_Trace(img_Trace) {
            mediaFileName_Trace = savedName_Trace
        } else {
            // 保存失败时使用空字符串，MediaDisplayView 会显示占位图
            mediaFileName_Trace = ""
        }

        // 6. 触觉反馈
        publishButton_Trace.animatePressDown_Trace { self.publishButton_Trace.animatePressUp_Trace() }
        let generator_Trace = UIImpactFeedbackGenerator(style: .medium)
        generator_Trace.impactOccurred()

        // 7. 发布帖子
        TitleViewModel_Trace.shared_Trace.releasePost_Trace(
            title_trace: title_Trace,
            content_trace: content_Trace,
            media_trace: mediaFileName_Trace,
            type_trace: 0
        )

        // 8. 重置表单，发布页复用同一 VC 实例（Tab 页），需清除旧数据
        resetForm_Trace()

        Navigation_Trace.pop_Trace()
    }
}

// MARK: - PHPickerViewControllerDelegate

extension Release_Trace: PHPickerViewControllerDelegate {
    
    /// 处理媒体选择结果（支持图片和视频）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result_Trace = results.first else { return }
        
        let provider_Trace = result_Trace.itemProvider
        if provider_Trace.canLoadObject(ofClass: UIImage.self) {
            // 图片
            provider_Trace.loadObject(ofClass: UIImage.self) { [weak self] image_trace, _ in
                DispatchQueue.main.async {
                    self?.isVideo_Trace = false
                    self?.selectedImage_Trace = image_trace as? UIImage
                    self?.updateMediaPreview_Trace()
                }
            }
        } else if provider_Trace.hasItemConformingToTypeIdentifier("public.movie") {
            // 视频 - 生成封面帧
            provider_Trace.loadFileRepresentation(forTypeIdentifier: "public.movie") { [weak self] url_trace, _ in
                guard let url_Trace = url_trace else { return }
                let asset_Trace = AVAsset(url: url_Trace)
                let gen_Trace = AVAssetImageGenerator(asset: asset_Trace)
                gen_Trace.appliesPreferredTrackTransform = true
                if let cgImage_Trace = try? gen_Trace.copyCGImage(at: .zero, actualTime: nil) {
                    DispatchQueue.main.async {
                        self?.isVideo_Trace = true
                        self?.selectedImage_Trace = UIImage(cgImage: cgImage_Trace)
                        self?.updateMediaPreview_Trace()
                    }
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension Release_Trace: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentTextView_Trace.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension Release_Trace: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let count_Trace = textView.text.count
        charCountLabel_Trace.text = "\(count_Trace) / 500"
        contentPlaceholder_Trace.isHidden = !textView.text.isEmpty
        if count_Trace > 500 {
            textView.text = String(textView.text.prefix(500))
            charCountLabel_Trace.textColor = UIColor(hexstring_Trace: "#FC8181")
        } else {
            charCountLabel_Trace.textColor = ColorConfig_Trace.textPlaceholder_Trace
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        contentPlaceholder_Trace.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        contentPlaceholder_Trace.isHidden = !textView.text.isEmpty
    }
}

// MARK: - UILabel 字间距扩展辅助

private extension UILabel {
    /// 设置字母间距
    func letterSpacing_Trace(spacing_trace: CGFloat) {
        guard let text_Trace = text else { return }
        let attr_Trace = NSMutableAttributedString(string: text_Trace)
        attr_Trace.addAttribute(.kern, value: spacing_trace, range: NSRange(location: 0, length: text_Trace.count))
        attributedText = attr_Trace
    }
}
