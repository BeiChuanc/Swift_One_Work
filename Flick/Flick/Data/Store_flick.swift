import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Flick: NSObject {
    
    /// 单例
    static let shared_Flick = Store_Flick()
    
    // 礼物商品列表
    var goodsList_Flick: [StoreModel_Flick] = [
        // 顶部商品
        StoreModel_Flick(
            id_Flick: 0,
            goodsId_Flick: "wanderbell.gift.1x.1_9_s",
            goodsName_Flick: "1x",
            goodsPrice_Flick: "$1.99",
            goodIsTop_Flick: true,
        ),
        StoreModel_Flick(
            id_Flick: 1,
            goodsId_Flick: "wanderbell.gift.2x.2_9_s",
            goodsName_Flick: "2x",
            goodsPrice_Flick: "$2.99",
            goodIsTop_Flick: true,
        ),
        StoreModel_Flick(
            id_Flick: 2,
            goodsId_Flick: "wanderbell.gift.3x.3_9_s",
            goodsName_Flick: "3x",
            goodsPrice_Flick: "$4.99",
            goodIsTop_Flick: true,
        ),
        // 中部商品
        StoreModel_Flick(
            id_Flick: 3,
            goodsId_Flick: "wanderbell.gift.1x.1_9",
            goodsName_Flick: "1x",
            goodsPrice_Flick: "$1.99",
            goodIsLimit_Flick: true
        ),
        StoreModel_Flick(
            id_Flick: 4,
            goodsId_Flick: "wanderbell.gift.2x.2_9",
            goodsName_Flick: "2x",
            goodsPrice_Flick: "$2.99",
            goodIsLimit_Flick: true
        ),
        StoreModel_Flick(
            id_Flick: 5,
            goodsId_Flick: "wanderbell.gift.3x.3_9",
            goodsName_Flick: "3x",
            goodsPrice_Flick: "$3.99",
            goodIsLimit_Flick: true
        ),
        // 底部商品
        StoreModel_Flick(
            id_Flick: 6,
            goodsId_Flick: "wanderbell.gift.4x.4_9",
            goodsName_Flick: "4x",
            goodsPrice_Flick: "$4.99",
        ),
        StoreModel_Flick(
            id_Flick: 7,
            goodsId_Flick: "wanderbell.gift.5x.6_9",
            goodsName_Flick: "5x",
            goodsPrice_Flick: "$6.99",
        ),
        StoreModel_Flick(
            id_Flick: 8,
            goodsId_Flick: "wanderbell.gift.7x.9_9",
            goodsName_Flick: "7x",
            goodsPrice_Flick: "$9.99",
        ),
        StoreModel_Flick(
            id_Flick: 9,
            goodsId_Flick: "wanderbell.gift.12x.19_9",
            goodsName_Flick: "12x",
            goodsPrice_Flick: "$19.99",
        ),
        StoreModel_Flick(
            id_Flick: 10,
            goodsId_Flick: "wanderbell.gift.20x.29_9",
            goodsName_Flick: "20x",
            goodsPrice_Flick: "$29.99",
        ),
        StoreModel_Flick(
            id_Flick: 11,
            goodsId_Flick: "wanderbell.gift.42x.49_9",
            goodsName_Flick: "42x",
            goodsPrice_Flick: "$49.99",
        ),
        StoreModel_Flick(
            id_Flick: 12,
            goodsId_Flick: "wanderbell.gift.64x.69_9",
            goodsName_Flick: "64x",
            goodsPrice_Flick: "$69.99",
        ),
        StoreModel_Flick(
            id_Flick: 13,
            goodsId_Flick: "wanderbell.gift.102x.99_9",
            goodsName_Flick: "102x",
            goodsPrice_Flick: "$99.99",
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Flick {
    
    // 内购商品
    func PurchaseStoreGift_Flick(gid_Flick: String, completion_Flick: @escaping() -> Void) {
        Utils_Flick.showLoading_Flick()
        
        let products: Set = [gid_Flick]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Flick) { SKPaymentTransaction in
                Utils_Flick.dismissLoading_Flick()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Flick.showSuccess_Flick(message_Flick: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Flick()
                }else{
                    print("取消支付")
                    Utils_Flick.showError_Flick(message_Flick: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Flick.showError_Flick(message_Flick: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Flick.showError_Flick(message_Flick: "Invalid product information")
        }
    }
    
}
