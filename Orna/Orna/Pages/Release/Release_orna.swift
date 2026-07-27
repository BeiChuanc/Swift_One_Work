import Foundation
import UIKit
import SnapKit

// MARK: 发布页面

/// 发布页面视图控制器
/// 核心作用：撰写标题、正文并从相册选择单个图片或视频完成帖子发布
/// 设计思路：
///   - 页面背景改为与首页/发现页一致的浅紫底色，营造统一的"桌面摆件"品牌基调
///   - 标题/正文/媒体三个输入区分别封装为独立卡片，卡片头部使用彩色图标徽标区分（紫/粉/橙三色呼应主题强调色），
///     丰富色彩层次的同时提升信息分区的可读性
///   - 媒体选择区在未选中媒体时叠加彩色渐变徽标 + 虚线描边，呈现清晰的"上传区"视觉语言
///   - 发布按钮使用紫粉渐变，呼应发现页横幅与首页签到卡片的强调色
///   - 确认发布按钮下方展示带下划线的 EULA 协议入口
///   - 发布前校验登录状态、标题/正文/媒体均非空；发布成功后清空表单数据
/// 关键属性：
///   - pickedImage_Orna / pickedVideoURL_Orna: 当前选中的媒体（二者互斥，只保留一个）
class Release_Orna: UIViewController {

    /// 已选中的图片
    private var pickedImage_Orna: UIImage?

    /// 已选中的视频临时文件地址
    private var pickedVideoURL_Orna: URL?

    // MARK: - UI · 顶部渐变横幅

    /// 头部改为与发现页横幅一致的紫粉渐变卡片，取代之前浅色纯文字头部，
    /// 统一全 App 各主要入口页面（发现页/首页签到卡）的强调色视觉基调，进一步丰富色彩层次
    private let heroCardView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 24
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.18
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.layer.shadowRadius = 16
        return v
    }()

    private var heroGradientLayer_Orna: CAGradientLayer?

    /// 装饰性图标（无关闭按钮时展示），呼应发现页横幅的 sparkles 图标语言
    private let headerIconView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "square.and.pencil"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 关闭按钮：与装饰图标共享同一角位，仅模态展示场景下替代图标显示
    private let closeButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let cfg_orna = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_orna), for: .normal)
        b.tintColor = UIColor(hexstring_Orna: "#7B61FF")
        b.backgroundColor = .white
        b.layer.cornerRadius = 16
        return b
    }()

    private let titleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "New Post"
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.textColor = .white
        return l
    }()

    /// 头部描述文案，说明该页面的用途，替代原来仅有标题的单薄头部
    private let subtitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Share a cozy moment from your desk with the community"
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        l.numberOfLines = 2
        return l
    }()

    // MARK: - UI · 滚动容器

    private let scrollView_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentView_Orna = UIView()

    // MARK: - UI · 标题卡片

    private let titleCardView_Orna = Release_Orna.makeCardContainer_Orna()

    private let titleField_Orna: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 15, weight: .semibold)
        tf.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        tf.placeholder = "Give your post a catchy title..."
        tf.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        tf.layer.cornerRadius = 14
        let padding_orna = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        tf.leftView = padding_orna
        tf.leftViewMode = .always
        return tf
    }()

    // MARK: - UI · 正文卡片

    private let storyCardView_Orna = Release_Orna.makeCardContainer_Orna()

    private let contentTextView_Orna: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 14, weight: .regular)
        tv.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        tv.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        tv.layer.cornerRadius = 14
        tv.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        return tv
    }()

    private let contentPlaceholderLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Share your desk story..."
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0").withAlphaComponent(0.7)
        return l
    }()

    // MARK: - UI · 媒体选择卡片

    private let mediaCardView_Orna = Release_Orna.makeCardContainer_Orna()

    private let mediaPreviewView_Orna = MediaDisplayView_Orna()

    /// 未选中媒体时的虚线描边（呈现清晰的"上传区"视觉语言）
    private let mediaDashBorderLayer_Orna: CAShapeLayer = {
        let layer_orna = CAShapeLayer()
        layer_orna.strokeColor = UIColor(hexstring_Orna: "#7B61FF").withAlphaComponent(0.4).cgColor
        layer_orna.fillColor = UIColor.clear.cgColor
        layer_orna.lineWidth = 1.5
        layer_orna.lineDashPattern = [6, 4]
        return layer_orna
    }()

    private let mediaHintView_Orna: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 渐变徽标背景（承载"+"图标，紫粉渐变呼应发布按钮与发现页横幅）
    private let mediaHintBadgeView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 26
        return v
    }()

    private var mediaHintBadgeGradientLayer_Orna: CAGradientLayer?

    private let mediaHintIconView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "plus"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let mediaHintLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Add a photo or video"
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        return l
    }()

    private let removeMediaButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let cfg_orna = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_orna), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        b.layer.cornerRadius = 14
        b.isHidden = true
        return b
    }()

    // MARK: - UI · 发布操作

    private let releaseButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Post It ✨", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        b.layer.cornerRadius = 24
        b.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        b.layer.shadowOpacity = 0.3
        b.layer.shadowOffset = CGSize(width: 0, height: 8)
        b.layer.shadowRadius = 14
        return b
    }()

    private var releaseButtonGradientLayer_Orna: CAGradientLayer?

    private let eulaHintLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = ""
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        return l
    }()

    private let eulaButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let attr_orna = NSAttributedString(
            string: "EULA",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .bold),
                .foregroundColor: UIColor(hexstring_Orna: "#7B61FF"),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        b.setAttributedTitle(attr_orna, for: .normal)
        return b
    }()

    private let eulaRow_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 4
        sv.alignment = .center
        return sv
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        setupUI_Orna()
        setupConstraints_Orna()
        setupActions_Orna()
        updateCloseButtonVisibility_Orna()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        updateCloseButtonVisibility_Orna()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heroGradientLayer_Orna?.frame = heroCardView_Orna.bounds
        releaseButtonGradientLayer_Orna?.frame = releaseButton_Orna.bounds
        mediaHintBadgeGradientLayer_Orna?.frame = mediaHintBadgeView_Orna.bounds
        mediaDashBorderLayer_Orna.frame = mediaPreviewView_Orna.bounds
        mediaDashBorderLayer_Orna.path = UIBezierPath(
            roundedRect: mediaPreviewView_Orna.bounds.insetBy(dx: 0.75, dy: 0.75), cornerRadius: 12
        ).cgPath
    }

    // MARK: - UI 搭建

    private func setupUI_Orna() {
        view.addSubview(heroCardView_Orna)
        heroCardView_Orna.addSubview(titleLabel_Orna)
        heroCardView_Orna.addSubview(subtitleLabel_Orna)
        heroCardView_Orna.addSubview(headerIconView_Orna)
        heroCardView_Orna.addSubview(closeButton_Orna)
        setupHeroGradient_Orna()

        view.addSubview(scrollView_Orna)
        scrollView_Orna.addSubview(contentView_Orna)

        // 标题卡片
        contentView_Orna.addSubview(titleCardView_Orna)
        let titleHeader_orna = makeSectionHeader_Orna(
            icon_orna: "textformat.size", text_orna: "Title", accentColorHex_orna: "#7B61FF"
        )
        titleCardView_Orna.addSubview(titleHeader_orna)
        titleCardView_Orna.addSubview(titleField_Orna)
        titleHeader_orna.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(16)
        }
        titleField_Orna.snp.makeConstraints {
            $0.top.equalTo(titleHeader_orna.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }

        // 正文卡片
        contentView_Orna.addSubview(storyCardView_Orna)
        let storyHeader_orna = makeSectionHeader_Orna(
            icon_orna: "text.alignleft", text_orna: "Story", accentColorHex_orna: "#FF6B9D"
        )
        storyCardView_Orna.addSubview(storyHeader_orna)
        storyCardView_Orna.addSubview(contentTextView_Orna)
        contentTextView_Orna.addSubview(contentPlaceholderLabel_Orna)
        storyHeader_orna.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(16)
        }
        contentTextView_Orna.snp.makeConstraints {
            $0.top.equalTo(storyHeader_orna.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(120)
        }
        contentPlaceholderLabel_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        // 媒体卡片
        contentView_Orna.addSubview(mediaCardView_Orna)
        let mediaHeader_orna = makeSectionHeader_Orna(
            icon_orna: "photo.on.rectangle.angled", text_orna: "Photo / Video", accentColorHex_orna: "#FF9A6C"
        )
        mediaCardView_Orna.addSubview(mediaHeader_orna)
        mediaCardView_Orna.addSubview(mediaPreviewView_Orna)
        // 已自定义渐变徽标 + 文案作为占位提示，隐藏组件内置占位图标避免二者重叠遮盖
        mediaPreviewView_Orna.showsBuiltInPlaceholder_Orna = false
        mediaPreviewView_Orna.layer.addSublayer(mediaDashBorderLayer_Orna)
        mediaHintView_Orna.addSubview(mediaHintBadgeView_Orna)
        mediaHintBadgeView_Orna.addSubview(mediaHintIconView_Orna)
        mediaHintView_Orna.addSubview(mediaHintLabel_Orna)
        mediaPreviewView_Orna.addSubview(mediaHintView_Orna)
        mediaPreviewView_Orna.addSubview(removeMediaButton_Orna)
        setupMediaHintGradient_Orna()
        mediaHeader_orna.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(16)
        }
        mediaPreviewView_Orna.snp.makeConstraints {
            $0.top.equalTo(mediaHeader_orna.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(180)
        }
        mediaHintView_Orna.snp.makeConstraints { $0.center.equalToSuperview() }
        mediaHintBadgeView_Orna.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.width.height.equalTo(52)
        }
        mediaHintIconView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(20)
        }
        mediaHintLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(mediaHintBadgeView_Orna.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        removeMediaButton_Orna.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(10)
            $0.width.height.equalTo(28)
        }

        // 发布按钮 + EULA
        contentView_Orna.addSubview(releaseButton_Orna)
        setupReleaseButtonGradient_Orna()
        eulaRow_Orna.addArrangedSubview(eulaHintLabel_Orna)
        eulaRow_Orna.addArrangedSubview(eulaButton_Orna)
        contentView_Orna.addSubview(eulaRow_Orna)
    }

    /// 搭建标题/正文/媒体三个卡片统一的顶部圆角容器
    private static func makeCardContainer_Orna() -> UIView {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 10
        return v
    }

    /// 搭建卡片头部图标徽标 + 分区标题，用于区分标题/正文/媒体三个输入区并丰富色彩层次
    /// 参数：
    /// - icon_orna: SF Symbols 图标名称
    /// - text_orna: 分区标题文本
    /// - accentColorHex_orna: 该分区的强调色（十六进制）
    private func makeSectionHeader_Orna(icon_orna: String, text_orna: String, accentColorHex_orna: String) -> UIView {
        let container_orna = UIView()
        let accentColor_orna = UIColor(hexstring_Orna: accentColorHex_orna)

        let badge_orna = UIView()
        badge_orna.backgroundColor = accentColor_orna.withAlphaComponent(0.15)
        badge_orna.layer.cornerRadius = 14

        let icon_view_orna = UIImageView(image: UIImage(systemName: icon_orna))
        icon_view_orna.tintColor = accentColor_orna
        icon_view_orna.contentMode = .scaleAspectFit

        let label_orna = UILabel()
        label_orna.text = text_orna
        label_orna.font = .systemFont(ofSize: 14, weight: .bold)
        label_orna.textColor = UIColor(hexstring_Orna: "#2D2A3D")

        container_orna.addSubview(badge_orna)
        badge_orna.addSubview(icon_view_orna)
        container_orna.addSubview(label_orna)

        badge_orna.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.height.equalTo(28)
        }
        icon_view_orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(14)
        }
        label_orna.snp.makeConstraints {
            $0.leading.equalTo(badge_orna.snp.trailing).offset(8)
            $0.centerY.equalTo(badge_orna)
            $0.trailing.lessThanOrEqualToSuperview()
        }
        return container_orna
    }

    /// 搭建发布按钮的紫粉渐变，呼应发现页横幅与首页签到卡片的强调色
    private func setupReleaseButtonGradient_Orna() {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor(hexstring_Orna: "#7B61FF").cgColor,
            UIColor(hexstring_Orna: "#FF6B9D").cgColor,
        ]
        layer_orna.startPoint = CGPoint(x: 0, y: 0)
        layer_orna.endPoint = CGPoint(x: 1, y: 1)
        layer_orna.cornerRadius = 24
        releaseButton_Orna.layer.insertSublayer(layer_orna, at: 0)
        releaseButtonGradientLayer_Orna = layer_orna
    }

    /// 搭建头部横幅的紫粉渐变，与发现页横幅（heroCardView_Orna）保持同一视觉语言，
    /// 让"发布"这一核心操作入口在色彩上与"发现"入口形成呼应，强化桌面摆件品牌基调
    private func setupHeroGradient_Orna() {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor(hexstring_Orna: "#7B61FF").cgColor,
            UIColor(hexstring_Orna: "#FF6B9D").cgColor,
        ]
        layer_orna.startPoint = CGPoint(x: 0, y: 0)
        layer_orna.endPoint = CGPoint(x: 1, y: 1)
        layer_orna.cornerRadius = 24
        heroCardView_Orna.layer.insertSublayer(layer_orna, at: 0)
        heroGradientLayer_Orna = layer_orna
    }

    /// 搭建媒体占位徽标的紫粉渐变
    private func setupMediaHintGradient_Orna() {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor(hexstring_Orna: "#7B61FF").cgColor,
            UIColor(hexstring_Orna: "#FF9A6C").cgColor,
        ]
        layer_orna.startPoint = CGPoint(x: 0, y: 0)
        layer_orna.endPoint = CGPoint(x: 1, y: 1)
        layer_orna.cornerRadius = 26
        mediaHintBadgeView_Orna.layer.insertSublayer(layer_orna, at: 0)
        mediaHintBadgeGradientLayer_Orna = layer_orna
    }

    private func setupConstraints_Orna() {
        heroCardView_Orna.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(104)
        }
        headerIconView_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.trailing.equalToSuperview().offset(-18)
            $0.width.height.equalTo(26)
        }
        closeButton_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-14)
            $0.width.height.equalTo(32)
        }
        titleLabel_Orna.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualTo(headerIconView_Orna.snp.leading).offset(-10)
        }
        subtitleLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(titleLabel_Orna.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        scrollView_Orna.snp.makeConstraints {
            $0.top.equalTo(heroCardView_Orna.snp.bottom).offset(18)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        titleCardView_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        storyCardView_Orna.snp.makeConstraints {
            $0.top.equalTo(titleCardView_Orna.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        mediaCardView_Orna.snp.makeConstraints {
            $0.top.equalTo(storyCardView_Orna.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        releaseButton_Orna.snp.makeConstraints {
            $0.top.equalTo(mediaCardView_Orna.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(50)
        }
        eulaRow_Orna.snp.makeConstraints {
            $0.top.equalTo(releaseButton_Orna.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            // 底部预留悬浮导航栏遮挡高度，确保内容可以完全滚动到导航栏上方，不被其遮盖
            $0.bottom.equalToSuperview().offset(-TabBar_Orna.floatingBarClearance_Orna)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Orna() {
        closeButton_Orna.addTarget(self, action: #selector(handleCloseTapped_Orna), for: .touchUpInside)
        releaseButton_Orna.addTarget(self, action: #selector(handleReleaseTapped_Orna), for: .touchUpInside)
        eulaButton_Orna.addTarget(self, action: #selector(handleEULATapped_Orna), for: .touchUpInside)
        removeMediaButton_Orna.addTarget(self, action: #selector(handleRemoveMediaTapped_Orna), for: .touchUpInside)

        contentTextView_Orna.delegate = self
        mediaPreviewView_Orna.isUserInteractionEnabled = true
        mediaPreviewView_Orna.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMediaTapped_Orna)))
    }

    // MARK: - 事件处理

    @objc private func handleCloseTapped_Orna() {
        dismissOrGoHome_Orna()
    }

    /// 更新关闭按钮的显示状态：
    /// 作为底部 Tab 常驻页面展示时无需关闭按钮（切换其他 Tab 即可离开，展示关闭按钮反而造成误导），
    /// 此时头部右上角展示装饰性编辑图标，呼应发现页横幅的图标语言；
    /// 仅当页面是通过模态方式单独展示时（如首页快捷入口跳转）才显示关闭按钮供用户主动退出，
    /// 并隐藏装饰图标以避免同一角位两个元素相互遮盖
    private func updateCloseButtonVisibility_Orna() {
        let isModal_orna = presentingViewController != nil
        closeButton_Orna.isHidden = !isModal_orna
        headerIconView_Orna.isHidden = isModal_orna
    }

    /// 点击媒体区：弹出相册选择图片或视频
    @objc private func handleMediaTapped_Orna() {
        MediaPickerHelper_Orna.pickMedia_Orna(from: self) { [weak self] result_orna in
            guard let self else { return }
            switch result_orna {
            case .photo_Orna(let image_orna):
                self.pickedImage_Orna = image_orna
                self.pickedVideoURL_Orna = nil
                self.mediaPreviewView_Orna.configureWithImage_Orna(image_Orna: image_orna)
                self.mediaHintView_Orna.isHidden = true
                self.mediaDashBorderLayer_Orna.isHidden = true
                self.removeMediaButton_Orna.isHidden = false
            case .video_Orna(let url_orna):
                self.pickedVideoURL_Orna = url_orna
                self.pickedImage_Orna = nil
                self.mediaPreviewView_Orna.configure_Orna(mediaPath_Orna: url_orna.path, isVideo_Orna: true)
                self.mediaHintView_Orna.isHidden = true
                self.mediaDashBorderLayer_Orna.isHidden = true
                self.removeMediaButton_Orna.isHidden = false
            case .cancelled_Orna:
                break
            }
        }
    }

    /// 移除已选中的媒体
    @objc private func handleRemoveMediaTapped_Orna() {
        pickedImage_Orna = nil
        pickedVideoURL_Orna = nil
        mediaPreviewView_Orna.configure_Orna(mediaPath_Orna: nil)
        mediaHintView_Orna.isHidden = false
        mediaDashBorderLayer_Orna.isHidden = false
        removeMediaButton_Orna.isHidden = true
    }

    /// EULA 协议入口
    @objc private func handleEULATapped_Orna() {
        ProtocolHelper_Orna.showProtocol_Orna(type_Orna: .eula_Orna, content_Orna: "eula.png", from: self)
    }

    /// 确认发布：校验登录状态与标题/正文/媒体均非空后调用 TitleViewModel_Orna 发布
    @objc private func handleReleaseTapped_Orna() {
        guard UserViewModel_Orna.shared_Orna.isLoggedIn_Orna else {
            Navigation_Orna.toLogin_Orna()
            return
        }

        let title_orna = (titleField_Orna.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let content_orna = (contentTextView_Orna.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title_orna.isEmpty else {
            Load_Orna.showWarning_Orna(message_Orna: "Please enter a title.")
            return
        }
        guard !content_orna.isEmpty else {
            Load_Orna.showWarning_Orna(message_Orna: "Please write something in your post.")
            return
        }

        var mediaPath_orna: String?
        var isVideo_orna = false

        if let image_orna = pickedImage_Orna {
            mediaPath_orna = savePickedImageToDisk_Orna(image_orna: image_orna)
        } else if let videoURL_orna = pickedVideoURL_Orna {
            mediaPath_orna = videoURL_orna.path
            isVideo_orna = true
        }

        guard let media_orna = mediaPath_orna, !media_orna.isEmpty else {
            Load_Orna.showWarning_Orna(message_Orna: "Please add a photo or video.")
            return
        }

        TitleViewModel_Orna.shared_Orna.releasePost_Orna(
            title_orna: title_orna,
            content_orna: content_orna,
            media_orna: media_orna,
            isVideo_orna: isVideo_orna
        )

        clearForm_Orna()
        dismissOrGoHome_Orna()
    }

    // MARK: - 工具方法

    /// 清空表单数据，恢复初始状态
    private func clearForm_Orna() {
        titleField_Orna.text = ""
        contentTextView_Orna.text = ""
        contentPlaceholderLabel_Orna.isHidden = false
        pickedImage_Orna = nil
        pickedVideoURL_Orna = nil
        mediaPreviewView_Orna.configure_Orna(mediaPath_Orna: nil)
        mediaHintView_Orna.isHidden = false
        mediaDashBorderLayer_Orna.isHidden = false
        removeMediaButton_Orna.isHidden = true
    }

    /// 将选中的图片保存到 Documents 目录
    /// 返回值：保存成功返回完整文件路径，失败返回 nil
    private func savePickedImageToDisk_Orna(image_orna: UIImage) -> String? {
        guard let data_orna = image_orna.jpegData(compressionQuality: 0.85) else { return nil }
        let docsDir_orna = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_orna = docsDir_orna.appendingPathComponent("post_\(Int(Date().timeIntervalSince1970 * 1000)).jpg")
        do {
            try data_orna.write(to: fileURL_orna)
            return fileURL_orna.path
        } catch {
            print("❌ 保存帖子图片失败: \(error)")
            return nil
        }
    }

    /// 关闭页面：以模态方式呈现时直接 dismiss，作为 Tab 内嵌页面时切回首页
    private func dismissOrGoHome_Orna() {
        if presentingViewController != nil {
            Navigation_Orna.dismiss_Orna(from: self)
        } else if let tabBarController_orna = tabBarController {
            tabBarController_orna.selectedIndex = 0
        } else {
            Navigation_Orna.pop_Orna(from: self)
        }
    }
}

// MARK: - UITextViewDelegate

extension Release_Orna: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        contentPlaceholderLabel_Orna.isHidden = !textView.text.isEmpty
    }
}
