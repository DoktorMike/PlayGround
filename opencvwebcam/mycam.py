"""Test script for webcam capture via opencv."""
import cv2

cap = cv2.VideoCapture(0)

while True:
    # Capture frame-by-frame and change color and show frame
    ret, frame = cap.read()
    #gray = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    gray = frame
    cv2.imshow("frame", gray)
    if cv2.waitKey(1) & 0xFF == ord("q"):
        break

# When everything done, release the capture
cap.release()
cv2.destroyAllWindows()
