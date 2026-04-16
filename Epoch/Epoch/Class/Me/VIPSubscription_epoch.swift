import Foundation
import UIKit
import SnapKit

// MARK: - VIP 订阅页面

/// VIP 订阅页面
/// 核心作用：展示 VIP 套餐列表，支持套餐选择、发起内购订阅及恢复购买
/// 设计思路：全屏三段渐变背景（顶部居中 #8CBDFF → #D6A1FB → 底部居中 #F790FD）
///          顶部 vip_top_bg 装饰背景图（全屏宽）+ 恢复购买按钮 + vip_top 装饰图 + 横向套餐列表 + 底部操作区
/// 关键属性：
/// - vipItems_Epoch: 从 Store_Epoch 筛选出 goodIsVIP_Epoch 为 true 的套餐数组
/// - selectedItem_Epoch: 当前选中的 VIP 套餐（发起购买前校验）
/// - itemCells_Epoch: 所有套餐 Cell，用于统一切换选中态
class VIPSubscription_Epoch: UIViewController {

    // MARK: - 数据

    /// 所有 VIP 套餐
    private var vipItems_Epoch: [StoreModel_Epoch] = []
    /// 当前选中套餐
    private var selectedItem_Epoch: StoreModel_Epoch?
    /// 所有套餐 Cell 引用（统一更新选中态）
    private var itemCells_Epoch: [VIPItemCell_Epoch] = []

    // MARK: - UI · 背景渐变

    private var bgGradient_Epoch: CAGradientLayer?

    // MARK: - UI · 自定义导航栏

    private let navBar_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v 
    }()

    private let backButton_Epoch: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Epoch = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "xmark", withConfiguration: cfg_Epoch)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Epoch: UILabel = {
        let l = UILabel()
        l.text = "Membership Subscription"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .white
        return l
    }()

    // MARK: - UI · 滚动容器

    private let scrollView_Epoch: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Epoch = UIView()

    // MARK: - UI · 组件0：顶部背景装饰图

    /// vip_top_bg 顶部背景装饰图，全屏宽，左右无间隙
    private let vipTopBgImage_Epoch: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top_bg")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    // MARK: - UI · 组件1：顶部装饰图

    /// vip_top 装饰图（组件1），左右内边距20，完整展示图片内容
    private let vipTopImage_Epoch: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        return iv
    }()

    // MARK: - UI · 组件2：套餐横向滑动列表

    /// 套餐横向滚动容器，高度 150，不显示滚动条
    private let itemsScrollView_Epoch: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        sv.clipsToBounds = false
        return sv
    }()

    /// 套餐横向 StackView，间距 12
    private let itemsHStack_Epoch: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .fill
        return sv
    }()

    // MARK: - UI · 组件3：恢复购买

    private let restoreButton_Epoch: UIButton = {
        let b = UIButton(type: .system)
        let attrs_Epoch: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.white
        ]
        let title_Epoch = NSAttributedString(string: "Restore Purchases", attributes: attrs_Epoch)
        b.setAttributedTitle(title_Epoch, for: .normal)
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - UI · 组件4：订阅按钮

    private let subscribeButton_Epoch: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "vip_sub"), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.clipsToBounds = true
        return b
    }()

    // MARK: - UI · 组件5：协议标签

    private var protocolLabel_Epoch: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData_Epoch()
        setupUI_Epoch()
        buildItemCells_Epoch()
        setupActions_Epoch()
        // 默认选中第一项
        if let first_Epoch = vipItems_Epoch.first {
            updateSelection_Epoch(model: first_Epoch)
        }
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
        bgGradient_Epoch?.frame = view.bounds
    }

    // MARK: - 数据加载

    /// 从 Store_Epoch 筛选 VIP 套餐
    private func loadData_Epoch() {
        vipItems_Epoch = Store_Epoch.shared_Epoch.goodsList_Epoch.filter { $0.goodIsVIP_Epoch == true }
    }

    // MARK: - UI 搭建

    private func setupUI_Epoch() {
        setupBgGradient_Epoch()

        view.addSubview(scrollView_Epoch)
        scrollView_Epoch.addSubview(contentView_Epoch)

        // 组件0：顶部背景装饰图
        contentView_Epoch.addSubview(vipTopBgImage_Epoch)
        // 组件3（前置）：恢复购买，位于 vip_top_bg 与 vip_top 之间
        contentView_Epoch.addSubview(restoreButton_Epoch)
        // 组件1：vip_top 装饰图
        contentView_Epoch.addSubview(vipTopImage_Epoch)
        // 组件2：横向滑动列表
        contentView_Epoch.addSubview(itemsScrollView_Epoch)
        itemsScrollView_Epoch.addSubview(itemsHStack_Epoch)
        // 组件4
        contentView_Epoch.addSubview(subscribeButton_Epoch)

        // 组件5：协议标签（terms + eula，白色文字，适配渐变背景）
        let proto_Epoch = ProtocolHelper_Epoch.createProtocolTextLabel_Epoch(
            firstProtocol_Epoch: .terms_Epoch,
            firstContent_Epoch: "terms.png",
            secondProtocol_Epoch: .eula_Epoch,
            secondContent_Epoch: "eula.png",
            config_Epoch: .dark_Epoch(),
            from: self
        )
        contentView_Epoch.addSubview(proto_Epoch)
        protocolLabel_Epoch = proto_Epoch

        // 导航栏（最顶层）
        view.addSubview(navBar_Epoch)
        navBar_Epoch.addSubview(backButton_Epoch)
        navBar_Epoch.addSubview(navTitleLabel_Epoch)

        setupConstraints_Epoch(protoLabel: proto_Epoch)
    }

    /// 全屏渐变背景：顶部居中 #8CBDFF → #D6A1FB → 底部居中 #F790FD
    private func setupBgGradient_Epoch() {
        let gl_Epoch = CAGradientLayer()
        gl_Epoch.colors = [
            UIColor(hexstring_Epoch: "#8CBDFF").cgColor,
            UIColor(hexstring_Epoch: "#D6A1FB").cgColor,
            UIColor(hexstring_Epoch: "#F790FD").cgColor
        ]
        gl_Epoch.startPoint = CGPoint(x: 0.5, y: 0)
        gl_Epoch.endPoint   = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gl_Epoch, at: 0)
        bgGradient_Epoch = gl_Epoch
    }

    // MARK: - 构建套餐 Cell

    /// 遍历 vipItems_Epoch 生成 VIPItemCell_Epoch 并加入横向 StackView
    private func buildItemCells_Epoch() {
        itemCells_Epoch.removeAll()
        // 左侧首项内边距
        let leadingSpacer_Epoch = UIView()
        itemsHStack_Epoch.addArrangedSubview(leadingSpacer_Epoch)
        leadingSpacer_Epoch.snp.makeConstraints { $0.width.equalTo(16) }

        vipItems_Epoch.forEach { model_Epoch in
            let cell_Epoch = VIPItemCell_Epoch()
            cell_Epoch.configure_Epoch(model: model_Epoch)
            cell_Epoch.onTap_Epoch = { [weak self] selected_Epoch in
                self?.updateSelection_Epoch(model: selected_Epoch)
            }
            itemsHStack_Epoch.addArrangedSubview(cell_Epoch)
            cell_Epoch.snp.makeConstraints {
                $0.width.equalTo(140)
                $0.height.equalTo(150)
            }
            itemCells_Epoch.append(cell_Epoch)
        }

        // 右侧末项内边距
        let trailingSpacer_Epoch = UIView()
        itemsHStack_Epoch.addArrangedSubview(trailingSpacer_Epoch)
        trailingSpacer_Epoch.snp.makeConstraints { $0.width.equalTo(16) }
    }

    // MARK: - 约束

    private func setupConstraints_Epoch(protoLabel: UILabel) {
        let screenW_Epoch = UIScreen.main.bounds.width

        /// vip_top_bg 高度按图片比例计算后缩减至 80%
        let bgImg_Epoch    = UIImage(named: "vip_top_bg")
        let bgAspect_Epoch = bgImg_Epoch.map { $0.size.height / $0.size.width } ?? 0.5
        let vipTopBgH_Epoch: CGFloat = screenW_Epoch * bgAspect_Epoch * 0.80

        /// vip_top 高度按图片比例计算（左右各内边距20）
        let imgW_Epoch    = screenW_Epoch - 40
        let topImg_Epoch  = UIImage(named: "vip_top")
        let topAspect_Epoch = topImg_Epoch.map { $0.size.height / $0.size.width } ?? 0.75
        let vipTopH_Epoch: CGFloat = imgW_Epoch * topAspect_Epoch

        // 导航栏
        navBar_Epoch.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Epoch.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        /// 标题位置：X 按钮右边 10
        navTitleLabel_Epoch.snp.makeConstraints {
            $0.leading.equalTo(backButton_Epoch.snp.trailing).offset(10)
            $0.centerY.equalTo(backButton_Epoch)
        }

        // 滚动容器：从屏幕顶部开始，vip_top_bg 无缝铺满，navBar 悬浮覆盖其上
        scrollView_Epoch.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Epoch.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // 组件0：vip_top_bg，全屏宽，左右无间隙
        vipTopBgImage_Epoch.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(vipTopBgH_Epoch)
        }

        // 组件3（前置）：恢复购买，vip_top_bg 底部下方 10，居中
        restoreButton_Epoch.snp.makeConstraints {
            $0.top.equalTo(vipTopBgImage_Epoch.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(22)
        }

        // 组件1：vip_top，恢复购买按钮底部下方 16，左右内边距20
        vipTopImage_Epoch.snp.makeConstraints {
            $0.top.equalTo(restoreButton_Epoch.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(vipTopH_Epoch)
        }

        // 组件2：横向套餐列表，距 vip_top 下方 20，高度 150，左右撑满
        itemsScrollView_Epoch.snp.makeConstraints {
            $0.top.equalTo(vipTopImage_Epoch.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(150)
        }
        itemsHStack_Epoch.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }

        // 组件4：订阅按钮，距套餐列表下方 20，屏幕宽-32，高 62
        subscribeButton_Epoch.snp.makeConstraints {
            $0.top.equalTo(itemsScrollView_Epoch.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(62)
        }

        // 组件5：协议，距订阅按钮下方 15
        protoLabel.snp.makeConstraints {
            $0.top.equalTo(subscribeButton_Epoch.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 选中状态更新

    /// 更新所有 Cell 的选中态，并记录当前选中套餐
    /// - Parameter model: 被选中的套餐模型
    private func updateSelection_Epoch(model: StoreModel_Epoch) {
        selectedItem_Epoch = model
        itemCells_Epoch.forEach { cell_Epoch in
            cell_Epoch.setSelected_Epoch(cell_Epoch.model_Epoch?.id_Epoch == model.id_Epoch)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Epoch() {
        backButton_Epoch.addTarget(self, action: #selector(backTapped_Epoch), for: .touchUpInside)
        restoreButton_Epoch.addTarget(self, action: #selector(restoreTapped_Epoch), for: .touchUpInside)
        subscribeButton_Epoch.addTarget(self, action: #selector(subscribeTapped_Epoch), for: .touchUpInside)
    }

    @objc private func backTapped_Epoch() {
        Navigation_Epoch.pop_Epoch(from: self)
    }

    /// 恢复购买按钮回调
    @objc private func restoreTapped_Epoch() {
        Store_Epoch.shared_Epoch.RestorePurchase_Epoch { [weak self] in
            guard let self_Epoch = self else { return }
            print("恢复购买成功，刷新 VIP 状态")
            _ = self_Epoch
        }
    }

    /// 订阅按钮回调：发起 VIP 内购
    @objc private func subscribeTapped_Epoch() {
        guard let item_Epoch = selectedItem_Epoch,
              let gid_Epoch  = item_Epoch.goodsId_Epoch else {
            Utils_Epoch.showWarning_Epoch(message_Epoch: "Please select a subscription plan.")
            return
        }
        subscribeButton_Epoch.animatePressDown_Epoch { self.subscribeButton_Epoch.animatePressUp_Epoch() }
        Store_Epoch.shared_Epoch.PurchaseStoreVIP_Epoch(vipId_Epoch: gid_Epoch) { [weak self] in
            guard let self_Epoch = self else { return }
            print("VIP 订阅成功，关闭页面")
            Navigation_Epoch.pop_Epoch(from: self_Epoch)
        }
    }
}

// MARK: - VIPItemCell_Epoch

/// VIP 套餐单元格视图
/// 核心作用：展示单个 VIP 套餐信息（Premium Member + 价格 + 套餐名），支持点击回调
/// 设计思路：圆角20的卡片，内部居中 VStack 排列三行文本，选中态改变背景及套餐名颜色
/// 关键方法：
/// - configure_Epoch: 注入套餐数据（价格 + 套餐名）
/// - setSelected_Epoch: 切换选中态（背景透明度 + 套餐名颜色）
private class VIPItemCell_Epoch: UIView {

    // MARK: - 属性

    /// 当前套餐数据（外部只读，内部赋值）
    private(set) var model_Epoch: StoreModel_Epoch?

    /// 点击回调，回传选中的套餐模型
    var onTap_Epoch: ((StoreModel_Epoch) -> Void)?

    // MARK: - UI

    /// 固定文案 "Premium Member"，始终黑色
    private let premiumLabel_Epoch: UILabel = {
        let l = UILabel()
        l.text          = "Premium Member"
        l.font          = .systemFont(ofSize: 14, weight: .bold)
        l.textColor     = UIColor(hexstring_Epoch: "#111111")
        l.textAlignment = .center
        return l
    }()

    /// 价格文本，初始白色（未选中），选中变 #F93AA7
    private let priceLabel_Epoch: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 30, weight: .bold)
        l.textColor     = .white
        l.textAlignment = .center
        return l
    }()

    /// 套餐名，始终黑色
    private let nameLabel_Epoch: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 16, weight: .regular)
        l.textColor     = UIColor(hexstring_Epoch: "#111111")
        l.textAlignment = .center
        return l
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func setupUI_Epoch() {
        /// 初始为未选中粉色背景
        backgroundColor    = UIColor(hexstring_Epoch: "#F93AA7")
        layer.cornerRadius = 25

        // 垂直 StackView 居中显示，Premium Member → (12) → 价格 → (5) → 套餐名
        let vStack_Epoch = UIStackView(arrangedSubviews: [
            premiumLabel_Epoch,
            priceLabel_Epoch,
            nameLabel_Epoch
        ])
        vStack_Epoch.axis      = .vertical
        vStack_Epoch.alignment = .center
        vStack_Epoch.spacing   = 0
        // premiumLabel 与 priceLabel 间距 12
        vStack_Epoch.setCustomSpacing(12, after: premiumLabel_Epoch)
        // priceLabel 与 nameLabel 间距 5
        vStack_Epoch.setCustomSpacing(5, after: priceLabel_Epoch)

        addSubview(vStack_Epoch)
        vStack_Epoch.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(8)
        }

        // 点击手势
        let tap_Epoch = UITapGestureRecognizer(target: self, action: #selector(handleTap_Epoch))
        addGestureRecognizer(tap_Epoch)
        isUserInteractionEnabled = true
    }

    // MARK: - 数据填充

    /// 注入套餐数据
    /// - Parameter model: VIP 套餐模型（读取 goodsPrice_Epoch 和 goodsName_Epoch）
    func configure_Epoch(model: StoreModel_Epoch) {
        self.model_Epoch      = model
        priceLabel_Epoch.text = model.goodsPrice_Epoch
        nameLabel_Epoch.text  = model.goodsName_Epoch
    }

    // MARK: - 选中态切换

    /// 切换选中状态
    /// 背景：选中白色，未选中 #F93AA7
    /// premiumLabel / nameLabel：始终黑色（不随选中态变化）
    /// priceLabel：选中 #F93AA7，未选中白色
    /// - Parameter selected: true 为选中态，false 为未选中态
    func setSelected_Epoch(_ selected: Bool) {
        UIView.animate(withDuration: 0.18) {
            self.backgroundColor          = selected ? .white : UIColor(hexstring_Epoch: "#F93AA7")
            self.priceLabel_Epoch.textColor = selected
                ? UIColor(hexstring_Epoch: "#F93AA7")
                : .white
        }
    }

    // MARK: - 点击处理

    @objc private func handleTap_Epoch() {
        guard let model_Epoch = model_Epoch else { return }
        onTap_Epoch?(model_Epoch)
    }
}
