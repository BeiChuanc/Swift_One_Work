import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Clara: NSObject {
    
    /// 单例
    static let shared_Clara = Store_Clara()
    
    // 礼物商品列表
    var goodsList_Clara: [StoreModel_Clara] = [
        // 顶部商品
        StoreModel_Clara(
            id_Clara: 0,
            goodsId_Clara: "wanderbell.gift.1x.1_9_s",
            goodsName_Clara: "1x",
            goodsPrice_Clara: "$1.99",
            goodIsTop_Clara: true,
        ),
        StoreModel_Clara(
            id_Clara: 1,
            goodsId_Clara: "wanderbell.gift.2x.2_9_s",
            goodsName_Clara: "2x",
            goodsPrice_Clara: "$2.99",
            goodIsTop_Clara: true,
        ),
        StoreModel_Clara(
            id_Clara: 2,
            goodsId_Clara: "wanderbell.gift.3x.3_9_s",
            goodsName_Clara: "3x",
            goodsPrice_Clara: "$4.99",
            goodIsTop_Clara: true,
        ),
        // 中部商品
        StoreModel_Clara(
            id_Clara: 3,
            goodsId_Clara: "wanderbell.gift.1x.1_9",
            goodsName_Clara: "1x",
            goodsPrice_Clara: "$1.99",
            goodIsLimit_Clara: true
        ),
        StoreModel_Clara(
            id_Clara: 4,
            goodsId_Clara: "wanderbell.gift.2x.2_9",
            goodsName_Clara: "2x",
            goodsPrice_Clara: "$2.99",
            goodIsLimit_Clara: true
        ),
        StoreModel_Clara(
            id_Clara: 5,
            goodsId_Clara: "wanderbell.gift.3x.3_9",
            goodsName_Clara: "3x",
            goodsPrice_Clara: "$3.99",
            goodIsLimit_Clara: true
        ),
        // 底部商品
        StoreModel_Clara(
            id_Clara: 6,
            goodsId_Clara: "wanderbell.gift.4x.4_9",
            goodsName_Clara: "4x",
            goodsPrice_Clara: "$4.99",
        ),
        StoreModel_Clara(
            id_Clara: 7,
            goodsId_Clara: "wanderbell.gift.5x.6_9",
            goodsName_Clara: "5x",
            goodsPrice_Clara: "$6.99",
        ),
        StoreModel_Clara(
            id_Clara: 8,
            goodsId_Clara: "wanderbell.gift.7x.9_9",
            goodsName_Clara: "7x",
            goodsPrice_Clara: "$9.99",
        ),
        StoreModel_Clara(
            id_Clara: 9,
            goodsId_Clara: "wanderbell.gift.12x.19_9",
            goodsName_Clara: "12x",
            goodsPrice_Clara: "$19.99",
        ),
        StoreModel_Clara(
            id_Clara: 10,
            goodsId_Clara: "wanderbell.gift.20x.29_9",
            goodsName_Clara: "20x",
            goodsPrice_Clara: "$29.99",
        ),
        StoreModel_Clara(
            id_Clara: 11,
            goodsId_Clara: "wanderbell.gift.42x.49_9",
            goodsName_Clara: "42x",
            goodsPrice_Clara: "$49.99",
        ),
        StoreModel_Clara(
            id_Clara: 12,
            goodsId_Clara: "wanderbell.gift.64x.69_9",
            goodsName_Clara: "64x",
            goodsPrice_Clara: "$69.99",
        ),
        StoreModel_Clara(
            id_Clara: 13,
            goodsId_Clara: "wanderbell.gift.102x.99_9",
            goodsName_Clara: "102x",
            goodsPrice_Clara: "$99.99",
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Clara {
    
    // 内购商品
    func PurchaseStoreGift_Clara(gid_Clara: String, completion_Clara: @escaping() -> Void) {
        Utils_Clara.showLoading_Clara()
        
        let products: Set = [gid_Clara]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Clara) { SKPaymentTransaction in
                Utils_Clara.dismissLoading_Clara()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Clara.showSuccess_Clara(message_Clara: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Clara()
                }else{
                    print("取消支付")
                    Utils_Clara.showError_Clara(message_Clara: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Clara.showError_Clara(message_Clara: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Clara.showError_Clara(message_Clara: "Invalid product information")
        }
    }
    
}
