import UIKit
import SnapKit

// MARK: - 修改用户信息页面控制器

/// 修改用户信息页面控制器
/// 功能：允许登录用户修改头像（从相册选取）、昵称、个人简介，并提交保存
/// 设计：波浪渐变头部 + 渐变头像环 + 激活边框表单 + Bio 字数计数 + Cancel/Save 双按钮
/// 逻辑：数据变化检测在保存时进行，未修改字段保留原值
class EditInfo_Flick: UIViewController {

    // MARK: - 私有属性

    private var originalName_Flick: String = ""
    private var originalBio_Flick: String  = ""
    private var originalHead_Flick: String? = nil

    private var selectedAvatarImage_Flick: UIImage? = nil

    /// Bio 最大字数
    private let maxBioLength_Flick = 120

    // MARK: - UI 组件

    private let scrollView_Flick: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
        sv.keyboardDismissMode = .onDrag
        // 禁止自动增加安全区 inset，确保渐变头部贴顶显示
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentContainer_Flick = UIView()

    // 顶部渐变头部（带波浪）
    private let headerView_Flick = UIView()
    private var headerGradient_Flick: CAGradientLayer?
    private var headerWaveMask_Flick: CAShapeLayer?

    private let backBtn_Flick = BackButton_Flick()

    private let titleLabel_Flick: UILabel = {
        let lbl = UILabel()
        lbl.text = "Edit Profile"
        lbl.font = .systemFont(ofSize: 28, weight: .bold)
        lbl.textColor = .white
        return lbl
    }()

    private let subtitleLabel_Flick: UILabel = {
        let lbl = UILabel()
        lbl.text = "Make it yours"
        lbl.font = .systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = UIColor.white.withValues(alpha: 0.7)
        return lbl
    }()

    // 渐变头像环
    private let avatarRingView_Flick = UIView()
    private var avatarRingGradient_Flick: CAGradientLayer?
    private var avatarRingMask_Flick: CAShapeLayer?

    /// 头像（带编辑按钮）
    private let avatarView_Flick: CurrentUserAvatarView_Flick = {
        let v = CurrentUserAvatarView_Flick()
        v.showEditButton_Flick = true
        v.layer.cornerRadius = 46
        v.clipsToBounds = false
        v.layer.borderWidth = 3
        v.layer.borderColor = UIColor.white.cgColor
        return v
    }()

    private let avatarHintLabel_Flick: UILabel = {
        let lbl = UILabel()
        lbl.text = "Tap to change photo"
        lbl.font = .systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = ColorConfig_Flick.primaryGradientStart_Flick
        lbl.textAlignment = .center
        return lbl
    }()

    /// 表单卡片
    private let formCard_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Flick.cardBackground_Flick
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor.black.withValues(alpha: 0.06).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 12
        return v
    }()

    /// 用户名输入框（含激活下划线）
    private let nameTextField_Flick: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Your name"
        tf.font = .systemFont(ofSize: 16, weight: .medium)
        tf.textColor = ColorConfig_Flick.textPrimary_Flick
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .next
        tf.autocorrectionType = .no
        return tf
    }()

    /// 姓名字段激活线
    private let nameActiveLine_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Flick.divider_Flick
        v.layer.cornerRadius = 1
        return v
    }()

    /// 简介输入视图
    private let bioTextView_Flick: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 15, weight: .regular)
        tv.textColor = ColorConfig_Flick.textPrimary_Flick
        tv.backgroundColor = .clear
        tv.returnKeyType = .done
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.isScrollEnabled = false
        return tv
    }()

    private let bioPlaceholder_Flick: UILabel = {
        let lbl = UILabel()
        lbl.text = "Write something about yourself..."
        lbl.font = .systemFont(ofSize: 15, weight: .regular)
        lbl.textColor = ColorConfig_Flick.textPlaceholder_Flick
        lbl.numberOfLines = 0
        return lbl
    }()

    /// Bio 字段激活线
    private let bioActiveLine_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Flick.divider_Flick
        v.layer.cornerRadius = 1
        return v
    }()

    /// Bio 字数计数
    private let bioCountLabel_Flick: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = ColorConfig_Flick.textSecondary_Flick
        lbl.text = "0 / 120"
        lbl.textAlignment = .right
        return lbl
    }()

    /// Cancel 按钮
    private let cancelBtn_Flick: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Cancel", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        btn.setTitleColor(ColorConfig_Flick.textSecondary_Flick, for: .normal)
        btn.backgroundColor = UIColor(hexstring_Flick: "#EDF2F7")
        btn.layer.cornerRadius = 20
        return btn
    }()

    /// Save Changes 按钮（渐变）
    private let saveBtn_Flick: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        btn.setImage(UIImage(systemName: "checkmark", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.setTitle("  Save", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 20
        btn.layer.shadowColor = UIColor(hexstring_Flick: "#B794F6").cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 5)
        btn.layer.shadowOpacity = 0.35
        btn.layer.shadowRadius = 10
        return btn
    }()
    private var saveBtnGradient_Flick: CAGradientLayer?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Flick()
        loadCurrentUserData_Flick()
        setupKeyboardObserver_Flick()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Flick?.frame = headerView_Flick.bounds
        applyHeaderWave_Flick()
        updateAvatarRing_Flick()
        updateSaveGradient_Flick()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - UI 设置

    private func setupUI_Flick() {
        view.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick

        view.addSubview(scrollView_Flick)
        scrollView_Flick.snp.makeConstraints { $0.edges.equalToSuperview() }

        scrollView_Flick.addSubview(contentContainer_Flick)
        contentContainer_Flick.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        setupHeaderSection_Flick()
        setupAvatarSection_Flick()
        setupFormSection_Flick()
        setupActionButtons_Flick()
    }

    // MARK: - 头部

    private func setupHeaderSection_Flick() {
        contentContainer_Flick.addSubview(headerView_Flick)
        headerView_Flick.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(165)
        }

        let gradient = UIColor.createPrimaryGradientLayer_Flick(
            frame_Flick: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 165)
        )
        headerView_Flick.layer.insertSublayer(gradient, at: 0)
        headerGradient_Flick = gradient

        let mask = CAShapeLayer()
        headerView_Flick.layer.mask = mask
        headerWaveMask_Flick = mask

        addHeaderDecor_Flick()

        headerView_Flick.addSubview(backBtn_Flick)
        backBtn_Flick.snp.makeConstraints { make in
            make.top.equalTo(headerView_Flick.safeAreaLayoutGuide.snp.top).offset(12)
            make.left.equalToSuperview().inset(16)
            make.width.height.equalTo(44)
        }
        backBtn_Flick.onTapped_Flick = { [weak self] in Navigation_Flick.pop_Flick(from: self) }

        // 副标题：与返回按钮同行，显示在其右侧
        headerView_Flick.addSubview(subtitleLabel_Flick)
        subtitleLabel_Flick.snp.makeConstraints { make in
            make.left.equalTo(backBtn_Flick.snp.right).offset(10)
            make.centerY.equalTo(backBtn_Flick)
        }

        // 大标题：紧跟返回按钮下方，避免遮盖
        headerView_Flick.addSubview(titleLabel_Flick)
        titleLabel_Flick.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(24)
            make.top.equalTo(backBtn_Flick.snp.bottom).offset(8)
        }

        // 右侧装饰 emoji：与大标题垂直居中对齐
        let emoji = UILabel()
        emoji.text = "✏️"
        emoji.font = .systemFont(ofSize: 44)
        emoji.alpha = 0.85
        headerView_Flick.addSubview(emoji)
        emoji.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(28)
            make.centerY.equalTo(titleLabel_Flick)
        }
    }

    private func applyHeaderWave_Flick() {
        let b = headerView_Flick.bounds
        guard b.width > 0 else { return }
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: b.width, y: 0))
        path.addLine(to: CGPoint(x: b.width, y: b.height - 22))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: b.height - 22),
            controlPoint: CGPoint(x: b.width / 2, y: b.height + 22)
        )
        path.close()
        headerWaveMask_Flick?.path = path.cgPath
    }

    private func addHeaderDecor_Flick() {
        let circles: [(CGFloat, CGFloat, Bool, CGFloat)] = [
            (100, 0.08, true, 35),
            (70, 0.06, false, 100)
        ]
        for (size, alpha, isRight, offset) in circles {
            let c = UIView()
            c.backgroundColor = UIColor.white.withValues(alpha: alpha)
            c.layer.cornerRadius = size / 2
            headerView_Flick.addSubview(c)
            c.snp.makeConstraints { make in
                make.width.height.equalTo(size)
                if isRight {
                    make.right.equalToSuperview().offset(offset)
                    make.top.equalToSuperview().offset(-20)
                } else {
                    make.left.equalToSuperview().offset(offset)
                    make.bottom.equalToSuperview().offset(20)
                }
            }
        }
    }

    // MARK: - 头像区域

    private func setupAvatarSection_Flick() {
        // 渐变环
        contentContainer_Flick.addSubview(avatarRingView_Flick)
        avatarRingView_Flick.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerView_Flick.snp.bottom).offset(-50)
            make.width.height.equalTo(108)
        }
        setupAvatarRing_Flick()

        // 头像（在环内）
        contentContainer_Flick.addSubview(avatarView_Flick)
        avatarView_Flick.snp.makeConstraints { make in
            make.center.equalTo(avatarRingView_Flick)
            make.width.height.equalTo(96)
        }

        contentContainer_Flick.addSubview(avatarHintLabel_Flick)
        avatarHintLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView_Flick.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        avatarView_Flick.onTapped_Flick = { [weak self] in self?.openPhotoPicker_Flick() }
    }

    private func setupAvatarRing_Flick() {
        let g = CAGradientLayer()
        g.colors = [
            ColorConfig_Flick.primaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.secondaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.primaryGradientEnd_Flick.cgColor
        ]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint   = CGPoint(x: 1, y: 1)
        avatarRingView_Flick.layer.addSublayer(g)
        avatarRingGradient_Flick = g

        let mask = CAShapeLayer()
        mask.fillRule = .evenOdd
        avatarRingView_Flick.layer.mask = mask
        avatarRingMask_Flick = mask
    }

    private func updateAvatarRing_Flick() {
        let b = avatarRingView_Flick.bounds
        guard b.width > 0 else { return }
        avatarRingGradient_Flick?.frame = b
        let outer = UIBezierPath(ovalIn: b)
        let inner = UIBezierPath(ovalIn: b.insetBy(dx: 4, dy: 4))
        outer.append(inner.reversing())
        avatarRingMask_Flick?.path = outer.cgPath
    }

    // MARK: - 表单区域

    private func setupFormSection_Flick() {
        contentContainer_Flick.addSubview(formCard_Flick)
        formCard_Flick.snp.makeConstraints { make in
            make.top.equalTo(avatarHintLabel_Flick.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(16)
        }

        // --- Name 字段 ---
        let nameSection = buildFormField_Flick(
            icon: "person.fill",
            iconColor: ColorConfig_Flick.primaryGradientStart_Flick,
            label: "Name",
            inputView: nameTextField_Flick,
            inputHeight: 40,
            activeLine: nameActiveLine_Flick,
            showDivider: true
        )
        formCard_Flick.addSubview(nameSection)
        nameSection.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        nameTextField_Flick.delegate = self

        // --- Bio 字段 ---
        let bioSection = buildFormField_Flick(
            icon: "text.alignleft",
            iconColor: UIColor(hexstring_Flick: "#90CDF4"),
            label: "Bio",
            inputView: bioTextView_Flick,
            inputHeight: 88,
            activeLine: bioActiveLine_Flick,
            showDivider: false
        )
        formCard_Flick.addSubview(bioSection)
        bioSection.snp.makeConstraints { make in
            make.top.equalTo(nameSection.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        // Bio 占位符
        bioTextView_Flick.addSubview(bioPlaceholder_Flick)
        bioPlaceholder_Flick.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        bioTextView_Flick.delegate = self

        // 字数计数（在表单卡片外右对齐）
        contentContainer_Flick.addSubview(bioCountLabel_Flick)
        bioCountLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(formCard_Flick.snp.bottom).offset(8)
            make.right.equalToSuperview().inset(20)
            make.height.equalTo(18)
        }
    }

    /// 构建表单字段行：图标 + 字段名 Label + 输入控件 + 激活线
    private func buildFormField_Flick(
        icon: String,
        iconColor: UIColor,
        label: String,
        inputView: UIView,
        inputHeight: CGFloat,
        activeLine: UIView,
        showDivider: Bool
    ) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let iconBg = UIView()
        iconBg.backgroundColor = iconColor.withValues(alpha: 0.12)
        iconBg.layer.cornerRadius = 11
        container.addSubview(iconBg)
        iconBg.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(16)
            make.width.height.equalTo(40)
        }

        let iconImg = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        iconImg.image = UIImage(systemName: icon, withConfiguration: cfg)
        iconImg.tintColor = iconColor
        iconImg.contentMode = .scaleAspectFit
        iconBg.addSubview(iconImg)
        iconImg.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(17)
        }

        let fieldLbl = UILabel()
        fieldLbl.text = label
        fieldLbl.font = .systemFont(ofSize: 11, weight: .semibold)
        fieldLbl.textColor = iconColor
        container.addSubview(fieldLbl)
        fieldLbl.snp.makeConstraints { make in
            make.left.equalTo(iconBg.snp.right).offset(14)
            make.top.equalToSuperview().inset(16)
        }

        container.addSubview(inputView)
        inputView.snp.makeConstraints { make in
            make.left.equalTo(iconBg.snp.right).offset(14)
            make.right.equalToSuperview().inset(16)
            make.top.equalTo(fieldLbl.snp.bottom).offset(6)
            make.height.greaterThanOrEqualTo(inputHeight)
            make.bottom.equalToSuperview().inset(16)
        }

        // 激活下划线（默认灰色，聚焦时变渐变色）
        container.addSubview(activeLine)
        activeLine.snp.makeConstraints { make in
            make.left.equalTo(iconBg.snp.right).offset(14)
            make.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
            make.height.equalTo(1.5)
        }

        if showDivider {
            let div = UIView()
            div.backgroundColor = ColorConfig_Flick.divider_Flick
            container.addSubview(div)
            div.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(16)
                make.right.equalToSuperview()
                make.bottom.equalTo(activeLine.snp.top).offset(-1)
                make.height.equalTo(0.5)
            }
        }

        return container
    }

    // MARK: - 激活线动画

    /// 输入框聚焦时将激活线切换为渐变色
    private func setActiveLine_Flick(_ line: UIView, active: Bool) {
        if active {
            line.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
            let g = UIColor.createPrimaryGradientLayer_Flick(frame_Flick: line.bounds)
            g.cornerRadius = 1
            line.layer.insertSublayer(g, at: 0)
        } else {
            line.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
            line.backgroundColor = ColorConfig_Flick.divider_Flick
        }
        UIView.animate(withDuration: 0.25) {
            line.transform = active ? CGAffineTransform(scaleX: 1, y: 1.5) : .identity
        }
    }

    // MARK: - 底部按钮区域

    private func setupActionButtons_Flick() {
        // 字数计数底部锚点已在 setupFormSection_Flick 设置，这里以 formCard 下方计算
        let btnStack = UIStackView(arrangedSubviews: [cancelBtn_Flick, saveBtn_Flick])
        btnStack.axis = .horizontal
        btnStack.spacing = 12
        btnStack.distribution = .fillEqually

        contentContainer_Flick.addSubview(btnStack)
        btnStack.snp.makeConstraints { make in
            make.top.equalTo(bioCountLabel_Flick.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(52)
            make.bottom.equalToSuperview().inset(52)
        }

        cancelBtn_Flick.addTarget(self, action: #selector(cancelTapped_Flick), for: .touchUpInside)
        saveBtn_Flick.addTarget(self, action: #selector(saveTapped_Flick), for: .touchUpInside)
    }

    private func updateSaveGradient_Flick() {
        guard saveBtn_Flick.bounds.width > 0 else { return }
        saveBtnGradient_Flick?.removeFromSuperlayer()
        let g = UIColor.createPrimaryGradientLayer_Flick(frame_Flick: saveBtn_Flick.bounds)
        g.cornerRadius = 20
        saveBtn_Flick.layer.insertSublayer(g, at: 0)
        saveBtnGradient_Flick = g
    }

    // MARK: - 数据加载

    private func loadCurrentUserData_Flick() {
        let user = UserViewModel_Flick.shared_Flick.getCurrentUser_Flick()

        originalName_Flick = user.userName_Flick ?? ""
        originalBio_Flick  = user.userIntroduce_Flick ?? ""
        originalHead_Flick = user.userHead_Flick

        nameTextField_Flick.text = originalName_Flick

        let bio = originalBio_Flick
        bioTextView_Flick.text = bio
        bioPlaceholder_Flick.isHidden = !bio.isEmpty
        updateBioCount_Flick(count: bio.count)
    }

    // MARK: - Bio 字数更新

    private func updateBioCount_Flick(count: Int) {
        bioCountLabel_Flick.text = "\(count) / \(maxBioLength_Flick)"
        let ratio = CGFloat(count) / CGFloat(maxBioLength_Flick)
        if ratio > 0.9 {
            bioCountLabel_Flick.textColor = UIColor(hexstring_Flick: "#FC8181")
        } else if ratio > 0.7 {
            bioCountLabel_Flick.textColor = UIColor(hexstring_Flick: "#F6AD55")
        } else {
            bioCountLabel_Flick.textColor = ColorConfig_Flick.textSecondary_Flick
        }
    }

    // MARK: - 相册选取头像

    private func openPhotoPicker_Flick() {
        MediaPickerHelper_Flick.pickImage_Flick(from: self) { [weak self] image in
            guard let self, let image else { return }
            self.selectedAvatarImage_Flick = image
            self.avatarView_Flick.imageView_Flick.image = image
            self.avatarView_Flick.imageView_Flick.contentMode = .scaleAspectFill
            // 头像更换时给头像环一个缩放脉冲动画
            self.avatarRingView_Flick.animatePressDown_Flick { [weak self] in
                self?.avatarRingView_Flick.animatePressUp_Flick()
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    private func saveImageToDocuments_Flick(_ image: UIImage) -> String? {
        let fileName = "avatar_\(Int(Date().timeIntervalSince1970)).jpg"
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let fileURL = docDir?.appendingPathComponent(fileName),
              let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("头像保存失败：\(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - 保存操作

    @objc private func cancelTapped_Flick() {
        cancelBtn_Flick.animatePressDown_Flick { [weak self] in self?.cancelBtn_Flick.animatePressUp_Flick() }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Flick.pop_Flick(from: self)
    }

    @objc private func saveTapped_Flick() {
        saveBtn_Flick.animatePressDown_Flick { [weak self] in self?.saveBtn_Flick.animatePressUp_Flick() }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        guard UserViewModel_Flick.shared_Flick.isLoggedIn_Flick else {
            Navigation_Flick.toLogin_Flick(style_flick: .present_flick)
            return
        }

        let newName = nameTextField_Flick.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let newBio  = bioTextView_Flick.text.trimmingCharacters(in: .whitespaces)

        let nameChanged   = newName != originalName_Flick && !newName.isEmpty
        let bioChanged    = newBio  != originalBio_Flick
        let avatarChanged = selectedAvatarImage_Flick != nil

        guard nameChanged || bioChanged || avatarChanged else {
            Utils_Flick.showInfo_Flick(message_Flick: "No changes to save")
            return
        }

        if newName.isEmpty {
            Utils_Flick.showWarning_Flick(message_Flick: "Name cannot be empty")
            nameTextField_Flick.animateShake_Flick()
            return
        }

        if let image = selectedAvatarImage_Flick, let path = saveImageToDocuments_Flick(image) {
            UserViewModel_Flick.shared_Flick.updateHead_Flick(headUrl_flick: path)
        }
        if nameChanged { UserViewModel_Flick.shared_Flick.updateName_Flick(userName_flick: newName) }
        if bioChanged  { UserViewModel_Flick.shared_Flick.updateIntroduce_Flick(introduce_flick: newBio) }

        originalName_Flick = newName
        originalBio_Flick  = newBio
        selectedAvatarImage_Flick = nil

        Task {
            try? await Task.sleep(nanoseconds: 700_000_000)
            Navigation_Flick.pop_Flick(from: self)
        }
    }

    // MARK: - 键盘处理

    private func setupKeyboardObserver_Flick() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow_Flick(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide_Flick),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func keyboardWillShow_Flick(_ notification: Notification) {
        guard let frame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        scrollView_Flick.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height + 16, right: 0)
    }

    @objc private func keyboardWillHide_Flick() {
        scrollView_Flick.contentInset = .zero
        scrollView_Flick.scrollIndicatorInsets = .zero
    }
}

// MARK: - UITextFieldDelegate

extension EditInfo_Flick: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        setActiveLine_Flick(nameActiveLine_Flick, active: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        setActiveLine_Flick(nameActiveLine_Flick, active: false)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        bioTextView_Flick.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension EditInfo_Flick: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        setActiveLine_Flick(bioActiveLine_Flick, active: true)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        setActiveLine_Flick(bioActiveLine_Flick, active: false)
    }

    func textViewDidChange(_ textView: UITextView) {
        bioPlaceholder_Flick.isHidden = !textView.text.isEmpty
        updateBioCount_Flick(count: textView.text.count)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        let currentText = textView.text ?? ""
        guard let r = Range(range, in: currentText) else { return true }
        return currentText.replacingCharacters(in: r, with: text).count <= maxBioLength_Flick
    }
}
