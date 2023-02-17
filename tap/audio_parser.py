import pyaudio
import numpy as np
import pylab
import time
import sys
import matplotlib.pyplot as plt


RATE = 44100
CHUNK = int(RATE/20) # RATE / number of updates per second

def soundplot(stream):
  
   t1=time.time()
   #use np.frombuffer if you face error at this line
   data = np.fromstring(stream.read(CHUNK),dtype=np.int16)
   print(data)

if __name__=="__main__":
    p=pyaudio.PyAudio()
    stream=p.open(format=pyaudio.paInt16,channels=1,rate=RATE,input=True,
                  frames_per_buffer=CHUNK)
    for i in range(sys.maxsize**10):
        soundplot(stream)
    stream.stop_stream()
    stream.close()
    p.terminate()