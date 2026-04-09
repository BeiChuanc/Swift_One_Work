import Foundation
import UIKit
import SnapKit

// MARK: - VIP 订阅页面

/// VIP 订阅页面
/// 核心作用：展示 VIP 套餐列表，支持套餐选择、发起内购订阅及恢复购买
/// 设计思路：全屏青紫渐变背景（左上 #00FFF0 → 右下 #A678F1）+ 顶部 vip_top 装饰图 + 横向套餐列表 + 底部操作区
/// 关键属性：
/// - vipItems_Tidy: 从 Store_Tidy 筛选出 goodIsVIP_Tidy 为 true 的套餐数组
/// - selectedItem_Tidy: 当前选中的 VIP 套餐（发起购买前校验）
/// - itemCells_Tidy: 所有套餐 Cell，用于统一切换选中态
class VIPSubscription_Tidy: UIViewController {

    // MARK: - 数据

    /// 所有 VIP 套餐
    private var vipItems_Tidy: [StoreModel_Tidy] = []
    /// 当前选中套餐
    private var selectedItem_Tidy: StoreModel_Tidy?
    /// 所有套餐 Cell 引用（统一更新选中态）
    private var itemCells_Tidy: [VIPItemCell_Tidy] = []

    // MARK: - UI · 背景渐变

    private var bgGradient_Tidy: CAGradientLayer?

    // MARK: - UI · 自定义导航栏

    private let navBar_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let backButton_Tidy: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Tidy = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Tidy)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Tidy: UILabel = {
        let l = UILabel()
        l.text = "Subscription"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .white
        return l
    }()

    // MARK: - UI · 滚动容器

    private let scrollView_Tidy: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Tidy = UIView()

    // MARK: - UI · 组件1：顶部装饰图

    /// vip_top 装饰图（组件1），紧贴导航栏底部，左右内边距20，完整展示图片内容
    private let vipTopImage_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        return iv
    }()

    // MARK: - UI · 组件2：套餐横向滑动列表

    /// 套餐横向滚动容器，高度 150，不显示滚动条
    private let itemsScrollView_Tidy: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        sv.clipsToBounds = false
        return sv
    }()

    /// 套餐横向 StackView，间距 12
    private let itemsHStack_Tidy: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .fill
        return sv
    }()

    // MARK: - UI · 组件3：恢复购买

    private let restoreButton_Tidy: UIButton = {
        let b = UIButton(type: .system)
        let attrs_Tidy: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.white
        ]
        let title_Tidy = NSAttributedString(string: "Restore Purchases", attributes: attrs_Tidy)
        b.setAttributedTitle(title_Tidy, for: .normal)
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - UI · 组件4：订阅按钮

    private let subscribeButton_Tidy: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "vip_sub"), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.clipsToBounds = true
        return b
    }()

    // MARK: - UI · 组件5：协议标签

    private var protocolLabel_Tidy: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData_Tidy()
        setupUI_Tidy()
        buildItemCells_Tidy()
        setupActions_Tidy()
        // 默认选中第一项
        if let first_Tidy = vipItems_Tidy.first {
            updateSelection_Tidy(model: first_Tidy)
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
        bgGradient_Tidy?.frame = view.bounds
    }

    // MARK: - 数据加载

    /// 从 Store_Tidy 筛选 VIP 套餐
    private func loadData_Tidy() {
        vipItems_Tidy = Store_Tidy.shared_Tidy.goodsList_Tidy.filter { $0.goodIsVIP_Tidy == true }
    }

    // MARK: - UI 搭建

    private func setupUI_Tidy() {
        setupBgGradient_Tidy()

        view.addSubview(scrollView_Tidy)
        scrollView_Tidy.addSubview(contentView_Tidy)

        // 组件1
        contentView_Tidy.addSubview(vipTopImage_Tidy)
        // 组件2：横向滑动列表
        contentView_Tidy.addSubview(itemsScrollView_Tidy)
        itemsScrollView_Tidy.addSubview(itemsHStack_Tidy)
        // 组件3
        contentView_Tidy.addSubview(restoreButton_Tidy)
        // 组件4
        contentView_Tidy.addSubview(subscribeButton_Tidy)

        // 组件5：协议标签（terms + eula，白色文字，适配渐变背景）
        let proto_Tidy = ProtocolHelper_Tidy.createProtocolTextLabel_Tidy(
            firstProtocol_Tidy: .terms_Tidy,
            firstContent_Tidy: "terms.png",
            secondProtocol_Tidy: .eula_Tidy,
            secondContent_Tidy: "eula.png",
            config_Tidy: .dark_Tidy(),
            from: self
        )
        contentView_Tidy.addSubview(proto_Tidy)
        protocolLabel_Tidy = proto_Tidy

        // 导航栏（最顶层）
        view.addSubview(navBar_Tidy)
        navBar_Tidy.addSubview(backButton_Tidy)
        navBar_Tidy.addSubview(navTitleLabel_Tidy)

        setupConstraints_Tidy(protoLabel: proto_Tidy)
    }

    /// 全屏渐变背景：#00FFF0（左上）→ #A678F1（右下）
    private func setupBgGradient_Tidy() {
        let gl_Tidy = CAGradientLayer()
        gl_Tidy.colors = [
            UIColor(hexstring_Tidy: "#00FFF0").cgColor,
            UIColor(hexstring_Tidy: "#A678F1").cgColor
        ]
        gl_Tidy.startPoint = CGPoint(x: 0, y: 0)
        gl_Tidy.endPoint   = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gl_Tidy, at: 0)
        bgGradient_Tidy = gl_Tidy
    }

    // MARK: - 构建套餐 Cell

    /// 遍历 vipItems_Tidy 生成 VIPItemCell_Tidy 并加入横向 StackView
    private func buildItemCells_Tidy() {
        itemCells_Tidy.removeAll()
        // 左侧首项内边距
        let leadingSpacer_Tidy = UIView()
        itemsHStack_Tidy.addArrangedSubview(leadingSpacer_Tidy)
        leadingSpacer_Tidy.snp.makeConstraints { $0.width.equalTo(16) }

        vipItems_Tidy.forEach { model_Tidy in
            let cell_Tidy = VIPItemCell_Tidy()
            cell_Tidy.configure_Tidy(model: model_Tidy)
            cell_Tidy.onTap_Tidy = { [weak self] selected_Tidy in
                self?.updateSelection_Tidy(model: selected_Tidy)
            }
            itemsHStack_Tidy.addArrangedSubview(cell_Tidy)
            cell_Tidy.snp.makeConstraints {
                $0.width.equalTo(140)
                $0.height.equalTo(150)
            }
            itemCells_Tidy.append(cell_Tidy)
        }

        // 右侧末项内边距
        let trailingSpacer_Tidy = UIView()
        itemsHStack_Tidy.addArrangedSubview(trailingSpacer_Tidy)
        trailingSpacer_Tidy.snp.makeConstraints { $0.width.equalTo(16) }
    }

    // MARK: - 约束

    private func setupConstraints_Tidy(protoLabel: UILabel) {
        let screenW_Tidy = UIScreen.main.bounds.width
        // 图片宽度 = 屏幕宽 - 左右各20内边距，高度按图片实际比例自适应（scaleAspectFit）
        let imgW_Tidy: CGFloat = screenW_Tidy - 40
        let img_Tidy = UIImage(named: "vip_top")
        let aspect_Tidy = img_Tidy.map { $0.size.height / $0.size.width } ?? 0.75
        let vipTopH_Tidy: CGFloat = imgW_Tidy * aspect_Tidy

        // 导航栏
        navBar_Tidy.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Tidy.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Tidy.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton_Tidy)
        }

        // 滚动容器：顶部从导航栏底部开始，确保内容可正常滚动
        scrollView_Tidy.snp.makeConstraints {
            $0.top.equalTo(navBar_Tidy.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Tidy.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // 组件1：vip_top，左右内边距20，高度按缩小比例展示完整图片
        vipTopImage_Tidy.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(vipTopH_Tidy)
        }

        // 组件2：横向套餐列表，距 vip_top 下方 20，高度 150，左右撑满
        itemsScrollView_Tidy.snp.makeConstraints {
            $0.top.equalTo(vipTopImage_Tidy.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(150)
        }
        itemsHStack_Tidy.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }

        // 组件3：恢复购买，距套餐列表下方 15，居中
        restoreButton_Tidy.snp.makeConstraints {
            $0.top.equalTo(itemsScrollView_Tidy.snp.bottom).offset(15)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(22)
        }

        // 组件4：订阅按钮，距恢复购买下方 20，屏幕宽-32，高 62
        subscribeButton_Tidy.snp.makeConstraints {
            $0.top.equalTo(restoreButton_Tidy.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(62)
        }

        // 组件5：协议，距订阅按钮下方 15
        protoLabel.snp.makeConstraints {
            $0.top.equalTo(subscribeButton_Tidy.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 选中状态更新

    /// 更新所有 Cell 的选中态，并记录当前选中套餐
    /// - Parameter model: 被选中的套餐模型
    private func updateSelection_Tidy(model: StoreModel_Tidy) {
        selectedItem_Tidy = model
        itemCells_Tidy.forEach { cell_Tidy in
            cell_Tidy.setSelected_Tidy(cell_Tidy.model_Tidy?.id_Tidy == model.id_Tidy)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Tidy() {
        backButton_Tidy.addTarget(self, action: #selector(backTapped_Tidy), for: .touchUpInside)
        restoreButton_Tidy.addTarget(self, action: #selector(restoreTapped_Tidy), for: .touchUpInside)
        subscribeButton_Tidy.addTarget(self, action: #selector(subscribeTapped_Tidy), for: .touchUpInside)
    }

    @objc private func backTapped_Tidy() {
        Navigation_Tidy.pop_Tidy(from: self)
    }

    /// 恢复购买按钮回调
    @objc private func restoreTapped_Tidy() {
        Store_Tidy.shared_Tidy.RestorePurchase_Tidy { [weak self] in
            guard let self_Tidy = self else { return }
            print("恢复购买成功，刷新 VIP 状态")
            _ = self_Tidy
        }
    }

    /// 订阅按钮回调：发起 VIP 内购
    @objc private func subscribeTapped_Tidy() {
        guard let item_Tidy = selectedItem_Tidy,
              let gid_Tidy  = item_Tidy.goodsId_Tidy else {
            Utils_Tidy.showWarning_Tidy(message_Tidy: "Please select a subscription plan.")
            return
        }
        subscribeButton_Tidy.animatePressDown_Tidy { self.subscribeButton_Tidy.animatePressUp_Tidy() }
        Store_Tidy.shared_Tidy.PurchaseStoreVIP_Tidy(vipId_Tidy: gid_Tidy) { [weak self] in
            guard let self_Tidy = self else { return }
            print("VIP 订阅成功，关闭页面")
            Navigation_Tidy.pop_Tidy(from: self_Tidy)
        }
    }
}

// MARK: - VIPItemCell_Tidy

/// VIP 套餐单元格视图
/// 核心作用：展示单个 VIP 套餐信息（Premium Member + 价格 + 套餐名），支持点击回调
/// 设计思路：圆角20的卡片，内部居中 VStack 排列三行文本，选中态改变背景及套餐名颜色
/// 关键方法：
/// - configure_Tidy: 注入套餐数据（价格 + 套餐名）
/// - setSelected_Tidy: 切换选中态（背景透明度 + 套餐名颜色）
private class VIPItemCell_Tidy: UIView {

    // MARK: - 属性

    /// 当前套餐数据（外部只读，内部赋值）
    private(set) var model_Tidy: StoreModel_Tidy?

    /// 点击回调，回传选中的套餐模型
    var onTap_Tidy: ((StoreModel_Tidy) -> Void)?

    // MARK: - UI

    /// 固定文案 "Premium Member"，字号12，颜色 #111111
    private let premiumLabel_Tidy: UILabel = {
        let l = UILabel()
        l.text          = "Premium Member"
        l.font          = .systemFont(ofSize: 14, weight: .bold)
        l.textColor     = UIColor(hexstring_Tidy: "#111111")
        l.textAlignment = .center
        return l
    }()

    /// 价格文本，字号20加粗，颜色 #A678F1
    private let priceLabel_Tidy: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 30, weight: .bold)
        l.textColor     = UIColor(hexstring_Tidy: "#A678F1")
        l.textAlignment = .center
        return l
    }()

    /// 套餐名：未选中白色，选中浅黑色 #333333，字号14常规
    private let nameLabel_Tidy: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 16, weight: .regular)
        l.textColor     = .white
        l.textAlignment = .center
        return l
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Tidy()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func setupUI_Tidy() {
        backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        layer.cornerRadius = 25

        // 垂直 StackView 居中显示，Premium Member → (12) → 价格 → (5) → 套餐名
        let vStack_Tidy = UIStackView(arrangedSubviews: [
            premiumLabel_Tidy,
            priceLabel_Tidy,
            nameLabel_Tidy
        ])
        vStack_Tidy.axis      = .vertical
        vStack_Tidy.alignment = .center
        vStack_Tidy.spacing   = 0
        // premiumLabel 与 priceLabel 间距 12
        vStack_Tidy.setCustomSpacing(12, after: premiumLabel_Tidy)
        // priceLabel 与 nameLabel 间距 5
        vStack_Tidy.setCustomSpacing(5, after: priceLabel_Tidy)

        addSubview(vStack_Tidy)
        vStack_Tidy.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(8)
        }

        // 点击手势
        let tap_Tidy = UITapGestureRecognizer(target: self, action: #selector(handleTap_Tidy))
        addGestureRecognizer(tap_Tidy)
        isUserInteractionEnabled = true
    }

    // MARK: - 数据填充

    /// 注入套餐数据
    /// - Parameter model: VIP 套餐模型（读取 goodsPrice_Tidy 和 goodsName_Tidy）
    func configure_Tidy(model: StoreModel_Tidy) {
        self.model_Tidy      = model
        priceLabel_Tidy.text = model.goodsPrice_Tidy
        nameLabel_Tidy.text  = model.goodsName_Tidy
    }

    // MARK: - 选中态切换

    /// 切换选中状态：选中时背景更不透明 + 套餐名变为浅黑色，未选中时半透明 + 套餐名白色
    /// - Parameter selected: true 为选中态，false 为未选中态
    func setSelected_Tidy(_ selected: Bool) {
        backgroundColor        = selected
            ? UIColor.white.withAlphaComponent(0.88)
            : UIColor.white.withAlphaComponent(0.25)
        nameLabel_Tidy.textColor = selected
            ? UIColor(hexstring_Tidy: "#333333")
            : .white
    }

    // MARK: - 点击处理

    @objc private func handleTap_Tidy() {
        guard let model_Tidy = model_Tidy else { return }
        onTap_Tidy?(model_Tidy)
    }
}
