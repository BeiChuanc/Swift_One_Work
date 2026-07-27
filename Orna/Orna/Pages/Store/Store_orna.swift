import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Orna: NSObject {
    
    /// 单例
    static let shared_Orna = Store_Orna()
    
    // 礼物商品列表
    var goodsList_Orna: [StoreModel_Orna] = [
        StoreModel_Orna(
            id_Orna: 0,
            goodsId_Orna: "wanderbell.gift.x2.1_9",
            goodsName_Orna: "x2",
            goodsPrice_Orna: "$1.99",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: true
        ),
        StoreModel_Orna(
            id_Orna: 1,
            goodsId_Orna: "wanderbell.gift.x3.3_9",
            goodsName_Orna: "x3",
            goodsPrice_Orna: "$3.99",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: true
        ),
        StoreModel_Orna(
            id_Orna: 2,
            goodsId_Orna: "wanderbell.gift.x5.4_9",
            goodsName_Orna: "x5",
            goodsPrice_Orna: "$4.99",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: true
        ),
        StoreModel_Orna(
            id_Orna: 3,
            goodsId_Orna: "wanderbell.gift.x1.1_9",
            goodsName_Orna: "x1",
            goodsPrice_Orna: "$1.99",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: false
        ),
        StoreModel_Orna(
            id_Orna: 4,
            goodsId_Orna: "wanderbell.gift.x2.2_9",
            goodsName_Orna: "x2",
            goodsPrice_Orna: "$2.99",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: false
        ),
        StoreModel_Orna(
            id_Orna: 5,
            goodsId_Orna: "wanderbell.gift.x3.3_9_s",
            goodsName_Orna: "x3",
            goodsPrice_Orna: "$3.99",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: false
        ),
        StoreModel_Orna(
            id_Orna: 6,
            goodsId_Orna: "wanderbell.gift.x4.4_9",
            goodsName_Orna: "x4",
            goodsPrice_Orna: "$4.99",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: false
        ),
        StoreModel_Orna(
            id_Orna: 7,
            goodsId_Orna: "wanderbell.gift.x5.6_9",
            goodsName_Orna: "x5",
            goodsPrice_Orna: "$6.99",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: false
        ),
        StoreModel_Orna(
            id_Orna: 8,
            goodsId_Orna: "wanderbell.gift.x10.9_9",
            goodsName_Orna: "x10",
            goodsPrice_Orna: "$9.99",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: false
        ),
        StoreModel_Orna(
            id_Orna: 9,
            goodsId_Orna: "wanderbell.gift.x20.19_9",
            goodsName_Orna: "x20",
            goodsPrice_Orna: "$19.99",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: false
        ),
        StoreModel_Orna(
            id_Orna: 10,
            goodsId_Orna: "wanderbell.gift.x30.29_9",
            goodsName_Orna: "x30",
            goodsPrice_Orna: "$29.99",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: false
        ),
        StoreModel_Orna(
            id_Orna: 11,
            goodsId_Orna: "wanderbell.gift.x50.49_9",
            goodsName_Orna: "x50",
            goodsPrice_Orna: "$49.99",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: false
        ),
        StoreModel_Orna(
            id_Orna: 12,
            goodsId_Orna: "wanderbell.gift.x70.69_9",
            goodsName_Orna: "x70",
            goodsPrice_Orna: "$69.99",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: false
        ),
        StoreModel_Orna(
            id_Orna: 13,
            goodsId_Orna: "wanderbell.gift.x100.99_9",
            goodsName_Orna: "x100",
            goodsPrice_Orna: "$99.99",
            goodIsTop_Orna: false,
            goodIsLimit_Orna: false
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Orna {
    
    // 内购商品
    func PurchaseStoreGift_Orna(gid_Orna: String, completion_Orna: @escaping() -> Void) {
        Load_Orna.showLoading_Orna()
        
        let products: Set = [gid_Orna]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Orna) { SKPaymentTransaction in
                Load_Orna.dismissLoading_Orna()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Load_Orna.showSuccess_Orna(message_Orna: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Orna()
                }else{
                    print("取消支付")
                    Load_Orna.showError_Orna(message_Orna: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Load_Orna.showError_Orna(message_Orna: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Load_Orna.showError_Orna(message_Orna: "Invalid product information")
        }
    }
    
}
