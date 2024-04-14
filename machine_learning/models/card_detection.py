import numpy as np
import cv2

def angle_cos(p0, p1, p2):
    d1, d2 = (p0-p1).astype('float'), (p2-p1).astype('float')
    return abs( np.dot(d1, d2) / np.sqrt( np.dot(d1, d1)*np.dot(d2, d2) ) )

def getContours(img,rects):
    imgArea = img.shape[0] * img.shape[1]
    for gray in cv2.split(img):
        for thrs in range(0, 255, 26):
            if thrs == 0:
                bin = cv2.Canny(gray, 0, 50, apertureSize=5)
            else:
                _, bin = cv2.threshold(gray, thrs, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
            
            contours, _ = cv2.findContours(bin, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
            for cnt in contours:
                cnt_len = cv2.arcLength(cnt, True)
                cnt = cv2.approxPolyDP(cnt, 0.02*cnt_len, True)
                cntArea = cv2.contourArea(cnt)
                if len(cnt) == 4 and cntArea > 1000 and cv2.isContourConvex(cnt):
                    cnt = cnt.reshape(-1, 2)
                    max_cos = np.max([angle_cos(cnt[i], cnt[(i+1) % 4], cnt[(i+2) % 4] ) for i in range(4)])
                    if max_cos < 0.1 and cntArea/imgArea < 0.75:
                        rects.append(cnt)

def getIdCard(img_path):
    img = cv2.imread(img_path)
    
    # Transform Image to HSV (Hue"Color", Saturation"Intensity", Value"Brightness") channels
    img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    channels_hsv = cv2.split(img_hsv)
    
    # Applying Gaussian blur to sutration Channel because its effective in the edge detection tasks
    channel_s = channels_hsv[1]
    channel_s = cv2.GaussianBlur(channel_s, (9, 9), 2, 2)
    

    # The purpose of this operation is to normalize or adjust the saturation values for later proceesing
    # Converts the pixel values of the saturation channel to floating-point
    imf = channel_s.astype(np.float32)
    # Scaling and converting images.
    imf = cv2.convertScaleAbs(imf, alpha=0.5, beta=0.5)

    # These lines of code are performing edge detection using the Sobel operator on the saturation channel
    # Horizintal edge detection
    sobx = cv2.Sobel(imf, cv2.CV_32F, 1, 0)
    # Vertical edge detection
    soby = cv2.Sobel(imf, cv2.CV_32F, 0, 1)
    # Squaring the gradients enhances the edges in the image, making them more prominent and easier to detect. 
    # This is a common step in many edge detection algorithms, as it emphasizes regions with strong intensity changes.
    sobx = cv2.multiply(sobx, sobx) 
    soby = cv2.multiply(soby, soby)

    # This operation calculates the approximate absolute gradient magnitude, which represents the strength of edges in the image.
    # It combines the horizontal and vertical gradient information to get a single value representing the overall gradient 
    # magnitude at each pixel.
    grad_abs_val_approx = cv2.pow(sobx + soby, 0.5)    
    # After obtaining the gradient magnitude approximation, a Gaussian blur is applied to smooth the image.
    filtered = cv2.GaussianBlur(grad_abs_val_approx, (9, 9), 2, 2)
    # Once the Gaussian blur is applied, the resulting image needs to be converted to a suitable format for display 
    # or further processin
    sobelImg = cv2.cvtColor((filtered).astype(np.uint8), cv2.COLOR_RGB2BGR)

    # Adjust the kernel size for desired thickness
    kernel = np.ones((3, 3), dtype=np.uint8)  
    # Morphological dilation is a process that expands the boundaries of objects in an image.
    sobelImg = cv2.dilate(sobelImg, kernel, iterations=3)

    rects = []
    getContours(img, rects)
    getContours(sobelImg, rects)
    largest_contour = max(rects, key=cv2.contourArea)
    
    print(len(rects))
    mask = np.zeros_like(img)  # create blank image of same size as input
    cv2.drawContours(mask, [largest_contour], -1, (255, 255, 255), cv2.FILLED)  # fill the contour with white

    # Calculate the area of the bounding rectangle around the card contour
    x, y, w, h = cv2.boundingRect(largest_contour)
    card_area = w * h
    
    # Display the result image
    cv2.imshow('Result', mask)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
#     This function returns how many cms are equal to 1 px
#        Ex : 1px  ->  0.5cm, if the distance between the 2 shoulders in the image is 100px then the shoulder width is 50cm
    return (45.9 / card_area)

if __name__ == '__main__':
    card_area_pixels = getIdCard(r'Path/to/image/file')
    print("cm in one pixel => ", card_area_pixels)

