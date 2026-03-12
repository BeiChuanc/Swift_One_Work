import Foundation
import UIKit
import SnapKit

// MARK: 修改我的信息

/// 修改用户信息页面
/// 设计风格：浅色渐变背景 + 居中头像选取区 + 表单卡片（用户名 / 简介）+ 底部确认按钮
/// 逻辑：默认填充当前登录用户数据；字段未变则保留原值；保存前检查是否登录；头像通过相册选取后写入 Documents
class EditInfo_Doze: UIViewController {

    // MARK: - 私有状态

    /// 当前选取的新头像图片（nil 表示未修改）
    private var selectedAvatarImage_Doze: UIImage?

    /// 保存新头像后的本地路径（nil 表示未修改）
    private var newAvatarPath_Doze: String?

    // MARK: - 顶部 NavBar

    private let navBar_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Doze: "#F2F0F8")
        return v
    }()

    private let backButton_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = ColorConfig_Doze.textPrimary_Doze
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        btn.layer.cornerRadius = 18
        return btn
    }()

    private let navTitleLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Edit Profile"
        lbl.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        lbl.textColor = ColorConfig_Doze.textPrimary_Doze
        return lbl
    }()

    // MARK: - 滚动容器

    private let scrollView_Doze: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode = .onDrag
        return sv
    }()

    private let contentView_Doze = UIView()

    // MARK: - 头像区域

    /// 头像卡片容器
    private let avatarCardView_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 24
        v.layer.shadowColor = UIColor(hexstring_Doze: "#7B5EA7").withAlphaComponent(0.1).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 14
        v.layer.shadowOpacity = 1
        return v
    }()

    private let avatarCardBanner_Doze: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.clipsToBounds = true
        return v
    }()

    private let avatarCardBannerGl_Doze: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [
            ColorConfig_Doze.primaryGradientStart_Doze.cgColor,
            ColorConfig_Doze.primaryGradientEnd_Doze.cgColor
        ]
        gl.startPoint = CGPoint(x: 0, y: 0)
        gl.endPoint = CGPoint(x: 1, y: 1)
        return gl
    }()

    /// 使用 UserAvatarView_Doze 展示头像（圆形裁剪容器）
    private let avatarWrap_Doze: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 44
        v.layer.borderWidth = 3.5
        v.layer.borderColor = UIColor.white.cgColor
        v.clipsToBounds = true
        return v
    }()

    private let avatarView_Doze: UserAvatarView_Doze = UserAvatarView_Doze()

    /// 覆盖在头像上的相机图标（右下角）
    private let cameraIconView_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Doze.primaryGradientStart_Doze
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.white.cgColor
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        iv.image = UIImage(systemName: "camera.fill", withConfiguration: cfg)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        v.addSubview(iv)
        iv.snp.makeConstraints { make in make.center.equalToSuperview() }
        return v
    }()

    private let avatarHintLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Tap to change photo"
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = ColorConfig_Doze.textSecondary_Doze
        lbl.textAlignment = .center
        return lbl
    }()

    // MARK: - 表单卡片

    private let formCard_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Doze: "#7B5EA7").withAlphaComponent(0.08).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 12
        v.layer.shadowOpacity = 1
        return v
    }()

    // 用户名区域
    private let nameSection_Doze: UIView = UIView()

    private let nameSectionLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Nickname"
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl.textColor = ColorConfig_Doze.primaryGradientStart_Doze
        return lbl
    }()

    private let nameTextField_Doze: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.textColor = ColorConfig_Doze.textPrimary_Doze
        tf.attributedPlaceholder = NSAttributedString(
            string: "Enter your nickname",
            attributes: [.foregroundColor: ColorConfig_Doze.textPlaceholder_Doze]
        )
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .next
        return tf
    }()

    // Bio 区域
    private let bioSection_Doze: UIView = UIView()

    private let bioSectionLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Bio"
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl.textColor = ColorConfig_Doze.primaryGradientStart_Doze
        return lbl
    }()

    private let bioTextView_Doze: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tv.textColor = ColorConfig_Doze.textPrimary_Doze
        tv.backgroundColor = .clear
        tv.returnKeyType = .done
        tv.textContainer.lineFragmentPadding = 0
        tv.isScrollEnabled = false
        return tv
    }()

    private let bioPlaceholder_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Tell others about yourself..."
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lbl.textColor = ColorConfig_Doze.textPlaceholder_Doze
        lbl.numberOfLines = 0
        return lbl
    }()

    private let bioCountLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "0/80"
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl.textColor = ColorConfig_Doze.textPlaceholder_Doze
        lbl.textAlignment = .right
        return lbl
    }()

    // MARK: - 确认按钮

    private let confirmWrapper_Doze: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 26
        v.clipsToBounds = true
        return v
    }()

    private let confirmGradient_Doze: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [
            ColorConfig_Doze.primaryGradientStart_Doze.cgColor,
            ColorConfig_Doze.primaryGradientEnd_Doze.cgColor
        ]
        gl.startPoint = CGPoint(x: 0, y: 0.5)
        gl.endPoint = CGPoint(x: 1, y: 0.5)
        return gl
    }()

    private let confirmButton_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Save Changes", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .clear
        return btn
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Doze: "#F2F0F8")
        setupNavBar_Doze()
        setupScrollView_Doze()
        prefillData_Doze()
        animateEntrance_Doze()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarCardBannerGl_Doze.frame = avatarCardBanner_Doze.bounds
        confirmGradient_Doze.frame = confirmWrapper_Doze.bounds
    }

    // MARK: - NavBar 搭建

    private func setupNavBar_Doze() {
        view.addSubview(navBar_Doze)
        navBar_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }

        navBar_Doze.addSubview(backButton_Doze)
        backButton_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        backButton_Doze.addTarget(self, action: #selector(handleBack_Doze), for: .touchUpInside)

        navBar_Doze.addSubview(navTitleLabel_Doze)
        navTitleLabel_Doze.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    // MARK: - 滚动内容搭建

    private func setupScrollView_Doze() {
        view.addSubview(scrollView_Doze)
        scrollView_Doze.snp.makeConstraints { make in
            make.top.equalTo(navBar_Doze.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }

        scrollView_Doze.addSubview(contentView_Doze)
        contentView_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        setupAvatarCard_Doze()
        setupFormCard_Doze()
        setupConfirmButton_Doze()
    }

    // MARK: - 头像卡搭建

    private func setupAvatarCard_Doze() {
        contentView_Doze.addSubview(avatarCardView_Doze)
        avatarCardView_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview().inset(20)
        }

        // 渐变横幅
        avatarCardView_Doze.addSubview(avatarCardBanner_Doze)
        avatarCardBanner_Doze.layer.addSublayer(avatarCardBannerGl_Doze)
        avatarCardBanner_Doze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(64)
        }

        // 头像圆形容器（叠放在横幅下边）
        avatarCardView_Doze.addSubview(avatarWrap_Doze)
        avatarWrap_Doze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(avatarCardBanner_Doze.snp.bottom)
            make.width.height.equalTo(88)
        }
        avatarWrap_Doze.addSubview(avatarView_Doze)
        avatarView_Doze.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 相机图标（右下角）
        avatarCardView_Doze.addSubview(cameraIconView_Doze)
        cameraIconView_Doze.snp.makeConstraints { make in
            make.right.equalTo(avatarWrap_Doze).offset(2)
            make.bottom.equalTo(avatarWrap_Doze).offset(2)
            make.width.height.equalTo(28)
        }

        // 提示文字
        avatarCardView_Doze.addSubview(avatarHintLabel_Doze)
        avatarHintLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(avatarWrap_Doze.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }

        // 头像区整体可点击
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap_Doze))
        avatarCardView_Doze.addGestureRecognizer(tap)
        avatarCardView_Doze.isUserInteractionEnabled = true
    }

    // MARK: - 表单卡搭建

    private func setupFormCard_Doze() {
        contentView_Doze.addSubview(formCard_Doze)
        formCard_Doze.snp.makeConstraints { make in
            make.top.equalTo(avatarCardView_Doze.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }

        // 用户名 section
        formCard_Doze.addSubview(nameSection_Doze)
        nameSection_Doze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }

        let nameAccent = makeAccentBar_Doze()
        nameSection_Doze.addSubview(nameAccent)
        nameAccent.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(16)
            make.width.equalTo(3)
            make.height.equalTo(16)
        }

        nameSection_Doze.addSubview(nameSectionLabel_Doze)
        nameSectionLabel_Doze.snp.makeConstraints { make in
            make.left.equalTo(nameAccent.snp.right).offset(8)
            make.centerY.equalTo(nameAccent)
        }

        let nameBg = UIView()
        nameBg.backgroundColor = UIColor(hexstring_Doze: "#F3F1FB")
        nameBg.layer.cornerRadius = 12
        nameSection_Doze.addSubview(nameBg)
        nameBg.snp.makeConstraints { make in
            make.top.equalTo(nameSectionLabel_Doze.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-4)
        }
        nameBg.addSubview(nameTextField_Doze)
        nameTextField_Doze.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(14)
        }
        nameTextField_Doze.delegate = self

        // 分隔线
        let sep = UIView()
        sep.backgroundColor = ColorConfig_Doze.divider_Doze
        formCard_Doze.addSubview(sep)
        sep.snp.makeConstraints { make in
            make.top.equalTo(nameSection_Doze.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(0.5)
        }

        // Bio section
        formCard_Doze.addSubview(bioSection_Doze)
        bioSection_Doze.snp.makeConstraints { make in
            make.top.equalTo(sep.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        let bioAccent = makeAccentBar_Doze()
        bioSection_Doze.addSubview(bioAccent)
        bioAccent.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(14)
            make.width.equalTo(3)
            make.height.equalTo(16)
        }

        bioSection_Doze.addSubview(bioSectionLabel_Doze)
        bioSectionLabel_Doze.snp.makeConstraints { make in
            make.left.equalTo(bioAccent.snp.right).offset(8)
            make.centerY.equalTo(bioAccent)
        }

        let bioBg = UIView()
        bioBg.backgroundColor = UIColor(hexstring_Doze: "#F3F1FB")
        bioBg.layer.cornerRadius = 12
        bioSection_Doze.addSubview(bioBg)
        bioBg.snp.makeConstraints { make in
            make.top.equalTo(bioSectionLabel_Doze.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.greaterThanOrEqualTo(80)
        }

        bioBg.addSubview(bioPlaceholder_Doze)
        bioPlaceholder_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.right.equalToSuperview().inset(14)
        }

        bioBg.addSubview(bioTextView_Doze)
        bioTextView_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().offset(-10)
            make.height.greaterThanOrEqualTo(60)
        }
        bioTextView_Doze.delegate = self

        bioSection_Doze.addSubview(bioCountLabel_Doze)
        bioCountLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(bioBg.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-10)
        }
    }

    /// 构建左侧渐变口音条
    private func makeAccentBar_Doze() -> UIView {
        let v = UIView()
        let gl = CAGradientLayer()
        gl.colors = [
            ColorConfig_Doze.primaryGradientStart_Doze.cgColor,
            ColorConfig_Doze.primaryGradientEnd_Doze.cgColor
        ]
        gl.startPoint = CGPoint(x: 0, y: 0)
        gl.endPoint = CGPoint(x: 0, y: 1)
        gl.cornerRadius = 2
        v.layer.cornerRadius = 2
        v.layer.addSublayer(gl)
        DispatchQueue.main.async { gl.frame = v.bounds }
        return v
    }

    // MARK: - 确认按钮搭建

    private func setupConfirmButton_Doze() {
        confirmWrapper_Doze.layer.addSublayer(confirmGradient_Doze)
        contentView_Doze.addSubview(confirmWrapper_Doze)
        confirmWrapper_Doze.snp.makeConstraints { make in
            make.top.equalTo(formCard_Doze.snp.bottom).offset(28)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(52)
            make.bottom.equalToSuperview().offset(-40)
        }

        confirmWrapper_Doze.addSubview(confirmButton_Doze)
        confirmButton_Doze.snp.makeConstraints { make in make.edges.equalToSuperview() }
        confirmButton_Doze.addTarget(self, action: #selector(handleConfirm_Doze), for: .touchUpInside)

        // 爪印图标
        let pawIv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        pawIv.image = UIImage(systemName: "pawprint.fill", withConfiguration: cfg)
        pawIv.tintColor = UIColor.white.withAlphaComponent(0.7)
        confirmWrapper_Doze.addSubview(pawIv)
        pawIv.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
        }
    }

    // MARK: - 数据预填充

    /// 用当前登录用户数据预填各字段
    private func prefillData_Doze() {
        let user = UserViewModel_Doze.shared_Doze.getCurrentUser_Doze()
        avatarView_Doze.configure_Doze(userId_Doze: user.userId_Doze ?? 0)
        nameTextField_Doze.text = user.userName_Doze ?? ""
        let bio = user.userIntroduce_Doze ?? ""
        bioTextView_Doze.text = bio
        bioPlaceholder_Doze.isHidden = !bio.isEmpty
        updateBioCount_Doze(text: bio)
    }

    /// 更新字符计数 badge
    private func updateBioCount_Doze(text: String) {
        let count = min(text.count, 80)
        bioCountLabel_Doze.text = "\(count)/80"
        bioCountLabel_Doze.textColor = count >= 70
            ? ColorConfig_Doze.primaryGradientStart_Doze
            : ColorConfig_Doze.textPlaceholder_Doze
    }

    // MARK: - 保存图片到本地

    /// 将 UIImage 写入 Documents 目录，返回路径
    private func saveAvatarImage_Doze(image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        let fileName = "avatar_\(Int(Date().timeIntervalSince1970)).jpg"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        do {
            try data.write(to: url)
            return url.path
        } catch {
            print("❌ 保存头像失败: \(error)")
            return nil
        }
    }

    // MARK: - 入场动画

    private func animateEntrance_Doze() {
        let targets: [UIView] = [navBar_Doze, avatarCardView_Doze, formCard_Doze, confirmWrapper_Doze]
        targets.enumerated().forEach { idx, v in
            v.alpha = 0
            v.transform = CGAffineTransform(translationX: 0, y: 20)
        }
        for (i, v) in targets.enumerated() {
            UIView.animate(withDuration: 0.44, delay: Double(i) * 0.07,
                           usingSpringWithDamping: 0.84, initialSpringVelocity: 0.3,
                           options: .curveEaseOut) {
                v.alpha = 1
                v.transform = .identity
            }
        }
    }

    // MARK: - 事件处理

    /// 返回
    @objc private func handleBack_Doze() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Doze.pop_Doze()
    }

    /// 点击头像区域选取图片
    @objc private func handleAvatarTap_Doze() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        MediaPickerHelper_Doze.pickImage_Doze(from: self) { [weak self] image in
            guard let self, let image else { return }
            self.selectedAvatarImage_Doze = image
            // 将选取的图片显示在 avatarView 的 imageView 上
            self.avatarView_Doze.imageView_Doze.image = image
        }
    }

    /// 确认保存
    @objc private func handleConfirm_Doze() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        confirmButton_Doze.animatePressDown_Doze { self.confirmButton_Doze.animatePressUp_Doze() }

        // 登录检查
        guard UserViewModel_Doze.shared_Doze.isLoggedIn_Doze else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                Navigation_Doze.toLogin_Doze()
            }
            return
        }

        let vm = UserViewModel_Doze.shared_Doze
        let currentUser = vm.getCurrentUser_Doze()

        // 头像：有新图片则保存
        if let newImg = selectedAvatarImage_Doze {
            if let path = saveAvatarImage_Doze(image: newImg) {
                vm.updateHead_Doze(headUrl_doze: path)
            }
        }

        // 用户名：有修改才更新
        let newName = nameTextField_Doze.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if !newName.isEmpty, newName != currentUser.userName_Doze {
            vm.updateName_Doze(userName_doze: newName)
        }

        // 简介：有修改才更新
        let newBio = bioTextView_Doze.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if newBio != (currentUser.userIntroduce_Doze ?? "") {
            vm.updateIntroduce_Doze(introduce_doze: newBio)
        }

        Utils_Doze.showSuccess_Doze(message_Doze: "Profile updated!")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            Navigation_Doze.pop_Doze()
        }
    }
}

// MARK: - UITextFieldDelegate

extension EditInfo_Doze: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        bioTextView_Doze.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension EditInfo_Doze: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        bioPlaceholder_Doze.isHidden = !text.isEmpty
        // 限制 80 字
        if text.count > 80 {
            textView.text = String(text.prefix(80))
        }
        updateBioCount_Doze(text: textView.text)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
