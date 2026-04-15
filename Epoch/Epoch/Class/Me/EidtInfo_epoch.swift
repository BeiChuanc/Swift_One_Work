import Foundation
import UIKit
import SnapKit

// MARK: 修改用户信息页面

/// 修改用户信息页面
/// 核心作用：支持当前用户编辑头像、用户名和个人简介
/// 设计思路：顶部横幅头像区（渐变环）+ 字段分组卡（图标 + 标题 + 输入 + 字数统计）+ 确认按钮，整体可滚动
class EditInfo_Epoch: UIViewController {

    // MARK: - 滚动与容器

    private let backgroundDecorationView_Epoch = PageDecorationView_Epoch()

    private let scrollView_Epoch: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentView_Epoch = UIView()

    // MARK: - 头像横幅区

    /// 头像横幅卡片
    private let avatarBannerView_Epoch: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()

    private var bannerGradientLayer_Epoch: CAGradientLayer?

    /// 右上装饰光斑
    private let bannerGlowTop_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Epoch.secondaryGradientStart_Epoch.withAlphaComponent(0.28)
        v.layer.cornerRadius = 64
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 左下装饰光斑
    private let bannerGlowBottom_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Epoch.primaryGradientEnd_Epoch.withAlphaComponent(0.20)
        v.layer.cornerRadius = 56
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 头像渐变环
    private let avatarRingView_Epoch: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    private var avatarRingGradientLayer_Epoch: CAGradientLayer?

    /// 头像间隔层
    private let avatarSepView_Epoch: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    /// 头像视图
    private let avatarView_Epoch = UserAvatarView_Epoch()

    /// 相机覆盖图标
    private let cameraOverlayView_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Epoch.accentPurple_Epoch
        v.layer.cornerRadius = 14
        return v
    }()

    private let cameraIconView_Epoch: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "camera.fill"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 选取头像按钮（点击整个头像区域）
    private let pickAvatarButton_Epoch: UIButton = {
        let btn = UIButton(type: .system)
        return btn
    }()

    /// 头像区副标题
    private let avatarHintLabel_Epoch: UILabel = {
        let l = UILabel()
        l.text = "Tap to change avatar"
        l.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        l.textColor = ColorConfig_Epoch.textSecondary_Epoch
        l.textAlignment = .center
        return l
    }()

    // MARK: - 用户名字段

    private let nameSectionHeaderView_Epoch = EditInfoSectionHeaderView_Epoch()

    private let nameCardView_Epoch = SurfaceCardView_Epoch()

    private let nameTextField_Epoch: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tf.textColor = ColorConfig_Epoch.textPrimary_Epoch
        tf.backgroundColor = .clear
        tf.clearButtonMode = .whileEditing
        return tf
    }()

    private let nameDividerView_Epoch = UIView()
    private var nameDividerGradientLayer_Epoch: CAGradientLayer?

    private let nameCharCountLabel_Epoch: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        l.textColor = ColorConfig_Epoch.textPlaceholder_Epoch
        l.textAlignment = .right
        l.text = "0 / 30"
        return l
    }()

    // MARK: - 简介字段

    private let introSectionHeaderView_Epoch = EditInfoSectionHeaderView_Epoch()

    private let introCardView_Epoch = SurfaceCardView_Epoch()

    private let introTextView_Epoch: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        tv.textColor = ColorConfig_Epoch.textPrimary_Epoch
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 40, right: 12)
        return tv
    }()

    private let introPlaceholderLabel_Epoch: UILabel = {
        let l = UILabel()
        l.text = "Bio"
        l.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        l.textColor = ColorConfig_Epoch.textPlaceholder_Epoch
        return l
    }()

    private let introCharCountLabel_Epoch: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        l.textColor = ColorConfig_Epoch.textPlaceholder_Epoch
        l.textAlignment = .right
        l.text = "0 / 120"
        return l
    }()

    // MARK: - 确认按钮

    private let confirmButton_Epoch = PrimaryActionButton_Epoch(title_Epoch: "Save changes")

    // MARK: - 数据

    private var selectedImage_Epoch: UIImage?
    private var selectedAvatarPath_Epoch: String?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        fillCurrentData_Epoch()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Epoch()
        fillCurrentData_Epoch()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bannerGradientLayer_Epoch?.frame = avatarBannerView_Epoch.bounds
        avatarRingGradientLayer_Epoch?.frame = avatarRingView_Epoch.bounds
        avatarRingView_Epoch.layer.cornerRadius = avatarRingView_Epoch.bounds.width / 2
        avatarSepView_Epoch.layer.cornerRadius = avatarSepView_Epoch.bounds.width / 2
        nameDividerGradientLayer_Epoch?.frame = nameDividerView_Epoch.bounds
    }

    // MARK: - 界面搭建

    private func setupUI_Epoch() {
        title = "Edit profile"
        view.backgroundColor = ColorConfig_Epoch.backgroundPrimary_Epoch

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Epoch)
        )
        navigationItem.leftBarButtonItem?.tintColor = ColorConfig_Epoch.textPrimary_Epoch

        view.addSubview(backgroundDecorationView_Epoch)
        view.addSubview(scrollView_Epoch)
        scrollView_Epoch.addSubview(contentView_Epoch)

        backgroundDecorationView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView_Epoch.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView_Epoch.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Epoch.contentLayoutGuide)
            make.width.equalTo(scrollView_Epoch.frameLayoutGuide)
        }

        setupAvatarBanner_Epoch()
        setupNameSection_Epoch()
        setupIntroSection_Epoch()
        setupConfirmButton_Epoch()

        introTextView_Epoch.delegate = self
        nameTextField_Epoch.addTarget(self, action: #selector(nameTextChanged_Epoch), for: .editingChanged)
    }

    /// 搭建头像横幅
    private func setupAvatarBanner_Epoch() {
        // 横幅渐变
        let bannerGrad_epoch = CAGradientLayer()
        bannerGrad_epoch.colors = [
            UIColor(hexstring_Epoch: "#F0EAFF").cgColor,
            UIColor(hexstring_Epoch: "#FFF0F8").cgColor,
            UIColor(hexstring_Epoch: "#FAFAFA").cgColor
        ]
        bannerGrad_epoch.startPoint = CGPoint(x: 0, y: 0)
        bannerGrad_epoch.endPoint = CGPoint(x: 1, y: 1)
        avatarBannerView_Epoch.layer.insertSublayer(bannerGrad_epoch, at: 0)
        bannerGradientLayer_Epoch = bannerGrad_epoch

        // 头像渐变环
        let ringGrad_epoch = CAGradientLayer()
        ringGrad_epoch.colors = [
            ColorConfig_Epoch.primaryGradientStart_Epoch.cgColor,
            ColorConfig_Epoch.accentPink_Epoch.cgColor,
            ColorConfig_Epoch.primaryGradientEnd_Epoch.cgColor
        ]
        ringGrad_epoch.startPoint = CGPoint(x: 0, y: 0)
        ringGrad_epoch.endPoint = CGPoint(x: 1, y: 1)
        avatarRingView_Epoch.layer.insertSublayer(ringGrad_epoch, at: 0)
        avatarRingGradientLayer_Epoch = ringGrad_epoch

        avatarSepView_Epoch.backgroundColor = UIColor(hexstring_Epoch: "#F0EAFF")

        contentView_Epoch.addSubview(avatarBannerView_Epoch)
        avatarBannerView_Epoch.addSubview(bannerGlowTop_Epoch)
        avatarBannerView_Epoch.addSubview(bannerGlowBottom_Epoch)
        avatarBannerView_Epoch.addSubview(avatarRingView_Epoch)
        avatarRingView_Epoch.addSubview(avatarSepView_Epoch)
        avatarSepView_Epoch.addSubview(avatarView_Epoch)
        avatarBannerView_Epoch.addSubview(cameraOverlayView_Epoch)
        cameraOverlayView_Epoch.addSubview(cameraIconView_Epoch)
        avatarBannerView_Epoch.addSubview(avatarHintLabel_Epoch)
        avatarBannerView_Epoch.addSubview(pickAvatarButton_Epoch)

        pickAvatarButton_Epoch.addTarget(self, action: #selector(pickAvatarTapped_Epoch), for: .touchUpInside)

        avatarBannerView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.right.equalToSuperview().inset(20)
        }

        bannerGlowTop_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-30)
            make.right.equalToSuperview().offset(30)
            make.width.height.equalTo(128)
        }

        bannerGlowBottom_Epoch.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(-30)
            make.width.height.equalTo(112)
        }

        avatarRingView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(104)
        }

        avatarSepView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(96)
        }

        avatarView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(88)
        }

        cameraOverlayView_Epoch.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(avatarRingView_Epoch).inset(2)
            make.width.height.equalTo(28)
        }

        cameraIconView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(14)
        }

        avatarHintLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView_Epoch.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-22)
        }

        pickAvatarButton_Epoch.snp.makeConstraints { make in
            make.edges.equalTo(avatarRingView_Epoch)
        }
    }

    /// 搭建用户名字段
    private func setupNameSection_Epoch() {
        nameSectionHeaderView_Epoch.configure_Epoch(
            iconName_Epoch: "person.fill",
            title_Epoch: "Username"
        )
        contentView_Epoch.addSubview(nameSectionHeaderView_Epoch)
        contentView_Epoch.addSubview(nameCardView_Epoch)

        nameCardView_Epoch.addSubview(nameTextField_Epoch)
        nameCardView_Epoch.addSubview(nameDividerView_Epoch)
        nameCardView_Epoch.addSubview(nameCharCountLabel_Epoch)

        let divGrad_epoch = UIColor.createPrimaryGradientLayer_Epoch(frame_Epoch: .zero)
        nameDividerView_Epoch.layer.addSublayer(divGrad_epoch)
        nameDividerGradientLayer_Epoch = divGrad_epoch

        nameSectionHeaderView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(avatarBannerView_Epoch.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
        }

        nameCardView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(nameSectionHeaderView_Epoch.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(78)
        }

        nameTextField_Epoch.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(UIEdgeInsets(top: 18, left: 16, bottom: 0, right: 16))
        }

        nameDividerView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(nameTextField_Epoch.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(2)
        }

        nameCharCountLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(nameDividerView_Epoch.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-16)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }
    }

    /// 搭建简介字段
    private func setupIntroSection_Epoch() {
        introSectionHeaderView_Epoch.configure_Epoch(
            iconName_Epoch: "text.alignleft",
            title_Epoch: "Bio"
        )
        contentView_Epoch.addSubview(introSectionHeaderView_Epoch)
        contentView_Epoch.addSubview(introCardView_Epoch)

        introCardView_Epoch.addSubview(introTextView_Epoch)
        introCardView_Epoch.addSubview(introPlaceholderLabel_Epoch)
        introCardView_Epoch.addSubview(introCharCountLabel_Epoch)

        introSectionHeaderView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(nameCardView_Epoch.snp.bottom).offset(22)
            make.left.right.equalToSuperview().inset(20)
        }

        introCardView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(introSectionHeaderView_Epoch.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(180)
        }

        introTextView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        introPlaceholderLabel_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(18)
        }

        introCharCountLabel_Epoch.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().inset(12)
        }
    }

    /// 搭建确认按钮
    private func setupConfirmButton_Epoch() {
        contentView_Epoch.addSubview(confirmButton_Epoch)
        confirmButton_Epoch.addTarget(self, action: #selector(confirmTapped_Epoch), for: .touchUpInside)

        confirmButton_Epoch.snp.makeConstraints { make in
            make.top.equalTo(introCardView_Epoch.snp.bottom).offset(28)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-100)
        }
    }

    // MARK: - 数据填充

    /// 填充当前用户数据到表单
    private func fillCurrentData_Epoch() {
        let user_epoch = UserViewModel_Epoch.shared_Epoch.getCurrentUser_Epoch()
        nameTextField_Epoch.text = user_epoch.userName_Epoch
        introTextView_Epoch.text = user_epoch.userIntroduce_Epoch
        introPlaceholderLabel_Epoch.isHidden = !(user_epoch.userIntroduce_Epoch?.isEmpty ?? true)
        if let userId_epoch = user_epoch.userId_Epoch {
            avatarView_Epoch.configure_Epoch(userId_Epoch: userId_epoch)
        }
        refreshCharCount_Epoch()
    }

    /// 刷新字数统计
    private func refreshCharCount_Epoch() {
        let nameLen_epoch = nameTextField_Epoch.text?.count ?? 0
        let introLen_epoch = introTextView_Epoch.text.count
        nameCharCountLabel_Epoch.text = "\(nameLen_epoch) / 30"
        introCharCountLabel_Epoch.text = "\(introLen_epoch) / 120"
        nameCharCountLabel_Epoch.textColor = nameLen_epoch > 30
            ? ColorConfig_Epoch.accentPink_Epoch
            : ColorConfig_Epoch.textPlaceholder_Epoch
        introCharCountLabel_Epoch.textColor = introLen_epoch > 120
            ? ColorConfig_Epoch.accentPink_Epoch
            : ColorConfig_Epoch.textPlaceholder_Epoch
    }

    /// 保存头像图片到本地
    /// - Parameter image_Epoch: 头像图片
    /// - Returns: 本地存储路径
    private func storeAvatarImage_Epoch(image_Epoch: UIImage) -> String? {
        let fileName_epoch = "avatar_\(Int(Date().timeIntervalSince1970)).jpg"
        let fileURL_epoch = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName_epoch)
        guard let data_epoch = image_Epoch.jpegData(compressionQuality: 0.85) else { return nil }
        do {
            try data_epoch.write(to: fileURL_epoch)
            return fileURL_epoch.path
        } catch {
            Utils_Epoch.showError_Epoch(message_Epoch: "Failed to save avatar.")
            return nil
        }
    }

    // MARK: - @objc 动作

    @objc private func backTapped_Epoch() {
        Navigation_Epoch.pop_Epoch()
    }

    @objc private func nameTextChanged_Epoch() {
        refreshCharCount_Epoch()
    }

    @objc private func pickAvatarTapped_Epoch() {
        MediaPickerHelper_Epoch.pickImage_Epoch(from: self) { [weak self] image_epoch in
            guard let self = self, let image_epoch = image_epoch else { return }
            self.selectedImage_Epoch = image_epoch
            self.avatarView_Epoch.imageView_Epoch.image = image_epoch
            self.avatarView_Epoch.imageView_Epoch.contentMode = .scaleAspectFill
        }
    }

    @objc private func confirmTapped_Epoch() {
        if let selectedImage_Epoch = selectedImage_Epoch {
            selectedAvatarPath_Epoch = storeAvatarImage_Epoch(image_Epoch: selectedImage_Epoch)
        }
        _ = UserViewModel_Epoch.shared_Epoch.updateProfile_Epoch(
            userName_epoch: nameTextField_Epoch.text,
            userIntroduce_epoch: introTextView_Epoch.text,
            headPath_epoch: selectedAvatarPath_Epoch
        )
    }
}

// MARK: - UITextViewDelegate

extension EditInfo_Epoch: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        introPlaceholderLabel_Epoch.isHidden = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        refreshCharCount_Epoch()
    }
}

// MARK: - 字段分组头部

/// 编辑页字段分组头部
/// 核心作用：在每个输入字段上方展示图标和字段名，提升表单可读性
/// 设计思路：小图标背景圆角块 + 粗字标题，与发布页分组头保持一致风格
private final class EditInfoSectionHeaderView_Epoch: UIView {

    private let iconBgView_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.14)
        v.layer.cornerRadius = 14
        return v
    }()

    private let iconImageView_Epoch: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorConfig_Epoch.accentPurple_Epoch
        return iv
    }()

    private let titleLabel_Epoch: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        l.textColor = ColorConfig_Epoch.textPrimary_Epoch
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 配置字段头部
    /// - Parameters:
    ///   - iconName_Epoch: 图标名称
    ///   - title_Epoch: 字段名称
    func configure_Epoch(iconName_Epoch: String, title_Epoch: String) {
        iconImageView_Epoch.image = UIImage(systemName: iconName_Epoch)
        titleLabel_Epoch.text = title_Epoch
    }

    private func setupUI_Epoch() {
        addSubview(iconBgView_Epoch)
        iconBgView_Epoch.addSubview(iconImageView_Epoch)
        addSubview(titleLabel_Epoch)

        iconBgView_Epoch.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }

        iconImageView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(14)
        }

        titleLabel_Epoch.snp.makeConstraints { make in
            make.left.equalTo(iconBgView_Epoch.snp.right).offset(8)
            make.centerY.right.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(4)
        }
    }
}
