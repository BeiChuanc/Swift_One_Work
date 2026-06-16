import Foundation
import UIKit
import SnapKit

// MARK: - VIP 订阅页面

/// VIP 订阅页面
/// 核心作用：展示 VIP 套餐横向卡片列表，支持每张卡片直接发起内购订阅及恢复购买
/// 设计思路：顶部 vip_top_bg 背景图 + vip_top 装饰图 + 横向可滚动套餐卡片（130×153 渐变圆角）+ 底部协议
/// 关键属性：
/// - vipItems_Retrs: 从 Store_Retrs 筛选出 goodIsVIP_Retrs 为 true 的套餐数组
class VIPSubscription_Retrs: UIViewController {

    // MARK: - 数据

    /// 所有 VIP 套餐
    private var vipItems_Retrs: [StoreModel_Retrs] = []

    // MARK: - UI · 顶部背景图

    /// 顶部背景图（vip_top_bg），宽度等于屏幕宽，高度按图片比例自适应，置于所有内容之下
    private let topBgImageView_Retrs: UIImageView = {
        let iv_Retrs = UIImageView()
        iv_Retrs.image = UIImage(named: "vip_top_bg")?.withRenderingMode(.alwaysOriginal)
        iv_Retrs.contentMode = .scaleAspectFill
        iv_Retrs.clipsToBounds = true
        return iv_Retrs
    }()

    // MARK: - UI · 自定义导航栏

    private let navBar_Retrs: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let backButton_Retrs: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Retrs = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Retrs)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Retrs: UILabel = {
        let l = UILabel()
        l.text = "Membership Subscription"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .white
        return l
    }()

    private let restoreButton_Retrs: UIButton = {
        let b = UIButton(type: .system)
        let attrs_Retrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.white
        ]
        let title_Retrs = NSAttributedString(string: "Restore Purchases", attributes: attrs_Retrs)
        b.setAttributedTitle(title_Retrs, for: .normal)
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - UI · 纵向滚动容器

    private let scrollView_Retrs: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Retrs = UIView()

    // MARK: - UI · 组件1：顶部装饰图

    /// vip_top 装饰图，紧贴横向套餐列表上方 10pt，左右内边距20，高度按图片比例自适应
    private let vipTopImage_Retrs: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        return iv
    }()

    // MARK: - UI · 组件2：套餐横向滚动列表

    /// 横向滚动容器，左右内边距16，内含套餐横向 StackView
    private let itemsHScroll_Retrs: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        sv.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return sv
    }()

    /// 套餐横向 StackView，间距 12
    private let itemsHStack_Retrs: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()

    // MARK: - UI · 组件3：协议标签

    private var protocolLabel_Retrs: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData_Retrs()
        setupUI_Retrs()
        buildItemCells_Retrs()
        setupActions_Retrs()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /// 只有被 pop 出栈时才恢复导航栏，避免 modal 弹出时错误改变导航栏状态
        if isMovingFromParent {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }

    // MARK: - 数据加载

    /// 从 Store_Retrs 筛选 VIP 套餐
    private func loadData_Retrs() {
        vipItems_Retrs = Store_Retrs.shared_Retrs.goodsList_Retrs.filter { $0.goodIsVIP_Retrs == true }
    }

    // MARK: - UI 搭建

    private func setupUI_Retrs() {
        view.backgroundColor = UIColor(hexstring_Retrs: "#50D8FC")

        /// 顶部背景图最先添加，置于所有内容之下
        view.addSubview(topBgImageView_Retrs)
        view.addSubview(scrollView_Retrs)
        scrollView_Retrs.addSubview(contentView_Retrs)

        /// 组件1：顶部装饰图
        contentView_Retrs.addSubview(vipTopImage_Retrs)

        /// 组件2：横向滚动套餐列表
        contentView_Retrs.addSubview(itemsHScroll_Retrs)
        itemsHScroll_Retrs.addSubview(itemsHStack_Retrs)

        /// 恢复购买按钮：位于 vip_top 与套餐列表之间
        contentView_Retrs.addSubview(restoreButton_Retrs)

        /// 组件3：协议标签（terms + eula，黑色文字）
        let proto_Retrs = ProtocolHelper_Retrs.createProtocolTextLabel_Retrs(
            firstProtocol_Retrs: .terms_Retrs,
            firstContent_Retrs: "terms.png",
            secondProtocol_Retrs: .eula_Retrs,
            secondContent_Retrs: "eula.png",
            config_Retrs: ProtocolHelper_Retrs.ProtocolTextConfig_Retrs(
                textColor_Retrs: UIColor(hexstring_Retrs: "#111111"),
                linkColor_Retrs: UIColor(hexstring_Retrs: "#111111"),
                fontSize_Retrs: 13,
                fontWeight_Retrs: .regular,
                hasUnderline_Retrs: true
            ),
            from: self
        )
        contentView_Retrs.addSubview(proto_Retrs)
        protocolLabel_Retrs = proto_Retrs

        /// 导航栏（最顶层）
        view.addSubview(navBar_Retrs)
        navBar_Retrs.addSubview(backButton_Retrs)
        navBar_Retrs.addSubview(navTitleLabel_Retrs)

        setupConstraints_Retrs(protoLabel: proto_Retrs)
    }

    // MARK: - 构建套餐 Cell

    /// 遍历 vipItems_Retrs 生成 VIPItemCell_Retrs 并加入横向列表
    private func buildItemCells_Retrs() {
        vipItems_Retrs.forEach { model_Retrs in
            let cell_Retrs = VIPItemCell_Retrs()
            cell_Retrs.configure_Retrs(model: model_Retrs)
            /// 点击 Cell 内订阅按钮直接发起内购
            cell_Retrs.onSubscribeTap_Retrs = { [weak self] tappedModel_Retrs in
                self?.purchaseItem_Retrs(model: tappedModel_Retrs)
            }
            itemsHStack_Retrs.addArrangedSubview(cell_Retrs)
            cell_Retrs.snp.makeConstraints {
                $0.width.equalTo(130)
                $0.height.equalTo(153)
            }
        }
    }

    // MARK: - 约束

    private func setupConstraints_Retrs(protoLabel: UILabel) {
        let screenW_Retrs = UIScreen.main.bounds.width

        /// vip_top 图片高度按比例自适应
        let imgW_Retrs: CGFloat = screenW_Retrs - 40
        let img_Retrs = UIImage(named: "vip_top")
        let aspect_Retrs = img_Retrs.map { $0.size.height / $0.size.width } ?? 0.75
        let vipTopH_Retrs: CGFloat = imgW_Retrs * aspect_Retrs

        /// 顶部背景图：全宽，高度按 vip_top_bg 图片比例自适应
        let bgImg_Retrs = UIImage(named: "vip_top_bg")
        let bgAspect_Retrs = bgImg_Retrs.map { $0.size.height / $0.size.width } ?? 0.5
        let bgH_Retrs: CGFloat = screenW_Retrs * bgAspect_Retrs
        topBgImageView_Retrs.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(bgH_Retrs)
        }

        /// 导航栏
        navBar_Retrs.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Retrs.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Retrs.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton_Retrs)
        }

        /// 纵向滚动容器：顶部从导航栏底部开始
        scrollView_Retrs.snp.makeConstraints {
            $0.top.equalTo(navBar_Retrs.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        /// contentView 最小高度等于滚动视图高度，保证底部内容始终贴底
        contentView_Retrs.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualTo(scrollView_Retrs.snp.height)
        }

        /// 组件3（协议）：底部固定在 contentView 底部
        protoLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-30)
        }

        /// 组件2（横向套餐列表）：紧贴协议上方 20pt，高度 153
        itemsHScroll_Retrs.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(153)
            $0.bottom.equalTo(protoLabel.snp.top).offset(-20)
        }
        itemsHStack_Retrs.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }

        /// 恢复购买按钮：位于套餐列表上方 10pt，水平居中
        restoreButton_Retrs.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(itemsHScroll_Retrs.snp.top).offset(-10)
            $0.height.equalTo(22)
        }

        /// 组件1（vip_top）：紧贴恢复按钮上方 10pt
        vipTopImage_Retrs.snp.makeConstraints {
            $0.bottom.equalTo(restoreButton_Retrs.snp.top).offset(-10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(vipTopH_Retrs)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Retrs() {
        backButton_Retrs.addTarget(self, action: #selector(backTapped_Retrs), for: .touchUpInside)
        restoreButton_Retrs.addTarget(self, action: #selector(restoreTapped_Retrs), for: .touchUpInside)
    }

    @objc private func backTapped_Retrs() {
        Navigation_Retrs.pop_Retrs(from: self)
    }

    /// 恢复购买按钮回调
    @objc private func restoreTapped_Retrs() {
        Store_Retrs.shared_Retrs.RestorePurchase_Retrs { [weak self] in
            guard let self_Retrs = self else { return }
            _ = self_Retrs
        }
    }

    /// 发起指定套餐的 VIP 内购
    /// - Parameter model: 选中的套餐模型
    private func purchaseItem_Retrs(model: StoreModel_Retrs) {
        guard let gid_Retrs = model.goodsId_Retrs else {
            Utils_Retrs.showWarning_Retrs(message_Retrs: "Invalid subscription plan.")
            return
        }
        Store_Retrs.shared_Retrs.PurchaseStoreVIP_Retrs(vipId_Retrs: gid_Retrs) { [weak self] in
            guard let self_Retrs = self else { return }
            Navigation_Retrs.pop_Retrs(from: self_Retrs)
        }
    }
}

// MARK: - VIPItemCell_Retrs

/// VIP 套餐卡片视图
/// 核心作用：展示单个 VIP 套餐信息，支持点击订阅按钮直接发起内购
/// 设计思路：130×153 渐变圆角矩形（#FF136A 顶部居中 → #FF850F 底部居中），
///           VStack 居中：Premium Member（12pt黑）→ 价格（$14pt白 + 数字30pt白）→
///           名称（16pt黑）→ vip_sub 订阅按钮（高30 宽自适应）
/// 关键属性：
/// - model_Retrs: 当前绑定的套餐数据
/// - onSubscribeTap_Retrs: 订阅按钮点击回调
private class VIPItemCell_Retrs: UIView {

    // MARK: - 属性

    /// 当前套餐数据（外部只读，内部赋值）
    private(set) var model_Retrs: StoreModel_Retrs?

    /// 点击订阅按钮回调，回传套餐模型
    var onSubscribeTap_Retrs: ((StoreModel_Retrs) -> Void)?

    // MARK: - UI

    /// 渐变背景图层（FF136A 顶部 → FF850F 底部）
    private let gradientLayer_Retrs = CAGradientLayer()

    /// "Premium Member" 固定文本，12pt，黑色
    private let memberLabel_Retrs: UILabel = {
        let l = UILabel()
        l.text = "Premium Member"
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = .black
        l.textAlignment = .center
        return l
    }()

    /// 价格富文本标签（$ 14pt白 + 数字 30pt白）
    private let priceLabel_Retrs: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.7
        return l
    }()

    /// 套餐名称（goodsName_Retrs），16pt，黑色
    private let nameLabel_Retrs: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.textColor = .black
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 订阅按钮（vip_sub 图片，高度30，宽度自适应）
    private let subButton_Retrs: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "vip_sub"), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.clipsToBounds = true
        return b
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI_Retrs()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()
        /// 渐变图层随 bounds 刷新（解决初始 frame=zero 问题）
        gradientLayer_Retrs.frame = bounds
    }

    // MARK: - UI 搭建

    /// 构建渐变圆角矩形背景 + 居中 VStack 内容
    private func buildUI_Retrs() {
        layer.cornerRadius = 16
        layer.masksToBounds = true

        /// 渐变背景：顶部居中 #FF136A → 底部居中 #FF850F
        gradientLayer_Retrs.colors = [
            UIColor(hexstring_Retrs: "#A655F0").cgColor,
            UIColor(hexstring_Retrs: "#A655F0").cgColor
        ]
        gradientLayer_Retrs.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer_Retrs.endPoint   = CGPoint(x: 0.5, y: 1.0)
        layer.insertSublayer(gradientLayer_Retrs, at: 0)

        /// VStack 容器：4个元素间距均为10，整体居中
        let vStack_Retrs = UIStackView(arrangedSubviews: [
            memberLabel_Retrs,
            priceLabel_Retrs,
            nameLabel_Retrs,
            subButton_Retrs
        ])
        vStack_Retrs.axis      = .vertical
        vStack_Retrs.spacing   = 10
        vStack_Retrs.alignment = .center

        addSubview(vStack_Retrs)
        vStack_Retrs.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(8)
            $0.trailing.lessThanOrEqualToSuperview().offset(-8)
        }

        /// 订阅按钮固定高度30，宽度由图片自适应
        subButton_Retrs.snp.makeConstraints {
            $0.height.equalTo(30)
        }

        subButton_Retrs.addTarget(self, action: #selector(subTapped_Retrs), for: .touchUpInside)
    }

    // MARK: - 数据填充

    /// 注入套餐数据，更新价格富文本与套餐名
    /// - Parameter model: VIP 套餐模型（读取 goodsPrice_Retrs 和 goodsName_Retrs）
    func configure_Retrs(model: StoreModel_Retrs) {
        self.model_Retrs = model
        nameLabel_Retrs.text = model.goodsName_Retrs ?? ""

        /// 构建价格富文本：分离货币符号与数字，分别设置不同字号
        let priceStr_Retrs = model.goodsPrice_Retrs ?? ""
        let hasCurrencyPrefix_Retrs = priceStr_Retrs.hasPrefix("$") || priceStr_Retrs.hasPrefix("¥")
        let symbol_Retrs = hasCurrencyPrefix_Retrs ? String(priceStr_Retrs.prefix(1)) : ""
        let number_Retrs = hasCurrencyPrefix_Retrs ? String(priceStr_Retrs.dropFirst()) : priceStr_Retrs

        let attrStr_Retrs = NSMutableAttributedString(
            string: symbol_Retrs,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                .foregroundColor: UIColor.white
            ]
        )
        attrStr_Retrs.append(NSAttributedString(
            string: number_Retrs,
            attributes: [
                .font: UIFont.systemFont(ofSize: 30, weight: .bold),
                .foregroundColor: UIColor.white
            ]
        ))
        priceLabel_Retrs.attributedText = attrStr_Retrs
    }

    // MARK: - 点击处理

    /// 点击订阅按钮，触发内购回调
    @objc private func subTapped_Retrs() {
        guard let model_Retrs = model_Retrs else { return }
        subButton_Retrs.animatePulse_Retrs()
        onSubscribeTap_Retrs?(model_Retrs)
    }
}
