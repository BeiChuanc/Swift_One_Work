import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Wanderbell: NSObject {
    
    /// 单例
    static let shared_Wanderbell = Store_Wanderbell()
    
    // 礼物商品列表
    var goodsList_Wanderbell: [StoreModel_Wanderbell] = [
        StoreModel_Wanderbell(
            id_Wanderbell: 0,
            goodsId_Wanderbell: "wanderbell.gift.x2.1_9",
            goodsName_Wanderbell: "x2",
            goodsPrice_Wanderbell: "$1.99",
            goodIsTop_Wanderbell: false,
            goodIsLimit_Wanderbell: true
        ),
        StoreModel_Wanderbell(
            id_Wanderbell: 1,
            goodsId_Wanderbell: "wanderbell.gift.x3.3_9",
            goodsName_Wanderbell: "x3",
            goodsPrice_Wanderbell: "$3.99",
            goodIsTop_Wanderbell: false,
            goodIsLimit_Wanderbell: true
        ),
        StoreModel_Wanderbell(
            id_Wanderbell: 2,
            goodsId_Wanderbell: "wanderbell.gift.x5.4_9",
            goodsName_Wanderbell: "x5",
            goodsPrice_Wanderbell: "$4.99",
            goodIsTop_Wanderbell: false,
            goodIsLimit_Wanderbell: true
        ),
        StoreModel_Wanderbell(
            id_Wanderbell: 3,
            goodsId_Wanderbell: "wanderbell.gift.x1.1_9",
            goodsName_Wanderbell: "x1",
            goodsPrice_Wanderbell: "$1.99",
            goodIsTop_Wanderbell: false,
            goodIsLimit_Wanderbell: false
        ),
        StoreModel_Wanderbell(
            id_Wanderbell: 4,
            goodsId_Wanderbell: "wanderbell.gift.x2.2_9",
            goodsName_Wanderbell: "x2",
            goodsPrice_Wanderbell: "$2.99",
            goodIsTop_Wanderbell: false,
            goodIsLimit_Wanderbell: false
        ),
        StoreModel_Wanderbell(
            id_Wanderbell: 5,
            goodsId_Wanderbell: "wanderbell.gift.x3.3_9_s",
            goodsName_Wanderbell: "x3",
            goodsPrice_Wanderbell: "$3.99",
            goodIsTop_Wanderbell: false,
            goodIsLimit_Wanderbell: false
        ),
        StoreModel_Wanderbell(
            id_Wanderbell: 6,
            goodsId_Wanderbell: "wanderbell.gift.x4.4_9",
            goodsName_Wanderbell: "x4",
            goodsPrice_Wanderbell: "$4.99",
            goodIsTop_Wanderbell: false,
            goodIsLimit_Wanderbell: false
        ),
        StoreModel_Wanderbell(
            id_Wanderbell: 7,
            goodsId_Wanderbell: "wanderbell.gift.x5.6_9",
            goodsName_Wanderbell: "x5",
            goodsPrice_Wanderbell: "$6.99",
            goodIsTop_Wanderbell: false,
            goodIsLimit_Wanderbell: false
        ),
        StoreModel_Wanderbell(
            id_Wanderbell: 8,
            goodsId_Wanderbell: "wanderbell.gift.x10.9_9",
            goodsName_Wanderbell: "x10",
            goodsPrice_Wanderbell: "$9.99",
            goodIsTop_Wanderbell: false,
            goodIsLimit_Wanderbell: false
        ),
        StoreModel_Wanderbell(
            id_Wanderbell: 9,
            goodsId_Wanderbell: "wanderbell.gift.x20.19_9",
            goodsName_Wanderbell: "x20",
            goodsPrice_Wanderbell: "$19.99",
            goodIsTop_Wanderbell: false,
            goodIsLimit_Wanderbell: false
        ),
        StoreModel_Wanderbell(
            id_Wanderbell: 10,
            goodsId_Wanderbell: "wanderbell.gift.x30.29_9",
            goodsName_Wanderbell: "x30",
            goodsPrice_Wanderbell: "$29.99",
            goodIsTop_Wanderbell: false,
            goodIsLimit_Wanderbell: false
        ),
        StoreModel_Wanderbell(
            id_Wanderbell: 11,
            goodsId_Wanderbell: "wanderbell.gift.x50.49_9",
            goodsName_Wanderbell: "x50",
            goodsPrice_Wanderbell: "$49.99",
            goodIsTop_Wanderbell: false,
            goodIsLimit_Wanderbell: false
        ),
        StoreModel_Wanderbell(
            id_Wanderbell: 12,
            goodsId_Wanderbell: "wanderbell.gift.x70.69_9",
            goodsName_Wanderbell: "x70",
            goodsPrice_Wanderbell: "$69.99",
            goodIsTop_Wanderbell: false,
            goodIsLimit_Wanderbell: false
        ),
        StoreModel_Wanderbell(
            id_Wanderbell: 13,
            goodsId_Wanderbell: "wanderbell.gift.x100.99_9",
            goodsName_Wanderbell: "x100",
            goodsPrice_Wanderbell: "$99.99",
            goodIsTop_Wanderbell: false,
            goodIsLimit_Wanderbell: false
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Wanderbell {
    
    // 内购商品
    func PurchaseStoreGift_Wanderbell(gid_Wanderbell: String, completion_Wanderbell: @escaping() -> Void) {
        Utils_Wanderbell.showLoading_Wanderbell()
        
        let products: Set = [gid_Wanderbell]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Wanderbell) { SKPaymentTransaction in
                Utils_Wanderbell.dismissLoading_Wanderbell()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Wanderbell.showSuccess_Wanderbell(message_wanderbell: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Wanderbell()
                }else{
                    print("取消支付")
                    Utils_Wanderbell.showError_Wanderbell(message_wanderbell: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Wanderbell.showError_Wanderbell(message_wanderbell: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Wanderbell.showError_Wanderbell(message_wanderbell: "Invalid product information")
        }
    }
    
}
