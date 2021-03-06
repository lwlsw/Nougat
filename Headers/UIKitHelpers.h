#import <UIKit/UIKit.h>
#import <UIKit/UIKit+Private.h>

/**
 * Converts the given `location` from the coordinate system of 
 * @c fromOrientation to the coordinate system of @c toOrientation
 *
 * @param location The given location
 * @param bounds The portrait size of the rect containing the point
 * @param fromOrientation The prior orientation
 * @param toOrientation The current orientation
 * @return The location translated the current orientation
 */
static inline CGPoint NUAConvertPointFromOrientationToOrientation(CGPoint location, CGSize bounds, UIInterfaceOrientation fromOrientation, UIInterfaceOrientation toOrientation) {
    if (fromOrientation == toOrientation) {
        return location;
    }

    CGFloat portraitX = location.x;
    CGFloat portraitY = location.y;
    switch (fromOrientation) {
        case UIInterfaceOrientationUnknown:
        case UIInterfaceOrientationPortrait:
            break;
        case UIInterfaceOrientationPortraitUpsideDown: {
            portraitX = bounds.width - location.x;
            portraitY = bounds.height - location.y;
            break;
        }
        case UIInterfaceOrientationLandscapeLeft: {
            portraitX = location.y;
            portraitY = bounds.height - location.x;
            break;
        }
        case UIInterfaceOrientationLandscapeRight: {
            portraitX = bounds.width - location.y;
            portraitY = location.x;
            break;
        }
    }

    CGFloat rotatedX = portraitX;
    CGFloat rotatedY = portraitY;
    switch (toOrientation) {
        case UIInterfaceOrientationUnknown:
        case UIInterfaceOrientationPortrait:
            break;
        case UIInterfaceOrientationPortraitUpsideDown: {
            rotatedX = bounds.width - portraitX;
            rotatedY = bounds.height - portraitY;
            break;
        }
        case UIInterfaceOrientationLandscapeLeft: {
            rotatedX = bounds.height - portraitY;
            rotatedY = portraitX;
            break;
        }
        case UIInterfaceOrientationLandscapeRight: {
            rotatedX = portraitY;
            rotatedY = bounds.width - portraitX;
            break;
        }
    }

    return CGPointMake(rotatedX, rotatedY);
}

/**
 * In iOS 10, mainScreen's bounds do not properly adjust for orientation
 * SpringBoard retains its orientation and ignores any orientation changes of current apps
 * Not sure if this only applies to iOS 10 iphones, more testing is required
 *
 * @param orientation Current orientation
 * @return Screen bounds adjusted to the given orientation
 */
static inline CGRect NUAScreenBoundsAdjustedForOrientation(UIInterfaceOrientation orientation) {
    CGRect referenceBounds = [UIScreen mainScreen]._referenceBounds;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return CGRectMake(0, 0, CGRectGetHeight(referenceBounds), CGRectGetWidth(referenceBounds));
    } else {
        return referenceBounds;
    }
}

/**
 * Get the current screen width adjusted for 
 * @c orientation
 *
 * @param orientation Current orientation
 * @return The screen width for the provided orientation
 */
static inline CGFloat NUAGetScreenWidthForOrientation(UIInterfaceOrientation orientation) {
    return CGRectGetWidth(NUAScreenBoundsAdjustedForOrientation(orientation));
}

/**
 * Get the current screen height adjusted for 
 * @c orientation
 *
 * @param orientation Current orientation
 * @return The screen height for the provided orientation
 */
static inline CGFloat NUAGetScreenHeightForOrientation(UIInterfaceOrientation orientation) {
    return CGRectGetHeight(NUAScreenBoundsAdjustedForOrientation(orientation));
}