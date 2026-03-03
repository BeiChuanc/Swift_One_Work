import Foundation
import UIKit
import SnapKit

// MARK: 修改我的信息

/// 修改我的信息页面
/// 功能：编辑用户头像、用户名、简介
/// 设计：现代化表单设计，支持从相册选择头像
class EditInfo_Glasspaint: UIViewController {
    
    // MARK: - 数据属性
    
    /// 原始用户数据
    private var originalUser_Glasspaint: LoginUserModel_Glasspaint?
    
    /// 新的头像图片
    private var newAvatarImage_Glasspaint: UIImage?
    
    // MARK: - UI组件
    
    private let scrollView_Glasspaint = UIScrollView()
    private let contentView_Glasspaint = UIView()
    
    // 背景装饰
    private let backgroundGradientLayer_Glasspaint = CAGradientLayer()
    private let decorCircle_Glasspaint = UIView()
    
    // 头像区域
    private let avatarContainer_Glasspaint = UIView()
    private let avatarView_Glasspaint = CurrentUserAvatarView_Glasspaint()
    private let avatarEditButton_Glasspaint = UIButton(type: .system)
    private let avatarHintLabel_Glasspaint = UILabel()
    
    // 表单区域
    private let formContainer_Glasspaint = UIView()
    private let formGradientLayer_Glasspaint = CAGradientLayer()
    
    // 用户名输入
    private let nameIconView_Glasspaint = UIImageView()
    private let nameTextField_Glasspaint = UITextField()
    private let nameDivider_Glasspaint = UIView()
    
    // 简介输入
    private let bioIconView_Glasspaint = UIImageView()
    private let bioTextView_Glasspaint = UITextView()
    private let bioPlaceholder_Glasspaint = UILabel()
    private let bioCharCountLabel_Glasspaint = UILabel()
    
    // 确认按钮
    private let confirmButton_Glasspaint = UIButton(type: .system)
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Glasspaint()
        loadData_Glasspaint()
        setupKeyboardObservers_Glasspaint()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer_Glasspaint.frame = view.bounds
        formGradientLayer_Glasspaint.frame = formContainer_Glasspaint.bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        view.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        title = "Edit Profile"
        
        // 设置返回按钮
        setupNavigationBar_Glasspaint()
        
        // 背景渐变
        setupBackgroundGradient_Glasspaint()
        
        // 装饰元素
        setupDecorationElements_Glasspaint()
        
        // 滚动视图
        view.addSubview(scrollView_Glasspaint)
        scrollView_Glasspaint.showsVerticalScrollIndicator = false
        scrollView_Glasspaint.keyboardDismissMode = .interactive
        scrollView_Glasspaint.addSubview(contentView_Glasspaint)
        
        // 头像区域
        contentView_Glasspaint.addSubview(avatarContainer_Glasspaint)
        setupAvatarSection_Glasspaint()
        
        // 表单区域
        contentView_Glasspaint.addSubview(formContainer_Glasspaint)
        setupFormSection_Glasspaint()
        
        // 确认按钮
        contentView_Glasspaint.addSubview(confirmButton_Glasspaint)
        setupConfirmButton_Glasspaint()
        
        // 设置约束
        setupConstraints_Glasspaint()
        
        // 添加点击手势关闭键盘
        let tapGesture_glasspaint = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Glasspaint))
        view.addGestureRecognizer(tapGesture_glasspaint)
    }
    
    /// 设置导航栏
    private func setupNavigationBar_Glasspaint() {
        let backButton_glasspaint = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(handleBackTap_Glasspaint)
        )
        backButton_glasspaint.tintColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        navigationItem.leftBarButtonItem = backButton_glasspaint
    }
    
    /// 设置背景渐变
    private func setupBackgroundGradient_Glasspaint() {
        backgroundGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.backgroundPrimary_Glasspaint.cgColor,
            UIColor(hexstring_Glasspaint: "#F0F4F8").cgColor,
            ColorConfig_Glasspaint.backgroundSecondary_Glasspaint.cgColor
        ]
        backgroundGradientLayer_Glasspaint.locations = [0.0, 0.5, 1.0]
        backgroundGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(backgroundGradientLayer_Glasspaint, at: 0)
    }
    
    /// 设置装饰元素
    private func setupDecorationElements_Glasspaint() {
        view.addSubview(decorCircle_Glasspaint)
        decorCircle_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.08)
        decorCircle_Glasspaint.layer.cornerRadius = 120
        
        decorCircle_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-60)
            make.right.equalToSuperview().offset(60)
            make.width.height.equalTo(240)
        }
        
        // 旋转动画
        let rotation_glasspaint = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation_glasspaint.fromValue = 0
        rotation_glasspaint.toValue = Double.pi * 2
        rotation_glasspaint.duration = 60
        rotation_glasspaint.repeatCount = .infinity
        decorCircle_Glasspaint.layer.add(rotation_glasspaint, forKey: "rotation")
    }
    
    /// 设置头像区域
    private func setupAvatarSection_Glasspaint() {
        avatarContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        avatarContainer_Glasspaint.layer.cornerRadius = 20
        avatarContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        avatarContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        avatarContainer_Glasspaint.layer.shadowRadius = 12
        avatarContainer_Glasspaint.layer.shadowOpacity = 0.1
        
        // 头像
        avatarContainer_Glasspaint.addSubview(avatarView_Glasspaint)
        avatarView_Glasspaint.layer.masksToBounds = true
        avatarView_Glasspaint.layer.borderWidth = 4
        avatarView_Glasspaint.layer.borderColor = UIColor.white.cgColor
        
        // 确保头像内部图片视图的contentMode正确
        avatarView_Glasspaint.imageView_Glasspaint.contentMode = .scaleAspectFill
        avatarView_Glasspaint.imageView_Glasspaint.clipsToBounds = true
        
        // 编辑按钮
        avatarContainer_Glasspaint.addSubview(avatarEditButton_Glasspaint)
        let editConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        avatarEditButton_Glasspaint.setImage(UIImage(systemName: "camera.circle.fill", withConfiguration: editConfig_glasspaint), for: .normal)
        avatarEditButton_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        avatarEditButton_Glasspaint.backgroundColor = .white
        avatarEditButton_Glasspaint.layer.cornerRadius = 24
        avatarEditButton_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        avatarEditButton_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        avatarEditButton_Glasspaint.layer.shadowRadius = 6
        avatarEditButton_Glasspaint.layer.shadowOpacity = 0.2
        avatarEditButton_Glasspaint.addTarget(self, action: #selector(handleAvatarEditTap_Glasspaint), for: .touchUpInside)
        
        // 提示文本
        avatarContainer_Glasspaint.addSubview(avatarHintLabel_Glasspaint)
        avatarHintLabel_Glasspaint.text = "Tap to change avatar"
        avatarHintLabel_Glasspaint.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        avatarHintLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        avatarHintLabel_Glasspaint.textAlignment = .center
        
        // 布局
        avatarView_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(24)
            make.width.height.equalTo(100)
        }
        
        avatarEditButton_Glasspaint.snp.makeConstraints { make in
            make.right.bottom.equalTo(avatarView_Glasspaint).offset(4)
            make.width.height.equalTo(48)
        }
        
        avatarHintLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Glasspaint.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    /// 设置表单区域
    private func setupFormSection_Glasspaint() {
        formContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        formContainer_Glasspaint.layer.cornerRadius = 20
        formContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        formContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        formContainer_Glasspaint.layer.shadowRadius = 12
        formContainer_Glasspaint.layer.shadowOpacity = 0.1
        
        // 渐变背景
        formGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.05).cgColor,
            ColorConfig_Glasspaint.cardBackground_Glasspaint.cgColor
        ]
        formGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        formGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        formGradientLayer_Glasspaint.cornerRadius = 20
        formContainer_Glasspaint.layer.insertSublayer(formGradientLayer_Glasspaint, at: 0)
        
        // 用户名图标
        formContainer_Glasspaint.addSubview(nameIconView_Glasspaint)
        let nameIconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        nameIconView_Glasspaint.image = UIImage(systemName: "person.fill", withConfiguration: nameIconConfig_glasspaint)
        nameIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        nameIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 用户名输入框
        formContainer_Glasspaint.addSubview(nameTextField_Glasspaint)
        nameTextField_Glasspaint.placeholder = "Enter your name"
        nameTextField_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        nameTextField_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        nameTextField_Glasspaint.delegate = self
        
        // 分隔线
        formContainer_Glasspaint.addSubview(nameDivider_Glasspaint)
        nameDivider_Glasspaint.backgroundColor = ColorConfig_Glasspaint.textSecondary_Glasspaint.withAlphaComponent(0.15)
        
        // 简介图标
        formContainer_Glasspaint.addSubview(bioIconView_Glasspaint)
        let bioIconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        bioIconView_Glasspaint.image = UIImage(systemName: "text.alignleft", withConfiguration: bioIconConfig_glasspaint)
        bioIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        bioIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 简介输入框
        formContainer_Glasspaint.addSubview(bioTextView_Glasspaint)
        bioTextView_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        bioTextView_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        bioTextView_Glasspaint.backgroundColor = .clear
        bioTextView_Glasspaint.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        bioTextView_Glasspaint.delegate = self
        
        // 简介占位符
        formContainer_Glasspaint.addSubview(bioPlaceholder_Glasspaint)
        bioPlaceholder_Glasspaint.text = "Tell others about yourself..."
        bioPlaceholder_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        bioPlaceholder_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint.withAlphaComponent(0.5)
        
        // 字符计数
        formContainer_Glasspaint.addSubview(bioCharCountLabel_Glasspaint)
        bioCharCountLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        bioCharCountLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        bioCharCountLabel_Glasspaint.text = "0/200"
    }
    
    /// 设置确认按钮
    private func setupConfirmButton_Glasspaint() {
        confirmButton_Glasspaint.setTitle("Save Changes", for: .normal)
        confirmButton_Glasspaint.setTitleColor(.white, for: .normal)
        confirmButton_Glasspaint.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        confirmButton_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        confirmButton_Glasspaint.layer.cornerRadius = 24
        confirmButton_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        confirmButton_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        confirmButton_Glasspaint.layer.shadowRadius = 12
        confirmButton_Glasspaint.layer.shadowOpacity = 0.4
        confirmButton_Glasspaint.addTarget(self, action: #selector(handleConfirmTap_Glasspaint), for: .touchUpInside)
    }
    
    /// 设置约束
    private func setupConstraints_Glasspaint() {
        scrollView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Glasspaint)
        }
        
        // 头像区域
        avatarContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        avatarView_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(28)
            make.width.height.equalTo(100)
        }
        
        avatarEditButton_Glasspaint.snp.makeConstraints { make in
            make.right.bottom.equalTo(avatarView_Glasspaint).offset(4)
            make.width.height.equalTo(48)
        }
        
        avatarHintLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Glasspaint.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // 表单区域
        formContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(avatarContainer_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        nameIconView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(24)
            make.width.height.equalTo(24)
        }
        
        nameTextField_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(nameIconView_Glasspaint.snp.right).offset(16)
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalTo(nameIconView_Glasspaint)
            make.height.equalTo(44)
        }
        
        nameDivider_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(nameTextField_Glasspaint.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        
        bioIconView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(nameDivider_Glasspaint.snp.bottom).offset(24)
            make.width.height.equalTo(24)
        }
        
        bioTextView_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(bioIconView_Glasspaint.snp.right).offset(8)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(nameDivider_Glasspaint.snp.bottom).offset(12)
            make.height.equalTo(120)
        }
        
        bioPlaceholder_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(bioTextView_Glasspaint).offset(13)
            make.top.equalTo(bioTextView_Glasspaint).offset(12)
        }
        
        bioCharCountLabel_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(bioTextView_Glasspaint.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // 确认按钮
        confirmButton_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(formContainer_Glasspaint.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(40)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
    
    // MARK: - 数据加载
    
    /// 加载数据
    private func loadData_Glasspaint() {
        originalUser_Glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getCurrentUser_Glasspaint()
        
        guard let user_glasspaint = originalUser_Glasspaint else { return }
        
        // 填充数据
        nameTextField_Glasspaint.text = user_glasspaint.userName_Glasspaint
        bioTextView_Glasspaint.text = user_glasspaint.userIntroduce_Glasspaint
        
        // 确保头像正确显示
        avatarView_Glasspaint.imageView_Glasspaint.contentMode = .scaleAspectFill
        avatarView_Glasspaint.imageView_Glasspaint.clipsToBounds = true
        
        // 更新占位符和字符计数
        updateBioPlaceholder_Glasspaint()
        updateBioCharCount_Glasspaint()
    }
    
    /// 更新简介占位符
    private func updateBioPlaceholder_Glasspaint() {
        bioPlaceholder_Glasspaint.isHidden = !bioTextView_Glasspaint.text.isEmpty
    }
    
    /// 更新字符计数
    private func updateBioCharCount_Glasspaint() {
        let count_glasspaint = bioTextView_Glasspaint.text.count
        bioCharCountLabel_Glasspaint.text = "\(count_glasspaint)/200"
        bioCharCountLabel_Glasspaint.textColor = count_glasspaint > 200 ? .systemRed : ColorConfig_Glasspaint.textSecondary_Glasspaint
    }
    
    // MARK: - 键盘处理
    
    /// 设置键盘观察者
    private func setupKeyboardObservers_Glasspaint() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Glasspaint),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Glasspaint),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    /// 键盘显示
    @objc private func keyboardWillShow_Glasspaint(_ notification: Notification) {
        guard let keyboardFrame_glasspaint = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let contentInset_glasspaint = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame_glasspaint.height, right: 0)
        scrollView_Glasspaint.contentInset = contentInset_glasspaint
        scrollView_Glasspaint.scrollIndicatorInsets = contentInset_glasspaint
    }
    
    /// 键盘隐藏
    @objc private func keyboardWillHide_Glasspaint(_ notification: Notification) {
        scrollView_Glasspaint.contentInset = .zero
        scrollView_Glasspaint.scrollIndicatorInsets = .zero
    }
    
    /// 关闭键盘
    @objc private func dismissKeyboard_Glasspaint() {
        view.endEditing(true)
    }
    
    // MARK: - 事件处理
    
    /// 返回
    @objc private func handleBackTap_Glasspaint() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 编辑头像
    @objc private func handleAvatarEditTap_Glasspaint() {
        MediaPickerHelper_Glasspaint.shared_Glasspaint.showPicker_Glasspaint(
            from: self,
            mediaType_Glasspaint: .photo_Glasspaint,
            selectionLimit_Glasspaint: 1,
            completion_Glasspaint: { [weak self] result_glasspaint in
                switch result_glasspaint {
                case .photo_Glasspaint(let image_glasspaint):
                    self?.newAvatarImage_Glasspaint = image_glasspaint
                    // 设置头像图片并确保铺满
                    self?.avatarView_Glasspaint.imageView_Glasspaint.image = image_glasspaint
                    self?.avatarView_Glasspaint.imageView_Glasspaint.contentMode = .scaleAspectFill
                    self?.avatarView_Glasspaint.imageView_Glasspaint.clipsToBounds = true
                case .video_Glasspaint:
                    break
                case .cancelled_Glasspaint:
                    break
                }
            }
        )
    }
    
    /// 确认修改
    @objc private func handleConfirmTap_Glasspaint() {
        // 检查登录状态
        if !UserViewModel_Glasspaint.shared_Glasspaint.isLoggedIn_Glasspaint {
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 1.5秒
                Navigation_Glasspaint.toLogin_Glasspaint(style_glasspaint: .present_glasspaint)
            }
            return
        }
        
        // 获取输入数据
        let newName_glasspaint = nameTextField_Glasspaint.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let newBio_glasspaint = bioTextView_Glasspaint.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // 验证
        if newName_glasspaint.isEmpty {
            Utils_Glasspaint.showError_Glasspaint(message_Glasspaint: "Name cannot be empty")
            return
        }
        
        if newBio_glasspaint.count > 200 {
            Utils_Glasspaint.showError_Glasspaint(message_Glasspaint: "Bio is too long (max 200 characters)")
            return
        }
        
        // 检查是否有修改
        guard let originalUser_glasspaint = originalUser_Glasspaint else { return }
        
        let nameChanged_glasspaint = newName_glasspaint != originalUser_glasspaint.userName_Glasspaint
        let bioChanged_glasspaint = newBio_glasspaint != (originalUser_glasspaint.userIntroduce_Glasspaint ?? "")
        let avatarChanged_glasspaint = newAvatarImage_Glasspaint != nil
        
        if !nameChanged_glasspaint && !bioChanged_glasspaint && !avatarChanged_glasspaint {
            Utils_Glasspaint.showInfo_Glasspaint(message_Glasspaint: "No changes to save")
            return
        }
        
        // 执行保存
        performSave_Glasspaint(name: newName_glasspaint, bio: newBio_glasspaint)
    }
    
    /// 执行保存
    /// 参数：
    /// - name: 新的用户名
    /// - bio: 新的简介
    private func performSave_Glasspaint(name: String, bio: String) {
        Utils_Glasspaint.showLoading_Glasspaint(message_Glasspaint: "Saving...")
        
        // 模拟保存延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            
            // 更新用户数据
            let user_glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getCurrentUser_Glasspaint()
            user_glasspaint.userName_Glasspaint = name
            user_glasspaint.userIntroduce_Glasspaint = bio
            
            // 保存头像
            if let newAvatar_glasspaint = self.newAvatarImage_Glasspaint {
                self.saveAvatarImage_Glasspaint(image_glasspaint: newAvatar_glasspaint, user_glasspaint: user_glasspaint)
            }
            
            // 通知状态变化
            UserViewModel_Glasspaint.shared_Glasspaint.notifyStateChange_Glasspaint()
            
            Utils_Glasspaint.dismissLoading_Glasspaint()
            Utils_Glasspaint.showSuccess_Glasspaint(message_Glasspaint: "Profile updated successfully")
            
            // 返回上一页
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    /// 保存头像图片到本地
    /// 参数：
    /// - image_glasspaint: 要保存的图片
    /// - user_glasspaint: 用户模型
    private func saveAvatarImage_Glasspaint(image_glasspaint: UIImage, user_glasspaint: LoginUserModel_Glasspaint) {
        // 获取Documents目录
        guard let documentsDirectory_glasspaint = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("⚠️ 无法获取Documents目录")
            return
        }
        
        // 创建Avatars文件夹
        let avatarsDirectory_glasspaint = documentsDirectory_glasspaint.appendingPathComponent("Avatars", isDirectory: true)
        if !FileManager.default.fileExists(atPath: avatarsDirectory_glasspaint.path) {
            try? FileManager.default.createDirectory(at: avatarsDirectory_glasspaint, withIntermediateDirectories: true, attributes: nil)
        }
        
        // 生成文件名
        let userId_glasspaint = user_glasspaint.userId_Glasspaint ?? 0
        let fileName_glasspaint = "avatar_\(userId_glasspaint)_\(Date().timeIntervalSince1970).jpg"
        let fileURL_glasspaint = avatarsDirectory_glasspaint.appendingPathComponent(fileName_glasspaint)
        
        // 保存图片
        if let imageData_glasspaint = image_glasspaint.jpegData(compressionQuality: 0.8) {
            do {
                try imageData_glasspaint.write(to: fileURL_glasspaint)
                // 更新用户头像路径
                user_glasspaint.userHead_Glasspaint = fileURL_glasspaint.path
                print("✅ 头像保存成功: \(fileURL_glasspaint.path)")
                
                // 立即刷新当前页面的头像显示
                DispatchQueue.main.async { [weak self] in
                    self?.avatarView_Glasspaint.loadAvatarFromPath_Glasspaint(
                        path_Glasspaint: fileURL_glasspaint.path,
                        defaultColor_Glasspaint: ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
                    )
                }
            } catch {
                print("⚠️ 头像保存失败: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension EditInfo_Glasspaint: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 限制用户名长度
        let currentText_glasspaint = textField.text ?? ""
        guard let stringRange_glasspaint = Range(range, in: currentText_glasspaint) else { return false }
        let updatedText_glasspaint = currentText_glasspaint.replacingCharacters(in: stringRange_glasspaint, with: string)
        return updatedText_glasspaint.count <= 30
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension EditInfo_Glasspaint: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        updateBioPlaceholder_Glasspaint()
        updateBioCharCount_Glasspaint()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText_glasspaint = textView.text ?? ""
        guard let stringRange_glasspaint = Range(range, in: currentText_glasspaint) else { return false }
        let updatedText_glasspaint = currentText_glasspaint.replacingCharacters(in: stringRange_glasspaint, with: text)
        return updatedText_glasspaint.count <= 200
    }
}
