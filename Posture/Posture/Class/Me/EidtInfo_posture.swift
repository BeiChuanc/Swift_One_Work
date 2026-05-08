import Foundation
import UIKit
import SnapKit

// MARK: 修改用户信息页面

/// 修改用户信息页面控制器
/// 核心作用：允许登录用户修改头像、用户名和简介。
/// 设计思路：头像通过媒体选择器获取并保存到临时目录，文本更新统一写入 `UserViewModel_Posture`。
/// UI 层分为渐变头像区、用户名输入卡、简介输入卡、保存按钮四块，整体可滚动。
/// 关键属性：`avatarView_Posture` 展示头像，`nameField_Posture` 与 `introView_Posture` 编辑资料。
/// 关键方法：`handleSave_Posture()` 校验登录并提交修改。
@MainActor
class EditInfo_Posture: UIViewController {

    // MARK: - 属性

    /// 用户头像
    private let avatarView_Posture = CurrentUserAvatarView_Posture()

    /// 用户名输入框
    private let nameField_Posture = UITextField()

    /// 简介输入框
    private let introView_Posture = UITextView()

    /// 新头像本地路径
    private var selectedAvatarPath_Posture: String?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        loadCurrentUser_Posture()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Posture()
        loadCurrentUser_Posture()

        // 点击背景收起键盘
        let tap_Posture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Posture))
        tap_Posture.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Posture)
    }

    // MARK: - UI 搭建

    /// 搭建编辑资料完整 UI
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupUI_Posture() {
        view.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        setupBackgroundGlows_Posture()

        // 滚动容器
        let scrollView_Posture = UIScrollView()
        scrollView_Posture.showsVerticalScrollIndicator = false
        scrollView_Posture.keyboardDismissMode = .interactive
        view.addSubview(scrollView_Posture)

        let contentView_Posture = UIView()
        scrollView_Posture.addSubview(contentView_Posture)
        scrollView_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Posture.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Posture.contentLayoutGuide)
            make.width.equalTo(scrollView_Posture.frameLayoutGuide)
        }

        // 顶部导航栏
        let navBar_Posture = buildNavBar_Posture()
        contentView_Posture.addSubview(navBar_Posture)

        // 头像英雄区
        let avatarSection_Posture = buildAvatarSection_Posture()
        contentView_Posture.addSubview(avatarSection_Posture)

        // 用户名输入卡
        let nameCard_Posture = buildFieldCard_Posture(
            icon: "person.fill",
            iconColor: ColorConfig_Posture.accentIndigo_Posture,
            label: "Username",
            hint: "How others will find you.",
            fieldView: nameField_Posture,
            fieldHeight: 54
        )
        configureField_Posture(nameField_Posture, placeholder: "e.g. DeskResetter")
        contentView_Posture.addSubview(nameCard_Posture)

        // 简介输入卡
        let bioCard_Posture = buildFieldCard_Posture(
            icon: "text.alignleft",
            iconColor: ColorConfig_Posture.accentTeal_Posture,
            label: "Bio",
            hint: "Tell your posture story in a few words.",
            fieldView: introView_Posture,
            fieldHeight: 120
        )
        configureTextView_Posture()
        contentView_Posture.addSubview(bioCard_Posture)

        // 保存按钮
        let saveSection_Posture = buildSaveSection_Posture()
        contentView_Posture.addSubview(saveSection_Posture)

        // 布局
        navBar_Posture.snp.makeConstraints { make in
            make.top.equalTo(contentView_Posture).offset(0)
            make.leading.trailing.equalToSuperview()
        }
        avatarSection_Posture.snp.makeConstraints { make in
            make.top.equalTo(navBar_Posture.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview()
        }
        nameCard_Posture.snp.makeConstraints { make in
            make.top.equalTo(avatarSection_Posture.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        bioCard_Posture.snp.makeConstraints { make in
            make.top.equalTo(nameCard_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        saveSection_Posture.snp.makeConstraints { make in
            make.top.equalTo(bioCard_Posture.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-40)
        }
    }

    // MARK: - 区块构建

    /// 搭建背景光晕装饰
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupBackgroundGlows_Posture() {
        [
            (ColorConfig_Posture.accentIndigo_Posture.withAlphaComponent(0.14), CGFloat(180), true,  -50.0),
            (ColorConfig_Posture.accentTeal_Posture.withAlphaComponent(0.12),   CGFloat(140), false, 400.0),
            (ColorConfig_Posture.accentFuchsia_Posture.withAlphaComponent(0.1), CGFloat(110), true,  560.0),
        ].forEach { cfg_Posture in
            let blob_Posture = UIView()
            blob_Posture.backgroundColor = cfg_Posture.0
            blob_Posture.layer.cornerRadius = cfg_Posture.1 / 2
            blob_Posture.isUserInteractionEnabled = false
            view.insertSubview(blob_Posture, at: 0)
            blob_Posture.snp.makeConstraints { make in
                if cfg_Posture.2 { make.trailing.equalToSuperview().offset(cfg_Posture.3)
                } else { make.leading.equalToSuperview().offset(cfg_Posture.3) }
                make.top.equalToSuperview().offset(cfg_Posture.3 > 200 ? cfg_Posture.3 : 30)
                make.width.height.equalTo(cfg_Posture.1)
            }
        }
    }

    /// 构建顶部导航栏（返回 + 标题）
    /// - Parameters: 无
    /// - Returns: UIView - 导航栏视图
    /// - Throws: 无
    private func buildNavBar_Posture() -> UIView {
        let container_Posture = UIView()

        let backButton_Posture = UIButton(type: .system)
        backButton_Posture.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton_Posture.tintColor = ColorConfig_Posture.textPrimary_Posture
        backButton_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        backButton_Posture.layer.cornerRadius = 22
        backButton_Posture.layer.shadowColor = ColorConfig_Posture.shadowColor_Posture.cgColor
        backButton_Posture.layer.shadowOpacity = 1
        backButton_Posture.layer.shadowRadius = 8
        backButton_Posture.layer.shadowOffset = CGSize(width: 0, height: 4)
        backButton_Posture.addAction(UIAction { _ in Navigation_Posture.pop_Posture() }, for: .touchUpInside)

        let titleLabel_Posture = UILabel()
        titleLabel_Posture.text = "Edit Profile"
        titleLabel_Posture.font = .systemFont(ofSize: 20, weight: .heavy)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        container_Posture.addSubview(backButton_Posture)
        container_Posture.addSubview(titleLabel_Posture)

        backButton_Posture.snp.makeConstraints { make in
            make.top.equalTo(container_Posture).offset(0)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(44)
            // safeArea 通过 snp.makeConstraints 在当前上下文不可用，使用固定的大值兼容
        }
        titleLabel_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(backButton_Posture)
            make.leading.equalTo(backButton_Posture.snp.trailing).offset(14)
        }
        container_Posture.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        // 把返回按钮放在 safeArea 下方：用 topLayoutGuide 替代
        backButton_Posture.snp.remakeConstraints { make in
            make.bottom.equalToSuperview().offset(-16)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(44)
        }
        titleLabel_Posture.snp.remakeConstraints { make in
            make.centerY.equalTo(backButton_Posture)
            make.leading.equalTo(backButton_Posture.snp.trailing).offset(14)
        }

        return container_Posture
    }

    /// 构建头像英雄区（渐变背景 + 居中头像 + 相机按钮 + 提示）
    /// - Parameters: 无
    /// - Returns: UIView - 头像区视图
    /// - Throws: 无
    private func buildAvatarSection_Posture() -> UIView {
        let hero_Posture = UIView()
        hero_Posture.layer.cornerRadius = 36
        hero_Posture.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        hero_Posture.clipsToBounds = true

        let grad_Posture = CAGradientLayer()
        grad_Posture.colors = [
            ColorConfig_Posture.accentIndigo_Posture.cgColor,
            ColorConfig_Posture.primaryGradientStart_Posture.cgColor,
            ColorConfig_Posture.accentTeal_Posture.cgColor
        ]
        grad_Posture.startPoint = CGPoint(x: 0, y: 0)
        grad_Posture.endPoint   = CGPoint(x: 1, y: 1)
        hero_Posture.layer.insertSublayer(grad_Posture, at: 0)

        // 装饰泡泡
        let bubble1_Posture = makeDecorBubble_Posture(size: 90, alpha: 0.13)
        let bubble2_Posture = makeDecorBubble_Posture(size: 56, alpha: 0.1)

        // 头像外环
        let ringView_Posture = UIView()
        ringView_Posture.backgroundColor = .white
        ringView_Posture.layer.cornerRadius = 60

        let innerRing_Posture = UIView()
        innerRing_Posture.backgroundColor = ColorConfig_Posture.accentIndigo_Posture
        innerRing_Posture.layer.cornerRadius = 56
        ringView_Posture.addSubview(innerRing_Posture)
        innerRing_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(112)
        }

        avatarView_Posture.layer.cornerRadius = 50
        avatarView_Posture.clipsToBounds = true
        avatarView_Posture.onTapped_Posture = { [weak self] in self?.pickAvatar_Posture() }
        ringView_Posture.addSubview(avatarView_Posture)
        avatarView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(100)
        }

        // 相机编辑按钮
        let cameraBtn_Posture = UIButton(type: .system)
        cameraBtn_Posture.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        cameraBtn_Posture.tintColor = .white
        cameraBtn_Posture.backgroundColor = ColorConfig_Posture.accentFuchsia_Posture
        cameraBtn_Posture.layer.cornerRadius = 18
        cameraBtn_Posture.layer.borderWidth = 3
        cameraBtn_Posture.layer.borderColor = UIColor.white.cgColor
        cameraBtn_Posture.addAction(UIAction { [weak self] _ in self?.pickAvatar_Posture() }, for: .touchUpInside)

        // 提示文字
        let hintLabel_Posture = UILabel()
        hintLabel_Posture.text = "Tap to change photo"
        hintLabel_Posture.font = .systemFont(ofSize: 12, weight: .bold)
        hintLabel_Posture.textColor = UIColor.white.withAlphaComponent(0.78)

        hero_Posture.addSubview(bubble1_Posture)
        hero_Posture.addSubview(bubble2_Posture)
        hero_Posture.addSubview(ringView_Posture)
        hero_Posture.addSubview(cameraBtn_Posture)
        hero_Posture.addSubview(hintLabel_Posture)

        bubble1_Posture.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(-20)
            make.width.height.equalTo(90)
        }
        bubble2_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(22)
            make.width.height.equalTo(56)
        }
        ringView_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(120)
        }
        cameraBtn_Posture.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(ringView_Posture).inset(-2)
            make.width.height.equalTo(36)
        }
        hintLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(ringView_Posture.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-22)
        }

        DispatchQueue.main.async { grad_Posture.frame = hero_Posture.bounds }
        return hero_Posture
    }

    /// 构建带图标标签的输入卡片
    /// - Parameters:
    ///   - icon: SF Symbols 图标名
    ///   - iconColor: 图标强调色
    ///   - label: 字段名称
    ///   - hint: 提示文字
    ///   - fieldView: 输入视图（UITextField 或 UITextView）
    ///   - fieldHeight: 输入视图高度
    /// - Returns: UIView - 输入卡片
    /// - Throws: 无
    private func buildFieldCard_Posture(icon: String, iconColor: UIColor, label: String, hint: String, fieldView: UIView, fieldHeight: CGFloat) -> UIView {
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 28
        card_Posture.layer.shadowColor  = ColorConfig_Posture.shadowColor_Posture.cgColor
        card_Posture.layer.shadowOpacity = 1
        card_Posture.layer.shadowRadius  = 14
        card_Posture.layer.shadowOffset  = CGSize(width: 0, height: 8)

        // 图标圆背景
        let iconBg_Posture = UIView()
        iconBg_Posture.backgroundColor = iconColor.withAlphaComponent(0.13)
        iconBg_Posture.layer.cornerRadius = 20

        let iconView_Posture = UIImageView(image: UIImage(systemName: icon))
        iconView_Posture.tintColor = iconColor
        iconView_Posture.contentMode = .scaleAspectFit
        iconBg_Posture.addSubview(iconView_Posture)
        iconView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }

        // 标签
        let labelView_Posture = UILabel()
        labelView_Posture.text = label
        labelView_Posture.font = .systemFont(ofSize: 17, weight: .heavy)
        labelView_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        // 提示
        let hintView_Posture = UILabel()
        hintView_Posture.text = hint
        hintView_Posture.font = .systemFont(ofSize: 12, weight: .medium)
        hintView_Posture.textColor = ColorConfig_Posture.textSecondary_Posture

        // 顶部颜色细条
        let stripe_Posture = UIView()
        stripe_Posture.backgroundColor = iconColor
        stripe_Posture.layer.cornerRadius = 3

        card_Posture.addSubview(stripe_Posture)
        card_Posture.addSubview(iconBg_Posture)
        card_Posture.addSubview(labelView_Posture)
        card_Posture.addSubview(hintView_Posture)
        card_Posture.addSubview(fieldView)

        stripe_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.leading.equalToSuperview().offset(22)
            make.width.equalTo(4)
            make.height.equalTo(44)
        }
        iconBg_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.leading.equalTo(stripe_Posture.snp.trailing).offset(12)
            make.width.height.equalTo(40)
        }
        labelView_Posture.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Posture)
            make.leading.equalTo(iconBg_Posture.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(20)
        }
        hintView_Posture.snp.makeConstraints { make in
            make.top.equalTo(labelView_Posture.snp.bottom).offset(3)
            make.leading.trailing.equalTo(labelView_Posture)
        }
        fieldView.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Posture.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(fieldHeight)
            make.bottom.equalToSuperview().inset(18)
        }

        return card_Posture
    }

    /// 构建保存按钮区
    /// - Parameters: 无
    /// - Returns: UIView - 保存按钮容器
    /// - Throws: 无
    private func buildSaveSection_Posture() -> UIView {
        let container_Posture = UIView()

        // 渐变按钮容器
        let btnContainer_Posture = UIView()
        btnContainer_Posture.layer.cornerRadius = 28
        btnContainer_Posture.clipsToBounds = true
        btnContainer_Posture.layer.shadowColor = ColorConfig_Posture.accentIndigo_Posture.cgColor
        btnContainer_Posture.layer.shadowOpacity = 0.4
        btnContainer_Posture.layer.shadowRadius  = 16
        btnContainer_Posture.layer.shadowOffset  = CGSize(width: 0, height: 10)

        let gradLayer_Posture = CAGradientLayer()
        gradLayer_Posture.colors = [
            ColorConfig_Posture.accentIndigo_Posture.cgColor,
            ColorConfig_Posture.primaryGradientStart_Posture.cgColor,
            ColorConfig_Posture.accentTeal_Posture.cgColor
        ]
        gradLayer_Posture.startPoint = CGPoint(x: 0, y: 0)
        gradLayer_Posture.endPoint   = CGPoint(x: 1, y: 0)
        btnContainer_Posture.layer.insertSublayer(gradLayer_Posture, at: 0)

        let saveButton_Posture = UIButton(type: .system)
        saveButton_Posture.setTitle("Save Changes", for: .normal)
        saveButton_Posture.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        saveButton_Posture.tintColor = .white
        saveButton_Posture.setTitleColor(.white, for: .normal)
        saveButton_Posture.titleLabel?.font = .systemFont(ofSize: 17, weight: .heavy)
        saveButton_Posture.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        saveButton_Posture.addAction(UIAction { [weak self] _ in self?.handleSave_Posture() }, for: .touchUpInside)

        btnContainer_Posture.addSubview(saveButton_Posture)
        saveButton_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }

        container_Posture.addSubview(btnContainer_Posture)
        btnContainer_Posture.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(58)
        }

        DispatchQueue.main.async { gradLayer_Posture.frame = btnContainer_Posture.bounds }
        return container_Posture
    }

    // MARK: - 辅助视图

    /// 创建装饰泡泡
    private func makeDecorBubble_Posture(size: CGFloat, alpha: CGFloat) -> UIView {
        let v_Posture = UIView()
        v_Posture.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Posture.layer.cornerRadius = size / 2
        v_Posture.isUserInteractionEnabled = false
        return v_Posture
    }

    // MARK: - 输入控件配置

    /// 配置用户名输入框样式
    /// - Parameter field: 输入框
    /// - Parameter placeholder: 占位文本
    /// - Returns: Void
    /// - Throws: 无
    private func configureField_Posture(_ field: UITextField, placeholder: String) {
        field.placeholder = placeholder
        field.font = .systemFont(ofSize: 15, weight: .semibold)
        field.textColor = ColorConfig_Posture.textPrimary_Posture
        field.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        field.layer.cornerRadius = 18
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        field.leftViewMode = .always
    }

    /// 配置简介 TextView 样式
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func configureTextView_Posture() {
        introView_Posture.font = .systemFont(ofSize: 15, weight: .medium)
        introView_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        introView_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        introView_Posture.layer.cornerRadius = 18
        introView_Posture.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
    }

    // MARK: - 事件处理

    /// 收起键盘
    @objc private func dismissKeyboard_Posture() { view.endEditing(true) }

    // MARK: - 业务逻辑（保持不变）

    /// 加载当前用户资料
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func loadCurrentUser_Posture() {
        guard isViewLoaded else { return }
        let user_Posture = UserViewModel_Posture.shared_Posture.getCurrentUser_Posture()
        nameField_Posture.text = user_Posture.userName_Posture
        introView_Posture.text = user_Posture.userIntroduce_Posture ?? "Better posture starts with one mindful break."
        avatarView_Posture.loadCurrentUserAvatar_Posture()
    }

    /// 选择头像
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func pickAvatar_Posture() {
        MediaPickerHelper_Posture.pickImage_Posture(from: self) { [weak self] image_Posture in
            guard let self_Posture = self, let image_Posture else { return }
            self_Posture.avatarView_Posture.configureWithImageIfNeeded_Posture(image_Posture: image_Posture)
            self_Posture.selectedAvatarPath_Posture = self_Posture.saveAvatarImage_Posture(image_Posture: image_Posture)
        }
    }

    /// 保存头像到临时目录
    /// - Parameter image_Posture: 头像图片
    /// - Returns: String? - 保存成功时返回本地路径
    /// - Throws: 无
    private func saveAvatarImage_Posture(image_Posture: UIImage) -> String? {
        guard let data_Posture = image_Posture.jpegData(compressionQuality: 0.86) else { return nil }
        let url_Posture = FileManager.default.temporaryDirectory.appendingPathComponent("avatar_posture_\(Date().timeIntervalSince1970).jpg")
        do {
            try data_Posture.write(to: url_Posture)
            return url_Posture.path
        } catch {
            print("头像保存失败: \(error.localizedDescription)")
            return nil
        }
    }

    /// 保存用户资料
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func handleSave_Posture() {
        guard UserViewModel_Posture.shared_Posture.isLoggedIn_Posture else {
            Navigation_Posture.toLogin_Posture(style_posture: .present_posture)
            return
        }
        let name_Posture = (nameField_Posture.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let intro_Posture = introView_Posture.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name_Posture.isEmpty else {
            Utils_Posture.showWarning_Posture(message_Posture: "Username is required.")
            return
        }
        if let path_Posture = selectedAvatarPath_Posture {
            UserViewModel_Posture.shared_Posture.updateHead_Posture(headUrl_posture: path_Posture)
        }
        UserViewModel_Posture.shared_Posture.updateName_Posture(userName_posture: name_Posture)
        UserViewModel_Posture.shared_Posture.updateIntroduce_Posture(introduce_posture: intro_Posture.isEmpty ? "Better posture starts with one mindful break." : intro_Posture)
        Navigation_Posture.pop_Posture()
    }
}

// MARK: - CurrentUserAvatarView 扩展

private extension CurrentUserAvatarView_Posture {
    /// 直接展示已选择头像
    /// - Parameter image_Posture: 用户从相册选择的图片
    /// - Returns: Void
    /// - Throws: 无
    func configureWithImageIfNeeded_Posture(image_Posture: UIImage) {
        imageView_Posture.image = image_Posture
        imageView_Posture.contentMode = .scaleAspectFill
    }
}
