import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Maki: NSObject {
    
    /// 单例
    static let shared_Maki = Store_Maki()
    
    // 礼物商品列表
    var goodsList_Maki: [StoreModel_Maki] = [
        StoreModel_Maki(
            id_Maki: 0,
            goodsId_Maki: "wanderbell.gift.x2.1_9",
            goodsName_Maki: "x2",
            goodsPrice_Maki: "$1.99",
            goodIsTop_Maki: false,
            goodIsLimit_Maki: true
        ),
        StoreModel_Maki(
            id_Maki: 1,
            goodsId_Maki: "wanderbell.gift.x3.3_9",
            goodsName_Maki: "x3",
            goodsPrice_Maki: "$3.99",
            goodIsTop_Maki: false,
            goodIsLimit_Maki: true
        ),
        StoreModel_Maki(
            id_Maki: 2,
            goodsId_Maki: "wanderbell.gift.x5.4_9",
            goodsName_Maki: "x5",
            goodsPrice_Maki: "$4.99",
            goodIsTop_Maki: false,
            goodIsLimit_Maki: true
        ),
        StoreModel_Maki(
            id_Maki: 3,
            goodsId_Maki: "wanderbell.gift.x1.1_9",
            goodsName_Maki: "x1",
            goodsPrice_Maki: "$1.99",
            goodIsTop_Maki: false,
            goodIsLimit_Maki: false
        ),
        StoreModel_Maki(
            id_Maki: 4,
            goodsId_Maki: "wanderbell.gift.x2.2_9",
            goodsName_Maki: "x2",
            goodsPrice_Maki: "$2.99",
            goodIsTop_Maki: false,
            goodIsLimit_Maki: false
        ),
        StoreModel_Maki(
            id_Maki: 5,
            goodsId_Maki: "wanderbell.gift.x3.3_9_s",
            goodsName_Maki: "x3",
            goodsPrice_Maki: "$3.99",
            goodIsTop_Maki: false,
            goodIsLimit_Maki: false
        ),
        StoreModel_Maki(
            id_Maki: 6,
            goodsId_Maki: "wanderbell.gift.x4.4_9",
            goodsName_Maki: "x4",
            goodsPrice_Maki: "$4.99",
            goodIsTop_Maki: false,
            goodIsLimit_Maki: false
        ),
        StoreModel_Maki(
            id_Maki: 7,
            goodsId_Maki: "wanderbell.gift.x5.6_9",
            goodsName_Maki: "x5",
            goodsPrice_Maki: "$6.99",
            goodIsTop_Maki: false,
            goodIsLimit_Maki: false
        ),
        StoreModel_Maki(
            id_Maki: 8,
            goodsId_Maki: "wanderbell.gift.x10.9_9",
            goodsName_Maki: "x10",
            goodsPrice_Maki: "$9.99",
            goodIsTop_Maki: false,
            goodIsLimit_Maki: false
        ),
        StoreModel_Maki(
            id_Maki: 9,
            goodsId_Maki: "wanderbell.gift.x20.19_9",
            goodsName_Maki: "x20",
            goodsPrice_Maki: "$19.99",
            goodIsTop_Maki: false,
            goodIsLimit_Maki: false
        ),
        StoreModel_Maki(
            id_Maki: 10,
            goodsId_Maki: "wanderbell.gift.x30.29_9",
            goodsName_Maki: "x30",
            goodsPrice_Maki: "$29.99",
            goodIsTop_Maki: false,
            goodIsLimit_Maki: false
        ),
        StoreModel_Maki(
            id_Maki: 11,
            goodsId_Maki: "wanderbell.gift.x50.49_9",
            goodsName_Maki: "x50",
            goodsPrice_Maki: "$49.99",
            goodIsTop_Maki: false,
            goodIsLimit_Maki: false
        ),
        StoreModel_Maki(
            id_Maki: 12,
            goodsId_Maki: "wanderbell.gift.x70.69_9",
            goodsName_Maki: "x70",
            goodsPrice_Maki: "$69.99",
            goodIsTop_Maki: false,
            goodIsLimit_Maki: false
        ),
        StoreModel_Maki(
            id_Maki: 13,
            goodsId_Maki: "wanderbell.gift.x100.99_9",
            goodsName_Maki: "x100",
            goodsPrice_Maki: "$99.99",
            goodIsTop_Maki: false,
            goodIsLimit_Maki: false
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Maki {
    
    // 内购商品
    func PurchaseStoreGift_Maki(gid_Maki: String, completion_Maki: @escaping() -> Void) {
        Load_Maki.showLoading_Maki()
        
        let products: Set = [gid_Maki]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Maki) { SKPaymentTransaction in
                Load_Maki.dismissLoading_Maki()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Load_Maki.showSuccess_Maki(message_Maki: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Maki()
                }else{
                    print("取消支付")
                    Load_Maki.showError_Maki(message_Maki: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Load_Maki.showError_Maki(message_Maki: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Load_Maki.showError_Maki(message_Maki: "Invalid product information")
        }
    }
    
}
