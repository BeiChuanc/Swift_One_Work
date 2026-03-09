import Foundation
import UIKit
import SnapKit
import PhotosUI

// MARK: - 修改用户信息页面
// 核心作用：提供登录用户修改头像、昵称、简介的表单界面；
//           未登录时跳转登录页，数据未变更时沿用原值。
// 设计思路：渐变 Header + 头像选择卡 + 输入卡片；
//           使用 PHPickerViewController 选取相册图片，
//           调用 UserViewModel 的 update 方法持久化数据。
// 关键属性：originalHead_Moode / originalName_Moode / originalBio_Moode 用于变更检测；
//           pickedImage_Moode 暂存用户选取的图片；

/// 修改用户信息页面控制器
class EditInfo_Moode: UIViewController {
    
    // MARK: - 私有属性
    
    /// 原始头像路径（变更检测用）
    private var originalHead_Moode: String?
    
    /// 原始昵称（变更检测用）
    private var originalName_Moode: String?
    
    /// 原始简介（变更检测用）
    private var originalBio_Moode: String?
    
    /// 用户选取的新头像图片（nil 表示未更换）
    private var pickedImage_Moode: UIImage?
    
    // MARK: - UI组件
    
    /// 主滚动容器
    private let scrollView_Moode: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()
    
    /// 内容容器
    private let contentView_Moode = UIView()
    
    /// 顶部渐变 Header
    private let headerBg_Moode: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()
    
    /// Header 渐变层
    private let headerGradient_Moode = CAGradientLayer()
    
    /// 装饰圆1
    private let decCircle1_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 60
        return v
    }()
    
    /// 装饰圆2
    private let decCircle2_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.layer.cornerRadius = 45
        return v
    }()
    
    /// 返回按钮
    private let backBtn_Moode: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: "arrow.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        btn.layer.cornerRadius = 18
        return btn
    }()
    
    /// 页面标题
    private let pageTitleLbl_Moode: UILabel = {
        let lbl = UILabel()
        lbl.text = "Edit Profile"
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        lbl.textColor = .white
        return lbl
    }()

    /// 页面副标题
    private let pageSubLbl_Moode: UILabel = {
        let lbl = UILabel()
        lbl.text = "Make it uniquely you ✨"
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.78)
        return lbl
    }()
    
    /// 装饰 emoji1
    private let decEmoji1_Moode: UILabel = {
        let lbl = UILabel()
        lbl.text = "🖼"
        lbl.font = UIFont.systemFont(ofSize: 28)
        lbl.alpha = 0.55
        return lbl
    }()
    
    /// 装饰 emoji2
    private let decEmoji2_Moode: UILabel = {
        let lbl = UILabel()
        lbl.text = "✏️"
        lbl.font = UIFont.systemFont(ofSize: 22)
        lbl.alpha = 0.55
        return lbl
    }()
    
    /// 内容白卡
    private let contentCard_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Moode: "#F5F4FF")
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()
    
    // MARK: 头像区域
    
    /// 头像卡片容器
    private let avatarCard_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Moode: "#7C6FF7").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowOpacity = 0.10
        v.layer.shadowRadius = 10
        return v
    }()
    
    /// 步骤标签
    private let step1Badge_Moode: UIView = makeBadge_Moode(text: "01")
    
    /// 头像区块标题
    private let avatarSectionTitle_Moode: UILabel = {
        let lbl = UILabel()
        lbl.text = "Avatar"
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        lbl.textColor = UIColor(hexstring_Moode: "#2D2D3A")
        return lbl
    }()
    
    /// 头像容器（使用 UserAvatarView_Moode）
    private let avatarView_Moode: UserAvatarView_Moode = {
        let v = UserAvatarView_Moode()
        return v
    }()
    
    /// 相机角标
    private let cameraIcon_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Moode: "#7C6FF7")
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 2.5
        v.layer.borderColor = UIColor.white.cgColor
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        let iv = UIImageView(image: UIImage(systemName: "camera.fill", withConfiguration: cfg))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        v.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(13)
        }
        return v
    }()
    
    /// 更换头像提示文字
    private let avatarHintLbl_Moode: UILabel = {
        let lbl = UILabel()
        lbl.text = "Tap to change avatar"
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = UIColor(hexstring_Moode: "#7C6FF7")
        lbl.textAlignment = .center
        return lbl
    }()
    
    // MARK: 信息输入区域
    
    /// 信息输入卡片
    private let infoCard_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Moode: "#7C6FF7").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowOpacity = 0.10
        v.layer.shadowRadius = 10
        return v
    }()
    
    /// 步骤标签2
    private let step2Badge_Moode: UIView = makeBadge_Moode(text: "02")
    
    /// 信息区块标题
    private let infoSectionTitle_Moode: UILabel = {
        let lbl = UILabel()
        lbl.text = "Your Info"
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        lbl.textColor = UIColor(hexstring_Moode: "#2D2D3A")
        return lbl
    }()
    
    /// 昵称输入行容器
    private let nameRow_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Moode: "#F5F4FF")
        v.layer.cornerRadius = 14
        return v
    }()
    
    /// 昵称 icon
    private let nameIcon_Moode: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let iv = UIImageView(image: UIImage(systemName: "person.fill", withConfiguration: cfg))
        iv.tintColor = UIColor(hexstring_Moode: "#7C6FF7")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    /// 昵称输入框
    private let nameField_Moode: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.textColor = UIColor(hexstring_Moode: "#2D2D3A")
        tf.attributedPlaceholder = NSAttributedString(
            string: "Enter your name",
            attributes: [.foregroundColor: UIColor(hexstring_Moode: "#BBAAEE")]
        )
        tf.returnKeyType = .next
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    
    /// 昵称字数提示
    private let nameCountLbl_Moode: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl.textColor = UIColor(hexstring_Moode: "#BBAAEE")
        lbl.text = "0/20"
        return lbl
    }()
    
    /// 分隔线
    private let rowDivider_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Moode: "#EDE9FF")
        return v
    }()
    
    /// 简介输入行容器
    private let bioRow_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Moode: "#F5F4FF")
        v.layer.cornerRadius = 14
        return v
    }()
    
    /// 简介 icon
    private let bioIcon_Moode: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let iv = UIImageView(image: UIImage(systemName: "text.bubble.fill", withConfiguration: cfg))
        iv.tintColor = UIColor(hexstring_Moode: "#7C6FF7")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    /// 简介输入框
    private let bioField_Moode: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.textColor = UIColor(hexstring_Moode: "#2D2D3A")
        tf.attributedPlaceholder = NSAttributedString(
            string: "Write a short bio...",
            attributes: [.foregroundColor: UIColor(hexstring_Moode: "#BBAAEE")]
        )
        tf.returnKeyType = .done
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    
    /// 简介字数提示
    private let bioCountLbl_Moode: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl.textColor = UIColor(hexstring_Moode: "#BBAAEE")
        lbl.text = "0/80"
        return lbl
    }()
    
    // MARK: 保存按钮
    
    /// 保存按钮
    private let saveBtn_Moode: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Save Changes", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 22
        btn.clipsToBounds = true
        return btn
    }()
    
    /// 保存按钮渐变层
    private let saveBtnGradient_Moode = CAGradientLayer()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Moode()
        fillDefaultData_Moode()
        addKeyboardObservers_Moode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Moode.frame = headerBg_Moode.bounds
        saveBtnGradient_Moode.frame = saveBtn_Moode.bounds
        // 启动装饰 emoji 浮动动画（仅执行一次）
        startFloatAnimation_Moode()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI 搭建
    
    /// 搭建全部 UI
    private func setupUI_Moode() {
        view.backgroundColor = UIColor(hexstring_Moode: "#F5F4FF")
        
        view.addSubview(scrollView_Moode)
        scrollView_Moode.addSubview(contentView_Moode)
        
        scrollView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Moode.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Moode.contentLayoutGuide)
            make.width.equalTo(scrollView_Moode.frameLayoutGuide)
        }
        
        setupHeaderUI_Moode()
        setupContentUI_Moode()
    }
    
    /// 搭建顶部 Header UI
    private func setupHeaderUI_Moode() {
        contentView_Moode.addSubview(headerBg_Moode)
        headerBg_Moode.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(130)
        }

        headerGradient_Moode.colors = [
            UIColor(hexstring_Moode: "#7C6FF7").cgColor,
            UIColor(hexstring_Moode: "#A78BFA").cgColor,
            UIColor(hexstring_Moode: "#C4B5FD").cgColor
        ]
        headerGradient_Moode.startPoint = CGPoint(x: 0, y: 0)
        headerGradient_Moode.endPoint   = CGPoint(x: 1, y: 1)
        headerBg_Moode.layer.insertSublayer(headerGradient_Moode, at: 0)

        // 装饰圆
        headerBg_Moode.addSubview(decCircle1_Moode)
        decCircle1_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(120)
            make.top.equalToSuperview().offset(-30)
            make.right.equalToSuperview().offset(30)
        }

        headerBg_Moode.addSubview(decCircle2_Moode)
        decCircle2_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(90)
            make.bottom.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(-20)
        }

        // 装饰 emoji（右侧）
        headerBg_Moode.addSubview(decEmoji1_Moode)
        decEmoji1_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-14)
        }

        headerBg_Moode.addSubview(decEmoji2_Moode)
        decEmoji2_Moode.snp.makeConstraints { make in
            make.right.equalTo(decEmoji1_Moode.snp.left).offset(-8)
            make.centerY.equalTo(decEmoji1_Moode)
        }

        // 返回按钮（与标题同行，贴近安全区顶部）
        headerBg_Moode.addSubview(backBtn_Moode)
        backBtn_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.width.height.equalTo(36)
        }
        backBtn_Moode.addTarget(self, action: #selector(handleBack_Moode), for: .touchUpInside)

        // 标题与副标题：垂直居中对齐返回按钮，紧靠其右侧
        headerBg_Moode.addSubview(pageTitleLbl_Moode)
        pageTitleLbl_Moode.snp.makeConstraints { make in
            make.left.equalTo(backBtn_Moode.snp.right).offset(12)
            make.bottom.equalTo(backBtn_Moode.snp.centerY).offset(-1)
            make.right.lessThanOrEqualTo(decEmoji2_Moode.snp.left).offset(-8)
        }

        headerBg_Moode.addSubview(pageSubLbl_Moode)
        pageSubLbl_Moode.snp.makeConstraints { make in
            make.left.equalTo(backBtn_Moode.snp.right).offset(12)
            make.top.equalTo(backBtn_Moode.snp.centerY).offset(2)
            make.right.lessThanOrEqualTo(decEmoji2_Moode.snp.left).offset(-8)
        }
    }
    
    /// 搭建内容区域 UI
    private func setupContentUI_Moode() {
        contentView_Moode.addSubview(contentCard_Moode)
        contentCard_Moode.snp.makeConstraints { make in
            make.top.equalTo(headerBg_Moode.snp.bottom).offset(-16)
            make.left.right.bottom.equalToSuperview()
        }
        
        setupAvatarCard_Moode()
        setupInfoCard_Moode()
        setupSaveButton_Moode()
    }
    
    /// 搭建头像卡片
    private func setupAvatarCard_Moode() {
        contentCard_Moode.addSubview(avatarCard_Moode)
        avatarCard_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // 步骤标签
        avatarCard_Moode.addSubview(step1Badge_Moode)
        step1Badge_Moode.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
            make.width.equalTo(36)
            make.height.equalTo(22)
        }
        
        // 区块标题
        avatarCard_Moode.addSubview(avatarSectionTitle_Moode)
        avatarSectionTitle_Moode.snp.makeConstraints { make in
            make.centerY.equalTo(step1Badge_Moode)
            make.left.equalTo(step1Badge_Moode.snp.right).offset(8)
        }
        
        // 头像视图（可点击选取相册）
        avatarCard_Moode.addSubview(avatarView_Moode)
        avatarView_Moode.snp.makeConstraints { make in
            make.top.equalTo(step1Badge_Moode.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        avatarView_Moode.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePickAvatar_Moode))
        avatarView_Moode.addGestureRecognizer(tapGesture)
        
        // 相机角标
        avatarCard_Moode.addSubview(cameraIcon_Moode)
        cameraIcon_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(28)
            make.right.equalTo(avatarView_Moode.snp.right).offset(2)
            make.bottom.equalTo(avatarView_Moode.snp.bottom).offset(2)
        }
        
        // 提示文字
        avatarCard_Moode.addSubview(avatarHintLbl_Moode)
        avatarHintLbl_Moode.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Moode.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-18)
        }
    }
    
    /// 搭建信息输入卡片
    private func setupInfoCard_Moode() {
        contentCard_Moode.addSubview(infoCard_Moode)
        infoCard_Moode.snp.makeConstraints { make in
            make.top.equalTo(avatarCard_Moode.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // 步骤标签
        infoCard_Moode.addSubview(step2Badge_Moode)
        step2Badge_Moode.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
            make.width.equalTo(36)
            make.height.equalTo(22)
        }
        
        infoCard_Moode.addSubview(infoSectionTitle_Moode)
        infoSectionTitle_Moode.snp.makeConstraints { make in
            make.centerY.equalTo(step2Badge_Moode)
            make.left.equalTo(step2Badge_Moode.snp.right).offset(8)
        }
        
        // 昵称行
        infoCard_Moode.addSubview(nameRow_Moode)
        nameRow_Moode.snp.makeConstraints { make in
            make.top.equalTo(step2Badge_Moode.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
        nameRow_Moode.addSubview(nameIcon_Moode)
        nameIcon_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        
        nameRow_Moode.addSubview(nameCountLbl_Moode)
        nameCountLbl_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        
        nameRow_Moode.addSubview(nameField_Moode)
        nameField_Moode.snp.makeConstraints { make in
            make.left.equalTo(nameIcon_Moode.snp.right).offset(10)
            make.right.equalTo(nameCountLbl_Moode.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }
        nameField_Moode.delegate = self
        nameField_Moode.addTarget(self, action: #selector(nameFieldChanged_Moode), for: .editingChanged)
        
        // 分隔线
        infoCard_Moode.addSubview(rowDivider_Moode)
        rowDivider_Moode.snp.makeConstraints { make in
            make.top.equalTo(nameRow_Moode.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }
        
        // 简介行
        infoCard_Moode.addSubview(bioRow_Moode)
        bioRow_Moode.snp.makeConstraints { make in
            make.top.equalTo(rowDivider_Moode.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-18)
        }
        
        bioRow_Moode.addSubview(bioIcon_Moode)
        bioIcon_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        
        bioRow_Moode.addSubview(bioCountLbl_Moode)
        bioCountLbl_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        
        bioRow_Moode.addSubview(bioField_Moode)
        bioField_Moode.snp.makeConstraints { make in
            make.left.equalTo(bioIcon_Moode.snp.right).offset(10)
            make.right.equalTo(bioCountLbl_Moode.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }
        bioField_Moode.delegate = self
        bioField_Moode.addTarget(self, action: #selector(bioFieldChanged_Moode), for: .editingChanged)
    }
    
    /// 搭建保存按钮
    private func setupSaveButton_Moode() {
        contentCard_Moode.addSubview(saveBtn_Moode)
        saveBtn_Moode.snp.makeConstraints { make in
            make.top.equalTo(infoCard_Moode.snp.bottom).offset(28)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(54)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        saveBtnGradient_Moode.colors = [
            UIColor(hexstring_Moode: "#7C6FF7").cgColor,
            UIColor(hexstring_Moode: "#A78BFA").cgColor
        ]
        saveBtnGradient_Moode.startPoint = CGPoint(x: 0, y: 0)
        saveBtnGradient_Moode.endPoint = CGPoint(x: 1, y: 0)
        saveBtnGradient_Moode.cornerRadius = 22
        saveBtn_Moode.layer.insertSublayer(saveBtnGradient_Moode, at: 0)
        
        // 装饰图标
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        let checkIcon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill", withConfiguration: cfg))
        checkIcon.tintColor = .white
        saveBtn_Moode.addSubview(checkIcon)
        checkIcon.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        saveBtn_Moode.addTarget(self, action: #selector(handleSave_Moode), for: .touchUpInside)
    }
    
    // MARK: - 工厂方法
    
    /// 创建步骤标签视图
    /// - Parameter text_moode: 标签文字（如 "01"）
    /// - Returns: 配置好的视图
    private static func makeBadge_Moode(text: String) -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Moode: "#EDE9FF")
        v.layer.cornerRadius = 8
        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .heavy)
        lbl.textColor = UIColor(hexstring_Moode: "#7C6FF7")
        lbl.textAlignment = .center
        v.addSubview(lbl)
        lbl.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 3, left: 6, bottom: 3, right: 6))
        }
        return v
    }
    
    // MARK: - 数据填充
    
    /// 填充默认数据（来自当前登录用户）
    private func fillDefaultData_Moode() {
        let user = UserViewModel_Moode.shared_Moode.getCurrentUser_Moode()
        
        originalHead_Moode = user.userHead_Moode
        originalName_Moode = user.userName_Moode
        originalBio_Moode = user.userIntroduce_Moode
        
        // 头像
        if let uid = user.userId_Moode {
            avatarView_Moode.configure_Moode(userId_Moode: uid)
        }
        
        // 昵称
        nameField_Moode.text = user.userName_Moode
        updateNameCount_Moode()
        
        // 简介
        bioField_Moode.text = user.userIntroduce_Moode
        updateBioCount_Moode()
    }
    
    // MARK: - 字数统计
    
    /// 更新昵称字数显示
    private func updateNameCount_Moode() {
        let count = nameField_Moode.text?.count ?? 0
        nameCountLbl_Moode.text = "\(count)/20"
        nameCountLbl_Moode.textColor = count > 18
            ? UIColor(hexstring_Moode: "#FC8181")
            : UIColor(hexstring_Moode: "#BBAAEE")
    }
    
    /// 更新简介字数显示
    private func updateBioCount_Moode() {
        let count = bioField_Moode.text?.count ?? 0
        bioCountLbl_Moode.text = "\(count)/80"
        bioCountLbl_Moode.textColor = count > 72
            ? UIColor(hexstring_Moode: "#FC8181")
            : UIColor(hexstring_Moode: "#BBAAEE")
    }
    
    // MARK: - 装饰动画
    
    private var floatAnimationStarted_Moode = false
    
    /// 启动装饰 emoji 浮动动画（只执行一次）
    private func startFloatAnimation_Moode() {
        guard !floatAnimationStarted_Moode else { return }
        floatAnimationStarted_Moode = true
        
        UIView.animate(withDuration: 2.2, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) {
            self.decEmoji1_Moode.transform = CGAffineTransform(translationX: 0, y: -8)
        }
        UIView.animate(withDuration: 2.8, delay: 0.4, options: [.autoreverse, .repeat, .curveEaseInOut]) {
            self.decEmoji2_Moode.transform = CGAffineTransform(translationX: 0, y: -6)
        }
    }
    
    // MARK: - 键盘处理
    
    /// 添加键盘监听
    private func addKeyboardObservers_Moode() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Moode(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Moode),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        // 点击空白收起键盘
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Moode))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func keyboardWillShow_Moode(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView_Moode.contentInset.bottom = keyboardFrame.height + 20
    }
    
    @objc private func keyboardWillHide_Moode() {
        scrollView_Moode.contentInset.bottom = 0
    }
    
    @objc private func dismissKeyboard_Moode() {
        view.endEditing(true)
    }
    
    // MARK: - 事件处理
    
    /// 昵称输入变化
    @objc private func nameFieldChanged_Moode() {
        // 限制最多20字
        if let text = nameField_Moode.text, text.count > 20 {
            nameField_Moode.text = String(text.prefix(20))
        }
        updateNameCount_Moode()
    }
    
    /// 简介输入变化
    @objc private func bioFieldChanged_Moode() {
        if let text = bioField_Moode.text, text.count > 80 {
            bioField_Moode.text = String(text.prefix(80))
        }
        updateBioCount_Moode()
    }
    
    /// 点击返回按钮
    @objc private func handleBack_Moode() {
        Navigation_Moode.pop_Moode(from: self)
    }
    
    /// 点击头像选取相册
    @objc private func handlePickAvatar_Moode() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    /// 点击保存按钮
    @objc private func handleSave_Moode() {
        // 检查登录状态
        guard UserViewModel_Moode.shared_Moode.isLoggedIn_Moode else {
            Navigation_Moode.toLogin_Moode()
            return
        }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        let vm = UserViewModel_Moode.shared_Moode
        
        // 更新头像（仅选取了新图片才更新）
        if let img = pickedImage_Moode {
            // 将图片保存到临时文件并传入路径
            if let data = img.jpegData(compressionQuality: 0.8) {
                let path = NSTemporaryDirectory() + "avatar_\(Date().timeIntervalSince1970).jpg"
                let url = URL(fileURLWithPath: path)
                try? data.write(to: url)
                vm.updateHead_Moode(headUrl_moode: path)
            }
        }
        
        // 更新昵称（有内容且与原始值不同时更新）
        let newName = nameField_Moode.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if !newName.isEmpty, newName != originalName_Moode {
            vm.updateName_Moode(userName_moode: newName)
        }
        
        // 更新简介
        let newBio = bioField_Moode.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if newBio != originalBio_Moode {
            vm.updateIntroduce_Moode(introduce_moode: newBio)
        }
        
        // 若均未修改，给出提示
        let headUnchanged = pickedImage_Moode == nil
        let nameUnchanged = newName.isEmpty || newName == originalName_Moode
        let bioUnchanged = newBio == originalBio_Moode
        if headUnchanged && nameUnchanged && bioUnchanged {
            Utils_Moode.showInfo_Moode(message_Moode: "No changes detected")
            return
        }
        
        // 保存成功后返回
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            Navigation_Moode.pop_Moode(from: self)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension EditInfo_Moode: PHPickerViewControllerDelegate {
    
    /// 用户选取图片后回调
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] obj, _ in
            guard let img = obj as? UIImage else { return }
            DispatchQueue.main.async {
                self?.pickedImage_Moode = img
                // 直接更新头像 imageView
                self?.avatarView_Moode.imageView_Moode.image = img
                UIView.animate(withDuration: 0.25) {
                    self?.avatarView_Moode.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                } completion: { _ in
                    UIView.animate(withDuration: 0.2) {
                        self?.avatarView_Moode.transform = .identity
                    }
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension EditInfo_Moode: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField_Moode {
            bioField_Moode.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
