import Foundation
import UIKit
import SnapKit

// MARK: - 修改用户信息页面

/// 修改用户信息页面视图控制器
/// 核心作用：提供修改头像、用户名、简介的交互界面，未登录时阻止操作
/// 设计思路：卡片式表单布局，头像可点击从相册选取，修改后通过 ViewModel 更新
/// 关键属性：
///   - selectedImage_Lumia: 用户从相册选取的新头像图片
///   - hasChanges_Lumia: 标识数据是否有修改（未修改时沿用原数据）
class EditInfo_Lumia: UIViewController {

    // MARK: - 私有属性

    private var selectedImage_Lumia: UIImage?
    private var originalName_Lumia: String = ""
    private var originalIntro_Lumia: String = ""

    // MARK: - UI组件

    private lazy var scrollView_Lumia: UIScrollView = {
        let sv_Lumia = UIScrollView()
        sv_Lumia.showsVerticalScrollIndicator = false
        sv_Lumia.alwaysBounceVertical = true
        // 关闭自动 inset 调整，contentView 从 (0,0) 开始，触摸区域准确
        sv_Lumia.contentInsetAdjustmentBehavior = .never
        return sv_Lumia
    }()

    private let contentView_Lumia = UIView()

    /// 顶部标题栏
    private let topBar_Lumia = UIView()

    private let backButton_Lumia = BackButton_Lumia()

    private let pageTitleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Edit Profile"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lbl_Lumia.textColor = ColorConfig_Lumia.textPrimary_Lumia
        return lbl_Lumia
    }()

    /// 头像区域
    private let avatarContainerView_Lumia = UIView()

    private let avatarView_Lumia: CurrentUserAvatarView_Lumia = {
        let v_Lumia = CurrentUserAvatarView_Lumia(frame: .zero)
        v_Lumia.layer.cornerRadius = 50
        v_Lumia.layer.borderWidth = 3
        v_Lumia.layer.borderColor = ColorConfig_Lumia.primaryGradientStart_Lumia.cgColor
        v_Lumia.clipsToBounds = true
        return v_Lumia
    }()

    private let cameraOverlay_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        v_Lumia.layer.cornerRadius = 50
        // 禁用交互，触摸事件穿透到父视图的手势识别器
        v_Lumia.isUserInteractionEnabled = false
        return v_Lumia
    }()

    private let cameraIcon_Lumia: UIImageView = {
        let iv_Lumia = UIImageView()
        iv_Lumia.image = UIImage(systemName: "camera.fill")
        iv_Lumia.tintColor = .white
        iv_Lumia.contentMode = .scaleAspectFit
        return iv_Lumia
    }()

    private let changePhotoLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Change Photo"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        lbl_Lumia.textColor = ColorConfig_Lumia.primaryGradientStart_Lumia
        return lbl_Lumia
    }()

    /// 表单卡片
    private let formCard_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = .white
        v_Lumia.layer.cornerRadius = 20
        v_Lumia.layer.shadowColor = UIColor.black.cgColor
        v_Lumia.layer.shadowOpacity = 0.07
        v_Lumia.layer.shadowRadius = 12
        v_Lumia.layer.shadowOffset = CGSize(width: 0, height: 4)
        return v_Lumia
    }()

    private let nameLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Username"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl_Lumia.textColor = ColorConfig_Lumia.textSecondary_Lumia
        return lbl_Lumia
    }()

    private let nameField_Lumia: UITextField = {
        let tf_Lumia = UITextField()
        tf_Lumia.placeholder = "Enter your name"
        tf_Lumia.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        tf_Lumia.textColor = ColorConfig_Lumia.textPrimary_Lumia
        tf_Lumia.clearButtonMode = .whileEditing
        tf_Lumia.returnKeyType = .next
        return tf_Lumia
    }()

    private let nameDivider_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = ColorConfig_Lumia.divider_Lumia
        return v_Lumia
    }()

    private let introLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Bio"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl_Lumia.textColor = ColorConfig_Lumia.textSecondary_Lumia
        return lbl_Lumia
    }()

    private let introTextView_Lumia: UITextView = {
        let tv_Lumia = UITextView()
        tv_Lumia.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tv_Lumia.textColor = ColorConfig_Lumia.textPrimary_Lumia
        tv_Lumia.backgroundColor = .clear
        tv_Lumia.returnKeyType = .done
        // 保留默认 inset 和 lineFragmentPadding，避免 NSMutableRLEArray Out of bounds 崩溃
        return tv_Lumia
    }()

    private let introPlaceholder_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Tell the world about yourself"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 15)
        lbl_Lumia.textColor = ColorConfig_Lumia.textPlaceholder_Lumia
        lbl_Lumia.isUserInteractionEnabled = false
        return lbl_Lumia
    }()

    private let confirmButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        btn_Lumia.setTitle("Save Changes", for: .normal)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn_Lumia.setTitleColor(.white, for: .normal)
        btn_Lumia.layer.cornerRadius = 24
        return btn_Lumia
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lumia()
        loadCurrentUser_Lumia()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        view.backgroundColor = UIColor(hexstring_Lumia: "#F7F3EE")

        // 顶部栏
        view.addSubview(topBar_Lumia)
        topBar_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F7F3EE")
        topBar_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(90)
        }

        topBar_Lumia.addSubview(backButton_Lumia)
        backButton_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(44)
        }
        backButton_Lumia.onTapped_Lumia = { Navigation_Lumia.pop_Lumia() }

        topBar_Lumia.addSubview(pageTitleLabel_Lumia)
        pageTitleLabel_Lumia.snp.makeConstraints { make in
            make.centerY.equalTo(backButton_Lumia)
            make.centerX.equalToSuperview()
        }

        // 滚动视图
        view.addSubview(scrollView_Lumia)
        scrollView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(topBar_Lumia.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        scrollView_Lumia.addSubview(contentView_Lumia)
        contentView_Lumia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        // 头像区域 ── 所有视图直接放在 contentView_Lumia，避免容器宽度为 0 导致点击区域失效
        // 头像视图（禁用自身交互，防止内置手势拦截上层点击）
        contentView_Lumia.addSubview(avatarView_Lumia)
        avatarView_Lumia.isUserInteractionEnabled = false
        avatarView_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }

        // 相机遮罩（不拦截触摸）
        contentView_Lumia.addSubview(cameraOverlay_Lumia)
        cameraOverlay_Lumia.snp.makeConstraints { make in
            make.edges.equalTo(avatarView_Lumia)
        }
        contentView_Lumia.addSubview(cameraIcon_Lumia)
        cameraIcon_Lumia.snp.makeConstraints { make in
            make.center.equalTo(avatarView_Lumia)
            make.width.height.equalTo(28)
        }

        // "Change Photo" 标签
        contentView_Lumia.addSubview(changePhotoLabel_Lumia)
        changePhotoLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Lumia.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        // 透明点击按钮直接放在 contentView 最顶层，确保尺寸明确且可命中
        let avatarTapBtn_Lumia = UIButton(type: .custom)
        avatarTapBtn_Lumia.backgroundColor = .clear
        contentView_Lumia.addSubview(avatarTapBtn_Lumia)
        avatarTapBtn_Lumia.snp.makeConstraints { make in
            make.edges.equalTo(avatarView_Lumia)
        }
        avatarTapBtn_Lumia.addTarget(self, action: #selector(handleAvatarTap_Lumia), for: .touchUpInside)

        // 表单卡片（顶部对齐到 changePhotoLabel 底部，不再依赖已移除的 avatarContainerView）
        contentView_Lumia.addSubview(formCard_Lumia)
        formCard_Lumia.snp.makeConstraints { make in
            make.top.equalTo(changePhotoLabel_Lumia.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        setupFormCard_Lumia()

        // 确认按钮
        contentView_Lumia.addSubview(confirmButton_Lumia)
        confirmButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(formCard_Lumia.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-40)
        }
        let gradientBtn_Lumia = UIColor.createPrimaryGradientLayer_Lumia(
            frame_Lumia: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 48, height: 48)
        )
        gradientBtn_Lumia.cornerRadius = 24
        confirmButton_Lumia.layer.insertSublayer(gradientBtn_Lumia, at: 0)
        confirmButton_Lumia.addTarget(self, action: #selector(handleConfirm_Lumia), for: .touchUpInside)
    }

    private func setupFormCard_Lumia() {
        formCard_Lumia.addSubview(nameLabel_Lumia)
        nameLabel_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
        }

        formCard_Lumia.addSubview(nameField_Lumia)
        nameField_Lumia.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Lumia.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(36)
        }
        nameField_Lumia.delegate = self

        formCard_Lumia.addSubview(nameDivider_Lumia)
        nameDivider_Lumia.snp.makeConstraints { make in
            make.top.equalTo(nameField_Lumia.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(0.5)
        }

        formCard_Lumia.addSubview(introLabel_Lumia)
        introLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(nameDivider_Lumia.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }

        formCard_Lumia.addSubview(introTextView_Lumia)
        introTextView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(introLabel_Lumia.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(80)
            make.bottom.equalToSuperview().offset(-20)
        }
        introTextView_Lumia.delegate = self

        formCard_Lumia.addSubview(introPlaceholder_Lumia)
        introPlaceholder_Lumia.snp.makeConstraints { make in
            make.top.leading.equalTo(introTextView_Lumia)
        }
    }

    // MARK: - 数据加载

    private func loadCurrentUser_Lumia() {
        let user_Lumia = UserViewModel_Lumia.shared_Lumia.getCurrentUser_Lumia()

        // 用户名
        nameField_Lumia.text = user_Lumia.userName_Lumia
        originalName_Lumia = user_Lumia.userName_Lumia ?? ""

        // 个人简介（从模型中读取，无则置空）
        let intro_Lumia = user_Lumia.userIntroduce_Lumia ?? ""
        introTextView_Lumia.text = intro_Lumia
        originalIntro_Lumia = intro_Lumia
        introPlaceholder_Lumia.isHidden = !intro_Lumia.isEmpty
    }

    // MARK: - 事件处理

    /// 头像点击 → 打开相册
    @objc private func handleAvatarTap_Lumia() {
        MediaPickerHelper_Lumia.pickImage_Lumia(from: self) { [weak self] image_Lumia in
            guard let self = self, let image_Lumia = image_Lumia else { return }
            self.selectedImage_Lumia = image_Lumia
            self.avatarView_Lumia.imageView_Lumia.image = image_Lumia
        }
    }

    /// 确认修改
    @objc private func handleConfirm_Lumia() {
        // 收起键盘，确保 UITextView/UITextField 完成编辑，避免 pop 时触发内部 RLEArray 越界
        view.endEditing(true)

        // 判断是否已登录
        guard UserViewModel_Lumia.shared_Lumia.isLoggedIn_Lumia else {
            Navigation_Lumia.toLogin_Lumia()
            return
        }

        let newName_Lumia = nameField_Lumia.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let newIntro_Lumia = introTextView_Lumia.text?.trimmingCharacters(in: .whitespaces) ?? ""

        // 保存头像（若有新选取）
        if let image_Lumia = selectedImage_Lumia {
            saveImageToDocuments_Lumia(image: image_Lumia)
        }

        // 保存用户名（若有修改）
        if !newName_Lumia.isEmpty && newName_Lumia != originalName_Lumia {
            Task { @MainActor in
                UserViewModel_Lumia.shared_Lumia.updateName_Lumia(userName_lumia: newName_Lumia)
            }
        }

        // 保存个人简介（若有修改）
        if newIntro_Lumia != originalIntro_Lumia {
            Task { @MainActor in
                UserViewModel_Lumia.shared_Lumia.updateIntroduce_Lumia(introduce_lumia: newIntro_Lumia)
            }
        }

        Utils_Lumia.showSuccess_Lumia(message_Lumia: "Profile saved successfully")
        Navigation_Lumia.pop_Lumia()
    }

    /// 将图片保存到文档目录并更新头像 URL
    private func saveImageToDocuments_Lumia(image: UIImage) {
        guard let data_Lumia = image.jpegData(compressionQuality: 0.8) else { return }
        let fileName_Lumia = "avatar_\(Int(Date().timeIntervalSince1970)).jpg"
        let url_Lumia = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName_Lumia)
        try? data_Lumia.write(to: url_Lumia)
        Task { @MainActor in
            UserViewModel_Lumia.shared_Lumia.updateHead_Lumia(headUrl_lumia: url_Lumia.path)
        }
    }
}

// MARK: - UITextFieldDelegate

extension EditInfo_Lumia: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        introTextView_Lumia.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension EditInfo_Lumia: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        introPlaceholder_Lumia.isHidden = !textView.text.isEmpty
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
