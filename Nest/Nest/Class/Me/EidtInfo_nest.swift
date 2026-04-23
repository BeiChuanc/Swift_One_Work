import Foundation
import UIKit
import SnapKit

// MARK: - 修改用户信息页面
/// 核心作用：允许已登录用户修改头像、用户名、个人简介
/// 设计思路：
///   - 沉浸式渐变 Header（紧贴屏幕顶部，波浪底边 + 装饰气泡），高度 200pt
///   - 头像悬浮在 Header 底边中心，带渐变双环 + 相机图标遮罩
///   - 表单卡片浮于头像下方，包含 Username / Bio 输入框
///   - 底部全宽渐变保存按钮，带触感反馈与按压动画
///   - contentInsetAdjustmentBehavior = .never 确保顶部无间隙
class EditInfo_Nest: UIViewController {

    // MARK: - 私有状态

    /// 用户选取的新头像图片（nil 表示未修改）
    private var selectedAvatarImage_Nest: UIImage?

    // MARK: - UI 组件

    private let scrollView_Nest: UIScrollView = {
        let sv_Nest = UIScrollView()
        sv_Nest.showsVerticalScrollIndicator = false
        sv_Nest.keyboardDismissMode = .onDrag
        sv_Nest.alwaysBounceVertical = true
        sv_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        sv_Nest.contentInsetAdjustmentBehavior = .never
        return sv_Nest
    }()

    private let contentView_Nest = UIView()

    /// 沉浸式渐变顶部 Header
    private let headerView_Nest = EditInfoHeaderView_Nest()

    /// 头像外环（渐变色，凸出 Header 底部）
    private let avatarOuterRing_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.layer.cornerRadius = 52
        v_Nest.clipsToBounds = true
        return v_Nest
    }()

    private var avatarRingGradient_Nest: CAGradientLayer?

    /// 头像内圆白色间隔
    private let avatarInnerWhite_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        v_Nest.layer.cornerRadius = 48
        v_Nest.clipsToBounds = true
        return v_Nest
    }()

    /// 真实头像视图
    private let avatarView_Nest: CurrentUserAvatarView_Nest = CurrentUserAvatarView_Nest()

    /// 相机遮罩
    private let cameraOverlay_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        v_Nest.layer.cornerRadius = 44
        v_Nest.clipsToBounds = true
        v_Nest.isUserInteractionEnabled = false
        return v_Nest
    }()

    private let cameraIcon_Nest: UIImageView = {
        let iv_Nest = UIImageView(image: UIImage(systemName: "camera.fill"))
        iv_Nest.tintColor = .white
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    // MARK: - 表单

    /// 表单卡片容器
    private let formCard_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        v_Nest.layer.cornerRadius = 24
        v_Nest.layer.shadowColor   = ColorConfig_Nest.shadowColor_Nest.cgColor
        v_Nest.layer.shadowOffset  = CGSize(width: 0, height: 6)
        v_Nest.layer.shadowRadius  = 16
        v_Nest.layer.shadowOpacity = 1
        return v_Nest
    }()

    private let nameLabel_Nest  = makeFormSectionLabel_Nest("Username")
    private let bioLabel_Nest   = makeFormSectionLabel_Nest("Bio")

    private let nameField_Nest: UITextField = {
        let tf_Nest = UITextField()
        tf_Nest.placeholder = "Enter your username"
        tf_Nest.font = UIFont.systemFont(ofSize: 15)
        tf_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        tf_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        tf_Nest.layer.cornerRadius = 14
        tf_Nest.layer.borderWidth = 1.5
        tf_Nest.layer.borderColor = ColorConfig_Nest.border_Nest.cgColor
        tf_Nest.autocapitalizationType = .none
        tf_Nest.autocorrectionType = .no
        tf_Nest.returnKeyType = .next
        return tf_Nest
    }()

    private let bioContainerView_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        v_Nest.layer.cornerRadius = 14
        v_Nest.layer.borderWidth = 1.5
        v_Nest.layer.borderColor = ColorConfig_Nest.border_Nest.cgColor
        return v_Nest
    }()

    private let bioView_Nest: UITextView = {
        let tv_Nest = UITextView()
        tv_Nest.font = UIFont.systemFont(ofSize: 15)
        tv_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        tv_Nest.backgroundColor = .clear
        tv_Nest.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        tv_Nest.layer.cornerRadius = 14
        tv_Nest.clipsToBounds = true
        return tv_Nest
    }()

    private let bioPlaceholder_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Write a short bio..."
        lbl_Nest.font = UIFont.systemFont(ofSize: 15)
        lbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest
        lbl_Nest.isUserInteractionEnabled = false
        return lbl_Nest
    }()

    /// 字符计数标签
    private let bioCountLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "0 / 120"
        lbl_Nest.font = UIFont.systemFont(ofSize: 11)
        lbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest
        lbl_Nest.textAlignment = .right
        return lbl_Nest
    }()

    // MARK: - 保存按钮

    private let saveBtn_Nest: UIButton = {
        let btn_Nest = UIButton(type: .custom)
        btn_Nest.setTitle("Save Changes", for: .normal)
        btn_Nest.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn_Nest.setTitleColor(.white, for: .normal)
        btn_Nest.layer.cornerRadius = 26
        btn_Nest.layer.shadowColor   = ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.4).cgColor
        btn_Nest.layer.shadowOffset  = CGSize(width: 0, height: 6)
        btn_Nest.layer.shadowRadius  = 14
        btn_Nest.layer.shadowOpacity = 1
        return btn_Nest
    }()

    private var saveBtnGradient_Nest: CAGradientLayer?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        setupScrollView_Nest()
        buildHeader_Nest()
        buildAvatar_Nest()
        buildForm_Nest()
        buildSaveButton_Nest()
        prefillData_Nest()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView_Nest.updateCurvedMask_Nest()
        saveBtnGradient_Nest?.frame = saveBtn_Nest.bounds
        avatarRingGradient_Nest?.frame = avatarOuterRing_Nest.bounds
    }

    // MARK: - 布局搭建

    private func setupScrollView_Nest() {
        view.addSubview(scrollView_Nest)
        scrollView_Nest.addSubview(contentView_Nest)
        scrollView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.edges.equalToSuperview()
        }
        contentView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.edges.equalToSuperview()
            make_Nest.width.equalTo(view)
        }
    }

    /// 构建沉浸式 Header
    private func buildHeader_Nest() {
        contentView_Nest.addSubview(headerView_Nest)
        headerView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.leading.trailing.equalToSuperview()
            make_Nest.height.equalTo(200)
        }
        headerView_Nest.onBack_Nest = { [weak self] in Navigation_Nest.pop_Nest(from: self) }
    }

    /// 构建头像区域（悬浮在 Header 底部中心）
    private func buildAvatar_Nest() {
        // 渐变外环
        let gl_Nest = CAGradientLayer()
        gl_Nest.colors = [
            ColorConfig_Nest.primaryGradientStart_Nest.cgColor,
            ColorConfig_Nest.primaryGradientEnd_Nest.cgColor
        ]
        gl_Nest.startPoint = CGPoint(x: 0, y: 0)
        gl_Nest.endPoint   = CGPoint(x: 1, y: 1)
        avatarOuterRing_Nest.layer.insertSublayer(gl_Nest, at: 0)
        avatarRingGradient_Nest = gl_Nest

        // 内部白色间隔
        avatarOuterRing_Nest.addSubview(avatarInnerWhite_Nest)
        // 头像
        avatarInnerWhite_Nest.addSubview(avatarView_Nest)
        // 相机遮罩
        avatarView_Nest.addSubview(cameraOverlay_Nest)
        cameraOverlay_Nest.addSubview(cameraIcon_Nest)

        contentView_Nest.addSubview(avatarOuterRing_Nest)
        avatarOuterRing_Nest.snp.makeConstraints { make_Nest in
            // 顶部在 Header 底边上方 44pt（即悬浮一半）
            make_Nest.centerX.equalToSuperview()
            make_Nest.top.equalTo(headerView_Nest.snp.bottom).offset(-44)
            make_Nest.width.height.equalTo(104)
        }
        avatarInnerWhite_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(96)
        }
        avatarView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(88)
        }
        cameraOverlay_Nest.snp.makeConstraints { make_Nest in
            make_Nest.edges.equalToSuperview()
        }
        cameraIcon_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(26)
        }

        // 点击手势
        avatarOuterRing_Nest.isUserInteractionEnabled = true
        avatarOuterRing_Nest.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onAvatarTapped_Nest))
        )
    }

    /// 构建表单卡片
    private func buildForm_Nest() {
        contentView_Nest.addSubview(formCard_Nest)
        formCard_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(avatarOuterRing_Nest.snp.bottom).offset(20)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.trailing.equalToSuperview().offset(-16)
        }

        // 左侧 person 图标
        let personIconView_Nest = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 52))
        let piv_Nest = UIImageView(image: UIImage(systemName: "person"))
        piv_Nest.tintColor = ColorConfig_Nest.textPlaceholder_Nest
        piv_Nest.contentMode = .scaleAspectFit
        piv_Nest.frame = CGRect(x: 12, y: 14, width: 20, height: 20)
        personIconView_Nest.addSubview(piv_Nest)
        nameField_Nest.leftView = personIconView_Nest
        nameField_Nest.leftViewMode = .always
        nameField_Nest.delegate = self

        // bio 容器
        bioContainerView_Nest.addSubview(bioView_Nest)
        bioContainerView_Nest.addSubview(bioPlaceholder_Nest)
        bioView_Nest.delegate = self

        formCard_Nest.addSubview(nameLabel_Nest)
        formCard_Nest.addSubview(nameField_Nest)
        formCard_Nest.addSubview(bioLabel_Nest)
        formCard_Nest.addSubview(bioContainerView_Nest)
        formCard_Nest.addSubview(bioCountLabel_Nest)

        nameLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(22)
            make_Nest.leading.equalToSuperview().offset(20)
        }
        nameField_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(nameLabel_Nest.snp.bottom).offset(8)
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(-20)
            make_Nest.height.equalTo(52)
        }
        bioLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(nameField_Nest.snp.bottom).offset(18)
            make_Nest.leading.equalToSuperview().offset(20)
        }
        bioContainerView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(bioLabel_Nest.snp.bottom).offset(8)
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(-20)
            make_Nest.height.equalTo(110)
        }
        bioView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.edges.equalToSuperview()
        }
        bioPlaceholder_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(12)
            make_Nest.leading.equalToSuperview().offset(14)
        }
        bioCountLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(bioContainerView_Nest.snp.bottom).offset(6)
            make_Nest.trailing.equalToSuperview().offset(-20)
            make_Nest.bottom.equalToSuperview().offset(-14)
        }
    }

    /// 构建底部保存按钮
    private func buildSaveButton_Nest() {
        let gl_Nest = UIColor.createPrimaryGradientLayer_Nest(frame_Nest: .zero)
        gl_Nest.cornerRadius = 26
        saveBtn_Nest.layer.insertSublayer(gl_Nest, at: 0)
        saveBtnGradient_Nest = gl_Nest
        saveBtn_Nest.addTarget(self, action: #selector(onSaveTapped_Nest), for: .touchUpInside)
        saveBtn_Nest.addTarget(self, action: #selector(onSaveBtnDown_Nest), for: .touchDown)
        saveBtn_Nest.addTarget(self, action: #selector(onSaveBtnUp_Nest), for: [.touchUpOutside, .touchCancel])

        contentView_Nest.addSubview(saveBtn_Nest)
        saveBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(formCard_Nest.snp.bottom).offset(28)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.trailing.equalToSuperview().offset(-16)
            make_Nest.height.equalTo(52)
            make_Nest.bottom.equalToSuperview().offset(-50)
        }
    }

    // MARK: - 数据填充

    /// 预填当前登录用户数据
    private func prefillData_Nest() {
        guard UserViewModel_Nest.shared_Nest.isLoggedIn_Nest else { return }
        let user_Nest = UserViewModel_Nest.shared_Nest.getCurrentUser_Nest()
        nameField_Nest.text = user_Nest.userName_Nest
        if let bio_Nest = user_Nest.userBio_Nest, !bio_Nest.isEmpty {
            bioView_Nest.text = bio_Nest
            bioPlaceholder_Nest.isHidden = true
            updateBioCount_Nest()
        }
    }

    // MARK: - 事件

    /// 更新 bio 字数统计
    private func updateBioCount_Nest() {
        let count_Nest = bioView_Nest.text.count
        bioCountLabel_Nest.text = "\(count_Nest) / 120"
        bioCountLabel_Nest.textColor = count_Nest > 100
            ? UIColor(hexstring_Nest: "#FC8181")
            : ColorConfig_Nest.textPlaceholder_Nest
    }

    /// 点击头像 → 打开相册
    @objc private func onAvatarTapped_Nest() {
        avatarOuterRing_Nest.animatePressDown_Nest {
            self.avatarOuterRing_Nest.animatePressUp_Nest()
        }
        MediaPickerHelper_Nest.pickImage_Nest(from: self) { [weak self] image_Nest in
            guard let self, let image_Nest else { return }
            self.selectedAvatarImage_Nest = image_Nest
            self.avatarView_Nest.imageView_Nest.image = image_Nest
            self.avatarView_Nest.imageView_Nest.contentMode = .scaleAspectFill
        }
    }

    @objc private func onSaveBtnDown_Nest() {
        saveBtn_Nest.animatePressDown_Nest()
    }

    @objc private func onSaveBtnUp_Nest() {
        saveBtn_Nest.animatePressUp_Nest()
    }

    /// 保存修改
    @objc private func onSaveTapped_Nest() {
        saveBtn_Nest.animatePressUp_Nest()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        guard UserViewModel_Nest.shared_Nest.isLoggedIn_Nest else {
            Navigation_Nest.toLogin_Nest(style_nest: .present_nest)
            return
        }

        let current_Nest = UserViewModel_Nest.shared_Nest.getCurrentUser_Nest()

        // 保存新头像
        if let img_Nest = selectedAvatarImage_Nest,
           let data_Nest = img_Nest.jpegData(compressionQuality: 0.8) {
            let path_Nest = FileManager.default.temporaryDirectory
                .appendingPathComponent("user_avatar_\(Int(Date().timeIntervalSince1970)).jpg").path
            try? data_Nest.write(to: URL(fileURLWithPath: path_Nest))
            UserViewModel_Nest.shared_Nest.updateHead_Nest(headUrl_nest: path_Nest)
        }

        // 保存用户名
        let newName_Nest = (nameField_Nest.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !newName_Nest.isEmpty && newName_Nest != current_Nest.userName_Nest {
            UserViewModel_Nest.shared_Nest.updateName_Nest(userName_nest: newName_Nest)
        }

        // 保存简介
        let newBio_Nest = bioView_Nest.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !newBio_Nest.isEmpty && newBio_Nest != current_Nest.userBio_Nest {
            UserViewModel_Nest.shared_Nest.updateBio_Nest(bio_nest: newBio_Nest)
        }

        view.endEditing(true)
        Navigation_Nest.pop_Nest(from: self)
    }
}

// MARK: - UITextViewDelegate

extension EditInfo_Nest: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText_Nest = textView.text ?? ""
        guard let range_Nest = Range(range, in: currentText_Nest) else { return true }
        let updatedText_Nest = currentText_Nest.replacingCharacters(in: range_Nest, with: text)
        return updatedText_Nest.count <= 120
    }

    func textViewDidChange(_ textView: UITextView) {
        bioPlaceholder_Nest.isHidden = !textView.text.isEmpty
        updateBioCount_Nest()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: AnimationConfig_Nest.durationFast_Nest) {
            self.bioContainerView_Nest.layer.borderColor = ColorConfig_Nest.primaryGradientStart_Nest.cgColor
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: AnimationConfig_Nest.durationFast_Nest) {
            self.bioContainerView_Nest.layer.borderColor = ColorConfig_Nest.border_Nest.cgColor
        }
    }
}

// MARK: - UITextFieldDelegate

extension EditInfo_Nest: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        bioView_Nest.becomeFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: AnimationConfig_Nest.durationFast_Nest) {
            textField.layer.borderColor = ColorConfig_Nest.primaryGradientStart_Nest.cgColor
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: AnimationConfig_Nest.durationFast_Nest) {
            textField.layer.borderColor = ColorConfig_Nest.border_Nest.cgColor
        }
    }
}

// MARK: - 表单标签工厂

/// 创建表单区块标签
private func makeFormSectionLabel_Nest(_ text: String) -> UILabel {
    let lbl_Nest = UILabel()
    lbl_Nest.text = text
    lbl_Nest.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
    lbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
    return lbl_Nest
}

// MARK: - EditInfoHeaderView_Nest
/// EditInfo 页面沉浸式渐变 Header
/// 设计：高度 200pt，波浪底边，背景气泡，返回按钮，页面标题与副标题
private class EditInfoHeaderView_Nest: UIView {

    var onBack_Nest: (() -> Void)?

    private var gradientLayer_Nest: CAGradientLayer?

    private let bubble1_Nest = EditInfoHeaderView_Nest.makeBubble_Nest(size: 140, alpha: 0.07)
    private let bubble2_Nest = EditInfoHeaderView_Nest.makeBubble_Nest(size: 80,  alpha: 0.09)
    private let bubble3_Nest = EditInfoHeaderView_Nest.makeBubble_Nest(size: 45,  alpha: 0.12)

    private let backBtn_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v_Nest.layer.cornerRadius = 18
        return v_Nest
    }()

    private let backIcon_Nest: UIImageView = {
        let iv_Nest = UIImageView(image: UIImage(systemName: "chevron.left"))
        iv_Nest.tintColor = .white
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    private let titleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Edit Profile"
        lbl_Nest.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lbl_Nest.textColor = .white
        return lbl_Nest
    }()

    private let subtitleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Update your personal information"
        lbl_Nest.font = UIFont.systemFont(ofSize: 12)
        lbl_Nest.textColor = UIColor.white.withAlphaComponent(0.7)
        return lbl_Nest
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        setupGradient_Nest()
        setupSubviews_Nest()
    }

    required init?(coder: NSCoder) { fatalError() }

    private static func makeBubble_Nest(size: CGFloat, alpha: CGFloat) -> UIView {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Nest.layer.cornerRadius = size / 2
        return v_Nest
    }

    private func setupGradient_Nest() {
        let gl_Nest = UIColor.createPrimaryGradientLayer_Nest(frame_Nest: .zero)
        layer.insertSublayer(gl_Nest, at: 0)
        gradientLayer_Nest = gl_Nest
    }

    private func setupSubviews_Nest() {
        addSubview(bubble1_Nest)
        addSubview(bubble2_Nest)
        addSubview(bubble3_Nest)

        backBtn_Nest.addSubview(backIcon_Nest)
        addSubview(backBtn_Nest)
        addSubview(titleLabel_Nest)
        addSubview(subtitleLabel_Nest)

        bubble1_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(-30)
            make_Nest.trailing.equalToSuperview().offset(30)
            make_Nest.width.height.equalTo(140)
        }
        bubble2_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(50)
            make_Nest.trailing.equalToSuperview().offset(-80)
            make_Nest.width.height.equalTo(80)
        }
        bubble3_Nest.snp.makeConstraints { make_Nest in
            make_Nest.bottom.equalToSuperview().offset(20)
            make_Nest.leading.equalToSuperview().offset(30)
            make_Nest.width.height.equalTo(45)
        }

        backBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(54)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.width.height.equalTo(36)
        }
        backIcon_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(16)
        }
        titleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(backBtn_Nest.snp.trailing).offset(12)
            make_Nest.centerY.equalTo(backBtn_Nest)
        }
        subtitleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(titleLabel_Nest)
            make_Nest.top.equalTo(titleLabel_Nest.snp.bottom).offset(2)
        }

        backBtn_Nest.isUserInteractionEnabled = true
        backBtn_Nest.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backTapped_Nest)))
    }

    /// 刷新渐变 frame 与波浪底边蒙版，需在 viewDidLayoutSubviews 时调用
    func updateCurvedMask_Nest() {
        gradientLayer_Nest?.frame = bounds
        let path_Nest = UIBezierPath()
        path_Nest.move(to: .zero)
        path_Nest.addLine(to: CGPoint(x: bounds.width, y: 0))
        path_Nest.addLine(to: CGPoint(x: bounds.width, y: bounds.height - 18))
        path_Nest.addQuadCurve(
            to: CGPoint(x: 0, y: bounds.height - 18),
            controlPoint: CGPoint(x: bounds.width / 2, y: bounds.height + 26)
        )
        path_Nest.close()
        let mask_Nest = CAShapeLayer()
        mask_Nest.path = path_Nest.cgPath
        layer.mask = mask_Nest
    }

    @objc private func backTapped_Nest() {
        backBtn_Nest.animatePressDown_Nest { self.backBtn_Nest.animatePressUp_Nest() }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onBack_Nest?()
    }
}
