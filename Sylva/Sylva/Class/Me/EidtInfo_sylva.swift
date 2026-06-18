import Foundation
import UIKit
import SnapKit

// MARK: - 修改用户信息页面（Premium 重构版）

/// 修改用户信息视图控制器
/// 核心作用：提供用户头像、昵称、简介的修改功能，并通过 UserViewModel 持久化更新
/// 设计思路：渐变头部背景 + 头像浮层交界处 + 卡片式表单 + 渐变保存按钮 + 焦点动画
class EditInfo_Sylva: UIViewController {

    // MARK: - 私有属性

    /// 渐变头部（头像悬浮在此与白区交界）
    private let headerView_Sylva     = UIView()
    private let headerGradient_Sylva = CAGradientLayer()
    private let headerGradMask_Sylva = CAShapeLayer()

    /// 头像区域
    private let avatarContainer_Sylva = UIView()
    private let avatarView_Sylva      = CurrentUserAvatarView_Sylva()
    private let editBadge_Sylva       = UIView()

    /// 表单卡片
    private let formCardView_Sylva    = UIView()

    /// 用户名输入框
    private let nameField_Sylva = UITextField()

    /// 简介输入区
    private let introduceTextView_Sylva = UITextView()
    private let introducePlaceholder_Sylva = UILabel()

    /// 保存按钮容器（渐变背景）
    private let saveContainerView_Sylva = UIView()
    private let saveGradient_Sylva      = CAGradientLayer()
    private let saveButton_Sylva        = UIButton(type: .system)

    private var hasChanges_Sylva        = false
    private var selectedAvatarPath_Sylva: String?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Sylva: "#F7FAFA")
        setupHeader_Sylva()
        setupAvatarArea_Sylva()
        setupFormCard_Sylva()
        setupSaveButton_Sylva()
        setupKeyboardDismiss_Sylva()
        loadCurrentUserData_Sylva()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 渐变背景 mask（底部圆角）
        let hBounds_sylva = headerView_Sylva.bounds
        headerGradient_Sylva.frame = hBounds_sylva
        let hPath_sylva = UIBezierPath(
            roundedRect: hBounds_sylva,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 28, height: 28)
        )
        headerGradMask_Sylva.path = hPath_sylva.cgPath

        // 保存按钮渐变 frame
        saveGradient_Sylva.frame = saveContainerView_Sylva.bounds
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - UI 搭建

    /// 搭建渐变头部背景（含返回键 + 标题）
    private func setupHeader_Sylva() {
        headerGradient_Sylva.colors = [
            UIColor(hexstring_Sylva: "#1B4332").cgColor,
            UIColor(hexstring_Sylva: "#40916C").cgColor
        ]
        headerGradient_Sylva.startPoint = CGPoint(x: 0, y: 0)
        headerGradient_Sylva.endPoint   = CGPoint(x: 1, y: 1)
        headerGradient_Sylva.mask       = headerGradMask_Sylva
        headerView_Sylva.layer.insertSublayer(headerGradient_Sylva, at: 0)
        // headerView 仅作渐变背景，高度固定覆盖所有机型安全区
        view.addSubview(headerView_Sylva)
        headerView_Sylva.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(210)
        }

        // 装饰圆（视觉装饰，不可交互）
        let deco_sylva = UIView()
        deco_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        deco_sylva.layer.cornerRadius = 60
        headerView_Sylva.addSubview(deco_sylva)
        deco_sylva.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(-20)
            make.width.height.equalTo(120)
        }

        // 返回按钮和标题直接加到 view，用 safeAreaLayoutGuide 定位
        // 确保始终在安全区内可点击，不受 headerView 层级影响
        let backBtn_sylva = UIButton(type: .system)
        let backCfg_sylva = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        backBtn_sylva.setImage(UIImage(systemName: "chevron.left", withConfiguration: backCfg_sylva), for: .normal)
        backBtn_sylva.tintColor = .white
        backBtn_sylva.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        backBtn_sylva.layer.cornerRadius = 18
        backBtn_sylva.addTarget(self, action: #selector(backTapped_Sylva), for: .touchUpInside)
        view.addSubview(backBtn_sylva)
        backBtn_sylva.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }

        let titleLabel_sylva = UILabel()
        titleLabel_sylva.text = "Edit Profile"
        titleLabel_sylva.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel_sylva.textColor = .white
        view.addSubview(titleLabel_sylva)
        titleLabel_sylva.snp.makeConstraints { make in
            make.centerY.equalTo(backBtn_sylva)
            make.centerX.equalToSuperview()
        }
    }

    /// 搭建头像区域（悬浮在 Header / 表单交界处）
    private func setupAvatarArea_Sylva() {
        // 白色圆环底座（让头像有"浮起"感）
        let ringBase_sylva = UIView()
        ringBase_sylva.backgroundColor = UIColor(hexstring_Sylva: "#F7FAFA")
        ringBase_sylva.layer.cornerRadius = 56
        view.addSubview(ringBase_sylva)
        ringBase_sylva.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(headerView_Sylva.snp.bottom)
            make.width.height.equalTo(112)
        }

        // 头像
        avatarView_Sylva.layer.cornerRadius = 48
        avatarView_Sylva.layer.masksToBounds = true
        avatarView_Sylva.layer.borderWidth = 3.5
        avatarView_Sylva.layer.borderColor = UIColor.white.cgColor
        avatarView_Sylva.onTapped_Sylva = { [weak self] in self?.avatarTapped_Sylva() }
        view.addSubview(avatarView_Sylva)
        avatarView_Sylva.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(headerView_Sylva.snp.bottom)
            make.width.height.equalTo(96)
        }

        // 相机徽章
        editBadge_Sylva.backgroundColor = UIColor(hexstring_Sylva: "#40916C")
        editBadge_Sylva.layer.cornerRadius = 15
        editBadge_Sylva.layer.borderWidth  = 2.5
        editBadge_Sylva.layer.borderColor  = UIColor.white.cgColor
        view.addSubview(editBadge_Sylva)
        editBadge_Sylva.snp.makeConstraints { make in
            make.trailing.equalTo(avatarView_Sylva.snp.trailing).offset(3)
            make.bottom.equalTo(avatarView_Sylva.snp.bottom).offset(3)
            make.width.height.equalTo(30)
        }
        let cameraIcon_sylva = UIImageView(image: UIImage(systemName: "camera.fill"))
        cameraIcon_sylva.tintColor = .white
        cameraIcon_sylva.contentMode = .scaleAspectFit
        editBadge_Sylva.addSubview(cameraIcon_sylva)
        cameraIcon_sylva.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(14)
        }

        // "Tap to change" 提示
        let tapHint_sylva = UILabel()
        tapHint_sylva.text = "Tap to change avatar"
        tapHint_sylva.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        tapHint_sylva.textColor = UIColor(hexstring_Sylva: "#52B788")
        tapHint_sylva.textAlignment = .center
        view.addSubview(tapHint_sylva)
        tapHint_sylva.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Sylva.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
        }
    }

    /// 搭建表单卡片（用户名 + 简介输入）
    private func setupFormCard_Sylva() {
        formCardView_Sylva.backgroundColor = .white
        formCardView_Sylva.layer.cornerRadius = 20
        formCardView_Sylva.layer.shadowColor  = UIColor.black.cgColor
        formCardView_Sylva.layer.shadowOpacity = 0.06
        formCardView_Sylva.layer.shadowRadius  = 12
        formCardView_Sylva.layer.shadowOffset  = CGSize(width: 0, height: 4)
        view.addSubview(formCardView_Sylva)
        formCardView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(headerView_Sylva.snp.bottom).offset(70)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        // Username 标签
        let nameTitleLabel_sylva = makeFieldTitle_Sylva("Username")
        formCardView_Sylva.addSubview(nameTitleLabel_sylva)
        nameTitleLabel_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(16)
        }

        // Username 输入框
        nameField_Sylva.font = UIFont.systemFont(ofSize: 15)
        nameField_Sylva.textColor = ColorConfig_Sylva.textPrimary_Sylva
        nameField_Sylva.backgroundColor = UIColor(hexstring_Sylva: "#F0FFF4")
        nameField_Sylva.layer.cornerRadius = 12
        nameField_Sylva.layer.borderWidth  = 1.5
        nameField_Sylva.layer.borderColor  = ColorConfig_Sylva.border_Sylva.cgColor
        nameField_Sylva.returnKeyType = .next
        nameField_Sylva.delegate = self
        nameField_Sylva.setLeftPadding_Sylva(padding_Sylva: 14)
        nameField_Sylva.setRightPadding_Sylva(padding_Sylva: 14)
        nameField_Sylva.addTarget(self, action: #selector(textChanged_Sylva), for: .editingChanged)
        formCardView_Sylva.addSubview(nameField_Sylva)
        nameField_Sylva.snp.makeConstraints { make in
            make.top.equalTo(nameTitleLabel_sylva.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(48)
        }

        // Bio 标签
        let bioTitleLabel_sylva = makeFieldTitle_Sylva("Bio")
        formCardView_Sylva.addSubview(bioTitleLabel_sylva)
        bioTitleLabel_sylva.snp.makeConstraints { make in
            make.top.equalTo(nameField_Sylva.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(16)
        }

        // Bio 输入区
        introduceTextView_Sylva.font = UIFont.systemFont(ofSize: 15)
        introduceTextView_Sylva.textColor = ColorConfig_Sylva.textPrimary_Sylva
        introduceTextView_Sylva.backgroundColor = UIColor(hexstring_Sylva: "#F0FFF4")
        introduceTextView_Sylva.layer.cornerRadius = 12
        introduceTextView_Sylva.layer.borderWidth  = 1.5
        introduceTextView_Sylva.layer.borderColor  = ColorConfig_Sylva.border_Sylva.cgColor
        introduceTextView_Sylva.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        introduceTextView_Sylva.delegate = self
        formCardView_Sylva.addSubview(introduceTextView_Sylva)

        // 占位文字
        introducePlaceholder_Sylva.text = "Tell others about your green journey..."
        introducePlaceholder_Sylva.font = UIFont.systemFont(ofSize: 15)
        introducePlaceholder_Sylva.textColor = ColorConfig_Sylva.textPlaceholder_Sylva
        introduceTextView_Sylva.addSubview(introducePlaceholder_Sylva)

        // 统一约束
        introduceTextView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(bioTitleLabel_sylva.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(100)
            make.bottom.equalToSuperview().offset(-20)
        }
        introducePlaceholder_Sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
        }
    }

    /// 搭建渐变保存按钮
    private func setupSaveButton_Sylva() {
        saveContainerView_Sylva.layer.cornerRadius = 18
        saveContainerView_Sylva.layer.shadowColor  = UIColor(hexstring_Sylva: "#40916C").cgColor
        saveContainerView_Sylva.layer.shadowOpacity = 0.35
        saveContainerView_Sylva.layer.shadowRadius  = 12
        saveContainerView_Sylva.layer.shadowOffset  = CGSize(width: 0, height: 5)
        view.addSubview(saveContainerView_Sylva)
        saveContainerView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(formCardView_Sylva.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(54)
        }

        saveGradient_Sylva.colors = [
            UIColor(hexstring_Sylva: "#52B788").cgColor,
            UIColor(hexstring_Sylva: "#1B4332").cgColor
        ]
        saveGradient_Sylva.startPoint   = CGPoint(x: 0, y: 0.5)
        saveGradient_Sylva.endPoint     = CGPoint(x: 1, y: 0.5)
        saveGradient_Sylva.cornerRadius = 18
        saveContainerView_Sylva.layer.insertSublayer(saveGradient_Sylva, at: 0)

        let saveCfg_sylva = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        saveButton_Sylva.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: saveCfg_sylva), for: .normal)
        saveButton_Sylva.setTitle("Save Changes", for: .normal)
        saveButton_Sylva.setTitleColor(.white, for: .normal)
        saveButton_Sylva.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        saveButton_Sylva.tintColor = .white
        saveButton_Sylva.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        saveButton_Sylva.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        saveButton_Sylva.backgroundColor = .clear
        saveButton_Sylva.addTarget(self, action: #selector(saveTapped_Sylva), for: .touchUpInside)
        saveContainerView_Sylva.addSubview(saveButton_Sylva)
        saveButton_Sylva.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    // MARK: - 辅助

    private func makeFieldTitle_Sylva(_ text: String) -> UILabel {
        let label_sylva = UILabel()
        label_sylva.text = text
        label_sylva.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label_sylva.textColor = UIColor(hexstring_Sylva: "#40916C")
        return label_sylva
    }

    private func setupKeyboardDismiss_Sylva() {
        let tap_sylva = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Sylva))
        tap_sylva.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_sylva)
    }

    private func loadCurrentUserData_Sylva() {
        // 不判断登录，直接加载当前用户数据（无数据则字段为空）
        let user_sylva = UserViewModel_Sylva.shared_Sylva.getCurrentUser_Sylva()
        nameField_Sylva.text = user_sylva.userName_Sylva
        let intro_sylva = user_sylva.userIntroduce_Sylva ?? ""
        if !intro_sylva.isEmpty {
            introduceTextView_Sylva.text = intro_sylva
            introducePlaceholder_Sylva.isHidden = true
        }
    }

    // MARK: - 事件

    @objc private func backTapped_Sylva() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func dismissKeyboard_Sylva() {
        view.endEditing(true)
    }

    @objc private func avatarTapped_Sylva() {
        avatarView_Sylva.animatePulse_Sylva()
        MediaPickerHelper_Sylva.pickImage_Sylva(from: self) { [weak self] image_sylva in
            guard let self_sylva = self, let image_sylva = image_sylva else { return }
            if let path_sylva = self_sylva.saveImageToDocuments_Sylva(image_sylva) {
                self_sylva.selectedAvatarPath_Sylva = path_sylva
            }
            self_sylva.avatarView_Sylva.imageView_Sylva.image = image_sylva
            self_sylva.avatarView_Sylva.imageView_Sylva.contentMode = .scaleAspectFill
            self_sylva.hasChanges_Sylva = true
        }
    }

    private func saveImageToDocuments_Sylva(_ image_sylva: UIImage) -> String? {
        guard let data_sylva = image_sylva.jpegData(compressionQuality: 0.8) else { return nil }
        let filename_sylva = "avatar_\(Int(Date().timeIntervalSince1970)).jpg"
        let url_sylva = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename_sylva)
        do {
            try data_sylva.write(to: url_sylva)
            return url_sylva.path
        } catch {
            print("头像保存失败: \(error)")
            return nil
        }
    }

    @objc private func textChanged_Sylva() { hasChanges_Sylva = true }

    @objc private func saveTapped_Sylva() {
        saveButton_Sylva.animatePressDown_Sylva { [weak self] in
            self?.saveButton_Sylva.animatePressUp_Sylva()
        }
        guard hasChanges_Sylva else {
            navigationController?.popViewController(animated: true)
            return
        }
        let newName_sylva  = nameField_Sylva.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let newIntro_sylva = introduceTextView_Sylva.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if let path_sylva = selectedAvatarPath_Sylva {
            UserViewModel_Sylva.shared_Sylva.updateHead_Sylva(headUrl_sylva: path_sylva)
        }
        if !newName_sylva.isEmpty {
            UserViewModel_Sylva.shared_Sylva.updateName_Sylva(userName_sylva: newName_sylva)
        }
        if !newIntro_sylva.isEmpty {
            UserViewModel_Sylva.shared_Sylva.updateIntroduce_Sylva(introduce_sylva: newIntro_sylva)
        }
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension EditInfo_Sylva: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        introduceTextView_Sylva.becomeFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderColor = UIColor(hexstring_Sylva: "#40916C").cgColor
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderColor = ColorConfig_Sylva.border_Sylva.cgColor
        }
    }
}

// MARK: - UITextViewDelegate

extension EditInfo_Sylva: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        introducePlaceholder_Sylva.isHidden = !textView.text.isEmpty
        hasChanges_Sylva = true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        introducePlaceholder_Sylva.isHidden = !textView.text.isEmpty
        UIView.animate(withDuration: 0.2) {
            textView.layer.borderColor = UIColor(hexstring_Sylva: "#40916C").cgColor
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        introducePlaceholder_Sylva.isHidden = !textView.text.isEmpty
        UIView.animate(withDuration: 0.2) {
            textView.layer.borderColor = ColorConfig_Sylva.border_Sylva.cgColor
        }
    }
}
