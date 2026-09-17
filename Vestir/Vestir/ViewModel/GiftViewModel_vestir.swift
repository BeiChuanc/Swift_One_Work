import Foundation

/// 礼物页面状态管理器，负责筛选商品、维护选中礼物并复用现有内购流程。
/// 设计思路：页面仅订阅状态通知和展示数据，商品来源与支付实现统一使用现有商店服务。
/// 关键属性：顶级礼物、最多八个普通礼物以及当前选中礼物；关键方法负责选择与购买。
@MainActor
final class GiftViewModel_vestir: NSObject {

    /// 礼物选择状态发生变化时发送的通知，通知对象为当前状态管理器。
    static let stateDidChangeNotification_vestir = Notification.Name("GiftStateDidChange_vestir")

    /// 当前商店中的顶级一次性礼物。
    let topGift_vestir: StoreModel_Vestir?

    /// 普通礼物保留现有商品顺序，最多显示两行四列。
    let normalGifts_vestir: [StoreModel_Vestir]

    /// 当前选中的普通礼物，未选择时为空。
    private(set) var selectedGift_vestir: StoreModel_Vestir?

    /// 从现有商店服务中读取礼物商品并排除订阅商品。
    /// 参数：无。
    /// 返回值：新建的礼物状态管理器；不会抛出异常。
    override init() {
        let gifts_vestir = Subscribe_Vestir.shared_Vestir.goodsList_Vestir.filter { gift_vestir in
            !(gift_vestir.goodIsVIP_Vestir ?? false)
        }
        topGift_vestir = gifts_vestir.first { gift_vestir in
            gift_vestir.goodIsTop_Vestir ?? false
        }
        normalGifts_vestir = Array(gifts_vestir.filter { gift_vestir in
            !(gift_vestir.goodIsTop_Vestir ?? false)
        }.prefix(8))
        super.init()
    }

    /// 更新当前选中礼物，避免重复发送相同选择的状态通知。
    /// 参数：gift_vestir 为用户点击的礼物商品。
    /// 返回值：无；不会抛出异常。
    func selectGift_vestir(gift_vestir: StoreModel_Vestir) {
        guard selectedGift_vestir !== gift_vestir else { return }
        selectedGift_vestir = gift_vestir
        notifyStateChange_vestir()
    }

    /// 购买当前选中礼物，未选择时沿用现有英文提示。
    /// 参数：completion_vestir 为支付成功后的回调，页面可据此关闭弹层。
    /// 返回值：无；支付失败提示由现有商店服务处理，不会抛出异常。
    func purchaseSelectedGift_vestir(completion_vestir: @escaping () -> Void) {
        guard let gift_vestir = selectedGift_vestir else {
            Utils_Vestir.showWarning_Vestir(message_Vestir: "Please select a gift first")
            return
        }
        purchaseGift_vestir(gift_vestir: gift_vestir, completion_vestir: completion_vestir)
    }

    /// 直接购买顶级礼物，独立于普通礼物的选中状态。
    /// 参数：completion_vestir 为顶级礼物支付成功后的回调。
    /// 返回值：无；缺少商品时显示英文提示，支付失败由现有商店服务处理。
    func purchaseTopGift_vestir(completion_vestir: @escaping () -> Void) {
        guard let gift_vestir = topGift_vestir else {
            Utils_Vestir.showWarning_Vestir(message_Vestir: "This gift is currently unavailable")
            return
        }
        purchaseGift_vestir(gift_vestir: gift_vestir, completion_vestir: completion_vestir)
    }

    /// 校验商品标识后将购买交给项目现有内购服务。
    /// 参数：
    /// - gift_vestir：待购买的礼物商品。
    /// - completion_vestir：仅支付成功时调用的回调。
    /// 返回值：无；商品标识缺失时显示英文提示，不发起支付，也不会抛出异常。
    private func purchaseGift_vestir(
        gift_vestir: StoreModel_Vestir,
        completion_vestir: @escaping () -> Void
    ) {
        guard let goodsID_vestir = gift_vestir.goodsId_Vestir, !goodsID_vestir.isEmpty else {
            Utils_Vestir.showWarning_Vestir(message_Vestir: "This gift is currently unavailable")
            return
        }
        Subscribe_Vestir.shared_Vestir.PurchaseStoreGift_Vestir(
            gid_Vestir: goodsID_vestir,
            completion_Vestir: completion_vestir
        )
    }

    /// 通知页面刷新选中状态，通知对象用于区分不同页面实例。
    /// 参数：无。
    /// 返回值：无；不会抛出异常。
    private func notifyStateChange_vestir() {
        NotificationCenter.default.post(
            name: Self.stateDidChangeNotification_vestir,
            object: self
        )
    }
}
