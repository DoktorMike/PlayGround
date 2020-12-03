import cv2 as cv
import torch

# Load model
model = (
    torch.hub.load("ultralytics/yolov5", "yolov5s", pretrained=True).fuse().autoshape()
)  # for PIL/cv2/np inputs and NMS

# Get camera 0 is my usb cam and 2 is my internal one
cap = cv.VideoCapture(2)


def drawbboxes(img, bboxes, labels):
    """Draw bounding boxed onto the image

    :img: Image to draw the bboxes on
    :bboxes: Bounding boxes to draw which should be given as (top-left, bottom-right)
    :returns: An image with bounding boxes drawn

    """
    thickness = 5
    color = (0, 255, 0)
    for bbox in bboxes:
        # top-left is x1, y1; bottom-right is x2,y2
        x1, y1, x2, y2, prob, category = (
            int(bbox[0]),
            int(bbox[1]),
            int(bbox[2]),
            int(bbox[3]),
            round(bbox[4], 2),
            labels[int(bbox[5])],
        )
        img = cv.rectangle(img, (x1, y1), (x2, y2), color, thickness)
        img = cv.putText(
            img,
            f"Label: {category} ({prob})",
            (x1, y1 - 10),
            0,
            0.5,
            color,
            thickness // 3,
        )
    return img


while True:

    success, img = cap.read()

    # Predict
    img2 = cv.cvtColor(img, cv.COLOR_BGR2RGB)
    results = model(img2, size=640)  # includes NMS
    results.print()  # print results to screen

    # Visualize
    img = drawbboxes(img, results.pred[0].tolist(), results.names)
    cv.imshow("Camera", img)

    if cv.waitKey(1) and 0xFF == ord("q"):
        break
