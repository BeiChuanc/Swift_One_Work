import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Doze {
    /// 个人聊天
    case personal_doze
    /// 群聊
    case group_doze
    /// AI聊天
    case ai_doze
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Doze {
    
    /// 单例
    static let shared_Doze = MessageViewModel_Doze()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Doze = Notification.Name("MessageStateDidChange_Doze")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Doze: [Int: [MessageModel_Doze]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Doze: [Int: GroupChatInfo_Doze] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Doze: [MessageModel_Doze] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Doze: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Doze() {
        userMesMap_Doze = [:]
        aiChats_Doze = []
        setGroup_Doze()
        notifyStateChange_Doze()
    }
    
    /// 设置群聊基础信息
    /// 功能：初始化5个预设群聊
    private func setGroup_Doze() {
        groupChats_Doze = [
            10: GroupChatInfo_Doze(
                gid_doze: 10,
                intro_doze: "Bonfire Stories Hub",
                cover_doze: "",
                join_doze: "",
                messages_doze: []
            ),
            11: GroupChatInfo_Doze(
                gid_doze: 11,
                intro_doze: "Night Gathering Friends",
                cover_doze: "",
                join_doze: "",
                messages_doze: []
            ),
            12: GroupChatInfo_Doze(
                gid_doze: 12,
                intro_doze: "Campfire Adventure Team",
                cover_doze: "",
                join_doze: "",
                messages_doze: []
            ),
            13: GroupChatInfo_Doze(
                gid_doze: 13,
                intro_doze: "Outdoor Bonfire Lovers",
                cover_doze: "",
                join_doze: "",
                messages_doze: []
            ),
            14: GroupChatInfo_Doze(
                gid_doze: 14,
                intro_doze: "Warm Fire Community",
                cover_doze: "",
                join_doze: "",
                messages_doze: []
            )
        ]
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Doze() -> [Int: GroupChatInfo_Doze] {
        return groupChats_Doze
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Doze(userId_doze: Int) -> [MessageModel_Doze] {
        return userMesMap_Doze[userId_doze] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Doze() -> [PrewUserModel_Doze] {
        let userIds_doze = userMesMap_Doze.keys
        return LocalData_Doze.shared_Doze.userList_Doze.filter { user in
            guard let userId = user.userId_Doze else { return false }
            return userIds_doze.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Doze() -> [MessageModel_Doze] {
        return aiChats_Doze
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Doze(groupId_doze: Int) -> [MessageModel_Doze] {
        return groupChats_Doze[groupId_doze]?.messages_doze ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Doze(userId_doze: Int) -> MessageModel_Doze? {
        return userMesMap_Doze[userId_doze]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Doze(message_doze: String, chatType_doze: ChatType_Doze, id_doze: Int) {
        let currentTime_doze = getCurrentTime_Doze()
        
        let chatMessage_doze = MessageModel_Doze(
            messageId_doze: Int(Date().timeIntervalSince1970 * 1000),
            content_doze: message_doze,
            userHead_doze: "current_user_head", // 这里应该从UserViewModel获取
            isMine_doze: true,
            time_doze: currentTime_doze
        )
        
        switch chatType_doze {
        case .personal_doze:
            // 个人聊天
            if userMesMap_Doze[id_doze] == nil {
                userMesMap_Doze[id_doze] = []
            }
            userMesMap_Doze[id_doze]?.append(chatMessage_doze)
            handleMessage_Doze(message_doze: chatMessage_doze, id_doze: id_doze, chatType_doze: chatType_doze)
            
        case .group_doze:
            // 群聊
            if var groupInfo_doze = groupChats_Doze[id_doze] {
                groupInfo_doze.messages_doze.append(chatMessage_doze)
                groupChats_Doze[id_doze] = groupInfo_doze
            } else {
                groupChats_Doze[id_doze] = GroupChatInfo_Doze(
                    gid_doze: id_doze,
                    intro_doze: "",
                    cover_doze: "",
                    join_doze: "",
                    messages_doze: [chatMessage_doze]
                )
            }
            
        case .ai_doze:
            // AI聊天
            aiChats_Doze.append(chatMessage_doze)
            handleMessage_Doze(message_doze: chatMessage_doze, id_doze: id_doze, chatType_doze: chatType_doze)
        }
        
        notifyStateChange_Doze()
    }
    
    /// 处理消息回复
    private func handleMessage_Doze(message_doze: MessageModel_Doze, id_doze: Int, chatType_doze: ChatType_Doze) {
        Task {
            let response_doze = await chatService_Doze(
                userId_doze: 0, // 这里应该从UserViewModel获取
                message_doze: message_doze.content_Doze ?? ""
            )
            
            let replyMessage_doze = MessageModel_Doze(
                messageId_doze: Int(Date().timeIntervalSince1970 * 1000),
                content_doze: response_doze ?? "Server error",
                userHead_doze: "",
                isMine_doze: false,
                time_doze: getCurrentTime_Doze()
            )
            
            switch chatType_doze {
            case .ai_doze:
                aiChats_Doze.append(replyMessage_doze)
                
            case .personal_doze:
                if userMesMap_Doze[id_doze] == nil {
                    userMesMap_Doze[id_doze] = []
                }
                userMesMap_Doze[id_doze]?.append(replyMessage_doze)
                
            case .group_doze:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Doze()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Doze(groupId_doze: Int) {
        if var groupInfo_doze = groupChats_Doze[groupId_doze] {
            groupInfo_doze.messages_doze = []
            groupChats_Doze[groupId_doze] = groupInfo_doze
            notifyStateChange_Doze()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Doze(groupId_doze: Int) {
        groupChats_Doze.removeValue(forKey: groupId_doze)
        notifyStateChange_Doze()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Doze() {
        aiChats_Doze = []
        notifyStateChange_Doze()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Doze(userId_doze: Int) {
        userMesMap_Doze.removeValue(forKey: userId_doze)
        notifyStateChange_Doze()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Doze() {
        userMesMap_Doze = [:]
        groupChats_Doze = [:]
        aiChats_Doze = []
        notifyStateChange_Doze()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Doze() -> String {
        let formatter_doze = DateFormatter()
        formatter_doze.dateFormat = "HH:mm"
        return formatter_doze.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Doze() {
        NotificationCenter.default.post(
            name: MessageViewModel_Doze.messageStateDidChangeNotification_Doze,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Doze(userId_doze: Int, message_doze: String) async -> String? {
        do {
            let bundleId_doze = "com.doze.app"
            let timestamp_doze = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_doze = generateRandomString_Doze(length_doze: 16)
            let sessionId_doze = "\(timestamp_doze)_\(randomString_doze)"
            
            // 解密URL
            let urlString_doze = decryptUrl_Doze(encryptedCodes_doze: MessageViewModel_Doze.chatService_Doze)
            guard let url_doze = URL(string: urlString_doze) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_doze = URLRequest(url: url_doze)
            request_doze.httpMethod = "POST"
            request_doze.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_doze: [String: Any] = [
                "bundle_id": bundleId_doze,
                "session_id": sessionId_doze,
                "content_type": "text",
                "content": message_doze
            ]
            
            request_doze.httpBody = try JSONSerialization.data(withJSONObject: body_doze)
            
            let (data_doze, response_doze) = try await URLSession.shared.data(for: request_doze)
            
            if let httpResponse_doze = response_doze as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_doze.statusCode)")
                
                if httpResponse_doze.statusCode == 200 {
                    if let json_doze = try JSONSerialization.jsonObject(with: data_doze) as? [String: Any],
                       let code_doze = json_doze["code"] as? Int,
                       code_doze == 1003,
                       let data_doze = json_doze["data"] as? [String: Any],
                       let answer_doze = data_doze["answer"] as? String,
                       !answer_doze.isEmpty {
                        return answer_doze
                    }
                }
            }
            return "Server error"
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Doze(encryptedCodes_doze: [Int]) -> String {
        let xorKey_doze = 20 // 异或密钥
        let offset_doze = 23 // 字符偏移量
        
        var result_doze = ""
        
        // 第一层：异或解密
        for code_doze in encryptedCodes_doze {
            let charCode_doze = code_doze ^ xorKey_doze
            if let scalar_doze = UnicodeScalar(charCode_doze) {
                result_doze.append(Character(scalar_doze))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_doze = ""
        for char_doze in result_doze.unicodeScalars {
            let charCode_doze = Int(char_doze.value) - offset_doze
            if let scalar_doze = UnicodeScalar(charCode_doze) {
                finalResult_doze.append(Character(scalar_doze))
            }
        }
        
        return finalResult_doze
    }
    
    /// 生成随机字符串
    private func generateRandomString_Doze(length_doze: Int) -> String {
        let letters_doze = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_doze).map { _ in letters_doze.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Doze {
    /// 群组ID
    var gid_doze: Int
    /// 群组简介
    var intro_doze: String
    /// 群组封面
    var cover_doze: String
    /// 加入信息
    var join_doze: String
    /// 消息列表
    var messages_doze: [MessageModel_Doze]
}
