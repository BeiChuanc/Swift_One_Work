import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Ornit {
    /// 个人聊天
    case personal_ornit
    /// 群聊
    case group_ornit
    /// AI聊天
    case ai_ornit
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Ornit {
    
    /// 单例
    static let shared_Ornit = MessageViewModel_Ornit()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Ornit = Notification.Name("MessageStateDidChange_Ornit")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Ornit: [Int: [MessageModel_Ornit]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Ornit: [Int: GroupChatInfo_Ornit] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Ornit: [MessageModel_Ornit] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Ornit: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Ornit() {
        userMesMap_Ornit = [:]
        aiChats_Ornit = []
        notifyStateChange_Ornit()
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Ornit() -> [Int: GroupChatInfo_Ornit] {
        return groupChats_Ornit
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Ornit(userId_ornit: Int) -> [MessageModel_Ornit] {
        return userMesMap_Ornit[userId_ornit] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Ornit() -> [PrewUserModel_Ornit] {
        let userIds_ornit = userMesMap_Ornit.keys
        return LocalData_Ornit.shared_Ornit.userList_Ornit.filter { user in
            guard let userId = user.userId_Ornit else { return false }
            return userIds_ornit.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Ornit() -> [MessageModel_Ornit] {
        return aiChats_Ornit
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Ornit(groupId_ornit: Int) -> [MessageModel_Ornit] {
        return groupChats_Ornit[groupId_ornit]?.messages_ornit ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Ornit(userId_ornit: Int) -> MessageModel_Ornit? {
        return userMesMap_Ornit[userId_ornit]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Ornit(message_ornit: String, chatType_ornit: ChatType_Ornit, id_ornit: Int) {
        let currentTime_ornit = getCurrentTime_Ornit()
        
        let chatMessage_ornit = MessageModel_Ornit(
            messageId_ornit: Int(Date().timeIntervalSince1970 * 1000),
            content_ornit: message_ornit,
            userHead_ornit: "current_user_head", // 这里应该从UserViewModel获取
            isMine_ornit: true,
            time_ornit: currentTime_ornit
        )
        
        switch chatType_ornit {
        case .personal_ornit:
            // 个人聊天
            if userMesMap_Ornit[id_ornit] == nil {
                userMesMap_Ornit[id_ornit] = []
            }
            userMesMap_Ornit[id_ornit]?.append(chatMessage_ornit)
            handleMessage_Ornit(message_ornit: chatMessage_ornit, id_ornit: id_ornit, chatType_ornit: chatType_ornit)
            
        case .group_ornit:
            // 群聊
            if var groupInfo_ornit = groupChats_Ornit[id_ornit] {
                groupInfo_ornit.messages_ornit.append(chatMessage_ornit)
                groupChats_Ornit[id_ornit] = groupInfo_ornit
            } else {
                groupChats_Ornit[id_ornit] = GroupChatInfo_Ornit(
                    gid_ornit: id_ornit,
                    intro_ornit: "",
                    cover_ornit: "",
                    join_ornit: "",
                    messages_ornit: [chatMessage_ornit]
                )
            }
            
        case .ai_ornit:
            // AI聊天
            aiChats_Ornit.append(chatMessage_ornit)
            handleMessage_Ornit(message_ornit: chatMessage_ornit, id_ornit: id_ornit, chatType_ornit: chatType_ornit)
        }
        
        notifyStateChange_Ornit()
    }
    
    /// 处理消息回复
    private func handleMessage_Ornit(message_ornit: MessageModel_Ornit, id_ornit: Int, chatType_ornit: ChatType_Ornit) {
        Task {
            let response_ornit = await chatService_Ornit(
                userId_ornit: 0, // 这里应该从UserViewModel获取
                message_ornit: message_ornit.content_Ornit ?? ""
            )
            
            let replyMessage_ornit = MessageModel_Ornit(
                messageId_ornit: Int(Date().timeIntervalSince1970 * 1000),
                content_ornit: response_ornit ?? "Server error",
                userHead_ornit: "",
                isMine_ornit: false,
                time_ornit: getCurrentTime_Ornit()
            )
            
            switch chatType_ornit {
            case .ai_ornit:
                aiChats_Ornit.append(replyMessage_ornit)
                
            case .personal_ornit:
                if userMesMap_Ornit[id_ornit] == nil {
                    userMesMap_Ornit[id_ornit] = []
                }
                userMesMap_Ornit[id_ornit]?.append(replyMessage_ornit)
                
            case .group_ornit:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Ornit()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Ornit(groupId_ornit: Int) {
        if var groupInfo_ornit = groupChats_Ornit[groupId_ornit] {
            groupInfo_ornit.messages_ornit = []
            groupChats_Ornit[groupId_ornit] = groupInfo_ornit
            notifyStateChange_Ornit()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Ornit(groupId_ornit: Int) {
        groupChats_Ornit.removeValue(forKey: groupId_ornit)
        notifyStateChange_Ornit()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Ornit() {
        aiChats_Ornit = []
        notifyStateChange_Ornit()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Ornit(userId_ornit: Int) {
        userMesMap_Ornit.removeValue(forKey: userId_ornit)
        notifyStateChange_Ornit()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Ornit() {
        userMesMap_Ornit = [:]
        groupChats_Ornit = [:]
        aiChats_Ornit = []
        notifyStateChange_Ornit()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Ornit() -> String {
        let formatter_ornit = DateFormatter()
        formatter_ornit.dateFormat = "HH:mm"
        return formatter_ornit.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Ornit() {
        NotificationCenter.default.post(
            name: MessageViewModel_Ornit.messageStateDidChangeNotification_Ornit,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Ornit(userId_ornit: Int, message_ornit: String) async -> String? {
        do {
            let bundleId_ornit = "com.ornit.app"
            let timestamp_ornit = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_ornit = generateRandomString_Ornit(length_ornit: 16)
            let sessionId_ornit = "\(timestamp_ornit)_\(randomString_ornit)"
            
            // 解密URL
            let urlString_ornit = decryptUrl_Ornit(encryptedCodes_ornit: MessageViewModel_Ornit.chatService_Ornit)
            guard let url_ornit = URL(string: urlString_ornit) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_ornit = URLRequest(url: url_ornit)
            request_ornit.httpMethod = "POST"
            request_ornit.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_ornit: [String: Any] = [
                "bundle_id": bundleId_ornit,
                "session_id": sessionId_ornit,
                "content_type": "text",
                "content": message_ornit
            ]
            
            request_ornit.httpBody = try JSONSerialization.data(withJSONObject: body_ornit)
            
            let (data_ornit, response_ornit) = try await URLSession.shared.data(for: request_ornit)
            
            if let httpResponse_ornit = response_ornit as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_ornit.statusCode)")
                
                if httpResponse_ornit.statusCode == 200 {
                    if let json_ornit = try JSONSerialization.jsonObject(with: data_ornit) as? [String: Any],
                       let code_ornit = json_ornit["code"] as? Int,
                       code_ornit == 1003,
                       let data_ornit = json_ornit["data"] as? [String: Any],
                       let answer_ornit = data_ornit["answer"] as? String,
                       !answer_ornit.isEmpty {
                        return answer_ornit
                    }
                }
            }
            return "Server error"
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }
    
    /// URL加密方法（双重加密：字符偏移加密 + 异或加密）
    static func encryptUrl_Ornit(plainUrl_Ornit: String) -> [Int] {
        let xorKey_Ornit = 20 // 异或密钥
        let offset_Ornit = 23 // 字符偏移量
        
        var result_Ornit: [Int] = []
        
        // 第一层：字符偏移加密
        for char_Ornit in plainUrl_Ornit.unicodeScalars {
            let charCode_Ornit = Int(char_Ornit.value) + offset_Ornit
            result_Ornit.append(charCode_Ornit)
        }
        
        // 第二层：异或加密
        var finalResult_Ornit: [Int] = []
        for code_Ornit in result_Ornit {
            finalResult_Ornit.append(code_Ornit ^ xorKey_Ornit)
        }
        
        print("✅ URL加密结果: \(finalResult_Ornit)")
        return finalResult_Ornit
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Ornit(encryptedCodes_ornit: [Int]) -> String {
        let xorKey_ornit = 20 // 异或密钥
        let offset_ornit = 23 // 字符偏移量
        
        var result_ornit = ""
        
        // 第一层：异或解密
        for code_ornit in encryptedCodes_ornit {
            let charCode_ornit = code_ornit ^ xorKey_ornit
            if let scalar_ornit = UnicodeScalar(charCode_ornit) {
                result_ornit.append(Character(scalar_ornit))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_ornit = ""
        for char_ornit in result_ornit.unicodeScalars {
            let charCode_ornit = Int(char_ornit.value) - offset_ornit
            if let scalar_ornit = UnicodeScalar(charCode_ornit) {
                finalResult_ornit.append(Character(scalar_ornit))
            }
        }
        
        return finalResult_ornit
    }
    
    /// 生成随机字符串
    private func generateRandomString_Ornit(length_ornit: Int) -> String {
        let letters_ornit = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_ornit).map { _ in letters_ornit.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Ornit {
    /// 群组ID
    var gid_ornit: Int
    /// 群组简介
    var intro_ornit: String
    /// 群组封面
    var cover_ornit: String
    /// 加入信息
    var join_ornit: String
    /// 消息列表
    var messages_ornit: [MessageModel_Ornit]
}
