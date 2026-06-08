import Foundation
import UIKit
import SnapKit

// MARK: - VIP 订阅页面

/// VIP 订阅页面
/// 核心作用：展示 VIP 套餐列表，支持套餐选择、发起内购订阅及恢复购买
/// 设计思路：全屏青紫渐变背景（左上 #FFA100 → 右下 #E55C45+ 顶部 vip_top 装饰图 + 纵向套餐列表 + 底部操作区
/// 关键属性：
/// - vipItems_Hush: 从 Store_Hush 筛选出 goodIsVIP_Hush 为 true 的套餐数组
/// - selectedItem_Hush: 当前选中的 VIP 套餐（发起购买前校验）
/// - itemCells_Hush: 所有套餐 Cell，用于统一切换选中态
class VIPSubscription_Hush: UIViewController {

    // MARK: - 数据

    /// 所有 VIP 套餐
    private var vipItems_Hush: [StoreModel_Hush] = []
    /// 当前选中套餐
    private var selectedItem_Hush: StoreModel_Hush?
    /// 所有套餐 Cell 引用（统一更新选中态）
    private var itemCells_Hush: [VIPItemCell_Hush] = []

    // MARK: - UI · 背景

    /// 顶部背景图（vip_top_bg，全宽铺满）
    private let bgTopImageView_Hush: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top_bg")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    /// 图片下方渐变背景区（#FFFFFF → #F0411B → #FF5817）
    private let bgGradientView_Hush = UIView()
    private var bgGradientLayer_Hush: CAGradientLayer?

    // MARK: - UI · 自定义导航栏

    private let navBar_Hush: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let backButton_Hush: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Hush = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Hush)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Hush: UILabel = {
        let l = UILabel()
        l.text = "Member"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .white
        return l
    }()

    // MARK: - UI · 滚动容器

    private let scrollView_Hush: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Hush = UIView()

    // MARK: - UI · 组件1：顶部装饰图

    /// vip_top 装饰图（组件1），紧贴导航栏底部，左右内边距20，完整展示图片内容
    private let vipTopImage_Hush: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        return iv
    }()

    // MARK: - UI · 组件1.5：营销语标签

    /// 套餐列表与 vip_top 图片之间的倾斜营销文案
    private let sloganLabel_Hush: UILabel = {
        let l = UILabel()
        l.text = "So Many People To Choose From"
        l.font = .italicSystemFont(ofSize: 20)
        l.textColor = .black
        l.textAlignment = .center
        l.numberOfLines = 1
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.7
        return l
    }()

    // MARK: - UI · 组件2：套餐横向列表

    /// 套餐横向 StackView，间距 12，等分宽度
    private let itemsVStack_Hush: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .fill
        sv.distribution = .fillEqually
        return sv
    }()

    // MARK: - UI · 组件2.5：vip_top_1 展示图片

    /// 套餐列表与恢复购买之间的装饰图（vip_top_1，全宽展示）
    private let vipTop1Image_Hush: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top_1")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    // MARK: - UI · 组件3：恢复购买

    private let restoreButton_Hush: UIButton = {
        let b = UIButton(type: .system)
        let attrs_Hush: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.white
        ]
        let title_Hush = NSAttributedString(string: "Restore Purchases", attributes: attrs_Hush)
        b.setAttributedTitle(title_Hush, for: .normal)
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - UI · 组件4：订阅按钮

    private let subscribeButton_Hush: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "vip_sub"), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.clipsToBounds = true
        return b
    }()

    // MARK: - UI · 组件5：协议标签

    private var protocolLabel_Hush: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData_Hush()
        setupUI_Hush()
        buildItemCells_Hush()
        setupActions_Hush()
        // 默认选中第一项
        if let first_Hush = vipItems_Hush.first {
            updateSelection_Hush(model: first_Hush)
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
        bgGradientLayer_Hush?.frame = bgGradientView_Hush.bounds
    }

    // MARK: - 数据加载

    /// 从 Store_Hush 筛选 VIP 套餐
    private func loadData_Hush() {
        vipItems_Hush = Subscribe_Hush.shared_Hush.goodsList_Hush.filter { $0.goodIsVIP_Hush == true }
    }

    // MARK: - UI 搭建

    private func setupUI_Hush() {
        setupBackground_Hush()
        // 滚动容器与内容区透明，确保背景图/渐变层透出
        view.backgroundColor = .clear
        scrollView_Hush.backgroundColor = .clear
        contentView_Hush.backgroundColor = .clear
        view.addSubview(scrollView_Hush)
        scrollView_Hush.addSubview(contentView_Hush)

        // 组件1
        contentView_Hush.addSubview(vipTopImage_Hush)
        // 组件1.5：营销语标签
        contentView_Hush.addSubview(sloganLabel_Hush)
        // 组件2：横向列表
        contentView_Hush.addSubview(itemsVStack_Hush)
        // 组件2.5：vip_top_1 装饰图
        contentView_Hush.addSubview(vipTop1Image_Hush)
        // 组件3：恢复购买按钮（位于装饰图与购买按钮之间）
        contentView_Hush.addSubview(restoreButton_Hush)
        // 组件4
        contentView_Hush.addSubview(subscribeButton_Hush)

        // 组件5：协议标签（terms + eula，白色文字）
        let proto_Hush = ProtocolHelper_Hush.createProtocolTextLabel_Hush(
            firstProtocol_Hush: .terms_Hush,
            firstContent_Hush: "terms.png",
            secondProtocol_Hush: .eula_Hush,
            secondContent_Hush: "eula.png",
            config_Hush: ProtocolHelper_Hush.ProtocolTextConfig_Hush(
                textColor_Hush: UIColor(hexstring_Hush: "#FFFFFF"),
                linkColor_Hush: UIColor(hexstring_Hush: "#FFFFFF"),
                fontSize_Hush: 13,
                fontWeight_Hush: .regular,
                hasUnderline_Hush: true
            ),
            from: self
        )
        contentView_Hush.addSubview(proto_Hush)
        protocolLabel_Hush = proto_Hush

        // 导航栏（最顶层，不含恢复购买按钮）
        view.addSubview(navBar_Hush)
        navBar_Hush.addSubview(backButton_Hush)
        navBar_Hush.addSubview(navTitleLabel_Hush)

        setupConstraints_Hush(protoLabel: proto_Hush)
    }

    /// 搭建背景：顶部 vip_top_bg 图片 + 图片下方 #FFFFFF→#F0411B→#FF5817 渐变
    /// 背景层置于滚动容器之下，随界面固定不随内容滚动
    private func setupBackground_Hush() {
        // 顶部背景图：全宽，按图片宽高比计算高度
        view.addSubview(bgTopImageView_Hush)
        let img_Hush   = UIImage(named: "vip_top_bg")
        let aspect_Hush = img_Hush.map { $0.size.height / $0.size.width } ?? 0.6
        let imgH_Hush: CGFloat = UIScreen.main.bounds.width * aspect_Hush
        bgTopImageView_Hush.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(imgH_Hush)
        }

        // 渐变背景区：从图片底部延伸至屏幕底部
        view.addSubview(bgGradientView_Hush)
        bgGradientView_Hush.snp.makeConstraints { make in
            make.top.equalTo(bgTopImageView_Hush.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        let gl_Hush = CAGradientLayer()
        gl_Hush.colors = [
            UIColor(hexstring_Hush: "#FFFFFF").cgColor,
            UIColor(hexstring_Hush: "#F0411B").cgColor,
            UIColor(hexstring_Hush: "#FF5817").cgColor
        ]
        gl_Hush.locations = [0, 0.8, 1.0]
        gl_Hush.startPoint = CGPoint(x: 0.5, y: 0.0)
        gl_Hush.endPoint   = CGPoint(x: 0.5, y: 1.0)
        bgGradientView_Hush.layer.addSublayer(gl_Hush)
        bgGradientLayer_Hush = gl_Hush
    }

    // MARK: - 构建套餐 Cell

    /// 遍历 vipItems_Hush 生成 VIPItemCell_Hush 并加入纵向列表
    private func buildItemCells_Hush() {
        itemCells_Hush.removeAll()
        vipItems_Hush.forEach { model_Hush in
            let cell_Hush = VIPItemCell_Hush()
            cell_Hush.configure_Hush(model: model_Hush)
            cell_Hush.onTap_Hush = { [weak self] selected_Hush in
                self?.updateSelection_Hush(model: selected_Hush)
            }
            itemsVStack_Hush.addArrangedSubview(cell_Hush)
            itemCells_Hush.append(cell_Hush)
        }
    }

    // MARK: - 约束

    private func setupConstraints_Hush(protoLabel: UILabel) {
        let screenW_Hush = UIScreen.main.bounds.width
        let imgW_Hush: CGFloat = screenW_Hush - 40
        let img_Hush = UIImage(named: "vip_top")
        let aspect_Hush = img_Hush.map { $0.size.height / $0.size.width } ?? 0.75
        let vipTopH_Hush: CGFloat = imgW_Hush * aspect_Hush

        // 导航栏（仅含返回按钮和标题，不含恢复购买）
        navBar_Hush.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Hush.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Hush.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton_Hush)
        }

        // 滚动容器
        scrollView_Hush.snp.makeConstraints {
            $0.top.equalTo(navBar_Hush.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Hush.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // 组件1：vip_top 装饰图
        vipTopImage_Hush.snp.makeConstraints {
            $0.top.equalToSuperview().offset(120)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(vipTopH_Hush)
        }

        // 组件1.5：营销语标签（距 vip_top 下方 40，居中）
        sloganLabel_Hush.snp.makeConstraints {
            $0.top.equalTo(vipTopImage_Hush.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        // 组件2：横向套餐列表（距营销语下方 15，高度固定 92）
        itemsVStack_Hush.snp.makeConstraints {
            $0.top.equalTo(sloganLabel_Hush.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(92)
        }

        // 组件2.5：vip_top_1 装饰图（套餐列表下方20，按图片宽高比自适应高度）
        let img1_Hush    = UIImage(named: "vip_top_1")
        let aspect1_Hush = img1_Hush.map { $0.size.height / $0.size.width } ?? 0.5
        let vipTop1H_Hush: CGFloat = (screenW_Hush - 32) * aspect1_Hush
        vipTop1Image_Hush.snp.makeConstraints {
            $0.top.equalTo(itemsVStack_Hush.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(vipTop1H_Hush)
        }

        // 组件3：恢复购买按钮，位于装饰图下方 35pt，居中
        restoreButton_Hush.snp.makeConstraints {
            $0.top.equalTo(vipTop1Image_Hush.snp.bottom).offset(35)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(22)
        }

        // 组件4：订阅按钮，距恢复购买按钮下方 10pt
        subscribeButton_Hush.snp.makeConstraints {
            $0.top.equalTo(restoreButton_Hush.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(62)
        }

        // 组件5：协议标签，距购买按钮下方 15pt
        protoLabel.snp.makeConstraints {
            $0.top.equalTo(subscribeButton_Hush.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 选中状态更新

    /// 更新所有 Cell 的选中态，并记录当前选中套餐
    /// - Parameter model: 被选中的套餐模型
    private func updateSelection_Hush(model: StoreModel_Hush) {
        selectedItem_Hush = model
        itemCells_Hush.forEach { cell_Hush in
            cell_Hush.setSelected_Hush(cell_Hush.model_Hush?.id_Hush == model.id_Hush)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Hush() {
        backButton_Hush.addTarget(self, action: #selector(backTapped_Hush), for: .touchUpInside)
        restoreButton_Hush.addTarget(self, action: #selector(restoreTapped_Hush), for: .touchUpInside)
        subscribeButton_Hush.addTarget(self, action: #selector(subscribeTapped_Hush), for: .touchUpInside)
    }

    @objc private func backTapped_Hush() {
        Navigation_Hush.pop_Hush(from: self)
    }

    /// 恢复购买按钮回调
    @objc private func restoreTapped_Hush() {
        Subscribe_Hush.shared_Hush.RestorePurchase_Hush { [weak self] in
            guard let self_Hush = self else { return }
            _ = self_Hush
        }
    }

    /// 订阅按钮回调：发起 VIP 内购
    @objc private func subscribeTapped_Hush() {
        guard let item_Hush = selectedItem_Hush,
              let gid_Hush  = item_Hush.goodsId_Hush else {
            Utils_Hush.showWarning_Hush(message_Hush: "Please select a subscription plan.")
            return
        }
        subscribeButton_Hush.animatePressDown_Hush { self.subscribeButton_Hush.animatePressUp_Hush() }
        Subscribe_Hush.shared_Hush.PurchaseStoreVIP_Hush(vipId_Hush: gid_Hush) { [weak self] in
            guard let self_Hush = self else { return }
            Navigation_Hush.pop_Hush(from: self_Hush)
        }
    }
}

// MARK: - VIPItemCell_Hush

/// VIP 套餐单元格视图
/// 核心作用：横向列表中的单个套餐卡片，高度92
/// 设计：白色背景 + 1.5pt 黑色边框，圆角16；选中时背景 #F3461A、边框 #F3461A
/// 布局：goodsName（顶部12，12号中等黑色居中）/ goodsPrice（底部12，20号中等黑色居中）
/// 关键方法：configure_Hush 注入数据；setSelected_Hush 切换选中态
private class VIPItemCell_Hush: UIView {

    // MARK: - 属性

    /// 当前套餐数据（外部只读）
    private(set) var model_Hush: StoreModel_Hush?

    /// 点击回调，回传选中的套餐模型
    var onTap_Hush: ((StoreModel_Hush) -> Void)?

    // MARK: - UI

    /// 套餐名称（goodsName，顶部12，12号中等，黑色）
    private let nameLabel_Hush: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = .black
        l.textAlignment = .center
        l.numberOfLines = 1
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.7
        return l
    }()

    /// 套餐价格（goodsPrice，底部12，20号中等，黑色）
    private let priceLabel_Hush: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .medium)
        l.textColor = .black
        l.textAlignment = .center
        l.numberOfLines = 1
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.6
        return l
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Hush()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func setupUI_Hush() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.black.cgColor
        layer.masksToBounds = true

        addSubview(nameLabel_Hush)
        addSubview(priceLabel_Hush)

        // 套餐名：距顶部12，水平居中
        nameLabel_Hush.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.trailing.equalToSuperview().inset(8)
        }
        // 套餐价格：距底部12，水平居中
        priceLabel_Hush.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(12)
            $0.leading.trailing.equalToSuperview().inset(8)
        }

        let tap_Hush = UITapGestureRecognizer(target: self, action: #selector(handleTap_Hush))
        addGestureRecognizer(tap_Hush)
        isUserInteractionEnabled = true
    }

    // MARK: - 数据填充

    /// 注入套餐数据，分别展示套餐名与价格
    /// - Parameter model: VIP 套餐模型
    func configure_Hush(model: StoreModel_Hush) {
        self.model_Hush = model
        nameLabel_Hush.text  = model.goodsName_Hush  ?? ""
        priceLabel_Hush.text = model.goodsPrice_Hush ?? ""
    }

    // MARK: - 选中态切换

    /// 切换选中状态
    /// 选中：#F3461A 背景 + #F3461A 边框 + 白色文字
    /// 未选中：白色背景 + 黑色边框 + 黑色文字
    /// - Parameter selected: 是否选中
    func setSelected_Hush(_ selected: Bool) {
        // layer 属性同步设置，不放入 UIView.animate 块
        layer.borderColor = selected
            ? UIColor(hexstring_Hush: "#F3461A").cgColor
            : UIColor.black.cgColor

        UIView.animate(withDuration: 0.18) {
            self.backgroundColor = selected
                ? UIColor(hexstring_Hush: "#F3461A")
                : .white
            let textColor_Hush: UIColor = selected ? .white : .black
            self.nameLabel_Hush.textColor  = textColor_Hush
            self.priceLabel_Hush.textColor = textColor_Hush
        }
    }

    // MARK: - 点击处理

    @objc private func handleTap_Hush() {
        guard let model_Hush = model_Hush else { return }
        onTap_Hush?(model_Hush)
    }
}
