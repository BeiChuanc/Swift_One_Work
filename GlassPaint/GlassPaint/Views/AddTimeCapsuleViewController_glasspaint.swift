import Foundation
import UIKit
import SnapKit
import PhotosUI

// MARK: - 添加时间胶囊页面

/// 添加时间胶囊页面
/// 功能：创建时间胶囊，封存作品照片、创作心得和背后故事，设置未来解锁时间
/// 特性：多图选择、文本输入、解锁时间选择、创建验证
class AddTimeCapsuleViewController_Glasspaint: UIViewController {
    
    // MARK: - UI属性
    
    /// 滚动视图
    private let scrollView_Glasspaint = UIScrollView()
    
    /// 内容视图
    private let contentView_Glasspaint = UIView()
    
    /// 导航栏容器
    private let navContainer_Glasspaint = UIView()
    
    /// 取消按钮
    private let cancelButton_Glasspaint = UIButton(type: .system)
    
    /// 标题标签
    private let titleLabel_Glasspaint = UILabel()
    
    /// 创建按钮
    private let createButton_Glasspaint = UIButton(type: .system)
    
    /// 作品标题容器
    private let titleContainer_Glasspaint = UIView()
    
    /// 作品标题输入框
    private let titleTextField_Glasspaint: UITextField = {
        let textField_glasspaint = UITextField()
        textField_glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textField_glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        textField_glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        textField_glasspaint.layer.cornerRadius = 12
        textField_glasspaint.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField_glasspaint.leftViewMode = .always
        textField_glasspaint.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField_glasspaint.rightViewMode = .always
        textField_glasspaint.attributedPlaceholder = NSAttributedString(
            string: "Enter artwork title...",
            attributes: [.foregroundColor: ColorConfig_Glasspaint.textSecondary_Glasspaint]
        )
        return textField_glasspaint
    }()
    
    /// 解锁时间容器
    private let unlockContainer_Glasspaint = UIView()
    
    /// 解锁时间标签
    private let unlockLabel_Glasspaint = UILabel()
    
    /// 解锁时间选择器
    private let unlockSegment_Glasspaint = UISegmentedControl(items: ["1 Year", "3 Years", "5 Years", "Custom"])
    
    /// 自定义日期选择器
    private let customDatePicker_Glasspaint: UIDatePicker = {
        let picker_glasspaint = UIDatePicker()
        picker_glasspaint.datePickerMode = .date
        picker_glasspaint.minimumDate = Date()
        picker_glasspaint.preferredDatePickerStyle = .wheels
        picker_glasspaint.isHidden = true
        return picker_glasspaint
    }()
    
    /// 图片容器
    private let imagesContainer_Glasspaint = UIView()
    
    /// 图片标题
    private let imagesTitleLabel_Glasspaint = UILabel()
    
    /// 添加图片按钮
    private let addImageButton_Glasspaint = UIButton(type: .system)
    
    /// 图片集合视图
    private lazy var imagesCollectionView_Glasspaint: UICollectionView = {
        let layout_glasspaint = UICollectionViewFlowLayout()
        layout_glasspaint.scrollDirection = .horizontal
        layout_glasspaint.minimumLineSpacing = 12
        layout_glasspaint.itemSize = CGSize(width: 100, height: 100)
        let collectionView_glasspaint = UICollectionView(frame: .zero, collectionViewLayout: layout_glasspaint)
        collectionView_glasspaint.backgroundColor = .clear
        collectionView_glasspaint.showsHorizontalScrollIndicator = false
        return collectionView_glasspaint
    }()
    
    /// 创作心得容器
    private let thoughtsContainer_Glasspaint = UIView()
    
    /// 创作心得标题
    private let thoughtsTitleLabel_Glasspaint = UILabel()
    
    /// 创作心得输入框
    private let thoughtsTextView_Glasspaint: UITextView = {
        let textView_glasspaint = UITextView()
        textView_glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textView_glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        textView_glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        textView_glasspaint.layer.cornerRadius = 12
        textView_glasspaint.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return textView_glasspaint
    }()
    
    /// 创作心得占位符
    private let thoughtsPlaceholderLabel_Glasspaint = UILabel()
    
    /// 背后故事容器
    private let storyContainer_Glasspaint = UIView()
    
    /// 背后故事标题
    private let storyTitleLabel_Glasspaint = UILabel()
    
    /// 背后故事输入框
    private let storyTextView_Glasspaint: UITextView = {
        let textView_glasspaint = UITextView()
        textView_glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textView_glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        textView_glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        textView_glasspaint.layer.cornerRadius = 12
        textView_glasspaint.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return textView_glasspaint
    }()
    
    /// 背后故事占位符
    private let storyPlaceholderLabel_Glasspaint = UILabel()
    
    // MARK: - 数据属性
    
    /// 选中的图片列表
    private var selectedImages_Glasspaint: [UIImage] = []
    
    /// 完成回调
    var onCompleted_Glasspaint: (() -> Void)?
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Glasspaint()
        setupKeyboardObservers_Glasspaint()
    }
    
    deinit {
        removeKeyboardObservers_Glasspaint()
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        view.backgroundColor = ColorConfig_Glasspaint.backgroundSecondary_Glasspaint
        
        // 滚动视图
        view.addSubview(scrollView_Glasspaint)
        scrollView_Glasspaint.showsVerticalScrollIndicator = false
        scrollView_Glasspaint.contentInsetAdjustmentBehavior = .never
        scrollView_Glasspaint.keyboardDismissMode = .interactive
        
        // 内容视图
        scrollView_Glasspaint.addSubview(contentView_Glasspaint)
        
        // 导航栏
        setupNavigationBar_Glasspaint()
        
        // 作品标题
        setupTitleSection_Glasspaint()
        
        // 解锁时间
        setupUnlockSection_Glasspaint()
        
        // 图片
        setupImagesSection_Glasspaint()
        
        // 创作心得
        setupThoughtsSection_Glasspaint()
        
        // 背后故事
        setupStorySection_Glasspaint()
        
        // 布局
        setupConstraints_Glasspaint()
    }
    
    /// 设置导航栏
    private func setupNavigationBar_Glasspaint() {
        view.addSubview(navContainer_Glasspaint)
        navContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        
        // 取消按钮
        navContainer_Glasspaint.addSubview(cancelButton_Glasspaint)
        cancelButton_Glasspaint.setTitle("Cancel", for: .normal)
        cancelButton_Glasspaint.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton_Glasspaint.setTitleColor(ColorConfig_Glasspaint.textSecondary_Glasspaint, for: .normal)
        cancelButton_Glasspaint.addTarget(self, action: #selector(handleCancelTap_Glasspaint), for: .touchUpInside)
        
        // 标题（添加图标）
        navContainer_Glasspaint.addSubview(titleLabel_Glasspaint)
        titleLabel_Glasspaint.text = "⏱️ Time Capsule"
        titleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        titleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        titleLabel_Glasspaint.textAlignment = .center
        
        // 创建按钮
        navContainer_Glasspaint.addSubview(createButton_Glasspaint)
        createButton_Glasspaint.setTitle("Create", for: .normal)
        createButton_Glasspaint.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        createButton_Glasspaint.setTitleColor(ColorConfig_Glasspaint.primaryGradientStart_Glasspaint, for: .normal)
        createButton_Glasspaint.setTitleColor(ColorConfig_Glasspaint.textSecondary_Glasspaint, for: .disabled)
        createButton_Glasspaint.addTarget(self, action: #selector(handleCreateTap_Glasspaint), for: .touchUpInside)
        createButton_Glasspaint.isEnabled = false
        
        // 布局
        navContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        
        cancelButton_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        titleLabel_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        createButton_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    /// 设置作品标题区域
    private func setupTitleSection_Glasspaint() {
        contentView_Glasspaint.addSubview(titleContainer_Glasspaint)
        titleContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        titleContainer_Glasspaint.layer.cornerRadius = 16
        titleContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        titleContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        titleContainer_Glasspaint.layer.shadowRadius = 8
        titleContainer_Glasspaint.layer.shadowOpacity = 0.08
        
        let label_glasspaint = UILabel()
        titleContainer_Glasspaint.addSubview(label_glasspaint)
        label_glasspaint.text = "✨ Artwork Title"
        label_glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label_glasspaint.textColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        
        titleContainer_Glasspaint.addSubview(titleTextField_Glasspaint)
        titleTextField_Glasspaint.delegate = self
        titleTextField_Glasspaint.addTarget(self, action: #selector(handleTextChange_Glasspaint), for: .editingChanged)
        
        label_glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(16)
        }
        
        titleTextField_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(label_glasspaint.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    /// 设置解锁时间区域
    private func setupUnlockSection_Glasspaint() {
        contentView_Glasspaint.addSubview(unlockContainer_Glasspaint)
        unlockContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        unlockContainer_Glasspaint.layer.cornerRadius = 16
        unlockContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        unlockContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        unlockContainer_Glasspaint.layer.shadowRadius = 8
        unlockContainer_Glasspaint.layer.shadowOpacity = 0.08
        
        unlockContainer_Glasspaint.addSubview(unlockLabel_Glasspaint)
        unlockLabel_Glasspaint.text = "🔒 Unlock Time"
        unlockLabel_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        unlockLabel_Glasspaint.textColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint
        
        unlockContainer_Glasspaint.addSubview(unlockSegment_Glasspaint)
        unlockSegment_Glasspaint.selectedSegmentIndex = 0
        unlockSegment_Glasspaint.addTarget(self, action: #selector(handleUnlockTimeChange_Glasspaint), for: .valueChanged)
        
        unlockContainer_Glasspaint.addSubview(customDatePicker_Glasspaint)
        
        unlockLabel_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(16)
        }
        
        unlockSegment_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(unlockLabel_Glasspaint.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(36)
        }
        
        customDatePicker_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(unlockSegment_Glasspaint.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(0)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    /// 设置图片区域
    private func setupImagesSection_Glasspaint() {
        contentView_Glasspaint.addSubview(imagesContainer_Glasspaint)
        imagesContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        imagesContainer_Glasspaint.layer.cornerRadius = 16
        imagesContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        imagesContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        imagesContainer_Glasspaint.layer.shadowRadius = 8
        imagesContainer_Glasspaint.layer.shadowOpacity = 0.08
        
        imagesContainer_Glasspaint.addSubview(imagesTitleLabel_Glasspaint)
        imagesTitleLabel_Glasspaint.text = "📸 Artwork Photos"
        imagesTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        imagesTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        
        imagesContainer_Glasspaint.addSubview(addImageButton_Glasspaint)
        addImageButton_Glasspaint.setTitle("+ Add Photos", for: .normal)
        addImageButton_Glasspaint.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        addImageButton_Glasspaint.setTitleColor(.white, for: .normal)
        addImageButton_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        addImageButton_Glasspaint.layer.cornerRadius = 14
        addImageButton_Glasspaint.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        addImageButton_Glasspaint.addTarget(self, action: #selector(handleAddImageTap_Glasspaint), for: .touchUpInside)
        
        imagesContainer_Glasspaint.addSubview(imagesCollectionView_Glasspaint)
        imagesCollectionView_Glasspaint.delegate = self
        imagesCollectionView_Glasspaint.dataSource = self
        imagesCollectionView_Glasspaint.register(ImageCell_Glasspaint.self, forCellWithReuseIdentifier: "ImageCell")
        
        imagesTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
        }
        
        addImageButton_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(imagesTitleLabel_Glasspaint)
            make.height.equalTo(28)
        }
        
        imagesCollectionView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(imagesTitleLabel_Glasspaint.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview()
            make.height.equalTo(100)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    /// 设置创作心得区域
    private func setupThoughtsSection_Glasspaint() {
        contentView_Glasspaint.addSubview(thoughtsContainer_Glasspaint)
        thoughtsContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        thoughtsContainer_Glasspaint.layer.cornerRadius = 16
        thoughtsContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        thoughtsContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        thoughtsContainer_Glasspaint.layer.shadowRadius = 8
        thoughtsContainer_Glasspaint.layer.shadowOpacity = 0.08
        
        thoughtsContainer_Glasspaint.addSubview(thoughtsTitleLabel_Glasspaint)
        thoughtsTitleLabel_Glasspaint.text = "💭 Creative Thoughts"
        thoughtsTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        thoughtsTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint
        
        thoughtsContainer_Glasspaint.addSubview(thoughtsTextView_Glasspaint)
        thoughtsTextView_Glasspaint.delegate = self
        
        thoughtsContainer_Glasspaint.addSubview(thoughtsPlaceholderLabel_Glasspaint)
        thoughtsPlaceholderLabel_Glasspaint.text = "Share your creative process and feelings..."
        thoughtsPlaceholderLabel_Glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        thoughtsPlaceholderLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        thoughtsPlaceholderLabel_Glasspaint.isUserInteractionEnabled = false
        
        thoughtsTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(16)
        }
        
        thoughtsTextView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(thoughtsTitleLabel_Glasspaint.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(120)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        thoughtsPlaceholderLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(thoughtsTextView_Glasspaint).offset(12)
            make.left.equalTo(thoughtsTextView_Glasspaint).offset(16)
            make.right.equalTo(thoughtsTextView_Glasspaint).offset(-16)
        }
    }
    
    /// 设置背后故事区域
    private func setupStorySection_Glasspaint() {
        contentView_Glasspaint.addSubview(storyContainer_Glasspaint)
        storyContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        storyContainer_Glasspaint.layer.cornerRadius = 16
        storyContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        storyContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        storyContainer_Glasspaint.layer.shadowRadius = 8
        storyContainer_Glasspaint.layer.shadowOpacity = 0.08
        
        storyContainer_Glasspaint.addSubview(storyTitleLabel_Glasspaint)
        storyTitleLabel_Glasspaint.text = "📖 Behind the Story"
        storyTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        storyTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        
        storyContainer_Glasspaint.addSubview(storyTextView_Glasspaint)
        storyTextView_Glasspaint.delegate = self
        
        storyContainer_Glasspaint.addSubview(storyPlaceholderLabel_Glasspaint)
        storyPlaceholderLabel_Glasspaint.text = "Tell the story behind this artwork..."
        storyPlaceholderLabel_Glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        storyPlaceholderLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        storyPlaceholderLabel_Glasspaint.isUserInteractionEnabled = false
        
        storyTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(16)
        }
        
        storyTextView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(storyTitleLabel_Glasspaint.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(120)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        storyPlaceholderLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(storyTextView_Glasspaint).offset(12)
            make.left.equalTo(storyTextView_Glasspaint).offset(16)
            make.right.equalTo(storyTextView_Glasspaint).offset(-16)
        }
    }
    
    /// 设置布局约束
    private func setupConstraints_Glasspaint() {
        scrollView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(navContainer_Glasspaint.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        contentView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        titleContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        unlockContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(titleContainer_Glasspaint.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
        }
        
        imagesContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(unlockContainer_Glasspaint.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
        }
        
        thoughtsContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(imagesContainer_Glasspaint.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
        }
        
        storyContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(thoughtsContainer_Glasspaint.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
    
    
    // MARK: - 交互处理
    
    @objc private func handleCancelTap_Glasspaint() {
        dismiss(animated: true)
    }
    
    @objc private func handleCreateTap_Glasspaint() {
        guard validateInput_Glasspaint() else { return }
        
        let title_glasspaint = titleTextField_Glasspaint.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let thoughts_glasspaint = thoughtsTextView_Glasspaint.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let story_glasspaint = storyTextView_Glasspaint.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let unlockDate_glasspaint = getSelectedUnlockDate_Glasspaint()
        
        let currentUser_glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getCurrentUser_Glasspaint()
        
        // 保存图片并获取路径
        let imagePaths_glasspaint = saveImages_Glasspaint()
        
        // 创建时间胶囊
        let capsule_glasspaint = TimeCapsulePost_Glasspaint(
            title_Glasspaint: title_glasspaint,
            imagePaths_Glasspaint: imagePaths_glasspaint,
            creativeThoughts_Glasspaint: thoughts_glasspaint,
            story_Glasspaint: story_glasspaint,
            unlockDate_Glasspaint: unlockDate_glasspaint,
            userId_Glasspaint: currentUser_glasspaint.userId_Glasspaint ?? 0,
            userName_Glasspaint: currentUser_glasspaint.userName_Glasspaint ?? "User",
            paintingLevel_Glasspaint: currentUser_glasspaint.paintingLevel_Glasspaint
        )
        
        UserViewModel_Glasspaint.shared_Glasspaint.createTimeCapsule_Glasspaint(capsule_glasspaint: capsule_glasspaint)
        
        dismiss(animated: true) {
            self.onCompleted_Glasspaint?()
        }
    }
    
    @objc private func handleUnlockTimeChange_Glasspaint() {
        let isCustom_glasspaint = unlockSegment_Glasspaint.selectedSegmentIndex == 3
        
        UIView.animate(withDuration: 0.3) {
            self.customDatePicker_Glasspaint.isHidden = !isCustom_glasspaint
            self.customDatePicker_Glasspaint.snp.updateConstraints { make in
                make.height.equalTo(isCustom_glasspaint ? 200 : 0)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func handleAddImageTap_Glasspaint() {
        let remaining_glasspaint = 5 - selectedImages_Glasspaint.count
        if remaining_glasspaint <= 0 {
            Utils_Glasspaint.showWarning_Glasspaint(message_Glasspaint: "Maximum 5 images allowed")
            return
        }
        
        // 使用MediaPickerHelper选择图片
        MediaPickerHelper_Glasspaint.shared_Glasspaint.showPicker_Glasspaint(
            from: self,
            mediaType_Glasspaint: .photo_Glasspaint,
            selectionLimit_Glasspaint: remaining_glasspaint
        ) { [weak self] result_glasspaint in
            guard let self = self else { return }
            
            if case .photo_Glasspaint(let image_glasspaint) = result_glasspaint {
                self.selectedImages_Glasspaint.append(image_glasspaint)
                self.imagesCollectionView_Glasspaint.reloadData()
                self.updateCreateButtonState_Glasspaint()
            }
        }
    }
    
    @objc private func handleTextChange_Glasspaint() {
        updateCreateButtonState_Glasspaint()
    }
    
    /// 更新创建按钮状态
    private func updateCreateButtonState_Glasspaint() {
        let hasTitle_glasspaint = !(titleTextField_Glasspaint.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let hasImages_glasspaint = !selectedImages_Glasspaint.isEmpty
        let hasThoughts_glasspaint = !thoughtsTextView_Glasspaint.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasStory_glasspaint = !storyTextView_Glasspaint.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        createButton_Glasspaint.isEnabled = hasTitle_glasspaint && hasImages_glasspaint && hasThoughts_glasspaint && hasStory_glasspaint
    }
    
    /// 验证输入
    private func validateInput_Glasspaint() -> Bool {
        if titleTextField_Glasspaint.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            Utils_Glasspaint.showWarning_Glasspaint(message_Glasspaint: "Please enter artwork title")
            return false
        }
        
        if selectedImages_Glasspaint.isEmpty {
            Utils_Glasspaint.showWarning_Glasspaint(message_Glasspaint: "Please add at least one image")
            return false
        }
        
        if thoughtsTextView_Glasspaint.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Utils_Glasspaint.showWarning_Glasspaint(message_Glasspaint: "Please share your creative thoughts")
            return false
        }
        
        if storyTextView_Glasspaint.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Utils_Glasspaint.showWarning_Glasspaint(message_Glasspaint: "Please tell the story behind")
            return false
        }
        
        return true
    }
    
    /// 获取选中的解锁日期
    private func getSelectedUnlockDate_Glasspaint() -> Date {
        let calendar_glasspaint = Calendar.current
        let now_glasspaint = Date()
        
        switch unlockSegment_Glasspaint.selectedSegmentIndex {
        case 0:
            return calendar_glasspaint.date(byAdding: .year, value: 1, to: now_glasspaint) ?? now_glasspaint
        case 1:
            return calendar_glasspaint.date(byAdding: .year, value: 3, to: now_glasspaint) ?? now_glasspaint
        case 2:
            return calendar_glasspaint.date(byAdding: .year, value: 5, to: now_glasspaint) ?? now_glasspaint
        case 3:
            return customDatePicker_Glasspaint.date
        default:
            return calendar_glasspaint.date(byAdding: .year, value: 1, to: now_glasspaint) ?? now_glasspaint
        }
    }
    
    /// 保存图片并返回路径
    private func saveImages_Glasspaint() -> [String] {
        var paths_glasspaint: [String] = []
        
        // 获取Documents目录
        let documentsPath_glasspaint = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let capsuleFolder_glasspaint = documentsPath_glasspaint.appendingPathComponent("TimeCapsules", isDirectory: true)
        
        // 创建时间胶囊文件夹（如果不存在）
        try? FileManager.default.createDirectory(at: capsuleFolder_glasspaint, withIntermediateDirectories: true)
        
        for (index_glasspaint, image_glasspaint) in selectedImages_Glasspaint.enumerated() {
            let imageName_glasspaint = "capsule_\(UUID().uuidString)_\(index_glasspaint).jpg"
            let imagePath_glasspaint = capsuleFolder_glasspaint.appendingPathComponent(imageName_glasspaint)
            
            // 压缩并保存图片
            if let imageData_glasspaint = image_glasspaint.jpegData(compressionQuality: 0.8) {
                try? imageData_glasspaint.write(to: imagePath_glasspaint)
                paths_glasspaint.append(imagePath_glasspaint.path)
            }
        }
        
        return paths_glasspaint
    }
    
    // MARK: - 键盘处理
    
    /// 设置键盘监听
    private func setupKeyboardObservers_Glasspaint() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillShow_Glasspaint(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide_Glasspaint(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    /// 移除键盘监听
    private func removeKeyboardObservers_Glasspaint() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleKeyboardWillShow_Glasspaint(_ notification: Notification) {
        guard let keyboardFrame_glasspaint = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight_glasspaint = keyboardFrame_glasspaint.height
        scrollView_Glasspaint.contentInset.bottom = keyboardHeight_glasspaint
        scrollView_Glasspaint.scrollIndicatorInsets.bottom = keyboardHeight_glasspaint
    }
    
    @objc private func handleKeyboardWillHide_Glasspaint(_ notification: Notification) {
        scrollView_Glasspaint.contentInset.bottom = 0
        scrollView_Glasspaint.scrollIndicatorInsets.bottom = 0
    }
}

// MARK: - UITextFieldDelegate

extension AddTimeCapsuleViewController_Glasspaint: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension AddTimeCapsuleViewController_Glasspaint: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == thoughtsTextView_Glasspaint {
            thoughtsPlaceholderLabel_Glasspaint.isHidden = !textView.text.isEmpty
        } else if textView == storyTextView_Glasspaint {
            storyPlaceholderLabel_Glasspaint.isHidden = !textView.text.isEmpty
        }
        updateCreateButtonState_Glasspaint()
    }
}

// MARK: - UICollectionView Delegate & DataSource

extension AddTimeCapsuleViewController_Glasspaint: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages_Glasspaint.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_glasspaint = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell_Glasspaint
        
        let image_glasspaint = selectedImages_Glasspaint[indexPath.item]
        cell_glasspaint.configure_Glasspaint(with_glasspaint: image_glasspaint)
        cell_glasspaint.onDelete_Glasspaint = { [weak self] in
            self?.selectedImages_Glasspaint.remove(at: indexPath.item)
            self?.imagesCollectionView_Glasspaint.reloadData()
            self?.updateCreateButtonState_Glasspaint()
        }
        
        return cell_glasspaint
    }
}

// MARK: - 图片单元格

/// 图片单元格
class ImageCell_Glasspaint: UICollectionViewCell {
    
    private let imageView_Glasspaint = UIImageView()
    private let deleteButton_Glasspaint = UIButton(type: .system)
    
    var onDelete_Glasspaint: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI_Glasspaint() {
        contentView.addSubview(imageView_Glasspaint)
        imageView_Glasspaint.contentMode = .scaleAspectFill
        imageView_Glasspaint.layer.cornerRadius = 12
        imageView_Glasspaint.layer.masksToBounds = true
        
        contentView.addSubview(deleteButton_Glasspaint)
        deleteButton_Glasspaint.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        deleteButton_Glasspaint.tintColor = .white
        deleteButton_Glasspaint.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        deleteButton_Glasspaint.layer.cornerRadius = 12
        deleteButton_Glasspaint.addTarget(self, action: #selector(handleDeleteTap_Glasspaint), for: .touchUpInside)
        
        imageView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        deleteButton_Glasspaint.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(4)
            make.width.height.equalTo(24)
        }
    }
    
    func configure_Glasspaint(with_glasspaint image_glasspaint: UIImage) {
        imageView_Glasspaint.image = image_glasspaint
    }
    
    @objc private func handleDeleteTap_Glasspaint() {
        onDelete_Glasspaint?()
    }
}
