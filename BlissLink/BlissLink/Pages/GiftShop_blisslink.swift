import SwiftUI

// MARK: - 礼物商店
// 核心作用：展示和购买礼物商品
// 设计思路：分层展示不同类型商品（特价、限时、常规），提供清晰的购买入口
// 关键功能：商品展示、分类筛选、购买操作

/// 礼物商店页面
struct GiftShop_blisslink: View {
    
    // MARK: - 属性
    
    @Environment(\.presentationMode) var presentationMode_blisslink
    @State private var selectedGoods_blisslink: StoreModel_blisslink?
    
    // MARK: - 初始化
    
    init() {
        // 设置所有 ViewController 的背景为透明
        let appearance_blisslink = UINavigationBarAppearance()
        appearance_blisslink.configureWithTransparentBackground()
        appearance_blisslink.backgroundColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance_blisslink
        UINavigationBar.appearance().scrollEdgeAppearance = appearance_blisslink
    }
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // 清除默认背景
            Color.clear
                .ignoresSafeArea()
            
            // 背景图
            backgroundView_blisslink
            
            // 礼物布局
            giftLayoutView_blisslink
            
            // 购买按钮
            buyButtonView_blisslink
        }
        .background(Color.clear)
        .presentationBackground(Color.clear)
        .ignoresSafeArea()
        .hudOverlay_blisslink()
        .toastOverlay_blisslink()
        .onAppear {
            // 设置窗口背景为透明
            DispatchQueue.main.async {
                if let windowScene_blisslink = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window_blisslink = windowScene_blisslink.windows.first {
                    window_blisslink.backgroundColor = .clear
                }
            }
        }
    }
    
    // MARK: - 背景视图
    
    /// 背景视图
    /// 功能：展示礼物商店背景图
    /// 高度：屏幕高度的80%，从顶部开始显示
    private var backgroundView_blisslink: some View {
        VStack(spacing: 0) {
            Image("gift_bg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.8)
                .clipped()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
    
    // MARK: - 礼物布局视图
    
    /// 礼物布局视图
    /// 功能：垂直布局展示所有礼物分类
    /// 从下往上间距：20
    private var giftLayoutView_blisslink: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 20) {
                // 特价区域（顶部商品）
                topGiftsRow_blisslink
                    .frame(height: 78)
                
                // 限时商品区域
                limitedGiftsRow_blisslink
                    .frame(height: 78)
                
                // 常规商品网格
                regularGiftsGrid_blisslink
            }
            
            // 底部间距（为购买按钮留出空间）
            Spacer()
                .frame(height: 116) // 62(按钮高度) + 34(底部距离) + 20(间距)
        }
    }
    
    // MARK: - 特价区域
    
    /// 特价区域（顶部商品）
    /// 功能：展示special_off标签和两个顶部商品
    /// 布局：HStack，左侧特价标签，右侧两个商品，右上角关闭按钮
    private var topGiftsRow_blisslink: some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 12) {
                // 特价标签
                Image("special_off")
                    .resizable()
                    .frame(width: 170, height: 32)
                
                // 获取顶部商品
                ForEach(Store_blisslink.shared_blisslink.goodsList_blisslink.filter { $0.goodIsTop_blisslink == true }.prefix(2), id: \.id_blisslink) { goods_blisslink in
                    giftItemView_blisslink(goods_blisslink: goods_blisslink, iconName_blisslink: "gift_one")
                }
            }
            .padding(.horizontal, 20)
            
            // 关闭按钮
            Button(action: {
                presentationMode_blisslink.wrappedValue.dismiss()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 36, height: 36)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }
            .padding(.trailing, 20)
            .padding(.top, -50)
        }
    }
    
    // MARK: - 限时商品区域
    
    /// 限时商品区域
    /// 功能：展示限时购买的商品
    /// 布局：HStack均分，goodIsSpecial_blisslink为true的商品
    private var limitedGiftsRow_blisslink: some View {
        HStack(spacing: 12) {
            // 获取限时商品（goodIsSpecial_blisslink在Store_blisslink中对应goodIsLimit_blisslink参数）
            ForEach(Store_blisslink.shared_blisslink.goodsList_blisslink.filter { $0.goodIsSpecial_blisslink == true }, id: \.id_blisslink) { goods_blisslink in
                giftItemView_blisslink(goods_blisslink: goods_blisslink, iconName_blisslink: "gift_two")
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 常规商品网格
    
    /// 常规商品网格
    /// 功能：展示常规商品，4列2行布局
    /// 第一行：gift_three图标
    /// 第二行：gift_four图标
    private var regularGiftsGrid_blisslink: some View {
        VStack(spacing: 12) {
            // 获取常规商品（既不是顶部也不是限时）
            let regularGoods_blisslink = Store_blisslink.shared_blisslink.goodsList_blisslink.filter { 
                $0.goodIsTop_blisslink == false && $0.goodIsSpecial_blisslink == false 
            }
            
            // 第一行 - gift_three
            HStack(spacing: 12) {
                ForEach(Array(regularGoods_blisslink.prefix(4).enumerated()), id: \.element.id_blisslink) { index_blisslink, goods_blisslink in
                    giftItemView_blisslink(goods_blisslink: goods_blisslink, iconName_blisslink: "gift_three")
                }
            }
            .frame(height: 78)
            
            // 第二行 - gift_four
            HStack(spacing: 12) {
                ForEach(Array(regularGoods_blisslink.dropFirst(4).prefix(4).enumerated()), id: \.element.id_blisslink) { index_blisslink, goods_blisslink in
                    giftItemView_blisslink(goods_blisslink: goods_blisslink, iconName_blisslink: "gift_four")
                }
            }
            .frame(height: 78)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 礼物Item视图
    
    /// 礼物Item视图
    /// 功能：展示单个礼物商品信息
    /// 参数：
    ///   - goods_blisslink: 商品模型
    ///   - iconName_blisslink: 礼物图标名称
    /// 布局：白色圆角背景，垂直布局，上部HStack（图标+名称），下部价格
    private func giftItemView_blisslink(goods_blisslink: StoreModel_blisslink, iconName_blisslink: String) -> some View {
        let isSelected_blisslink = selectedGoods_blisslink?.id_blisslink == goods_blisslink.id_blisslink
        
        return Button(action: {
            selectedGoods_blisslink = goods_blisslink
        }) {
            VStack(spacing: 6) {
                // 上部：图标和商品名称
                HStack(spacing: 4) {
                    Image(iconName_blisslink)
                        .resizable()
                        .frame(width: 36, height: 36)
                    
                    Text(goods_blisslink.goodsName_blisslink ?? "")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(isSelected_blisslink ? .white : Color(hex: "005A64"))
                }
                
                // 下部：价格
                Text(goods_blisslink.goodsPrice_blisslink ?? "")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isSelected_blisslink ? .white.opacity(0.9) : Color(hex: "005A64"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 5)
            .background(isSelected_blisslink ? Color(hex: "00C68D") : Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected_blisslink ? Color(hex: "00C68D") : Color.clear, lineWidth: 2)
            )
            .shadow(color: isSelected_blisslink ? Color(hex: "00C68D").opacity(0.4) : Color.clear, radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - 购买按钮视图
    
    /// 购买按钮视图
    /// 功能：触发购买操作
    /// 尺寸：水平间距16，高度62，距离底部34
    private var buyButtonView_blisslink: some View {
        VStack {
            Spacer()
            
            Button(action: {
                handlePurchase_blisslink()
            }) {
                Image("gift_buy")
                    .resizable()
                    .frame(height: 62)
                    .padding(.horizontal, 16)
            }
            .padding(.bottom, 34)
        }
    }
    
    // MARK: - 购买处理方法
    
    /// 处理购买操作
    /// 功能：验证选中商品并调用购买流程
    /// 异常：未选中商品时提示用户
    private func handlePurchase_blisslink() {
        guard let goods_blisslink = selectedGoods_blisslink else {
            Utils_blisslink.showError_blisslink(message_blisslink: "Please select a gift")
            return
        }
        
        // 调用商店购买方法
        Store_blisslink.shared_blisslink.PurchaseStoreGift_blisslink(
            gid_blisslink: goods_blisslink.goodsId_blisslink ?? ""
        ) {
            // 购买成功回调
            print("礼物购买成功：\(goods_blisslink.goodsName_blisslink ?? "")")
            selectedGoods_blisslink = nil
        }
    }
}
