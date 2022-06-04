@available(iOS 13, macOS 10.15, *)
public struct YLKSecurity {}

extension YLKSecurity {
    public static let serviceKey = "YLKSecurity"
}

extension YLKSecurity {
    static public func save(value: String, for key: String, service: String = YLKSecurity.serviceKey) throws {
        try EnclaverHelper.makeAndStoreKey(name: key, requiresBiometry: false)
        guard let secKey = EnclaverHelper.loadKey(name: key) else { return }
        let encryptedPrivateKey = try EnclaverHelper.cypher(key: secKey, value: value)
        _ = try? KeychainHelper.delete(service: serviceKey, account: key)
        try KeychainHelper.save(value: encryptedPrivateKey, service: serviceKey, account: key)
    }
    
    static public func getValue(for key: String, service: String = YLKSecurity.serviceKey) async throws -> String {
        guard let secKey = EnclaverHelper.loadKey(name: key) else {
            throw(EnclaverHelper.SecError.noSecKey)
        }
        let data = try KeychainHelper.read(service: service, account: key)
        let decypherData = try await EnclaverHelper.uncypher(key: secKey, data: data)
        return decypherData
    }
    
    static public func removeValue(for key: String, service: String = YLKSecurity.serviceKey) throws {
        try KeychainHelper.delete(service: service, account: key)
    }
}
