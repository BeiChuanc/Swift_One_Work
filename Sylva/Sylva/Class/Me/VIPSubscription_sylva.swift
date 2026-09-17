import UIKit
import SnapKit

/// VIP 订阅页面，展示会员权益、四种套餐、订阅与恢复购买入口。
/// 设计思路：复用全屏植物背景和权益素材，通过两列卡片展示套餐，业务状态与购买交给用户状态管理类。
/// 关键属性：subscriptionState_sylva 管理套餐，planCards_sylva 在通知到达时同步选中样式。
class VIPSubscription_Sylva: UIViewController {
    private let subscriptionState_sylva = VIPSubscriptionViewModel_sylva()
    private let backgroundImageView_sylva = UIImageView(image: UIImage(named: "vip_bg"))
    private let closeButton_sylva = UIButton(type: .custom)
    private let restoreButton_sylva = UIButton(type: .system)
    private let scrollView_sylva = UIScrollView()
    private let contentView_sylva = UIView()
    private let benefitsImageView_sylva = UIImageView(image: UIImage(named: "vip_top"))
    private let plansStack_sylva = UIStackView()
    private let subscribeButton_sylva = UIButton(type: .custom)
    private var benefitsTopConstraint_sylva: Constraint?
    private var planCards_sylva: [(planId_sylva: String?, card_sylva: VIPPlanCard_sylva)] = []

    /// 创建订阅界面、绑定状态通知并显示默认选中的套餐。
    /// 参数：无。返回值：Void。异常：无。
    override func viewDidLoad() {
        super.viewDidLoad()
        buildBackground_sylva()
        buildNavigation_sylva()
        buildContent_sylva()
        buildPlanCards_sylva()
        bindActions_sylva()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshSelection_sylva),
            name: VIPSubscriptionViewModel_sylva.stateDidChange_sylva,
            object: subscriptionState_sylva
        )
        refreshSelection_sylva()
    }

    /// 显示自定义导航控件，避免系统导航栏遮挡背景。
    /// - Parameter animated_sylva: 系统传入的页面转场动画标记。
    /// - Returns: Void，无返回值；无抛出异常。
    override func viewWillAppear(_ animated_sylva: Bool) {
        super.viewWillAppear(animated_sylva)
        navigationController?.setNavigationBarHidden(true, animated: animated_sylva)
    }

    /// 根据可见高度调整顶部留白，短屏保持可滚动且操作区不重叠。
    /// 参数：无。返回值：Void。异常：无。
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let spacing_sylva = min(82, max(20, scrollView_sylva.bounds.height * 0.10))
        benefitsTopConstraint_sylva?.update(offset: spacing_sylva)
    }

    /// 释放界面时移除通知监听；无参数、无返回值、无异常。
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 使用已有植物背景铺满页面，保留素材自带的暗色渐变。
    /// 参数：无。返回值：Void。异常：无。
    private func buildBackground_sylva() {
        view.backgroundColor = UIColor(hexstring_Sylva: "#101010")
        backgroundImageView_sylva.contentMode = .scaleAspectFill
        backgroundImageView_sylva.clipsToBounds = true
        view.addSubview(backgroundImageView_sylva)
        backgroundImageView_sylva.snp.makeConstraints { make_sylva in
            make_sylva.edges.equalToSuperview()
        }
    }

    /// 配置左侧关闭按钮与右侧恢复购买按钮，并遵循安全区布局。
    /// 参数：无。返回值：Void。异常：无。
    private func buildNavigation_sylva() {
        let symbolConfig_sylva = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        closeButton_sylva.setImage(UIImage(systemName: "xmark", withConfiguration: symbolConfig_sylva), for: .normal)
        closeButton_sylva.tintColor = .white
        closeButton_sylva.accessibilityLabel = "Close subscription"
        view.addSubview(closeButton_sylva)
        closeButton_sylva.snp.makeConstraints { make_sylva in
            make_sylva.top.equalTo(view.safeAreaLayoutGuide).offset(2)
            make_sylva.leading.equalTo(view.safeAreaLayoutGuide).offset(4)
            make_sylva.width.height.equalTo(44)
        }

        restoreButton_sylva.setTitle("Restore Purchase", for: .normal)
        restoreButton_sylva.setTitleColor(.white, for: .normal)
        let restoreFont_sylva = UIFont.systemFont(ofSize: 15, weight: .heavy)
        restoreButton_sylva.titleLabel?.font = UIFont(
            descriptor: restoreFont_sylva.fontDescriptor.withDesign(.rounded) ?? restoreFont_sylva.fontDescriptor,
            size: 15
        )
        view.addSubview(restoreButton_sylva)
        restoreButton_sylva.snp.makeConstraints { make_sylva in
            make_sylva.trailing.equalTo(view.safeAreaLayoutGuide).offset(-14)
            make_sylva.centerY.height.equalTo(closeButton_sylva)
            make_sylva.leading.greaterThanOrEqualTo(closeButton_sylva.snp.trailing).offset(12)
        }
    }

    /// 构建可滚动的权益图、套餐网格、订阅按钮和协议文本。
    /// 参数：无。返回值：Void。异常：无。
    private func buildContent_sylva() {
        scrollView_sylva.showsVerticalScrollIndicator = false
        scrollView_sylva.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_sylva)
        scrollView_sylva.snp.makeConstraints { make_sylva in
            make_sylva.top.equalTo(closeButton_sylva.snp.bottom)
            make_sylva.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make_sylva.bottom.equalToSuperview()
        }
        scrollView_sylva.addSubview(contentView_sylva)
        contentView_sylva.snp.makeConstraints { make_sylva in
            make_sylva.edges.equalTo(scrollView_sylva.contentLayoutGuide)
            make_sylva.width.equalTo(scrollView_sylva.frameLayoutGuide)
        }

        benefitsImageView_sylva.contentMode = .scaleAspectFit
        benefitsImageView_sylva.isAccessibilityElement = true
        benefitsImageView_sylva.accessibilityLabel = "Subscribe: Unlock VIP. Unlimited chat function. Unlimited posting of updates. Unlimited video calling function."
        contentView_sylva.addSubview(benefitsImageView_sylva)
        benefitsImageView_sylva.snp.makeConstraints { make_sylva in
            benefitsTopConstraint_sylva = make_sylva.top.equalToSuperview().offset(60).constraint
            make_sylva.leading.equalToSuperview().offset(10)
            make_sylva.trailing.equalToSuperview().offset(-14)
            make_sylva.height.equalTo(benefitsImageView_sylva.snp.width).multipliedBy(428.0 / 676.0)
        }

        plansStack_sylva.axis = .vertical
        plansStack_sylva.spacing = 22
        plansStack_sylva.distribution = .fillEqually
        contentView_sylva.addSubview(plansStack_sylva)
        plansStack_sylva.snp.makeConstraints { make_sylva in
            make_sylva.top.equalTo(benefitsImageView_sylva.snp.bottom).offset(46)
            make_sylva.leading.trailing.equalToSuperview().inset(38)
            make_sylva.height.equalTo(214)
        }

        subscribeButton_sylva.setBackgroundImage(UIImage(named: "vip_sub")?.withRenderingMode(.alwaysOriginal), for: .normal)
        subscribeButton_sylva.accessibilityLabel = "Subscribe"
        contentView_sylva.addSubview(subscribeButton_sylva)
        subscribeButton_sylva.snp.makeConstraints { make_sylva in
            make_sylva.top.equalTo(plansStack_sylva.snp.bottom).offset(30)
            make_sylva.leading.trailing.equalToSuperview().inset(10)
            make_sylva.height.equalTo(subscribeButton_sylva.snp.width).multipliedBy(96.0 / 670.0)
        }

        let protocolLabel_sylva = ProtocolHelper_Sylva.createProtocolTextLabel_Sylva(
            firstProtocol_Sylva: .terms_Sylva,
            firstContent_Sylva: "terms.png",
            secondProtocol_Sylva: .eula_Sylva,
            secondContent_Sylva: "eula.png",
            config_Sylva: ProtocolHelper_Sylva.ProtocolTextConfig_Sylva(
                textColor_Sylva: UIColor(hexstring_Sylva: "#777777"),
                linkColor_Sylva: UIColor(hexstring_Sylva: "#EEEEEE"),
                fontSize_Sylva: 13,
                fontWeight_Sylva: .regular,
                hasUnderline_Sylva: true,
                prefixText_Sylva: "By continuing, you agree to our ",
                separatorText_Sylva: " and "
            ),
            from: self
        )
        contentView_sylva.addSubview(protocolLabel_sylva)
        protocolLabel_sylva.snp.makeConstraints { make_sylva in
            make_sylva.top.equalTo(subscribeButton_sylva.snp.bottom).offset(24)
            make_sylva.leading.trailing.equalToSuperview().inset(10)
            make_sylva.bottom.equalToSuperview().offset(-48)
        }
    }

    /// 创建两行两列套餐卡片，将选择事件交给订阅状态管理类。
    /// 参数：无。返回值：Void。异常：无，缺失套餐以透明空位显示。
    private func buildPlanCards_sylva() {
        for rowIndex_sylva in 0..<2 {
            let row_sylva = UIStackView()
            row_sylva.axis = .horizontal
            row_sylva.spacing = 22
            row_sylva.distribution = .fillEqually
            for columnIndex_sylva in 0..<2 {
                let planIndex_sylva = rowIndex_sylva * 2 + columnIndex_sylva
                guard subscriptionState_sylva.plans_sylva.indices.contains(planIndex_sylva) else {
                    row_sylva.addArrangedSubview(UIView())
                    continue
                }
                let plan_sylva = subscriptionState_sylva.plans_sylva[planIndex_sylva]
                let card_sylva = VIPPlanCard_sylva()
                card_sylva.configure_sylva(
                    price_sylva: subscriptionState_sylva.priceText_sylva(plan_sylva: plan_sylva),
                    name_sylva: subscriptionState_sylva.nameText_sylva(plan_sylva: plan_sylva)
                )
                card_sylva.onSelect_sylva = { [weak self] in
                    self?.subscriptionState_sylva.selectPlan_sylva(plan_sylva: plan_sylva)
                }
                planCards_sylva.append((planId_sylva: plan_sylva.goodsId_Sylva, card_sylva: card_sylva))
                row_sylva.addArrangedSubview(card_sylva)
            }
            plansStack_sylva.addArrangedSubview(row_sylva)
        }
    }

    /// 将关闭、恢复和订阅操作绑定到导航及状态管理，不在页面实现支付逻辑。
    /// 参数：无。返回值：Void。异常：无。
    private func bindActions_sylva() {
        closeButton_sylva.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            Navigation_Sylva.pop_Sylva(from: self)
        }, for: .touchUpInside)
        restoreButton_sylva.addAction(UIAction { [weak self] _ in
            self?.subscriptionState_sylva.restorePurchases_sylva(completion_sylva: {})
        }, for: .touchUpInside)
        subscribeButton_sylva.addAction(UIAction { [weak self] _ in
            self?.subscriptionState_sylva.subscribe_sylva { [weak self] in
                guard let self else { return }
                Navigation_Sylva.pop_Sylva(from: self)
            }
        }, for: .touchUpInside)
    }

    /// 按当前套餐编号刷新所有卡片的选中样式。
    /// 参数：无。返回值：Void。异常：无。
    @objc private func refreshSelection_sylva() {
        for planCard_sylva in planCards_sylva {
            planCard_sylva.card_sylva.applySelection_sylva(
                isSelected_sylva: planCard_sylva.planId_sylva == subscriptionState_sylva.selectedPlanId_sylva
            )
        }
    }
}
