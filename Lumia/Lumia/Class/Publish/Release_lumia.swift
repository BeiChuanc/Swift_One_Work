import Foundation
import UIKit
import SnapKit

// MARK: - 发布页面

/// 发布帖子视图控制器
/// 核心作用：用户创作并发布帖子（标题、内容、单一媒体），支持图片/视频选择
/// 设计思路：胶片风格表单，媒体预览卡片，发布后清空数据
/// 关键方法：
///   - handlePublish_Lumia(): 校验后调用 TitleViewModel.releasePost_Lumia
class Release_Lumia: UIViewController {

    // MARK: - 私有属性

    private var selectedImage_Lumia: UIImage?
    private var selectedVideoUrl_Lumia: URL?

    // MARK: - UI组件

    private let scrollView_Lumia: UIScrollView = {
        let sv_Lumia = UIScrollView()
        sv_Lumia.showsVerticalScrollIndicator = false
        sv_Lumia.alwaysBounceVertical = true
        sv_Lumia.keyboardDismissMode = .onDrag
        return sv_Lumia
    }()

    private let contentView_Lumia = UIView()

    /// 顶部栏
    private let topBar_Lumia = UIView()
    private var topGradient_Lumia: CAGradientLayer?


    private let pageTitleLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "New Post"
        lbl_Lumia.font = UIFont(name: "AvenirNext-Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)
        lbl_Lumia.textColor = .white
        return lbl_Lumia
    }()

    private let pageSubtitle_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Share your film moment"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl_Lumia.textColor = UIColor.white.withAlphaComponent(0.75)
        return lbl_Lumia
    }()

    /// 媒体选择区域
    private let mediaCard_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = .white
        v_Lumia.layer.cornerRadius = 20
        v_Lumia.layer.shadowColor = UIColor.black.cgColor
        v_Lumia.layer.shadowOpacity = 0.08
        v_Lumia.layer.shadowRadius = 12
        v_Lumia.layer.shadowOffset = CGSize(width: 0, height: 3)
        return v_Lumia
    }()

    private let mediaDisplayView_Lumia: MediaDisplayView_Lumia = {
        let mv_Lumia = MediaDisplayView_Lumia()
        mv_Lumia.layer.cornerRadius = 14
        mv_Lumia.clipsToBounds = true
        return mv_Lumia
    }()

    private let mediaBadge_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F6A623")
        v_Lumia.layer.cornerRadius = 14
        v_Lumia.isHidden = true
        return v_Lumia
    }()

    private let mediaBadgeLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl_Lumia.textColor = .white
        return lbl_Lumia
    }()

    private let selectMediaButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        btn_Lumia.setTitle("Select Photo / Video", for: .normal)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn_Lumia.setTitleColor(ColorConfig_Lumia.primaryGradientStart_Lumia, for: .normal)
        btn_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#F7F3EE")
        btn_Lumia.layer.cornerRadius = 10
        btn_Lumia.layer.borderWidth = 1
        btn_Lumia.layer.borderColor = ColorConfig_Lumia.primaryGradientStart_Lumia.withAlphaComponent(0.4).cgColor
        return btn_Lumia
    }()

    /// 表单卡片
    private let formCard_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = .white
        v_Lumia.layer.cornerRadius = 20
        v_Lumia.layer.shadowColor = UIColor.black.cgColor
        v_Lumia.layer.shadowOpacity = 0.08
        v_Lumia.layer.shadowRadius = 12
        v_Lumia.layer.shadowOffset = CGSize(width: 0, height: 3)
        return v_Lumia
    }()

    private let titleInputLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Title"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl_Lumia.textColor = ColorConfig_Lumia.textSecondary_Lumia
        return lbl_Lumia
    }()

    private let titleField_Lumia: UITextField = {
        let tf_Lumia = UITextField()
        tf_Lumia.placeholder = "Give your moment a title..."
        tf_Lumia.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        tf_Lumia.textColor = ColorConfig_Lumia.textPrimary_Lumia
        tf_Lumia.returnKeyType = .next
        return tf_Lumia
    }()

    private let divider_Lumia: UIView = {
        let v_Lumia = UIView()
        v_Lumia.backgroundColor = ColorConfig_Lumia.divider_Lumia
        return v_Lumia
    }()

    private let contentInputLabel_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Story"
        lbl_Lumia.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl_Lumia.textColor = ColorConfig_Lumia.textSecondary_Lumia
        return lbl_Lumia
    }()

    private let contentTextView_Lumia: UITextView = {
        let tv_Lumia = UITextView()
        tv_Lumia.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tv_Lumia.textColor = ColorConfig_Lumia.textPrimary_Lumia
        tv_Lumia.backgroundColor = .clear
        tv_Lumia.textContainerInset = .zero
        tv_Lumia.textContainer.lineFragmentPadding = 0
        return tv_Lumia
    }()

    private let contentPlaceholder_Lumia: UILabel = {
        let lbl_Lumia = UILabel()
        lbl_Lumia.text = "Describe the moment behind your film..."
        lbl_Lumia.font = UIFont.systemFont(ofSize: 14)
        lbl_Lumia.textColor = ColorConfig_Lumia.textPlaceholder_Lumia
        lbl_Lumia.isUserInteractionEnabled = false
        return lbl_Lumia
    }()

    /// 发布按钮
    private let publishButton_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .system)
        btn_Lumia.setTitle("Publish", for: .normal)
        btn_Lumia.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn_Lumia.setTitleColor(.white, for: .normal)
        btn_Lumia.layer.cornerRadius = 24
        return btn_Lumia
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lumia()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topGradient_Lumia?.frame = topBar_Lumia.bounds
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        view.backgroundColor = UIColor(hexstring_Lumia: "#F7F3EE")

        // 顶部渐变栏
        view.addSubview(topBar_Lumia)
        topBar_Lumia.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(110)
        }
        let gradient_Lumia = CAGradientLayer()
        gradient_Lumia.colors = [
            UIColor(hexstring_Lumia: "#F6A623").cgColor,
            UIColor(hexstring_Lumia: "#D4654E").cgColor
        ]
        gradient_Lumia.startPoint = CGPoint(x: 0, y: 0)
        gradient_Lumia.endPoint = CGPoint(x: 1, y: 1)
        topBar_Lumia.layer.insertSublayer(gradient_Lumia, at: 0)
        topBar_Lumia.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        topBar_Lumia.layer.cornerRadius = 24
        topGradient_Lumia = gradient_Lumia

        topBar_Lumia.addSubview(pageTitleLabel_Lumia)
        pageTitleLabel_Lumia.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-24)
            make.leading.equalToSuperview().offset(20)
        }

        topBar_Lumia.addSubview(pageSubtitle_Lumia)
        pageSubtitle_Lumia.snp.makeConstraints { make in
            make.top.equalTo(pageTitleLabel_Lumia.snp.bottom).offset(2)
            make.leading.equalTo(pageTitleLabel_Lumia)
        }

        // 滚动视图
        view.addSubview(scrollView_Lumia)
        scrollView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(topBar_Lumia.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
        scrollView_Lumia.addSubview(contentView_Lumia)
        contentView_Lumia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        setupMediaCard_Lumia()
        setupFormCard_Lumia()
        setupPublishButton_Lumia()
    }

    private func setupMediaCard_Lumia() {
        contentView_Lumia.addSubview(mediaCard_Lumia)
        mediaCard_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        mediaCard_Lumia.addSubview(mediaDisplayView_Lumia)
        mediaDisplayView_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(200)
        }

        mediaCard_Lumia.addSubview(mediaBadge_Lumia)
        mediaBadge_Lumia.snp.makeConstraints { make in
            make.top.equalTo(mediaDisplayView_Lumia).offset(8)
            make.leading.equalTo(mediaDisplayView_Lumia).offset(8)
            make.height.equalTo(28)
        }
        mediaBadge_Lumia.addSubview(mediaBadgeLabel_Lumia)
        mediaBadgeLabel_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
        }

        mediaCard_Lumia.addSubview(selectMediaButton_Lumia)
        selectMediaButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(mediaDisplayView_Lumia.snp.bottom).offset(10)
            make.leading.trailing.equalTo(mediaDisplayView_Lumia)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-12)
        }
        selectMediaButton_Lumia.addTarget(self, action: #selector(handleSelectMedia_Lumia), for: .touchUpInside)
    }

    private func setupFormCard_Lumia() {
        contentView_Lumia.addSubview(formCard_Lumia)
        formCard_Lumia.snp.makeConstraints { make in
            make.top.equalTo(mediaCard_Lumia.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        formCard_Lumia.addSubview(titleInputLabel_Lumia)
        titleInputLabel_Lumia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
        }

        formCard_Lumia.addSubview(titleField_Lumia)
        titleField_Lumia.delegate = self
        titleField_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleInputLabel_Lumia.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(36)
        }

        formCard_Lumia.addSubview(divider_Lumia)
        divider_Lumia.snp.makeConstraints { make in
            make.top.equalTo(titleField_Lumia.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(0.5)
        }

        formCard_Lumia.addSubview(contentInputLabel_Lumia)
        contentInputLabel_Lumia.snp.makeConstraints { make in
            make.top.equalTo(divider_Lumia.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
        }

        formCard_Lumia.addSubview(contentTextView_Lumia)
        contentTextView_Lumia.delegate = self
        contentTextView_Lumia.snp.makeConstraints { make in
            make.top.equalTo(contentInputLabel_Lumia.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
            make.bottom.equalToSuperview().offset(-20)
        }

        formCard_Lumia.addSubview(contentPlaceholder_Lumia)
        contentPlaceholder_Lumia.snp.makeConstraints { make in
            make.top.leading.equalTo(contentTextView_Lumia)
        }
    }

    private func setupPublishButton_Lumia() {
        contentView_Lumia.addSubview(publishButton_Lumia)
        publishButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(formCard_Lumia.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(48)
        }
        let gradientBtn_Lumia = UIColor.createPrimaryGradientLayer_Lumia(
            frame_Lumia: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 48, height: 48)
        )
        gradientBtn_Lumia.cornerRadius = 24
        publishButton_Lumia.layer.insertSublayer(gradientBtn_Lumia, at: 0)
        publishButton_Lumia.addTarget(self, action: #selector(handlePublish_Lumia), for: .touchUpInside)

        // EULA 按钮（发布按钮下方 10）
        let eulaButton_Lumia = UIButton(type: .system)
        let eulaFullText_Lumia = "EULA"
        let eulaAttr_Lumia = NSMutableAttributedString(string: eulaFullText_Lumia)
        let fullRange_Lumia = NSRange(location: 0, length: eulaAttr_Lumia.length)
        // 动态计算 "EULA" 的位置，避免硬编码越界
        let eulaKeyword_Lumia = "EULA"
        let eulaRange_Lumia: NSRange
        if let swiftRange_Lumia = eulaFullText_Lumia.range(of: eulaKeyword_Lumia) {
            eulaRange_Lumia = NSRange(swiftRange_Lumia, in: eulaFullText_Lumia)
        } else {
            eulaRange_Lumia = NSRange(location: eulaAttr_Lumia.length - 4, length: 4)
        }
        let prefixRange_Lumia = NSRange(location: 0, length: eulaRange_Lumia.location)
        eulaAttr_Lumia.addAttribute(.font, value: UIFont.systemFont(ofSize: 12), range: fullRange_Lumia)
        eulaAttr_Lumia.addAttribute(.foregroundColor, value: ColorConfig_Lumia.textSecondary_Lumia, range: prefixRange_Lumia)
        eulaAttr_Lumia.addAttribute(.foregroundColor, value: ColorConfig_Lumia.primaryGradientStart_Lumia, range: eulaRange_Lumia)
        eulaAttr_Lumia.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: eulaRange_Lumia)
        eulaAttr_Lumia.addAttribute(.underlineColor, value: ColorConfig_Lumia.primaryGradientStart_Lumia, range: eulaRange_Lumia)
        eulaButton_Lumia.setAttributedTitle(eulaAttr_Lumia, for: .normal)
        contentView_Lumia.addSubview(eulaButton_Lumia)
        eulaButton_Lumia.snp.makeConstraints { make in
            make.top.equalTo(publishButton_Lumia.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
        }
        eulaButton_Lumia.addTarget(self, action: #selector(handleEula_Lumia), for: .touchUpInside)
    }

    // MARK: - 事件处理

    @objc private func handleClose_Lumia() {
        Navigation_Lumia.dismiss_Lumia()
    }

    /// 选择媒体
    @objc private func handleSelectMedia_Lumia() {
        MediaPickerHelper_Lumia.pickMedia_Lumia(from: self) { [weak self] result_Lumia in
            guard let self = self else { return }
            switch result_Lumia {
            case .photo_Lumia(let image_Lumia):
                self.selectedImage_Lumia = image_Lumia
                self.selectedVideoUrl_Lumia = nil
                self.mediaDisplayView_Lumia.configureWithImage_Lumia(image_Lumia: image_Lumia)
                self.mediaBadge_Lumia.isHidden = false
                self.mediaBadgeLabel_Lumia.text = "📷 Photo"
            case .video_Lumia(let url_Lumia):
                self.selectedVideoUrl_Lumia = url_Lumia
                self.selectedImage_Lumia = nil
                self.mediaDisplayView_Lumia.configure_Lumia(
                    mediaPath_Lumia: url_Lumia.path, isVideo_Lumia: true
                )
                self.mediaBadge_Lumia.isHidden = false
                self.mediaBadgeLabel_Lumia.text = "🎬 Video"
            case .cancelled_Lumia:
                break
            }
        }
    }

    /// 发布
    @objc private func handlePublish_Lumia() {
        // 校验是否登录
        guard UserViewModel_Lumia.shared_Lumia.isLoggedIn_Lumia else {
            Utils_Lumia.showWarning_Lumia(message_Lumia: "Please login first.")
            Navigation_Lumia.toLogin_Lumia()
            return
        }

        let title_Lumia = titleField_Lumia.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let content_Lumia = contentTextView_Lumia.text?.trimmingCharacters(in: .whitespaces) ?? ""

        guard !title_Lumia.isEmpty else {
            Utils_Lumia.showWarning_Lumia(message_Lumia: "Please enter a title.")
            return
        }
        guard !content_Lumia.isEmpty else {
            Utils_Lumia.showWarning_Lumia(message_Lumia: "Please write your story.")
            return
        }
        guard selectedImage_Lumia != nil || selectedVideoUrl_Lumia != nil else {
            Utils_Lumia.showWarning_Lumia(message_Lumia: "Please select a photo or video.")
            return
        }

        view.endEditing(true)
        publishButton_Lumia.animatePressDown_Lumia { self.publishButton_Lumia.animatePressUp_Lumia() }

        // 构建媒体路径
        let mediaPath_Lumia: String
        if let image_Lumia = selectedImage_Lumia {
            mediaPath_Lumia = saveImageToDocuments_Lumia(image: image_Lumia) ?? "photo.fill"
        } else if let url_Lumia = selectedVideoUrl_Lumia {
            mediaPath_Lumia = url_Lumia.path
        } else {
            mediaPath_Lumia = "photo.fill"
        }

        Task { @MainActor in
            TitleViewModel_Lumia.shared_Lumia.releasePost_Lumia(
                title_lumia: title_Lumia,
                content_lumia: content_Lumia,
                media_lumia: mediaPath_Lumia
            )
        }

        clearForm_Lumia()
        Navigation_Lumia.dismiss_Lumia()
    }

    /// EULA 点击
    @objc private func handleEula_Lumia() {
        ProtocolHelper_Lumia.showProtocol_Lumia(
            type_Lumia: .eula_Lumia,
            content_Lumia: "eula_image",
            from: self
        )
    }

    /// 清空表单
    private func clearForm_Lumia() {
        titleField_Lumia.text = ""
        contentTextView_Lumia.text = ""
        contentPlaceholder_Lumia.isHidden = false
        selectedImage_Lumia = nil
        selectedVideoUrl_Lumia = nil
        mediaDisplayView_Lumia.configure_Lumia(mediaPath_Lumia: nil)
        mediaBadge_Lumia.isHidden = true
    }

    /// 保存图片到文档目录，返回路径
    private func saveImageToDocuments_Lumia(image: UIImage) -> String? {
        guard let data_Lumia = image.jpegData(compressionQuality: 0.8) else { return nil }
        let fileName_Lumia = "post_\(Int(Date().timeIntervalSince1970)).jpg"
        let url_Lumia = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName_Lumia)
        try? data_Lumia.write(to: url_Lumia)
        return url_Lumia.path
    }
}

// MARK: - UITextFieldDelegate

extension Release_Lumia: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentTextView_Lumia.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension Release_Lumia: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        contentPlaceholder_Lumia.isHidden = !textView.text.isEmpty
    }
}
