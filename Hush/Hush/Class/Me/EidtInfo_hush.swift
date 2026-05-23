import Foundation
import UIKit
import SnapKit

// MARK: 编辑用户信息页面

/// 编辑用户信息页 ViewController
/// 功能：修改头像、用户名、用户简介，确认后调用 UserViewModel 更新
/// 设计：顶部渐变头部（含头像区），卡片式表单，只在有变更时才提交对应字段
/// 注意：逻辑均在 VC 中处理，viewWillAppear 时重新加载默认数据
class EditInfo_Hush: UIViewController {
    
    // MARK: - 私有属性
    
    /// 当前选取的头像图片（nil 表示未改动）
    private var _selectedAvatarImage_Hush: UIImage?
    
    /// 原始用户名（用于判断是否有修改）
    private var _originalName_Hush: String = ""
    
    /// 原始简介（用于判断是否有修改）
    private var _originalIntroduce_Hush: String = ""
    
    /// 原始头像路径（用于判断是否有修改）
    private var _originalHead_Hush: String?
    
    // MARK: - UI 组件
    
    /// 返回按钮
    private let backButton_Hush = BackButton_Hush()
    
    /// 顶部渐变头部容器
    private let headerView_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.clipsToBounds = true
        view_Hush.layer.cornerRadius = 0
        return view_Hush
    }()
    
    /// 顶部渐变图层
    private var headerGradientLayer_Hush: CAGradientLayer?
    
    /// 页面标题标签
    private let titleLabel_Hush: UILabel = {
        let label_Hush = UILabel()
        label_Hush.text = "Edit Profile"
        label_Hush.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        label_Hush.textColor = .white
        return label_Hush
    }()
    
    /// 头像外圈光晕视图
    private let avatarRing_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = .clear
        view_Hush.layer.cornerRadius = 46
        view_Hush.layer.borderWidth = 3
        view_Hush.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        return view_Hush
    }()
    
    /// 登录用户头像组件（可点击）
    private let avatarView_Hush = CurrentUserAvatarView_Hush(frame: .zero)
    
    /// 相机图标角标（提示可点击）
    private let cameraIcon_Hush: UIView = {
        let container_Hush = UIView()
        container_Hush.backgroundColor = ColorConfig_Hush.primaryGradientStart_Hush
        container_Hush.layer.cornerRadius = 14
        container_Hush.layer.borderWidth = 2
        container_Hush.layer.borderColor = UIColor.white.cgColor
        let iv_Hush = UIImageView()
        iv_Hush.image = UIImage(systemName: "camera.fill")
        iv_Hush.tintColor = .white
        iv_Hush.contentMode = .scaleAspectFit
        container_Hush.addSubview(iv_Hush)
        iv_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(14)
        }
        return container_Hush
    }()
    
    /// 头像提示标签
    private let avatarHintLabel_Hush: UILabel = {
        let label_Hush = UILabel()
        label_Hush.text = "Tap to change photo"
        label_Hush.font = UIFont.systemFont(ofSize: 12)
        label_Hush.textColor = UIColor.white.withAlphaComponent(0.85)
        label_Hush.textAlignment = .center
        return label_Hush
    }()
    
    /// 主滚动容器
    private let scrollView_Hush: UIScrollView = {
        let sv_Hush = UIScrollView()
        sv_Hush.showsVerticalScrollIndicator = false
        sv_Hush.alwaysBounceVertical = true
        return sv_Hush
    }()
    
    /// 内容容器
    private let contentView_Hush: UIView = {
        return UIView()
    }()
    
    /// 表单卡片
    private let formCard_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = ColorConfig_Hush.cardBackground_Hush
        view_Hush.layer.cornerRadius = 20
        view_Hush.layer.shadowColor = ColorConfig_Hush.shadowColor_Hush.cgColor
        view_Hush.layer.shadowOffset = CGSize(width: 0, height: 4)
        view_Hush.layer.shadowRadius = 12
        view_Hush.layer.shadowOpacity = 1.0
        return view_Hush
    }()
    
    // MARK: - 用户名区域
    
    /// 用户名区分段标题
    private let nameSectionLabel_Hush: UILabel = {
        let label_Hush = UILabel()
        label_Hush.text = "Username"
        label_Hush.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label_Hush.textColor = ColorConfig_Hush.textSecondary_Hush
        return label_Hush
    }()
    
    /// 用户名输入框容器
    private let nameContainer_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        view_Hush.layer.cornerRadius = 12
        view_Hush.layer.borderWidth = 1
        view_Hush.layer.borderColor = ColorConfig_Hush.border_Hush.cgColor
        return view_Hush
    }()
    
    /// 用户名输入框
    private let nameField_Hush: UITextField = {
        let tf_Hush = UITextField()
        tf_Hush.placeholder = "Enter your username"
        tf_Hush.font = UIFont.systemFont(ofSize: 15)
        tf_Hush.textColor = ColorConfig_Hush.textPrimary_Hush
        tf_Hush.autocorrectionType = .no
        tf_Hush.autocapitalizationType = .none
        tf_Hush.returnKeyType = .next
        tf_Hush.backgroundColor = .clear
        return tf_Hush
    }()
    
    // MARK: - 简介区域
    
    /// 简介分段标题
    private let introduceSectionLabel_Hush: UILabel = {
        let label_Hush = UILabel()
        label_Hush.text = "Bio"
        label_Hush.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label_Hush.textColor = ColorConfig_Hush.textSecondary_Hush
        return label_Hush
    }()
    
    /// 简介输入容器
    private let introduceContainer_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        view_Hush.layer.cornerRadius = 12
        view_Hush.layer.borderWidth = 1
        view_Hush.layer.borderColor = ColorConfig_Hush.border_Hush.cgColor
        return view_Hush
    }()
    
    /// 简介多行输入框
    private let introduceTextView_Hush: UITextView = {
        let tv_Hush = UITextView()
        tv_Hush.font = UIFont.systemFont(ofSize: 15)
        tv_Hush.textColor = ColorConfig_Hush.textPrimary_Hush
        tv_Hush.backgroundColor = .clear
        tv_Hush.isScrollEnabled = false
        tv_Hush.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        tv_Hush.returnKeyType = .done
        return tv_Hush
    }()
    
    /// 简介占位符标签（UITextView 原生不支持 placeholder）
    private let introducePlaceholder_Hush: UILabel = {
        let label_Hush = UILabel()
        label_Hush.text = "Tell us about yourself..."
        label_Hush.font = UIFont.systemFont(ofSize: 15)
        label_Hush.textColor = ColorConfig_Hush.textPlaceholder_Hush
        label_Hush.numberOfLines = 0
        return label_Hush
    }()
    
    // MARK: - 确认按钮
    
    /// 确认修改按钮
    private let confirmButton_Hush: UIButton = {
        let btn_Hush = UIButton(type: .custom)
        btn_Hush.setTitle("Save Changes", for: .normal)
        btn_Hush.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn_Hush.setTitleColor(.white, for: .normal)
        btn_Hush.layer.cornerRadius = 14
        btn_Hush.layer.masksToBounds = true
        return btn_Hush
    }()
    
    /// 确认按钮渐变图层
    private var confirmGradientLayer_Hush: CAGradientLayer?
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Hush()
        setupActions_Hush()
        setupKeyboardDismiss_Hush()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        // 每次出现时重新加载当前用户数据
        loadUserData_Hush()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer_Hush?.frame = headerView_Hush.bounds
        if confirmGradientLayer_Hush == nil && confirmButton_Hush.bounds.width > 0 {
            let gradient_Hush = UIColor.createPrimaryGradientLayer_Hush(frame_Hush: confirmButton_Hush.bounds)
            confirmGradientLayer_Hush = gradient_Hush
            confirmButton_Hush.layer.insertSublayer(gradient_Hush, at: 0)
        } else {
            confirmGradientLayer_Hush?.frame = confirmButton_Hush.bounds
        }
    }
    
    // MARK: - 加载用户数据
    
    /// 从 UserViewModel 加载当前用户数据填充到输入框
    private func loadUserData_Hush() {
        let currentUser_Hush = UserViewModel_Hush.shared_Hush.getCurrentUser_Hush()
        
        // 填充用户名
        let name_Hush = currentUser_Hush.userName_Hush ?? ""
        nameField_Hush.text = name_Hush
        _originalName_Hush = name_Hush
        
        // 从 PrewUserModel 获取简介（LoginUserModel 不含 introduce 字段）
        let prewUser_Hush = UserViewModel_Hush.shared_Hush.getUserById_Hush(
            userId_hush: currentUser_Hush.userId_Hush ?? 0
        )
        let introduce_Hush = prewUser_Hush.userIntroduce_Hush ?? ""
        introduceTextView_Hush.text = introduce_Hush.isEmpty ? "" : introduce_Hush
        _originalIntroduce_Hush = introduce_Hush
        
        // 更新占位符可见性
        introducePlaceholder_Hush.isHidden = !introduceTextView_Hush.text.isEmpty
        
        // 保存原始头像路径
        _originalHead_Hush = currentUser_Hush.userHead_Hush
        
        // 刷新头像视图
        if let userId_Hush = currentUser_Hush.userId_Hush {
            avatarView_Hush.configure_Hush(userId_Hush: userId_Hush)
        }
    }
    
    // MARK: - UI 搭建
    
    private func setupUI_Hush() {
        view.backgroundColor = ColorConfig_Hush.backgroundPrimary_Hush
        
        setupHeaderView_Hush()
        setupScrollContent_Hush()
        setupEntryAnimation_Hush()
    }
    
    /// 搭建顶部渐变头部（含返回按钮和头像）
    private func setupHeaderView_Hush() {
        view.addSubview(headerView_Hush)
        headerView_Hush.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(260)
        }
        
        // 渐变图层
        let gradient_Hush = UIColor.createPrimaryGradientLayer_Hush(frame_Hush: .zero)
        gradient_Hush.cornerRadius = 0
        headerGradientLayer_Hush = gradient_Hush
        headerView_Hush.layer.insertSublayer(gradient_Hush, at: 0)
        headerView_Hush.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Hush.layer.cornerRadius = 32
        
        // 返回按钮
        view.addSubview(backButton_Hush)
        backButton_Hush.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        backButton_Hush.onTapped_Hush = { [weak self] in
            Navigation_Hush.pop_Hush(from: self)
        }
        
        // 标题
        headerView_Hush.addSubview(titleLabel_Hush)
        titleLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(18)
            make.centerX.equalToSuperview()
        }
        
        // 头像外圈
        headerView_Hush.addSubview(avatarRing_Hush)
        avatarRing_Hush.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel_Hush.snp.bottom).offset(20)
            make.width.height.equalTo(92)
        }
        
        // 头像视图
        avatarRing_Hush.addSubview(avatarView_Hush)
        avatarView_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(82)
        }
        
        // 相机角标
        headerView_Hush.addSubview(cameraIcon_Hush)
        cameraIcon_Hush.snp.makeConstraints { make in
            make.trailing.equalTo(avatarRing_Hush.snp.trailing)
            make.bottom.equalTo(avatarRing_Hush.snp.bottom)
            make.width.height.equalTo(28)
        }
        
        // 头像提示
        headerView_Hush.addSubview(avatarHintLabel_Hush)
        avatarHintLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(avatarRing_Hush.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    /// 搭建滚动内容区
    private func setupScrollContent_Hush() {
        view.addSubview(scrollView_Hush)
        scrollView_Hush.addSubview(contentView_Hush)
        
        scrollView_Hush.snp.makeConstraints { make in
            make.top.equalTo(headerView_Hush.snp.bottom).offset(-12)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Hush.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // 表单卡片
        contentView_Hush.addSubview(formCard_Hush)
        formCard_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        setupFormContent_Hush()
        
        // 确认按钮
        contentView_Hush.addSubview(confirmButton_Hush)
        confirmButton_Hush.snp.makeConstraints { make in
            make.top.equalTo(formCard_Hush.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(52)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
    
    /// 搭建表单内容
    private func setupFormContent_Hush() {
        // 用户名区域
        formCard_Hush.addSubview(nameSectionLabel_Hush)
        nameSectionLabel_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(16)
        }
        formCard_Hush.addSubview(nameContainer_Hush)
        nameContainer_Hush.snp.makeConstraints { make in
            make.top.equalTo(nameSectionLabel_Hush.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(48)
        }
        nameContainer_Hush.addSubview(nameField_Hush)
        nameField_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
        nameField_Hush.placeHolderTextColor_Hush(ColorConfig_Hush.textPlaceholder_Hush)
        
        // 分割线
        let divider_Hush = UIView()
        divider_Hush.backgroundColor = ColorConfig_Hush.divider_Hush
        formCard_Hush.addSubview(divider_Hush)
        divider_Hush.snp.makeConstraints { make in
            make.top.equalTo(nameContainer_Hush.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(0.5)
        }
        
        // 简介区域
        formCard_Hush.addSubview(introduceSectionLabel_Hush)
        introduceSectionLabel_Hush.snp.makeConstraints { make in
            make.top.equalTo(divider_Hush.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        formCard_Hush.addSubview(introduceContainer_Hush)
        introduceContainer_Hush.snp.makeConstraints { make in
            make.top.equalTo(introduceSectionLabel_Hush.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-20)
            make.height.greaterThanOrEqualTo(100)
        }
        
        // 简介 TextView
        introduceContainer_Hush.addSubview(introduceTextView_Hush)
        introduceTextView_Hush.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        introduceTextView_Hush.delegate = self
        
        // 占位符标签
        introduceContainer_Hush.addSubview(introducePlaceholder_Hush)
        introducePlaceholder_Hush.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    
    // MARK: - 入场动画
    
    private func setupEntryAnimation_Hush() {
        formCard_Hush.alpha = 0
        formCard_Hush.transform = CGAffineTransform(translationX: 0, y: 24)
        confirmButton_Hush.alpha = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.animate(
                withDuration: AnimationConfig_Hush.durationSpring_Hush,
                delay: 0,
                usingSpringWithDamping: AnimationConfig_Hush.springDampingNormal_Hush,
                initialSpringVelocity: AnimationConfig_Hush.springVelocity_Hush,
                options: [.curveEaseOut],
                animations: {
                    self.formCard_Hush.alpha = 1
                    self.formCard_Hush.transform = .identity
                }
            )
            self.confirmButton_Hush.animateFadeIn_Hush(duration_Hush: 0.4, delay_Hush: 0.2)
        }
    }
    
    // MARK: - 事件绑定
    
    private func setupActions_Hush() {
        // 头像点击（通过 CurrentUserAvatarView_Hush 的 onTapped_Hush 回调）
        avatarView_Hush.onTapped_Hush = { [weak self] in
            self?.handleAvatarTap_Hush()
        }
        confirmButton_Hush.addTarget(self, action: #selector(handleConfirm_Hush), for: .touchUpInside)
        nameField_Hush.delegate = self
    }
    
    private func setupKeyboardDismiss_Hush() {
        let tap_Hush = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap_Hush.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Hush)
    }
    
    // MARK: - 头像点击处理
    
    /// 点击头像，从相册选取图片
    private func handleAvatarTap_Hush() {
        MediaPickerHelper_Hush.pickImage_Hush(from: self) { [weak self] image_Hush in
            guard let self_Hush = self, let image_Hush = image_Hush else { return }
            self_Hush._selectedAvatarImage_Hush = image_Hush
            // 实时更新头像预览
            self_Hush.avatarView_Hush.imageView_Hush.image = image_Hush
            self_Hush.avatarView_Hush.imageView_Hush.contentMode = .scaleAspectFill
            // 提示已选择
            UIView.animate(withDuration: 0.2) {
                self_Hush.avatarRing_Hush.layer.borderColor = ColorConfig_Hush.secondaryGradientStart_Hush.cgColor
            }
        }
    }
    
    // MARK: - 确认修改
    
    /// 确认修改按钮点击
    /// 逻辑：校验登录状态 → 逐项比较原始值 → 有变更才调用对应 VM 方法 → pop 返回
    @objc private func handleConfirm_Hush() {
        view.endEditing(true)
        
        // 校验登录状态
        guard UserViewModel_Hush.shared_Hush.isLoggedIn_Hush else {
            Utils_Hush.showWarning_Hush(message_Hush: "Please sign in first")
            return
        }
        
        let newName_Hush = nameField_Hush.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let newIntroduce_Hush = introduceTextView_Hush.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var hasChanges_Hush = false
        
        // 用户名有修改
        if !newName_Hush.isEmpty && newName_Hush != _originalName_Hush {
            Task { @MainActor in
                UserViewModel_Hush.shared_Hush.updateName_Hush(userName_hush: newName_Hush)
            }
            hasChanges_Hush = true
        }
        
        // 简介有修改
        if newIntroduce_Hush != _originalIntroduce_Hush {
            Task { @MainActor in
                UserViewModel_Hush.shared_Hush.updateIntroduce_Hush(introduce_hush: newIntroduce_Hush)
            }
            hasChanges_Hush = true
        }
        
        // 头像有修改：将图片存储到临时文件，传入路径
        if let selectedImage_Hush = _selectedAvatarImage_Hush {
            if let savedPath_Hush = saveImageToTemp_Hush(image: selectedImage_Hush) {
                Task { @MainActor in
                    UserViewModel_Hush.shared_Hush.updateHead_Hush(headUrl_hush: savedPath_Hush)
                }
                hasChanges_Hush = true
            }
        }
        
        // 按钮动画反馈
        confirmButton_Hush.animatePressDown_Hush {
            self.confirmButton_Hush.animatePressUp_Hush {
                if hasChanges_Hush {
                    // 有修改则短暂延迟后 pop 返回
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        Navigation_Hush.pop_Hush(from: self)
                    }
                } else {
                    Utils_Hush.showInfo_Hush(message_Hush: "No changes made")
                }
            }
        }
    }
    
    // MARK: - 辅助方法
    
    /// 将图片保存到临时目录，返回文件路径
    /// - Parameter image: 要保存的图片
    /// - Returns: 临时文件路径（失败返回 nil）
    private func saveImageToTemp_Hush(image: UIImage) -> String? {
        guard let data_Hush = image.jpegData(compressionQuality: 0.85) else { return nil }
        let fileName_Hush = "avatar_\(Int(Date().timeIntervalSince1970)).jpg"
        let tempURL_Hush = FileManager.default.temporaryDirectory.appendingPathComponent(fileName_Hush)
        do {
            try data_Hush.write(to: tempURL_Hush)
            return tempURL_Hush.path
        } catch {
            print("❌ 头像图片保存失败：\(error)")
            return nil
        }
    }
}

// MARK: - UITextFieldDelegate

extension EditInfo_Hush: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        introduceTextView_Hush.becomeFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: AnimationConfig_Hush.durationFast_Hush) {
            self.nameContainer_Hush.layer.borderColor = ColorConfig_Hush.primaryGradientStart_Hush.cgColor
            self.nameContainer_Hush.layer.borderWidth = 1.5
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: AnimationConfig_Hush.durationFast_Hush) {
            self.nameContainer_Hush.layer.borderColor = ColorConfig_Hush.border_Hush.cgColor
            self.nameContainer_Hush.layer.borderWidth = 1.0
        }
    }
}

// MARK: - UITextViewDelegate

extension EditInfo_Hush: UITextViewDelegate {
    
    /// 简介输入时更新占位符可见性
    func textViewDidChange(_ textView: UITextView) {
        introducePlaceholder_Hush.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: AnimationConfig_Hush.durationFast_Hush) {
            self.introduceContainer_Hush.layer.borderColor = ColorConfig_Hush.primaryGradientStart_Hush.cgColor
            self.introduceContainer_Hush.layer.borderWidth = 1.5
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: AnimationConfig_Hush.durationFast_Hush) {
            self.introduceContainer_Hush.layer.borderColor = ColorConfig_Hush.border_Hush.cgColor
            self.introduceContainer_Hush.layer.borderWidth = 1.0
        }
    }
    
    /// Return 键关闭键盘
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
