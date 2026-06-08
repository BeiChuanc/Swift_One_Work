import Foundation
import UIKit
import SnapKit

// MARK: - VIP 订阅页面

/// VIP 订阅页面
/// 核心作用：展示 VIP 套餐列表，支持套餐选择、发起内购订阅及恢复购买
/// 设计思路：全屏青紫渐变背景（左上 #FFA100 → 右下 #E55C45+ 顶部 vip_top 装饰图 + 纵向套餐列表 + 底部操作区
/// 关键属性：
/// - vipItems_Lumia: 从 Store_Lumia 筛选出 goodIsVIP_Lumia 为 true 的套餐数组
/// - selectedItem_Lumia: 当前选中的 VIP 套餐（发起购买前校验）
/// - itemCells_Lumia: 所有套餐 Cell，用于统一切换选中态
class VIPSubscription_Lumia: UIViewController {

    // MARK: - 数据

    /// 所有 VIP 套餐
    private var vipItems_Lumia: [StoreModel_Lumia] = []
    /// 当前选中套餐
    private var selectedItem_Lumia: StoreModel_Lumia?
    /// 所有套餐 Cell 引用（统一更新选中态）
    private var itemCells_Lumia: [VIPItemCell_Lumia] = []

    // MARK: - UI · 背景渐变

    private var bgGradient_Lumia: CAGradientLayer?

    // MARK: - UI · 自定义导航栏

    private let navBar_Lumia: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let backButton_Lumia: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Lumia = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Lumia)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Lumia: UILabel = {
        let l = UILabel()
        l.text = "Subscription"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .white
        return l
    }()

    // MARK: - UI · 滚动容器

    private let scrollView_Lumia: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Lumia = UIView()

    // MARK: - UI · 组件1：顶部装饰图

    /// vip_top 装饰图（组件1），紧贴导航栏底部，左右内边距20，完整展示图片内容
    private let vipTopImage_Lumia: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        return iv
    }()

    // MARK: - UI · 组件2：套餐纵向列表

    /// 套餐纵向 StackView，间距 12
    private let itemsVStack_Lumia: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()

    // MARK: - UI · 组件3：恢复购买

    private let restoreButton_Lumia: UIButton = {
        let b = UIButton(type: .system)
        let attrs_Lumia: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.white
        ]
        let title_Lumia = NSAttributedString(string: "Restore Purchases", attributes: attrs_Lumia)
        b.setAttributedTitle(title_Lumia, for: .normal)
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - UI · 组件4：订阅按钮

    private let subscribeButton_Lumia: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "vip_sub"), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.clipsToBounds = true
        return b
    }()

    // MARK: - UI · 组件5：协议标签

    private var protocolLabel_Lumia: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData_Lumia()
        setupUI_Lumia()
        buildItemCells_Lumia()
        setupActions_Lumia()
        // 默认选中第一项
        if let first_Lumia = vipItems_Lumia.first {
            updateSelection_Lumia(model: first_Lumia)
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
        bgGradient_Lumia?.frame = view.bounds
    }

    // MARK: - 数据加载

    /// 从 Store_Lumia 筛选 VIP 套餐
    private func loadData_Lumia() {
        vipItems_Lumia = Subscribe_Lumia.shared_Lumia.goodsList_Lumia.filter { $0.goodIsVIP_Lumia == true }
    }

    // MARK: - UI 搭建

    private func setupUI_Lumia() {
        setupBgGradient_Lumia()

        view.addSubview(scrollView_Lumia)
        scrollView_Lumia.addSubview(contentView_Lumia)

        // 组件1
        contentView_Lumia.addSubview(vipTopImage_Lumia)
        // 组件2：纵向列表
        contentView_Lumia.addSubview(itemsVStack_Lumia)
        // 组件3：恢复购买按钮（位于套餐列表与购买按钮之间）
        contentView_Lumia.addSubview(restoreButton_Lumia)
        // 组件4
        contentView_Lumia.addSubview(subscribeButton_Lumia)

        // 组件5：协议标签（terms + eula，白色文字）
        let proto_Lumia = ProtocolHelper_Lumia.createProtocolTextLabel_Lumia(
            firstProtocol_Lumia: .terms_Lumia,
            firstContent_Lumia: "terms.png",
            secondProtocol_Lumia: .eula_Lumia,
            secondContent_Lumia: "eula.png",
            config_Lumia: ProtocolHelper_Lumia.ProtocolTextConfig_Lumia(
                textColor_Lumia: UIColor(hexstring_Lumia: "#FFFFFF"),
                linkColor_Lumia: UIColor(hexstring_Lumia: "#FFFFFF"),
                fontSize_Lumia: 13,
                fontWeight_Lumia: .regular,
                hasUnderline_Lumia: true
            ),
            from: self
        )
        contentView_Lumia.addSubview(proto_Lumia)
        protocolLabel_Lumia = proto_Lumia

        // 导航栏（最顶层，不含恢复购买按钮）
        view.addSubview(navBar_Lumia)
        navBar_Lumia.addSubview(backButton_Lumia)
        navBar_Lumia.addSubview(navTitleLabel_Lumia)

        setupConstraints_Lumia(protoLabel: proto_Lumia)
    }

    /// 全屏渐变背景：#7297F9（顶部居中）→ #4A8EFF（底部居中）
    private func setupBgGradient_Lumia() {
        let gl_Lumia = CAGradientLayer()
        gl_Lumia.colors = [
            UIColor(hexstring_Lumia: "#FFA100").cgColor,
            UIColor(hexstring_Lumia: "#E55C45").cgColor
        ]
        gl_Lumia.startPoint = CGPoint(x: 0.5, y: 0.0)
        gl_Lumia.endPoint   = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gl_Lumia, at: 0)
        bgGradient_Lumia = gl_Lumia
    }

    // MARK: - 构建套餐 Cell

    /// 遍历 vipItems_Lumia 生成 VIPItemCell_Lumia 并加入纵向列表
    private func buildItemCells_Lumia() {
        itemCells_Lumia.removeAll()
        vipItems_Lumia.forEach { model_Lumia in
            let cell_Lumia = VIPItemCell_Lumia()
            cell_Lumia.configure_Lumia(model: model_Lumia)
            cell_Lumia.onTap_Lumia = { [weak self] selected_Lumia in
                self?.updateSelection_Lumia(model: selected_Lumia)
            }
            itemsVStack_Lumia.addArrangedSubview(cell_Lumia)
            cell_Lumia.snp.makeConstraints {
                $0.height.equalTo(84)
            }
            itemCells_Lumia.append(cell_Lumia)
        }
    }

    // MARK: - 约束

    private func setupConstraints_Lumia(protoLabel: UILabel) {
        let screenW_Lumia = UIScreen.main.bounds.width
        let imgW_Lumia: CGFloat = screenW_Lumia - 40
        let img_Lumia = UIImage(named: "vip_top")
        let aspect_Lumia = img_Lumia.map { $0.size.height / $0.size.width } ?? 0.75
        let vipTopH_Lumia: CGFloat = imgW_Lumia * aspect_Lumia

        // 导航栏（仅含返回按钮和标题，不含恢复购买）
        navBar_Lumia.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Lumia.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Lumia.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton_Lumia)
        }

        // 滚动容器
        scrollView_Lumia.snp.makeConstraints {
            $0.top.equalTo(navBar_Lumia.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Lumia.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // 组件1：vip_top 装饰图
        vipTopImage_Lumia.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(vipTopH_Lumia)
        }

        // 组件2：纵向套餐列表
        itemsVStack_Lumia.snp.makeConstraints {
            $0.top.equalTo(vipTopImage_Lumia.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        // 组件3：恢复购买按钮，位于套餐列表与购买按钮中间，上下各 10pt，居中
        restoreButton_Lumia.snp.makeConstraints {
            $0.top.equalTo(itemsVStack_Lumia.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(22)
        }

        // 组件4：订阅按钮，距恢复购买按钮下方 10pt
        subscribeButton_Lumia.snp.makeConstraints {
            $0.top.equalTo(restoreButton_Lumia.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(62)
        }

        // 组件5：协议标签，距购买按钮下方 15pt
        protoLabel.snp.makeConstraints {
            $0.top.equalTo(subscribeButton_Lumia.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 选中状态更新

    /// 更新所有 Cell 的选中态，并记录当前选中套餐
    /// - Parameter model: 被选中的套餐模型
    private func updateSelection_Lumia(model: StoreModel_Lumia) {
        selectedItem_Lumia = model
        itemCells_Lumia.forEach { cell_Lumia in
            cell_Lumia.setSelected_Lumia(cell_Lumia.model_Lumia?.id_Lumia == model.id_Lumia)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Lumia() {
        backButton_Lumia.addTarget(self, action: #selector(backTapped_Lumia), for: .touchUpInside)
        restoreButton_Lumia.addTarget(self, action: #selector(restoreTapped_Lumia), for: .touchUpInside)
        subscribeButton_Lumia.addTarget(self, action: #selector(subscribeTapped_Lumia), for: .touchUpInside)
    }

    @objc private func backTapped_Lumia() {
        Navigation_Lumia.pop_Lumia(from: self)
    }

    /// 恢复购买按钮回调
    @objc private func restoreTapped_Lumia() {
        Subscribe_Lumia.shared_Lumia.RestorePurchase_Lumia { [weak self] in
            guard let self_Lumia = self else { return }
            _ = self_Lumia
        }
    }

    /// 订阅按钮回调：发起 VIP 内购
    @objc private func subscribeTapped_Lumia() {
        guard let item_Lumia = selectedItem_Lumia,
              let gid_Lumia  = item_Lumia.goodsId_Lumia else {
            Utils_Lumia.showWarning_Lumia(message_Lumia: "Please select a subscription plan.")
            return
        }
        subscribeButton_Lumia.animatePressDown_Lumia { self.subscribeButton_Lumia.animatePressUp_Lumia() }
        Subscribe_Lumia.shared_Lumia.PurchaseStoreVIP_Lumia(vipId_Lumia: gid_Lumia) { [weak self] in
            guard let self_Lumia = self else { return }
            Navigation_Lumia.pop_Lumia(from: self_Lumia)
        }
    }
}

// MARK: - VIPItemCell_Lumia

/// VIP 套餐单元格视图
/// 核心作用：展示单个 VIP 套餐信息，高度84，背景50%白色半透明，2.5白色边框，圆角25
/// 第一行：goodsName / goodsPrice（白色加粗），第二行：固定副标题（淡白色）
/// 选中时：白色背景+主题色文字+圆形指示器填充；未选中：半透明背景+白色文字+空心指示器
private class VIPItemCell_Lumia: UIView {

    // MARK: - 属性

    /// 当前套餐数据（外部只读）
    private(set) var model_Lumia: StoreModel_Lumia?

    /// 点击回调，回传选中的套餐模型
    var onTap_Lumia: ((StoreModel_Lumia) -> Void)?

    // MARK: - UI

    /// 圆形选中指示器（左侧）
    private let selectCircle_Lumia: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.white.cgColor
        v.backgroundColor = .clear
        return v
    }()
    private let selectInnerDot_Lumia: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white
        v.layer.cornerRadius = 6
        v.isHidden = true
        return v
    }()

    /// 第一行：套餐名 / 价格，白色加粗
    private let titleLabel_Lumia: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textColor = .white
        l.numberOfLines = 1
        return l
    }()

    /// 第二行：固定副标题，颜色比第一行淡
    private let subtitleLabel_Lumia: UILabel = {
        let l = UILabel()
        l.text = "Premium experience"
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor.white.withAlphaComponent(0.65)
        l.numberOfLines = 1
        return l
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lumia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func setupUI_Lumia() {
        backgroundColor = UIColor.white.withAlphaComponent(0.5)
        layer.cornerRadius = 25
        layer.borderWidth = 2.5
        layer.borderColor = UIColor.white.cgColor
        layer.masksToBounds = true

        addSubview(selectCircle_Lumia)
        selectCircle_Lumia.addSubview(selectInnerDot_Lumia)

        // 文字纵向栈：第一行 + 第二行
        let textStack_Lumia = UIStackView(arrangedSubviews: [titleLabel_Lumia, subtitleLabel_Lumia])
        textStack_Lumia.axis = .vertical
        textStack_Lumia.spacing = 5
        textStack_Lumia.alignment = .leading
        addSubview(textStack_Lumia)

        selectCircle_Lumia.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(18)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        selectInnerDot_Lumia.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(12)
        }
        textStack_Lumia.snp.makeConstraints {
            $0.leading.equalTo(selectCircle_Lumia.snp.trailing).offset(14)
            $0.trailing.equalToSuperview().offset(-18)
            $0.centerY.equalToSuperview()
        }

        let tap_Lumia = UITapGestureRecognizer(target: self, action: #selector(handleTap_Lumia))
        addGestureRecognizer(tap_Lumia)
        isUserInteractionEnabled = true
    }

    // MARK: - 数据填充

    /// 注入套餐数据，第一行合并展示套餐名与价格
    /// - Parameter model: VIP 套餐模型
    func configure_Lumia(model: StoreModel_Lumia) {
        self.model_Lumia = model
        let name_Lumia  = model.goodsName_Lumia  ?? ""
        let price_Lumia = model.goodsPrice_Lumia ?? ""
        titleLabel_Lumia.text = "\(name_Lumia) / \(price_Lumia)"
    }

    // MARK: - 选中态切换

    /// 切换选中状态
    /// 选中：白色背景 + 主题色文字 + 主题色圆形指示器填充
    /// 未选中：50% 白色半透明背景 + 白色文字 + 白色空心指示器
    func setSelected_Lumia(_ selected: Bool) {
        // layer 属性不在 UIView.animate 中处理，需同步设置
        selectCircle_Lumia.layer.borderColor = selected
            ? UIColor(hexstring_Lumia: "#E55C45").cgColor
            : UIColor.white.cgColor

        UIView.animate(withDuration: 0.18) {
            if selected {
                self.backgroundColor                    = UIColor.white
                self.titleLabel_Lumia.textColor         = UIColor(hexstring_Lumia: "#E55C45")
                self.subtitleLabel_Lumia.textColor      = UIColor(hexstring_Lumia: "#E55C45").withAlphaComponent(0.6)
                self.selectInnerDot_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#E55C45")
                self.selectInnerDot_Lumia.isHidden      = false
            } else {
                self.backgroundColor                    = UIColor.white.withAlphaComponent(0.5)
                self.titleLabel_Lumia.textColor         = UIColor.white
                self.subtitleLabel_Lumia.textColor      = UIColor.white.withAlphaComponent(0.65)
                self.selectInnerDot_Lumia.backgroundColor = UIColor.white
                self.selectInnerDot_Lumia.isHidden      = true
            }
        }
    }

    // MARK: - 点击处理

    @objc private func handleTap_Lumia() {
        guard let model_Lumia = model_Lumia else { return }
        onTap_Lumia?(model_Lumia)
    }
}
