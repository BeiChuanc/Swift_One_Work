import Foundation
import UIKit
import SnapKit

// MARK: 发布

/// 发布页面
/// 功能：发布彩绘作品，包括标题、内容、媒体、风格、难度
/// 设计：现代化卡片式布局，渐变背景，动画交互
class Release_Glasspaint: UIViewController {
    
    // MARK: - UI元素
    
    private let scrollView_Glasspaint = UIScrollView()
    private let contentView_Glasspaint = UIView()
    
    // 顶部装饰元素
    private let headerGradientView_Glasspaint = UIView()
    private let headerGradientLayer_Glasspaint = CAGradientLayer()
    private let headerIconView_Glasspaint = UIImageView()
    private let headerTitleLabel_Glasspaint = UILabel()
    private let headerSubtitleLabel_Glasspaint = UILabel()
    
    // 媒体选择区
    private let mediaContainer_Glasspaint = UIView()
    private let mediaPlaceholderView_Glasspaint = UIView()
    private let mediaIconView_Glasspaint = UIImageView()
    private let mediaTitleLabel_Glasspaint = UILabel()
    private let mediaSubtitleLabel_Glasspaint = UILabel()
    private let mediaImageView_Glasspaint = UIImageView()
    private let mediaRemoveButton_Glasspaint = UIButton(type: .system)
    private let mediaTypeLabel_Glasspaint = UILabel()
    
    // 标题输入区
    private let titleContainer_Glasspaint = UIView()
    private let titleIconView_Glasspaint = UIImageView()
    private let titleTextField_Glasspaint = UITextField()
    private let titleCountLabel_Glasspaint = UILabel()
    
    // 内容输入区
    private let contentContainer_Glasspaint = UIView()
    private let contentIconView_Glasspaint = UIImageView()
    private let contentTextView_Glasspaint = UITextView()
    private let contentPlaceholderLabel_Glasspaint = UILabel()
    private let contentCountLabel_Glasspaint = UILabel()
    
    // 风格选择区
    private let styleContainer_Glasspaint = UIView()
    private let styleHeaderView_Glasspaint = UIView()
    private let styleIconView_Glasspaint = UIImageView()
    private let styleTitleLabel_Glasspaint = UILabel()
    private let styleCollectionView_Glasspaint: UICollectionView
    private let customStyleButton_Glasspaint = UIButton(type: .system)
    
    // 难度选择区
    private let levelContainer_Glasspaint = UIView()
    private let levelIconView_Glasspaint = UIImageView()
    private let levelTitleLabel_Glasspaint = UILabel()
    private let levelSegmentedControl_Glasspaint = UISegmentedControl(items: ["Beginner", "Intermediate", "Advanced"])
    
    // 发布按钮
    private let publishButton_Glasspaint = UIButton(type: .system)
    private let publishGradientLayer_Glasspaint = CAGradientLayer()
    
    // EULA按钮
    private let eulaButton_Glasspaint = UIButton(type: .system)
    
    // MARK: - 数据属性
    
    private var selectedMedia_Glasspaint: PickerMediaResult_Glasspaint?
    private var selectedStyle_Glasspaint: PaintingStyle_Glasspaint = .modern_glasspaint
    private var selectedLevel_Glasspaint: PaintingLevel_Glasspaint = .beginner_glasspaint
    private var customStyleText_Glasspaint: String?
    
    private let styles_Glasspaint: [PaintingStyle_Glasspaint] = [
        .minimalist_glasspaint,
        .retro_glasspaint,
        .cute_glasspaint,
        .modern_glasspaint,
        .artistic_glasspaint
    ]
    
    /// 媒体结果封装
    enum PickerMediaResult_Glasspaint {
        case image_Glasspaint(UIImage)
        case video_Glasspaint(URL)
    }
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Glasspaint()
        setupActions_Glasspaint()
        
        // 监听键盘通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow_Glasspaint), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide_Glasspaint), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer_Glasspaint.frame = headerGradientView_Glasspaint.bounds
        publishGradientLayer_Glasspaint.frame = publishButton_Glasspaint.bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 初始化
    
    init() {
        // 创建风格选择CollectionView布局
        let layout_glasspaint = UICollectionViewFlowLayout()
        layout_glasspaint.scrollDirection = .horizontal
        layout_glasspaint.minimumInteritemSpacing = 12
        layout_glasspaint.minimumLineSpacing = 12
        layout_glasspaint.itemSize = CGSize(width: 100, height: 90)
        layout_glasspaint.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        styleCollectionView_Glasspaint = UICollectionView(frame: .zero, collectionViewLayout: layout_glasspaint)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        view.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        title = "Create Post"
        
        // 配置导航栏
        navigationController?.navigationBar.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        
        // 滚动视图
        view.addSubview(scrollView_Glasspaint)
        scrollView_Glasspaint.showsVerticalScrollIndicator = false
        scrollView_Glasspaint.keyboardDismissMode = .interactive
        
        scrollView_Glasspaint.addSubview(contentView_Glasspaint)
        
        // 顶部装饰区
        setupHeaderSection_Glasspaint()
        
        // 媒体选择区
        setupMediaSection_Glasspaint()
        
        // 标题输入区
        setupTitleSection_Glasspaint()
        
        // 内容输入区
        setupContentSection_Glasspaint()
        
        // 风格选择区
        setupStyleSection_Glasspaint()
        
        // 难度选择区
        setupLevelSection_Glasspaint()
        
        // 发布按钮
        setupPublishButton_Glasspaint()
        
        // EULA按钮
        setupEULAButton_Glasspaint()
        
        // 设置约束
        setupConstraints_Glasspaint()
    }
    
    /// 设置顶部装饰区
    private func setupHeaderSection_Glasspaint() {
        contentView_Glasspaint.addSubview(headerGradientView_Glasspaint)
        headerGradientView_Glasspaint.layer.cornerRadius = 20
        headerGradientView_Glasspaint.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerGradientView_Glasspaint.layer.masksToBounds = true
        
        // 渐变背景
        headerGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor,
            ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint.cgColor
        ]
        headerGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        headerGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        headerGradientLayer_Glasspaint.cornerRadius = 20
        headerGradientView_Glasspaint.layer.insertSublayer(headerGradientLayer_Glasspaint, at: 0)
        
        // 装饰图标
        headerGradientView_Glasspaint.addSubview(headerIconView_Glasspaint)
        let iconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        headerIconView_Glasspaint.image = UIImage(systemName: "paintbrush.pointed.fill", withConfiguration: iconConfig_glasspaint)
        headerIconView_Glasspaint.tintColor = .white
        headerIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 标题
        headerGradientView_Glasspaint.addSubview(headerTitleLabel_Glasspaint)
        headerTitleLabel_Glasspaint.text = "Share Your Masterpiece"
        headerTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 24, weight: .black)
        headerTitleLabel_Glasspaint.textColor = .white
        headerTitleLabel_Glasspaint.textAlignment = .center
        
        // 副标题
        headerGradientView_Glasspaint.addSubview(headerSubtitleLabel_Glasspaint)
        headerSubtitleLabel_Glasspaint.text = "Let the world see your creativity"
        headerSubtitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        headerSubtitleLabel_Glasspaint.textColor = .white.withAlphaComponent(0.9)
        headerSubtitleLabel_Glasspaint.textAlignment = .center
    }
    
    /// 设置媒体选择区
    private func setupMediaSection_Glasspaint() {
        contentView_Glasspaint.addSubview(mediaContainer_Glasspaint)
        mediaContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        mediaContainer_Glasspaint.layer.cornerRadius = 20
        mediaContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        mediaContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        mediaContainer_Glasspaint.layer.shadowRadius = 12
        mediaContainer_Glasspaint.layer.shadowOpacity = 0.1
        
        // 占位视图
        mediaContainer_Glasspaint.addSubview(mediaPlaceholderView_Glasspaint)
        
        // 媒体图标
        mediaPlaceholderView_Glasspaint.addSubview(mediaIconView_Glasspaint)
        let mediaIconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 50, weight: .light)
        mediaIconView_Glasspaint.image = UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: mediaIconConfig_glasspaint)
        mediaIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.5)
        mediaIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 标题
        mediaPlaceholderView_Glasspaint.addSubview(mediaTitleLabel_Glasspaint)
        mediaTitleLabel_Glasspaint.text = "Tap to select media"
        mediaTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        mediaTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        mediaTitleLabel_Glasspaint.textAlignment = .center
        
        // 副标题
        mediaPlaceholderView_Glasspaint.addSubview(mediaSubtitleLabel_Glasspaint)
        mediaSubtitleLabel_Glasspaint.text = "Photo or Video"
        mediaSubtitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        mediaSubtitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        mediaSubtitleLabel_Glasspaint.textAlignment = .center
        
        // 预览图片视图
        mediaContainer_Glasspaint.addSubview(mediaImageView_Glasspaint)
        mediaImageView_Glasspaint.contentMode = .scaleAspectFill
        mediaImageView_Glasspaint.layer.cornerRadius = 16
        mediaImageView_Glasspaint.layer.masksToBounds = true
        mediaImageView_Glasspaint.isHidden = true
        
        // 移除按钮
        mediaContainer_Glasspaint.addSubview(mediaRemoveButton_Glasspaint)
        let removeConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        mediaRemoveButton_Glasspaint.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: removeConfig_glasspaint), for: .normal)
        mediaRemoveButton_Glasspaint.tintColor = .white
        mediaRemoveButton_Glasspaint.backgroundColor = UIColor.systemRed
        mediaRemoveButton_Glasspaint.layer.cornerRadius = 16
        mediaRemoveButton_Glasspaint.isHidden = true
        
        // 媒体类型标签
        mediaContainer_Glasspaint.addSubview(mediaTypeLabel_Glasspaint)
        mediaTypeLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        mediaTypeLabel_Glasspaint.textColor = .white
        mediaTypeLabel_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        mediaTypeLabel_Glasspaint.textAlignment = .center
        mediaTypeLabel_Glasspaint.layer.cornerRadius = 10
        mediaTypeLabel_Glasspaint.layer.masksToBounds = true
        mediaTypeLabel_Glasspaint.isHidden = true
        
        // 添加点击手势
        let tapGesture_glasspaint = UITapGestureRecognizer(target: self, action: #selector(handleMediaTap_Glasspaint))
        mediaContainer_Glasspaint.addGestureRecognizer(tapGesture_glasspaint)
        mediaContainer_Glasspaint.isUserInteractionEnabled = true
    }
    
    /// 设置标题输入区
    private func setupTitleSection_Glasspaint() {
        contentView_Glasspaint.addSubview(titleContainer_Glasspaint)
        titleContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        titleContainer_Glasspaint.layer.cornerRadius = 18
        titleContainer_Glasspaint.layer.borderWidth = 2
        titleContainer_Glasspaint.layer.borderColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.1).cgColor
        
        // 图标
        titleContainer_Glasspaint.addSubview(titleIconView_Glasspaint)
        let titleIconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        titleIconView_Glasspaint.image = UIImage(systemName: "textformat.size", withConfiguration: titleIconConfig_glasspaint)
        titleIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        titleIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 输入框
        titleContainer_Glasspaint.addSubview(titleTextField_Glasspaint)
        titleTextField_Glasspaint.placeholder = "Give your artwork a title"
        titleTextField_Glasspaint.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        titleTextField_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        titleTextField_Glasspaint.delegate = self
        
        // 字数统计
        titleContainer_Glasspaint.addSubview(titleCountLabel_Glasspaint)
        titleCountLabel_Glasspaint.text = "0/50"
        titleCountLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        titleCountLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
    }
    
    /// 设置内容输入区
    private func setupContentSection_Glasspaint() {
        contentView_Glasspaint.addSubview(contentContainer_Glasspaint)
        contentContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        contentContainer_Glasspaint.layer.cornerRadius = 18
        contentContainer_Glasspaint.layer.borderWidth = 2
        contentContainer_Glasspaint.layer.borderColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.1).cgColor
        
        // 图标
        contentContainer_Glasspaint.addSubview(contentIconView_Glasspaint)
        let contentIconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        contentIconView_Glasspaint.image = UIImage(systemName: "text.alignleft", withConfiguration: contentIconConfig_glasspaint)
        contentIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        contentIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 文本视图
        contentContainer_Glasspaint.addSubview(contentTextView_Glasspaint)
        contentTextView_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        contentTextView_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        contentTextView_Glasspaint.backgroundColor = .clear
        contentTextView_Glasspaint.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        contentTextView_Glasspaint.delegate = self
        
        // 占位符
        contentContainer_Glasspaint.addSubview(contentPlaceholderLabel_Glasspaint)
        contentPlaceholderLabel_Glasspaint.text = "Describe your creative process, inspiration, or techniques..."
        contentPlaceholderLabel_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        contentPlaceholderLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint.withAlphaComponent(0.6)
        contentPlaceholderLabel_Glasspaint.numberOfLines = 0
        
        // 字数统计
        contentContainer_Glasspaint.addSubview(contentCountLabel_Glasspaint)
        contentCountLabel_Glasspaint.text = "0/500"
        contentCountLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        contentCountLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
    }
    
    /// 设置风格选择区
    private func setupStyleSection_Glasspaint() {
        contentView_Glasspaint.addSubview(styleContainer_Glasspaint)
        styleContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        styleContainer_Glasspaint.layer.cornerRadius = 18
        styleContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        styleContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        styleContainer_Glasspaint.layer.shadowRadius = 8
        styleContainer_Glasspaint.layer.shadowOpacity = 0.08
        
        // 头部
        styleContainer_Glasspaint.addSubview(styleHeaderView_Glasspaint)
        
        // 图标
        styleHeaderView_Glasspaint.addSubview(styleIconView_Glasspaint)
        let styleIconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        styleIconView_Glasspaint.image = UIImage(systemName: "paintpalette.fill", withConfiguration: styleIconConfig_glasspaint)
        styleIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        styleIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 标题
        styleHeaderView_Glasspaint.addSubview(styleTitleLabel_Glasspaint)
        styleTitleLabel_Glasspaint.text = "Painting Style"
        styleTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        styleTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // CollectionView
        styleContainer_Glasspaint.addSubview(styleCollectionView_Glasspaint)
        styleCollectionView_Glasspaint.backgroundColor = .clear
        styleCollectionView_Glasspaint.showsHorizontalScrollIndicator = false
        styleCollectionView_Glasspaint.delegate = self
        styleCollectionView_Glasspaint.dataSource = self
        styleCollectionView_Glasspaint.register(StyleCell_Glasspaint.self, forCellWithReuseIdentifier: "StyleCell")
        
        // 自定义风格按钮
        styleContainer_Glasspaint.addSubview(customStyleButton_Glasspaint)
        customStyleButton_Glasspaint.setTitle("✨ Custom Style", for: .normal)
        customStyleButton_Glasspaint.setTitleColor(ColorConfig_Glasspaint.primaryGradientStart_Glasspaint, for: .normal)
        customStyleButton_Glasspaint.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        customStyleButton_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.1)
        customStyleButton_Glasspaint.layer.cornerRadius = 12
        customStyleButton_Glasspaint.layer.borderWidth = 1.5
        customStyleButton_Glasspaint.layer.borderColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.3).cgColor
    }
    
    /// 设置难度选择区
    private func setupLevelSection_Glasspaint() {
        contentView_Glasspaint.addSubview(levelContainer_Glasspaint)
        levelContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        levelContainer_Glasspaint.layer.cornerRadius = 18
        levelContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        levelContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        levelContainer_Glasspaint.layer.shadowRadius = 8
        levelContainer_Glasspaint.layer.shadowOpacity = 0.08
        
        // 图标
        levelContainer_Glasspaint.addSubview(levelIconView_Glasspaint)
        let levelIconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        levelIconView_Glasspaint.image = UIImage(systemName: "chart.bar.fill", withConfiguration: levelIconConfig_glasspaint)
        levelIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        levelIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 标题
        levelContainer_Glasspaint.addSubview(levelTitleLabel_Glasspaint)
        levelTitleLabel_Glasspaint.text = "Difficulty Level"
        levelTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        levelTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 分段控制器
        levelContainer_Glasspaint.addSubview(levelSegmentedControl_Glasspaint)
        levelSegmentedControl_Glasspaint.selectedSegmentIndex = 0
        levelSegmentedControl_Glasspaint.selectedSegmentTintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        levelSegmentedControl_Glasspaint.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)
        levelSegmentedControl_Glasspaint.setTitleTextAttributes([
            .foregroundColor: ColorConfig_Glasspaint.textSecondary_Glasspaint,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
    }
    
    /// 设置发布按钮
    private func setupPublishButton_Glasspaint() {
        contentView_Glasspaint.addSubview(publishButton_Glasspaint)
        publishButton_Glasspaint.setTitle("Publish Now", for: .normal)
        publishButton_Glasspaint.setTitleColor(.white, for: .normal)
        publishButton_Glasspaint.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        publishButton_Glasspaint.layer.cornerRadius = 25
        publishButton_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        publishButton_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        publishButton_Glasspaint.layer.shadowRadius = 12
        publishButton_Glasspaint.layer.shadowOpacity = 0.4
        
        // 渐变背景
        publishGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor,
            ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint.cgColor
        ]
        publishGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0.5)
        publishGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 0.5)
        publishGradientLayer_Glasspaint.cornerRadius = 25
        publishButton_Glasspaint.layer.insertSublayer(publishGradientLayer_Glasspaint, at: 0)
        
        // 添加图标
        let publishIconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        let publishIcon_glasspaint = UIImage(systemName: "paperplane.fill", withConfiguration: publishIconConfig_glasspaint)
        publishButton_Glasspaint.setImage(publishIcon_glasspaint, for: .normal)
        publishButton_Glasspaint.tintColor = .white
        publishButton_Glasspaint.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
    }
    
    /// 设置EULA按钮
    private func setupEULAButton_Glasspaint() {
        contentView_Glasspaint.addSubview(eulaButton_Glasspaint)
        
        // 创建带下划线的文本
        let attributes_glasspaint: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .medium),
            .foregroundColor: ColorConfig_Glasspaint.textSecondary_Glasspaint,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: ColorConfig_Glasspaint.textSecondary_Glasspaint
        ]
        let attributedTitle_glasspaint = NSAttributedString(string: "EULA", attributes: attributes_glasspaint)
        eulaButton_Glasspaint.setAttributedTitle(attributedTitle_glasspaint, for: .normal)
    }
    
    /// 设置约束
    private func setupConstraints_Glasspaint() {
        scrollView_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-120)
        }
        
        contentView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Glasspaint)
        }
        
        // 顶部装饰区
        headerGradientView_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-60)
            make.left.right.equalToSuperview()
            make.height.equalTo(180)
        }
        
        headerIconView_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(50)
            make.width.height.equalTo(50)
        }
        
        headerTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(headerIconView_Glasspaint.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        
        headerSubtitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel_Glasspaint.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // 媒体选择区
        mediaContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(headerGradientView_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(240)
        }
        
        mediaPlaceholderView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        mediaIconView_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.width.height.equalTo(60)
        }
        
        mediaTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(mediaIconView_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
        }
        
        mediaSubtitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(mediaTitleLabel_Glasspaint.snp.bottom).offset(6)
            make.left.right.equalToSuperview()
        }
        
        mediaImageView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        mediaRemoveButton_Glasspaint.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(20)
            make.width.height.equalTo(32)
        }
        
        mediaTypeLabel_Glasspaint.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(20)
            make.height.equalTo(24)
            make.width.equalTo(60)
        }
        
        // 标题输入区
        titleContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(mediaContainer_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
        
        titleIconView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleTextField_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(titleIconView_Glasspaint.snp.right).offset(12)
            make.right.equalTo(titleCountLabel_Glasspaint.snp.left).offset(-12)
            make.centerY.equalToSuperview()
        }
        
        titleCountLabel_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        // 内容输入区
        contentContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(titleContainer_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(160)
        }
        
        contentIconView_Glasspaint.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(16)
            make.width.height.equalTo(24)
        }
        
        contentTextView_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(contentIconView_Glasspaint.snp.right).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalTo(contentCountLabel_Glasspaint.snp.top).offset(-8)
        }
        
        contentPlaceholderLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(contentTextView_Glasspaint).offset(16)
            make.right.equalTo(contentTextView_Glasspaint).offset(-16)
            make.top.equalTo(contentTextView_Glasspaint).offset(16)
        }
        
        contentCountLabel_Glasspaint.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().inset(16)
        }
        
        // 风格选择区
        styleContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(contentContainer_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        styleHeaderView_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(60)
        }
        
        styleIconView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        styleTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(styleIconView_Glasspaint.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }
        
        styleCollectionView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(styleHeaderView_Glasspaint.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(90)
        }
        
        customStyleButton_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(styleCollectionView_Glasspaint.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        // 难度选择区
        levelContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(styleContainer_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        levelIconView_Glasspaint.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(20)
            make.width.height.equalTo(24)
        }
        
        levelTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(levelIconView_Glasspaint.snp.right).offset(12)
            make.centerY.equalTo(levelIconView_Glasspaint)
        }
        
        levelSegmentedControl_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(levelIconView_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(36)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // 发布按钮
        publishButton_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(levelContainer_Glasspaint.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        
        // EULA按钮
        eulaButton_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(publishButton_Glasspaint.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.bottom.equalToSuperview().offset(-32)
        }
    }
    
    // MARK: - 事件处理
    
    /// 设置事件
    private func setupActions_Glasspaint() {
        mediaRemoveButton_Glasspaint.addTarget(self, action: #selector(handleRemoveMedia_Glasspaint), for: .touchUpInside)
        customStyleButton_Glasspaint.addTarget(self, action: #selector(handleCustomStyle_Glasspaint), for: .touchUpInside)
        levelSegmentedControl_Glasspaint.addTarget(self, action: #selector(handleLevelChange_Glasspaint), for: .valueChanged)
        publishButton_Glasspaint.addTarget(self, action: #selector(handlePublish_Glasspaint), for: .touchUpInside)
        eulaButton_Glasspaint.addTarget(self, action: #selector(handleEULATap_Glasspaint), for: .touchUpInside)
    }
    
    /// 处理媒体选择点击
    @objc private func handleMediaTap_Glasspaint() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.mediaContainer_Glasspaint.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.mediaContainer_Glasspaint.transform = .identity
            }
        }
        
        // 显示媒体选择器
        MediaPickerHelper_Glasspaint.shared_Glasspaint.showPicker_Glasspaint(
            from: self,
            mediaType_Glasspaint: .photoAndVideo_Glasspaint,
            selectionLimit_Glasspaint: 1
        ) { [weak self] result_glasspaint in
            guard let self = self else { return }
            
            switch result_glasspaint {
            case .photo_Glasspaint(let image_glasspaint):
                self.selectedMedia_Glasspaint = .image_Glasspaint(image_glasspaint)
                self.updateMediaPreview_Glasspaint(image: image_glasspaint, isVideo: false)
                
            case .video_Glasspaint(let url_glasspaint):
                self.selectedMedia_Glasspaint = .video_Glasspaint(url_glasspaint)
                self.updateMediaPreview_Glasspaint(videoURL: url_glasspaint)
                
            case .cancelled_Glasspaint:
                break
            }
        }
    }
    
    /// 更新媒体预览
    /// 参数：
    /// - image: 图片
    /// - isVideo: 是否为视频
    private func updateMediaPreview_Glasspaint(image: UIImage? = nil, videoURL: URL? = nil, isVideo: Bool = false) {
        mediaPlaceholderView_Glasspaint.isHidden = true
        mediaImageView_Glasspaint.isHidden = false
        mediaRemoveButton_Glasspaint.isHidden = false
        mediaTypeLabel_Glasspaint.isHidden = false
        
        if let image_glasspaint = image {
            mediaImageView_Glasspaint.image = image_glasspaint
            mediaTypeLabel_Glasspaint.text = isVideo ? "VIDEO" : "PHOTO"
        } else if let videoURL_glasspaint = videoURL {
            // 从视频URL获取缩略图
            let asset_glasspaint = AVAsset(url: videoURL_glasspaint)
            let imageGenerator_glasspaint = AVAssetImageGenerator(asset: asset_glasspaint)
            imageGenerator_glasspaint.appliesPreferredTrackTransform = true
            
            do {
                let cgImage_glasspaint = try imageGenerator_glasspaint.copyCGImage(at: .zero, actualTime: nil)
                let thumbnail_glasspaint = UIImage(cgImage: cgImage_glasspaint)
                mediaImageView_Glasspaint.image = thumbnail_glasspaint
                mediaTypeLabel_Glasspaint.text = "VIDEO"
            } catch {
                mediaImageView_Glasspaint.image = UIImage(systemName: "video.fill")
                mediaTypeLabel_Glasspaint.text = "VIDEO"
            }
        }
    }
    
    /// 处理移除媒体
    @objc private func handleRemoveMedia_Glasspaint() {
        selectedMedia_Glasspaint = nil
        mediaPlaceholderView_Glasspaint.isHidden = false
        mediaImageView_Glasspaint.isHidden = true
        mediaRemoveButton_Glasspaint.isHidden = true
        mediaTypeLabel_Glasspaint.isHidden = true
        mediaImageView_Glasspaint.image = nil
    }
    
    /// 处理自定义风格
    @objc private func handleCustomStyle_Glasspaint() {
        let alert_glasspaint = UIAlertController(
            title: "Custom Style",
            message: "Enter your unique painting style",
            preferredStyle: .alert
        )
        
        alert_glasspaint.addTextField { textField_glasspaint in
            textField_glasspaint.placeholder = "e.g., Abstract Watercolor"
            textField_glasspaint.text = self.customStyleText_Glasspaint
        }
        
        alert_glasspaint.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_glasspaint.addAction(UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            if let text_glasspaint = alert_glasspaint.textFields?.first?.text, !text_glasspaint.isEmpty {
                self?.customStyleText_Glasspaint = text_glasspaint
                Utils_Glasspaint.showSuccess_Glasspaint(message_Glasspaint: "Custom style set: \(text_glasspaint)", delay_Glasspaint: 1.5)
            }
        })
        
        present(alert_glasspaint, animated: true)
    }
    
    /// 处理难度变化
    @objc private func handleLevelChange_Glasspaint() {
        switch levelSegmentedControl_Glasspaint.selectedSegmentIndex {
        case 0:
            selectedLevel_Glasspaint = .beginner_glasspaint
        case 1:
            selectedLevel_Glasspaint = .intermediate_glasspaint
        case 2:
            selectedLevel_Glasspaint = .advanced_glasspaint
        default:
            selectedLevel_Glasspaint = .beginner_glasspaint
        }
    }
    
    /// 处理发布
    @objc private func handlePublish_Glasspaint() {
        // 发布按钮动画
        UIView.animate(withDuration: 0.15, animations: {
            self.publishButton_Glasspaint.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.publishButton_Glasspaint.transform = .identity
            }
        }
        
        // 1. 检查是否登录
        guard UserViewModel_Glasspaint.shared_Glasspaint.isLoggedIn_Glasspaint else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Navigation_Glasspaint.toLogin_Glasspaint()
            }
            return
        }
        
        // 2. 验证标题
        guard let title_glasspaint = titleTextField_Glasspaint.text, !title_glasspaint.isEmpty else {
            Utils_Glasspaint.showWarning_Glasspaint(message_Glasspaint: "Title cannot be empty", delay_Glasspaint: 1.5)
            return
        }
        
        // 3. 验证内容
        guard let content_glasspaint = contentTextView_Glasspaint.text, !content_glasspaint.isEmpty else {
            Utils_Glasspaint.showWarning_Glasspaint(message_Glasspaint: "Content cannot be empty", delay_Glasspaint: 1.5)
            return
        }
        
        // 4. 验证媒体
        guard let media_glasspaint = selectedMedia_Glasspaint else {
            Utils_Glasspaint.showWarning_Glasspaint(message_Glasspaint: "Please select a photo or video", delay_Glasspaint: 1.5)
            return
        }
        
        // 5. 获取风格（优先使用自定义风格）
        let finalStyle_glasspaint: String
        if let customStyle_glasspaint = customStyleText_Glasspaint, !customStyle_glasspaint.isEmpty {
            finalStyle_glasspaint = customStyle_glasspaint
        } else {
            finalStyle_glasspaint = selectedStyle_Glasspaint.rawValue
        }
        
        // 6. 保存媒体并发布
        var mediaPath_glasspaint = ""
        
        switch media_glasspaint {
        case .image_Glasspaint(let image_glasspaint):
            // 保存图片到Documents目录
            if let imageData_glasspaint = image_glasspaint.jpegData(compressionQuality: 0.8) {
                let documentsPath_glasspaint = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let postsFolder_glasspaint = documentsPath_glasspaint.appendingPathComponent("Posts", isDirectory: true)
                
                // 创建Posts文件夹（如果不存在）
                try? FileManager.default.createDirectory(at: postsFolder_glasspaint, withIntermediateDirectories: true)
                
                let fileName_glasspaint = "post_\(Date().timeIntervalSince1970).jpg"
                let fileURL_glasspaint = postsFolder_glasspaint.appendingPathComponent(fileName_glasspaint)
                
                try? imageData_glasspaint.write(to: fileURL_glasspaint)
                mediaPath_glasspaint = fileURL_glasspaint.path
            }
            
        case .video_Glasspaint(let url_glasspaint):
            mediaPath_glasspaint = url_glasspaint.path
        }
        
        // 7. 创建帖子
        let currentUser_glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getCurrentUser_Glasspaint()
        let newPostId_glasspaint = Int(Date().timeIntervalSince1970)
        
        let newPost_glasspaint = TitleModel_Glasspaint(
            titleId_Glasspaint: newPostId_glasspaint,
            titleUserId_Glasspaint: currentUser_glasspaint.userId_Glasspaint ?? 0,
            titleUserName_Glasspaint: currentUser_glasspaint.userName_Glasspaint ?? "User",
            titleMeidas_Glasspaint: [mediaPath_glasspaint],
            title_Glasspaint: title_glasspaint,
            titleContent_Glasspaint: content_glasspaint,
            reviews_Glasspaint: [],
            likes_Glasspaint: 0,
            paintingLevel_Glasspaint: selectedLevel_Glasspaint,
            paintingStyle_Glasspaint: selectedStyle_Glasspaint,
            scene_Glasspaint: "Home Decoration",
            carrier_Glasspaint: .glassCup_glasspaint,
            createdDate_Glasspaint: Date()
        )
        
        // 8. 添加到列表
        TitleViewModel_Glasspaint.shared_Glasspaint.releasePost_Glasspaint(
            title_glasspaint: title_glasspaint,
            content_glasspaint: content_glasspaint,
            media_glasspaint: mediaPath_glasspaint
        )
        
        // 9. 显示成功提示
        Utils_Glasspaint.showSuccess_Glasspaint(message_Glasspaint: "Published successfully!", delay_Glasspaint: 1.5)
        
        // 10. 清除表单数据
        clearFormData_Glasspaint()
        
        // 11. 返回上一页
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    /// 清除表单数据
    /// 功能：清空所有输入字段和选择的媒体，重置表单到初始状态
    private func clearFormData_Glasspaint() {
        // 清除标题
        titleTextField_Glasspaint.text = ""
        titleCountLabel_Glasspaint.text = "0/50"
        
        // 清除内容
        contentTextView_Glasspaint.text = ""
        contentCountLabel_Glasspaint.text = "0/500"
        contentPlaceholderLabel_Glasspaint.isHidden = false
        
        // 清除媒体
        selectedMedia_Glasspaint = nil
        mediaPlaceholderView_Glasspaint.isHidden = false
        mediaImageView_Glasspaint.isHidden = true
        mediaRemoveButton_Glasspaint.isHidden = true
        mediaTypeLabel_Glasspaint.isHidden = true
        mediaImageView_Glasspaint.image = nil
        
        // 重置风格选择
        selectedStyle_Glasspaint = .modern_glasspaint
        customStyleText_Glasspaint = nil
        styleCollectionView_Glasspaint.reloadData()
        
        // 重置难度选择
        selectedLevel_Glasspaint = .beginner_glasspaint
        levelSegmentedControl_Glasspaint.selectedSegmentIndex = 0
        
        print("✅ 表单数据已清除")
    }
    
    /// 处理EULA按钮点击
    @objc private func handleEULATap_Glasspaint() {
        ProtocolHelper_Glasspaint.showProtocol_Glasspaint(
            type_Glasspaint: .eula_Glasspaint,
            content_Glasspaint: "eula.png",
            from: self
        )
    }
    
    /// 键盘将要显示
    @objc private func keyboardWillShow_Glasspaint(_ notification: Notification) {
        guard let keyboardFrame_glasspaint = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight_glasspaint = keyboardFrame_glasspaint.height
        scrollView_Glasspaint.contentInset.bottom = keyboardHeight_glasspaint
        scrollView_Glasspaint.scrollIndicatorInsets.bottom = keyboardHeight_glasspaint
    }
    
    /// 键盘将要隐藏
    @objc private func keyboardWillHide_Glasspaint(_ notification: Notification) {
        scrollView_Glasspaint.contentInset.bottom = 0
        scrollView_Glasspaint.scrollIndicatorInsets.bottom = 0
    }
}

// MARK: - UITextFieldDelegate

extension Release_Glasspaint: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText_glasspaint = textField.text ?? ""
        let newText_glasspaint = (currentText_glasspaint as NSString).replacingCharacters(in: range, with: string)
        
        // 限制50字符
        if newText_glasspaint.count <= 50 {
            titleCountLabel_Glasspaint.text = "\(newText_glasspaint.count)/50"
            return true
        }
        return false
    }
}

// MARK: - UITextViewDelegate

extension Release_Glasspaint: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        // 更新占位符
        contentPlaceholderLabel_Glasspaint.isHidden = !textView.text.isEmpty
        
        // 更新字数统计
        let count_glasspaint = textView.text.count
        contentCountLabel_Glasspaint.text = "\(count_glasspaint)/500"
        
        // 限制500字符
        if count_glasspaint > 500 {
            textView.text = String(textView.text.prefix(500))
            contentCountLabel_Glasspaint.text = "500/500"
        }
    }
}

// MARK: - UICollectionViewDelegate & DataSource

extension Release_Glasspaint: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return styles_Glasspaint.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_glasspaint = collectionView.dequeueReusableCell(withReuseIdentifier: "StyleCell", for: indexPath) as! StyleCell_Glasspaint
        let style_glasspaint = styles_Glasspaint[indexPath.item]
        let isSelected_glasspaint = style_glasspaint == selectedStyle_Glasspaint
        cell_glasspaint.configure_Glasspaint(style: style_glasspaint, isSelected: isSelected_glasspaint)
        return cell_glasspaint
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedStyle_Glasspaint = styles_Glasspaint[indexPath.item]
        customStyleText_Glasspaint = nil
        collectionView.reloadData()
    }
}

// MARK: - 风格Cell

/// 风格选择Cell
class StyleCell_Glasspaint: UICollectionViewCell {
    
    private let containerView_Glasspaint = UIView()
    private let iconLabel_Glasspaint = UILabel()
    private let titleLabel_Glasspaint = UILabel()
    private let checkmarkView_Glasspaint = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        contentView.addSubview(containerView_Glasspaint)
        containerView_Glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundSecondary_Glasspaint
        containerView_Glasspaint.layer.cornerRadius = 14
        containerView_Glasspaint.layer.borderWidth = 2
        containerView_Glasspaint.layer.borderColor = UIColor.clear.cgColor
        
        containerView_Glasspaint.addSubview(iconLabel_Glasspaint)
        iconLabel_Glasspaint.font = UIFont.systemFont(ofSize: 32)
        iconLabel_Glasspaint.textAlignment = .center
        
        containerView_Glasspaint.addSubview(titleLabel_Glasspaint)
        titleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        titleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        titleLabel_Glasspaint.textAlignment = .center
        
        containerView_Glasspaint.addSubview(checkmarkView_Glasspaint)
        let checkConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        checkmarkView_Glasspaint.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: checkConfig_glasspaint)
        checkmarkView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        checkmarkView_Glasspaint.isHidden = true
        
        containerView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconLabel_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(12)
        }
        
        titleLabel_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
            make.left.right.equalToSuperview().inset(4)
        }
        
        checkmarkView_Glasspaint.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(6)
            make.width.height.equalTo(20)
        }
    }
    
    /// 配置Cell
    /// 参数：
    /// - style: 风格类型
    /// - isSelected: 是否选中
    func configure_Glasspaint(style: PaintingStyle_Glasspaint, isSelected: Bool) {
        titleLabel_Glasspaint.text = style.rawValue
        
        // 根据风格类型设置图标
        switch style {
        case .minimalist_glasspaint:
            iconLabel_Glasspaint.text = "🎯"
        case .retro_glasspaint:
            iconLabel_Glasspaint.text = "📻"
        case .cute_glasspaint:
            iconLabel_Glasspaint.text = "🐰"
        case .modern_glasspaint:
            iconLabel_Glasspaint.text = "✨"
        case .artistic_glasspaint:
            iconLabel_Glasspaint.text = "🎨"
        }
        
        // 更新选中状态
        if isSelected {
            containerView_Glasspaint.layer.borderColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
            containerView_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.1)
            checkmarkView_Glasspaint.isHidden = false
        } else {
            containerView_Glasspaint.layer.borderColor = UIColor.clear.cgColor
            containerView_Glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundSecondary_Glasspaint
            checkmarkView_Glasspaint.isHidden = true
        }
    }
}

// 需要导入AVFoundation
import AVFoundation
