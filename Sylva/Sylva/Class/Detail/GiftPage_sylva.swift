import UIKit
import SnapKit

/// 礼物弹窗，复用礼盒背景素材展示顶部专属商品和两行普通礼物。
/// 设计思路：底部背景保持原始比例，内容按职责拆为购买栏和可复用卡片，业务由礼物状态管理类处理。
/// 关键属性：giftState_sylva 管理商品与选中状态，giftItems_sylva 保存需要响应通知的卡片。
class GiftPage_Sylva: UIViewController {
    private let giftState_sylva = GiftSelectionViewModel_sylva()
    private let dimControl_sylva = UIControl()
    private let backgroundImageView_sylva = UIImageView(image: UIImage(named: "gift_bg"))
    private let contentScrollView_sylva = UIScrollView()
    private let contentStack_sylva = UIStackView()
    private var contentTopConstraint_sylva: Constraint?
    private var giftItems_sylva: [(giftId_sylva: String?, view_sylva: GiftItemView_sylva)] = []

    /// 创建礼物弹窗并订阅选中状态，首次展示默认选中的礼物。
    /// 参数：无。返回值：Void。异常：无。
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        buildBackground_sylva()
        buildContent_sylva()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshSelection_sylva),
            name: GiftSelectionViewModel_sylva.stateDidChange_sylva,
            object: giftState_sylva
        )
        refreshSelection_sylva()
    }

    /// 根据背景实际宽度定位商品区，避免遮挡素材中的标题与礼盒。
    /// 参数：无。返回值：Void。异常：无。
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentTopConstraint_sylva?.update(offset: backgroundImageView_sylva.bounds.width * 500 / 750)
    }

    /// 释放页面时移除通知监听；无参数、无返回值、无异常。
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 创建全屏遮罩和底部等比例背景，遮罩点击交给项目导航关闭弹窗。
    /// 参数：无。返回值：Void。异常：无。
    private func buildBackground_sylva() {
        dimControl_sylva.backgroundColor = UIColor(hexstring_Sylva: "#000000", alpha_Sylva: 0.78)
        dimControl_sylva.isAccessibilityElement = true
        dimControl_sylva.accessibilityLabel = "Close gifts"
        dimControl_sylva.accessibilityTraits = .button
        dimControl_sylva.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            Navigation_Sylva.dismiss_Sylva(from: self)
        }, for: .touchUpInside)
        view.addSubview(dimControl_sylva)
        dimControl_sylva.snp.makeConstraints { make_sylva in
            make_sylva.edges.equalToSuperview()
        }

        backgroundImageView_sylva.contentMode = .scaleAspectFit
        backgroundImageView_sylva.isUserInteractionEnabled = false
        backgroundImageView_sylva.isAccessibilityElement = true
        backgroundImageView_sylva.accessibilityLabel = "Gift Giving Center"
        view.addSubview(backgroundImageView_sylva)
        backgroundImageView_sylva.snp.makeConstraints { make_sylva in
            make_sylva.centerX.bottom.equalToSuperview()
            make_sylva.width.equalToSuperview().priority(999)
            make_sylva.width.lessThanOrEqualTo(480)
            make_sylva.height.equalTo(backgroundImageView_sylva.snp.width).multipliedBy(1286.0 / 750.0)
        }

        // 绿色面板承接空白区域的触摸，避免点击标题时误触背后的关闭遮罩。
        let cardTouchArea_sylva = UIView()
        view.insertSubview(cardTouchArea_sylva, belowSubview: backgroundImageView_sylva)
        cardTouchArea_sylva.snp.makeConstraints { make_sylva in
            make_sylva.leading.trailing.bottom.equalTo(backgroundImageView_sylva)
            make_sylva.height.equalTo(backgroundImageView_sylva.snp.width).multipliedBy(866.0 / 750.0)
        }
    }

    /// 构建商品滚动区域，小屏幕可滚动查看所有礼物，卡片预留独立的赠送按钮位置。
    /// 参数：无。返回值：Void。异常：无。
    private func buildContent_sylva() {
        contentScrollView_sylva.showsVerticalScrollIndicator = false
        contentScrollView_sylva.contentInsetAdjustmentBehavior = .never
        view.addSubview(contentScrollView_sylva)
        contentScrollView_sylva.snp.makeConstraints { make_sylva in
            make_sylva.leading.trailing.bottom.equalTo(backgroundImageView_sylva)
            contentTopConstraint_sylva = make_sylva.top.equalTo(backgroundImageView_sylva.snp.top)
                .offset(view.bounds.width * 500 / 750).priority(999).constraint
            make_sylva.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.top)
        }

        contentStack_sylva.axis = .vertical
        contentStack_sylva.spacing = 27
        contentScrollView_sylva.addSubview(contentStack_sylva)
        contentStack_sylva.snp.makeConstraints { make_sylva in
            make_sylva.top.equalTo(contentScrollView_sylva.contentLayoutGuide)
            make_sylva.leading.equalTo(contentScrollView_sylva.contentLayoutGuide).offset(20)
            make_sylva.trailing.equalTo(contentScrollView_sylva.contentLayoutGuide).offset(-20)
            make_sylva.bottom.equalTo(contentScrollView_sylva.contentLayoutGuide).offset(-40)
            make_sylva.width.equalTo(contentScrollView_sylva.frameLayoutGuide).offset(-40)
        }

        if let topGift_sylva = giftState_sylva.topGift_sylva {
            let purchaseRow_sylva = makePurchaseRow_sylva(gift_sylva: topGift_sylva)
            contentStack_sylva.addArrangedSubview(purchaseRow_sylva)
            contentStack_sylva.setCustomSpacing(24, after: purchaseRow_sylva)
            purchaseRow_sylva.snp.makeConstraints { make_sylva in
                make_sylva.height.equalTo(48)
            }
        }

        for rowIndex_sylva in 0..<2 {
            let row_sylva = makeGiftRow_sylva(rowIndex_sylva: rowIndex_sylva)
            contentStack_sylva.addArrangedSubview(row_sylva)
            row_sylva.snp.makeConstraints { make_sylva in
                make_sylva.height.equalTo(118)
            }
        }
    }

    /// 创建顶部购买栏，以横向布局展示礼物、价格、一次性购买说明和购买按钮。
    /// - Parameter gift_sylva: 顶部专属礼物，价格由状态管理类格式化。
    /// - Returns: 已绑定购买事件的横向视图栈；无抛出异常。
    private func makePurchaseRow_sylva(gift_sylva: StoreModel_Sylva) -> UIStackView {
        let iconView_sylva = UIImageView(image: UIImage(named: "gift_one"))
        iconView_sylva.contentMode = .scaleAspectFit
        iconView_sylva.snp.makeConstraints { make_sylva in
            make_sylva.width.height.equalTo(48)
        }

        let priceLabel_sylva = UILabel()
        priceLabel_sylva.text = giftState_sylva.priceText_sylva(gift_sylva: gift_sylva)
        priceLabel_sylva.font = .systemFont(ofSize: 16, weight: .heavy)
        priceLabel_sylva.textColor = .black
        priceLabel_sylva.setContentCompressionResistancePriority(.required, for: .horizontal)

        let subtitleLabel_sylva = UILabel()
        subtitleLabel_sylva.text = "Can Only Be Purchased Once"
        subtitleLabel_sylva.font = .systemFont(ofSize: 10, weight: .regular)
        subtitleLabel_sylva.textColor = .black
        subtitleLabel_sylva.adjustsFontSizeToFitWidth = true
        subtitleLabel_sylva.minimumScaleFactor = 0.75
        subtitleLabel_sylva.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let buyButton_sylva = UIButton(type: .custom)
        buyButton_sylva.setTitle("BUY", for: .normal)
        buyButton_sylva.setTitleColor(UIColor(hexstring_Sylva: "#00B98D"), for: .normal)
        buyButton_sylva.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        buyButton_sylva.backgroundColor = .black
        buyButton_sylva.layer.cornerRadius = 21
        buyButton_sylva.layer.shadowColor = UIColor.black.cgColor
        buyButton_sylva.layer.shadowOpacity = 0.25
        buyButton_sylva.layer.shadowRadius = 3
        buyButton_sylva.layer.shadowOffset = CGSize(width: 0, height: 3)
        buyButton_sylva.accessibilityLabel = "Buy special gift"
        buyButton_sylva.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.giftState_sylva.purchaseGift_sylva(gift_sylva: gift_sylva) { [weak self] in
                guard let self else { return }
                Navigation_Sylva.dismiss_Sylva(from: self)
            }
        }, for: .touchUpInside)
        buyButton_sylva.snp.makeConstraints { make_sylva in
            make_sylva.width.equalTo(65)
            make_sylva.height.equalTo(42)
        }

        let row_sylva = UIStackView(arrangedSubviews: [iconView_sylva, priceLabel_sylva, subtitleLabel_sylva, buyButton_sylva])
        row_sylva.axis = .horizontal
        row_sylva.alignment = .center
        row_sylva.spacing = 8
        return row_sylva
    }

    /// 创建一行四列礼物卡片，将点击和购买事件转发给状态管理类。
    /// - Parameter rowIndex_sylva: 从零开始的行号，决定商品范围和礼物图标。
    /// - Returns: 等宽分布的横向视图栈；无抛出异常，缺失商品以透明空位展示。
    private func makeGiftRow_sylva(rowIndex_sylva: Int) -> UIStackView {
        let row_sylva = UIStackView()
        row_sylva.axis = .horizontal
        row_sylva.spacing = 13
        row_sylva.distribution = .fillEqually

        for columnIndex_sylva in 0..<4 {
            let giftIndex_sylva = rowIndex_sylva * 4 + columnIndex_sylva
            guard giftState_sylva.normalGifts_sylva.indices.contains(giftIndex_sylva) else {
                row_sylva.addArrangedSubview(UIView())
                continue
            }
            let gift_sylva = giftState_sylva.normalGifts_sylva[giftIndex_sylva]
            let item_sylva = GiftItemView_sylva(iconName_sylva: rowIndex_sylva == 0 ? "gift_two" : "gift_three")
            item_sylva.configure_sylva(
                quantity_sylva: giftState_sylva.quantityText_sylva(gift_sylva: gift_sylva),
                price_sylva: giftState_sylva.priceText_sylva(gift_sylva: gift_sylva)
            )
            item_sylva.onSelect_sylva = { [weak self] in
                self?.giftState_sylva.selectGift_sylva(gift_sylva: gift_sylva)
            }
            item_sylva.onGiveAway_sylva = { [weak self] in
                guard let self else { return }
                self.giftState_sylva.purchaseGift_sylva(gift_sylva: gift_sylva) { [weak self] in
                    guard let self else { return }
                    Navigation_Sylva.dismiss_Sylva(from: self)
                }
            }
            giftItems_sylva.append((giftId_sylva: gift_sylva.goodsId_Sylva, view_sylva: item_sylva))
            row_sylva.addArrangedSubview(item_sylva)
        }
        return row_sylva
    }

    /// 根据状态通知同步卡片描边、阴影和赠送按钮，不改变商品业务状态。
    /// 参数：无。返回值：Void。异常：无。
    @objc private func refreshSelection_sylva() {
        for item_sylva in giftItems_sylva {
            item_sylva.view_sylva.applySelection_sylva(
                isSelected_sylva: item_sylva.giftId_sylva == giftState_sylva.selectedGiftId_sylva
            )
        }
    }
}
