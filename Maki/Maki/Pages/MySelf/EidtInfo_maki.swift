import Foundation
import UIKit
import SnapKit

// MARK: - 编辑用户信息页面视图控制器

/// 编辑用户信息页面视图控制器
/// 功能：修改头像（相册选取）、用户名、用户简介；默认填充登录用户数据
/// 设计：透明导航栏 + 顶部橙色渐变装饰 + 悬浮头像 + 独立输入卡片 + 渐变保存按钮
/// 逻辑：字段变化检测，无变化时仍使用原数据；确认前校验登录状态
class EditInfo_Maki: UIViewController {

    // MARK: - 私有常量

    private enum K_Maki {
        static let primary = UIColor(hexstring_Maki: "#FF8C00")
        static let bg      = UIColor(hexstring_Maki: "#FFFBF4")
        static let card    = UIColor.white
        static let tp      = UIColor(hexstring_Maki: "#1A0A00")
        static let ts      = UIColor(hexstring_Maki: "#8B7355")
    }

    // MARK: - 数据

    private let currentUser_Maki = UserViewModel_Maki.shared_Maki.getCurrentUser_Maki()
    private var selectedAvatarImage_Maki: UIImage?

    // MARK: - UI 属性

    private let scrollView_Maki: UIScrollView = {
        let sv_maki = UIScrollView()
        sv_maki.alwaysBounceVertical = true
        sv_maki.showsVerticalScrollIndicator = false
        return sv_maki
    }()
    private let contentView_Maki = UIView()

    // MARK: 顶部装饰区

    private let topDecor_Maki = UIView()
    private let topGrad_Maki  = CAGradientLayer()

    // MARK: 头像区

    /// 头像外圈光晕
    private let avatarRing_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.15)
        v_maki.layer.cornerRadius = 62
        return v_maki
    }()
    private let avatarContainer_Maki: UIView = {
        let v_maki = UIView()
        v_maki.layer.cornerRadius = 54
        v_maki.layer.borderWidth  = 3.5
        v_maki.layer.borderColor  = UIColor(hexstring_Maki: "#FF8C00").cgColor
        v_maki.clipsToBounds      = true
        return v_maki
    }()
    private let avatarImageView_Maki: UIImageView = {
        let iv_maki = UIImageView()
        iv_maki.contentMode = .scaleAspectFill
        iv_maki.clipsToBounds = true
        return iv_maki
    }()
    private let avatarEditBadge_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00")
        v_maki.layer.cornerRadius = 17
        v_maki.layer.borderWidth  = 2.5
        v_maki.layer.borderColor  = UIColor.white.cgColor
        v_maki.layer.shadowColor  = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.4).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 3)
        v_maki.layer.shadowRadius = 6
        v_maki.layer.shadowOpacity = 1
        return v_maki
    }()
    private let avatarEditIcon_Maki: UIImageView = {
        let iv_maki = UIImageView(image: UIImage(systemName: "camera.fill"))
        iv_maki.tintColor   = .white
        iv_maki.contentMode = .scaleAspectFit
        return iv_maki
    }()
    private let avatarHintLabel_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.text      = "Tap to change avatar"
        lb_maki.font      = .systemFont(ofSize: 12, weight: .medium)
        lb_maki.textColor = UIColor(hexstring_Maki: "#8B7355")
        lb_maki.textAlignment = .center
        return lb_maki
    }()

    // MARK: 输入字段卡片

    private let nameTF_Maki = EditInfoField_Maki(
        iconName_maki: "person.fill",
        label: "Display Name",
        placeholder: "Your name"
    )
    private let bioTV_Maki  = EditInfoTextView_Maki(
        iconName_maki: "text.quote",
        label: "Bio",
        placeholder: "Tell us about yourself..."
    )

    // MARK: 保存按钮

    private let saveBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setTitle("  Save Changes", for: .normal)
        btn_maki.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        btn_maki.setTitleColor(.white, for: .normal)
        btn_maki.tintColor = .white
        btn_maki.titleLabel?.font  = .systemFont(ofSize: 16, weight: .bold)
        btn_maki.layer.cornerRadius = 16
        btn_maki.layer.shadowColor  = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.4).cgColor
        btn_maki.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn_maki.layer.shadowRadius = 14
        btn_maki.layer.shadowOpacity = 1
        return btn_maki
    }()
    private let saveGrad_Maki = CAGradientLayer()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K_Maki.bg
        setupNav_Maki()
        buildUI_Maki()
        fillCurrentUserData_Maki()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topGrad_Maki.frame = topDecor_Maki.bounds
        saveGrad_Maki.frame = CGRect(x: 0, y: 0, width: APPSCREEN_Maki.WIDTH_Maki - 40, height: 56)
    }

    // MARK: - 导航栏配置

    /// 配置透明导航栏样式
    private func setupNav_Maki() {
        title = "Edit Profile"
        let appearance_maki = UINavigationBarAppearance()
        appearance_maki.configureWithTransparentBackground()
        appearance_maki.titleTextAttributes = [
            .foregroundColor: K_Maki.tp,
            .font: UIFont(name: "Georgia-Bold", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationController?.navigationBar.standardAppearance   = appearance_maki
        navigationController?.navigationBar.scrollEdgeAppearance = appearance_maki
        navigationController?.navigationBar.tintColor = K_Maki.primary
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(onBack_Maki)
        )
    }
}

// MARK: - UI 构建

extension EditInfo_Maki {

    private func buildUI_Maki() {
        view.addSubview(scrollView_Maki)
        scrollView_Maki.addSubview(contentView_Maki)
        scrollView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Maki.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Maki.contentLayoutGuide)
            make.width.equalTo(scrollView_Maki.frameLayoutGuide)
        }
        buildTopDecor_Maki()
        buildAvatarSection_Maki()
        buildFormSection_Maki()
        buildSaveButton_Maki()
    }

    /// 构建顶部渐变装饰区（橙色渐变淡出到背景）
    private func buildTopDecor_Maki() {
        topGrad_Maki.colors = [
            UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.18).cgColor,
            UIColor(hexstring_Maki: "#FFFBF4").cgColor
        ]
        topGrad_Maki.startPoint = CGPoint(x: 0.5, y: 0)
        topGrad_Maki.endPoint   = CGPoint(x: 0.5, y: 1)
        topDecor_Maki.layer.insertSublayer(topGrad_Maki, at: 0)
        contentView_Maki.addSubview(topDecor_Maki)
        topDecor_Maki.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(160)
        }

        // 右侧装饰气泡
        let bubble_maki = UIView()
        bubble_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.08)
        bubble_maki.layer.cornerRadius = 50
        topDecor_Maki.addSubview(bubble_maki)
        bubble_maki.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.trailing.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
    }

    /// 构建头像选取区（光晕 + 圆形头像 + 相机徽章 + 提示文字）
    private func buildAvatarSection_Maki() {
        // 头像外圈光晕
        contentView_Maki.addSubview(avatarRing_Maki)
        avatarRing_Maki.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
            make.width.height.equalTo(124)
        }

        // 头像容器
        contentView_Maki.addSubview(avatarContainer_Maki)
        avatarContainer_Maki.addSubview(avatarImageView_Maki)
        avatarContainer_Maki.snp.makeConstraints { make in
            make.center.equalTo(avatarRing_Maki)
            make.width.height.equalTo(108)
        }
        avatarImageView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 相机编辑徽章
        contentView_Maki.addSubview(avatarEditBadge_Maki)
        avatarEditBadge_Maki.addSubview(avatarEditIcon_Maki)
        avatarEditBadge_Maki.snp.makeConstraints { make in
            make.width.height.equalTo(34)
            make.trailing.equalTo(avatarContainer_Maki.snp.trailing).offset(4)
            make.bottom.equalTo(avatarContainer_Maki.snp.bottom).offset(4)
        }
        avatarEditIcon_Maki.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }

        // 提示文字
        contentView_Maki.addSubview(avatarHintLabel_Maki)
        avatarHintLabel_Maki.snp.makeConstraints { make in
            make.top.equalTo(avatarContainer_Maki.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        // 头像点击手势
        let tap_maki = UITapGestureRecognizer(target: self, action: #selector(onAvatarTap_Maki))
        avatarContainer_Maki.isUserInteractionEnabled = true
        avatarContainer_Maki.addGestureRecognizer(tap_maki)
    }

    /// 构建表单区域（区块标题 + 输入字段卡片）
    private func buildFormSection_Maki() {
        // 区块标题
        let sectionLb_maki = buildSectionLabel_Maki(icon_maki: "person.text.rectangle.fill", title_maki: "Profile Info")
        contentView_Maki.addSubview(sectionLb_maki)
        sectionLb_maki.snp.makeConstraints { make in
            make.top.equalTo(avatarHintLabel_Maki.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
        }

        // 用户名输入卡片
        contentView_Maki.addSubview(nameTF_Maki)
        nameTF_Maki.snp.makeConstraints { make in
            make.top.equalTo(sectionLb_maki.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(68)
        }

        // 简介输入卡片
        contentView_Maki.addSubview(bioTV_Maki)
        bioTV_Maki.snp.makeConstraints { make in
            make.top.equalTo(nameTF_Maki.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(110)
        }
    }

    /// 构建区块标题标签（图标 + 文字）
    private func buildSectionLabel_Maki(icon_maki: String, title_maki: String) -> UIView {
        let wrap_maki = UIView()
        let iv_maki = UIImageView(image: UIImage(systemName: icon_maki))
        iv_maki.tintColor = K_Maki.primary
        iv_maki.contentMode = .scaleAspectFit
        let lb_maki = UILabel()
        lb_maki.text = title_maki
        lb_maki.font = .systemFont(ofSize: 13, weight: .bold)
        lb_maki.textColor = K_Maki.tp
        wrap_maki.addSubview(iv_maki)
        wrap_maki.addSubview(lb_maki)
        iv_maki.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        lb_maki.snp.makeConstraints { make in
            make.leading.equalTo(iv_maki.snp.trailing).offset(6)
            make.centerY.trailing.equalToSuperview()
        }
        return wrap_maki
    }

    /// 构建渐变保存按钮
    private func buildSaveButton_Maki() {
        saveGrad_Maki.colors = [
            UIColor(hexstring_Maki: "#FF8C00").cgColor,
            UIColor(hexstring_Maki: "#E8650A").cgColor
        ]
        saveGrad_Maki.startPoint   = CGPoint(x: 0, y: 0.5)
        saveGrad_Maki.endPoint     = CGPoint(x: 1, y: 0.5)
        saveGrad_Maki.cornerRadius = 16
        saveGrad_Maki.frame        = CGRect(x: 0, y: 0, width: APPSCREEN_Maki.WIDTH_Maki - 40, height: 56)
        saveBtn_Maki.layer.insertSublayer(saveGrad_Maki, at: 0)

        contentView_Maki.addSubview(saveBtn_Maki)
        saveBtn_Maki.snp.makeConstraints { make in
            make.top.equalTo(bioTV_Maki.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-48)
        }
        saveBtn_Maki.addTarget(self, action: #selector(onSave_Maki), for: .touchUpInside)
    }
}

// MARK: - 数据填充

extension EditInfo_Maki {

    /// 用登录用户现有数据填充表单
    private func fillCurrentUserData_Maki() {
        nameTF_Maki.setValue_Maki(currentUser_Maki.userName_Maki ?? "")
        bioTV_Maki.setValue_Maki(currentUser_Maki.userIntroduce_Maki ?? "")

        if let head_maki = currentUser_Maki.userHead_Maki, !head_maki.isEmpty,
           let img_maki = UIImage(named: head_maki) ?? UIImage(contentsOfFile: head_maki) {
            avatarImageView_Maki.image = img_maki
        } else {
            avatarImageView_Maki.image = UIImage(systemName: "person.circle.fill")
            avatarImageView_Maki.tintColor = UIColor(hexstring_Maki: "#FF8C00")
        }
    }
}

// MARK: - 事件响应

extension EditInfo_Maki {

    @objc private func onBack_Maki() {
        Navigation_Maki.pop_Maki()
    }

    /// 点击头像 → 打开相册选图，成功后弹性缩放反馈
    @objc private func onAvatarTap_Maki() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        MediaPickerHelper_Maki.pickImage_Maki(from: self) { [weak self] image_maki in
            guard let self, let img_maki = image_maki else { return }
            self.selectedAvatarImage_Maki = img_maki
            self.avatarImageView_Maki.image = img_maki
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0.4,
                options: [],
                animations: {
                    self.avatarContainer_Maki.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.2) {
                        self.avatarContainer_Maki.transform = .identity
                    }
                }
            )
        }
    }

    /// 保存修改
    @objc private func onSave_Maki() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        // 按钮按压动画
        UIView.animate(withDuration: 0.1, animations: {
            self.saveBtn_Maki.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15) { self.saveBtn_Maki.transform = .identity }
        })

        guard UserViewModel_Maki.shared_Maki.isLoggedIn_Maki else {
            Load_Maki.showWarning_Maki(message_Maki: "Please log in first")
            Navigation_Maki.toLogin_Maki(style_maki: .present_maki)
            return
        }

        let newName_maki = nameTF_Maki.currentValue_Maki.trimmingCharacters(in: .whitespaces)
        let newBio_maki  = bioTV_Maki.currentValue_Maki.trimmingCharacters(in: .whitespaces)
        let userVM_maki  = UserViewModel_Maki.shared_Maki

        if let img_maki = selectedAvatarImage_Maki {
            userVM_maki.updateHead_Maki(headUrl_maki: saveAvatarImage_Maki(img_maki))
        }
        if newName_maki != (currentUser_Maki.userName_Maki ?? "") && !newName_maki.isEmpty {
            userVM_maki.updateName_Maki(userName_maki: newName_maki)
        }
        if newBio_maki != (currentUser_Maki.userIntroduce_Maki ?? "") && !newBio_maki.isEmpty {
            userVM_maki.updateIntroduce_Maki(userIntroduce_maki: newBio_maki)
        }

        Load_Maki.showSuccess_Maki(message_Maki: "Profile updated!")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            Navigation_Maki.pop_Maki()
        }
    }

    /// 将头像 UIImage 存入 Documents 目录，返回文件路径
    private func saveAvatarImage_Maki(_ image_maki: UIImage) -> String {
        let filename_maki = "user_avatar_\(Int(Date().timeIntervalSince1970)).jpg"
        let url_maki = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename_maki)
        if let data_maki = image_maki.jpegData(compressionQuality: 0.8) {
            try? data_maki.write(to: url_maki)
        }
        return url_maki.path
    }
}

// MARK: - EditInfoField_Maki（带图标标签输入框卡片）

/// 编辑资料页带图标输入框卡片
/// 功能：SF Symbol 图标 + 小标签 + 单行输入；聚焦时橙色边框高亮
final class EditInfoField_Maki: UIView {

    private let iconIV_Maki: UIImageView = {
        let iv_maki = UIImageView()
        iv_maki.tintColor = UIColor(hexstring_Maki: "#FF8C00")
        iv_maki.contentMode = .scaleAspectFit
        return iv_maki
    }()
    private let labelView_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font      = .systemFont(ofSize: 10, weight: .bold)
        lb_maki.textColor = UIColor(hexstring_Maki: "#8B7355")
        return lb_maki
    }()
    private let tf_Maki: UITextField = {
        let tf_maki = UITextField()
        tf_maki.font         = .systemFont(ofSize: 15, weight: .medium)
        tf_maki.textColor    = UIColor(hexstring_Maki: "#1A0A00")
        tf_maki.autocorrectionType = .no
        return tf_maki
    }()

    var currentValue_Maki: String { tf_Maki.text ?? "" }

    init(iconName_maki: String, label: String, placeholder: String) {
        super.init(frame: .zero)
        iconIV_Maki.image = UIImage(systemName: iconName_maki)
        labelView_Maki.text = label.uppercased()
        tf_Maki.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor(hexstring_Maki: "#C0A880")]
        )
        setupAppearance_Maki()
        setupLayout_Maki()
        tf_Maki.delegate = self
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupAppearance_Maki() {
        backgroundColor = .white
        layer.cornerRadius = 14
        layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 8
        layer.shadowOpacity = 1
        layer.borderWidth = 1.5
        layer.borderColor = UIColor(hexstring_Maki: "#F0EDE6").cgColor
    }

    private func setupLayout_Maki() {
        addSubview(iconIV_Maki)
        addSubview(labelView_Maki)
        addSubview(tf_Maki)

        iconIV_Maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        labelView_Maki.snp.makeConstraints { make in
            make.leading.equalTo(iconIV_Maki.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(12)
        }
        tf_Maki.snp.makeConstraints { make in
            make.top.equalTo(labelView_Maki.snp.bottom).offset(3)
            make.leading.equalTo(labelView_Maki)
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-10)
        }
    }

    func setValue_Maki(_ value: String) { tf_Maki.text = value }
}

extension EditInfoField_Maki: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.layer.borderColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.55).cgColor
            self.layer.shadowColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.12).cgColor
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.layer.borderColor = UIColor(hexstring_Maki: "#F0EDE6").cgColor
            self.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        }
    }
}

// MARK: - EditInfoTextView_Maki（带图标标签多行输入卡片）

/// 编辑资料页带图标多行文本输入卡片
/// 功能：SF Symbol 图标 + 标签 + 多行 UITextView；聚焦时橙色边框高亮
final class EditInfoTextView_Maki: UIView {

    private let iconIV_Maki: UIImageView = {
        let iv_maki = UIImageView()
        iv_maki.tintColor = UIColor(hexstring_Maki: "#FF8C00")
        iv_maki.contentMode = .scaleAspectFit
        return iv_maki
    }()
    private let labelView_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font      = .systemFont(ofSize: 10, weight: .bold)
        lb_maki.textColor = UIColor(hexstring_Maki: "#8B7355")
        return lb_maki
    }()
    private let tv_Maki: UITextView = {
        let tv_maki = UITextView()
        tv_maki.font             = .systemFont(ofSize: 15)
        tv_maki.textColor        = UIColor(hexstring_Maki: "#1A0A00")
        tv_maki.backgroundColor  = .clear
        tv_maki.textContainerInset = .zero
        tv_maki.textContainer.lineFragmentPadding = 0
        tv_maki.isScrollEnabled  = false
        return tv_maki
    }()
    private let placeholder_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font      = .systemFont(ofSize: 15)
        lb_maki.textColor = UIColor(hexstring_Maki: "#C0A880")
        lb_maki.numberOfLines = 0
        return lb_maki
    }()

    var currentValue_Maki: String { tv_Maki.text ?? "" }

    init(iconName_maki: String, label: String, placeholder: String) {
        super.init(frame: .zero)
        iconIV_Maki.image = UIImage(systemName: iconName_maki)
        labelView_Maki.text   = label.uppercased()
        placeholder_Maki.text = placeholder
        tv_Maki.delegate = self
        setupAppearance_Maki()
        setupLayout_Maki()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupAppearance_Maki() {
        backgroundColor = .white
        layer.cornerRadius = 14
        layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 8
        layer.shadowOpacity = 1
        layer.borderWidth = 1.5
        layer.borderColor = UIColor(hexstring_Maki: "#F0EDE6").cgColor
    }

    private func setupLayout_Maki() {
        addSubview(iconIV_Maki)
        addSubview(labelView_Maki)
        addSubview(tv_Maki)
        addSubview(placeholder_Maki)

        iconIV_Maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(14)
            make.width.height.equalTo(20)
        }
        labelView_Maki.snp.makeConstraints { make in
            make.leading.equalTo(iconIV_Maki.snp.trailing).offset(10)
            make.centerY.equalTo(iconIV_Maki)
        }
        tv_Maki.snp.makeConstraints { make in
            make.top.equalTo(labelView_Maki.snp.bottom).offset(6)
            make.leading.equalTo(labelView_Maki)
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-14)
        }
        placeholder_Maki.snp.makeConstraints { $0.edges.equalTo(tv_Maki) }
    }

    func setValue_Maki(_ value: String) {
        tv_Maki.text = value
        placeholder_Maki.isHidden = !value.isEmpty
    }
}

extension EditInfoTextView_Maki: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholder_Maki.isHidden = !textView.text.isEmpty
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.2) {
            self.layer.borderColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.55).cgColor
            self.layer.shadowColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.12).cgColor
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.2) {
            self.layer.borderColor = UIColor(hexstring_Maki: "#F0EDE6").cgColor
            self.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        }
    }
}
