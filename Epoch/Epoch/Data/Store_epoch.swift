import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Epoch: NSObject {
    
    /// 单例
    static let shared_Epoch = Store_Epoch()
    
    // 礼物商品列表
    var goodsList_Epoch: [StoreModel_Epoch] = [
        StoreModel_Epoch(
            id_Epoch: 0,
            goodsId_Epoch: "wanderbell.gift.x2.1_9",
            goodsName_Epoch: "x2",
            goodsPrice_Epoch: "$1.99",
            goodIsTop_Epoch: false,
            goodIsLimit_Epoch: true
        ),
        StoreModel_Epoch(
            id_Epoch: 1,
            goodsId_Epoch: "wanderbell.gift.x3.3_9",
            goodsName_Epoch: "x3",
            goodsPrice_Epoch: "$3.99",
            goodIsTop_Epoch: false,
            goodIsLimit_Epoch: true
        ),
        StoreModel_Epoch(
            id_Epoch: 2,
            goodsId_Epoch: "wanderbell.gift.x5.4_9",
            goodsName_Epoch: "x5",
            goodsPrice_Epoch: "$4.99",
            goodIsTop_Epoch: false,
            goodIsLimit_Epoch: true
        ),
        StoreModel_Epoch(
            id_Epoch: 3,
            goodsId_Epoch: "wanderbell.gift.x1.1_9",
            goodsName_Epoch: "x1",
            goodsPrice_Epoch: "$1.99",
            goodIsTop_Epoch: false,
            goodIsLimit_Epoch: false
        ),
        StoreModel_Epoch(
            id_Epoch: 4,
            goodsId_Epoch: "wanderbell.gift.x2.2_9",
            goodsName_Epoch: "x2",
            goodsPrice_Epoch: "$2.99",
            goodIsTop_Epoch: false,
            goodIsLimit_Epoch: false
        ),
        StoreModel_Epoch(
            id_Epoch: 5,
            goodsId_Epoch: "wanderbell.gift.x3.3_9_s",
            goodsName_Epoch: "x3",
            goodsPrice_Epoch: "$3.99",
            goodIsTop_Epoch: false,
            goodIsLimit_Epoch: false
        ),
        StoreModel_Epoch(
            id_Epoch: 6,
            goodsId_Epoch: "wanderbell.gift.x4.4_9",
            goodsName_Epoch: "x4",
            goodsPrice_Epoch: "$4.99",
            goodIsTop_Epoch: false,
            goodIsLimit_Epoch: false
        ),
        StoreModel_Epoch(
            id_Epoch: 7,
            goodsId_Epoch: "wanderbell.gift.x5.6_9",
            goodsName_Epoch: "x5",
            goodsPrice_Epoch: "$6.99",
            goodIsTop_Epoch: false,
            goodIsLimit_Epoch: false
        ),
        StoreModel_Epoch(
            id_Epoch: 8,
            goodsId_Epoch: "wanderbell.gift.x10.9_9",
            goodsName_Epoch: "x10",
            goodsPrice_Epoch: "$9.99",
            goodIsTop_Epoch: false,
            goodIsLimit_Epoch: false
        ),
        StoreModel_Epoch(
            id_Epoch: 9,
            goodsId_Epoch: "wanderbell.gift.x20.19_9",
            goodsName_Epoch: "x20",
            goodsPrice_Epoch: "$19.99",
            goodIsTop_Epoch: false,
            goodIsLimit_Epoch: false
        ),
        StoreModel_Epoch(
            id_Epoch: 10,
            goodsId_Epoch: "wanderbell.gift.x30.29_9",
            goodsName_Epoch: "x30",
            goodsPrice_Epoch: "$29.99",
            goodIsTop_Epoch: false,
            goodIsLimit_Epoch: false
        ),
        StoreModel_Epoch(
            id_Epoch: 11,
            goodsId_Epoch: "wanderbell.gift.x50.49_9",
            goodsName_Epoch: "x50",
            goodsPrice_Epoch: "$49.99",
            goodIsTop_Epoch: false,
            goodIsLimit_Epoch: false
        ),
        StoreModel_Epoch(
            id_Epoch: 12,
            goodsId_Epoch: "wanderbell.gift.x70.69_9",
            goodsName_Epoch: "x70",
            goodsPrice_Epoch: "$69.99",
            goodIsTop_Epoch: false,
            goodIsLimit_Epoch: false
        ),
        StoreModel_Epoch(
            id_Epoch: 13,
            goodsId_Epoch: "wanderbell.gift.x100.99_9",
            goodsName_Epoch: "x100",
            goodsPrice_Epoch: "$99.99",
            goodIsTop_Epoch: false,
            goodIsLimit_Epoch: false
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Epoch {
    
    // 内购商品
    func PurchaseStoreGift_Epoch(gid_Epoch: String, completion_Epoch: @escaping() -> Void) {
        Utils_Epoch.showLoading_Epoch()
        
        let products: Set = [gid_Epoch]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Epoch) { SKPaymentTransaction in
                Utils_Epoch.dismissLoading_Epoch()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Epoch.showSuccess_Epoch(message_Epoch: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Epoch()
                }else{
                    print("取消支付")
                    Utils_Epoch.showError_Epoch(message_Epoch: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Epoch.showError_Epoch(message_Epoch: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Epoch.showError_Epoch(message_Epoch: "Invalid product information")
        }
    }
    
}
