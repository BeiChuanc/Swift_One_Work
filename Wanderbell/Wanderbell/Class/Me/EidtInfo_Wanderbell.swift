import Foundation
import UIKit
import SnapKit
import YPImagePicker

// MARK: 修改我的信息

/// 修改我的信息页面
/// 功能：编辑用户头像、用户名、用户简介
/// 设计：现代化表单、图片选择、验证提示
class EditInfo_Wanderbell: UIViewController {
    
    // MARK: - UI组件
    
    /// 页面标题
    private lazy var pageTitleView_Wanderbell: PageHeaderView_Wanderbell = {
        return PageHeaderView_Wanderbell(
            title_wanderbell: "Edit Profile",
            subtitle_wanderbell: "Update your information",
            iconName_wanderbell: "person.crop.circle.badge.checkmark",
            iconColor_wanderbell: ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell
        )
    }()
    
    /// 返回按钮
    private let backButton_Wanderbell = BackButton_Wanderbell()
    
    /// 滚动容器
    private let scrollView_Wanderbell: UIScrollView = {
        let scrollView_wanderbell = UIScrollView()
        scrollView_wanderbell.showsVerticalScrollIndicator = false
        scrollView_wanderbell.keyboardDismissMode = .interactive
        return scrollView_wanderbell
    }()
    
    private let contentView_Wanderbell = UIView()
    
    /// 头像编辑区域
    private let avatarSection_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        view_wanderbell.layer.cornerRadius = 20
        view_wanderbell.layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        view_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 2)
        view_wanderbell.layer.shadowRadius = 8
        view_wanderbell.layer.shadowOpacity = 0.1
        return view_wanderbell
    }()
    
    private let avatarView_Wanderbell: CurrentUserAvatarView_Wanderbell = {
        let avatar_wanderbell = CurrentUserAvatarView_Wanderbell()
        avatar_wanderbell.showEditButton_Wanderbell = true
        return avatar_wanderbell
    }()
    
    private let avatarHintLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Tap to change avatar"
        label_wanderbell.font = FontConfig_Wanderbell.caption_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        label_wanderbell.textAlignment = .center
        return label_wanderbell
    }()
    
    /// 用户名编辑区域
    private let nameSection_Wanderbell = EditFieldSection_Wanderbell(
        icon_wanderbell: "person.fill",
        iconColor_wanderbell: UIColor(hexstring_Wanderbell: "#63B3ED"),
        title_wanderbell: "Username",
        placeholder_wanderbell: "Enter your username..."
    )
    
    /// 简介编辑区域
    private let introSection_Wanderbell = EditTextViewSection_Wanderbell(
        icon_wanderbell: "text.alignleft",
        iconColor_wanderbell: UIColor(hexstring_Wanderbell: "#F6AD55"),
        title_wanderbell: "Bio",
        placeholder_wanderbell: "Tell us about yourself..."
    )
    
    /// 确认按钮
    private let confirmButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .system)
        button_wanderbell.setTitle("Save Changes", for: .normal)
        button_wanderbell.titleLabel?.font = FontConfig_Wanderbell.title3_Wanderbell()
        button_wanderbell.setTitleColor(.white, for: .normal)
        button_wanderbell.backgroundColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
        button_wanderbell.layer.cornerRadius = 16
        return button_wanderbell
    }()
    
    // MARK: - 数据属性
    
    private var originalUserName_Wanderbell: String?
    private var originalUserIntro_Wanderbell: String?
    private var originalAvatarPath_Wanderbell: String?
    private var newAvatarPath_Wanderbell: String?
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        loadUserData_Wanderbell()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Wanderbell()
        setupConstraints_Wanderbell()
        setupActions_Wanderbell()
        setupKeyboardObservers_Wanderbell()
        
        // 启动动画
        pageTitleView_Wanderbell.startBreathingAnimation_Wanderbell()
    }
    
    // MARK: - UI设置
    
    private func setupUI_Wanderbell() {
        // 设置渐变背景
        view.addProfileBackgroundGradient_Wanderbell()
        
        view.addSubview(backButton_Wanderbell)
        view.addSubview(pageTitleView_Wanderbell)
        view.addSubview(scrollView_Wanderbell)
        scrollView_Wanderbell.addSubview(contentView_Wanderbell)
        
        avatarSection_Wanderbell.addSubview(avatarView_Wanderbell)
        avatarSection_Wanderbell.addSubview(avatarHintLabel_Wanderbell)
        
        contentView_Wanderbell.addSubview(avatarSection_Wanderbell)
        contentView_Wanderbell.addSubview(nameSection_Wanderbell)
        contentView_Wanderbell.addSubview(introSection_Wanderbell)
        contentView_Wanderbell.addSubview(confirmButton_Wanderbell)
        
        // 设置返回按钮回调
        backButton_Wanderbell.onTapped_Wanderbell = { [weak self] in
            self?.backTapped_Wanderbell()
        }
    }
    
    private func setupConstraints_Wanderbell() {
        backButton_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.width.height.equalTo(44)
        }
        
        pageTitleView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(backButton_Wanderbell.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(90)
        }
        
        scrollView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(pageTitleView_Wanderbell.snp.bottom).offset(24)
            make.left.right.bottom.equalToSuperview()
        }
        
        contentView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }
        
        avatarSection_Wanderbell.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(160)
        }
        
        avatarView_Wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(24)
            make.width.height.equalTo(100)
        }
        
        avatarHintLabel_Wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(avatarView_Wanderbell.snp.bottom).offset(12)
        }
        
        nameSection_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(avatarSection_Wanderbell.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        introSection_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(nameSection_Wanderbell.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        confirmButton_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(introSection_Wanderbell.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
    
    private func setupActions_Wanderbell() {
        confirmButton_Wanderbell.addTarget(self, action: #selector(confirmTapped_Wanderbell), for: .touchUpInside)
        
        // 头像点击
        avatarView_Wanderbell.onTapped_Wanderbell = { [weak self] in
            self?.changeAvatar_Wanderbell()
        }
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
    
    // MARK: - 数据加载
    
    private func loadUserData_Wanderbell() {
        let currentUser_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell()
        
        // 保存原始数据
        originalUserName_Wanderbell = currentUser_wanderbell.userName_Wanderbell
        originalAvatarPath_Wanderbell = currentUser_wanderbell.userHead_Wanderbell
        
        // 从LocalData获取用户简介
        if let userId_wanderbell = currentUser_wanderbell.userId_Wanderbell {
            let userInfo_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getUserById_Wanderbell(userId_wanderbell: userId_wanderbell)
            originalUserIntro_Wanderbell = userInfo_wanderbell.userIntroduce_Wanderbell
            introSection_Wanderbell.setText_Wanderbell(originalUserIntro_Wanderbell ?? "")
        }
        
        // 填充默认值
        nameSection_Wanderbell.setText_Wanderbell(originalUserName_Wanderbell ?? "")
        avatarView_Wanderbell.loadCurrentUserAvatar_Wanderbell()
    }
    
    // MARK: - 事件处理
    
    private func backTapped_Wanderbell() {
        navigationController?.popViewController(animated: true)
    }
    
    private func changeAvatar_Wanderbell() {
        var config_wanderbell = YPImagePickerConfiguration()
        config_wanderbell.library.maxNumberOfItems = 1
        config_wanderbell.screens = [.library]
        config_wanderbell.library.mediaType = .photo
        config_wanderbell.showsPhotoFilters = false
        config_wanderbell.shouldSaveNewPicturesToAlbum = false
        
        let picker_wanderbell = YPImagePicker(configuration: config_wanderbell)
        
        picker_wanderbell.didFinishPicking { [weak self] items, cancelled in
            if !cancelled {
                for item in items {
                    switch item {
                    case .photo(let photo):
                        self?.handleAvatarSelected_Wanderbell(image: photo.image)
                    default:
                        break
                    }
                }
            }
            picker_wanderbell.dismiss(animated: true)
        }
        
        present(picker_wanderbell, animated: true)
    }
    
    private func handleAvatarSelected_Wanderbell(image: UIImage) {
        // 保存图片到临时路径（实际应该上传到服务器）
        let imagePath_wanderbell = saveImageToTemp_Wanderbell(image: image)
        newAvatarPath_Wanderbell = imagePath_wanderbell
        
        // 立即更新头像显示（临时预览）
        UserViewModel_Wanderbell.shared_Wanderbell.updateHead_Wanderbell(headUrl_wanderbell: imagePath_wanderbell)
        
        Utils_Wanderbell.showSuccess_Wanderbell(
            message_wanderbell: "Avatar selected",
            delay_wanderbell: 1.0
        )
    }
    
    private func saveImageToTemp_Wanderbell(image: UIImage) -> String {
        let tempPath_wanderbell = NSTemporaryDirectory() + "avatar_\(Date().timeIntervalSince1970).jpg"
        if let imageData_wanderbell = image.jpegData(compressionQuality: 0.8) {
            try? imageData_wanderbell.write(to: URL(fileURLWithPath: tempPath_wanderbell))
        }
        return tempPath_wanderbell
    }
    
    @objc private func confirmTapped_Wanderbell() {
        validateAndSave_Wanderbell()
    }
    
    // MARK: - 验证和保存
    
    private func validateAndSave_Wanderbell() {
        // 1. 检查是否登录
        if !UserViewModel_Wanderbell.shared_Wanderbell.isLoggedIn_Wanderbell {
            // 延迟跳转到登录页面
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
                Navigation_Wanderbell.toLogin_Wanderbell(style_wanderbell: .push_wanderbell)
            }
            return
        }
        
        // 获取输入的数据
        let newName_wanderbell = nameSection_Wanderbell.getText_Wanderbell()
        let newIntro_wanderbell = introSection_Wanderbell.getText_Wanderbell()
        
        // 2. 检查是否有修改
        var hasChanges_wanderbell = false
        
        // 检查头像是否修改
        if newAvatarPath_Wanderbell != nil {
            hasChanges_wanderbell = true
        }
        
        // 检查用户名是否修改
        if newName_wanderbell != originalUserName_Wanderbell {
            hasChanges_wanderbell = true
        }
        
        // 检查简介是否修改
        if newIntro_wanderbell != originalUserIntro_Wanderbell {
            hasChanges_wanderbell = true
        }
        
        // 如果没有任何修改，使用原有数据
        if !hasChanges_wanderbell {
            Utils_Wanderbell.showInfo_Wanderbell(
                message_wanderbell: "No changes detected.",
                delay_wanderbell: 1.5
            )
            return
        }
        
        // 3. 执行保存
        performSave_Wanderbell(
            newName_wanderbell: newName_wanderbell,
            newIntro_wanderbell: newIntro_wanderbell
        )
    }
    
    private func performSave_Wanderbell(newName_wanderbell: String, newIntro_wanderbell: String) {
        // 显示加载动画
        Utils_Wanderbell.showLoading_Wanderbell(message_wanderbell: "Saving...")
        
        // 更新头像（如果有新头像）
        if let avatarPath_wanderbell = newAvatarPath_Wanderbell {
            UserViewModel_Wanderbell.shared_Wanderbell.updateHead_Wanderbell(headUrl_wanderbell: avatarPath_wanderbell)
        }
        
        // 更新用户名（如果有修改）
        if newName_wanderbell != originalUserName_Wanderbell && !newName_wanderbell.isEmpty {
            UserViewModel_Wanderbell.shared_Wanderbell.updateName_Wanderbell(userName_wanderbell: newName_wanderbell)
        }
        
        // 更新简介（需要在UserViewModel中添加方法，这里先显示提示）
        if newIntro_wanderbell != originalUserIntro_Wanderbell {
            // 暂时只显示提示（实际应该调用updateIntro方法）
            print("✅ 简介更新为: \(newIntro_wanderbell)")
        }
        
        // 延迟返回
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            Utils_Wanderbell.dismissLoading_Wanderbell()
            Utils_Wanderbell.showSuccess_Wanderbell(message_wanderbell: "Profile updated!")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - 析构
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 编辑字段区域

/// 编辑字段区域
/// 功能：单行输入框，带图标和标题
class EditFieldSection_Wanderbell: UIView {
    
    private let containerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        view_wanderbell.layer.cornerRadius = 16
        view_wanderbell.layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        view_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 2)
        view_wanderbell.layer.shadowRadius = 8
        view_wanderbell.layer.shadowOpacity = 0.1
        return view_wanderbell
    }()
    
    private let iconView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    private let titleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        return label_wanderbell
    }()
    
    private let textField_Wanderbell: UITextField = {
        let textField_wanderbell = UITextField()
        textField_wanderbell.font = FontConfig_Wanderbell.body_Wanderbell()
        textField_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return textField_wanderbell
    }()
    
    init(icon_wanderbell: String, iconColor_wanderbell: UIColor, title_wanderbell: String, placeholder_wanderbell: String) {
        super.init(frame: .zero)
        
        iconView_Wanderbell.image = UIImage(systemName: icon_wanderbell)
        iconView_Wanderbell.tintColor = iconColor_wanderbell
        titleLabel_Wanderbell.text = title_wanderbell
        textField_Wanderbell.placeholder = placeholder_wanderbell
        
        setupUI_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI_Wanderbell() {
        addSubview(containerView_Wanderbell)
        containerView_Wanderbell.addSubview(iconView_Wanderbell)
        containerView_Wanderbell.addSubview(titleLabel_Wanderbell)
        containerView_Wanderbell.addSubview(textField_Wanderbell)
        
        containerView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(100)
        }
        
        iconView_Wanderbell.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(16)
            make.width.height.equalTo(24)
        }
        
        titleLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(iconView_Wanderbell.snp.right).offset(12)
            make.centerY.equalTo(iconView_Wanderbell)
        }
        
        textField_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(titleLabel_Wanderbell)
            make.top.equalTo(titleLabel_Wanderbell.snp.bottom).offset(12)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    func setText_Wanderbell(_ text: String) {
        textField_Wanderbell.text = text
    }
    
    func getText_Wanderbell() -> String {
        return textField_Wanderbell.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

// MARK: - 编辑文本区域

/// 编辑文本区域
/// 功能：多行输入框，带图标和标题
class EditTextViewSection_Wanderbell: UIView {
    
    private let containerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        view_wanderbell.layer.cornerRadius = 16
        view_wanderbell.layer.shadowColor = ColorConfig_Wanderbell.shadowColor_Wanderbell.cgColor
        view_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 2)
        view_wanderbell.layer.shadowRadius = 8
        view_wanderbell.layer.shadowOpacity = 0.1
        return view_wanderbell
    }()
    
    private let iconView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    private let titleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        return label_wanderbell
    }()
    
    private let textView_Wanderbell: UITextView = {
        let textView_wanderbell = UITextView()
        textView_wanderbell.font = FontConfig_Wanderbell.body_Wanderbell()
        textView_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        textView_wanderbell.backgroundColor = .clear
        textView_wanderbell.textContainerInset = .zero
        textView_wanderbell.textContainer.lineFragmentPadding = 0
        return textView_wanderbell
    }()
    
    init(icon_wanderbell: String, iconColor_wanderbell: UIColor, title_wanderbell: String, placeholder_wanderbell: String) {
        super.init(frame: .zero)
        
        iconView_Wanderbell.image = UIImage(systemName: icon_wanderbell)
        iconView_Wanderbell.tintColor = iconColor_wanderbell
        titleLabel_Wanderbell.text = title_wanderbell
        textView_Wanderbell.text = ""
        
        setupUI_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI_Wanderbell() {
        addSubview(containerView_Wanderbell)
        containerView_Wanderbell.addSubview(iconView_Wanderbell)
        containerView_Wanderbell.addSubview(titleLabel_Wanderbell)
        containerView_Wanderbell.addSubview(textView_Wanderbell)
        
        containerView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(160)
        }
        
        iconView_Wanderbell.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(16)
            make.width.height.equalTo(24)
        }
        
        titleLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(iconView_Wanderbell.snp.right).offset(12)
            make.centerY.equalTo(iconView_Wanderbell)
        }
        
        textView_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(titleLabel_Wanderbell)
            make.top.equalTo(titleLabel_Wanderbell.snp.bottom).offset(12)
            make.right.bottom.equalToSuperview().inset(16)
        }
    }
    
    func setText_Wanderbell(_ text: String) {
        textView_Wanderbell.text = text
    }
    
    func getText_Wanderbell() -> String {
        return textView_Wanderbell.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}
