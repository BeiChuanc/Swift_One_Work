import Foundation
import UIKit
import SnapKit

// MARK: - VIP 订阅页面

/// VIP 订阅页面
/// 核心作用：展示 VIP 套餐列表，支持套餐选择、发起内购订阅及恢复购买
/// 设计思路：全屏青紫渐变背景（左上 #00FFF0 → 右下 #A678F1）+ 顶部 vip_top 装饰图 + 纵向套餐列表 + 底部操作区
/// 关键属性：
/// - vipItems_Orna: 从 Store_Orna 筛选出 goodIsVIP_Orna 为 true 的套餐数组
/// - selectedItem_Orna: 当前选中的 VIP 套餐（发起购买前校验）
/// - itemCells_Orna: 所有套餐 Cell，用于统一切换选中态
class VIPSubscription_Orna: UIViewController {

    // MARK: - 数据

    /// 所有 VIP 套餐
    private var vipItems_Orna: [StoreModel_Orna] = []
    /// 当前选中套餐
    private var selectedItem_Orna: StoreModel_Orna?
    /// 所有套餐 Cell 引用（统一更新选中态）
    private var itemCells_Orna: [VIPItemCell_Orna] = []

    // MARK: - UI · 背景渐变

    private var bgGradient_Orna: CAGradientLayer?

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
        l.text = "Subscription"
        l.font = .funFont_Orna(ofSize: 18, weight: .bold)
        l.textColor = .white
        return l
    }()

    // MARK: - UI · 滚动容器

    private let scrollView_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Orna = UIView()

    // MARK: - UI · 组件1：顶部装饰图

    /// vip_top 装饰图（组件1），紧贴导航栏底部，左右内边距20，完整展示图片内容
    private let vipTopImage_Orna: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        return iv
    }()

    // MARK: - UI · 组件2：套餐纵向列表

    /// 套餐纵向 StackView，间距 12
    private let itemsVStack_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()

    // MARK: - UI · 组件3：恢复购买

    private let restoreButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let attrs_Orna: [NSAttributedString.Key: Any] = [
            .font: UIFont.funFont_Orna(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.black
        ]
        let title_Orna = NSAttributedString(string: "Restore Purchases", attributes: attrs_Orna)
        b.setAttributedTitle(title_Orna, for: .normal)
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - UI · 组件4：订阅按钮

    private let subscribeButton_Orna: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "vip_sub"), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.clipsToBounds = true
        return b
    }()

    // MARK: - UI · 组件5：协议标签

    private var protocolLabel_Orna: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData_Orna()
        setupUI_Orna()
        buildItemCells_Orna()
        setupActions_Orna()
        // 默认选中第一项
        if let first_Orna = vipItems_Orna.first {
            updateSelection_Orna(model: first_Orna)
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
        bgGradient_Orna?.frame = view.bounds
    }

    // MARK: - 数据加载

    /// 从 Store_Orna 筛选 VIP 套餐
    private func loadData_Orna() {
        vipItems_Orna = Store_Orna.shared_Orna.goodsList_Orna.filter { $0.goodIsVIP_Orna == true }
    }

    // MARK: - UI 搭建

    private func setupUI_Orna() {
        setupBgGradient_Orna()

        view.addSubview(scrollView_Orna)
        scrollView_Orna.addSubview(contentView_Orna)

        // 组件1
        contentView_Orna.addSubview(vipTopImage_Orna)
        // 组件2：纵向列表
        contentView_Orna.addSubview(itemsVStack_Orna)
        // 组件4
        contentView_Orna.addSubview(subscribeButton_Orna)

        // 组件5：协议标签（terms + eula，黑色文字）
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

        // 导航栏（最顶层）
        view.addSubview(navBar_Orna)
        navBar_Orna.addSubview(backButton_Orna)
        navBar_Orna.addSubview(navTitleLabel_Orna)
        navBar_Orna.addSubview(restoreButton_Orna)

        setupConstraints_Orna(protoLabel: proto_Orna)
    }

    /// 全屏渐变背景：#7297F9（顶部居中）→ #4A8EFF（底部居中）
    private func setupBgGradient_Orna() {
        let gl_Orna = CAGradientLayer()
        gl_Orna.colors = [
            UIColor(hexstring_Orna: "#7297F9").cgColor,
            UIColor(hexstring_Orna: "#4A8EFF").cgColor
        ]
        gl_Orna.startPoint = CGPoint(x: 0.5, y: 0.0)
        gl_Orna.endPoint   = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gl_Orna, at: 0)
        bgGradient_Orna = gl_Orna
    }

    // MARK: - 构建套餐 Cell

    /// 遍历 vipItems_Orna 生成 VIPItemCell_Orna 并加入纵向列表
    private func buildItemCells_Orna() {
        itemCells_Orna.removeAll()
        vipItems_Orna.forEach { model_Orna in
            let cell_Orna = VIPItemCell_Orna()
            cell_Orna.configure_Orna(model: model_Orna)
            cell_Orna.onTap_Orna = { [weak self] selected_Orna in
                self?.updateSelection_Orna(model: selected_Orna)
            }
            itemsVStack_Orna.addArrangedSubview(cell_Orna)
            cell_Orna.snp.makeConstraints {
                $0.height.equalTo(50)
            }
            itemCells_Orna.append(cell_Orna)
        }
    }

    // MARK: - 约束

    private func setupConstraints_Orna(protoLabel: UILabel) {
        let screenW_Orna = UIScreen.main.bounds.width
        // 图片宽度 = 屏幕宽 - 左右各20内边距，高度按图片实际比例自适应（scaleAspectFit）
        let imgW_Orna: CGFloat = screenW_Orna - 40
        let img_Orna = UIImage(named: "vip_top")
        let aspect_Orna = img_Orna.map { $0.size.height / $0.size.width } ?? 0.75
        let vipTopH_Orna: CGFloat = imgW_Orna * aspect_Orna

        // 导航栏
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
        restoreButton_Orna.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(backButton_Orna)
            $0.height.equalTo(22)
        }

        // 滚动容器：顶部从导航栏底部开始，确保内容可正常滚动
        scrollView_Orna.snp.makeConstraints {
            $0.top.equalTo(navBar_Orna.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // 组件1：vip_top，左右内边距20，高度按缩小比例展示完整图片
        vipTopImage_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(vipTopH_Orna)
        }

        // 组件2：纵向套餐列表，距 vip_top 下方 20，左右内边距16
        itemsVStack_Orna.snp.makeConstraints {
            $0.top.equalTo(vipTopImage_Orna.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        // 组件4：订阅按钮，距套餐列表下方 20，屏幕宽-32，高 62
        subscribeButton_Orna.snp.makeConstraints {
            $0.top.equalTo(itemsVStack_Orna.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(62)
        }

        // 组件5：协议，距订阅按钮下方 15
        protoLabel.snp.makeConstraints {
            $0.top.equalTo(subscribeButton_Orna.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 选中状态更新

    /// 更新所有 Cell 的选中态，并记录当前选中套餐
    /// - Parameter model: 被选中的套餐模型
    private func updateSelection_Orna(model: StoreModel_Orna) {
        selectedItem_Orna = model
        itemCells_Orna.forEach { cell_Orna in
            cell_Orna.setSelected_Orna(cell_Orna.model_Orna?.id_Orna == model.id_Orna)
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
        Subscribe_Orna.shared_Orna.RestorePurchase_Orna { [weak self] in
            guard let self_Orna = self else { return }
            _ = self_Orna
        }
    }

    /// 订阅按钮回调：发起 VIP 内购
    @objc private func subscribeTapped_Orna() {
        guard let item_Orna = selectedItem_Orna,
              let gid_Orna  = item_Orna.goodsId_Orna else {
            Load_Orna.showWarning_Orna(message_Orna: "Please select a subscription plan.")
            return
        }
        Subscribe_Orna.shared_Orna.PurchaseStoreVIP_Orna(vipId_Orna: gid_Orna) { [weak self] in
            guard let self_Orna = self else { return }
            Navigation_Orna.pop_Orna(from: self_Orna)
        }
    }
}

// MARK: - VIPItemCell_Orna

/// VIP 套餐单元格视图
/// 核心作用：展示单个 VIP 套餐信息（选中图标 + 套餐名 + 价格），支持点击回调
/// 设计思路：高度50的圆角10横向卡片，未选中白底蓝字，选中蓝底白字并显示24x24圆形状态图标
/// 关键方法：
/// - configure_Orna: 注入套餐数据（价格 + 套餐名）
/// - setSelected_Orna: 切换选中态（背景透明度 + 套餐名颜色）
private class VIPItemCell_Orna: UIView {

    // MARK: - 属性

    /// 当前套餐数据（外部只读，内部赋值）
    private(set) var model_Orna: StoreModel_Orna?

    /// 点击回调，回传选中的套餐模型
    var onTap_Orna: ((StoreModel_Orna) -> Void)?

    // MARK: - UI

    /// 选中状态圆形指示器
    private let selectCircle_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor(hexstring_Orna: "#2353E4").cgColor
        v.backgroundColor = .clear
        v.isHidden = true
        return v
    }()
    private let selectInnerDot_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#2353E4")
        v.layer.cornerRadius = 6
        v.isHidden = true
        return v
    }()

    /// 价格文本，字号20加粗
    private let priceLabel_Orna: UILabel = {
        let l = UILabel()
        l.font          = .funFont_Orna(ofSize: 20, weight: .bold)
        l.textColor     = UIColor(hexstring_Orna: "#2353E4")
        l.textAlignment = .right
        return l
    }()

    /// 套餐名：默认蓝色，选中白色，字号18加粗
    private let nameLabel_Orna: UILabel = {
        let l = UILabel()
        l.font          = .funFont_Orna(ofSize: 18, weight: .bold)
        l.textColor     = UIColor(hexstring_Orna: "#2353E4")
        l.textAlignment = .left
        return l
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Orna()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func setupUI_Orna() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 10
        layer.masksToBounds = true

        addSubview(selectCircle_Orna)
        selectCircle_Orna.addSubview(selectInnerDot_Orna)
        addSubview(nameLabel_Orna)
        addSubview(priceLabel_Orna)

        selectCircle_Orna.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        selectInnerDot_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(12)
        }
        nameLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(selectCircle_Orna.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(priceLabel_Orna.snp.leading).offset(-12)
        }
        priceLabel_Orna.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-14)
            $0.centerY.equalToSuperview()
        }

        // 点击手势
        let tap_Orna = UITapGestureRecognizer(target: self, action: #selector(handleTap_Orna))
        addGestureRecognizer(tap_Orna)
        isUserInteractionEnabled = true
    }

    // MARK: - 数据填充

    /// 注入套餐数据
    /// - Parameter model: VIP 套餐模型（读取 goodsPrice_Orna 和 goodsName_Orna）
    func configure_Orna(model: StoreModel_Orna) {
        self.model_Orna = model
        priceLabel_Orna.text = model.goodsPrice_Orna
        nameLabel_Orna.text = model.goodsName_Orna
    }

    // MARK: - 选中态切换

    /// 切换选中状态：选中时蓝底白字，未选中时白底蓝字，并同步圆形指示器
    /// - Parameter selected: true 为选中态，false 为未选中态
    func setSelected_Orna(_ selected: Bool) {
        backgroundColor = selected ? UIColor(hexstring_Orna: "#2353E4") : UIColor.white
        nameLabel_Orna.textColor = selected ? UIColor.white : UIColor(hexstring_Orna: "#2353E4")
        priceLabel_Orna.textColor = selected ? UIColor.white : UIColor(hexstring_Orna: "#2353E4")
        selectCircle_Orna.layer.borderColor = selected ? UIColor.white.cgColor : UIColor(hexstring_Orna: "#2353E4").cgColor
        selectInnerDot_Orna.backgroundColor = selected ? UIColor.white : UIColor(hexstring_Orna: "#2353E4")
        selectCircle_Orna.isHidden = !selected
        selectInnerDot_Orna.isHidden = !selected
    }

    // MARK: - 点击处理

    @objc private func handleTap_Orna() {
        guard let model_Orna = model_Orna else { return }
        onTap_Orna?(model_Orna)
    }
}
