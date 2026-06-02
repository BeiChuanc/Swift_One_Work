import Foundation
import UIKit
import SnapKit

// MARK: 修改用户信息页面

/// 修改用户信息页面
/// 核心作用：编辑当前用户头像、昵称与简介，仅提交发生变更的字段；无需登录即可进入（保存时若未登录提示）
/// 设计思路：渐变头部（与 Discover 同款）+ 居中头像区 + 卡片输入区 + 渐变保存按钮
/// 关键属性：pickedImage_Breeze 新选头像、originalName/Intro_Breeze 原始值（用于判断是否变更）
class EditInfo_Breeze: UIViewController {
    
    // MARK: - 数据
    
    /// 新选取的头像（nil = 未修改）
    private var pickedImage_Breeze: UIImage?
    
    /// 原始昵称（用于判断是否变更）
    private var originalName_Breeze: String = ""
    
    /// 原始简介（用于判断是否变更）
    private var originalIntro_Breeze: String = ""
    
    // MARK: - UI：渐变头部
    
    /// 头部渐变容器
    private let headerView_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.clipsToBounds = true
        return v_breeze
    }()
    
    private var headerGradient_Breeze: CAGradientLayer?
    
    /// 装饰圆 - 右上大圆
    private let decorLarge_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v_breeze.layer.cornerRadius = 68
        return v_breeze
    }()
    
    /// 装饰圆 - 左下小圆
    private let decorSmall_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v_breeze.layer.cornerRadius = 36
        return v_breeze
    }()
    
    /// 返回按钮（白色圆形）
    private let backButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn_breeze.setImage(UIImage(systemName: "chevron.left", withConfiguration: config_breeze), for: .normal)
        btn_breeze.tintColor = .white
        btn_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn_breeze.layer.cornerRadius = 18
        return btn_breeze
    }()
    
    /// 页面主标题
    private let pageTitleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Edit Profile"
        label_breeze.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label_breeze.textColor = .white
        return label_breeze
    }()
    
    /// 页面副标题
    private let pageSubtitle_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Update your avatar, name and bio"
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label_breeze.textColor = UIColor.white.withAlphaComponent(0.82)
        return label_breeze
    }()
    
    // MARK: - UI：头像区（浮于渐变底部）
    
    /// 头像外圈（白色环）
    private let avatarRing_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = .white
        v_breeze.layer.cornerRadius = 52
        v_breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        v_breeze.layer.shadowOffset = CGSize(width: 0, height: 6)
        v_breeze.layer.shadowRadius = 14
        v_breeze.layer.shadowOpacity = 0.15
        return v_breeze
    }()
    
    /// 头像视图
    private let avatarView_Breeze: CurrentUserAvatarView_Breeze = {
        let av_breeze = CurrentUserAvatarView_Breeze()
        av_breeze.layer.cornerRadius = 46
        av_breeze.clipsToBounds = true
        return av_breeze
    }()
    
    /// 相机角标
    private let cameraBadge_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        v_breeze.layer.cornerRadius = 16
        v_breeze.layer.borderWidth = 2
        v_breeze.layer.borderColor = UIColor.white.cgColor
        v_breeze.isUserInteractionEnabled = false
        return v_breeze
    }()
    
    private let cameraIcon_Breeze: UIImageView = {
        let iv_breeze = UIImageView()
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        iv_breeze.image = UIImage(systemName: "camera.fill", withConfiguration: config_breeze)
        iv_breeze.tintColor = .white
        iv_breeze.contentMode = .scaleAspectFit
        return iv_breeze
    }()
    
    // MARK: - UI：滚动输入区
    
    private let scrollView_Breeze: UIScrollView = {
        let sv_breeze = UIScrollView()
        sv_breeze.showsVerticalScrollIndicator = false
        sv_breeze.keyboardDismissMode = .onDrag
        sv_breeze.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        return sv_breeze
    }()
    
    private let contentView_Breeze = UIView()
    
    /// Username 区块标签
    private let nameSectionLabel_Breeze = EditInfo_Breeze.makeSectionLabel_Breeze(text_breeze: "Username")
    
    /// 昵称输入卡片
    private let nameCard_Breeze = EditInfo_Breeze.makeInputCard_Breeze()
    
    /// 昵称图标
    private let nameIcon_Breeze = EditInfo_Breeze.makeFieldIcon_Breeze(systemName_breeze: "person.fill")
    
    /// 昵称输入框
    private let nameTextField_Breeze: UITextField = {
        let field_breeze = UITextField()
        field_breeze.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        field_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        field_breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        field_breeze.borderStyle = .none
        field_breeze.backgroundColor = .clear
        field_breeze.returnKeyType = .next
        field_breeze.clearButtonMode = .whileEditing
        let attrs_breeze: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorConfig_Breeze.textPlaceholder_Breeze,
            .font: UIFont.systemFont(ofSize: 15, weight: .regular)
        ]
        field_breeze.attributedPlaceholder = NSAttributedString(string: "Enter your username", attributes: attrs_breeze)
        return field_breeze
    }()
    
    /// Bio 区块标签
    private let bioSectionLabel_Breeze = EditInfo_Breeze.makeSectionLabel_Breeze(text_breeze: "Bio")
    
    /// 简介输入卡片
    private let bioCard_Breeze = EditInfo_Breeze.makeInputCard_Breeze()
    
    /// 简介输入框
    private let introTextView_Breeze: UITextView = {
        let tv_breeze = UITextView()
        tv_breeze.font = UIFont.systemFont(ofSize: 14)
        tv_breeze.backgroundColor = .clear
        tv_breeze.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        tv_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        tv_breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        return tv_breeze
    }()
    
    /// 简介占位文字
    private let introPlaceholder_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Tell others about yourself..."
        label_breeze.font = UIFont.systemFont(ofSize: 14)
        label_breeze.textColor = ColorConfig_Breeze.textPlaceholder_Breeze
        label_breeze.numberOfLines = 0
        return label_breeze
    }()
    
    // MARK: - UI：保存按钮
    
    private let saveButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        btn_breeze.setTitle("Save Changes", for: .normal)
        btn_breeze.setTitleColor(.white, for: .normal)
        btn_breeze.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn_breeze.layer.cornerRadius = 28
        btn_breeze.layer.shadowColor = ColorConfig_Breeze.primaryGradientStart_Breeze.cgColor
        btn_breeze.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn_breeze.layer.shadowRadius = 14
        btn_breeze.layer.shadowOpacity = 0.36
        return btn_breeze
    }()
    
    private var saveGradient_Breeze: CAGradientLayer?
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Breeze()
        loadCurrentData_Breeze()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshHeaderGradient_Breeze()
        refreshSaveGradient_Breeze()
    }
    
    // MARK: - UI 搭建
    
    private func setupUI_Breeze() {
        view.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        setupHeaderArea_Breeze()
        setupScrollContent_Breeze()
    }
    
    /// 搭建渐变头部 + 头像区
    private func setupHeaderArea_Breeze() {
        view.addSubview(headerView_Breeze)
        headerView_Breeze.addSubview(decorLarge_Breeze)
        headerView_Breeze.addSubview(decorSmall_Breeze)
        headerView_Breeze.addSubview(backButton_Breeze)
        headerView_Breeze.addSubview(pageTitleLabel_Breeze)
        headerView_Breeze.addSubview(pageSubtitle_Breeze)
        view.addSubview(avatarRing_Breeze)
        avatarRing_Breeze.addSubview(avatarView_Breeze)
        view.addSubview(cameraBadge_Breeze)
        cameraBadge_Breeze.addSubview(cameraIcon_Breeze)
        
        headerView_Breeze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        decorLarge_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(136)
            make.right.equalToSuperview().offset(36)
            make.top.equalToSuperview().offset(-26)
        }
        
        decorSmall_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(72)
            make.left.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(10)
        }
        
        backButton_Breeze.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
        
        pageTitleLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(backButton_Breeze.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(22)
        }
        
        pageSubtitle_Breeze.snp.makeConstraints { make in
            make.top.equalTo(pageTitleLabel_Breeze.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(22)
            make.bottom.equalToSuperview().offset(-52)
        }
        
        // 头像环（浮于 header 底部，垂直居中于 header 底边）
        avatarRing_Breeze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(headerView_Breeze.snp.bottom)
            make.width.height.equalTo(104)
        }
        
        avatarView_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(92)
        }
        
        cameraBadge_Breeze.snp.makeConstraints { make in
            make.right.equalTo(avatarRing_Breeze).offset(-2)
            make.bottom.equalTo(avatarRing_Breeze).offset(-2)
            make.width.height.equalTo(32)
        }
        
        cameraIcon_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(14)
        }
        
        backButton_Breeze.addTarget(self, action: #selector(handleBack_Breeze), for: .touchUpInside)
        
        let avatarTap_breeze = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap_Breeze))
        avatarRing_Breeze.addGestureRecognizer(avatarTap_breeze)
        avatarRing_Breeze.isUserInteractionEnabled = true
        avatarView_Breeze.onTapped_Breeze = { [weak self] in self?.pickAvatar_Breeze() }
    }
    
    private func refreshHeaderGradient_Breeze() {
        headerGradient_Breeze?.removeFromSuperlayer()
        let gradient_breeze = UIColor.createPrimaryGradientLayer_Breeze(frame_Breeze: headerView_Breeze.bounds)
        headerView_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        headerGradient_Breeze = gradient_breeze
    }
    
    /// 搭建滚动输入区内容
    private func setupScrollContent_Breeze() {
        view.addSubview(scrollView_Breeze)
        scrollView_Breeze.addSubview(contentView_Breeze)
        
        scrollView_Breeze.snp.makeConstraints { make in
            make.top.equalTo(avatarRing_Breeze.snp.bottom).offset(20)
            make.left.right.bottom.equalToSuperview()
        }
        
        contentView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // Username section
        contentView_Breeze.addSubview(nameSectionLabel_Breeze)
        contentView_Breeze.addSubview(nameCard_Breeze)
        nameCard_Breeze.addSubview(nameIcon_Breeze)
        nameCard_Breeze.addSubview(nameTextField_Breeze)
        
        nameSectionLabel_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.equalToSuperview().offset(22)
        }
        
        nameCard_Breeze.snp.makeConstraints { make in
            make.top.equalTo(nameSectionLabel_Breeze.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        
        nameIcon_Breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        
        nameTextField_Breeze.snp.makeConstraints { make in
            make.left.equalTo(nameIcon_Breeze.snp.right).offset(10)
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
        
        // Bio section
        contentView_Breeze.addSubview(bioSectionLabel_Breeze)
        contentView_Breeze.addSubview(bioCard_Breeze)
        bioCard_Breeze.addSubview(introTextView_Breeze)
        introTextView_Breeze.addSubview(introPlaceholder_Breeze)
        
        bioSectionLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(nameCard_Breeze.snp.bottom).offset(22)
            make.left.equalToSuperview().offset(22)
        }
        
        bioCard_Breeze.snp.makeConstraints { make in
            make.top.equalTo(bioSectionLabel_Breeze.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(120)
        }
        
        introTextView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        introPlaceholder_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-12)
        }
        
        // Save button
        contentView_Breeze.addSubview(saveButton_Breeze)
        saveButton_Breeze.snp.makeConstraints { make in
            make.top.equalTo(bioCard_Breeze.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        nameTextField_Breeze.delegate = self
        introTextView_Breeze.delegate = self
        saveButton_Breeze.addTarget(self, action: #selector(handleConfirm_Breeze), for: .touchUpInside)
    }
    
    private func refreshSaveGradient_Breeze() {
        guard !saveButton_Breeze.bounds.isEmpty else { return }
        saveGradient_Breeze?.removeFromSuperlayer()
        let gradient_breeze = UIColor.createPrimaryGradientLayer_Breeze(frame_Breeze: saveButton_Breeze.bounds)
        gradient_breeze.cornerRadius = saveButton_Breeze.layer.cornerRadius
        saveButton_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        saveGradient_Breeze = gradient_breeze
    }
    
    // MARK: - 数据加载
    
    /// 加载当前用户数据填充表单
    private func loadCurrentData_Breeze() {
        let user_breeze = UserViewModel_Breeze.shared_Breeze.getCurrentUser_Breeze()
        originalName_Breeze = user_breeze.userName_Breeze ?? ""
        originalIntro_Breeze = user_breeze.userIntroduce_Breeze ?? ""
        nameTextField_Breeze.text = originalName_Breeze
        introTextView_Breeze.text = originalIntro_Breeze
        introPlaceholder_Breeze.isHidden = !originalIntro_Breeze.isEmpty
        avatarView_Breeze.loadCurrentUserAvatar_Breeze()
    }
    
    // MARK: - 事件
    
    @objc private func handleBack_Breeze() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleAvatarTap_Breeze() {
        pickAvatar_Breeze()
    }
    
    /// 从相册选取头像
    private func pickAvatar_Breeze() {
        MediaPickerHelper_Breeze.pickImage_Breeze(from: self) { [weak self] image_breeze in
            guard let self, let image_breeze else { return }
            self.pickedImage_Breeze = image_breeze
            self.avatarView_Breeze.imageView_Breeze.image = image_breeze
            self.avatarView_Breeze.imageView_Breeze.contentMode = .scaleAspectFill
        }
    }
    
    /// 保存修改（未登录时直接保存也可；若校验失败则提示）
    @objc private func handleConfirm_Breeze() {
        let newName_breeze = nameTextField_Breeze.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let newIntro_breeze = introTextView_Breeze.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !newName_breeze.isEmpty else {
            nameCard_Breeze.animateShake_Breeze()
            Utils_Breeze.showWarning_Breeze(message_Breeze: "Username cannot be empty")
            return
        }
        
        var changed_breeze = false
        
        if let pickedImage_breeze = pickedImage_Breeze,
           let savedPath_breeze = MediaPickerHelper_Breeze.saveImageToDocuments_Breeze(image_breeze: pickedImage_breeze) {
            UserViewModel_Breeze.shared_Breeze.updateHead_Breeze(headUrl_breeze: savedPath_breeze)
            changed_breeze = true
        }
        if newName_breeze != originalName_Breeze {
            UserViewModel_Breeze.shared_Breeze.updateName_Breeze(userName_breeze: newName_breeze)
            changed_breeze = true
        }
        if newIntro_breeze != originalIntro_Breeze {
            UserViewModel_Breeze.shared_Breeze.updateIntro_Breeze(intro_breeze: newIntro_breeze)
            changed_breeze = true
        }
        
        if changed_breeze {
            Utils_Breeze.showSuccess_Breeze(message_Breeze: "Profile updated")
        } else {
            Utils_Breeze.showInfo_Breeze(message_Breeze: "No changes to save")
        }
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - 工厂方法
    
    private static func makeSectionLabel_Breeze(text_breeze: String) -> UILabel {
        let label_breeze = UILabel()
        label_breeze.text = text_breeze
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label_breeze.textColor = ColorConfig_Breeze.textSecondary_Breeze
        return label_breeze
    }
    
    private static func makeInputCard_Breeze() -> UIView {
        let v_breeze = UIView()
        v_breeze.backgroundColor = .white
        v_breeze.layer.cornerRadius = 16
        v_breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        v_breeze.layer.shadowOffset = CGSize(width: 0, height: 3)
        v_breeze.layer.shadowRadius = 8
        v_breeze.layer.shadowOpacity = 0.09
        return v_breeze
    }
    
    private static func makeFieldIcon_Breeze(systemName_breeze: String) -> UIImageView {
        let iv_breeze = UIImageView()
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        iv_breeze.image = UIImage(systemName: systemName_breeze, withConfiguration: config_breeze)
        iv_breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        iv_breeze.contentMode = .scaleAspectFit
        return iv_breeze
    }
}

// MARK: - UITextFieldDelegate

extension EditInfo_Breeze: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        introTextView_Breeze.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension EditInfo_Breeze: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        introPlaceholder_Breeze.isHidden = !textView.text.isEmpty
    }
}
