import Foundation
import UIKit
import SnapKit

// MARK: 修改用户信息页面 - 重构版

/// 编辑用户信息页控制器
/// 核心作用：修改用户头像（从相册选取）、用户名、自我介绍，确认后更新 UserViewModel
/// 设计思路：渐变头部 + 渐变圆环头像区 + 分离式输入卡片 + 渐变保存按钮
/// 关键方法：confirmTapped_Retrs 校验并调用 updateHead_Retrs / updateName_Retrs
class EditInfo_Retrs: UIViewController {

    // MARK: - 属性

    private let userVM_Retrs = UserViewModel_Retrs.shared_Retrs

    private let scrollView_Retrs  = UIScrollView()
    private let contentView_Retrs = UIView()

    /// 渐变头部
    private let headerView_Retrs      = UIView()
    private let headerGradLayer_Retrs = CAGradientLayer()
    private let backBtn_Retrs         = UIButton(type: .system)
    private let titleNavLabel_Retrs   = UILabel()
    private let headerSubLabel_Retrs  = UILabel()

    /// 头像区域
    private let avatarRingView_Retrs    = EditGradRingView_Retrs()
    private let avatarView_Retrs        = CurrentUserAvatarView_Retrs()
    private let changeAvatarBtn_Retrs   = UIButton(type: .system)
    private var selectedAvatarImage_Retrs: UIImage?

    /// 表单卡片（用户名 / 简介分开）
    private let nameCard_Retrs          = UIView()
    private let nameField_Retrs         = UITextField()
    private let bioCard_Retrs           = UIView()
    private let introField_Retrs        = UITextField()

    /// 保存按钮
    private let confirmBtn_Retrs        = UIButton(type: .system)
    private let confirmGradLayer_Retrs  = CAGradientLayer()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fillDefaultData_Retrs()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Retrs.backgroundPrimary_Retrs
        setupScrollView_Retrs()
        setupHeaderView_Retrs()
        setupAvatarSection_Retrs()
        setupNameCard_Retrs()
        setupBioCard_Retrs()
        setupConfirmButton_Retrs()
        setupConstraints_Retrs()

        let tap_Retrs = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Retrs))
        tap_Retrs.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Retrs)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow_Retrs(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide_Retrs(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradLayer_Retrs.frame = headerView_Retrs.bounds
        confirmGradLayer_Retrs.frame = confirmBtn_Retrs.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 主滚动视图

    private func setupScrollView_Retrs() {
        scrollView_Retrs.showsVerticalScrollIndicator = false
        scrollView_Retrs.alwaysBounceVertical = true
        scrollView_Retrs.backgroundColor = .clear
        scrollView_Retrs.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_Retrs)
        scrollView_Retrs.addSubview(contentView_Retrs)
        contentView_Retrs.backgroundColor = .clear
    }

    // MARK: - 渐变头部

    private func setupHeaderView_Retrs() {
        headerGradLayer_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
        ]
        headerGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0)
        headerGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 1)
        headerView_Retrs.layer.insertSublayer(headerGradLayer_Retrs, at: 0)
        headerView_Retrs.layer.cornerRadius = 28
        headerView_Retrs.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Retrs.clipsToBounds = true
        contentView_Retrs.addSubview(headerView_Retrs)

        // 装饰气泡
        addBubble_Retrs(alpha: 0.12, size: 120, top: -30, trailing: 20)
        addBubble_Retrs(alpha: 0.07, size: 65,  bottom: 10, leading: -15)

        // 返回按钮
        backBtn_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        backBtn_Retrs.layer.cornerRadius = 18
        backBtn_Retrs.layer.borderWidth  = 1
        backBtn_Retrs.layer.borderColor  = UIColor.white.withAlphaComponent(0.35).cgColor
        let cfg_Retrs = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        backBtn_Retrs.setImage(UIImage(systemName: "arrow.left", withConfiguration: cfg_Retrs), for: .normal)
        backBtn_Retrs.tintColor = .white
        backBtn_Retrs.addTarget(self, action: #selector(backTapped_Retrs), for: .touchUpInside)
        headerView_Retrs.addSubview(backBtn_Retrs)

        // 标题
        titleNavLabel_Retrs.text = "Edit Profile"
        titleNavLabel_Retrs.font = UIFont.systemFont(ofSize: 26, weight: .black)
        titleNavLabel_Retrs.textColor = .white
        headerView_Retrs.addSubview(titleNavLabel_Retrs)

        // 副标题
        headerSubLabel_Retrs.text = "Update your name, bio & avatar"
        headerSubLabel_Retrs.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        headerSubLabel_Retrs.textColor = UIColor.white.withAlphaComponent(0.75)
        headerView_Retrs.addSubview(headerSubLabel_Retrs)

        let safeTop_Retrs = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 44

        backBtn_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Retrs + 14)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(36)
        }
        titleNavLabel_Retrs.snp.makeConstraints { make in
            make.centerY.equalTo(backBtn_Retrs)
            make.centerX.equalToSuperview()
        }
        headerSubLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(backBtn_Retrs.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    private func addBubble_Retrs(alpha: CGFloat, size: CGFloat,
                                  top: CGFloat? = nil, bottom: CGFloat? = nil,
                                  leading: CGFloat? = nil, trailing: CGFloat? = nil) {
        let v_Retrs = UIView()
        v_Retrs.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v_Retrs.layer.cornerRadius = size / 2
        headerView_Retrs.addSubview(v_Retrs)
        v_Retrs.snp.makeConstraints { make in
            make.width.height.equalTo(size)
            if let t = top     { make.top.equalToSuperview().offset(t) }
            if let b = bottom  { make.bottom.equalToSuperview().offset(b) }
            if let l = leading { make.leading.equalToSuperview().offset(l) }
            if let r = trailing { make.trailing.equalToSuperview().offset(r) }
        }
    }

    // MARK: - 头像区域

    private func setupAvatarSection_Retrs() {
        // 渐变圆环
        contentView_Retrs.addSubview(avatarRingView_Retrs)
        avatarRingView_Retrs.snp.makeConstraints { make in
            make.top.equalTo(headerView_Retrs.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }

        // 头像（内嵌）
        contentView_Retrs.addSubview(avatarView_Retrs)
        avatarView_Retrs.layer.cornerRadius = 44
        avatarView_Retrs.clipsToBounds = true
        avatarView_Retrs.snp.makeConstraints { make in
            make.center.equalTo(avatarRingView_Retrs)
            make.width.height.equalTo(90)
        }

        // 相机角标（渐变背景圆形）
        let camBg_Retrs = UIView()
        camBg_Retrs.backgroundColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        camBg_Retrs.layer.cornerRadius = 16
        camBg_Retrs.layer.borderWidth  = 2.5
        camBg_Retrs.layer.borderColor  = UIColor.white.cgColor
        camBg_Retrs.layer.shadowColor  = ColorConfig_Retrs.primaryGradientStart_Retrs
            .withAlphaComponent(0.4).cgColor
        camBg_Retrs.layer.shadowOffset = CGSize(width: 0, height: 3)
        camBg_Retrs.layer.shadowOpacity = 1
        camBg_Retrs.layer.shadowRadius  = 6
        contentView_Retrs.addSubview(camBg_Retrs)
        camBg_Retrs.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.trailing.equalTo(avatarRingView_Retrs).offset(4)
            make.bottom.equalTo(avatarRingView_Retrs).offset(4)
        }

        let camIcon_Retrs = UIImageView(
            image: UIImage(systemName: "camera.fill",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))
        )
        camIcon_Retrs.tintColor = .white
        camIcon_Retrs.contentMode = .scaleAspectFit
        camBg_Retrs.addSubview(camIcon_Retrs)
        camIcon_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }

        changeAvatarBtn_Retrs.backgroundColor = .clear
        changeAvatarBtn_Retrs.addTarget(self, action: #selector(changeAvatarTapped_Retrs), for: .touchUpInside)
        contentView_Retrs.addSubview(changeAvatarBtn_Retrs)
        changeAvatarBtn_Retrs.snp.makeConstraints { make in
            make.edges.equalTo(avatarRingView_Retrs)
        }

        // "Change Photo" 提示
        let changeHint_Retrs = UILabel()
        changeHint_Retrs.text = "Tap to change photo"
        changeHint_Retrs.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        changeHint_Retrs.textColor = ColorConfig_Retrs.primaryGradientStart_Retrs.withAlphaComponent(0.7)
        changeHint_Retrs.textAlignment = .center
        contentView_Retrs.addSubview(changeHint_Retrs)
        changeHint_Retrs.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView_Retrs.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        changeHint_Retrs.tag = 9901
    }

    // MARK: - 表单卡片

    /// 用户名输入卡片
    private func setupNameCard_Retrs() {
        styleInputCard_Retrs(nameCard_Retrs)
        contentView_Retrs.addSubview(nameCard_Retrs)

        let header_Retrs = makeFieldHeader_Retrs(title_Retrs: "Username",
                                                  icon_Retrs: "person.fill",
                                                  accent_Retrs: ColorConfig_Retrs.primaryGradientStart_Retrs)
        nameCard_Retrs.addSubview(header_Retrs)
        header_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(20)
        }

        let accentBar_Retrs = makeAccentBar_Retrs(color_Retrs: ColorConfig_Retrs.primaryGradientStart_Retrs)
        nameCard_Retrs.addSubview(accentBar_Retrs)
        accentBar_Retrs.snp.makeConstraints { make in
            make.top.equalTo(header_Retrs.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(18)
            make.width.equalTo(4)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-18)
        }

        let wrap_Retrs = makeInputWrap_Retrs()
        nameCard_Retrs.addSubview(wrap_Retrs)
        wrap_Retrs.snp.makeConstraints { make in
            make.top.equalTo(header_Retrs.snp.bottom).offset(10)
            make.leading.equalTo(accentBar_Retrs.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-18)
        }

        nameField_Retrs.placeholder = "Your display name"
        nameField_Retrs.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        nameField_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        nameField_Retrs.backgroundColor = .clear
        nameField_Retrs.autocorrectionType = .no
        nameField_Retrs.leftView = makeIconPad_Retrs(
            icon_Retrs: "person.fill",
            color_Retrs: ColorConfig_Retrs.primaryGradientStart_Retrs
        )
        nameField_Retrs.leftViewMode = .always
        wrap_Retrs.addSubview(nameField_Retrs)
        nameField_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 简介输入卡片
    private func setupBioCard_Retrs() {
        styleInputCard_Retrs(bioCard_Retrs)
        contentView_Retrs.addSubview(bioCard_Retrs)

        let header_Retrs = makeFieldHeader_Retrs(title_Retrs: "Bio",
                                                  icon_Retrs: "text.alignleft",
                                                  accent_Retrs: ColorConfig_Retrs.primaryGradientEnd_Retrs)
        bioCard_Retrs.addSubview(header_Retrs)
        header_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(20)
        }

        let accentBar_Retrs = makeAccentBar_Retrs(color_Retrs: ColorConfig_Retrs.primaryGradientEnd_Retrs)
        bioCard_Retrs.addSubview(accentBar_Retrs)
        accentBar_Retrs.snp.makeConstraints { make in
            make.top.equalTo(header_Retrs.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(18)
            make.width.equalTo(4)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-18)
        }

        let wrap_Retrs = makeInputWrap_Retrs()
        bioCard_Retrs.addSubview(wrap_Retrs)
        wrap_Retrs.snp.makeConstraints { make in
            make.top.equalTo(header_Retrs.snp.bottom).offset(10)
            make.leading.equalTo(accentBar_Retrs.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-18)
        }

        introField_Retrs.placeholder = "Tell the world about yourself..."
        introField_Retrs.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        introField_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        introField_Retrs.backgroundColor = .clear
        introField_Retrs.autocorrectionType = .no
        introField_Retrs.leftView = makeIconPad_Retrs(
            icon_Retrs: "quote.bubble.fill",
            color_Retrs: ColorConfig_Retrs.primaryGradientEnd_Retrs
        )
        introField_Retrs.leftViewMode = .always
        wrap_Retrs.addSubview(introField_Retrs)
        introField_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    // MARK: - 保存按钮

    private func setupConfirmButton_Retrs() {
        confirmGradLayer_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
        ]
        confirmGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0.5)
        confirmGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 0.5)
        confirmGradLayer_Retrs.cornerRadius = 28
        confirmBtn_Retrs.layer.insertSublayer(confirmGradLayer_Retrs, at: 0)
        confirmBtn_Retrs.layer.cornerRadius = 28
        confirmBtn_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            .withAlphaComponent(0.4).cgColor
        confirmBtn_Retrs.layer.shadowOffset = CGSize(width: 0, height: 6)
        confirmBtn_Retrs.layer.shadowOpacity = 1
        confirmBtn_Retrs.layer.shadowRadius  = 12
        confirmBtn_Retrs.setTitle("  Save Changes", for: .normal)
        confirmBtn_Retrs.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        confirmBtn_Retrs.setTitleColor(.white, for: .normal)
        confirmBtn_Retrs.addTarget(self, action: #selector(confirmTapped_Retrs), for: .touchUpInside)
        contentView_Retrs.addSubview(confirmBtn_Retrs)

        // 左侧 checkmark 图标
        let checkIV_Retrs = UIImageView(
            image: UIImage(systemName: "checkmark.circle.fill",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold))
        )
        checkIV_Retrs.tintColor = UIColor.white.withAlphaComponent(0.85)
        checkIV_Retrs.contentMode = .scaleAspectFit
        confirmBtn_Retrs.addSubview(checkIV_Retrs)
        checkIV_Retrs.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(28)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
    }

    // MARK: - 表单辅助构建方法

    private func styleInputCard_Retrs(_ card_Retrs: UIView) {
        card_Retrs.backgroundColor = .white
        card_Retrs.layer.cornerRadius = 20
        card_Retrs.clipsToBounds = false
        card_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            .withAlphaComponent(0.11).cgColor
        card_Retrs.layer.shadowOffset = CGSize(width: 0, height: 5)
        card_Retrs.layer.shadowOpacity = 1.0
        card_Retrs.layer.shadowRadius  = 14
    }

    private func makeFieldHeader_Retrs(title_Retrs: String, icon_Retrs: String,
                                        accent_Retrs: UIColor) -> UIView {
        let row_Retrs = UIView()
        let dot_Retrs = UIView()
        dot_Retrs.backgroundColor = accent_Retrs
        dot_Retrs.layer.cornerRadius = 3
        row_Retrs.addSubview(dot_Retrs)
        dot_Retrs.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(6)
        }
        let lbl_Retrs = UILabel()
        lbl_Retrs.text = title_Retrs
        lbl_Retrs.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        lbl_Retrs.textColor = accent_Retrs.withAlphaComponent(0.85)
        row_Retrs.addSubview(lbl_Retrs)
        lbl_Retrs.snp.makeConstraints { make in
            make.leading.equalTo(dot_Retrs.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        let iv_Retrs = UIImageView(
            image: UIImage(systemName: icon_Retrs,
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .medium))
        )
        iv_Retrs.tintColor = accent_Retrs.withAlphaComponent(0.5)
        iv_Retrs.contentMode = .scaleAspectFit
        row_Retrs.addSubview(iv_Retrs)
        iv_Retrs.snp.makeConstraints { make in
            make.leading.equalTo(lbl_Retrs.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(13)
            make.trailing.equalToSuperview()
        }
        return row_Retrs
    }

    private func makeAccentBar_Retrs(color_Retrs: UIColor) -> UIView {
        let bar_Retrs = EditGradFillView_Retrs(
            colors_Retrs: [color_Retrs, color_Retrs.withAlphaComponent(0.3)],
            start_Retrs: CGPoint(x: 0.5, y: 0),
            end_Retrs: CGPoint(x: 0.5, y: 1)
        )
        bar_Retrs.layer.cornerRadius = 2
        bar_Retrs.clipsToBounds = true
        return bar_Retrs
    }

    private func makeInputWrap_Retrs() -> UIView {
        let wrap_Retrs = UIView()
        wrap_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#EEF2FF")
        wrap_Retrs.layer.cornerRadius = 14
        return wrap_Retrs
    }

    private func makeIconPad_Retrs(icon_Retrs: String, color_Retrs: UIColor) -> UIView {
        let pad_Retrs = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 50))
        let iv_Retrs  = UIImageView(
            image: UIImage(systemName: icon_Retrs,
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .medium))
        )
        iv_Retrs.tintColor = color_Retrs
        iv_Retrs.contentMode = .scaleAspectFit
        iv_Retrs.frame = CGRect(x: 12, y: 13, width: 18, height: 24)
        pad_Retrs.addSubview(iv_Retrs)
        return pad_Retrs
    }

    // MARK: - 约束

    private func setupConstraints_Retrs() {
        let screenW_Retrs = UIScreen.main.bounds.width
        scrollView_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(screenW_Retrs)
        }
        headerView_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        // 头像区域完整显示在头部下方，避免被头部渐变遮挡
        avatarRingView_Retrs.snp.remakeConstraints { make in
            make.top.equalTo(headerView_Retrs.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        avatarView_Retrs.snp.remakeConstraints { make in
            make.center.equalTo(avatarRingView_Retrs)
            make.width.height.equalTo(90)
        }
        // changeHint 相对 ring 定位
        if let hint_Retrs = contentView_Retrs.viewWithTag(9901) {
            hint_Retrs.snp.remakeConstraints { make in
                make.top.equalTo(avatarRingView_Retrs.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
            }
        }
        nameCard_Retrs.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView_Retrs.snp.bottom).offset(46)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        bioCard_Retrs.snp.makeConstraints { make in
            make.top.equalTo(nameCard_Retrs.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        confirmBtn_Retrs.snp.makeConstraints { make in
            make.top.equalTo(bioCard_Retrs.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(58)
            make.bottom.equalToSuperview().offset(-36)
        }
    }

    // MARK: - 数据填充

    private func fillDefaultData_Retrs() {
        let user_Retrs = userVM_Retrs.getCurrentUser_Retrs()
        nameField_Retrs.text = user_Retrs.userName_Retrs ?? ""
        let previewUser_Retrs = userVM_Retrs.getUserById_Retrs(userId_retrs: user_Retrs.userId_Retrs ?? 0)
        introField_Retrs.text = previewUser_Retrs.userIntroduce_Retrs ?? ""
    }

    // MARK: - 事件

    @objc private func backTapped_Retrs() {
        Navigation_Retrs.pop_Retrs()
    }

    @objc private func dismissKeyboard_Retrs() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow_Retrs(_ notification: Notification) {
        guard let kbFrame_Retrs = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        scrollView_Retrs.contentInset.bottom = kbFrame_Retrs.height + 20
    }

    @objc private func keyboardWillHide_Retrs(_ notification: Notification) {
        scrollView_Retrs.contentInset.bottom = 0
    }

    /// 点击头像区域弹出相册
    @objc private func changeAvatarTapped_Retrs() {
        MediaPickerHelper_Retrs.pickImage_Retrs(from: self) { [weak self] image_Retrs in
            guard let self, let img_Retrs = image_Retrs else { return }
            self.selectedAvatarImage_Retrs = img_Retrs
            self.avatarView_Retrs.imageView_Retrs.image = img_Retrs
            self.avatarView_Retrs.imageView_Retrs.contentMode = .scaleAspectFill
        }
    }

    /// 确认保存修改：校验 → 更新 ViewModel → 返回
    @objc private func confirmTapped_Retrs() {
        guard userVM_Retrs.isLoggedIn_Retrs else {
            Navigation_Retrs.toLogin_Retrs(style_retrs: .present_retrs)
            return
        }
        confirmBtn_Retrs.animatePressDown_Retrs { [weak self] in
            self?.confirmBtn_Retrs.animatePressUp_Retrs()
        }
        let currentUser_Retrs  = userVM_Retrs.getCurrentUser_Retrs()
        let newName_Retrs      = nameField_Retrs.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let originalName_Retrs = currentUser_Retrs.userName_Retrs ?? ""

        if let img_Retrs = selectedAvatarImage_Retrs {
            let imagePath_Retrs = saveAvatarToDocuments_Retrs(image_Retrs: img_Retrs)
            userVM_Retrs.updateHead_Retrs(headUrl_retrs: imagePath_Retrs ?? "")
        }
        if !newName_Retrs.isEmpty && newName_Retrs != originalName_Retrs {
            userVM_Retrs.updateName_Retrs(userName_retrs: newName_Retrs)
        } else {
            Utils_Retrs.showSuccess_Retrs(message_Retrs: "Profile saved")
        }
        Navigation_Retrs.pop_Retrs()
    }

    /// 保存头像到沙盒文档目录，返回文件路径
    private func saveAvatarToDocuments_Retrs(image_Retrs: UIImage) -> String? {
        let fileName_Retrs = "avatar_\(Int(Date().timeIntervalSince1970)).jpg"
        let docURL_Retrs   = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Retrs  = docURL_Retrs.appendingPathComponent(fileName_Retrs)
        guard let data_Retrs = image_Retrs.jpegData(compressionQuality: 0.8) else { return nil }
        try? data_Retrs.write(to: fileURL_Retrs)
        return fileURL_Retrs.path
    }
}

// MARK: - 渐变圆环辅助视图

/// 头像渐变圆环（薰衣草紫→天空蓝，环宽 5pt）
class EditGradRingView_Retrs: UIView {

    private let gradLayer_Retrs = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        gradLayer_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
        ]
        gradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0)
        gradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 1)
        layer.addSublayer(gradLayer_Retrs)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Retrs.frame = bounds
        let ringW_Retrs: CGFloat = 4
        let outer_Retrs = UIBezierPath(ovalIn: bounds)
        let inner_Retrs = UIBezierPath(ovalIn: bounds.insetBy(dx: ringW_Retrs, dy: ringW_Retrs))
        outer_Retrs.append(inner_Retrs)
        outer_Retrs.usesEvenOddFillRule = true
        let mask_Retrs = CAShapeLayer()
        mask_Retrs.path     = outer_Retrs.cgPath
        mask_Retrs.fillRule = .evenOdd
        gradLayer_Retrs.mask = mask_Retrs
    }
}

// MARK: - 渐变填充辅助视图

/// 自动追踪父视图 bounds 的渐变 UIView
class EditGradFillView_Retrs: UIView {

    private let gradLayer_Retrs = CAGradientLayer()

    init(colors_Retrs: [UIColor], start_Retrs: CGPoint, end_Retrs: CGPoint) {
        super.init(frame: .zero)
        gradLayer_Retrs.colors     = colors_Retrs.map { $0.cgColor }
        gradLayer_Retrs.startPoint = start_Retrs
        gradLayer_Retrs.endPoint   = end_Retrs
        layer.addSublayer(gradLayer_Retrs)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Retrs.frame = bounds
    }
}
