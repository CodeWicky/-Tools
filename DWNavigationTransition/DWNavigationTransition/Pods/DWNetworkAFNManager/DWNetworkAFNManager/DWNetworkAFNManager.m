//
//  DWNetworkAFNManager.m
//  DWNetwork
//
//  Created by Wicky on 2017/11/16.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWNetworkAFNManager.h"

@implementation DWNetworkUploadFile

-(instancetype)initWithFilePath:(NSString *)filePath name:(NSString *)name loadData:(BOOL)load {
    if (!name.length) {
        return nil;
    }
    if (self = [super init]) {
        _name = name;
        if (load) {
            _fileData = [NSData dataWithContentsOfFile:filePath];
        }
        if (filePath) {
            if ([filePath hasPrefix:@"file://"]) {
                _fileURL = [NSURL fileURLWithPath:filePath];
            } else {
                _fileURL = [NSURL URLWithString:filePath];
            }
        }
        _fileName = filePath.lastPathComponent;
        _mimeType = mimeTypeFromFileName(_fileName);
    }
    return self;
}

-(instancetype)initWithFilePath:(NSString *)filePath name:(NSString *)name {
    return [self initWithFilePath:filePath name:name loadData:NO];
}

-(instancetype)initWithData:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName {
    if (!name.length) {
        return nil;
    }
    if (self = [super init]) {
        _name = name;
        _fileData = data;
        _fileName = fileName;
        _mimeType = mimeTypeFromFileName(fileName);
    }
    return self;
}

-(void)resetPngDataIfNeed {
    if ([_mimeType isEqualToString:@"image/png"] || [_fileName hasSuffix:@".png"] || [_fileURL.absoluteString hasSuffix:@".png"]) {///判定为Png
        if (_fileURL) {
            UIImage * image = nil;
            if ([_fileURL isFileURL]) {
                image = [UIImage imageWithContentsOfFile:_fileURL.absoluteString];
            } else {
                image = [UIImage imageWithData:[NSData dataWithContentsOfURL:_fileURL]];
            }
            _fileData = UIImagePNGRepresentation(image);
        } else if (_fileData) {
            UIImage * image = [UIImage imageWithData:_fileData];
            _fileData = UIImagePNGRepresentation(image);
        }
    }
}

#pragma mark --- tool func ---
static NSString * mimeTypeFromFileName(NSString * fileName) {
    if (![fileName pathExtension]) {
        return nil;
    }
    NSString * ext = [fileName pathExtension];
    NSDictionary * dic = fileType4ExtensionMap();
    NSString * fileType = dic[ext];
    if (!fileType) {
        fileType = dic[@"*"];
    }
    return fileType;
}

static NSDictionary * fileType4ExtensionMap() {
    static NSDictionary * map = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = @{@"*":@"application/octet-stream",
                @"323":@"text/h323",
                @"acx":@"application/internet-property-stream",
                @"acc":@"audio/aac",
                @"ai":@"application/postscript",
                @"aif":@"audio/x-aiff",
                @"aifc":@"audio/x-aiff",
                @"aiff":@"audio/x-aiff",
                @"asf":@"video/x-ms-asf",
                @"asr":@"video/x-ms-asf",
                @"asx":@"video/x-ms-asf",
                @"au":@"audio/basic",
                @"avi":@"video/x-msvideo",
                @"axs":@"application/olescript",
                @"bas":@"text/plain",
                @"bcpio":@"application/x-bcpio",
                @"bin":@"application/octet-stream",
                @"bmp":@"image/bmp",
                @"c":@"text/plain",
                @"cat":@"application/vnd.ms-pkiseccat",
                @"cdf":@"application/x-cdf",
                @"cer":@"application/x-x509-ca-cert",
                @"class":@"application/octet-stream",
                @"clp":@"application/x-msclip",
                @"cmx":@"image/x-cmx",
                @"cod":@"image/cis-cod",
                @"cpio":@"application/x-cpio",
                @"crd":@"application/x-mscardfile",
                @"crl":@"application/pkix-crl",
                @"crt":@"application/x-x509-ca-cert",
                @"csh":@"application/x-csh",
                @"css":@"text/css",
                @"csv":@"text/csv",
                @"dcr":@"application/x-director",
                @"der":@"application/x-x509-ca-cert",
                @"dir":@"application/x-director",
                @"dll":@"application/x-msdownload",
                @"dms":@"application/octet-stream",
                @"doc":@"application/msword",
                @"dot":@"application/msword",
                @"dvi":@"application/x-dvi",
                @"dxr":@"application/x-director",
                @"eps":@"application/postscript",
                @"etx":@"text/x-setext",
                @"evy":@"application/envoy",
                @"exe":@"application/octet-stream",
                @"fif":@"application/fractals",
                @"flr":@"x-world/x-vrml",
                @"gif":@"image/gif",
                @"gtar":@"application/x-gtar",
                @"gz":@"application/x-gzip",
                @"h":@"text/plain",
                @"hdf":@"application/x-hdf",
                @"hlp":@"application/winhlp",
                @"hqx":@"application/mac-binhex40",
                @"hta":@"application/hta",
                @"htc":@"text/x-component",
                @"htm":@"text/html",
                @"html":@"text/html",
                @"htt":@"text/webviewhtml",
                @"ico":@"image/x-icon",
                @"ief":@"image/ief",
                @"iii":@"application/x-iphone",
                @"ins":@"application/x-internet-signup",
                @"isp":@"application/x-internet-signup",
                @"jar":@"application/java-archive",
                @"jfif":@"image/pipeg",
                @"jpe":@"image/jpeg",
                @"jpeg":@"image/jpeg",
                @"jpg":@"image/jpeg",
                @"js":@"application/x-javascript",
                @"json":@"application/json",
                @"latex":@"application/x-latex",
                @"lha":@"application/octet-stream",
                @"lsf":@"video/x-la-asf",
                @"lsx":@"video/x-la-asf",
                @"lzh":@"application/octet-stream",
                @"m13":@"application/x-msmediaview",
                @"m14":@"application/x-msmediaview",
                @"m3u":@"audio/x-mpegurl",
                @"man":@"application/x-troff-man",
                @"mdb":@"application/x-msaccess",
                @"me":@"application/x-troff-me",
                @"mht":@"message/rfc822",
                @"mhtml":@"message/rfc822",
                @"mid":@"audio/mid",
                @"mny":@"application/x-msmoney",
                @"mov":@"video/quicktime",
                @"movie":@"video/x-sgi-movie",
                @"mp2":@"video/mpeg",
                @"mp3":@"audio/mpeg",
                @"mpa":@"video/mpeg",
                @"mpe":@"video/mpeg",
                @"mpeg":@"video/mpeg",
                @"mpg":@"video/mpeg",
                @"mpp":@"application/vnd.ms-project",
                @"mpv2":@"video/mpeg",
                @"ms":@"application/x-troff-ms",
                @"mvb":@"application/x-msmediaview",
                @"nws":@"message/rfc822",
                @"oda":@"application/oda",
                @"p10":@"application/pkcs10",
                @"p12":@"application/x-pkcs12",
                @"p7b":@"application/x-pkcs7-certificates",
                @"p7c":@"application/x-pkcs7-mime",
                @"p7m":@"application/x-pkcs7-mime",
                @"p7r":@"application/x-pkcs7-certreqresp",
                @"p7s":@"application/x-pkcs7-signature",
                @"pbm":@"image/x-portable-bitmap",
                @"pdf":@"application/pdf",
                @"pfx":@"application/x-pkcs12",
                @"pgm":@"image/x-portable-graymap",
                @"pko":@"application/ynd.ms-pkipko",
                @"pma":@"application/x-perfmon",
                @"pmc":@"application/x-perfmon",
                @"pml":@"application/x-perfmon",
                @"pmr":@"application/x-perfmon",
                @"pmw":@"application/x-perfmon",
                @"png":@"image/png",
                @"pnm":@"image/x-portable-anymap",
                @"pot":@"application/vnd.ms-powerpoint",
                @"ppm":@"image/x-portable-pixmap",
                @"pps":@"application/vnd.ms-powerpoint",
                @"ppt":@"application/vnd.ms-powerpoint",
                @"prf":@"application/pics-rules",
                @"ps":@"application/postscript",
                @"pub":@"application/x-mspublisher",
                @"qt":@"video/quicktime",
                @"ra":@"audio/x-pn-realaudio",
                @"ram":@"audio/x-pn-realaudio",
                @"rar":@"application/x-rar-compressed",
                @"ras":@"image/x-cmu-raster",
                @"rgb":@"image/x-rgb",
                @"rmi":@"audio/mid",
                @"roff":@"application/x-troff",
                @"rtf":@"application/rtf",
                @"rtx":@"text/richtext",
                @"scd":@"application/x-msschedule",
                @"sct":@"text/scriptlet",
                @"setpay":@"application/set-payment-initiation",
                @"setreg":@"application/set-registration-initiation",
                @"sh":@"application/x-sh",
                @"shar":@"application/x-shar",
                @"sit":@"application/x-stuffit",
                @"snd":@"audio/basic",
                @"spc":@"application/x-pkcs7-certificates",
                @"spl":@"application/futuresplash",
                @"src":@"application/x-wais-source",
                @"sst":@"application/vnd.ms-pkicertstore",
                @"stl":@"application/vnd.ms-pkistl",
                @"stm":@"text/html",
                @"svg":@"image/svg+xml",
                @"sv4cpio":@"application/x-sv4cpio",
                @"sv4crc":@"application/x-sv4crc",
                @"swf":@"application/x-shockwave-flash",
                @"t":@"application/x-troff",
                @"tar":@"application/x-tar",
                @"tcl":@"application/x-tcl",
                @"tex":@"application/x-tex",
                @"texi":@"application/x-texinfo",
                @"texinfo":@"application/x-texinfo",
                @"tgz":@"application/x-compressed",
                @"tif":@"image/tiff",
                @"tiff":@"image/tiff",
                @"tr":@"application/x-troff",
                @"trm":@"application/x-msterminal",
                @"tsv":@"text/tab-separated-values",
                @"txt":@"text/plain",
                @"uls":@"text/iuls",
                @"ustar":@"application/x-ustar",
                @"vcf":@"text/x-vcard",
                @"vrml":@"x-world/x-vrml",
                @"wav":@"audio/x-wav",
                @"wcm":@"application/vnd.ms-works",
                @"wdb":@"application/vnd.ms-works",
                @"weba":@"audio/webm",
                @"webm":@"video/webm",
                @"webp":@"image/webp",
                @"wks":@"application/vnd.ms-works",
                @"wmf":@"application/x-msmetafile",
                @"wps":@"application/vnd.ms-works",
                @"wri":@"application/x-mswrite",
                @"wrl":@"x-world/x-vrml",
                @"wrz":@"x-world/x-vrml",
                @"xaf":@"x-world/x-vrml",
                @"xbm":@"image/x-xbitmap",
                @"xla":@"application/vnd.ms-excel",
                @"xlc":@"application/vnd.ms-excel",
                @"xlm":@"application/vnd.ms-excel",
                @"xls":@"application/vnd.ms-excel",
                @"xlt":@"application/vnd.ms-excel",
                @"xlw":@"application/vnd.ms-excel",
                @"xml":@"application/xml",
                @"xof":@"x-world/x-vrml",
                @"xpm":@"image/x-xpixmap",
                @"xwd":@"image/x-xwindowdump",
                @"z":@"application/x-compress",
                @"zip":@"application/zip",
                @"3gp":@"video/3gpp",
                @"7z":@"application/x-7z-compressed"
                };
    });
    return map;
}

@end


@implementation DWNetworkAFNManager

#pragma mark --- interface method ---
+(void)GET:(NSString *)URLString
 parameter:(id)parameters
   success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
   failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    DWNetworkAFNManager * m = JSONManager();
    [m request:URLString method:@"GET" parameters:parameters success:success failure:failure];
}

+(void)POST:(NSString *)URLString
 parameters:(id)parameters
    success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
    failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    DWNetworkAFNManager * m = JSONManager();
    [m request:URLString method:@"POST" parameters:parameters success:success failure:failure];
}

+(void)DOWNLOAD:(NSString *)URLString
     parameters:(id)parameters
       savePath:(NSString *)savePath
       progress:(void (^)(NSProgress * _Nonnull))downloadProgressBlock
        success:(void (^)(NSURLSessionDownloadTask * _Nonnull, NSURLResponse * _Nullable, NSURL * _Nullable))success
        failure:(void (^)(NSURLSessionDownloadTask * _Nullable, NSError * _Nonnull))failure {
    DWNetworkAFNManager * m = JSONManager();
    NSURL * (^destination)(NSURL * targetPath, NSURLResponse * response) = nil;
    if (savePath.length) {
        destination = ^NSURL *(NSURL * targetPath, NSURLResponse * response) {
            return [NSURL fileURLWithPath:savePath];
        };
    }
    [m downLoad:URLString method:@"GET" parameters:parameters destination:destination progress:downloadProgressBlock success:success failure:failure];
}

+(void)UPLOAD:(NSString *)URLString
   parameters:(id)parameters
  uploadFiles:(NSArray<DWNetworkUploadFile *> *)files
     progress:(void (^)(NSProgress * _Nonnull))uploadProgressBlock
      success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nonnull))success
      failure:(void (^)(NSURLSessionDataTask * _Nonnull, NSError * _Nonnull))failure {
    DWNetworkAFNManager * m = JSONManager();
    [m upload:URLString method:@"POST" uploadFiles:files parameters:parameters progress:uploadProgressBlock success:success failure:failure];
}

+(instancetype)manager {
    return [[self alloc] initWithSessionConfiguration:nil];
}

-(NSURLSessionDataTask *)request:(NSString *)URLString
                          method:(NSString *)method
                      parameters:(id)parameters
                         success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                         failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    if (!method) {
        method = @"GET";
    }
    NSURLSessionDataTask * task = [self dataTaskWithHTTPMethod:method URLString:URLString parameters:parameters
                                                       success:success failure:failure];
    [task resume];
    return task;
}

-(NSURLSessionDownloadTask *)downLoad:(NSString *)URLString
                               method:(NSString *)method
                           parameters:(id)parameters
                          destination:(NSURL * _Nonnull (^)(NSURL * _Nonnull, NSURLResponse * _Nonnull))destination
                             progress:(void (^)(NSProgress * _Nonnull))downloadProgressBlock
                              success:(void (^)(NSURLSessionDownloadTask * _Nonnull, NSURLResponse * _Nullable, NSURL * _Nullable))success
                              failure:(void (^)(NSURLSessionDownloadTask * _Nullable, NSError * _Nonnull))failure {
    if (!method) {
        method = @"GET";
    }
    NSURLSessionDownloadTask * task = [self downLoadTaskWithHTTPMethod:method URLString:URLString parameters:parameters destination:destination progress:downloadProgressBlock success:success failure:failure];
    [task resume];
    return task;
}

-(NSURLSessionDownloadTask *)downloadWithResumeData:(NSData *)resumeData
                                        destination:(NSURL * _Nonnull (^)(NSURL * _Nonnull, NSURLResponse * _Nonnull))destination
                                           progress:(void (^)(NSProgress * _Nonnull))downloadProgressBlock
                                            success:(void (^)(NSURLSessionDownloadTask * _Nonnull, NSURLResponse * _Nullable, NSURL * _Nullable))success
                                            failure:(void (^)(NSURLSessionDownloadTask * _Nullable, NSError * _Nonnull))failure {
    __block NSURLSessionDownloadTask *downloadTask = nil;
    __weak typeof(self)weakSelf = self;
    downloadTask = [self downloadTaskWithResumeData:resumeData progress:downloadProgressBlock destination:destination completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(downloadTask, error);
            }
        } else {
            if (success) {
                success(downloadTask, response, filePath);
            }
        }
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf invalidateSessionCancelingTasks:NO];
    }];
    [downloadTask resume];
    return downloadTask;
}

-(NSURLSessionUploadTask *)upload:(NSString *)URLString
                           method:(NSString *)method
                             file:(DWNetworkUploadFile *)file
                         progress:(void (^)(NSProgress * _Nonnull))uploadProgressBlock
                          success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nonnull))success
                          failure:(void (^)(NSURLSessionDataTask * _Nonnull, NSError * _Nonnull))failure {
    if (!method || !([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"])) {
        method = @"POST";
    }
    NSURLSessionUploadTask * task = [self uploadTaskWithHTTPMethod:method URLString:URLString file:file progress:uploadProgressBlock success:success failure:failure];
    [task resume];
    return task;
}

-(NSURLSessionUploadTask *)upload:(NSString *)URLString
                           method:(NSString *)method
                      uploadFiles:(NSArray<DWNetworkUploadFile *> *)files
                       parameters:(id)parameters progress:(void (^)(NSProgress * _Nonnull uploadProgress))uploadProgressBlock
                          success:(void (^)(NSURLSessionDataTask * task, id responseObject))success
                          failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure {
    __block NSError * serializationError = nil;
    if (files.count == 0) {
        if (failure) {
            NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: @"No file to upload!"};
            serializationError = [[NSError alloc] initWithDomain:AFURLRequestSerializationErrorDomain code:NSURLErrorBadURL userInfo:userInfo];
            failure(nil,serializationError);
        }
        return nil;
    }
    if (!method || !([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"])) {
        method = @"POST";
    }
    NSURLSessionUploadTask * task = [self uploadTaskWithHTTPMethod:method URLString:URLString parameters:parameters uploadFiles:files progress:uploadProgressBlock success:success failure:failure];
    [task resume];
    return task;
}


#pragma mark --- tool method ---
///To fix memory leak
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                         success:(void (^)(NSURLSessionDataTask * task, id responseObject))success
                                         failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure
{
    NSError *serializationError = nil;
    
    NSMutableURLRequest *request = [self createRequestWithMethod:method URLString:URLString parameters:parameters error:&serializationError failure:failure];
    if (!request) {
        if (failure) {
            failure(nil, serializationError);
        }
        return nil;
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    __weak typeof(self)weakSelf = self;
    dataTask = [self dataTaskWithRequest:request
                          uploadProgress:nil
                        downloadProgress:nil
                       completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                           if (error) {
                               if (failure) {
                                   failure(dataTask, error);
                               }
                           } else {
                               if (success) {
                                   success(dataTask, responseObject);
                               }
                           }
                           __strong typeof(weakSelf)strongSelf = weakSelf;
                           [strongSelf invalidateSessionCancelingTasks:NO];
                       }];
    return dataTask;
}

-(NSURLSessionDownloadTask *)downLoadTaskWithHTTPMethod:(NSString *)method
                                              URLString:(NSString *)URLString
                                             parameters:(id)parameters
                                            destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                               progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                                success:(void (^)(NSURLSessionDownloadTask *task, NSURLResponse * response,NSURL *  filePath))success
                                                failure:(void (^)(NSURLSessionDownloadTask * task, NSError *error))failure {
    NSError *serializationError = nil;
    
    NSMutableURLRequest *request = [self createRequestWithMethod:method URLString:URLString parameters:parameters error:&serializationError failure:failure];
    if (!request) {
        if (failure) {
            failure(nil, serializationError);
        }
        return nil;
    }
    __block NSURLSessionDownloadTask * downloadTask = nil;
    __weak typeof(self)weakSelf = self;
    downloadTask = [self downloadTaskWithRequest:request progress:downloadProgressBlock destination:destination completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(downloadTask, error);
            }
        } else {
            if (success) {
                success(downloadTask, response, filePath);
            }
        }
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf invalidateSessionCancelingTasks:NO];
    }];
    return downloadTask;
}

-(NSURLSessionUploadTask *)uploadTaskWithHTTPMethod:(NSString *)method
                                          URLString:(NSString *)URLString
                                               file:(DWNetworkUploadFile *)file
                                           progress:(void (^)(NSProgress *downloadProgress)) uploadProgressBlock
                                            success:(void (^)(NSURLSessionUploadTask *task, id responseObject))success
                                            failure:(void (^)(NSURLSessionUploadTask * task, NSError *error))failure {
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self createRequestWithMethod:method URLString:URLString parameters:nil error:&serializationError failure:failure];
    if (!file.fileData && !file.fileURL) {
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Can't load data from file:%@", file]};
        serializationError = [[NSError alloc] initWithDomain:AFURLRequestSerializationErrorDomain code:NSURLErrorBadURL userInfo:userInfo];
        if (failure) {
            failure(nil, serializationError);
        }
        return nil;
    }
    __block NSURLSessionUploadTask * uploadTask = nil;
    __weak typeof(self)weakSelf = self;
    void(^completionHandler)(NSURLResponse * _Nonnull , id  _Nullable , NSError * _Nullable ) = ^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(uploadTask, error);
            }
        } else {
            if (success) {
                success(uploadTask, responseObject);
            }
        }
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf invalidateSessionCancelingTasks:NO];
    };
    [file resetPngDataIfNeed];
    if (file.fileData) {
        uploadTask = [self uploadTaskWithRequest:request fromData:file.fileData progress:uploadProgressBlock completionHandler:completionHandler];
    } else {
        uploadTask = [self uploadTaskWithRequest:request fromFile:file.fileURL progress:uploadProgressBlock completionHandler:completionHandler];
    }
    return uploadTask;
}

-(NSURLSessionUploadTask *)uploadTaskWithHTTPMethod:(NSString *)method
                                          URLString:(NSString *)URLString
                                         parameters:(id)parameters
                                        uploadFiles:(NSArray<DWNetworkUploadFile *> *)files
                                           progress:(void (^)(NSProgress *downloadProgress)) uploadProgressBlock
                                            success:(void (^)(NSURLSessionUploadTask *task, id responseObject))success
                                            failure:(void (^)(NSURLSessionUploadTask * task, NSError *error))failure {
    __block NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:method URLString:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [files enumerateObjectsUsingBlock:^(DWNetworkUploadFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj resetPngDataIfNeed];
            if (obj.name.length && obj.fileData) {
                if (obj.fileName.length && obj.mimeType.length) {
                    [formData appendPartWithFileData:obj.fileData name:obj.name fileName:obj.fileName mimeType:obj.mimeType];
                } else {
                    [formData appendPartWithFormData:obj.fileData name:obj.name];
                }
            } else if (obj.name.length && obj.fileURL) {
                NSError *fileError = nil;
                if (obj.fileName && obj.mimeType) {
                    [formData appendPartWithFileURL:obj.fileURL name:obj.name fileName:obj.fileName mimeType:obj.mimeType error:&fileError];
                } else {
                    [formData appendPartWithFileURL:obj.fileURL name:obj.name error:&fileError];
                }
                if (fileError) {
                    serializationError = fileError;
                    *stop = YES;
                }
            } else {
                NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Can't load data from file:%@", obj]};
                serializationError = [[NSError alloc] initWithDomain:AFURLRequestSerializationErrorDomain code:NSURLErrorBadURL userInfo:userInfo];
            }
        }];
    } error:&serializationError];
    if (!request) {
        if (failure) {
            failure(nil, serializationError);
        }
        return nil;
    }
    __block NSURLSessionUploadTask * uploadTask = nil;
    __weak typeof(self)weakSelf = self;
    uploadTask = [self uploadTaskWithStreamedRequest:request progress:uploadProgressBlock completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(uploadTask, error);
            }
        } else {
            if (success) {
                success(uploadTask, responseObject);
            }
        }
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf invalidateSessionCancelingTasks:NO];
    }];
    return uploadTask;
}

-(NSMutableURLRequest *)createRequestWithMethod:(NSString *)method
                                      URLString:(NSString *)URLString
                                     parameters:(id)parameters
                                          error:(NSError * __autoreleasing *)error
                                        failure:(void (^)(__kindof NSURLSessionTask * task, NSError *error))failure {
    NSError * e = *error;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:error];
    if (e || !request) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue?: dispatch_get_main_queue(), ^{
                failure(nil, e);
            });
#pragma clang diagnostic pop
        }
        return nil;
    }
    
    ///登录
    if (self.userName.length && self.password.length) {
        NSData *basicAuthCredentials = [[NSString stringWithFormat:@"%@:%@", self.userName, self.password] dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64AuthCredentials = [basicAuthCredentials base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
        [request setValue:[NSString stringWithFormat:@"Basic %@", base64AuthCredentials] forHTTPHeaderField:@"Authorization"];
    }
    
    return request;
}

#pragma mark --- tool func ---
static inline DWNetworkAFNManager * JSONManager() {
    DWNetworkAFNManager * m = [DWNetworkAFNManager manager];
    m.requestSerializer = [AFJSONRequestSerializer serializer];
    m.responseSerializer = [AFJSONResponseSerializer serializer];
    return m;
}

-(AFHTTPRequestSerializer *)requestSerializer {
    if (!_requestSerializer) {
        _requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    return _requestSerializer;
}

-(void)dealloc {
    NSLog(@"AFNMgr<%p> dealloc",self);
}

@end


