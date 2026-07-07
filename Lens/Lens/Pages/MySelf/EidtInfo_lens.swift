import UIKit
import SnapKit

// MARK: - 修改用户信息页面（重构版）

/// 修改用户信息页面视图控制器（重构版）
/// 核心作用：允许用户更新头像、昵称和自我介绍
/// 设计思路：
///   - 自定义顶部导航栏，不依赖外层被隐藏的系统导航栏
///   - 背景多层径向光晕渐变与全局视觉一致
///   - 头像区使用彩虹渐变光圈 + 相机覆盖层，点击触发相册选取
///   - 输入框聚焦时呈现紫色渐变边框，失焦恢复低调样式
///   - 区块标题带渐变竖条装饰（Display Name / Bio）
///   - 保存按钮紫蓝渐变 + 前置图标，高度 56pt
/// 关键方法：saveChanges_Lens()，pickAvatar_Lens()
class EditInfo_Lens: UIViewController {

    // MARK: - 属性

    private var selectedImage_Lens: UIImage?
    private var originalName_Lens: String = ""
    private var originalBio_Lens: String = ""

    // MARK: - UI 组件：背景装饰

    private let backgroundGlowView_Lens: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - UI 组件：自定义导航栏

    private let navBar_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#161626")
        return v
    }()

    private let backButton_Lens: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Lens)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .white
        b.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Edit Profile"
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    // MARK: - UI 组件：滚动内容

    private let scrollView_Lens = UIScrollView()
    private let contentView_Lens = UIView()

    // MARK: - UI 组件：头像区

    /// 头像卡片容器
    private let avatarCardView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#1E1E38")
        v.layer.cornerRadius = 20
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.12).cgColor
        return v
    }()

    /// 彩虹渐变光圈容器（102pt，clipsToBounds）
    private let avatarRingView_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 51
        v.clipsToBounds = true
        return v
    }()

    /// 当前用户头像（可点击）
    private let avatarView_Lens = CurrentUserAvatarView_Lens()

    /// 相机覆盖层（提示可点击换头像）
    private let cameraOverlay_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#000000", alpha_Lens: 0.4)
        v.layer.cornerRadius = 47
        v.isUserInteractionEnabled = false
        return v
    }()

    private let cameraIcon_Lens: UIImageView = {
        let iv = UIImageView()
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        iv.image = UIImage(systemName: "camera.fill", withConfiguration: cfg_Lens)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let avatarHintLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Tap to change avatar"
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.4)
        l.font = .systemFont(ofSize: 12)
        l.textAlignment = .center
        return l
    }()

    // MARK: - UI 组件：编辑区

    private let editCardView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#1E1E38")
        v.layer.cornerRadius = 20
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.12).cgColor
        return v
    }()

    // 昵称区块
    private let nameSectionView_Lens = UIView()
    private let nameAccentBar_Lens = UIView()

    private let nameTitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "DISPLAY NAME"
        l.textColor = UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.85)
        l.font = .systemFont(ofSize: 11, weight: .bold)
        return l
    }()

    private let nameTextField_Lens: UITextField = {
        let tf_Lens = UITextField()
        tf_Lens.textColor = .white
        tf_Lens.font = .systemFont(ofSize: 16)
        tf_Lens.attributedPlaceholder = NSAttributedString(
            string: "Enter your name",
            attributes: [.foregroundColor: UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.28)]
        )
        tf_Lens.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06)
        tf_Lens.layer.cornerRadius = 12
        tf_Lens.layer.borderWidth = 1
        tf_Lens.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.08).cgColor
        tf_Lens.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        tf_Lens.leftViewMode = .always
        tf_Lens.returnKeyType = .next
        return tf_Lens
    }()

    // 简介区块
    private let bioSectionView_Lens = UIView()
    private let bioAccentBar_Lens = UIView()

    private let bioTitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "BIO"
        l.textColor = UIColor(hexstring_Lens: "#4D96FF", alpha_Lens: 0.85)
        l.font = .systemFont(ofSize: 11, weight: .bold)
        return l
    }()

    private let bioTextView_Lens: UITextView = {
        let tv_Lens = UITextView()
        tv_Lens.textColor = .white
        tv_Lens.font = .systemFont(ofSize: 16)
        tv_Lens.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06)
        tv_Lens.layer.cornerRadius = 12
        tv_Lens.layer.borderWidth = 1
        tv_Lens.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.08).cgColor
        tv_Lens.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        return tv_Lens
    }()

    private let bioPlaceholderLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Tell others about yourself"
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.28)
        l.font = .systemFont(ofSize: 16)
        l.numberOfLines = 0
        return l
    }()

    // MARK: - UI 组件：保存按钮

    private let saveBtn_Lens: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Save Changes", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 17)
        b.layer.cornerRadius = 16
        b.clipsToBounds = true
        return b
    }()

    private let saveIconView_Lens: UIImageView = {
        let iv = UIImageView()
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        iv.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: cfg_Lens)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        return iv
    }()

    private let saveGradientLayer_Lens: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [UIColor(hexstring_Lens: "#7B2FF7").cgColor, UIColor(hexstring_Lens: "#2D5BE3").cgColor]
        g.startPoint = CGPoint(x: 0, y: 0.5)
        g.endPoint = CGPoint(x: 1, y: 0.5)
        g.cornerRadius = 16
        return g
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView_Lens()
        setupCustomNavigation_Lens()
        setupScrollContent_Lens()
        view.bringSubviewToFront(navBar_Lens)
        loadCurrentUserData_Lens()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        saveGradientLayer_Lens.frame = saveBtn_Lens.bounds
        // 同步头像光圈渐变
        if let ringLayer_Lens = avatarRingView_Lens.layer.sublayers?.first as? CAGradientLayer {
            ringLayer_Lens.frame = avatarRingView_Lens.bounds
        }
        let bottomInset_Lens = view.safeAreaInsets.bottom + 16
        if scrollView_Lens.contentInset.bottom != bottomInset_Lens {
            scrollView_Lens.contentInset.bottom = bottomInset_Lens
        }
    }

    // MARK: - 布局搭建

    private func setupView_Lens() {
        view.backgroundColor = UIColor(hexstring_Lens: "#0D0D1A")

        view.insertSubview(backgroundGlowView_Lens, at: 0)
        backgroundGlowView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(260)
        }
        setupBackgroundGlows_Lens()

        let tap_Lens = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Lens))
        tap_Lens.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Lens)
    }

    /// 构建背景多层径向光晕
    private func setupBackgroundGlows_Lens() {
        let purple_Lens = CAGradientLayer()
        purple_Lens.type = .radial
        purple_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.25).cgColor,
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0).cgColor
        ]
        purple_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        purple_Lens.endPoint = CGPoint(x: 1.0, y: 1.0)
        purple_Lens.frame = CGRect(x: -80, y: -60, width: 280, height: 280)
        backgroundGlowView_Lens.layer.addSublayer(purple_Lens)

        let blue_Lens = CAGradientLayer()
        blue_Lens.type = .radial
        blue_Lens.colors = [
            UIColor(hexstring_Lens: "#2D5BE3", alpha_Lens: 0.15).cgColor,
            UIColor(hexstring_Lens: "#2D5BE3", alpha_Lens: 0).cgColor
        ]
        blue_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        blue_Lens.endPoint = CGPoint(x: 1.0, y: 1.0)
        let sw_Lens = UIScreen.main.bounds.width
        blue_Lens.frame = CGRect(x: sw_Lens - 50, y: 40, width: 180, height: 180)
        backgroundGlowView_Lens.layer.addSublayer(blue_Lens)
    }

    /// 搭建自定义顶部导航栏（返回按钮 + 标题）
    private func setupCustomNavigation_Lens() {
        view.addSubview(navBar_Lens)
        navBar_Lens.addSubview(backButton_Lens)
        navBar_Lens.addSubview(navTitleLabel_Lens)
        backButton_Lens.addTarget(self, action: #selector(onBackTap_Lens), for: .touchUpInside)

        navBar_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton_Lens)
        }
    }

    private func setupScrollContent_Lens() {
        view.addSubview(scrollView_Lens)
        scrollView_Lens.addSubview(contentView_Lens)
        scrollView_Lens.showsVerticalScrollIndicator = false
        scrollView_Lens.contentInsetAdjustmentBehavior = .never
        scrollView_Lens.keyboardDismissMode = .onDrag
        scrollView_Lens.snp.makeConstraints {
            $0.top.equalTo(navBar_Lens.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        setupAvatarCard_Lens()
        setupEditCard_Lens()
        setupSaveButton_Lens()
    }

    /// 搭建头像卡片（彩虹光圈 + 相机覆盖）
    private func setupAvatarCard_Lens() {
        contentView_Lens.addSubview(avatarCardView_Lens)
        avatarCardView_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        // 彩虹光圈
        let ringGrad_Lens = CAGradientLayer()
        ringGrad_Lens.colors = [
            UIColor(hexstring_Lens: "#C77DFF").cgColor,
            UIColor(hexstring_Lens: "#4D96FF").cgColor,
            UIColor(hexstring_Lens: "#6BCB77").cgColor,
            UIColor(hexstring_Lens: "#FFD93D").cgColor,
            UIColor(hexstring_Lens: "#FFB347").cgColor,
            UIColor(hexstring_Lens: "#FF6B6B").cgColor,
            UIColor(hexstring_Lens: "#7B2FF7").cgColor
        ]
        ringGrad_Lens.startPoint = CGPoint(x: 0, y: 0)
        ringGrad_Lens.endPoint = CGPoint(x: 1, y: 1)
        ringGrad_Lens.cornerRadius = 51
        ringGrad_Lens.frame = CGRect(x: 0, y: 0, width: 102, height: 102)
        avatarRingView_Lens.layer.insertSublayer(ringGrad_Lens, at: 0)

        // 头像组件（点击选取）
        avatarView_Lens.layer.cornerRadius = 47
        avatarView_Lens.clipsToBounds = true
        avatarView_Lens.onTapped_Lens = { [weak self] in self?.pickAvatar_Lens() }

        cameraOverlay_Lens.addSubview(cameraIcon_Lens)
        cameraIcon_Lens.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(22) }

        avatarRingView_Lens.addSubview(avatarView_Lens)
        avatarCardView_Lens.addSubview(avatarRingView_Lens)
        avatarCardView_Lens.addSubview(cameraOverlay_Lens)
        avatarCardView_Lens.addSubview(avatarHintLabel_Lens)

        avatarRingView_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(28)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(102)
        }
        avatarView_Lens.snp.makeConstraints { $0.edges.equalToSuperview().inset(3) }
        cameraOverlay_Lens.snp.makeConstraints {
            $0.center.equalTo(avatarRingView_Lens)
            $0.width.height.equalTo(96)
        }
        avatarHintLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(avatarRingView_Lens.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(24)
        }
    }

    /// 搭建编辑信息卡片（昵称 + 简介，带区块标题）
    private func setupEditCard_Lens() {
        contentView_Lens.addSubview(editCardView_Lens)
        editCardView_Lens.snp.makeConstraints {
            $0.top.equalTo(avatarCardView_Lens.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        // 昵称区块标题
        setupAccentBar_Lens(barView_Lens: nameAccentBar_Lens, topColor_Lens: "#7B2FF7", bottomColor_Lens: "#C77DFF")
        editCardView_Lens.addSubview(nameSectionView_Lens)
        nameSectionView_Lens.addSubview(nameAccentBar_Lens)
        nameSectionView_Lens.addSubview(nameTitleLabel_Lens)
        nameSectionView_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(16)
        }
        nameAccentBar_Lens.snp.makeConstraints {
            $0.leading.centerY.top.bottom.equalToSuperview()
            $0.width.equalTo(3)
            $0.height.equalTo(14)
        }
        nameTitleLabel_Lens.snp.makeConstraints {
            $0.leading.equalTo(nameAccentBar_Lens.snp.trailing).offset(8)
            $0.centerY.trailing.equalToSuperview()
        }

        editCardView_Lens.addSubview(nameTextField_Lens)
        nameTextField_Lens.delegate = self
        nameTextField_Lens.snp.makeConstraints {
            $0.top.equalTo(nameSectionView_Lens.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }

        // 简介区块标题
        setupAccentBar_Lens(barView_Lens: bioAccentBar_Lens, topColor_Lens: "#4D96FF", bottomColor_Lens: "#6BCB77")
        editCardView_Lens.addSubview(bioSectionView_Lens)
        bioSectionView_Lens.addSubview(bioAccentBar_Lens)
        bioSectionView_Lens.addSubview(bioTitleLabel_Lens)
        bioSectionView_Lens.snp.makeConstraints {
            $0.top.equalTo(nameTextField_Lens.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
        }
        bioAccentBar_Lens.snp.makeConstraints {
            $0.leading.centerY.top.bottom.equalToSuperview()
            $0.width.equalTo(3)
            $0.height.equalTo(14)
        }
        bioTitleLabel_Lens.snp.makeConstraints {
            $0.leading.equalTo(bioAccentBar_Lens.snp.trailing).offset(8)
            $0.centerY.trailing.equalToSuperview()
        }

        editCardView_Lens.addSubview(bioTextView_Lens)
        bioTextView_Lens.addSubview(bioPlaceholderLabel_Lens)
        bioTextView_Lens.delegate = self
        bioTextView_Lens.snp.makeConstraints {
            $0.top.equalTo(bioSectionView_Lens.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(120)
            $0.bottom.equalToSuperview().inset(20)
        }
        bioPlaceholderLabel_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().inset(14)
        }
    }

    /// 为区块标题渐变竖条设置渐变层
    private func setupAccentBar_Lens(barView_Lens: UIView, topColor_Lens: String, bottomColor_Lens: String) {
        barView_Lens.layer.cornerRadius = 1.5
        let grad_Lens = CAGradientLayer()
        grad_Lens.colors = [
            UIColor(hexstring_Lens: topColor_Lens).cgColor,
            UIColor(hexstring_Lens: bottomColor_Lens).cgColor
        ]
        grad_Lens.startPoint = CGPoint(x: 0.5, y: 0)
        grad_Lens.endPoint = CGPoint(x: 0.5, y: 1)
        grad_Lens.cornerRadius = 1.5
        grad_Lens.frame = CGRect(x: 0, y: 0, width: 3, height: 14)
        barView_Lens.layer.addSublayer(grad_Lens)
    }

    /// 搭建保存按钮
    private func setupSaveButton_Lens() {
        contentView_Lens.addSubview(saveBtn_Lens)
        saveBtn_Lens.layer.insertSublayer(saveGradientLayer_Lens, at: 0)
        saveBtn_Lens.addSubview(saveIconView_Lens)
        saveBtn_Lens.addTarget(self, action: #selector(onSaveTap_Lens), for: .touchUpInside)

        saveBtn_Lens.snp.makeConstraints {
            $0.top.equalTo(editCardView_Lens.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(56)
            $0.bottom.equalToSuperview().inset(36)
        }
        saveIconView_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(18)
        }
    }

    // MARK: - 数据加载

    private func loadCurrentUserData_Lens() {
        let user_Lens = UserViewModel_Lens.shared_Lens.getCurrentUser_Lens()
        originalName_Lens = user_Lens.userName_Lens ?? ""
        originalBio_Lens = user_Lens.userIntroduce_Lens ?? ""
        nameTextField_Lens.text = originalName_Lens
        bioTextView_Lens.text = originalBio_Lens
        bioPlaceholderLabel_Lens.isHidden = !originalBio_Lens.isEmpty
    }

    // MARK: - 事件响应

    @objc private func onBackTap_Lens() {
        Navigation_Lens.pop_Lens(from: self)
    }

    private func pickAvatar_Lens() {
        MediaPickerHelper_Lens.shared_Lens.showPicker_Lens(from: self, mediaType_Lens: .photo_Lens) { [weak self] result_Lens in
            guard let self else { return }
            if case .photo_Lens(let image_Lens) = result_Lens {
                self.selectedImage_Lens = image_Lens
                self.avatarView_Lens.imageView_Lens.image = image_Lens
                self.avatarView_Lens.imageView_Lens.contentMode = .scaleAspectFill
            }
        }
    }

    @objc private func onSaveTap_Lens() {
        guard UserViewModel_Lens.shared_Lens.isLoggedIn_Lens else {
            Load_Lens.showWarning_Lens(message_Lens: "Please log in first")
            Navigation_Lens.toLogin_Lens(style_lens: .present_lens)
            return
        }

        dismissKeyboard_Lens()
        var hasChanges_Lens = false

        if let image_Lens = selectedImage_Lens,
           let path_Lens = saveImageToDocument_Lens(image_Lens: image_Lens) {
            UserViewModel_Lens.shared_Lens.updateHead_Lens(headUrl_lens: path_Lens)
            hasChanges_Lens = true
        }

        let newName_Lens = (nameTextField_Lens.text ?? "").trimmingCharacters(in: .whitespaces)
        let nameFinal_Lens = newName_Lens.isEmpty ? originalName_Lens : newName_Lens
        if nameFinal_Lens != originalName_Lens {
            UserViewModel_Lens.shared_Lens.updateName_Lens(userName_lens: nameFinal_Lens)
            hasChanges_Lens = true
        }

        let newBio_Lens = (bioTextView_Lens.text ?? "").trimmingCharacters(in: .whitespaces)
        let bioFinal_Lens = newBio_Lens.isEmpty ? originalBio_Lens : newBio_Lens
        if bioFinal_Lens != originalBio_Lens {
            UserViewModel_Lens.shared_Lens.updateIntroduce_Lens(userIntroduce_lens: bioFinal_Lens)
            hasChanges_Lens = true
        }

        if !hasChanges_Lens {
            Load_Lens.showInfo_Lens(message_Lens: "No changes detected")
        }
    }

    @objc private func dismissKeyboard_Lens() { view.endEditing(true) }

    private func saveImageToDocument_Lens(image_Lens: UIImage) -> String? {
        guard let data_Lens = image_Lens.jpegData(compressionQuality: 0.8) else { return nil }
        let fileName_Lens = "user_avatar_\(Int(Date().timeIntervalSince1970)).jpg"
        let dirURL_Lens = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Lens = dirURL_Lens.appendingPathComponent(fileName_Lens)
        do {
            try data_Lens.write(to: fileURL_Lens)
            return fileURL_Lens.path
        } catch {
            print("头像保存失败: \(error)")
            return nil
        }
    }
}

// MARK: - UITextViewDelegate

extension EditInfo_Lens: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        bioPlaceholderLabel_Lens.isHidden = !textView.text.isEmpty
    }

    /// 聚焦时高亮简介输入框边框
    func textViewDidBeginEditing(_ textView: UITextView) {
        bioTextView_Lens.layer.borderColor = UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.5).cgColor
    }

    /// 失焦时恢复边框
    func textViewDidEndEditing(_ textView: UITextView) {
        bioTextView_Lens.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.08).cgColor
    }
}

// MARK: - UITextFieldDelegate

extension EditInfo_Lens: UITextFieldDelegate {

    /// 聚焦时高亮昵称输入框边框
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameTextField_Lens.layer.borderColor = UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.5).cgColor
    }

    /// 失焦时恢复边框
    func textFieldDidEndEditing(_ textField: UITextField) {
        nameTextField_Lens.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.08).cgColor
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        bioTextView_Lens.becomeFirstResponder()
        return true
    }
}
