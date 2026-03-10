import Foundation
import UIKit
import SnapKit

// MARK: - 修改个人资料页面

/// 修改个人资料页面
/// 核心作用：允许登录用户修改头像（从相册选取）、用户名、个人简介，并提交保存
/// 设计思路：渐变头部（含副标题）+ 浮岛卡片区域 + 带相机蒙层的头像 + 图标输入框 + 渐变保存按钮
/// 关键方法：
///   - prefillUserData_Trace()：用当前登录用户数据预填表单
///   - handleSave_Trace()：校验登录状态并提交修改到 UserViewModel
///   - handleAvatarTap_Trace()：唤起相册选择头像
class EditInfo_Trace: UIViewController {

    // MARK: - 状态属性

    /// 用户从相册选取的新头像（nil 表示未修改）
    private var selectedAvatarImage_Trace: UIImage?

    /// 原始用户名（用于判断是否有改动）
    private var originalName_Trace: String = ""

    /// 原始简介（用于判断是否有改动）
    private var originalBio_Trace: String = ""

    // MARK: - UI 组件

    private let scrollView_Trace: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        sv.contentInsetAdjustmentBehavior = .never
        sv.keyboardDismissMode = .interactive
        return sv
    }()

    private let contentView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        return v
    }()

    // MARK: 渐变头部

    private let headerView_Trace: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    private let headerGradientLayer_Trace = CAGradientLayer()

    /// 头部装饰圆
    private let headerDecorCircle_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.layer.cornerRadius = 75
        return v
    }()

    private let headerDecorCircle2_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 50
        return v
    }()

    private let backButton_Trace = BackButton_Trace()

    private let titleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "Edit Profile"
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = .white
        return lbl
    }()

    private let subtitleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "Shape your identity"
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.75)
        return lbl
    }()

    // MARK: 浮岛内容区

    private let contentIslandView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: -4)
        v.layer.shadowRadius = 16
        v.layer.shadowOpacity = 0.05
        v.layer.masksToBounds = false
        return v
    }()

    // MARK: 头像区域卡片

    private let avatarCardView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 22
        v.layer.shadowColor = UIColor(hexstring_Trace: "#B794F6").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 16
        v.layer.shadowOpacity = 0.1
        v.layer.masksToBounds = false
        return v
    }()

    /// 头像渐变外环
    private let avatarRingView_Trace: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 54
        v.layer.masksToBounds = true
        return v
    }()

    private let avatarRingGradientLayer_Trace = CAGradientLayer()

    /// 头像白色内边框
    private let avatarBorderView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 51
        return v
    }()

    /// 头像视图
    private let avatarView_Trace: CurrentUserAvatarView_Trace = {
        let v = CurrentUserAvatarView_Trace()
        v.showEditButton_Trace = false
        return v
    }()

    /// 相机蒙层（半透明遮罩 + 相机图标）
    private let cameraOverlayView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.38)
        v.layer.cornerRadius = 48
        v.layer.masksToBounds = true
        v.isUserInteractionEnabled = false
        return v
    }()

    private let cameraIconView_Trace: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        iv.image = UIImage(systemName: "camera.fill", withConfiguration: cfg)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let cameraLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "Change"
        lbl.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()

    /// 头像区点击容器（整体可点击）
    private let avatarTapContainer_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.isUserInteractionEnabled = true
        return v
    }()

    // MARK: 表单卡片

    private let formCardView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 22
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 14
        v.layer.shadowOpacity = 0.06
        v.layer.masksToBounds = false
        return v
    }()

    // MARK: Username 区域

    private let nameSectionView_Trace: UIView = buildAccentRow_Trace(
        text: "Username",
        iconName: "person.fill",
        gradientStart: "#B794F6",
        gradientEnd: "#90CDF4"
    )

    private let nameTextField_Trace: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        tf.textColor = ColorConfig_Trace.textPrimary_Trace
        tf.placeholder = "Your name"
        tf.returnKeyType = .next
        tf.clearButtonMode = .whileEditing
        tf.backgroundColor = UIColor(hexstring_Trace: "#F8F5FF")
        tf.layer.cornerRadius = 13
        tf.layer.masksToBounds = true
        tf.layer.borderColor = UIColor(hexstring_Trace: "#B794F6").withAlphaComponent(0.2).cgColor
        tf.layer.borderWidth = 1
        // 左侧图标内边距
        let leftPad = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        tf.leftView = leftPad
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        tf.rightViewMode = .always
        return tf
    }()

    private let nameDivider_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Trace.divider_Trace
        return v
    }()

    // MARK: Bio 区域

    private let bioSectionView_Trace: UIView = buildAccentRow_Trace(
        text: "Bio",
        iconName: "text.alignleft",
        gradientStart: "#FBB6CE",
        gradientEnd: "#FED7AA"
    )

    private let bioTextView_Trace: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tv.textColor = ColorConfig_Trace.textPrimary_Trace
        tv.backgroundColor = UIColor(hexstring_Trace: "#FFF8F8")
        tv.layer.cornerRadius = 13
        tv.layer.masksToBounds = true
        tv.layer.borderColor = UIColor(hexstring_Trace: "#FBB6CE").withAlphaComponent(0.3).cgColor
        tv.layer.borderWidth = 1
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        tv.returnKeyType = .done
        return tv
    }()

    private let bioPlaceholderLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "Tell us something about yourself..."
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lbl.textColor = ColorConfig_Trace.textPlaceholder_Trace
        lbl.numberOfLines = 0
        return lbl
    }()

    private let bioCharCountLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = ColorConfig_Trace.textPlaceholder_Trace
        lbl.textAlignment = .right
        lbl.text = "0 / 80"
        return lbl
    }()

    // MARK: 保存按钮

    private let saveButton_Trace: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 24
        btn.layer.masksToBounds = true
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        btn.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.setTitle("  Save Changes", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return btn
    }()

    private let saveGradientLayer_Trace = CAGradientLayer()

    // MARK: - 辅助：分区行构造

    /// 构建带渐变色图标的分区标题行
    /// - Parameters:
    ///   - text: 标题文字
    ///   - iconName: SF Symbol 名称
    ///   - gradientStart: 渐变起始色十六进制
    ///   - gradientEnd: 渐变结束色十六进制
    /// - Returns: 组合视图（图标 + 文字）
    private static func buildAccentRow_Trace(
        text: String,
        iconName: String,
        gradientStart: String,
        gradientEnd: String
    ) -> UIView {
        let container = UIView()

        let iconBg = UIView()
        iconBg.layer.cornerRadius = 8
        iconBg.layer.masksToBounds = true

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(hexstring_Trace: gradientStart).cgColor,
            UIColor(hexstring_Trace: gradientEnd).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 8
        iconBg.layer.addSublayer(gradientLayer)

        let cfg = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        let iconView = UIImageView(image: UIImage(systemName: iconName, withConfiguration: cfg))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textColor = ColorConfig_Trace.textSecondary_Trace

        container.addSubview(iconBg)
        iconBg.addSubview(iconView)
        container.addSubview(label)

        iconBg.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(12)
        }

        label.snp.makeConstraints { make in
            make.leading.equalTo(iconBg.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        // 修正 gradientLayer 尺寸（在 layoutSubviews 中调用可能更精确，此处近似）
        iconBg.layoutIfNeeded()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 24, height: 24)

        return container
    }

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Trace()
        bindActions_Trace()
        registerKeyboardNotifications_Trace()
        prefillUserData_Trace()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer_Trace.frame = headerView_Trace.bounds
        avatarRingGradientLayer_Trace.frame = avatarRingView_Trace.bounds
        saveGradientLayer_Trace.frame = saveButton_Trace.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Trace() {
        view.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace

        // 头部渐变（薰衣草紫 → 橙粉）
        headerGradientLayer_Trace.colors = [
            UIColor(hexstring_Trace: "#B794F6").cgColor,
            UIColor(hexstring_Trace: "#FDA085").cgColor
        ]
        headerGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        headerGradientLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
        headerView_Trace.layer.insertSublayer(headerGradientLayer_Trace, at: 0)

        // 头像外环渐变
        avatarRingGradientLayer_Trace.colors = [
            UIColor(hexstring_Trace: "#FDA085").cgColor,
            UIColor(hexstring_Trace: "#B794F6").cgColor,
            UIColor(hexstring_Trace: "#90CDF4").cgColor
        ]
        avatarRingGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        avatarRingGradientLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
        avatarRingGradientLayer_Trace.cornerRadius = 54
        avatarRingView_Trace.layer.insertSublayer(avatarRingGradientLayer_Trace, at: 0)

        // 保存按钮渐变
        saveGradientLayer_Trace.colors = [
            UIColor(hexstring_Trace: "#B794F6").cgColor,
            UIColor(hexstring_Trace: "#FDA085").cgColor
        ]
        saveGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0.5)
        saveGradientLayer_Trace.endPoint = CGPoint(x: 1, y: 0.5)
        saveGradientLayer_Trace.cornerRadius = 24
        saveButton_Trace.layer.insertSublayer(saveGradientLayer_Trace, at: 0)

        // 层级组装
        view.addSubview(scrollView_Trace)
        scrollView_Trace.addSubview(contentView_Trace)

        contentView_Trace.addSubview(headerView_Trace)
        headerView_Trace.addSubview(headerDecorCircle_Trace)
        headerView_Trace.addSubview(headerDecorCircle2_Trace)
        headerView_Trace.addSubview(backButton_Trace)
        headerView_Trace.addSubview(titleLabel_Trace)
        headerView_Trace.addSubview(subtitleLabel_Trace)

        // 浮岛
        contentView_Trace.addSubview(contentIslandView_Trace)

        // 头像卡片
        contentIslandView_Trace.addSubview(avatarCardView_Trace)
        avatarCardView_Trace.addSubview(avatarTapContainer_Trace)
        avatarTapContainer_Trace.addSubview(avatarRingView_Trace)
        avatarRingView_Trace.addSubview(avatarBorderView_Trace)
        avatarBorderView_Trace.addSubview(avatarView_Trace)
        avatarBorderView_Trace.addSubview(cameraOverlayView_Trace)
        cameraOverlayView_Trace.addSubview(cameraIconView_Trace)
        cameraOverlayView_Trace.addSubview(cameraLabel_Trace)

        // 表单卡片
        contentIslandView_Trace.addSubview(formCardView_Trace)
        formCardView_Trace.addSubview(nameSectionView_Trace)
        formCardView_Trace.addSubview(nameTextField_Trace)
        formCardView_Trace.addSubview(nameDivider_Trace)
        formCardView_Trace.addSubview(bioSectionView_Trace)
        formCardView_Trace.addSubview(bioTextView_Trace)
        bioTextView_Trace.addSubview(bioPlaceholderLabel_Trace)
        formCardView_Trace.addSubview(bioCharCountLabel_Trace)

        contentIslandView_Trace.addSubview(saveButton_Trace)

        buildConstraints_Trace()
    }

    private func buildConstraints_Trace() {
        scrollView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        // 头部底边 = 安全区顶部 + 110pt，覆盖安全区高度差异，确保副标题不被浮岛遮盖
        headerView_Trace.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(110)
        }

        headerDecorCircle_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-40)
            make.trailing.equalToSuperview().offset(40)
            make.width.height.equalTo(150)
        }

        headerDecorCircle2_Trace.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(30)
            make.leading.equalToSuperview().offset(-30)
            make.width.height.equalTo(100)
        }

        backButton_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(6)
            make.width.height.equalTo(44)
        }

        titleLabel_Trace.snp.makeConstraints { make in
            make.leading.equalTo(backButton_Trace.snp.trailing).offset(10)
            make.centerY.equalTo(backButton_Trace)
        }

        subtitleLabel_Trace.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel_Trace)
            make.top.equalTo(titleLabel_Trace.snp.bottom).offset(3)
        }

        // 浮岛
        contentIslandView_Trace.snp.makeConstraints { make in
            make.top.equalTo(headerView_Trace.snp.bottom).offset(-24)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        // 头像卡片
        avatarCardView_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        avatarTapContainer_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(108)
            make.bottom.equalToSuperview().offset(-24)
        }

        // 头像外环 → 白边框 → 头像 + 相机蒙层
        avatarRingView_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(108)
        }

        avatarBorderView_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(102)
        }

        avatarView_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(96)
        }

        cameraOverlayView_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(96)
        }

        cameraIconView_Trace.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-6)
            make.width.height.equalTo(24)
        }

        cameraLabel_Trace.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(cameraIconView_Trace.snp.bottom).offset(2)
        }

        // 表单卡片
        formCardView_Trace.snp.makeConstraints { make in
            make.top.equalTo(avatarCardView_Trace.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        nameSectionView_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(18)
            make.height.equalTo(28)
        }

        nameTextField_Trace.snp.makeConstraints { make in
            make.top.equalTo(nameSectionView_Trace.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }

        nameDivider_Trace.snp.makeConstraints { make in
            make.top.equalTo(nameTextField_Trace.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(0.5)
        }

        bioSectionView_Trace.snp.makeConstraints { make in
            make.top.equalTo(nameDivider_Trace.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(18)
            make.height.equalTo(28)
        }

        bioTextView_Trace.snp.makeConstraints { make in
            make.top.equalTo(bioSectionView_Trace.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(110)
        }

        bioPlaceholderLabel_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
        }

        bioCharCountLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(bioTextView_Trace.snp.bottom).offset(6)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }

        // 保存按钮
        saveButton_Trace.snp.makeConstraints { make in
            make.top.equalTo(formCardView_Trace.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(58)
            make.bottom.equalToSuperview().offset(-40)
        }
    }

    // MARK: - 数据预填

    private func prefillUserData_Trace() {
        let user_trace = UserViewModel_Trace.shared_Trace.getCurrentUser_Trace()

        let name_trace = user_trace.userName_Trace ?? ""
        nameTextField_Trace.text = name_trace
        originalName_Trace = name_trace

        let bio_trace = user_trace.userIntroduce_Trace ?? ""
        if bio_trace.isEmpty {
            bioTextView_Trace.text = ""
            bioPlaceholderLabel_Trace.isHidden = false
        } else {
            bioTextView_Trace.text = bio_trace
            bioPlaceholderLabel_Trace.isHidden = true
            bioCharCountLabel_Trace.text = "\(bio_trace.count) / 80"
        }
        originalBio_Trace = bio_trace

        if let userId_trace = user_trace.userId_Trace {
            avatarView_Trace.configure_Trace(userId_Trace: userId_trace)
        }
    }

    // MARK: - 事件绑定

    private func bindActions_Trace() {
        backButton_Trace.onTapped_Trace = {
            Navigation_Trace.pop_Trace()
        }

        // CurrentUserAvatarView_Trace 内部 imageView 持有 tap 手势，通过 onTapped_Trace 回调触发相册选取
        avatarView_Trace.onTapped_Trace = { [weak self] in
            self?.handleAvatarTap_Trace()
        }
        // 容器额外补充 tap，覆盖点击头像外环区域时也可响应
        let tapGesture_trace = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap_Trace))
        avatarTapContainer_Trace.addGestureRecognizer(tapGesture_trace)

        nameTextField_Trace.delegate = self
        bioTextView_Trace.delegate = self

        saveButton_Trace.addTarget(self, action: #selector(handleSave_Trace), for: .touchUpInside)
    }

    // MARK: - 头像选取

    /// 唤起相册图片选择器
    @objc private func handleAvatarTap_Trace() {
        // 点击动效
        UIView.animate(withDuration: 0.1, animations: {
            self.avatarTapContainer_Trace.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
        }, completion: { _ in
            UIView.animate(withDuration: 0.18, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: []) {
                self.avatarTapContainer_Trace.transform = .identity
            }
        })
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        MediaPickerHelper_Trace.pickImage_Trace(from: self) { [weak self] image_trace in
            guard let self = self, let image_trace = image_trace else { return }
            self.selectedAvatarImage_Trace = image_trace
            self.avatarView_Trace.imageView_Trace.image = image_trace
            self.avatarView_Trace.imageView_Trace.contentMode = .scaleAspectFill
        }
    }

    // MARK: - 保存逻辑

    @objc private func handleSave_Trace() {
        saveButton_Trace.animatePressDown_Trace {
            self.saveButton_Trace.animatePressUp_Trace()
        }

        guard UserViewModel_Trace.shared_Trace.isLoggedIn_Trace else {
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000)
                Navigation_Trace.toLogin_Trace(style_trace: .present_trace)
            }
            return
        }

        view.endEditing(true)

        let newName_trace = nameTextField_Trace.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let newBio_trace = bioTextView_Trace.text?.trimmingCharacters(in: .whitespaces) ?? ""

        guard !newName_trace.isEmpty else {
            Utils_Trace.showWarning_Trace(message_Trace: "Username cannot be empty.")
            nameTextField_Trace.animateShake_Trace()
            return
        }

        let nameChanged_trace = newName_trace != originalName_Trace
        let bioChanged_trace = newBio_trace != originalBio_Trace
        let avatarChanged_trace = selectedAvatarImage_Trace != nil

        guard nameChanged_trace || bioChanged_trace || avatarChanged_trace else {
            Utils_Trace.showInfo_Trace(message_Trace: "Nothing has changed.")
            return
        }

        UserViewModel_Trace.shared_Trace.updateProfile_Trace(
            userName_trace: nameChanged_trace ? newName_trace : nil,
            introduce_trace: bioChanged_trace ? newBio_trace : nil,
            headImage_trace: avatarChanged_trace ? selectedAvatarImage_Trace : nil
        )

        Navigation_Trace.pop_Trace()
    }

    // MARK: - 键盘处理

    private func registerKeyboardNotifications_Trace() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillShow_Trace(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide_Trace),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func handleKeyboardWillShow_Trace(_ notification: Notification) {
        guard let keyboardFrame_trace = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        scrollView_Trace.contentInset.bottom = keyboardFrame_trace.height + 20
        scrollView_Trace.scrollIndicatorInsets.bottom = keyboardFrame_trace.height
    }

    @objc private func handleKeyboardWillHide_Trace() {
        scrollView_Trace.contentInset.bottom = 0
        scrollView_Trace.scrollIndicatorInsets.bottom = 0
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextFieldDelegate

extension EditInfo_Trace: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        bioTextView_Trace.becomeFirstResponder()
        return true
    }

    /// 输入框获焦时高亮边框
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderColor = UIColor(hexstring_Trace: "#B794F6").withAlphaComponent(0.6).cgColor
            textField.layer.borderWidth = 1.5
        }
    }

    /// 输入框失焦时还原边框
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderColor = UIColor(hexstring_Trace: "#B794F6").withAlphaComponent(0.2).cgColor
            textField.layer.borderWidth = 1
        }
    }
}

// MARK: - UITextViewDelegate

extension EditInfo_Trace: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.2) {
            textView.layer.borderColor = UIColor(hexstring_Trace: "#FBB6CE").withAlphaComponent(0.6).cgColor
            textView.layer.borderWidth = 1.5
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.2) {
            textView.layer.borderColor = UIColor(hexstring_Trace: "#FBB6CE").withAlphaComponent(0.3).cgColor
            textView.layer.borderWidth = 1
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        bioPlaceholderLabel_Trace.isHidden = !textView.text.isEmpty

        let count_trace = textView.text.count
        bioCharCountLabel_Trace.text = "\(count_trace) / 80"
        bioCharCountLabel_Trace.textColor = count_trace > 80
            ? UIColor(hexstring_Trace: "#FC8181")
            : ColorConfig_Trace.textPlaceholder_Trace

        if count_trace > 80 {
            textView.text = String(textView.text.prefix(80))
            bioCharCountLabel_Trace.text = "80 / 80"
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
