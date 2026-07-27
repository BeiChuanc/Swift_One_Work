import Foundation
import UIKit
import SnapKit

// MARK: 修改用户信息页面

/// 修改用户信息页面视图控制器
/// 核心作用：支持登录用户修改头像、昵称与简介，确认后统一提交给 UserViewModel_Orna 保存
/// 设计思路：
///   - 页面背景改为与首页/发现页/我的页一致的浅紫底色，昵称/简介输入区分别封装为独立白色圆角卡片，
///     卡片头部使用彩色图标徽标区分（紫/粉呼应主题强调色），与发布页三个输入卡片保持同一视觉语言
///   - 头像区新增"更换头像"胶囊按钮取代原来单薄的纯文字提示，提升可点击性的视觉暗示
///   - 确认按钮改用紫粉渐变 + 投影，呼应发布页发布按钮与发现页横幅的强调色
///   - 整体内容包裹进滚动容器，避免小屏设备下底部按钮被截断
///   - 默认数据读取当前登录用户资料；确认修改前校验登录状态，
///     未修改的字段保持原值不被清空覆盖
/// 关键属性：
///   - pickedAvatarImage_Orna: 用户新选择但尚未保存的头像图片
class EditInfo_Orna: UIViewController {

    // MARK: - 数据

    /// 用户新选择但尚未保存的头像
    private var pickedAvatarImage_Orna: UIImage?

    // MARK: - UI · 顶部工具条

    private let backButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let cfg_orna = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg_orna), for: .normal)
        b.tintColor = UIColor(hexstring_Orna: "#2D2A3D")
        b.backgroundColor = .white
        b.layer.cornerRadius = 18
        b.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        b.layer.shadowOpacity = 0.1
        b.layer.shadowOffset = CGSize(width: 0, height: 3)
        b.layer.shadowRadius = 6
        return b
    }()

    private let titleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Edit Profile"
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        return l
    }()

    // MARK: - UI · 滚动容器

    private let scrollView_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentView_Orna = UIView()

    // MARK: - UI · 头像

    private lazy var avatarView_Orna: CurrentUserAvatarView_Orna = {
        let v = CurrentUserAvatarView_Orna()
        v.layer.cornerRadius = 48
        v.clipsToBounds = true
        v.layer.borderWidth = 3
        v.layer.borderColor = UIColor(hexstring_Orna: "#7B61FF").withAlphaComponent(0.2).cgColor
        v.onTapped_Orna = { [weak self] in
            self?.handleChangeAvatarTapped_Orna()
        }
        return v
    }()

    private let cameraBadgeView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#7B61FF")
        v.layer.cornerRadius = 15
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.white.cgColor
        return v
    }()

    private let cameraIconView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "camera.fill"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// "更换头像"胶囊按钮，取代原来单薄的纯文字提示，强化可点击性的视觉暗示
    private let changePhotoButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        var config_orna = UIButton.Configuration.plain()
        config_orna.title = "Change Photo"
        config_orna.image = UIImage(systemName: "photo.on.rectangle.angled")
        config_orna.imagePadding = 6
        config_orna.baseForegroundColor = UIColor(hexstring_Orna: "#7B61FF")
        config_orna.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        config_orna.attributedTitle = AttributedString(
            "Change Photo", attributes: AttributeContainer([.font: UIFont.systemFont(ofSize: 13, weight: .semibold)])
        )
        b.configuration = config_orna
        b.backgroundColor = .white
        b.layer.cornerRadius = 18
        b.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        b.layer.shadowOpacity = 0.08
        b.layer.shadowOffset = CGSize(width: 0, height: 3)
        b.layer.shadowRadius = 8
        return b
    }()

    // MARK: - UI · 昵称卡片

    private let nameCardView_Orna = EditInfo_Orna.makeCardContainer_Orna()

    private let nameField_Orna: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 15, weight: .medium)
        tf.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        tf.placeholder = "Enter a username"
        tf.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        tf.layer.cornerRadius = 14
        tf.setLeftPadding_Orna(16)
        return tf
    }()

    // MARK: - UI · 简介卡片

    private let bioCardView_Orna = EditInfo_Orna.makeCardContainer_Orna()

    private let bioTextView_Orna: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 14, weight: .regular)
        tv.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        tv.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        tv.layer.cornerRadius = 14
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        return tv
    }()

    private let bioPlaceholderLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Tell others about your desk world..."
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0").withAlphaComponent(0.7)
        return l
    }()

    // MARK: - UI · 确认按钮

    private let confirmButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Save Changes", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        b.layer.cornerRadius = 24
        b.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        b.layer.shadowOpacity = 0.25
        b.layer.shadowOffset = CGSize(width: 0, height: 6)
        b.layer.shadowRadius = 12
        return b
    }()

    private var confirmButtonGradientLayer_Orna: CAGradientLayer?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        setupUI_Orna()
        setupConstraints_Orna()
        setupActions_Orna()
        fillDefaultData_Orna()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        confirmButtonGradientLayer_Orna?.frame = confirmButton_Orna.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Orna() {
        view.addSubview(backButton_Orna)
        view.addSubview(titleLabel_Orna)
        view.addSubview(scrollView_Orna)
        scrollView_Orna.addSubview(contentView_Orna)

        contentView_Orna.addSubview(avatarView_Orna)
        avatarView_Orna.addSubview(cameraBadgeView_Orna)
        cameraBadgeView_Orna.addSubview(cameraIconView_Orna)
        contentView_Orna.addSubview(changePhotoButton_Orna)

        contentView_Orna.addSubview(nameCardView_Orna)
        let nameHeader_orna = makeSectionHeader_Orna(icon_orna: "person.text.rectangle.fill", text_orna: "Username", accentColorHex_orna: "#7B61FF")
        nameCardView_Orna.addSubview(nameHeader_orna)
        nameCardView_Orna.addSubview(nameField_Orna)
        nameHeader_orna.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(16)
        }
        nameField_Orna.snp.makeConstraints {
            $0.top.equalTo(nameHeader_orna.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }

        contentView_Orna.addSubview(bioCardView_Orna)
        let bioHeader_orna = makeSectionHeader_Orna(icon_orna: "text.alignleft", text_orna: "Bio", accentColorHex_orna: "#FF6B9D")
        bioCardView_Orna.addSubview(bioHeader_orna)
        bioCardView_Orna.addSubview(bioTextView_Orna)
        bioTextView_Orna.addSubview(bioPlaceholderLabel_Orna)
        bioHeader_orna.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(16)
        }
        bioTextView_Orna.snp.makeConstraints {
            $0.top.equalTo(bioHeader_orna.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(110)
        }
        bioPlaceholderLabel_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-14)
        }

        contentView_Orna.addSubview(confirmButton_Orna)
        setupConfirmButtonGradient_Orna()
    }

    /// 确认按钮紫粉渐变，呼应发布页发布按钮与发现页横幅的强调色
    private func setupConfirmButtonGradient_Orna() {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor(hexstring_Orna: "#7B61FF").cgColor,
            UIColor(hexstring_Orna: "#FF6B9D").cgColor
        ]
        layer_orna.startPoint = CGPoint(x: 0, y: 0)
        layer_orna.endPoint = CGPoint(x: 1, y: 1)
        layer_orna.cornerRadius = 24
        confirmButton_Orna.layer.insertSublayer(layer_orna, at: 0)
        confirmButtonGradientLayer_Orna = layer_orna
    }

    /// 搭建卡片统一的白色圆角容器，呼应发布页三个输入卡片的视觉语言
    private static func makeCardContainer_Orna() -> UIView {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 10
        return v
    }

    /// 搭建卡片头部图标徽标 + 分区标题，用于区分昵称/简介两个输入区并丰富色彩层次
    /// 参数：
    /// - icon_orna: SF Symbols 图标名称
    /// - text_orna: 分区标题文本
    /// - accentColorHex_orna: 该分区的强调色（十六进制）
    private func makeSectionHeader_Orna(icon_orna: String, text_orna: String, accentColorHex_orna: String) -> UIView {
        let container_orna = UIView()
        let accentColor_orna = UIColor(hexstring_Orna: accentColorHex_orna)

        let badge_orna = UIView()
        badge_orna.backgroundColor = accentColor_orna.withAlphaComponent(0.15)
        badge_orna.layer.cornerRadius = 14

        let iconView_orna = UIImageView(image: UIImage(systemName: icon_orna))
        iconView_orna.tintColor = accentColor_orna
        iconView_orna.contentMode = .scaleAspectFit

        let label_orna = UILabel()
        label_orna.text = text_orna
        label_orna.font = .systemFont(ofSize: 14, weight: .bold)
        label_orna.textColor = UIColor(hexstring_Orna: "#2D2A3D")

        container_orna.addSubview(badge_orna)
        badge_orna.addSubview(iconView_orna)
        container_orna.addSubview(label_orna)

        badge_orna.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.height.equalTo(28)
        }
        iconView_orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(14)
        }
        label_orna.snp.makeConstraints {
            $0.leading.equalTo(badge_orna.snp.trailing).offset(8)
            $0.centerY.equalTo(badge_orna)
            $0.trailing.lessThanOrEqualToSuperview()
        }
        return container_orna
    }

    // MARK: - 约束

    private func setupConstraints_Orna() {
        backButton_Orna.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(36)
        }
        titleLabel_Orna.snp.makeConstraints {
            $0.centerY.equalTo(backButton_Orna)
            $0.centerX.equalToSuperview()
        }
        scrollView_Orna.snp.makeConstraints {
            $0.top.equalTo(backButton_Orna.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        avatarView_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(96)
        }
        cameraBadgeView_Orna.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview()
            $0.width.height.equalTo(30)
        }
        cameraIconView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(14)
        }
        changePhotoButton_Orna.snp.makeConstraints {
            $0.top.equalTo(avatarView_Orna.snp.bottom).offset(14)
            $0.centerX.equalToSuperview()
        }

        nameCardView_Orna.snp.makeConstraints {
            $0.top.equalTo(changePhotoButton_Orna.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        bioCardView_Orna.snp.makeConstraints {
            $0.top.equalTo(nameCardView_Orna.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        confirmButton_Orna.snp.makeConstraints {
            $0.top.equalTo(bioCardView_Orna.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-32)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Orna() {
        backButton_Orna.addTarget(self, action: #selector(handleBackTapped_Orna), for: .touchUpInside)
        changePhotoButton_Orna.addTarget(self, action: #selector(handleChangeAvatarTapped_Orna), for: .touchUpInside)
        confirmButton_Orna.addTarget(self, action: #selector(handleConfirmTapped_Orna), for: .touchUpInside)
        bioTextView_Orna.delegate = self
    }

    // MARK: - 数据填充

    /// 使用当前登录用户资料填充默认数据
    private func fillDefaultData_Orna() {
        let user_orna = UserViewModel_Orna.shared_Orna.getCurrentUser_Orna()
        nameField_Orna.text = user_orna.userName_Orna
        bioTextView_Orna.text = user_orna.userIntroduce_Orna
        bioPlaceholderLabel_Orna.isHidden = !(user_orna.userIntroduce_Orna?.isEmpty ?? true)
    }

    // MARK: - 事件处理

    @objc private func handleBackTapped_Orna() {
        Navigation_Orna.pop_Orna(from: self)
    }

    /// 选择新头像
    @objc private func handleChangeAvatarTapped_Orna() {
        MediaPickerHelper_Orna.pickImage_Orna(from: self) { [weak self] image_orna in
            guard let self, let image_orna else { return }
            self.pickedAvatarImage_Orna = image_orna
            self.avatarView_Orna.imageView_Orna.image = image_orna
            self.avatarView_Orna.imageView_Orna.contentMode = .scaleAspectFill
        }
    }

    /// 确认保存修改
    /// 功能：校验登录状态；仅提交发生变化的字段，未修改字段保持原有数据
    @objc private func handleConfirmTapped_Orna() {
        guard UserViewModel_Orna.shared_Orna.isLoggedIn_Orna else {
            Navigation_Orna.toLogin_Orna()
            return
        }

        let currentUser_orna = UserViewModel_Orna.shared_Orna.getCurrentUser_Orna()
        var didChange_orna = false

        let newName_orna = (nameField_Orna.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !newName_orna.isEmpty, newName_orna != (currentUser_orna.userName_Orna ?? "") {
            UserViewModel_Orna.shared_Orna.updateName_Orna(userName_orna: newName_orna)
            didChange_orna = true
        }

        let newBio_orna = (bioTextView_Orna.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !newBio_orna.isEmpty, newBio_orna != (currentUser_orna.userIntroduce_Orna ?? "") {
            UserViewModel_Orna.shared_Orna.updateIntroduce_Orna(userIntroduce_orna: newBio_orna)
            didChange_orna = true
        }

        if let pickedImage_orna = pickedAvatarImage_Orna,
           let savedPath_orna = saveAvatarImageToDisk_Orna(image_orna: pickedImage_orna) {
            UserViewModel_Orna.shared_Orna.updateHead_Orna(headUrl_orna: savedPath_orna)
            didChange_orna = true
        }

        if !didChange_orna {
            Load_Orna.showInfo_Orna(message_Orna: "No changes to save")
        }
        Navigation_Orna.pop_Orna(from: self)
    }

    /// 将选中的头像图片保存到 Documents 目录
    /// 返回值：保存成功返回完整文件路径，失败返回 nil
    private func saveAvatarImageToDisk_Orna(image_orna: UIImage) -> String? {
        guard let data_orna = image_orna.jpegData(compressionQuality: 0.85) else { return nil }
        let docsDir_orna = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_orna = docsDir_orna.appendingPathComponent("avatar_\(Int(Date().timeIntervalSince1970)).jpg")
        do {
            try data_orna.write(to: fileURL_orna)
            return fileURL_orna.path
        } catch {
            print("❌ 保存头像失败: \(error)")
            return nil
        }
    }
}

// MARK: - UITextViewDelegate

extension EditInfo_Orna: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        bioPlaceholderLabel_Orna.isHidden = !textView.text.isEmpty
    }
}

// MARK: - UITextField 左内边距扩展

private extension UITextField {
    /// 设置左内边距（用于卡片式输入框留白）
    func setLeftPadding_Orna(_ amount: CGFloat) {
        let paddingView_orna = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 1))
        leftView = paddingView_orna
        leftViewMode = .always
    }
}
