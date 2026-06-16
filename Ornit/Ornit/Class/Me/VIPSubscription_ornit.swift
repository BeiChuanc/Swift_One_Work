import Foundation
import UIKit
import SnapKit

// MARK: - VIP 订阅页面

/// VIP 订阅页面
/// 核心作用：展示 VIP 套餐列表，支持套餐选择、发起内购订阅及恢复购买
/// 设计思路：顶部 vip_top_bg 背景图 + 纯色 #C197FC 填充其余区域 + 顶部 vip_top 装饰图
///          + 纵向套餐列表 + 恢复按钮（列表与订阅按钮之间）+ 订阅按钮 + 协议标签
/// 关键属性：
/// - vipItems_Ornit: 从 Store_Ornit 筛选出 goodIsVIP_Ornit 为 true 的套餐数组
/// - selectedItem_Ornit: 当前选中的 VIP 套餐（发起购买前校验）
/// - itemCells_Ornit: 所有套餐 Cell，用于统一切换选中态
class VIPSubscription_Ornit: UIViewController {

    // MARK: - 数据

    /// 所有 VIP 套餐
    private var vipItems_Ornit: [StoreModel_Ornit] = []
    /// 当前选中套餐
    private var selectedItem_Ornit: StoreModel_Ornit?
    /// 所有套餐 Cell 引用（统一更新选中态）
    private var itemCells_Ornit: [VIPItemCell_Ornit] = []

    // MARK: - UI · 顶部背景图

    /// vip_top_bg 顶部背景图，覆盖页面顶部区域，其余区域由 view.backgroundColor 纯色填充
    private let topBgImage_Ornit: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top_bg")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    // MARK: - UI · 自定义导航栏

    private let navBar_Ornit: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let backButton_Ornit: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Ornit = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Ornit)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .black
        b.backgroundColor = UIColor.black.withAlphaComponent(0.08)
        b.layer.cornerRadius = 18
        return b
    }()

    /// 页面标题，靠左紧贴返回按钮，不居中，字体 18 regular 黑色
    private let navTitleLabel_Ornit: UILabel = {
        let l = UILabel()
        l.text = "Membership Subscription"
        l.font = .systemFont(ofSize: 18, weight: .regular)
        l.textColor = .black
        return l
    }()

    // MARK: - UI · 滚动容器

    private let scrollView_Ornit: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        sv.backgroundColor = .clear
        return sv
    }()

    private let contentView_Ornit: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    // MARK: - UI · 组件1：顶部装饰图

    /// vip_top 装饰图（组件1），紧贴导航栏底部，左右内边距 20，按比例完整展示
    private let vipTopImage_Ornit: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        return iv
    }()

    // MARK: - UI · 组件2：套餐纵向列表

    /// 套餐纵向 StackView，间距 12
    private let itemsVStack_Ornit: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()

    // MARK: - UI · 组件3：恢复购买（位于套餐列表与订阅按钮之间）

    /// 恢复购买按钮，字体 14 medium，颜色 #010101，带下划线，上间距 18，下间距 32
    private let restoreButton_Ornit: UIButton = {
        let b = UIButton(type: .system)
        let attrs_Ornit: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor(hexstring_Ornit: "#010101"),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor(hexstring_Ornit: "#010101")
        ]
        let title_Ornit = NSAttributedString(string: "Restore Purchases", attributes: attrs_Ornit)
        b.setAttributedTitle(title_Ornit, for: .normal)
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - UI · 组件4：订阅按钮

    private let subscribeButton_Ornit: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "vip_sub"), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.clipsToBounds = true
        return b
    }()

    // MARK: - UI · 组件5：协议标签

    private var protocolLabel_Ornit: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData_Ornit()
        setupUI_Ornit()
        buildItemCells_Ornit()
        setupActions_Ornit()
        // 默认选中第一项
        if let first_Ornit = vipItems_Ornit.first {
            updateSelection_Ornit(model: first_Ornit)
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

    /// 从 Store_Ornit 筛选 VIP 套餐
    private func loadData_Ornit() {
        vipItems_Ornit = Subscribe_Ornit.shared_Ornit.goodsList_Ornit.filter { $0.goodIsVIP_Ornit == true }
    }

    // MARK: - UI 搭建

    private func setupUI_Ornit() {
        // 整体背景改为 vip_bg 图片铺满，删除原纯色背景
        view.backgroundColor = .clear

        // vip_bg 全屏背景图（index 0，最底层）
        let bgImageView_Ornit = UIImageView()
        bgImageView_Ornit.image = UIImage(named: "vip_bg")?.withRenderingMode(.alwaysOriginal)
        bgImageView_Ornit.contentMode = .scaleAspectFill
        bgImageView_Ornit.clipsToBounds = true
        view.insertSubview(bgImageView_Ornit, at: 0)
        bgImageView_Ornit.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 顶部背景图插入 vip_bg 之上（index 1），scrollView 背景透明，背景图可透出
        view.insertSubview(topBgImage_Ornit, at: 1)
        view.addSubview(scrollView_Ornit)
        scrollView_Ornit.addSubview(contentView_Ornit)

        // 组件1：顶部装饰图
        contentView_Ornit.addSubview(vipTopImage_Ornit)
        // 组件2：纵向套餐列表
        contentView_Ornit.addSubview(itemsVStack_Ornit)
        // 组件3：恢复购买（列表与订阅按钮之间）
        contentView_Ornit.addSubview(restoreButton_Ornit)
        // 组件4：订阅按钮
        contentView_Ornit.addSubview(subscribeButton_Ornit)

        // 组件5：协议标签（terms + eula）
        let proto_Ornit = ProtocolHelper_Ornit.createProtocolTextLabel_Ornit(
            firstProtocol_Ornit: .terms_Ornit,
            firstContent_Ornit: "terms.png",
            secondProtocol_Ornit: .eula_Ornit,
            secondContent_Ornit: "eula.png",
            config_Ornit: ProtocolHelper_Ornit.ProtocolTextConfig_Ornit(
                textColor_Ornit: UIColor(hexstring_Ornit: "#111111"),
                linkColor_Ornit: UIColor(hexstring_Ornit: "#111111"),
                fontSize_Ornit: 13,
                fontWeight_Ornit: .regular,
                hasUnderline_Ornit: true
            ),
            from: self
        )
        contentView_Ornit.addSubview(proto_Ornit)
        protocolLabel_Ornit = proto_Ornit

        // 导航栏（最顶层）
        view.addSubview(navBar_Ornit)
        navBar_Ornit.addSubview(backButton_Ornit)
        navBar_Ornit.addSubview(navTitleLabel_Ornit)

        setupConstraints_Ornit(protoLabel: proto_Ornit)
    }

    // MARK: - 构建套餐 Cell

    /// 遍历 vipItems_Ornit 生成 VIPItemCell_Ornit 并加入纵向列表
    private func buildItemCells_Ornit() {
        itemCells_Ornit.removeAll()
        vipItems_Ornit.forEach { model_Ornit in
            let cell_Ornit = VIPItemCell_Ornit()
            cell_Ornit.configure_Ornit(model: model_Ornit)
            cell_Ornit.onTap_Ornit = { [weak self] selected_Ornit in
                self?.updateSelection_Ornit(model: selected_Ornit)
            }
            itemsVStack_Ornit.addArrangedSubview(cell_Ornit)
            cell_Ornit.snp.makeConstraints {
                $0.height.equalTo(83)
            }
            itemCells_Ornit.append(cell_Ornit)
        }
    }

    // MARK: - 约束

    /// 布局所有子视图约束
    /// - Parameter protoLabel: 协议标签，需要在约束中引用其位置
    private func setupConstraints_Ornit(protoLabel: UILabel) {
        let screenW_Ornit = UIScreen.main.bounds.width

        // 顶部背景图：全宽，从 view 顶部开始，高度按图片真实比例自适应
        let topBgImg_Ornit = UIImage(named: "vip_top_bg")
        let topBgAspect_Ornit = topBgImg_Ornit.map { $0.size.height / $0.size.width } ?? 0.6
        let topBgH_Ornit: CGFloat = screenW_Ornit * topBgAspect_Ornit
        topBgImage_Ornit.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(topBgH_Ornit)
        }

        // 导航栏
        navBar_Ornit.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Ornit.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        // 标题靠近返回按钮右侧，间距 10，竖向对齐
        navTitleLabel_Ornit.snp.makeConstraints {
            $0.leading.equalTo(backButton_Ornit.snp.trailing).offset(10)
            $0.centerY.equalTo(backButton_Ornit)
        }

        // 滚动容器：从导航栏底部开始，背景透明使顶部背景图透出
        scrollView_Ornit.snp.makeConstraints {
            $0.top.equalTo(navBar_Ornit.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Ornit.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // 组件1：vip_top，左右内边距 20，高度按比例完整展示
        let imgW_Ornit: CGFloat = screenW_Ornit - 40
        let img_Ornit = UIImage(named: "vip_top")
        let aspect_Ornit = img_Ornit.map { $0.size.height / $0.size.width } ?? 0.75
        let vipTopH_Ornit: CGFloat = imgW_Ornit * aspect_Ornit
        vipTopImage_Ornit.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(vipTopH_Ornit)
        }

        // 组件2：纵向套餐列表，距 vip_top 下方 20，左右内边距 16
        itemsVStack_Ornit.snp.makeConstraints {
            $0.top.equalTo(vipTopImage_Ornit.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        // 组件3：恢复购买，距套餐列表下方 18
        restoreButton_Ornit.snp.makeConstraints {
            $0.top.equalTo(itemsVStack_Ornit.snp.bottom).offset(18)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(22)
        }

        // 组件4：订阅按钮，距恢复购买下方 32，左右内边距 16，高度 62
        subscribeButton_Ornit.snp.makeConstraints {
            $0.top.equalTo(restoreButton_Ornit.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(62)
        }

        // 组件5：协议，距订阅按钮下方 15
        protoLabel.snp.makeConstraints {
            $0.top.equalTo(subscribeButton_Ornit.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 选中状态更新

    /// 更新所有 Cell 的选中态，并记录当前选中套餐
    /// - Parameter model: 被选中的套餐模型
    private func updateSelection_Ornit(model: StoreModel_Ornit) {
        selectedItem_Ornit = model
        itemCells_Ornit.forEach { cell_Ornit in
            cell_Ornit.setSelected_Ornit(cell_Ornit.model_Ornit?.id_Ornit == model.id_Ornit)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Ornit() {
        backButton_Ornit.addTarget(self, action: #selector(backTapped_Ornit), for: .touchUpInside)
        restoreButton_Ornit.addTarget(self, action: #selector(restoreTapped_Ornit), for: .touchUpInside)
        subscribeButton_Ornit.addTarget(self, action: #selector(subscribeTapped_Ornit), for: .touchUpInside)
    }

    @objc private func backTapped_Ornit() {
        Navigation_Ornit.pop_Ornit(from: self)
    }

    /// 恢复购买按钮回调
    @objc private func restoreTapped_Ornit() {
        Subscribe_Ornit.shared_Ornit.RestorePurchase_Ornit { [weak self] in
            guard let self_Ornit = self else { return }
            _ = self_Ornit
        }
    }

    /// 订阅按钮回调：发起 VIP 内购
    @objc private func subscribeTapped_Ornit() {
        guard let item_Ornit = selectedItem_Ornit,
              let gid_Ornit  = item_Ornit.goodsId_Ornit else {
            Utils_Ornit.showWarning_Ornit(message_Ornit: "Please select a subscription plan.")
            return
        }
        subscribeButton_Ornit.animatePressDown_Ornit { self.subscribeButton_Ornit.animatePressUp_Ornit() }
        Subscribe_Ornit.shared_Ornit.PurchaseStoreVIP_Ornit(vipId_Ornit: gid_Ornit) { [weak self] in
            guard let self_Ornit = self else { return }
            Navigation_Ornit.pop_Ornit(from: self_Ornit)
        }
    }
}

// MARK: - VIPItemCell_Ornit

/// VIP 套餐单元格视图
/// 核心作用：展示单个 VIP 套餐信息（左侧选中圆圈 + 右侧文本两行），支持点击回调
/// 设计思路：高度 83、圆角 25 的毛玻璃卡片
///          左侧 leading=24 处放置 27×27 选中圆圈；文本区域左对齐，距圆圈右边 24
///          未选中：毛玻璃白色效果，圆圈空心（黑色边框），文字黑色，无外框
///          选中：毛玻璃效果不变，外层加黑色边框，圆圈变为黑色实心，文字始终黑色
/// 关键方法：
/// - configure_Ornit: 注入套餐数据
/// - setSelected_Ornit: 切换选中态（圆圈实心 + 外框，文字颜色不变）
private class VIPItemCell_Ornit: UIView {

    // MARK: - 属性

    private(set) var model_Ornit: StoreModel_Ornit?
    var onTap_Ornit: ((StoreModel_Ornit) -> Void)?

    // MARK: - UI

    /// 选中状态圆圈外环（27×27），始终黑色边框
    private let selectCircle_Ornit: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 13.5
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.black.cgColor
        v.backgroundColor = .clear
        return v
    }()

    /// 选中圆圈内部实心黑点（仅选中时显示）
    private let selectInnerDot_Ornit: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 6.5
        v.backgroundColor = .black
        v.isHidden = true
        return v
    }()

    /// 主文本：goodsName + "/" + goodsPrice，字体 18 加粗，黑色（固定）
    private let mainLabel_Ornit: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .black
        l.textAlignment = .left
        return l
    }()

    /// 副标题：固定文本 "Premium experience"，70% 黑色（固定）
    private let subLabel_Ornit: UILabel = {
        let l = UILabel()
        l.text = "Premium experience"
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor.black.withAlphaComponent(0.7)
        l.textAlignment = .left
        return l
    }()

    private let contentVStack_Ornit: UIStackView = {
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
        setupUI_Ornit()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func setupUI_Ornit() {
        // 卡片自身透明，毛玻璃视图铺满作为背景
        backgroundColor = .clear
        layer.cornerRadius = 25
        layer.masksToBounds = true
        layer.borderWidth = 0
        layer.borderColor = UIColor.clear.cgColor

        // 毛玻璃底层（light 效果，白色磨砂感）
        let blurView_Ornit = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        insertSubview(blurView_Ornit, at: 0)
        blurView_Ornit.snp.makeConstraints { $0.edges.equalToSuperview() }

        addSubview(selectCircle_Ornit)
        selectCircle_Ornit.addSubview(selectInnerDot_Ornit)
        selectInnerDot_Ornit.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(13)
        }

        contentVStack_Ornit.addArrangedSubview(mainLabel_Ornit)
        contentVStack_Ornit.addArrangedSubview(subLabel_Ornit)
        addSubview(contentVStack_Ornit)

        selectCircle_Ornit.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(27)
        }

        contentVStack_Ornit.snp.makeConstraints {
            $0.leading.equalTo(selectCircle_Ornit.snp.trailing).offset(24)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }

        let tap_Ornit = UITapGestureRecognizer(target: self, action: #selector(handleTap_Ornit))
        addGestureRecognizer(tap_Ornit)
        isUserInteractionEnabled = true
    }

    // MARK: - 数据填充

    func configure_Ornit(model: StoreModel_Ornit) {
        self.model_Ornit = model
        let name_Ornit = model.goodsName_Ornit ?? ""
        let price_Ornit = model.goodsPrice_Ornit ?? ""
        mainLabel_Ornit.text = "\(name_Ornit)/\(price_Ornit)"
    }

    // MARK: - 选中态切换

    /// 切换选中状态
    /// 选中：加黑色外边框 + 圆圈内部黑色实心点
    /// 未选中：移除外边框 + 隐藏内部实心点
    /// 文字颜色始终为黑色，不随选中状态改变
    /// - Parameter selected: true 为选中态，false 为未选中态
    func setSelected_Ornit(_ selected: Bool) {
        if selected {
            layer.borderWidth = 2.5
            layer.borderColor = UIColor.black.cgColor
            selectInnerDot_Ornit.isHidden = false
        } else {
            layer.borderWidth = 0
            layer.borderColor = UIColor.clear.cgColor
            selectInnerDot_Ornit.isHidden = true
        }
        // 文字颜色固定，不受选中态影响
    }

    @objc private func handleTap_Ornit() {
        guard let model_Ornit = model_Ornit else { return }
        onTap_Ornit?(model_Ornit)
    }
}
