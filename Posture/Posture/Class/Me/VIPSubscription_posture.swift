import Foundation
import UIKit
import SnapKit

// MARK: - VIP 订阅页面

/// VIP 订阅页面
/// 核心作用：展示 VIP 套餐列表，支持套餐选择、发起内购订阅及恢复购买
/// 设计思路：全屏青紫渐变背景（左上 #00FFF0 → 右下 #A678F1）+ 顶部 vip_top 装饰图 + 纵向套餐列表 + 底部操作区
/// 关键属性：
/// - vipItems_Posture: 从 Store_Posture 筛选出 goodIsVIP_Posture 为 true 的套餐数组
/// - selectedItem_Posture: 当前选中的 VIP 套餐（发起购买前校验）
/// - itemCells_Posture: 所有套餐 Cell，用于统一切换选中态
class VIPSubscription_Posture: UIViewController {

    // MARK: - 数据

    /// 所有 VIP 套餐
    private var vipItems_Posture: [StoreModel_Posture] = []
    /// 当前选中套餐
    private var selectedItem_Posture: StoreModel_Posture?
    /// 所有套餐 Cell 引用（统一更新选中态）
    private var itemCells_Posture: [VIPItemCell_Posture] = []

    // MARK: - UI · 全屏背景图片

    /// vip_bg 铺满全屏作为背景图
    private let bgImageView_Posture: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_bg")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    // MARK: - UI · 自定义导航栏

    private let navBar_Posture: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    /// X 关闭按钮，替代返回箭头
    private let backButton_Posture: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Posture = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "xmark", withConfiguration: cfg_Posture)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .black
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Posture: UILabel = {
        let l = UILabel()
        l.text = "Membership subscription"
        l.font = .systemFont(ofSize: 14, weight: .bold)
        l.textColor = .black
        return l
    }()

    // MARK: - UI · 滚动容器

    private let scrollView_Posture: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Posture = UIView()

    // MARK: - UI · 组件1：顶部装饰图

    /// vip_top 装饰图（组件1），紧贴导航栏底部，左右内边距20，完整展示图片内容
    private let vipTopImage_Posture: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        return iv
    }()

    // MARK: - UI · 组件2：套餐纵向列表

    /// 套餐纵向 StackView，间距 12
    private let itemsVStack_Posture: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()

    // MARK: - UI · 组件3：恢复购买（位于导航栏右侧）

    private let restoreButton_Posture: UIButton = {
        let b = UIButton(type: .system)
        let attrs_Posture: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.black
        ]
        let title_Posture = NSAttributedString(string: "Restore Purchases", attributes: attrs_Posture)
        b.setAttributedTitle(title_Posture, for: .normal)
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - UI · 组件4：订阅按钮

    private let subscribeButton_Posture: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "vip_sub"), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.clipsToBounds = true
        return b
    }()

    // MARK: - UI · 组件5：协议标签

    private var protocolLabel_Posture: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData_Posture()
        setupUI_Posture()
        buildItemCells_Posture()
        setupActions_Posture()
        // 默认选中第一项
        if let first_Posture = vipItems_Posture.first {
            updateSelection_Posture(model: first_Posture)
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
    }

    // MARK: - 数据加载

    /// 从 Store_Posture 筛选 VIP 套餐
    private func loadData_Posture() {
        vipItems_Posture = Subscribe_Posture.shared_Posture.goodsList_Posture.filter { $0.goodIsVIP_Posture == true }
    }

    // MARK: - UI 搭建

    private func setupUI_Posture() {
        // 背景图片铺满全屏
        view.addSubview(bgImageView_Posture)
        bgImageView_Posture.snp.makeConstraints { $0.edges.equalToSuperview() }

        view.addSubview(scrollView_Posture)
        scrollView_Posture.addSubview(contentView_Posture)

        // 组件1
        contentView_Posture.addSubview(vipTopImage_Posture)
        // 组件2：纵向列表
        contentView_Posture.addSubview(itemsVStack_Posture)
        // 组件4
        contentView_Posture.addSubview(subscribeButton_Posture)

        // 组件5：协议标签（terms + eula，黑色文字）
        let proto_Posture = ProtocolHelper_Posture.createProtocolTextLabel_Posture(
            firstProtocol_Posture: .terms_Posture,
            firstContent_Posture: "terms.png",
            secondProtocol_Posture: .eula_Posture,
            secondContent_Posture: "eula.png",
            config_Posture: ProtocolHelper_Posture.ProtocolTextConfig_Posture(
                textColor_Posture: UIColor(hexstring_Posture: "#111111"),
                linkColor_Posture: UIColor(hexstring_Posture: "#111111"),
                fontSize_Posture: 13,
                fontWeight_Posture: .regular,
                hasUnderline_Posture: true
            ),
            from: self
        )
        contentView_Posture.addSubview(proto_Posture)
        protocolLabel_Posture = proto_Posture

        // 导航栏（最顶层）
        view.addSubview(navBar_Posture)
        navBar_Posture.addSubview(backButton_Posture)
        navBar_Posture.addSubview(navTitleLabel_Posture)
        navBar_Posture.addSubview(restoreButton_Posture)

        setupConstraints_Posture(protoLabel: proto_Posture)
    }

    // MARK: - 构建套餐 Cell

    /// 遍历 vipItems_Posture 生成 VIPItemCell_Posture 并加入纵向列表
    private func buildItemCells_Posture() {
        itemCells_Posture.removeAll()
        vipItems_Posture.forEach { model_Posture in
            let cell_Posture = VIPItemCell_Posture()
            cell_Posture.configure_Posture(model: model_Posture)
            cell_Posture.onTap_Posture = { [weak self] selected_Posture in
                self?.updateSelection_Posture(model: selected_Posture)
            }
            itemsVStack_Posture.addArrangedSubview(cell_Posture)
            cell_Posture.snp.makeConstraints {
                $0.height.equalTo(50)
            }
            itemCells_Posture.append(cell_Posture)
        }
    }

    // MARK: - 约束

    private func setupConstraints_Posture(protoLabel: UILabel) {
        let screenW_Posture = UIScreen.main.bounds.width
        // 图片宽度 = 屏幕宽 - 左右各20内边距，高度按图片实际比例自适应（scaleAspectFit）
        let imgW_Posture: CGFloat = screenW_Posture - 40
        let img_Posture = UIImage(named: "vip_top")
        let aspect_Posture = img_Posture.map { $0.size.height / $0.size.width } ?? 0.75
        let vipTopH_Posture: CGFloat = imgW_Posture * aspect_Posture

        // 导航栏
        navBar_Posture.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Posture.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Posture.snp.makeConstraints {
            $0.leading.equalTo(backButton_Posture.snp.trailing).offset(10)
            $0.centerY.equalTo(backButton_Posture)
        }
        restoreButton_Posture.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(backButton_Posture)
            $0.height.equalTo(22)
        }

        // 滚动容器：顶部从导航栏底部开始，确保内容可正常滚动
        scrollView_Posture.snp.makeConstraints {
            $0.top.equalTo(navBar_Posture.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Posture.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // 组件1：vip_top，左右内边距20，高度按缩小比例展示完整图片
        vipTopImage_Posture.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(vipTopH_Posture)
        }

        // 组件2：纵向套餐列表，距 vip_top 下方 20，左右内边距16
        itemsVStack_Posture.snp.makeConstraints {
            $0.top.equalTo(vipTopImage_Posture.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        // 组件4：订阅按钮，距套餐列表下方 20，屏幕宽-32，高 62
        subscribeButton_Posture.snp.makeConstraints {
            $0.top.equalTo(itemsVStack_Posture.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(62)
        }

        // 组件5：协议，距订阅按钮下方 15
        protoLabel.snp.makeConstraints {
            $0.top.equalTo(subscribeButton_Posture.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 选中状态更新

    /// 更新所有 Cell 的选中态，并记录当前选中套餐
    /// - Parameter model: 被选中的套餐模型
    private func updateSelection_Posture(model: StoreModel_Posture) {
        selectedItem_Posture = model
        itemCells_Posture.forEach { cell_Posture in
            cell_Posture.setSelected_Posture(cell_Posture.model_Posture?.id_Posture == model.id_Posture)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Posture() {
        backButton_Posture.addTarget(self, action: #selector(backTapped_Posture), for: .touchUpInside)
        restoreButton_Posture.addTarget(self, action: #selector(restoreTapped_Posture), for: .touchUpInside)
        subscribeButton_Posture.addTarget(self, action: #selector(subscribeTapped_Posture), for: .touchUpInside)
    }

    @objc private func backTapped_Posture() {
        Navigation_Posture.pop_Posture(from: self)
    }

    /// 恢复购买按钮回调
    @objc private func restoreTapped_Posture() {
        Subscribe_Posture.shared_Posture.RestorePurchase_Posture { [weak self] in
            guard let self_Posture = self else { return }
            _ = self_Posture
        }
    }

    /// 订阅按钮回调：发起 VIP 内购
    @objc private func subscribeTapped_Posture() {
        guard let item_Posture = selectedItem_Posture,
              let gid_Posture  = item_Posture.goodsId_Posture else {
            Utils_Posture.showWarning_Posture(message_Posture: "Please select a subscription plan.")
            return
        }
        subscribeButton_Posture.animatePressDown_Posture { self.subscribeButton_Posture.animatePressUp_Posture() }
        Subscribe_Posture.shared_Posture.PurchaseStoreVIP_Posture(vipId_Posture: gid_Posture) { [weak self] in
            guard let self_Posture = self else { return }
            Navigation_Posture.pop_Posture(from: self_Posture)
        }
    }
}

// MARK: - VIPItemCell_Posture

/// VIP 套餐单元格视图
/// 核心作用：展示单个 VIP 套餐信息（选中图标 + 套餐名 + 价格），支持点击回调
/// 设计思路：高度50的圆角10横向卡片，未选中白底蓝字，选中蓝底白字并显示24x24圆形状态图标
/// 关键方法：
/// - configure_Posture: 注入套餐数据（价格 + 套餐名）
/// - setSelected_Posture: 切换选中态（背景透明度 + 套餐名颜色）
private class VIPItemCell_Posture: UIView {

    // MARK: - 属性

    /// 当前套餐数据（外部只读，内部赋值）
    private(set) var model_Posture: StoreModel_Posture?

    /// 点击回调，回传选中的套餐模型
    var onTap_Posture: ((StoreModel_Posture) -> Void)?

    // MARK: - UI

    /// 选中状态圆形指示器
    private let selectCircle_Posture: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor(hexstring_Posture: "#2353E4").cgColor
        v.backgroundColor = .clear
        v.isHidden = true
        return v
    }()
    private let selectInnerDot_Posture: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Posture: "#2353E4")
        v.layer.cornerRadius = 6
        v.isHidden = true
        return v
    }()

    /// 价格文本，字号20加粗
    private let priceLabel_Posture: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 20, weight: .bold)
        l.textColor     = UIColor(hexstring_Posture: "#2353E4")
        l.textAlignment = .right
        return l
    }()

    /// 套餐名：默认蓝色，选中白色，字号18加粗
    private let nameLabel_Posture: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 18, weight: .bold)
        l.textColor     = UIColor(hexstring_Posture: "#2353E4")
        l.textAlignment = .left
        return l
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Posture()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func setupUI_Posture() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 10
        layer.masksToBounds = true

        addSubview(selectCircle_Posture)
        selectCircle_Posture.addSubview(selectInnerDot_Posture)
        addSubview(nameLabel_Posture)
        addSubview(priceLabel_Posture)

        selectCircle_Posture.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        selectInnerDot_Posture.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(12)
        }
        nameLabel_Posture.snp.makeConstraints {
            $0.leading.equalTo(selectCircle_Posture.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(priceLabel_Posture.snp.leading).offset(-12)
        }
        priceLabel_Posture.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-14)
            $0.centerY.equalToSuperview()
        }

        // 点击手势
        let tap_Posture = UITapGestureRecognizer(target: self, action: #selector(handleTap_Posture))
        addGestureRecognizer(tap_Posture)
        isUserInteractionEnabled = true
    }

    // MARK: - 数据填充

    /// 注入套餐数据
    /// - Parameter model: VIP 套餐模型（读取 goodsPrice_Posture 和 goodsName_Posture）
    func configure_Posture(model: StoreModel_Posture) {
        self.model_Posture = model
        priceLabel_Posture.text = model.goodsPrice_Posture
        nameLabel_Posture.text = model.goodsName_Posture
    }

    // MARK: - 选中态切换

    /// 切换选中状态：选中时蓝底白字，未选中时白底蓝字，并同步圆形指示器
    /// - Parameter selected: true 为选中态，false 为未选中态
    func setSelected_Posture(_ selected: Bool) {
        backgroundColor = selected ? UIColor(hexstring_Posture: "#2353E4") : UIColor.white
        nameLabel_Posture.textColor = selected ? UIColor.white : UIColor(hexstring_Posture: "#2353E4")
        priceLabel_Posture.textColor = selected ? UIColor.white : UIColor(hexstring_Posture: "#2353E4")
        selectCircle_Posture.layer.borderColor = selected ? UIColor.white.cgColor : UIColor(hexstring_Posture: "#2353E4").cgColor
        selectInnerDot_Posture.backgroundColor = selected ? UIColor.white : UIColor(hexstring_Posture: "#2353E4")
        selectCircle_Posture.isHidden = !selected
        selectInnerDot_Posture.isHidden = !selected
    }

    // MARK: - 点击处理

    @objc private func handleTap_Posture() {
        guard let model_Posture = model_Posture else { return }
        onTap_Posture?(model_Posture)
    }
}
