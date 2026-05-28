import Foundation
import UIKit
import SnapKit

// MARK: 修改用户信息页面

/// 编辑用户信息页面
/// 功能：修改用户头像（从相册选取）、用户名、个人简介，确认修改时判断数据是否有变化
/// 设计：深紫渐变 Header + 居中大头像（悬浮叠加于 Header 底部）+ 表单输入卡片 + 渐变保存按钮
class EditInfo_Ornit: UIViewController {

    // MARK: - 私有数据属性

    /// 是否修改了头像
    private var isAvatarChanged_Ornit: Bool = false

    /// 选中的新头像图片
    private var newAvatarImage_Ornit: UIImage?

    /// 原始用户名（用于判断是否修改）
    private var originalName_Ornit: String = ""

    /// 原始简介（用于判断是否修改）
    private var originalIntroduce_Ornit: String = ""

    // MARK: - Header 组件

    /// 顶部渐变 Header
    private let headerView_Ornit = UIView()

    /// Header 渐变图层（viewDidLayoutSubviews 中同步 frame）
    private var headerGradient_Ornit: CAGradientLayer?

    /// 页面主标题
    private let titleLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.text = "Edit Profile"
        label_ornit.font = UIFont.systemFont(ofSize: 22, weight: .black)
        label_ornit.textColor = .white
        return label_ornit
    }()

    /// 副标题
    private let subtitleLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.text = "Update your birdwatcher profile"
        label_ornit.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label_ornit.textColor = UIColor.white.withValues(alpha: 0.72)
        return label_ornit
    }()

    // MARK: - 头像组件

    /// 头像容器（可点击，叠于 Header 底部）
    private let avatarContainer_Ornit = UIView()

    /// 头像视图（带白色边框环）
    private let avatarView_Ornit: UserAvatarView_Ornit = {
        let av_ornit = UserAvatarView_Ornit()
        av_ornit.layer.borderWidth = 4
        av_ornit.layer.borderColor = UIColor.white.cgColor
        av_ornit.isUserInteractionEnabled = true
        return av_ornit
    }()

    /// 相机图标覆盖层（半透明黑底）
    private let cameraOverlay_Ornit: UIView = {
        let v_ornit = UIView()
        v_ornit.backgroundColor = UIColor.black.withValues(alpha: 0.38)
        v_ornit.isUserInteractionEnabled = false
        return v_ornit
    }()

    /// 相机图标
    private let cameraIcon_Ornit: UIImageView = {
        let config_ornit = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        let iv_ornit = UIImageView(
            image: UIImage(systemName: "camera.fill", withConfiguration: config_ornit)
        )
        iv_ornit.tintColor = .white
        iv_ornit.contentMode = .scaleAspectFit
        return iv_ornit
    }()

    // MARK: - 表单组件

    /// 白色表单卡片（带紫色调阴影）
    private let formCard_Ornit = UIView()

    /// 用户名输入框
    private let nameField_Ornit: UITextField = {
        let tf_ornit = UITextField()
        tf_ornit.placeholder = "Username"
        tf_ornit.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        tf_ornit.autocapitalizationType = .none
        tf_ornit.autocorrectionType = .no
        tf_ornit.returnKeyType = .next
        tf_ornit.backgroundColor = .clear
        return tf_ornit
    }()

    /// 简介输入 TextView（支持多行，最多 100 字）
    private let bioTextView_Ornit: UITextView = {
        let tv_ornit = UITextView()
        tv_ornit.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tv_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        tv_ornit.backgroundColor = .clear
        tv_ornit.isScrollEnabled = false
        tv_ornit.textContainerInset = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        return tv_ornit
    }()

    /// 简介占位符标签（UITextView 无内置 placeholder，手动模拟）
    private let bioPlaceholder_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.text = "Tell others about your birdwatching journey..."
        label_ornit.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label_ornit.textColor = ColorConfig_Ornit.textPlaceholder_Ornit
        label_ornit.numberOfLines = 0
        label_ornit.isUserInteractionEnabled = false
        return label_ornit
    }()

    /// 简介字符计数标签（超过 100 字时变红提示）
    private let bioCharCount_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.text = "0 / 100"
        label_ornit.font = UIFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        label_ornit.textColor = ColorConfig_Ornit.textPlaceholder_Ornit
        label_ornit.textAlignment = .right
        return label_ornit
    }()

    // MARK: - 保存按钮

    /// 保存按钮外层阴影容器
    private let saveButtonWrapper_Ornit = UIView()

    /// 渐变保存按钮
    private let saveButton_Ornit: UIButton = {
        let btn_ornit = UIButton(type: .custom)
        btn_ornit.setTitle("  Save Changes", for: .normal)
        btn_ornit.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn_ornit.setTitleColor(.white, for: .normal)
        let config_ornit = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn_ornit.setImage(
            UIImage(systemName: "checkmark.circle.fill", withConfiguration: config_ornit),
            for: .normal
        )
        btn_ornit.tintColor = .white
        btn_ornit.layer.cornerRadius = 16
        btn_ornit.layer.masksToBounds = true
        return btn_ornit
    }()

    /// 保存按钮渐变图层
    private var saveGradient_Ornit: CAGradientLayer?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Ornit.backgroundMe_Ornit
        setupHeaderView_Ornit()
        setupAvatarSection_Ornit()
        setupFormCard_Ornit()
        setupSaveButton_Ornit()
        loadCurrentUserData_Ornit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Ornit?.frame = headerView_Ornit.bounds
        saveGradient_Ornit?.frame = saveButton_Ornit.bounds
        avatarView_Ornit.layer.cornerRadius = avatarView_Ornit.bounds.width / 2
        cameraOverlay_Ornit.layer.cornerRadius = cameraOverlay_Ornit.bounds.width / 2
    }

    // MARK: - 数据加载

    /// 加载当前登录用户数据，填充表单初始值
    private func loadCurrentUserData_Ornit() {
        let user_ornit = UserViewModel_Ornit.shared_Ornit.getCurrentUser_Ornit()

        if let uid_ornit = user_ornit.userId_Ornit {
            avatarView_Ornit.configure_Ornit(userId_Ornit: uid_ornit)
        }

        originalName_Ornit = user_ornit.userName_Ornit ?? ""
        originalIntroduce_Ornit = user_ornit.userIntroduce_Ornit ?? ""

        nameField_Ornit.text = originalName_Ornit
        bioTextView_Ornit.text = originalIntroduce_Ornit
        bioPlaceholder_Ornit.isHidden = !originalIntroduce_Ornit.isEmpty
        bioCharCount_Ornit.text = "\(originalIntroduce_Ornit.count) / 100"
    }

    // MARK: - UI 搭建

    /// 构建顶部渐变 Header（深紫渐变 + 返回按钮 + 标题 + 副标题 + 装饰圆）
    private func setupHeaderView_Ornit() {
        view.addSubview(headerView_Ornit)

        let gradient_ornit = CAGradientLayer()
        gradient_ornit.colors = [
            ColorConfig_Ornit.meGradientStart_Ornit.cgColor,
            ColorConfig_Ornit.meGradientEnd_Ornit.cgColor
        ]
        gradient_ornit.startPoint = CGPoint(x: 0, y: 0)
        gradient_ornit.endPoint = CGPoint(x: 1, y: 1)
        headerView_Ornit.layer.insertSublayer(gradient_ornit, at: 0)
        headerGradient_Ornit = gradient_ornit

        headerView_Ornit.layer.cornerRadius = 24
        headerView_Ornit.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Ornit.clipsToBounds = true

        // 装饰圆
        let deco1_ornit = UIView()
        deco1_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.07)
        deco1_ornit.layer.cornerRadius = 60
        headerView_Ornit.addSubview(deco1_ornit)

        let deco2_ornit = UIView()
        deco2_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.04)
        deco2_ornit.layer.cornerRadius = 40
        headerView_Ornit.addSubview(deco2_ornit)

        // 返回按钮
        let backView_ornit = BackButton_Ornit()
        backView_ornit.onTapped_Ornit = { [weak self] in
            Navigation_Ornit.pop_Ornit(from: self)
        }
        headerView_Ornit.addSubview(backView_ornit)
        headerView_Ornit.addSubview(titleLabel_Ornit)
        headerView_Ornit.addSubview(subtitleLabel_Ornit)

        headerView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.leading.trailing.equalToSuperview()
            // 增大 Header 高度，给标题、副标题和头像悬浮区留出充足空间
            make_ornit.height.equalTo(176)
        }

        deco1_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(38)
            make_ornit.top.equalToSuperview().offset(-22)
            make_ornit.width.height.equalTo(120)
        }

        deco2_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(-18)
            make_ornit.bottom.equalToSuperview().offset(20)
            make_ornit.width.height.equalTo(80)
        }

        backView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(20)
            make_ornit.top.equalToSuperview().offset(56)
            make_ornit.width.height.equalTo(38)
        }

        titleLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.centerX.equalToSuperview()
            make_ornit.centerY.equalTo(backView_ornit)
        }

        subtitleLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.centerX.equalToSuperview()
            make_ornit.top.equalTo(titleLabel_Ornit.snp.bottom).offset(6)
        }
    }

    /// 构建头像选择区（居中悬浮于 Header 底部，带相机覆盖层）
    private func setupAvatarSection_Ornit() {
        view.addSubview(avatarContainer_Ornit)
        avatarContainer_Ornit.addSubview(avatarView_Ornit)
        avatarContainer_Ornit.addSubview(cameraOverlay_Ornit)
        cameraOverlay_Ornit.addSubview(cameraIcon_Ornit)
        avatarContainer_Ornit.isUserInteractionEnabled = true

        // 头像外围阴影环（独立于 avatarContainer 之下，避免被 clipsToBounds 裁切）
        let shadowRing_ornit = UIView()
        shadowRing_ornit.backgroundColor = .clear
        shadowRing_ornit.layer.shadowColor = ColorConfig_Ornit.meAccent_Ornit.withValues(alpha: 0.35).cgColor
        shadowRing_ornit.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadowRing_ornit.layer.shadowOpacity = 1
        shadowRing_ornit.layer.shadowRadius = 12
        shadowRing_ornit.layer.cornerRadius = 52
        view.insertSubview(shadowRing_ornit, belowSubview: avatarContainer_Ornit)

        avatarContainer_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.centerX.equalToSuperview()
            // 头像一半在 Header 内、一半在 Header 外，给内容区足够呼吸空间
            make_ornit.top.equalTo(headerView_Ornit.snp.bottom).offset(-50)
            make_ornit.width.height.equalTo(100)
        }

        shadowRing_ornit.snp.makeConstraints { make_ornit in
            make_ornit.center.equalTo(avatarContainer_Ornit)
            make_ornit.width.height.equalTo(100)
        }

        avatarView_Ornit.snp.makeConstraints { make_ornit in make_ornit.edges.equalToSuperview() }
        cameraOverlay_Ornit.snp.makeConstraints { make_ornit in make_ornit.edges.equalToSuperview() }

        cameraIcon_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.center.equalToSuperview()
            make_ornit.width.height.equalTo(22)
        }

        let tap_ornit = UITapGestureRecognizer(target: self, action: #selector(avatarTapped_Ornit))
        avatarContainer_Ornit.addGestureRecognizer(tap_ornit)
    }

    /// 构建表单输入卡片（用户名区段 + 分割线 + 简介区段）
    private func setupFormCard_Ornit() {
        formCard_Ornit.backgroundColor = .white
        formCard_Ornit.layer.cornerRadius = 20
        formCard_Ornit.layer.shadowColor = ColorConfig_Ornit.meAccent_Ornit.withValues(alpha: 0.12).cgColor
        formCard_Ornit.layer.shadowOffset = CGSize(width: 0, height: 4)
        formCard_Ornit.layer.shadowOpacity = 1
        formCard_Ornit.layer.shadowRadius = 14
        view.addSubview(formCard_Ornit)

        // 用户名输入区
        let nameSection_ornit = makeFieldSection_Ornit(
            textField_ornit: nameField_Ornit,
            icon_ornit: "person.fill",
            sectionLabel_ornit: "Username"
        )
        formCard_Ornit.addSubview(nameSection_ornit)

        // 分割线
        let divider_ornit = UIView()
        divider_ornit.backgroundColor = ColorConfig_Ornit.divider_Ornit
        formCard_Ornit.addSubview(divider_ornit)

        // 简介输入区（专属 TextView 多行方案）
        let bioSection_ornit = makeBioSection_Ornit()
        formCard_Ornit.addSubview(bioSection_ornit)

        formCard_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(avatarContainer_Ornit.snp.bottom).offset(24)
            make_ornit.leading.equalToSuperview().offset(20)
            make_ornit.trailing.equalToSuperview().offset(-20)
        }

        nameSection_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(68)
        }

        divider_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(nameSection_ornit.snp.bottom)
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.height.equalTo(0.5)
        }

        bioSection_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(divider_ornit.snp.bottom)
            make_ornit.leading.trailing.equalToSuperview()
            make_ornit.bottom.equalToSuperview()
        }

        nameField_Ornit.delegate = self
        bioTextView_Ornit.delegate = self
    }

    /// 创建带区段标题和图标的输入区
    /// - Parameters:
    ///   - textField_ornit: 输入框
    ///   - icon_ornit: SF Symbol 图标名
    ///   - sectionLabel_ornit: 区段标题文字
    /// - Returns: 完整输入区容器 UIView
    private func makeFieldSection_Ornit(
        textField_ornit: UITextField,
        icon_ornit: String,
        sectionLabel_ornit: String
    ) -> UIView {
        let container_ornit = UIView()

        // 图标圆形背景
        let iconBg_ornit = UIView()
        iconBg_ornit.backgroundColor = ColorConfig_Ornit.meAccent_Ornit.withValues(alpha: 0.1)
        iconBg_ornit.layer.cornerRadius = 11
        container_ornit.addSubview(iconBg_ornit)

        let iconConfig_ornit = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        let iconView_ornit = UIImageView(
            image: UIImage(systemName: icon_ornit, withConfiguration: iconConfig_ornit)
        )
        iconView_ornit.tintColor = ColorConfig_Ornit.meAccent_Ornit
        iconView_ornit.contentMode = .scaleAspectFit
        iconBg_ornit.addSubview(iconView_ornit)

        // 区段标题（小字，灰色）
        let sectionLbl_ornit = UILabel()
        sectionLbl_ornit.text = sectionLabel_ornit
        sectionLbl_ornit.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        sectionLbl_ornit.textColor = ColorConfig_Ornit.meAccent_Ornit.withValues(alpha: 0.7)
        container_ornit.addSubview(sectionLbl_ornit)

        container_ornit.addSubview(textField_ornit)

        iconBg_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.centerY.equalToSuperview()
            make_ornit.width.height.equalTo(34)
        }

        iconView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.center.equalToSuperview()
            make_ornit.width.height.equalTo(15)
        }

        sectionLbl_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(iconBg_ornit.snp.trailing).offset(12)
            make_ornit.top.equalToSuperview().offset(12)
        }

        textField_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(iconBg_ornit.snp.trailing).offset(12)
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.bottom.equalToSuperview().offset(-12)
        }

        return container_ornit
    }

    /// 构建简介多行输入区（UITextView + 模拟占位符 + 字符计数）
    /// - Returns: 配置完成的容器 UIView
    private func makeBioSection_Ornit() -> UIView {
        let container_ornit = UIView()

        // 图标圆形背景
        let iconBg_ornit = UIView()
        iconBg_ornit.backgroundColor = ColorConfig_Ornit.meAccent_Ornit.withValues(alpha: 0.1)
        iconBg_ornit.layer.cornerRadius = 11
        container_ornit.addSubview(iconBg_ornit)

        let iconConfig_ornit = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        let iconView_ornit = UIImageView(
            image: UIImage(systemName: "text.alignleft", withConfiguration: iconConfig_ornit)
        )
        iconView_ornit.tintColor = ColorConfig_Ornit.meAccent_Ornit
        iconView_ornit.contentMode = .scaleAspectFit
        iconBg_ornit.addSubview(iconView_ornit)

        // 区段标题
        let sectionLbl_ornit = UILabel()
        sectionLbl_ornit.text = "Bio"
        sectionLbl_ornit.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        sectionLbl_ornit.textColor = ColorConfig_Ornit.meAccent_Ornit.withValues(alpha: 0.7)
        container_ornit.addSubview(sectionLbl_ornit)

        // 多行输入框（含模拟占位符）
        container_ornit.addSubview(bioTextView_Ornit)
        bioTextView_Ornit.addSubview(bioPlaceholder_Ornit)

        // 字符计数（右下角）
        container_ornit.addSubview(bioCharCount_Ornit)

        iconBg_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.top.equalToSuperview().offset(12)
            make_ornit.width.height.equalTo(34)
        }

        iconView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.center.equalToSuperview()
            make_ornit.width.height.equalTo(15)
        }

        sectionLbl_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(iconBg_ornit.snp.trailing).offset(12)
            make_ornit.top.equalToSuperview().offset(12)
        }

        bioTextView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(iconBg_ornit.snp.trailing).offset(8)
            make_ornit.trailing.equalToSuperview().offset(-12)
            make_ornit.top.equalTo(sectionLbl_ornit.snp.bottom).offset(4)
            make_ornit.bottom.equalToSuperview().offset(-28)
            make_ornit.height.greaterThanOrEqualTo(64)
        }

        bioPlaceholder_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalToSuperview().offset(2)
            make_ornit.leading.equalToSuperview().offset(5)
            make_ornit.trailing.equalToSuperview().offset(-4)
        }

        bioCharCount_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-12)
            make_ornit.bottom.equalToSuperview().offset(-6)
        }

        return container_ornit
    }

    /// 构建保存按钮（使用 wrapper 承载阴影，按钮本身裁切渐变）
    private func setupSaveButton_Ornit() {
        saveButtonWrapper_Ornit.layer.cornerRadius = 16
        saveButtonWrapper_Ornit.layer.shadowColor = ColorConfig_Ornit.meGradientEnd_Ornit.withValues(alpha: 0.4).cgColor
        saveButtonWrapper_Ornit.layer.shadowOffset = CGSize(width: 0, height: 6)
        saveButtonWrapper_Ornit.layer.shadowOpacity = 1
        saveButtonWrapper_Ornit.layer.shadowRadius = 14
        view.addSubview(saveButtonWrapper_Ornit)
        saveButtonWrapper_Ornit.addSubview(saveButton_Ornit)

        // 深紫 → 鲜亮紫渐变（横向）
        let btnGrad_ornit = CAGradientLayer()
        btnGrad_ornit.colors = [
            ColorConfig_Ornit.meGradientStart_Ornit.cgColor,
            ColorConfig_Ornit.meGradientEnd_Ornit.cgColor
        ]
        btnGrad_ornit.startPoint = CGPoint(x: 0, y: 0.5)
        btnGrad_ornit.endPoint = CGPoint(x: 1, y: 0.5)
        saveButton_Ornit.layer.insertSublayer(btnGrad_ornit, at: 0)
        saveGradient_Ornit = btnGrad_ornit

        saveButtonWrapper_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(formCard_Ornit.snp.bottom).offset(28)
            make_ornit.leading.equalToSuperview().offset(20)
            make_ornit.trailing.equalToSuperview().offset(-20)
            make_ornit.height.equalTo(54)
        }

        saveButton_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview()
        }

        saveButton_Ornit.addTarget(self, action: #selector(saveTapped_Ornit), for: .touchUpInside)
    }

    // MARK: - 事件处理

    /// 头像点击，弹出图片选择器
    @objc private func avatarTapped_Ornit() {
        UIView.animate(withDuration: 0.1, animations: {
            self.avatarContainer_Ornit.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
        }) { _ in
            UIView.animate(withDuration: 0.12) {
                self.avatarContainer_Ornit.transform = .identity
            }
        }

        MediaPickerHelper_Ornit.pickImage_Ornit(from: self) { [weak self] image_ornit in
            guard let self = self, let image_ornit = image_ornit else { return }
            self.isAvatarChanged_Ornit = true
            self.newAvatarImage_Ornit = image_ornit
            self.avatarView_Ornit.imageView_Ornit.image = image_ornit
        }
    }

    /// 保存按钮点击，校验变更并提交
    @objc private func saveTapped_Ornit() {
        guard UserViewModel_Ornit.shared_Ornit.isLoggedIn_Ornit else {
            Navigation_Ornit.toLogin_Ornit()
            return
        }

        let newName_ornit = nameField_Ornit.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let newBio_ornit = bioTextView_Ornit.text?.trimmingCharacters(in: .whitespaces) ?? ""

        var hasChanges_ornit = false

        if isAvatarChanged_Ornit, let image_ornit = newAvatarImage_Ornit {
            if let path_ornit = saveAvatarToDocument_Ornit(image_ornit: image_ornit) {
                UserViewModel_Ornit.shared_Ornit.updateHead_Ornit(headUrl_ornit: path_ornit)
                hasChanges_ornit = true
            }
        }

        if !newName_ornit.isEmpty && newName_ornit != originalName_Ornit {
            UserViewModel_Ornit.shared_Ornit.updateName_Ornit(userName_ornit: newName_ornit)
            hasChanges_ornit = true
        }

        if newBio_ornit != originalIntroduce_Ornit {
            UserViewModel_Ornit.shared_Ornit.updateIntroduce_Ornit(introduce_ornit: newBio_ornit)
            hasChanges_ornit = true
        }

        guard hasChanges_ornit else {
            Utils_Ornit.showInfo_Ornit(message_Ornit: "No changes to save")
            return
        }

        UIView.animate(withDuration: 0.1, animations: {
            self.saveButton_Ornit.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.12) {
                self.saveButton_Ornit.transform = .identity
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            Navigation_Ornit.pop_Ornit()
        }
    }

    /// 将头像图片保存至文档目录
    /// - Parameter image_ornit: 头像图片
    /// - Returns: 保存成功后的文件路径，失败时为 nil
    private func saveAvatarToDocument_Ornit(image_ornit: UIImage) -> String? {
        guard let data_ornit = image_ornit.jpegData(compressionQuality: 0.8) else { return nil }
        let filename_ornit = "avatar_\(Int(Date().timeIntervalSince1970)).jpg"
        let docDir_ornit = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_ornit = docDir_ornit.appendingPathComponent(filename_ornit)
        do {
            try data_ornit.write(to: fileURL_ornit)
            return fileURL_ornit.path
        } catch {
            print("保存头像失败: \(error)")
            return nil
        }
    }
}

// MARK: - UITextFieldDelegate

extension EditInfo_Ornit: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField_Ornit {
            // 用户名输入完成后跳转到简介多行输入框
            bioTextView_Ornit.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - UITextViewDelegate

extension EditInfo_Ornit: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        let count_ornit = textView.text.count
        bioPlaceholder_Ornit.isHidden = count_ornit > 0
        // 超过 100 字时计数变红警示
        bioCharCount_Ornit.textColor = count_ornit > 100
            ? UIColor(hexstring_Ornit: "#EF4444")
            : ColorConfig_Ornit.textPlaceholder_Ornit
        bioCharCount_Ornit.text = "\(count_ornit) / 100"
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        bioPlaceholder_Ornit.isHidden = true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        bioPlaceholder_Ornit.isHidden = textView.text.isEmpty
    }
}
