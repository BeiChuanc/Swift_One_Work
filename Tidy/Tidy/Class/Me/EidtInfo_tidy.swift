import Foundation
import UIKit
import SnapKit

// MARK: - 修改个人信息页面

/// 修改个人信息页面
/// 功能：允许用户修改头像（从相册选取）、用户名、个人简介
/// 设计：透明导航栏 + 渐变头部，头像锚定至 safeAreaLayoutGuide 下方确保不与导航栏重叠
///       表单字段带前缀图标，底部固定保存按钮
/// 逻辑：仅更新发生变化的字段；未登录时保存时跳转登录
class EditInfo_Tidy: UIViewController {

    // MARK: - 私有属性

    /// 用户选取的新头像（nil 表示未修改）
    private var selectedImage_Tidy: UIImage?

    /// 原始用户名（用于判断是否修改）
    private var originalName_Tidy: String = ""

    /// 原始简介（用于判断是否修改）
    private var originalBio_Tidy: String = ""

    // MARK: - 头部渐变区

    private let headerView_Tidy: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        v.layer.cornerRadius = 32
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return v
    }()

    private let headerGradientLayer_Tidy = CAGradientLayer()

    /// 装饰圆 1（右上）
    private let decorCircle1_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        v.layer.cornerRadius = 65
        return v
    }()

    /// 装饰圆 2（左下）
    private let decorCircle2_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 45
        return v
    }()

    /// 头像外圈光晕
    private let avatarGlowView_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        v.layer.cornerRadius = 56
        return v
    }()

    // 头像（使用现有组件 CurrentUserAvatarView，确保统一样式）
    private let avatarView_Tidy: CurrentUserAvatarView_Tidy = {
        let v = CurrentUserAvatarView_Tidy()
        v.showEditButton_Tidy = true
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowOpacity = 0.20
        v.layer.shadowRadius = 14
        return v
    }()

    /// 相机图标徽章（头像右下角，提示可编辑）
    private let cameraBadge_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.primaryGradientStart_Tidy
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 2.5
        v.layer.borderColor = UIColor.white.cgColor
        v.isUserInteractionEnabled = false
        return v
    }()

    private let cameraIcon_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "camera.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        return iv
    }()

    /// "Tap to change" 提示
    private let avatarHintLabel_Tidy: UILabel = {
        let label = UILabel()
        label.text = "Tap to change photo"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        label.textAlignment = .center
        return label
    }()

    // MARK: - 滚动容器

    private let scrollView_Tidy: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode = .onDrag
        sv.backgroundColor = .clear
        return sv
    }()

    private let contentView_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    // MARK: - 表单卡片

    private let formCardView_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.cardBackground_Tidy
        v.layer.cornerRadius = 22
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 16
        return v
    }()

    // —— 用户名字段 ——

    /// 用户名字段图标容器
    private let nameIconView_Tidy = EditInfo_Tidy.makeFieldIcon_Tidy(
        systemName: "person.fill",
        color: ColorConfig_Tidy.primaryGradientStart_Tidy
    )

    private let nameSectionLabel_Tidy = EditInfo_Tidy.makeFieldLabel_Tidy(text: "Username")

    private let nameTextField_Tidy: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter your username"
        tf.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        tf.textColor = ColorConfig_Tidy.textPrimary_Tidy
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .next
        tf.attributedPlaceholder = NSAttributedString(
            string: "Enter your username",
            attributes: [.foregroundColor: ColorConfig_Tidy.textPlaceholder_Tidy]
        )
        return tf
    }()

    private let nameDivider_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.divider_Tidy
        return v
    }()

    // —— 简介字段 ——

    /// 简介字段图标容器
    private let bioIconView_Tidy = EditInfo_Tidy.makeFieldIcon_Tidy(
        systemName: "text.bubble.fill",
        color: ColorConfig_Tidy.primaryGradientEnd_Tidy
    )

    private let bioSectionLabel_Tidy = EditInfo_Tidy.makeFieldLabel_Tidy(text: "Bio")

    private let bioTextView_Tidy: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        tv.textColor = ColorConfig_Tidy.textPrimary_Tidy
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.returnKeyType = .done
        tv.textContainerInset = UIEdgeInsets(top: 4, left: -4, bottom: 4, right: -4)
        return tv
    }()

    private let bioPlaceholderLabel_Tidy: UILabel = {
        let label = UILabel()
        label.text = "Tell something about yourself..."
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = ColorConfig_Tidy.textPlaceholder_Tidy
        label.isUserInteractionEnabled = false
        return label
    }()

    /// 字符计数 + 进度条
    private let charCountLabel_Tidy: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = ColorConfig_Tidy.textPlaceholder_Tidy
        label.textAlignment = .right
        label.text = "0 / 80"
        return label
    }()

    /// 字符进度条背景
    private let charProgressBg_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.divider_Tidy
        v.layer.cornerRadius = 2
        return v
    }()

    /// 字符进度条填充
    private let charProgressFill_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.primaryGradientStart_Tidy
        v.layer.cornerRadius = 2
        return v
    }()

    private var charProgressWidthConstraint_Tidy: Constraint?

    // MARK: - 保存按钮

    private let saveButton_Tidy: UIButton = {
        let button_Tidy = UIButton(type: .system)
        button_Tidy.setTitle("Save Changes", for: .normal)
        button_Tidy.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button_Tidy.setTitleColor(.white, for: .normal)
        button_Tidy.layer.cornerRadius = 26
        button_Tidy.layer.shadowColor = ColorConfig_Tidy.primaryGradientStart_Tidy.cgColor
        button_Tidy.layer.shadowOffset = CGSize(width: 0, height: 8)
        button_Tidy.layer.shadowOpacity = 0.30
        button_Tidy.layer.shadowRadius = 12
        return button_Tidy
    }()

    private let saveButtonGradient_Tidy = CAGradientLayer()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Tidy()
        loadCurrentUserData_Tidy()
        bindActions_Tidy()
        setupKeyboardObservers_Tidy()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 透明导航栏，与渐变头部融合
        navigationController?.setNavigationBarHidden(false, animated: animated)
        setupNavigationBar_Tidy()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers_Tidy()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer_Tidy.frame = headerView_Tidy.bounds
        saveButtonGradient_Tidy.frame = saveButton_Tidy.bounds
        saveButtonGradient_Tidy.cornerRadius = saveButton_Tidy.layer.cornerRadius
    }

    // MARK: - UI 搭建

    private func setupUI_Tidy() {
        view.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        setupHeaderView_Tidy()
        setupScrollContent_Tidy()
        setupSaveButton_Tidy()
        animateEntrance_Tidy()
    }

    /// 配置透明导航栏（与渐变头部无缝融合）
    private func setupNavigationBar_Tidy() {
        title = "Edit Profile"
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Tidy)
        )
    }

    // MARK: 头部渐变

    private func setupHeaderView_Tidy() {
        headerGradientLayer_Tidy.colors = [
            ColorConfig_Tidy.primaryGradientStart_Tidy.cgColor,
            ColorConfig_Tidy.primaryGradientEnd_Tidy.cgColor
        ]
        headerGradientLayer_Tidy.startPoint = CGPoint(x: 0, y: 0)
        headerGradientLayer_Tidy.endPoint = CGPoint(x: 1, y: 1)
        headerView_Tidy.layer.insertSublayer(headerGradientLayer_Tidy, at: 0)

        view.addSubview(headerView_Tidy)
        headerView_Tidy.addSubview(decorCircle1_Tidy)
        headerView_Tidy.addSubview(decorCircle2_Tidy)
        headerView_Tidy.addSubview(avatarGlowView_Tidy)
        headerView_Tidy.addSubview(avatarView_Tidy)
        headerView_Tidy.addSubview(cameraBadge_Tidy)
        cameraBadge_Tidy.addSubview(cameraIcon_Tidy)
        headerView_Tidy.addSubview(avatarHintLabel_Tidy)

        headerView_Tidy.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(270)
        }

        // 装饰圆
        decorCircle1_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(130)
            make.top.equalToSuperview().offset(-20)
            make.right.equalToSuperview().offset(10)
        }
        decorCircle2_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(90)
            make.bottom.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(-20)
        }

        // 头像光晕（比头像大 24pt）
        // 关键修复：使用 view.safeAreaLayoutGuide 锚定，确保头像在导航栏下方可见
        avatarGlowView_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.width.height.equalTo(112)
        }

        // 头像（centered inside glow）
        avatarView_Tidy.snp.makeConstraints { make in
            make.center.equalTo(avatarGlowView_Tidy)
            make.width.height.equalTo(88)
        }

        // 相机徽章（右下角）
        cameraBadge_Tidy.snp.makeConstraints { make in
            make.right.equalTo(avatarView_Tidy.snp.right).offset(4)
            make.bottom.equalTo(avatarView_Tidy.snp.bottom).offset(4)
            make.width.height.equalTo(28)
        }
        cameraIcon_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(14)
        }

        avatarHintLabel_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(avatarView_Tidy.snp.bottom).offset(16)
        }
    }

    // MARK: 滚动内容

    private func setupScrollContent_Tidy() {
        view.addSubview(scrollView_Tidy)
        scrollView_Tidy.addSubview(contentView_Tidy)

        scrollView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(headerView_Tidy.snp.bottom).offset(-22)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-82)
        }
        contentView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Tidy)
        }

        contentView_Tidy.addSubview(formCardView_Tidy)

        // 用户名行
        formCardView_Tidy.addSubview(nameIconView_Tidy)
        formCardView_Tidy.addSubview(nameSectionLabel_Tidy)
        formCardView_Tidy.addSubview(nameTextField_Tidy)
        formCardView_Tidy.addSubview(nameDivider_Tidy)

        // 简介行
        formCardView_Tidy.addSubview(bioIconView_Tidy)
        formCardView_Tidy.addSubview(bioSectionLabel_Tidy)
        formCardView_Tidy.addSubview(bioTextView_Tidy)
        formCardView_Tidy.addSubview(bioPlaceholderLabel_Tidy)
        formCardView_Tidy.addSubview(charProgressBg_Tidy)
        charProgressBg_Tidy.addSubview(charProgressFill_Tidy)
        formCardView_Tidy.addSubview(charCountLabel_Tidy)

        layoutFormCard_Tidy()
    }

    private func layoutFormCard_Tidy() {
        let pad = 20

        formCardView_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(36)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-16)
        }

        // —— 用户名 ——
        nameIconView_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.left.equalToSuperview().offset(pad)
            make.width.height.equalTo(32)
        }
        nameSectionLabel_Tidy.snp.makeConstraints { make in
            make.centerY.equalTo(nameIconView_Tidy)
            make.left.equalTo(nameIconView_Tidy.snp.right).offset(10)
        }
        nameTextField_Tidy.snp.makeConstraints { make in
            make.top.equalTo(nameIconView_Tidy.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(pad)
            make.right.equalToSuperview().offset(-pad)
            make.height.equalTo(44)
        }
        nameDivider_Tidy.snp.makeConstraints { make in
            make.top.equalTo(nameTextField_Tidy.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(pad)
            make.right.equalToSuperview().offset(-pad)
            make.height.equalTo(1)
        }

        // —— 简介 ——
        bioIconView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(nameDivider_Tidy.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(pad)
            make.width.height.equalTo(32)
        }
        bioSectionLabel_Tidy.snp.makeConstraints { make in
            make.centerY.equalTo(bioIconView_Tidy)
            make.left.equalTo(bioIconView_Tidy.snp.right).offset(10)
        }
        bioTextView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(bioIconView_Tidy.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(pad)
            make.right.equalToSuperview().offset(-pad)
            make.height.greaterThanOrEqualTo(80)
        }
        bioPlaceholderLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(bioTextView_Tidy).offset(4)
            make.left.equalTo(bioTextView_Tidy)
        }

        // 进度条（左）+ 字符数（右）
        charProgressBg_Tidy.snp.makeConstraints { make in
            make.top.equalTo(bioTextView_Tidy.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(pad)
            make.height.equalTo(4)
            make.right.equalTo(charCountLabel_Tidy.snp.left).offset(-12)
            make.bottom.equalToSuperview().offset(-22)
        }
        charProgressFill_Tidy.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            charProgressWidthConstraint_Tidy = make.width.equalTo(0).constraint
        }
        charCountLabel_Tidy.snp.makeConstraints { make in
            make.centerY.equalTo(charProgressBg_Tidy)
            make.right.equalToSuperview().offset(-pad)
            make.width.equalTo(50)
        }
    }

    // MARK: 保存按钮

    private func setupSaveButton_Tidy() {
        saveButtonGradient_Tidy.colors = [
            ColorConfig_Tidy.primaryGradientStart_Tidy.cgColor,
            ColorConfig_Tidy.primaryGradientEnd_Tidy.cgColor
        ]
        saveButtonGradient_Tidy.startPoint = CGPoint(x: 0, y: 0)
        saveButtonGradient_Tidy.endPoint = CGPoint(x: 1, y: 0)
        saveButton_Tidy.layer.insertSublayer(saveButtonGradient_Tidy, at: 0)

        view.addSubview(saveButton_Tidy)
        saveButton_Tidy.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(52)
        }
    }

    // MARK: 入场动画

    private func animateEntrance_Tidy() {
        formCardView_Tidy.alpha = 0
        formCardView_Tidy.animateSlideInFromBottom_Tidy(offset_Tidy: 36, delay_Tidy: 0.08)
        saveButton_Tidy.alpha = 0
        saveButton_Tidy.animateFadeIn_Tidy(delay_Tidy: 0.22)
        avatarGlowView_Tidy.animateSpringScaleIn_Tidy(delay_Tidy: 0.05)
    }

    // MARK: - 数据加载

    /// 加载当前登录用户数据作为默认值
    private func loadCurrentUserData_Tidy() {
        let user_Tidy = UserViewModel_Tidy.shared_Tidy.getCurrentUser_Tidy()
        originalName_Tidy = user_Tidy.userName_Tidy ?? ""
        originalBio_Tidy = user_Tidy.userIntroduce_Tidy ?? ""

        nameTextField_Tidy.text = originalName_Tidy
        bioTextView_Tidy.text = originalBio_Tidy
        updateBioState_Tidy()
    }

    // MARK: - 事件绑定

    private func bindActions_Tidy() {
        // 头像 + 相机徽章点击 → 打开相册
        avatarView_Tidy.onTapped_Tidy = { [weak self] in
            self?.openPhotoPicker_Tidy()
        }
        saveButton_Tidy.addTarget(self, action: #selector(saveTapped_Tidy), for: .touchUpInside)
        bioTextView_Tidy.delegate = self
        nameTextField_Tidy.delegate = self

        // 输入框激活高亮
        nameTextField_Tidy.addTarget(self, action: #selector(nameFocused_Tidy), for: .editingDidBegin)
        nameTextField_Tidy.addTarget(self, action: #selector(nameBlurred_Tidy), for: .editingDidEnd)
    }

    // MARK: 字段焦点动画

    @objc private func nameFocused_Tidy() {
        UIView.animate(withDuration: 0.2) {
            self.nameIconView_Tidy.backgroundColor = ColorConfig_Tidy.primaryGradientStart_Tidy
            self.nameIconView_Tidy.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }
        animateDivider_Tidy(active: true)
    }

    @objc private func nameBlurred_Tidy() {
        UIView.animate(withDuration: 0.2) {
            self.nameIconView_Tidy.backgroundColor = ColorConfig_Tidy.primaryGradientStart_Tidy.withAlphaComponent(0.12)
            self.nameIconView_Tidy.transform = .identity
        }
        animateDivider_Tidy(active: false)
    }

    /// 输入框下划线激活/非激活动画
    private func animateDivider_Tidy(active: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.nameDivider_Tidy.backgroundColor = active
                ? ColorConfig_Tidy.primaryGradientStart_Tidy
                : ColorConfig_Tidy.divider_Tidy
            self.nameDivider_Tidy.snp.updateConstraints { make in
                make.height.equalTo(active ? 2 : 1)
            }
        }
    }

    // MARK: - 相册选择

    private func openPhotoPicker_Tidy() {
        avatarView_Tidy.animatePressDown_Tidy {
            self.avatarView_Tidy.animatePressUp_Tidy()
        }
        MediaPickerHelper_Tidy.pickImage_Tidy(from: self) { [weak self] image_Tidy in
            guard let self = self, let image_Tidy = image_Tidy else { return }
            self.selectedImage_Tidy = image_Tidy
            self.avatarView_Tidy.imageView_Tidy.image = image_Tidy
            self.avatarView_Tidy.imageView_Tidy.contentMode = .scaleAspectFill
            self.avatarGlowView_Tidy.animatePulse_Tidy()
        }
    }

    // MARK: - 保存操作

    @objc private func saveTapped_Tidy() {
        saveButton_Tidy.animatePressDown_Tidy {
            self.saveButton_Tidy.animatePressUp_Tidy()
        }

        // 未登录时跳转登录（仅在保存时检查）
        guard UserViewModel_Tidy.shared_Tidy.isLoggedIn_Tidy else {
            Navigation_Tidy.toLogin_Tidy(style_tidy: .present_tidy)
            return
        }

        let newName_Tidy = nameTextField_Tidy.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let newBio_Tidy = bioTextView_Tidy.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        var hasChange_Tidy = false

        if let image_Tidy = selectedImage_Tidy {
            Task { @MainActor in
                UserViewModel_Tidy.shared_Tidy.saveAvatarImage_Tidy(image_tidy: image_Tidy)
            }
            hasChange_Tidy = true
        }

        if !newName_Tidy.isEmpty && newName_Tidy != originalName_Tidy {
            Task { @MainActor in
                UserViewModel_Tidy.shared_Tidy.updateName_Tidy(userName_tidy: newName_Tidy)
            }
            hasChange_Tidy = true
        }

        if newBio_Tidy != originalBio_Tidy {
            Task { @MainActor in
                UserViewModel_Tidy.shared_Tidy.updateIntroduce_Tidy(introduce_tidy: newBio_Tidy)
            }
            hasChange_Tidy = true
        }

        if hasChange_Tidy {
            originalName_Tidy = newName_Tidy.isEmpty ? originalName_Tidy : newName_Tidy
            originalBio_Tidy = newBio_Tidy
            selectedImage_Tidy = nil
            Utils_Tidy.showSuccess_Tidy(message_Tidy: "Profile updated!")
        } else {
            Utils_Tidy.showInfo_Tidy(message_Tidy: "No changes detected")
        }

        view.endEditing(true)
        Navigation_Tidy.pop_Tidy()
    }

    @objc private func backTapped_Tidy() {
        view.endEditing(true)
        Navigation_Tidy.pop_Tidy()
    }

    // MARK: - 简介状态更新

    private func updateBioState_Tidy() {
        let text_Tidy = bioTextView_Tidy.text ?? ""
        bioPlaceholderLabel_Tidy.isHidden = !text_Tidy.isEmpty

        let count_Tidy = text_Tidy.count
        charCountLabel_Tidy.text = "\(count_Tidy) / 80"
        charCountLabel_Tidy.textColor = count_Tidy > 70
            ? ColorConfig_Tidy.tidyWarm_Tidy
            : ColorConfig_Tidy.textPlaceholder_Tidy

        // 更新进度条宽度（相对于背景宽度）
        let ratio_Tidy = min(CGFloat(count_Tidy) / 80.0, 1.0)
        let bgWidth_Tidy = charProgressBg_Tidy.bounds.width
        if bgWidth_Tidy > 0 {
            charProgressWidthConstraint_Tidy?.update(offset: bgWidth_Tidy * ratio_Tidy)
            UIView.animate(withDuration: 0.15) {
                self.charProgressBg_Tidy.layoutIfNeeded()
            }
        }

        // 进度条颜色：超过 70% 变红
        charProgressFill_Tidy.backgroundColor = count_Tidy > 56
            ? ColorConfig_Tidy.tidyWarm_Tidy
            : ColorConfig_Tidy.primaryGradientStart_Tidy
    }

    // MARK: - 键盘处理

    private func setupKeyboardObservers_Tidy() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Tidy(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Tidy(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func removeKeyboardObservers_Tidy() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow_Tidy(_ notification: Notification) {
        guard let frame_Tidy = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView_Tidy.contentInset.bottom = frame_Tidy.height - view.safeAreaInsets.bottom + 20
    }

    @objc private func keyboardWillHide_Tidy(_ notification: Notification) {
        scrollView_Tidy.contentInset.bottom = 0
    }

    // MARK: - 工厂方法

    /// 创建字段标签
    private static func makeFieldLabel_Tidy(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = ColorConfig_Tidy.textSecondary_Tidy
        return label
    }

    /// 创建字段前缀图标视图（圆角方形 icon）
    /// - Parameters:
    ///   - systemName: SF Symbol 名称
    ///   - color: 图标主题色（背景为该色的透明版）
    private static func makeFieldIcon_Tidy(systemName: String, color: UIColor) -> UIView {
        let container_Tidy = UIView()
        container_Tidy.backgroundColor = color.withAlphaComponent(0.12)
        container_Tidy.layer.cornerRadius = 10

        let imageView_Tidy = UIImageView()
        imageView_Tidy.image = UIImage(systemName: systemName)
        imageView_Tidy.tintColor = color
        imageView_Tidy.contentMode = .scaleAspectFit

        container_Tidy.addSubview(imageView_Tidy)
        imageView_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }
        return container_Tidy
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextViewDelegate

extension EditInfo_Tidy: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        updateBioState_Tidy()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.2) {
            self.bioIconView_Tidy.backgroundColor = ColorConfig_Tidy.primaryGradientEnd_Tidy.withAlphaComponent(0.25)
            self.bioIconView_Tidy.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.2) {
            self.bioIconView_Tidy.backgroundColor = ColorConfig_Tidy.primaryGradientEnd_Tidy.withAlphaComponent(0.12)
            self.bioIconView_Tidy.transform = .identity
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        let current_Tidy = textView.text ?? ""
        guard let range_Tidy = Range(range, in: current_Tidy) else { return true }
        let updated_Tidy = current_Tidy.replacingCharacters(in: range_Tidy, with: text)
        return updated_Tidy.count <= 80
    }
}

// MARK: - UITextFieldDelegate

extension EditInfo_Tidy: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        bioTextView_Tidy.becomeFirstResponder()
        return false
    }
}
