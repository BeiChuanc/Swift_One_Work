import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Sprig: NSObject {
    
    /// 单例
    static let shared_Sprig = Store_Sprig()
    
    // 礼物商品列表
    var goodsList_Sprig: [StoreModel_Sprig] = [
        // 顶部商品
        StoreModel_Sprig(
            id_Sprig: 0,
            goodsId_Sprig: "wanderbell.gift.1x.1_9_s",
            goodsName_Sprig: "1x",
            goodsPrice_Sprig: "$1.99",
            goodIsTop_Sprig: true,
        ),
        StoreModel_Sprig(
            id_Sprig: 1,
            goodsId_Sprig: "wanderbell.gift.2x.2_9_s",
            goodsName_Sprig: "2x",
            goodsPrice_Sprig: "$2.99",
            goodIsTop_Sprig: true,
        ),
        StoreModel_Sprig(
            id_Sprig: 2,
            goodsId_Sprig: "wanderbell.gift.3x.3_9_s",
            goodsName_Sprig: "3x",
            goodsPrice_Sprig: "$4.99",
            goodIsTop_Sprig: true,
        ),
        // 中部商品
        StoreModel_Sprig(
            id_Sprig: 3,
            goodsId_Sprig: "wanderbell.gift.1x.1_9",
            goodsName_Sprig: "1x",
            goodsPrice_Sprig: "$1.99",
            goodIsLimit_Sprig: true
        ),
        StoreModel_Sprig(
            id_Sprig: 4,
            goodsId_Sprig: "wanderbell.gift.2x.2_9",
            goodsName_Sprig: "2x",
            goodsPrice_Sprig: "$2.99",
            goodIsLimit_Sprig: true
        ),
        StoreModel_Sprig(
            id_Sprig: 5,
            goodsId_Sprig: "wanderbell.gift.3x.3_9",
            goodsName_Sprig: "3x",
            goodsPrice_Sprig: "$3.99",
            goodIsLimit_Sprig: true
        ),
        // 底部商品
        StoreModel_Sprig(
            id_Sprig: 6,
            goodsId_Sprig: "wanderbell.gift.4x.4_9",
            goodsName_Sprig: "4x",
            goodsPrice_Sprig: "$4.99",
        ),
        StoreModel_Sprig(
            id_Sprig: 7,
            goodsId_Sprig: "wanderbell.gift.5x.6_9",
            goodsName_Sprig: "5x",
            goodsPrice_Sprig: "$6.99",
        ),
        StoreModel_Sprig(
            id_Sprig: 8,
            goodsId_Sprig: "wanderbell.gift.7x.9_9",
            goodsName_Sprig: "7x",
            goodsPrice_Sprig: "$9.99",
        ),
        StoreModel_Sprig(
            id_Sprig: 9,
            goodsId_Sprig: "wanderbell.gift.12x.19_9",
            goodsName_Sprig: "12x",
            goodsPrice_Sprig: "$19.99",
        ),
        StoreModel_Sprig(
            id_Sprig: 10,
            goodsId_Sprig: "wanderbell.gift.20x.29_9",
            goodsName_Sprig: "20x",
            goodsPrice_Sprig: "$29.99",
        ),
        StoreModel_Sprig(
            id_Sprig: 11,
            goodsId_Sprig: "wanderbell.gift.42x.49_9",
            goodsName_Sprig: "42x",
            goodsPrice_Sprig: "$49.99",
        ),
        StoreModel_Sprig(
            id_Sprig: 12,
            goodsId_Sprig: "wanderbell.gift.64x.69_9",
            goodsName_Sprig: "64x",
            goodsPrice_Sprig: "$69.99",
        ),
        StoreModel_Sprig(
            id_Sprig: 13,
            goodsId_Sprig: "wanderbell.gift.102x.99_9",
            goodsName_Sprig: "102x",
            goodsPrice_Sprig: "$99.99",
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Sprig {
    
    // 内购商品
    func PurchaseStoreGift_Sprig(gid_Sprig: String, completion_Sprig: @escaping() -> Void) {
        Utils_Sprig.showLoading_Sprig()
        
        let products: Set = [gid_Sprig]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Sprig) { SKPaymentTransaction in
                Utils_Sprig.dismissLoading_Sprig()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Sprig.showSuccess_Sprig(message_Sprig: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Sprig()
                }else{
                    print("取消支付")
                    Utils_Sprig.showError_Sprig(message_Sprig: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Sprig.showError_Sprig(message_Sprig: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Sprig.showError_Sprig(message_Sprig: "Invalid product information")
        }
    }
    
}
