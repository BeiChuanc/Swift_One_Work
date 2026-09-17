import Foundation
import UIKit
import SnapKit

// MARK: - VIP 订阅页面

/// VIP 订阅页面
/// 核心作用：横向展示 VIP 套餐，通过卡片按钮订阅对应商品，并提供恢复购买入口
/// 设计思路：保留顶部装饰图及页面背景，使用可复用卡片展示商品，购买逻辑委托用户状态管理器
/// 关键属性：
/// - itemsScrollView_lens：提供横向商品滚动区域
/// - itemsStack_lens：以固定尺寸横向排列套餐卡片
class VIPSubscription_Lens: UIViewController {

    // MARK: - UI · 背景渐变

    private var bgGradient_Lens: CAGradientLayer?

    // MARK: - UI · 自定义导航栏

    private let navBar_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let backButton_Lens: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Lens)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Subscribe"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .white
        return l
    }()

    // MARK: - UI · 滚动容器

    private let scrollView_Lens: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Lens = UIView()

    // MARK: - UI · 组件1：顶部装饰图

    /// vip_top 装饰图（组件1），紧贴导航栏底部，左右内边距20，完整展示图片内容
    private let vipTopImage_Lens: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        return iv
    }()

    // MARK: - UI · 组件2：套餐横向列表

    /// 横向滚动区域，支持查看全部套餐并保留下一张卡片的可见部分
    private let itemsScrollView_lens: UIScrollView = {
        let scrollView_lens = UIScrollView()
        scrollView_lens.showsHorizontalScrollIndicator = false
        scrollView_lens.alwaysBounceHorizontal = true
        scrollView_lens.isDirectionalLockEnabled = true
        scrollView_lens.contentInsetAdjustmentBehavior = .never
        return scrollView_lens
    }()

    /// 横向套餐栈，固定间距，卡片尺寸由布局约束统一设置
    private let itemsStack_lens: UIStackView = {
        let stack_lens = UIStackView()
        stack_lens.axis = .horizontal
        stack_lens.spacing = 12
        stack_lens.alignment = .fill
        stack_lens.distribution = .fill
        return stack_lens
    }()

    // MARK: - UI · 组件3：恢复购买

    private let restoreButton_Lens: UIButton = {
        let b = UIButton(type: .system)
        let attrs_Lens: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.white
        ]
        let title_Lens = NSAttributedString(string: "Restore Purchases", attributes: attrs_Lens)
        b.setAttributedTitle(title_Lens, for: .normal)
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - UI · 组件5：协议标签

    private var protocolLabel_Lens: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lens()
        buildItemCards_lens()
        setupActions_Lens()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 只有被 pop 出栈时才恢复导航栏，避免 modal 弹出时错误地改变导航栏状态
        if isMovingFromParent {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradient_Lens?.frame = view.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Lens() {
        setupBgGradient_Lens()

        view.addSubview(scrollView_Lens)
        scrollView_Lens.addSubview(contentView_Lens)

        // 组件1
        contentView_Lens.addSubview(vipTopImage_Lens)
        // 组件2：横向商品卡片列表
        contentView_Lens.addSubview(itemsScrollView_lens)
        itemsScrollView_lens.addSubview(itemsStack_lens)

        // 组件5：协议文字及链接统一使用白色
        let proto_Lens = ProtocolHelper_Lens.createProtocolTextLabel_Lens(
            firstProtocol_Lens: .terms_Lens,
            firstContent_Lens: "terms.png",
            secondProtocol_Lens: .eula_Lens,
            secondContent_Lens: "eula.png",
            config_Lens: ProtocolHelper_Lens.ProtocolTextConfig_Lens(
                textColor_Lens: .white,
                linkColor_Lens: .white,
                fontSize_Lens: 13,
                fontWeight_Lens: .regular,
                hasUnderline_Lens: true
            ),
            from: self
        )
        contentView_Lens.addSubview(proto_Lens)
        protocolLabel_Lens = proto_Lens

        // 导航栏（最顶层）
        view.addSubview(navBar_Lens)
        navBar_Lens.addSubview(backButton_Lens)
        navBar_Lens.addSubview(navTitleLabel_Lens)
        navBar_Lens.addSubview(restoreButton_Lens)

        setupConstraints_Lens(protoLabel: proto_Lens)
    }

    /// 全屏渐变背景：#7297F9（顶部居中）→ #4A8EFF（底部居中）
    private func setupBgGradient_Lens() {
        let gl_Lens = CAGradientLayer()
        gl_Lens.colors = [
            UIColor(hexstring_Lens: "#7297F9").cgColor,
            UIColor(hexstring_Lens: "#4A8EFF").cgColor
        ]
        gl_Lens.startPoint = CGPoint(x: 0.5, y: 0.0)
        gl_Lens.endPoint   = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gl_Lens, at: 0)
        bgGradient_Lens = gl_Lens
    }

    // MARK: - 构建套餐卡片

    /// 渲染横向商品卡片，并将每张卡片的订阅事件绑定到对应商品
    /// 参数：无。
    /// 返回值：无（Void）；无抛出异常。
    private func buildItemCards_lens() {
        for view_lens in itemsStack_lens.arrangedSubviews {
            itemsStack_lens.removeArrangedSubview(view_lens)
            view_lens.removeFromSuperview()
        }
        for product_lens in UserViewModel_Lens.shared_Lens.vipProducts_lens {
            let card_lens = VIPSubscriptionCard_lens()
            let priceParts_lens = product_lens.subscriptionPriceParts_lens
            card_lens.configure_lens(
                price_lens: priceParts_lens.amount_lens,
                currency_lens: priceParts_lens.currency_lens,
                period_lens: product_lens.subscriptionPeriodTitle_lens
            )
            card_lens.onSubscribe_lens = { [weak self] in
                UserViewModel_Lens.shared_Lens.subscribeToVIP_lens(product_lens: product_lens) { [weak self] in
                    guard let page_lens = self else { return }
                    Navigation_Lens.pop_Lens(from: page_lens)
                }
            }
            itemsStack_lens.addArrangedSubview(card_lens)
            card_lens.snp.makeConstraints { make_lens in
                make_lens.width.equalTo(166)
                make_lens.height.equalTo(196)
            }
        }
    }

    // MARK: - 约束

    private func setupConstraints_Lens(protoLabel: UILabel) {
        let screenW_Lens = UIScreen.main.bounds.width
        // 图片宽度 = 屏幕宽 - 左右各20内边距，高度按图片实际比例自适应（scaleAspectFit）
        let imgW_Lens: CGFloat = screenW_Lens - 40
        let img_Lens = UIImage(named: "vip_top")
        let aspect_Lens = img_Lens.map { $0.size.height / $0.size.width } ?? 0.75
        let vipTopH_Lens: CGFloat = imgW_Lens * aspect_Lens

        // 导航栏
        navBar_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton_Lens)
        }
        restoreButton_Lens.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(backButton_Lens)
            $0.height.equalTo(22)
        }

        // 滚动容器：顶部从导航栏底部开始，确保内容可正常滚动
        scrollView_Lens.snp.makeConstraints {
            $0.top.equalTo(navBar_Lens.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // 组件1：vip_top，左右内边距20，高度按缩小比例展示完整图片
        vipTopImage_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(vipTopH_Lens)
        }

        // 组件2：固定高度的横向滚动区域，内容宽度由卡片数量决定
        itemsScrollView_lens.snp.makeConstraints { make_lens in
            make_lens.top.equalTo(vipTopImage_Lens.snp.bottom).offset(20)
            make_lens.leading.trailing.equalToSuperview()
            make_lens.height.equalTo(196)
        }
        itemsStack_lens.snp.makeConstraints { make_lens in
            make_lens.edges.equalTo(itemsScrollView_lens.contentLayoutGuide)
                .inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make_lens.height.equalTo(itemsScrollView_lens.frameLayoutGuide)
        }

        // 组件5：协议位于商品卡片下方
        protoLabel.snp.makeConstraints {
            $0.top.equalTo(itemsScrollView_lens.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Lens() {
        backButton_Lens.addTarget(self, action: #selector(backTapped_Lens), for: .touchUpInside)
        restoreButton_Lens.addTarget(self, action: #selector(restoreTapped_Lens), for: .touchUpInside)
    }

    @objc private func backTapped_Lens() {
        Navigation_Lens.pop_Lens(from: self)
    }

    /// 恢复购买按钮回调
    @objc private func restoreTapped_Lens() {
        Subscribe_Lens.shared_Lens.RestorePurchase_Lens { [weak self] in
            guard let self_Lens = self else { return }
            _ = self_Lens
        }
    }

}
