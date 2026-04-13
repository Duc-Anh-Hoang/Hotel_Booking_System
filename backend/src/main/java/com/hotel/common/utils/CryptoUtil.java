package com.hotel.common.utils;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;

public class CryptoUtil {

        public static String hmacSHA512(final String key, final String data) {
            return hash("HmacSHA512", key, data);
        }

        public static String hmacSHA256(final String key, final String data) {
            return hash("HmacSHA256", key, data);
        }

        private static String hash(String algorithm, String key, String data) {
            try {
                if (key == null || data == null) {
                    throw new IllegalArgumentException("Key or data cannot be null");
                }
                Mac mac = Mac.getInstance(algorithm);
                byte[] hmacKeyBytes = key.getBytes(StandardCharsets.UTF_8);
                SecretKeySpec secretKey = new SecretKeySpec(hmacKeyBytes, algorithm);
                mac.init(secretKey);

                byte[] dataBytes = data.getBytes(StandardCharsets.UTF_8);
                byte[] result = mac.doFinal(dataBytes);

                StringBuilder sb = new StringBuilder(2 * result.length);
                for (byte b : result) {
                    sb.append(String.format("%02x", b & 0xff));
                }
                return sb.toString();

            } catch (Exception ex) {
                throw new RuntimeException("Failed to generate " + algorithm + " signature", ex);
            }
        }

}

