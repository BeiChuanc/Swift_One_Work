import Foundation
import UIKit
import SnapKit
import AVFoundation

// MARK: 发布页

/// 发布页视图控制器
/// 功能：输入标题/内容/媒体，发布帖子；支持图片/视频选取，发布前登录检测，发布后清空表单
/// 设计：三色渐变头部+装饰元素、彩色虚线媒体选区、分离式输入卡片、字数计数、辅助渐变发布按钮
class Release_Bague: UIViewController {

    // MARK: - UI 组件（滚动容器）

    private let scrollView_Bague: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode = .interactive
        // 禁止自动添加 safeArea 内边距，确保头部渐变紧贴屏幕顶端
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Bague = UIView()

    // MARK: - 头部区域

    /// 渐变头部容器
    private let headerView_Bague = UIView()
    private var headerGradient_Bague: CAGradientLayer?

    /// 主标题
    private let headerTitleLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "New Post"
        label.font = UIFont.systemFont(ofSize: 30, weight: .black)
        label.textColor = .white
        return label
    }()

    /// 副标题
    private let headerSubtitle_Bague: UILabel = {
        let label = UILabel()
        label.text = "Share your bag discovery"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.82)
        return label
    }()

    /// 头部装饰：大闪光图标
    private let headerDecorIcon_Bague: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "sparkles")
        iv.tintColor = UIColor.white.withAlphaComponent(0.18)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 头部装饰：半透明大圆
    private let headerDecorCircle_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.layer.cornerRadius = 55
        return v
    }()

    /// 头部装饰：小星形
    private let headerDecorStar_Bague: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "star.fill")
        iv.tintColor = UIColor.white.withAlphaComponent(0.15)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - 媒体选取区

    /// 媒体区段标签
    private let mediaSectionRow_Bague = makeSectionRow_Release_Bague(
        icon: "photo.on.rectangle",
        title: "Media",
        tint: UIColor(hexstring_Bague: "#9B72F5")
    )

    /// 媒体选取卡片（虚线渐变边框）
    private let mediaPickerView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Bague: "#F5F0FF")
        v.layer.cornerRadius = 18
        return v
    }()

    /// 虚线边框图层（选取前）
    private var dashedBorderLayer_Bague: CAShapeLayer?

    /// 选中后的媒体预览图
    private let mediaPreviewImage_Bague: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.isHidden = true
        return iv
    }()

    /// 选取状态图标背景
    private let mediaIconBg_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Bague: "#EDD9FF")
        v.layer.cornerRadius = 30
        return v
    }()

    /// 选取状态图标
    private let mediaAddIcon_Bague: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
        iv.image = UIImage(systemName: "plus", withConfiguration: cfg)
        iv.tintColor = UIColor(hexstring_Bague: "#9B72F5")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 选取提示主文字
    private let mediaHintTitle_Bague: UILabel = {
        let label = UILabel()
        label.text = "Add photo or video"
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = UIColor(hexstring_Bague: "#9B72F5")
        label.textAlignment = .center
        return label
    }()

    /// 选取提示副文字
    private let mediaHintSub_Bague: UILabel = {
        let label = UILabel()
        label.text = "JPG, PNG, MP4 supported"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = ColorConfig_Bague.textPlaceholder_Bague
        label.textAlignment = .center
        return label
    }()

    /// 清除媒体按钮
    private let mediaClearBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        btn.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor(hexstring_Bague: "#FF6B6B")
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 15
        btn.isHidden = true
        return btn
    }()

    /// 视频标签
    private let videoTagView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        v.layer.cornerRadius = 8
        v.isHidden = true
        return v
    }()

    private let videoTagLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "VIDEO"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .white
        return label
    }()

    // MARK: - 标题输入区

    /// 帖子标题区段标签
    private let titleSectionRow_Bague = makeSectionRow_Release_Bague(
        icon: "text.quote",
        title: "Post Title",
        tint: UIColor(hexstring_Bague: "#5AADEC")
    )

    /// 标题输入卡片
    private let titleCard_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor(hexstring_Bague: "#8B9CC8").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowOpacity = 0.1
        v.layer.shadowRadius = 10
        return v
    }()

    /// 标题卡片左侧蓝色口音条
    private let titleAccentBar_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Bague: "#5AADEC")
        v.layer.cornerRadius = 2
        return v
    }()

    private let titleField_Bague: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Give your post a title..."
        tf.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tf.textColor = ColorConfig_Bague.textPrimary_Bague
        tf.returnKeyType = .next
        tf.placeHolderTextColor_Bague(ColorConfig_Bague.textPlaceholder_Bague)
        return tf
    }()

    // MARK: - 内容输入区

    /// 帖子内容区段标签
    private let contentSectionRow_Bague = makeSectionRow_Release_Bague(
        icon: "text.alignleft",
        title: "Content",
        tint: UIColor(hexstring_Bague: "#3DC9A6")
    )

    /// 内容输入卡片
    private let contentCard_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor(hexstring_Bague: "#8B9CC8").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowOpacity = 0.1
        v.layer.shadowRadius = 10
        return v
    }()

    /// 内容卡片左侧绿色口音条
    private let contentAccentBar_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Bague: "#3DC9A6")
        v.layer.cornerRadius = 2
        return v
    }()

    private let contentTextView_Bague: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tv.textColor = ColorConfig_Bague.textPrimary_Bague
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }()

    private let contentPlaceholder_Bague: UILabel = {
        let label = UILabel()
        label.text = "What's your bag story?"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = ColorConfig_Bague.textPlaceholder_Bague
        label.numberOfLines = 2
        return label
    }()

    /// 字数计数标签
    private let charCountLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "0 / 500"
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = ColorConfig_Bague.textPlaceholder_Bague
        label.textAlignment = .right
        return label
    }()

    // MARK: - 发布按钮区

    private let publishBtn_Bague: UIButton = {
        let btn = UIButton(type: .custom)
        // 图标 + 文字
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        btn.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg), for: .normal)
        btn.setTitle("  Publish Post", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.tintColor = .white
        btn.layer.cornerRadius = 26
        btn.layer.shadowColor = UIColor(hexstring_Bague: "#F07DAD").cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn.layer.shadowOpacity = 0.35
        btn.layer.shadowRadius = 14
        return btn
    }()

    private var publishBtnGradient_Bague: CAGradientLayer?

    /// EULA 协议按钮
    private let eulaBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        let attrs_bague: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: ColorConfig_Bague.textPlaceholder_Bague
        ]
        let attrsFront_bague: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
            .foregroundColor: ColorConfig_Bague.primaryGradientStart_Bague,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let full_bague = NSMutableAttributedString(string: "", attributes: attrs_bague)
        full_bague.append(NSAttributedString(string: "EULA", attributes: attrsFront_bague))
        btn.setAttributedTitle(full_bague, for: .normal)
        return btn
    }()

    // MARK: - 数据

    /// 选中的媒体路径（图片或视频URL）
    private var selectedMediaPath_Bague: String?
    /// 是否为视频媒体
    private var isVideoMedia_Bague = false

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Bague()
        setupConstraints_Bague()
        setupKeyboardObservers_Bague()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradients_Bague()
        updateDashedBorder_Bague()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        // contentInsetAdjustmentBehavior = .never 时手动补充底部安全区内边距，
        // 保证内容可以完整滚动到底部，不被 home indicator 遮挡
        scrollView_Bague.contentInset.bottom = view.safeAreaInsets.bottom
        scrollView_Bague.verticalScrollIndicatorInsets.bottom = view.safeAreaInsets.bottom
    }

    // MARK: - UI 设置

    private func setupUI_Bague() {
        view.backgroundColor = ColorConfig_Bague.backgroundPrimary_Bague

        view.addSubview(scrollView_Bague)
        scrollView_Bague.addSubview(contentView_Bague)

        // 头部
        contentView_Bague.addSubview(headerView_Bague)
        headerView_Bague.addSubview(headerDecorCircle_Bague)
        headerView_Bague.addSubview(headerDecorIcon_Bague)
        headerView_Bague.addSubview(headerDecorStar_Bague)
        headerView_Bague.addSubview(headerTitleLabel_Bague)
        headerView_Bague.addSubview(headerSubtitle_Bague)

        // 媒体选取
        contentView_Bague.addSubview(mediaSectionRow_Bague)
        contentView_Bague.addSubview(mediaPickerView_Bague)
        mediaPickerView_Bague.addSubview(mediaIconBg_Bague)
        mediaIconBg_Bague.addSubview(mediaAddIcon_Bague)
        mediaPickerView_Bague.addSubview(mediaHintTitle_Bague)
        mediaPickerView_Bague.addSubview(mediaHintSub_Bague)
        mediaPickerView_Bague.addSubview(mediaPreviewImage_Bague)
        mediaPickerView_Bague.addSubview(mediaClearBtn_Bague)
        mediaPickerView_Bague.addSubview(videoTagView_Bague)
        videoTagView_Bague.addSubview(videoTagLabel_Bague)

        let mediaTap_bague = UITapGestureRecognizer(target: self, action: #selector(mediaPickerTapped_Bague))
        mediaPickerView_Bague.addGestureRecognizer(mediaTap_bague)
        mediaPickerView_Bague.isUserInteractionEnabled = true
        mediaClearBtn_Bague.addTarget(self, action: #selector(clearMedia_Bague), for: .touchUpInside)

        // 标题输入
        contentView_Bague.addSubview(titleSectionRow_Bague)
        contentView_Bague.addSubview(titleCard_Bague)
        titleCard_Bague.addSubview(titleAccentBar_Bague)
        titleCard_Bague.addSubview(titleField_Bague)
        titleField_Bague.delegate = self

        // 内容输入
        contentView_Bague.addSubview(contentSectionRow_Bague)
        contentView_Bague.addSubview(contentCard_Bague)
        contentCard_Bague.addSubview(contentAccentBar_Bague)
        contentCard_Bague.addSubview(contentTextView_Bague)
        contentCard_Bague.addSubview(contentPlaceholder_Bague)
        contentCard_Bague.addSubview(charCountLabel_Bague)
        contentTextView_Bague.delegate = self

        // 发布按钮 + EULA
        contentView_Bague.addSubview(publishBtn_Bague)
        contentView_Bague.addSubview(eulaBtn_Bague)
        publishBtn_Bague.addTarget(self, action: #selector(publishTapped_Bague), for: .touchUpInside)
        publishBtn_Bague.addTarget(self, action: #selector(btnDown_Bague), for: .touchDown)
        publishBtn_Bague.addTarget(self, action: #selector(btnUp_Bague), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        eulaBtn_Bague.addTarget(self, action: #selector(eulaTapped_Bague), for: .touchUpInside)

        // 点击空白收键盘
        let bgTap_bague = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Bague))
        bgTap_bague.cancelsTouchesInView = false
        scrollView_Bague.addGestureRecognizer(bgTap_bague)
    }

    private func setupConstraints_Bague() {
        scrollView_Bague.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        // 头部
        headerView_Bague.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
        headerDecorCircle_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(28)
            make.top.equalToSuperview().offset(-18)
            make.width.height.equalTo(110)
        }
        headerDecorIcon_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(56)
            make.width.height.equalTo(68)
        }
        headerDecorStar_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-100)
            make.top.equalToSuperview().offset(64)
            make.width.height.equalTo(20)
        }
        headerTitleLabel_Bague.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-36)
            make.leading.equalToSuperview().offset(24)
        }
        headerSubtitle_Bague.snp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel_Bague.snp.bottom).offset(5)
            make.leading.equalTo(headerTitleLabel_Bague)
        }

        // 媒体选取
        mediaSectionRow_Bague.snp.makeConstraints { make in
            make.top.equalTo(headerView_Bague.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(24)
        }
        mediaPickerView_Bague.snp.makeConstraints { make in
            make.top.equalTo(mediaSectionRow_Bague.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(180)
        }
        mediaPreviewImage_Bague.snp.makeConstraints { make in make.edges.equalToSuperview() }
        mediaIconBg_Bague.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-18)
            make.width.height.equalTo(60)
        }
        mediaAddIcon_Bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
        mediaHintTitle_Bague.snp.makeConstraints { make in
            make.top.equalTo(mediaIconBg_Bague.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        mediaHintSub_Bague.snp.makeConstraints { make in
            make.top.equalTo(mediaHintTitle_Bague.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        mediaClearBtn_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(30)
        }
        videoTagView_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        videoTagLabel_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 3, left: 6, bottom: 3, right: 6))
        }

        // 标题输入
        titleSectionRow_Bague.snp.makeConstraints { make in
            make.top.equalTo(mediaPickerView_Bague.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(24)
        }
        titleCard_Bague.snp.makeConstraints { make in
            make.top.equalTo(titleSectionRow_Bague.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        titleAccentBar_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(24)
        }
        titleField_Bague.snp.makeConstraints { make in
            make.leading.equalTo(titleAccentBar_Bague.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        // 内容输入
        contentSectionRow_Bague.snp.makeConstraints { make in
            make.top.equalTo(titleCard_Bague.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(24)
        }
        contentCard_Bague.snp.makeConstraints { make in
            make.top.equalTo(contentSectionRow_Bague.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        contentAccentBar_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.width.equalTo(4)
            make.height.equalTo(24)
        }
        contentTextView_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(contentAccentBar_Bague.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.height.greaterThanOrEqualTo(100)
        }
        contentPlaceholder_Bague.snp.makeConstraints { make in
            make.top.equalTo(contentTextView_Bague)
            make.leading.equalTo(contentTextView_Bague)
            make.trailing.equalToSuperview().offset(-16)
        }
        charCountLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(contentTextView_Bague.snp.bottom).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-10)
        }

        // 发布按钮
        publishBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(contentCard_Bague.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        eulaBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(publishBtn_Bague.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
        }
    }

    // MARK: - 渐变更新

    /// 更新头部三色渐变（与发现页保持色系一致）和发布按钮辅助渐变
    private func updateGradients_Bague() {
        // 头部渐变：深紫 → 天空蓝 → 薄荷绿
        headerGradient_Bague?.removeFromSuperlayer()
        let hGrad_bague = CAGradientLayer()
        hGrad_bague.frame = headerView_Bague.bounds
        hGrad_bague.colors = [
            UIColor(hexstring_Bague: "#BBA3FF").cgColor,
            UIColor(hexstring_Bague: "#7DC4F0").cgColor,
            UIColor(hexstring_Bague: "#99E8D0").cgColor
        ]
        hGrad_bague.locations = [0.0, 0.55, 1.0]
        hGrad_bague.startPoint = CGPoint(x: 0, y: 0)
        hGrad_bague.endPoint = CGPoint(x: 1, y: 1)
        hGrad_bague.cornerRadius = 28
        hGrad_bague.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Bague.layer.insertSublayer(hGrad_bague, at: 0)
        headerGradient_Bague = hGrad_bague

        // 发布按钮渐变：玫瑰粉 → 珊瑚橙（辅助色系）
        publishBtnGradient_Bague?.removeFromSuperlayer()
        let bGrad_bague = CAGradientLayer()
        bGrad_bague.frame = publishBtn_Bague.bounds
        bGrad_bague.colors = [
            UIColor(hexstring_Bague: "#F07DAD").cgColor,
            UIColor(hexstring_Bague: "#FFA07A").cgColor
        ]
        bGrad_bague.startPoint = CGPoint(x: 0, y: 0)
        bGrad_bague.endPoint = CGPoint(x: 1, y: 0)
        bGrad_bague.cornerRadius = 26
        publishBtn_Bague.layer.insertSublayer(bGrad_bague, at: 0)
        publishBtnGradient_Bague = bGrad_bague
    }

    /// 绘制媒体选区虚线圆角边框
    private func updateDashedBorder_Bague() {
        dashedBorderLayer_Bague?.removeFromSuperlayer()
        guard mediaPreviewImage_Bague.isHidden else { return }
        let dashed_bague = CAShapeLayer()
        let rect_bague = mediaPickerView_Bague.bounds
        dashed_bague.path = UIBezierPath(roundedRect: rect_bague, cornerRadius: 18).cgPath
        dashed_bague.strokeColor = UIColor(hexstring_Bague: "#C4ABFF").cgColor
        dashed_bague.fillColor = UIColor.clear.cgColor
        dashed_bague.lineWidth = 1.8
        dashed_bague.lineDashPattern = [8, 5]
        mediaPickerView_Bague.layer.insertSublayer(dashed_bague, at: 0)
        dashedBorderLayer_Bague = dashed_bague
    }

    // MARK: - 键盘处理

    private func setupKeyboardObservers_Bague() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Bague(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Bague(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow_Bague(_ notification: Notification) {
        guard let frame_bague = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_bague = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration_bague) {
            self.scrollView_Bague.contentInset.bottom = frame_bague.height + 20
            self.scrollView_Bague.verticalScrollIndicatorInsets.bottom = frame_bague.height
        }
    }

    @objc private func keyboardWillHide_Bague(_ notification: Notification) {
        guard let duration_bague = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration_bague) {
            self.scrollView_Bague.contentInset.bottom = 0
            self.scrollView_Bague.verticalScrollIndicatorInsets.bottom = 0
        }
    }

    @objc private func dismissKeyboard_Bague() {
        view.endEditing(true)
    }

    // MARK: - 事件处理

    @objc private func mediaPickerTapped_Bague() {
        guard selectedMediaPath_Bague == nil else { return }
        mediaPickerView_Bague.animatePulse_Bague()
        MediaPickerHelper_Bague.pickMedia_Bague(from: self) { [weak self] result_bague in
            guard let self = self else { return }
            switch result_bague {
            case .photo_Bague(let image_bague):
                self.handleImageSelected_Bague(image_bague)
            case .video_Bague(let url_bague):
                self.handleVideoSelected_Bague(url_bague)
            case .cancelled_Bague:
                break
            }
        }
    }

    private func handleImageSelected_Bague(_ image_bague: UIImage) {
        let path_bague = NSTemporaryDirectory() + "post_media_\(Date().timeIntervalSince1970).jpg"
        if let data_bague = image_bague.jpegData(compressionQuality: 0.85) {
            try? data_bague.write(to: URL(fileURLWithPath: path_bague))
        }
        selectedMediaPath_Bague = path_bague
        isVideoMedia_Bague = false
        showMediaPreview_Bague(image_bague, isVideo_bague: false)
    }

    private func handleVideoSelected_Bague(_ url_bague: URL) {
        selectedMediaPath_Bague = url_bague.path
        isVideoMedia_Bague = true
        let asset_bague = AVURLAsset(url: url_bague)
        let generator_bague = AVAssetImageGenerator(asset: asset_bague)
        generator_bague.appliesPreferredTrackTransform = true
        let previewImage_bague: UIImage
        if let cgImage_bague = try? generator_bague.copyCGImage(at: .zero, actualTime: nil) {
            previewImage_bague = UIImage(cgImage: cgImage_bague)
        } else {
            previewImage_bague = UIImage()
        }
        showMediaPreview_Bague(previewImage_bague, isVideo_bague: true)
    }

    /// 显示已选媒体预览，切换 UI 状态
    private func showMediaPreview_Bague(_ image_bague: UIImage, isVideo_bague: Bool) {
        mediaPreviewImage_Bague.image = image_bague
        mediaPreviewImage_Bague.isHidden = false
        mediaIconBg_Bague.isHidden = true
        mediaAddIcon_Bague.isHidden = true
        mediaHintTitle_Bague.isHidden = true
        mediaHintSub_Bague.isHidden = true
        mediaClearBtn_Bague.isHidden = false
        videoTagView_Bague.isHidden = !isVideo_bague
        // 隐藏虚线边框
        dashedBorderLayer_Bague?.removeFromSuperlayer()
        dashedBorderLayer_Bague = nil
    }

    @objc private func clearMedia_Bague() {
        selectedMediaPath_Bague = nil
        isVideoMedia_Bague = false
        mediaPreviewImage_Bague.isHidden = true
        mediaIconBg_Bague.isHidden = false
        mediaAddIcon_Bague.isHidden = false
        mediaHintTitle_Bague.isHidden = false
        mediaHintSub_Bague.isHidden = false
        mediaClearBtn_Bague.isHidden = true
        videoTagView_Bague.isHidden = true
        // 重新绘制虚线边框
        updateDashedBorder_Bague()
    }

    @objc private func btnDown_Bague() { publishBtn_Bague.animatePressDown_Bague() }
    @objc private func btnUp_Bague() { publishBtn_Bague.animatePressUp_Bague() }

    @objc private func publishTapped_Bague() {
        view.endEditing(true)

        // 登录检测
        if !UserViewModel_Bague.shared_Bague.isLoggedIn_Bague {
            Navigation_Bague.toLogin_Bague(style_bague: .present_bague)
            return
        }

        // 输入验证
        guard let title_bague = titleField_Bague.text, !title_bague.isEmpty else {
            titleField_Bague.animateShake_Bague()
            Utils_Bague.showWarning_Bague(message_Bague: "Please enter a title")
            return
        }

        let content_bague = contentTextView_Bague.text ?? ""
        guard !content_bague.isEmpty else {
            contentTextView_Bague.animateShake_Bague()
            Utils_Bague.showWarning_Bague(message_Bague: "Please write some content")
            return
        }

        guard let mediaPath_bague = selectedMediaPath_Bague else {
            mediaPickerView_Bague.animateShake_Bague()
            Utils_Bague.showWarning_Bague(message_Bague: "Please select a photo or video")
            return
        }

        // 发布帖子
        Task { @MainActor in
            TitleViewModel_Bague.shared_Bague.releasePost_Bague(
                title_bague: title_bague,
                content_bague: content_bague,
                media_bague: mediaPath_bague
            )
        }

        clearForm_Bague()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            Navigation_Bague.dismiss_Bague()
        }
    }

    @objc private func eulaTapped_Bague() {
        eulaBtn_Bague.animatePulse_Bague()
        ProtocolHelper_Bague.showProtocol_Bague(
            type_Bague: .eula_Bague,
            content_Bague: "terms.png",
            from: self
        )
    }

    private func clearForm_Bague() {
        titleField_Bague.text = ""
        contentTextView_Bague.text = ""
        contentPlaceholder_Bague.isHidden = false
        charCountLabel_Bague.text = "0 / 500"
        clearMedia_Bague()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextFieldDelegate

extension Release_Bague: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentTextView_Bague.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension Release_Bague: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        contentPlaceholder_Bague.isHidden = !textView.text.isEmpty
        // 更新字数计数（最多 500 字）
        let count_bague = textView.text.count
        charCountLabel_Bague.text = "\(count_bague) / 500"
        charCountLabel_Bague.textColor = count_bague > 500
            ? UIColor(hexstring_Bague: "#FF6B6B")
            : ColorConfig_Bague.textPlaceholder_Bague
    }
}

// MARK: - 辅助工厂方法

/// 创建带彩色图标的区段标题行视图
/// - Parameters:
///   - icon: SF Symbol 名称
///   - title: 标题文字
///   - tint: 图标与文字强调色
/// - Returns: 横向排列的区段标题视图
private func makeSectionRow_Release_Bague(icon: String, title: String, tint: UIColor) -> UIView {
    let container_bague = UIView()

    let iconView_bague = UIImageView()
    let cfg_bague = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
    iconView_bague.image = UIImage(systemName: icon, withConfiguration: cfg_bague)
    iconView_bague.tintColor = tint
    iconView_bague.contentMode = .scaleAspectFit

    let label_bague = UILabel()
    label_bague.text = title.uppercased()
    label_bague.font = UIFont.systemFont(ofSize: 11, weight: .bold)
    label_bague.textColor = tint

    container_bague.addSubview(iconView_bague)
    container_bague.addSubview(label_bague)

    iconView_bague.snp.makeConstraints { make in
        make.leading.centerY.equalToSuperview()
        make.width.height.equalTo(14)
    }
    label_bague.snp.makeConstraints { make in
        make.leading.equalTo(iconView_bague.snp.trailing).offset(6)
        make.centerY.equalToSuperview()
        make.trailing.equalToSuperview()
        make.top.bottom.equalToSuperview()
    }

    return container_bague
}
