import Foundation
import UIKit
import SnapKit

// MARK: - VIP 订阅页面

/// VIP 订阅页面
/// 核心作用：展示 VIP 套餐列表，支持套餐选择、发起内购订阅及恢复购买
/// 设计思路：全屏暖橙-玫红渐变背景 + 顶部 vip_top 装饰图 + 套餐列表 + 底部操作区
/// 关键属性：
/// - vipItems_Pane: 从 Store_Pane 筛选出 goodIsVIP_Pane 为 true 的套餐数组
/// - selectedItem_Pane: 当前选中的 VIP 套餐（发起购买前校验）
/// - itemCells_Pane: 所有套餐 Cell，用于统一切换选中态
class VIPSubscription_Pane: UIViewController {

    // MARK: - 数据

    /// 所有 VIP 套餐
    private var vipItems_Pane: [StoreModel_Pane] = []
    /// 当前选中套餐
    private var selectedItem_Pane: StoreModel_Pane?
    /// 所有套餐 Cell 引用（统一更新选中态）
    private var itemCells_Pane: [VIPItemCell_Pane] = []

    // MARK: - UI · 背景渐变

    private var bgGradient_Pane: CAGradientLayer?

    // MARK: - UI · 自定义导航栏

    private let navBar_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let backButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_pane = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_pane)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "Subscription"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .white
        return l
    }()

    // MARK: - UI · 滚动容器

    private let scrollView_Pane: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Pane = UIView()

    // MARK: - UI · 组件1：顶部装饰图

    /// vip_top 装饰图（组件1），紧贴导航栏底部，左右内边距20，完整展示图片内容
    private let vipTopImage_Pane: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        return iv
    }()

    // MARK: - UI · 组件2：套餐列表

    /// VIP 套餐垂直容器（间距15）
    private let itemsStack_Pane: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 15
        sv.alignment = .fill
        return sv
    }()

    // MARK: - UI · 组件3：恢复购买

    private let restoreButton_Pane: UIButton = {
        let b = UIButton(type: .system)
        let attrs_pane: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.white
        ]
        let title_pane = NSAttributedString(string: "Restore Purchases", attributes: attrs_pane)
        b.setAttributedTitle(title_pane, for: .normal)
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - UI · 组件4：订阅按钮

    private let subscribeButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "vip_sub"), for: .normal)
        b.imageView?.contentMode = .scaleAspectFill
        b.clipsToBounds = true
        return b
    }()

    // MARK: - UI · 组件5：协议标签

    private var protocolLabel_Pane: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData_Pane()
        setupUI_Pane()
        buildItemCells_Pane()
        setupActions_Pane()
        // 默认选中第一项
        if let first_pane = vipItems_Pane.first {
            updateSelection_Pane(model: first_pane)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradient_Pane?.frame = view.bounds
    }

    // MARK: - 数据加载

    /// 从 Store_Pane 筛选 VIP 套餐
    private func loadData_Pane() {
        vipItems_Pane = Store_Pane.shared_Pane.goodsList_Pane.filter { $0.goodIsVIP_Pane == true }
    }

    // MARK: - UI 搭建

    private func setupUI_Pane() {
        setupBgGradient_Pane()

        view.addSubview(scrollView_Pane)
        scrollView_Pane.addSubview(contentView_Pane)

        // 组件1
        contentView_Pane.addSubview(vipTopImage_Pane)
        // 组件2
        contentView_Pane.addSubview(itemsStack_Pane)
        // 组件3
        contentView_Pane.addSubview(restoreButton_Pane)
        // 组件4
        contentView_Pane.addSubview(subscribeButton_Pane)

        // 组件5：协议标签（terms + eula，白色文字，适配渐变背景）
        let proto_pane = ProtocolHelper_Pane.createProtocolTextLabel_Pane(
            firstProtocol_Pane: .terms_Pane,
            firstContent_Pane: "terms",
            secondProtocol_Pane: .eula_Pane,
            secondContent_Pane: "eula",
            config_Pane: .dark_Pane(),
            from: self
        )
        contentView_Pane.addSubview(proto_pane)
        protocolLabel_Pane = proto_pane

        // 导航栏（最顶层）
        view.addSubview(navBar_Pane)
        navBar_Pane.addSubview(backButton_Pane)
        navBar_Pane.addSubview(navTitleLabel_Pane)

        setupConstraints_Pane(protoLabel: proto_pane)
    }

    /// 全屏渐变背景：#FF6630（顶）→ #FF0097（底）
    private func setupBgGradient_Pane() {
        let gl_pane = CAGradientLayer()
        gl_pane.colors = [
            UIColor(hexstring_Pane: "#FF6630").cgColor,
            UIColor(hexstring_Pane: "#FF0097").cgColor
        ]
        gl_pane.startPoint = CGPoint(x: 0.5, y: 0)
        gl_pane.endPoint   = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gl_pane, at: 0)
        bgGradient_Pane = gl_pane
    }

    // MARK: - 构建套餐 Cell

    /// 遍历 vipItems_Pane 生成 VIPItemCell_Pane 并加入 StackView
    private func buildItemCells_Pane() {
        itemCells_Pane.removeAll()
        vipItems_Pane.forEach { model_pane in
            let cell_pane = VIPItemCell_Pane()
            cell_pane.configure_Pane(model: model_pane)
            cell_pane.onTap_Pane = { [weak self] selected_pane in
                self?.updateSelection_Pane(model: selected_pane)
            }
            itemsStack_Pane.addArrangedSubview(cell_pane)
            cell_pane.snp.makeConstraints {
                $0.height.equalTo(84)
            }
            itemCells_Pane.append(cell_pane)
        }
    }

    // MARK: - 约束

    private func setupConstraints_Pane(protoLabel: UILabel) {
        let screenW_pane = UIScreen.main.bounds.width
        // 图片宽度 = 屏幕宽 - 左右各20内边距，高度按图片实际比例自适应（scaleAspectFit）
        let imgW_pane: CGFloat = screenW_pane - 40
        let img_pane = UIImage(named: "vip_top")
        let aspect_pane = img_pane.map { $0.size.height / $0.size.width } ?? 0.75
        let vipTopH_pane: CGFloat = imgW_pane * aspect_pane

        // 导航栏
        navBar_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Pane.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton_Pane)
        }

        // 滚动容器：顶部从导航栏底部开始，确保内容可正常滚动
        scrollView_Pane.snp.makeConstraints {
            $0.top.equalTo(navBar_Pane.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Pane.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // 组件1：vip_top，左右内边距20，高度按缩小比例展示完整图片
        vipTopImage_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(vipTopH_pane)
        }

        // 组件2：套餐列表，距 vip_top 下方 20
        itemsStack_Pane.snp.makeConstraints {
            $0.top.equalTo(vipTopImage_Pane.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        // 组件3：恢复购买，距套餐列表下方 15，居中
        restoreButton_Pane.snp.makeConstraints {
            $0.top.equalTo(itemsStack_Pane.snp.bottom).offset(15)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(22)
        }

        // 组件4：订阅按钮，距恢复购买下方 20，屏幕宽-32，高 62
        subscribeButton_Pane.snp.makeConstraints {
            $0.top.equalTo(restoreButton_Pane.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(62)
        }

        // 组件5：协议，距订阅按钮下方 15
        protoLabel.snp.makeConstraints {
            $0.top.equalTo(subscribeButton_Pane.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 选中状态更新

    /// 更新所有 Cell 的选中态，并记录当前选中套餐
    /// - Parameter model: 被选中的套餐模型
    private func updateSelection_Pane(model: StoreModel_Pane) {
        selectedItem_Pane = model
        itemCells_Pane.forEach { cell_pane in
            cell_pane.setSelected_Pane(cell_pane.model_Pane?.id_Pane == model.id_Pane)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Pane() {
        backButton_Pane.addTarget(self, action: #selector(backTapped_Pane), for: .touchUpInside)
        restoreButton_Pane.addTarget(self, action: #selector(restoreTapped_Pane), for: .touchUpInside)
        subscribeButton_Pane.addTarget(self, action: #selector(subscribeTapped_Pane), for: .touchUpInside)
    }

    @objc private func backTapped_Pane() {
        Navigation_Pane.pop_Pane(from: self)
    }

    /// 恢复购买按钮回调
    @objc private func restoreTapped_Pane() {
        Store_Pane.shared_Pane.RestorePurchase_Pane { [weak self] in
            guard let self_pane = self else { return }
            print("恢复购买成功，刷新 VIP 状态")
            _ = self_pane
        }
    }

    /// 订阅按钮回调：发起 VIP 内购
    @objc private func subscribeTapped_Pane() {
        guard let item_pane = selectedItem_Pane,
              let gid_pane  = item_pane.goodsId_Pane else {
            Utils_Pane.showWarning_Pane(message_Pane: "Please select a subscription plan.")
            return
        }
        subscribeButton_Pane.animatePressDown_Pane { self.subscribeButton_Pane.animatePressUp_Pane() }
        Store_Pane.shared_Pane.PurchaseStoreVIP_Pane(vipId_Pane: gid_pane) { [weak self] in
            guard let self_pane = self else { return }
            print("VIP 订阅成功，关闭页面")
            Navigation_Pane.pop_Pane(from: self_pane)
        }
    }
}

// MARK: - VIPItemCell_Pane

/// VIP 套餐单元格视图
/// 核心作用：展示单个 VIP 套餐信息（选中圆圈 + 套餐名 + 副标题），支持点击回调
/// 关键方法：
/// - configure_Pane: 注入套餐数据
/// - setSelected_Pane: 切换选中态（圆圈空心/填充）
private class VIPItemCell_Pane: UIView {

    // MARK: - 属性

    /// 当前套餐数据（外部只读，内部赋值）
    private(set) var model_Pane: StoreModel_Pane?

    /// 点击回调，回传选中的套餐模型
    var onTap_Pane: ((StoreModel_Pane) -> Void)?

    // MARK: - UI

    /// 外圈：白色圆环27×27
    private let outerCircle_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.cornerRadius = 13.5
        v.layer.borderWidth  = 1.5
        v.layer.borderColor  = UIColor.white.cgColor
        return v
    }()

    /// 内圆：选中时可见的白色填充（尺寸 = 27 - 2×2 = 23）
    private let innerCircle_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 11.5
        v.isHidden = true
        return v
    }()

    /// 套餐名称（20pt 加粗，白色）
    private let nameLabel_Pane: UILabel = {
        let l = UILabel()
        l.font      = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = .white
        return l
    }()

    /// 副标题（固定文本，14pt 常规，白色 70%）
    private let descLabel_Pane: UILabel = {
        let l = UILabel()
        l.text      = "Premium experience"
        l.font      = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor.white.withAlphaComponent(0.7)
        return l
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Pane()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func setupUI_Pane() {
        backgroundColor = UIColor.white.withAlphaComponent(0.7)
        layer.cornerRadius = 20

        // 圆圈区域
        addSubview(outerCircle_Pane)
        outerCircle_Pane.addSubview(innerCircle_Pane)

        // 文字纵向堆叠
        let textStack_pane = UIStackView(arrangedSubviews: [nameLabel_Pane, descLabel_Pane])
        textStack_pane.axis      = .vertical
        textStack_pane.spacing   = 4
        textStack_pane.alignment = .leading
        addSubview(textStack_pane)

        // 约束
        outerCircle_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(18)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(27)
        }
        innerCircle_Pane.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(23)
        }
        textStack_pane.snp.makeConstraints {
            $0.leading.equalTo(outerCircle_Pane.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }

        // 点击手势
        let tap_pane = UITapGestureRecognizer(target: self, action: #selector(handleTap_Pane))
        addGestureRecognizer(tap_pane)
        isUserInteractionEnabled = true
    }

    // MARK: - 数据填充

    /// 注入套餐数据
    /// - Parameter model: VIP 套餐模型
    func configure_Pane(model: StoreModel_Pane) {
        self.model_Pane    = model
        nameLabel_Pane.text = model.goodsName_Pane
    }

    // MARK: - 选中态切换

    /// 切换圆圈选中状态
    /// - Parameter selected: true 时显示内圆（填充态），false 时隐藏（空心态）
    func setSelected_Pane(_ selected: Bool) {
        innerCircle_Pane.isHidden = !selected
    }

    // MARK: - 点击处理

    @objc private func handleTap_Pane() {
        guard let model_pane = model_Pane else { return }
        onTap_Pane?(model_pane)
    }
}
