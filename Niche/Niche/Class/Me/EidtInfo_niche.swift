import Foundation
import UIKit
import SnapKit

// MARK: 编辑用户信息页面

/// 编辑用户信息视图控制器
/// 功能：修改头像（从相册）、用户名、简介，确认保存
/// 设计：渐变顶部 + 渐变环头像区 + 表单卡片（图标+标签+输入框）+ 渐变保存按钮
/// 关键：默认填充登录用户数据；仅保存有变动的字段；未登录跳转登录
class EditInfo_Niche: UIViewController {

    // MARK: - 私有属性

    private var _selectedAvatar_niche: UIImage?

    // MARK: - UI 组件 / 顶部

    private let _topBg_niche = UIView()

    private let _topOrb_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor.white.withValues(alpha: 0.10)
        v_niche.layer.cornerRadius = 44
        v_niche.isUserInteractionEnabled = false
        return v_niche
    }()

    private let _backBtn_niche = BackButton_Niche()

    private let _pageTitleLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Edit Profile"
        l_niche.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        l_niche.textColor = .white
        return l_niche
    }()

    private let _pageSubtitle_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Update your tribe identity"
        l_niche.font = UIFont.systemFont(ofSize: 12)
        l_niche.textColor = UIColor.white.withValues(alpha: 0.7)
        return l_niche
    }()

    // MARK: - UI 组件 / 头像区域

    /// 头像外圈（渐变圆环）
    private let _avatarRing_niche: UIView = {
        let v_niche = UIView()
        v_niche.layer.cornerRadius = 54
        return v_niche
    }()
    private var _avatarRingGrad_niche: CAGradientLayer?

    private let _avatarView_niche = CurrentUserAvatarView_Niche()

    /// 相机遮罩（作为头像区域点击的最顶层响应视图）
    private let _cameraMask_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor.black.withValues(alpha: 0.38)
        v_niche.layer.cornerRadius = 51
        v_niche.isUserInteractionEnabled = true
        return v_niche
    }()

    private let _cameraIcon_niche: UIImageView = {
        let iv_niche = UIImageView()
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        iv_niche.image = UIImage(systemName: "camera.fill", withConfiguration: cfg_niche)
        iv_niche.tintColor = .white
        iv_niche.contentMode = .scaleAspectFit
        return iv_niche
    }()

    private let _changePhotoLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Change Photo"
        l_niche.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        l_niche.textColor = ColorConfig_Niche.primaryGradientStart_Niche
        l_niche.textAlignment = .center
        return l_niche
    }()

    // MARK: - UI 组件 / 表单卡片

    private let _formCard_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = .white
        v_niche.layer.cornerRadius = 22
        v_niche.layer.shadowColor = UIColor(hexstring_Niche: "#B794F6").withValues(alpha: 0.12).cgColor
        v_niche.layer.shadowOffset = CGSize(width: 0, height: 6)
        v_niche.layer.shadowRadius = 16
        v_niche.layer.shadowOpacity = 1
        return v_niche
    }()

    // 用户名区块
    private let _nameSectionLabel_niche: UILabel = makeSectionLabel_Niche("USERNAME", color: ColorConfig_Niche.primaryGradientStart_Niche)
    private let _nameIcon_niche: UIImageView = makeFieldIcon_Niche("person.fill", color: ColorConfig_Niche.primaryGradientStart_Niche)
    private let _usernameField_niche: UITextField = {
        let tf_niche = UITextField()
        tf_niche.placeholder = "Your username..."
        tf_niche.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        tf_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        tf_niche.backgroundColor = .clear
        tf_niche.autocapitalizationType = .none
        tf_niche.autocorrectionType = .no
        return tf_niche
    }()

    // 分割线
    private let _divider_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = ColorConfig_Niche.divider_Niche
        return v_niche
    }()

    // 简介区块
    private let _bioSectionLabel_niche: UILabel = makeSectionLabel_Niche("BIO", color: ColorConfig_Niche.secondaryGradientStart_Niche)
    private let _bioIcon_niche: UIImageView = makeFieldIcon_Niche("text.bubble.fill", color: ColorConfig_Niche.secondaryGradientStart_Niche)
    private let _bioTextView_niche: UITextView = {
        let tv_niche = UITextView()
        tv_niche.font = UIFont.systemFont(ofSize: 15)
        tv_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        tv_niche.backgroundColor = .clear
        tv_niche.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tv_niche.textContainer.lineFragmentPadding = 0
        return tv_niche
    }()

    private let _bioPlaceholder_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Tell your tribe about yourself..."
        l_niche.font = UIFont.systemFont(ofSize: 15)
        l_niche.textColor = ColorConfig_Niche.textPlaceholder_Niche
        l_niche.numberOfLines = 0
        return l_niche
    }()

    // MARK: - UI 组件 / 保存按钮

    private let _saveButton_niche: UIButton = {
        let btn_niche = UIButton(type: .custom)
        btn_niche.layer.cornerRadius = 22
        btn_niche.clipsToBounds = true
        return btn_niche
    }()

    private let _saveIcon_niche: UIImageView = {
        let iv_niche = UIImageView()
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        iv_niche.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: cfg_niche)
        iv_niche.tintColor = .white
        iv_niche.contentMode = .scaleAspectFit
        iv_niche.isUserInteractionEnabled = false
        return iv_niche
    }()

    private let _saveTitleLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Save Changes"
        l_niche.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        l_niche.textColor = .white
        l_niche.isUserInteractionEnabled = false
        return l_niche
    }()

    // MARK: - 辅助工厂

    private static func makeSectionLabel_Niche(_ text: String, color: UIColor) -> UILabel {
        let l_niche = UILabel()
        l_niche.text = text
        l_niche.font = UIFont.systemFont(ofSize: 10, weight: .heavy)
        l_niche.textColor = color
        return l_niche
    }

    private static func makeFieldIcon_Niche(_ symbol: String, color: UIColor) -> UIImageView {
        let iv_niche = UIImageView()
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        iv_niche.image = UIImage(systemName: symbol, withConfiguration: cfg_niche)
        iv_niche.tintColor = color
        iv_niche.contentMode = .scaleAspectFit
        return iv_niche
    }

    // MARK: - 滚动视图

    private let _scrollView_niche: UIScrollView = {
        let sv_niche = UIScrollView()
        sv_niche.showsVerticalScrollIndicator = false
        sv_niche.keyboardDismissMode = .onDrag
        return sv_niche
    }()
    private let _contentView_niche = UIView()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Niche()
        fillDefaultData_Niche()
        setupActions_Niche()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshTopGradient_Niche()
        refreshSaveBtnGradient_Niche()
        refreshAvatarRingGrad_Niche()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 构建

    private func setupUI_Niche() {
        view.backgroundColor = UIColor(hexstring_Niche: "#F4F0FF")

        // 顶部背景
        view.addSubview(_topBg_niche)
        _topBg_niche.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(145)
        }

        _topBg_niche.addSubview(_topOrb_niche)
        _topOrb_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-16)
            make.trailing.equalToSuperview().offset(14)
            make.width.height.equalTo(88)
        }

        view.addSubview(_backBtn_niche)
        _backBtn_niche.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(44)
        }
        _backBtn_niche.onTapped_Niche = { Navigation_Niche.pop_Niche() }

        _topBg_niche.addSubview(_pageTitleLabel_niche)
        _pageTitleLabel_niche.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-26)
            make.centerX.equalToSuperview()
        }

        _topBg_niche.addSubview(_pageSubtitle_niche)
        _pageSubtitle_niche.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-8)
            make.centerX.equalToSuperview()
        }

        // 滚动区域
        view.addSubview(_scrollView_niche)
        _scrollView_niche.snp.makeConstraints { make in
            make.top.equalTo(_topBg_niche.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        _scrollView_niche.addSubview(_contentView_niche)
        _contentView_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        buildAvatarSection_Niche()
        buildFormCard_Niche()
        buildSaveButton_Niche()
    }

    private func buildAvatarSection_Niche() {
        // 头像外圈
        _contentView_niche.addSubview(_avatarRing_niche)
        _avatarRing_niche.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(108)
        }

        _avatarRing_niche.addSubview(_avatarView_niche)
        _avatarView_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
        }

        // 相机遮罩
        _avatarView_niche.addSubview(_cameraMask_niche)
        _cameraMask_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        _cameraMask_niche.addSubview(_cameraIcon_niche)
        _cameraIcon_niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }

        // 点击提示文字
        _contentView_niche.addSubview(_changePhotoLabel_niche)
        _changePhotoLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_avatarRing_niche.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        // 手势绑定在相机遮罩（最顶层，确保触摸可被捕获）
        let maskTap_niche = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap_Niche))
        _cameraMask_niche.addGestureRecognizer(maskTap_niche)

        // "Change Photo" 文字也响应点击
        _changePhotoLabel_niche.isUserInteractionEnabled = true
        let labelTap_niche = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap_Niche))
        _changePhotoLabel_niche.addGestureRecognizer(labelTap_niche)
    }

    private func buildFormCard_Niche() {
        _contentView_niche.addSubview(_formCard_niche)
        _formCard_niche.snp.makeConstraints { make in
            make.top.equalTo(_changePhotoLabel_niche.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(18)
        }

        // 用户名区块（先全部 addSubview 再统一约束）
        _formCard_niche.addSubview(_nameSectionLabel_niche)
        _formCard_niche.addSubview(_nameIcon_niche)
        _formCard_niche.addSubview(_usernameField_niche)

        _nameSectionLabel_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalToSuperview().offset(18)
        }

        _nameIcon_niche.snp.makeConstraints { make in
            make.top.equalTo(_nameSectionLabel_niche.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(22)
        }

        _usernameField_niche.snp.makeConstraints { make in
            make.centerY.equalTo(_nameIcon_niche)
            make.leading.equalTo(_nameIcon_niche.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(40)
        }
        _usernameField_niche.placeHolderTextColor_Niche(ColorConfig_Niche.textPlaceholder_Niche)

        // 分割线
        _formCard_niche.addSubview(_divider_niche)
        _divider_niche.snp.makeConstraints { make in
            make.top.equalTo(_usernameField_niche.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(0.5)
        }

        // 简介区块
        _formCard_niche.addSubview(_bioSectionLabel_niche)
        _formCard_niche.addSubview(_bioIcon_niche)
        _formCard_niche.addSubview(_bioTextView_niche)
        _formCard_niche.addSubview(_bioPlaceholder_niche)

        _bioSectionLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_divider_niche.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(18)
        }

        _bioIcon_niche.snp.makeConstraints { make in
            make.top.equalTo(_bioSectionLabel_niche.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(22)
        }

        _bioTextView_niche.snp.makeConstraints { make in
            make.top.equalTo(_bioSectionLabel_niche.snp.bottom).offset(8)
            make.leading.equalTo(_bioIcon_niche.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(100)
            make.bottom.equalToSuperview().offset(-16)
        }

        _bioPlaceholder_niche.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(_bioTextView_niche)
        }
    }

    private func buildSaveButton_Niche() {
        _contentView_niche.addSubview(_saveButton_niche)
        _saveButton_niche.snp.makeConstraints { make in
            make.top.equalTo(_formCard_niche.snp.bottom).offset(22)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-30)
        }

        _saveButton_niche.addSubview(_saveIcon_niche)
        _saveButton_niche.addSubview(_saveTitleLabel_niche)

        _saveIcon_niche.snp.makeConstraints { make in
            make.trailing.equalTo(_saveTitleLabel_niche.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        _saveTitleLabel_niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    // MARK: - 渐变刷新

    private func refreshTopGradient_Niche() {
        _topBg_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        guard !_topBg_niche.bounds.isEmpty else { return }
        let grad_niche = CAGradientLayer()
        grad_niche.frame = _topBg_niche.bounds
        grad_niche.colors = [
            UIColor(hexstring_Niche: "#9B59B6").cgColor,
            UIColor(hexstring_Niche: "#B794F6").cgColor,
            UIColor(hexstring_Niche: "#90CDF4").cgColor
        ]
        grad_niche.locations = [0, 0.5, 1.0]
        grad_niche.startPoint = CGPoint(x: 0, y: 0)
        grad_niche.endPoint   = CGPoint(x: 1, y: 1)
        _topBg_niche.layer.insertSublayer(grad_niche, at: 0)
    }

    private func refreshSaveBtnGradient_Niche() {
        _saveButton_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        guard !_saveButton_niche.bounds.isEmpty else { return }
        let grad_niche = UIColor.createPrimaryGradientLayer_Niche(frame_Niche: _saveButton_niche.bounds)
        grad_niche.cornerRadius = 22
        _saveButton_niche.layer.insertSublayer(grad_niche, at: 0)
    }

    private func refreshAvatarRingGrad_Niche() {
        guard !_avatarRing_niche.bounds.isEmpty else { return }
        if _avatarRingGrad_niche == nil {
            let grad_niche = CAGradientLayer()
            grad_niche.cornerRadius = 54
            grad_niche.colors = [
                UIColor(hexstring_Niche: "#B794F6").cgColor,
                UIColor(hexstring_Niche: "#90CDF4").cgColor
            ]
            grad_niche.startPoint = CGPoint(x: 0, y: 0)
            grad_niche.endPoint   = CGPoint(x: 1, y: 1)
            _avatarRing_niche.layer.insertSublayer(grad_niche, at: 0)
            _avatarRingGrad_niche = grad_niche
        }
        _avatarRingGrad_niche?.frame = _avatarRing_niche.bounds
    }

    // MARK: - 行为绑定

    private func setupActions_Niche() {
        _saveButton_niche.addTarget(self, action: #selector(handleSave_Niche), for: .touchUpInside)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBioChange_Niche),
            name: UITextView.textDidChangeNotification,
            object: _bioTextView_niche
        )
    }

    // MARK: - 数据填充

    private func fillDefaultData_Niche() {
        guard UserViewModel_Niche.shared_Niche.isLoggedIn_Niche else { return }
        let user_niche = UserViewModel_Niche.shared_Niche.getCurrentUser_Niche()
        _usernameField_niche.text = user_niche.userName_Niche ?? ""

        // 简介优先取 loggedUser.userIntroduce_Niche，再 fallback 到 LocalData
        let bio_niche: String
        if let directBio_niche = user_niche.userIntroduce_Niche, !directBio_niche.isEmpty {
            bio_niche = directBio_niche
        } else if let userId_niche = user_niche.userId_Niche {
            bio_niche = UserViewModel_Niche.shared_Niche.getUserById_Niche(userId_niche: userId_niche).userIntroduce_Niche ?? ""
        } else {
            bio_niche = ""
        }

        if !bio_niche.isEmpty {
            _bioTextView_niche.text = bio_niche
            _bioPlaceholder_niche.isHidden = true
        }
    }

    // MARK: - 事件处理

    @objc private func handleAvatarTap_Niche() {
        MediaPickerHelper_Niche.pickImage_Niche(from: self) { [weak self] img_niche in
            guard let self = self, let img_niche = img_niche else { return }
            self._selectedAvatar_niche = img_niche
            self._avatarView_niche.imageView_Niche.image = img_niche
            self._avatarView_niche.imageView_Niche.contentMode = .scaleAspectFill
        }
    }

    @objc private func handleBioChange_Niche() {
        _bioPlaceholder_niche.isHidden = !(_bioTextView_niche.text?.isEmpty ?? true)
    }

    @objc private func handleSave_Niche() {
        guard UserViewModel_Niche.shared_Niche.isLoggedIn_Niche else {
            Utils_Niche.showWarning_Niche(message_Niche: "Please sign in first")
            Navigation_Niche.toLogin_Niche(style_niche: .present_niche)
            return
        }

        let currentUser_niche = UserViewModel_Niche.shared_Niche.getCurrentUser_Niche()
        let newName_niche = _usernameField_niche.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let newBio_niche  = _bioTextView_niche.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        _saveButton_niche.animatePressDown_Niche { self._saveButton_niche.animatePressUp_Niche() }

        Task { @MainActor in
            if let img_niche = self._selectedAvatar_niche {
                let path_niche = self.saveAvatarToDocuments_Niche(image: img_niche)
                UserViewModel_Niche.shared_Niche.updateHead_Niche(headUrl_niche: path_niche)
            }
            let originalName_niche = currentUser_niche.userName_Niche ?? ""
            if !newName_niche.isEmpty && newName_niche != originalName_niche {
                UserViewModel_Niche.shared_Niche.updateName_Niche(userName_niche: newName_niche)
            }
            if !newBio_niche.isEmpty {
                UserViewModel_Niche.shared_Niche.updateIntroduce_Niche(introduce_niche: newBio_niche)
            }
            Utils_Niche.showSuccess_Niche(message_Niche: "Profile updated!")
            Navigation_Niche.pop_Niche()
        }
    }

    private func saveAvatarToDocuments_Niche(image: UIImage) -> String {
        let fileName_niche = "avatar_\(Int(Date().timeIntervalSince1970)).jpg"
        let docDir_niche = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_niche = docDir_niche.appendingPathComponent(fileName_niche)
        if let data_niche = image.jpegData(compressionQuality: 0.85) {
            try? data_niche.write(to: fileURL_niche)
        }
        return fileURL_niche.path
    }
}
