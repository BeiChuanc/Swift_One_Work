import Foundation
import UIKit
import SnapKit

// MARK: 发布页面（重构版）

/// 发布帖子页面
/// 核心作用：提供丰富的帖子发布界面，涵盖彩虹头部、分步骤引导输入、媒体选取（图片/视频独立入口）和发布确认
/// 设计思路：
///   - 头部使用彩虹光谱条 + 大标题 + 副标题，与发现页保持视觉一致
///   - 各输入区块带步骤编号 (01/02/03)，右侧实时字数计数
///   - 媒体区支持 Photo/Video 独立快捷入口，已选媒体可一键移除
///   - 输入框聚焦时显示紫色高亮边框，提升交互层次感
/// 关键属性：
///   - selectedMediaPath_Lens: 已选媒体本地路径（发布时传给 ViewModel）
///   - selectedImage_Lens: 选取的图片预览对象
class Release_Lens: UIViewController {

    // MARK: - 私有属性

    /// 已选媒体文件本地路径（图片存 Documents，视频存临时目录）
    private var selectedMediaPath_Lens: String?

    /// 已选图片预览对象
    private var selectedImage_Lens: UIImage?

    // MARK: - UI 组件：背景装饰

    /// 顶部棱镜多层光晕渐变装饰层
    private let headerDecorView_Lens: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - UI 组件：滚动内容

    private let scrollView_Lens: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode = .interactive
        return sv
    }()

    private let contentView_Lens = UIView()

    // MARK: - UI 组件：顶部导航

    /// 彩虹光谱装饰条（与发现页视觉统一）
    private let spectrumBarView_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 页面大标题 "New Post"
    private let navTitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "New Post"
        l.font = .systemFont(ofSize: 26, weight: .bold)
        l.textColor = .white
        return l
    }()

    /// 页面副标题
    private let navSubtitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Share your lens moment"
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.4)
        return l
    }()


    // MARK: - UI 组件：标题输入区块

    /// 标题区块 section label（带步骤编号，用富文本设置）
    private let titleSectionLabel_Lens: UILabel = UILabel()

    /// 标题字数实时计数（"0/50"）
    private let titleCountLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "0/50"
        l.font = .systemFont(ofSize: 11)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.3)
        return l
    }()

    private let titleTextField_Lens: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 16, weight: .medium)
        tf.textColor = .white
        tf.backgroundColor = UIColor(hexstring_Lens: "#161626")
        tf.layer.cornerRadius = 14
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.08).cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        tf.rightViewMode = .always
        let placeholder_Lens = NSAttributedString(
            string: "Add a title...",
            attributes: [.foregroundColor: UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.22)]
        )
        tf.attributedPlaceholder = placeholder_Lens
        return tf
    }()

    // MARK: - UI 组件：内容输入区块

    /// 内容区块 section label
    private let contentSectionLabel_Lens: UILabel = UILabel()

    /// 内容字数实时计数（"0/500"）
    private let contentCountLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "0/500"
        l.font = .systemFont(ofSize: 11)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.3)
        return l
    }()

    private let contentTextView_Lens: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 15)
        tv.textColor = .white
        tv.backgroundColor = UIColor(hexstring_Lens: "#161626")
        tv.layer.cornerRadius = 14
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.08).cgColor
        tv.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        return tv
    }()

    /// 内容区占位文本
    private let contentPlaceholderLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Share your color story..."
        l.font = .systemFont(ofSize: 15)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.22)
        return l
    }()

    // MARK: - UI 组件：媒体选取区块

    /// 媒体区块 section label
    private let mediaSectionLabel_Lens: UILabel = UILabel()

    /// 媒体选取容器（虚线边框 + 内容）
    private let mediaPickerView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#161626")
        v.layer.cornerRadius = 16
        v.isUserInteractionEnabled = true
        return v
    }()

    /// 虚线边框 CAShapeLayer（空状态时显示）
    private var dashedBorderLayer_Lens: CAShapeLayer?

    /// 相机图标（空状态中心）
    private let mediaIconView_Lens: UIImageView = {
        let iv = UIImageView()
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 34, weight: .light)
        iv.image = UIImage(systemName: "camera.fill", withConfiguration: cfg_Lens)
        iv.tintColor = UIColor(hexstring_Lens: "#7B2FF7")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 媒体选取提示文字
    private let mediaHintLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Choose from your library"
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.38)
        l.textAlignment = .center
        return l
    }()

    /// 媒体类型标签行容器
    private let mediaTagRow_Lens = UIView()

    /// Photo 快速入口 pill 按钮（蓝色）
    private let photoTagButton_Lens: UIButton = {
        let b = UIButton(type: .custom)
        b.backgroundColor = UIColor(hexstring_Lens: "#4D96FF", alpha_Lens: 0.14)
        b.layer.cornerRadius = 13
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor(hexstring_Lens: "#4D96FF", alpha_Lens: 0.35).cgColor
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        b.setImage(UIImage(systemName: "photo.fill", withConfiguration: cfg_Lens), for: .normal)
        b.tintColor = UIColor(hexstring_Lens: "#4D96FF")
        b.setTitle("  Photo", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        b.setTitleColor(UIColor(hexstring_Lens: "#4D96FF"), for: .normal)
        b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 14)
        return b
    }()

    /// Video 快速入口 pill 按钮（紫色）
    private let videoTagButton_Lens: UIButton = {
        let b = UIButton(type: .custom)
        b.backgroundColor = UIColor(hexstring_Lens: "#C77DFF", alpha_Lens: 0.14)
        b.layer.cornerRadius = 13
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor(hexstring_Lens: "#C77DFF", alpha_Lens: 0.35).cgColor
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        b.setImage(UIImage(systemName: "video.fill", withConfiguration: cfg_Lens), for: .normal)
        b.tintColor = UIColor(hexstring_Lens: "#C77DFF")
        b.setTitle("  Video", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        b.setTitleColor(UIColor(hexstring_Lens: "#C77DFF"), for: .normal)
        b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 14)
        return b
    }()

    /// 已选媒体预览视图（覆盖整个 picker 区域）
    private let mediaPreviewView_Lens: MediaDisplayView_Lens = {
        let v = MediaDisplayView_Lens()
        v.isHidden = true
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    /// 移除媒体按钮（预览状态右上角显示）
    private let mediaRemoveButton_Lens: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Lens), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor(hexstring_Lens: "#000000", alpha_Lens: 0.6)
        b.layer.cornerRadius = 14
        b.isHidden = true
        return b
    }()

    // MARK: - UI 组件：发布区域

    /// 发布前提示文案
    private let tipsLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Your post will be visible to all members"
        l.font = .systemFont(ofSize: 12)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.28)
        l.textAlignment = .center
        return l
    }()

    /// 发布按钮（渐变背景 + 前置图标）
    private let publishButton_Lens: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("Publish Now", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        b.layer.cornerRadius = 16
        b.clipsToBounds = true
        return b
    }()

    /// 发布按钮前置纸飞机图标
    private let publishIconView_Lens: UIImageView = {
        let iv = UIImageView()
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        iv.image = UIImage(systemName: "paperplane.fill", withConfiguration: cfg_Lens)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        return iv
    }()

    /// 发布按钮渐变层（紫→蓝）
    private let publishGradientLayer_Lens: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(hexstring_Lens: "#7B2FF7").cgColor,
            UIColor(hexstring_Lens: "#2D5BE3").cgColor
        ]
        g.startPoint = CGPoint(x: 0, y: 0.5)
        g.endPoint = CGPoint(x: 1, y: 0.5)
        return g
    }()

    /// EULA 协议按钮（带下划线）
    private let eulaButton_Lens: UIButton = {
        let b = UIButton(type: .system)
        let attrs_Lens: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.3),
            .font: UIFont.systemFont(ofSize: 12),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        b.setAttributedTitle(NSAttributedString(string: "EULA Agreement", attributes: attrs_Lens), for: .normal)
        return b
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lens()
        setupConstraints_Lens()
        bindActions_Lens()
        setupKeyboardObserver_Lens()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateDashedBorder_Lens()
        publishGradientLayer_Lens.frame = publishButton_Lens.bounds
        // 同步彩虹条渐变层尺寸
        spectrumBarView_Lens.layer.sublayers?.forEach { $0.frame = spectrumBarView_Lens.bounds }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Lens() {
        view.backgroundColor = UIColor(hexstring_Lens: "#0D0D1A")

        // 顶部光晕装饰（最底层）
        view.addSubview(headerDecorView_Lens)
        setupHeaderGlows_Lens()

        // 滚动视图
        view.addSubview(scrollView_Lens)
        scrollView_Lens.addSubview(contentView_Lens)

        // 导航区
        contentView_Lens.addSubview(spectrumBarView_Lens)
        contentView_Lens.addSubview(navTitleLabel_Lens)
        contentView_Lens.addSubview(navSubtitleLabel_Lens)
        setupSpectrumBar_Lens()

        // 标题区
        contentView_Lens.addSubview(titleSectionLabel_Lens)
        contentView_Lens.addSubview(titleCountLabel_Lens)
        contentView_Lens.addSubview(titleTextField_Lens)

        // 内容区
        contentView_Lens.addSubview(contentSectionLabel_Lens)
        contentView_Lens.addSubview(contentCountLabel_Lens)
        contentView_Lens.addSubview(contentTextView_Lens)
        contentTextView_Lens.addSubview(contentPlaceholderLabel_Lens)

        // 媒体区
        contentView_Lens.addSubview(mediaSectionLabel_Lens)
        contentView_Lens.addSubview(mediaPickerView_Lens)
        mediaPickerView_Lens.addSubview(mediaIconView_Lens)
        mediaPickerView_Lens.addSubview(mediaHintLabel_Lens)
        mediaPickerView_Lens.addSubview(mediaTagRow_Lens)
        mediaTagRow_Lens.addSubview(photoTagButton_Lens)
        mediaTagRow_Lens.addSubview(videoTagButton_Lens)
        mediaPickerView_Lens.addSubview(mediaPreviewView_Lens)
        mediaPickerView_Lens.addSubview(mediaRemoveButton_Lens)

        // 发布区
        contentView_Lens.addSubview(tipsLabel_Lens)
        contentView_Lens.addSubview(publishButton_Lens)
        publishButton_Lens.layer.insertSublayer(publishGradientLayer_Lens, at: 0)
        publishButton_Lens.addSubview(publishIconView_Lens)
        contentView_Lens.addSubview(eulaButton_Lens)

        // 设置代理
        contentTextView_Lens.delegate = self
        titleTextField_Lens.delegate = self

        // 设置各区块 section label 富文本
        setupSectionLabels_Lens()
    }

    /// 设置各区块带步骤编号的富文本 section label
    private func setupSectionLabels_Lens() {
        titleSectionLabel_Lens.attributedText = makeSectionAttr_Lens(step_Lens: "01", title_Lens: "TITLE")
        contentSectionLabel_Lens.attributedText = makeSectionAttr_Lens(step_Lens: "02", title_Lens: "STORY")
        mediaSectionLabel_Lens.attributedText = makeSectionAttr_Lens(step_Lens: "03", title_Lens: "MEDIA")
    }

    /// 生成步骤编号 + 区块标题的富文本
    /// - Parameters:
    ///   - step_Lens: 步骤编号，如 "01"
    ///   - title_Lens: 区块名称，如 "TITLE"
    /// - Returns: 紫色编号 + 灰白色标题的 NSAttributedString
    private func makeSectionAttr_Lens(step_Lens: String, title_Lens: String) -> NSAttributedString {
        let result_Lens = NSMutableAttributedString(
            string: "\(step_Lens)  ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 11, weight: .bold),
                .foregroundColor: UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.9)
            ]
        )
        result_Lens.append(NSAttributedString(
            string: title_Lens,
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.45)
            ]
        ))
        return result_Lens
    }

    /// 构建顶部多层径向光晕（紫色 + 蓝色，与发现页统一）
    private func setupHeaderGlows_Lens() {
        let purpleGlow_Lens = CAGradientLayer()
        purpleGlow_Lens.type = .radial
        purpleGlow_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.28).cgColor,
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0).cgColor
        ]
        purpleGlow_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        purpleGlow_Lens.endPoint = CGPoint(x: 1.0, y: 1.0)
        purpleGlow_Lens.frame = CGRect(x: -80, y: -60, width: 300, height: 300)
        headerDecorView_Lens.layer.addSublayer(purpleGlow_Lens)

        let blueGlow_Lens = CAGradientLayer()
        blueGlow_Lens.type = .radial
        blueGlow_Lens.colors = [
            UIColor(hexstring_Lens: "#2D5BE3", alpha_Lens: 0.18).cgColor,
            UIColor(hexstring_Lens: "#2D5BE3", alpha_Lens: 0).cgColor
        ]
        blueGlow_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        blueGlow_Lens.endPoint = CGPoint(x: 1.0, y: 1.0)
        let screenW_Lens = UIScreen.main.bounds.width
        blueGlow_Lens.frame = CGRect(x: screenW_Lens - 50, y: 30, width: 180, height: 180)
        headerDecorView_Lens.layer.addSublayer(blueGlow_Lens)
    }

    /// 构建彩虹光谱装饰条渐变
    private func setupSpectrumBar_Lens() {
        let colors_Lens: [UIColor] = [
            UIColor(hexstring_Lens: "#FF6B6B"),
            UIColor(hexstring_Lens: "#FFB347"),
            UIColor(hexstring_Lens: "#FFD93D"),
            UIColor(hexstring_Lens: "#6BCB77"),
            UIColor(hexstring_Lens: "#4D96FF"),
            UIColor(hexstring_Lens: "#C77DFF")
        ]
        let gradient_Lens = CAGradientLayer()
        gradient_Lens.colors = colors_Lens.map { $0.cgColor }
        gradient_Lens.startPoint = CGPoint(x: 0, y: 0.5)
        gradient_Lens.endPoint = CGPoint(x: 1, y: 0.5)
        gradient_Lens.cornerRadius = 2
        spectrumBarView_Lens.layer.addSublayer(gradient_Lens)
    }

    // MARK: - 约束

    /// 设置所有 SnapKit 约束
    private func setupConstraints_Lens() {
        headerDecorView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(220)
        }

        scrollView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(view)
        }

        // 彩虹条（从 contentView 顶部偏移；.automatic 模式下系统会把安全区高度加到 adjustedContentInset.top，
        // 因此滚动到顶时此元素正好出现在安全区下方 18pt 处）
        spectrumBarView_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview().offset(18)
            $0.width.equalTo(36)
            $0.height.equalTo(4)
        }

        // 大标题
        navTitleLabel_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(spectrumBarView_Lens.snp.bottom).offset(8)
        }

        // 副标题
        navSubtitleLabel_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(navTitleLabel_Lens.snp.bottom).offset(4)
        }

        // 标题区
        titleSectionLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(navSubtitleLabel_Lens.snp.bottom).offset(28)
            $0.leading.equalToSuperview().offset(24)
        }
        titleCountLabel_Lens.snp.makeConstraints {
            $0.centerY.equalTo(titleSectionLabel_Lens)
            $0.trailing.equalToSuperview().inset(24)
        }
        titleTextField_Lens.snp.makeConstraints {
            $0.top.equalTo(titleSectionLabel_Lens.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }

        // 内容区
        contentSectionLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(titleTextField_Lens.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(24)
        }
        contentCountLabel_Lens.snp.makeConstraints {
            $0.centerY.equalTo(contentSectionLabel_Lens)
            $0.trailing.equalToSuperview().inset(24)
        }
        contentTextView_Lens.snp.makeConstraints {
            $0.top.equalTo(contentSectionLabel_Lens.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(160)
        }
        contentPlaceholderLabel_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(17)
        }

        // 媒体区
        mediaSectionLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(contentTextView_Lens.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(24)
        }
        mediaPickerView_Lens.snp.makeConstraints {
            $0.top.equalTo(mediaSectionLabel_Lens.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(180)
        }

        // 媒体 picker 内部（空状态）
        mediaIconView_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-22)
            $0.width.height.equalTo(42)
        }
        mediaHintLabel_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(mediaIconView_Lens.snp.bottom).offset(8)
        }
        mediaTagRow_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(mediaHintLabel_Lens.snp.bottom).offset(12)
            $0.height.equalTo(28)
        }
        photoTagButton_Lens.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }
        videoTagButton_Lens.snp.makeConstraints {
            $0.leading.equalTo(photoTagButton_Lens.snp.trailing).offset(8)
            $0.top.bottom.trailing.equalToSuperview()
        }

        // 媒体预览（覆盖整个 picker）
        mediaPreviewView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // 移除按钮（预览右上角）
        mediaRemoveButton_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().inset(10)
            $0.width.height.equalTo(28)
        }

        // 发布区
        tipsLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(mediaPickerView_Lens.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        publishButton_Lens.snp.makeConstraints {
            $0.top.equalTo(tipsLabel_Lens.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(56)
        }
        publishIconView_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(18)
        }
        eulaButton_Lens.snp.makeConstraints {
            $0.top.equalTo(publishButton_Lens.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(100)
        }
    }

    // MARK: - 事件绑定

    /// 绑定所有按钮和手势事件
    private func bindActions_Lens() {
        publishButton_Lens.addTarget(self, action: #selector(handlePublish_Lens), for: .touchUpInside)
        eulaButton_Lens.addTarget(self, action: #selector(handleEULA_Lens), for: .touchUpInside)
        photoTagButton_Lens.addTarget(self, action: #selector(handlePhotoTag_Lens), for: .touchUpInside)
        videoTagButton_Lens.addTarget(self, action: #selector(handleVideoTag_Lens), for: .touchUpInside)
        mediaRemoveButton_Lens.addTarget(self, action: #selector(handleRemoveMedia_Lens), for: .touchUpInside)

        // 点击媒体区（非预览状态）弹出全类型选择器
        let mediaTap_Lens = UITapGestureRecognizer(target: self, action: #selector(handleMediaPicker_Lens))
        mediaPickerView_Lens.addGestureRecognizer(mediaTap_Lens)

        let bgTap_Lens = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Lens))
        bgTap_Lens.cancelsTouchesInView = false
        view.addGestureRecognizer(bgTap_Lens)
    }

    // MARK: - 键盘监听

    /// 注册键盘弹出/收起通知
    private func setupKeyboardObserver_Lens() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Lens(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Lens(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // MARK: - 动作响应

    /// 打开图片选择器（仅图片模式）
    @objc private func handlePhotoTag_Lens() {
        MediaPickerHelper_Lens.shared_Lens.showPicker_Lens(
            from: self,
            mediaType_Lens: .photo_Lens
        ) { [weak self] result_Lens in
            guard let self else { return }
            if case .photo_Lens(let image_Lens) = result_Lens {
                self.handlePickedPhoto_Lens(image_Lens: image_Lens)
            }
        }
    }

    /// 打开视频选择器（仅视频模式）
    @objc private func handleVideoTag_Lens() {
        MediaPickerHelper_Lens.shared_Lens.showPicker_Lens(
            from: self,
            mediaType_Lens: .video_Lens
        ) { [weak self] result_Lens in
            guard let self else { return }
            if case .video_Lens(let url_Lens) = result_Lens {
                self.handlePickedVideo_Lens(url_Lens: url_Lens)
            }
        }
    }

    /// 点击媒体区弹出图片 + 视频混合选择器（仅空状态时响应）
    @objc private func handleMediaPicker_Lens() {
        guard mediaPreviewView_Lens.isHidden else { return }
        MediaPickerHelper_Lens.shared_Lens.showPicker_Lens(
            from: self,
            mediaType_Lens: .photoAndVideo_Lens
        ) { [weak self] result_Lens in
            guard let self else { return }
            switch result_Lens {
            case .photo_Lens(let image_Lens):
                self.handlePickedPhoto_Lens(image_Lens: image_Lens)
            case .video_Lens(let url_Lens):
                self.handlePickedVideo_Lens(url_Lens: url_Lens)
            case .cancelled_Lens:
                print("用户取消了媒体选择")
            }
        }
    }

    /// 处理选取的图片：保存到 Documents 并更新预览
    /// - Parameter image_Lens: 从相册选取的 UIImage
    private func handlePickedPhoto_Lens(image_Lens: UIImage) {
        selectedImage_Lens = image_Lens
        let fileName_Lens = "release_img_\(Int(Date().timeIntervalSince1970)).jpg"
        let docs_Lens = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_Lens = docs_Lens.appendingPathComponent(fileName_Lens)
        if let data_Lens = image_Lens.jpegData(compressionQuality: 0.85) {
            try? data_Lens.write(to: fileURL_Lens)
            selectedMediaPath_Lens = fileURL_Lens.path
        }
        mediaPreviewView_Lens.configureWithImage_Lens(image_Lens: image_Lens)
        showMediaPreview_Lens()
    }

    /// 处理选取的视频：使用临时路径展示缩略图
    /// - Parameter url_Lens: 视频临时文件 URL
    private func handlePickedVideo_Lens(url_Lens: URL) {
        selectedMediaPath_Lens = url_Lens.path
        mediaPreviewView_Lens.configure_Lens(mediaPath_Lens: url_Lens.path, isVideo_Lens: true)
        showMediaPreview_Lens()
    }

    /// 展示媒体预览状态，隐藏空状态 UI
    private func showMediaPreview_Lens() {
        mediaIconView_Lens.isHidden = true
        mediaHintLabel_Lens.isHidden = true
        mediaTagRow_Lens.isHidden = true
        mediaPreviewView_Lens.isHidden = false
        mediaRemoveButton_Lens.isHidden = false
        // 预览状态移除虚线边框
        dashedBorderLayer_Lens?.removeFromSuperlayer()
        dashedBorderLayer_Lens = nil
    }

    /// 移除已选媒体，恢复空状态 UI（带触觉反馈）
    @objc private func handleRemoveMedia_Lens() {
        let generator_Lens = UIImpactFeedbackGenerator(style: .light)
        generator_Lens.impactOccurred()
        selectedMediaPath_Lens = nil
        selectedImage_Lens = nil
        mediaPreviewView_Lens.isHidden = true
        mediaRemoveButton_Lens.isHidden = true
        mediaIconView_Lens.isHidden = false
        mediaHintLabel_Lens.isHidden = false
        mediaTagRow_Lens.isHidden = false
        updateDashedBorder_Lens()
    }

    /// 发布帖子：校验登录状态、输入字段、媒体，调用 ViewModel 发布
    @objc private func handlePublish_Lens() {
        guard UserViewModel_Lens.shared_Lens.isLoggedIn_Lens else {
            Navigation_Lens.dismiss_Lens(from: self)
            Navigation_Lens.toLogin_Lens(style_lens: .present_lens)
            return
        }

        let title_Lens = titleTextField_Lens.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let content_Lens = contentTextView_Lens.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !title_Lens.isEmpty else {
            Load_Lens.showWarning_Lens(message_Lens: "Please add a title.")
            return
        }
        guard !content_Lens.isEmpty else {
            Load_Lens.showWarning_Lens(message_Lens: "Please share your color story.")
            return
        }
        guard let mediaPath_Lens = selectedMediaPath_Lens, !mediaPath_Lens.isEmpty else {
            Load_Lens.showWarning_Lens(message_Lens: "Please add a photo or video.")
            return
        }

        TitleViewModel_Lens.shared_Lens.releasePost_Lens(
            title_lens: title_Lens,
            content_lens: content_Lens,
            media_lens: mediaPath_Lens
        )

        clearForm_Lens()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            Navigation_Lens.dismiss_Lens(from: self)
        }
    }

    /// 展示 EULA 协议页面
    @objc private func handleEULA_Lens() {
        ProtocolHelper_Lens.showProtocol_Lens(
            type_Lens: .eula_Lens,
            content_Lens: "txt",
            from: self
        )
    }

    @objc private func dismissKeyboard_Lens() {
        view.endEditing(true)
    }

    /// 键盘弹出时调整 scrollView 底部 inset，确保内容可见
    @objc private func keyboardWillShow_Lens(_ notification: Notification) {
        guard let userInfo_Lens = notification.userInfo,
              let keyboardFrame_Lens = userInfo_Lens[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_Lens = userInfo_Lens[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        UIView.animate(withDuration: duration_Lens) {
            self.scrollView_Lens.contentInset.bottom = keyboardFrame_Lens.height
            self.scrollView_Lens.scrollIndicatorInsets.bottom = keyboardFrame_Lens.height
        }
    }

    /// 键盘收起时恢复 scrollView 底部 inset
    @objc private func keyboardWillHide_Lens(_ notification: Notification) {
        guard let userInfo_Lens = notification.userInfo,
              let duration_Lens = userInfo_Lens[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        UIView.animate(withDuration: duration_Lens) {
            self.scrollView_Lens.contentInset.bottom = 0
            self.scrollView_Lens.scrollIndicatorInsets.bottom = 0
        }
    }

    // MARK: - 辅助方法

    /// 更新媒体区虚线边框（空状态时绘制，预览状态时不显示）
    private func updateDashedBorder_Lens() {
        guard mediaPreviewView_Lens.isHidden else { return }
        dashedBorderLayer_Lens?.removeFromSuperlayer()
        let border_Lens = CAShapeLayer()
        border_Lens.strokeColor = UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.4).cgColor
        border_Lens.fillColor = UIColor.clear.cgColor
        border_Lens.lineDashPattern = [8, 5]
        border_Lens.lineWidth = 1.5
        border_Lens.path = UIBezierPath(roundedRect: mediaPickerView_Lens.bounds, cornerRadius: 16).cgPath
        mediaPickerView_Lens.layer.insertSublayer(border_Lens, at: 0)
        dashedBorderLayer_Lens = border_Lens
    }

    /// 清空所有表单数据（发布成功后调用）
    private func clearForm_Lens() {
        titleTextField_Lens.text = nil
        contentTextView_Lens.text = nil
        contentPlaceholderLabel_Lens.isHidden = false
        titleCountLabel_Lens.text = "0/50"
        titleCountLabel_Lens.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.3)
        contentCountLabel_Lens.text = "0/500"
        contentCountLabel_Lens.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.3)
        selectedMediaPath_Lens = nil
        selectedImage_Lens = nil
        mediaPreviewView_Lens.isHidden = true
        mediaRemoveButton_Lens.isHidden = true
        mediaIconView_Lens.isHidden = false
        mediaHintLabel_Lens.isHidden = false
        mediaTagRow_Lens.isHidden = false
    }
}

// MARK: - UITextViewDelegate

extension Release_Lens: UITextViewDelegate {

    /// 内容变化时更新占位符显隐和字数计数
    func textViewDidChange(_ textView: UITextView) {
        contentPlaceholderLabel_Lens.isHidden = !textView.text.isEmpty
        let count_Lens = textView.text.count
        contentCountLabel_Lens.text = "\(min(count_Lens, 500))/500"
        // 超过 500 字时字数标红提示
        contentCountLabel_Lens.textColor = count_Lens > 500
            ? UIColor(hexstring_Lens: "#FF6B6B", alpha_Lens: 0.9)
            : UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.3)
    }

    /// 聚焦时高亮内容输入框边框
    func textViewDidBeginEditing(_ textView: UITextView) {
        contentTextView_Lens.layer.borderColor = UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.5).cgColor
    }

    /// 失焦时恢复内容输入框边框
    func textViewDidEndEditing(_ textView: UITextView) {
        contentTextView_Lens.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.08).cgColor
    }
}

// MARK: - UITextFieldDelegate

extension Release_Lens: UITextFieldDelegate {

    /// 实时更新标题字数计数，超过 50 字时阻止输入
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let current_Lens = textField.text ?? ""
        let updated_Lens = (current_Lens as NSString).replacingCharacters(in: range, with: string)
        let count_Lens = updated_Lens.count
        titleCountLabel_Lens.text = "\(min(count_Lens, 50))/50"
        // 超过 50 字时字数标红提示
        titleCountLabel_Lens.textColor = count_Lens > 50
            ? UIColor(hexstring_Lens: "#FF6B6B", alpha_Lens: 0.9)
            : UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.3)
        return count_Lens <= 50
    }

    /// 聚焦时高亮标题输入框边框
    func textFieldDidBeginEditing(_ textField: UITextField) {
        titleTextField_Lens.layer.borderColor = UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.5).cgColor
    }

    /// 失焦时恢复标题输入框边框
    func textFieldDidEndEditing(_ textField: UITextField) {
        titleTextField_Lens.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.08).cgColor
    }
}
