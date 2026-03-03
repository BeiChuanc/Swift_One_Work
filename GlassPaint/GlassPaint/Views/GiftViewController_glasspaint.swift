import Foundation
import UIKit
import SnapKit

// MARK: - 礼物界面视图控制器

/// 礼物界面视图控制器
/// 功能：展示礼物商品，支持选择和购买
/// 设计：模态弹起，底部对齐，背景图片
class GiftViewController_Glasspaint: UIViewController {
    
    // MARK: - 回调闭包
    
    /// 购买回调
    private var onPurchase_Glasspaint: ((StoreModel_Glasspaint) -> Void)?
    
    // MARK: - 数据属性
    
    /// 选中的礼物
    private var selectedGift_Glasspaint: StoreModel_Glasspaint?
    
    /// 礼物列表
    private var giftList_Glasspaint: [StoreModel_Glasspaint] = []
    
    /// 顶部礼物列表（goodIsTop为true）
    private var topGiftList_Glasspaint: [StoreModel_Glasspaint] = []
    
    /// 普通礼物列表（goodIsTop为false）
    private var normalGiftList_Glasspaint: [StoreModel_Glasspaint] = []
    
    // MARK: - UI组件
    
    /// 遮罩视图
    private let maskView_Glasspaint: UIView = {
        let view_Glasspaint = UIView()
        view_Glasspaint.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view_Glasspaint
    }()
    
    /// 容器视图
    private let containerView_Glasspaint: UIView = {
        let view_Glasspaint = UIView()
        view_Glasspaint.backgroundColor = .clear
        return view_Glasspaint
    }()
    
    /// 背景图片视图
    private let backgroundImageView_Glasspaint: UIImageView = {
        let imageView_Glasspaint = UIImageView()
        imageView_Glasspaint.image = UIImage(named: "gift_bg")
        imageView_Glasspaint.contentMode = .scaleToFill
        return imageView_Glasspaint
    }()
    
    /// 内容滚动视图
    private let scrollView_Glasspaint: UIScrollView = {
        let scrollView_Glasspaint = UIScrollView()
        scrollView_Glasspaint.showsVerticalScrollIndicator = false
        scrollView_Glasspaint.backgroundColor = .clear
        return scrollView_Glasspaint
    }()
    
    /// 内容容器
    private let contentView_Glasspaint: UIView = {
        let view_Glasspaint = UIView()
        view_Glasspaint.backgroundColor = .clear
        return view_Glasspaint
    }()
    
    /// 顶部组件容器
    private let topSectionView_Glasspaint: UIView = {
        let view_Glasspaint = UIView()
        view_Glasspaint.backgroundColor = .clear
        return view_Glasspaint
    }()
    
    /// 特殊优惠标题
    private let specialOfferLabel_Glasspaint: UILabel = {
        let label_Glasspaint = UILabel()
        label_Glasspaint.text = "Special offer gift"
        label_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label_Glasspaint.textColor = .white
        label_Glasspaint.textAlignment = .left
        return label_Glasspaint
    }()
    
    /// 顶部礼物容器
    private let topGiftsContainer_Glasspaint: UIView = {
        let view_Glasspaint = UIView()
        view_Glasspaint.backgroundColor = .clear
        return view_Glasspaint
    }()
    
    /// 普通礼物滚动视图
    private let normalGiftsScrollView_Glasspaint: UIScrollView = {
        let scrollView_Glasspaint = UIScrollView()
        scrollView_Glasspaint.backgroundColor = .clear
        scrollView_Glasspaint.showsHorizontalScrollIndicator = false
        scrollView_Glasspaint.showsVerticalScrollIndicator = false
        return scrollView_Glasspaint
    }()
    
    /// 普通礼物容器
    private let normalGiftsContainer_Glasspaint: UIView = {
        let view_Glasspaint = UIView()
        view_Glasspaint.backgroundColor = .clear
        return view_Glasspaint
    }()
    
    /// 购买按钮
    private let buyButton_Glasspaint: UIButton = {
        let button_Glasspaint = UIButton(type: .custom)
        button_Glasspaint.setImage(UIImage(named: "gift_buy"), for: .normal)
        button_Glasspaint.contentMode = .scaleAspectFill
        button_Glasspaint.imageView?.contentMode = .scaleToFill
        return button_Glasspaint
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onPurchase_Glasspaint: @escaping (StoreModel_Glasspaint) -> Void) {
        self.onPurchase_Glasspaint = onPurchase_Glasspaint
        super.init(nibName: nil, bundle: nil)
        
        // 设置模态样式
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGiftData_Glasspaint()
        setupUI_Glasspaint()
        setupConstraints_Glasspaint()
        setupGestures_Glasspaint()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - UI设置
    
    /// 加载礼物数据
    private func loadGiftData_Glasspaint() {
        giftList_Glasspaint = Store_Glasspaint.shared_Glasspaint.goodsList_Glasspaint
        
        // 分类礼物
        topGiftList_Glasspaint = giftList_Glasspaint.filter { $0.goodIsTop_Glasspaint == true }
        normalGiftList_Glasspaint = giftList_Glasspaint.filter { $0.goodIsTop_Glasspaint == false }
    }
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        view.backgroundColor = .clear
        
        // 遮罩视图
        view.addSubview(maskView_Glasspaint)
        
        // 容器视图
        view.addSubview(containerView_Glasspaint)
        
        // 背景图片
        containerView_Glasspaint.addSubview(backgroundImageView_Glasspaint)
        
        // 购买按钮（最底部）
        containerView_Glasspaint.addSubview(buyButton_Glasspaint)
        buyButton_Glasspaint.addTarget(self, action: #selector(handleBuyTap_Glasspaint), for: .touchUpInside)
        
        // 普通礼物滚动视图（购买按钮上方）
        containerView_Glasspaint.addSubview(normalGiftsScrollView_Glasspaint)
        normalGiftsScrollView_Glasspaint.addSubview(normalGiftsContainer_Glasspaint)
        setupNormalGiftsSection_Glasspaint()
        
        // 顶部组件（普通礼物上方）
        containerView_Glasspaint.addSubview(topSectionView_Glasspaint)
        setupTopSection_Glasspaint()
        
        // 初始禁用购买按钮
        buyButton_Glasspaint.alpha = 0.5
        buyButton_Glasspaint.isEnabled = false
    }
    
    /// 设置顶部组件
    private func setupTopSection_Glasspaint() {
        // 添加标题
        topSectionView_Glasspaint.addSubview(specialOfferLabel_Glasspaint)
        
        // 添加顶部礼物容器
        topSectionView_Glasspaint.addSubview(topGiftsContainer_Glasspaint)
        
        // 标题约束
        specialOfferLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
        }
        
        // 顶部礼物容器约束
        topGiftsContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(specialOfferLabel_Glasspaint.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(82)
            make.bottom.equalToSuperview()
        }
        
        // 创建顶部礼物视图（使用HStack布局）
        let giftIcons_glasspaint = ["gift_one", "gift_two", "gift_three"]
        let spacing_glasspaint: CGFloat = 8
        let itemCount_glasspaint = min(topGiftList_Glasspaint.count, 3)
        
        for i_glasspaint in 0..<itemCount_glasspaint {
            let gift_glasspaint = topGiftList_Glasspaint[i_glasspaint]
            let giftView_glasspaint = createTopGiftItemView_Glasspaint(
                gift_Glasspaint: gift_glasspaint,
                iconName_Glasspaint: giftIcons_glasspaint[i_glasspaint]
            )
            topGiftsContainer_Glasspaint.addSubview(giftView_glasspaint)
            
            giftView_glasspaint.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(topGiftsContainer_Glasspaint.snp.width).multipliedBy(1.0 / 3.0).offset(-spacing_glasspaint * 2 / 3)
                
                if i_glasspaint == 0 {
                    make.left.equalToSuperview()
                } else if i_glasspaint == itemCount_glasspaint - 1 {
                    make.right.equalToSuperview()
                } else {
                    make.centerX.equalToSuperview()
                }
            }
        }
    }
    
    /// 设置普通礼物组件（水平滚动）
    private func setupNormalGiftsSection_Glasspaint() {
        let giftIcon_glasspaint = "gift_four"
        let spacing_glasspaint: CGFloat = 8
        let itemWidth_glasspaint: CGFloat = 130
        
        for (index_glasspaint, gift_glasspaint) in normalGiftList_Glasspaint.enumerated() {
            let giftView_glasspaint = createHorizontalGiftItemView_Glasspaint(
                gift_Glasspaint: gift_glasspaint,
                iconName_Glasspaint: giftIcon_glasspaint
            )
            normalGiftsContainer_Glasspaint.addSubview(giftView_glasspaint)
            
            giftView_glasspaint.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(CGFloat(index_glasspaint) * (itemWidth_glasspaint + spacing_glasspaint))
                make.top.bottom.equalToSuperview()
                make.width.equalTo(itemWidth_glasspaint)
                make.height.equalTo(82)
            }
        }
        
        // 设置容器宽度
        let totalWidth_glasspaint = CGFloat(normalGiftList_Glasspaint.count) * itemWidth_glasspaint + CGFloat(normalGiftList_Glasspaint.count - 1) * spacing_glasspaint
        normalGiftsContainer_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(totalWidth_glasspaint)
        }
    }
    
    /// 创建礼物Item视图
    private func createGiftItemView_Glasspaint(
        gift_Glasspaint: StoreModel_Glasspaint,
        iconName_Glasspaint: String,
        imageSize_Glasspaint: CGFloat
    ) -> UIView {
        let containerView_glasspaint = UIView()
        containerView_glasspaint.backgroundColor = .white
        containerView_glasspaint.layer.cornerRadius = 20
        containerView_glasspaint.tag = gift_Glasspaint.id_Glasspaint ?? 0
        
        // 图标
        let iconView_glasspaint = UIImageView()
        iconView_glasspaint.image = UIImage(named: iconName_Glasspaint)
        iconView_glasspaint.contentMode = .scaleAspectFit
        containerView_glasspaint.addSubview(iconView_glasspaint)
        
        // 名称标签
        let nameLabel_glasspaint = UILabel()
        nameLabel_glasspaint.text = gift_Glasspaint.goodsName_Glasspaint
        nameLabel_glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        nameLabel_glasspaint.textColor = UIColor(hex: "2A374A")
        nameLabel_glasspaint.textAlignment = .center
        containerView_glasspaint.addSubview(nameLabel_glasspaint)
        
        // 价格标签
        let priceLabel_glasspaint = UILabel()
        priceLabel_glasspaint.text = gift_Glasspaint.goodsPrice_Glasspaint
        priceLabel_glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        priceLabel_glasspaint.textColor = UIColor(hex: "2A374A")
        priceLabel_glasspaint.textAlignment = .center
        containerView_glasspaint.addSubview(priceLabel_glasspaint)
        
        // 布局
        iconView_glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(imageSize_Glasspaint)
        }
        
        nameLabel_glasspaint.snp.makeConstraints { make in
            make.top.equalTo(iconView_glasspaint.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(4)
        }
        
        priceLabel_glasspaint.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_glasspaint.snp.bottom).offset(2)
            make.left.right.equalToSuperview().inset(4)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }
        
        // 添加点击手势
        let tapGesture_glasspaint = UITapGestureRecognizer(target: self, action: #selector(handleGiftItemTap_Glasspaint(_:)))
        containerView_glasspaint.addGestureRecognizer(tapGesture_glasspaint)
        
        return containerView_glasspaint
    }
    
    /// 创建顶部特殊礼物Item视图（VStack布局：图标+名字的HStack，然后价格）
    private func createTopGiftItemView_Glasspaint(
        gift_Glasspaint: StoreModel_Glasspaint,
        iconName_Glasspaint: String
    ) -> UIView {
        let containerView_glasspaint = UIView()
        containerView_glasspaint.backgroundColor = .white
        containerView_glasspaint.layer.cornerRadius = 20
        containerView_glasspaint.tag = gift_Glasspaint.id_Glasspaint ?? 0
        
        // 顶部容器（HStack：图标 + 名字）
        let topContainer_glasspaint = UIView()
        containerView_glasspaint.addSubview(topContainer_glasspaint)
        
        // 图标
        let iconView_glasspaint = UIImageView()
        iconView_glasspaint.image = UIImage(named: iconName_Glasspaint)
        iconView_glasspaint.contentMode = .scaleAspectFit
        topContainer_glasspaint.addSubview(iconView_glasspaint)
        
        // 名称标签
        let nameLabel_glasspaint = UILabel()
        nameLabel_glasspaint.text = gift_Glasspaint.goodsName_Glasspaint
        nameLabel_glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        nameLabel_glasspaint.textColor = UIColor(hex: "2A374A")
        nameLabel_glasspaint.textAlignment = .left
        topContainer_glasspaint.addSubview(nameLabel_glasspaint)
        
        // 价格标签
        let priceLabel_glasspaint = UILabel()
        priceLabel_glasspaint.text = gift_Glasspaint.goodsPrice_Glasspaint
        priceLabel_glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        priceLabel_glasspaint.textColor = UIColor(hex: "2A374A")
        priceLabel_glasspaint.textAlignment = .center
        containerView_glasspaint.addSubview(priceLabel_glasspaint)
        
        // 顶部容器约束
        topContainer_glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
        }
        
        // HStack布局：图标在左，名字在右
        iconView_glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
            make.top.bottom.equalToSuperview()
        }
        
        nameLabel_glasspaint.snp.makeConstraints { make in
            make.left.equalTo(iconView_glasspaint.snp.right).offset(5)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        // 价格标签约束（在顶部容器下方）
        priceLabel_glasspaint.snp.makeConstraints { make in
            make.top.equalTo(topContainer_glasspaint.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }
        
        // 添加点击手势
        let tapGesture_glasspaint = UITapGestureRecognizer(target: self, action: #selector(handleGiftItemTap_Glasspaint(_:)))
        containerView_glasspaint.addGestureRecognizer(tapGesture_glasspaint)
        
        return containerView_glasspaint
    }
    
    /// 创建水平礼物Item视图（HStack布局）
    private func createHorizontalGiftItemView_Glasspaint(
        gift_Glasspaint: StoreModel_Glasspaint,
        iconName_Glasspaint: String
    ) -> UIView {
        let containerView_glasspaint = UIView()
        containerView_glasspaint.backgroundColor = .white
        containerView_glasspaint.layer.cornerRadius = 20
        containerView_glasspaint.tag = gift_Glasspaint.id_Glasspaint ?? 0
        
        // 图标
        let iconView_glasspaint = UIImageView()
        iconView_glasspaint.image = UIImage(named: iconName_Glasspaint)
        iconView_glasspaint.contentMode = .scaleAspectFit
        containerView_glasspaint.addSubview(iconView_glasspaint)
        
        // 文本容器（VStack效果）
        let textContainer_glasspaint = UIView()
        containerView_glasspaint.addSubview(textContainer_glasspaint)
        
        // 名称标签
        let nameLabel_glasspaint = UILabel()
        nameLabel_glasspaint.text = gift_Glasspaint.goodsName_Glasspaint
        nameLabel_glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        nameLabel_glasspaint.textColor = UIColor(hex: "2A374A")
        nameLabel_glasspaint.textAlignment = .left
        textContainer_glasspaint.addSubview(nameLabel_glasspaint)
        
        // 价格标签
        let priceLabel_glasspaint = UILabel()
        priceLabel_glasspaint.text = gift_Glasspaint.goodsPrice_Glasspaint
        priceLabel_glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        priceLabel_glasspaint.textColor = UIColor(hex: "2A374A")
        priceLabel_glasspaint.textAlignment = .left
        textContainer_glasspaint.addSubview(priceLabel_glasspaint)
        
        // HStack布局：图标在左，文本容器在右
        iconView_glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        textContainer_glasspaint.snp.makeConstraints { make in
            make.left.equalTo(iconView_glasspaint.snp.right).offset(8)
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }
        
        // VStack布局：名称在上，价格在下
        nameLabel_glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        priceLabel_glasspaint.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_glasspaint.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        // 添加点击手势
        let tapGesture_glasspaint = UITapGestureRecognizer(target: self, action: #selector(handleGiftItemTap_Glasspaint(_:)))
        containerView_glasspaint.addGestureRecognizer(tapGesture_glasspaint)
        
        return containerView_glasspaint
    }
    
    /// 设置约束
    private func setupConstraints_Glasspaint() {
        let screenHeight_glasspaint = UIScreen.main.bounds.height
        let containerHeight_glasspaint = screenHeight_glasspaint * 0.65
        
        // 遮罩视图
        maskView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 容器视图
        containerView_Glasspaint.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(containerHeight_glasspaint)
        }
        
        // 背景图片
        backgroundImageView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 购买按钮（固定在最底部）
        buyButton_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(62)
        }
        
        // 普通礼物滚动视图（购买按钮上方）
        normalGiftsScrollView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(buyButton_Glasspaint.snp.top).offset(-10)
            make.height.equalTo(82)
        }
        
        // 顶部组件（普通礼物上方）
        topSectionView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(normalGiftsScrollView_Glasspaint.snp.top).offset(-10)
        }
    }
    
    /// 设置手势
    private func setupGestures_Glasspaint() {
        // 遮罩点击关闭
        let tapGesture_glasspaint = UITapGestureRecognizer(target: self, action: #selector(handleMaskTap_Glasspaint))
        maskView_Glasspaint.addGestureRecognizer(tapGesture_glasspaint)
    }
    
    // MARK: - 动画
    
    /// 弹出动画
    private func animateOut_Glasspaint(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
            self.containerView_Glasspaint.transform = CGAffineTransform(translationX: 0, y: self.containerView_Glasspaint.frame.height)
            self.view.alpha = 0
        } completion: { _ in
            completion()
        }
    }
    
    // MARK: - 事件处理
    
    /// 处理遮罩点击
    @objc private func handleMaskTap_Glasspaint() {
        dismissView_Glasspaint()
    }
    
    /// 处理礼物Item点击
    @objc private func handleGiftItemTap_Glasspaint(_ gesture: UITapGestureRecognizer) {
        guard let itemView_glasspaint = gesture.view else { return }
        let giftId_glasspaint = itemView_glasspaint.tag
        
        // 查找对应的礼物
        guard let gift_glasspaint = giftList_Glasspaint.first(where: { $0.id_Glasspaint == giftId_glasspaint }) else { return }
        
        // 更新选中状态
        selectedGift_Glasspaint = gift_glasspaint
        
        // 更新UI
        updateSelectionUI_Glasspaint(selectedView_glasspaint: itemView_glasspaint)
        
        // 启用购买按钮
        buyButton_Glasspaint.isEnabled = true
        UIView.animate(withDuration: 0.2) {
            self.buyButton_Glasspaint.alpha = 1.0
        }
    }
    
    /// 更新选中UI
    private func updateSelectionUI_Glasspaint(selectedView_glasspaint: UIView) {
        // 重置所有礼物视图
        [topGiftsContainer_Glasspaint, normalGiftsContainer_Glasspaint].forEach { container_glasspaint in
            container_glasspaint.subviews.forEach { subview_glasspaint in
                subview_glasspaint.backgroundColor = .white
            }
        }
        
        // 设置选中视图
        selectedView_glasspaint.backgroundColor = UIColor(hex: "D849A3").withAlphaComponent(0.3)
        
        // 添加缩放动画
        UIView.animate(withDuration: 0.1, animations: {
            selectedView_glasspaint.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                selectedView_glasspaint.transform = .identity
            }
        }
    }
    
    /// 处理购买按钮点击
    @objc private func handleBuyTap_Glasspaint() {
        guard let selectedGift_glasspaint = selectedGift_Glasspaint else { return }
        
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.buyButton_Glasspaint.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.buyButton_Glasspaint.transform = .identity
            }
        }
        
        // 调用购买回调
        onPurchase_Glasspaint?(selectedGift_glasspaint)
        
        // 关闭界面
        dismissView_Glasspaint()
    }
    
    /// 关闭视图
    private func dismissView_Glasspaint() {
        animateOut_Glasspaint { [weak self] in
            self?.dismiss(animated: false)
        }
    }
}

// MARK: - UIColor扩展

extension UIColor {
    
    /// 通过十六进制字符串创建颜色
    convenience init(hex: String) {
        var hexSanitized_glasspaint = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized_glasspaint = hexSanitized_glasspaint.replacingOccurrences(of: "#", with: "")
        
        var rgb_glasspaint: UInt64 = 0
        Scanner(string: hexSanitized_glasspaint).scanHexInt64(&rgb_glasspaint)
        
        let red_glasspaint = CGFloat((rgb_glasspaint & 0xFF0000) >> 16) / 255.0
        let green_glasspaint = CGFloat((rgb_glasspaint & 0x00FF00) >> 8) / 255.0
        let blue_glasspaint = CGFloat(rgb_glasspaint & 0x0000FF) / 255.0
        
        self.init(red: red_glasspaint, green: green_glasspaint, blue: blue_glasspaint, alpha: 1.0)
    }
}
