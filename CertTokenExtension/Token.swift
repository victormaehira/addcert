import CryptoTokenKit

class Token: TKToken, TKTokenDelegate {
    override init(tokenDriver: TKTokenDriver, instanceID: String) {
        super.init(tokenDriver: tokenDriver, instanceID: instanceID)
        delegate = self
    }

    func createSession(_ token: TKToken) throws -> TKTokenSession {
        return TokenSession(token: self)
    }
}
