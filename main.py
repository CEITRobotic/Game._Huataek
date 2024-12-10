import cv2
import mediapipe as mp  
import pyautogui 
import keyboard

# Initialize MediaPipe for face and eye tracking
mp_face_mesh = mp.solutions.face_mesh  
face_mesh = mp_face_mesh.FaceMesh(min_detection_confidence=0.5, min_tracking_confidence=0.5)

# Get screen dimensions for cursor mapping
screen_width, screen_height = pyautogui.size() 

# Start webcam
cap = cv2.VideoCapture(0)

# Game control variables  
blink_counter = 0 
left_eye_closed = False 

def is_eye_closed(landmarks, left=True):
    """Detect if the left or right eye is closed."""
    eye_top = landmarks[386] if left else landmarks[159]  # Adjusted for Mediapipe's landmarks
    eye_bottom = landmarks[374] if left else landmarks[145] 
    return abs(eye_top.y - eye_bottom.y) < 0.02

while cap.isOpened():
    ret, frame = cap.read()
    if not ret: 
        break 

    # Flip the frame horizontally for a mirror effect
    frame = cv2.flip(frame, 1) 

    # Convert the frame to RGB for MediaPipe
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = face_mesh.process(rgb_frame)

    if results.multi_face_landmarks:
        landmarks = results.multi_face_landmarks[0].landmark

        # Map nose tip (index 1) to screen coordinates for cursor control
        nose_tip = landmarks[1]
        x = int(nose_tip.x * screen_width)
        y = int(nose_tip.y * screen_height)
        pyautogui.moveTo(x, y)

        # Detect if the left eye is closed to simulate a "click"
        if is_eye_closed(landmarks, left=True):  
            if not left_eye_closed:
                left_eye_closed = True 
                pyautogui.click()
        else:
            left_eye_closed = False

        # Detect if the right eye is closed to simulate a "keyboard press"
        if is_eye_closed(landmarks, left=False):
            blink_counter += 1
            if blink_counter == 1:  # Press the space key on the first blink
                keyboard.press_and_release('space')  
        else:
            blink_counter = 0

 
    # Quit on pressing 'q' 
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release the webcam and close all windows
cap.release()
cv2.destroyAllWindows()
 