import Foundation
import UIKit
import SnapKit

// MARK: 修改用户信息页面

/// 编辑用户信息视图控制器
/// 功能：修改头像（相册选取）、用户名、用户简介，确认修改
/// 设计：三色渐变头部、渐变头像环、分离字段卡片（蓝色口音条/薄荷口音条）、辅助色保存按钮
class EditInfo_Bague: UIViewController {

    // MARK: - UI 组件（滚动容器）

    private let scrollView_Bague: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode = .interactive
        // 禁止自动添加 safeArea 内边距，让头部渐变紧贴屏幕顶端
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Bague = UIView()

    // MARK: - 头部区域

    private let headerView_Bague = UIView()
    private var headerGradient_Bague: CAGradientLayer?

    /// 返回按钮（半透明胶囊）
    private let backBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return btn
    }()

    private let headerTitleLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "Edit Profile"
        label.font = UIFont.systemFont(ofSize: 22, weight: .black)
        label.textColor = .white
        return label
    }()

    private let headerSubtitle_Bague: UILabel = {
        let label = UILabel()
        label.text = "Update your personal info"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        return label
    }()

    /// 头部装饰：半透明大圆
    private let headerDecorCircle_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.09)
        v.layer.cornerRadius = 50
        return v
    }()

    /// 头部装饰：闪光图标
    private let headerDecorIcon_Bague: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.fill")
        iv.tintColor = UIColor.white.withAlphaComponent(0.15)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - 头像区域

    /// 头像渐变环
    private let avatarRing_Bague: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 56
        return v
    }()

    private var avatarRingGradient_Bague: CAGradientLayer?

    private let avatarContainerView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 50
        return v
    }()

    private let avatarView_Bague = CurrentUserAvatarView_Bague()

    private let cameraOverlay_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        v.layer.cornerRadius = 50
        v.isUserInteractionEnabled = false
        return v
    }()

    private let cameraIcon_Bague: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        iv.image = UIImage(systemName: "camera.fill", withConfiguration: cfg)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let changePhotoBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Change Photo", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        btn.setTitleColor(UIColor(hexstring_Bague: "#9B72F5"), for: .normal)
        btn.backgroundColor = UIColor(hexstring_Bague: "#EDD9FF")
        btn.layer.cornerRadius = 14
        btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
        return btn
    }()

    // MARK: - 用户名输入区

    private let nameSectionRow_Bague = makeSectionRow_EditInfo_Bague(
        icon: "person.fill",
        title: "Username",
        tint: UIColor(hexstring_Bague: "#5AADEC")
    )

    private let nameCard_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor(hexstring_Bague: "#8B9CC8").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowOpacity = 0.1
        v.layer.shadowRadius = 10
        return v
    }()

    private let nameAccentBar_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Bague: "#5AADEC")
        v.layer.cornerRadius = 2
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        return v
    }()

    private let nameField_Bague: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter your username..."
        tf.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tf.textColor = ColorConfig_Bague.textPrimary_Bague
        tf.returnKeyType = .next
        tf.placeHolderTextColor_Bague(ColorConfig_Bague.textPlaceholder_Bague)
        return tf
    }()

    // MARK: - 简介输入区

    private let bioSectionRow_Bague = makeSectionRow_EditInfo_Bague(
        icon: "text.alignleft",
        title: "Bio",
        tint: UIColor(hexstring_Bague: "#3DC9A6")
    )

    private let bioCard_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor(hexstring_Bague: "#8B9CC8").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowOpacity = 0.1
        v.layer.shadowRadius = 10
        return v
    }()

    private let bioAccentBar_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Bague: "#3DC9A6")
        v.layer.cornerRadius = 2
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        return v
    }()

    private let bioField_Bague: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tv.textColor = ColorConfig_Bague.textPrimary_Bague
        tv.backgroundColor = .clear
        tv.returnKeyType = .done
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.isScrollEnabled = false
        return tv
    }()

    private let bioPlaceholder_Bague: UILabel = {
        let label = UILabel()
        label.text = "Tell us about yourself..."
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = ColorConfig_Bague.textPlaceholder_Bague
        return label
    }()

    // MARK: - 保存按钮

    private let confirmBtn_Bague: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        btn.setImage(UIImage(systemName: "checkmark", withConfiguration: cfg), for: .normal)
        btn.setTitle("  Save Changes", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.tintColor = .white
        btn.layer.cornerRadius = 26
        btn.layer.shadowColor = UIColor(hexstring_Bague: "#F07DAD").cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn.layer.shadowOpacity = 0.32
        btn.layer.shadowRadius = 14
        return btn
    }()

    private var confirmBtnGradient_Bague: CAGradientLayer?

    // MARK: - 数据

    private var originalName_Bague: String?
    private var originalBio_Bague: String?
    private var selectedAvatarImage_Bague: UIImage?
    private var hasChanges_Bague: Bool {
        let currentName_bague = nameField_Bague.text ?? ""
        let currentBio_bague = bioField_Bague.text ?? ""
        return currentName_bague != (originalName_Bague ?? "")
            || currentBio_bague != (originalBio_Bague ?? "")
            || selectedAvatarImage_Bague != nil
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Bague()
        setupConstraints_Bague()
        loadUserData_Bague()
        setupKeyboardObservers_Bague()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradients_Bague()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        scrollView_Bague.contentInset.bottom = view.safeAreaInsets.bottom
        scrollView_Bague.verticalScrollIndicatorInsets.bottom = view.safeAreaInsets.bottom
    }

    // MARK: - UI 设置

    private func setupUI_Bague() {
        view.backgroundColor = ColorConfig_Bague.backgroundPrimary_Bague

        view.addSubview(scrollView_Bague)
        scrollView_Bague.addSubview(contentView_Bague)
        contentView_Bague.addSubview(headerView_Bague)

        // 头部
        headerView_Bague.addSubview(headerDecorCircle_Bague)
        headerView_Bague.addSubview(headerDecorIcon_Bague)
        headerView_Bague.addSubview(backBtn_Bague)
        headerView_Bague.addSubview(headerTitleLabel_Bague)
        headerView_Bague.addSubview(headerSubtitle_Bague)
        backBtn_Bague.addTarget(self, action: #selector(backTapped_Bague), for: .touchUpInside)

        // 头像
        contentView_Bague.addSubview(avatarRing_Bague)
        avatarRing_Bague.addSubview(avatarContainerView_Bague)
        avatarContainerView_Bague.addSubview(avatarView_Bague)
        avatarContainerView_Bague.addSubview(cameraOverlay_Bague)
        cameraOverlay_Bague.addSubview(cameraIcon_Bague)
        contentView_Bague.addSubview(changePhotoBtn_Bague)

        // CurrentUserAvatarView 内部有自己的手势拦截触摸，通过 onTapped_Bague 回调路由到选图逻辑
        avatarView_Bague.onTapped_Bague = { [weak self] in
            self?.avatarTapped_Bague()
        }
        // 同时给外层环和下方按钮也绑定，确保任意位置点击都可触发
        let avatarTap_bague = UITapGestureRecognizer(target: self, action: #selector(avatarTapped_Bague))
        avatarRing_Bague.addGestureRecognizer(avatarTap_bague)
        avatarRing_Bague.isUserInteractionEnabled = true
        changePhotoBtn_Bague.addTarget(self, action: #selector(avatarTapped_Bague), for: .touchUpInside)

        // 用户名卡片
        contentView_Bague.addSubview(nameSectionRow_Bague)
        contentView_Bague.addSubview(nameCard_Bague)
        nameCard_Bague.addSubview(nameAccentBar_Bague)
        nameCard_Bague.addSubview(nameField_Bague)
        nameField_Bague.delegate = self

        // 简介卡片
        contentView_Bague.addSubview(bioSectionRow_Bague)
        contentView_Bague.addSubview(bioCard_Bague)
        bioCard_Bague.addSubview(bioAccentBar_Bague)
        bioCard_Bague.addSubview(bioField_Bague)
        bioCard_Bague.addSubview(bioPlaceholder_Bague)
        bioField_Bague.delegate = self

        // 保存按钮
        contentView_Bague.addSubview(confirmBtn_Bague)
        confirmBtn_Bague.addTarget(self, action: #selector(confirmTapped_Bague), for: .touchUpInside)
        confirmBtn_Bague.addTarget(self, action: #selector(btnPressDown_Bague), for: .touchDown)
        confirmBtn_Bague.addTarget(self, action: #selector(btnPressUp_Bague), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        let bgTap_bague = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Bague))
        bgTap_bague.cancelsTouchesInView = false
        scrollView_Bague.addGestureRecognizer(bgTap_bague)
    }

    private func setupConstraints_Bague() {
        scrollView_Bague.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        headerView_Bague.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(170)
        }
        headerDecorCircle_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(25)
            make.top.equalToSuperview().offset(-15)
            make.width.height.equalTo(100)
        }
        // 装饰图标使用相对 headerView 的固定偏移
        headerDecorIcon_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-16)
            make.width.height.equalTo(68)
        }
        backBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(36)
        }
        // 标题紧跟返回按钮，消除红框空白区域
        headerTitleLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(backBtn_Bague.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(24)
        }
        headerSubtitle_Bague.snp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel_Bague.snp.bottom).offset(5)
            make.leading.equalTo(headerTitleLabel_Bague)
        }

        // 头像渐变环
        avatarRing_Bague.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerView_Bague.snp.bottom).offset(-44)
            make.width.height.equalTo(108)
        }
        avatarContainerView_Bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(96)
        }
        avatarView_Bague.snp.makeConstraints { make in make.edges.equalToSuperview().inset(4) }
        cameraOverlay_Bague.snp.makeConstraints { make in make.edges.equalToSuperview() }
        cameraIcon_Bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(26)
        }
        changePhotoBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(avatarRing_Bague.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        // 用户名
        nameSectionRow_Bague.snp.makeConstraints { make in
            make.top.equalTo(changePhotoBtn_Bague.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(24)
        }
        nameCard_Bague.snp.makeConstraints { make in
            make.top.equalTo(nameSectionRow_Bague.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        nameAccentBar_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(24)
        }
        nameField_Bague.snp.makeConstraints { make in
            make.leading.equalTo(nameAccentBar_Bague.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        // 简介
        bioSectionRow_Bague.snp.makeConstraints { make in
            make.top.equalTo(nameCard_Bague.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(24)
        }
        bioCard_Bague.snp.makeConstraints { make in
            make.top.equalTo(bioSectionRow_Bague.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        bioAccentBar_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(14)
            make.width.equalTo(4)
            make.height.equalTo(24)
        }
        bioField_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(bioAccentBar_Bague.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
            make.height.greaterThanOrEqualTo(80)
        }
        bioPlaceholder_Bague.snp.makeConstraints { make in
            make.top.equalTo(bioField_Bague)
            make.leading.equalTo(bioField_Bague)
        }

        // 保存按钮
        confirmBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(bioCard_Bague.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-50)
        }
    }

    // MARK: - 渐变

    private func updateGradients_Bague() {
        // 头部三色渐变
        headerGradient_Bague?.removeFromSuperlayer()
        let hGrad_bague = CAGradientLayer()
        hGrad_bague.frame = headerView_Bague.bounds
        hGrad_bague.colors = [
            UIColor(hexstring_Bague: "#BBA3FF").cgColor,
            UIColor(hexstring_Bague: "#7DC4F0").cgColor,
            UIColor(hexstring_Bague: "#99E8D0").cgColor
        ]
        hGrad_bague.locations = [0.0, 0.55, 1.0]
        hGrad_bague.startPoint = CGPoint(x: 0, y: 0)
        hGrad_bague.endPoint = CGPoint(x: 1, y: 1)
        hGrad_bague.cornerRadius = 28
        hGrad_bague.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Bague.layer.insertSublayer(hGrad_bague, at: 0)
        headerGradient_Bague = hGrad_bague

        // 头像渐变环
        avatarRingGradient_Bague?.removeFromSuperlayer()
        let ring_bague = CAGradientLayer()
        ring_bague.frame = avatarRing_Bague.bounds
        ring_bague.colors = [
            UIColor(hexstring_Bague: "#BBA3FF").cgColor,
            UIColor(hexstring_Bague: "#7DC4F0").cgColor
        ]
        ring_bague.startPoint = CGPoint(x: 0, y: 0)
        ring_bague.endPoint = CGPoint(x: 1, y: 1)
        ring_bague.cornerRadius = 56
        avatarRing_Bague.layer.insertSublayer(ring_bague, at: 0)
        avatarRingGradient_Bague = ring_bague

        // 保存按钮：玫瑰粉 → 珊瑚橙
        confirmBtnGradient_Bague?.removeFromSuperlayer()
        let bGrad_bague = CAGradientLayer()
        bGrad_bague.frame = confirmBtn_Bague.bounds
        bGrad_bague.colors = [
            UIColor(hexstring_Bague: "#F07DAD").cgColor,
            UIColor(hexstring_Bague: "#FFA07A").cgColor
        ]
        bGrad_bague.startPoint = CGPoint(x: 0, y: 0)
        bGrad_bague.endPoint = CGPoint(x: 1, y: 0)
        bGrad_bague.cornerRadius = 26
        confirmBtn_Bague.layer.insertSublayer(bGrad_bague, at: 0)
        confirmBtnGradient_Bague = bGrad_bague
    }

    // MARK: - 键盘处理

    private func setupKeyboardObservers_Bague() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Bague(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Bague(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow_Bague(_ notification: Notification) {
        guard let frame_bague = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_bague = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration_bague) {
            self.scrollView_Bague.contentInset.bottom = frame_bague.height + 20
        }
    }

    @objc private func keyboardWillHide_Bague(_ notification: Notification) {
        guard let duration_bague = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration_bague) {
            self.scrollView_Bague.contentInset.bottom = 0
        }
    }

    @objc private func dismissKeyboard_Bague() { view.endEditing(true) }

    // MARK: - 数据加载

    private func loadUserData_Bague() {
        let user_bague = UserViewModel_Bague.shared_Bague.getCurrentUser_Bague()
        originalName_Bague = user_bague.userName_Bague
        originalBio_Bague = user_bague.userIntroduce_Bague
        nameField_Bague.text = user_bague.userName_Bague
        bioField_Bague.text = user_bague.userIntroduce_Bague
        bioPlaceholder_Bague.isHidden = !(user_bague.userIntroduce_Bague?.isEmpty ?? true)
    }

    // MARK: - 事件处理

    @objc private func backTapped_Bague() { Navigation_Bague.pop_Bague() }

    @objc private func avatarTapped_Bague() {
        avatarRing_Bague.animatePulse_Bague()
        MediaPickerHelper_Bague.pickImage_Bague(from: self) { [weak self] image_bague in
            guard let self = self, let image_bague = image_bague else { return }
            self.selectedAvatarImage_Bague = image_bague
            self.avatarView_Bague.imageView_Bague.image = image_bague
            self.avatarView_Bague.imageView_Bague.contentMode = .scaleAspectFill
        }
    }

    @objc private func btnPressDown_Bague() { confirmBtn_Bague.animatePressDown_Bague() }
    @objc private func btnPressUp_Bague() { confirmBtn_Bague.animatePressUp_Bague() }

    @objc private func confirmTapped_Bague() {
        view.endEditing(true)

        guard hasChanges_Bague else {
            Utils_Bague.showInfo_Bague(message_Bague: "No changes detected")
            return
        }

        if let image_bague = selectedAvatarImage_Bague,
           let data_bague = image_bague.jpegData(compressionQuality: 0.8) {
            let path_bague = NSTemporaryDirectory() + "user_avatar_\(Date().timeIntervalSince1970).jpg"
            try? data_bague.write(to: URL(fileURLWithPath: path_bague))
            Task { @MainActor in
                UserViewModel_Bague.shared_Bague.updateHead_Bague(headUrl_bague: path_bague)
            }
        }

        let newName_bague = nameField_Bague.text ?? ""
        if !newName_bague.isEmpty, newName_bague != originalName_Bague {
            Task { @MainActor in
                UserViewModel_Bague.shared_Bague.updateName_Bague(userName_bague: newName_bague)
            }
        }

        let newBio_bague = bioField_Bague.text ?? ""
        if newBio_bague != originalBio_Bague {
            Task { @MainActor in
                UserViewModel_Bague.shared_Bague.updateIntroduce_Bague(introduce_bague: newBio_bague)
            }
        }

        Utils_Bague.showSuccess_Bague(message_Bague: "Profile updated!")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            Navigation_Bague.pop_Bague()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextFieldDelegate

extension EditInfo_Bague: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField_Bague {
            bioField_Bague.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - UITextViewDelegate

extension EditInfo_Bague: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        bioPlaceholder_Bague.isHidden = !textView.text.isEmpty
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

// MARK: - 辅助工厂方法

/// 创建带彩色图标的区段标题行视图（与发布页风格统一）
private func makeSectionRow_EditInfo_Bague(icon: String, title: String, tint: UIColor) -> UIView {
    let container_bague = UIView()
    let iconView_bague = UIImageView()
    let cfg_bague = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
    iconView_bague.image = UIImage(systemName: icon, withConfiguration: cfg_bague)
    iconView_bague.tintColor = tint
    iconView_bague.contentMode = .scaleAspectFit
    let label_bague = UILabel()
    label_bague.text = title.uppercased()
    label_bague.font = UIFont.systemFont(ofSize: 11, weight: .bold)
    label_bague.textColor = tint
    container_bague.addSubview(iconView_bague)
    container_bague.addSubview(label_bague)
    iconView_bague.snp.makeConstraints { make in
        make.leading.centerY.equalToSuperview()
        make.width.height.equalTo(14)
    }
    label_bague.snp.makeConstraints { make in
        make.leading.equalTo(iconView_bague.snp.trailing).offset(6)
        make.centerY.top.bottom.trailing.equalToSuperview()
    }
    return container_bague
}
