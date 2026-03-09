import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Moode: NSObject {
    
    /// 单例
    static let shared_Moode = Store_Moode()
    
    // 礼物商品列表
    var goodsList_Moode: [StoreModel_Moode] = [
        StoreModel_Moode(
            id_Moode: 1,
            goodsId_Moode: "trace.pur.e.x5.3_9",
            goodsName_Moode: "x5",
            goodsPrice_Moode: "$3.99",
            goodIsTop_Moode: true,
            goodIsLimit_Moode: false
        ),
        StoreModel_Moode(
            id_Moode: 2,
            goodsId_Moode: "trace.pur.e.x10.4_9",
            goodsName_Moode: "x10",
            goodsPrice_Moode: "$4.99",
            goodIsTop_Moode: true,
            goodIsLimit_Moode: false
        ),
        StoreModel_Moode(
            id_Moode: 3,
            goodsId_Moode: "trace.pur.e.x1.1_9",
            goodsName_Moode: "x1",
            goodsPrice_Moode: "$1.99",
            goodIsTop_Moode: false,
            goodIsLimit_Moode: true
        ),
        StoreModel_Moode(
            id_Moode: 4,
            goodsId_Moode: "trace.pur.e.x2.2_9",
            goodsName_Moode: "x2",
            goodsPrice_Moode: "$2.99",
            goodIsTop_Moode: false,
            goodIsLimit_Moode: true
        ),
        StoreModel_Moode(
            id_Moode: 5,
            goodsId_Moode: "trace.pur.e.x3.3_9_s",
            goodsName_Moode: "x3",
            goodsPrice_Moode: "$3.99",
            goodIsTop_Moode: false,
            goodIsLimit_Moode: true
        ),
        StoreModel_Moode(
            id_Moode: 6,
            goodsId_Moode: "trace.pur.e.x4.4_9",
            goodsName_Moode: "x4",
            goodsPrice_Moode: "$4.99",
            goodIsTop_Moode: false,
            goodIsLimit_Moode: false
        ),
        StoreModel_Moode(
            id_Moode: 7,
            goodsId_Moode: "trace.pur.e.x5.6_9",
            goodsName_Moode: "x5",
            goodsPrice_Moode: "$6.99",
            goodIsTop_Moode: false,
            goodIsLimit_Moode: false
        ),
        StoreModel_Moode(
            id_Moode: 8,
            goodsId_Moode: "trace.pur.e.x7.9_9",
            goodsName_Moode: "x7",
            goodsPrice_Moode: "$9.99",
            goodIsTop_Moode: false,
            goodIsLimit_Moode: false
        ),
        StoreModel_Moode(
            id_Moode: 9,
            goodsId_Moode: "trace.pur.e.x12.19_9",
            goodsName_Moode: "x12",
            goodsPrice_Moode: "$19.99",
            goodIsTop_Moode: false,
            goodIsLimit_Moode: false
        ),
        StoreModel_Moode(
            id_Moode: 10,
            goodsId_Moode: "trace.pur.e.x20.29_9",
            goodsName_Moode: "x20",
            goodsPrice_Moode: "$29.99",
            goodIsTop_Moode: false,
            goodIsLimit_Moode: false
        ),
        StoreModel_Moode(
            id_Moode: 11,
            goodsId_Moode: "trace.pur.e.x42.49_9",
            goodsName_Moode: "x42",
            goodsPrice_Moode: "$49.99",
            goodIsTop_Moode: false,
            goodIsLimit_Moode: false
        ),
        StoreModel_Moode(
            id_Moode: 12,
            goodsId_Moode: "trace.pur.e.x64.69_9",
            goodsName_Moode: "x64",
            goodsPrice_Moode: "$69.99",
            goodIsTop_Moode: false,
            goodIsLimit_Moode: false
        ),
        StoreModel_Moode(
            id_Moode: 13,
            goodsId_Moode: "trace.pur.e.x102.99_9",
            goodsName_Moode: "x102",
            goodsPrice_Moode: "$99.99",
            goodIsTop_Moode: false,
            goodIsLimit_Moode: false
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Moode {
    
    // 内购商品
    func PurchaseStoreGift_Moode(gid_Moode: String, completion_Moode: @escaping() -> Void) {
        Utils_Moode.showLoading_Moode()
        
        let products: Set = [gid_Moode]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Moode) { SKPaymentTransaction in
                Utils_Moode.dismissLoading_Moode()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Moode.showSuccess_Moode(message_Moode: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Moode()
                }else{
                    print("取消支付")
                    Utils_Moode.showError_Moode(message_Moode: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Moode.showError_Moode(message_Moode: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Moode.showError_Moode(message_Moode: "Invalid product information")
        }
    }
    
}
