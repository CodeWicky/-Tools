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
    NSString * orderString = @"832296957393455071001";
    
    [DWPaymentManager payWithOrderInfo:orderString payType:DWPaymentTypeUnionPay currentVC:self completion:^(DWPaymentType payType, id payResult) {
        NSLog(@"Union Pay Result = %@",payResult);
    }];
}
- (IBAction)alipay:(id)sender {
    NSString * orderString = @"app_id=2017072107837708&biz_content=%7B%22out_trade_no%22%3A%22ZFBKJ_170728000000001%22%2C%22product_code%22%3A%22QUICK_MSECURITY_PAY%22%2C%22subject%22%3A%221501207664345%22%2C%22total_amount%22%3A%220.01%22%7D&charset=UTF-8&method=alipay.trade.app.pay&notify_url=http%3A%2F%2Fsettle-sit-api.gomefinance.com.cn%2Fgateway%2Fapi%2FzfbkjAppAsynTransRes.do&sign_type=RSA2&timestamp=2017-07-28+10%3A07%3A14&version=1.0&sign=gVFQp%2FcjVPBrhdcvKjIRUl7mAVX9AZ3qoKGdjlCZbosAr211Jx1Fz643%2BV7lxCuBTd2EOU6Lo9N61OHKuUiWEfOO0OCpV9nBzgEa7g%2Femyf9d0ov%2FthosVWR%2B69NbuJI%2B8HBfnp%2Fkz07vQgILI54yz6kU20Bt%2FMKlfdABSiB6PksVAME3qPFcAm2JjPnfnsPG1bnlRe2Yxb%2BYrApV%2B9g3S%2F4NBQhIe6Sop2X7KMGeYTFSXg0m9zntMrf5otyycFvekg3KzFVU58ZsXdJIHmLYbxP60CvzqL%2FoUwS1cQQ5x9XMreQT5rG3kU2vMsr8j%2F%2FzQhYiBZMdXl%2Bl8K2T%2B8YAA%3D%3D";
    
    [DWPaymentManager payWithOrderInfo:orderString payType:DWPaymentTypeAlipay currentVC:self completion:^(DWPaymentType payType, id payResult) {
        NSLog(@"Alipay Result = %@",payResult);
    }];
}
- (IBAction)weixinPay:(id)sender {
    ///由于尚未接入微信，所以开发者账号等相关资料并不完善，暂时无法模拟支付请求，但相关逻辑已做处理。没意外的话无需调整。
    [DWPaymentManager payWithOrderInfo:nil payType:DWPaymentTypeWeiXin currentVC:self completion:^(DWPaymentType payType, id payResult) {
        NSLog(@"Alipay Result = %@",payResult);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
