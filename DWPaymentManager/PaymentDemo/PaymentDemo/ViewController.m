//
//  ViewController.m
//  PaymentDemo
//
//  Created by Wicky on 2017/8/4.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "ViewController.h"
#import "DWPaymentManager.h"
#import "WXApi.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)unionPay:(id)sender {
    NSString * orderString = @"745200661042109123601";
    
    [DWPaymentManager payWithOrderInfo:orderString payType:DWPaymentTypeUnionPay currentVC:self completion:^(DWPaymentType payType, PayStatus status, NSString *code, NSString *message, id payResult) {
        NSLog(@"Union Pay Result = %@",payResult);
    }];
}
- (IBAction)alipay:(id)sender {
    NSString * orderString = @"app_id=2017072107837708&biz_content=%7B%22out_trade_no%22%3A%22ZFBKJ_170809000000002%22%2C%22product_code%22%3A%22QUICK_MSECURITY_PAY%22%2C%22subject%22%3A%221502262261108%22%2C%22total_amount%22%3A%220.02%22%7D&charset=UTF-8&method=alipay.trade.app.pay&notify_url=http%3A%2F%2Fsettle-sit-api.gomefinance.com.cn%2Fgateway%2Fapi%2FzfbkjAppAsynTransRes.do&sign_type=RSA2&timestamp=2017-08-09+15%3A03%3A48&version=1.0&sign=TZUfTTVo2Hq2b9r%2BSW9w%2BowI80olg0ybLktU08K365jLglxZt1ew9nD6g5L7IP9%2FDmd1jGk%2BpOyErqQ96eL1MhGUmUmFJ7XVdb7YP%2Bs5tyzXIwTsr9Vtu9S3gleCe0l%2FroTBoAixrywIuRKcyF9XLsH4qjW%2FazsAVpWX5mFKS1DuIU7weYvcI2GmOECytuasB1fStPH%2FvifnmLsqzeAdMmEJdKD2HqtBqNFFKA9J6Npd85sRCAxxp751xXqZsk5huQm5D%2BeqXK5qFmIMXq%2BprOm1QQA1kVl7KMCZIMGVmuRmz77WsxsRrpfeWIJEnl9ywUzSJK%2FR4WswjszJYWdp3g%3D%3D";
    
    [DWPaymentManager payWithOrderInfo:orderString payType:DWPaymentTypeAlipay currentVC:self completion:^(DWPaymentType payType, PayStatus status, NSString *code, NSString *message, id payResult) {
        NSLog(@"Alipay Result = %@",payResult);
    }];
}
- (IBAction)weixinPay:(id)sender {
    ///由于尚未接入微信，所以开发者账号等相关资料并不完善，暂时无法模拟支付请求，但相关逻辑已做处理。没意外的话无需调整。
    PayReq *request = [[PayReq alloc] init];
    
    request.partnerId = @"10000100";
    
    request.prepayId= @"1101000000140415649af9fc314aa427";
    
    request.package = @"Sign=WXPay";
    
    request.nonceStr= @"a462b76e7436e98e0ed6e13c64b4fd1c";
    
    request.timeStamp= 1397527777;
    
    request.sign= @"582282D72DD2B03AD892830965F428CB16E7A256";
    
    [DWPaymentManager payWithOrderInfo:request payType:DWPaymentTypeWeiXin currentVC:self completion:^(DWPaymentType payType, PayStatus status, NSString *code, NSString *message, id payResult) {
        NSLog(@"Alipay Result = %@",payResult);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
