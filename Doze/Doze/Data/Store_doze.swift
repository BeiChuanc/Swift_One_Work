import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Doze: NSObject {
    
    /// 单例
    static let shared_Doze = Store_Doze()
    
    // 礼物商品列表
    var goodsList_Doze: [StoreModel_Doze] = [
        StoreModel_Doze(
            id_Doze: 1,
            goodsId_Doze: "doze.gift.pur.x5.3_9",
            goodsName_Doze: "x5",
            goodsPrice_Doze: "$3.99",
            goodIsTop_Doze: true,
            goodIsLimit_Doze: false
        ),
        StoreModel_Doze(
            id_Doze: 2,
            goodsId_Doze: "doze.gift.pur.x10.4_9",
            goodsName_Doze: "x10",
            goodsPrice_Doze: "$4.99",
            goodIsTop_Doze: true,
            goodIsLimit_Doze: false
        ),
        StoreModel_Doze(
            id_Doze: 3,
            goodsId_Doze: "doze.gift.pur.x1.1_9",
            goodsName_Doze: "x1",
            goodsPrice_Doze: "$1.99",
            goodIsTop_Doze: false,
            goodIsLimit_Doze: true
        ),
        StoreModel_Doze(
            id_Doze: 4,
            goodsId_Doze: "doze.gift.pur.x2.2_9",
            goodsName_Doze: "x2",
            goodsPrice_Doze: "$2.99",
            goodIsTop_Doze: false,
            goodIsLimit_Doze: true
        ),
        StoreModel_Doze(
            id_Doze: 5,
            goodsId_Doze: "doze.gift.pur.x3.3_9_s",
            goodsName_Doze: "x3",
            goodsPrice_Doze: "$3.99",
            goodIsTop_Doze: false,
            goodIsLimit_Doze: true
        ),
        StoreModel_Doze(
            id_Doze: 6,
            goodsId_Doze: "doze.gift.pur.x4.4_9",
            goodsName_Doze: "x4",
            goodsPrice_Doze: "$4.99",
            goodIsTop_Doze: false,
            goodIsLimit_Doze: false
        ),
        StoreModel_Doze(
            id_Doze: 7,
            goodsId_Doze: "doze.gift.pur.x5.6_9",
            goodsName_Doze: "x5",
            goodsPrice_Doze: "$6.99",
            goodIsTop_Doze: false,
            goodIsLimit_Doze: false
        ),
        StoreModel_Doze(
            id_Doze: 8,
            goodsId_Doze: "doze.gift.pur.x7.9_9",
            goodsName_Doze: "x7",
            goodsPrice_Doze: "$9.99",
            goodIsTop_Doze: false,
            goodIsLimit_Doze: false
        ),
        StoreModel_Doze(
            id_Doze: 9,
            goodsId_Doze: "doze.gift.pur.x12.19_9",
            goodsName_Doze: "x12",
            goodsPrice_Doze: "$19.99",
            goodIsTop_Doze: false,
            goodIsLimit_Doze: false
        ),
        StoreModel_Doze(
            id_Doze: 10,
            goodsId_Doze: "doze.gift.pur.x20.29_9",
            goodsName_Doze: "x20",
            goodsPrice_Doze: "$29.99",
            goodIsTop_Doze: false,
            goodIsLimit_Doze: false
        ),
        StoreModel_Doze(
            id_Doze: 11,
            goodsId_Doze: "doze.gift.pur.x42.49_9",
            goodsName_Doze: "x42",
            goodsPrice_Doze: "$49.99",
            goodIsTop_Doze: false,
            goodIsLimit_Doze: false
        ),
        StoreModel_Doze(
            id_Doze: 12,
            goodsId_Doze: "doze.gift.pur.x64.69_9",
            goodsName_Doze: "x64",
            goodsPrice_Doze: "$69.99",
            goodIsTop_Doze: false,
            goodIsLimit_Doze: false
        ),
        StoreModel_Doze(
            id_Doze: 13,
            goodsId_Doze: "doze.gift.pur.x102.99_9",
            goodsName_Doze: "x102",
            goodsPrice_Doze: "$99.99",
            goodIsTop_Doze: false,
            goodIsLimit_Doze: false
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Doze {
    
    // 内购商品
    func PurchaseStoreGift_Doze(gid_Doze: String, completion_Doze: @escaping() -> Void) {
        Utils_Doze.showLoading_Doze()
        
        let products: Set = [gid_Doze]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Doze) { SKPaymentTransaction in
                Utils_Doze.dismissLoading_Doze()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Doze.showSuccess_Doze(message_Doze: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Doze()
                }else{
                    print("取消支付")
                    Utils_Doze.showError_Doze(message_Doze: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Doze.showError_Doze(message_Doze: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Doze.showError_Doze(message_Doze: "Invalid product information")
        }
    }
    
}
