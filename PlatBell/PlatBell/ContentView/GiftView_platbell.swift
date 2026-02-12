import SwiftUI

// MARK: - 礼物界面组件
// 核心作用：展示礼物选择界面，支持礼物选择和赠送
// 设计思路：底部弹出式界面 + 礼物列表展示 + 选中效果
// 关键功能：礼物选择、礼物赠送、界面关闭

/// 礼物界面
struct GiftView_platbell: View {
    
    /// 是否显示
    @Binding var isPresented_platbell: Bool
    
    /// 选中的礼物
    @State private var selectedGift_platbell: StoreModel_platbell?
    
    /// 礼物列表
    @State private var giftList_platbell: [StoreModel_platbell] = []
    
    /// 屏幕宽度
    private let screenWidth_platbell = ScreenSize_platbell.shared_platbell.width_platbell
    
    /// 屏幕高度
    private let screenHeight_platbell = ScreenSize_platbell.shared_platbell.height_platbell
    
    var body: some View {
        ZStack {
            // 背景遮罩层
            Color.black
                .opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    closeGiftView_platbell()
                }
            
            // 礼物内容区域
            VStack(spacing: 0) {
                Spacer()
                
                ZStack(alignment: .bottom) {
                    // 背景图片
                    Image("gift_bg")
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenWidth_platbell, height: screenHeight_platbell * 0.6)
                        .clipped()
                    
                    // 内容区域（从下往上排列）
                    VStack(alignment: .center, spacing: 25) {
                        Spacer()
                        
                        // 特殊礼物区域
                        specialGiftSection_platbell
                        
                        // 普通礼物区域
                        ordinaryGiftSection_platbell
                        
                        // 购买按钮
                        buyButton_platbell
                            .padding(.bottom, 50)
                    }
                    .frame(width: screenWidth_platbell, height: screenHeight_platbell * 0.6)
                }
                .frame(width: screenWidth_platbell, height: screenHeight_platbell * 0.6)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .onAppear {
            loadGiftData_platbell()
        }
    }
    
    // MARK: - 特殊礼物区域
    
    /// 特殊礼物区域
    private var specialGiftSection_platbell: some View {
        VStack(alignment: .center, spacing: 10) {
            // 标题图片
            Image("gift_special")
                .resizable()
                .scaledToFit()
                .frame(width: screenWidth_platbell - 32, height: 40)
            
            // 礼物列表
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 10) {
                    ForEach(Array(specialGiftList_platbell.enumerated()), id: \.element.id_platbell) { index_platbell, gift_platbell in
                        GiftItemView_platbell(
                            gift_platbell: gift_platbell,
                            giftImage_platbell: getSpecialGiftImage_platbell(at: index_platbell),
                            isSelected_platbell: selectedGift_platbell?.id_platbell == gift_platbell.id_platbell,
                            onTap_platbell: {
                                selectGift_platbell(gift_platbell)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 78)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - 普通礼物区域
    
    /// 普通礼物区域
    private var ordinaryGiftSection_platbell: some View {
        VStack(alignment: .center, spacing: 10) {
            // 标题图片
            Image("gift_ordinary")
                .resizable()
                .scaledToFit()
                .frame(width: screenWidth_platbell - 32, height: 40)
            
            // 礼物列表
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(ordinaryGiftList_platbell, id: \.id_platbell) { gift_platbell in
                        GiftItemView_platbell(
                            gift_platbell: gift_platbell,
                            giftImage_platbell: "gift_four",
                            isSelected_platbell: selectedGift_platbell?.id_platbell == gift_platbell.id_platbell,
                            onTap_platbell: {
                                selectGift_platbell(gift_platbell)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 82)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - 购买按钮
    
    /// 购买按钮
    private var buyButton_platbell: some View {
        Button(action: {
            handleBuyAction_platbell()
        }) {
            Image("gift_buy")
                .resizable()
                .scaledToFit()
                .frame(width: screenWidth_platbell - 32, height: 62)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - 计算属性
    
    /// 特殊礼物列表
    private var specialGiftList_platbell: [StoreModel_platbell] {
        giftList_platbell.filter { $0.goodIsTop_platbell == true }
    }
    
    /// 普通礼物列表
    private var ordinaryGiftList_platbell: [StoreModel_platbell] {
        giftList_platbell.filter { $0.goodIsTop_platbell == false }
    }
    
    // MARK: - 业务方法
    
    /// 加载礼物数据
    private func loadGiftData_platbell() {
        giftList_platbell = Store_platbell.shared_platbell.goodsList_platbell
    }
    
    /// 获取特殊礼物图标
    /// - Parameter index_platbell: 特殊礼物索引
    /// - Returns: 图标名称
    private func getSpecialGiftImage_platbell(at index_platbell: Int) -> String {
        let images_platbell = ["gift_one", "gift_two", "gift_three"]
        return images_platbell[index_platbell % images_platbell.count]
    }
    
    /// 选择礼物
    private func selectGift_platbell(_ gift_platbell: StoreModel_platbell) {
        withAnimation(AnimationPresets_platbell.quickSpring_platbell) {
            if selectedGift_platbell?.id_platbell == gift_platbell.id_platbell {
                selectedGift_platbell = nil
            } else {
                selectedGift_platbell = gift_platbell
            }
        }
        
        // 震动反馈
        let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .light)
        impactFeedback_platbell.impactOccurred()
    }
    
    /// 处理购买操作
    private func handleBuyAction_platbell() {
        guard let gift_platbell = selectedGift_platbell else {
            // 提示：请先选择礼物
            Utils_platbell.showWarning_platbell(
                message_platbell: "Please select a gift",
                delay_platbell: 1.5
            )
            return
        }
        
        // 执行购买逻辑
        print("Buy gift: \(gift_platbell.goodsName_platbell ?? ""), price: \(gift_platbell.goodsPrice_platbell ?? "")")
        
        // 调用内购方法
        if let goodsId_platbell = gift_platbell.goodsId_platbell {
            Store_platbell.shared_platbell.PurchaseStoreGift_platbell(gid_platbell: goodsId_platbell) {
                // 购买成功后的回调
                print("Purchase completed successfully")
            }
        }
        
        // 震动反馈
        let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback_platbell.impactOccurred()
    }
    
    /// 关闭礼物界面
    private func closeGiftView_platbell() {
        withAnimation(AnimationPresets_platbell.standardSpring_platbell) {
            isPresented_platbell = false
        }
    }
}

// MARK: - 礼物Item组件

/// 礼物Item组件
struct GiftItemView_platbell: View {
    
    /// 礼物数据
    let gift_platbell: StoreModel_platbell
    
    /// 礼物图标
    let giftImage_platbell: String
    
    /// 是否选中
    let isSelected_platbell: Bool
    
    /// 点击回调
    let onTap_platbell: () -> Void
    
    var body: some View {
        Button(action: onTap_platbell) {
            VStack(spacing: 5) {
                // 礼物图片和名称横向排列
                HStack(spacing: 10) {
                    // 礼物图片
                    Image(giftImage_platbell)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 42, height: 42)
                    
                    // 礼物名称
                    Text(gift_platbell.goodsName_platbell ?? "")
                        .font(.system(size: 14))
                        .foregroundColor(isSelected_platbell ? .white : Color(hex: "FC00FF"))
                }
                
                // 礼物价格
                Text(gift_platbell.goodsPrice_platbell ?? "")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isSelected_platbell ? .white : Color(hex: "FC00FF"))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected_platbell
                            ? Color(hex: "FC00FF").opacity(0.2)
                            : Color.white
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

