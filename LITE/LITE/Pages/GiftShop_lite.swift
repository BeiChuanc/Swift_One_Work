import SwiftUI

// MARK: - 礼物商店
// 核心作用：展示和购买礼物商品
// 设计思路：参考UI设计，分层展示特价礼物和推荐礼物
// 关键功能：商品展示、选择购买

/// 礼物商店页面
struct GiftShop_lite: View {
    
    // MARK: - 属性
    
    @Environment(\.dismiss) private var dismiss_lite
    @State private var selectedGoods_lite: StoreModel_lite?
    
    init() {
        // 设置所有 ViewController 的背景为透明
        let appearance_lite = UINavigationBarAppearance()
        appearance_lite.configureWithTransparentBackground()
        appearance_lite.backgroundColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance_lite
        UINavigationBar.appearance().scrollEdgeAppearance = appearance_lite
    }
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 透明背景层（点击关闭）
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    dismiss_lite()
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                // 背景图片
                Image("gift_bg")
                    .resizable()
                    .frame(
                        width: UIScreen.main.bounds.width,
                        height: UIScreen.main.bounds.height - 200
                    )
                    .clipped()
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
            
            // 所有组件底部对齐，间隔10
            VStack(alignment: .trailing, spacing: 10.h_lite) {
                // 右上角特价区域
                discountedGiftsSection_lite
                
                // 推荐礼物区域
                recommendedGiftsSection_lite
                
                // 购买按钮
                buyButtonView_lite
            }
            .padding(.bottom, 40.h_lite)
        }
        .background(Color.clear)
        .presentationBackground(Color.clear)
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .hudOverlay_lite()
        .toastOverlay_lite()
        .onAppear {
            // 设置窗口背景为透明
            DispatchQueue.main.async {
                if let windowScene_lite = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window_lite = windowScene_lite.windows.first {
                    window_lite.backgroundColor = .clear
                }
            }
        }
    }
    
    // MARK: - 特价礼物区域
    
    /// 特价礼物区域（右对齐的VStack）
    private var discountedGiftsSection_lite: some View {
        VStack(alignment: .trailing, spacing: 10.h_lite) {
            // discount图片
            Image("discount")
                .resizable()
                .scaledToFit()
                .frame(width: 174.w_lite, height: 27.h_lite)
            
            // 横向显示特价商品（固定宽度72）
            HStack(spacing: 5.w_lite) {
                ForEach(Store_lite.shared_lite.goodsList_lite.filter { $0.goodIsTop_lite == true }.prefix(3), id: \.id_lite) { goods_lite in
                    giftItemView_lite(goods_lite: goods_lite, iconName_lite: "gift_one")
                        .frame(width: 72.w_lite)
                }
            }
            .frame(height: 75.h_lite)
            .padding(.trailing, 5.w_lite)
        }
        .padding(.trailing, 20.w_lite)
    }
    
    // MARK: - 推荐礼物区域
    
    /// 推荐礼物区域（左对齐的VStack）
    private var recommendedGiftsSection_lite: some View {
        VStack(alignment: .leading, spacing: 10.h_lite) {
            // recommend图片
            Image("recommend")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width - 30.w_lite, height: 27.h_lite)
                .padding(.leading, 15.w_lite)
            
            // 获取推荐商品（除去goodIsTop_lite为true的数据，应该有11个）
            let recommendedGoods_lite = Store_lite.shared_lite.goodsList_lite.filter {
                $0.goodIsTop_lite == false
            }
            
            VStack(spacing: 10.h_lite) {
                // 第一行：前4个使用gift_two
                if recommendedGoods_lite.count >= 4 {
                    HStack(spacing: 5.w_lite) {
                        ForEach(Array(recommendedGoods_lite.prefix(4).enumerated()), id: \.element.id_lite) { index, goods in
                            giftItemView_lite(goods_lite: goods, iconName_lite: "gift_two")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 82.h_lite)
                    .padding(.horizontal, 5.w_lite)
                }
                
                // 第二行：接着4个使用gift_three
                if recommendedGoods_lite.count >= 8 {
                    HStack(spacing: 5.w_lite) {
                        ForEach(Array(recommendedGoods_lite.dropFirst(4).prefix(4).enumerated()), id: \.element.id_lite) { index, goods in
                            giftItemView_lite(goods_lite: goods, iconName_lite: "gift_three")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 82.h_lite)
                    .padding(.horizontal, 5.w_lite)
                }
                
                // 第三行：最后3个使用gift_four
                if recommendedGoods_lite.count >= 11 {
                    HStack(spacing: 5.w_lite) {
                        ForEach(Array(recommendedGoods_lite.dropFirst(8).prefix(3).enumerated()), id: \.element.id_lite) { index, goods in
                            giftItemView_lite(goods_lite: goods, iconName_lite: "gift_four")
                                .frame(maxWidth: .infinity)
                        }
                        
                        // 占位空白保持4列布局
                        Color.clear
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: 82.h_lite)
                    .padding(.horizontal, 5.w_lite)
                }
            }
        }
        .padding(.horizontal, 15.w_lite)
    }
    
    // MARK: - 礼物Item视图
    
    /// 礼物Item视图
    /// 布局：VStack，图片和名称为HStack间隔5，价格独立显示
    /// 背景：白色圆角20，选中时浅紫色767BE1
    private func giftItemView_lite(goods_lite: StoreModel_lite, iconName_lite: String) -> some View {
        let isSelected_lite = selectedGoods_lite?.id_lite == goods_lite.id_lite
        
        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedGoods_lite = goods_lite
            }
            
            let generator_lite = UIImpactFeedbackGenerator(style: .medium)
            generator_lite.impactOccurred()
        }) {
            VStack(spacing: 5.h_lite) {
                // 上部：礼物图片和名称（HStack）
                HStack(spacing: 5.w_lite) {
                    // 礼物图标
                    Image(iconName_lite)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36.w_lite, height: 36.h_lite)
                    
                    // 商品名称
                    Text(goods_lite.goodsName_lite ?? "")
                        .font(.system(size: 9.sp_lite, weight: .bold))
                        .foregroundColor(Color(hex: "333333"))
                }
                
                // 下部：价格
                Text(goods_lite.goodsPrice_lite ?? "")
                    .font(.system(size: 12.sp_lite, weight: .bold))
                    .foregroundColor(Color(hex: "333333"))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20.w_lite)
                    .fill(isSelected_lite ? Color(hex: "767BE1") : Color.white)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 购买按钮视图
    
    /// 购买按钮视图（使用gift_buy图片）
    private var buyButtonView_lite: some View {
        Button(action: {
            handlePurchase_lite()
        }) {
            Image("gift_nuy")
                .resizable()
                .scaledToFit()
                .frame(
                    width: UIScreen.main.bounds.width - 30.w_lite,
                    height: 48.h_lite
                )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(selectedGoods_lite == nil)
        .opacity(selectedGoods_lite == nil ? 0.5 : 1.0)
        .padding(.horizontal, 15.w_lite)
    }
    
    // MARK: - 购买处理方法
    
    /// 处理购买操作
    /// 功能：验证选中商品并调用购买流程
    private func handlePurchase_lite() {
        guard let goods_lite = selectedGoods_lite else {
            Utils_lite.showError_lite(message_lite: "Please select a gift")
            return
        }
        
        // 调用商店购买方法
        Store_lite.shared_lite.PurchaseStoreGift_lite(
            gid_lite: goods_lite.goodsId_lite ?? ""
        ) {
            // 购买成功回调
            print("✅ 礼物购买成功：\(goods_lite.goodsName_lite ?? "")")
            
            // 重置选中状态
            withAnimation {
                selectedGoods_lite = nil
            }
            
            // 关闭页面
            dismiss_lite()
        }
    }
}
