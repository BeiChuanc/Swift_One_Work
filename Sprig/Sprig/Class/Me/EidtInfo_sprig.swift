import Foundation
import UIKit
import SnapKit

// MARK: 修改用户信息页面

/// 修改用户信息页面
/// 功能：支持修改头像（从相册选取预览，确认后保存）、昵称、个人简介
/// 设计：渐变头部（含副标题）+ 多圈装饰头像区 + 带左侧渐变条的输入卡片 + 图标渐变保存按钮
/// 逻辑：确认前判断是否登录；字段未填写时保留原有数据
class EditInfo_Sprig: UIViewController {

    // MARK: - 属性

    /// 待保存的新头像（从相册选取后暂存，确认时写入）
    private var pendingAvatar_Sprig: UIImage?

    /// 原始昵称（用于空白回退）
    private var originalName_Sprig: String = ""

    /// 原始简介（用于空白回退）
    private var originalBio_Sprig: String = ""

    // MARK: - UI 组件 - 头部

    private let headerView_Sprig = UIView()
    private let gradientLayer_Sprig = CAGradientLayer()
    private let backButton_Sprig = UIButton(type: .system)
    private let pageTitleLabel_Sprig = UILabel()
    /// 头部装饰圆
    private let headerDecorCircle_Sprig = UIView()

    // MARK: - UI 组件 - 内容

    private let scrollView_Sprig = UIScrollView()
    private let contentView_Sprig = UIView()

    // 头像区域
    private let avatarWrapperView_Sprig = UIView()
    private let avatarView_Sprig = CurrentUserAvatarView_Sprig()
    /// "已选取"角标（选取新头像后显示）
    private let avatarNewBadge_Sprig = UILabel()

    // 昵称卡片
    private let nameCard_Sprig = UIView()
    private let nameAccentStrip_Sprig = UIView()
    private let nameAccentGradient_Sprig = CAGradientLayer()
    private let nameSectionLabel_Sprig = UILabel()
    private let nameTextField_Sprig = UITextField()

    // 简介卡片
    private let bioCard_Sprig = UIView()
    private let bioAccentStrip_Sprig = UIView()
    private let bioAccentGradient_Sprig = CAGradientLayer()
    private let bioSectionLabel_Sprig = UILabel()
    private let bioTextView_Sprig = UITextView()
    private let bioPlaceholderLabel_Sprig = UILabel()
    private let bioCharCountLabel_Sprig = UILabel()

    // 保存按钮
    private let confirmButton_Sprig = UIButton(type: .system)
    private let confirmGradientLayer_Sprig = CAGradientLayer()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI_Sprig()
        prefillData_Sprig()
        registerKeyboardObservers_Sprig()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer_Sprig.frame = headerView_Sprig.bounds
        confirmGradientLayer_Sprig.frame = confirmButton_Sprig.bounds
        // 更新两个卡片左侧渐变条的尺寸
        nameAccentGradient_Sprig.frame = nameAccentStrip_Sprig.bounds
        bioAccentGradient_Sprig.frame = bioAccentStrip_Sprig.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func buildUI_Sprig() {
        view.backgroundColor = ColorConfig_Sprig.backgroundPrimary_Sprig
        buildHeader_Sprig()
        buildScrollContent_Sprig()
        let tap_Sprig = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Sprig))
        tap_Sprig.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Sprig)
    }

    /// 搭建渐变头部（含副标题 + 装饰圆）
    private func buildHeader_Sprig() {
        gradientLayer_Sprig.colors = [
            ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor
        ]
        gradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Sprig.endPoint = CGPoint(x: 1, y: 1)
        headerView_Sprig.layer.insertSublayer(gradientLayer_Sprig, at: 0)
        headerView_Sprig.clipsToBounds = true
        view.addSubview(headerView_Sprig)
        headerView_Sprig.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(96)
        }

        // 装饰圆（右上角）
        headerDecorCircle_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        headerDecorCircle_Sprig.layer.cornerRadius = 55
        headerView_Sprig.addSubview(headerDecorCircle_Sprig)
        headerDecorCircle_Sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(28)
            make.top.equalToSuperview().offset(-22)
            make.width.height.equalTo(110)
        }

        // 描边装饰圆（左下）
        let decorRing_Sprig = UIView()
        decorRing_Sprig.backgroundColor = .clear
        decorRing_Sprig.layer.borderWidth = 2
        decorRing_Sprig.layer.borderColor = UIColor.white.withAlphaComponent(0.20).cgColor
        decorRing_Sprig.layer.cornerRadius = 28
        headerView_Sprig.addSubview(decorRing_Sprig)
        decorRing_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(18)
            make.width.height.equalTo(56)
        }

        // 返回按钮（毛玻璃背景）
        let backBg_Sprig = UIView()
        backBg_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        backBg_Sprig.layer.cornerRadius = 18
        headerView_Sprig.addSubview(backBg_Sprig)
        backBg_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.width.height.equalTo(36)
        }
        let backCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        backButton_Sprig.setImage(UIImage(systemName: "chevron.left", withConfiguration: backCfg_Sprig), for: .normal)
        backButton_Sprig.tintColor = .white
        backButton_Sprig.addTarget(self, action: #selector(onBackTapped_Sprig), for: .touchUpInside)
        headerView_Sprig.addSubview(backButton_Sprig)
        backButton_Sprig.snp.makeConstraints { make in make.edges.equalTo(backBg_Sprig) }

        // 页面标题
        pageTitleLabel_Sprig.text = "Edit Profile"
        pageTitleLabel_Sprig.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        pageTitleLabel_Sprig.textColor = .white
        headerView_Sprig.addSubview(pageTitleLabel_Sprig)
        pageTitleLabel_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton_Sprig)
        }

        // 副标题
        let subTitleLabel_Sprig = UILabel()
        subTitleLabel_Sprig.text = "Keep your profile fresh ✨"
        subTitleLabel_Sprig.font = UIFont.systemFont(ofSize: 13)
        subTitleLabel_Sprig.textColor = UIColor.white.withAlphaComponent(0.72)
        subTitleLabel_Sprig.textAlignment = .center
        headerView_Sprig.addSubview(subTitleLabel_Sprig)
        subTitleLabel_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(backButton_Sprig.snp.bottom).offset(10)
        }
    }

    /// 搭建滚动内容区（头像 + 输入卡片 + 保存按钮）
    private func buildScrollContent_Sprig() {
        scrollView_Sprig.showsVerticalScrollIndicator = false
        scrollView_Sprig.alwaysBounceVertical = true
        view.addSubview(scrollView_Sprig)
        scrollView_Sprig.snp.makeConstraints { make in
            make.top.equalTo(headerView_Sprig.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        scrollView_Sprig.addSubview(contentView_Sprig)
        contentView_Sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        buildAvatarSection_Sprig()
        buildNameCard_Sprig()
        buildBioCard_Sprig()
        buildConfirmButton_Sprig()

        let bottomPad_Sprig = UIView()
        contentView_Sprig.addSubview(bottomPad_Sprig)
        bottomPad_Sprig.snp.makeConstraints { make in
            make.top.equalTo(confirmButton_Sprig.snp.bottom).offset(40)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(60)
        }
    }

    /// 搭建头像展示区域（双圈装饰 + 相机遮罩 + 已选角标）
    private func buildAvatarSection_Sprig() {
        contentView_Sprig.addSubview(avatarWrapperView_Sprig)
        avatarWrapperView_Sprig.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(110)
        }

        // 最外层虚线装饰环
        let outerRing_Sprig = UIView()
        outerRing_Sprig.backgroundColor = .clear
        outerRing_Sprig.layer.borderWidth = 1.5
        outerRing_Sprig.layer.borderColor = ColorConfig_Sprig.primaryGradientStart_Sprig.withAlphaComponent(0.22).cgColor
        outerRing_Sprig.layer.cornerRadius = 55
        avatarWrapperView_Sprig.addSubview(outerRing_Sprig)
        outerRing_Sprig.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 中间实线装饰环
        let innerRing_Sprig = UIView()
        innerRing_Sprig.backgroundColor = .clear
        innerRing_Sprig.layer.borderWidth = 2.5
        innerRing_Sprig.layer.borderColor = ColorConfig_Sprig.primaryGradientStart_Sprig.withAlphaComponent(0.55).cgColor
        innerRing_Sprig.layer.cornerRadius = 47
        avatarWrapperView_Sprig.addSubview(innerRing_Sprig)
        innerRing_Sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(94)
        }

        // 头像组件（显示编辑铅笔按钮，点击打开相册）
        avatarView_Sprig.showEditButton_Sprig = true
        avatarView_Sprig.onTapped_Sprig = { [weak self] in
            self?.openImagePicker_Sprig()
        }
        avatarWrapperView_Sprig.addSubview(avatarView_Sprig)
        avatarView_Sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(88)
        }

        // 右下角相机徽章（独立视觉提示）
        let cameraBadge_Sprig = UIView()
        cameraBadge_Sprig.backgroundColor = ColorConfig_Sprig.primaryGradientStart_Sprig
        cameraBadge_Sprig.layer.cornerRadius = 13
        cameraBadge_Sprig.layer.borderWidth = 2
        cameraBadge_Sprig.layer.borderColor = UIColor.white.cgColor
        avatarWrapperView_Sprig.addSubview(cameraBadge_Sprig)
        cameraBadge_Sprig.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().inset(4)
            make.width.height.equalTo(26)
        }
        let camCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        let camIcon_Sprig = UIImageView(image: UIImage(systemName: "camera.fill", withConfiguration: camCfg_Sprig))
        camIcon_Sprig.tintColor = .white
        camIcon_Sprig.contentMode = .scaleAspectFit
        cameraBadge_Sprig.addSubview(camIcon_Sprig)
        camIcon_Sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(13)
        }

        // "New ✓" 角标（初始隐藏）
        avatarNewBadge_Sprig.text = "New ✓"
        avatarNewBadge_Sprig.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        avatarNewBadge_Sprig.textColor = .white
        avatarNewBadge_Sprig.backgroundColor = UIColor(hexstring_Sprig: "#38A169")
        avatarNewBadge_Sprig.layer.cornerRadius = 9
        avatarNewBadge_Sprig.clipsToBounds = true
        avatarNewBadge_Sprig.textAlignment = .center
        avatarNewBadge_Sprig.isHidden = true
        contentView_Sprig.addSubview(avatarNewBadge_Sprig)
        avatarNewBadge_Sprig.snp.makeConstraints { make in
            make.top.equalTo(avatarWrapperView_Sprig.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.height.equalTo(22)
            make.width.equalTo(60)
        }

        // 点击提示文字（当未显示 New 角标时出现）
        let changeAvatarHint_Sprig = UILabel()
        changeAvatarHint_Sprig.text = "Tap to change avatar"
        changeAvatarHint_Sprig.font = UIFont.systemFont(ofSize: 12)
        changeAvatarHint_Sprig.textColor = ColorConfig_Sprig.textSecondary_Sprig
        contentView_Sprig.addSubview(changeAvatarHint_Sprig)
        changeAvatarHint_Sprig.snp.makeConstraints { make in
            make.top.equalTo(avatarNewBadge_Sprig.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }
    }

    /// 搭建昵称输入卡片（带左侧渐变色条 + 图标标签）
    private func buildNameCard_Sprig() {
        nameCard_Sprig.backgroundColor = .white
        nameCard_Sprig.layer.cornerRadius = 20
        nameCard_Sprig.clipsToBounds = true
        applyCardShadow_Sprig(to: nameCard_Sprig)
        contentView_Sprig.addSubview(nameCard_Sprig)
        nameCard_Sprig.snp.makeConstraints { make in
            make.top.equalTo(avatarWrapperView_Sprig.snp.bottom).offset(52)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(82)
        }

        // 左侧渐变色条
        nameAccentGradient_Sprig.colors = [
            ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor
        ]
        nameAccentGradient_Sprig.startPoint = CGPoint(x: 0.5, y: 0)
        nameAccentGradient_Sprig.endPoint = CGPoint(x: 0.5, y: 1)
        nameAccentStrip_Sprig.layer.insertSublayer(nameAccentGradient_Sprig, at: 0)
        nameCard_Sprig.addSubview(nameAccentStrip_Sprig)
        nameAccentStrip_Sprig.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(4)
        }

        // 图标
        let personCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let personIcon_Sprig = UIImageView(image: UIImage(systemName: "person.fill", withConfiguration: personCfg_Sprig))
        personIcon_Sprig.tintColor = ColorConfig_Sprig.primaryGradientStart_Sprig
        personIcon_Sprig.contentMode = .scaleAspectFit
        nameCard_Sprig.addSubview(personIcon_Sprig)
        personIcon_Sprig.snp.makeConstraints { make in
            make.left.equalTo(nameAccentStrip_Sprig.snp.right).offset(14)
            make.top.equalToSuperview().offset(14)
            make.width.height.equalTo(14)
        }

        // 字段标签（与图标同行）
        nameSectionLabel_Sprig.text = "Username"
        nameSectionLabel_Sprig.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        nameSectionLabel_Sprig.textColor = ColorConfig_Sprig.primaryGradientStart_Sprig
        nameCard_Sprig.addSubview(nameSectionLabel_Sprig)
        nameSectionLabel_Sprig.snp.makeConstraints { make in
            make.left.equalTo(personIcon_Sprig.snp.right).offset(5)
            make.centerY.equalTo(personIcon_Sprig)
        }

        // 输入框
        nameTextField_Sprig.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        nameTextField_Sprig.textColor = ColorConfig_Sprig.textPrimary_Sprig
        nameTextField_Sprig.placeholder = "Your name"
        nameTextField_Sprig.placeHolderTextColor_Sprig(ColorConfig_Sprig.textPlaceholder_Sprig)
        nameTextField_Sprig.returnKeyType = .done
        nameTextField_Sprig.delegate = self
        nameCard_Sprig.addSubview(nameTextField_Sprig)
        nameTextField_Sprig.snp.makeConstraints { make in
            make.top.equalTo(nameSectionLabel_Sprig.snp.bottom).offset(6)
            make.left.equalTo(nameAccentStrip_Sprig.snp.right).offset(14)
            make.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-14)
        }
    }

    /// 搭建简介输入卡片（含字数统计 + 左侧渐变条）
    private func buildBioCard_Sprig() {
        bioCard_Sprig.backgroundColor = .white
        bioCard_Sprig.layer.cornerRadius = 20
        bioCard_Sprig.clipsToBounds = true
        applyCardShadow_Sprig(to: bioCard_Sprig)
        contentView_Sprig.addSubview(bioCard_Sprig)
        bioCard_Sprig.snp.makeConstraints { make in
            make.top.equalTo(nameCard_Sprig.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(138)
        }

        // 左侧渐变色条（End 颜色）
        bioAccentGradient_Sprig.colors = [
            ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor,
            ColorConfig_Sprig.secondaryGradientStart_Sprig.cgColor
        ]
        bioAccentGradient_Sprig.startPoint = CGPoint(x: 0.5, y: 0)
        bioAccentGradient_Sprig.endPoint = CGPoint(x: 0.5, y: 1)
        bioAccentStrip_Sprig.layer.insertSublayer(bioAccentGradient_Sprig, at: 0)
        bioCard_Sprig.addSubview(bioAccentStrip_Sprig)
        bioAccentStrip_Sprig.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(4)
        }

        // 图标
        let noteCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let noteIcon_Sprig = UIImageView(image: UIImage(systemName: "text.quote", withConfiguration: noteCfg_Sprig))
        noteIcon_Sprig.tintColor = ColorConfig_Sprig.primaryGradientEnd_Sprig
        noteIcon_Sprig.contentMode = .scaleAspectFit
        bioCard_Sprig.addSubview(noteIcon_Sprig)
        noteIcon_Sprig.snp.makeConstraints { make in
            make.left.equalTo(bioAccentStrip_Sprig.snp.right).offset(14)
            make.top.equalToSuperview().offset(14)
            make.width.height.equalTo(14)
        }

        // 字段标签
        bioSectionLabel_Sprig.text = "Bio"
        bioSectionLabel_Sprig.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        bioSectionLabel_Sprig.textColor = ColorConfig_Sprig.primaryGradientEnd_Sprig
        bioCard_Sprig.addSubview(bioSectionLabel_Sprig)
        bioSectionLabel_Sprig.snp.makeConstraints { make in
            make.left.equalTo(noteIcon_Sprig.snp.right).offset(5)
            make.centerY.equalTo(noteIcon_Sprig)
        }

        // 字符数上限胶囊
        bioCharCountLabel_Sprig.text = "0/100"
        bioCharCountLabel_Sprig.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        bioCharCountLabel_Sprig.textColor = ColorConfig_Sprig.textPlaceholder_Sprig
        bioCharCountLabel_Sprig.backgroundColor = ColorConfig_Sprig.backgroundPrimary_Sprig
        bioCharCountLabel_Sprig.layer.cornerRadius = 8
        bioCharCountLabel_Sprig.clipsToBounds = true
        bioCharCountLabel_Sprig.textAlignment = .center
        bioCard_Sprig.addSubview(bioCharCountLabel_Sprig)
        bioCharCountLabel_Sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalTo(bioSectionLabel_Sprig)
            make.height.equalTo(18)
            make.width.equalTo(42)
        }

        // 文本输入区
        bioTextView_Sprig.font = UIFont.systemFont(ofSize: 15)
        bioTextView_Sprig.textColor = ColorConfig_Sprig.textPrimary_Sprig
        bioTextView_Sprig.backgroundColor = .clear
        bioTextView_Sprig.textContainerInset = .zero
        bioTextView_Sprig.textContainer.lineFragmentPadding = 0
        bioTextView_Sprig.delegate = self
        bioCard_Sprig.addSubview(bioTextView_Sprig)
        bioTextView_Sprig.snp.makeConstraints { make in
            make.top.equalTo(bioSectionLabel_Sprig.snp.bottom).offset(8)
            make.left.equalTo(bioAccentStrip_Sprig.snp.right).offset(14)
            make.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-14)
        }

        // 占位符文字（TextView 无内置 placeholder，手动实现）
        bioPlaceholderLabel_Sprig.text = "Tell us a little about yourself..."
        bioPlaceholderLabel_Sprig.font = UIFont.systemFont(ofSize: 15)
        bioPlaceholderLabel_Sprig.textColor = ColorConfig_Sprig.textPlaceholder_Sprig
        bioPlaceholderLabel_Sprig.isUserInteractionEnabled = false
        bioCard_Sprig.addSubview(bioPlaceholderLabel_Sprig)
        bioPlaceholderLabel_Sprig.snp.makeConstraints { make in
            make.top.left.right.equalTo(bioTextView_Sprig)
        }
    }

    /// 搭建渐变保存按钮（带图标 + 发光阴影）
    private func buildConfirmButton_Sprig() {
        confirmGradientLayer_Sprig.colors = [
            ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor
        ]
        confirmGradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0.5)
        confirmGradientLayer_Sprig.endPoint = CGPoint(x: 1, y: 0.5)
        confirmGradientLayer_Sprig.cornerRadius = 26
        confirmButton_Sprig.layer.insertSublayer(confirmGradientLayer_Sprig, at: 0)
        confirmButton_Sprig.layer.cornerRadius = 26
        confirmButton_Sprig.clipsToBounds = false

        // 发光阴影
        confirmButton_Sprig.layer.shadowColor = ColorConfig_Sprig.primaryGradientStart_Sprig.withAlphaComponent(0.50).cgColor
        confirmButton_Sprig.layer.shadowOffset = CGSize(width: 0, height: 6)
        confirmButton_Sprig.layer.shadowOpacity = 1
        confirmButton_Sprig.layer.shadowRadius = 12

        confirmButton_Sprig.setTitle("  Save Changes", for: .normal)
        confirmButton_Sprig.setTitleColor(.white, for: .normal)
        confirmButton_Sprig.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        let checkCfg_Sprig = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        confirmButton_Sprig.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: checkCfg_Sprig), for: .normal)
        confirmButton_Sprig.tintColor = .white
        confirmButton_Sprig.addTarget(self, action: #selector(onConfirmTapped_Sprig), for: .touchUpInside)
        contentView_Sprig.addSubview(confirmButton_Sprig)
        confirmButton_Sprig.snp.makeConstraints { make in
            make.top.equalTo(bioCard_Sprig.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
    }

    // MARK: - 数据预填充

    /// 使用当前登录用户数据预填充表单字段
    private func prefillData_Sprig() {
        let user_Sprig = UserViewModel_Sprig.shared_Sprig.getCurrentUser_Sprig()
        let name_Sprig = user_Sprig.userName_Sprig ?? ""
        let bio_Sprig = user_Sprig.userIntroduce_Sprig ?? ""

        originalName_Sprig = name_Sprig
        originalBio_Sprig = bio_Sprig

        nameTextField_Sprig.text = name_Sprig

        if bio_Sprig.isEmpty {
            bioPlaceholderLabel_Sprig.isHidden = false
            bioCharCountLabel_Sprig.text = "0/100"
        } else {
            bioTextView_Sprig.text = bio_Sprig
            bioPlaceholderLabel_Sprig.isHidden = true
            bioCharCountLabel_Sprig.text = "\(bio_Sprig.count)/100"
        }
    }

    // MARK: - 键盘管理

    private func registerKeyboardObservers_Sprig() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onKeyboardShow_Sprig(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onKeyboardHide_Sprig(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    @objc private func onKeyboardShow_Sprig(_ notification: Notification) {
        guard let frame_Sprig = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView_Sprig.contentInset.bottom = frame_Sprig.height + 20
        scrollView_Sprig.scrollIndicatorInsets.bottom = frame_Sprig.height
    }

    @objc private func onKeyboardHide_Sprig(_ notification: Notification) {
        scrollView_Sprig.contentInset.bottom = 0
        scrollView_Sprig.scrollIndicatorInsets.bottom = 0
    }

    @objc private func dismissKeyboard_Sprig() {
        view.endEditing(true)
    }

    // MARK: - 相册选取

    /// 打开系统相册选取头像，选取后预览并显示 New 角标
    private func openImagePicker_Sprig() {
        MediaPickerHelper_Sprig.pickImage_Sprig(from: self) { [weak self] image_Sprig in
            guard let self, let image_Sprig else { return }
            // 暂存待保存图片
            self.pendingAvatar_Sprig = image_Sprig
            // 直接在头像视图上预览，不触发 ViewModel 通知
            self.avatarView_Sprig.imageView_Sprig.image = image_Sprig
            self.avatarView_Sprig.imageView_Sprig.contentMode = .scaleAspectFill
            // 显示已选取角标（带弹出动画）
            self.avatarNewBadge_Sprig.isHidden = false
            self.avatarNewBadge_Sprig.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, delay: 0,
                           usingSpringWithDamping: 0.65, initialSpringVelocity: 0.8,
                           options: []) {
                self.avatarNewBadge_Sprig.transform = .identity
            }
        }
    }

    // MARK: - 事件处理

    @objc private func onBackTapped_Sprig() {
        Navigation_Sprig.pop_Sprig()
    }

    /// 点击保存：验证登录状态 → 对比变化 → 调用 ViewModel 更新
    @objc private func onConfirmTapped_Sprig() {
        guard UserViewModel_Sprig.shared_Sprig.isLoggedIn_Sprig else {
            Navigation_Sprig.toLogin_Sprig(style_sprig: .present_sprig)
            return
        }

        confirmButton_Sprig.animatePressDown_Sprig { self.confirmButton_Sprig.animatePressUp_Sprig() }
        view.endEditing(true)

        // 保存新头像（若有选取）
        if let newAvatar_Sprig = pendingAvatar_Sprig {
            UserViewModel_Sprig.shared_Sprig.saveAndUpdateAvatar_Sprig(image_sprig: newAvatar_Sprig)
        }

        // 计算最终昵称和简介（空白时保留原有数据）
        let inputName_Sprig = nameTextField_Sprig.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let finalName_Sprig = inputName_Sprig.isEmpty ? originalName_Sprig : inputName_Sprig

        let inputBio_Sprig = bioTextView_Sprig.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let finalBio_Sprig = inputBio_Sprig.isEmpty ? originalBio_Sprig : inputBio_Sprig

        // 仅在有实际变化时发起更新，避免多余的 Toast
        let nameChanged_Sprig = finalName_Sprig != originalName_Sprig
        let bioChanged_Sprig = finalBio_Sprig != originalBio_Sprig

        if nameChanged_Sprig || bioChanged_Sprig || pendingAvatar_Sprig != nil {
            UserViewModel_Sprig.shared_Sprig.updateProfile_Sprig(
                name_sprig: nameChanged_Sprig ? finalName_Sprig : nil,
                introduce_sprig: bioChanged_Sprig ? finalBio_Sprig : nil
            )
        }

        // 延迟返回，等待 Toast 展示完毕
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            Navigation_Sprig.pop_Sprig()
        }
    }

    // MARK: - 工具方法

    /// 为卡片视图应用统一阴影样式
    private func applyCardShadow_Sprig(to view_Sprig: UIView) {
        view_Sprig.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        view_Sprig.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Sprig.layer.shadowOpacity = 1
        view_Sprig.layer.shadowRadius = 10
    }
}

// MARK: - UITextFieldDelegate

extension EditInfo_Sprig: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /// 昵称最多 30 个字符
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let current_Sprig = textField.text ?? ""
        guard let swiftRange_Sprig = Range(range, in: current_Sprig) else { return true }
        return current_Sprig.replacingCharacters(in: swiftRange_Sprig, with: string).count <= 30
    }
}

// MARK: - UITextViewDelegate

extension EditInfo_Sprig: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        let count_Sprig = textView.text.count
        bioPlaceholderLabel_Sprig.isHidden = !textView.text.isEmpty
        bioCharCountLabel_Sprig.text = "\(count_Sprig)/100"
        // 超出限制时标红提示
        bioCharCountLabel_Sprig.textColor = count_Sprig > 100
            ? UIColor(hexstring_Sprig: "#E53E3E")
            : ColorConfig_Sprig.textPlaceholder_Sprig
    }

    /// 简介最多 100 个字符
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        let current_Sprig = textView.text ?? ""
        guard let swiftRange_Sprig = Range(range, in: current_Sprig) else { return true }
        return current_Sprig.replacingCharacters(in: swiftRange_Sprig, with: text).count <= 100
    }
}
