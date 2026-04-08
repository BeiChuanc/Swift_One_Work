import Foundation
import UIKit
import SnapKit

// MARK: 修改我的信息

/// 修改用户信息页面
/// 核心作用：允许登录用户修改头像、昵称及个人简介
/// 设计思路：三色渐变沉浸式头部（含粒子浮球装饰）+ 三层头像圆环 + 现代卡片表单
///          头部固定展示，表单区域可滚动避让键盘
class EditInfo_Somnia: UIViewController {

    // MARK: - 私有属性

    /// 用户是否选了新头像（nil 表示未变更）
    private var newAvatarImage_Somnia: UIImage?

    /// 头部区域高度常量
    private let headerH_Somnia: CGFloat = 260

    // MARK: - UI组件 — 背景与头部

    private var _gradientLayer_Somnia: CAGradientLayer?

    /// 返回按钮
    private let backButton_Somnia = BackButton_Somnia()

    /// 页面主标题
    private let titleLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "Edit Profile"
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = .white
        lbl.layer.shadowColor = UIColor.black.cgColor
        lbl.layer.shadowOpacity = 0.15
        lbl.layer.shadowRadius = 4
        return lbl
    }()

    /// 页面副标题
    private let subtitleLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "Customize your profile"
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.72)
        lbl.textAlignment = .center
        return lbl
    }()

    // MARK: - UI组件 — 头像

    /// 头像最外层渐变环（100pt）
    private let avatarOuterRing_Somnia: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 50
        v.clipsToBounds = true
        return v
    }()

    private var avatarRingGradient_Somnia: CAGradientLayer?

    /// 头像白色内边框（90pt）
    private let avatarWhiteBorder_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 45
        return v
    }()

    /// 头像视图（80pt，支持点击更换）
    private let avatarView_Somnia: CurrentUserAvatarView_Somnia = {
        let v = CurrentUserAvatarView_Somnia()
        v.layer.cornerRadius = 40
        v.clipsToBounds = true
        return v
    }()

    /// 相机图标
    private let cameraIconView_Somnia: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        iv.image = UIImage(systemName: "camera.fill", withConfiguration: cfg)
        iv.tintColor = UIColor.white.withAlphaComponent(0.85)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 修改头像提示文字
    private let changePhotoLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "Tap to change photo"
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = UIColor.white.withAlphaComponent(0.85)
        return lbl
    }()

    // MARK: - UI组件 — 表单区域（ScrollView）

    private let scrollView_Somnia: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let formContent_Somnia = UIView()

    /// 表单卡片（仅顶部圆角，与背景融合）
    private let formCard_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: -6)
        v.layer.shadowRadius = 20
        v.layer.shadowOpacity = 0.07
        return v
    }()

    // MARK: - UI组件 — 昵称字段

    /// 昵称区域标签
    private let nameSectionLabel_Somnia = EditInfo_Somnia.makeFieldLabel_Somnia("Display Name")

    /// 昵称输入框容器
    private let nameContainer_Somnia = EditInfo_Somnia.makeFieldContainer_Somnia()

    /// 昵称字段图标
    private let nameIconView_Somnia = EditInfo_Somnia.makeFieldIcon_Somnia("person.fill")

    /// 昵称输入框
    private let nameField_Somnia: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter your name"
        tf.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tf.textColor = ColorConfig_Somnia.textPrimary_Somnia
        tf.autocorrectionType = .no
        tf.returnKeyType = .next
        return tf
    }()

    // MARK: - UI组件 — 简介字段

    /// 简介区域标签
    private let bioSectionLabel_Somnia = EditInfo_Somnia.makeFieldLabel_Somnia("Bio")

    /// 简介输入框容器
    private let bioContainer_Somnia = EditInfo_Somnia.makeFieldContainer_Somnia()

    /// 简介字段图标
    private let bioIconView_Somnia = EditInfo_Somnia.makeFieldIcon_Somnia("text.alignleft")

    /// 简介输入框
    private let bioField_Somnia: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tv.textColor = ColorConfig_Somnia.textPrimary_Somnia
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        tv.isScrollEnabled = false
        return tv
    }()

    /// 简介字符计数标签
    private let bioCountLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "0 / 80"
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl.textColor = ColorConfig_Somnia.textPlaceholder_Somnia
        lbl.textAlignment = .right
        return lbl
    }()

    // MARK: - UI组件 — 保存按钮

    /// 保存按钮
    private let saveButton_Somnia: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 16
        btn.layer.masksToBounds = true
        return btn
    }()

    private var saveGradient_Somnia: CAGradientLayer?

    // MARK: - 工厂方法（静态辅助）

    /// 创建字段分组标签
    private static func makeFieldLabel_Somnia(_ text: String) -> UILabel {
        let lbl = UILabel()
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .bold),
            .foregroundColor: ColorConfig_Somnia.textSecondary_Somnia,
            .kern: 0.8
        ]
        lbl.attributedText = NSAttributedString(string: text.uppercased(), attributes: attrs)
        return lbl
    }

    /// 创建输入框容器卡片
    private static func makeFieldContainer_Somnia() -> UIView {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 14
        v.layer.borderColor = ColorConfig_Somnia.divider_Somnia.cgColor
        v.layer.borderWidth = 1.0
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 6
        v.layer.shadowOpacity = 0.04
        return v
    }

    /// 创建字段左侧图标
    private static func makeFieldIcon_Somnia(_ name: String) -> UIImageView {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        iv.image = UIImage(systemName: name, withConfiguration: cfg)
        iv.tintColor = ColorConfig_Somnia.primaryGradientStart_Somnia
        iv.contentMode = .scaleAspectFit
        return iv
    }

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        fillDefaultData_Somnia()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Somnia()
        setupActions_Somnia()
        setupKeyboardObservers_Somnia()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _gradientLayer_Somnia?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: headerH_Somnia)
        saveGradient_Somnia?.frame = saveButton_Somnia.bounds
        if avatarRingGradient_Somnia == nil {
            let g = CAGradientLayer()
            g.colors = [
                ColorConfig_Somnia.secondaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
            ]
            g.startPoint = CGPoint(x: 0, y: 0)
            g.endPoint   = CGPoint(x: 1, y: 1)
            g.frame = avatarOuterRing_Somnia.bounds
            avatarOuterRing_Somnia.layer.insertSublayer(g, at: 0)
            avatarRingGradient_Somnia = g
        }
        avatarRingGradient_Somnia?.frame = avatarOuterRing_Somnia.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 私有方法 — UI设置

    private func setupUI_Somnia() {
        view.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia

        // ── 三色渐变头部背景 ──
        let gradient_Somnia = CAGradientLayer()
        gradient_Somnia.colors = [
            UIColor(hexstring_Somnia: "#C4B5FD").cgColor,
            ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
            ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
        ]
        gradient_Somnia.locations = [0.0, 0.45, 1.0]
        gradient_Somnia.startPoint = CGPoint(x: 0.1, y: 0)
        gradient_Somnia.endPoint   = CGPoint(x: 0.9, y: 1)
        gradient_Somnia.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: headerH_Somnia)
        view.layer.insertSublayer(gradient_Somnia, at: 0)
        _gradientLayer_Somnia = gradient_Somnia

        // ── 浮动装饰球 ──
        addDecorOrbs_Somnia()

        // ── 头部视图 ──
        view.addSubview(backButton_Somnia)
        view.addSubview(titleLabel_Somnia)
        view.addSubview(subtitleLabel_Somnia)

        // ── 头像三层环 ──
        view.addSubview(avatarOuterRing_Somnia)
        avatarOuterRing_Somnia.addSubview(avatarWhiteBorder_Somnia)
        avatarWhiteBorder_Somnia.addSubview(avatarView_Somnia)

        // ── 相机提示 ──
        view.addSubview(cameraIconView_Somnia)
        view.addSubview(changePhotoLabel_Somnia)

        // ── 滚动区域 ──
        view.addSubview(scrollView_Somnia)
        scrollView_Somnia.addSubview(formContent_Somnia)
        formContent_Somnia.addSubview(formCard_Somnia)

        // ── 表单卡片内容 ──
        formCard_Somnia.addSubview(nameSectionLabel_Somnia)
        formCard_Somnia.addSubview(nameContainer_Somnia)
        nameContainer_Somnia.addSubview(nameIconView_Somnia)
        nameContainer_Somnia.addSubview(nameField_Somnia)

        formCard_Somnia.addSubview(bioSectionLabel_Somnia)
        formCard_Somnia.addSubview(bioContainer_Somnia)
        bioContainer_Somnia.addSubview(bioIconView_Somnia)
        bioContainer_Somnia.addSubview(bioField_Somnia)
        bioContainer_Somnia.addSubview(bioCountLabel_Somnia)

        formCard_Somnia.addSubview(saveButton_Somnia)

        setupConstraints_Somnia()
        setupSaveButtonStyle_Somnia()
    }

    /// 布局所有约束
    private func setupConstraints_Somnia() {

        // 返回按钮
        backButton_Somnia.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(44)
        }

        // 主标题（居中，与返回按钮同高）
        titleLabel_Somnia.snp.makeConstraints { make in
            make.centerY.equalTo(backButton_Somnia)
            make.centerX.equalToSuperview()
        }

        // 副标题
        subtitleLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Somnia.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        // 头像外环（100pt）
        avatarOuterRing_Somnia.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Somnia.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }

        // 白色内边框（90pt，居中于外环）
        avatarWhiteBorder_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(90)
        }

        // 头像（80pt，居中于白色内边框）
        avatarView_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }

        // 相机图标 + 提示文字（水平排列于头像正下方）
        cameraIconView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(avatarOuterRing_Somnia.snp.bottom).offset(10)
            make.right.equalTo(changePhotoLabel_Somnia.snp.left).offset(-4)
            make.centerY.equalTo(changePhotoLabel_Somnia)
            make.width.height.equalTo(13)
        }

        changePhotoLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(avatarOuterRing_Somnia.snp.bottom).offset(10)
            make.centerX.equalToSuperview().offset(9)
        }

        // 滚动视图（从头部底部延伸到底部安全区）
        scrollView_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(headerH_Somnia - 28)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        formContent_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        // 表单卡片（圆角顶部覆盖，延伸到底部）
        formCard_Somnia.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.greaterThanOrEqualToSuperview().offset(-20)
        }

        // ── 昵称字段 ──
        nameSectionLabel_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.left.equalToSuperview().offset(24)
        }

        nameContainer_Somnia.snp.makeConstraints { make in
            make.top.equalTo(nameSectionLabel_Somnia.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(54)
        }

        nameIconView_Somnia.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }

        nameField_Somnia.snp.makeConstraints { make in
            make.left.equalTo(nameIconView_Somnia.snp.right).offset(12)
            make.right.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview()
        }

        // ── 简介字段 ──
        bioSectionLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(nameContainer_Somnia.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(24)
        }

        bioContainer_Somnia.snp.makeConstraints { make in
            make.top.equalTo(bioSectionLabel_Somnia.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }

        bioIconView_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(18)
        }

        bioField_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.left.equalTo(bioIconView_Somnia.snp.right).offset(12)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(110)
        }

        bioCountLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(bioField_Somnia.snp.bottom).offset(6)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-10)
        }

        // ── 保存按钮 ──
        saveButton_Somnia.snp.makeConstraints { make in
            make.top.equalTo(bioContainer_Somnia.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-40)
        }
    }

    /// 构建保存按钮的渐变样式与图标
    private func setupSaveButtonStyle_Somnia() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let grad = CAGradientLayer()
            grad.colors = [
                ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
            ]
            grad.startPoint = CGPoint(x: 0, y: 0)
            grad.endPoint   = CGPoint(x: 1, y: 0)
            grad.frame = self.saveButton_Somnia.bounds
            self.saveButton_Somnia.layer.insertSublayer(grad, at: 0)
            self.saveGradient_Somnia = grad

            // 图标 + 文字使用 UIButton.Configuration
            var cfg = UIButton.Configuration.plain()
            cfg.title = "Save Changes"
            cfg.image = UIImage(systemName: "checkmark.circle.fill",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold))
            cfg.imagePadding = 8
            cfg.imagePlacement = .leading
            cfg.baseForegroundColor = .white
            cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var out = incoming
                out.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
                return out
            }
            self.saveButton_Somnia.configuration = cfg
        }
    }

    /// 添加头部浮动装饰半透明球
    private func addDecorOrbs_Somnia() {
        let w = view.bounds.width
        let configs: [(x: CGFloat, y: CGFloat, r: CGFloat, a: CGFloat)] = [
            (w - 30, 60,  55, 0.10),
            (20,     140, 45, 0.08),
            (w * 0.55, 20, 30, 0.12)
        ]
        for c in configs {
            let orb = UIView(frame: CGRect(x: c.x - c.r, y: c.y - c.r,
                                          width: c.r * 2, height: c.r * 2))
            orb.backgroundColor = UIColor.white.withAlphaComponent(c.a)
            orb.layer.cornerRadius = c.r
            view.insertSubview(orb, at: 1)
        }
    }

    // MARK: - 私有方法 — 键盘处理

    /// 注册键盘弹出/收起通知
    private func setupKeyboardObservers_Somnia() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Somnia(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Somnia(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    /// 键盘弹出时调整 scrollView 内边距
    @objc private func keyboardWillShow_Somnia(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        UIView.animate(withDuration: duration) {
            self.scrollView_Somnia.contentInset.bottom = frame.height + 20
        }
    }

    /// 键盘收起时还原内边距
    @objc private func keyboardWillHide_Somnia(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        UIView.animate(withDuration: duration) {
            self.scrollView_Somnia.contentInset.bottom = 0
        }
    }

    // MARK: - 私有方法 — 事件绑定

    private func setupActions_Somnia() {
        backButton_Somnia.onTapped_Somnia = {
            Navigation_Somnia.pop_Somnia()
        }

        avatarView_Somnia.onTapped_Somnia = { [weak self] in
            self?.pickAvatarImage_Somnia()
        }

        saveButton_Somnia.addAction(UIAction { [weak self] _ in
            self?.handleSave_Somnia()
        }, for: .touchUpInside)

        // 保存按钮按压弹簧动画
        saveButton_Somnia.addAction(UIAction { [weak self] _ in
            UIView.animate(withDuration: 0.1) {
                self?.saveButton_Somnia.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            }
        }, for: .touchDown)
        saveButton_Somnia.addAction(UIAction { [weak self] _ in
            UIView.animate(withDuration: 0.3, delay: 0,
                           usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0.5) {
                self?.saveButton_Somnia.transform = .identity
            }
        }, for: [.touchUpInside, .touchUpOutside, .touchCancel])

        bioField_Somnia.delegate = self

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Somnia))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - 私有方法 — 数据

    /// 填充当前用户的默认数据
    private func fillDefaultData_Somnia() {
        let user_Somnia = UserViewModel_Somnia.shared_Somnia.getCurrentUser_Somnia()
        nameField_Somnia.text = user_Somnia.userName_Somnia ?? ""
        bioField_Somnia.text  = user_Somnia.userIntroduce_Somnia ?? ""
        updateBioCount_Somnia()
    }

    /// 更新简介字符计数显示
    private func updateBioCount_Somnia() {
        let count = bioField_Somnia.text.count
        bioCountLabel_Somnia.text = "\(count) / 80"
        bioCountLabel_Somnia.textColor = count > 80
            ? UIColor(hexstring_Somnia: "#FC8181")
            : ColorConfig_Somnia.textPlaceholder_Somnia
    }

    /// 选择头像图片
    private func pickAvatarImage_Somnia() {
        MediaPickerHelper_Somnia.pickImage_Somnia(from: self) { [weak self] image_Somnia in
            guard let self = self, let image_Somnia = image_Somnia else { return }
            self.newAvatarImage_Somnia = image_Somnia
            self.avatarView_Somnia.imageView_Somnia.image = image_Somnia
        }
    }

    /// 处理保存操作
    private func handleSave_Somnia() {
        guard UserViewModel_Somnia.shared_Somnia.isLoggedIn_Somnia else {
            Navigation_Somnia.toLogin_Somnia(style_somnia: .present_somnia)
            return
        }

        let currentUser_Somnia = UserViewModel_Somnia.shared_Somnia.getCurrentUser_Somnia()
        let newName_Somnia = nameField_Somnia.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let newBio_Somnia  = bioField_Somnia.text?.trimmingCharacters(in: .whitespaces) ?? ""

        // 头像更新
        if let newImage_Somnia = newAvatarImage_Somnia {
            let fileName_Somnia = "avatar_\(Int(Date().timeIntervalSince1970)).jpg"
            let docDir_Somnia   = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL_Somnia  = docDir_Somnia.appendingPathComponent(fileName_Somnia)
            if let data_Somnia = newImage_Somnia.jpegData(compressionQuality: 0.8) {
                try? data_Somnia.write(to: fileURL_Somnia)
                Task { @MainActor in
                    UserViewModel_Somnia.shared_Somnia.updateHead_Somnia(headUrl_somnia: fileURL_Somnia.path)
                }
            }
        }

        if !newName_Somnia.isEmpty, newName_Somnia != currentUser_Somnia.userName_Somnia {
            Task { @MainActor in
                UserViewModel_Somnia.shared_Somnia.updateName_Somnia(userName_somnia: newName_Somnia)
            }
        }

        if newBio_Somnia != (currentUser_Somnia.userIntroduce_Somnia ?? "") {
            Task { @MainActor in
                UserViewModel_Somnia.shared_Somnia.updateIntroduce_Somnia(introduce_somnia: newBio_Somnia)
            }
        }

        Utils_Somnia.showSuccess_Somnia(message_Somnia: "Profile updated!")
        Navigation_Somnia.pop_Somnia()
    }

    @objc private func dismissKeyboard_Somnia() {
        view.endEditing(true)
    }
}

// MARK: - UITextViewDelegate（简介字符计数）

extension EditInfo_Somnia: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateBioCount_Somnia()
    }
}
