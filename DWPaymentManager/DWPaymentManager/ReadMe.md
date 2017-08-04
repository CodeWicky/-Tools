#DWPaymentManager使用方法

###以插件的形式让代码入侵性更小，使用谁引入谁即可。

###关于库的引入
---
使用时**按需在Lib中引入对应支付方式三方库，Plugin中引入对应提供的管理者即可**。例如需支持支付宝，则对应引入Alipay即可。

###关于支付调用
---
支付是统一调用DWPaymentManager的类方法并传入`支付类型`及`订单信息`即可。

```
NSString * orderString = ...
[DWPaymentManager payWithOrderInfo:orderString payType:DWPaymentTypeAlipay currentVC:self completion:^(DWPaymentType payType, id payResult) {
    NSLog(@"Alipay Result = %@",payResult);
}];
```

###关于SDK的扩展及补充
---
当前提供支付宝、微信、广银联三种支付方式。如需额外添加方式，建议继承自抽象类DWAbstractManager。该抽象类提供了支付流程的必要接口，子类需重写其提供的接口，也可按需扩展接口，原接口务必重写。

