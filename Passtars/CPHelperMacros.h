//
// CPHelperMacros.h
//

#ifndef _HELPER_MACROS_
#define _HELPER_MACROS_

/* 'n_s' is short for Type Not Specified */

#define isPointInCircle(center, radius, point) \
    /* BOOL isPointInCircle(CGPoint center, CGFloat radius, CGPoint point) */ \
    ((point.x - center.x) * (point.x - center.x) + (point.y - center.y) * (point.y - center.y) <= radius * radius)

#define cstrToObjc(str) /* Using ASCII for string encoding */ \
    /* NSString cstrToObjc(char *str) */ \
    [NSString stringWithCString:str encoding:NSASCIIStringEncoding]

#define currentOrientation() \
    /* UIInterfaceOrientation currentOrientation() */ \
    ([UIApplication sharedApplication].statusBarOrientation)

#define delayBlock(delay, block) /* Avoid comma in 'block' because it will break the macro */ \
    /* void delayBlock(float delay, void (^block)(void)) */ \
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), block)

#define deviceRelatedObj(phone, pad) \
    /* n_s deviceRelatedObj(n_s phone, n_s pad) */ \
    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? phone : pad)

#define orientationRelatedObj(landscape, portrait) \
    /* n_s orientationRelatedObj(n_s landscape, n_s portrait) */ \
    specifiedOrientationRelatedObj(CURRENT_ORIENTATION, landscape, portrait)

#define rectWithCenterAndSize(center, size) \
    /* CGRect rectWithCenterAndSize(CGPoint center, CGSize size) */ \
    CGRectMake(center.x - size.width / 2, center.y - size.height / 2, size.width, size.height)

#define rectContainingCircle(center, radius) \
    /* CGRect rectContainingCircle(CGPoint center, CGFloat radius) */ \
    CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2)

#define specifiedOrientationRelatedObj(orientation, landscape, portrait) \
    /* n_s specifiedOrientationRelatedObj(UIInterfaceOrientation orientation, n_s landscape, n_s portrait) */ \
    (UIInterfaceOrientationIsLandscape(orientation) ? landscape : portrait)

#endif
