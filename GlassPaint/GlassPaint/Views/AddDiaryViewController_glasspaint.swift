import Foundation
import UIKit
import SnapKit
import PhotosUI

// MARK: - 添加日记页面

/// 添加日记页面
/// 功能：完整的日记添加流程，包含图片选择（最多3张）、文本描述输入、日期选择、发布功能
/// 特性：多图预览与删除、文本输入框、日期选择器、键盘自适应、发布验证、完成回调
/// 关键属性：selectedDate_Glasspaint（选中日期）、selectedImages_Glasspaint（选中图片列表）、onCompleted_Glasspaint（完成回调）
/// 关键方法：handlePublishTap_Glasspaint（发布处理）、handleAddImageTap_Glasspaint（添加图片）、updatePublishButtonState_Glasspaint（更新发布按钮状态）
class AddDiaryViewController_Glasspaint: UIViewController {
    
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
    
    /// 发布按钮
    private let publishButton_Glasspaint = UIButton(type: .system)
    
    /// 日期选择容器
    private let dateContainer_Glasspaint = UIView()
    
    /// 日期标签
    private let dateLabel_Glasspaint = UILabel()
    
    /// 日期选择按钮
    private let datePickerButton_Glasspaint = UIButton(type: .system)
    
    /// 图片容器
    private let imagesContainer_Glasspaint = UIView()
    
    /// 图片标题
    private let imagesTitleLabel_Glasspaint = UILabel()
    
    /// 添加图片按钮
    private let addImageButton_Glasspaint = UIButton(type: .system)
    
    /// 图片集合视图布局
    private let imagesCollectionLayout_Glasspaint: UICollectionViewFlowLayout = {
        let layout_glasspaint = UICollectionViewFlowLayout()
        layout_glasspaint.scrollDirection = .vertical
        layout_glasspaint.minimumLineSpacing = 0
        layout_glasspaint.minimumInteritemSpacing = 0
        return layout_glasspaint
    }()
    
    /// 图片集合视图
    private lazy var imagesCollectionView_Glasspaint: UICollectionView = {
        let collectionView_glasspaint = UICollectionView(frame: .zero, collectionViewLayout: imagesCollectionLayout_Glasspaint)
        collectionView_glasspaint.backgroundColor = .clear
        collectionView_glasspaint.showsVerticalScrollIndicator = false
        collectionView_glasspaint.isScrollEnabled = false
        return collectionView_glasspaint
    }()
    
    /// 文本容器
    private let textContainer_Glasspaint = UIView()
    
    /// 文本标题
    private let textTitleLabel_Glasspaint = UILabel()
    
    /// 文本输入框
    private let textView_Glasspaint: UITextView = {
        let textView_glasspaint = UITextView()
        textView_glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textView_glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        textView_glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        textView_glasspaint.layer.cornerRadius = 12
        textView_glasspaint.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return textView_glasspaint
    }()
    
    /// 占位符标签
    private let placeholderLabel_Glasspaint = UILabel()
    
    // MARK: - 数据属性
    
    /// 选中的日期
    private var selectedDate_Glasspaint: Date
    
    /// 选中的图片列表
    private var selectedImages_Glasspaint: [UIImage] = []
    
    /// 完成回调
    var onCompleted_Glasspaint: (() -> Void)?
    
    /// 是否正在显示日期选择器（防止重复触发）
    private var isShowingDatePicker_Glasspaint: Bool = false
    
    // MARK: - 初始化
    
    /// 初始化
    /// 参数：
    /// - selectedDate_glasspaint: 选中的日期（默认今天）
    init(selectedDate_glasspaint: Date = Date()) {
        self.selectedDate_Glasspaint = selectedDate_glasspaint
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Glasspaint()
        setupKeyboardObservers_Glasspaint()
        updateDateLabel_Glasspaint()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 确保标志位在视图出现时被重置（处理 alert 被外部点击关闭的情况）
        if presentedViewController == nil {
            isShowingDatePicker_Glasspaint = false
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        view.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        
        // 添加渐变背景
        let gradientLayer_glasspaint = CAGradientLayer()
        gradientLayer_glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.05).cgColor,
            ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint.withAlphaComponent(0.05).cgColor
        ]
        gradientLayer_glasspaint.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_glasspaint.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer_glasspaint.frame = view.bounds
        view.layer.insertSublayer(gradientLayer_glasspaint, at: 0)
        
        // 导航栏
        setupNavigationBar_Glasspaint()
        
        // 滚动视图
        view.addSubview(scrollView_Glasspaint)
        scrollView_Glasspaint.addSubview(contentView_Glasspaint)
        
        // 日期选择
        contentView_Glasspaint.addSubview(dateContainer_Glasspaint)
        setupDateSection_Glasspaint()
        
        // 图片选择
        contentView_Glasspaint.addSubview(imagesContainer_Glasspaint)
        setupImagesSection_Glasspaint()
        
        // 文本输入
        contentView_Glasspaint.addSubview(textContainer_Glasspaint)
        setupTextSection_Glasspaint()
        
        setupConstraints_Glasspaint()
    }
    
    /// 设置导航栏
    private func setupNavigationBar_Glasspaint() {
        view.addSubview(navContainer_Glasspaint)
        navContainer_Glasspaint.backgroundColor = .clear
        
        // 取消按钮
        navContainer_Glasspaint.addSubview(cancelButton_Glasspaint)
        cancelButton_Glasspaint.setTitle("Cancel", for: .normal)
        cancelButton_Glasspaint.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton_Glasspaint.setTitleColor(ColorConfig_Glasspaint.textSecondary_Glasspaint, for: .normal)
        cancelButton_Glasspaint.addTarget(self, action: #selector(handleCancelTap_Glasspaint), for: .touchUpInside)
        
        // 标题
        navContainer_Glasspaint.addSubview(titleLabel_Glasspaint)
        titleLabel_Glasspaint.text = "New Diary Entry"
        titleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        titleLabel_Glasspaint.textAlignment = .center
        
        // 发布按钮
        navContainer_Glasspaint.addSubview(publishButton_Glasspaint)
        publishButton_Glasspaint.setTitle("Publish", for: .normal)
        publishButton_Glasspaint.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        publishButton_Glasspaint.setTitleColor(ColorConfig_Glasspaint.primaryGradientStart_Glasspaint, for: .normal)
        publishButton_Glasspaint.setTitleColor(ColorConfig_Glasspaint.textPlaceholder_Glasspaint, for: .disabled)
        publishButton_Glasspaint.addTarget(self, action: #selector(handlePublishTap_Glasspaint), for: .touchUpInside)
        publishButton_Glasspaint.isEnabled = false
        
        // 布局
        cancelButton_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        titleLabel_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        publishButton_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    /// 设置日期选择区域
    private func setupDateSection_Glasspaint() {
        dateContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        dateContainer_Glasspaint.layer.cornerRadius = 16
        dateContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        dateContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        dateContainer_Glasspaint.layer.shadowRadius = 8
        dateContainer_Glasspaint.layer.shadowOpacity = 0.6
        
        // 日期图标
        let iconView_glasspaint = UIImageView(image: UIImage(systemName: "calendar.circle.fill"))
        dateContainer_Glasspaint.addSubview(iconView_glasspaint)
        iconView_glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        iconView_glasspaint.contentMode = .scaleAspectFit
        
        // 日期标签
        dateContainer_Glasspaint.addSubview(dateLabel_Glasspaint)
        dateLabel_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        dateLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 日期选择按钮
        dateContainer_Glasspaint.addSubview(datePickerButton_Glasspaint)
        datePickerButton_Glasspaint.setImage(UIImage(systemName: "chevron.right.circle.fill"), for: .normal)
        datePickerButton_Glasspaint.tintColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint
        datePickerButton_Glasspaint.addTarget(self, action: #selector(handleDatePickerTap_Glasspaint), for: .touchUpInside)
        
        // 布局
        iconView_glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        dateLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(iconView_glasspaint.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }
        
        datePickerButton_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        dateContainer_Glasspaint.snp.makeConstraints { make in
            make.height.equalTo(64)
        }
    }
    
    /// 设置图片选择区域
    private func setupImagesSection_Glasspaint() {
        imagesContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        imagesContainer_Glasspaint.layer.cornerRadius = 16
        imagesContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        imagesContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        imagesContainer_Glasspaint.layer.shadowRadius = 8
        imagesContainer_Glasspaint.layer.shadowOpacity = 0.6
        
        // 标题
        imagesContainer_Glasspaint.addSubview(imagesTitleLabel_Glasspaint)
        imagesTitleLabel_Glasspaint.text = "Photo (Max 1)"
        imagesTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        imagesTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 添加图片按钮
        imagesContainer_Glasspaint.addSubview(addImageButton_Glasspaint)
        addImageButton_Glasspaint.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addImageButton_Glasspaint.tintColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint
        addImageButton_Glasspaint.addTarget(self, action: #selector(handleAddImageTap_Glasspaint), for: .touchUpInside)
        
        // 图片集合视图
        imagesContainer_Glasspaint.addSubview(imagesCollectionView_Glasspaint)
        imagesCollectionView_Glasspaint.delegate = self
        imagesCollectionView_Glasspaint.dataSource = self
        imagesCollectionView_Glasspaint.register(DiaryImageCell_Glasspaint.self, forCellWithReuseIdentifier: "DiaryImageCell")
        
        // 布局
        imagesTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(16)
        }
        
        addImageButton_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(imagesTitleLabel_Glasspaint)
            make.width.height.equalTo(32)
        }
        
        imagesCollectionView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(imagesTitleLabel_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(0).priority(.high)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    /// 设置文本输入区域
    private func setupTextSection_Glasspaint() {
        textContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        textContainer_Glasspaint.layer.cornerRadius = 16
        textContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        textContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        textContainer_Glasspaint.layer.shadowRadius = 8
        textContainer_Glasspaint.layer.shadowOpacity = 0.6
        
        // 标题
        textContainer_Glasspaint.addSubview(textTitleLabel_Glasspaint)
        textTitleLabel_Glasspaint.text = "Description"
        textTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        textTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 文本输入框
        textContainer_Glasspaint.addSubview(textView_Glasspaint)
        textView_Glasspaint.delegate = self
        
        // 占位符
        textView_Glasspaint.addSubview(placeholderLabel_Glasspaint)
        placeholderLabel_Glasspaint.text = "Write your thoughts about this painting..."
        placeholderLabel_Glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        placeholderLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPlaceholder_Glasspaint
        
        // 布局
        textTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview().inset(16)
        }
        
        textView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(textTitleLabel_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.greaterThanOrEqualTo(150)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        placeholderLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    /// 设置约束
    private func setupConstraints_Glasspaint() {
        navContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        
        scrollView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(navContainer_Glasspaint.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        contentView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        dateContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        imagesContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(dateContainer_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        textContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(imagesContainer_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
    
    // MARK: - 键盘处理
    
    /// 设置键盘通知
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
        
        // 点击空白处收起键盘
        let tapGesture_glasspaint = UITapGestureRecognizer(target: self, action: #selector(handleTapToDismissKeyboard_Glasspaint))
        tapGesture_glasspaint.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture_glasspaint)
    }
    
    /// 处理键盘显示
    @objc private func handleKeyboardWillShow_Glasspaint(_ notification_glasspaint: Notification) {
        guard let keyboardFrame_glasspaint = notification_glasspaint.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight_glasspaint = keyboardFrame_glasspaint.height
        scrollView_Glasspaint.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight_glasspaint, right: 0)
        scrollView_Glasspaint.scrollIndicatorInsets = scrollView_Glasspaint.contentInset
    }
    
    /// 处理键盘隐藏
    @objc private func handleKeyboardWillHide_Glasspaint(_ notification_glasspaint: Notification) {
        scrollView_Glasspaint.contentInset = .zero
        scrollView_Glasspaint.scrollIndicatorInsets = .zero
    }
    
    /// 点击空白处收起键盘
    @objc private func handleTapToDismissKeyboard_Glasspaint() {
        view.endEditing(true)
    }
    
    // MARK: - 数据更新
    
    /// 更新日期标签
    private func updateDateLabel_Glasspaint() {
        let formatter_glasspaint = DateFormatter()
        formatter_glasspaint.dateFormat = "MMMM dd, yyyy"
        dateLabel_Glasspaint.text = formatter_glasspaint.string(from: selectedDate_Glasspaint)
    }
    
    /// 更新发布按钮状态
    private func updatePublishButtonState_Glasspaint() {
        let hasContent_glasspaint = !textView_Glasspaint.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasImages_glasspaint = !selectedImages_Glasspaint.isEmpty
        
        publishButton_Glasspaint.isEnabled = hasContent_glasspaint || hasImages_glasspaint
    }
    
    // MARK: - 事件处理
    
    /// 处理取消按钮
    @objc private func handleCancelTap_Glasspaint() {
        dismiss(animated: true)
    }
    
    /// 处理日期选择
    @objc private func handleDatePickerTap_Glasspaint() {
        // 防止重复触发
        guard !isShowingDatePicker_Glasspaint else { return }
        isShowingDatePicker_Glasspaint = true
        
        datePickerButton_Glasspaint.animatePulse_Glasspaint()
        
        // 获取当前月份名称
        let monthFormatter_glasspaint = DateFormatter()
        monthFormatter_glasspaint.dateFormat = "MMMM yyyy"
        let currentMonth_glasspaint = monthFormatter_glasspaint.string(from: Date())
        
        let alert_glasspaint = UIAlertController(title: "Select Date in \(currentMonth_glasspaint)", message: "\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        // 计算当月的日期范围
        let calendar_glasspaint = Calendar.current
        let now_glasspaint = Date()
        
        // 当月第一天
        let components_glasspaint = calendar_glasspaint.dateComponents([.year, .month], from: now_glasspaint)
        let firstDayOfMonth_glasspaint = calendar_glasspaint.date(from: components_glasspaint)!
        
        // 当月最后一天
        var nextMonthComponents_glasspaint = components_glasspaint
        nextMonthComponents_glasspaint.month = (components_glasspaint.month ?? 0) + 1
        let firstDayOfNextMonth_glasspaint = calendar_glasspaint.date(from: nextMonthComponents_glasspaint)!
        let lastDayOfMonth_glasspaint = calendar_glasspaint.date(byAdding: .day, value: -1, to: firstDayOfNextMonth_glasspaint)!
        
        // 确保选中日期在当月范围内
        var validDate_glasspaint = selectedDate_Glasspaint
        if selectedDate_Glasspaint < firstDayOfMonth_glasspaint {
            validDate_glasspaint = firstDayOfMonth_glasspaint
        } else if selectedDate_Glasspaint > lastDayOfMonth_glasspaint {
            validDate_glasspaint = lastDayOfMonth_glasspaint
        }
        selectedDate_Glasspaint = validDate_glasspaint
        
        // 创建日期选择器
        let datePicker_glasspaint = UIDatePicker()
        datePicker_glasspaint.datePickerMode = .date
        datePicker_glasspaint.preferredDatePickerStyle = .wheels
        datePicker_glasspaint.date = validDate_glasspaint
        datePicker_glasspaint.minimumDate = firstDayOfMonth_glasspaint
        datePicker_glasspaint.maximumDate = lastDayOfMonth_glasspaint
        datePicker_glasspaint.locale = Locale(identifier: "en_US")
        datePicker_glasspaint.addTarget(self, action: #selector(handleDateChanged_Glasspaint(_:)), for: .valueChanged)
        
        // 创建底部间距视图（占位，防止选择器与按钮重叠）
        let spacerView_glasspaint = UIView()
        spacerView_glasspaint.backgroundColor = .clear
        spacerView_glasspaint.isUserInteractionEnabled = false
        alert_glasspaint.view.addSubview(spacerView_glasspaint)
        
        alert_glasspaint.view.addSubview(datePicker_glasspaint)
        
        // 调整日期选择器布局
        datePicker_glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(50)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(200)
        }
        
        // 间距视图布局（在选择器下方，高度 20pt）
        spacerView_glasspaint.snp.makeConstraints { make in
            make.top.equalTo(datePicker_glasspaint.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
        }
        
        let confirmAction_glasspaint = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            self?.updateDateLabel_Glasspaint()
            // 延迟重置标志位，确保 dismiss 动画完成
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.isShowingDatePicker_Glasspaint = false
            }
        }
        
        let cancelAction_glasspaint = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            // 延迟重置标志位，确保 dismiss 动画完成
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.isShowingDatePicker_Glasspaint = false
            }
        }
        
        alert_glasspaint.addAction(confirmAction_glasspaint)
        alert_glasspaint.addAction(cancelAction_glasspaint)
        
        // 调整 ActionSheet 高度
        if let containerView_glasspaint = alert_glasspaint.view.superview {
            containerView_glasspaint.subviews.first?.layer.cornerRadius = 20
        }
        
        present(alert_glasspaint, animated: true)
    }
    
    /// 处理日期改变
    @objc private func handleDateChanged_Glasspaint(_ picker_glasspaint: UIDatePicker) {
        selectedDate_Glasspaint = picker_glasspaint.date
    }
    
    /// 处理添加图片
    @objc private func handleAddImageTap_Glasspaint() {
        // 检查图片数量限制
        if selectedImages_Glasspaint.count >= 1 {
            Utils_Glasspaint.showWarning_Glasspaint(message_Glasspaint: "Maximum 1 photo allowed")
            return
        }
        
        addImageButton_Glasspaint.animatePulse_Glasspaint()
        
        // 使用 PHPickerViewController（iOS 14+）
        if #available(iOS 14, *) {
            var configuration_glasspaint = PHPickerConfiguration()
            configuration_glasspaint.filter = .images
            configuration_glasspaint.selectionLimit = 1
            
            let picker_glasspaint = PHPickerViewController(configuration: configuration_glasspaint)
            picker_glasspaint.delegate = self
            present(picker_glasspaint, animated: true)
        } else {
            let picker_glasspaint = UIImagePickerController()
            picker_glasspaint.sourceType = .photoLibrary
            picker_glasspaint.delegate = self
            present(picker_glasspaint, animated: true)
        }
    }
    
    /// 处理发布
    @objc private func handlePublishTap_Glasspaint() {
        view.endEditing(true)
        
        let content_glasspaint = textView_Glasspaint.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 验证
        if content_glasspaint.isEmpty && selectedImages_Glasspaint.isEmpty {
            Utils_Glasspaint.showWarning_Glasspaint(message_Glasspaint: "Please add at least photos or description")
            return
        }
        
        // 显示加载
        Utils_Glasspaint.showLoading_Glasspaint(message_Glasspaint: "Publishing...")
        
        publishButton_Glasspaint.animatePressDown_Glasspaint()
        
        // 保存图片到本地
        var imagePaths_glasspaint: [String] = []
        let fileManager_glasspaint = FileManager.default
        let documentsPath_glasspaint = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let diaryFolder_glasspaint = (documentsPath_glasspaint as NSString).appendingPathComponent("PaintingDiary")
        
        // 创建目录
        try? fileManager_glasspaint.createDirectory(atPath: diaryFolder_glasspaint, withIntermediateDirectories: true)
        
        for (index_glasspaint, image_glasspaint) in selectedImages_Glasspaint.enumerated() {
            let fileName_glasspaint = "\(UUID().uuidString)_\(index_glasspaint).jpg"
            let filePath_glasspaint = (diaryFolder_glasspaint as NSString).appendingPathComponent(fileName_glasspaint)
            
            if let imageData_glasspaint = image_glasspaint.jpegData(compressionQuality: 0.8) {
                try? imageData_glasspaint.write(to: URL(fileURLWithPath: filePath_glasspaint))
                imagePaths_glasspaint.append(filePath_glasspaint)
            }
        }
        
        // 创建日记条目
        let entry_glasspaint = PaintingDiaryEntry_Glasspaint(
            date_Glasspaint: selectedDate_Glasspaint,
            imagePaths_Glasspaint: imagePaths_glasspaint,
            content_Glasspaint: content_glasspaint
        )
        
        // 保存到用户数据
        UserViewModel_Glasspaint.shared_Glasspaint.addDiaryEntry_Glasspaint(entry_glasspaint: entry_glasspaint)
        
        // 延迟关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Utils_Glasspaint.dismissLoading_Glasspaint()
            Utils_Glasspaint.showSuccess_Glasspaint(message_Glasspaint: "Diary Published!")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.onCompleted_Glasspaint?()
                self.dismiss(animated: true)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 更新渐变层
        if let gradientLayer_glasspaint = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer_glasspaint.frame = view.bounds
        }
    }
}

// MARK: - UICollectionViewDelegate & DataSource

extension AddDiaryViewController_Glasspaint: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages_Glasspaint.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_glasspaint = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryImageCell", for: indexPath) as! DiaryImageCell_Glasspaint
        let image_glasspaint = selectedImages_Glasspaint[indexPath.item]
        cell_glasspaint.configure_Glasspaint(image_glasspaint: image_glasspaint, index_glasspaint: indexPath.item)
        cell_glasspaint.onDeleteTapped_Glasspaint = { [weak self] index_glasspaint in
            self?.removeImage_Glasspaint(at_glasspaint: index_glasspaint)
        }
        return cell_glasspaint
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 单张图片占据整个宽度，使用更大的尺寸
        let width_glasspaint = collectionView.bounds.width
        let height_glasspaint: CGFloat = 200
        return CGSize(width: width_glasspaint, height: height_glasspaint)
    }
    
    /// 删除图片
    /// 参数：
    /// - at_glasspaint: 索引
    private func removeImage_Glasspaint(at_glasspaint index_glasspaint: Int) {
        guard index_glasspaint < selectedImages_Glasspaint.count else { return }
        selectedImages_Glasspaint.remove(at: index_glasspaint)
        imagesCollectionView_Glasspaint.reloadData()
        updateImagesCollectionHeight_Glasspaint()
        updatePublishButtonState_Glasspaint()
    }
    
    /// 更新图片集合视图高度
    private func updateImagesCollectionHeight_Glasspaint() {
        let height_glasspaint: CGFloat = selectedImages_Glasspaint.isEmpty ? 0 : 200
        imagesCollectionView_Glasspaint.snp.updateConstraints { make in
            make.height.equalTo(height_glasspaint).priority(.high)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITextViewDelegate

extension AddDiaryViewController_Glasspaint: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel_Glasspaint.isHidden = !textView.text.isEmpty
        updatePublishButtonState_Glasspaint()
    }
}

// MARK: - PHPickerViewController 代理（iOS 14+）

@available(iOS 14, *)
extension AddDiaryViewController_Glasspaint: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard !results.isEmpty else { return }
        
        let group_glasspaint = DispatchGroup()
        
        for result_glasspaint in results {
            group_glasspaint.enter()
            
            result_glasspaint.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object_glasspaint, error_glasspaint in
                if let image_glasspaint = object_glasspaint as? UIImage {
                    DispatchQueue.main.async {
                        self?.selectedImages_Glasspaint.append(image_glasspaint)
                    }
                }
                group_glasspaint.leave()
            }
        }
        
        group_glasspaint.notify(queue: .main) { [weak self] in
            self?.imagesCollectionView_Glasspaint.reloadData()
            self?.updateImagesCollectionHeight_Glasspaint()
            self?.updatePublishButtonState_Glasspaint()
        }
    }
}

// MARK: - UIImagePickerController 代理

extension AddDiaryViewController_Glasspaint: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image_glasspaint = info[.originalImage] as? UIImage {
            selectedImages_Glasspaint.append(image_glasspaint)
            imagesCollectionView_Glasspaint.reloadData()
            updateImagesCollectionHeight_Glasspaint()
            updatePublishButtonState_Glasspaint()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - 日记图片单元格

/// 日记图片单元格
class DiaryImageCell_Glasspaint: UICollectionViewCell {
    
    /// 图片视图
    private let imageView_Glasspaint = UIImageView()
    
    /// 删除按钮
    private let deleteButton_Glasspaint = UIButton(type: .system)
    
    /// 删除回调
    var onDeleteTapped_Glasspaint: ((Int) -> Void)?
    
    /// 图片索引
    private var imageIndex_Glasspaint: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        // 图片视图
        contentView.addSubview(imageView_Glasspaint)
        imageView_Glasspaint.contentMode = .scaleAspectFill
        imageView_Glasspaint.layer.cornerRadius = 12
        imageView_Glasspaint.layer.masksToBounds = true
        imageView_Glasspaint.backgroundColor = ColorConfig_Glasspaint.divider_Glasspaint
        
        // 删除按钮
        contentView.addSubview(deleteButton_Glasspaint)
        deleteButton_Glasspaint.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        deleteButton_Glasspaint.tintColor = .white
        deleteButton_Glasspaint.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        deleteButton_Glasspaint.layer.cornerRadius = 12
        deleteButton_Glasspaint.addTarget(self, action: #selector(handleDeleteTap_Glasspaint), for: .touchUpInside)
        
        // 布局
        imageView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        deleteButton_Glasspaint.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(4)
            make.width.height.equalTo(24)
        }
    }
    
    /// 配置单元格
    /// 参数：
    /// - image_glasspaint: 图片
    /// - index_glasspaint: 索引
    func configure_Glasspaint(image_glasspaint: UIImage, index_glasspaint: Int) {
        imageView_Glasspaint.image = image_glasspaint
        imageIndex_Glasspaint = index_glasspaint
    }
    
    /// 处理删除
    @objc private func handleDeleteTap_Glasspaint() {
        deleteButton_Glasspaint.animatePulse_Glasspaint()
        onDeleteTapped_Glasspaint?(imageIndex_Glasspaint)
    }
}
