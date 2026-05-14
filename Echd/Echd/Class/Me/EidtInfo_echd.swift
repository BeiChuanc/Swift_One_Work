import Foundation
import UIKit
import SnapKit

// MARK: 修改用户信息页
// 设计思路：
//   顶部采用与全局统一的深紫-靛蓝渐变 Header（圆弧底部）；
//   内容区包含头像编辑卡片（渐变环 + 相机浮层）和表单卡片（用户名 / 简介），
//   底部全宽渐变 Save 按钮。
//   进入页面不强制登录验证，直接填充当前用户数据；
//   保存时若未登录则弹出轻提示而非跳转登录页。
// 关键属性：
//   isAvatarChanged_Echd — 是否修改了头像
//   newAvatarPath_Echd   — 新头像本地路径（用于保存）

/// 修改用户信息页视图控制器
class EditInfo_Echd: UIViewController {

    // MARK: - 私有属性

    /// 是否修改了头像
    private var isAvatarChanged_Echd: Bool = false

    /// 选择的新头像图片
    private var newAvatarImage_Echd: UIImage?

    /// 新头像本地路径
    private var newAvatarPath_Echd: String?

    // MARK: - UI组件 / Header

    /// 顶部渐变 Header 容器
    private let headerView_Echd = UIView()

    /// Header 渐变图层
    private var headerGradient_Echd: CAGradientLayer?

    /// 返回按钮
    private let backButton_Echd = BackButton_Echd()

    /// 页面标题
    private let pageTitleLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Edit Profile"
        label_Echd.font = UIFont.systemFont(ofSize: 26, weight: .black)
        label_Echd.textColor = .white
        return label_Echd
    }()

    /// Header 副标题
    private let pageSubLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Update your personal info ✦"
        label_Echd.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_Echd.textColor = UIColor.white.withAlphaComponent(0.75)
        return label_Echd
    }()

    /// Header 右侧装饰图标
    private let headerDecoIcon_Echd: UIImageView = {
        let iv_Echd = UIImageView()
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 40, weight: .thin)
        iv_Echd.image = UIImage(systemName: "person.crop.circle.badge.pencil", withConfiguration: cfg_Echd)
        iv_Echd.tintColor = UIColor.white.withAlphaComponent(0.12)
        iv_Echd.contentMode = .scaleAspectFit
        return iv_Echd
    }()

    // MARK: - UI组件 / 滚动区

    /// 主滚动视图
    private let scrollView_Echd: UIScrollView = {
        let sv_Echd = UIScrollView()
        sv_Echd.showsVerticalScrollIndicator = false
        sv_Echd.alwaysBounceVertical = true
        sv_Echd.keyboardDismissMode = .onDrag
        return sv_Echd
    }()

    /// 滚动内容容器
    private let contentView_Echd = UIView()

    // MARK: - UI组件 / 头像卡片

    /// 头像编辑卡片
    private let avatarCard_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = .white
        view_Echd.layer.cornerRadius = 20
        view_Echd.layer.shadowColor = UIColor(hexstring_Echd: "#7C3AED").withAlphaComponent(0.12).cgColor
        view_Echd.layer.shadowOffset = CGSize(width: 0, height: 5)
        view_Echd.layer.shadowRadius = 14
        view_Echd.layer.shadowOpacity = 1
        return view_Echd
    }()

    /// 头像渐变环（深紫-靛蓝）
    private let avatarRingView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.layer.cornerRadius = 50
        view_Echd.clipsToBounds = true
        return view_Echd
    }()

    /// 渐变环 CAGradientLayer
    private var avatarRingGradient_Echd: CAGradientLayer?

    /// 头像图片视图
    private let avatarImageView_Echd: UIImageView = {
        let iv_Echd = UIImageView()
        iv_Echd.contentMode = .scaleAspectFill
        iv_Echd.clipsToBounds = true
        iv_Echd.layer.cornerRadius = 44
        iv_Echd.backgroundColor = UIColor(hexstring_Echd: "#EDE9FE")
        return iv_Echd
    }()

    /// 相机浮层（点击更换头像）
    private let cameraOverlay_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        view_Echd.layer.cornerRadius = 44
        view_Echd.clipsToBounds = true
        let iv_Echd = UIImageView()
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        iv_Echd.image = UIImage(systemName: "camera.fill", withConfiguration: cfg_Echd)
        iv_Echd.tintColor = .white
        iv_Echd.contentMode = .scaleAspectFit
        view_Echd.addSubview(iv_Echd)
        iv_Echd.snp.makeConstraints { make in make.center.equalToSuperview(); make.width.height.equalTo(22) }
        return view_Echd
    }()

    /// Change Photo 按钮文字
    private let changePhotoLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Tap to change photo"
        label_Echd.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_Echd.textColor = UIColor(hexstring_Echd: "#7C3AED")
        label_Echd.textAlignment = .center
        return label_Echd
    }()

    // MARK: - UI组件 / 表单卡片

    /// 用户名输入卡片
    private let nameCard_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = .white
        view_Echd.layer.cornerRadius = 16
        view_Echd.layer.shadowColor = UIColor(hexstring_Echd: "#7C3AED").withAlphaComponent(0.08).cgColor
        view_Echd.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Echd.layer.shadowRadius = 10
        view_Echd.layer.shadowOpacity = 1
        return view_Echd
    }()

    /// 用户名 accent 竖条
    private let nameAccentBar_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor(hexstring_Echd: "#7C3AED")
        view_Echd.layer.cornerRadius = 2
        return view_Echd
    }()

    /// 用户名 Section 标签
    private let nameSectionLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Username"
        label_Echd.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label_Echd.textColor = UIColor(hexstring_Echd: "#7C3AED")
        return label_Echd
    }()

    /// 用户名输入框
    private let usernameTextField_Echd: UITextField = {
        let tf_Echd = UITextField()
        tf_Echd.placeholder = "Your display name"
        tf_Echd.font = UIFont.systemFont(ofSize: 16)
        tf_Echd.textColor = UIColor(hexstring_Echd: "#1F2937")
        tf_Echd.autocorrectionType = .no
        tf_Echd.autocapitalizationType = .none
        tf_Echd.borderStyle = .none
        return tf_Echd
    }()

    /// 用户名卡片分隔线
    private let nameDivider_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor(hexstring_Echd: "#F3F4F6")
        return view_Echd
    }()

    /// 简介输入卡片
    private let bioCard_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = .white
        view_Echd.layer.cornerRadius = 16
        view_Echd.layer.shadowColor = UIColor(hexstring_Echd: "#EC4899").withAlphaComponent(0.08).cgColor
        view_Echd.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Echd.layer.shadowRadius = 10
        view_Echd.layer.shadowOpacity = 1
        return view_Echd
    }()

    /// 简介 accent 竖条（玫瑰粉）
    private let bioAccentBar_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor(hexstring_Echd: "#EC4899")
        view_Echd.layer.cornerRadius = 2
        return view_Echd
    }()

    /// 简介 Section 标签
    private let bioSectionLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Bio"
        label_Echd.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label_Echd.textColor = UIColor(hexstring_Echd: "#EC4899")
        return label_Echd
    }()

    /// 简介多行输入框
    private let bioTextView_Echd: UITextView = {
        let tv_Echd = UITextView()
        tv_Echd.font = UIFont.systemFont(ofSize: 15)
        tv_Echd.textColor = UIColor(hexstring_Echd: "#1F2937")
        tv_Echd.backgroundColor = .clear
        tv_Echd.isScrollEnabled = false
        tv_Echd.textContainerInset = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: -4)
        return tv_Echd
    }()

    /// 简介占位符
    private let bioPlaceholder_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Tell your story..."
        label_Echd.font = UIFont.systemFont(ofSize: 15)
        label_Echd.textColor = UIColor(hexstring_Echd: "#D1D5DB")
        label_Echd.isUserInteractionEnabled = false
        return label_Echd
    }()

    // MARK: - UI组件 / 保存按钮

    /// 保存按钮
    private let saveButton_Echd: UIButton = {
        let btn_Echd = UIButton(type: .custom)
        btn_Echd.setTitle("✦  Save Changes", for: .normal)
        btn_Echd.setTitleColor(.white, for: .normal)
        btn_Echd.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn_Echd.layer.cornerRadius = 18
        btn_Echd.layer.shadowColor = UIColor(hexstring_Echd: "#7C3AED").withAlphaComponent(0.45).cgColor
        btn_Echd.layer.shadowOffset = CGSize(width: 0, height: 8)
        btn_Echd.layer.shadowRadius = 16
        btn_Echd.layer.shadowOpacity = 1
        return btn_Echd
    }()

    /// 保存按钮渐变图层
    private var saveGradient_Echd: CAGradientLayer?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Echd: "#F8F7FF")
        setupUI_Echd()
        setupConstraints_Echd()
        // 直接填充数据，不弹起登录
        fillCurrentUserData_Echd()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Echd?.frame = headerView_Echd.bounds
        applyHeaderArc_Echd()
        saveGradient_Echd?.frame = saveButton_Echd.bounds
        saveButton_Echd.layer.masksToBounds = true
        // 更新头像渐变环尺寸
        avatarRingGradient_Echd?.frame = avatarRingView_Echd.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI设置

    private func setupUI_Echd() {
        // Header
        headerView_Echd.clipsToBounds = true
        view.addSubview(headerView_Echd)

        let grad_Echd = CAGradientLayer()
        grad_Echd.colors = [
            UIColor(hexstring_Echd: "#7C3AED").cgColor,
            UIColor(hexstring_Echd: "#4F46E5").cgColor
        ]
        grad_Echd.startPoint = CGPoint(x: 0, y: 0)
        grad_Echd.endPoint = CGPoint(x: 1, y: 1)
        headerView_Echd.layer.insertSublayer(grad_Echd, at: 0)
        headerGradient_Echd = grad_Echd

        headerView_Echd.addSubview(pageTitleLabel_Echd)
        headerView_Echd.addSubview(pageSubLabel_Echd)
        headerView_Echd.addSubview(headerDecoIcon_Echd)

        // 返回按钮浮于 Header
        view.addSubview(backButton_Echd)
        backButton_Echd.onTapped_Echd = { Navigation_Echd.pop_Echd() }

        // 滚动区
        view.addSubview(scrollView_Echd)
        scrollView_Echd.addSubview(contentView_Echd)

        // 头像卡片
        contentView_Echd.addSubview(avatarCard_Echd)

        // 头像渐变环
        let ringGrad_Echd = CAGradientLayer()
        ringGrad_Echd.colors = [
            UIColor(hexstring_Echd: "#7C3AED").cgColor,
            UIColor(hexstring_Echd: "#EC4899").cgColor
        ]
        ringGrad_Echd.startPoint = CGPoint(x: 0, y: 0)
        ringGrad_Echd.endPoint = CGPoint(x: 1, y: 1)
        avatarRingView_Echd.layer.insertSublayer(ringGrad_Echd, at: 0)
        avatarRingGradient_Echd = ringGrad_Echd

        avatarCard_Echd.addSubview(avatarRingView_Echd)
        avatarRingView_Echd.addSubview(avatarImageView_Echd)
        avatarCard_Echd.addSubview(cameraOverlay_Echd)
        avatarCard_Echd.addSubview(changePhotoLabel_Echd)

        // 头像点击
        let avatarTap_Echd = UITapGestureRecognizer(target: self, action: #selector(changeAvatarTapped_Echd))
        avatarRingView_Echd.addGestureRecognizer(avatarTap_Echd)
        avatarRingView_Echd.isUserInteractionEnabled = true
        cameraOverlay_Echd.isUserInteractionEnabled = false

        // 用户名卡片
        contentView_Echd.addSubview(nameCard_Echd)
        nameCard_Echd.addSubview(nameAccentBar_Echd)
        nameCard_Echd.addSubview(nameSectionLabel_Echd)
        nameCard_Echd.addSubview(nameDivider_Echd)
        nameCard_Echd.addSubview(usernameTextField_Echd)

        // 简介卡片
        contentView_Echd.addSubview(bioCard_Echd)
        bioCard_Echd.addSubview(bioAccentBar_Echd)
        bioCard_Echd.addSubview(bioSectionLabel_Echd)
        bioCard_Echd.addSubview(bioTextView_Echd)
        bioCard_Echd.addSubview(bioPlaceholder_Echd)
        bioTextView_Echd.delegate = self

        // 保存按钮
        contentView_Echd.addSubview(saveButton_Echd)
        let saveGrad_Echd = CAGradientLayer()
        saveGrad_Echd.colors = [
            UIColor(hexstring_Echd: "#7C3AED").cgColor,
            UIColor(hexstring_Echd: "#4F46E5").cgColor
        ]
        saveGrad_Echd.startPoint = CGPoint(x: 0, y: 0)
        saveGrad_Echd.endPoint = CGPoint(x: 1, y: 0)
        saveButton_Echd.layer.insertSublayer(saveGrad_Echd, at: 0)
        saveGradient_Echd = saveGrad_Echd
        saveButton_Echd.addTarget(self, action: #selector(saveTapped_Echd), for: .touchUpInside)

        // 收起键盘
        let tap_Echd = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Echd))
        tap_Echd.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Echd)
    }

    /// Header 底部圆弧遮罩
    private func applyHeaderArc_Echd() {
        let w_Echd = headerView_Echd.bounds.width
        let h_Echd = headerView_Echd.bounds.height
        let path_Echd = UIBezierPath()
        path_Echd.move(to: .zero)
        path_Echd.addLine(to: CGPoint(x: w_Echd, y: 0))
        path_Echd.addLine(to: CGPoint(x: w_Echd, y: h_Echd - 20))
        path_Echd.addQuadCurve(
            to: CGPoint(x: 0, y: h_Echd - 20),
            controlPoint: CGPoint(x: w_Echd / 2, y: h_Echd + 20)
        )
        path_Echd.close()
        let mask_Echd = CAShapeLayer()
        mask_Echd.path = path_Echd.cgPath
        headerView_Echd.layer.mask = mask_Echd
    }

    // MARK: - 约束布局

    private func setupConstraints_Echd() {
        let sw_Echd = UIScreen.main.bounds.width

        // Header
        headerView_Echd.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(130)
        }
        pageTitleLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalTo(backButton_Echd.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(headerDecoIcon_Echd.snp.leading).offset(-10)
        }
        pageSubLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(pageTitleLabel_Echd.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(22)
        }
        headerDecoIcon_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(8)
            make.width.height.equalTo(110)
        }

        // 返回按钮
        backButton_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }

        // 滚动区
        scrollView_Echd.snp.makeConstraints { make in
            make.top.equalTo(headerView_Echd.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(sw_Echd)
        }

        // 头像卡片
        avatarCard_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        avatarRingView_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        avatarImageView_Echd.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(92)
        }
        cameraOverlay_Echd.snp.makeConstraints { make in
            make.center.equalTo(avatarRingView_Echd)
            make.width.height.equalTo(92)
        }
        changePhotoLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView_Echd.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }

        // 用户名卡片
        nameCard_Echd.snp.makeConstraints { make in
            make.top.equalTo(avatarCard_Echd.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        nameAccentBar_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(14)
            make.width.equalTo(4)
            make.height.equalTo(16)
        }
        nameSectionLabel_Echd.snp.makeConstraints { make in
            make.centerY.equalTo(nameAccentBar_Echd)
            make.leading.equalTo(nameAccentBar_Echd.snp.trailing).offset(8)
        }
        nameDivider_Echd.snp.makeConstraints { make in
            make.top.equalTo(nameAccentBar_Echd.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(1)
        }
        usernameTextField_Echd.snp.makeConstraints { make in
            make.top.equalTo(nameDivider_Echd.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-14)
        }

        // 简介卡片
        bioCard_Echd.snp.makeConstraints { make in
            make.top.equalTo(nameCard_Echd.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        bioAccentBar_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(14)
            make.width.equalTo(4)
            make.height.equalTo(16)
        }
        bioSectionLabel_Echd.snp.makeConstraints { make in
            make.centerY.equalTo(bioAccentBar_Echd)
            make.leading.equalTo(bioAccentBar_Echd.snp.trailing).offset(8)
        }
        bioTextView_Echd.snp.makeConstraints { make in
            make.top.equalTo(bioAccentBar_Echd.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.height.greaterThanOrEqualTo(100)
            make.bottom.equalToSuperview().offset(-14)
        }
        bioPlaceholder_Echd.snp.makeConstraints { make in
            make.top.equalTo(bioTextView_Echd).offset(0)
            make.leading.equalTo(bioTextView_Echd).offset(0)
        }

        // 保存按钮
        saveButton_Echd.snp.makeConstraints { make in
            make.top.equalTo(bioCard_Echd.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(60)
            make.bottom.equalToSuperview().offset(-34)
        }
    }

    // MARK: - 数据填充

    /// 填充当前登录用户数据（不强制验证登录）
    private func fillCurrentUserData_Echd() {
        let currentUser_Echd = UserViewModel_Echd.shared_Echd.getCurrentUser_Echd()
        usernameTextField_Echd.text = currentUser_Echd.userName_Echd

        if let headPath_Echd = currentUser_Echd.userHead_Echd, !headPath_Echd.isEmpty {
            if let assetImg_Echd = UIImage(named: headPath_Echd) {
                avatarImageView_Echd.image = assetImg_Echd
            } else if let localImg_Echd = UIImage(contentsOfFile: headPath_Echd) {
                avatarImageView_Echd.image = localImg_Echd
            } else {
                setDefaultAvatar_Echd()
            }
        } else {
            setDefaultAvatar_Echd()
        }
    }

    /// 设置默认头像
    private func setDefaultAvatar_Echd() {
        avatarImageView_Echd.image = UIImage(systemName: "person.circle.fill")
        avatarImageView_Echd.tintColor = UIColor(hexstring_Echd: "#7C3AED")
        avatarImageView_Echd.contentMode = .scaleAspectFit
    }

    // MARK: - 事件处理

    /// 修改头像点击
    @objc private func changeAvatarTapped_Echd() {
        avatarRingView_Echd.animatePulse_Echd()
        MediaPickerHelper_Echd.pickImage_Echd(from: self) { [weak self] image_Echd in
            guard let self = self, let image_Echd = image_Echd else { return }
            self.avatarImageView_Echd.image = image_Echd
            self.avatarImageView_Echd.contentMode = .scaleAspectFill
            self.newAvatarImage_Echd = image_Echd
            self.isAvatarChanged_Echd = true
            let fileName_Echd = "avatar_\(Date().timeIntervalSince1970).jpg"
            let dir_Echd = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url_Echd = dir_Echd.appendingPathComponent(fileName_Echd)
            if let data_Echd = image_Echd.jpegData(compressionQuality: 0.8) {
                try? data_Echd.write(to: url_Echd)
                self.newAvatarPath_Echd = url_Echd.path
            }
        }
    }

    /// 保存修改
    @objc private func saveTapped_Echd() {
        saveButton_Echd.animatePressDown_Echd { self.saveButton_Echd.animatePressUp_Echd() }

        // 未登录时仅提示，不强制跳转
        guard UserViewModel_Echd.shared_Echd.isLoggedIn_Echd else {
            Navigation_Echd.toLogin_Echd(style_echd: .present_echd)
            return
        }

        let currentUser_Echd = UserViewModel_Echd.shared_Echd.getCurrentUser_Echd()
        let newName_Echd = usernameTextField_Echd.text ?? ""
        let isNameChanged_Echd = newName_Echd != (currentUser_Echd.userName_Echd ?? "")
        let isBioChanged_Echd = !bioTextView_Echd.text.trimmingCharacters(in: .whitespaces).isEmpty

        guard isAvatarChanged_Echd || isNameChanged_Echd || isBioChanged_Echd else {
            Utils_Echd.showInfo_Echd(message_Echd: "No changes to save.")
            return
        }

        if isAvatarChanged_Echd, let path_Echd = newAvatarPath_Echd {
            Task { @MainActor in
                UserViewModel_Echd.shared_Echd.updateHead_Echd(headUrl_echd: path_Echd)
            }
        }
        if isNameChanged_Echd && !newName_Echd.trimmingCharacters(in: .whitespaces).isEmpty {
            Task { @MainActor in
                UserViewModel_Echd.shared_Echd.updateName_Echd(userName_echd: newName_Echd)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Navigation_Echd.pop_Echd()
        }
    }

    /// 收起键盘
    @objc private func dismissKeyboard_Echd() {
        view.endEditing(true)
    }
}

// MARK: - UITextViewDelegate

extension EditInfo_Echd: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        bioPlaceholder_Echd.isHidden = !textView.text.isEmpty
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        bioPlaceholder_Echd.isHidden = true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        bioPlaceholder_Echd.isHidden = textView.text.isEmpty
    }
}
