import Foundation
import UIKit
import SnapKit

/// 送礼界面
/// 功能：展示礼物商品列表、支持内购
/// 设计：背景图、文字贴图标题、商品网格布局
class Gift_Wanderbell: UIViewController {
    
    // MARK: - 属性
    
    /// 选中的商品
    private var selectedProduct_Wanderbell: StoreModel_Wanderbell?
    
    /// 选中的视图（用于显示蒙层）
    private var selectedView_Wanderbell: UIView?
    
    /// 礼物商品ID到图片名称的映射
    private let giftImageMapping_Wanderbell: [String: String] = [
        "wanderbell.gift.x2.1_9": "gift_1",
        "wanderbell.gift.x3.3_9": "gift_2",
        "wanderbell.gift.x5.4_9": "gift_3",
        "wanderbell.gift.x1.1_9": "gift_4",
        "wanderbell.gift.x2.2_9": "gift_5",
        "wanderbell.gift.x3.3_9_s": "gift_6",
        "wanderbell.gift.x4.4_9": "gift_7",
        "wanderbell.gift.x5.5_9": "gift_8",
        "wanderbell.gift.x10.9_9": "gift_9",
        "wanderbell.gift.x20.19_9": "gift_10",
        "wanderbell.gift.x30.29_9": "gift_11",
        "wanderbell.gift.x50.49_9": "gift_12",
        "wanderbell.gift.x70.69_9": "gift_13",
        "wanderbell.gift.x100.99_9": "gift_14"
    ]
    
    // MARK: - UI组件
    
    /// 背景图片
    private let backgroundImageView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(named: "gift_bg")
        imageView_wanderbell.contentMode = .scaleToFill
        imageView_wanderbell.clipsToBounds = true
        return imageView_wanderbell
    }()
    
    /// 滚动容器
    private let scrollView_Wanderbell: UIScrollView = {
        let scrollView_wanderbell = UIScrollView()
        scrollView_wanderbell.showsVerticalScrollIndicator = false
        scrollView_wanderbell.backgroundColor = .clear
        return scrollView_wanderbell
    }()
    
    private let contentView_Wanderbell = UIView()
    
    /// Ordinary文字贴图
    private let ordinaryTextImageView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(named: "ordinary_text")
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    /// 特殊礼物容器
    private let specialGiftsContainer_Wanderbell: UIStackView = {
        let stack_wanderbell = UIStackView()
        stack_wanderbell.axis = .horizontal
        stack_wanderbell.distribution = .fillEqually
        stack_wanderbell.spacing = 12
        return stack_wanderbell
    }()
    
    /// Special文字贴图
    private let specialTextImageView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(named: "special_text")
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    /// 普通礼物滚动容器
    private let ordinaryScrollView_Wanderbell: UIScrollView = {
        let scrollView_wanderbell = UIScrollView()
        scrollView_wanderbell.showsVerticalScrollIndicator = false
        scrollView_wanderbell.showsHorizontalScrollIndicator = true
        scrollView_wanderbell.backgroundColor = .clear
        return scrollView_wanderbell
    }()
    
    private let ordinaryContentView_Wanderbell = UIView()
    
    /// 普通礼物容器
    private let ordinaryGiftsContainer_Wanderbell: UIStackView = {
        let stack_wanderbell = UIStackView()
        stack_wanderbell.axis = .horizontal
        stack_wanderbell.distribution = .equalSpacing
        stack_wanderbell.spacing = 12
        return stack_wanderbell
    }()
    
    /// 购买按钮
    private let buyButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .custom)
        button_wanderbell.setImage(UIImage(named: "gift_buy"), for: .normal)
        button_wanderbell.imageView?.contentMode = .scaleAspectFit
        return button_wanderbell
    }()
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Wanderbell()
        setupConstraints_Wanderbell()
        setupActions_Wanderbell()
        loadGiftData_Wanderbell()
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Wanderbell() {
        view.backgroundColor = .clear
        
        view.addSubview(backgroundImageView_Wanderbell)
        view.addSubview(scrollView_Wanderbell)
        view.addSubview(buyButton_Wanderbell)
        
        scrollView_Wanderbell.addSubview(contentView_Wanderbell)
        contentView_Wanderbell.addSubview(ordinaryTextImageView_Wanderbell)
        contentView_Wanderbell.addSubview(specialGiftsContainer_Wanderbell)
        contentView_Wanderbell.addSubview(specialTextImageView_Wanderbell)
        contentView_Wanderbell.addSubview(ordinaryScrollView_Wanderbell)
        
        ordinaryScrollView_Wanderbell.addSubview(ordinaryContentView_Wanderbell)
        ordinaryContentView_Wanderbell.addSubview(ordinaryGiftsContainer_Wanderbell)
    }
    
    /// 设置约束
    private func setupConstraints_Wanderbell() {
        backgroundImageView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(buyButton_Wanderbell.snp.top).offset(-20)
        }
        
        contentView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }
        
        ordinaryTextImageView_Wanderbell.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(140)
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(40)
            make.width.lessThanOrEqualTo(200)
        }
        
        specialGiftsContainer_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(ordinaryTextImageView_Wanderbell.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(85)
        }
        
        specialTextImageView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(specialGiftsContainer_Wanderbell.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(40)
            make.width.lessThanOrEqualTo(200)
        }
        
        ordinaryScrollView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(specialTextImageView_Wanderbell.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(85)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        ordinaryContentView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(ordinaryScrollView_Wanderbell)
        }
        
        ordinaryGiftsContainer_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        buyButton_Wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(APPSCREEN_Wanderbell.WIDTH_Wanderbell - 20)
            make.height.equalTo(65)
        }
    }
    
    /// 设置事件
    private func setupActions_Wanderbell() {
        buyButton_Wanderbell.addTarget(self, action: #selector(buyButtonTapped_Wanderbell), for: .touchUpInside)
    }
    
    // MARK: - 数据加载
    
    /// 加载礼物数据
    private func loadGiftData_Wanderbell() {
        let allGifts_wanderbell = Store_Wanderbell.shared_Wanderbell.goodsList_Wanderbell
        
        var firstView_wanderbell: UIView?
        
        // 筛选特殊礼物（goodIsSpecial_Wanderbell 为 true 的商品，显示3个）
        let specialGifts_wanderbell = allGifts_wanderbell.filter { $0.goodIsSpecial_Wanderbell == true }
        for (index_wanderbell, gift_wanderbell) in specialGifts_wanderbell.prefix(3).enumerated() {
            let giftView_wanderbell = createGiftItemView_Wanderbell(gift: gift_wanderbell)
            specialGiftsContainer_Wanderbell.addArrangedSubview(giftView_wanderbell)
            
            // 保存第一个视图用于默认选中
            if index_wanderbell == 0 {
                firstView_wanderbell = giftView_wanderbell
            }
        }
        
        // 剩余的11个商品（横向滚动展示）
        let ordinaryGifts_wanderbell = allGifts_wanderbell.filter { $0.goodIsSpecial_Wanderbell != true }
        for gift_wanderbell in ordinaryGifts_wanderbell.prefix(11) {
            let giftView_wanderbell = createGiftItemView_Wanderbell(gift: gift_wanderbell)
            ordinaryGiftsContainer_Wanderbell.addArrangedSubview(giftView_wanderbell)
        }
        
        // 默认选中第一个特殊礼物
        if let firstGift_wanderbell = specialGifts_wanderbell.first,
           let firstView_wanderbell = firstView_wanderbell {
            selectedProduct_Wanderbell = firstGift_wanderbell
            selectedView_Wanderbell = firstView_wanderbell
            
            // 添加黄色边框
            firstView_wanderbell.layer.borderWidth = 3
            firstView_wanderbell.layer.cornerRadius = 25
            firstView_wanderbell.layer.borderColor = UIColor.systemYellow.cgColor
        }
    }
    
    /// 创建礼物项视图
    /// 参数：
    /// - gift: 礼物模型
    /// 返回值：礼物视图
    private func createGiftItemView_Wanderbell(gift: StoreModel_Wanderbell) -> UIView {
        let containerView_wanderbell = UIView()
        containerView_wanderbell.backgroundColor = .clear
        containerView_wanderbell.layer.cornerRadius = 25
        containerView_wanderbell.layer.borderWidth = 0
        containerView_wanderbell.layer.borderColor = UIColor.clear.cgColor
        
        // 礼物图片
        let giftImageView_wanderbell = UIImageView()
        // 使用礼物商品ID从映射字典中获取图片名称
        if let goodsId_wanderbell = gift.goodsId_Wanderbell,
           let imageName_wanderbell = giftImageMapping_Wanderbell[goodsId_wanderbell] {
            giftImageView_wanderbell.image = UIImage(named: imageName_wanderbell)
        }
        giftImageView_wanderbell.contentMode = .scaleAspectFill
        giftImageView_wanderbell.clipsToBounds = true
        giftImageView_wanderbell.layer.cornerRadius = 15
        containerView_wanderbell.addSubview(giftImageView_wanderbell)
        
        // 布局
        giftImageView_wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3) // 留出边框空间
            make.width.equalTo(104)
            make.height.equalTo(72)
        }
        
        containerView_wanderbell.snp.makeConstraints { make in
            make.width.equalTo(110)
            make.height.equalTo(78)
        }
        
        // 点击手势
        let tapGesture_wanderbell = UITapGestureRecognizer(target: self, action: #selector(giftItemTapped_Wanderbell(_:)))
        containerView_wanderbell.addGestureRecognizer(tapGesture_wanderbell)
        containerView_wanderbell.tag = gift.id_Wanderbell ?? 0
        
        return containerView_wanderbell
    }
    
    // MARK: - 事件处理
    
    /// 礼物项点击
    @objc private func giftItemTapped_Wanderbell(_ gesture: UITapGestureRecognizer) {
        guard let tappedView_wanderbell = gesture.view else { return }
        
        let giftId_wanderbell = tappedView_wanderbell.tag
        selectedProduct_Wanderbell = Store_Wanderbell.shared_Wanderbell.goodsList_Wanderbell.first { $0.id_Wanderbell == giftId_wanderbell }
        
        // 更新所有视图的选中状态
        updateSelectionState_Wanderbell(selectedView: tappedView_wanderbell)
        
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .light)
        generator_wanderbell.impactOccurred()
    }
    
    /// 更新选中状态
    /// 参数：
    /// - selectedView: 选中的视图
    private func updateSelectionState_Wanderbell(selectedView: UIView) {
        // 移除之前选中视图的黄色边框
        if let previousView_wanderbell = selectedView_Wanderbell {
            previousView_wanderbell.layer.borderWidth = 0
            previousView_wanderbell.layer.borderColor = UIColor.clear.cgColor
        }
        
        // 添加当前选中视图的黄色边框
        selectedView.layer.borderWidth = 3
        selectedView.layer.borderColor = UIColor.systemYellow.cgColor
        
        // 保存选中的视图
        selectedView_Wanderbell = selectedView
    }
    
    /// 购买按钮点击
    @objc private func buyButtonTapped_Wanderbell() {
        guard let product_wanderbell = selectedProduct_Wanderbell,
              let productId_wanderbell = product_wanderbell.goodsId_Wanderbell else {
            Utils_Wanderbell.showWarning_Wanderbell(message_wanderbell: "Please select a gift")
            return
        }
        
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .medium)
        generator_wanderbell.impactOccurred()
        
        // 执行内购
        Store_Wanderbell.shared_Wanderbell.PurchaseStoreGift_Wanderbell(gid_Wanderbell: productId_wanderbell) {
            // 购买成功后关闭页面
            self.dismiss(animated: true, completion: nil)
        }
    }
}
