import mediapipe as mp
import cv2

class FindHands():
    def __init__(self, detection_con=0.5, tracking_con=0.5):
        self.mpHands = mp.solutions.mediapipe.python.solutions.hands
        self.hands = self.mpHands.Hands(min_detection_confidence=detection_con, min_tracking_confidence=tracking_con)
        self.mpDraw = mp.solutions.mediapipe.python.solutions.drawing_utils
    
    def getPosition(self, img, index, hand_no=0, draw=True):
        lst = []
        imgRGB = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        results = self.hands.process(imgRGB)
        if results.multi_hand_landmarks:
            if len(results.multi_hand_landmarks) >= hand_no+1:
                for id, lm in enumerate(results.multi_hand_landmarks[hand_no].landmark):
                    if id in index:
                        h, w, c = img.shape
                        x, y = int(lm.x*w), int(lm.y*h)
                        lst.append((x,y))
                if draw:
                    self.mpDraw.draw_landmarks(img, results.multi_hand_landmarks[hand_no], self.mpHands.HAND_CONNECTIONS)
        return lst

    def index_finger_up(self, img, hand_no=0):
        pos = self.getPosition(img, (6,8), draw=False)
        try:
            if pos[0][1] >= pos[1][1]:
                return True
            elif pos[0][1] < pos[1][1]:
                return False
        except:
            return "NO HAND FOUND"
        
    def middle_finger_up(self, img, hand_no=0):
        pos = self.getPosition(img, (10,12), draw=False)
        try:
            if pos[0][1] >= pos[1][1]:
                return True
            elif pos[0][1] < pos[1][1]:
                return False
        except:
            return "NO HAND FOUND"

    def ring_finger_up(self, img, hand_no=0):
        pos = self.getPosition(img, (14,16), draw=False)
        try:
            if pos[0][1] >= pos[1][1]:
                return True
            elif pos[0][1] < pos[1][1]:
                return False
        except:
            return "NO HAND FOUND"

    def little_finger_up(self, img, hand_no=0):
        pos = self.getPosition(img, (18,20), draw=False)
        try:
            if pos[0][1] >= pos[1][1]:
                return True
            elif pos[0][1] < pos[1][1]:
                return False
        except:
            return "NO HAND FOUND"
