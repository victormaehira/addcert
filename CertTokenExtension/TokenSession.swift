import CryptoTokenKit
import Security

class TokenSession: TKTokenSession, TKTokenSessionDelegate {
    static let privateKey = "MIIEowIBAAKCAQEAt/KNX0Kq4LGc/AIVsAisYA2BOImtP7HTL6oB6k9BvJ/PE20YGdpDK3OXvcm1Q/k5b5kmnjdPBAMeTXQe5hiSvxBr0RpWykSB9EqIvRMr+k72/UgxqHdDopCu2LUudK85FkMdlFbO7UMDl9d/YZS1xPHX4i9Cid/+NobCmvy9WbKCQU1x5XjEnDhcntRXTYMnIT+SAib1hKPwM89AsWfQiE30WKU+y1Xxa0D1kxpnSCH+xzrjtWJU2eNoMLN4NOQecU36vCrUh80iLEZLHH5mmVT9NKP6NPe3/oAFOYwwv7fQAQ3x0E/T85yEFqEd9efw/hFTLB1T28RgeG4NaQQbLwIDAQABAoIBAC9yGJThlUGvjlZSE1X8Zrm/wfzbRhyPuXEp4KSXHNWSQs837Gd+rKSghBsn0+FcfzwRvKxCh9b5Fu/Ta8TdwbwWeDjPGmPBl+Ny9iIOt+EwTPS3kldpq8BaoT60PO9L4uWjGhYQ7f60slCP/QMmYFwUJSLqHbeCVweparifSBfCSzc8dH6dC6uOTizSF+6V7nkNU8lfJ9A52yYxK7zOv7AH4iD9hTpHmjyYsT5GDzgXLvZOpB9/WblL8mcy0WQDbSTfTqHSNlHenGXDFvCYv7AcbSoHIdiNHbXX1RjqNLEssdjZhQln2RJ2fFyVfKev2jJeQWuwrIcprQk0+slEo0ECgYEA56yHkRpIYujDQrIYMklAn5CRjasWbdBS6aCvv591SoYAPodN1HoPk6JjkfyJY4T5fBogUWYBxSE9YNT5Das6tUz33HdcbkCxRoC2JjD4HNRhjOU1iORLx+VdIiIWcunEzv8/MD/u6i+pBCofQ6+Bv1bpLBNmV6RUTlhralmZYvMCgYEAy0MeoMcL4SWOJ3JdVGC7upYyAJqf1pXhoiL9Ty9ZreMsXCZlvRG3dNyRlC/WeW5+yXf0Aev6Sc4g0tnFbqy5Q7NaTjqd0Hf7DSf/LAMninP1DhPCGhane0KbwUc0mLYQhRpZ36/tDTqRgNi7I9vV/cPdGb10GsABop53IJpj3dUCgYAVvYUDQtokHf+k1J2cqm8cCi7+gl2adIAzWFblvor9MVH4jC3rkIDBs+1wF6i05BedY75ApTfpTdM6sQGmHLlnpg9kavcLiZqZKR7uuo2t9ugolqHNdM7/tTBmMZi1s+Y6Ho3Jc1ZyN4K+100TxvaABCHhdviVpOAccgOyeTIBrQKBgQDK/T/UHpQdh+zcNhlAj85K+336HnEr0sjfrAO/FbGAt5Nwf6Qw2kWVPkVgcRnGcXPK7bFQTgLJvEIJcBP8gCAQnUe9Qkqii3+7Vss9f/T4Du+W3GKGvUMLFK0Jq3u6WnBLDNLeUgnxoSD4RPk3SW7+m6Dt+Ma/hCrd5VVgyO6c9QKBgFlV2AGeNqpLcL+OwkgMVh04hpLAeKJyaLWhCF2ZTRFtu2+6QyAoRQc8Ey4qkh0Zjho8pH4VL6o9py8yRyJkm6eXB33VOtOOeulyFkPTIzC52dz13sTjM4+cO1gQf7BB9utrIIctvAPDZ7CMhWZ0DNcyseUWleB/63w+qg9yoGim"

    private static var cachedSecKey: SecKey?

    private static func getPrivateSecKey() throws -> SecKey {
        if let key = cachedSecKey { return key }

        let cleanBase64 = privateKey
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: " ", with: "")

        guard let keyData = Data(base64Encoded: cleanBase64) else {
            throw NSError(domain: "CertTokenExtension", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Failed to decode private key base64"
            ])
        }

        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits as String: 2048
        ]

        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(keyData as CFData, attributes as CFDictionary, &error) else {
            let desc = error?.takeRetainedValue().localizedDescription ?? "unknown error"
            throw NSError(domain: "CertTokenExtension", code: -2, userInfo: [
                NSLocalizedDescriptionKey: "Failed to create SecKey: \(desc)"
            ])
        }

        cachedSecKey = secKey
        NSLog("CertTokenExtension: RSA private key loaded successfully")
        return secKey
    }

    override init(token: TKToken) {
        super.init(token: token)
        NSLog(">init do TokenSession")
        print(">init do TokenSession")
        delegate = self
    }

    func tokenSession(
    _ session: TKTokenSession,
    supports operation: TKTokenOperation,
    keyObjectID: Any,
    algorithm: TKTokenKeyAlgorithm
    ) -> Bool {
        switch operation {
        case .signData:
            let ok = algorithm.supportsAlgorithm(.rsaSignatureRaw)
            NSLog("CertTokenExtension: supports signData key=%@ -> %@",
                String(describing: keyObjectID), ok ? "YES" : "NO")
            return ok
        case .decryptData:
            let ok = algorithm.supportsAlgorithm(.rsaEncryptionRaw)
            NSLog("CertTokenExtension: supports decryptData key=%@ -> %@",
                String(describing: keyObjectID), ok ? "YES" : "NO")
            return ok
        default:
            NSLog("CertTokenExtension: supports op=%d -> NO (unhandled)",
                operation.rawValue)
            return false
        }
    }

    func tokenSession(
        _ session: TKTokenSession,
        sign dataToSign: Data,
        keyObjectID: Any,
        algorithm: TKTokenKeyAlgorithm
    ) throws -> Data {
        NSLog("CertTokenExtension: sign requested for key %@ (%d bytes)",
              String(describing: keyObjectID), dataToSign.count)

        let key = try Self.getPrivateSecKey()

        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(
            key,
            .rsaSignatureRaw,
            dataToSign as CFData,
            &error
        ) else {
            let desc = error?.takeRetainedValue().localizedDescription ?? "unknown error"
            NSLog("CertTokenExtension: signing failed: %@", desc)
            throw NSError(domain: "CertTokenExtension", code: -3, userInfo: [
                NSLocalizedDescriptionKey: "Signing failed: \(desc)"
            ])
        }

        NSLog("CertTokenExtension: sign succeeded (%d bytes)", (signature as Data).count)
        return signature as Data
    }

    func tokenSession(
        _ session: TKTokenSession,
        decrypt ciphertext: Data,
        keyObjectID: Any,
        algorithm: TKTokenKeyAlgorithm
    ) throws -> Data {
        NSLog("CertTokenExtension: decrypt requested for key %@ (%d bytes)",
              String(describing: keyObjectID), ciphertext.count)

        let key = try Self.getPrivateSecKey()

        var error: Unmanaged<CFError>?
        guard let plaintext = SecKeyCreateDecryptedData(
            key,
            .rsaEncryptionRaw,
            ciphertext as CFData,
            &error
        ) else {
            let desc = error?.takeRetainedValue().localizedDescription ?? "unknown error"
            NSLog("CertTokenExtension: decryption failed: %@", desc)
            throw NSError(domain: "CertTokenExtension", code: -4, userInfo: [
                NSLocalizedDescriptionKey: "Decryption failed: \(desc)"
            ])
        }

        NSLog("CertTokenExtension: decrypt succeeded (%d bytes)", (plaintext as Data).count)
        return plaintext as Data
    }
}
