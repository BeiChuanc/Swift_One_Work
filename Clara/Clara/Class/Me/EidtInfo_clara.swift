import Foundation
import UIKit
import SnapKit

// MARK: - 修改用户信息页面

/// 修改用户信息页面
/// 核心功能：允许已登录用户修改头像、昵称和个人简介
/// 设计思路：顶部高渐变 Banner（含装饰圆圈和引导文字）→ 浮出头像（带渐变光环阴影）
///           → 表单卡片（Nickname / Bio）→ 渐变保存按钮；
///           头像区叠加相机图标提示可编辑，Bio 卡片底部显示字数统计
/// 关键属性：
/// - selectedImage_Clara: 用户从相册选择的新头像图片（nil 表示未修改）
/// - originalName_Clara / originalBio_Clara: 缓存的原始值，保存时未修改则使用原值
/// 关键方法：
/// - loadCurrentUserData_Clara: 从 UserViewModel 填充默认表单值
/// - saveTapped_Clara: 保存逻辑（校验登录 → 读取表单 → 调用 ViewModel 更新）
/// - pickAvatar_Clara: 调用 MediaPickerHelper 打开相册选择头像
class EditInfo_Clara: UIViewController {

    // MARK: - 数据属性

    /// 用户从相册选取的新头像（nil 表示未修改）
    private var selectedImage_Clara: UIImage?

    /// 原始昵称（用于未修改时保留原值）
    private var originalName_Clara: String = ""

    /// 原始简介（用于未修改时保留原值）
    private var originalBio_Clara: String = ""

    // MARK: - UI 组件

    private let scrollView_Clara: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.keyboardDismissMode = .onDrag
        return sv
    }()

    private let contentView_Clara = UIView()

    /// 顶部渐变 Banner
    private let topBanner_Clara = UIView()

    /// Banner 渐变图层
    private var topBannerGl_Clara: CAGradientLayer?

    /// 头像白色底衬（光晕效果）
    private let avatarGlowBg_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white
        v.layer.cornerRadius = 56
        return v
    }()

    /// 头像容器
    private let avatarContainer_Clara = UIView()

    /// 头像视图
    private let avatarView_Clara: CurrentUserAvatarView_Clara = {
        let v = CurrentUserAvatarView_Clara()
        return v
    }()

    /// 相机遮罩
    private let cameraOverlay_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.36)
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 相机图标
    private let cameraIcon_Clara: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        iv.image = UIImage(systemName: "camera.fill", withConfiguration: cfg)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        return iv
    }()

    /// 昵称输入框
    private let nameField_Clara: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter your nickname"
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = ColorConfig_Clara.textPrimary_Clara
        tf.borderStyle = .none
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .next
        return tf
    }()

    /// 简介输入框
    private let bioTextView_Clara: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.textColor = ColorConfig_Clara.textPrimary_Clara
        tv.backgroundColor = .clear
        tv.returnKeyType = .done
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }()

    /// 简介占位符
    private let bioPlaceholder_Clara: UILabel = {
        let l = UILabel()
        l.text = "Write something about yourself..."
        l.font = UIFont.systemFont(ofSize: 15)
        l.textColor = ColorConfig_Clara.textPlaceholder_Clara
        return l
    }()

    /// 简介字数统计标签
    private let bioCountLabel_Clara: UILabel = {
        let l = UILabel()
        l.text = "0 / 80"
        l.font = UIFont.systemFont(ofSize: 11)
        l.textColor = ColorConfig_Clara.textPlaceholder_Clara
        l.textAlignment = .right
        return l
    }()

    /// 保存按钮
    private let saveButton_Clara: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.setTitle("  Save Changes", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 24
        return btn
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 完全隐藏导航栏，使用 Banner 内嵌的自定义返回按钮
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyThemeBackground_Clara()
        setupScrollView_Clara()
        setupTopBanner_Clara()
        setupAvatarArea_Clara()
        setupFormFields_Clara()
        setupSaveButton_Clara()
        loadCurrentUserData_Clara()
        // 最后添加返回按钮，确保 z-order 在 ScrollView 之上
        setupNavigationBar_Clara()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gl = topBannerGl_Clara {
            gl.frame = topBanner_Clara.bounds
        } else if topBanner_Clara.bounds.width > 0 {
            let gl = UIColor.createPrimaryGradientLayer_Clara(frame_Clara: topBanner_Clara.bounds)
            topBanner_Clara.layer.insertSublayer(gl, at: 0)
            topBannerGl_Clara = gl
        }
        view.updateThemeBackgroundFrame_Clara()
        avatarContainer_Clara.layer.cornerRadius = 46
        avatarContainer_Clara.clipsToBounds = true
        cameraOverlay_Clara.layer.cornerRadius = 46
    }

    // MARK: - 导航栏

    // MARK: - 自定义返回按钮

    /// 在 Banner 左上角嵌入自定义返回按钮，与渐变背景融合
    private func setupNavigationBar_Clara() {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn.setImage(UIImage(systemName: "arrow.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
        btn.addTarget(self, action: #selector(backTapped_Clara), for: .touchUpInside)
    }

    // MARK: - UI 搭建

    private func setupScrollView_Clara() {
        view.addSubview(scrollView_Clara)
        scrollView_Clara.addSubview(contentView_Clara)
        // 透明背景，使 view 层的多拼色渐变透出
        scrollView_Clara.backgroundColor = .clear
        contentView_Clara.backgroundColor = .clear
        // 贴满整个 view（含状态栏区域），让 Banner 延伸到屏幕顶部
        scrollView_Clara.contentInsetAdjustmentBehavior = .never
        scrollView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    /// 顶部渐变 Banner（含装饰圆圈与引导文字）
    private func setupTopBanner_Clara() {
        contentView_Clara.addSubview(topBanner_Clara)
        topBanner_Clara.layer.cornerRadius = 28
        topBanner_Clara.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        topBanner_Clara.clipsToBounds = true
        topBanner_Clara.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(148)
        }

        // 装饰圆圈（右上）
        let circle1 = UIView()
        circle1.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        circle1.layer.cornerRadius = 55
        topBanner_Clara.addSubview(circle1)
        circle1.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.right.equalToSuperview().inset(-24)
            make.top.equalToSuperview().inset(-28)
        }

        // 装饰圆圈（左下）
        let circle2 = UIView()
        circle2.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        circle2.layer.cornerRadius = 36
        topBanner_Clara.addSubview(circle2)
        circle2.snp.makeConstraints { make in
            make.width.height.equalTo(72)
            make.left.equalToSuperview().inset(-20)
            make.bottom.equalToSuperview().inset(-22)
        }

        // Banner 标题
        let titleLabel = UILabel()
        titleLabel.text = "Update Your Profile"
        titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        titleLabel.textColor = .white
        topBanner_Clara.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(38)
        }

        let subLabel = UILabel()
        subLabel.text = "Let others know who you are ✨"
        subLabel.font = UIFont.systemFont(ofSize: 13)
        subLabel.textColor = UIColor.white.withAlphaComponent(0.82)
        topBanner_Clara.addSubview(subLabel)
        subLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(7)
        }
    }

    /// 头像区域（白色光晕底 + 可点击打开相册）
    private func setupAvatarArea_Clara() {
        // 光晕底衬
        contentView_Clara.addSubview(avatarGlowBg_Clara)
        avatarGlowBg_Clara.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(topBanner_Clara.snp.bottom).offset(-46)
            make.width.height.equalTo(112)
        }
        avatarGlowBg_Clara.layer.shadowColor = ColorConfig_Clara.primaryGradientStart_Clara.cgColor
        avatarGlowBg_Clara.layer.shadowOffset = .zero
        avatarGlowBg_Clara.layer.shadowOpacity = 0.28
        avatarGlowBg_Clara.layer.shadowRadius = 12

        // 头像容器
        contentView_Clara.addSubview(avatarContainer_Clara)
        avatarContainer_Clara.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(topBanner_Clara.snp.bottom).offset(-42)
            make.width.height.equalTo(100)
        }
        avatarContainer_Clara.addSubview(avatarView_Clara)
        avatarView_Clara.snp.makeConstraints { make in make.edges.equalToSuperview() }
        avatarView_Clara.onTapped_Clara = { [weak self] in
            self?.pickAvatar_Clara()
        }

        // 相机遮罩
        avatarContainer_Clara.addSubview(cameraOverlay_Clara)
        cameraOverlay_Clara.snp.makeConstraints { make in make.edges.equalToSuperview() }

        avatarContainer_Clara.addSubview(cameraIcon_Clara)
        cameraIcon_Clara.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(26)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(pickAvatar_Clara))
        avatarContainer_Clara.isUserInteractionEnabled = true
        avatarContainer_Clara.addGestureRecognizer(tap)

        // 提示文字
        let hintLabel = UILabel()
        hintLabel.text = "Tap photo to change"
        hintLabel.font = UIFont.systemFont(ofSize: 12)
        hintLabel.textColor = ColorConfig_Clara.textPlaceholder_Clara
        hintLabel.textAlignment = .center
        contentView_Clara.addSubview(hintLabel)
        hintLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(avatarContainer_Clara.snp.bottom).offset(8)
        }
    }

    /// 搭建昵称与简介表单卡片
    private func setupFormFields_Clara() {
        // 昵称卡片
        let nameCard = makeFieldCard_Clara(
            iconName: "person.fill",
            iconColor: ColorConfig_Clara.primaryGradientStart_Clara,
            labelText: "Nickname",
            inputView: nameField_Clara
        )
        contentView_Clara.addSubview(nameCard)
        nameCard.snp.makeConstraints { make in
            make.top.equalTo(avatarContainer_Clara.snp.bottom).offset(48)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(68)
        }
        nameField_Clara.delegate = self

        // 简介卡片
        let bioCard = makeFieldCard_Clara(
            iconName: "text.quote",
            iconColor: ColorConfig_Clara.primaryGradientEnd_Clara,
            labelText: "Bio",
            inputView: bioTextView_Clara
        )
        contentView_Clara.addSubview(bioCard)
        bioCard.snp.makeConstraints { make in
            make.top.equalTo(nameCard.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(112)
        }
        bioTextView_Clara.delegate = self

        // 简介占位符
        bioCard.addSubview(bioPlaceholder_Clara)
        bioPlaceholder_Clara.snp.makeConstraints { make in
            make.left.equalTo(bioTextView_Clara.snp.left)
            make.top.equalTo(bioTextView_Clara.snp.top).offset(1)
        }

        // 字数统计标签
        bioCard.addSubview(bioCountLabel_Clara)
        bioCountLabel_Clara.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(14)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    /// 创建带图标色块、字段标题和输入控件的表单卡片
    /// - Parameters:
    ///   - iconName: SF Symbol 图标名
    ///   - iconColor: 图标强调色
    ///   - labelText: 字段标题文字
    ///   - inputView: 嵌入的输入控件（UITextField 或 UITextView）
    /// - Returns: 配置好的卡片视图
    private func makeFieldCard_Clara(
        iconName: String,
        iconColor: UIColor,
        labelText: String,
        inputView: UIView
    ) -> UIView {
        let card = UIView()
        card.backgroundColor = ColorConfig_Clara.cardBackground_Clara
        card.layer.cornerRadius = 16
        card.layer.shadowColor = ColorConfig_Clara.shadowColor_Clara.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowOpacity = 1
        card.layer.shadowRadius = 8

        // 左侧色块图标
        let iconBg = UIView()
        iconBg.backgroundColor = iconColor.withAlphaComponent(0.12)
        iconBg.layer.cornerRadius = 10
        card.addSubview(iconBg)
        iconBg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }

        let icon = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        icon.image = UIImage(systemName: iconName, withConfiguration: cfg)
        icon.tintColor = iconColor
        icon.contentMode = .scaleAspectFit
        iconBg.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }

        // 字段标题
        let titleLabel = UILabel()
        titleLabel.text = labelText
        titleLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textColor = ColorConfig_Clara.textPlaceholder_Clara
        card.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconBg.snp.right).offset(10)
            make.top.equalToSuperview().offset(12)
        }

        card.addSubview(inputView)
        inputView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalToSuperview().inset(14)
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
            make.bottom.equalToSuperview().inset(10)
        }
        return card
    }

    /// 搭建保存按钮（渐变背景 + 图标）
    private func setupSaveButton_Clara() {
        contentView_Clara.addSubview(saveButton_Clara)
        saveButton_Clara.snp.makeConstraints { make in
            make.top.equalTo(avatarContainer_Clara.snp.bottom).offset(48 + 68 + 14 + 112 + 28)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(52)
            make.bottom.equalToSuperview().inset(30)
        }
        saveButton_Clara.addTarget(self, action: #selector(saveTapped_Clara), for: .touchUpInside)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let gl = UIColor.createPrimaryGradientLayer_Clara(frame_Clara: self.saveButton_Clara.bounds)
            gl.cornerRadius = 24
            self.saveButton_Clara.layer.insertSublayer(gl, at: 0)
        }
    }

    // MARK: - 数据填充

    /// 从 UserViewModel 加载当前登录用户的默认数据填入表单
    private func loadCurrentUserData_Clara() {
        let user = UserViewModel_Clara.shared_Clara.getCurrentUser_Clara()
        nameField_Clara.text = user.userName_Clara ?? ""
        originalName_Clara = user.userName_Clara ?? ""
        originalBio_Clara = user.userIntroduce_Clara ?? ""
        bioTextView_Clara.text = originalBio_Clara
        bioPlaceholder_Clara.isHidden = !originalBio_Clara.isEmpty
        bioCountLabel_Clara.text = "\(originalBio_Clara.count) / 80"
    }

    // MARK: - 事件响应

    @objc private func backTapped_Clara() {
        navigationController?.popViewController(animated: true)
    }

    /// 从相册选取头像
    @objc private func pickAvatar_Clara() {
        MediaPickerHelper_Clara.pickImage_Clara(from: self) { [weak self] image in
            guard let self = self, let img = image else { return }
            self.selectedImage_Clara = img
            self.avatarView_Clara.imageView_Clara.image = img
            self.avatarView_Clara.imageView_Clara.contentMode = .scaleAspectFill
        }
    }

    /// 保存修改（校验登录 → 写入 ViewModel）
    @objc private func saveTapped_Clara() {
        guard UserViewModel_Clara.shared_Clara.isLoggedIn_Clara else {
            Task {
                 try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
                 Navigation_Clara.toLogin_Clara(style_clara: .present_clara)
             }
            return
        }

        let newName = nameField_Clara.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = (newName?.isEmpty == false) ? newName! : originalName_Clara
        let finalBio = bioTextView_Clara.text.trimmingCharacters(in: .whitespacesAndNewlines)

        if finalName != originalName_Clara {
            UserViewModel_Clara.shared_Clara.updateName_Clara(userName_clara: finalName)
        }
        if finalBio != originalBio_Clara {
            UserViewModel_Clara.shared_Clara.updateIntroduce_Clara(userIntroduce_clara: finalBio)
        }

        if let img = selectedImage_Clara {
            let tempPath = saveImageToTemp_Clara(image: img)
            UserViewModel_Clara.shared_Clara.updateHead_Clara(headUrl_clara: tempPath)
        }

        navigationController?.popViewController(animated: true)
    }

    /// 将选取的图片临时存储并返回路径
    /// - Parameter image: 要存储的图片
    /// - Returns: 临时文件路径字符串
    private func saveImageToTemp_Clara(image: UIImage) -> String {
        let fileName = "avatar_\(Int(Date().timeIntervalSince1970)).jpg"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: url)
        }
        return url.path
    }
}

// MARK: - UITextFieldDelegate

extension EditInfo_Clara: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        bioTextView_Clara.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension EditInfo_Clara: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        bioPlaceholder_Clara.isHidden = !textView.text.isEmpty
        let count = textView.text.count
        bioCountLabel_Clara.text = "\(count) / 80"
        bioCountLabel_Clara.textColor = count > 80
            ? .systemRed
            : ColorConfig_Clara.textPlaceholder_Clara
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
