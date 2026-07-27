import Foundation
import UIKit
import SnapKit

// MARK: 我的CCD技巧库 - 新增条目页面

/// CCD 技巧库新增条目控制器
/// 核心作用：专用于首页"我的CCD技巧库"区块的新增入口，独立于通用发布页（Release_Retrs）
/// 设计思路：紧凑的单卡片布局（媒体 + 相机型号 + 使用心得），提交后写入与首页技巧库共用的帖子数据源
/// 关键逻辑：提交前校验登录状态及表单非空，成功后关闭页面并清空表单，由首页监听通知刷新技巧库列表
class DiaryPublish_Retrs: UIViewController {

    // MARK: - 属性

    private let titleVM_Retrs = TitleViewModel_Retrs.shared_Retrs
    private let userVM_Retrs  = UserViewModel_Retrs.shared_Retrs

    /// 主滚动视图
    private let scrollView_Retrs  = UIScrollView()
    private let contentView_Retrs = UIView()

    /// 顶部导航栏
    private let navBar_Retrs        = UIView()
    private let closeBtn_Retrs      = UIButton(type: .system)
    private let navTitleLabel_Retrs = UILabel()

    /// 媒体选区
    private let mediaCard_Retrs            = UIView()
    private let mediaDashLayer_Retrs       = CAShapeLayer()
    private let mediaDisplayView_Retrs     = MediaDisplayView_Retrs()
    private let mediaPlaceholderWrap_Retrs = UIView()
    private let mediaHintLabel_Retrs       = UILabel()
    private let mediaChangeBadge_Retrs     = UIView()
    private var mediaPath_Retrs: String = ""

    /// 相机型号输入卡片
    private let cameraCard_Retrs  = UIView()
    private let cameraField_Retrs = UITextField()

    /// 使用心得输入卡片
    private let notesCard_Retrs        = UIView()
    private let notesTextView_Retrs    = UITextView()
    private let notesPlaceholder_Retrs = UILabel()
    private let charCountLabel_Retrs   = UILabel()

    /// 提交按钮
    private let submitBtn_Retrs       = UIButton(type: .system)
    private let submitGradLayer_Retrs = CAGradientLayer()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Retrs.backgroundPrimary_Retrs
        setupScrollView_Retrs()
        setupNavBar_Retrs()
        setupMediaCard_Retrs()
        setupCameraCard_Retrs()
        setupNotesCard_Retrs()
        setupSubmitArea_Retrs()
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
        submitGradLayer_Retrs.frame = submitBtn_Retrs.bounds
        updateDashBorder_Retrs()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - UI 搭建

    /// 主滚动视图
    private func setupScrollView_Retrs() {
        scrollView_Retrs.showsVerticalScrollIndicator = false
        scrollView_Retrs.alwaysBounceVertical = true
        scrollView_Retrs.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_Retrs)
        scrollView_Retrs.addSubview(contentView_Retrs)
    }

    /// 顶部导航栏：关闭按钮 + 标题
    private func setupNavBar_Retrs() {
        view.addSubview(navBar_Retrs)
        navBar_Retrs.backgroundColor = ColorConfig_Retrs.backgroundPrimary_Retrs

        closeBtn_Retrs.setImage(
            UIImage(systemName: "xmark.circle.fill",
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)),
            for: .normal)
        closeBtn_Retrs.tintColor = ColorConfig_Retrs.textSecondary_Retrs
        closeBtn_Retrs.addTarget(self, action: #selector(closeTapped_Retrs), for: .touchUpInside)
        navBar_Retrs.addSubview(closeBtn_Retrs)

        navTitleLabel_Retrs.text = "Add to My CCD Gallery"
        navTitleLabel_Retrs.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        navTitleLabel_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        navBar_Retrs.addSubview(navTitleLabel_Retrs)
    }

    /// 媒体选区卡片（带虚线边框 + 渐变图标占位）
    private func setupMediaCard_Retrs() {
        mediaCard_Retrs.backgroundColor = .white
        mediaCard_Retrs.layer.cornerRadius = 20
        mediaCard_Retrs.clipsToBounds = false
        mediaCard_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs.withAlphaComponent(0.12).cgColor
        mediaCard_Retrs.layer.shadowOffset = CGSize(width: 0, height: 6)
        mediaCard_Retrs.layer.shadowOpacity = 1.0
        mediaCard_Retrs.layer.shadowRadius = 16
        contentView_Retrs.addSubview(mediaCard_Retrs)

        mediaDashLayer_Retrs.strokeColor = ColorConfig_Retrs.primaryGradientStart_Retrs.withAlphaComponent(0.4).cgColor
        mediaDashLayer_Retrs.fillColor   = UIColor.clear.cgColor
        mediaDashLayer_Retrs.lineWidth   = 1.5
        mediaDashLayer_Retrs.lineDashPattern = [8, 5]
        mediaCard_Retrs.layer.addSublayer(mediaDashLayer_Retrs)

        mediaDisplayView_Retrs.layer.cornerRadius = 20
        mediaDisplayView_Retrs.clipsToBounds = true
        mediaCard_Retrs.addSubview(mediaDisplayView_Retrs)
        mediaDisplayView_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }

        mediaCard_Retrs.addSubview(mediaPlaceholderWrap_Retrs)
        mediaPlaceholderWrap_Retrs.snp.makeConstraints { make in make.center.equalToSuperview() }

        let iconBg_Retrs = UIView()
        iconBg_Retrs.backgroundColor = ColorConfig_Retrs.primaryGradientStart_Retrs.withAlphaComponent(0.12)
        iconBg_Retrs.layer.cornerRadius = 18
        mediaPlaceholderWrap_Retrs.addSubview(iconBg_Retrs)
        iconBg_Retrs.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }

        let uploadIcon_Retrs = UIImageView(
            image: UIImage(systemName: "photo.badge.plus",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium))
        )
        uploadIcon_Retrs.tintColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        uploadIcon_Retrs.contentMode = .scaleAspectFit
        iconBg_Retrs.addSubview(uploadIcon_Retrs)
        uploadIcon_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }

        mediaHintLabel_Retrs.text = "Tap to Add a CCD Shot"
        mediaHintLabel_Retrs.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        mediaHintLabel_Retrs.textColor = ColorConfig_Retrs.textSecondary_Retrs
        mediaHintLabel_Retrs.textAlignment = .center
        mediaPlaceholderWrap_Retrs.addSubview(mediaHintLabel_Retrs)
        mediaHintLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Retrs.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        // 已选媒体后出现的"更换"徽章
        mediaChangeBadge_Retrs.backgroundColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        mediaChangeBadge_Retrs.layer.cornerRadius = 18
        mediaChangeBadge_Retrs.isHidden = true
        mediaCard_Retrs.addSubview(mediaChangeBadge_Retrs)
        mediaChangeBadge_Retrs.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-12)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(36)
            make.width.equalTo(96)
        }
        let changeIcon_Retrs = UIImageView(
            image: UIImage(systemName: "arrow.2.circlepath",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .bold))
        )
        changeIcon_Retrs.tintColor = .white
        changeIcon_Retrs.contentMode = .scaleAspectFit
        mediaChangeBadge_Retrs.addSubview(changeIcon_Retrs)
        changeIcon_Retrs.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(13)
        }
        let changeLabel_Retrs = UILabel()
        changeLabel_Retrs.text = "Change"
        changeLabel_Retrs.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        changeLabel_Retrs.textColor = .white
        mediaChangeBadge_Retrs.addSubview(changeLabel_Retrs)
        changeLabel_Retrs.snp.makeConstraints { make in
            make.leading.equalTo(changeIcon_Retrs.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-12)
        }

        let tap_Retrs = UITapGestureRecognizer(target: self, action: #selector(pickMediaTapped_Retrs))
        mediaCard_Retrs.addGestureRecognizer(tap_Retrs)
        mediaCard_Retrs.isUserInteractionEnabled = true
    }

    /// 相机型号输入卡片
    private func setupCameraCard_Retrs() {
        styleInputCard_Retrs(cameraCard_Retrs)
        contentView_Retrs.addSubview(cameraCard_Retrs)

        let header_Retrs = makeSectionHeader_Retrs(title_Retrs: "Camera Model", icon_Retrs: "camera.fill")
        cameraCard_Retrs.addSubview(header_Retrs)
        header_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(18)
        }

        let fieldWrap_Retrs = makeInputWrap_Retrs()
        cameraCard_Retrs.addSubview(fieldWrap_Retrs)
        fieldWrap_Retrs.snp.makeConstraints { make in
            make.top.equalTo(header_Retrs.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(46)
            make.bottom.equalToSuperview().offset(-16)
        }

        cameraField_Retrs.placeholder = "e.g. Canon PowerShot A620"
        cameraField_Retrs.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        cameraField_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        cameraField_Retrs.backgroundColor = .clear
        cameraField_Retrs.autocorrectionType = .no
        cameraField_Retrs.leftView = makeIconPad_Retrs(iconName_Retrs: "textformat.alt")
        cameraField_Retrs.leftViewMode = .always
        fieldWrap_Retrs.addSubview(cameraField_Retrs)
        cameraField_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 使用心得输入卡片
    private func setupNotesCard_Retrs() {
        styleInputCard_Retrs(notesCard_Retrs)
        contentView_Retrs.addSubview(notesCard_Retrs)

        let header_Retrs = makeSectionHeader_Retrs(title_Retrs: "Notes & Tips", icon_Retrs: "text.alignleft")
        notesCard_Retrs.addSubview(header_Retrs)
        header_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(18)
        }

        let tvWrap_Retrs = makeInputWrap_Retrs()
        notesCard_Retrs.addSubview(tvWrap_Retrs)
        tvWrap_Retrs.snp.makeConstraints { make in
            make.top.equalTo(header_Retrs.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(120)
        }

        notesTextView_Retrs.font = UIFont.systemFont(ofSize: 14)
        notesTextView_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        notesTextView_Retrs.backgroundColor = .clear
        notesTextView_Retrs.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        notesTextView_Retrs.delegate = self
        tvWrap_Retrs.addSubview(notesTextView_Retrs)
        notesTextView_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }

        notesPlaceholder_Retrs.text = "Share your shooting settings, keeper tips..."
        notesPlaceholder_Retrs.font = UIFont.systemFont(ofSize: 14)
        notesPlaceholder_Retrs.textColor = ColorConfig_Retrs.textPlaceholder_Retrs
        tvWrap_Retrs.addSubview(notesPlaceholder_Retrs)
        notesPlaceholder_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
        }

        let countRow_Retrs = UIView()
        notesCard_Retrs.addSubview(countRow_Retrs)
        countRow_Retrs.snp.makeConstraints { make in
            make.top.equalTo(tvWrap_Retrs.snp.bottom).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-14)
            make.height.equalTo(16)
        }

        charCountLabel_Retrs.text = "0 / 200"
        charCountLabel_Retrs.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        charCountLabel_Retrs.textColor = ColorConfig_Retrs.textPlaceholder_Retrs
        countRow_Retrs.addSubview(charCountLabel_Retrs)
        charCountLabel_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 为输入卡片应用统一样式（白色背景 + 圆角 + 紫色调阴影）
    private func styleInputCard_Retrs(_ card_Retrs: UIView) {
        card_Retrs.backgroundColor = .white
        card_Retrs.layer.cornerRadius = 18
        card_Retrs.clipsToBounds = false
        card_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs.withAlphaComponent(0.1).cgColor
        card_Retrs.layer.shadowOffset = CGSize(width: 0, height: 4)
        card_Retrs.layer.shadowOpacity = 1.0
        card_Retrs.layer.shadowRadius = 12
    }

    /// 创建区块标题行（图标 + 标题）
    private func makeSectionHeader_Retrs(title_Retrs: String, icon_Retrs: String) -> UIView {
        let row_Retrs = UIView()
        let iv_Retrs = UIImageView(
            image: UIImage(systemName: icon_Retrs,
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold))
        )
        iv_Retrs.tintColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        iv_Retrs.contentMode = .scaleAspectFit
        row_Retrs.addSubview(iv_Retrs)
        iv_Retrs.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }
        let lbl_Retrs = UILabel()
        lbl_Retrs.text = title_Retrs
        lbl_Retrs.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        lbl_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        row_Retrs.addSubview(lbl_Retrs)
        lbl_Retrs.snp.makeConstraints { make in
            make.leading.equalTo(iv_Retrs.snp.trailing).offset(6)
            make.centerY.trailing.equalToSuperview()
        }
        return row_Retrs
    }

    /// 创建输入框背景容器（浅紫 + 圆角）
    private func makeInputWrap_Retrs() -> UIView {
        let wrap_Retrs = UIView()
        wrap_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#EEF2FF")
        wrap_Retrs.layer.cornerRadius = 12
        return wrap_Retrs
    }

    /// 创建输入框左侧图标 pad（leftView 用）
    private func makeIconPad_Retrs(iconName_Retrs: String) -> UIView {
        let pad_Retrs = UIView(frame: CGRect(x: 0, y: 0, width: 38, height: 46))
        let iv_Retrs  = UIImageView(
            image: UIImage(systemName: iconName_Retrs,
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .medium))
        )
        iv_Retrs.tintColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        iv_Retrs.contentMode = .scaleAspectFit
        iv_Retrs.frame = CGRect(x: 12, y: 11, width: 16, height: 24)
        pad_Retrs.addSubview(iv_Retrs)
        return pad_Retrs
    }

    /// 更新虚线边框路径（在 layoutSubviews 后调用）
    private func updateDashBorder_Retrs() {
        let path_Retrs = UIBezierPath(roundedRect: mediaCard_Retrs.bounds, cornerRadius: 20)
        mediaDashLayer_Retrs.path = path_Retrs.cgPath
        mediaDashLayer_Retrs.frame = mediaCard_Retrs.bounds
    }

    // MARK: - 提交区域

    /// 提交按钮
    private func setupSubmitArea_Retrs() {
        submitGradLayer_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
        ]
        submitGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0.5)
        submitGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 0.5)
        submitGradLayer_Retrs.cornerRadius = 26
        submitBtn_Retrs.layer.insertSublayer(submitGradLayer_Retrs, at: 0)
        submitBtn_Retrs.layer.cornerRadius = 26
        submitBtn_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs.withAlphaComponent(0.4).cgColor
        submitBtn_Retrs.layer.shadowOffset = CGSize(width: 0, height: 6)
        submitBtn_Retrs.layer.shadowOpacity = 1
        submitBtn_Retrs.layer.shadowRadius = 12
        submitBtn_Retrs.setTitle("Add to Gallery", for: .normal)
        submitBtn_Retrs.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        submitBtn_Retrs.setTitleColor(.white, for: .normal)
        submitBtn_Retrs.addTarget(self, action: #selector(submitTapped_Retrs), for: .touchUpInside)
        contentView_Retrs.addSubview(submitBtn_Retrs)
    }

    // MARK: - 约束

    private func setupConstraints_Retrs() {
        let screenW_Retrs = UIScreen.main.bounds.width
        let safeTop_Retrs = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 44

        navBar_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(safeTop_Retrs + 46)
        }
        closeBtn_Retrs.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(28)
        }
        navTitleLabel_Retrs.snp.makeConstraints { make in
            make.centerY.equalTo(closeBtn_Retrs)
            make.leading.equalTo(closeBtn_Retrs.snp.trailing).offset(10)
        }

        scrollView_Retrs.snp.makeConstraints { make in
            make.top.equalTo(navBar_Retrs.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(screenW_Retrs)
        }

        mediaCard_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(180)
        }

        cameraCard_Retrs.snp.makeConstraints { make in
            make.top.equalTo(mediaCard_Retrs.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        notesCard_Retrs.snp.makeConstraints { make in
            make.top.equalTo(cameraCard_Retrs.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        submitBtn_Retrs.snp.makeConstraints { make in
            make.top.equalTo(notesCard_Retrs.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(52)
            make.bottom.equalToSuperview().offset(-40)
        }
    }

    // MARK: - 事件

    @objc private func closeTapped_Retrs() {
        Navigation_Retrs.dismiss_Retrs(from: self)
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

    /// 选取媒体（图片或视频）
    @objc private func pickMediaTapped_Retrs() {
        MediaPickerHelper_Retrs.pickMedia_Retrs(from: self) { [weak self] result_Retrs in
            guard let self else { return }
            switch result_Retrs {
            case .photo_Retrs(let image_Retrs):
                self.mediaDisplayView_Retrs.configureWithImage_Retrs(image_Retrs: image_Retrs)
                self.mediaPath_Retrs = self.saveImageToDocuments_Retrs(image_Retrs: image_Retrs) ?? ""
                self.updateMediaPickerState_Retrs(hasMedia: true)
            case .video_Retrs(let url_Retrs):
                self.mediaPath_Retrs = url_Retrs.path
                self.mediaDisplayView_Retrs.configure_Retrs(mediaPath_Retrs: url_Retrs.lastPathComponent, isVideo_Retrs: true)
                self.updateMediaPickerState_Retrs(hasMedia: true)
            case .cancelled_Retrs:
                break
            }
        }
    }

    /// 更新媒体选区视觉状态（显示/隐藏占位与更换徽章）
    /// - Parameter hasMedia: 是否已选择媒体
    private func updateMediaPickerState_Retrs(hasMedia: Bool) {
        mediaPlaceholderWrap_Retrs.isHidden = hasMedia
        mediaDashLayer_Retrs.isHidden       = hasMedia
        mediaChangeBadge_Retrs.isHidden     = !hasMedia
    }

    /// 确认提交：校验 → 调用 ViewModel → 关闭页面
    @objc private func submitTapped_Retrs() {
        submitBtn_Retrs.animatePressDown_Retrs { [weak self] in
            self?.submitBtn_Retrs.animatePressUp_Retrs()
        }

        guard userVM_Retrs.isLoggedIn_Retrs else {
            Navigation_Retrs.toLogin_Retrs(style_retrs: .present_retrs)
            return
        }

        let cameraText_Retrs = cameraField_Retrs.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let notesText_Retrs  = notesTextView_Retrs.text.trimmingCharacters(in: .whitespaces)

        guard !cameraText_Retrs.isEmpty else {
            cameraField_Retrs.animateShake_Retrs()
            Utils_Retrs.showWarning_Retrs(message_Retrs: "Please enter a camera model")
            return
        }
        guard !notesText_Retrs.isEmpty else {
            notesTextView_Retrs.animateShake_Retrs()
            Utils_Retrs.showWarning_Retrs(message_Retrs: "Please add some notes")
            return
        }
        guard !mediaPath_Retrs.isEmpty else {
            mediaCard_Retrs.animateShake_Retrs()
            Utils_Retrs.showWarning_Retrs(message_Retrs: "Please add a photo or video")
            return
        }

        titleVM_Retrs.releasePost_Retrs(
            title_retrs: cameraText_Retrs,
            content_retrs: notesText_Retrs,
            media_retrs: mediaPath_Retrs
        )
        Navigation_Retrs.dismiss_Retrs(from: self)
    }

    /// 保存图片到沙盒文档目录，返回完整文件路径
    private func saveImageToDocuments_Retrs(image_Retrs: UIImage) -> String? {
        let fileName_Retrs = "diary_img_\(Int(Date().timeIntervalSince1970)).jpg"
        let docURL_Retrs   = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Retrs  = docURL_Retrs.appendingPathComponent(fileName_Retrs)
        guard let data_Retrs = image_Retrs.jpegData(compressionQuality: 0.8) else { return nil }
        try? data_Retrs.write(to: fileURL_Retrs)
        return fileURL_Retrs.path
    }
}

// MARK: - UITextViewDelegate

extension DiaryPublish_Retrs: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        notesPlaceholder_Retrs.isHidden = !textView.text.isEmpty
        let count_Retrs = min(textView.text.count, 200)
        charCountLabel_Retrs.text = "\(count_Retrs) / 200"
        charCountLabel_Retrs.textColor = textView.text.count > 200
            ? UIColor(hexstring_Retrs: "#FF6B9D")
            : ColorConfig_Retrs.textPlaceholder_Retrs
    }
}
