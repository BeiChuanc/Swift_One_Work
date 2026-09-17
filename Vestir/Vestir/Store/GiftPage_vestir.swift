import UIKit
import SnapKit

/// 礼物弹层：以底部贴边的全宽深色面板展示独立购买的顶级礼物和两行普通礼物。
/// 设计思路：页面仅负责布局与事件转发，商品选择和购买统一交给礼物视图模型。
/// 关键属性：视图模型保存选择状态，滚动容器适配较小屏幕，底部按钮购买当前普通礼物。
class GiftPage_Vestir: UIViewController {

    private let viewModel_vestir = GiftViewModel_vestir()
    private let dimView_vestir = UIView()
    private let panelView_vestir = UIView()
    private let backgroundImageView_vestir = UIImageView()
    private let scrollView_vestir = UIScrollView()
    private let contentStack_vestir = UIStackView()
    private let topGiftCard_vestir = TopGiftCard_vestir()
    private let gridStack_vestir = UIStackView()
    private let buyButton_vestir = UIButton(type: .system)
    private var giftItems_vestir: [GiftItemView_vestir] = []

    /// 初始化页面布局并监听礼物状态。
    /// 参数：无；返回值：无（Void）；异常：无。
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI_vestir()
        setupConstraints_vestir()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshSelection_vestir),
            name: GiftViewModel_vestir.stateDidChangeNotification_vestir,
            object: viewModel_vestir
        )
        refreshSelection_vestir()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 构建全宽面板、礼物组件和购买入口。
    /// 参数：无；返回值：无（Void）；异常：无。
    private func buildUI_vestir() {
        view.backgroundColor = .clear
        dimView_vestir.backgroundColor = UIColor(hexstring_Vestir: "#000000", alpha_Vestir: 0.5)
        dimView_vestir.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close_vestir)))
        view.addSubview(dimView_vestir)

        panelView_vestir.backgroundColor = UIColor(hexstring_Vestir: "#131313")
        panelView_vestir.layer.cornerRadius = 28
        panelView_vestir.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        panelView_vestir.clipsToBounds = true
        view.addSubview(panelView_vestir)

        // 背景图按面板宽度铺开，保留标题比例；面板底色延续图片底色。
        backgroundImageView_vestir.image = UIImage(named: "gift_bg")?.withRenderingMode(.alwaysOriginal)
        backgroundImageView_vestir.contentMode = .scaleAspectFit
        panelView_vestir.addSubview(backgroundImageView_vestir)

        scrollView_vestir.showsVerticalScrollIndicator = false
        scrollView_vestir.alwaysBounceVertical = false
        scrollView_vestir.contentInsetAdjustmentBehavior = .never
        panelView_vestir.addSubview(scrollView_vestir)
        contentStack_vestir.axis = .vertical
        contentStack_vestir.spacing = 12
        scrollView_vestir.addSubview(contentStack_vestir)

        topGiftCard_vestir.configure_vestir(gift_vestir: viewModel_vestir.topGift_vestir)
        topGiftCard_vestir.onBuy_vestir = { [weak self] in
            self?.viewModel_vestir.purchaseTopGift_vestir { [weak self] in
                self?.close_vestir()
            }
        }
        contentStack_vestir.addArrangedSubview(topGiftCard_vestir)
        gridStack_vestir.axis = .vertical
        gridStack_vestir.spacing = 12
        gridStack_vestir.distribution = .fillEqually
        contentStack_vestir.addArrangedSubview(gridStack_vestir)
        buildGiftGrid_vestir()

        buyButton_vestir.setTitle("BUY GIFT", for: .normal)
        buyButton_vestir.setTitleColor(.white, for: .normal)
        buyButton_vestir.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        buyButton_vestir.backgroundColor = UIColor(hexstring_Vestir: "#6155D9")
        buyButton_vestir.layer.cornerRadius = 22
        buyButton_vestir.addAction(UIAction { [weak self] _ in
            self?.viewModel_vestir.purchaseSelectedGift_vestir { [weak self] in
                self?.close_vestir()
            }
        }, for: .touchUpInside)
        panelView_vestir.addSubview(buyButton_vestir)
    }

    /// 将普通礼物渲染为两行四列，空位保持透明以对齐列宽。
    /// 参数：无；返回值：无（Void）；异常：商品不足时显示已有商品。
    private func buildGiftGrid_vestir() {
        for rowIndex_vestir in 0..<2 {
            let rowStack_vestir = UIStackView()
            rowStack_vestir.axis = .horizontal
            rowStack_vestir.spacing = 8
            rowStack_vestir.distribution = .fillEqually
            gridStack_vestir.addArrangedSubview(rowStack_vestir)

            for columnIndex_vestir in 0..<4 {
                let itemIndex_vestir = rowIndex_vestir * 4 + columnIndex_vestir
                guard itemIndex_vestir < viewModel_vestir.normalGifts_vestir.count else {
                    rowStack_vestir.addArrangedSubview(UIView())
                    continue
                }
                let gift_vestir = viewModel_vestir.normalGifts_vestir[itemIndex_vestir]
                let itemView_vestir = GiftItemView_vestir(
                    gift_vestir: gift_vestir,
                    iconName_vestir: rowIndex_vestir == 0 ? "gift_two" : "gift_three"
                )
                itemView_vestir.addAction(UIAction { [weak self] _ in
                    self?.viewModel_vestir.selectGift_vestir(gift_vestir: gift_vestir)
                }, for: .touchUpInside)
                giftItems_vestir.append(itemView_vestir)
                rowStack_vestir.addArrangedSubview(itemView_vestir)
            }
        }
    }

    /// 设置左右及底部贴边的弹层约束，购买按钮避开底部安全区；高度不足时礼物区域滚动。
    /// 参数：无；返回值：无（Void）；异常：无。
    private func setupConstraints_vestir() {
        dimView_vestir.snp.makeConstraints { make_vestir in
            make_vestir.edges.equalToSuperview()
        }
        panelView_vestir.snp.makeConstraints { make_vestir in
            make_vestir.leading.trailing.bottom.equalToSuperview()
            // 内容区维持原高度，面板背景自然延伸至底部安全区。
            make_vestir.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-448).priority(750)
            make_vestir.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.top).offset(12)
        }
        backgroundImageView_vestir.snp.makeConstraints { make_vestir in
            make_vestir.top.leading.trailing.equalToSuperview()
            make_vestir.height.equalTo(backgroundImageView_vestir.snp.width).multipliedBy(870.0 / 750.0)
        }
        scrollView_vestir.snp.makeConstraints { make_vestir in
            make_vestir.top.equalToSuperview().offset(50)
            make_vestir.leading.trailing.equalTo(panelView_vestir.safeAreaLayoutGuide).inset(16)
            make_vestir.bottom.equalTo(buyButton_vestir.snp.top).offset(-16)
        }
        contentStack_vestir.snp.makeConstraints { make_vestir in
            make_vestir.edges.equalTo(scrollView_vestir.contentLayoutGuide)
            make_vestir.width.equalTo(scrollView_vestir.frameLayoutGuide)
        }
        topGiftCard_vestir.snp.makeConstraints { make_vestir in
            make_vestir.height.equalTo(64)
        }
        gridStack_vestir.snp.makeConstraints { make_vestir in
            make_vestir.height.equalTo(236)
        }
        buyButton_vestir.snp.makeConstraints { make_vestir in
            make_vestir.leading.trailing.equalTo(panelView_vestir.safeAreaLayoutGuide).inset(24)
            make_vestir.height.equalTo(44)
            make_vestir.bottom.equalTo(panelView_vestir.safeAreaLayoutGuide.snp.bottom).offset(-18)
        }
    }

    /// 将模型的选择状态同步到普通礼物卡片和购买按钮。
    /// 参数：无；返回值：无（Void）；异常：尚未选择礼物时显示默认按钮文案。
    @objc private func refreshSelection_vestir() {
        let selectedId_vestir = viewModel_vestir.selectedGift_vestir?.goodsId_Vestir
        giftItems_vestir.forEach { item_vestir in
            item_vestir.isSelected = selectedId_vestir != nil && item_vestir.gift_vestir.goodsId_Vestir == selectedId_vestir
        }
        if let price_vestir = viewModel_vestir.selectedGift_vestir?.goodsPrice_Vestir {
            buyButton_vestir.setTitle("BUY GIFT · \(price_vestir)", for: .normal)
        } else {
            buyButton_vestir.setTitle("BUY GIFT", for: .normal)
        }
    }

    /// 通过项目导航管理器关闭礼物弹层。
    /// 参数：无；返回值：无（Void）；异常：无。
    @objc private func close_vestir() {
        Navigation_Vestir.dismiss_Vestir(from: self)
    }
}
