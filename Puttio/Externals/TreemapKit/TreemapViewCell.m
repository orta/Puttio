#import "TreemapView.h"
#import "TreemapViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+Puttio.h"
#import "UIDevice+deviceInfo.h"

@implementation TreemapViewCell

@synthesize valueLabel;
@synthesize textLabel;
@synthesize index;
@synthesize delegate;

#pragma mark -

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [[UIColor whiteColor] CGColor];

        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 4, 40)];
        CGFloat titleSize = [UIDevice isPad]? 20: 14;
        textLabel.font = [UIFont titleFontWithSize:titleSize];
        textLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        textLabel.textAlignment = UITextAlignmentCenter;
        textLabel.textColor = [UIColor whiteColor];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.numberOfLines = 2;
        textLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:textLabel];

        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 4, 20)];
        CGFloat valueSize = [UIDevice isPad]? 16: 12;
        valueLabel.font = [UIFont bodyFontWithSize:valueSize];
        valueLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        valueLabel.textAlignment = UITextAlignmentCenter;
        valueLabel.textColor = [UIColor whiteColor];
        valueLabel.backgroundColor = [UIColor clearColor];
        valueLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        valueLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:valueLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (CGRectGetHeight(self.frame) > 50 && CGRectGetWidth(self.frame) > 50) {
        textLabel.frame = CGRectMake(4, self.frame.size.height / 2 - 30, self.frame.size.width - 8, 60);
        valueLabel.frame = CGRectMake(4, self.frame.size.height / 2 + 30, self.frame.size.width - 8, 20);
    } else {
        textLabel.frame = CGRectNull;
        valueLabel.frame = CGRectNull;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    if (delegate && [delegate respondsToSelector:@selector(treemapViewCell:tapped:)]) {
        [delegate treemapViewCell:self tapped:index];
    }
}

@end
