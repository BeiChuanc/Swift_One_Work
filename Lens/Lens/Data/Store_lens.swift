import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Lens: NSObject {
    
    /// 单例
    static let shared_Lens = Store_Lens()
    
    // 礼物商品列表
    var goodsList_Lens: [StoreModel_Lens] = [
        StoreModel_Lens(
            id_Lens: 0,
            goodsId_Lens: "wanderbell.gift.x2.1_9",
            goodsName_Lens: "x2",
            goodsPrice_Lens: "$1.99",
            goodIsTop_Lens: false,
            goodIsLimit_Lens: true
        ),
        StoreModel_Lens(
            id_Lens: 1,
            goodsId_Lens: "wanderbell.gift.x3.3_9",
            goodsName_Lens: "x3",
            goodsPrice_Lens: "$3.99",
            goodIsTop_Lens: false,
            goodIsLimit_Lens: true
        ),
        StoreModel_Lens(
            id_Lens: 2,
            goodsId_Lens: "wanderbell.gift.x5.4_9",
            goodsName_Lens: "x5",
            goodsPrice_Lens: "$4.99",
            goodIsTop_Lens: false,
            goodIsLimit_Lens: true
        ),
        StoreModel_Lens(
            id_Lens: 3,
            goodsId_Lens: "wanderbell.gift.x1.1_9",
            goodsName_Lens: "x1",
            goodsPrice_Lens: "$1.99",
            goodIsTop_Lens: false,
            goodIsLimit_Lens: false
        ),
        StoreModel_Lens(
            id_Lens: 4,
            goodsId_Lens: "wanderbell.gift.x2.2_9",
            goodsName_Lens: "x2",
            goodsPrice_Lens: "$2.99",
            goodIsTop_Lens: false,
            goodIsLimit_Lens: false
        ),
        StoreModel_Lens(
            id_Lens: 5,
            goodsId_Lens: "wanderbell.gift.x3.3_9_s",
            goodsName_Lens: "x3",
            goodsPrice_Lens: "$3.99",
            goodIsTop_Lens: false,
            goodIsLimit_Lens: false
        ),
        StoreModel_Lens(
            id_Lens: 6,
            goodsId_Lens: "wanderbell.gift.x4.4_9",
            goodsName_Lens: "x4",
            goodsPrice_Lens: "$4.99",
            goodIsTop_Lens: false,
            goodIsLimit_Lens: false
        ),
        StoreModel_Lens(
            id_Lens: 7,
            goodsId_Lens: "wanderbell.gift.x5.6_9",
            goodsName_Lens: "x5",
            goodsPrice_Lens: "$6.99",
            goodIsTop_Lens: false,
            goodIsLimit_Lens: false
        ),
        StoreModel_Lens(
            id_Lens: 8,
            goodsId_Lens: "wanderbell.gift.x10.9_9",
            goodsName_Lens: "x10",
            goodsPrice_Lens: "$9.99",
            goodIsTop_Lens: false,
            goodIsLimit_Lens: false
        ),
        StoreModel_Lens(
            id_Lens: 9,
            goodsId_Lens: "wanderbell.gift.x20.19_9",
            goodsName_Lens: "x20",
            goodsPrice_Lens: "$19.99",
            goodIsTop_Lens: false,
            goodIsLimit_Lens: false
        ),
        StoreModel_Lens(
            id_Lens: 10,
            goodsId_Lens: "wanderbell.gift.x30.29_9",
            goodsName_Lens: "x30",
            goodsPrice_Lens: "$29.99",
            goodIsTop_Lens: false,
            goodIsLimit_Lens: false
        ),
        StoreModel_Lens(
            id_Lens: 11,
            goodsId_Lens: "wanderbell.gift.x50.49_9",
            goodsName_Lens: "x50",
            goodsPrice_Lens: "$49.99",
            goodIsTop_Lens: false,
            goodIsLimit_Lens: false
        ),
        StoreModel_Lens(
            id_Lens: 12,
            goodsId_Lens: "wanderbell.gift.x70.69_9",
            goodsName_Lens: "x70",
            goodsPrice_Lens: "$69.99",
            goodIsTop_Lens: false,
            goodIsLimit_Lens: false
        ),
        StoreModel_Lens(
            id_Lens: 13,
            goodsId_Lens: "wanderbell.gift.x100.99_9",
            goodsName_Lens: "x100",
            goodsPrice_Lens: "$99.99",
            goodIsTop_Lens: false,
            goodIsLimit_Lens: false
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Lens {
    
    // 内购商品
    func PurchaseStoreGift_Lens(gid_Lens: String, completion_Lens: @escaping() -> Void) {
        Load_Lens.showLoading_Lens()
        
        let products: Set = [gid_Lens]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Lens) { SKPaymentTransaction in
                Load_Lens.dismissLoading_Lens()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Load_Lens.showSuccess_Lens(message_Lens: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Lens()
                }else{
                    print("取消支付")
                    Load_Lens.showError_Lens(message_Lens: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Load_Lens.showError_Lens(message_Lens: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Load_Lens.showError_Lens(message_Lens: "Invalid product information")
        }
    }
    
}
