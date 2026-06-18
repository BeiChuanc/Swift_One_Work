import Foundation
import UIKit
import SnapKit

// MARK: - VIP 订阅页面

/// VIP 订阅页面
/// 核心作用：展示 VIP 套餐列表，支持套餐选择、发起内购订阅及恢复购买
/// 设计思路：全屏青紫渐变背景（左上 #00FFF0 → 右下 #A678F1）+ 顶部 vip_top 装饰图 + 纵向套餐列表 + 底部操作区
/// 关键属性：
/// - vipItems_Sylva: 从 Store_Sylva 筛选出 goodIsVIP_Sylva 为 true 的套餐数组
/// - selectedItem_Sylva: 当前选中的 VIP 套餐（发起购买前校验）
/// - itemCells_Sylva: 所有套餐 Cell，用于统一切换选中态
class VIPSubscription_Sylva: UIViewController {

    // MARK: - 数据

    /// 所有 VIP 套餐
    private var vipItems_Sylva: [StoreModel_Sylva] = []
    /// 当前选中套餐
    private var selectedItem_Sylva: StoreModel_Sylva?
    /// 所有套餐 Cell 引用（统一更新选中态）
    private var itemCells_Sylva: [VIPItemCell_Sylva] = []

    // MARK: - UI · 背景渐变

    private var bgGradient_Sylva: CAGradientLayer?

    // MARK: - UI · 自定义导航栏

    private let navBar_Sylva: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let backButton_Sylva: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Sylva = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Sylva)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Sylva: UILabel = {
        let l = UILabel()
        l.text = "Subscription"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .white
        return l
    }()

    // MARK: - UI · 滚动容器

    private let scrollView_Sylva: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Sylva = UIView()

    // MARK: - UI · 组件1：顶部装饰图

    /// vip_top 装饰图（组件1），紧贴导航栏底部，左右内边距20，完整展示图片内容
    private let vipTopImage_Sylva: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        return iv
    }()

    // MARK: - UI · 组件2：套餐纵向列表

    /// 套餐纵向 StackView，间距 12
    private let itemsVStack_Sylva: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()

    // MARK: - UI · 组件3：恢复购买

    private let restoreButton_Sylva: UIButton = {
        let b = UIButton(type: .system)
        let attrs_Sylva: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.black
        ]
        let title_Sylva = NSAttributedString(string: "Restore Purchases", attributes: attrs_Sylva)
        b.setAttributedTitle(title_Sylva, for: .normal)
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - UI · 组件4：订阅按钮

    private let subscribeButton_Sylva: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "vip_sub"), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.clipsToBounds = true
        return b
    }()

    // MARK: - UI · 组件5：协议标签

    private var protocolLabel_Sylva: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData_Sylva()
        setupUI_Sylva()
        buildItemCells_Sylva()
        setupActions_Sylva()
        // 默认选中第一项
        if let first_Sylva = vipItems_Sylva.first {
            updateSelection_Sylva(model: first_Sylva)
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
        bgGradient_Sylva?.frame = view.bounds
    }

    // MARK: - 数据加载

    /// 从 Store_Sylva 筛选 VIP 套餐
    private func loadData_Sylva() {
        vipItems_Sylva = Store_Sylva.shared_Sylva.goodsList_Sylva.filter { $0.goodIsVIP_Sylva == true }
    }

    // MARK: - UI 搭建

    private func setupUI_Sylva() {
        setupBgGradient_Sylva()

        view.addSubview(scrollView_Sylva)
        scrollView_Sylva.addSubview(contentView_Sylva)

        // 组件1
        contentView_Sylva.addSubview(vipTopImage_Sylva)
        // 组件2：纵向列表
        contentView_Sylva.addSubview(itemsVStack_Sylva)
        // 组件4
        contentView_Sylva.addSubview(subscribeButton_Sylva)

        // 组件5：协议标签（terms + eula，黑色文字）
        let proto_Sylva = ProtocolHelper_Sylva.createProtocolTextLabel_Sylva(
            firstProtocol_Sylva: .terms_Sylva,
            firstContent_Sylva: "terms.png",
            secondProtocol_Sylva: .eula_Sylva,
            secondContent_Sylva: "eula.png",
            config_Sylva: ProtocolHelper_Sylva.ProtocolTextConfig_Sylva(
                textColor_Sylva: UIColor(hexstring_Sylva: "#111111"),
                linkColor_Sylva: UIColor(hexstring_Sylva: "#111111"),
                fontSize_Sylva: 13,
                fontWeight_Sylva: .regular,
                hasUnderline_Sylva: true
            ),
            from: self
        )
        contentView_Sylva.addSubview(proto_Sylva)
        protocolLabel_Sylva = proto_Sylva

        // 导航栏（最顶层）
        view.addSubview(navBar_Sylva)
        navBar_Sylva.addSubview(backButton_Sylva)
        navBar_Sylva.addSubview(navTitleLabel_Sylva)
        navBar_Sylva.addSubview(restoreButton_Sylva)

        setupConstraints_Sylva(protoLabel: proto_Sylva)
    }

    /// 全屏渐变背景：#7297F9（顶部居中）→ #4A8EFF（底部居中）
    private func setupBgGradient_Sylva() {
        let gl_Sylva = CAGradientLayer()
        gl_Sylva.colors = [
            UIColor(hexstring_Sylva: "#7297F9").cgColor,
            UIColor(hexstring_Sylva: "#4A8EFF").cgColor
        ]
        gl_Sylva.startPoint = CGPoint(x: 0.5, y: 0.0)
        gl_Sylva.endPoint   = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gl_Sylva, at: 0)
        bgGradient_Sylva = gl_Sylva
    }

    // MARK: - 构建套餐 Cell

    /// 遍历 vipItems_Sylva 生成 VIPItemCell_Sylva 并加入纵向列表
    private func buildItemCells_Sylva() {
        itemCells_Sylva.removeAll()
        vipItems_Sylva.forEach { model_Sylva in
            let cell_Sylva = VIPItemCell_Sylva()
            cell_Sylva.configure_Sylva(model: model_Sylva)
            cell_Sylva.onTap_Sylva = { [weak self] selected_Sylva in
                self?.updateSelection_Sylva(model: selected_Sylva)
            }
            itemsVStack_Sylva.addArrangedSubview(cell_Sylva)
            cell_Sylva.snp.makeConstraints {
                $0.height.equalTo(50)
            }
            itemCells_Sylva.append(cell_Sylva)
        }
    }

    // MARK: - 约束

    private func setupConstraints_Sylva(protoLabel: UILabel) {
        let screenW_Sylva = UIScreen.main.bounds.width
        // 图片宽度 = 屏幕宽 - 左右各20内边距，高度按图片实际比例自适应（scaleAspectFit）
        let imgW_Sylva: CGFloat = screenW_Sylva - 40
        let img_Sylva = UIImage(named: "vip_top")
        let aspect_Sylva = img_Sylva.map { $0.size.height / $0.size.width } ?? 0.75
        let vipTopH_Sylva: CGFloat = imgW_Sylva * aspect_Sylva

        // 导航栏
        navBar_Sylva.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Sylva.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Sylva.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton_Sylva)
        }
        restoreButton_Sylva.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(backButton_Sylva)
            $0.height.equalTo(22)
        }

        // 滚动容器：顶部从导航栏底部开始，确保内容可正常滚动
        scrollView_Sylva.snp.makeConstraints {
            $0.top.equalTo(navBar_Sylva.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Sylva.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // 组件1：vip_top，左右内边距20，高度按缩小比例展示完整图片
        vipTopImage_Sylva.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(vipTopH_Sylva)
        }

        // 组件2：纵向套餐列表，距 vip_top 下方 20，左右内边距16
        itemsVStack_Sylva.snp.makeConstraints {
            $0.top.equalTo(vipTopImage_Sylva.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        // 组件4：订阅按钮，距套餐列表下方 20，屏幕宽-32，高 62
        subscribeButton_Sylva.snp.makeConstraints {
            $0.top.equalTo(itemsVStack_Sylva.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(62)
        }

        // 组件5：协议，距订阅按钮下方 15
        protoLabel.snp.makeConstraints {
            $0.top.equalTo(subscribeButton_Sylva.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 选中状态更新

    /// 更新所有 Cell 的选中态，并记录当前选中套餐
    /// - Parameter model: 被选中的套餐模型
    private func updateSelection_Sylva(model: StoreModel_Sylva) {
        selectedItem_Sylva = model
        itemCells_Sylva.forEach { cell_Sylva in
            cell_Sylva.setSelected_Sylva(cell_Sylva.model_Sylva?.id_Sylva == model.id_Sylva)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Sylva() {
        backButton_Sylva.addTarget(self, action: #selector(backTapped_Sylva), for: .touchUpInside)
        restoreButton_Sylva.addTarget(self, action: #selector(restoreTapped_Sylva), for: .touchUpInside)
        subscribeButton_Sylva.addTarget(self, action: #selector(subscribeTapped_Sylva), for: .touchUpInside)
    }

    @objc private func backTapped_Sylva() {
        Navigation_Sylva.pop_Sylva(from: self)
    }

    /// 恢复购买按钮回调
    @objc private func restoreTapped_Sylva() {
        Store_Sylva.shared_Sylva.RestorePurchase_Sylva { [weak self] in
            guard let self_Sylva = self else { return }
            _ = self_Sylva
        }
    }

    /// 订阅按钮回调：发起 VIP 内购
    @objc private func subscribeTapped_Sylva() {
        guard let item_Sylva = selectedItem_Sylva,
              let gid_Sylva  = item_Sylva.goodsId_Sylva else {
            Utils_Sylva.showWarning_Sylva(message_Sylva: "Please select a subscription plan.")
            return
        }
        subscribeButton_Sylva.animatePressDown_Sylva { self.subscribeButton_Sylva.animatePressUp_Sylva() }
        Store_Sylva.shared_Sylva.PurchaseStoreVIP_Sylva(vipId_Sylva: gid_Sylva) { [weak self] in
            guard let self_Sylva = self else { return }
            Navigation_Sylva.pop_Sylva(from: self_Sylva)
        }
    }
}

// MARK: - VIPItemCell_Sylva

/// VIP 套餐单元格视图
/// 核心作用：展示单个 VIP 套餐信息（选中图标 + 套餐名 + 价格），支持点击回调
/// 设计思路：高度50的圆角10横向卡片，未选中白底蓝字，选中蓝底白字并显示24x24圆形状态图标
/// 关键方法：
/// - configure_Sylva: 注入套餐数据（价格 + 套餐名）
/// - setSelected_Sylva: 切换选中态（背景透明度 + 套餐名颜色）
private class VIPItemCell_Sylva: UIView {

    // MARK: - 属性

    /// 当前套餐数据（外部只读，内部赋值）
    private(set) var model_Sylva: StoreModel_Sylva?

    /// 点击回调，回传选中的套餐模型
    var onTap_Sylva: ((StoreModel_Sylva) -> Void)?

    // MARK: - UI

    /// 选中状态圆形指示器
    private let selectCircle_Sylva: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor(hexstring_Sylva: "#2353E4").cgColor
        v.backgroundColor = .clear
        v.isHidden = true
        return v
    }()
    private let selectInnerDot_Sylva: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Sylva: "#2353E4")
        v.layer.cornerRadius = 6
        v.isHidden = true
        return v
    }()

    /// 价格文本，字号20加粗
    private let priceLabel_Sylva: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 20, weight: .bold)
        l.textColor     = UIColor(hexstring_Sylva: "#2353E4")
        l.textAlignment = .right
        return l
    }()

    /// 套餐名：默认蓝色，选中白色，字号18加粗
    private let nameLabel_Sylva: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 18, weight: .bold)
        l.textColor     = UIColor(hexstring_Sylva: "#2353E4")
        l.textAlignment = .left
        return l
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Sylva()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func setupUI_Sylva() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 10
        layer.masksToBounds = true

        addSubview(selectCircle_Sylva)
        selectCircle_Sylva.addSubview(selectInnerDot_Sylva)
        addSubview(nameLabel_Sylva)
        addSubview(priceLabel_Sylva)

        selectCircle_Sylva.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        selectInnerDot_Sylva.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(12)
        }
        nameLabel_Sylva.snp.makeConstraints {
            $0.leading.equalTo(selectCircle_Sylva.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(priceLabel_Sylva.snp.leading).offset(-12)
        }
        priceLabel_Sylva.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-14)
            $0.centerY.equalToSuperview()
        }

        // 点击手势
        let tap_Sylva = UITapGestureRecognizer(target: self, action: #selector(handleTap_Sylva))
        addGestureRecognizer(tap_Sylva)
        isUserInteractionEnabled = true
    }

    // MARK: - 数据填充

    /// 注入套餐数据
    /// - Parameter model: VIP 套餐模型（读取 goodsPrice_Sylva 和 goodsName_Sylva）
    func configure_Sylva(model: StoreModel_Sylva) {
        self.model_Sylva = model
        priceLabel_Sylva.text = model.goodsPrice_Sylva
        nameLabel_Sylva.text = model.goodsName_Sylva
    }

    // MARK: - 选中态切换

    /// 切换选中状态：选中时蓝底白字，未选中时白底蓝字，并同步圆形指示器
    /// - Parameter selected: true 为选中态，false 为未选中态
    func setSelected_Sylva(_ selected: Bool) {
        backgroundColor = selected ? UIColor(hexstring_Sylva: "#2353E4") : UIColor.white
        nameLabel_Sylva.textColor = selected ? UIColor.white : UIColor(hexstring_Sylva: "#2353E4")
        priceLabel_Sylva.textColor = selected ? UIColor.white : UIColor(hexstring_Sylva: "#2353E4")
        selectCircle_Sylva.layer.borderColor = selected ? UIColor.white.cgColor : UIColor(hexstring_Sylva: "#2353E4").cgColor
        selectInnerDot_Sylva.backgroundColor = selected ? UIColor.white : UIColor(hexstring_Sylva: "#2353E4")
        selectCircle_Sylva.isHidden = !selected
        selectInnerDot_Sylva.isHidden = !selected
    }

    // MARK: - 点击处理

    @objc private func handleTap_Sylva() {
        guard let model_Sylva = model_Sylva else { return }
        onTap_Sylva?(model_Sylva)
    }
}
