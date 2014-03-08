//
//  ViewLineChart.m
//  YSJViewer
//
//  Created by Kevin Zhang on 14-3-8.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "ViewLineChart.h"

@implementation ViewLineChart

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor grayColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //一个不透明类型的Quartz 2D绘画环境,相当于一个画布,你可以在上面任意绘画
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    /*画线及孤线*/
    //画线
    CGPoint aPoints[2];//坐标点
    aPoints[0] =CGPointMake(100, 180);//坐标1
    aPoints[1] =CGPointMake(230, 180);//坐标2
    
    CGContextSetStrokeColorWithColor(context, [UIColor yellowColor].CGColor);
    CGContextAddLines(context, aPoints, 2);//添加线
    CGContextDrawPath(context, kCGPathStroke); //根据坐标绘制路
}

@end
