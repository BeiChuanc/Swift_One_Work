import Foundation
import UIKit
import SnapKit

// MARK: - VIP 订阅页面

/// VIP 订阅页面
/// 核心作用：展示 VIP 套餐横向卡片列表，支持每张卡片直接发起内购订阅及恢复购买
/// 设计思路：顶部 vip_top_bg 背景图 + vip_top 装饰图 + 横向可滚动套餐卡片（130×153 渐变圆角）+ 底部协议
/// 关键属性：
/// - vipItems_Echd: 从 Store_Echd 筛选出 goodIsVIP_Echd 为 true 的套餐数组
class VIPSubscription_Echd: UIViewController {

    // MARK: - 数据

    /// 所有 VIP 套餐
    private var vipItems_Echd: [StoreModel_Echd] = []

    // MARK: - UI · 顶部背景图

    /// 顶部背景图（vip_top_bg），宽度等于屏幕宽，高度按图片比例自适应，置于所有内容之下
    private let topBgImageView_Echd: UIImageView = {
        let iv_Echd = UIImageView()
        iv_Echd.image = UIImage(named: "vip_top_bg")?.withRenderingMode(.alwaysOriginal)
        iv_Echd.contentMode = .scaleAspectFill
        iv_Echd.clipsToBounds = true
        return iv_Echd
    }()

    // MARK: - UI · 自定义导航栏

    private let navBar_Echd: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let backButton_Echd: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Echd)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Echd: UILabel = {
        let l = UILabel()
        l.text = "Membership Subscription"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .white
        return l
    }()

    private let restoreButton_Echd: UIButton = {
        let b = UIButton(type: .system)
        let attrs_Echd: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.black
        ]
        let title_Echd = NSAttributedString(string: "Restore Purchases", attributes: attrs_Echd)
        b.setAttributedTitle(title_Echd, for: .normal)
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - UI · 纵向滚动容器

    private let scrollView_Echd: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Echd = UIView()

    // MARK: - UI · 组件1：顶部装饰图

    /// vip_top 装饰图，紧贴横向套餐列表上方 10pt，左右内边距20，高度按图片比例自适应
    private let vipTopImage_Echd: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        return iv
    }()

    // MARK: - UI · 组件2：套餐横向滚动列表

    /// 横向滚动容器，左右内边距16，内含套餐横向 StackView
    private let itemsHScroll_Echd: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        sv.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return sv
    }()

    /// 套餐横向 StackView，间距 12
    private let itemsHStack_Echd: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()

    // MARK: - UI · 组件3：协议标签

    private var protocolLabel_Echd: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData_Echd()
        setupUI_Echd()
        buildItemCells_Echd()
        setupActions_Echd()
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

    /// 从 Store_Echd 筛选 VIP 套餐
    private func loadData_Echd() {
        vipItems_Echd = Store_Echd.shared_Echd.goodsList_Echd.filter { $0.goodIsVIP_Echd == true }
    }

    // MARK: - UI 搭建

    private func setupUI_Echd() {
        view.backgroundColor = .white

        /// 顶部背景图最先添加，置于所有内容之下
        view.addSubview(topBgImageView_Echd)
        view.addSubview(scrollView_Echd)
        scrollView_Echd.addSubview(contentView_Echd)

        /// 组件1：顶部装饰图
        contentView_Echd.addSubview(vipTopImage_Echd)

        /// 组件2：横向滚动套餐列表
        contentView_Echd.addSubview(itemsHScroll_Echd)
        itemsHScroll_Echd.addSubview(itemsHStack_Echd)

        /// 恢复购买按钮：位于 vip_top 与套餐列表之间
        contentView_Echd.addSubview(restoreButton_Echd)

        /// 组件3：协议标签（terms + eula，黑色文字）
        let proto_Echd = ProtocolHelper_Echd.createProtocolTextLabel_Echd(
            firstProtocol_Echd: .terms_Echd,
            firstContent_Echd: "terms.png",
            secondProtocol_Echd: .eula_Echd,
            secondContent_Echd: "eula.png",
            config_Echd: ProtocolHelper_Echd.ProtocolTextConfig_Echd(
                textColor_Echd: UIColor(hexstring_Echd: "#111111"),
                linkColor_Echd: UIColor(hexstring_Echd: "#111111"),
                fontSize_Echd: 13,
                fontWeight_Echd: .regular,
                hasUnderline_Echd: true
            ),
            from: self
        )
        contentView_Echd.addSubview(proto_Echd)
        protocolLabel_Echd = proto_Echd

        /// 导航栏（最顶层）
        view.addSubview(navBar_Echd)
        navBar_Echd.addSubview(backButton_Echd)
        navBar_Echd.addSubview(navTitleLabel_Echd)

        setupConstraints_Echd(protoLabel: proto_Echd)
    }

    // MARK: - 构建套餐 Cell

    /// 遍历 vipItems_Echd 生成 VIPItemCell_Echd 并加入横向列表
    private func buildItemCells_Echd() {
        vipItems_Echd.forEach { model_Echd in
            let cell_Echd = VIPItemCell_Echd()
            cell_Echd.configure_Echd(model: model_Echd)
            /// 点击 Cell 内订阅按钮直接发起内购
            cell_Echd.onSubscribeTap_Echd = { [weak self] tappedModel_Echd in
                self?.purchaseItem_Echd(model: tappedModel_Echd)
            }
            itemsHStack_Echd.addArrangedSubview(cell_Echd)
            cell_Echd.snp.makeConstraints {
                $0.width.equalTo(130)
                $0.height.equalTo(153)
            }
        }
    }

    // MARK: - 约束

    private func setupConstraints_Echd(protoLabel: UILabel) {
        let screenW_Echd = UIScreen.main.bounds.width

        /// vip_top 图片高度按比例自适应
        let imgW_Echd: CGFloat = screenW_Echd - 40
        let img_Echd = UIImage(named: "vip_top")
        let aspect_Echd = img_Echd.map { $0.size.height / $0.size.width } ?? 0.75
        let vipTopH_Echd: CGFloat = imgW_Echd * aspect_Echd

        /// 顶部背景图：全宽，高度按 vip_top_bg 图片比例自适应
        let bgImg_Echd = UIImage(named: "vip_top_bg")
        let bgAspect_Echd = bgImg_Echd.map { $0.size.height / $0.size.width } ?? 0.5
        let bgH_Echd: CGFloat = screenW_Echd * bgAspect_Echd
        topBgImageView_Echd.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(bgH_Echd)
        }

        /// 导航栏
        navBar_Echd.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Echd.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Echd.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton_Echd)
        }

        /// 纵向滚动容器：顶部从导航栏底部开始
        scrollView_Echd.snp.makeConstraints {
            $0.top.equalTo(navBar_Echd.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        /// contentView 最小高度等于滚动视图高度，保证底部内容始终贴底
        contentView_Echd.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualTo(scrollView_Echd.snp.height)
        }

        /// 组件3（协议）：底部固定在 contentView 底部
        protoLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-30)
        }

        /// 组件2（横向套餐列表）：紧贴协议上方 20pt，高度 153
        itemsHScroll_Echd.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(153)
            $0.bottom.equalTo(protoLabel.snp.top).offset(-20)
        }
        itemsHStack_Echd.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }

        /// 恢复购买按钮：位于套餐列表上方 10pt，水平居中
        restoreButton_Echd.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(itemsHScroll_Echd.snp.top).offset(-10)
            $0.height.equalTo(22)
        }

        /// 组件1（vip_top）：紧贴恢复按钮上方 10pt
        vipTopImage_Echd.snp.makeConstraints {
            $0.bottom.equalTo(restoreButton_Echd.snp.top).offset(-10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(vipTopH_Echd)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Echd() {
        backButton_Echd.addTarget(self, action: #selector(backTapped_Echd), for: .touchUpInside)
        restoreButton_Echd.addTarget(self, action: #selector(restoreTapped_Echd), for: .touchUpInside)
    }

    @objc private func backTapped_Echd() {
        Navigation_Echd.pop_Echd(from: self)
    }

    /// 恢复购买按钮回调
    @objc private func restoreTapped_Echd() {
        Store_Echd.shared_Echd.RestorePurchase_Echd { [weak self] in
            guard let self_Echd = self else { return }
            _ = self_Echd
        }
    }

    /// 发起指定套餐的 VIP 内购
    /// - Parameter model: 选中的套餐模型
    private func purchaseItem_Echd(model: StoreModel_Echd) {
        guard let gid_Echd = model.goodsId_Echd else {
            Utils_Echd.showWarning_Echd(message_Echd: "Invalid subscription plan.")
            return
        }
        Store_Echd.shared_Echd.PurchaseStoreVIP_Echd(vipId_Echd: gid_Echd) { [weak self] in
            guard let self_Echd = self else { return }
            Navigation_Echd.pop_Echd(from: self_Echd)
        }
    }
}

// MARK: - VIPItemCell_Echd

/// VIP 套餐卡片视图
/// 核心作用：展示单个 VIP 套餐信息，支持点击订阅按钮直接发起内购
/// 设计思路：130×153 渐变圆角矩形（#FF136A 顶部居中 → #FF850F 底部居中），
///           VStack 居中：Premium Member（12pt黑）→ 价格（$14pt白 + 数字30pt白）→
///           名称（16pt黑）→ vip_sub 订阅按钮（高30 宽自适应）
/// 关键属性：
/// - model_Echd: 当前绑定的套餐数据
/// - onSubscribeTap_Echd: 订阅按钮点击回调
private class VIPItemCell_Echd: UIView {

    // MARK: - 属性

    /// 当前套餐数据（外部只读，内部赋值）
    private(set) var model_Echd: StoreModel_Echd?

    /// 点击订阅按钮回调，回传套餐模型
    var onSubscribeTap_Echd: ((StoreModel_Echd) -> Void)?

    // MARK: - UI

    /// 渐变背景图层（FF136A 顶部 → FF850F 底部）
    private let gradientLayer_Echd = CAGradientLayer()

    /// "Premium Member" 固定文本，12pt，黑色
    private let memberLabel_Echd: UILabel = {
        let l = UILabel()
        l.text = "Premium Member"
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = .black
        l.textAlignment = .center
        return l
    }()

    /// 价格富文本标签（$ 14pt白 + 数字 30pt白）
    private let priceLabel_Echd: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.7
        return l
    }()

    /// 套餐名称（goodsName_Echd），16pt，黑色
    private let nameLabel_Echd: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.textColor = .black
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 订阅按钮（vip_sub 图片，高度30，宽度自适应）
    private let subButton_Echd: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "vip_sub"), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.clipsToBounds = true
        return b
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI_Echd()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()
        /// 渐变图层随 bounds 刷新（解决初始 frame=zero 问题）
        gradientLayer_Echd.frame = bounds
    }

    // MARK: - UI 搭建

    /// 构建渐变圆角矩形背景 + 居中 VStack 内容
    private func buildUI_Echd() {
        layer.cornerRadius = 16
        layer.masksToBounds = true

        /// 渐变背景：顶部居中 #FF136A → 底部居中 #FF850F
        gradientLayer_Echd.colors = [
            UIColor(hexstring_Echd: "#FF136A").cgColor,
            UIColor(hexstring_Echd: "#FF850F").cgColor
        ]
        gradientLayer_Echd.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer_Echd.endPoint   = CGPoint(x: 0.5, y: 1.0)
        layer.insertSublayer(gradientLayer_Echd, at: 0)

        /// VStack 容器：4个元素间距均为10，整体居中
        let vStack_Echd = UIStackView(arrangedSubviews: [
            memberLabel_Echd,
            priceLabel_Echd,
            nameLabel_Echd,
            subButton_Echd
        ])
        vStack_Echd.axis      = .vertical
        vStack_Echd.spacing   = 10
        vStack_Echd.alignment = .center

        addSubview(vStack_Echd)
        vStack_Echd.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(8)
            $0.trailing.lessThanOrEqualToSuperview().offset(-8)
        }

        /// 订阅按钮固定高度30，宽度由图片自适应
        subButton_Echd.snp.makeConstraints {
            $0.height.equalTo(30)
        }

        subButton_Echd.addTarget(self, action: #selector(subTapped_Echd), for: .touchUpInside)
    }

    // MARK: - 数据填充

    /// 注入套餐数据，更新价格富文本与套餐名
    /// - Parameter model: VIP 套餐模型（读取 goodsPrice_Echd 和 goodsName_Echd）
    func configure_Echd(model: StoreModel_Echd) {
        self.model_Echd = model
        nameLabel_Echd.text = model.goodsName_Echd ?? ""

        /// 构建价格富文本：分离货币符号与数字，分别设置不同字号
        let priceStr_Echd = model.goodsPrice_Echd ?? ""
        let hasCurrencyPrefix_Echd = priceStr_Echd.hasPrefix("$") || priceStr_Echd.hasPrefix("¥")
        let symbol_Echd = hasCurrencyPrefix_Echd ? String(priceStr_Echd.prefix(1)) : ""
        let number_Echd = hasCurrencyPrefix_Echd ? String(priceStr_Echd.dropFirst()) : priceStr_Echd

        let attrStr_Echd = NSMutableAttributedString(
            string: symbol_Echd,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                .foregroundColor: UIColor.white
            ]
        )
        attrStr_Echd.append(NSAttributedString(
            string: number_Echd,
            attributes: [
                .font: UIFont.systemFont(ofSize: 30, weight: .bold),
                .foregroundColor: UIColor.white
            ]
        ))
        priceLabel_Echd.attributedText = attrStr_Echd
    }

    // MARK: - 点击处理

    /// 点击订阅按钮，触发内购回调
    @objc private func subTapped_Echd() {
        guard let model_Echd = model_Echd else { return }
        subButton_Echd.animatePulse_Echd()
        onSubscribeTap_Echd?(model_Echd)
    }
}
