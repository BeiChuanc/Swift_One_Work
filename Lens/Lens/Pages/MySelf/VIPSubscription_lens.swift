import Foundation
import UIKit
import SnapKit

// MARK: - VIP 订阅页面

/// VIP 订阅页面
/// 核心作用：展示 VIP 套餐列表，支持套餐选择、发起内购订阅及恢复购买
/// 设计思路：全屏青紫渐变背景（左上 #00FFF0 → 右下 #A678F1）+ 顶部 vip_top 装饰图 + 纵向套餐列表 + 底部操作区
/// 关键属性：
/// - vipItems_Lens: 从 Store_Lens 筛选出 goodIsVIP_Lens 为 true 的套餐数组
/// - selectedItem_Lens: 当前选中的 VIP 套餐（发起购买前校验）
/// - itemCells_Lens: 所有套餐 Cell，用于统一切换选中态
class VIPSubscription_Lens: UIViewController {

    // MARK: - 数据

    /// 所有 VIP 套餐
    private var vipItems_Lens: [StoreModel_Lens] = []
    /// 当前选中套餐
    private var selectedItem_Lens: StoreModel_Lens?
    /// 所有套餐 Cell 引用（统一更新选中态）
    private var itemCells_Lens: [VIPItemCell_Lens] = []

    // MARK: - UI · 背景渐变

    private var bgGradient_Lens: CAGradientLayer?

    // MARK: - UI · 自定义导航栏

    private let navBar_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let backButton_Lens: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Lens)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Subscription"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .white
        return l
    }()

    // MARK: - UI · 滚动容器

    private let scrollView_Lens: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Lens = UIView()

    // MARK: - UI · 组件1：顶部装饰图

    /// vip_top 装饰图（组件1），紧贴导航栏底部，左右内边距20，完整展示图片内容
    private let vipTopImage_Lens: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        return iv
    }()

    // MARK: - UI · 组件2：套餐纵向列表

    /// 套餐纵向 StackView，间距 12
    private let itemsVStack_Lens: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()

    // MARK: - UI · 组件3：恢复购买

    private let restoreButton_Lens: UIButton = {
        let b = UIButton(type: .system)
        let attrs_Lens: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.black
        ]
        let title_Lens = NSAttributedString(string: "Restore Purchases", attributes: attrs_Lens)
        b.setAttributedTitle(title_Lens, for: .normal)
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - UI · 组件4：订阅按钮

    private let subscribeButton_Lens: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "vip_sub"), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.clipsToBounds = true
        return b
    }()

    // MARK: - UI · 组件5：协议标签

    private var protocolLabel_Lens: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData_Lens()
        setupUI_Lens()
        buildItemCells_Lens()
        setupActions_Lens()
        // 默认选中第一项
        if let first_Lens = vipItems_Lens.first {
            updateSelection_Lens(model: first_Lens)
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
        bgGradient_Lens?.frame = view.bounds
    }

    // MARK: - 数据加载

    /// 从 Store_Lens 筛选 VIP 套餐
    private func loadData_Lens() {
        vipItems_Lens = Store_Lens.shared_Lens.goodsList_Lens.filter { $0.goodIsVIP_Lens == true }
    }

    // MARK: - UI 搭建

    private func setupUI_Lens() {
        setupBgGradient_Lens()

        view.addSubview(scrollView_Lens)
        scrollView_Lens.addSubview(contentView_Lens)

        // 组件1
        contentView_Lens.addSubview(vipTopImage_Lens)
        // 组件2：纵向列表
        contentView_Lens.addSubview(itemsVStack_Lens)
        // 组件4
        contentView_Lens.addSubview(subscribeButton_Lens)

        // 组件5：协议标签（terms + eula，黑色文字）
        let proto_Lens = ProtocolHelper_Lens.createProtocolTextLabel_Lens(
            firstProtocol_Lens: .terms_Lens,
            firstContent_Lens: "terms.png",
            secondProtocol_Lens: .eula_Lens,
            secondContent_Lens: "eula.png",
            config_Lens: ProtocolHelper_Lens.ProtocolTextConfig_Lens(
                textColor_Lens: UIColor(hexstring_Lens: "#111111"),
                linkColor_Lens: UIColor(hexstring_Lens: "#111111"),
                fontSize_Lens: 13,
                fontWeight_Lens: .regular,
                hasUnderline_Lens: true
            ),
            from: self
        )
        contentView_Lens.addSubview(proto_Lens)
        protocolLabel_Lens = proto_Lens

        // 导航栏（最顶层）
        view.addSubview(navBar_Lens)
        navBar_Lens.addSubview(backButton_Lens)
        navBar_Lens.addSubview(navTitleLabel_Lens)
        navBar_Lens.addSubview(restoreButton_Lens)

        setupConstraints_Lens(protoLabel: proto_Lens)
    }

    /// 全屏渐变背景：#7297F9（顶部居中）→ #4A8EFF（底部居中）
    private func setupBgGradient_Lens() {
        let gl_Lens = CAGradientLayer()
        gl_Lens.colors = [
            UIColor(hexstring_Lens: "#7297F9").cgColor,
            UIColor(hexstring_Lens: "#4A8EFF").cgColor
        ]
        gl_Lens.startPoint = CGPoint(x: 0.5, y: 0.0)
        gl_Lens.endPoint   = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gl_Lens, at: 0)
        bgGradient_Lens = gl_Lens
    }

    // MARK: - 构建套餐 Cell

    /// 遍历 vipItems_Lens 生成 VIPItemCell_Lens 并加入纵向列表
    private func buildItemCells_Lens() {
        itemCells_Lens.removeAll()
        vipItems_Lens.forEach { model_Lens in
            let cell_Lens = VIPItemCell_Lens()
            cell_Lens.configure_Lens(model: model_Lens)
            cell_Lens.onTap_Lens = { [weak self] selected_Lens in
                self?.updateSelection_Lens(model: selected_Lens)
            }
            itemsVStack_Lens.addArrangedSubview(cell_Lens)
            cell_Lens.snp.makeConstraints {
                $0.height.equalTo(50)
            }
            itemCells_Lens.append(cell_Lens)
        }
    }

    // MARK: - 约束

    private func setupConstraints_Lens(protoLabel: UILabel) {
        let screenW_Lens = UIScreen.main.bounds.width
        // 图片宽度 = 屏幕宽 - 左右各20内边距，高度按图片实际比例自适应（scaleAspectFit）
        let imgW_Lens: CGFloat = screenW_Lens - 40
        let img_Lens = UIImage(named: "vip_top")
        let aspect_Lens = img_Lens.map { $0.size.height / $0.size.width } ?? 0.75
        let vipTopH_Lens: CGFloat = imgW_Lens * aspect_Lens

        // 导航栏
        navBar_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton_Lens)
        }
        restoreButton_Lens.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(backButton_Lens)
            $0.height.equalTo(22)
        }

        // 滚动容器：顶部从导航栏底部开始，确保内容可正常滚动
        scrollView_Lens.snp.makeConstraints {
            $0.top.equalTo(navBar_Lens.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // 组件1：vip_top，左右内边距20，高度按缩小比例展示完整图片
        vipTopImage_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(vipTopH_Lens)
        }

        // 组件2：纵向套餐列表，距 vip_top 下方 20，左右内边距16
        itemsVStack_Lens.snp.makeConstraints {
            $0.top.equalTo(vipTopImage_Lens.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        // 组件4：订阅按钮，距套餐列表下方 20，屏幕宽-32，高 62
        subscribeButton_Lens.snp.makeConstraints {
            $0.top.equalTo(itemsVStack_Lens.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(62)
        }

        // 组件5：协议，距订阅按钮下方 15
        protoLabel.snp.makeConstraints {
            $0.top.equalTo(subscribeButton_Lens.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 选中状态更新

    /// 更新所有 Cell 的选中态，并记录当前选中套餐
    /// - Parameter model: 被选中的套餐模型
    private func updateSelection_Lens(model: StoreModel_Lens) {
        selectedItem_Lens = model
        itemCells_Lens.forEach { cell_Lens in
            cell_Lens.setSelected_Lens(cell_Lens.model_Lens?.id_Lens == model.id_Lens)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Lens() {
        backButton_Lens.addTarget(self, action: #selector(backTapped_Lens), for: .touchUpInside)
        restoreButton_Lens.addTarget(self, action: #selector(restoreTapped_Lens), for: .touchUpInside)
        subscribeButton_Lens.addTarget(self, action: #selector(subscribeTapped_Lens), for: .touchUpInside)
    }

    @objc private func backTapped_Lens() {
        Navigation_Lens.pop_Lens(from: self)
    }

    /// 恢复购买按钮回调
    @objc private func restoreTapped_Lens() {
        Subscribe_Lens.shared_Lens.RestorePurchase_Lens { [weak self] in
            guard let self_Lens = self else { return }
            _ = self_Lens
        }
    }

    /// 订阅按钮回调：发起 VIP 内购
    @objc private func subscribeTapped_Lens() {
        guard let item_Lens = selectedItem_Lens,
              let gid_Lens  = item_Lens.goodsId_Lens else {
            Load_Lens.showWarning_Lens(message_Lens: "Please select a subscription plan.")
            return
        }
        Subscribe_Lens.shared_Lens.PurchaseStoreVIP_Lens(vipId_Lens: gid_Lens) { [weak self] in
            guard let self_Lens = self else { return }
            Navigation_Lens.pop_Lens(from: self_Lens)
        }
    }
}

// MARK: - VIPItemCell_Lens

/// VIP 套餐单元格视图
/// 核心作用：展示单个 VIP 套餐信息（选中图标 + 套餐名 + 价格），支持点击回调
/// 设计思路：高度50的圆角10横向卡片，未选中白底蓝字，选中蓝底白字并显示24x24圆形状态图标
/// 关键方法：
/// - configure_Lens: 注入套餐数据（价格 + 套餐名）
/// - setSelected_Lens: 切换选中态（背景透明度 + 套餐名颜色）
private class VIPItemCell_Lens: UIView {

    // MARK: - 属性

    /// 当前套餐数据（外部只读，内部赋值）
    private(set) var model_Lens: StoreModel_Lens?

    /// 点击回调，回传选中的套餐模型
    var onTap_Lens: ((StoreModel_Lens) -> Void)?

    // MARK: - UI

    /// 选中状态圆形指示器
    private let selectCircle_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor(hexstring_Lens: "#2353E4").cgColor
        v.backgroundColor = .clear
        v.isHidden = true
        return v
    }()
    private let selectInnerDot_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#2353E4")
        v.layer.cornerRadius = 6
        v.isHidden = true
        return v
    }()

    /// 价格文本，字号20加粗
    private let priceLabel_Lens: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 20, weight: .bold)
        l.textColor     = UIColor(hexstring_Lens: "#2353E4")
        l.textAlignment = .right
        return l
    }()

    /// 套餐名：默认蓝色，选中白色，字号18加粗
    private let nameLabel_Lens: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 18, weight: .bold)
        l.textColor     = UIColor(hexstring_Lens: "#2353E4")
        l.textAlignment = .left
        return l
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lens()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func setupUI_Lens() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 10
        layer.masksToBounds = true

        addSubview(selectCircle_Lens)
        selectCircle_Lens.addSubview(selectInnerDot_Lens)
        addSubview(nameLabel_Lens)
        addSubview(priceLabel_Lens)

        selectCircle_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        selectInnerDot_Lens.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(12)
        }
        nameLabel_Lens.snp.makeConstraints {
            $0.leading.equalTo(selectCircle_Lens.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(priceLabel_Lens.snp.leading).offset(-12)
        }
        priceLabel_Lens.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-14)
            $0.centerY.equalToSuperview()
        }

        // 点击手势
        let tap_Lens = UITapGestureRecognizer(target: self, action: #selector(handleTap_Lens))
        addGestureRecognizer(tap_Lens)
        isUserInteractionEnabled = true
    }

    // MARK: - 数据填充

    /// 注入套餐数据
    /// - Parameter model: VIP 套餐模型（读取 goodsPrice_Lens 和 goodsName_Lens）
    func configure_Lens(model: StoreModel_Lens) {
        self.model_Lens = model
        priceLabel_Lens.text = model.goodsPrice_Lens
        nameLabel_Lens.text = model.goodsName_Lens
    }

    // MARK: - 选中态切换

    /// 切换选中状态：选中时蓝底白字，未选中时白底蓝字，并同步圆形指示器
    /// - Parameter selected: true 为选中态，false 为未选中态
    func setSelected_Lens(_ selected: Bool) {
        backgroundColor = selected ? UIColor(hexstring_Lens: "#2353E4") : UIColor.white
        nameLabel_Lens.textColor = selected ? UIColor.white : UIColor(hexstring_Lens: "#2353E4")
        priceLabel_Lens.textColor = selected ? UIColor.white : UIColor(hexstring_Lens: "#2353E4")
        selectCircle_Lens.layer.borderColor = selected ? UIColor.white.cgColor : UIColor(hexstring_Lens: "#2353E4").cgColor
        selectInnerDot_Lens.backgroundColor = selected ? UIColor.white : UIColor(hexstring_Lens: "#2353E4")
        selectCircle_Lens.isHidden = !selected
        selectInnerDot_Lens.isHidden = !selected
    }

    // MARK: - 点击处理

    @objc private func handleTap_Lens() {
        guard let model_Lens = model_Lens else { return }
        onTap_Lens?(model_Lens)
    }
}
