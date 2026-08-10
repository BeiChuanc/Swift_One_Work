import Foundation
import UIKit
import SnapKit

// MARK: - VIP 订阅页面

/// VIP 订阅页面
/// 核心作用：展示 VIP 套餐横向卡片列表，支持选择套餐后通过底部订阅按钮发起内购及恢复购买
/// 设计思路：顶部 vip_top 装饰图 + 横向可滚动套餐选择卡片（110×115 白底圆角）+ 恢复购买 + 底部订阅按钮与协议
/// 关键属性：
/// - vipItems_Orna: 从 Store_Orna 筛选出 goodIsVIP_Orna 为 true 的套餐数组
/// - selectedVIPItem_Orna: 当前选中的 VIP 套餐
class VIPSubscription_Orna: UIViewController {

    // MARK: - 数据

    /// 所有 VIP 套餐
    private var vipItems_Orna: [StoreModel_Orna] = []

    /// 当前选中的 VIP 套餐，默认选中第一项
    private var selectedVIPItem_Orna: StoreModel_Orna?

    /// 当前展示的 VIP 套餐卡片集合，用于同步选中态
    private var vipItemCells_Orna: [VIPItemCell_Orna] = []

    // MARK: - UI · 顶部背景图

    /// 顶部背景图（vip_top_bg），宽度等于屏幕宽，高度按图片比例自适应，置于所有内容之下
    private let topBgImageView_Orna: UIImageView = {
        let iv_Orna = UIImageView()
        iv_Orna.image = UIImage(named: "vip_top_bg")?.withRenderingMode(.alwaysOriginal)
        iv_Orna.contentMode = .scaleAspectFill
        iv_Orna.clipsToBounds = true
        return iv_Orna
    }()

    // MARK: - UI · 自定义导航栏

    private let navBar_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let backButton_Orna: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Orna = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Orna)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "SUBSCRIBE"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .black
        return l
    }()

    private let restoreButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let attrs_Orna: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.black
        ]
        let title_Orna = NSAttributedString(string: "Restore Purchases", attributes: attrs_Orna)
        b.setAttributedTitle(title_Orna, for: .normal)
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - UI · 纵向滚动容器

    private let scrollView_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Orna = UIView()

    // MARK: - UI · 组件1：顶部装饰图

    /// vip_top 装饰图，紧贴横向套餐列表上方 10pt，左右内边距20，高度按图片比例自适应
    private let vipTopImage_Orna: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        /// 资源图顶部自带一段透明留白，裁切顶部 12% 以压缩导航栏下方空白区域
        iv.layer.contentsRect = CGRect(x: 0, y: 0.12, width: 1, height: 0.88)
        return iv
    }()

    // MARK: - UI · 组件2：套餐横向滚动列表

    /// 横向滚动容器，左右内边距16，内含套餐横向 StackView
    private let itemsHScroll_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        sv.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        sv.clipsToBounds = false
        return sv
    }()

    /// 套餐横向 StackView，间距 12
    private let itemsHStack_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()

    /// 底部订阅按钮，使用 Assets 中 vip_sub 图片，点击购买当前选中套餐
    private let subscribeButton_Orna: UIButton = {
        let b = UIButton(type: .custom)
        b.setBackgroundImage(UIImage(named: "vip_sub")?.withRenderingMode(.alwaysOriginal), for: .normal)
        b.clipsToBounds = true
        b.layer.cornerRadius = 25
        return b
    }()

    // MARK: - UI · 组件3：协议标签

    private var protocolLabel_Orna: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData_Orna()
        setupUI_Orna()
        buildItemCells_Orna()
        setupActions_Orna()
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

    /// 从 Store_Orna 筛选 VIP 套餐
    private func loadData_Orna() {
        vipItems_Orna = Store_Orna.shared_Orna.goodsList_Orna.filter { $0.goodIsVIP_Orna == true }
        selectedVIPItem_Orna = vipItems_Orna.first
    }

    // MARK: - UI 搭建

    private func setupUI_Orna() {
        view.backgroundColor = UIColor(hexstring_Orna: "#50D8FC")

        /// 顶部背景图最先添加，置于所有内容之下
        view.addSubview(topBgImageView_Orna)
        view.addSubview(scrollView_Orna)
        scrollView_Orna.addSubview(contentView_Orna)

        /// 组件1：顶部装饰图
        contentView_Orna.addSubview(vipTopImage_Orna)

        /// 组件2：横向滚动套餐列表
        contentView_Orna.addSubview(itemsHScroll_Orna)
        itemsHScroll_Orna.addSubview(itemsHStack_Orna)

        /// 恢复购买按钮：位于套餐列表下方
        contentView_Orna.addSubview(restoreButton_Orna)

        /// 底部订阅按钮：位于恢复购买按钮下方
        contentView_Orna.addSubview(subscribeButton_Orna)

        /// 组件3：协议标签（terms + eula，黑色文字）
        let proto_Orna = ProtocolHelper_Orna.createProtocolTextLabel_Orna(
            firstProtocol_Orna: .terms_Orna,
            firstContent_Orna: "terms.png",
            secondProtocol_Orna: .eula_Orna,
            secondContent_Orna: "eula.png",
            config_Orna: ProtocolHelper_Orna.ProtocolTextConfig_Orna(
                textColor_Orna: UIColor(hexstring_Orna: "#111111"),
                linkColor_Orna: UIColor(hexstring_Orna: "#111111"),
                fontSize_Orna: 13,
                fontWeight_Orna: .regular,
                hasUnderline_Orna: true
            ),
            from: self
        )
        contentView_Orna.addSubview(proto_Orna)
        protocolLabel_Orna = proto_Orna

        /// 导航栏（最顶层）
        view.addSubview(navBar_Orna)
        navBar_Orna.addSubview(backButton_Orna)
        navBar_Orna.addSubview(navTitleLabel_Orna)

        setupConstraints_Orna(protoLabel: proto_Orna)
    }

    // MARK: - 构建套餐 Cell

    /// 遍历 vipItems_Orna 生成 VIPItemCell_Orna 并加入横向列表
    private func buildItemCells_Orna() {
        vipItemCells_Orna.removeAll()
        vipItems_Orna.forEach { model_Orna in
            let cell_Orna = VIPItemCell_Orna()
            cell_Orna.configure_Orna(model: model_Orna)
            cell_Orna.setSelected_Orna(isSelected_orna: model_Orna.goodsId_Orna == selectedVIPItem_Orna?.goodsId_Orna)
            /// 点击 Cell 仅切换选中套餐，由底部订阅按钮统一发起购买
            cell_Orna.onSelectTap_Orna = { [weak self] tappedModel_Orna in
                self?.selectVIPItem_Orna(model_orna: tappedModel_Orna)
            }
            itemsHStack_Orna.addArrangedSubview(cell_Orna)
            vipItemCells_Orna.append(cell_Orna)
            cell_Orna.snp.makeConstraints {
                $0.width.equalTo(130)
                $0.height.equalTo(115)
            }
        }
    }

    // MARK: - 约束

    private func setupConstraints_Orna(protoLabel: UILabel) {
        let screenW_Orna = UIScreen.main.bounds.width

        /// vip_top 图片高度按比例自适应
        let imgW_Orna: CGFloat = screenW_Orna - 40
        let img_Orna = UIImage(named: "vip_top")
        let aspect_Orna = img_Orna.map { $0.size.height / $0.size.width } ?? 0.75
        let vipTopH_Orna: CGFloat = imgW_Orna * aspect_Orna * 0.88

        /// 顶部背景图：全宽，高度按 vip_top_bg 图片比例自适应
        let bgImg_Orna = UIImage(named: "vip_top_bg")
        let bgAspect_Orna = bgImg_Orna.map { $0.size.height / $0.size.width } ?? 0.5
        let bgH_Orna: CGFloat = screenW_Orna * bgAspect_Orna
        topBgImageView_Orna.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(bgH_Orna)
        }

        /// 导航栏
        navBar_Orna.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Orna.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Orna.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton_Orna)
        }

        /// 纵向滚动容器：顶部从导航栏底部开始
        scrollView_Orna.snp.makeConstraints {
            $0.top.equalTo(navBar_Orna.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        /// contentView 最小高度等于滚动视图高度，保证底部内容始终贴底
        contentView_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualTo(scrollView_Orna.snp.height)
        }

        /// 组件1（vip_top）：从内容顶部开始排布，消除导航栏下方多余空白
        vipTopImage_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(0)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(vipTopH_Orna)
        }

        /// 组件2（横向套餐列表）：位于装饰图下方，高度预留选中阴影空间
        itemsHScroll_Orna.snp.makeConstraints {
            $0.top.equalTo(vipTopImage_Orna.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(135)
        }
        itemsHStack_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }

        /// 恢复购买按钮：位于套餐列表下方 10pt，水平居中，文本为黑色
        restoreButton_Orna.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(itemsHScroll_Orna.snp.bottom).offset(10)
            $0.height.equalTo(22)
        }

        /// 订阅按钮：位于恢复购买按钮下方 30pt，宽度为屏幕宽度 - 32，高度 50
        subscribeButton_Orna.snp.makeConstraints {
            $0.top.equalTo(restoreButton_Orna.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }

        /// 组件3（协议）：位于订阅按钮下方并决定内容底部
        protoLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(subscribeButton_Orna.snp.bottom).offset(16)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Orna() {
        backButton_Orna.addTarget(self, action: #selector(backTapped_Orna), for: .touchUpInside)
        restoreButton_Orna.addTarget(self, action: #selector(restoreTapped_Orna), for: .touchUpInside)
        subscribeButton_Orna.addTarget(self, action: #selector(subscribeTapped_Orna), for: .touchUpInside)
    }

    @objc private func backTapped_Orna() {
        Navigation_Orna.pop_Orna(from: self)
    }

    /// 恢复购买按钮回调
    @objc private func restoreTapped_Orna() {
        Store_Orna.shared_Orna.RestorePurchase_Orna { [weak self] in
            guard let self_Orna = self else { return }
            _ = self_Orna
        }
    }

    /// 订阅按钮回调
    /// 功能：购买当前选中的 VIP 套餐
    /// 参数：无
    /// 返回值：无
    /// 异常场景：没有选中套餐时展示错误提示
    @objc private func subscribeTapped_Orna() {
        guard let selectedVIPItem_Orna else {
            Load_Orna.showWarning_Orna(message_Orna: "Please select a subscription plan.")
            return
        }
        purchaseItem_Orna(model: selectedVIPItem_Orna)
    }

    /// 切换选中的 VIP 套餐
    /// 功能：记录当前选中套餐，并刷新所有套餐卡片的边框与阴影状态
    /// 参数：
    /// - model_orna: 用户点击选中的套餐模型
    /// 返回值：无
    /// 异常场景：无
    private func selectVIPItem_Orna(model_orna: StoreModel_Orna) {
        selectedVIPItem_Orna = model_orna
        vipItemCells_Orna.forEach { cell_orna in
            cell_orna.setSelected_Orna(isSelected_orna: cell_orna.model_Orna?.goodsId_Orna == model_orna.goodsId_Orna)
        }
    }

    /// 发起指定套餐的 VIP 内购
    /// - Parameter model: 选中的套餐模型
    private func purchaseItem_Orna(model: StoreModel_Orna) {
        guard let gid_Orna = model.goodsId_Orna else {
            Load_Orna.showWarning_Orna(message_Orna: "Invalid subscription plan.")
            return
        }
        Store_Orna.shared_Orna.PurchaseStoreVIP_Orna(vipId_Orna: gid_Orna) { [weak self] in
            guard let self_Orna = self else { return }
            Navigation_Orna.pop_Orna(from: self_Orna)
        }
    }
}

// MARK: - VIPItemCell_Orna

/// VIP 套餐卡片视图
/// 核心作用：展示单个 VIP 套餐信息，支持点击卡片切换当前选中套餐
/// 设计思路：110×115 白色圆角卡片，内部展示套餐名称、价格与续订说明；
///           选中态显示 2pt 黑色边框，并带有向下的紫色阴影强调当前选择
/// 关键属性：
/// - model_Orna: 当前绑定的套餐数据
/// - onSelectTap_Orna: 套餐卡片点击回调
private class VIPItemCell_Orna: UIView {

    // MARK: - 属性

    /// 当前套餐数据（外部只读，内部赋值）
    private(set) var model_Orna: StoreModel_Orna?

    /// 点击套餐卡片回调，回传套餐模型
    var onSelectTap_Orna: ((StoreModel_Orna) -> Void)?

    // MARK: - UI

    /// 套餐名称标签，显示 goodsName_Orna
    private let memberLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#666666")
        l.textAlignment = .center
        l.numberOfLines = 1
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.75
        return l
    }()

    /// 价格富文本标签
    private let priceLabel_Orna: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.7
        return l
    }()

    /// 续订说明标签，根据套餐周期展示对应文案
    private let renewalLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#999999")
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI_Orna()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    /// 构建白色圆角套餐卡片与点击手势
    /// 功能：搭建套餐名称、价格、续订说明三段内容，并添加卡片点击能力
    /// 参数：无
    /// 返回值：无
    /// 异常场景：无
    private func buildUI_Orna() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.masksToBounds = false

        /// VStack 容器：3个元素垂直排列，适配 110×115 的紧凑卡片尺寸
        let vStack_Orna = UIStackView(arrangedSubviews: [
            memberLabel_Orna,
            priceLabel_Orna,
            renewalLabel_Orna
        ])
        vStack_Orna.axis      = .vertical
        vStack_Orna.spacing   = 6
        vStack_Orna.alignment = .center

        addSubview(vStack_Orna)
        vStack_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.lessThanOrEqualToSuperview().offset(-10)
        }

        renewalLabel_Orna.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }

        let tap_Orna = UITapGestureRecognizer(target: self, action: #selector(cellTapped_Orna))
        addGestureRecognizer(tap_Orna)
        isUserInteractionEnabled = true
    }

    // MARK: - 数据填充

    /// 注入套餐数据，更新套餐名、价格富文本与续订说明
    /// 参数：
    /// - model: VIP 套餐模型（读取 goodsPrice_Orna 和 goodsName_Orna）
    /// 返回值：无
    /// 异常场景：无
    func configure_Orna(model: StoreModel_Orna) {
        self.model_Orna = model
        memberLabel_Orna.text = model.goodsName_Orna ?? ""

        /// 构建价格富文本：去掉周期后缀，分离货币符号与数字，分别设置不同字号
        let priceStr_Orna = model.goodsPrice_Orna ?? ""
        let displayPrice_Orna = priceStr_Orna.components(separatedBy: "/").first ?? priceStr_Orna
        let hasCurrencyPrefix_Orna = displayPrice_Orna.hasPrefix("$") || displayPrice_Orna.hasPrefix("¥")
        let symbol_Orna = hasCurrencyPrefix_Orna ? String(displayPrice_Orna.prefix(1)) : ""
        let number_Orna = hasCurrencyPrefix_Orna ? String(displayPrice_Orna.dropFirst()) : displayPrice_Orna

        let attrStr_Orna = NSMutableAttributedString(
            string: symbol_Orna,
            attributes: [
                .font: UIFont.systemFont(ofSize: 13, weight: .bold),
                .foregroundColor: UIColor(hexstring_Orna: "#4D4D4D")
            ]
        )
        attrStr_Orna.append(NSAttributedString(
            string: number_Orna,
            attributes: [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor(hexstring_Orna: "#4D4D4D")
            ]
        ))
        priceLabel_Orna.attributedText = attrStr_Orna
        renewalLabel_Orna.text = renewalText_Orna(price_orna: priceStr_Orna)
    }

    /// 更新套餐卡片选中态
    /// 功能：选中时显示黑色边框与向下紫色阴影，未选中时还原为普通白色卡片
    /// 参数：
    /// - isSelected_orna: 当前卡片是否选中
    /// 返回值：无
    /// 异常场景：无
    func setSelected_Orna(isSelected_orna: Bool) {
        layer.borderWidth = isSelected_orna ? 2 : 0
        layer.borderColor = isSelected_orna ? UIColor.black.cgColor : UIColor.clear.cgColor
        layer.shadowColor = UIColor(hexstring_Orna: "#9863F4").cgColor
        layer.shadowOpacity = isSelected_orna ? 0.28 : 0
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowRadius = isSelected_orna ? 12 : 0
    }

    /// 根据价格周期生成续订说明
    /// 参数：
    /// - price_orna: 原始价格字符串，例如 "$6.99/w"、"$14.99/m"、"$39.99/3m"
    /// 返回值：续订周期说明文本
    /// 异常场景：无法识别周期时返回通用按周期支付说明
    private func renewalText_Orna(price_orna: String) -> String {
        if price_orna.contains("/w") {
            return "Pay weekly, cancel any time"
        }
        if price_orna.contains("/3m") {
            return "Pay every 3 months, cancel any time"
        }
        if price_orna.contains("/m") {
            return "Pay monthly, cancel any time"
        }
        return "Pay by plan, cancel any time"
    }

    // MARK: - 点击处理

    /// 点击套餐卡片，触发选中回调
    /// 功能：通知外部当前用户选择的套餐
    /// 参数：无
    /// 返回值：无
    /// 异常场景：模型为空时不触发回调
    @objc private func cellTapped_Orna() {
        guard let model_Orna = model_Orna else { return }
        onSelectTap_Orna?(model_Orna)
    }
}
