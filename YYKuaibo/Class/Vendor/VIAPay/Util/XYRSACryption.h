//
//  XYRSACryption.h
//  XYCryption
//
//  Created by 潘显跃 on 16/1/24.
//  Copyright © 2016年 Panda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XYRSACryption : NSObject

/**
 *  Load pubilc key form file
 *
 *  @param derFilePath The path for public key
 */
- (void)loadPublicKeyFromFile:(NSString*)derFilePath;


/**
 *  Load public key form data
 *
 *  @param derData The data for public key
 */
- (void)loadPublicKeyFromData:(NSData*)derData;

/**
 *  Load private key form file
 *
 *  @param p12FilePath The path for private key
 *  @param p12Password The password for private key
 */
- (void)loadPrivateKeyFromFile:(NSString*)p12FilePath password:(NSString*)p12Password;

/**
 *  Load private key form data
 *
 *  @param p12Data The data for private key
 *  @param p12Password The password for private key
 */
- (void)loadPrivateKeyFromData:(NSData*)p12Data password:(NSString*)p12Password;

/**
 *  Return the SecKeyRef of public key
 *
 *  @param derData The data for public key
 *
 *  @return A SecKeyRef
 */
- (SecKeyRef)getPublicKeyRefrenceFromeData:(NSData*)derData;

/**
 *  Return the SecKeyRef of private key
 *
 *  @param p12Data  The data for private key
 *  @param password The password for private key
 *
 *  @return A SecKeyRef
 */
- (SecKeyRef)getPrivateKeyRefrenceFromData:(NSData*)p12Data password:(NSString*)password;

/**
 *  RSA encrypt with string
 *
 *  @param string The string for encrypt
 *
 *  @return The string of encrypted
 */
- (NSString*)rsaEncryptString:(NSString*)string;

/**
 *  RSA encrypt with data
 *
 *  @param data The data for encrypt
 *
 *  @return The data of encryted
 */
- (NSData*)rsaEncryptData:(NSData*)data;

/**
 *  RSA decrypt with string
 *
 *  @param string The string for decrypt
 *
 *  @return The string of decrypted
 */
- (NSString*)rsaDecryptString:(NSString*)string;

/**
 *  RSA decrypt with data
 *
 *  @param data The data for decrypt
 *
 *  @return The data of decrypted
 */
- (NSData*)rsaDecryptData:(NSData*)data;


@end
