import Foundation
import UIKit
import SnapKit
import PhotosUI

// MARK: - 修改用户信息页面

/// 修改用户信息页面
/// 核心作用：允许登录用户修改头像、昵称、个人简介，提交时判断登录状态并按需更新
/// 设计思路：顶部渐变卡片展示 CurrentUserAvatarView_Pane + 用户名；
///          中间卡片包含输入框（Name / Bio）；底部确认按钮；
///          数据未改变则保留原值，仅更新实际修改的字段
/// 关键属性：
/// - originalName_Pane / originalIntro_Pane: 保存进入页面时的原始数据，用于对比是否修改
/// - selectedAvatarPath_Pane: 从相册选取的新头像文件路径（为 nil 表示未修改头像）
class EditInfo_Pane: UIViewController {

    // MARK: - 属性

    /// 原始昵称（用于对比是否有修改）
    private var originalName_Pane: String?
    /// 原始简介（用于对比是否有修改）
    private var originalIntro_Pane: String?
    /// 从相册选取后存储的新头像路径（nil 表示未修改头像）
    private var selectedAvatarPath_Pane: String?

    // MARK: - UI · 外层滚动

    private let scrollView_Pane: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode = .onDrag
        // 关闭自动 SafeArea 偏移，让渐变头部从屏幕最顶端开始渲染
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()
    private let contentView_Pane = UIView()

    // MARK: - UI · 顶部头像卡片

    private let headerCard_Pane: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()
    private var headerGradient_Pane: CAGradientLayer?

    /// 装饰圆
    private let decorCircle_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.layer.cornerRadius = 45
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 当前用户头像（支持点击更换）
    private let avatarView_Pane: CurrentUserAvatarView_Pane = {
        let v = CurrentUserAvatarView_Pane()
        v.showEditButton_Pane = true
        v.layer.cornerRadius = 48
        v.clipsToBounds = true
        v.layer.borderWidth = 4
        v.layer.borderColor = UIColor.white.cgColor
        return v
    }()

    /// 提示文案
    private let tapHintLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "Tap to change avatar"
        l.font = .systemFont(ofSize: 11)
        l.textColor = UIColor.white.withAlphaComponent(0.8)
        l.textAlignment = .center
        return l
    }()

    // MARK: - UI · 输入卡片

    private let inputCard_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.cardBackground_Pane
        v.layer.cornerRadius = 20
        v.layer.shadowColor  = ColorConfig_Pane.shadowColor_Pane.cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowOffset  = CGSize(width: 0, height: 4)
        v.layer.shadowRadius  = 10
        return v
    }()

    /// Name 标签
    private let nameSectionLabel_Pane: UILabel = buildSectionLabel_Pane(text_pane: "Name")

    /// 姓名输入框容器
    private let nameFieldContainer_Pane: UIView = buildFieldContainer_Pane()

    /// 姓名输入框
    private let nameField_Pane: UITextField = {
        let tf = UITextField()
        tf.font        = .systemFont(ofSize: 15)
        tf.textColor   = ColorConfig_Pane.textPrimary_Pane
        tf.placeholder = "Your display name"
        tf.returnKeyType = .next
        tf.clearButtonMode = .whileEditing
        return tf
    }()

    /// Bio 标签
    private let bioSectionLabel_Pane: UILabel = buildSectionLabel_Pane(text_pane: "Introduce")

    /// 简介输入框容器
    private let bioFieldContainer_Pane: UIView = buildFieldContainer_Pane()

    /// 简介输入框
    private let bioTextView_Pane: UITextView = {
        let tv = UITextView()
        tv.font            = .systemFont(ofSize: 15)
        tv.textColor       = ColorConfig_Pane.textPrimary_Pane
        tv.backgroundColor = .clear
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.isScrollEnabled = false
        return tv
    }()

    /// Bio 占位文本
    private let bioPlaceholder_Pane: UILabel = {
        let l = UILabel()
        l.text      = "Tell something about yourself..."
        l.font      = .systemFont(ofSize: 15)
        l.textColor = ColorConfig_Pane.textPlaceholder_Pane
        return l
    }()

    // MARK: - UI · 底部按钮

    private let confirmButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("Confirm Changes", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 24
        b.clipsToBounds = true
        return b
    }()

    private var confirmBtnGradient_Pane: CAGradientLayer?

    // MARK: - 工厂方法（纯静态辅助，避免在 stored property 初始化时引用 self）

    /// 构建 Section 标签
    private static func buildSectionLabel_Pane(text_pane: String) -> UILabel {
        let l = UILabel()
        l.text      = text_pane
        l.font      = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = ColorConfig_Pane.textSecondary_Pane
        return l
    }

    /// 构建输入容器背景
    private static func buildFieldContainer_Pane() -> UIView {
        let v = UIView()
        v.backgroundColor  = ColorConfig_Pane.backgroundSecondary_Pane
        v.layer.cornerRadius = 12
        return v
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Pane()
        setupActions_Pane()
        prefillData_Pane()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Pane?.frame     = headerCard_Pane.bounds
        confirmBtnGradient_Pane?.frame = confirmButton_Pane.bounds
        applyHeaderRoundBottom_Pane()
    }

    /// 头部卡片裁剪圆弧底边
    private func applyHeaderRoundBottom_Pane() {
        guard headerCard_Pane.bounds.height > 0 else { return }
        let path_pane = UIBezierPath(
            roundedRect: headerCard_Pane.bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 28, height: 28)
        )
        let mask_pane = CAShapeLayer()
        mask_pane.path = path_pane.cgPath
        headerCard_Pane.layer.mask = mask_pane
    }

    // MARK: - UI 搭建

    private func setupUI_Pane() {
        view.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane

        // 滚动容器
        view.addSubview(scrollView_Pane)
        scrollView_Pane.addSubview(contentView_Pane)

        // 头部卡片
        contentView_Pane.addSubview(headerCard_Pane)
        headerCard_Pane.addSubview(decorCircle_Pane)
        headerCard_Pane.addSubview(avatarView_Pane)
        headerCard_Pane.addSubview(tapHintLabel_Pane)

        // 自定义返回按钮（右上角不需要，左上角）
        let backBtn_pane = buildNavBackButton_Pane()
        headerCard_Pane.addSubview(backBtn_pane)

        // 输入卡片
        contentView_Pane.addSubview(inputCard_Pane)
        inputCard_Pane.addSubview(nameSectionLabel_Pane)
        inputCard_Pane.addSubview(nameFieldContainer_Pane)
        nameFieldContainer_Pane.addSubview(nameField_Pane)
        inputCard_Pane.addSubview(bioSectionLabel_Pane)
        inputCard_Pane.addSubview(bioFieldContainer_Pane)
        bioFieldContainer_Pane.addSubview(bioTextView_Pane)
        bioFieldContainer_Pane.addSubview(bioPlaceholder_Pane)

        // 确认按钮
        contentView_Pane.addSubview(confirmButton_Pane)

        setupHeaderGradient_Pane()
        setupConfirmGradient_Pane()
        setupConstraints_Pane(backBtn_pane: backBtn_pane)

        nameField_Pane.delegate   = self
        bioTextView_Pane.delegate = self
    }

    /// 构建自定义返回按钮
    private func buildNavBackButton_Pane() -> UIButton {
        let b = UIButton(type: .custom)
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_pane)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor      = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        b.addTarget(self, action: #selector(backTapped_Pane), for: .touchUpInside)
        return b
    }

    private func setupHeaderGradient_Pane() {
        let gl_pane = CAGradientLayer()
        gl_pane.colors = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        gl_pane.startPoint = CGPoint(x: 0, y: 0)
        gl_pane.endPoint   = CGPoint(x: 1, y: 1)
        headerCard_Pane.layer.insertSublayer(gl_pane, at: 0)
        headerGradient_Pane = gl_pane
    }

    private func setupConfirmGradient_Pane() {
        let gl_pane = CAGradientLayer()
        gl_pane.colors = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        gl_pane.startPoint = CGPoint(x: 0, y: 0.5)
        gl_pane.endPoint   = CGPoint(x: 1, y: 0.5)
        confirmButton_Pane.layer.insertSublayer(gl_pane, at: 0)
        confirmBtnGradient_Pane = gl_pane
    }

    private func setupConstraints_Pane(backBtn_pane: UIButton) {
        scrollView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Pane.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView_Pane)
        }

        // 头部卡片
        headerCard_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(170)
        }
        decorCircle_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(20)
            $0.width.height.equalTo(90)
        }
        backBtn_pane.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(36)
        }
        avatarView_Pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(26)
            $0.width.height.equalTo(96)
        }
        tapHintLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(avatarView_Pane.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }

        // 输入卡片
        inputCard_Pane.snp.makeConstraints {
            $0.top.equalTo(headerCard_Pane.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        nameSectionLabel_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(16)
        }
        nameFieldContainer_Pane.snp.makeConstraints {
            $0.top.equalTo(nameSectionLabel_Pane.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
        nameField_Pane.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(14)
            $0.centerY.equalToSuperview()
        }
        bioSectionLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(nameFieldContainer_Pane.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(16)
        }
        bioFieldContainer_Pane.snp.makeConstraints {
            $0.top.equalTo(bioSectionLabel_Pane.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-20)
        }
        bioTextView_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(14)
            $0.bottom.equalToSuperview().offset(-12)
            $0.height.greaterThanOrEqualTo(80)
        }
        bioPlaceholder_Pane.snp.makeConstraints {
            $0.top.leading.equalTo(bioTextView_Pane)
        }

        // 确认按钮
        confirmButton_Pane.snp.makeConstraints {
            $0.top.equalTo(inputCard_Pane.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-40)
        }
    }

    // MARK: - 数据填充

    /// 用登录用户原始数据预填充输入框
    private func prefillData_Pane() {
        let user_pane = UserViewModel_Pane.shared_Pane.getCurrentUser_Pane()
        let name_pane  = user_pane.userName_Pane ?? ""
        let intro_pane = user_pane.userIntroduce_Pane ?? ""
        originalName_Pane  = name_pane
        originalIntro_Pane = intro_pane
        nameField_Pane.text = name_pane
        if !intro_pane.isEmpty {
            bioTextView_Pane.text = intro_pane
            bioPlaceholder_Pane.isHidden = true
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Pane() {
        confirmButton_Pane.addTarget(self, action: #selector(confirmTapped_Pane), for: .touchUpInside)
        avatarView_Pane.onTapped_Pane = { [weak self] in
            self?.pickAvatar_Pane()
        }
    }

    /// 返回上一页
    @objc private func backTapped_Pane() {
        if let nav_pane = navigationController, nav_pane.viewControllers.count > 1 {
            nav_pane.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    /// 确认修改
    /// 功能：校验登录状态 → 逐字段比较是否修改 → 按需调用 ViewModel 更新方法
    @objc private func confirmTapped_Pane() {
        guard UserViewModel_Pane.shared_Pane.isLoggedIn_Pane else {
            Navigation_Pane.toLogin_Pane()
            return
        }

        let newName_pane  = nameField_Pane.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let newIntro_pane = bioTextView_Pane.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        var hasChange_pane = false

        // 更新头像（仅选取了新头像才更新）
        if let path_pane = selectedAvatarPath_Pane {
            UserViewModel_Pane.shared_Pane.updateHead_Pane(headUrl_pane: path_pane)
            hasChange_pane = true
        }

        // 更新昵称（仅实际修改过才更新）
        if !newName_pane.isEmpty, newName_pane != originalName_Pane {
            UserViewModel_Pane.shared_Pane.updateName_Pane(userName_pane: newName_pane)
            hasChange_pane = true
        }

        // 更新简介（仅实际修改过才更新）
        if newIntro_pane != originalIntro_Pane {
            UserViewModel_Pane.shared_Pane.updateIntroduce_Pane(introduce_pane: newIntro_pane)
            hasChange_pane = true
        }

        if !hasChange_pane {
            Utils_Pane.showInfo_Pane(message_Pane: "No changes to save.")
            return
        }

        // 稍作延迟后返回，让 showSuccess toast 先弹出
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.backTapped_Pane()
        }
    }

    // MARK: - 头像选取

    /// 从相册选取头像图片
    private func pickAvatar_Pane() {
        MediaPickerHelper_Pane.shared_Pane.showPicker_Pane(
            from: self,
            mediaType_Pane: .photo_Pane
        ) { [weak self] result_pane in
            guard let self = self else { return }
            switch result_pane {
            case .photo_Pane(let image_pane):
                self.handleSelectedAvatar_Pane(image_pane: image_pane)
            default:
                break
            }
        }
    }

    /// 将选取的头像保存为本地文件，并更新 UI
    /// - Parameter image_pane: 从相册选取的 UIImage
    private func handleSelectedAvatar_Pane(image_pane: UIImage) {
        // 保存到 Documents 目录
        let fileName_pane = "avatar_\(Date().timeIntervalSince1970).jpg"
        let url_pane = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName_pane)
        if let data_pane = image_pane.jpegData(compressionQuality: 0.8) {
            try? data_pane.write(to: url_pane)
            selectedAvatarPath_Pane = url_pane.path
        }
        // 更新头像组件展示（直接赋值 imageView）
        avatarView_Pane.imageView_Pane.image = image_pane
        print("已选取新头像，暂存路径：\(url_pane.path)")
    }
}

// MARK: - UITextFieldDelegate

extension EditInfo_Pane: UITextFieldDelegate {
    /// 按下 Next 键时跳转到 Bio 输入框
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        bioTextView_Pane.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension EditInfo_Pane: UITextViewDelegate {
    /// Bio 输入内容变化时控制占位文本显示
    func textViewDidChange(_ textView: UITextView) {
        bioPlaceholder_Pane.isHidden = !textView.text.isEmpty
    }
}
