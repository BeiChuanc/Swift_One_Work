import UIKit
import SnapKit

// MARK: - 快速记录半弹窗

/// 快速记录半弹窗页面
/// 核心作用：让用户快速上传一条窗景记录，包含标题/描述/图片/主题类型
/// 设计思路：分节卡片表单 + 各字段独立 Section 卡片 + 渐变发布按钮
/// 关键回调：onPublished_Pane - 发布成功后通知调用方刷新
class HomeQuickRecordSheet_Pane: UIViewController {

    // MARK: - 回调

    var onPublished_Pane: (() -> Void)?

    // MARK: - 私有属性

    private var selectedImage_Pane: UIImage?
    private var selectedTheme_Pane: WindowTheme_Pane = .windowView_pane
    private var themeButtons_Pane: [UIButton] = []

    // MARK: - UI 顶层容器

    private let scrollView_Pane: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode  = .interactive
        return sv
    }()

    private let contentStack_Pane: UIStackView = {
        let sv = UIStackView()
        sv.axis    = .vertical
        sv.spacing = 16
        return sv
    }()

    // MARK: - 标题字段

    private let titleSectionCard_Pane = UIView()

    private let titleFieldLabel_Pane: UILabel = {
        let l = UILabel()
        l.text      = "Title"
        l.font      = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = ColorConfig_Pane.textSecondary_Pane
        return l
    }()

    private let titleField_Pane: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter a window title..."
        tf.font        = .systemFont(ofSize: 15, weight: .regular)
        tf.textColor   = ColorConfig_Pane.textPrimary_Pane
        tf.returnKeyType = .next
        tf.clearButtonMode = .whileEditing
        tf.leftView    = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        tf.leftViewMode = .always
        return tf
    }()

    private let titleDivider_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.divider_Pane
        return v
    }()

    // MARK: - 描述字段

    private let descSectionCard_Pane = UIView()

    private let descFieldLabel_Pane: UILabel = {
        let l = UILabel()
        l.text      = "Description"
        l.font      = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = ColorConfig_Pane.textSecondary_Pane
        return l
    }()

    private let descTextView_Pane: UITextView = {
        let tv = UITextView()
        tv.font               = .systemFont(ofSize: 14)
        tv.textColor          = ColorConfig_Pane.textPrimary_Pane
        tv.backgroundColor    = .clear
        tv.textContainerInset = UIEdgeInsets(top: 0, left: -4, bottom: 8, right: 0)
        tv.isScrollEnabled    = false
        return tv
    }()

    private let descPlaceholder_Pane: UILabel = {
        let l = UILabel()
        l.text          = "Describe what you see through this window..."
        l.font          = .systemFont(ofSize: 14)
        l.textColor     = ColorConfig_Pane.textPlaceholder_Pane
        l.numberOfLines = 0
        l.isUserInteractionEnabled = false
        return l
    }()

    // MARK: - 图片选择区

    private let mediaSectionCard_Pane = UIView()

    private let mediaFieldLabel_Pane: UILabel = {
        let l = UILabel()
        l.text      = "Photo"
        l.font      = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = ColorConfig_Pane.textSecondary_Pane
        return l
    }()

    private let mediaContainer_Pane: UIView = {
        let v = UIView()
        v.backgroundColor    = ColorConfig_Pane.backgroundPrimary_Pane
        v.layer.cornerRadius = 12
        v.clipsToBounds      = true
        return v
    }()

    /// 未选择图片时的占位视图
    private let mediaPlaceholder_Pane: UIView = {
        let v = UIView()
        let cfg   = UIImage.SymbolConfiguration(pointSize: 28, weight: .ultraLight)
        let icon  = UIImageView(image: UIImage(systemName: "photo.badge.plus", withConfiguration: cfg))
        icon.tintColor   = ColorConfig_Pane.primaryGradientStart_Pane
        icon.contentMode = .scaleAspectFit
        let label = UILabel()
        label.text      = "Tap to add a photo"
        label.font      = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = ColorConfig_Pane.primaryGradientStart_Pane
        label.textAlignment = .center
        let sv = UIStackView(arrangedSubviews: [icon, label])
        sv.axis      = .vertical
        sv.spacing   = 8
        sv.alignment = .center
        sv.isUserInteractionEnabled = false
        v.addSubview(sv)
        sv.snp.makeConstraints { $0.center.equalToSuperview() }
        return v
    }()

    /// 已选择图片的媒体展示视图（使用 MediaDisplayView 替换原始 ImageView）
    private let pickedMediaView_Pane: MediaDisplayView_Pane = {
        let v = MediaDisplayView_Pane()
        v.isHidden = true
        return v
    }()

    /// 删除已选媒体的按钮（选择图片后显示在右上角）
    private let mediaDeleteButton_Pane: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor.black.alpha_Pane(0.5)
        b.layer.cornerRadius = 12
        b.isHidden = true
        return b
    }()

    // MARK: - 主题区

    private let themeSectionCard_Pane = UIView()

    private let themeFieldLabel_Pane: UILabel = {
        let l = UILabel()
        l.text      = "Theme"
        l.font      = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = ColorConfig_Pane.textSecondary_Pane
        return l
    }()

    private let themeScrollView_Pane: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        sv.clipsToBounds = false
        return sv
    }()

    private let themeStack_Pane: UIStackView = {
        let sv = UIStackView()
        sv.axis    = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        return sv
    }()

    // MARK: - 发布按钮

    private let publishButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("Publish Record", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font   = .systemFont(ofSize: 16, weight: .bold)
        b.layer.cornerRadius = 16
        b.layer.shadowColor  = ColorConfig_Pane.primaryGradientStart_Pane.cgColor
        b.layer.shadowOpacity = 0.35
        b.layer.shadowOffset  = CGSize(width: 0, height: 6)
        b.layer.shadowRadius  = 12
        return b
    }()

    private var publishGradient_Pane: CAGradientLayer?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane
        setupNavBar_Pane()
        setupUI_Pane()
        setupThemeChips_Pane()
        observeKeyboard_Pane()
        NotificationCenter.default.addObserver(
            self, selector: #selector(textViewDidChange_Pane),
            name: UITextView.textDidChangeNotification, object: descTextView_Pane
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        publishGradient_Pane?.frame = publishButton_Pane.bounds
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 导航栏

    private func setupNavBar_Pane() {
        title = "Quick Record"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane
        appearance.shadowColor     = .clear
        navigationController?.navigationBar.standardAppearance  = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = ColorConfig_Pane.primaryGradientStart_Pane

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain, target: self, action: #selector(closeTapped_Pane)
        )
    }

    // MARK: - 整体 UI

    private func setupUI_Pane() {
        view.addSubview(scrollView_Pane)
        scrollView_Pane.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        scrollView_Pane.addSubview(contentStack_Pane)
        contentStack_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(40)
            $0.width.equalTo(scrollView_Pane).offset(-32)
        }

        buildTitleCard_Pane()
        buildDescCard_Pane()
        buildMediaCard_Pane()
        buildThemeCard_Pane()
        buildPublishButton_Pane()
    }

    // MARK: - 分节卡片

    /// 标题输入卡片
    private func buildTitleCard_Pane() {
        styleCard_Pane(titleSectionCard_Pane)
        titleSectionCard_Pane.addSubview(titleFieldLabel_Pane)
        titleSectionCard_Pane.addSubview(titleField_Pane)
        titleSectionCard_Pane.addSubview(titleDivider_Pane)

        titleFieldLabel_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(16)
        }
        titleField_Pane.snp.makeConstraints {
            $0.top.equalTo(titleFieldLabel_Pane.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(36)
        }
        titleDivider_Pane.snp.makeConstraints {
            $0.top.equalTo(titleField_Pane.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview().inset(12)
        }
        contentStack_Pane.addArrangedSubview(titleSectionCard_Pane)
    }

    /// 描述输入卡片
    private func buildDescCard_Pane() {
        styleCard_Pane(descSectionCard_Pane)
        descSectionCard_Pane.addSubview(descFieldLabel_Pane)
        descSectionCard_Pane.addSubview(descTextView_Pane)
        // placeholder 添加到 descSectionCard，约束与 descTextView 的文字起始点对齐
        descSectionCard_Pane.addSubview(descPlaceholder_Pane)

        descFieldLabel_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(16)
        }
        descTextView_Pane.snp.makeConstraints {
            $0.top.equalTo(descFieldLabel_Pane.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.greaterThanOrEqualTo(72)
            $0.bottom.equalToSuperview().inset(8)
        }
        // placeholder 和 textView 文字对齐（textContainerInset left=-4，故偏移 12-4=8）
        descPlaceholder_Pane.snp.makeConstraints {
            $0.top.equalTo(descTextView_Pane).offset(1)
            $0.leading.equalTo(descTextView_Pane).offset(0)
            $0.trailing.equalTo(descTextView_Pane)
        }
        contentStack_Pane.addArrangedSubview(descSectionCard_Pane)
    }

    /// 图片选择卡片
    private func buildMediaCard_Pane() {
        styleCard_Pane(mediaSectionCard_Pane)
        mediaSectionCard_Pane.addSubview(mediaFieldLabel_Pane)
        mediaSectionCard_Pane.addSubview(mediaContainer_Pane)

        mediaFieldLabel_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(16)
        }
        mediaContainer_Pane.snp.makeConstraints {
            $0.top.equalTo(mediaFieldLabel_Pane.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(160)
            $0.bottom.equalToSuperview().inset(16)
        }

        // 占位视图（未选图时显示）
        mediaContainer_Pane.addSubview(mediaPlaceholder_Pane)
        mediaPlaceholder_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 已选媒体展示视图（覆盖占位符）
        mediaContainer_Pane.addSubview(pickedMediaView_Pane)
        pickedMediaView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 删除媒体按钮（右上角悬浮）
        mediaContainer_Pane.addSubview(mediaDeleteButton_Pane)
        mediaDeleteButton_Pane.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(8)
            $0.width.height.equalTo(24)
        }
        mediaDeleteButton_Pane.addTarget(self, action: #selector(deleteMediaTapped_Pane), for: .touchUpInside)

        let tap_pane = UITapGestureRecognizer(target: self, action: #selector(pickImageTapped_Pane))
        mediaContainer_Pane.addGestureRecognizer(tap_pane)
        contentStack_Pane.addArrangedSubview(mediaSectionCard_Pane)
    }

    /// 主题选择卡片
    private func buildThemeCard_Pane() {
        styleCard_Pane(themeSectionCard_Pane)
        themeSectionCard_Pane.addSubview(themeFieldLabel_Pane)
        themeSectionCard_Pane.addSubview(themeScrollView_Pane)

        themeFieldLabel_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(16)
        }
        themeScrollView_Pane.snp.makeConstraints {
            $0.top.equalTo(themeFieldLabel_Pane.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(32)
            $0.bottom.equalToSuperview().inset(16)
        }

        // themeStack 只固定 leading/top/bottom，不约束 trailing，让内容自然展宽
        themeScrollView_Pane.addSubview(themeStack_Pane)
        themeStack_Pane.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.height.equalToSuperview()
            // trailing 交给内容自动撑开，不约束
        }
        contentStack_Pane.addArrangedSubview(themeSectionCard_Pane)
    }

    /// 发布按钮
    private func buildPublishButton_Pane() {
        contentStack_Pane.addArrangedSubview(publishButton_Pane)
        publishButton_Pane.snp.makeConstraints { $0.height.equalTo(52) }
        publishButton_Pane.addTarget(self, action: #selector(publishTapped_Pane), for: .touchUpInside)

        let gl_pane = CAGradientLayer()
        gl_pane.colors       = [ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
                                 ColorConfig_Pane.primaryGradientEnd_Pane.cgColor]
        gl_pane.startPoint   = CGPoint(x: 0, y: 0.5)
        gl_pane.endPoint     = CGPoint(x: 1, y: 0.5)
        gl_pane.cornerRadius = 16
        publishButton_Pane.layer.insertSublayer(gl_pane, at: 0)
        publishGradient_Pane = gl_pane
    }

    /// 统一卡片样式
    private func styleCard_Pane(_ card_pane: UIView) {
        card_pane.backgroundColor    = .white
        card_pane.layer.cornerRadius = 16
        card_pane.layer.shadowColor  = UIColor.black.cgColor
        card_pane.layer.shadowOpacity = 0.05
        card_pane.layer.shadowOffset  = CGSize(width: 0, height: 2)
        card_pane.layer.shadowRadius  = 8
        card_pane.layer.masksToBounds = false
    }

    // MARK: - 主题胶囊

    private func setupThemeChips_Pane() {
        for (idx_pane, theme_pane) in WindowTheme_Pane.allCases.enumerated() {
            let btn_pane = UIButton(type: .custom)
            btn_pane.setTitle(theme_pane.rawValue, for: .normal)
            btn_pane.titleLabel?.font    = .systemFont(ofSize: 12, weight: .medium)
            btn_pane.titleLabel?.lineBreakMode = .byClipping
            btn_pane.layer.cornerRadius  = 14
            btn_pane.layer.borderWidth   = 1
            btn_pane.contentEdgeInsets   = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
            btn_pane.tag = idx_pane
            btn_pane.addTarget(self, action: #selector(themeChipTapped_Pane(_:)), for: .touchUpInside)
            // 高度固定，宽度由 intrinsicContentSize 决定
            btn_pane.snp.makeConstraints { $0.height.equalTo(28) }
            themeStack_Pane.addArrangedSubview(btn_pane)
            themeButtons_Pane.append(btn_pane)
        }
        applyThemeSelection_Pane(selected_pane: selectedTheme_Pane)
        // 让 themeStack 的 trailing 撑开 themeScrollView 内容宽度
        if let last_pane = themeStack_Pane.arrangedSubviews.last {
            last_pane.snp.makeConstraints { $0.trailing.equalTo(themeScrollView_Pane.contentLayoutGuide) }
        }
    }

    private func applyThemeSelection_Pane(selected_pane: WindowTheme_Pane) {
        selectedTheme_Pane = selected_pane
        let all_pane = WindowTheme_Pane.allCases
        for (idx_pane, btn_pane) in themeButtons_Pane.enumerated() {
            let isSel_pane = all_pane[idx_pane] == selected_pane
            if isSel_pane {
                btn_pane.backgroundColor = ColorConfig_Pane.primaryGradientStart_Pane
                btn_pane.setTitleColor(.white, for: .normal)
                btn_pane.layer.borderColor = UIColor.clear.cgColor
            } else {
                btn_pane.backgroundColor = .clear
                btn_pane.setTitleColor(ColorConfig_Pane.textSecondary_Pane, for: .normal)
                btn_pane.layer.borderColor = ColorConfig_Pane.divider_Pane.cgColor
            }
        }
    }

    // MARK: - 键盘处理

    private func observeKeyboard_Pane() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow_Pane(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide_Pane(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
        let tap_pane = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Pane))
        tap_pane.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_pane)
    }

    @objc private func keyboardWillShow_Pane(_ n: Notification) {
        guard let frame_pane = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView_Pane.contentInset.bottom = frame_pane.height + 20
        scrollView_Pane.scrollIndicatorInsets.bottom = frame_pane.height
    }

    @objc private func keyboardWillHide_Pane(_ n: Notification) {
        scrollView_Pane.contentInset.bottom = 0
        scrollView_Pane.scrollIndicatorInsets.bottom = 0
    }

    @objc private func dismissKeyboard_Pane() { view.endEditing(true) }

    // MARK: - 动作

    @objc private func closeTapped_Pane() { dismiss(animated: true) }

    @objc private func textViewDidChange_Pane() {
        descPlaceholder_Pane.isHidden = !descTextView_Pane.text.isEmpty
    }

    /// 删除已选媒体，恢复到占位符状态
    @objc private func deleteMediaTapped_Pane() {
        selectedImage_Pane             = nil
        pickedMediaView_Pane.isHidden  = true
        mediaPlaceholder_Pane.isHidden = false
        mediaDeleteButton_Pane.isHidden = true
    }

    @objc private func pickImageTapped_Pane() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let picker_pane          = UIImagePickerController()
        picker_pane.sourceType   = .photoLibrary
        picker_pane.delegate     = self
        picker_pane.allowsEditing = false
        present(picker_pane, animated: true)
    }

    @objc private func themeChipTapped_Pane(_ sender: UIButton) {
        let all_pane = WindowTheme_Pane.allCases
        guard sender.tag < all_pane.count else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        applyThemeSelection_Pane(selected_pane: all_pane[sender.tag])
    }

    @objc private func publishTapped_Pane() {
        guard UserViewModel_Pane.shared_Pane.isLoggedIn_Pane else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { Navigation_Pane.toLogin_Pane() }
            return
        }
        let title_pane = titleField_Pane.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !title_pane.isEmpty else {
            Utils_Pane.showWarning_Pane(message_Pane: "Please enter a title.")
            titleField_Pane.becomeFirstResponder()
            return
        }
        let content_pane = descTextView_Pane.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // 若用户选择了图片，持久化到 Documents 目录后以文件名存入帖子；否则使用默认占位
        let mediaName_pane: String
        if let img_pane = selectedImage_Pane,
           let savedName_pane = saveImageToDocuments_Pane(image_pane: img_pane) {
            mediaName_pane = savedName_pane
        } else {
            mediaName_pane = "post_media_1"
        }

        TitleViewModel_Pane.shared_Pane.releasePost_Pane(
            title_pane: title_pane,
            content_pane: content_pane,
            media_pane: mediaName_pane,
            theme_pane: selectedTheme_Pane.rawValue
        )
        onPublished_Pane?()
        dismiss(animated: true)
    }

    /// 将 UIImage 以 JPEG 格式持久化到 Documents 目录
    /// - Parameter image_pane: 要保存的图片
    /// - Returns: 保存成功时返回文件名（UUID.jpg），失败返回 nil
    private func saveImageToDocuments_Pane(image_pane: UIImage) -> String? {
        guard let data_pane = image_pane.jpegData(compressionQuality: 0.85) else { return nil }
        let fileName_pane = "\(UUID().uuidString).jpg"
        let url_pane = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName_pane)
        do {
            try data_pane.write(to: url_pane)
            return fileName_pane
        } catch {
            print("快速记录图片保存失败: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension HomeQuickRecordSheet_Pane: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let img_pane = info[.originalImage] as? UIImage else { return }
        selectedImage_Pane                  = img_pane
        pickedMediaView_Pane.configureWithImage_Pane(image_pane: img_pane)
        pickedMediaView_Pane.isHidden       = false
        mediaPlaceholder_Pane.isHidden      = true
        mediaDeleteButton_Pane.isHidden     = false
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
