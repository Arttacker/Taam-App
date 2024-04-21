import os.path

import cv2
import numpy as np
import matplotlib.pyplot as plt
from machine_learning.global_paths import IMAGES


def angle_cos(p0, p1, p2):
    d1, d2 = (p0 - p1).astype('float'), (p2 - p1).astype('float')
    return abs(np.dot(d1, d2) / np.sqrt(np.dot(d1, d1) * np.dot(d2, d2)))


def get_contours(img, rects):
    img_area = img.shape[0] * img.shape[1]
    for gray in cv2.split(img):
        for thrs in range(0, 255, 26):
            if thrs == 0:
                bin = cv2.Canny(gray, 0, 50, apertureSize=5)
            else:
                _, bin = cv2.threshold(gray, thrs, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

            contours, _ = cv2.findContours(bin, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
            for cnt in contours:
                cnt_len = cv2.arcLength(cnt, True)
                cnt = cv2.approxPolyDP(cnt, 0.02 * cnt_len, True)
                cnt_area = cv2.contourArea(cnt)
                if len(cnt) == 4 and cnt_area > 1000 and cv2.isContourConvex(cnt):
                    cnt = cnt.reshape(-1, 2)
                    max_cos = np.max([angle_cos(cnt[i], cnt[(i + 1) % 4], cnt[(i + 2) % 4]) for i in range(4)])
                    if max_cos < 0.1 and cnt_area / img_area < 0.75:
                        rects.append(cnt)


def get_pixel_measure(img_path):
    # Read the image
    img = cv2.imread(img_path)
    # img = cv2.resize(img, (224, 224), interpolation=cv2.INTER_AREA)

    # Transform Image to HSV channels
    img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    channels_hsv = cv2.split(img_hsv)

    # Gaussian blur on saturation Channel
    channel_s = channels_hsv[1]
    channel_s = cv2.GaussianBlur(channel_s, (9, 9), 2, 2)
    imf = channel_s.astype(np.float32)
    imf = cv2.convertScaleAbs(imf, alpha=0.5, beta=0.5)

    sobx = cv2.Sobel(imf, cv2.CV_32F, 1, 0)
    soby = cv2.Sobel(imf, cv2.CV_32F, 0, 1)
    sobx = cv2.multiply(sobx, sobx)
    soby = cv2.multiply(soby, soby)

    grad_abs_val_approx = cv2.pow(sobx + soby, 0.5)
    filtered = cv2.GaussianBlur(grad_abs_val_approx, (9, 9), 2, 2)
    sobel_img = cv2.cvtColor((filtered).astype(np.uint8), cv2.COLOR_RGB2BGR)

    kernel = np.ones((3, 3), dtype=np.uint8)
    sobel_img = cv2.dilate(sobel_img, kernel, iterations=3)

    rects = []
    try:
        get_contours(img, rects)
        get_contours(sobel_img, rects)
        largest_contour = max(rects, key=cv2.contourArea)
    except ValueError:
        print('No cards')
        return

    mask = np.zeros_like(img)
    cv2.drawContours(mask, [largest_contour], -1, (255, 255, 255), cv2.FILLED)

    x, y, w, h = cv2.boundingRect(largest_contour)

    # Create figure and axes
    fig, ax = plt.subplots()

    # Convert BGR image to RGB for display in matplotlib
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    # Display the image
    ax.imshow(img_rgb)

    # Create a rectangle patch
    rect = plt.Rectangle((x, y), w, h, linewidth=2, edgecolor='r', facecolor='none')

    # Add the rectangle to the axes
    ax.add_patch(rect)

    # Set the title and show the plot
    ax.set_title('Detected Object')
    plt.show()

    # Ex : 1px  ->  0.5cm
    img_h, img_w, _ = img.shape
    scale_factor_w = 224 / img_w
    scale_factor_h = 224 / img_h
    w = w * scale_factor_w
    h = h * scale_factor_h
    return w, h


if __name__ == '__main__':
    image_path = os.path.join(IMAGES, 'test_1.jpeg')
    get_pixel_measure(image_path)

