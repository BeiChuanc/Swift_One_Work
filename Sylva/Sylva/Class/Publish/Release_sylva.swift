import Foundation
import UIKit
import SnapKit

// MARK: - 发布帖子页面（重构版）

/// 发布帖子视图控制器
/// 核心作用：提供标题、内容输入及媒体选择，校验后通过 TitleViewModel 发布帖子
/// 设计思路：沉浸式媒体预览区置顶，下方卡片式表单，字符数实时计数，键盘自适应滚动
class Release_Sylva: UIViewController {

    // MARK: - 私有常量

    /// 内容最大字符数
    private let maxContentLength_Sylva = 500
    /// 标题最大字符数
    private let maxTitleLength_Sylva = 60

    // MARK: - 私有属性

    private let scrollView_Sylva = UIScrollView()
    private let scrollContentView_Sylva = UIView()

    /// 标题输入框
    private let titleField_Sylva = UITextField()

    /// 内容输入区
    private let contentTextView_Sylva = UITextView()
    private let contentPlaceholder_Sylva = UILabel()

    /// 字符计数标签
    private let charCountLabel_Sylva = UILabel()

    /// 媒体容器
    private let mediaContainerView_Sylva = UIView()
    /// 媒体预览视图（选媒体后显示）
    private let mediaDisplayView_Sylva = MediaDisplayView_Sylva()
    /// 媒体空状态提示区
    private let mediaEmptyView_Sylva = UIView()
    /// 媒体已选时的覆盖操作层
    private let mediaOverlayView_Sylva = UIView()
    /// 虚线边框图层
    private let dashBorderLayer_Sylva = CAShapeLayer()

    /// 选中的媒体路径
    private var selectedMediaPath_Sylva: String?
    private var selectedMediaIsVideo_Sylva: Bool = false

    /// 表单卡片（存储属性，供底部按钮区对齐引用）
    private let formCardView_Sylva = UIView()
    /// 发布按钮
    private let publishButton_Sylva = UIButton(type: .system)

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Sylva.backgroundPrimary_Sylva
        setupNavBar_Sylva()
        setupScrollView_Sylva()
        setupMediaSection_Sylva()
        setupFormCard_Sylva()
        setupBottomActions_Sylva()
        setupKeyboardObservers_Sylva()
        setupTapToDismissKeyboard_Sylva()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 布局完成后更新虚线边框路径
        updateDashBorderPath_Sylva()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    /// 搭建顶部导航栏
    private func setupNavBar_Sylva() {
        let navBar_sylva = UIView()
        navBar_sylva.backgroundColor = .white
        // 底部细分割线
        let divider_sylva = UIView()
        divider_sylva.backgroundColor = ColorConfig_Sylva.divider_Sylva
        navBar_sylva.addSubview(divider_sylva)
        view.addSubview(navBar_sylva)

        navBar_sylva.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(54)
        }
        divider_sylva.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }

        // 页面标题
        let titleLabel_sylva = UILabel()
        titleLabel_sylva.text = "Share Your Story"
        titleLabel_sylva.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel_sylva.textColor = UIColor(hexstring_Sylva: "#1B4332")
        navBar_sylva.addSubview(titleLabel_sylva)
        titleLabel_sylva.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        // 右侧叶子图标装饰
        let leafIcon_sylva = UIImageView(image: UIImage(systemName: "leaf.fill"))
        leafIcon_sylva.tintColor = UIColor(hexstring_Sylva: "#52B788")
        leafIcon_sylva.contentMode = .scaleAspectFit
        navBar_sylva.addSubview(leafIcon_sylva)
        leafIcon_sylva.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }

    /// 搭建滚动容器
    private func setupScrollView_Sylva() {
        scrollView_Sylva.showsVerticalScrollIndicator = false
        scrollView_Sylva.keyboardDismissMode = .interactive
        view.addSubview(scrollView_Sylva)
        scrollView_Sylva.addSubview(scrollContentView_Sylva)

        scrollView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(54)
            make.leading.trailing.equalToSuperview()
            // 滚动区底部距屏幕底部 100pt，预留固定操作区空间
            make.bottom.equalToSuperview().offset(-100)
        }
        scrollContentView_Sylva.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }
    }

    /// 搭建媒体选择区域
    private func setupMediaSection_Sylva() {
        // 区块标题行
        let sectionRow_sylva = makeSectionHeader_Sylva(icon: "photo.on.rectangle.angled", title: "Add Media")
        scrollContentView_Sylva.addSubview(sectionRow_sylva)
        sectionRow_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        // 媒体容器
        mediaContainerView_Sylva.backgroundColor = UIColor(hexstring_Sylva: "#F0FFF4")
        mediaContainerView_Sylva.layer.cornerRadius = 16
        mediaContainerView_Sylva.clipsToBounds = false
        scrollContentView_Sylva.addSubview(mediaContainerView_Sylva)
        mediaContainerView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(sectionRow_sylva.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(186)
        }

        // 虚线边框（布局后更新 path）
        dashBorderLayer_Sylva.strokeColor = UIColor(hexstring_Sylva: "#95D5B2").cgColor
        dashBorderLayer_Sylva.fillColor = UIColor.clear.cgColor
        dashBorderLayer_Sylva.lineWidth = 1.5
        dashBorderLayer_Sylva.lineDashPattern = [6, 4]
        dashBorderLayer_Sylva.lineJoin = .round
        mediaContainerView_Sylva.layer.addSublayer(dashBorderLayer_Sylva)

        // 媒体预览（选媒体后显示）
        mediaDisplayView_Sylva.layer.cornerRadius = 16
        mediaDisplayView_Sylva.clipsToBounds = true
        mediaDisplayView_Sylva.isHidden = true
        mediaContainerView_Sylva.addSubview(mediaDisplayView_Sylva)
        mediaDisplayView_Sylva.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 媒体空状态
        setupMediaEmptyState_Sylva()

        // 媒体已选时的覆盖按钮层
        setupMediaOverlay_Sylva()

        // 点击手势
        let tap_sylva = UITapGestureRecognizer(target: self, action: #selector(mediaContainerTapped_Sylva))
        mediaContainerView_Sylva.addGestureRecognizer(tap_sylva)
        mediaContainerView_Sylva.isUserInteractionEnabled = true
    }

    /// 搭建媒体空状态提示内容
    private func setupMediaEmptyState_Sylva() {
        mediaContainerView_Sylva.addSubview(mediaEmptyView_Sylva)
        mediaEmptyView_Sylva.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 相机图标
        let iconBg_sylva = UIView()
        iconBg_sylva.backgroundColor = UIColor(hexstring_Sylva: "#40916C").withAlphaComponent(0.12)
        iconBg_sylva.layer.cornerRadius = 28
        mediaEmptyView_Sylva.addSubview(iconBg_sylva)

        let cameraIcon_sylva = UIImageView(image: UIImage(systemName: "camera.fill"))
        cameraIcon_sylva.tintColor = UIColor(hexstring_Sylva: "#40916C")
        cameraIcon_sylva.contentMode = .scaleAspectFit
        mediaEmptyView_Sylva.addSubview(cameraIcon_sylva)

        let mainLabel_sylva = UILabel()
        mainLabel_sylva.text = "Tap to add photo or video"
        mainLabel_sylva.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        mainLabel_sylva.textColor = UIColor(hexstring_Sylva: "#40916C")
        mainLabel_sylva.textAlignment = .center
        mediaEmptyView_Sylva.addSubview(mainLabel_sylva)

        let subLabel_sylva = UILabel()
        subLabel_sylva.text = "JPG · PNG · MP4 · MOV"
        subLabel_sylva.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        subLabel_sylva.textColor = ColorConfig_Sylva.textPlaceholder_Sylva
        subLabel_sylva.textAlignment = .center
        mediaEmptyView_Sylva.addSubview(subLabel_sylva)

        // 约束（先加入层级再约束）
        iconBg_sylva.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-22)
            make.width.height.equalTo(56)
        }
        cameraIcon_sylva.snp.makeConstraints { make in
            make.center.equalTo(iconBg_sylva)
            make.width.height.equalTo(26)
        }
        mainLabel_sylva.snp.makeConstraints { make in
            make.top.equalTo(iconBg_sylva.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        subLabel_sylva.snp.makeConstraints { make in
            make.top.equalTo(mainLabel_sylva.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
    }

    /// 搭建媒体已选覆盖操作层（更换/移除）
    private func setupMediaOverlay_Sylva() {
        mediaOverlayView_Sylva.isHidden = true
        mediaContainerView_Sylva.addSubview(mediaOverlayView_Sylva)
        mediaOverlayView_Sylva.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 右上角移除按钮
        let removeBtn_sylva = UIButton(type: .system)
        let rmCfg_sylva = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        removeBtn_sylva.setImage(UIImage(systemName: "xmark", withConfiguration: rmCfg_sylva), for: .normal)
        removeBtn_sylva.tintColor = .white
        removeBtn_sylva.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        removeBtn_sylva.layer.cornerRadius = 16
        removeBtn_sylva.addTarget(self, action: #selector(removeMediaTapped_Sylva), for: .touchUpInside)
        mediaOverlayView_Sylva.addSubview(removeBtn_sylva)
        removeBtn_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(32)
        }

        // 底部"Tap to change"提示条
        let changeBanner_sylva = UIView()
        changeBanner_sylva.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        mediaOverlayView_Sylva.addSubview(changeBanner_sylva)
        changeBanner_sylva.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(32)
        }

        let changeLabel_sylva = UILabel()
        changeLabel_sylva.text = "Tap to change"
        changeLabel_sylva.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        changeLabel_sylva.textColor = .white
        changeLabel_sylva.textAlignment = .center
        changeBanner_sylva.addSubview(changeLabel_sylva)
        changeLabel_sylva.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 搭建表单卡片（标题 + 内容输入）
    private func setupFormCard_Sylva() {
        // 使用存储属性 formCardView_Sylva，底部不约束 scrollContentView，由 setupBottomActions 接管
        formCardView_Sylva.backgroundColor = .white
        formCardView_Sylva.layer.cornerRadius = 20
        formCardView_Sylva.layer.shadowColor = UIColor.black.cgColor
        formCardView_Sylva.layer.shadowOpacity = 0.06
        formCardView_Sylva.layer.shadowRadius = 12
        formCardView_Sylva.layer.shadowOffset = CGSize(width: 0, height: 4)
        scrollContentView_Sylva.addSubview(formCardView_Sylva)
        formCardView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(mediaContainerView_Sylva.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            // 不在此处约束 bottom，由 setupBottomActions 中的按钮区接管
        }

        // ---- 标题区域 ----
        let titleHeader_sylva = makeSectionHeader_Sylva(icon: "textformat", title: "Post Title")
        formCardView_Sylva.addSubview(titleHeader_sylva)
        titleHeader_sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        titleField_Sylva.backgroundColor = ColorConfig_Sylva.backgroundPrimary_Sylva
        titleField_Sylva.layer.cornerRadius = 12
        titleField_Sylva.layer.borderWidth = 1.5
        titleField_Sylva.layer.borderColor = ColorConfig_Sylva.border_Sylva.cgColor
        titleField_Sylva.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleField_Sylva.textColor = ColorConfig_Sylva.textPrimary_Sylva
        titleField_Sylva.setPlaceholder_Sylva(
            placeholder_Sylva: "Give your story a title...",
            color_Sylva: ColorConfig_Sylva.textPlaceholder_Sylva
        )
        titleField_Sylva.setLeftPadding_Sylva(padding_Sylva: 14)
        titleField_Sylva.returnKeyType = .next
        titleField_Sylva.delegate = self
        formCardView_Sylva.addSubview(titleField_Sylva)
        titleField_Sylva.snp.makeConstraints { make in
            make.top.equalTo(titleHeader_sylva.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(48)
        }

        // ---- 内容区域 ----
        let contentHeader_sylva = makeSectionHeader_Sylva(icon: "pencil.and.list.clipboard", title: "Your Story")
        formCardView_Sylva.addSubview(contentHeader_sylva)
        contentHeader_sylva.snp.makeConstraints { make in
            make.top.equalTo(titleField_Sylva.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        // 先加入层级，再统一设置约束
        charCountLabel_Sylva.font = UIFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        charCountLabel_Sylva.textColor = ColorConfig_Sylva.textPlaceholder_Sylva
        charCountLabel_Sylva.textAlignment = .right
        charCountLabel_Sylva.text = "0/\(maxContentLength_Sylva)"
        formCardView_Sylva.addSubview(charCountLabel_Sylva)

        contentTextView_Sylva.font = UIFont.systemFont(ofSize: 15)
        contentTextView_Sylva.textColor = ColorConfig_Sylva.textPrimary_Sylva
        contentTextView_Sylva.backgroundColor = ColorConfig_Sylva.backgroundPrimary_Sylva
        contentTextView_Sylva.layer.cornerRadius = 12
        contentTextView_Sylva.layer.borderWidth = 1.5
        contentTextView_Sylva.layer.borderColor = ColorConfig_Sylva.border_Sylva.cgColor
        contentTextView_Sylva.textContainerInset = UIEdgeInsets(top: 14, left: 10, bottom: 36, right: 10)
        contentTextView_Sylva.delegate = self
        formCardView_Sylva.addSubview(contentTextView_Sylva)

        contentPlaceholder_Sylva.text = "Share your tree planting journey..."
        contentPlaceholder_Sylva.font = UIFont.systemFont(ofSize: 15)
        contentPlaceholder_Sylva.textColor = ColorConfig_Sylva.textPlaceholder_Sylva
        contentPlaceholder_Sylva.numberOfLines = 0
        contentTextView_Sylva.addSubview(contentPlaceholder_Sylva)

        charCountLabel_Sylva.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-20)
        }

        contentTextView_Sylva.snp.makeConstraints { make in
            make.top.equalTo(contentHeader_sylva.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(140)
            make.bottom.equalToSuperview().offset(-20)
        }

        contentPlaceholder_Sylva.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
        }
    }

    /// 搭建底部发布按钮和 EULA（加入 scrollContentView，随页面滚动）
    private func setupBottomActions_Sylva() {
        // 发布按钮容器（局部变量，加入 scrollContentView）
        let btnContainer_sylva = UIView()
        btnContainer_sylva.layer.cornerRadius = 18
        btnContainer_sylva.layer.shadowColor = UIColor(hexstring_Sylva: "#40916C").cgColor
        btnContainer_sylva.layer.shadowOpacity = 0.35
        btnContainer_sylva.layer.shadowRadius = 12
        btnContainer_sylva.layer.shadowOffset = CGSize(width: 0, height: 5)
        scrollContentView_Sylva.addSubview(btnContainer_sylva)
        btnContainer_sylva.snp.makeConstraints { make in
            make.top.equalTo(formCardView_Sylva.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(54)
        }

        // 渐变背景层
        let gradientLayer_sylva = CAGradientLayer()
        gradientLayer_sylva.colors = [
            UIColor(hexstring_Sylva: "#52B788").cgColor,
            UIColor(hexstring_Sylva: "#1B4332").cgColor
        ]
        gradientLayer_sylva.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer_sylva.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer_sylva.cornerRadius = 18
        btnContainer_sylva.layer.insertSublayer(gradientLayer_sylva, at: 0)
        DispatchQueue.main.async {
            gradientLayer_sylva.frame = btnContainer_sylva.bounds
        }

        publishButton_Sylva.backgroundColor = .clear
        publishButton_Sylva.setTitle("Publish Story", for: .normal)
        publishButton_Sylva.setTitleColor(.white, for: .normal)
        publishButton_Sylva.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        let btnCfg_sylva = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        publishButton_Sylva.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: btnCfg_sylva), for: .normal)
        publishButton_Sylva.tintColor = .white
        publishButton_Sylva.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        publishButton_Sylva.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        publishButton_Sylva.addTarget(self, action: #selector(publishTapped_Sylva), for: .touchUpInside)
        btnContainer_sylva.addSubview(publishButton_Sylva)
        publishButton_Sylva.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // EULA 文字（底部约束 scrollContentView，撑开滚动内容高度）
        let eulaLabel_Sylva = UILabel()
        let fullText_Sylva = "EULA"
        let attrStr_Sylva = NSMutableAttributedString(string: fullText_Sylva, attributes: [
            .foregroundColor: ColorConfig_Sylva.textPlaceholder_Sylva,
            .font: UIFont.systemFont(ofSize: 11)
        ])
        if let range_sylva = fullText_Sylva.range(of: "EULA") {
            let nsRange_sylva = NSRange(range_sylva, in: fullText_Sylva)
            attrStr_Sylva.addAttributes([
                .foregroundColor: UIColor(hexstring_Sylva: "#40916C"),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ], range: nsRange_sylva)
        }
        eulaLabel_Sylva.attributedText = attrStr_Sylva
        eulaLabel_Sylva.textAlignment = .center
        eulaLabel_Sylva.isUserInteractionEnabled = true
        let tap_sylva = UITapGestureRecognizer(target: self, action: #selector(eulaTapped_Sylva))
        eulaLabel_Sylva.addGestureRecognizer(tap_sylva)
        scrollContentView_Sylva.addSubview(eulaLabel_Sylva)
        eulaLabel_Sylva.snp.makeConstraints { make in
            make.top.equalTo(btnContainer_sylva.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            // 此约束撑开 scrollContentView 的底部，决定滚动内容总高度
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    // MARK: - 辅助方法

    /// 构建统一的区块标题行（图标 + 标题）
    /// - Parameters:
    ///   - icon: SF Symbol 名称
    ///   - title: 标题文字
    /// - Returns: 已配置好的容器视图
    private func makeSectionHeader_Sylva(icon: String, title: String) -> UIView {
        let container_sylva = UIView()

        let iconView_sylva = UIImageView()
        let cfg_sylva = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        iconView_sylva.image = UIImage(systemName: icon, withConfiguration: cfg_sylva)
        iconView_sylva.tintColor = UIColor(hexstring_Sylva: "#40916C")
        iconView_sylva.contentMode = .scaleAspectFit

        let label_sylva = UILabel()
        label_sylva.text = title
        label_sylva.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label_sylva.textColor = UIColor(hexstring_Sylva: "#40916C")

        // 先加入层级
        container_sylva.addSubview(iconView_sylva)
        container_sylva.addSubview(label_sylva)

        iconView_sylva.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.height.equalTo(16)
        }
        label_sylva.snp.makeConstraints { make in
            make.leading.equalTo(iconView_sylva.snp.trailing).offset(6)
            make.centerY.equalTo(iconView_sylva)
            make.trailing.equalToSuperview()
        }

        return container_sylva
    }

    /// 更新虚线边框路径
    private func updateDashBorderPath_Sylva() {
        let bounds_sylva = mediaContainerView_Sylva.bounds
        guard bounds_sylva.width > 0 else { return }
        dashBorderLayer_Sylva.path = UIBezierPath(
            roundedRect: bounds_sylva,
            cornerRadius: 16
        ).cgPath
        dashBorderLayer_Sylva.frame = bounds_sylva
        // 选媒体后隐藏虚线
        dashBorderLayer_Sylva.isHidden = selectedMediaPath_Sylva != nil
    }

    /// 清空所有输入
    private func clearForm_Sylva() {
        titleField_Sylva.text = ""
        contentTextView_Sylva.text = ""
        contentPlaceholder_Sylva.isHidden = false
        charCountLabel_Sylva.text = "0/\(maxContentLength_Sylva)"
        charCountLabel_Sylva.textColor = ColorConfig_Sylva.textPlaceholder_Sylva
        selectedMediaPath_Sylva = nil
        selectedMediaIsVideo_Sylva = false
        mediaDisplayView_Sylva.isHidden = true
        mediaEmptyView_Sylva.isHidden = false
        mediaOverlayView_Sylva.isHidden = true
        dashBorderLayer_Sylva.isHidden = false
    }

    /// 展示媒体选中状态
    private func showMediaSelected_Sylva() {
        mediaEmptyView_Sylva.isHidden = true
        mediaDisplayView_Sylva.isHidden = false
        mediaOverlayView_Sylva.isHidden = false
        dashBorderLayer_Sylva.isHidden = true
    }

    /// 保存图片到 Documents 目录并返回文件路径
    private func saveMediaToDocuments_Sylva(image: UIImage) -> String? {
        guard let data_sylva = image.jpegData(compressionQuality: 0.85) else { return nil }
        let filename_sylva = "post_\(Int(Date().timeIntervalSince1970)).jpg"
        let url_sylva = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename_sylva)
        do {
            try data_sylva.write(to: url_sylva)
            return url_sylva.path
        } catch {
            print("媒体保存失败: \(error)")
            return nil
        }
    }

    // MARK: - 键盘处理

    /// 注册键盘弹出/收起通知
    private func setupKeyboardObservers_Sylva() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Sylva(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Sylva(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    /// 点击空白处收起键盘
    private func setupTapToDismissKeyboard_Sylva() {
        let tap_sylva = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Sylva))
        tap_sylva.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_sylva)
    }

    // MARK: - 事件处理

    @objc private func dismissKeyboard_Sylva() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow_Sylva(_ notification: Notification) {
        guard let info_sylva = notification.userInfo,
              let keyboardFrame_sylva = info_sylva[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_sylva = info_sylva[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }

        let inset_sylva = keyboardFrame_sylva.height - view.safeAreaInsets.bottom + 16
        UIView.animate(withDuration: duration_sylva) {
            self.scrollView_Sylva.contentInset.bottom = inset_sylva
            self.scrollView_Sylva.verticalScrollIndicatorInsets.bottom = inset_sylva
        }
    }

    @objc private func keyboardWillHide_Sylva(_ notification: Notification) {
        guard let info_sylva = notification.userInfo,
              let duration_sylva = info_sylva[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }

        UIView.animate(withDuration: duration_sylva) {
            self.scrollView_Sylva.contentInset.bottom = 0
            self.scrollView_Sylva.verticalScrollIndicatorInsets.bottom = 0
        }
    }

    @objc private func mediaContainerTapped_Sylva() {
        let sheet_Sylva = UIAlertController(title: "Add Media", message: nil, preferredStyle: .actionSheet)

        sheet_Sylva.addAction(UIAlertAction(title: "Photo", style: .default) { [weak self] _ in
            guard let self_sylva = self else { return }
            MediaPickerHelper_Sylva.pickImage_Sylva(from: self_sylva) { image_sylva in
                guard let image_sylva = image_sylva else { return }
                if let savedPath_sylva = self_sylva.saveMediaToDocuments_Sylva(image: image_sylva) {
                    self_sylva.selectedMediaPath_Sylva = savedPath_sylva
                }
                self_sylva.selectedMediaIsVideo_Sylva = false
                self_sylva.mediaDisplayView_Sylva.configureWithImage_Sylva(image_Sylva: image_sylva)
                self_sylva.showMediaSelected_Sylva()
            }
        })

        sheet_Sylva.addAction(UIAlertAction(title: "Video", style: .default) { [weak self] _ in
            guard let self_sylva = self else { return }
            MediaPickerHelper_Sylva.pickVideo_Sylva(from: self_sylva) { url_sylva in
                guard let url_sylva = url_sylva else { return }
                self_sylva.selectedMediaPath_Sylva = url_sylva.path
                self_sylva.selectedMediaIsVideo_Sylva = true
                self_sylva.mediaDisplayView_Sylva.configure_Sylva(mediaPath_Sylva: url_sylva.path, isVideo_Sylva: true)
                self_sylva.showMediaSelected_Sylva()
            }
        })

        sheet_Sylva.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet_Sylva, animated: true)
    }

    @objc private func removeMediaTapped_Sylva() {
        selectedMediaPath_Sylva = nil
        selectedMediaIsVideo_Sylva = false
        mediaDisplayView_Sylva.isHidden = true
        mediaEmptyView_Sylva.isHidden = false
        mediaOverlayView_Sylva.isHidden = true
        dashBorderLayer_Sylva.isHidden = false
    }

    @objc private func publishTapped_Sylva() {
        publishButton_Sylva.animatePressDown_Sylva { [weak self] in
            self?.publishButton_Sylva.animatePressUp_Sylva()
        }

        guard UserViewModel_Sylva.shared_Sylva.isLoggedIn_Sylva else {
            Navigation_Sylva.toLogin_Sylva()
            return
        }

        let title_sylva = titleField_Sylva.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let content_sylva = contentTextView_Sylva.text?.trimmingCharacters(in: .whitespaces) ?? ""

        guard !title_sylva.isEmpty else {
            Utils_Sylva.showWarning_Sylva(message_Sylva: "Please enter a title")
            titleField_Sylva.animateShake_Sylva()
            return
        }
        guard !content_sylva.isEmpty else {
            Utils_Sylva.showWarning_Sylva(message_Sylva: "Please write some content")
            contentTextView_Sylva.animateShake_Sylva()
            return
        }
        guard let media_sylva = selectedMediaPath_Sylva, !media_sylva.isEmpty else {
            Utils_Sylva.showWarning_Sylva(message_Sylva: "Please add a photo or video")
            mediaContainerView_Sylva.animateShake_Sylva()
            return
        }

        TitleViewModel_Sylva.shared_Sylva.releasePost_Sylva(
            title_sylva: title_sylva,
            content_sylva: content_sylva,
            media_sylva: media_sylva
        )

        clearForm_Sylva()
        dismiss(animated: true)
    }

    @objc private func eulaTapped_Sylva() {
        ProtocolHelper_Sylva.showProtocol_Sylva(
            type_Sylva: .eula_Sylva,
            content_Sylva: "tt",
            from: self
        )
    }
}

// MARK: - UITextFieldDelegate

extension Release_Sylva: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        // 获焦：绿色边框
        UIView.animate(withDuration: AnimationConfig_Sylva.durationFast_Sylva) {
            textField.layer.borderColor = UIColor(hexstring_Sylva: "#40916C").cgColor
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: AnimationConfig_Sylva.durationFast_Sylva) {
            textField.layer.borderColor = ColorConfig_Sylva.border_Sylva.cgColor
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let current_sylva = (textField.text ?? "") as NSString
        let newLength_sylva = current_sylva.replacingCharacters(in: range, with: string).count
        return newLength_sylva <= maxTitleLength_Sylva
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentTextView_Sylva.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension Release_Sylva: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        contentPlaceholder_Sylva.isHidden = !textView.text.isEmpty
        UIView.animate(withDuration: AnimationConfig_Sylva.durationFast_Sylva) {
            textView.layer.borderColor = UIColor(hexstring_Sylva: "#40916C").cgColor
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        contentPlaceholder_Sylva.isHidden = !textView.text.isEmpty
        UIView.animate(withDuration: AnimationConfig_Sylva.durationFast_Sylva) {
            textView.layer.borderColor = ColorConfig_Sylva.border_Sylva.cgColor
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        contentPlaceholder_Sylva.isHidden = !textView.text.isEmpty
        let count_sylva = textView.text.count
        charCountLabel_Sylva.text = "\(count_sylva)/\(maxContentLength_Sylva)"
        // 接近上限变为橙色，超限变为红色
        if count_sylva >= maxContentLength_Sylva {
            charCountLabel_Sylva.textColor = UIColor(hexstring_Sylva: "#E53E3E")
        } else if count_sylva >= Int(Double(maxContentLength_Sylva) * 0.8) {
            charCountLabel_Sylva.textColor = UIColor(hexstring_Sylva: "#DD6B20")
        } else {
            charCountLabel_Sylva.textColor = ColorConfig_Sylva.textPlaceholder_Sylva
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let current_sylva = (textView.text ?? "") as NSString
        let newLength_sylva = current_sylva.replacingCharacters(in: range, with: text).count
        return newLength_sylva <= maxContentLength_Sylva
    }
}
