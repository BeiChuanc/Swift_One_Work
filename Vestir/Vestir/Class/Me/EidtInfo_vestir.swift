import Foundation
import UIKit
import SnapKit

// MARK: 修改用户信息页面

/// 修改用户信息页面
/// 功能：修改头像（相册）、用户名、简介；确认修改
/// 设计亮点：
///   • 深玫瑰→靛蓝渐变背景（完全不同于其他三页的调色板）
///   • 头像区域位于渐变背景上，带大号相机图标引导 + 闪光角标
///   • 输入卡片使用"浮动标签"风格（标签在输入框上方，醒目易读）
///   • 左侧玫瑰色装饰条（不同于其他页面紫色/橙色）
///   • 保存按钮：深玫瑰→靛蓝渐变 + 玫瑰色发光阴影
class EditInfo_Vestir: UIViewController {

    // MARK: - 私有属性

    private var selectedImage_Vestir: UIImage?

    // MARK: - 沉浸式渐变背景（全页面，深玫瑰→靛蓝）

    private let bgCard_Vestir = EditInfoBgCard_Vestir()

    private let decoCircle1_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.09)
        v_Vestir.layer.cornerRadius = 50
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    private let decoCircle2_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#FDA4AF", alpha_Vestir: 0.18)
        v_Vestir.layer.cornerRadius = 36
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    // MARK: - 导航（白色文字，浮于渐变上）

    private lazy var backBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn_Vestir.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg_Vestir), for: .normal)
        btn_Vestir.tintColor = .white
        btn_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.20)
        btn_Vestir.layer.cornerRadius = 16
        btn_Vestir.clipsToBounds = true
        btn_Vestir.addTarget(self, action: #selector(backTapped_Vestir), for: .touchUpInside)
        return btn_Vestir
    }()

    private let navTitleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Edit Profile"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        lbl_Vestir.textColor = .white
        return lbl_Vestir
    }()

    // MARK: - 头像区域（大号，引导感强）

    /// 头像容器（100pt）
    private let avatarContainer_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.isUserInteractionEnabled = true
        return v_Vestir
    }()

    private let avatarView_Vestir: CurrentUserAvatarView_Vestir = {
        let av_Vestir = CurrentUserAvatarView_Vestir()
        av_Vestir.layer.cornerRadius = 50
        av_Vestir.clipsToBounds = true
        av_Vestir.layer.borderWidth = 3
        av_Vestir.layer.borderColor = UIColor.white.cgColor
        return av_Vestir
    }()

    private let avatarEditOverlay_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        v_Vestir.layer.cornerRadius = 50
        v_Vestir.clipsToBounds = true
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    private let cameraIconView_Vestir: UIImageView = {
        let iv_Vestir = UIImageView()
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        iv_Vestir.image = UIImage(systemName: "camera.fill", withConfiguration: cfg_Vestir)
        iv_Vestir.tintColor = .white
        iv_Vestir.contentMode = .scaleAspectFit
        iv_Vestir.isUserInteractionEnabled = false
        return iv_Vestir
    }()

    private let previewImageView_Vestir: UIImageView = {
        let iv_Vestir = UIImageView()
        iv_Vestir.contentMode = .scaleAspectFill
        iv_Vestir.layer.cornerRadius = 50
        iv_Vestir.clipsToBounds = true
        iv_Vestir.isHidden = true
        return iv_Vestir
    }()

    /// 闪光角标（右下角，白色圆形背景）
    private let sparkBadge_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "✦"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lbl_Vestir.textColor = UIColor(hexstring_Vestir: "#BE185D")
        lbl_Vestir.backgroundColor = .white
        lbl_Vestir.layer.cornerRadius = 14
        lbl_Vestir.clipsToBounds = true
        lbl_Vestir.textAlignment = .center
        lbl_Vestir.isUserInteractionEnabled = false
        return lbl_Vestir
    }()

    private let changePhotoHintLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Tap to change photo"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.72)
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    // MARK: - 滚动容器

    private let scrollView_Vestir: UIScrollView = {
        let sv_Vestir = UIScrollView()
        sv_Vestir.showsVerticalScrollIndicator = false
        sv_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        sv_Vestir.alwaysBounceVertical = true
        // 禁用自动 contentInset 补偿，防止顶部出现白色间隙
        sv_Vestir.contentInsetAdjustmentBehavior = .never
        return sv_Vestir
    }()

    private let contentView_Vestir = UIView()

    // MARK: - 表单卡片

    private let formCardShadow_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = .clear
        v_Vestir.layer.shadowColor = UIColor(hexstring_Vestir: "#BE185D").cgColor
        v_Vestir.layer.shadowOpacity = 0.15
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 6)
        v_Vestir.layer.shadowRadius = 16
        return v_Vestir
    }()

    private let formCard_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.backgroundSecondary_Vestir
        v_Vestir.layer.cornerRadius = 24
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    // MARK: - 姓名字段（玫瑰色左装饰条）

    private let nameRow_Vestir: UIView = UIView()

    private let nameAccentBar_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#BE185D")
        v_Vestir.layer.cornerRadius = 2
        return v_Vestir
    }()

    private let nameSectionLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Display Name"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lbl_Vestir.textColor = UIColor(hexstring_Vestir: "#BE185D")
        return lbl_Vestir
    }()

    private let nameField_Vestir: UITextField = {
        let tf_Vestir = UITextField()
        tf_Vestir.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tf_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        tf_Vestir.borderStyle = .none
        tf_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        tf_Vestir.layer.cornerRadius = 12
        tf_Vestir.setLeftPadding_Vestir(
            icon: "person.fill",
            tintColor: UIColor(hexstring_Vestir: "#BE185D")
        )
        tf_Vestir.autocorrectionType = .no
        return tf_Vestir
    }()

    /// 渐变分隔线
    private let formDivider_Vestir: UIView = UIView()

    // MARK: - Bio 字段（靛蓝左装饰条）

    private let bioAccentBar_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#4338CA")
        v_Vestir.layer.cornerRadius = 2
        return v_Vestir
    }()

    private let bioSectionLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Bio"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lbl_Vestir.textColor = UIColor(hexstring_Vestir: "#4338CA")
        return lbl_Vestir
    }()

    private let bioField_Vestir: UITextView = {
        let tv_Vestir = UITextView()
        tv_Vestir.font = UIFont.systemFont(ofSize: 15)
        tv_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        tv_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        tv_Vestir.layer.cornerRadius = 12
        tv_Vestir.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        tv_Vestir.isScrollEnabled = false
        return tv_Vestir
    }()

    // MARK: - 保存按钮（深玫瑰→靛蓝 + 玫瑰发光）

    private let saveBtnShadow_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = .clear
        v_Vestir.layer.shadowColor = UIColor(hexstring_Vestir: "#BE185D").cgColor
        v_Vestir.layer.shadowOpacity = 0.50
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 8)
        v_Vestir.layer.shadowRadius = 20
        return v_Vestir
    }()

    private let saveBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        btn_Vestir.setTitle("Save Changes", for: .normal)
        btn_Vestir.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn_Vestir.setTitleColor(.white, for: .normal)
        btn_Vestir.layer.cornerRadius = 28
        btn_Vestir.clipsToBounds = true
        return btn_Vestir
    }()

    private let saveGradLayer_Vestir: CAGradientLayer = {
        let g_Vestir = CAGradientLayer()
        g_Vestir.colors = [
            UIColor(hexstring_Vestir: "#BE185D").cgColor,
            UIColor(hexstring_Vestir: "#9333EA").cgColor,
            UIColor(hexstring_Vestir: "#4338CA").cgColor
        ]
        g_Vestir.locations = [0, 0.52, 1.0]
        g_Vestir.startPoint = CGPoint(x: 0, y: 0.5)
        g_Vestir.endPoint = CGPoint(x: 1, y: 0.5)
        g_Vestir.cornerRadius = 28
        return g_Vestir
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Vestir()
        setupConstraints_Vestir()
        setupActions_Vestir()
        loadCurrentUserData_Vestir()
        animateIn_Vestir()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        saveGradLayer_Vestir.frame = saveBtn_Vestir.bounds
        refreshDividerGradient_Vestir()
        if saveBtnShadow_Vestir.bounds.width > 0 {
            saveBtnShadow_Vestir.layer.shadowPath = UIBezierPath(
                roundedRect: saveBtnShadow_Vestir.bounds, cornerRadius: 28
            ).cgPath
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        let safeTop_Vestir = view.safeAreaInsets.top
        // 更新渐变背景区高度（导航栏高度 + 头像一半 = 适当留白）
        bgCard_Vestir.snp.updateConstraints { make in
            make.height.equalTo(safeTop_Vestir + 120)
        }
        // 同步更新返回按钮 top（确保在状态栏下方）
        backBtn_Vestir.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Vestir + 10)
        }
    }

    // MARK: - 渐变分隔线

    private func refreshDividerGradient_Vestir() {
        formDivider_Vestir.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }
        guard formDivider_Vestir.bounds.width > 0 else { return }
        let g_Vestir = CAGradientLayer()
        g_Vestir.frame = formDivider_Vestir.bounds
        g_Vestir.colors = [
            UIColor(hexstring_Vestir: "#BE185D").cgColor,
            UIColor(hexstring_Vestir: "#9333EA").cgColor,
            UIColor.clear.cgColor
        ]
        g_Vestir.locations = [0, 0.5, 1.0]
        g_Vestir.startPoint = CGPoint(x: 0, y: 0.5)
        g_Vestir.endPoint = CGPoint(x: 1, y: 0.5)
        formDivider_Vestir.layer.addSublayer(g_Vestir)
    }

    // MARK: - UI 搭建

    private func setupUI_Vestir() {
        view.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir

        // 渐变背景（仅覆盖头部区域，使用 scrollView 内容区的 headerArea 概念）
        view.addSubview(scrollView_Vestir)
        scrollView_Vestir.addSubview(contentView_Vestir)

        // 渐变背景卡（位于 contentView 顶部）
        contentView_Vestir.addSubview(bgCard_Vestir)
        bgCard_Vestir.addSubview(decoCircle1_Vestir)
        bgCard_Vestir.addSubview(decoCircle2_Vestir)
        bgCard_Vestir.addSubview(backBtn_Vestir)
        bgCard_Vestir.addSubview(navTitleLabel_Vestir)

        // 头像区域（在渐变背景下方区域）
        contentView_Vestir.addSubview(avatarContainer_Vestir)
        avatarContainer_Vestir.addSubview(avatarView_Vestir)
        avatarContainer_Vestir.addSubview(previewImageView_Vestir)
        avatarContainer_Vestir.addSubview(avatarEditOverlay_Vestir)
        avatarContainer_Vestir.addSubview(cameraIconView_Vestir)
        avatarContainer_Vestir.addSubview(sparkBadge_Vestir)
        contentView_Vestir.addSubview(changePhotoHintLabel_Vestir)

        // 表单卡片
        contentView_Vestir.addSubview(formCardShadow_Vestir)
        formCardShadow_Vestir.addSubview(formCard_Vestir)
        formCard_Vestir.addSubview(nameAccentBar_Vestir)
        formCard_Vestir.addSubview(nameSectionLabel_Vestir)
        formCard_Vestir.addSubview(nameField_Vestir)
        formCard_Vestir.addSubview(formDivider_Vestir)
        formCard_Vestir.addSubview(bioAccentBar_Vestir)
        formCard_Vestir.addSubview(bioSectionLabel_Vestir)
        formCard_Vestir.addSubview(bioField_Vestir)

        // 保存按钮
        contentView_Vestir.addSubview(saveBtnShadow_Vestir)
        saveBtnShadow_Vestir.addSubview(saveBtn_Vestir)
        saveBtn_Vestir.layer.insertSublayer(saveGradLayer_Vestir, at: 0)
    }

    private func setupConstraints_Vestir() {
        scrollView_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        // 渐变背景区（紧凑导航头部高度，随 safeArea 更新）
        bgCard_Vestir.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(view.safeAreaInsets.top + 120)
        }

        decoCircle1_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.trailing.equalToSuperview().offset(26)
            make.top.equalToSuperview().offset(-26)
        }
        decoCircle2_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(72)
            make.leading.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(18)
        }

        // 返回按钮：在 bgCard 顶部（safeArea 下方 10pt），随 viewSafeAreaInsetsDidChange 更新
        backBtn_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(view.safeAreaInsets.top + 10)
            make.width.height.equalTo(32)
        }
        // 标题与返回按钮垂直居中对齐
        navTitleLabel_Vestir.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backBtn_Vestir)
        }

        // 头像容器：中心与 bgCard 底边对齐，上半在渐变内、下半在白色区，形成悬浮效果
        avatarContainer_Vestir.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(bgCard_Vestir.snp.bottom)
            make.width.height.equalTo(100)
        }
        avatarView_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }
        previewImageView_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }
        avatarEditOverlay_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }
        cameraIconView_Vestir.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        sparkBadge_Vestir.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(4)
            make.width.height.equalTo(28)
        }

        changePhotoHintLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(avatarContainer_Vestir.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        // 表单卡片：头像中心在 bgCard 底，头像高 100pt，下半 50pt 在白色区 + 8pt hint + 16pt gap
        formCardShadow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(avatarContainer_Vestir.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        formCard_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }

        nameAccentBar_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(18)
            make.width.equalTo(4)
            make.height.equalTo(34)
        }
        nameSectionLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(nameAccentBar_Vestir.snp.trailing).offset(10)
            make.top.equalTo(nameAccentBar_Vestir)
        }
        nameField_Vestir.snp.makeConstraints { make in
            make.top.equalTo(nameSectionLabel_Vestir.snp.bottom).offset(6)
            make.leading.equalTo(nameAccentBar_Vestir)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
        formDivider_Vestir.snp.makeConstraints { make in
            make.top.equalTo(nameField_Vestir.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview()
            make.height.equalTo(1.5)
        }
        bioAccentBar_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.top.equalTo(formDivider_Vestir.snp.bottom).offset(14)
            make.width.equalTo(4)
            make.height.equalTo(26)
        }
        bioSectionLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(bioAccentBar_Vestir.snp.trailing).offset(10)
            make.centerY.equalTo(bioAccentBar_Vestir)
        }
        bioField_Vestir.snp.makeConstraints { make in
            make.top.equalTo(bioAccentBar_Vestir.snp.bottom).offset(8)
            make.leading.equalTo(bioAccentBar_Vestir)
            make.trailing.equalToSuperview().offset(-16)
            make.height.greaterThanOrEqualTo(90)
            make.bottom.equalToSuperview().offset(-20)
        }

        // 保存按钮
        saveBtnShadow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(formCardShadow_Vestir.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-32)
        }
        saveBtn_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    private func setupActions_Vestir() {
        // 通过 CurrentUserAvatarView 的 onTapped 回调响应点击，避免其内置手势消费掉 tap
        avatarView_Vestir.onTapped_Vestir = { [weak self] in
            self?.avatarTapped_Vestir()
        }
        // 给相机遮罩层也注册手势（点击任何区域均可触发）
        avatarEditOverlay_Vestir.isUserInteractionEnabled = true
        let overlayTap_Vestir = UITapGestureRecognizer(
            target: self, action: #selector(avatarTapped_Vestir)
        )
        avatarEditOverlay_Vestir.addGestureRecognizer(overlayTap_Vestir)

        saveBtn_Vestir.addTarget(self, action: #selector(saveTapped_Vestir), for: .touchUpInside)
    }

    private func animateIn_Vestir() {
        formCardShadow_Vestir.alpha = 0
        saveBtnShadow_Vestir.alpha = 0
        formCardShadow_Vestir.animateSlideInFromBottom_Vestir(offset_Vestir: 40, delay_Vestir: 0.15)
        saveBtnShadow_Vestir.animateFadeIn_Vestir(delay_Vestir: 0.30)
    }

    // MARK: - 数据加载

    private func loadCurrentUserData_Vestir() {
        // 无需登录校验，直接加载当前用户数据（未登录则保持空白）
        guard UserViewModel_Vestir.shared_Vestir.isLoggedIn_Vestir else { return }
        let user_Vestir = UserViewModel_Vestir.shared_Vestir.getCurrentUser_Vestir()
        nameField_Vestir.text = user_Vestir.userName_Vestir
        bioField_Vestir.text = user_Vestir.userIntroduce_Vestir
    }

    // MARK: - 事件处理

    @objc private func backTapped_Vestir() { Navigation_Vestir.pop_Vestir() }

    @objc private func avatarTapped_Vestir() {
        avatarContainer_Vestir.animatePressDown_Vestir {
            self.avatarContainer_Vestir.animatePressUp_Vestir()
        }
        MediaPickerHelper_Vestir.pickImage_Vestir(from: self) { [weak self] img_Vestir in
            guard let self = self, let img_Vestir = img_Vestir else { return }
            self.selectedImage_Vestir = img_Vestir
            self.previewImageView_Vestir.image = img_Vestir
            self.previewImageView_Vestir.isHidden = false
            self.previewImageView_Vestir.animateFadeIn_Vestir()
        }
    }

    @objc private func saveTapped_Vestir() {
        saveBtn_Vestir.animatePressDown_Vestir { self.saveBtn_Vestir.animatePressUp_Vestir() }
        guard UserViewModel_Vestir.shared_Vestir.isLoggedIn_Vestir else {
            Navigation_Vestir.toLogin_Vestir(style_vestir: .present_vestir)
            return
        }
        Task { @MainActor in
            var anyChanged_Vestir = false
            if let img_Vestir = self.selectedImage_Vestir,
               let data_Vestir = img_Vestir.jpegData(compressionQuality: 0.8) {
                let fileName_Vestir = "avatar_\(Date().timeIntervalSince1970).jpg"
                let url_Vestir = FileManager.default.urls(
                    for: .documentDirectory, in: .userDomainMask
                )[0].appendingPathComponent(fileName_Vestir)
                try? data_Vestir.write(to: url_Vestir)
                UserViewModel_Vestir.shared_Vestir.updateHead_Vestir(headUrl_vestir: url_Vestir.path)
                anyChanged_Vestir = true
            }
            let originalName_Vestir = UserViewModel_Vestir.shared_Vestir.getCurrentUser_Vestir().userName_Vestir
            if let name_Vestir = self.nameField_Vestir.text,
               !name_Vestir.isEmpty, name_Vestir != originalName_Vestir {
                UserViewModel_Vestir.shared_Vestir.updateName_Vestir(userName_vestir: name_Vestir)
                anyChanged_Vestir = true
            }
            let bio_Vestir = self.bioField_Vestir.text ?? ""
            if !bio_Vestir.isEmpty {
                UserViewModel_Vestir.shared_Vestir.updateIntroduce_Vestir(introduce_vestir: bio_Vestir)
                anyChanged_Vestir = true
            }
            if !anyChanged_Vestir {
                Utils_Vestir.showInfo_Vestir(message_Vestir: "No changes to save")
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                Navigation_Vestir.pop_Vestir()
            }
        }
    }
}

// MARK: - 编辑信息页渐变背景（深玫瑰→紫罗兰→靛蓝）

fileprivate final class EditInfoBgCard_Vestir: UIView {
    private let g_Vestir: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(hexstring_Vestir: "#BE185D").cgColor,
            UIColor(hexstring_Vestir: "#9333EA").cgColor,
            UIColor(hexstring_Vestir: "#4338CA").cgColor
        ]
        g.locations = [0, 0.50, 1.0]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 1)
        return g
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.insertSublayer(g_Vestir, at: 0)
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 30
        clipsToBounds = true
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() { super.layoutSubviews(); g_Vestir.frame = bounds }
}
