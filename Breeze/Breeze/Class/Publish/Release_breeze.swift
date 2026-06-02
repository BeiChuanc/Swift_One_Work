import Foundation
import UIKit
import SnapKit

// MARK: 发布页面

/// 发布页面（Tabbar 内嵌，非 present 弹出）
/// 核心作用：选择媒体、填写分类/标题/内容并发布帖子；发布后清空表单并切换至发现页
/// 设计思路：与 Discover 统一的渐变头部 + 卡片式输入区 + 分类 Chips + 渐变发布按钮
/// 关键属性：mediaPath_Breeze 已选媒体路径、selectedCategory_Breeze 当前选中分类
class Release_Breeze: UIViewController {
    
    // MARK: - 数据
    
    /// 已选媒体文件名
    private var mediaPath_Breeze: String?
    
    /// 已选媒体是否视频
    private var isVideo_Breeze: Bool = false
    
    /// 当前选中分类（默认露营）
    private var selectedCategory_Breeze: PostCategory_Breeze = .camping_breeze
    
    // MARK: - UI：渐变头部
    
    /// 头部渐变容器
    private let headerView_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.clipsToBounds = true
        return view_breeze
    }()
    
    /// 头部渐变图层（与 Discover 同款：青绿 → 天空蓝）
    private var headerGradientLayer_Breeze: CAGradientLayer?
    
    /// 装饰圆 - 右上角大圆
    private let decorLargeCircle_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        view_breeze.layer.cornerRadius = 75
        return view_breeze
    }()
    
    /// 装饰圆 - 左下小圆
    private let decorSmallCircle_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        view_breeze.layer.cornerRadius = 38
        return view_breeze
    }()
    
    /// 页面主标题
    private let pageTitleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "New Post"
        label_breeze.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        label_breeze.textColor = .white
        return label_breeze
    }()
    
    /// 页面副标题
    private let pageSubtitleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Share your outdoor story with the world"
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label_breeze.textColor = UIColor.white.withAlphaComponent(0.82)
        return label_breeze
    }()
    
    // MARK: - UI：滚动容器
    
    /// 主滚动视图（底部内边距 120pt，为悬浮 TabBar 留出空间）
    private let scrollView_Breeze: UIScrollView = {
        let sv_breeze = UIScrollView()
        sv_breeze.showsVerticalScrollIndicator = false
        sv_breeze.keyboardDismissMode = .onDrag
        sv_breeze.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        return sv_breeze
    }()
    
    /// 滚动内容容器
    private let contentView_Breeze = UIView()
    
    // MARK: - UI：媒体选择区
    
    /// "Media" 区块标签
    private let mediaSectionLabel_Breeze = Release_Breeze.makeSectionLabel_Breeze(text_breeze: "Media")
    
    /// 媒体选择卡片（可点击 UIControl）
    private let mediaPickerCard_Breeze: UIControl = {
        let control_breeze = UIControl()
        control_breeze.backgroundColor = .white
        control_breeze.layer.cornerRadius = 20
        control_breeze.layer.borderWidth = 1.5
        control_breeze.layer.borderColor = ColorConfig_Breeze.border_Breeze.cgColor
        control_breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        control_breeze.layer.shadowOffset = CGSize(width: 0, height: 4)
        control_breeze.layer.shadowRadius = 12
        control_breeze.layer.shadowOpacity = 0.1
        return control_breeze
    }()
    
    /// 媒体预览组件
    private let mediaPreview_Breeze = MediaDisplayView_Breeze()
    
    /// 媒体占位内容堆叠
    private let mediaEmptyStack_Breeze: UIStackView = {
        let stack_breeze = UIStackView()
        stack_breeze.axis = .vertical
        stack_breeze.alignment = .center
        stack_breeze.spacing = 10
        stack_breeze.isUserInteractionEnabled = false
        return stack_breeze
    }()
    
    /// 媒体占位图标
    private let mediaPlaceholderIcon_Breeze: UIImageView = {
        let iv_breeze = UIImageView()
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 44, weight: .light)
        iv_breeze.image = UIImage(systemName: "photo.badge.plus", withConfiguration: config_breeze)
        iv_breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        iv_breeze.contentMode = .scaleAspectFit
        return iv_breeze
    }()
    
    /// 媒体占位主文字
    private let mediaPlaceholderTitle_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Add a photo or video"
        label_breeze.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        return label_breeze
    }()
    
    /// 媒体占位副文字
    private let mediaPlaceholderSub_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Tap to choose from your library"
        label_breeze.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label_breeze.textColor = ColorConfig_Breeze.textPlaceholder_Breeze
        return label_breeze
    }()
    
    // MARK: - UI：分类选择区
    
    /// "Category" 区块标签
    private let categorySectionLabel_Breeze = Release_Breeze.makeSectionLabel_Breeze(text_breeze: "Category")
    
    /// 分类横向滚动视图
    private lazy var categoryScrollView_Breeze: UIScrollView = {
        let sv_breeze = UIScrollView()
        sv_breeze.showsHorizontalScrollIndicator = false
        sv_breeze.backgroundColor = .clear
        return sv_breeze
    }()
    
    /// 分类 Chip 横向堆叠容器
    private let categoryStack_Breeze: UIStackView = {
        let stack_breeze = UIStackView()
        stack_breeze.axis = .horizontal
        stack_breeze.spacing = 10
        stack_breeze.alignment = .center
        return stack_breeze
    }()
    
    /// 分类 Chip 按钮列表
    private var categoryChips_Breeze: [UIButton] = []
    
    // MARK: - UI：标题输入区
    
    /// "Title" 区块标签
    private let titleSectionLabel_Breeze = Release_Breeze.makeSectionLabel_Breeze(text_breeze: "Title")
    
    /// 标题输入卡片容器
    private let titleCard_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = .white
        view_breeze.layer.cornerRadius = 16
        view_breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        view_breeze.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_breeze.layer.shadowRadius = 8
        view_breeze.layer.shadowOpacity = 0.09
        return view_breeze
    }()
    
    /// 标题输入框左侧图标
    private let titleIconView_Breeze: UIImageView = {
        let iv_breeze = UIImageView()
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        iv_breeze.image = UIImage(systemName: "pencil.line", withConfiguration: config_breeze)
        iv_breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        iv_breeze.contentMode = .scaleAspectFit
        return iv_breeze
    }()
    
    /// 标题输入框
    private let titleField_Breeze: UITextField = {
        let field_breeze = UITextField()
        field_breeze.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        field_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        field_breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        field_breeze.borderStyle = .none
        field_breeze.backgroundColor = .clear
        field_breeze.returnKeyType = .next
        let attrs_breeze: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorConfig_Breeze.textPlaceholder_Breeze,
            .font: UIFont.systemFont(ofSize: 15, weight: .regular)
        ]
        field_breeze.attributedPlaceholder = NSAttributedString(
            string: "Give your post a catchy title",
            attributes: attrs_breeze
        )
        return field_breeze
    }()
    
    // MARK: - UI：内容输入区
    
    /// "Story" 区块标签
    private let storySectionLabel_Breeze = Release_Breeze.makeSectionLabel_Breeze(text_breeze: "Story")
    
    /// 内容输入卡片容器
    private let storyCard_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = .white
        view_breeze.layer.cornerRadius = 16
        view_breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        view_breeze.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_breeze.layer.shadowRadius = 8
        view_breeze.layer.shadowOpacity = 0.09
        return view_breeze
    }()
    
    /// 内容输入框
    private let contentTextView_Breeze: UITextView = {
        let tv_breeze = UITextView()
        tv_breeze.font = UIFont.systemFont(ofSize: 14)
        tv_breeze.backgroundColor = .clear
        tv_breeze.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        tv_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        tv_breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        return tv_breeze
    }()
    
    /// 内容输入占位文字
    private let contentPlaceholder_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Share the story behind this moment..."
        label_breeze.font = UIFont.systemFont(ofSize: 14)
        label_breeze.textColor = ColorConfig_Breeze.textPlaceholder_Breeze
        label_breeze.numberOfLines = 0
        return label_breeze
    }()
    
    // MARK: - UI：底部操作区
    
    /// 发布按钮（渐变背景）
    private let publishButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        btn_breeze.setTitle("Publish Post", for: .normal)
        btn_breeze.setTitleColor(.white, for: .normal)
        btn_breeze.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn_breeze.layer.cornerRadius = 28
        btn_breeze.layer.shadowColor = ColorConfig_Breeze.primaryGradientStart_Breeze.cgColor
        btn_breeze.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn_breeze.layer.shadowRadius = 16
        btn_breeze.layer.shadowOpacity = 0.38
        return btn_breeze
    }()
    
    /// 发布按钮渐变图层
    private var publishGradient_Breeze: CAGradientLayer?
    
    /// EULA 协议按钮
    private let eulaButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        let attrs_breeze: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: ColorConfig_Breeze.textPlaceholder_Breeze,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        btn_breeze.setAttributedTitle(
            NSAttributedString(string: "EULA", attributes: attrs_breeze),
            for: .normal
        )
        return btn_breeze
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Breeze()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshHeaderGradient_Breeze()
        refreshPublishButtonGradient_Breeze()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - UI 搭建
    
    /// 主入口：依次搭建头部、滚动区内容
    private func setupUI_Breeze() {
        view.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        setupHeaderView_Breeze()
        setupScrollContent_Breeze()
    }
    
    // MARK: - 头部渐变区
    
    /// 搭建渐变头部（装饰圆 + 标题 + 副标题）
    private func setupHeaderView_Breeze() {
        view.addSubview(headerView_Breeze)
        headerView_Breeze.addSubview(decorLargeCircle_Breeze)
        headerView_Breeze.addSubview(decorSmallCircle_Breeze)
        headerView_Breeze.addSubview(pageTitleLabel_Breeze)
        headerView_Breeze.addSubview(pageSubtitleLabel_Breeze)
        
        headerView_Breeze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        decorLargeCircle_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(150)
            make.right.equalToSuperview().offset(42)
            make.top.equalToSuperview().offset(-30)
        }
        
        decorSmallCircle_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(76)
            make.left.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(14)
        }
        
        pageTitleLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(18)
            make.left.equalToSuperview().offset(22)
        }
        
        pageSubtitleLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(pageTitleLabel_Breeze.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(22)
            make.right.equalTo(decorLargeCircle_Breeze.snp.left).offset(-8)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    /// 刷新头部渐变图层（viewDidLayoutSubviews 后调用）
    private func refreshHeaderGradient_Breeze() {
        headerGradientLayer_Breeze?.removeFromSuperlayer()
        let gradient_breeze = UIColor.createPrimaryGradientLayer_Breeze(frame_Breeze: headerView_Breeze.bounds)
        headerView_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        headerGradientLayer_Breeze = gradient_breeze
    }
    
    // MARK: - 滚动内容区搭建
    
    /// 搭建滚动区域内所有内容（媒体 + 分类 + 标题 + 内容 + 发布按钮）
    private func setupScrollContent_Breeze() {
        view.addSubview(scrollView_Breeze)
        scrollView_Breeze.addSubview(contentView_Breeze)
        
        scrollView_Breeze.snp.makeConstraints { make in
            make.top.equalTo(headerView_Breeze.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        contentView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        setupMediaSection_Breeze()
        setupCategorySection_Breeze()
        setupTitleSection_Breeze()
        setupStorySection_Breeze()
        setupBottomActions_Breeze()
    }
    
    // MARK: - 媒体区
    
    /// 搭建媒体选择区（大卡片 + 占位提示）
    private func setupMediaSection_Breeze() {
        contentView_Breeze.addSubview(mediaSectionLabel_Breeze)
        contentView_Breeze.addSubview(mediaPickerCard_Breeze)
        mediaPickerCard_Breeze.addSubview(mediaPreview_Breeze)
        mediaPickerCard_Breeze.addSubview(mediaEmptyStack_Breeze)
        mediaEmptyStack_Breeze.addArrangedSubview(mediaPlaceholderIcon_Breeze)
        mediaEmptyStack_Breeze.addArrangedSubview(mediaPlaceholderTitle_Breeze)
        mediaEmptyStack_Breeze.addArrangedSubview(mediaPlaceholderSub_Breeze)
        
        mediaSectionLabel_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(22)
        }
        
        mediaPickerCard_Breeze.snp.makeConstraints { make in
            make.top.equalTo(mediaSectionLabel_Breeze.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(210)
        }
        
        mediaPreview_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        
        mediaEmptyStack_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        mediaPlaceholderIcon_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(52)
        }
        
        mediaPreview_Breeze.isHidden = true
        
        mediaPickerCard_Breeze.addAction(
            UIAction { [weak self] _ in self?.handlePickMedia_Breeze() },
            for: .touchUpInside
        )
    }
    
    // MARK: - 分类区
    
    /// 搭建分类 Chips 横向选择区（不含 .all_breeze）
    private func setupCategorySection_Breeze() {
        contentView_Breeze.addSubview(categorySectionLabel_Breeze)
        contentView_Breeze.addSubview(categoryScrollView_Breeze)
        categoryScrollView_Breeze.addSubview(categoryStack_Breeze)
        
        categorySectionLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(mediaPickerCard_Breeze.snp.bottom).offset(22)
            make.left.equalToSuperview().offset(22)
        }
        
        categoryScrollView_Breeze.snp.makeConstraints { make in
            make.top.equalTo(categorySectionLabel_Breeze.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        categoryStack_Breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }
        
        // 生成可选分类 Chips（排除 .all_breeze）
        let selectableCategories_breeze = PostCategory_Breeze.allCases.filter { $0 != .all_breeze }
        for (index_breeze, category_breeze) in selectableCategories_breeze.enumerated() {
            let chip_breeze = makeCategoryChip_Breeze(category_breeze: category_breeze, tag_breeze: index_breeze)
            categoryStack_Breeze.addArrangedSubview(chip_breeze)
            categoryChips_Breeze.append(chip_breeze)
        }
        
        // 默认选中第一个（Camping）
        applyCategoryStyle_Breeze(activeIndex_breeze: 0)
    }
    
    /// 构建单个分类 Chip 按钮
    /// - Parameters:
    ///   - category_breeze: 对应分类
    ///   - tag_breeze: 按钮 tag（对应 selectableCategories 下标）
    /// - Returns: 配置完整的 UIButton
    private func makeCategoryChip_Breeze(category_breeze: PostCategory_Breeze, tag_breeze: Int) -> UIButton {
        let btn_breeze = UIButton(type: .system)
        btn_breeze.tag = tag_breeze
        btn_breeze.layer.cornerRadius = 18
        btn_breeze.layer.borderWidth = 1.5
        btn_breeze.clipsToBounds = true
        
        var config_breeze = UIButton.Configuration.plain()
        config_breeze.imagePadding = 5
        config_breeze.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14)
        
        let iconConf_breeze = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        config_breeze.image = UIImage(systemName: category_breeze.iconName_Breeze, withConfiguration: iconConf_breeze)
        config_breeze.title = category_breeze.rawValue
        config_breeze.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
            var m_breeze = attr
            m_breeze.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            return m_breeze
        }
        btn_breeze.configuration = config_breeze
        btn_breeze.snp.makeConstraints { make in
            make.height.equalTo(36)
        }
        btn_breeze.addTarget(self, action: #selector(onCategoryTap_Breeze(_:)), for: .touchUpInside)
        return btn_breeze
    }
    
    /// 刷新分类 Chip 的选中 / 非选中样式
    /// - Parameter activeIndex_breeze: 选中的下标
    private func applyCategoryStyle_Breeze(activeIndex_breeze: Int) {
        for (index_breeze, chip_breeze) in categoryChips_Breeze.enumerated() {
            if index_breeze == activeIndex_breeze {
                chip_breeze.backgroundColor = ColorConfig_Breeze.primaryGradientStart_Breeze
                chip_breeze.tintColor = .white
                chip_breeze.layer.borderColor = UIColor.clear.cgColor
                var conf_breeze = chip_breeze.configuration
                conf_breeze?.baseForegroundColor = .white
                chip_breeze.configuration = conf_breeze
            } else {
                chip_breeze.backgroundColor = .white
                chip_breeze.tintColor = ColorConfig_Breeze.textSecondary_Breeze
                chip_breeze.layer.borderColor = ColorConfig_Breeze.divider_Breeze.cgColor
                var conf_breeze = chip_breeze.configuration
                conf_breeze?.baseForegroundColor = ColorConfig_Breeze.textSecondary_Breeze
                chip_breeze.configuration = conf_breeze
            }
        }
    }
    
    // MARK: - 标题区
    
    /// 搭建标题输入卡片（图标 + TextField）
    private func setupTitleSection_Breeze() {
        contentView_Breeze.addSubview(titleSectionLabel_Breeze)
        contentView_Breeze.addSubview(titleCard_Breeze)
        titleCard_Breeze.addSubview(titleIconView_Breeze)
        titleCard_Breeze.addSubview(titleField_Breeze)
        
        titleSectionLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(categoryScrollView_Breeze.snp.bottom).offset(22)
            make.left.equalToSuperview().offset(22)
        }
        
        titleCard_Breeze.snp.makeConstraints { make in
            make.top.equalTo(titleSectionLabel_Breeze.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        
        titleIconView_Breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        
        titleField_Breeze.snp.makeConstraints { make in
            make.left.equalTo(titleIconView_Breeze.snp.right).offset(10)
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
        
        titleField_Breeze.delegate = self
    }
    
    // MARK: - 内容区
    
    /// 搭建故事内容输入卡片（TextVew + 占位文字）
    private func setupStorySection_Breeze() {
        contentView_Breeze.addSubview(storySectionLabel_Breeze)
        contentView_Breeze.addSubview(storyCard_Breeze)
        storyCard_Breeze.addSubview(contentTextView_Breeze)
        contentTextView_Breeze.addSubview(contentPlaceholder_Breeze)
        
        storySectionLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(titleCard_Breeze.snp.bottom).offset(22)
            make.left.equalToSuperview().offset(22)
        }
        
        storyCard_Breeze.snp.makeConstraints { make in
            make.top.equalTo(storySectionLabel_Breeze.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(150)
        }
        
        contentTextView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentPlaceholder_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-12)
        }
        
        contentTextView_Breeze.delegate = self
    }
    
    // MARK: - 底部操作区
    
    /// 搭建渐变发布按钮和 EULA 链接
    private func setupBottomActions_Breeze() {
        contentView_Breeze.addSubview(publishButton_Breeze)
        contentView_Breeze.addSubview(eulaButton_Breeze)
        
        publishButton_Breeze.snp.makeConstraints { make in
            make.top.equalTo(storyCard_Breeze.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        
        eulaButton_Breeze.snp.makeConstraints { make in
            make.top.equalTo(publishButton_Breeze.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
        }
        
        publishButton_Breeze.addTarget(self, action: #selector(handlePublish_Breeze), for: .touchUpInside)
        eulaButton_Breeze.addTarget(self, action: #selector(handleEula_Breeze), for: .touchUpInside)
    }
    
    /// 刷新发布按钮渐变图层
    private func refreshPublishButtonGradient_Breeze() {
        guard !publishButton_Breeze.bounds.isEmpty else { return }
        publishGradient_Breeze?.removeFromSuperlayer()
        let gradient_breeze = UIColor.createPrimaryGradientLayer_Breeze(frame_Breeze: publishButton_Breeze.bounds)
        gradient_breeze.cornerRadius = publishButton_Breeze.layer.cornerRadius
        publishButton_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        publishGradient_Breeze = gradient_breeze
    }
    
    // MARK: - 事件处理
    
    /// 分类 Chip 点击
    @objc private func onCategoryTap_Breeze(_ sender: UIButton) {
        let index_breeze = sender.tag
        let selectables_breeze = PostCategory_Breeze.allCases.filter { $0 != .all_breeze }
        guard index_breeze < selectables_breeze.count else { return }
        
        selectedCategory_Breeze = selectables_breeze[index_breeze]
        applyCategoryStyle_Breeze(activeIndex_breeze: index_breeze)
        
        let feedback_breeze = UIImpactFeedbackGenerator(style: .light)
        feedback_breeze.impactOccurred()
    }
    
    /// 选择媒体
    private func handlePickMedia_Breeze() {
        MediaPickerHelper_Breeze.pickMedia_Breeze(from: self) { [weak self] result_breeze in
            guard let self else { return }
            switch result_breeze {
            case .photo_Breeze(let image_breeze):
                if let savedName_breeze = MediaPickerHelper_Breeze.saveImageToDocuments_Breeze(image_breeze: image_breeze) {
                    self.mediaPath_Breeze = savedName_breeze
                    self.isVideo_Breeze = false
                    self.showMediaPreview_Breeze(image_breeze: image_breeze)
                }
            case .video_Breeze(let url_breeze):
                if let savedName_breeze = MediaPickerHelper_Breeze.saveVideoToDocuments_Breeze(sourceURL_breeze: url_breeze) {
                    self.mediaPath_Breeze = savedName_breeze
                    self.isVideo_Breeze = true
                    self.showVideoPreview_Breeze(path_breeze: savedName_breeze)
                }
            case .cancelled_Breeze:
                break
            }
        }
    }
    
    /// 展示图片预览
    private func showMediaPreview_Breeze(image_breeze: UIImage) {
        mediaPreview_Breeze.isHidden = false
        mediaEmptyStack_Breeze.isHidden = true
        mediaPickerCard_Breeze.layer.borderColor = UIColor.clear.cgColor
        mediaPreview_Breeze.configureWithImage_Breeze(image_Breeze: image_breeze)
    }
    
    /// 展示视频预览
    private func showVideoPreview_Breeze(path_breeze: String) {
        mediaPreview_Breeze.isHidden = false
        mediaEmptyStack_Breeze.isHidden = true
        mediaPickerCard_Breeze.layer.borderColor = UIColor.clear.cgColor
        mediaPreview_Breeze.configure_Breeze(mediaPath_Breeze: path_breeze, isVideo_Breeze: true)
    }
    
    /// 发布帖子
    @objc private func handlePublish_Breeze() {
        // 1. 校验登录
        guard UserViewModel_Breeze.shared_Breeze.isLoggedIn_Breeze else {
            Utils_Breeze.showInfo_Breeze(message_Breeze: "Please sign in to publish")
            Navigation_Breeze.toLogin_Breeze(style_breeze: .present_breeze)
            return
        }
        
        let title_breeze = titleField_Breeze.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let content_breeze = contentTextView_Breeze.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // 2. 必填校验
        guard !title_breeze.isEmpty else {
            titleCard_Breeze.animateShake_Breeze()
            Utils_Breeze.showWarning_Breeze(message_Breeze: "Please add a title")
            return
        }
        guard !content_breeze.isEmpty else {
            storyCard_Breeze.animateShake_Breeze()
            Utils_Breeze.showWarning_Breeze(message_Breeze: "Please add some content")
            return
        }
        guard let media_breeze = mediaPath_Breeze, !media_breeze.isEmpty else {
            mediaPickerCard_Breeze.animateShake_Breeze()
            Utils_Breeze.showWarning_Breeze(message_Breeze: "Please select a photo or video")
            return
        }
        
        // 3. 发布（携带分类信息）
        TitleViewModel_Breeze.shared_Breeze.releasePost_Breeze(
            title_breeze: title_breeze,
            content_breeze: content_breeze,
            media_breeze: media_breeze,
            category_breeze: selectedCategory_Breeze
        )
        
        // 4. 清空表单并切换至发现页（index 1）
        clearForm_Breeze()
        view.endEditing(true)
        (tabBarController as? TabBar_Breeze)?.switchToTab_Breeze(index_breeze: 1)
    }
    
    /// 清空发布表单至初始状态
    private func clearForm_Breeze() {
        titleField_Breeze.text = ""
        contentTextView_Breeze.text = ""
        contentPlaceholder_Breeze.isHidden = false
        mediaPath_Breeze = nil
        isVideo_Breeze = false
        mediaPreview_Breeze.isHidden = true
        mediaEmptyStack_Breeze.isHidden = false
        mediaPickerCard_Breeze.layer.borderColor = ColorConfig_Breeze.border_Breeze.cgColor
        selectedCategory_Breeze = .camping_breeze
        applyCategoryStyle_Breeze(activeIndex_breeze: 0)
    }
    
    /// 展示 EULA 协议
    @objc private func handleEula_Breeze() {
        ProtocolHelper_Breeze.showProtocol_Breeze(
            type_Breeze: .eula_Breeze,
            content_Breeze: ProtocolConfig_Breeze.eulaContent_Breeze,
            from: self
        )
    }
}

// MARK: - 工厂方法

extension Release_Breeze {
    
    /// 创建区块标题 UILabel
    /// - Parameter text_breeze: 标题文字（英文）
    /// - Returns: 配置好的 UILabel
    private static func makeSectionLabel_Breeze(text_breeze: String) -> UILabel {
        let label_breeze = UILabel()
        label_breeze.text = text_breeze
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label_breeze.textColor = ColorConfig_Breeze.textSecondary_Breeze
        label_breeze.textAlignment = .left
        return label_breeze
    }
}

// MARK: - UITextFieldDelegate

extension Release_Breeze: UITextFieldDelegate {
    
    /// 点击 Return 跳转至内容输入框
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentTextView_Breeze.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension Release_Breeze: UITextViewDelegate {
    
    /// 内容变化时同步占位文字可见性
    func textViewDidChange(_ textView: UITextView) {
        contentPlaceholder_Breeze.isHidden = !textView.text.isEmpty
    }
}
