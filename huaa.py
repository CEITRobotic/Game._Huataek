import cv2
import mediapipe as mp
import pyautogui

# เรียกใช้ face mesh จาก MediaPipe
mp_face_mesh = mp.solutions.face_mesh
face_mesh = mp_face_mesh.FaceMesh(static_image_mode=False, max_num_faces=1)

# เปิดกล้อง
cap = cv2.VideoCapture(0)
screen_width, screen_height = pyautogui.size()

while True:
    ret, frame = cap.read()
    if not ret:
        break

    # กลับภาพ (mirror)
    frame = cv2.flip(frame, 1)
    h, w, _ = frame.shape
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

    # ตรวจจับใบหน้า
    result = face_mesh.process(rgb_frame)

    if result.multi_face_landmarks:
        for face_landmarks in result.multi_face_landmarks:
            # จุดที่ประมาณอยู่กลางหน้าผาก (ใช้เป็นตำแหน่งหัว)
            forehead = face_landmarks.landmark[10]
            x = int(forehead.x * w)
            y = int(forehead.y * h)

            # แสดงจุดบนกล้อง
            cv2.circle(frame, (x, y), 5, (0, 255, 0), -1)

            # แปลงพิกัดกล้องเป็นพิกัดหน้าจอ
            screen_x = int(forehead.x * screen_width)
            screen_y = int(forehead.y * screen_height)

            # ควบคุมเม้าส์
            pyautogui.moveTo(screen_x, screen_y)

cap.release()
cv2.destroyAllWindows()
