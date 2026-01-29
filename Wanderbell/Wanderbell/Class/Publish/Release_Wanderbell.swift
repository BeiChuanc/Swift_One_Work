import Foundation
import UIKit
import SnapKit
import YPImagePicker
import AVFoundation

// MARK: 发布页面

/// 发布页面 - 创建心情记录帖子
/// 功能：输入标题、内容、上传媒体、选择情绪、发布
/// 设计：现代化表单、媒体预览、情绪选择、验证提示
class Release_Wanderbell: UIViewController {
    
    // MARK: - UI组件
    
    /// 滚动容器
    private let scrollView_Wanderbell: UIScrollView = {
        let scrollView_wanderbell = UIScrollView()
        scrollView_wanderbell.showsVerticalScrollIndicator = false
        scrollView_wanderbell.keyboardDismissMode = .interactive
        return scrollView_wanderbell
    }()
    
    private let contentView_Wanderbell = UIView()
    
    /// 页面标题（使用通用组件）
    private lazy var pageTitleView_Wanderbell: PageHeaderView_Wanderbell = {
        return PageHeaderView_Wanderbell(
            title_wanderbell: "Create",
            subtitle_wanderbell: "Share your emotional moment",
            iconName_wanderbell: "plus.circle.fill",
            iconColor_wanderbell: ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell
        )
    }()
    
    /// 媒体区域标签
    private let mediaSectionLabel_Wanderbell: UIView = {
        let container_wanderbell = UIView()
        return container_wanderbell
    }()
    
    private let mediaIcon_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_wanderbell.tintColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    private let mediaTitleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Media"
        label_wanderbell.font = FontConfig_Wanderbell.title3_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return label_wanderbell
    }()
    
    private let mediaDescLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Add a photo or video from your album"
        label_wanderbell.font = FontConfig_Wanderbell.caption_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        return label_wanderbell
    }()
    
    /// 媒体预览区域
    private let mediaPreviewView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.layer.cornerRadius = 20
        view_wanderbell.clipsToBounds = true
        return view_wanderbell
    }()
    
    /// 媒体渐变图层
    private var mediaGradientLayer_Wanderbell: CAGradientLayer?
    
    private let mediaImageView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.contentMode = .scaleAspectFill
        imageView_wanderbell.clipsToBounds = true
        imageView_wanderbell.isHidden = true
        return imageView_wanderbell
    }()
    
    /// 媒体移除按钮
    private let mediaRemoveButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .system)
        button_wanderbell.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button_wanderbell.tintColor = .white
        button_wanderbell.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button_wanderbell.layer.cornerRadius = 18
        button_wanderbell.isHidden = true
        return button_wanderbell
    }()
    
    private let mediaPlaceholderView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        return view_wanderbell
    }()
    
    private let mediaPlaceholderIcon_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView_wanderbell.tintColor = .white
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    private let mediaPlaceholderLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Tap to add from album"
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = .white
        return label_wanderbell
    }()
    
    /// 标题区域标签
    private let titleSectionLabel_Wanderbell: UIView = {
        let container_wanderbell = UIView()
        return container_wanderbell
    }()
    
    private let titleIcon_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "text.quote")
        imageView_wanderbell.tintColor = ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    private let titleTitleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Title"
        label_wanderbell.font = FontConfig_Wanderbell.title3_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return label_wanderbell
    }()
    
    private let titleDescLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Give your emotion a catchy title"
        label_wanderbell.font = FontConfig_Wanderbell.caption_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        return label_wanderbell
    }()
    
    /// 标题输入框
    private let titleTextField_Wanderbell: UITextField = {
        let textField_wanderbell = UITextField()
        textField_wanderbell.placeholder = "Give your emotion a title..."
        textField_wanderbell.font = FontConfig_Wanderbell.title3_Wanderbell()
        textField_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        textField_wanderbell.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        textField_wanderbell.layer.cornerRadius = 16
        textField_wanderbell.layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        textField_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField_wanderbell.layer.shadowRadius = 8
        textField_wanderbell.layer.shadowOpacity = 0.08
        textField_wanderbell.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
        textField_wanderbell.leftViewMode = .always
        textField_wanderbell.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
        textField_wanderbell.rightViewMode = .always
        return textField_wanderbell
    }()
    
    /// 内容区域标签
    private let contentSectionLabel_Wanderbell: UIView = {
        let container_wanderbell = UIView()
        return container_wanderbell
    }()
    
    private let contentIcon_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "square.and.pencil")
        imageView_wanderbell.tintColor = UIColor(hexstring_Wanderbell: "#9F7AEA")
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    private let contentTitleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Content"
        label_wanderbell.font = FontConfig_Wanderbell.title3_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return label_wanderbell
    }()
    
    private let contentDescLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Express your feelings in detail"
        label_wanderbell.font = FontConfig_Wanderbell.caption_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        return label_wanderbell
    }()
    
    /// 内容输入框
    private let contentTextView_Wanderbell: UITextView = {
        let textView_wanderbell = UITextView()
        textView_wanderbell.font = FontConfig_Wanderbell.body_Wanderbell()
        textView_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        textView_wanderbell.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        textView_wanderbell.layer.cornerRadius = 16
        textView_wanderbell.layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        textView_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 2)
        textView_wanderbell.layer.shadowRadius = 8
        textView_wanderbell.layer.shadowOpacity = 0.08
        textView_wanderbell.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        return textView_wanderbell
    }()
    
    private let contentPlaceholderLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Share how you're feeling..."
        label_wanderbell.font = FontConfig_Wanderbell.body_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPlaceholder_Wanderbell
        return label_wanderbell
    }()
    
    /// 情绪区域标签
    private let emotionSectionLabel_Wanderbell: UIView = {
        let container_wanderbell = UIView()
        return container_wanderbell
    }()
    
    private let emotionSectionIcon_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "face.smiling")
        imageView_wanderbell.tintColor = UIColor(hexstring_Wanderbell: "#F6AD55")
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    private let emotionSectionTitleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Emotion"
        label_wanderbell.font = FontConfig_Wanderbell.title3_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return label_wanderbell
    }()
    
    private let emotionSectionDescLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Choose how you're feeling right now"
        label_wanderbell.font = FontConfig_Wanderbell.caption_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        return label_wanderbell
    }()
    
    /// 情绪选择区域
    private let emotionSelectorView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        view_wanderbell.layer.cornerRadius = 16
        view_wanderbell.layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        view_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 2)
        view_wanderbell.layer.shadowRadius = 8
        view_wanderbell.layer.shadowOpacity = 0.08
        return view_wanderbell
    }()
    
    private let emotionLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Emotion Type"
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        return label_wanderbell
    }()
    
    private let selectedEmotionView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = ColorConfig_Wanderbell.backgroundPrimary_Wanderbell
        view_wanderbell.layer.cornerRadius = 20
        return view_wanderbell
    }()
    
    /// 大图标容器（选择情绪后显示）
    private let emotionIconContainer_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.layer.cornerRadius = 32
        view_wanderbell.isHidden = true
        return view_wanderbell
    }()
    
    private let emotionBigIcon_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    private let selectedEmotionIcon_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    private let selectedEmotionName_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Tap to select"
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        return label_wanderbell
    }()
    
    private let emotionArrow_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "chevron.right")
        imageView_wanderbell.tintColor = ColorConfig_Wanderbell.textPlaceholder_Wanderbell
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    /// 发布按钮
    private let publishButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .system)
        button_wanderbell.setTitle("Publish", for: .normal)
        button_wanderbell.titleLabel?.font = FontConfig_Wanderbell.title3_Wanderbell()
        button_wanderbell.setTitleColor(.white, for: .normal)
        button_wanderbell.backgroundColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
        button_wanderbell.layer.cornerRadius = 16
        return button_wanderbell
    }()
    
    /// EULA按钮
    private let eulaButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .system)
        
        // 创建带下划线的文本（使用更大的字体）
        let attributes_wanderbell: [NSAttributedString.Key: Any] = [
            .font: FontConfig_Wanderbell.subheadline_Wanderbell(),
            .foregroundColor: ColorConfig_Wanderbell.textSecondary_Wanderbell,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: ColorConfig_Wanderbell.textSecondary_Wanderbell
        ]
        
        let attributedTitle_wanderbell = NSAttributedString(string: "EULA", attributes: attributes_wanderbell)
        button_wanderbell.setAttributedTitle(attributedTitle_wanderbell, for: .normal)
        
        return button_wanderbell
    }()
    
    // MARK: - 数据属性
    
    private var selectedImage_Wanderbell: UIImage?
    private var selectedVideoURL_Wanderbell: URL?
    private var selectedEmotion_Wanderbell: EmotionType_Wanderbell?
    private var emotionIntensity_Wanderbell: Int = 3
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Wanderbell()
        setupConstraints_Wanderbell()
        setupActions_Wanderbell()
        setupKeyboardObservers_Wanderbell()
        
        // 启动标题图标呼吸动画
        pageTitleView_Wanderbell.startBreathingAnimation_Wanderbell()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 更新媒体渐变图层大小
        if mediaGradientLayer_Wanderbell == nil {
            let gradient_wanderbell = UIColor.createPrimaryGradientLayer_Wanderbell(frame_wanderbell: mediaPreviewView_Wanderbell.bounds)
            gradient_wanderbell.opacity = 0.8
            mediaGradientLayer_Wanderbell = gradient_wanderbell
            mediaPreviewView_Wanderbell.layer.insertSublayer(gradient_wanderbell, at: 0)
        } else {
            mediaGradientLayer_Wanderbell?.frame = mediaPreviewView_Wanderbell.bounds
        }
    }
    
    // MARK: - UI设置
    
    private func setupUI_Wanderbell() {
        // 设置发布页渐变背景
        view.addPublishBackgroundGradient_Wanderbell()
        
        view.addSubview(pageTitleView_Wanderbell)
        view.addSubview(scrollView_Wanderbell)
        scrollView_Wanderbell.addSubview(contentView_Wanderbell)
        
        // 设置媒体区域标签
        mediaSectionLabel_Wanderbell.addSubview(mediaIcon_Wanderbell)
        mediaSectionLabel_Wanderbell.addSubview(mediaTitleLabel_Wanderbell)
        mediaSectionLabel_Wanderbell.addSubview(mediaDescLabel_Wanderbell)
        
        // 设置标题区域标签
        titleSectionLabel_Wanderbell.addSubview(titleIcon_Wanderbell)
        titleSectionLabel_Wanderbell.addSubview(titleTitleLabel_Wanderbell)
        titleSectionLabel_Wanderbell.addSubview(titleDescLabel_Wanderbell)
        
        // 设置内容区域标签
        contentSectionLabel_Wanderbell.addSubview(contentIcon_Wanderbell)
        contentSectionLabel_Wanderbell.addSubview(contentTitleLabel_Wanderbell)
        contentSectionLabel_Wanderbell.addSubview(contentDescLabel_Wanderbell)
        
        // 设置情绪区域标签
        emotionSectionLabel_Wanderbell.addSubview(emotionSectionIcon_Wanderbell)
        emotionSectionLabel_Wanderbell.addSubview(emotionSectionTitleLabel_Wanderbell)
        emotionSectionLabel_Wanderbell.addSubview(emotionSectionDescLabel_Wanderbell)
        
        mediaPreviewView_Wanderbell.addSubview(mediaImageView_Wanderbell)
        mediaPlaceholderView_Wanderbell.addSubview(mediaPlaceholderIcon_Wanderbell)
        mediaPlaceholderView_Wanderbell.addSubview(mediaPlaceholderLabel_Wanderbell)
        mediaPreviewView_Wanderbell.addSubview(mediaPlaceholderView_Wanderbell)
        mediaPreviewView_Wanderbell.addSubview(mediaRemoveButton_Wanderbell)
        
        contentTextView_Wanderbell.addSubview(contentPlaceholderLabel_Wanderbell)
        
        emotionIconContainer_Wanderbell.addSubview(emotionBigIcon_Wanderbell)
        selectedEmotionView_Wanderbell.addSubview(selectedEmotionIcon_Wanderbell)
        selectedEmotionView_Wanderbell.addSubview(selectedEmotionName_Wanderbell)
        selectedEmotionView_Wanderbell.addSubview(emotionArrow_Wanderbell)
        emotionSelectorView_Wanderbell.addSubview(emotionLabel_Wanderbell)
        emotionSelectorView_Wanderbell.addSubview(emotionIconContainer_Wanderbell)
        emotionSelectorView_Wanderbell.addSubview(selectedEmotionView_Wanderbell)
        
        contentView_Wanderbell.addSubview(mediaSectionLabel_Wanderbell)
        contentView_Wanderbell.addSubview(mediaPreviewView_Wanderbell)
        contentView_Wanderbell.addSubview(titleSectionLabel_Wanderbell)
        contentView_Wanderbell.addSubview(titleTextField_Wanderbell)
        contentView_Wanderbell.addSubview(contentSectionLabel_Wanderbell)
        contentView_Wanderbell.addSubview(contentTextView_Wanderbell)
        contentView_Wanderbell.addSubview(emotionSectionLabel_Wanderbell)
        contentView_Wanderbell.addSubview(emotionSelectorView_Wanderbell)
        contentView_Wanderbell.addSubview(publishButton_Wanderbell)
        contentView_Wanderbell.addSubview(eulaButton_Wanderbell)
        
        contentTextView_Wanderbell.delegate = self
    }
    
    private func setupConstraints_Wanderbell() {
        // 页面标题
        pageTitleView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(90)
        }
        
        // 滚动容器
        scrollView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(pageTitleView_Wanderbell.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
        }
        
        contentView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }
        
        // 媒体区域标签
        mediaSectionLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        mediaIcon_Wanderbell.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        mediaTitleLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(mediaIcon_Wanderbell.snp.right).offset(8)
            make.top.equalToSuperview()
        }
        
        mediaDescLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(mediaTitleLabel_Wanderbell)
            make.top.equalTo(mediaTitleLabel_Wanderbell.snp.bottom).offset(4)
        }
        
        // 媒体预览
        mediaPreviewView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(mediaSectionLabel_Wanderbell.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(240)
        }
        
        mediaImageView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mediaPlaceholderView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mediaPlaceholderIcon_Wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.width.height.equalTo(60)
        }
        
        mediaPlaceholderLabel_Wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(mediaPlaceholderIcon_Wanderbell.snp.bottom).offset(12)
        }
        
        mediaRemoveButton_Wanderbell.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(12)
            make.width.height.equalTo(36)
        }
        
        // 标题区域标签
        titleSectionLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(mediaPreviewView_Wanderbell.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        titleIcon_Wanderbell.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleTitleLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(titleIcon_Wanderbell.snp.right).offset(8)
            make.top.equalToSuperview()
        }
        
        titleDescLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(titleTitleLabel_Wanderbell)
            make.top.equalTo(titleTitleLabel_Wanderbell.snp.bottom).offset(4)
        }
        
        // 标题输入
        titleTextField_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(titleSectionLabel_Wanderbell.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        // 内容区域标签
        contentSectionLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(titleTextField_Wanderbell.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        contentIcon_Wanderbell.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        contentTitleLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(contentIcon_Wanderbell.snp.right).offset(8)
            make.top.equalToSuperview()
        }
        
        contentDescLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(contentTitleLabel_Wanderbell)
            make.top.equalTo(contentTitleLabel_Wanderbell.snp.bottom).offset(4)
        }
        
        // 内容输入
        contentTextView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(contentSectionLabel_Wanderbell.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(180)
        }
        
        contentPlaceholderLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
        }
        
        // 情绪区域标签
        emotionSectionLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(contentTextView_Wanderbell.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        emotionSectionIcon_Wanderbell.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        emotionSectionTitleLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(emotionSectionIcon_Wanderbell.snp.right).offset(8)
            make.top.equalToSuperview()
        }
        
        emotionSectionDescLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(emotionSectionTitleLabel_Wanderbell)
            make.top.equalTo(emotionSectionTitleLabel_Wanderbell.snp.bottom).offset(4)
        }
        
        // 情绪选择
        emotionSelectorView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(emotionSectionLabel_Wanderbell.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(80)
        }
        
        emotionLabel_Wanderbell.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(16)
        }
        
        emotionIconContainer_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(emotionLabel_Wanderbell.snp.bottom).offset(12)
            make.width.height.equalTo(64)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        emotionBigIcon_Wanderbell.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        selectedEmotionView_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(emotionIconContainer_Wanderbell.snp.right).offset(12)
            make.top.equalTo(emotionLabel_Wanderbell.snp.bottom).offset(8)
            make.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        selectedEmotionIcon_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        selectedEmotionName_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(selectedEmotionIcon_Wanderbell.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        
        emotionArrow_Wanderbell.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        // 发布按钮
        publishButton_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(emotionSelectorView_Wanderbell.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        
        // EULA按钮
        eulaButton_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(publishButton_Wanderbell.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-120)
        }
    }
    
    private func setupActions_Wanderbell() {
        publishButton_Wanderbell.addTarget(self, action: #selector(publishButtonTapped_Wanderbell), for: .touchUpInside)
        mediaRemoveButton_Wanderbell.addTarget(self, action: #selector(removeMediaTapped_Wanderbell), for: .touchUpInside)
        eulaButton_Wanderbell.addTarget(self, action: #selector(eulaButtonTapped_Wanderbell), for: .touchUpInside)
        
        // 媒体选择手势
        let mediaTapGesture_wanderbell = UITapGestureRecognizer(target: self, action: #selector(mediaViewTapped_Wanderbell))
        mediaPreviewView_Wanderbell.addGestureRecognizer(mediaTapGesture_wanderbell)
        
        // 情绪选择手势
        let emotionTapGesture_wanderbell = UITapGestureRecognizer(target: self, action: #selector(emotionViewTapped_Wanderbell))
        emotionSelectorView_Wanderbell.addGestureRecognizer(emotionTapGesture_wanderbell)
    }
    
    // MARK: - 键盘处理
    
    private func setupKeyboardObservers_Wanderbell() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Wanderbell(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Wanderbell(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow_Wanderbell(_ notification: Notification) {
        guard let keyboardFrame_wanderbell = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight_wanderbell = keyboardFrame_wanderbell.height
        scrollView_Wanderbell.contentInset.bottom = keyboardHeight_wanderbell
    }
    
    @objc private func keyboardWillHide_Wanderbell(_ notification: Notification) {
        scrollView_Wanderbell.contentInset.bottom = 0
    }
    
    // MARK: - 事件处理
    
    @objc private func mediaViewTapped_Wanderbell() {
        showMediaPicker_Wanderbell()
    }
    
    @objc private func removeMediaTapped_Wanderbell() {
        // 清除媒体
        selectedImage_Wanderbell = nil
        selectedVideoURL_Wanderbell = nil
        
        mediaImageView_Wanderbell.image = nil
        mediaImageView_Wanderbell.isHidden = true
        mediaPlaceholderView_Wanderbell.isHidden = false
        mediaRemoveButton_Wanderbell.isHidden = true
        
        // 缩放动画
        mediaRemoveButton_Wanderbell.animatePulse_Wanderbell()
        
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .light)
        generator_wanderbell.impactOccurred()
    }
    
    @objc private func emotionViewTapped_Wanderbell() {
        showEmotionPicker_Wanderbell()
    }
    
    @objc private func publishButtonTapped_Wanderbell() {
        validateAndPublish_Wanderbell()
    }
    
    /// EULA按钮点击
    /// 功能：跳转到EULA协议页面展示eula.png
    @objc private func eulaButtonTapped_Wanderbell() {
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .light)
        generator_wanderbell.impactOccurred()
        
        // 跳转到协议页面展示EULA图片
        ProtocolHelper_Wanderbell.showProtocol_Wanderbell(type_wanderbell: .eula_Wanderbell, content_wanderbell: "eula.png", from: self)
    }
    
    // MARK: - 媒体选择
    
    private func showMediaPicker_Wanderbell() {
        var config_wanderbell = YPImagePickerConfiguration()
        config_wanderbell.library.maxNumberOfItems = 1
        config_wanderbell.screens = [.library] // 只从相册选择
        config_wanderbell.library.mediaType = .photoAndVideo
        config_wanderbell.video.compression = AVAssetExportPresetMediumQuality
        config_wanderbell.showsPhotoFilters = false
        config_wanderbell.shouldSaveNewPicturesToAlbum = false
        config_wanderbell.hidesStatusBar = false
        config_wanderbell.hidesBottomBar = false
        
        let picker_wanderbell = YPImagePicker(configuration: config_wanderbell)
        
        picker_wanderbell.didFinishPicking { [weak self] items, cancelled in
            if !cancelled {
                for item in items {
                    switch item {
                    case .photo(let photo):
                        self?.handleSelectedPhoto_Wanderbell(photo: photo.image)
                    case .video(let video):
                        self?.handleSelectedVideo_Wanderbell(url: video.url)
                    }
                }
            }
            picker_wanderbell.dismiss(animated: true)
        }
        
        present(picker_wanderbell, animated: true)
    }
    
    private func handleSelectedPhoto_Wanderbell(photo: UIImage) {
        selectedImage_Wanderbell = photo
        selectedVideoURL_Wanderbell = nil
        
        mediaImageView_Wanderbell.image = photo
        mediaImageView_Wanderbell.isHidden = false
        mediaPlaceholderView_Wanderbell.isHidden = true
        mediaRemoveButton_Wanderbell.isHidden = false
        
        // 显示动画
        mediaRemoveButton_Wanderbell.animateSpringScaleIn_Wanderbell()
    }
    
    private func handleSelectedVideo_Wanderbell(url: URL) {
        selectedVideoURL_Wanderbell = url
        selectedImage_Wanderbell = nil
        
        // 提取视频第一帧作为封面
        let asset_wanderbell = AVAsset(url: url)
        let imageGenerator_wanderbell = AVAssetImageGenerator(asset: asset_wanderbell)
        imageGenerator_wanderbell.appliesPreferredTrackTransform = true
        
        do {
            let cgImage_wanderbell = try imageGenerator_wanderbell.copyCGImage(at: .zero, actualTime: nil)
            let thumbnail_wanderbell = UIImage(cgImage: cgImage_wanderbell)
            mediaImageView_Wanderbell.image = thumbnail_wanderbell
            mediaImageView_Wanderbell.isHidden = false
            mediaPlaceholderView_Wanderbell.isHidden = true
            mediaRemoveButton_Wanderbell.isHidden = false
            
            // 显示动画
            mediaRemoveButton_Wanderbell.animateSpringScaleIn_Wanderbell()
        } catch {
            print("❌ 提取视频封面失败: \(error)")
        }
    }
    
    // MARK: - 情绪选择
    
    private func showEmotionPicker_Wanderbell() {
        let picker_wanderbell = EmotionPickerView_Wanderbell()
        picker_wanderbell.onEmotionSelected_Wanderbell = { [weak self] emotionType_wanderbell, intensity_wanderbell in
            self?.handleEmotionSelected_Wanderbell(emotionType_wanderbell: emotionType_wanderbell, intensity_wanderbell: intensity_wanderbell)
        }
        picker_wanderbell.show_Wanderbell(in: self)
    }
    
    private func handleEmotionSelected_Wanderbell(emotionType_wanderbell: EmotionType_Wanderbell, intensity_wanderbell: Int) {
        selectedEmotion_Wanderbell = emotionType_wanderbell
        emotionIntensity_Wanderbell = intensity_wanderbell
        
        // 显示大图标
        emotionIconContainer_Wanderbell.isHidden = false
        emotionIconContainer_Wanderbell.backgroundColor = emotionType_wanderbell.getColor_Wanderbell().withAlphaComponent(0.2)
        emotionBigIcon_Wanderbell.image = UIImage(systemName: emotionType_wanderbell.getIcon_Wanderbell())
        emotionBigIcon_Wanderbell.tintColor = emotionType_wanderbell.getColor_Wanderbell()
        
        // 更新UI
        selectedEmotionIcon_Wanderbell.image = UIImage(systemName: emotionType_wanderbell.getIcon_Wanderbell())
        selectedEmotionIcon_Wanderbell.tintColor = emotionType_wanderbell.getColor_Wanderbell()
        selectedEmotionName_Wanderbell.text = emotionType_wanderbell.rawValue
        selectedEmotionName_Wanderbell.textColor = emotionType_wanderbell.getColor_Wanderbell()
        selectedEmotionView_Wanderbell.backgroundColor = emotionType_wanderbell.getColor_Wanderbell().withAlphaComponent(0.15)
        
        // 大图标弹性出现动画
        emotionIconContainer_Wanderbell.animateSpringScaleIn_Wanderbell()
    }
    
    // MARK: - 验证和发布
    
    private func validateAndPublish_Wanderbell() {
        // 1. 检查是否登录
        if !UserViewModel_Wanderbell.shared_Wanderbell.isLoggedIn_Wanderbell {
            
            // 延迟跳转到登录页
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.dismiss(animated: true) {
                    Navigation_Wanderbell.toLogin_Wanderbell(style_wanderbell: .push_wanderbell)
                }
            }
            return
        }
        
        // 2. 检查标题
        guard let title_wanderbell = titleTextField_Wanderbell.text, !title_wanderbell.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            Utils_Wanderbell.showWarning_Wanderbell(
                message_wanderbell: "Please enter a title.",
                delay_wanderbell: 1.5
            )
            titleTextField_Wanderbell.animateShake_Wanderbell()
            return
        }
        
        // 3. 检查内容
        guard let content_wanderbell = contentTextView_Wanderbell.text, !content_wanderbell.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            Utils_Wanderbell.showWarning_Wanderbell(
                message_wanderbell: "Please share your feelings.",
                delay_wanderbell: 1.5
            )
            contentTextView_Wanderbell.animateShake_Wanderbell()
            return
        }
        
        // 4. 检查媒体
        guard selectedImage_Wanderbell != nil || selectedVideoURL_Wanderbell != nil else {
            Utils_Wanderbell.showWarning_Wanderbell(
                message_wanderbell: "Please add a photo or video.",
                delay_wanderbell: 1.5
            )
            mediaPreviewView_Wanderbell.animateShake_Wanderbell()
            return
        }
        
        // 5. 检查情绪
        guard let emotion_wanderbell = selectedEmotion_Wanderbell else {
            Utils_Wanderbell.showWarning_Wanderbell(
                message_wanderbell: "Please select an emotion type.",
                delay_wanderbell: 1.5
            )
            selectedEmotionView_Wanderbell.animateShake_Wanderbell()
            return
        }
        
        // 全部验证通过，执行发布
        performPublish_Wanderbell(
            title_wanderbell: title_wanderbell,
            content_wanderbell: content_wanderbell,
            emotion_wanderbell: emotion_wanderbell
        )
    }
    
    private func performPublish_Wanderbell(title_wanderbell: String, content_wanderbell: String, emotion_wanderbell: EmotionType_Wanderbell) {
        // 显示加载动画
        Utils_Wanderbell.showLoading_Wanderbell(message_wanderbell: "Publishing...")
        
        // 保存媒体文件到文档目录
        var mediaPath_wanderbell = ""
        
        if let image_wanderbell = selectedImage_Wanderbell {
            // 保存图片到文档目录
            mediaPath_wanderbell = saveImageToDocuments_Wanderbell(image_wanderbell: image_wanderbell)
        } else if let videoURL_wanderbell = selectedVideoURL_Wanderbell {
            // 保存视频到文档目录
            mediaPath_wanderbell = saveVideoToDocuments_Wanderbell(videoURL_wanderbell: videoURL_wanderbell)
        }
        
        // 发布帖子
        TitleViewModel_Wanderbell.shared_Wanderbell.releasePost_Wanderbell(
            title_wanderbell: title_wanderbell,
            content_wanderbell: content_wanderbell,
            media_wanderbell: mediaPath_wanderbell,
            type_wanderbell: 0
        )
        
        // 发布成功后，延迟清除数据并关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            // 清除所有输入数据
            self?.clearAllInputs_Wanderbell()
            
            // 延迟关闭页面
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.dismiss(animated: true)
            }
        }
    }
    
    /// 保存图片到文档目录
    /// 功能：将选中的图片保存到应用的文档目录
    /// 参数：
    /// - image_wanderbell: 要保存的图片
    /// 返回值：保存后的文件名
    private func saveImageToDocuments_Wanderbell(image_wanderbell: UIImage) -> String {
        let fileName_wanderbell = "post_\(Date().timeIntervalSince1970).jpg"
        
        if let data_wanderbell = image_wanderbell.jpegData(compressionQuality: 0.8) {
            let documentsPath_wanderbell = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL_wanderbell = documentsPath_wanderbell.appendingPathComponent(fileName_wanderbell)
            
            do {
                try data_wanderbell.write(to: fileURL_wanderbell)
                print("✅ 图片已保存到: \(fileURL_wanderbell.path)")
                return fileName_wanderbell
            } catch {
                print("❌ 保存图片失败: \(error)")
            }
        }
        
        return fileName_wanderbell
    }
    
    /// 保存视频到文档目录
    /// 功能：将选中的视频复制到应用的文档目录
    /// 参数：
    /// - videoURL_wanderbell: 视频的临时URL
    /// 返回值：保存后的文件名
    private func saveVideoToDocuments_Wanderbell(videoURL_wanderbell: URL) -> String {
        let fileName_wanderbell = "post_\(Date().timeIntervalSince1970).mp4"
        let documentsPath_wanderbell = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_wanderbell = documentsPath_wanderbell.appendingPathComponent(fileName_wanderbell)
        
        do {
            // 如果文件已存在，先删除
            if FileManager.default.fileExists(atPath: fileURL_wanderbell.path) {
                try FileManager.default.removeItem(at: fileURL_wanderbell)
            }
            // 复制视频文件
            try FileManager.default.copyItem(at: videoURL_wanderbell, to: fileURL_wanderbell)
            print("✅ 视频已保存到: \(fileURL_wanderbell.path)")
            return fileName_wanderbell
        } catch {
            print("❌ 保存视频失败: \(error)")
            return fileName_wanderbell
        }
    }
    
    /// 清除所有输入数据
    /// 功能：发布成功后清除表单中的所有数据，恢复初始状态
    private func clearAllInputs_Wanderbell() {
        // 清除文本输入
        titleTextField_Wanderbell.text = ""
        contentTextView_Wanderbell.text = ""
        contentPlaceholderLabel_Wanderbell.isHidden = false
        
        // 清除媒体选择
        selectedImage_Wanderbell = nil
        selectedVideoURL_Wanderbell = nil
        mediaImageView_Wanderbell.image = nil
        mediaImageView_Wanderbell.isHidden = true
        mediaPlaceholderView_Wanderbell.isHidden = false
        mediaRemoveButton_Wanderbell.isHidden = true
        
        // 清除情绪选择
        selectedEmotion_Wanderbell = nil
        emotionIntensity_Wanderbell = 3
        emotionIconContainer_Wanderbell.isHidden = true
        selectedEmotionIcon_Wanderbell.image = nil
        selectedEmotionName_Wanderbell.text = "Tap to select"
        selectedEmotionName_Wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        selectedEmotionView_Wanderbell.backgroundColor = ColorConfig_Wanderbell.backgroundPrimary_Wanderbell
        
        print("✅ 所有输入数据已清除")
    }
    
    /// 从内容中提取标签
    private func extractTags_Wanderbell(from content_wanderbell: String) -> [String] {
        var tags_wanderbell: [String] = []
        let lowercased_wanderbell = content_wanderbell.lowercased()
        
        if lowercased_wanderbell.contains("happy") || lowercased_wanderbell.contains("joy") {
            tags_wanderbell.append("joy")
        }
        if lowercased_wanderbell.contains("peace") || lowercased_wanderbell.contains("calm") {
            tags_wanderbell.append("peace")
        }
        if lowercased_wanderbell.contains("grateful") || lowercased_wanderbell.contains("thank") {
            tags_wanderbell.append("gratitude")
        }
        if lowercased_wanderbell.contains("anxiety") || lowercased_wanderbell.contains("worry") {
            tags_wanderbell.append("stress")
        }
        
        if tags_wanderbell.isEmpty {
            tags_wanderbell.append("reflection")
        }
        
        return tags_wanderbell
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextViewDelegate

extension Release_Wanderbell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        // 控制占位符显示/隐藏
        contentPlaceholderLabel_Wanderbell.isHidden = !textView.text.isEmpty
    }
}

