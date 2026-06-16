import Foundation
import UIKit
import SnapKit

// MARK: - VIP 订阅页面

/// VIP 订阅页面
/// 核心作用：展示 VIP 套餐列表，支持套餐选择、发起内购订阅及恢复购买
/// 设计思路：顶部 vip_top_bg 背景图 + 纯色 #C197FC 填充其余区域 + 顶部 vip_top 装饰图
///          + 纵向套餐列表 + 恢复按钮（列表与订阅按钮之间）+ 订阅按钮 + 协议标签
/// 关键属性：
/// - vipItems_Niche: 从 Store_Niche 筛选出 goodIsVIP_Niche 为 true 的套餐数组
/// - selectedItem_Niche: 当前选中的 VIP 套餐（发起购买前校验）
/// - itemCells_Niche: 所有套餐 Cell，用于统一切换选中态
class VIPSubscription_Niche: UIViewController {

    // MARK: - 数据

    /// 所有 VIP 套餐
    private var vipItems_Niche: [StoreModel_Niche] = []
    /// 当前选中套餐
    private var selectedItem_Niche: StoreModel_Niche?
    /// 所有套餐 Cell 引用（统一更新选中态）
    private var itemCells_Niche: [VIPItemCell_Niche] = []

    // MARK: - UI · 顶部背景图

    /// vip_top_bg 顶部背景图，覆盖页面顶部区域，其余区域由 view.backgroundColor 纯色填充
    private let topBgImage_Niche: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top_bg")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    // MARK: - UI · 自定义导航栏

    private let navBar_Niche: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let backButton_Niche: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Niche = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Niche)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        return b
    }()

    /// 页面标题，靠左紧贴返回按钮，不居中，字体 18 regular 白色
    private let navTitleLabel_Niche: UILabel = {
        let l = UILabel()
        l.text = "Membership Subscription"
        l.font = .systemFont(ofSize: 18, weight: .regular)
        l.textColor = .white
        return l
    }()

    // MARK: - UI · 滚动容器

    private let scrollView_Niche: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        sv.backgroundColor = .clear
        return sv
    }()

    private let contentView_Niche: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    // MARK: - UI · 组件1：顶部装饰图

    /// vip_top 装饰图（组件1），紧贴导航栏底部，左右内边距 20，按比例完整展示
    private let vipTopImage_Niche: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        return iv
    }()

    // MARK: - UI · 组件2：套餐纵向列表

    /// 套餐纵向 StackView，间距 12
    private let itemsVStack_Niche: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()

    // MARK: - UI · 组件3：恢复购买（位于套餐列表与订阅按钮之间）

    /// 恢复购买按钮，字体 14 medium，颜色 #010101，带下划线，上间距 18，下间距 32
    private let restoreButton_Niche: UIButton = {
        let b = UIButton(type: .system)
        let attrs_Niche: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor(hexstring_Niche: "#010101"),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor(hexstring_Niche: "#010101")
        ]
        let title_Niche = NSAttributedString(string: "Restore Purchases", attributes: attrs_Niche)
        b.setAttributedTitle(title_Niche, for: .normal)
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - UI · 组件4：订阅按钮

    private let subscribeButton_Niche: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "vip_sub"), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.clipsToBounds = true
        return b
    }()

    // MARK: - UI · 组件5：协议标签

    private var protocolLabel_Niche: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData_Niche()
        setupUI_Niche()
        buildItemCells_Niche()
        setupActions_Niche()
        // 默认选中第一项
        if let first_Niche = vipItems_Niche.first {
            updateSelection_Niche(model: first_Niche)
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

    // MARK: - 数据加载

    /// 从 Store_Niche 筛选 VIP 套餐
    private func loadData_Niche() {
        vipItems_Niche = Store_Niche.shared_Niche.goodsList_Niche.filter { $0.goodIsVIP_Niche == true }
    }

    // MARK: - UI 搭建

    private func setupUI_Niche() {
        // 整体背景纯色 #C197FC，顶部叠加 vip_top_bg 图片
        view.backgroundColor = UIColor(hexstring_Niche: "#C197FC")

        // 顶部背景图插入最底层（index 0），scrollView 背景透明，背景图可透出
        view.insertSubview(topBgImage_Niche, at: 0)
        view.addSubview(scrollView_Niche)
        scrollView_Niche.addSubview(contentView_Niche)

        // 组件1：顶部装饰图
        contentView_Niche.addSubview(vipTopImage_Niche)
        // 组件2：纵向套餐列表
        contentView_Niche.addSubview(itemsVStack_Niche)
        // 组件3：恢复购买（列表与订阅按钮之间）
        contentView_Niche.addSubview(restoreButton_Niche)
        // 组件4：订阅按钮
        contentView_Niche.addSubview(subscribeButton_Niche)

        // 组件5：协议标签（terms + eula）
        let proto_Niche = ProtocolHelper_Niche.createProtocolTextLabel_Niche(
            firstProtocol_Niche: .terms_Niche,
            firstContent_Niche: "terms.png",
            secondProtocol_Niche: .eula_Niche,
            secondContent_Niche: "eula.png",
            config_Niche: ProtocolHelper_Niche.ProtocolTextConfig_Niche(
                textColor_Niche: UIColor(hexstring_Niche: "#111111"),
                linkColor_Niche: UIColor(hexstring_Niche: "#111111"),
                fontSize_Niche: 13,
                fontWeight_Niche: .regular,
                hasUnderline_Niche: true
            ),
            from: self
        )
        contentView_Niche.addSubview(proto_Niche)
        protocolLabel_Niche = proto_Niche

        // 导航栏（最顶层）
        view.addSubview(navBar_Niche)
        navBar_Niche.addSubview(backButton_Niche)
        navBar_Niche.addSubview(navTitleLabel_Niche)

        setupConstraints_Niche(protoLabel: proto_Niche)
    }

    // MARK: - 构建套餐 Cell

    /// 遍历 vipItems_Niche 生成 VIPItemCell_Niche 并加入纵向列表
    private func buildItemCells_Niche() {
        itemCells_Niche.removeAll()
        vipItems_Niche.forEach { model_Niche in
            let cell_Niche = VIPItemCell_Niche()
            cell_Niche.configure_Niche(model: model_Niche)
            cell_Niche.onTap_Niche = { [weak self] selected_Niche in
                self?.updateSelection_Niche(model: selected_Niche)
            }
            itemsVStack_Niche.addArrangedSubview(cell_Niche)
            cell_Niche.snp.makeConstraints {
                $0.height.equalTo(83)
            }
            itemCells_Niche.append(cell_Niche)
        }
    }

    // MARK: - 约束

    /// 布局所有子视图约束
    /// - Parameter protoLabel: 协议标签，需要在约束中引用其位置
    private func setupConstraints_Niche(protoLabel: UILabel) {
        let screenW_Niche = UIScreen.main.bounds.width

        // 顶部背景图：全宽，从 view 顶部开始，高度按图片真实比例自适应
        let topBgImg_Niche = UIImage(named: "vip_top_bg")
        let topBgAspect_Niche = topBgImg_Niche.map { $0.size.height / $0.size.width } ?? 0.6
        let topBgH_Niche: CGFloat = screenW_Niche * topBgAspect_Niche
        topBgImage_Niche.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(topBgH_Niche)
        }

        // 导航栏
        navBar_Niche.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Niche.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        // 标题靠近返回按钮右侧，间距 10，竖向对齐
        navTitleLabel_Niche.snp.makeConstraints {
            $0.leading.equalTo(backButton_Niche.snp.trailing).offset(10)
            $0.centerY.equalTo(backButton_Niche)
        }

        // 滚动容器：从导航栏底部开始，背景透明使顶部背景图透出
        scrollView_Niche.snp.makeConstraints {
            $0.top.equalTo(navBar_Niche.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Niche.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // 组件1：vip_top，左右内边距 20，高度按比例完整展示
        let imgW_Niche: CGFloat = screenW_Niche - 40
        let img_Niche = UIImage(named: "vip_top")
        let aspect_Niche = img_Niche.map { $0.size.height / $0.size.width } ?? 0.75
        let vipTopH_Niche: CGFloat = imgW_Niche * aspect_Niche
        vipTopImage_Niche.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(vipTopH_Niche)
        }

        // 组件2：纵向套餐列表，距 vip_top 下方 20，左右内边距 16
        itemsVStack_Niche.snp.makeConstraints {
            $0.top.equalTo(vipTopImage_Niche.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        // 组件3：恢复购买，距套餐列表下方 18
        restoreButton_Niche.snp.makeConstraints {
            $0.top.equalTo(itemsVStack_Niche.snp.bottom).offset(18)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(22)
        }

        // 组件4：订阅按钮，距恢复购买下方 32，左右内边距 16，高度 62
        subscribeButton_Niche.snp.makeConstraints {
            $0.top.equalTo(restoreButton_Niche.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(62)
        }

        // 组件5：协议，距订阅按钮下方 15
        protoLabel.snp.makeConstraints {
            $0.top.equalTo(subscribeButton_Niche.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 选中状态更新

    /// 更新所有 Cell 的选中态，并记录当前选中套餐
    /// - Parameter model: 被选中的套餐模型
    private func updateSelection_Niche(model: StoreModel_Niche) {
        selectedItem_Niche = model
        itemCells_Niche.forEach { cell_Niche in
            cell_Niche.setSelected_Niche(cell_Niche.model_Niche?.id_Niche == model.id_Niche)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Niche() {
        backButton_Niche.addTarget(self, action: #selector(backTapped_Niche), for: .touchUpInside)
        restoreButton_Niche.addTarget(self, action: #selector(restoreTapped_Niche), for: .touchUpInside)
        subscribeButton_Niche.addTarget(self, action: #selector(subscribeTapped_Niche), for: .touchUpInside)
    }

    @objc private func backTapped_Niche() {
        Navigation_Niche.pop_Niche(from: self)
    }

    /// 恢复购买按钮回调
    @objc private func restoreTapped_Niche() {
        Store_Niche.shared_Niche.RestorePurchase_Niche { [weak self] in
            guard let self_Niche = self else { return }
            _ = self_Niche
        }
    }

    /// 订阅按钮回调：发起 VIP 内购
    @objc private func subscribeTapped_Niche() {
        guard let item_Niche = selectedItem_Niche,
              let gid_Niche  = item_Niche.goodsId_Niche else {
            Utils_Niche.showWarning_Niche(message_Niche: "Please select a subscription plan.")
            return
        }
        subscribeButton_Niche.animatePressDown_Niche { self.subscribeButton_Niche.animatePressUp_Niche() }
        Store_Niche.shared_Niche.PurchaseStoreVIP_Niche(vipId_Niche: gid_Niche) { [weak self] in
            guard let self_Niche = self else { return }
            Navigation_Niche.pop_Niche(from: self_Niche)
        }
    }
}

// MARK: - VIPItemCell_Niche

/// VIP 套餐单元格视图
/// 核心作用：展示单个 VIP 套餐信息（左侧选中圆圈 + 右侧文本两行），支持点击回调
/// 设计思路：高度 83、圆角 25 的卡片
///          左侧 leading=24 处放置 27×27 选中圆圈；文本区域左对齐，距圆圈右边 24
///          未选中：背景 #F1ECFF，圆圈空心（边框 #010101），字体 #010101
///          选中：2.5 白色边框，背景 #FFFFFF 60% 透明，圆圈实心白色，字体白色
/// 关键方法：
/// - configure_Niche: 注入套餐数据（组合 goodsName + "/" + goodsPrice 为主文本）
/// - setSelected_Niche: 切换选中态（圆圈 + 边框 + 背景 + 字体颜色同步变化）
private class VIPItemCell_Niche: UIView {

    // MARK: - 属性

    /// 当前套餐数据（外部只读，内部赋值）
    private(set) var model_Niche: StoreModel_Niche?

    /// 点击回调，回传选中的套餐模型
    var onTap_Niche: ((StoreModel_Niche) -> Void)?

    // MARK: - UI

    /// 选中状态圆圈外环（27×27）
    /// 选中：白色边框 + 内部白色实心圆（间隙由背景色透出），未选中：#010101 空心边框
    private let selectCircle_Niche: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 13.5
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor(hexstring_Niche: "#010101").cgColor
        v.backgroundColor = .clear
        return v
    }()

    /// 选中圆圈内部实心白点（仅选中时显示）
    private let selectInnerDot_Niche: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 6.5
        v.backgroundColor = .white
        v.isHidden = true
        return v
    }()

    /// 主文本：goodsName + "/" + goodsPrice，字体 18 加粗，左对齐
    private let mainLabel_Niche: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = UIColor(hexstring_Niche: "#010101")
        l.textAlignment = .left
        return l
    }()

    /// 副标题：固定文本 "Premium experience"，字体透明度 70%，左对齐
    private let subLabel_Niche: UILabel = {
        let l = UILabel()
        l.text = "Premium experience"
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor(hexstring_Niche: "#010101").withAlphaComponent(0.7)
        l.textAlignment = .left
        return l
    }()

    /// 主副标题垂直容器，spacing 5，左对齐
    private let contentVStack_Niche: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 5
        sv.alignment = .leading
        sv.distribution = .fill
        return sv
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Niche()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func setupUI_Niche() {
        backgroundColor = UIColor(hexstring_Niche: "#F1ECFF")
        layer.cornerRadius = 25
        layer.masksToBounds = true
        layer.borderWidth = 0
        layer.borderColor = UIColor.clear.cgColor

        addSubview(selectCircle_Niche)
        // 内部实心圆点居中于外环
        selectCircle_Niche.addSubview(selectInnerDot_Niche)
        selectInnerDot_Niche.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(13)
        }

        contentVStack_Niche.addArrangedSubview(mainLabel_Niche)
        contentVStack_Niche.addArrangedSubview(subLabel_Niche)
        addSubview(contentVStack_Niche)

        // 选中圆圈：左边距 24，垂直居中，固定 27×27
        selectCircle_Niche.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(27)
        }

        // 文本区域：紧接圆圈右侧间距 24，垂直居中，右边距 16
        contentVStack_Niche.snp.makeConstraints {
            $0.leading.equalTo(selectCircle_Niche.snp.trailing).offset(24)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }

        // 点击手势
        let tap_Niche = UITapGestureRecognizer(target: self, action: #selector(handleTap_Niche))
        addGestureRecognizer(tap_Niche)
        isUserInteractionEnabled = true
    }

    // MARK: - 数据填充

    /// 注入套餐数据，组合 goodsName + "/" + goodsPrice 为主显示文本
    /// - Parameter model: VIP 套餐模型
    func configure_Niche(model: StoreModel_Niche) {
        self.model_Niche = model
        let name_Niche = model.goodsName_Niche ?? ""
        let price_Niche = model.goodsPrice_Niche ?? ""
        mainLabel_Niche.text = "\(name_Niche)/\(price_Niche)"
    }

    // MARK: - 选中态切换

    /// 切换选中状态
    /// 选中：2.5 白色边框，背景 #FFFFFF 60% 透明，圆圈实心白色，主副标题颜色白色
    /// 未选中：无边框，背景 #F1ECFF，圆圈空心（#010101 边框），主副标题颜色 #010101
    /// - Parameter selected: true 为选中态，false 为未选中态
    func setSelected_Niche(_ selected: Bool) {
        if selected {
            backgroundColor = UIColor.white.withAlphaComponent(0.6)
            layer.borderWidth = 2.5
            layer.borderColor = UIColor.white.cgColor
            // 外环：白色边框，背景透明（卡片背景透出形成间隙）
            selectCircle_Niche.backgroundColor = .clear
            selectCircle_Niche.layer.borderWidth = 2
            selectCircle_Niche.layer.borderColor = UIColor.white.cgColor
            // 内部实心白点显示
            selectInnerDot_Niche.isHidden = false
            mainLabel_Niche.textColor = .white
            subLabel_Niche.textColor = UIColor.white.withAlphaComponent(0.7)
        } else {
            backgroundColor = UIColor(hexstring_Niche: "#F1ECFF")
            layer.borderWidth = 0
            layer.borderColor = UIColor.clear.cgColor
            // 外环：#010101 空心边框，内部实心点隐藏
            selectCircle_Niche.backgroundColor = .clear
            selectCircle_Niche.layer.borderWidth = 2
            selectCircle_Niche.layer.borderColor = UIColor(hexstring_Niche: "#010101").cgColor
            selectInnerDot_Niche.isHidden = true
            mainLabel_Niche.textColor = UIColor(hexstring_Niche: "#010101")
            subLabel_Niche.textColor = UIColor(hexstring_Niche: "#010101").withAlphaComponent(0.7)
        }
    }

    // MARK: - 点击处理

    @objc private func handleTap_Niche() {
        guard let model_Niche = model_Niche else { return }
        onTap_Niche?(model_Niche)
    }
}
