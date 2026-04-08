import Foundation
import UIKit
import SnapKit

// MARK: 发布

/// 发布页面
/// 核心作用：允许登录用户发布帖子（标题 + 内容 + 单一媒体）
/// 设计思路：渐变顶栏 + 表单卡片 + 媒体预览区，发布前校验登录和非空
/// 关键属性：_selectedImage_Somnia/_selectedVideoURL_Somnia（选中的媒体）
class Release_Somnia: UIViewController {

    // MARK: - 私有属性

    /// 选中的图片（优先使用图片）
    private var _selectedImage_Somnia: UIImage?

    /// 选中的视频 URL
    private var _selectedVideoURL_Somnia: URL?

    // MARK: - UI组件

    private let scrollView_Somnia: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentView_Somnia = UIView()

    /// 自定义导航栏
    private let navBar_Somnia: UIView = {
        let v = UIView()
        return v
    }()

    private var _navGradient_Somnia: CAGradientLayer?

    /// 导航栏主标题
    private let navTitleLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "New Post"
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = .white
        lbl.layer.shadowColor = UIColor.black.cgColor
        lbl.layer.shadowOpacity = 0.10
        lbl.layer.shadowRadius = 4
        return lbl
    }()

    /// 导航栏副标题描述
    private let navSubtitleLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "Express your thoughts & share your story"
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.78)
        lbl.textAlignment = .center
        return lbl
    }()

    /// 表单卡片
    private let formCard_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 24
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 16
        v.layer.shadowOpacity = 0.07
        return v
    }()

    /// 标题输入框
    private let titleField_Somnia: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Post title..."
        tf.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        tf.textColor = ColorConfig_Somnia.textPrimary_Somnia
        tf.borderStyle = .none
        tf.autocorrectionType = .no
        return tf
    }()

    private let divider1_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Somnia.divider_Somnia
        return v
    }()

    /// 内容输入框
    private let contentTextView_Somnia: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tv.textColor = ColorConfig_Somnia.textPrimary_Somnia
        tv.backgroundColor = .clear
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.isScrollEnabled = false
        return tv
    }()

    /// 内容占位符
    private let contentPlaceholder_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "Share your story..."
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lbl.textColor = ColorConfig_Somnia.textPlaceholder_Somnia
        lbl.numberOfLines = 0
        lbl.isUserInteractionEnabled = false
        return lbl
    }()

    private let divider2_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Somnia.divider_Somnia
        return v
    }()

    /// 媒体选择区域
    private let mediaPickerView_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia
        v.layer.cornerRadius = 16
        v.layer.borderColor = ColorConfig_Somnia.border_Somnia.cgColor
        v.layer.borderWidth = 1.5
        v.isUserInteractionEnabled = true
        return v
    }()

    /// 媒体预览展示
    private let mediaDisplayView_Somnia = MediaDisplayView_Somnia()

    private let mediaPlaceholderLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "Tap to add photo or video"
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = ColorConfig_Somnia.textPlaceholder_Somnia
        lbl.textAlignment = .center
        return lbl
    }()

    private let mediaPlaceholderIcon_Somnia: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "photo.badge.plus")
        let cfg = UIImage.SymbolConfiguration(pointSize: 32, weight: .light)
        iv.image = UIImage(systemName: "photo.badge.plus", withConfiguration: cfg)
        iv.tintColor = ColorConfig_Somnia.textPlaceholder_Somnia
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let removeMediaButton_Somnia: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        btn.layer.cornerRadius = 14
        btn.isHidden = true
        return btn
    }()

    /// 发布按钮
    private let publishButton_Somnia: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Publish", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 14
        btn.layer.masksToBounds = true
        return btn
    }()

    private var publishGradient_Somnia: CAGradientLayer?

    /// EULA 按钮（带下划线）
    private let eulaButton_Somnia: UIButton = {
        let btn = UIButton(type: .system)
        let attrs_Somnia: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: ColorConfig_Somnia.textSecondary_Somnia,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        btn.setAttributedTitle(NSAttributedString(string: "End User License Agreement (EULA)", attributes: attrs_Somnia), for: .normal)
        return btn
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Somnia()
        setupActions_Somnia()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _navGradient_Somnia?.frame = navBar_Somnia.bounds
        publishGradient_Somnia?.frame = publishButton_Somnia.bounds
    }

    // MARK: - 私有方法 - UI设置

    private func setupUI_Somnia() {
        view.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia

        view.addSubview(navBar_Somnia)
        navBar_Somnia.addSubview(navTitleLabel_Somnia)
        navBar_Somnia.addSubview(navSubtitleLabel_Somnia)
        view.addSubview(scrollView_Somnia)
        scrollView_Somnia.addSubview(contentView_Somnia)

        contentView_Somnia.addSubview(formCard_Somnia)
        formCard_Somnia.addSubview(titleField_Somnia)
        formCard_Somnia.addSubview(divider1_Somnia)
        formCard_Somnia.addSubview(contentTextView_Somnia)
        contentTextView_Somnia.addSubview(contentPlaceholder_Somnia)
        formCard_Somnia.addSubview(divider2_Somnia)
        formCard_Somnia.addSubview(mediaPickerView_Somnia)
        mediaPickerView_Somnia.addSubview(mediaDisplayView_Somnia)
        mediaPickerView_Somnia.addSubview(mediaPlaceholderIcon_Somnia)
        mediaPickerView_Somnia.addSubview(mediaPlaceholderLabel_Somnia)
        mediaPickerView_Somnia.addSubview(removeMediaButton_Somnia)

        contentView_Somnia.addSubview(publishButton_Somnia)
        contentView_Somnia.addSubview(eulaButton_Somnia)

        // 导航栏渐变
        let grad_Somnia = CAGradientLayer()
        grad_Somnia.colors = [
            ColorConfig_Somnia.secondaryGradientStart_Somnia.cgColor,
            ColorConfig_Somnia.secondaryGradientEnd_Somnia.cgColor
        ]
        grad_Somnia.startPoint = CGPoint(x: 0, y: 0)
        grad_Somnia.endPoint = CGPoint(x: 1, y: 0)
        navBar_Somnia.layer.insertSublayer(grad_Somnia, at: 0)
        _navGradient_Somnia = grad_Somnia

        navBar_Somnia.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(76)
        }

        navTitleLabel_Somnia.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(navSubtitleLabel_Somnia.snp.top).offset(-3)
        }

        navSubtitleLabel_Somnia.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
        }

        scrollView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(navBar_Somnia.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        contentView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        formCard_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview().inset(16)
        }

        titleField_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        divider1_Somnia.snp.makeConstraints { make in
            make.top.equalTo(titleField_Somnia.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }

        contentTextView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(divider1_Somnia.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(100)
        }

        contentPlaceholder_Somnia.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }

        divider2_Somnia.snp.makeConstraints { make in
            make.top.equalTo(contentTextView_Somnia.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }

        mediaPickerView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(divider2_Somnia.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(180)
            make.bottom.equalToSuperview().offset(-20)
        }

        mediaDisplayView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mediaPlaceholderIcon_Somnia.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-12)
            make.width.height.equalTo(40)
        }

        mediaPlaceholderLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(mediaPlaceholderIcon_Somnia.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
        }

        removeMediaButton_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.width.height.equalTo(28)
        }

        publishButton_Somnia.snp.makeConstraints { make in
            make.top.equalTo(formCard_Somnia.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(56)
        }

        eulaButton_Somnia.snp.makeConstraints { make in
            make.top.equalTo(publishButton_Somnia.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }

        contentTextView_Somnia.delegate = self

        // 发布按钮渐变
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let grad_Somnia = CAGradientLayer()
            grad_Somnia.colors = [
                ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
            ]
            grad_Somnia.startPoint = CGPoint(x: 0, y: 0)
            grad_Somnia.endPoint = CGPoint(x: 1, y: 0)
            grad_Somnia.frame = self.publishButton_Somnia.bounds
            self.publishButton_Somnia.layer.insertSublayer(grad_Somnia, at: 0)
            self.publishGradient_Somnia = grad_Somnia
        }
    }

    private func setupActions_Somnia() {
        // 点击媒体区域选择图片/视频
        let tap_Somnia = UITapGestureRecognizer(target: self, action: #selector(handleMediaPick_Somnia))
        mediaPickerView_Somnia.addGestureRecognizer(tap_Somnia)

        removeMediaButton_Somnia.addAction(UIAction { [weak self] _ in
            self?.clearMedia_Somnia()
        }, for: .touchUpInside)

        publishButton_Somnia.addAction(UIAction { [weak self] _ in
            self?.handlePublish_Somnia()
        }, for: .touchUpInside)

        eulaButton_Somnia.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            ProtocolHelper_Somnia.showProtocol_Somnia(
                type_Somnia: .eula_Somnia,
                content_Somnia: "eula.png",
                from: self
            )
        }, for: .touchUpInside)

        let bgTap_Somnia = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Somnia))
        bgTap_Somnia.cancelsTouchesInView = false
        view.addGestureRecognizer(bgTap_Somnia)
    }

    // MARK: - 私有方法 - 业务逻辑

    /// 选择媒体
    @objc private func handleMediaPick_Somnia() {
        MediaPickerHelper_Somnia.pickMedia_Somnia(from: self) { [weak self] result_Somnia in
            guard let self = self else { return }
            switch result_Somnia {
            case .photo_Somnia(let image_Somnia):
                self._selectedImage_Somnia = image_Somnia
                self._selectedVideoURL_Somnia = nil
                self.mediaDisplayView_Somnia.configureWithImage_Somnia(image_Somnia: image_Somnia)
                self.showMediaSelected_Somnia()

            case .video_Somnia(let url_Somnia):
                self._selectedImage_Somnia = nil
                self._selectedVideoURL_Somnia = url_Somnia
                self.mediaDisplayView_Somnia.configure_Somnia(mediaPath_Somnia: url_Somnia.path, isVideo_Somnia: true)
                self.showMediaSelected_Somnia()

            case .cancelled_Somnia:
                break
            }
        }
    }

    /// 展示已选媒体状态（隐藏占位符，显示移除按钮）
    private func showMediaSelected_Somnia() {
        mediaPlaceholderIcon_Somnia.isHidden = true
        mediaPlaceholderLabel_Somnia.isHidden = true
        removeMediaButton_Somnia.isHidden = false
    }

    /// 清除选中的媒体
    private func clearMedia_Somnia() {
        _selectedImage_Somnia = nil
        _selectedVideoURL_Somnia = nil
        mediaDisplayView_Somnia.configure_Somnia(mediaPath_Somnia: nil)
        mediaPlaceholderIcon_Somnia.isHidden = false
        mediaPlaceholderLabel_Somnia.isHidden = false
        removeMediaButton_Somnia.isHidden = true
    }

    /// 处理发布
    private func handlePublish_Somnia() {
        // 1. 检查是否已登录
        guard UserViewModel_Somnia.shared_Somnia.isLoggedIn_Somnia else {
            Navigation_Somnia.toLogin_Somnia(style_somnia: .present_somnia)
            return
        }

        let title_Somnia = titleField_Somnia.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let content_Somnia = contentTextView_Somnia.text?.trimmingCharacters(in: .whitespaces) ?? ""

        // 2. 非空校验
        guard !title_Somnia.isEmpty else {
            Utils_Somnia.showWarning_Somnia(message_Somnia: "Please enter a title")
            return
        }
        guard !content_Somnia.isEmpty else {
            Utils_Somnia.showWarning_Somnia(message_Somnia: "Please write some content")
            return
        }
        guard _selectedImage_Somnia != nil || _selectedVideoURL_Somnia != nil else {
            Utils_Somnia.showWarning_Somnia(message_Somnia: "Please add a photo or video")
            return
        }

        // 3. 保存媒体到本地，获取路径
        let mediaPath_Somnia = saveMedia_Somnia()

        // 4. 调用 ViewModel 发布
        Task { @MainActor in
            TitleViewModel_Somnia.shared_Somnia.releasePost_Somnia(
                title_somnia: title_Somnia,
                content_somnia: content_Somnia,
                media_somnia: mediaPath_Somnia
            )
        }

        // 5. 清空页面数据
        clearForm_Somnia()
    }

    /// 保存媒体到本地并返回路径
    /// - Returns: 本地文件路径或空字符串
    private func saveMedia_Somnia() -> String {
        let docDir_Somnia = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        if let image_Somnia = _selectedImage_Somnia {
            let fileName_Somnia = "post_img_\(Int(Date().timeIntervalSince1970)).jpg"
            let url_Somnia = docDir_Somnia.appendingPathComponent(fileName_Somnia)
            if let data_Somnia = image_Somnia.jpegData(compressionQuality: 0.8) {
                try? data_Somnia.write(to: url_Somnia)
                return url_Somnia.path
            }
        } else if let videoURL_Somnia = _selectedVideoURL_Somnia {
            return videoURL_Somnia.path
        }
        return ""
    }

    /// 清空表单数据
    private func clearForm_Somnia() {
        titleField_Somnia.text = ""
        contentTextView_Somnia.text = ""
        contentPlaceholder_Somnia.isHidden = false
        clearMedia_Somnia()
    }

    @objc private func dismissKeyboard_Somnia() { view.endEditing(true) }
}

// MARK: - UITextViewDelegate

extension Release_Somnia: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        contentPlaceholder_Somnia.isHidden = !textView.text.isEmpty
    }
}
