import Foundation
import UIKit
import SnapKit

// MARK: - 修改个人信息页面

/// 修改个人信息页面
/// 功能：允许用户修改头像（从相册选取）、用户名、个人简介
/// 设计：透明导航栏 + 渐变头部，头像锚定至 safeAreaLayoutGuide 下方确保不与导航栏重叠
///       表单字段带前缀图标，底部固定保存按钮
/// 逻辑：仅更新发生变化的字段；未登录时保存时跳转登录
class EditInfo_Base_one: UIViewController {

    // MARK: - 私有属性

    /// 用户选取的新头像（nil 表示未修改）
    private var selectedImage_Base_one: UIImage?

    /// 原始用户名（用于判断是否修改）
    private var originalName_Base_one: String = ""

    /// 原始简介（用于判断是否修改）
    private var originalBio_Base_one: String = ""

    // MARK: - 头部渐变区

    private let headerView_Base_one: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        v.layer.cornerRadius = 32
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return v
    }()

    private let headerGradientLayer_Base_one = CAGradientLayer()

    /// 装饰圆 1（右上）
    private let decorCircle1_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        v.layer.cornerRadius = 65
        return v
    }()

    /// 装饰圆 2（左下）
    private let decorCircle2_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 45
        return v
    }()

    /// 头像外圈光晕
    private let avatarGlowView_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        v.layer.cornerRadius = 56
        return v
    }()

    // 头像（使用现有组件 CurrentUserAvatarView，确保统一样式）
    private let avatarView_Base_one: CurrentUserAvatarView_Base_one = {
        let v = CurrentUserAvatarView_Base_one()
        v.showEditButton_Base_one = true
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowOpacity = 0.20
        v.layer.shadowRadius = 14
        return v
    }()

    /// 相机图标徽章（头像右下角，提示可编辑）
    private let cameraBadge_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Base_one: "#B794F6")
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 2.5
        v.layer.borderColor = UIColor.white.cgColor
        v.isUserInteractionEnabled = false
        return v
    }()

    private let cameraIcon_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "camera.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        return iv
    }()

    /// "Tap to change" 提示
    private let avatarHintLabel_Base_one: UILabel = {
        let label = UILabel()
        label.text = "Tap to change photo"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        label.textAlignment = .center
        return label
    }()

    // MARK: - 滚动容器

    private let scrollView_Base_one: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode = .onDrag
        sv.backgroundColor = .clear
        return sv
    }()

    private let contentView_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    // MARK: - 表单卡片

    private let formCardView_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.cardBackground_Base_one
        v.layer.cornerRadius = 22
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 16
        return v
    }()

    // —— 用户名字段 ——

    /// 用户名字段图标容器
    private let nameIconView_Base_one = EditInfo_Base_one.makeFieldIcon_Base_one(
        systemName: "person.fill",
        color: UIColor(hexstring_Base_one: "#B794F6")
    )

    private let nameSectionLabel_Base_one = EditInfo_Base_one.makeFieldLabel_Base_one(text: "Username")

    private let nameTextField_Base_one: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter your username"
        tf.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        tf.textColor = ColorConfig_Base_one.textPrimary_Base_one
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .next
        tf.attributedPlaceholder = NSAttributedString(
            string: "Enter your username",
            attributes: [.foregroundColor: ColorConfig_Base_one.textPlaceholder_Base_one]
        )
        return tf
    }()

    private let nameDivider_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.divider_Base_one
        return v
    }()

    // —— 简介字段 ——

    /// 简介字段图标容器
    private let bioIconView_Base_one = EditInfo_Base_one.makeFieldIcon_Base_one(
        systemName: "text.bubble.fill",
        color: UIColor(hexstring_Base_one: "#90CDF4")
    )

    private let bioSectionLabel_Base_one = EditInfo_Base_one.makeFieldLabel_Base_one(text: "Bio")

    private let bioTextView_Base_one: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        tv.textColor = ColorConfig_Base_one.textPrimary_Base_one
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.returnKeyType = .done
        tv.textContainerInset = UIEdgeInsets(top: 4, left: -4, bottom: 4, right: -4)
        return tv
    }()

    private let bioPlaceholderLabel_Base_one: UILabel = {
        let label = UILabel()
        label.text = "Tell something about yourself..."
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = ColorConfig_Base_one.textPlaceholder_Base_one
        label.isUserInteractionEnabled = false
        return label
    }()

    /// 字符计数 + 进度条
    private let charCountLabel_Base_one: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = ColorConfig_Base_one.textPlaceholder_Base_one
        label.textAlignment = .right
        label.text = "0 / 80"
        return label
    }()

    /// 字符进度条背景
    private let charProgressBg_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.divider_Base_one
        v.layer.cornerRadius = 2
        return v
    }()

    /// 字符进度条填充
    private let charProgressFill_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.primaryGradientStart_Base_one
        v.layer.cornerRadius = 2
        return v
    }()

    private var charProgressWidthConstraint_Base_one: Constraint?

    // MARK: - 保存按钮

    private let saveButton_Base_one: UIButton = {
        let button_Base_one = UIButton(type: .system)
        button_Base_one.setTitle("Save Changes", for: .normal)
        button_Base_one.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button_Base_one.setTitleColor(.white, for: .normal)
        button_Base_one.layer.cornerRadius = 26
        button_Base_one.layer.shadowColor = UIColor(hexstring_Base_one: "#B794F6").cgColor
        button_Base_one.layer.shadowOffset = CGSize(width: 0, height: 8)
        button_Base_one.layer.shadowOpacity = 0.30
        button_Base_one.layer.shadowRadius = 12
        return button_Base_one
    }()

    private let saveButtonGradient_Base_one = CAGradientLayer()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Base_one()
        loadCurrentUserData_Base_one()
        bindActions_Base_one()
        setupKeyboardObservers_Base_one()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 透明导航栏，与渐变头部融合
        navigationController?.setNavigationBarHidden(false, animated: animated)
        setupNavigationBar_Base_one()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers_Base_one()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer_Base_one.frame = headerView_Base_one.bounds
        saveButtonGradient_Base_one.frame = saveButton_Base_one.bounds
        saveButtonGradient_Base_one.cornerRadius = saveButton_Base_one.layer.cornerRadius
    }

    // MARK: - UI 搭建

    private func setupUI_Base_one() {
        view.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        setupHeaderView_Base_one()
        setupScrollContent_Base_one()
        setupSaveButton_Base_one()
        animateEntrance_Base_one()
    }

    /// 配置透明导航栏（与渐变头部无缝融合）
    private func setupNavigationBar_Base_one() {
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
            action: #selector(backTapped_Base_one)
        )
    }

    // MARK: 头部渐变

    private func setupHeaderView_Base_one() {
        headerGradientLayer_Base_one.colors = [
            ColorConfig_Base_one.primaryGradientStart_Base_one.cgColor,
            ColorConfig_Base_one.primaryGradientEnd_Base_one.cgColor
        ]
        headerGradientLayer_Base_one.startPoint = CGPoint(x: 0, y: 0)
        headerGradientLayer_Base_one.endPoint = CGPoint(x: 1, y: 1)
        headerView_Base_one.layer.insertSublayer(headerGradientLayer_Base_one, at: 0)

        view.addSubview(headerView_Base_one)
        headerView_Base_one.addSubview(decorCircle1_Base_one)
        headerView_Base_one.addSubview(decorCircle2_Base_one)
        headerView_Base_one.addSubview(avatarGlowView_Base_one)
        headerView_Base_one.addSubview(avatarView_Base_one)
        headerView_Base_one.addSubview(cameraBadge_Base_one)
        cameraBadge_Base_one.addSubview(cameraIcon_Base_one)
        headerView_Base_one.addSubview(avatarHintLabel_Base_one)

        headerView_Base_one.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(270)
        }

        // 装饰圆
        decorCircle1_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(130)
            make.top.equalToSuperview().offset(-20)
            make.right.equalToSuperview().offset(10)
        }
        decorCircle2_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(90)
            make.bottom.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(-20)
        }

        // 头像光晕（比头像大 24pt）
        // 关键修复：使用 view.safeAreaLayoutGuide 锚定，确保头像在导航栏下方可见
        avatarGlowView_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.width.height.equalTo(112)
        }

        // 头像（centered inside glow）
        avatarView_Base_one.snp.makeConstraints { make in
            make.center.equalTo(avatarGlowView_Base_one)
            make.width.height.equalTo(88)
        }

        // 相机徽章（右下角）
        cameraBadge_Base_one.snp.makeConstraints { make in
            make.right.equalTo(avatarView_Base_one.snp.right).offset(4)
            make.bottom.equalTo(avatarView_Base_one.snp.bottom).offset(4)
            make.width.height.equalTo(28)
        }
        cameraIcon_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(14)
        }

        avatarHintLabel_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(avatarView_Base_one.snp.bottom).offset(16)
        }
    }

    // MARK: 滚动内容

    private func setupScrollContent_Base_one() {
        view.addSubview(scrollView_Base_one)
        scrollView_Base_one.addSubview(contentView_Base_one)

        scrollView_Base_one.snp.makeConstraints { make in
            make.top.equalTo(headerView_Base_one.snp.bottom).offset(-22)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-82)
        }
        contentView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Base_one)
        }

        contentView_Base_one.addSubview(formCardView_Base_one)

        // 用户名行
        formCardView_Base_one.addSubview(nameIconView_Base_one)
        formCardView_Base_one.addSubview(nameSectionLabel_Base_one)
        formCardView_Base_one.addSubview(nameTextField_Base_one)
        formCardView_Base_one.addSubview(nameDivider_Base_one)

        // 简介行
        formCardView_Base_one.addSubview(bioIconView_Base_one)
        formCardView_Base_one.addSubview(bioSectionLabel_Base_one)
        formCardView_Base_one.addSubview(bioTextView_Base_one)
        formCardView_Base_one.addSubview(bioPlaceholderLabel_Base_one)
        formCardView_Base_one.addSubview(charProgressBg_Base_one)
        charProgressBg_Base_one.addSubview(charProgressFill_Base_one)
        formCardView_Base_one.addSubview(charCountLabel_Base_one)

        layoutFormCard_Base_one()
    }

    private func layoutFormCard_Base_one() {
        let pad = 20

        formCardView_Base_one.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(36)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-16)
        }

        // —— 用户名 ——
        nameIconView_Base_one.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.left.equalToSuperview().offset(pad)
            make.width.height.equalTo(32)
        }
        nameSectionLabel_Base_one.snp.makeConstraints { make in
            make.centerY.equalTo(nameIconView_Base_one)
            make.left.equalTo(nameIconView_Base_one.snp.right).offset(10)
        }
        nameTextField_Base_one.snp.makeConstraints { make in
            make.top.equalTo(nameIconView_Base_one.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(pad)
            make.right.equalToSuperview().offset(-pad)
            make.height.equalTo(44)
        }
        nameDivider_Base_one.snp.makeConstraints { make in
            make.top.equalTo(nameTextField_Base_one.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(pad)
            make.right.equalToSuperview().offset(-pad)
            make.height.equalTo(1)
        }

        // —— 简介 ——
        bioIconView_Base_one.snp.makeConstraints { make in
            make.top.equalTo(nameDivider_Base_one.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(pad)
            make.width.height.equalTo(32)
        }
        bioSectionLabel_Base_one.snp.makeConstraints { make in
            make.centerY.equalTo(bioIconView_Base_one)
            make.left.equalTo(bioIconView_Base_one.snp.right).offset(10)
        }
        bioTextView_Base_one.snp.makeConstraints { make in
            make.top.equalTo(bioIconView_Base_one.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(pad)
            make.right.equalToSuperview().offset(-pad)
            make.height.greaterThanOrEqualTo(80)
        }
        bioPlaceholderLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(bioTextView_Base_one).offset(4)
            make.left.equalTo(bioTextView_Base_one)
        }

        // 进度条（左）+ 字符数（右）
        charProgressBg_Base_one.snp.makeConstraints { make in
            make.top.equalTo(bioTextView_Base_one.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(pad)
            make.height.equalTo(4)
            make.right.equalTo(charCountLabel_Base_one.snp.left).offset(-12)
            make.bottom.equalToSuperview().offset(-22)
        }
        charProgressFill_Base_one.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            charProgressWidthConstraint_Base_one = make.width.equalTo(0).constraint
        }
        charCountLabel_Base_one.snp.makeConstraints { make in
            make.centerY.equalTo(charProgressBg_Base_one)
            make.right.equalToSuperview().offset(-pad)
            make.width.equalTo(50)
        }
    }

    // MARK: 保存按钮

    private func setupSaveButton_Base_one() {
        saveButtonGradient_Base_one.colors = [
            ColorConfig_Base_one.primaryGradientStart_Base_one.cgColor,
            ColorConfig_Base_one.primaryGradientEnd_Base_one.cgColor
        ]
        saveButtonGradient_Base_one.startPoint = CGPoint(x: 0, y: 0)
        saveButtonGradient_Base_one.endPoint = CGPoint(x: 1, y: 0)
        saveButton_Base_one.layer.insertSublayer(saveButtonGradient_Base_one, at: 0)

        view.addSubview(saveButton_Base_one)
        saveButton_Base_one.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(52)
        }
    }

    // MARK: 入场动画

    private func animateEntrance_Base_one() {
        formCardView_Base_one.alpha = 0
        formCardView_Base_one.animateSlideInFromBottom_Base_one(offset_Base_one: 36, delay_Base_one: 0.08)
        saveButton_Base_one.alpha = 0
        saveButton_Base_one.animateFadeIn_Base_one(delay_Base_one: 0.22)
        avatarGlowView_Base_one.animateSpringScaleIn_Base_one(delay_Base_one: 0.05)
    }

    // MARK: - 数据加载

    /// 加载当前登录用户数据作为默认值
    private func loadCurrentUserData_Base_one() {
        let user_Base_one = UserViewModel_Base_one.shared_Base_one.getCurrentUser_Base_one()
        originalName_Base_one = user_Base_one.userName_Base_one ?? ""
        originalBio_Base_one = user_Base_one.userIntroduce_Base_one ?? ""

        nameTextField_Base_one.text = originalName_Base_one
        bioTextView_Base_one.text = originalBio_Base_one
        updateBioState_Base_one()
    }

    // MARK: - 事件绑定

    private func bindActions_Base_one() {
        // 头像 + 相机徽章点击 → 打开相册
        avatarView_Base_one.onTapped_Base_one = { [weak self] in
            self?.openPhotoPicker_Base_one()
        }
        saveButton_Base_one.addTarget(self, action: #selector(saveTapped_Base_one), for: .touchUpInside)
        bioTextView_Base_one.delegate = self
        nameTextField_Base_one.delegate = self

        // 输入框激活高亮
        nameTextField_Base_one.addTarget(self, action: #selector(nameFocused_Base_one), for: .editingDidBegin)
        nameTextField_Base_one.addTarget(self, action: #selector(nameBlurred_Base_one), for: .editingDidEnd)
    }

    // MARK: 字段焦点动画

    @objc private func nameFocused_Base_one() {
        UIView.animate(withDuration: 0.2) {
            self.nameIconView_Base_one.backgroundColor = ColorConfig_Base_one.primaryGradientStart_Base_one
            self.nameIconView_Base_one.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }
        animateDivider_Base_one(active: true)
    }

    @objc private func nameBlurred_Base_one() {
        UIView.animate(withDuration: 0.2) {
            self.nameIconView_Base_one.backgroundColor = ColorConfig_Base_one.primaryGradientStart_Base_one.withAlphaComponent(0.12)
            self.nameIconView_Base_one.transform = .identity
        }
        animateDivider_Base_one(active: false)
    }

    /// 输入框下划线激活/非激活动画
    private func animateDivider_Base_one(active: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.nameDivider_Base_one.backgroundColor = active
                ? ColorConfig_Base_one.primaryGradientStart_Base_one
                : ColorConfig_Base_one.divider_Base_one
            self.nameDivider_Base_one.snp.updateConstraints { make in
                make.height.equalTo(active ? 2 : 1)
            }
        }
    }

    // MARK: - 相册选择

    private func openPhotoPicker_Base_one() {
        avatarView_Base_one.animatePressDown_Base_one {
            self.avatarView_Base_one.animatePressUp_Base_one()
        }
        MediaPickerHelper_Base_one.pickImage_Base_one(from: self) { [weak self] image_Base_one in
            guard let self = self, let image_Base_one = image_Base_one else { return }
            self.selectedImage_Base_one = image_Base_one
            self.avatarView_Base_one.imageView_Base_one.image = image_Base_one
            self.avatarView_Base_one.imageView_Base_one.contentMode = .scaleAspectFill
            self.avatarGlowView_Base_one.animatePulse_Base_one()
        }
    }

    // MARK: - 保存操作

    @objc private func saveTapped_Base_one() {
        saveButton_Base_one.animatePressDown_Base_one {
            self.saveButton_Base_one.animatePressUp_Base_one()
        }

        // 未登录时跳转登录（仅在保存时检查）
        guard UserViewModel_Base_one.shared_Base_one.isLoggedIn_Base_one else {
            Navigation_Base_one.toLogin_Base_one(style_base_one: .present_base_one)
            return
        }

        let newName_Base_one = nameTextField_Base_one.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let newBio_Base_one = bioTextView_Base_one.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        var hasChange_Base_one = false

        if let image_Base_one = selectedImage_Base_one {
            Task { @MainActor in
                UserViewModel_Base_one.shared_Base_one.saveAvatarImage_Base_one(image_base_one: image_Base_one)
            }
            hasChange_Base_one = true
        }

        if !newName_Base_one.isEmpty && newName_Base_one != originalName_Base_one {
            Task { @MainActor in
                UserViewModel_Base_one.shared_Base_one.updateName_Base_one(userName_base_one: newName_Base_one)
            }
            hasChange_Base_one = true
        }

        if newBio_Base_one != originalBio_Base_one {
            Task { @MainActor in
                UserViewModel_Base_one.shared_Base_one.updateIntroduce_Base_one(introduce_base_one: newBio_Base_one)
            }
            hasChange_Base_one = true
        }

        if hasChange_Base_one {
            originalName_Base_one = newName_Base_one.isEmpty ? originalName_Base_one : newName_Base_one
            originalBio_Base_one = newBio_Base_one
            selectedImage_Base_one = nil
            Utils_Base_one.showSuccess_Base_one(message_Base_one: "Profile updated!")
        } else {
            Utils_Base_one.showInfo_Base_one(message_Base_one: "No changes detected")
        }

        view.endEditing(true)
        Navigation_Base_one.pop_Base_one()
    }

    @objc private func backTapped_Base_one() {
        view.endEditing(true)
        Navigation_Base_one.pop_Base_one()
    }

    // MARK: - 简介状态更新

    private func updateBioState_Base_one() {
        let text_Base_one = bioTextView_Base_one.text ?? ""
        bioPlaceholderLabel_Base_one.isHidden = !text_Base_one.isEmpty

        let count_Base_one = text_Base_one.count
        charCountLabel_Base_one.text = "\(count_Base_one) / 80"
        charCountLabel_Base_one.textColor = count_Base_one > 70
            ? UIColor(hexstring_Base_one: "#FC8181")
            : ColorConfig_Base_one.textPlaceholder_Base_one

        // 更新进度条宽度（相对于背景宽度）
        let ratio_Base_one = min(CGFloat(count_Base_one) / 80.0, 1.0)
        let bgWidth_Base_one = charProgressBg_Base_one.bounds.width
        if bgWidth_Base_one > 0 {
            charProgressWidthConstraint_Base_one?.update(offset: bgWidth_Base_one * ratio_Base_one)
            UIView.animate(withDuration: 0.15) {
                self.charProgressBg_Base_one.layoutIfNeeded()
            }
        }

        // 进度条颜色：超过 70% 变红
        charProgressFill_Base_one.backgroundColor = count_Base_one > 56
            ? UIColor(hexstring_Base_one: "#FC8181")
            : ColorConfig_Base_one.primaryGradientStart_Base_one
    }

    // MARK: - 键盘处理

    private func setupKeyboardObservers_Base_one() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Base_one(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Base_one(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func removeKeyboardObservers_Base_one() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow_Base_one(_ notification: Notification) {
        guard let frame_Base_one = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView_Base_one.contentInset.bottom = frame_Base_one.height - view.safeAreaInsets.bottom + 20
    }

    @objc private func keyboardWillHide_Base_one(_ notification: Notification) {
        scrollView_Base_one.contentInset.bottom = 0
    }

    // MARK: - 工厂方法

    /// 创建字段标签
    private static func makeFieldLabel_Base_one(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = ColorConfig_Base_one.textSecondary_Base_one
        return label
    }

    /// 创建字段前缀图标视图（圆角方形 icon）
    /// - Parameters:
    ///   - systemName: SF Symbol 名称
    ///   - color: 图标主题色（背景为该色的透明版）
    private static func makeFieldIcon_Base_one(systemName: String, color: UIColor) -> UIView {
        let container_Base_one = UIView()
        container_Base_one.backgroundColor = color.withAlphaComponent(0.12)
        container_Base_one.layer.cornerRadius = 10

        let imageView_Base_one = UIImageView()
        imageView_Base_one.image = UIImage(systemName: systemName)
        imageView_Base_one.tintColor = color
        imageView_Base_one.contentMode = .scaleAspectFit

        container_Base_one.addSubview(imageView_Base_one)
        imageView_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }
        return container_Base_one
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextViewDelegate

extension EditInfo_Base_one: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        updateBioState_Base_one()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.2) {
            self.bioIconView_Base_one.backgroundColor = UIColor(hexstring_Base_one: "#90CDF4").withAlphaComponent(0.25)
            self.bioIconView_Base_one.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.2) {
            self.bioIconView_Base_one.backgroundColor = UIColor(hexstring_Base_one: "#90CDF4").withAlphaComponent(0.12)
            self.bioIconView_Base_one.transform = .identity
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        let current_Base_one = textView.text ?? ""
        guard let range_Base_one = Range(range, in: current_Base_one) else { return true }
        let updated_Base_one = current_Base_one.replacingCharacters(in: range_Base_one, with: text)
        return updated_Base_one.count <= 80
    }
}

// MARK: - UITextFieldDelegate

extension EditInfo_Base_one: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        bioTextView_Base_one.becomeFirstResponder()
        return false
    }
}
